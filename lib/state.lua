local utils = include("clippy/lib/utils")
local music_util = require("musicutil")
local state = {
    tracks = {},
    scale = nil,
    bpm = 120,
    midi = {}, -- initialize midi
    push = {} -- add push subsystem
}

function state:all_tracks()
    return self.tracks
end

function state:track(track_id)
  return self.tracks[track_id]
end

function state:pattern(track_id, pattern_id)
    local track = self.tracks[track_id]
    if track then
      return track.patterns[pattern_id or track.current_pattern]
    end
end

function state:add_track()
    table.insert(self.tracks, {patterns = {},
                                current_pattern = 1,
                                type = "engine"})
    local tid = #self.tracks
    self:add_pattern(tid)
    return tid
end

function off_step()
    return {type = "off",
            note = 36,
            length = 1}
end

function state:add_pattern(track_id)
    table.insert(self.tracks[track_id].patterns, {type = "melodic",
                                                    notes = utils.repeatedly(off_step, 16),
                                                    length = 16,
                                                    ticks = 1,
                                                    tick_countdown = 0,
                                                    step = 1
    })
    return #self.tracks[track_id].patterns
end

function state:step(track_id, pattern_id, step)
    return self.tracks[track_id].patterns[pattern_id].notes[step]
end

function state:current_step(track_id)
    local p = self:pattern(track_id)
    return p.notes[p.step]
end

function state:edit_step(track_id, pattern_id, step, k, v)
    self:step(track_id, pattern_id, step)[k] = v
end

function state:toggle_step(track_id, pattern_id, step)
    local step_data = self:step(track_id, pattern_id, step)
    local new_type = step_data.type == "on" and "off" or "on"
    self:edit_step(track_id, pattern_id, step, "type", new_type)
end

function state:set_track_pattern(track_id, pattern_id)
  self.tracks[track_id].current_pattern = pattern_id
end

local function play_engine(note)
  if(engine.name == "PolyPerc") then
    engine.hz(music_util.note_num_to_freq(note))
  else 
    print("unknown engine.name " .. engine.name)
  end
end

function state:tick(tid)
    local pattern = self:pattern(tid)
        if pattern.tick_countdown == 0 then
          local step = self:current_step(tid)
          if(step.type == "on") then
              print("sending note on " .. step.note)
              if(self:track(tid).type == "engine") then
                play_engine(step.note)
              end
          end
          pattern.step = (pattern.step % pattern.length) + 1
        end
        pattern.tick_countdown = pattern.tick_countdown - 1
      if pattern.tick_countdown < 0 then pattern.tick_countdown = pattern.ticks end
end

return state
