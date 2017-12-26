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

function TIC() 
    cls(0);
    map(0, 0, 5, 5, 30, 30);
    spr(1, 32, 32);
    print(string, x, y)
end
