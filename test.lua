-- name: test
-- description: test
-- unfinished, and i'm tired as I wrote this so expect dumb code mistakes and grammar mistakes
--- @param m MarioState
function mario_on_set_action(m)

    if (m.action == ACT_TRIPLE_JUMP) then -- if mario triple jumps
        mario_blow_off_cap(m, 1) --maker mario lose his cap, no idea on how to actually make the cap fly off his head
        print("triple jumped")
    end

    if (m.action == ACT_START_CROUCHING) then -- if mario starts crouching
        mario_retrieve_cap(m) --mario gets his cap back, he doesnt put it on though, i need to fix that
        print("crouched")
    end

    if (m.action == ACT_STOP_CROUCHING) then -- if mario finishes crouching
        cutscene_put_cap_on(m) -- make mario put his cap on
        print("finished crouching")
    end
end

-- hooks --
hook_event(HOOK_ON_SET_MARIO_ACTION, mario_on_set_action)