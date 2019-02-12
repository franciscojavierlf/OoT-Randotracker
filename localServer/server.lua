----------------------------------
----- SERVER FILE ----------------
----------------------------------


local socket = require('socket')
local host = nil
local requestHandler = require('randotracker\\localServer\\requestHandler')
local runThread = nil

-- Our server
local server = {}
server.ip = nil
server.port = nil
server.maxLogs = 1
server.__clients = {}
server.__running = false

-- Listens to a client
local function listen_clients()
    -- Waits for the connection from the client
    local client, err = host:accept()
    if client then
        -- We don't want to get stucked on requests
        client:settimeout(0)
        client:setoption('linger', {['on']=false, ['timeout']=0})
        -- Receives request
        local request = ''
        local req, err
        -- Hears the full request
        local reading = true
        while reading do
            req, err = client:receive()
            -- End of the request
            if err or req == '' then
                reading = false
            else request = request .. req .. '\n' end
        end
        --print('request...')
        --print(request)
        -- Responds
        local response = requestHandler.handleRequest(request)
        client:send(response)
        --print('response...')
        --print(response)
        -- Finalizes the response
        client:close()
    end
end

-- Checks if the server is opened
function server.isOpened()
    return not server.__running
end

-- Starts the server
function server.open(ip, port)
    server.ip = ip or 'localhost'
    server.port = port or 8000
    -- The socket transformed into a host
    host = socket.bind(server.ip, server.port, server.maxLogs)
    -- We don't want to block ourselves
    host:settimeout(0)
	local _, setport = host:getsockname()
    print('Created server on ' .. server.ip .. ":" .. setport)
    print('Put this direction in your browser to view the content.')
    server.__running = true
    -- Starts listening to clients
    while server.__running do
        listen_clients()
        coroutine.yield()
    end
    -- Closes the host
    host:close()
    print('Server closed.')
end

-- Closes the server
function server.close()
    -- Closes every client
    for _, client in pairs(server.__clients) do
        client:close()
    end
    server.__clients = {}
    server.__running = false
end

return server