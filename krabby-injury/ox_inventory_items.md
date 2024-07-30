Item('gauze', function(data, slot)
	LocalPlayer.state:set('DisableFunctions', {DisableHandsUp = true, DisablePointFinger = true, DisableEmoteMenu = true, DisableCrossArms = true}, true)
	ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent('krabby-injury:client:RemoveBleed')
        	TriggerEvent('krabby-injury:client:ResetLimbs')
			exports['mythic_notify']:DoLongHudText('inform', 'You have been healed.')
		end
	end)
end)