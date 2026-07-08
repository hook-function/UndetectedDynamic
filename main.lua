local id = game.PlaceId
local url = "https://raw.githubusercontent.com/hook-function/UndetectedDynamic/main/games/"..id..".lua"

local ok, ct = pcall(function()
    return game:HttpGet(url)
end)

if not ok then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Undetected Dynamic",
            Text = "Download failed: " .. tostring(ct),
            Duration = 5,
        })
    end)
    return
end

local fn, err = loadstring(ct)
if not fn then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Undetected Dynamic",
            Text = "Compile error: " .. tostring(err),
            Duration = 5,
        })
    end)
    return
end

local ok, eerr = pcall(fn)
if not eerr then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Undetected Dynamic",
            Text = "Execution error: " .. tostring(eerr),
            Duration = 5,
        })
    end)
    return
end

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Undetected Dynamic",
        Text = "Loader successful, we are so UD",
        Duration = 5,
    })
end)