-- CreateThread(function()
--     while true do
--         for k, v in pairs(RecentlyUsedHidden) do
--             local now = os.time()

--             if v <= now then
--                 TriggerClientEvent('krabby-injury:client:HiddenSetup', k)
--                 RecentlyUsedHidden[k] = nil
--             end
--         end

--         Wait(1000)
--     end
-- end)