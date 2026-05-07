---@diagnostic disable: undefined-global
-- Experimental help command handler

if cmd == "help" then
    print("|cFFE6CC99Great Vault Odds:|r |cFF66BBFFhelp menu|r")
    print("options - displays configurable options")
    print("|cFF66BBFFreset - resets all options to their defaults.|r")
    print("dev - toggles dev mode")
    if devMode then
        print("db list: Lists all stored databases")
        print("db gen: Generates a new database")
        print("db compare <list1> [<list2>] - Compares two databases to find errors") -- list 2 optional, compare against main if not there
        print("db compare all - compares all databases to the main one") -- need to add an optional arg to choose which list to compare against
        print("db delete <list>: Deletes the specified table")
        print("debug: Enables DevTool notes to troubleshoot database creation")
    end
    print("----------------------------------------")

elseif cmd == "db" then -- need to handle args now
    if subCmd == "compare" then
        if arg1 == "all" then
            if GreatVaultOddsDB[arg2] then
                -- compare all tables to the specified table from arg2
            else
                print(arg2, "is not a valid table. Comparing all tables to: ") -- get whatever table 1 is, or whatever is designated as the main table (flag maybe?)
            end
        elseif GreatVaultOddsDB[arg1] then -- first need to check if arg1 is not nil probably
            if GreatVaultOddsDB[arg2] then
                print("Comparing", arg1, "with", arg2) -- compare arg1 table with arg2 table with arg1 table acting as the original
            else
                print("Table 2 not provided or", arg2, "is not a valid table. Comparing", arg1, "with: ") -- compare with main table. Maybe can merge this with above if because 2 ifs check for arg2. Also here maybe distinguish between
                -- arg2 not existing vs not being a valid table
            end
        else
            print(arg1, "is not a valid table") -- can we also check if arg2 is a valid table or if it was supposed to be? Can check if arg2 is nil and if not nil then check if it's a valid table and if not say that it is ALSO not a valid table.
        end
    end
end