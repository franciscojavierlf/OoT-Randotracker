-- This script does not modify anything on the game (although it can ;)).
-- It only reads and passes the information.


---------------------------------
------ LINK FILE ----------------
---------------------------------

local Link = {

    -- Library for accessing ram
    __oot = require('randotracker\\helpers\\oot'),
    -- The context of the world
    __context = oot.ctx,
    -- Sav has the data of the saved game, but in BizHawk 2.3
    -- every time you get an item the game saves itself, thus
    -- facilitating our code (we don't have to access the
    -- memory blindly).
    __data = oot.sav,

    -- Variables for interacting with the world
    __awake = false,
    __previousScene = nil,

    -- The scenes of the game
    scenes = {
        kokiri_forest = { id = '85' },
        midos_house = { id = '40' }
    },

    -- Saves the things we have collected in the world
    -- scenes
        -- types
            -- flags
    entries = {},

    -- Here we save the names
    dictionary = {

        ----- STATS -----

        max_health              = { name = 'max_health', category = 'stats' },
        current_health          = { name = 'cur_health', category = 'stats' },
        magic_meter_level       = { name = 'magic_meter_level', category = 'stats' },
        current_magic           = { name = 'cur_magic', category = 'stats' },
        magic_meter_size        = { name = 'magic_meter_size', category = 'stats' },
        have_magic              = { name = 'have_magic', category = 'stats' },
        have_double_magic       = { name = 'have_double_magic', category = 'stats' },
        biggoron_sword_durable  = { name = 'biggoron_sword_durable', category = 'stats' },
        double_defense          = { name = 'double_defense', category = 'stats' },
        rupees                  = { name = 'rupees', category = 'stats' },
        double_defense_hearts   = { name = 'double_defense_hearts', category = 'stats' },
        beans_purchased         = { name = 'beans_purchased', category = 'stats' },

        ----- INVENTORY -----

        deku_sticks     = { name = 'deku_sticks', category = 'inventory' },
        deku_nuts       = { name = 'deku_nuts', category = 'inventory' },
        bombs           = { name = 'bombs', category = 'inventory' },
        bow             = { name = 'bow', category = 'inventory' },
        fire_arrow      = { name = 'fire_arrow', category = 'inventory' },
        dins_fire       = { name = 'dins_fire', category = 'inventory' },
        slingshot       = { name = 'slingshot', category = 'inventory' },
        ocarina         = { name = 'ocarina', category = 'inventory' },
        bombchus        = { name = 'bombchus', category = 'inventory' },
        hookshot        = { name = 'hookshot', category = 'inventory' },
        ice_arrow       = { name = 'ice_arrow', category = 'inventory' },
        farores_wind    = { name = 'farores_wind', category = 'inventory' },
        boomerang       = { name = 'boomerang', category = 'inventory' },
        lens_of_truth   = { name = 'lens_of_truth', category = 'inventory' },
        magic_beans     = { name = 'magic_beans', category = 'inventory' },
        megaton_hammer  = { name = 'megaton_hammer', category = 'inventory' },
        light_arrow     = { name = 'light_arrow', category = 'inventory' },
        nayrus_love     = { name = 'nayrus_love', category = 'inventory' },
        bottle_1        = { name = 'bottle1', category = 'inventory' },
        bottle_2        = { name = 'bottle2', category = 'inventory' },
        bottle_3        = { name = 'bottle3', category = 'inventory' },
        bottle_4        = { name = 'bottle4', category = 'inventory' },
        adult_trade     = { name = 'adult_trade', category = 'inventory' },
        child_trade     = { name = 'child_trade', category = 'inventory' },

        ----- EQUIPMENT -----
        
        kokiri_tunic        = { name = 'kokiri_tunic', category = 'equipment' },
        goron_tunic         = { name = 'goron_tunic', category = 'equipment' },
        zora_tunic          = { name = 'zora_tunic', category = 'equipment' },
        kokiri_boots        = { name = 'kokiri_boots', category = 'equipment' },
        iron_boots          = { name = 'iron_boots', category = 'equipment' },
        hover_boots         = { name = 'hover_boots', category = 'equipment' },
        kokiri_sword        = { name = 'kokiri_sword', category = 'equipment' },
        master_sword        = { name = 'master_sword', category = 'equipment' },
        biggoron_sword      = { name = 'biggoron_sword', category = 'equipment' },
        broken_sword_icon   = { name = 'broken_sword_icon', category = 'equipment' },
        deku_shield       	= { name = 'kokiri_shield', category = 'equipment' },
        hylian_shield       = { name = 'hylian_shield', category = 'equipment' },
        mirror_shield       = { name = 'mirror_shield', category = 'equipment' },
    }
}


-- splits a string into a table
local function split(s, delimiter)
    result = {};
    for match in (s .. delimiter):gmatch('(.-)' .. delimiter) do
        table.insert(result, match)
    end
    return result
end

-- Checks if a value is in a table
local function contains(table, value)
    for _, val in pairs(table) do
        if val == value then return true end
    end
    return false
end

-- Copies two files
local function copyFiles(patha, pathb)
    -- Reads first file
    local fa = io.open(patha, 'r')
    if fa then
        local text = fa:read('*a')
        fa:close()
        -- Writes second file
        local fb = io.open(pathb, 'w')
        if fb then
            fb:write(text)
            fb:close()
        end
    end
end

-- Deletes a file
local function deleteFile(path)
    os.remove(filename)
end

-- Cleans a file
local function cleanFile(path)
    local f = io.open(path, 'w')
    if f then f:close() end
end


-- Gets the save file for the game
local function getSavePath()
    return 'randotracker\\saves\\' .. gameinfo.getromname() .. '.dat'
end


-- Saves an entry to reload next time
local function saveEntry(scene, type, flag, path)
    path = path or getSavePath()
    local f = io.open(path, 'a')
    if f then
        f:write('s=' .. scene .. ',t=' .. type .. ',f=' .. flag .. '\n')
        f:close()
    end
end


-- Saves every entry
local function saveEntries()
    -- Creates a temp file
    local temp = 'randotracker\\saves\\temp.dat'
    cleanFile(temp) -- Cleans any temp
    for scene, types in pairs(Link.entries) do
        for type, flags in pairs(types) do
            for _, flag in pairs(flags) do
                -- Writes to temp
                saveEntry(scene, type, flag, temp)
            end
        end
    end
    -- We then save to the original
    copyFiles(temp, getSavePath())
    -- And deletes the temp file
    delteFile(temp)
end


-- Adds an entry
local function addEntry(scene, type, flag, onDisk)
    onDisk = onDisk or true
    if not Link.entries[scene] then Link.entries[scene] = {} end
    if not Link.entries[scene][type] then Link.entries[scene][type] = {} end

    -- Checks if we have already the entry
    if contains(Link.entries[scene][type], flag) then return end

    -- Inserts the value
    table.insert(Link.entries[scene][type], flag)
    -- Saves to disk
    if onDisk then
        saveEntry(scene, type, flag)
    end
end


-- Loads entries
local function loadEntries()
    local path = getSavePath()
    local f = io.open(path, 'r')
    if f then
        for line in f:lines() do
            -- Extracts the variables
            local parts = split(line, ',')
            local res = {}
            local var
            for _, val in pairs(parts) do
                var = split(val, '=')
                res[var[1]] = var[2]
            end
            -- Adds the entry
            addEntry(res['s'], res['t'], res['f'], false)
		end
		f:close()
    end
end


-- Removes an entry
local function removeEntry(scene, type, flag)
    -- We check if the input is correct
    if not Link.entries[scene] or not Link.entries[scene][type] then return end
    for i, val in pairs(Link.entries[scene][type]) do
        if val == flag then
            table.remove(Link.entries[scene][type], i)
            -- We save the whole entries
            saveEntries()
        end
    end
end

-- Removes every entry
local function removeEntries(onDisk)
    onDisk = onDisk or true

    for i, _ in pairs(Link.entries) do
        table.remove(Link.entries, i)
    end

    if onDisk then
        cleanFile(getSavePath())
    end
end

-- Checks if the current status corresponds to the saved one
local function cleanScene(scene, checkDisk)
    -- This tells us if we reload from the disk and then check
    checkDisk = checkDisk or false
    if checkDisk then
        -- We delete entries only from memory
        removeEntries(false)
        -- Then we reload from the file
        loadEntries()
    end

    local check = false
    -- Adds
    if scene.entries then
        for type, flags in pairs(scene.entries) do
            if flags then
                for _, flag in pairs(flags) do
                    if Link.entries[scene.id] and Link.entries[scene.id][type] then
                        check = contains(Link.entries[scene.id][type], flag)
                    end
                    -- The flag is not in Link
                    if not check then
                        addEntry(scene.id, type, flag)
                    end
                end
            end
        end
    end
    -- Removes
    check = false
    if Link.entries[scene.id] then
        for type, flags in pairs(Link.entries[scene.id]) do
            if flags then
                for _, flag in pairs(flags) do
                    if scene.entries[type] then
                        check = contains(scene.entries[type], flag)
                    end
                    -- The flag is not in rom
                    if not check then
                        removeEntry(scene.id, type, flag)
                    end
                end
            end
        end
    end
end

-- Checks if Link has an item
function Link.getItemStatus(item)
    local s
    -- The items without category
    if item.category == 'stats' then
        s = Link.__data[item.name]
    else
        s = Link.__data[item.category][item.name]
    end
    return s
end

-- Listens to any changes and acts upon it
local previous_scene = nil
local DELAY = 50
local delay = DELAY
local cleaning = true
local function listen_world()
    local current_scene = {}
    -- Gets information about the scene
    current_scene.id = Link.__context.cur_scene
    current_scene.entries = {}

    -- Gets the chests (We are assuming max 10 per room)
    current_scene.entries.chest = {}
    for i = 0, 20 do
        if oot.ctx.chest_flags:rawget(i):get() == true then
            table.insert(current_scene.entries.chest, i)
        end
    end

    -- We are in the same scene, so we can listen to changes
    if previous_scene ~= nil and current_scene.id == previous_scene.id then
        clean = true
        -- We use this delay to ignore the loading stage, when memory is mixed
        if delay <= 0 then
            -- We clean the new scene to eliminate any irregularities
            if cleaning then
                cleanScene(current_scene)
                cleaning = false
            end

            -- Listens to changes
            for type, flags in pairs(current_scene.entries) do
                if flags then
                    for _, flag in pairs(flags) do
                        if previous_scene.entries[type] and
                        not contains(previous_scene.entries[type], flag) then
                            -- Saves the entry
                            addEntry(current_scene.id, type, flag)
                        end
                    end
                end
            end
        else delay = delay - 1 end
    else
        delay = DELAY
        cleaning = true
    end

    -- Updates scene
    previous_scene = current_scene
end

-- Wakes up Link (listens to changes in the world)
function Link.wakeUp()
    Link.__awake = true
    -- Loads the file
    loadEntries()
    while Link.__awake do
        local a, b = pcall(listen_world)
        if b then print(b) end
        coroutine.yield()
    end
end

-- Link gets asleep (stops listening)
function Link.sleep()
    Link.__awake = false
end

-- Most important function. Processes a query and returns the result
function Link.processQuery(query)
    local err = 'Err'
    -- We need a req value
    if not query['req'] then return err end
    -- Information about an item
    if query['req'] == 'item' then
        -- We need the name of the item
        if not query['name'] then return err end
        -- Returns the information
        local item = Link.dictionary[string.lower(query['name'])]
        return Link.getItemStatus(item)
    -- Information about an object
    elseif query['req'] == 'object' then
        -- We need the name of the object
        if not query['name'] then return err end
        local object = Link.dictionary[string.lower(query['name'])]
        return Link.getObjectStatus
    end
    -- Wrong request
    return err
end


-------------------------------------
------ MAIN -------------------------
-------------------------------------


-- Skips one frame to let the game run
local function nextFrame()
    -- If game is paused, then yield will not frame advance
    emu.yield()
    emu.yield()
end


local threads = {}
local server = require('randotracker\\localServer\\server')

-- Link listens to changes in the world
local link_thread = coroutine.create(Link.wakeUp)

-- Runs the server in another thread
local server_thread = coroutine.create(server.open)


-- Will only run if there is a rom loaded
if gameinfo.getromname() ~= 'Null' then
    table.insert(threads, link_thread)
    --table.insert(threads, server_thread)
else
    print('ROM is not loaded.')
end

-- Global function to stop server
function stop()
    server.close()
end


---------------
-- MAIN LOOP --
---------------
local status, res
while true do
	-- No threads
	if #threads == 0 then break end
	-- Iterates through each thread
	for i = 1, #threads do
		status, err = coroutine.resume(threads[i])
		-- Thread is finished
		if not status then
			table.remove(threads, i)
			break
		end
	end
	-- Lets the emulator run in the background
	nextFrame()
end

print('Stopped.')