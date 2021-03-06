-- title:  clear snow 
-- author: V.Stebunov
-- desc:   clear all snow on winter time
-- script: lua
-- input:  gamepad
-- saveid: VSClearSnow
-- make state machine
-- but first we need output map
-- and set player on center
local PLAYER_SPRITE = 1
local WALL_SPRITE = 2
local CRATE_SPRITE = 3
local JUNK_SPRITE = 4
local EXIT_CLOSE_SPRITE = 5
local EXIT_OPEN_SPRITE = 6

local do_state = {}
local collided = {}
local force = {}
local events={}
local state={}

function cantMove(dx, dy)
    for _, crate in ipairs(state.crates) do
        if crate.isJunk and 
            crate.x == dx and crate.y == dy then
            return true
        end
    end
    return mget(dx, dy) == WALL_SPRITE or (not state.exit.open and state.exit.x == dx and state.exit.y == dy)
end

function collide(element) 
    for _, crate in ipairs(state.crates) do
        if not crate.isJunk and crate.x == element.x + force.x and crate.y == element.y + force.y then
            table.insert(events, "interaction")
            if (#collided == 0) then table.insert(collided, element) end
            table.insert(collided, crate)
            return true
        elseif crate.isJunk and element == state.player and crate.x == element.x + force.x and crate.y == element.y + force.y then
            table.insert(events, "junk_eats")
            crate.marked = true
            return false
        end
    end
    return false
end

function isMove(element) 
    return not collide(element) and
            not cantMove(element.x + force.x, element.y + force.y) 
end

function isPlayerMeetJunk(collided) 
    if not #collided == 2 then return false end
    if collided[1] == state.player and
        collided[2].isJunk then
            table.insert(events, "junk_eats")
            return true
    end
    return false
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
    local last_collided = collided[#collided]
    if isMove(last_collided) then table.insert(events, "uninteraction") end
    if isPlayerMeetJunk(collided) then table.insert(events, "uninteraction") end
    return state
end

do_state["uninteraction"] = function(state)
    local c = table.remove(collided, 1)
    c.x = c.x + force.x
    c.y = c.y + force.y
    if not (#collided == 0) then table.insert(events, "uninteraction") end
    return state
end

do_state["junk_eats"] = function(state) 
    local junk_counter = 0
    for i = #state.crates, 1, -1 do
        c = state.crates[i]
        if c.marked then table.remove(state.crates, i) end
        if c.isJunk and not c.marked then junk_counter = junk_counter + 1 end
    end
    if junk_counter == 0 then state.exit.open = true end
    table.insert(events, "player_moved")
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
    crates[3] = {}
    crates[3].x = 4
    crates[3].y = 7
    crates[3].isJunk = true

    state = {}
    state.player = {}
    state.player.x = 4
    state.player.y = 4
    state.crates = crates

    state.exit = {}
    state.exit.x = 6
    state.exit.y = 7
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

function draw(state)
    cls(0);
    -- map
    map(0, 0, 30, 17);
    -- sprites
    for _, crate in pairs(state.crates) do 
        local crate_sprite = CRATE_SPRITE
        if crate.isJunk then
            crate_sprite = JUNK_SPRITE
        end
        spr(crate_sprite, crate.x * 8, crate.y * 8, 0);
    end
    spr(PLAYER_SPRITE, state.player.x * 8, state.player.y * 8, 0);
    local exit_sprite = EXIT_CLOSE_SPRITE
    if state.exit.open then
        exit_sprite = EXIT_OPEN_SPRITE
    end
    spr(exit_sprite, state.exit.x * 8, state.exit.y * 8);
    -- hud
    -- text
    print(string, x, y)
end

function state_machine(state, events)
    for _,event in pairs(events) do
        if do_state[event] then
            trace('do event: ' .. event, 2)
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
    collided = {}
end
