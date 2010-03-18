---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @release v3.3.4
---------------------------------------------------------------------------

-- Grab environment we need
local ipairs = ipairs
local math = math

--- columns layouts module for awful
module("awful.layout.suit.gimp")

function arrange(p, orientation)
    local wa = p.workarea
    local clients = p.clients
    if #clients < 3 then
        for i=1, #clients do
            clients[i]:geometry({
                height=wa.height,
                width=wa.width/i,
                x=(i-1)*wa.width/i,
                y=wa.y
            })
        end
    elseif #clients >= 3 then
        clients[1]:geometry({
            height=wa.height,
            width=70,
            x=0,
            y=wa.y
        })
        clients[2]:geometry({
            height=wa.height,
            width=230,
            x=wa.width-300+70,
            y=wa.y
        })
        clients[3]:geometry({
            height=wa.height,
            width=wa.width-300,
            x=70,
            y=wa.y
        })
        if #clients > 3 then
            for i=4, #clients do
                clients[i]:geometry({
                    height=wa.height,
                    width=wa.width-300,
                    x=70,
                    y=wa.y
                })
            end
        end
    end
end
name='gimp'
