-------------------------------------
----------- REQUEST HANDLER ---------
-------------------------------------

local Handler = require('randotracker\\localServer\\handler')

local requestHandler = {}

-- Helps setting the real route of a file
local function get_relative_path(file_path)
    file_path = file_path or ''
    return 'randotracker/localServer/htdocs' .. file_path
end

-- Transforms a response into a string to pass
local function get_formatted_http_response(handler)
    local binary_content = handler.content
    -- We assume that other types are already in binary
    --if type(handler.content) == 'string' then
    --    binary_content = string.byte("asdfjkhkjasdf")
    --end
    -- The code string
    local status_string = 'Not Found'
    if handler.status == 200 then
        status_string = 'OK'
    end

    return  'HTTP/1.1 ' .. handler.status .. ' ' .. status_string .. '\n' ..
            'Content-Length: ' .. handler.contentLength .. '\n' ..
            'Content-Type: ' .. handler.contentType .. '\n\n' ..
            handler.content
end


-- Gets the response
local function respond(options)
    return get_formatted_http_response(options['handler'])
end

-- Head request
local function do_HEAD(request)
    return ''
end

-- Post request
local function do_POST(request)
    return ''
end

-- Get request
local function do_GET(request)
    local handler
    -- If the client asked for a file
    local file = request.file
    if file then
        -- Data requests
        if file.extension == '' then
            handler = Handler:create('data')
            handler:find(file)
        -- Images
    elseif file.extension == '.png' or file.extension == '.jpg' then
            handler = Handler:create('image')
            handler:find(file)
        -- Lua files (blocks the request)
        elseif file.extension == '.lua' then
            handler = Handler:create('bad_request')
        -- Other files (including HTML)
        else
            handler = Handler:create('static')
            handler:find(file)
        end
    else
        handler = Handler:create('bad_request')
    end
    -- Responds
    return respond({ handler = handler })
end

-- splits a string into a table
local function split(s, delimiter)
    result = {};
    for match in (s .. delimiter):gmatch('(.-)' .. delimiter) do
        table.insert(result, match)
    end
    return result
end

-- A request class
local Request = {}
Request.__index = Request
function Request:create(req_str)
    local req = {}
    setmetatable(req, Request)
    -- Initializes
    -- We ignore the headers for now since this is a simple server
    local parts = split(split(req_str, '\n')[1], ' ')    
    -- If there are two points, then it's a header
    if #parts == 3 then
        req.type = parts[1]
        req.version = parts[3]
        -- Gets the file
        local root = get_relative_path()
        if parts[2] == '/' then
            req.file = { path = root .. '/index.html', extension = '.html' }
        else
            -- Divides the string into file and query
            local file_parts = split(parts[2], '?')
            local left_side = file_parts[1]
            local right_side = file_parts[2] -- Can be nil

            -- Extension can be empty
            local extension = left_side:match('^.+(%..+)$') or ''

            -- Gets the queries
            local query = {}
            if right_side then
                -- Gets each query
                for _, value in pairs(split(right_side, '&')) do
                    local q = split(value, '=')
                    query[q[1]] = q[2]
                end
            end
            -- the data does not require the root
            local path
            if extension == '' then path = left_side else path = root .. left_side end
            -- Sets the file
            req.file = { path = path, extension = extension, query = query }
        end
    end

    return req
end

-- The function that handles requests
function requestHandler.handleRequest(req_str)
    -- When the client sends empty requests
    if req_str == '' then return '' end
    local request = Request:create(req_str)

    local response = ''
    -- Sends to the right request
    if      request.type == 'HEAD' then response = do_HEAD(request)
    elseif  request.type == 'POST' then response = do_POST(request)
    elseif  request.type == 'GET' then response = do_GET(request)
    else print('Request is invalid.') end

    return response
end

return requestHandler