local byte_commands = {}

function checksum(...)
    local sum = 0
    for k, v in pairs{...} do sum = sum + v end
    cksum = (sum<256) and sum or (sum%256)
    return cksum
end

function byte_commands.service_off()
    return string.char(171, 4, 0, 0, 0, 131, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 172)
end

function byte_commands.bind(channel)
    cksum = checksum(171, 2, 0, 0, channel, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    return string.char(171, 2, 0, 0, channel, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, cksum, 172)
end

function byte_commands.unbind(channel)
    cksum = checksum(171, 2, 0, 0, channel, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    return string.char(171, 2, 0, 0, channel, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, cksum, 172)
end

function byte_commands.switch(ctr, channel, id1, id2, id3, id4)
    cksum = checksum(171, 2, ctr, 0, channel, 4, 0, 0, 0, 0, 0, id1, id2, id3, id4)
    return string.char(171, 2, ctr, 0, channel, 4, 0, 0, 0, 0, 0, id1, id2, id3, id4, cksum, 172)
end

function byte_commands.on(ctr, channel, id1, id2, id3, id4)
    cksum = checksum(171, 2, ctr, 0, channel, 2, 0, 0, 0, 0, 0, id1, id2, id3, id4)
    return string.char(171, 2, ctr, 0, channel, 2, 0, 0, 0, 0, 0, id1, id2, id3, id4, cksum, 172)
end

function byte_commands.off(ctr, channel, id1, id2, id3, id4)
    cksum = checksum(171, 2, ctr, 0, channel, 0, 0, 0, 0, 0, 0, id1, id2, id3, id4)
    return string.char(171, 2, ctr, 0, channel, 0, 0, 0, 0, 0, 0, id1, id2, id3, id4, cksum, 172)
end

return byte_commands
