local QBCore = exports['qb-core']:GetCoreObject()
local listening = false

-- Function to check if the player has an allowed job
local function isInAllowedJob(jobName, config)
    for _, job in ipairs(config.requiredJob) do
        if job == jobName then
            return true
        end
    end
    return false
end

-- Function to check if the player has a valid license
local function hasLicense(licensesMeta, allowedLicenses)
    for _, allowedLicense in ipairs(allowedLicenses) do
        if licensesMeta[allowedLicense] then
            return true
        end
    end
    return false
end

-- Function to handle weapon restriction
local function handleWeaponRestriction()
    local ped = PlayerPedId()
    local currentWeapon = GetSelectedPedWeapon(ped)

    if currentWeapon ~= GetHashKey("WEAPON_UNARMED") then
        local playerData = QBCore.Functions.GetPlayerData()
        local hasWhitelistedItem = QBCore.Functions.HasItem(Config.WeaponRestriction.requiredItem)
        local licensesMeta = playerData.metadata["licences"]
        local hasValidLicense = hasLicense(licensesMeta, Config.WeaponRestriction.requiredLicense)

        if not isInAllowedJob(playerData.job.name, Config.WeaponRestriction) and not hasWhitelistedItem and not hasValidLicense then
            SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
            RemoveAllPedWeapons(ped, true)
            QBCore.Functions.Notify('You dont have permission', "error")
        end
    end
end

-- Function to handle vehicle restriction
local function handleVehicleRestriction()
    local ped = PlayerPedId()
    local currentVehicle = GetVehiclePedIsIn(ped, false)

    if currentVehicle ~= 0 then
        local enteringAsDriver = GetPedInVehicleSeat(currentVehicle, -1) == ped
        if enteringAsDriver then
            local playerData = QBCore.Functions.GetPlayerData()
            local jobName = playerData.job.name
            local licensesMeta = playerData.metadata["licences"]
            local hasValidLicense = hasLicense(licensesMeta, Config.VehicleRestriction.requiredLicense)
            local hasWhitelistedItem = QBCore.Functions.HasItem(Config.VehicleRestriction.requiredItem)

            if Config.VehicleRestriction.preventVehicle and not isInAllowedJob(jobName, Config.VehicleRestriction) and not hasWhitelistedItem and not hasValidLicense then
                TaskLeaveVehicle(ped, currentVehicle, 16)
                QBCore.Functions.Notify('You dont have permission', "error")
            end
        end
    end

    local enteringVehicle = GetVehiclePedIsEntering(ped)
    if enteringVehicle ~= 0 then
        local enteringAsDriver = GetPedInVehicleSeat(enteringVehicle, -1) == ped
        if enteringAsDriver then
            local playerData = QBCore.Functions.GetPlayerData()
            local jobName = playerData.job.name
            local licensesMeta = playerData.metadata["licences"]
            local hasValidLicense = hasLicense(licensesMeta, Config.VehicleRestriction.requiredLicense)
            local hasWhitelistedItem = QBCore.Functions.HasItem(Config.VehicleRestriction.requiredItem)

            if Config.VehicleRestriction.preventVehicle and not isInAllowedJob(jobName, Config.VehicleRestriction) and not hasWhitelistedItem and not hasValidLicense then
                ClearPedTasksImmediately(ped)
                QBCore.Functions.Notify('You dont have permission', "error")
            end
        end
    end
end

-- Main listening function
local function startListening()
    listening = true
    Citizen.CreateThread(function()
        while listening do
            -- Handle weapon restrictions
            if Config.WeaponRestriction.preventWeapons then
                handleWeaponRestriction()
            end

            -- Handle vehicle restrictions
            if Config.VehicleRestriction.preventVehicle then
                handleVehicleRestriction()
            end

            Citizen.Wait(250)
        end
    end)
end

-- Setup client function
local function setupClient()
    listening = false
    Citizen.Wait(500)
    startListening()
end

-- Register events for player loading and resource start
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    setupClient()
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        setupClient()
    end
end)
