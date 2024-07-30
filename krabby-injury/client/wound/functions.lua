function IsDamagingEvent(damageDone, weapon)
    math.randomseed(GetGameTimer())
    local luck = math.random(100)
    local multi = damageDone / Config.HealthDamage

    return luck < (Config.HealthDamage * multi) or (damageDone >= Config.ForceInjury or multi > Config.MaxInjuryChanceMulti or Config.ForceInjuryWeapons[weapon])
end

function IsInjuryCausingLimp()
    for k, v in pairs(BodyParts) do
        if v.causeLimp and v.isDamaged then
            return true
        end
    end

    return false
end

function IsInjuredOrBleeding()
    if isBleeding > 0 then
        return true
    else
        for k, v in pairs(BodyParts) do
            if v.isDamaged then
                return true
            end
        end
    end

    return false
end

function GetDamagingWeapon(ped)
    for k, v in pairs(Config.Weapons) do
        if HasPedBeenDamagedByWeapon(ped, k, 0) then
            ClearEntityLastDamageEntity(ped)
            return v
        end
    end

    return nil
end

function ResetAll()
    isBleeding = 0
    bleedTickTimer = 0
    advanceBleedTimer = 0
    fadeOutTimer = 0
    blackoutTimer = 0
    onDrugs = 0
    wasOnDrugs = false
    onPainKiller = 0
    wasOnPainKillers = false
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
    DoBleedAlert()

    TriggerServerEvent('krabby-injury:server:SyncInjuries', {
        limbs = BodyParts,
        isBleeding = tonumber(isBleeding)
    })

end

function ProcessRunStuff(ped)
    if IsInjuryCausingLimp() and not (onPainKiller > 0)  then
        RequestAnimSet("move_m@injured")
        while not HasAnimSetLoaded("move_m@injured") do
            Wait(0)
        end
        SetPedMovementClipset(ped, "move_m@injured", 1 )
        SetPlayerSprint(PlayerId(), false)

        if wasOnPainKillers then
            SetPedToRagdoll(ped, 1500, 2000, 3, true, true, false)
            wasOnPainKillers = false
            
        end
    else
        SetPedMoveRateOverride(ped, 1.0)
        ResetPedMovementClipset(ped, 1.0)

        if not wasOnPainKillers and (onPainKiller > 0) then wasOnPainKillers = true end

        if onPainKiller > 0 then
            onPainKiller = onPainKiller - 1
        end
    end
end

function ProcessDamage(ped)
    if not IsEntityDead(ped) or not (onDrugs > 0) then
        for k, v in pairs(injured) do
            if (v.part == 'LLEG' and v.severity > 1) or (v.part == 'RLEG' and v.severity > 1) or (v.part == 'LFOOT' and v.severity > 2) or (v.part == 'RFOOT' and v.severity > 2) then
                if legCount >= Config.LegInjuryTimer then
                    if not IsPedRagdoll(ped) and IsPedOnFoot(ped) then
                        local chance = math.random(100)
                        if (IsPedRunning(ped) or IsPedSprinting(ped)) then
                            if chance <= Config.LegInjuryChance.Running then
                                exports['mythic_notify']:DoLongHudText('error', Config.Strings.InjurNoRun)
                                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) -- change this float to increase/decrease camera shake
                                SetPedToRagdollWithFall(ped, 1500, 2000, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                            end
                        else
                            if chance <= Config.LegInjuryChance.Walking then
                                exports['mythic_notify']:DoLongHudText('error', Config.Strings.InjurStumble)
                                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) -- change this float to increase/decrease camera shake
                                SetPedToRagdollWithFall(ped, 1500, 2000, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                            end
                        end
                    end
                    legCount = 0
                else
                    legCount = legCount + 1
                end
            elseif (v.part == 'LARM' and v.severity > 1) or (v.part == 'LHAND' and v.severity > 1) or (v.part == 'LFINGER' and v.severity > 2) or (v.part == 'RARM' and v.severity > 1) or (v.part == 'RHAND' and v.severity > 1) or (v.part == 'RFINGER' and v.severity > 2) then
                if armcount >= Config.ArmInjuryTimer then
                    local chance = math.random(100)

                    if (v.part == 'LARM' and v.severity > 1) or (v.part == 'LHAND' and v.severity > 1) or (v.part == 'LFINGER' and v.severity > 2) then
                        local isDisabled = 15
                        CreateThread(function()
                            while isDisabled > 0 do
                                if IsPedInAnyVehicle(ped, true) then
                                    DisableControlAction(0, 63, true) -- veh turn left
                                end

                                if IsPlayerFreeAiming(PlayerId()) then
                                    DisablePlayerFiring(PlayerId(), true) -- Disable weapon firing
                                end

                                isDisabled = isDisabled - 1
                                Wait(1)
                            end
                        end)
                    else
                        local isDisabled = 15
                        CreateThread(function()
                            while isDisabled > 0 do
                                if IsPedInAnyVehicle(ped, true) then
                                    DisableControlAction(0, 63, true) -- veh turn left
                                end

                                if IsPlayerFreeAiming(PlayerId()) then
                                    DisableControlAction(0, 25, true) -- Disable weapon firing
                                end

                                isDisabled = isDisabled - 1
                                Wait(1)
                            end
                        end)
                    end

                    armcount = 0
                else
                    armcount = armcount + 1
                end
            elseif (v.part == 'HEAD' and v.severity > 2) then
                if headCount >= Config.HeadInjuryTimer then
                    local chance = math.random(100)

                    if chance <= Config.HeadInjuryChance then
                        exports['mythic_notify']:DoLongHudText('error', Config.Strings.Blackout)
                        SetFlash(0, 0, 100, 10000, 100)

                        DoScreenFadeOut(100)
                        while not IsScreenFadedOut() do
                            Wait(0)
                        end

                        if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
                            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) -- change this float to increase/decrease camera shake
                            SetPedToRagdoll(ped, 5000, 1, 2)
                        end

                        Wait(5000)
                        DoScreenFadeIn(250)
                    end
                    headCount = 0
                else
                    headCount = headCount + 1
                end
            end
        end

        if wasOnDrugs then
            SetPedToRagdoll(ped, 1500, 2000, 3, true, true, false)
            wasOnDrugs = false
            exports['mythic_notify']:DoLongHudText('error', Config.Strings.AdrenalineExpired)
        end
    else
        onDrugs = onDrugs - 1

        if not wasOnDrugs then
            wasOnDrugs = true
        end
    end
end

function DebugAlerts(ped, bone, weapon, damageDone)
    print(weapon)
    exports['mythic_notify']:DoLongHudText('error', 'Bone: ' .. Config.Bones[bone])
    if (Config.MinorInjurWeapons[weapon] ~= nil) then
        exports['mythic_notify']:DoLongHudText('error', 'Minor Weapon : ' .. weapon)
    else
        exports['mythic_notify']:DoLongHudText('error', 'Major Weapon : ' .. weapon)
    end
    exports['mythic_notify']:DoLongHudText('error', 'Crit Area: ' .. tostring(Config.CriticalAreas[Config.Bones[bone]] ~= nil))
    exports['mythic_notify']:DoLongHudText('error', 'Stagger Area: ' .. tostring(Config.StaggerAreas[Config.Bones[bone]] ~= nil and (Config.StaggerAreas[Config.Bones[bone]].armored or GetPedArmour(ped   ) <= 0)))
    exports['mythic_notify']:DoLongHudText('error', 'Dmg Done: ' .. damageDone)
end

function CheckDamage(ped, bone, weapon, damageDone)
    if weapon == nil then return end

    if Config.Bones[bone] ~= nil and not IsEntityDead(ped) then
        if Config.Debug then
            DebugAlerts(ped, bone, weapon, damageDone)
        end

        ApplyImmediateEffects(ped, bone, weapon, damageDone)

        if not BodyParts[Config.Bones[bone]].isDamaged then
            BodyParts[Config.Bones[bone]].isDamaged = true
            BodyParts[Config.Bones[bone]].severity = 1
            table.insert(injured, {
                part = Config.Bones[bone],
                label = BodyParts[Config.Bones[bone]].label,
                severity = BodyParts[Config.Bones[bone]].severity
            })
        else
            if BodyParts[Config.Bones[bone]].severity < 4 then
                BodyParts[Config.Bones[bone]].severity = BodyParts[Config.Bones[bone]].severity + 1

                for k, v in pairs(injured) do
                    if v.part == Config.Bones[bone] then
                        v.severity = BodyParts[Config.Bones[bone]].severity
                    end
                end
            end
        end

        TriggerServerEvent('krabby-injury:server:SyncInjuries', {
            limbs = BodyParts,
            isBleeding = tonumber(isBleeding)
        })

        ProcessRunStuff(ped)
        DoLimbAlert()
        DoBleedAlert()
    else
        if not IsEntityDead(ped) then
            print('Bone Not In Index - Report This! - ' .. bone)
        end
    end
end

function ApplyImmediateEffects(ped, bone, weapon, damageDone)
    local armor = GetPedArmour(ped)

    if Config.MinorInjurWeapons[weapon] and damageDone < Config.DamageMinorToMajor then
        if Config.CriticalAreas[Config.Bones[bone]] then
            if armor <= 0 then
                ApplyBleed(1)
            end
        end

        if Config.StaggerAreas[Config.Bones[bone]] ~= nil and (Config.StaggerAreas[Config.Bones[bone]].armored or armor <= 0) then
            if math.random(100) <= math.ceil(Config.StaggerAreas[Config.Bones[bone]].minor) then
                SetPedToRagdoll(ped, 1500, 2000, 3, true, true, false)
            end
        end
    elseif Config.MajorInjurWeapons[weapon] or (Config.MinorInjurWeapons[weapon] and damageDone >= Config.DamageMinorToMajor) then
        if Config.CriticalAreas[Config.Bones[bone]] ~= nil then
            if armor > 0 and Config.CriticalAreas[Config.Bones[bone]].armored then
                if math.random(100) <= math.ceil(Config.MajorArmoredBleedChance) then
                    ApplyBleed(1)
                end
            else
                ApplyBleed(1)
            end
        else
            if armor > 0 then
                if math.random(100) < (Config.MajorArmoredBleedChance) then
                    ApplyBleed(1)
                end
            else
                if math.random(100) < (Config.MajorArmoredBleedChance * 2) then
                    ApplyBleed(1)
                end
            end
        end

        if Config.StaggerAreas[Config.Bones[bone]] ~= nil and (Config.StaggerAreas[Config.Bones[bone]].armored or armor <= 0) then
            if math.random(100) <= math.ceil(Config.StaggerAreas[Config.Bones[bone]].major) then
                SetPedToRagdoll(ped, 1500, 2000, 3, true, true, false)
            end
        end
    end
end

function ApplyBleed(level)
    if isBleeding ~= 4 then
        if isBleeding + level > 4 then
            isBleeding = 4
        else
            isBleeding = isBleeding + level
        end
        
        DoBleedAlert()
    end
end

function DoLimbAlert()
    local player = PlayerPedId()
    local limbDamageMsg = ''
    local isPlayerDead = IsEntityDead(player)

    if not isPlayerDead then
        if #injured > 0 then
            if #injured <= Config.AlertShowInfo then
                for k, v in pairs(injured) do
                    limbDamageMsg = string.format(Config.Strings.LimbAlert, v.label, Config.WoundStates[v.severity])
                    if k < #injured then
                        limbDamageMsg = limbDamageMsg .. Config.Strings.LimbAlertSeperator
                    end
                end
            else
                limbDamageMsg = Config.Strings.LimbAlertMultiple
            end

            -- Check if notification is active
            local exists = exports['mythic_notify']:PersistentHudText('start', 'limbNotifId', 'error', limbDamageMsg)
            if not exists then
                exports['mythic_notify']:PersistentHudText('start', 'limbNotifId', 'error', limbDamageMsg)
            end
        else
            -- Check if notification should be removed
            local exists = exports['mythic_notify']:PersistentHudText('end', 'limbNotifId')
            if exists then
                exports['mythic_notify']:PersistentHudText('end', 'limbNotifId')
            end
        end
    else
        -- Check if notification should be removed
        local exists = exports['mythic_notify']:PersistentHudText('end', 'limbNotifId')
        if exists then
            exports['mythic_notify']:PersistentHudText('end', 'limbNotifId')
        end
    end
end

function DoBleedAlert()
    local player = PlayerPedId()
    local isPlayerDead = IsEntityDead(player)

    if not isPlayerDead and isBleeding > 0 then
        local bleedMessage = string.format(Config.Strings.BleedAlert, Config.BleedingStates[isBleeding])
        
        -- Check if notification is active
        local exists = exports['mythic_notify']:PersistentHudText('start', 'bleedNotifId', 'error', bleedMessage)
        if not exists then
            exports['mythic_notify']:PersistentHudText('start', 'bleedNotifId', 'error', bleedMessage)
        end
    else
        -- Check if notification should be removed
        local exists = exports['mythic_notify']:PersistentHudText('end', 'bleedNotifId')
        if exists then
            exports['mythic_notify']:PersistentHudText('end', 'bleedNotifId')
        end
    end
end
