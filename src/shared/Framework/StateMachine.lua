local Signal = require(script.Parent.Signal)

local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.new(config)
    local self = setmetatable({}, StateMachine)
    self._states = config.states or {}
    self._transitions = config.transitions or {}
    self._current = config.initial
    self.Changed = Signal.new()
    return self
end

function StateMachine:GetState()
    return self._current
end

function StateMachine:CanTransition(target)
    local validTargets = self._transitions[self._current]
    if not validTargets then
        return false
    end
    return table.find(validTargets, target) ~= nil
end

function StateMachine:Transition(target, payload)
    if not self:CanTransition(target) then
        return false, string.format("Invalid transition %s -> %s", self._current, target)
    end

    local oldState = self._current
    self._current = target
    self.Changed:Fire(oldState, target, payload)
    return true
end

return StateMachine
