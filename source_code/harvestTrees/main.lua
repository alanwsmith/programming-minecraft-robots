local lib = require("/lib")
local config = lib.loadConfig()

-- Note: if the game shuts off in
-- between the two turtle turns
-- it doesn't correct for that
-- and will miss by 90 degrees
-- until it's corrected, but the
-- height stuff should still
-- be fine. 

config.levels = 10
config.treeHeight = 5
config.treeLeaves = 1
config.treeEmptySpace = 1
config.treeDirt = 1
config.sleepTop = 180
config.sleepBottom = 900
config.iteration = 1

if not config.currentLevel then
    config.currentLevel = 1
end

if not config.currentSleep then
    config.currentSleep = 0
end

if not config.direction then
    config.direction = "up"
end

local goDown = function(c) 
    while turtle.detectDown() do
        turtle.digDown()
    end
    turtle.down()
    c.currentLevel = c.currentLevel - 1
end

local goUp = function(c) 
    while turtle.detectUp() do
        turtle.digUp()
    end
    turtle.up()
    c.currentLevel = c.currentLevel + 1
end

local processLevel = function(c)
    print(c.direction .. " - Level: " .. c.currentLevel)

    local levelHeight = config.treeHeight +
    config.treeLeaves +
    config.treeEmptySpace +
    config.treeDirt

    local adjustedLevel = c.currentLevel

    while adjustedLevel > levelHeight do
        adjustedLevel = adjustedLevel - levelHeight
    end

    local currentLevelHeight = 0

    for treeBlock = 1, c.treeHeight do
        currentLevelHeight = currentLevelHeight + 1
        if currentLevelHeight == adjustedLevel then
            if c.direction == "up" then
                    print("- FOUND TREE")
                    turtle.dig()
                    turtle.turnRight()
                    turtle.turnRight()
                    turtle.dig()
                    return ture
            elseif c.direction == "down" then
                print("Down: " .. treeBlock .. " " .. c.treeHeight)
                if currentLevelHeight == 1 then
                    turtle.suck()
                    if lib.placeItemForward("minecraft:birch_sapling") then
                        print("- Planted sapling")
                    else 
                        print("- Out of saplings")
                    end
                    turtle.turnRight()
                    turtle.turnRight()
                    turtle.suck()
                    if lib.placeItemForward("minecraft:birch_sapling") then
                        print("- Planted sapling")
                    else 
                        print("- Out of saplings")
                    end
                else 
                    print("- Skipping tree space")
                end
            else
                print("ERROR IN DIRECTION")
            end
        end
    end

    for leavesBlock = 1, c.treeLeaves do
        currentLevelHeight = currentLevelHeight + 1
        if currentLevelHeight == adjustedLevel then
            print("- FOUND LEAVES")
            return ture
        end
    end

    for emptySpace = 1, c.treeEmptySpace do
        currentLevelHeight = currentLevelHeight + 1
        if currentLevelHeight == adjustedLevel then
            print("- FOUND EMPTY SPACE")
            return ture
        end
    end

    for treeDirt = 1, c.treeDirt do
        currentLevelHeight = currentLevelHeight + 1
        if currentLevelHeight == adjustedLevel then
            print("- FOUND DIRT")
            return ture
        end
    end
    return false
end

local main = function(c)

    print("STARTING")

    -- setup
    c.active = true
    local levelHeight = config.treeHeight +
        config.treeLeaves +
        config.treeEmptySpace +
        config.treeDirt 
    local maxHeight = levelHeight * c.levels

    local requiredRoundTripFuel = (maxHeight * 2) + 200

    local keepGoing = true

    -- main loop
    while keepGoing do
        processLevel(c)
        if c.direction == "up" then
            if c.currentLevel < maxHeight then
                print("Still going up")
                goUp(c)
            elseif c.currentLevel == maxHeight then
                print("At the top. Sleeping...")
                sleep(c.sleepTop)
                c.direction = "down"
            else
                print("Went too far up")
                c.direction = "down"
            end
        elseif c.direction == "down" then
            if c.currentLevel > 1 then
                print("Still going down")
                goDown(c)
            elseif c.currentLevel == 1 then
                print("At the bottom. Sleeping...")
                turtle.turnLeft()
                turtle.suckUp()
                lib.dumpItem("minecraft:birch_log")
                lib.dumpItem("minecraft:stick")
                turtle.turnRight()
                sleep(c.sleepBottom)
                c.direction = "up"
            else
                print("Went too far down")
                c.direction = "up"
            end
        else
            print("ERROR HAPPEND WITH DIRECTION")
        end
        lib.saveConfig(config)
        if c.direction == "up" then
            if turtle.getFuelLevel() < requiredRoundTripFuel then
                keepGoing = false
            end
        end
    end    
end

main(config)



    
    
    -- local doSleep = function(c)
    --     print("Sleeping From: " .. config.currentSleep .. " To: " .. c.sleepTime)
    --     print("For iteration: " ..config.iteration)
    --     for asleep = config.currentSleep, c.sleepTime do
    --         sleep(1)
    --     end
    --     config.iteration = config.iteration + 1
    --     -- c.status = "chopUp"
    -- end


-- local chopUp = function(c)
--     -- print("chopUp")
--     for level = 1, c.levels do
--         print("Ascending level: " .. level)
--         for treeBlock = 1, c.treeHeight do
--             print("- Cutting tree")
--             turtle.dig()
--             turtle.turnRight()
--             turtle.turnRight()
--             turtle.dig()
--             goUp(c)
--         end
--         for leaveBlock = 1, c.treeLeaves do
--             print("- Skipping leaves")
--             goUp(c)
--         end
--         for emptySpace = 1, c.treeEmptySpace do
--             print("- Skipping empty space")
--             goUp(c)
--         end
--         for dirtSpace = 1, c.treeDirt do
--             print("- Skipping dirt")
--             goUp(c)
--         end
--     end
--     c.status = "plantDown"
-- end


-- local plantDown = function(c)
--     -- print("plantDown")
--     for level = c.levels, 1, -1  do
--         print("Decending level: " .. level)
--         for dirtSpace = c.treeDirt, 1, -1 do
--             print("- Skipping dirt")
--             goDown(c)
--         end
--         for emptySpace = 1, c.treeEmptySpace do
--             print("- Skipping empty space")
--             goDown(c)
--         end
--         for leaveBlock = 1, c.treeLeaves do
--             print("- Skipping leaves")
--             goDown(c)
--         end
--         for treeBlock = c.treeHeight, 1, -1 do
--             if treeBlock == 1 then
--                 sleep(3)
--                 if lib.placeItemForward("minecraft:birch_sapling") then
--                     print("- Planted sapling")
--                 else
--                     print("- Out of saplings")
--                 end
--             else 
--                 print("- Skipping planting")
--             end
--             goDown(c)
--         end
--     end
--     c.status = "doSleep"
-- end





-- local check_tree = function()
--     if details.name() == "minecraft:birch_log" then
--         turtle.dig()
--     end
--     -- remove saplings so they don't grow 
--     -- and stop other saplings from falling
--     if details.name() == "minecraft:birch_sapling" then
--         turtle.dig()
--     end
-- end


-- local chop_up = function()
--     for level = 1, config.levelHeight do
--         for dir = 1, 2 do
--             check_tree()
--             turtle.suck()
--             turtle.turnRight()
--             turtle.turnRight()
--         end
--         while turtle.detectUp() do
--             turtle.digUp()
--         end
--         turtle.up()
--     end
-- end

-- local plant_down = function()
--     for level = 1, config.levelHeight do
--         while turtle.detectDown() do
--             turtle.digDown()
--         end
--         turtle.down()
--     end
--     for dir = 1, 2 do
--         turtle.suck()
--         if details.name() ~= "minecraft:birch_sapling" then
--             place.itemForward("minecraft:birch_sapling")
--         end
--         turtle.turnRight()
--         turtle.turnRight()
--     end
-- end

-- local do_harvest = function(c)
--     for level = 1, c.levels do
--         chop_up()
--     end
--     sleep(c.sleep)
--     for level = 1, c.evels do
--         plant_down()
--     end
-- end

-- local fuel_level = turtle.getFuelLevel()
-- if fuel_level > 500 then
--     do_harvest()
-- else
--     print("Not enough fuel")
-- end
