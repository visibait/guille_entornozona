ESX = nil 

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) 

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print("^2Iniciando borrado de entornos en " .. Config.timeToDeleteEntornos.. " segundos^0")
        Citizen.Wait(Config.timeToDeleteEntornos * 1000)
        MySQL.Async.fetchAll("SELECT * FROM entornos", {}, function(result)
            if result[1] ~= nil then
                for i = 1, #result, 1 do
                    Citizen.Wait(5)
                    --print("Borrado entorno con tiempo: " ..result[i].time)
                    if result[i].time > 0 then
                        print("Borrado entorno con tiempo: " ..result[i].time .. " y id: " ..result[i].id)
                        MySQL.Async.execute('DELETE FROM `entornos` WHERE id = @id', {
                            ['@id'] = result[i].id,
                        })
                    end
                end
            else 
                print("Sin entornos registrados")
            end
        end)
    end
end)

RegisterCommand('borrartodosentornos', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayers = ESX.GetPlayers() 
    if xPlayer.getGroup() == 'admin' then
        MySQL.Async.execute('DELETE FROM `entornos`', {})
        for i=1, #xPlayers, 1 do
            TriggerClientEvent('guille_entornozona:updateentornos', xPlayers[i])
        end
        TriggerClientEvent('esx:showNotification', source, 'Todos los entornos de zona borrados correctamente')
        sendToDisc("El administrador **" .. GetPlayerName(source) .. "** ha borrado** todos los entornos**.")
    end

end)

RegisterCommand('entornozona', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    local pos = xPlayer.getCoords()
    local time = tonumber(args[1])
    local xPlayers = ESX.GetPlayers() 

    if args[1] ~= "" then
        if time < 120 and time >= 1 then
            local identifier = math.random(1, 50000)
            print(identifier)
            MySQL.Async.execute('INSERT INTO entornos (time, owner, pos, identifier) VALUES (@time, @owner, @pos, @identifier)', {
                ["@time"] = args[1],
                ["@owner"] = xPlayer.getIdentifier(),
                ["@pos"] = json.encode(pos),
                ["@identifier"] = identifier,
            })
            local test = args[1]
            table.remove(args, 1)
            Wait(500)
            if args ~= "" then
                MySQL.Async.execute("UPDATE entornos SET text = @text WHERE identifier = @identifier", {
                    ["@text"] = table.concat(args, " "),
                    ["@identifier"] = identifier,
                })
                TriggerClientEvent('esx:showNotification', source, 'Entorno añadido: ' .. table.concat(args, " ") .. '')
                sendToDisc("El jugador **" .. GetPlayerName(source) .. "** hecho un entorno de zona con los argumentos: **" .. table.concat(args, " ") .. "** durante: **" .. test .. "** minutos.")
                for i=1, #xPlayers, 1 do
                    TriggerClientEvent('guille_entornozona:updateentornos', xPlayers[i])
                end
            else
                TriggerClientEvent('esx:showNotification', source, 'El entorno tiene contener un mensaje.')
            end
        else
            TriggerClientEvent('esx:showNotification', source, 'El entorno debe durar entre 1 y 120 minutos')
        end
    else
        TriggerClientEvent('esx:showNotification', source, 'El comando precisa argumentos.')
    end

end, false)


RegisterCommand('entornozonaperma', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    local pos = xPlayer.getCoords()
    local xPlayers = ESX.GetPlayers() 

    if args[1] ~= nil and xPlayer.getGroup() == 'admin' then
        local identifier = math.random(1, 50000)
        MySQL.Async.execute('INSERT INTO entornos (time, owner, pos, identifier) VALUES (@time, @owner, @pos, @identifier)', {
            ["@time"] = -1,
            ["@owner"] = xPlayer.getIdentifier(),
            ["@pos"] = json.encode(pos),
            ["@identifier"] = identifier,
        })
        Wait(500)
        if args ~= nil then
            MySQL.Async.execute("UPDATE entornos SET text = @text WHERE identifier = @identifier", {
                ["@text"] = table.concat(args, " "),
                ["@identifier"] = identifier,
            })
            TriggerClientEvent('esx:showNotification', source, 'Entorno permanente añadido: ' .. table.concat(args, " ") .. '')
            sendToDisc("El jugador **" .. GetPlayerName(source) .. "** hecho un entorno permanente con los argumentos: **" .. table.concat(args, " ") .. "**")
            for i=1, #xPlayers, 1 do
                TriggerClientEvent('guille_entornozona:updateentornos', xPlayers[i])
            end
        else
            TriggerClientEvent('esx:showNotification', source, 'El entorno tiene contener un mensaje.')
        end
    else
        TriggerClientEvent('esx:showNotification', source, 'El comando precisa argumentos.')
    end

end, false)

ESX.RegisterServerCallback('guille_entornozona:gete', function(source,cb) 
    MySQL.Async.fetchAll("SELECT * FROM entornos", {}, function(result)
        local entornos = {}
        if result[1] ~= nil then
            for i = 1, #result, 1 do
                Citizen.Wait(5)
                table.insert(entornos, { ["text"] = result[i]["text"], ["pos"] = json.decode(result[i]["pos"]), ["id"] = result[i]["id"], ["time"] = result[i]["time"] })
            end
        end
        Citizen.Wait(500)
        cb(entornos)
    end)
end)

RegisterCommand('borrarentornozona', function(source, args)

    xPlayer = ESX.GetPlayerFromId(source)
    local xPlayers = ESX.GetPlayers() 

    if xPlayer.getGroup() == 'admin' then
        local id = args[1]

        MySQL.Async.execute('DELETE FROM entornos WHERE id = @id', {
            ["@id"] = id,
        })
        sendToDisc("El administrador **" .. GetPlayerName(source) .. "** ha borrado un entorno con la id: **" .. id .. "**")
        TriggerClientEvent('esx:showNotification', source, 'Entorno borrado con la id: ' .. id)
    else 
        TriggerClientEvent('esx:showNotification', source, 'No tienes permiso para usar este comando')
    end

    for i=1, #xPlayers, 1 do
        TriggerClientEvent('guille_entornozona:updateentornos', xPlayers[i])
    end

end, false)

RegisterServerEvent("guille_entornozona:deletebytime")
AddEventHandler("guille_entornozona:deletebytime", function(id)
    local xPlayers = ESX.GetPlayers() 

    MySQL.Async.execute('DELETE FROM entornos WHERE id = @id', {
        ["@id"] = id,
    })

    for i=1, #xPlayers, 1 do
        TriggerClientEvent('guille_entornozona:updateentornos', xPlayers[i])
    end

end)

--('guille_entornozona:gete', function(entornos)

function sendToDisc(message)
    local date = os.date('*t')
	
	if date.month < 10 then date.month = '0' .. tostring(date.month) end
	if date.day < 10 then date.day = '0' .. tostring(date.day) end
	if date.hour < 10 then date.hour = '0' .. tostring(date.hour) end
	if date.min < 10 then date.min = '0' .. tostring(date.min) end
	if date.sec < 10 then date.sec = '0' .. tostring(date.sec) end

	local embed = {}
	embed = {
		{
			["color"] = 16711680, -- GREEN = 65280 --- RED = 16711680
			["title"] = "**Entorno zona**",
      ["description"] = "" .. message ..  "",
			["footer"] = {
				["text"] = 'Fecha ' .. date.day .. '/' .. date.month .. '/' .. date.year .. ' | ' .. date.hour .. ':' .. date.min ..  ' minutos',
      },
		}
	}
	-- Start
	-- TODO Input Webhook
	PerformHttpRequest("", 
	function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
  -- END
end