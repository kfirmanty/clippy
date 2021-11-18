local sequencer = {
    state = nil
}

function sequencer:init(state)
    self.state = state
end

function sequencer:tick()
    for tid, t in ipairs(self.state:all_tracks()) do
      self.state:tick(tid)
    end
end

return sequencer