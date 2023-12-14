local inFingerPrintZone = false
exports['rz-polyzone']:AddBoxZone("fingerprint_area", vector3(474.02, -1013.33, 26.27), 4.5, 4.5, {
    heading = 175.37,
    debugPoly = false,
    minZ = 25,
    maxZ = 28
})

RegisterNetEvent("rz-polyzone:enter", function(zone)
    if zone == 'fingerprint_area' then
        inFingerPrintZone = true
    end
end)

RegisterNetEvent("rz-polyzone:exit", function(zone)
    if zone == 'fingerprint_area' then
        inFingerPrintZone = false
    end
end)

exports['rz-polytarget']:AddBoxZone("fingerprint_machine", vector3(487.29, -993.99, 30.69), 0.6, 0.6, {
    name = "fingerprint_machine",
    heading = 358,
    minZ = 30.69,
    maxZ = 31.1,
    debugPoly = false,
})

exports['rz-interact']:AddPeekEntryByPolyTarget('fingerprint_machine', {{
    event = "rz-police:runprints",
    id = "runfingerprints",
    icon = "fingerprint",
    label = "Run fingerprint card",
}}, {distance = {radius = 2.0}})

RegisterNetEvent('rz-police:fingerprint', function()
    if not IsCop() then
        TriggerEvent("ShortText", "Must be a Cop to do this.", 3)
        return
    end

    if not inFingerPrintZone then
        TriggerEvent('ShortText', 'You don\'t have the tools to do that here.', 3)
        return
    end

    local target, distance, serverId = GetClosestPlayer()

    if (distance ~= -1 and distance < 4) then
        ClearPedTasks(PlayerPedId())
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_STAND_MOBILE", 0, 1)
        local finished = exports['rz-taskbar']:TaskBar("Brushing fingerprints", 15000, true)
        if finished == 100 then
            ClearPedTasks(PlayerPedId())
            exports["rz-inventory"]:AddItem("fingerprint_card", 1, {CardNumber = serverId})
        end
    else
        TriggerEvent("ShortText", "No one is near you", 3)
        return
    end
end)

RegisterNetEvent('rz-police:runprints', function()
    local cardData = exports['rz-inventory']:GetItemAmount('fingerprint_card')
    if cardData > 1 then
        TriggerEvent('LongText', 'You can only run one fingerprint card through the machine at a time.', 3)
        return
    elseif cardData < 1 then
        TriggerEvent('LongText', 'You did not feed any fingerprint cards into the machine.', 3)
        return
    end

    local item = exports['rz-inventory']:GetItemDataComplete('fingerprint_card')
    local targetid = tonumber(item.data.CardNumber)
    local targetcid = RPC.Execute("base:getOthersCid", targetid)
    if targetcid then
        local char = RPC.Execute("base:getActiveCharacterWithCid", targetcid)
        TriggerEvent("chatMessage", "Fingerprints", 2, 'Those prints came back a match to: ' .. char.first_name .. ' ' .. char.last_name .. '.')

    else
        TriggerEvent("chatMessage", "Fingerprints", 3, 'An error occured with the machine.')
    end

    exports["rz-inventory"]:RemoveItem('fingerprint_card', 1)
end)