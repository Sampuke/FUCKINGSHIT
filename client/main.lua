-- FOR CHECKING IF PLAYER HAS LOADED IN TO THE GODDANM GAME
LOADED_IN = false
-- Global variable for storing client-side text
CLIENTTEXT = {}
-- Local variables for rendering text
local render, rendText = false, {}
-- Create a thread to handle rendering and updating 3D text
CreateThread(function()
    while not LOADED_IN do Wait(100) end
    while LOADED_IN do
        local sleep = 3000
        local pC = GetEntityCoords(PlayerPedId())
        -- Iterate through server-side 3D text and add them to the render list if they are within range
        if GlobalState.server3dText and type(GlobalState.server3dText) == "table" and next(GlobalState.server3dText) then
            for i = 1, #GlobalState.server3dText do
                local textDistance = #(GlobalState.server3dText[i].coords - pC)
                if textDistance <= 30 then
                    if textDistance <= GlobalState.server3dText[i].dist then
                        render = true
                        rendText[#rendText+1] = GlobalState.server3dText[i]
                    end
                end
            end
        end
        if CLIENTTEXT and type(CLIENTTEXT) == "table" and next(CLIENTTEXT) then
            for i = 1, #CLIENTTEXT do
                -- Iterate through client-side 3D text and add them to the render list if they are within range
                local textDistance = #(CLIENTTEXT[i].coords - pC)
                if textDistance <= 30 then
                    if textDistance <= CLIENTTEXT[i].dist then
                        render = true
                        rendText[#rendText+1] = CLIENTTEXT[i]
                    end
                end
            end
        end
        Wait(sleep)
    end
end)
-- Create a thread to render the 3D text
Citizen.CreateThread(function()
    while not LOADED_IN do Wait(100) end
    while LOADED_IN do
        local sleep = 2500
        if render then
            if #rendText <= 0 then
                render = false
                goto skip
            end
            local pC = GetEntityCoords(PlayerPedId())
            for i = 1, #rendText do
                local text = rendText[i]
                local textDistance = #(text.coords - pC)
                if textDistance > 30 then
                    table.remove(rendText, i)
                    goto skipRender
                end
                local label = string.gsub(text.label,"\n", "~n~")
                local color = {}
                -- Check if color is a hexadecimal string and convert it to RGB
                if type(text.color) == "string" then
                    color = hexToRGB(text.color)
                else
                    color = {r = text.color[1], g = text.color[2], b = text.color[3], a = text.color[4] or 255}
                end
                Draw3DText(text.coords.x, text.coords.y, text.coords.z, text.scale, label, color)
                ::skipRender::
            end
            if #rendText <= 0 then
                render = false
            end
            sleep = 0
        end
        ::skip::
        Wait(sleep)
    end
end)
-- Registering Exports
exports('crete3dText', addText)

exports('update3dText', addText)

exports('delete3dText', addText)

-- Event handlers for esx player loading and unloading
AddEventHandler("esx:playerLoaded", function(playerData, isNew, skin)
    LOADED_IN = true
end)
AddEventHandler("esx:onPlayerLogout", function()
    LOADED_IN = false
end)

-- Event handlers for QBCore player loading and unloading
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    LOADED_IN = true
end)
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    LOADED_IN = false
end)
