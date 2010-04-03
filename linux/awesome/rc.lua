-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "konsole"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
--modkey = "Mod4" --windows key
modkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
onelayout =
{
    awful.layout.suit.max,
}
twolayouts =
{
    awful.layout.suit.max,
    awful.layout.suit.dual,
}
alllayouts =
{
    awful.layout.suit.max,
    awful.layout.suit.dual,
    awful.layout.suit.special
}
layouts =
{
--    awful.layout.suit.floating,
--    awful.layout.suit.tile,
--    awful.layout.suit.tile.left,
--    awful.layout.suit.tile.bottom,
--    awful.layout.suit.tile.top,
--    awful.layout.suit.fair,
--    awful.layout.suit.fair.horizontal,
--    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.spiral,
    --awful.layout.suit.spiral,
--    awful.layout.suit.max.fullscreen,
--    awful.layout.suit.magnifier
--    awful.layout.suit.special
    awful.layout.suit.gimp,
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
    
}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5 }, s, layouts[1])
    for tagnumber = 1, 5 do
        awful.layout.set(layouts[1], tags[s][tagnumber])
    end
end

-- layout for sepcially for gimp
awful.layout.set(layouts[3], tags[1][5])
--awful.tag.setproperty(tags[1][3], "gimplayout", layouts[3])
-- awful.tag.setproperty(tags[1][3], "gimplayout", layouts[3])
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            layout = awful.widget.layout.horizontal.leftright,
            mypromptbox[s],
        },
        mylayoutbox[s],
        mytextclock,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

require("myrc.tagman")
require("myrc.keybind")

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- {{{ Key bindings
local function move_to_tag_focus_raise(tag)
    for k,marked in pairs(awful.client.getmarked()) do
        awful.client.movetotag(tag,marked)
        --awful.client.setslave(marked)
        client.focus = marked
        client.focus:raise()
    end
end
move_tag_actions={
--    CANNOT DO BELOW!
--    myrc.keybind.key({ modkey }, "t","Cancel",function(c)
--        awful.client.unmark(c)
--        myrc.keybind.pop()
--    end),
    myrc.keybind.key({},"Escape","Cancel",function(c)
        awful.client.unmark(c)
        myrc.keybind.pop()
    end),
    myrc.keybind.key({},"t",'Attach to Current Tag ',function(c)
        --mytextclock.text = 'not done '..mouse.screen
        --mytextclock.text = 'done '..mouse.screen
        --c:raise()
        --awful.tag.viewonly(tags[mouse.screen][1])
        --if client.focus then client.focus:raise() end
        --client.focus=mouse.screen.client
        --awful.client.focus.byidx(1)
        --mouse.screen.client:raise()
        --client.focus:raise()
        --awful.client.visible(mouse.screen)[1]:raise()
        move_to_tag_focus_raise(awful.tag.selected())
        --awful.client.swap.bydirection("right",c)
        --mytextclock.text='abc'..mouse.screen..'|'
        myrc.keybind.pop()
    end),
    myrc.keybind.key({},".",'Move to Next Screen',function(c)
        for k,marked in pairs(awful.client.getmarked()) do
            awful.client.movetoscreen(marked)
            client.focus = marked
            client.focus:raise()
        end
        myrc.keybind.pop()
    end),
    myrc.keybind.key({},"e",'Move to Previous Screen',function(c)
        for k,marked in pairs(awful.client.getmarked()) do
            awful.client.movetoscreen(marked)
            client.focus = marked
            client.focus:raise()
        end
        myrc.keybind.pop()
    end),
    myrc.keybind.key({},"u",'Move to Next Tag',function(c)
        --b=client.focus:tags()
        local tags = tags[client.focus.screen]
        local next_tag_i = awful.tag.selected().name % #tags + 1
        local next_tag = tags[next_tag_i]
        move_to_tag_focus_raise(next_tag)
        myrc.keybind.pop()
    end),
    myrc.keybind.key({},"o",'Move to Previous Tag',function(c)
        local tags = tags[client.focus.screen]
        local prev_tag_i = (awful.tag.selected().name-2) % #tags + 1
        local prev_tag = tags[prev_tag_i]
        move_to_tag_focus_raise(prev_tag)
        myrc.keybind.pop()
    end)
}
for i = 1, keynumber do
    table.insert(move_tag_actions,myrc.keybind.key({},i,'Tag '..i,function(c)
        move_to_tag_focus_raise(tags[client.focus.screen][i])
        myrc.keybind.pop()
    end))
end
globalkeys = awful.util.table.join(

--    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
--    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
--    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    awful.key({ modkey }, "t", 
        function(c)
            awful.client.togglemarked(c)
            myrc.keybind.push("Move to Tag",move_tag_actions)
        end
    ),
    awful.key({ modkey,           }, "g",
        function ()
            myrc.keybind.push("Global Action",{
                myrc.keybind.key({},"Escape","Cancel",function(c)
                    myrc.keybind.pop()
                end)
            })
            --awful.client.focus.byidx( 1)
            --if client.focus then client.focus:raise() end
        end),

    awful.key({ modkey,           }, "p",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, ",",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
--    awful.key({ modkey,           }, ".",
--        function ()
--            awful.client.focus.bydirection("up")
--            if client.focus then client.focus:raise() end
--        end),
--    awful.key({ modkey,           }, "e",
--        function ()
--            awful.client.focus.bydirection("down")
--            if client.focus then client.focus:raise() end
--        end),
    awful.key({ modkey,           }, "o",
        function ()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "u",
        function ()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ }, "F12", function () mymainmenu:show(true)        end),

    -- Layout manipulation
--    awful.key({ modkey, "Shift"   }, "p", function (c) 
--        clients = awful.client.visible(c.screen)
--        awful.client.swap.byidx(  1)    
--        mytextclock.text='m'
--    end),
    --awful.key({ modkey, "Shift"   }, ",", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey,  }, ".", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey,  }, "e", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "j", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
--    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "t", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () 
        local num_clients  = #awful.client.visible(client.focus.screen)
        local layouts 
        if num_clients == 1 then
            layouts = onelayout
        elseif num_clients == 2 then 
            layouts = twolayouts
        else
            layouts = alllayouts 
        end
        awful.layout.inc(layouts,  1) 
    end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(alllayouts, -1) end),
    --awful.key({ modkey,    }, "z", function ()
    --    local next_tag = awful.tag.selected
        --mytextclock.text('ac')
        --mytextclock.text='ac'
        --awful.client.movetotag(tags[client.focus.screen][2])
        --awful.tag.viewnext()
    --end),

    -- Prompt
    awful.key({ modkey },            "F2",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

local function setmaster(c)
    clients = awful.client.visible(c.screen)
    cl = {}
    for i,v in pairs(clients) do
        if v == c then
            break
        else
            table.insert(cl,v)
        end
    end
    for i = #cl, 1, -1 do
        c:swap(cl[i])
    end
end

clientkeys = awful.util.table.join(
    awful.key({ modkey, "Shift"   }, "p", function (c) 
        clients = awful.client.visible(c.screen)
        last_client = clients[#clients]
        if  last_client == c then 
            setmaster(c)
        else
            awful.client.swap.byidx(1) 
        end
        mytextclock.text='m'
    end),
    awful.key({ modkey, "Shift"   }, ",", function (c) 
        clients = awful.client.visible(c.screen)
        first_client = clients[1]
        if  first_client == c then 
            awful.client.setslave(c)
        else
            awful.client.swap.byidx(-1)
        end
        mytextclock.text='m'
    end),
    awful.key({ modkey,           }, "Return",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,   }, "q",      function (c) c:kill()                         end),
    awful.key({ modkey,   }, "m",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
--    awful.key({ modkey, "Shift"   }, "e",      awful.client.movetoscreen                        ),
--    awful.key({ modkey, "Shift"   }, ".",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)
-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
--        awful.key({ modkey, "Shift" }, "#" .. i + 9,
--                  function ()
--
--
--
--                      if client.focus and tags[client.focus.screen][i] then
--                          awful.client.movetotag(tags[client.focus.screen][i])
--                      end
--                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { 
      rule = { class = "MPlayer" },
      properties = { floating = true } 
    },
    { 
        rule = { class = "pinentry" },
      properties = { floating = true } 
    },
    { 
      rule = { class = "Gimp" },
      properties = { tag = tags[1][5] } 
    },
    { 
      rule = { class = "Pidgin" },
      properties = { tag = tags[screen.count()][5] } 
    },
    { 
      rule = { class = "Kopete" },
      properties = { tag = tags[screen.count()][5] } 
    },
    { 
      rule = { name = "robin3 : python" },
      properties = { tag = tags[screen.count()][4] } 
    },
    { 
      rule = { class = "Firefox" },
      properties = { tag = tags[1][1] } 
    },
    { 
      rule = { class = "Opera" },
      properties = { tag = tags[1][1] } 
    },
    { 
      rule = { class = "Google-chrome" },
      properties = { tag = tags[1][1] } 
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        awful.client.setslave(c)

        -- Put windows in a smart way, only if they des not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
    c:add_signal("marked", function (cl)
         cl.border_color = "#00ff00" 
    end)
    c:add_signal("unmarked", function (cl)
         cl.border_color = beautiful.border_normal 
    end)
end)

--client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
--client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- AUTOSTART
function run_once(prg)
    if not prg then
        do return nil end
    end
    os.execute("x=" .. prg .. "; pgrep -u $USER -x " .. prg .. " || (" .. prg .. " &)")
end
run_once("klipper")
run_once("wicd-client")
--os.execute("konsole -e /home/robin3/gmail_notify/check_gmail.py &")
