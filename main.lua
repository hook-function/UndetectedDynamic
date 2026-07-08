local ok, ct = pcall(function()
    return game:HttpGet(url)
end)

local loadOk, execErr = pcall(function()
    loadstring(ct)()
end)

if loadOk then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Undetected Dynamic",
        Text = "Loader successful, we are so UD",
        Duration = 5,
    })
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Error",
        Text = tostring(execErr),
        Duration = 5,
    })
end