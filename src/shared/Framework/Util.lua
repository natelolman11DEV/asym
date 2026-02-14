local Util = {}

function Util.DeepCopy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = type(v) == "table" and Util.DeepCopy(v) or v
    end
    return copy
end

function Util.Clamp(value, minVal, maxVal)
    return math.max(minVal, math.min(maxVal, value))
end

function Util.GenerateId(prefix)
    return string.format("%s_%d_%d", prefix, os.time(), math.random(1000, 9999))
end

function Util.Shuffle(arr)
    for i = #arr, 2, -1 do
        local j = math.random(1, i)
        arr[i], arr[j] = arr[j], arr[i]
    end
    return arr
end

return Util
