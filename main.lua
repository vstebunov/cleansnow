-- title:  clear snow 
-- author: V.Stebunov
-- desc:   clear all snow on winter time
-- script: lua
-- input:  gamepad
-- saveid: VSClearSnow
--
-- make state machine
-- but first we need output map
-- and set player on center

local string="RELAX!"
local width=print(string,0,-6)

local x = (240-width)//2
local y = (136-6)//2

local events = []
local btnLabel={"Up","Down","Left","Right","Btn A","Btn B"}

function readkeyboard() 
    for key = 0, 5 do
        if btn(key) then
            table.insert(events, btnLabel[key + 1] .. " pressed")
        end
    end
end

function showevents()
    for _, event in pairs(events) do
        print(event, 10, 10 + i * 10)
    end
end

function draw()
    cls(0);
    map(0, 0, 5, 5, 30, 30);
    spr(1, 32, 32, 0);
    print(string, x, y)
end

function TIC() 
    readkeyboard()
    draw()
    showevents()
    -- event done
    table.remove(event, 1);
end
