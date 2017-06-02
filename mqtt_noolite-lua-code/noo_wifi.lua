local noo_wifi = {}

-- WIFI setup
function noo_wifi.setup(name, pass)

    wifi.setmode(wifi.STATION)
    wifi.sta.config(name, pass)
    wifi.sta.connect()
    
    tmr.alarm(0, 1000, 1, function() 
            if wifi.sta.getip() == nil then 
                print("IP unavaiable, Waiting...")                                 
            else 
                tmr.stop(0)
                print("Config done, IP is "..wifi.sta.getip())
                print("mac : "..wifi.sta.getmac())
            end 
    end)
end
return noo_wifi
