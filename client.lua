local entornos = {}
local done = {}
local timetodelete = {}

ESX = nil 

Citizen.CreateThread(function() 
    while ESX == nil do 
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) 
        Citizen.Wait(0) 
    end 
    getEntornos()
end)

RegisterNetEvent('guille_entornozona:updateentornos')
AddEventHandler('guille_entornozona:updateentornos', function()
    entornos = {}
    done = {}
    getEntornos()
end)

function getEntornos()
    ESX.TriggerServerCallback('guille_entornozona:gete', function(entorno)
        entornos = entorno
        print("Entorno received")
    end)
end

Citizen.CreateThread(function()

    while true do
        Citizen.Wait(1000)
        local _ped = PlayerPedId()
        local _pcoords = GetEntityCoords(_ped)

        for k,v in pairs(entornos) do
            if v.pos ~= nil then
                local _distance = #(vector3(v.pos.x, v.pos.y, v.pos.z) - vector3(_pcoords))

                if _distance < Config.DistanceToEntorno then
                    if done[k] ~= true then
                        TriggerEvent('chat:addMessage', {args = {'Zone message: ', {"ID: " .. v.id .. " " , " Message: " .. v.text}}, color = {200, 20, 20}})
                        done[k] = true
                    end
                else
                    done[k] = false
                end
                if v.time ~= -1 then 
                    if timetodelete[k] == nil then
                        timetodelete[k] = 0
                    else
                        timetodelete[k] = timetodelete[k] + 1
                    end
                    if v.time * 60 < timetodelete[k] then
                        TriggerServerEvent('guille_entornozona:deletebytime', v.id)
                        timetodelete[k] = 0
                    end
                end
            end
        end
    end
end)

