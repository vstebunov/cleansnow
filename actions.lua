local do_state = {}

do_state["Up_pressed"] = function(state) 
    state.player.x -= 1
    return state
end

do_state["Init"] = function()
    return {
        player : {
            x : 32,
            y : 32
        }
    }
end

return do_state
