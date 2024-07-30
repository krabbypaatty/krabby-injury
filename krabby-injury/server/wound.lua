local PlayerInjuries = {}

function GetCharsInjuries(source)
    return PlayerInjuries[source]
end

RegisterServerEvent('krabby-injury:server:SyncInjuries')
AddEventHandler('krabby-injury:server:SyncInjuries', function(data)
    PlayerInjuries[source] = data
end)