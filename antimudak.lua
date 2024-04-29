do -- force hard-scan of gc
    local instanceDestroy = game.Destroy
    local RBXScriptConnectionDisable = game.Changed:Once(function()end).Disconnect
    local fuckup
    fuckup = function(v, depth)
        if depth > 1000 then return end
        
        local tt = type(v)
        if tt == 'table' then
            setreadonly(v, true)
            setrawmetatable(v, nil)
            
            for k, v in next, v do
                fuckup(k, depth + 1)
                fuckup(v, depth + 1)
            end
            return
        elseif tt == 'function' then
            if islclosure(v) then
                for _, upvalue in next, debug.getupvalues(v) do
                    fuckup(upvalue, depth + 1)
                end
            end
        elseif tt == 'thread' then
            if coroutine.status(v) == 'suspended' then
                coroutine.close(v)
            end
        elseif tt == 'userdata' then
            tt = typeof(v)
            if tt == 'Instance' then
                pcall(instanceDestroy, v)
            elseif tt == 'RBXScriptConnection' then
                pcall(RBXScriptConnectionDisable, v)
            end
        end
    end
    
    
    local fastIter = function(a) return a end
    local isexecfn = is_synapse_function or iselectronfunction or isexecutorclosure
    local typeForSearch = 'function'
    for k, v in fastIter(getgc()) do
        if type(v) ~= typeForSearch then continue end
        if not isexecfn(v) then continue end
        
        local name = debug.info(v, 'n')
        if name == 'shutdown' then -- one of simple spy fn name
            local env = getfenv(v)
            if rawget(env, 'toggleSpy') ~= nil and rawget(env, 'toggleSpyMethod') ~= nil then
                fuckup(v, 0)
                
                task.delay(0, v)
            end
        end
    end
    
    if oh then
        fuckup(oh, 0)
    end
end