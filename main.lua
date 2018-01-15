-- title:  clear snow 
-- author: V.Stebunov
-- desc:   clear all snow on winter time
-- script: lua
-- input:  gamepad
-- saveid: VSClearSnow
-- make state machine
-- but first we need output map
-- and set player on center
local WALL_SPRITE = 2
local PLAYER_SPRITE = 1
local CRATE_SPRITE = 3

local do_state = {}
local collided = {}
local force = {}
local events={}
local state={}

function cantMove(dx, dy)
    return mget(dx, dy) == WALL_SPRITE
end

function collide(element) 
    for _, crate in ipairs(state.crates) do
        if crate.x == element.x + force.x and crate.y == element.y + force.y then
            table.insert(events, "interaction")
            if (#collided == 0) then table.insert(collided, element) end
            table.insert(collided, crate)
            return true
        end
    end
    return false
end

function isMove(element) 
    if element == nil then return true end
    return not collide(element) and
            not cantMove(element.x + force.x, element.y + force.y) 
end

do_state["Up_pressed"] = function(state) 
    force.x = 0
    force.y = -1
    if isMove(state.player) then table.insert(events, "player_moved") end
    return state
end

do_state["Down_pressed"] = function(state) 
    force.x = 0
    force.y = 1
    if isMove(state.player) then table.insert(events, "player_moved") end
    return state
end

do_state["Left_pressed"] = function(state) 
    force.x = -1
    force.y = 0
    if isMove(state.player) then table.insert(events, "player_moved") end
    return state
end

do_state["Right_pressed"] = function(state) 
    force.x = 1
    force.y = 0
    if isMove(state.player) then table.insert(events, "player_moved") end
    return state
end

do_state["player_moved"] = function(state)
    table.insert(collided, state.player)
    table.insert(events, "uninteraction")
    return state
end

do_state["interaction"] = function(state)
    local last_collided = collided[#collided - 1]
    if last_collided and isMove(last_collided) then table.insert(events, "uninteraction") end
    return state
end

do_state["uninteraction"] = function(state)
    local c = table.remove(collided, 1)
    c.x = c.x + force.x
    c.y = c.y + force.y
    if not (#collided == 0) then table.insert(events, "uninteraction") end
    return state
end

do_state["Init"] = function()

    local crates = {}
    crates[1] = {}
    crates[1].x = 4
    crates[1].y = 5
    crates[2] = {}
    crates[2].x = 4
    crates[2].y = 6

    state = {}
    state.player = {}
    state.player.x = 4
    state.player.y = 4
    state.crates = crates
    return state
end

local string="RELAX!"
local width=print(string,0,-6)

local x = (240-width)//2
local y = (136-6)//2

local btnLabel={"Up","Down","Left","Right","Btn A","Btn B"}

function readkeyboard() 
    for key = 0, 5 do
        if btnp(key) then
            table.insert(events, btnLabel[key + 1] .. "_pressed")
        end
    end
end

function showevents()
    for i, event in pairs(events) do
        trace(i .. ':' .. event, 2)
    end
end

function draw(state)
    cls(0);
    -- map
    map(0, 0, 30, 17);
    -- sprites
    for _, crate in pairs(state.crates) do 
        spr(CRATE_SPRITE, crate.x * 8, crate.y * 8, 0);
    end
    spr(PLAYER_SPRITE, state.player.x * 8, state.player.y * 8, 0);
    -- hud
    -- text
    print(string, x, y)
end

function state_machine(state, events)
    for _,event in pairs(events) do
        if do_state[event] then
            trace('e:' .. event, 2)
            state = do_state[event](state)
        end
    end
    return state
end

state = do_state["Init"]()

function TIC() 
    readkeyboard()
    draw(state)
    state = state_machine(state, events)
    events = {}
end
