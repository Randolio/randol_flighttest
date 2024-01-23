local flightBusy = false
local cachedNet = 0
local currentPly = 0
local spawn = Config.HeliSpawn
local testCost = 2500
local timeToBeat = Config.RecordTime

local function hasFunds(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.money.bank >= testCost then
        Player.Functions.RemoveMoney('bank', testCost)
        return true
    end
    return false
end

local function createHelicopter()
    local heli = CreateVehicle(joaat('frogger'), spawn, true, false)

    while not DoesEntityExist(heli) do Wait(10) end 

    return NetworkGetNetworkIdFromEntity(heli)
end

local function formatFinishTime(time)
    local total = time / 1000
    local minutes = math.floor(total / 60)
    local seconds = math.floor(total % 60)
    local milliseconds = math.floor((total * 1000) % 1000)
    return ("%02d:%02d:%03d"):format(minutes, seconds, milliseconds)
end

lib.callback.register('randol_flight:server:resetTest', function(source)
    if not flightBusy then return false end
    local heli = NetworkGetEntityFromNetworkId(cachedNet)
    if DoesEntityExist(heli) then DeleteEntity(heli) end
    flightBusy = false
    cachedNet = 0
    currentPly = 0
    return true
end)

lib.callback.register('randol_flight:server:attemptTest', function(source)
    local src = source
    if not hasFunds(src) then
        return false, ("You don't have enough money in the bank to pay for this. Required: $%s"):format(testCost)
    end
    if flightBusy then 
        return false, "Someone is currently doing the flight test. Please wait." 
    end
    flightBusy = true
    cachedNet = createHelicopter()
    currentPly = src
    TriggerClientEvent('randol_flight:client:startRace', src, cachedNet)
    return true
end)

RegisterNetEvent('randol_flight:server:testFinished', function(time)
    if source ~= currentPly then return end

    local Player = QBCore.Functions.GetPlayer(source)
    local tbl = Player.PlayerData.metadata.licences
    local formatTime = formatFinishTime(time)

    if time > timeToBeat then
        QBCore.Functions.Notify(source, "You failed to beat the flight school time. Better luck next time.", "error")
        return
    end

    if not tbl.pilot then
        tbl.pilot = true
        Player.Functions.SetMetaData("licences", tbl)
        QBCore.Functions.Notify(source, ("You completed the test within the time limit and were granted a pilot's license. Your time: %s"):format(formatTime), "success", 8000)
    else
        QBCore.Functions.Notify(source, ("You completed the test within the time limit. Your time: %s"):format(formatTime), "success", 8000)
    end
end)