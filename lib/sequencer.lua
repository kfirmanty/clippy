local sequencer = {
    ticks = 0,
    state = nil
}

function sequencer:init(state)
    self.state = state
end

function sequencer:tick()
    for tid, t in ipairs(self.state:all_tracks()) do
        local step = self.state:current_step(tid, self.ticks)
        if(step.type == "on") then
            print("sending note on " .. step.note)
        end
    end
    self.ticks = self.ticks + 1
end

return sequencer