-- Require
wifiModule = require("noo_wifi")
parserModule = require("parsers")
uartModule = require("noo_uart")
commands = require("byte_commands")
db = require("storage")

-- Credentials
SSID = "YOUR SSID NAME"
PASSWORD = "YOUR PASSWORD"
MQTT_SERVER = "m21.cloudmqtt.com"
MQTT_SERVER_PORT = 16487
MQTT_USER = "noo"
MQTT_PASS = "noo"

-- Setup
wifiModule.setup(SSID, PASSWORD)
uartModule.setup()

local LAST_ACTION

uart.on("data", 17,
    function(data)
        local rx_a = ''
        local rx_b = ''
        for i = 1, 17 do
            c = data:sub(i, i)
            if i < 9 then
                rx_a = rx_a..string.byte(c)..':'
            elseif i >= 9 then
                rx_b = rx_b..string.byte(c)..':'
            end
        end
        
        answer_code, channel, cmd = parserModule.split_rx_a(rx_a)
        data3, id1, id2, id3, id4 = parserModule.split_rx_b(rx_b)

        m:publish("mqtt_buddy/sys", 'mtrf64> received RX '..rx_a..rx_b, 0, 0)
        --m:publish("mqtt_buddy/sys", 'mtrf64> received PARCED a/b '..answer_code..' '..channel..' '..cmd..' '..id1..' '..id2..' '..id3..' '..id4..' '..data3, 0, 0)

        -- answer_code=3 means bind success
        if answer_code == '3' then  
            m:publish("mqtt_buddy/sys", 'mtrf64> BINDING. chan '..channel..' addr '..id1..':'..id2..':'..id3..':'..id4, 0, 0)
            db.add_device(channel, id1, id2, id3, id4)
            m:publish("mqtt_buddy/sys", 'mtrf64> BINDED', 0, 0)
        -- data 192 or 193 while unbinding means unbind success
        -- more specific we are interested in the 6th bit
        -- 11000001
        -- ^         service mode enabled
        --  ^        unbind seccess
        --        ^  device on/off (0/1)
        elseif LAST_ACTION == 'unbind' and (data3 == '192' or data3 == '193') then
            m:publish("mqtt_buddy/sys", 'mtrf64> UNBINDING> chan '..channel..' addr '..id1..':'..id2..':'..id3..':'..id4, 0, 0)
            db.remove_device(channel, id1, id2, id3, id4)
            m:publish("mqtt_buddy/sys", 'mtrf64> UNBINDED', 0, 0)
        end
end, 0)

-- mqtt
function register_myself()  
    m:subscribe("mqtt_buddy/noolight/#", 0, function(conn) 
    print ("subscribed to MQTT server")
    m:publish("mqtt_buddy/sys", 'subscribed to MQTT server', 0, 0)
    end)
end

function reconnect_mqtt()
    m:connect(MQTT_SERVER, MQTT_SERVER_PORT, 0, function(conn) register_myself() end) 
end

m = mqtt.Client("MQTT_BUDDY_ESP", 120, MQTT_USER, MQTT_PASS)

m:on("connect", function(client) print ("connected MQTT server") end)
m:on("offline", function(client) reconnect_mqtt() end)
m:on("message", function(client, topic, data)
    channel, action = parserModule.split_topic(topic)
    LAST_ACTION = action
    if tonumber(channel) ~= nil then
        if action == 'bind' then uart.write(0, commands.bind(channel))
        elseif action == 'unbind' then uart.write(0, commands.unbind(channel))
        elseif action:match("^%d+-%d+-%d+-%d+") ~= nil then
            id1, id2, id3, id4 = parserModule.split_address(action)
            LAST_ACTION = 'addr_switch'
            if data == 'switch' then uart.write(0, commands.switch(8, channel, id1, id2, id3, id4))
            elseif data == 'on' then uart.write(0, commands.on(8, channel, id1, id2, id3, id4))
            elseif data == 'off' then uart.write(0, commands.off(8, channel, id1, id2, id3, id4))
            end
        elseif action == 'chan_switch' then
            if data == 'switch' then uart.write(0, commands.switch(0, channel, 0, 0, 0, 0))
            elseif data == 'on' then uart.write(0, commands.on(0, channel, 0, 0, 0, 0))
            elseif data == 'off' then uart.write(0, commands.off(0, channel, 0, 0, 0, 0))
            end
        elseif action == 'devices' and data == 'GET' then
            devices = db.get_devices(channel)
            if devices then m:publish("mqtt_buddy/sys", devices, 0, 0) end
        end
    end
end)

m:connect(MQTT_SERVER, MQTT_SERVER_PORT, 0, function(conn) register_myself() end) 

--reconnect each hours to mqtt
-- milisesonds N = 1000 milisesonds * 60 = minutes
-- reconnect each hour
tmr.alarm(5, 3600000, tmr.ALARM_AUTO, function() reconnect_mqtt() end)
