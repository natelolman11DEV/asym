local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({ _handlers = {} }, Signal)
end

function Signal:Connect(handler)
    table.insert(self._handlers, handler)
    local connected = true
    return {
        Disconnect = function()
            if not connected then
                return
            end
            connected = false
            for i, cb in ipairs(self._handlers) do
                if cb == handler then
                    table.remove(self._handlers, i)
                    break
                end
            end
        end,
    }
end

function Signal:Fire(...)
    for _, cb in ipairs(self._handlers) do
        task.spawn(cb, ...)
    end
end

return Signal
