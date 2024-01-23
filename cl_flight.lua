local zOffset = 1.00
local data = { currNum = 1, active = false, startTime = 0, blip = nil, checkpoint = nil }
local time = 0
local target = exports.ox_target

local function createInstructor()
    lib.requestModel(Config.Ped.model, 1000)
    flightPed = CreatePed(0, Config.Ped.model, Config.Ped.coords, false, false)
    SetEntityAsMissionEntity(flightPed, true, true)
    SetPedFleeAttributes(flightPed, 0, 0)
    SetBlockingOfNonTemporaryEvents(flightPed, true)
    SetEntityInvincible(flightPed, true)
    FreezeEntityPosition(flightPed, true)
    SetPedDefaultComponentVariation(flightPed)
    TaskStartScenarioInPlace(flightPed, Config.Ped.scenario, 0, false)

    local options = {
        {
            name = 'flight_guy',
            icon = "fa-solid fa-plane-circle-check",
            label = "Take Test",
            distance = 1.5,
            onSelect = function(data)
                local canStart, msg = lib.callback.await('randol_flight:server:attemptTest', false)
                if not canStart then
                    QBCore.Functions.Notify(msg, "error")
                end
            end,
        },
    }
    target:addLocalEntity(flightPed, options)

    local blip = AddBlipForCoord(Config.Ped.coords.xyz)
    SetBlipSprite(blip, 90)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, 3)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Flight Test")
    EndTextCommandSetBlipName(blip)
end

local function grantVehicleKeys(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    TriggerEvent('vehiclekeys:client:SetOwner', plate)
end 

local function checkPointBlip(x, y, z)
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, 128)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, 3)
    return blip
end

local function startCountdown(num) 
    time = GetGameTimer() + num * 1000 
end

local function getCountdown() 
    return math.floor((time - GetGameTimer()) / 1000) 
end

local function callScaleform(scaleform, returndata, the_function, ...) -- Credits: CritteRo for saving me some time with this function.
    BeginScaleformMovieMethod(scaleform, the_function)
    local args = {...}

    if args then
        for i = 1, #args do
            local arg = args[i]
            local arg_type = type(arg)

            if arg_type == "boolean" then
                ScaleformMovieMethodAddParamBool(arg)
            elseif arg_type == "number" then
                local isInteger = math.floor(arg) == arg
                if isInteger then
                    ScaleformMovieMethodAddParamInt(arg)
                else
                    ScaleformMovieMethodAddParamFloat(arg)
                end
            elseif arg_type == "string" then
                ScaleformMovieMethodAddParamTextureNameString(arg)
            end
        end

        if not returndata then
            EndScaleformMovieMethod()
        else
            return EndScaleformMovieMethodReturnValue()
        end
    end
end

local function showCountdown(num)
    local scaleform = lib.requestScaleformMovie('COUNTDOWN', 1000)
    callScaleform(scaleform, false, "SET_MESSAGE", num, 48, 182, 240, true)
    callScaleform(scaleform, false, "FADE_MP", num, 48, 182, 240)
    return scaleform
end

local function doHudShit(text)
    SetTextFont(4)
    SetTextProportional(7)
    SetTextScale(0.55, 0.55)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 0)
    SetTextEdge(1, 0, 0, 0, 0)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.015, 0.725)
end

local function setCoordinates(x, y, z, w)
    local entity = not cache.vehicle and cache.ped or cache.vehicle
    SetEntityCoords(entity, x, y, z)
    SetEntityHeading(entity, w)
end

local function resetFlightTest()
    data.currNum = 1
    data.active = false 
    data.startTime = 0
    data.blip = nil
    data.checkpoint = nil
    DoScreenFadeOut(10)
    Wait(500)
    local success = lib.callback.await('randol_flight:server:resetTest', false)
    if success then
        setCoordinates(Config.HeliSpawn.x, Config.HeliSpawn.y, Config.HeliSpawn.z, Config.HeliSpawn.w)
    end
    Wait(1000)
    DoScreenFadeIn(10)
end

local function startRace()
    data.startTime = GetGameTimer()
    data.active = true
    checkpoint = CreateCheckpoint(Config.Track.checkpoints[data.currNum].markerNumber, Config.Track.checkpoints[data.currNum].coords.x,  Config.Track.checkpoints[data.currNum].coords.y,  Config.Track.checkpoints[data.currNum].coords.z + zOffset, Config.Track.checkpoints[data.currNum].coords.x,Config.Track.checkpoints[data.currNum].coords.y, Config.Track.checkpoints[data.currNum].coords.z, 12.0, 51, 184, 232, math.ceil(255*0.9), 0)
    data.blip = checkPointBlip(Config.Track.checkpoints[data.currNum].coords.x, Config.Track.checkpoints[data.currNum].coords.y, Config.Track.checkpoints[data.currNum].coords.z)

    while data.active do 
        Wait(0)

        local total = (GetGameTimer() - data.startTime) / 1000
        local minutes = math.floor(total / 60)
        local seconds = math.floor(total % 60)
        local milliseconds = math.floor((total * 1000) % 1000)

        doHudShit(("%02d:%02d:%03d\nCheckpoint %s/%s"):format(minutes, seconds, milliseconds, data.currNum, #Config.Track.checkpoints))

        if IsControlJustReleased(0, 194) or cache.seat ~= -1 or IsEntityDead(cache.ped) or total * 1000 > Config.RecordTime then -- 194 is backspace
            DeleteCheckpoint(checkpoint)
            RemoveBlip(data.blip)
            break
        end

        local point = vec3(Config.Track.checkpoints[data.currNum].coords.x, Config.Track.checkpoints[data.currNum].coords.y, Config.Track.checkpoints[data.currNum].coords.z)
        local pos = GetEntityCoords(cache.ped)

        if #(point - pos) < 10.0 then
            DeleteCheckpoint(checkpoint)
            RemoveBlip(data.blip)
            PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS")  

            if data.currNum == #(Config.Track.checkpoints) then
                local finishTime = (GetGameTimer() - data.startTime)
                PlaySoundFrontend(-1, "ScreenFlash", "WastedSounds")
                TriggerServerEvent('randol_flight:server:testFinished', finishTime)
                break
            end

            data.currNum += 1
            checkpoint = CreateCheckpoint(Config.Track.checkpoints[data.currNum].markerNumber, Config.Track.checkpoints[data.currNum].coords.x,  Config.Track.checkpoints[data.currNum].coords.y,  Config.Track.checkpoints[data.currNum].coords.z + zOffset, Config.Track.checkpoints[data.currNum].coords.x, Config.Track.checkpoints[data.currNum].coords.y, Config.Track.checkpoints[data.currNum].coords.z, 12.0, 51, 184, 232, math.ceil(255*0.9), 0)
            data.blip = checkPointBlip(Config.Track.checkpoints[data.currNum].coords.x, Config.Track.checkpoints[data.currNum].coords.y, Config.Track.checkpoints[data.currNum].coords.z)
        end
    end

    resetFlightTest()
end

RegisterNetEvent("randol_flight:client:startRace", function(netid)
    if GetInvokingResource() then return end

    local veh = NetworkGetEntityFromNetworkId(netid)
    grantVehicleKeys(veh)
    FreezeEntityPosition(veh, true)

    startCountdown(6)
    while getCountdown() > 0 do
        Wait(0)
        scale = showCountdown(getCountdown())
        DrawScaleformMovieFullscreen(scale, 255, 255, 255, 255)
        DisableControlAction(2, 71, true)
        DisableControlAction(2, 72, true)
    end

    time = 0
    FreezeEntityPosition(veh, false)
    EnableControlAction(2, 71, true)
    EnableControlAction(2, 72, true)
    startRace()
end)

AddEventHandler('onResourceStop', function(resourceName) 
	if GetCurrentResourceName() == resourceName then
        target:removeEntity(flightPed, {'flight_guy'})
        DeleteEntity(flightPed)
	end 
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    createInstructor()
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        createInstructor()
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    target:removeEntity(flightPed, {'flight_guy'})
    DeleteEntity(flightPed)
end)
