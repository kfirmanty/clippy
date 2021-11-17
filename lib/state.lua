local utils = include("clippy/lib/utils")
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
    return track.patterns[pattern_id or track.current_pattern]
end

function state:add_track()
    table.insert(self.tracks, {patterns = {},
                                current_pattern = 1,
                                type = "engine"})
    return #self.tracks
end

function off_step()
    return {type = "off",
            note = 36,
            length = 1}
end

function state:add_pattern(track_id)
    table.insert(self.tracks[track_id].patterns, {type = "melodic",
                                                    notes = utils.repeatedly(off_step, 16),
                                                    length = 16})
    return #self.tracks[track_id].patterns
end

function state:step(track_id, pattern_id, step)
    return self.tracks[track_id].patterns[pattern_id].notes[step]
end

function state:current_step(track_id, tick)
    local p = self:pattern(track_id)
    local step = (tick % p.length) + 1
    return p.notes[step]
end

function state:edit_step(track_id, pattern_id, step, k, v)
    self:step(track_id, pattern_id, step)[k] = v
end

function state:toggle_step(track_id, pattern_id, step)
    local step_data = self:step(track_id, pattern_id, step)
    local new_type = step_data.type == "on" and "off" or "on"
    self:edit_step(track_id, pattern_id, step, "type", new_type)
end

return state
