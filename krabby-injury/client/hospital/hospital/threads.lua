exports.ox_target:addBoxZone({
    coords = vector3(312.09, -593.42, 43.28),
    size = vec3(1, 1, 2),
    rotation = 340,
    debug = false,
    options = {
        {
            name = 'box',
            event = 'krabby-injury:CheckIn',
            icon = 'fa-solid fa-cube',
            label = 'EMS Check in',
            canInteract = function(entity, distance, coords, name)
                return distance < 1.5 and not LocalPlayer.state.isDead
            end
        }
    }
})

AddEventHandler('krabby-injury:CheckIn', function()
    ESX.TriggerServerCallback("chames_ambulance_medic:requiredAmount", function(required)
        if required then
            if (GetEntityHealth(PlayerPedId()) < 200) or (IsInjuredOrBleeding()) then
                local success = lib.progressBar({
                    duration = 10000,
                    label = 'Signing for Checkin',
                    useWhileDead = false,
                    canCancel = false,
                    allowRagdoll = false,
                    allowCuffed = false,
                    allowFalling = false,
                    disable = {
                        move = true,
                        combat = true,
                        car = true,
                        mouse = false
                    },
                    anim = {
                        dict = 'missheistdockssetup1clipboard@base',
                        clip = 'base',
                        flag = 49
                    },
                    prop = {
                        model = `p_amb_clipboard_01`,
                        pos = vec3(0.12, 0.02, 0.08),
                        rot = vec3(-80.0, 0.0, 0.0) 
                    },
                })
                if success then
                    isInHospitalBed = true
                    if IsScreenFadedOut() then -- Hopeful error prevention if you start checkin right as you're blacking out
                        DoScreenFadeIn(100)
                    end
                    if not cancelled then
                        TriggerServerEvent('krabby-injury:server:RequestBed')
                    else
                        isInHospitalBed = false
                    end
                end
            else
                exports['cfx-hu-notify']:Custom({style = 'error', duration = 5000, title = 'STATUS', message = Config.Strings.NotHurt, sound = false})
                Wait(5000)
                CurrentAction = nil
            end
        else
            exports['cfx-hu-notify']:Custom({style = 'error', duration = 10000, title = 'STATUS', message = 'There are currently medics in duty, talk to them first please.', sound = false})
            Wait(5000)
            CurrentAction = nil
        end
    end)
end)

