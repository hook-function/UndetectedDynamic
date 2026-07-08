local id = game.PlaceId
local games = {
    [2753915549]= "https://raw.githubusercontent.com/deividcomsono/UndetectedDynamic/main/games/bloxfruits.lua",
}
if table.find(games, id) then
    loadstring(game:HttpGet(games[id]))()
else
    print("Game not supported")
end