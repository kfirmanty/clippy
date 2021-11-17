local music_util = require("musicutil")

local sequencer = {
    ticks = 0,
    state = nil
}

function sequencer:init(state)
    self.state = state
end

local function play_engine(note)
  if(engine.name == "PolyPerc") then
    engine.hz(music_util.note_num_to_freq(note))
  else 
    print("unknown engine.name " .. engine.name)
  end
end

function sequencer:tick()
    for tid, t in ipairs(self.state:all_tracks()) do
        local pattern = self.state:pattern(tid)
        if pattern.tick_countdown == 0 then
          local step = self.state:current_step(tid, self.ticks)
          if(step.type == "on") then
              print("sending note on " .. step.note)
              if(self.state:track(tid).type == "engine") then
                play_engine(step.note)
              end
          end
        end
        pattern.tick_countdown = pattern.tick_countdown - 1
        if pattern.tick_countdown < 0 then pattern.tick_countdown = pattern.ticks end
    end
    self.ticks = self.ticks + 1
end

return sequencer