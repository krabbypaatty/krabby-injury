local beds = {
    { x = 311.06484985352 , y = -583.12329101563 , z = 44.203971862793, h = 156.19, taken = false, model = 1631638868 },
	{ x = 314.5827331543 , y = -584.27593994141 , z = 44.203971862793, h = 156.19, taken = false, model = 1631638868 },
	{ x = 317.77136230469 , y = -585.51098632813 , z = 44.203971862793, h = 156.19, taken = false, model = 1631638868 }
}

local bedsTaken = {}

AddEventHandler('playerDropped', function()
    if bedsTaken[source] ~= nil then
        beds[bedsTaken[source]].taken = false
    end
end)

RegisterServerEvent('krabby-injury:server:RequestBed')
AddEventHandler('krabby-injury:server:RequestBed', function()
    for k, v in pairs(beds) do
        if not v.taken then
            v.taken = true
            bedsTaken[source] = k
            TriggerClientEvent('krabby-injury:client:SendToBed', source, k, v)
            return
        end
    end
    TriggerClientEvent('cfx-hu-notify:client:Custom', source, {style = 'error', duration = 5000, title = 'STATUS', message = 'No Beds Available.', sound = false})
end)

RegisterServerEvent('krabby-injury:server:RPRequestBed')
AddEventHandler('krabby-injury:server:RPRequestBed', function(plyCoords)
    local foundbed = false
    for k, v in pairs(beds) do
        local distance = #(vector3(v.x, v.y, v.z) - plyCoords)
        if distance < 3.0 then
            if not v.taken then
                v.taken = true
                foundbed = true
                TriggerClientEvent('krabby-injury:client:RPSendToBed', source, k, v)
                return
            else
                TriggerEvent('chatMessage', '', { 0, 0, 0 }, 'That Bed Is Taken')
            end
        end
    end

    if not foundbed then
        TriggerEvent('chatMessage', '', { 0, 0, 0 }, 'Not Near A Hospital Bed')
    end
end)
local ox_inventory = exports.ox_inventory

RegisterServerEvent('krabby-injury:server:EnteredBed')
AddEventHandler('krabby-injury:server:EnteredBed', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(source)
    -- local totalBill = CalculateBill(GetCharsInjuries(src), Config.InjuryBase)
    local moneyCount = ox_inventory:Search(src, 'count', 'money')
    if moneyCount >= 3000 then
        ox_inventory:RemoveItem(src, 'money', 3000)
        TriggerClientEvent('krabby-injury:SetPlayerRecoveryState', src, 90)
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_ambulance', function(account) account.addMoney(3000) end)
        TriggerClientEvent('cfx-hu-notify:client:Custom', src, {style = 'success', duration = 5000, title = 'STATUS', message = 'You\'ve Been Treated & Billed $ '..moneyCount, sound = false})
        TriggerClientEvent('krabby-injury:client:FinishServices', src, false, true)
    else
        TriggerClientEvent('krabby-injury:SetPlayerRecoveryState', src, 90)
        xPlayer.removeAccountMoney('bank', 3000, 'Hospital Check In')
        exports['cfx-hu-banking']:AddTransaction(xPlayer.source, "personal", -3000, "withdraw", "N/A", 'Hospital Check In')
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_ambulance', function(account) account.addMoney(3000) end)
        TriggerClientEvent('cfx-hu-notify:client:Custom', src, {style = 'success', duration = 5000, title = 'STATUS', message = 'You\'ve Been Treated & Billed $ '..moneyCount, sound = false})
        TriggerClientEvent('krabby-injury:client:FinishServices', src, false, true)
    end
end)

RegisterServerEvent('krabby-injury:server:LeaveBed')
AddEventHandler('krabby-injury:server:LeaveBed', function(id)
    beds[id].taken = false
end)

ESX.RegisterServerCallback("chames_ambulance_medic:requiredAmount", function(source, callback)
    local _source  = source
	local xPlayer  = ESX.GetPlayerFromId(_source)

    if not xPlayer then return callback(false) end

    local playersInJob = ESX.GetExtendedPlayers('job', 'ambulance')
    callback(#playersInJob <= 0)
end)