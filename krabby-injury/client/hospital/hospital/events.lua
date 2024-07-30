RegisterNetEvent('krabby-injury:client:RPCheckPos')
AddEventHandler('krabby-injury:client:RPCheckPos', function()
    TriggerServerEvent('krabby-injury:server:RPRequestBed', GetEntityCoords(PlayerPedId()))
end)

RegisterNetEvent('krabby-injury:client:RPSendToBed')
AddEventHandler('krabby-injury:client:RPSendToBed', function(id, data)
    bedOccupying = id
    bedOccupyingData = data

    SetBedCam()

    CreateThread(function()
        local scaleform = InBedTooltip('instructional_buttons', false)
        while bedOccupyingData ~= nil do
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
            if IsControlJustReleased(0, Config.Keys.GetUp) then
                LeaveBed()
            end
            Wait(1)
        end
    end)
end)

RegisterNetEvent('krabby-injury:client:SendToBed')
AddEventHandler('krabby-injury:client:SendToBed', function(id, data)
    bedOccupying = id
    bedOccupyingData = data

    SetBedCam()

    CreateThread(function ()
        Wait(5)
        local player = PlayerPedId()
        exports['cfx-hu-notify']:Custom({style = 'info', duration = Config.AIHealTimer * 1000, title = 'STATUS', message = Config.Strings.BeingTreated, sound = false})
        ESX.Progressbar(Config.AIHealTimer * 1000, 'Resting...')
        TriggerServerEvent('krabby-injury:server:EnteredBed')
    end)
end)

RegisterNetEvent('krabby-injury:client:ForceLeaveBed')
AddEventHandler('krabby-injury:client:ForceLeaveBed', function()
    LeaveBed()
end)