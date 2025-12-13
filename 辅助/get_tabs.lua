local tmp = os.tmpname()

local success, result = pcall(function()
    return DC.ExecuteCommand("cm_SaveTabs", "filename=" .. tmp, "savedirhistory=0")
end)

local file = io.open(tmp, 'r')
if file then
    local xml = file:read("*a")
    file:close()
    local out = io.open(os.getenv("TEMP") .. "\\dc_tabs_output.txt", 'w')
    if out then
        for path in xml:gmatch("<Path>([^<]+)") do
            out:write(path, "\n")
        end
        out:close()
    end
    os.remove(tmp)
end
