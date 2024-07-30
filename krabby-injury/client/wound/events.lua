RegisterNetEvent('krabby-injury:client:SyncLimbs')
AddEventHandler('krabby-injury:client:SyncLimbs', function(limbs)
    BodyParts = limbs

	injured = {}
    for k, v in pairs(BodyParts) do
        if v.isDamaged then
            table.insert(injured, {
                part = k,
                label = v.label,
                severity = v.severity
            })
        end
    end

    DoLimbAlert()
end)

RegisterNetEvent('krabby-injury:client:SyncBleed')
AddEventHandler('krabby-injury:client:SyncBleed', function(bleedStatus)
    isBleeding = tonumber(bleedStatus)
    DoBleedAlert()
end)

RegisterNetEvent('krabby-injury:client:FieldTreatLimbs')
AddEventHandler('krabby-injury:client:FieldTreatLimbs', function()
    for k, v in pairs(BodyParts) do
        v.isDamaged = false
        v.severity = 1
    end

    for k, v in pairs(injured) do
        if v.part == Config.Bones[bone] then
            v.severity = BodyParts[Config.Bones[bone]].severity
        end
    end

    TriggerServerEvent('krabby-injury:server:SyncInjuries', {
        limbs = BodyParts,
        isBleeding = tonumber(isBleeding)
    })

    ProcessRunStuff(PlayerPedId())
    DoLimbAlert()
end)
RegisterNetEvent('krabby-injury:client:FieldTreatBleed')
AddEventHandler('krabby-injury:client:FieldTreatBleed', function()
    if isBleeding > 1 then
        isBleeding = tonumber(isBleeding) - 1

        TriggerServerEvent('krabby-injury:server:SyncInjuries', {
            limbs = BodyParts,
            isBleeding = tonumber(isBleeding)
        })

        ProcessRunStuff(PlayerPedId())
        DoBleedAlert()
    end
end)

RegisterNetEvent('krabby-injury:client:ReduceBleed')
AddEventHandler('krabby-injury:client:ReduceBleed', function()
    if isBleeding > 0 then
        isBleeding = tonumber(isBleeding) - 1

        TriggerServerEvent('krabby-injury:server:SyncInjuries', {
            limbs = BodyParts,
            isBleeding = tonumber(isBleeding)
        })

        ProcessRunStuff(PlayerPedId())
        DoBleedAlert()
    end
end)


RegisterNetEvent('krabby-injury:client:ResetLimbs')
AddEventHandler('krabby-injury:client:ResetLimbs', function()
    injured = {}

    for k, v in pairs(BodyParts) do
        v.isDamaged = false
        v.severity = 0
    end
    TriggerServerEvent('krabby-injury:server:SyncInjuries', {
        limbs = BodyParts,
        isBleeding = tonumber(isBleeding)
    })

    ProcessRunStuff(PlayerPedId())
    DoLimbAlert()
end)

RegisterNetEvent('krabby-injury:client:RemoveBleed')
AddEventHandler('krabby-injury:client:RemoveBleed', function()
    isBleeding = 0

    TriggerServerEvent('krabby-injury:server:SyncInjuries', {
        limbs = BodyParts,
        isBleeding = tonumber(isBleeding)
    })

    ProcessRunStuff(PlayerPedId())
    DoBleedAlert()
end)

RegisterNetEvent('krabby-injury:client:UsePainKiller')
AddEventHandler('krabby-injury:client:UsePainKiller', function(tier)
    if tier < 10 then
        onPainKiller = 90 * tier
    end

    ProcessRunStuff(PlayerPedId())
end)

RegisterNetEvent('krabby-injury:client:UseAdrenaline')
AddEventHandler('krabby-injury:client:UseAdrenaline', function(tier)
    if tier < 10 then
        onDrugs = 180 * tier
    end
    ProcessRunStuff(PlayerPedId())
end)

--[[ Player Died Events ]]--
--[[RegisterNetEvent('baseevents:onPlayerKilled')
AddEventHandler('baseevents:onPlayerKilled', function(killedBy, data)
    ResetAll()
end)

RegisterNetEvent('baseevents:onPlayerDied')
AddEventHandler('baseevents:onPlayerDied', function(killedBy, pos)
    ResetAll()
end)]]