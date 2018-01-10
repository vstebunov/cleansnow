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

function cantMove(dx, dy)
    return mget(dx, dy) == WALL_SPRITE
end

function collide(dx, dy)
    for _, crate in pairs(state.crates) do 
        if crate.x == dx and crate.y == y then
            table.insert(collided, crate)
            table.insert(events, "crate_collide_player")
        end
    end
end

local do_state = {}

do_state["Up_pressed"] = function(state) 
    local new_y = state.player.y - 1
    if cantMove(state.player.x, new_y) then return state end
    if collide(state.player.x, new_y) then return state end
    state.player.y = new_y 
    return state
end

do_state["Down_pressed"] = function(state) 
    local new_y = state.player.y + 1
    if cantMove(state.player.x, new_y) then return state end
    state.player.y = new_y 
    return state
end

do_state["Left_pressed"] = function(state) 
    local new_x = state.player.x - 1
    if cantMove(new_x, state.player.y) then return state end
    state.player.x = new_x 
    return state
end

do_state["Right_pressed"] = function(state) 
    local new_x = state.player.x + 1
    if cantMove(new_x, state.player.y) then return state end
    state.player.x = new_x 
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

local events={}
local state={}
local btnLabel={"Up","Down","Left","Right","Btn A","Btn B"}
local collided={}

function readkeyboard() 
    for key = 0, 5 do
        if btnp(key) then
            table.insert(events, btnLabel[key + 1] .. "_pressed")
        end
    end
end

function showevents()
    for i, event in pairs(events) do
        trace(event, 2)
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
            state = do_state[event](state)
        end
    end

    -- event done
    if (#events > 0) then table.remove(events, 1) end

    return state
end

state = do_state["Init"]()

function TIC() 
    readkeyboard()
    draw(state)
    showevents()
    state = state_machine(state, events)
end
