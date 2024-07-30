RegisterServerEvent('krabby-injury:server:AttemptHiddenRevive')
AddEventHandler('krabby-injury:server:AttemptHiddenRevive', function()
    local src = source
    math.randomseed(os.time())
    local luck = math.random(100) < Config.HiddenRevChance

    local totalBill = CalculateBill(GetCharsInjuries(src), Config.HiddenInjuryBase)
    
    if BillPlayer(src, totalBill) then
        if luck then
            TriggerClientEvent('cfx-hu-notify:client:Custom', src, {style = 'success', duration = 5000, title = 'STATUS', message = 'You\'ve Been Treated & Billed.', sound = false})
        else
            TriggerClientEvent('cfx-hu-notify:client:Custom', src, {style = 'info', duration = 10000, title = 'STATUS', message = 'You were revived, but there were some complications.', sound = false})
        end
    else
        luck = false
        TriggerClientEvent('cfx-hu-notify:client:Custom', src, {style = 'info', duration = 5000, title = 'STATUS', message = 'You were revived, but did not have the funds to cover further medical services.', sound = false})
    end

    RecentlyUsedHidden[source] = os.time() + 180000
    TriggerClientEvent('krabby-injury:client:FinishServices', src, true, luck)
end)