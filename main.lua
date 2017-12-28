-- title:  clear snow 
-- author: V.Stebunov
-- desc:   clear all snow on winter time
-- script: lua
-- input:  gamepad
-- saveid: VSClearSnow
-- make state machine
-- but first we need output map
-- and set player on center

local do_state = require "actions.lua"

local string="RELAX!"
local width=print(string,0,-6)

local x = (240-width)//2
local y = (136-6)//2

local events={}
local state={}
local btnLabel={"Up","Down","Left","Right","Btn A","Btn B"}

function readkeyboard() 
    for key = 0, 5 do
        if btn(key) then
            table.insert(events, btnLabel[key + 1] .. "_pressed")
        end
    end
end

function showevents()
    for i, event in pairs(events) do
        print(event, 10, 10 + i * 10)
    end
end

function draw(state)
    cls(0);
    map(0, 0, 5, 5, 30, 30);
    spr(1, state.player.x, state.player.y, 0);
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
