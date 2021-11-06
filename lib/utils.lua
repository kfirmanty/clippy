local utils = {}

function utils.repeatedly(f, n)
    local t = {}
    for i = 1,n do
        table.insert(t, f())
    end
    return t
end

return utils