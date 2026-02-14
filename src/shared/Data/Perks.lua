local Perks = {
    SecondWind = {
        role = "Survivor",
        hooks = {
            OnChaseEnd = function(player, context)
                context.PlayerStateService:ApplySpeedBoost(player, 1.15, 4)
            end,
        },
    },
    QuietMind = {
        role = "Survivor",
        hooks = {
            OnStealthTick = function(player, context)
                context.PlayerStateService:ModifyDetection(player, -0.25)
            end,
        },
    },
    LastHope = {
        role = "Survivor",
        hooks = {
            OnLastSurvivor = function(player, context)
                context.ObjectiveService:ApplyObjectiveSpeed(player, 1.35)
            end,
        },
    },
    AdrenalSurge = {
        role = "Survivor",
        hooks = {
            OnHitTaken = function(player, context, state)
                if state.Used then
                    return
                end
                state.Used = true
                context.PlayerStateService:RestoreStamina(player)
            end,
        },
    },
    DeadAirPressure = { role = "Killer", hooks = {} },
    BroadcastCut = { role = "Killer", hooks = {} },
    AudienceHunger = { role = "Killer", hooks = {} },
    MarkedByBlood = { role = "Killer", hooks = {} },
    PredatorsPatience = { role = "Killer", hooks = {} },
    HollowHunger = { role = "Killer", hooks = {} },
}

return Perks
