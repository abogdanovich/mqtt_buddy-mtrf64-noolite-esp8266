local parsers = {}

function parsers.split_topic(str)
    -- mqtt_buddy/noolight/<int:channel>
    -- mqtt_buddy/noolight/<int:channel>/<XX-XX-XX-XX:address>
    -- mqtt_buddy/noolight/<int:channel>/bind
    -- mqtt_buddy/noolight/<int:channel>/unbind
    -- mqtt_buddy/noolight/<int:channel>/devices
    str = string.sub(str, 21)
    str = str .. '/__'
    
    a, b = str:match("([^/]+)/([^/]+)")
    if b == '__' then b = 'chan_switch' end
    return a, b
end

function parsers.split_address(address)
    address = address .. '-'
    id1, id2, id3, id4 = address:match("([^-]+)-([^-]+)-([^-]+)-([^-]+)")
    return id1, id2, id3, id4
end

function parsers.split_rx(rx)
    _, _, answer_code, _, channel, cmd, _, _, _, _, _, id1, id2, id3, id4, _, _ = rx:match("([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+)")
    return answer_code, channel, cmd, id1, id2, id3, id4
end

function parsers.split_rx_a(rx)
    _, _, answer_code, _, channel, cmd, _, _ = rx:match("([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+)")
    return answer_code, channel, cmd
end

function parsers.split_rx_b(rx)
    _, data3, _, id1, id2, id3, id4, _, _ = rx:match("([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+)")
    return data3, id1, id2, id3, id4
end

return parsers
