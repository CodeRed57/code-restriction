Config = {}
-- Configuration for the weapon restriction
Config.WeaponRestriction = {
    preventWeapons = true, -- Set this to false to disable weapon restriction
    requiredJob = { "police", "ambulance"}, -- Replace with the names of the allowed jobss
    requiredItem = "weapon_license", -- Replace with the name of the required item
    requiredLicense = { "weapon", "license2"} -- Add Metadata licenses here
}

-- Configuration for the vehicle restriction
Config.VehicleRestriction = {
    preventVehicle = true, -- Set this to false to disable vehicle restriction
    requiredJob = { "police", "ambulance"}, -- Replace with the names of the allowed jobss
    requiredItem = "driver_license", -- Replace with the name of the whitelisted item
    requiredLicense = { "driver", "license2"} -- Add Metadata licenses here
}
