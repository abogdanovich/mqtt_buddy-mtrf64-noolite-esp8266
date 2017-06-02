storage = {}

function storage.get_devices(channel)
    if file.open('devices.'..channel, 'r') then
        data = file.read()
        file.close()
    end
    return data
end

function storage.add_device(channel, id1, id2, id3, id4)
    if file.open('devices.'..channel, 'a+') then
        file.writeline(channel..':'..id1..':'..id2..':'..id3..':'..id4)
        file.close()
    end
end

function storage.remove_device(channel, id1, id2, id3, id4)
    file_name = 'devices.'..channel
    address = channel..':'..id1..':'..id2..':'..id3..':'..id4..'\n'
    fd = file.open(file_name, 'r')
    if fd then
        content = fd:read(); fd.close(); fd = nil
    end
    if content then
        print(content)
        content = string.gsub(content, address, '')
        file.remove(file_name)
        fd = file.open(file_name, 'a+')
        if fd then
          fd:write(content); fd:close()
        end
    end
end
    
return storage
