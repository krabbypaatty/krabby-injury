CreateThread(function()
	while true do
		if #injured > 0 then
			local level = 0
			for k, v in pairs(injured) do
				if v.severity > level then
					level = v.severity
				end
			end

			SetPedMoveRateOverride(PlayerPedId(), Config.MovementRate[level])
			
			Wait(5)
		else
			Wait(1000)
		end
	end
end)

local prevPos = nil
CreateThread(function()
    Wait(2500)
    prevPos = GetEntityCoords(PlayerPedId(), true)
    while true do
        if isBleeding > 0 then
            local player = PlayerPedId()
            if bleedTickTimer >= Config.BleedTickRate and not isInHospitalBed then
                if not IsEntityDead(player) then
                    if isBleeding > 0 then
                        if isBleeding == 1 then
                            SetFlash(0, 0, 100, 100, 100)
                        elseif isBleeding == 2 then
                            SetFlash(0, 0, 100, 250, 100)
                        elseif isBleeding == 3 then
                            SetFlash(0, 0, 100, 500, 100)
                        elseif isBleeding == 4 then
                            SetFlash(0, 0, 100, 500, 100)
                        end

                        if fadeOutTimer + 1 == Config.FadeOutTimer then
                            if blackoutTimer + 1 == Config.BlackoutTimer then
                                exports['cfx-hu-notify']:Custom({style = 'warning', duration = 5000, title = 'STATUS', message = 'You Suddenly Black Out', sound = false})
                                SetFlash(0, 0, 100, 7000, 100)

                                DoScreenFadeOut(500)
                                while not IsScreenFadedOut() do
                                    Wait(0)
                                end

                                if not IsPedRagdoll(player) and IsPedOnFoot(player) and not IsPedSwimming(player) then
                                    ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) -- change this float to increase/decrease camera shake
                                    SetPedToRagdollWithFall(PlayerPedId(), 7500, 9000, 1, GetEntityForwardVector(player), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                                end

                                Wait(1500)
                                DoScreenFadeIn(1000)
                                blackoutTimer = 0
                            else
                                DoScreenFadeOut(500)
                                while not IsScreenFadedOut() do
                                    Wait(0)
                                end
                                DoScreenFadeIn(500)

                                if isBleeding > 3 then
                                    blackoutTimer = blackoutTimer + 2
                                else
                                    blackoutTimer = blackoutTimer + 1
                                end
                            end

                            fadeOutTimer = 0
                        else
                            fadeOutTimer = fadeOutTimer + 1
                        end

                        local bleedDamage = tonumber(isBleeding) * Config.BleedTickDamage
                        ApplyDamageToPed(player, bleedDamage, false)
                        playerHealth = playerHealth - bleedDamage

                        if advanceBleedTimer >= Config.AdvanceBleedTimer then
                            ApplyBleed(1)
                            advanceBleedTimer = 0
                        else
                            advanceBleedTimer = advanceBleedTimer + 1
                        end
                    end
                end
                bleedTickTimer = 0
            else
                if math.floor(bleedTickTimer % (Config.BleedTickRate / 10)) == 0 then
                    local currPos = GetEntityCoords(player, true)
                    local moving = #(vector2(prevPos.x, prevPos.y) - vector2(currPos.x, currPos.y))
                    local exists = exports['cfx-hu-notify']:IsPersistentShowing(bleedMoveNotifId)
                    print(exists)
                    if (moving > 1 and not IsPedInAnyVehicle(player)) and isBleeding > 2 then
                        if not exists then
                            exports['cfx-hu-notify']:Persist({id = bleedMoveNotifId, step = 'start', options = {style = 'info', title = 'STATUS', message = 'You notice blood oozing from your wounds faster when you\'re moving', sound = false}})
                        end
                        advanceBleedTimer = advanceBleedTimer + Config.BleedMovementAdvance
                        bleedTickTimer = bleedTickTimer + Config.BleedMovementTick
                        prevPos = currPos
                    else
                        if exists then
                            exports['cfx-hu-notify']:Persist({id = bleedMoveNotifId, step = 'end'})
                        end
                        bleedTickTimer = bleedTickTimer + 1
                    end

                else

                end
                bleedTickTimer = bleedTickTimer + 1
            end
        end

        Wait(1000)
    end
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local health = GetEntityHealth(ped)
        local armor = GetPedArmour(ped)

        if not playerHealth then
            playerHealth = health
        end

        if not playerArmor then
            playerArmor = armor
        end

        local armorDamaged = (playerArmor ~= armor and armor < (playerArmor - Config.ArmorDamage) and armor > 0) -- Players armor was damaged
        local healthDamaged = (playerHealth ~= health) -- Players health was damaged

        local damageDone = (playerHealth - health)

        if armorDamaged or healthDamaged then
            local hit, bone = GetPedLastDamageBone(ped)
            local bodypart = Config.Bones[bone]
            local weapon = GetDamagingWeapon(ped)

            if hit and bodypart ~= 'NONE' then
                if damageDone >= Config.HealthDamage then
                    local checkDamage = true
                    if weapon ~= nil then
                        if armorDamaged and (bodypart == 'SPINE' or bodypart == 'UPPER_BODY') or weapon == Config.WeaponClasses['NOTHING'] then
                            checkDamage = false -- Don't check damage if the it was a body shot and the weapon class isn't that strong
                        end
    
                        if checkDamage then
    
                            if IsDamagingEvent(damageDone, weapon) then
                                CheckDamage(ped, bone, weapon, damageDone)
                            end
                        end
                    end
                elseif Config.AlwaysBleedChanceWeapons[weapon] then
                    if math.random(100) < Config.AlwaysBleedChance then
                        ApplyBleed(1)
                    end
                end
            end
        end

        playerHealth = health
        playerArmor = armor

        if not isInHospitalBed then
            ProcessDamage(ped)
        end
        Wait(100)
    end
end)

---- PLAYER RECOVERY STATE
local isRecovering = false

RegisterNetEvent("krabby-injury:SetPlayerRecoveryState")
AddEventHandler("krabby-injury:SetPlayerRecoveryState", function(duration)
    if isRecovering then return end
    isRecovering = true
    local recoverytime = duration * 1000
    local timestarted = GetGameTimer()
    local playerPed = PlayerPedId()
    local lastnotify = 0
    while isRecovering do
        if IsPedJumping(playerPed) then
            if math.random(100) < 60 then
                RecoveryFailed(50)
                isRecovering = false
            end
        end

        if IsPedRunning(playerPed) then
            if math.random(100) < 8 then
                RecoveryFailed(30)
                isRecovering = false
            end
        end 

        if IsPedShooting(playerPed) then
            if math.random(100) < 45 then
                RecoveryFailed(25)
                isRecovering = false
            end
        end 

        if IsPedClimbing(playerPed) then
            if math.random(100) < 60 then
                RecoveryFailed(50)
                isRecovering = false
            end
        end

        if IsPedBeingStunned(playerPed) then
            if math.random(100) < 60 then
                RecoveryFailed(50)
                isRecovering = false
            end
        end

        if IsPlayerFreeAiming(PlayerId()) then
            if math.random(100) < 5 then
                RecoveryFailed(15)
                isRecovering = false
            end
        end  

        if (GetGameTimer() - timestarted) > recoverytime or IsPlayerDead(PlayerId()) then
            isRecovering = false
        end

        if (GetGameTimer() - lastnotify) > 10000 then
            exports['cfx-hu-notify']:Custom({style = 'info', duration = 8000, title = 'MEDICAL', message = 'You are currently recovering from your previous injuries.', sound = false})
            lastnotify = GetGameTimer()
        end

        Wait(500)
    end
end)

RegisterNetEvent("krabby-injury:ResetPlayerRecoveryState")
AddEventHandler("krabby-injury:ResetPlayerRecoveryState", function()
    isRecovering = false
end)

function RecoveryFailed(rate)
    local curHealth = GetEntityHealth(PlayerPedId())
    local damage = curHealth - rate

    isBleeding = 5

    Wait(2500)
    SetPedToRagdollWithFall(PlayerPedId(), 4500, 2000, 1, GetEntityForwardVector(PlayerPedId()), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    Wait(2500)
    SetEntityHealth(PlayerPedId(), damage)
end

