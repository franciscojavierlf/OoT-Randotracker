--------------------------------------
-------- HANDLER ---------------------
--------------------------------------


local Handler = {}
Handler.__index = Handler


-- sets the information to show if there was an error
function set_bad_request(handler)
    handler.content = '404 Not Found'
    handler.contentLength = 15
    handler.type = 'static'
    handler.contentType = 'text/html'
    handler.status = 404
end

function Handler:create(type)
    local handler = {}
    setmetatable(handler, self)
    -- The different types of files
    handler.__contentTypes = {
        ['.html'] = 'text/html',
        ['.js'] = 'text/javascript',
        ['.css'] = 'text/css',
        ['.jpg'] = 'image/jpeg',
        ['.png'] = 'image/png',
        ['notfound'] = 'text/plain'
    }

    if type == 'data' or type == 'image' or type == 'static' then
        handler.content = ''
        handler.contentLength = 0
    -- A bad request
    else
        set_bad_request(handler)
    end
    return handler
end

function Handler:find(file)
    -- It's a data request
    if file.extension == '' and file.path == '/data' then
        -- Checks if there is a "Link"
        if Link then
            -- Checks if there is a query
            if file.query then
                local err
                success, self.content = pcall(Link.processQuery, file.query)
                if not success then
                    print('Error. Is the emulator running?')
                    self.content = ''
                    self.status = 404
                else
                    self.status = 200
                end
                self.contentLength = string.len(self.content)
                self.contentType = 'text/html'
            else
                set_bad_request(self)
                self.content = 'Bad query format.'
                self.contentLength = string.len(self.content)
            end
        else
            set_bad_request(self)
            self.content = 'No Link found. Try to start the game.'
            self.contentLength = string.len(self.content)
        end
    -- A file request
    else
        local f = io.open(file.path, "rb")
        -- The file was found
        if f then
            --for line in f:lines() do
                --self.content = self.content .. line .. '\n'
            --end
            self.content = f:read('*a')
            self.contentType = self.__contentTypes[file.extension]
            self.contentLength = string.len(self.content)
            self.status = 200
            f:close()
        -- The file was not found
        else
            set_bad_request(self)
        end
    end
end

return Handler