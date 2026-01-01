return function(dest: {any}, ...: {any}): nil
    for i, arg in ipairs {...} do
        table.move(arg, 1, #arg, #dest + 1, dest)
    end
    return
end