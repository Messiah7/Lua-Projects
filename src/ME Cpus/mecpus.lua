---
--- Made for the Advanced Peripherals documentation - Can be used in production
--- Created by Srendi - Created by Srendi - https://github.com/SirEndii
--- DateTime: I literally have no clue
--- Link: https://docs.intelligence-modding.de/1.18/peripherals/me_bridge/
---

mon = peripheral.find("monitor")
me = peripheral.find("meBridge")
data = {
    cpus = 0,
    oldCpus = 0,
    crafting = 0,
    bytes = 0,
    bytesUsed = 0
}

local firstStart = true

local label = "ME Crafting CPUs"

local monX, monY

os.loadAPI("mecpus/api/bars.lua")

function prepareMon()
    mon.clear()
    monX, monY = mon.getSize()
    if monX < 38 or monY < 25 then
        error("Monitor is too small, we need a size of 39x and 26y minimum.")
    end
    mon.setBackgroundColor(colors.black)
    mon.setCursorPos((monX / 2) - (#label / 2), 1)
    mon.setTextScale(1)
    mon.write(label)
    mon.setCursorPos(1, 1)
    drawBox(2, monX - 1, 3, monY - 10, "CPU's", colors.gray, colors.lightGray)
    drawBox(2, monX - 1, monY - 8, monY - 1, "Stats", colors.gray, colors.lightGray)
    addBars()
end

function addBars()
    cpus = me.getCraftingCPUs()
    for i = 1, #cpus do
        x = 5 * i
        full = (cpus[i].storage / 65536) + cpus[i].coProcessors
        bars.add("" .. i, "ver", full, cpus[i].coProcessors, -1 + x, 5, 4, monY - 16, colors.purple, colors.lightBlue)
        mon.setCursorPos(x + 1, monY - 11)
        --mon.write(string.format(i))
    end
    bars.construct(mon)
    bars.screen()
end

function drawBox(xMin, xMax, yMin, yMax, title, bcolor, tcolor)
    mon.setBackgroundColor(bcolor)
    for xPos = xMin, xMax, 1 do
        mon.setCursorPos(xPos, yMin)
        mon.write(" ")
    end
    for yPos = yMin, yMax, 1 do
        mon.setCursorPos(xMin, yPos)
        mon.write(" ")
        mon.setCursorPos(xMax, yPos)
        mon.write(" ")
    end
    for xPos = xMin, xMax, 1 do
        mon.setCursorPos(xPos, yMax)
        mon.write(" ")
    end
    mon.setCursorPos(xMin + 2, yMin)
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(tcolor)
    mon.write(" ")
    mon.write(title)
    mon.write(" ")
    mon.setTextColor(colors.white)
end

function clear(xMin, xMax, yMin, yMax)
    mon.setBackgroundColor(colors.black)
    for xPos = xMin, xMax, 1 do
        for yPos = yMin, yMax, 1 do
            mon.setCursorPos(xPos, yPos)
            mon.write(" ")
        end
    end
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function getUsage()
    return (data.crafting * 100) / data.cpus
end

function comma_value(n) -- credit http://richard.warburton.it
    local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)$')
    return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end

function updateStats()
    clear(3, monX - 3, monY - 5, monY - 2)
    --print("CPUs: ".. data.cpus)
    --print("busy: ".. data.crafting)
    mon.setCursorPos(4, monY - 6)
    mon.write("CPUs: " .. data.cpus)
    mon.setCursorPos(4, monY - 5)
    mon.write("Busy: " .. data.crafting)
    mon.setCursorPos(4, monY - 4)
    mon.write("Busy in percent: " .. math.floor(getUsage()) .. "%")
    mon.setCursorPos(4, monY - 3)
    if monX > 39 then
        mon.write("Bytes(Used|Total): " .. comma_value(data.bytesUsed) .. " | " .. comma_value(data.bytes))
    else
        mon.write("Bytes(Used|Total):")
        mon.setCursorPos(4, monY - 2)
        mon.write(comma_value(data.bytesUsed) .. " | " .. comma_value(data.bytes))
    end
    if tablelength(bars.getBars()) ~= data.cpus then
        clear(3, monX - 3, 4, monY - 12)
        shell.run("reboot")
    end
    oldCpus = cpus
    firstStart = false
end

prepareMon()

function job()
    cpus = {}
    for k in pairs(me.getCraftingCPUs()) do
        table.insert(cpus, k)
    end
    data.cpus = 0
    data.crafting = 0
    data.bytes = 0
    data.bytesUsed = 0
    table.sort(cpus)
    for i = 1, #cpus do
        local k, v = cpus[i], me.getCraftingCPUs()[cpus[i]]
        data.cpus = data.cpus + 1
        data.bytes = data.bytes + v.storage
        if v.isBusy then
            data.bytesUsed = data.bytesUsed + v.storage
            data.crafting = data.crafting + 1
        end

-- What a mess, but it works, so i won't change
        cpuBusy = me.getCraftingCPUs()
        for i = 1, #cpuBusy do
            x = 5 * i
            full = (cpuBusy[i].storage / 65536) + cpuBusy[i].coProcessors
            if cpuBusy[i].isBusy == true then
                bars.add("" .. i, "ver", full, cpuBusy[i].coProcessors, -1 + x, 5, 4, monY - 16, colors.red, colors.red)
            else
                bars.add("" .. i, "ver", full, cpuBusy[i].coProcessors, -1 + x, 5, 4, monY - 16, colors.green,
                    colors.green)
            end
            mon.setCursorPos(x + 1, monY - 11)
        end
        bars.construct(mon)
        bars.screen()
-- end of mess
        -- print(i, v.coProcessors, v.isBusy, v.storage/65536)
    end
    updateStats()
    sleep(1)
end

-- credit PavelKom https://github.com/SirEndii/Lua-Projects/issues/7#issuecomment-2322801431
while true do                      -- Infinite loop
    local status, err = pcall(job) -- https://www.lua.org/pil/8.4.html
    if not status then             -- On error
        mon = peripheral.find("monitor") -- Update monitor
        me = peripheral.find("meBridge") -- Update ME Bridge
        -- print(err)
        sleep(1)
    end
end
