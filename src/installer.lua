---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by info.
--- DateTime: 02.05.2021 14:48
---

local githuburl = "https://raw.githubusercontent.com/Seniorendi/Lua-Projects/master/src/Programs.txt"

programs = {}

local args = { ... }

function exit(message, error)
    term.setTextColor(error and colors.red or colors.yellow)
    term.write(message .. "\n")
    term.setTextColor(colors.white)
    if error then
        shell.exit()
    end
end

function loadSources()
    local dl, error = http.get(githuburl)
    if dl then
        text = dl.readAll()
        text:gsub("\n", "")
        text:gsub("\\", "")
        programs = textutils.unserialize(text)
    end
end

function startupInstall(program)
    if programs[program] == nil then
        error("Program '" .. program .. "' does not exists!")
    end

    local startup = programs[program]["startup"]

    if fs.exists("startup") then
        fs.delete("startup")
    end
    local sfile = fs.open("startup", "w")
    sfile.write(startup)
    sfile.close()

end

function showHelp()
    term.setTextColor(colors.lightGray)
    print("---- [Installer] ----")
    term.setTextColor(colors.white)
    print("installer help              - Shows this menu")
    print("installer list <program>    - Installs a program")
    print("installer install <program> - Installs a program")
    print("installer update <program>  - Updates a program")
    print("installer delete <program>  - Deletes a program")
    print("installer config <program>  - Configures a program after it is installed")
    term.setTextColor(colors.lightGray)
    print("---- [=========] ----")
    term.setTextColor(colors.white)
end

function install(name) 
    
end

function showList()
    for name, table in pairs(programs) do
        term.setTextColor(colors.green)
        write(name)
        term.setTextColor(colors.lightGray)
        write(" -- ")
        term.setTextColor(colors.cyan)
        write(table.desc .. "\n")
    end
end

function executeInput()
    if #args <= 0 then
        showHelp()
    end
    if #args >= 1 and args[1] == "help" then
        showHelp()
    elseif #args >= 1 and args[1] == "list" then
        showList()
    elseif #args >= 1 and args[1] == "install" then
        startupInstall(args[2])
    elseif #args >= 1 and args[1] == "update" then

    elseif #args >= 1 and args[1] == "delete" then

    elseif #args >= 1 and args[1] == "config" then

    elseif #args >= 1 then
        exit("Could not find command '" .. args[1] .. "'", false)
    end
end

if fs.exists("startup") or fs.exists("startup.lua") then
    exit("Delete the startup file and install this program as installer!", true)
end
loadSources()
executeInput()
