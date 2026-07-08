local id = game.PlaceId
local url = "https://raw.githubusercontent.com/hook-function/UndetectedDynamic/main/games/"..id..".lua"

if id and url then
    loadstring(game:HttpGet(url))()
else
    game:GetSerivce("StarterGui"):SetCore("SendNotification", {
        Title = "Undetected Dynamic",
        Text = "no game are supported contact ud developer in suggestion for further game support.",
        Duration = 5,
    })
end

game:GetSerivce("StarterGui"):SetCore("SendNotification", {
    Title = "Undetected Dynamic",
    Text = "loader successful, we are so UD",
    Duration = 5,
})