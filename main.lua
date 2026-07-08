local id = game.PlaceId
local url = "https://raw.githubusercontent.com/hook-function/UndetectedDynamic/main/games/"..id..".lua"

local ok, ct = pcall(function()
    return game:HttpGet(url)
end)

pcall(function()
    loadstring(ct)()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Undetected Dynamic",
        Text = "Loader successful, we are so UD",
        Duration = 5,
    })
end)