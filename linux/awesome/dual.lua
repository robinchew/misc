---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @release v3.3.4
---------------------------------------------------------------------------

-- Grab environment we need
local ipairs = ipairs
local math = math

--- columns layouts module for awful
module("awful.layout.suit.dual")

function arrange(p, orientation)
    local wa = p.workarea
    local clients = p.clients
    local num_columns = 2

    if #clients == 1 then
        num_columns = 1
    end

    local width = wa.width/num_columns

    local left_clients = math.ceil(#clients / num_columns)
    for k,c in ipairs(clients) do
        local g = {
            width=width,
            height=wa.height,
            y=wa.y
        }
        if k <= left_clients then
            g.x = 0
        else
            g.x = width
        end
        c:geometry(g)
    end
end
name='dual'
