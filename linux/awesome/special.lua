local ipairs = ipairs
local math = math

--- columns layouts module for awful
module("awful.layout.suit.special")

function arrange(p)
    local wa = p.workarea
    local clients = p.clients

    if #clients > 0 then
        local num_columns = 2
        if #clients == 1 then
            num_columns = 1
        end
        local num_rows = math.ceil(#clients / num_columns)
        local client_w = wa.width / num_columns
        local client_h = wa.height / num_rows

        local cell_capacity = num_rows * num_columns
        local num_empty_cell_slots = cell_capacity - #clients 
        local first_empty_cell_index = #clients+1 

        local dynamic_x = 0 
        local dynamic_y = wa.y 
        local i = 0
        local add_minus = 1
        for k, c in ipairs(clients) do
            local g = {}
--            local diff = 0

            -- calculating X and Y positions
            if i % num_columns == 0 then 
--                diff = 1
                -- reset x position to zero on next row
                if i > 0 then
                    dynamic_y = dynamic_y + client_h
                end
            else
--                if diff >= 1 then
--                    diff = diff+2
--                end
                dynamic_x = add_minus * client_w + dynamic_x
            end
            g.x = dynamic_x

            if i > 0 and i % num_columns == 0 then 
                add_minus = -add_minus 
            end
            g.y = dynamic_y

            g.width = client_w 
--            if diff > 0 and i >= (#clients - diff) then
--                g.height = client_h * 2
--                --g.x=-20
--            else
--                g.height = client_h
--            end
            g.height = client_h

            c:geometry(g)

            i = i + 1
        end

-- FILL BLANK SPACE
-- eg. if 3 windows, the 1st window should have the total height of the other 2 windows
        for i=1,num_empty_cell_slots do
            cell_index = #clients - num_columns - num_empty_cell_slots + i
            clients[cell_index]:geometry({height=client_h*2})
        end
    end
end

name = "special"
