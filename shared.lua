QBCore = exports['qb-core']:GetCoreObject()

Config = {}

Config.RecordTime = 75000 -- 1min 15sec

Config.Track = {
    start = vec4(893.26, -2678.21, 12.76, 53.12),
    checkpoints = {     
        {coords = vec4(728.65, -2579.78, 7.94, 88.79), markerNumber = 14 },
        {coords = vec4(622.1, -2502.83, 5.12, 7.53), markerNumber = 14 },
        {coords = vec4(626.69, -2043.27, 13.9, 355.48), markerNumber = 14 },
        {coords = vec4(674.57, -1729.7, 15.43, 355.32), markerNumber = 14 },
        {coords = vec4(610.74, -1337.22, 32.69, 17.53), markerNumber = 14 },
        {coords = vec4(559.83, -1189.81, 21.95, 1.38), markerNumber = 14 },
        {coords = vec4(586.38, -1026.34, 17.84, 354.77), markerNumber = 14 },
        {coords = vec4(621.87, -849.15, 22.8, 358.39), markerNumber = 14 },
        {coords = vec4(627.87, -570.37, 21.49, 328.39), markerNumber = 14 },
        {coords = vec4(722.51, -447.47, 24.3, 302.88), markerNumber = 14 },
        {coords = vec4(916.88, -401.55, 58.8, 285.64), markerNumber = 14 },
        {coords = vec4(1026.65, -322.57, 56.06, 326.51), markerNumber = 14 },
        {coords = vec4(1084.07, -230.11, 60.67, 325.33), markerNumber = 16 }
    }
}

Config.Ped = {
    model = `s_m_y_pilot_01`,
    coords = vec4(914.66, -2610.32, 5.11, 175.39),
    scenario = 'WORLD_HUMAN_CLIPBOARD',
}

Config.HeliSpawn = vec4(920.67, -2617.09, 6.11, 81.92)