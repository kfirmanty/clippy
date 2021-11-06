local push_utils = include("clippy/lib/push_utils")

local display = {
    state = nil,
    view = nil,
    push = nil
}

local tracks_view = {
    state = nil
}

local patterns_view = {
    state = nil,
    track_id = nil
}

local notes_view = {
    state = nil,
    track_id = nil,
    pattern_id = nil
}

function display:set_tracks_view()
    self.view = tracks_view:init(self.state)
end

function display:set_patterns_view(track_id)
    self.view = patterns_view:init(self.state, track_id)
end

function display:set_notes_view(track_id, pattern_id)
    self.view = notes_view:init(self.state, track_id, pattern_id)
end

function display:init(state)
    self.state = state
    self.push = push_utils.connect()
    push_utils.init_user_mode(self.push)
    local on_midi = function(m) self:on_click(m) end
    self.push.event = on_midi
    self:set_tracks_view()
end

function display:on_click(m)
    local event = midi.to_msg(m)
    print("recv midi event " .. event.type)
    if event.type == "note_on" then
    print("val " .. event.note)  
    end
    self.view:on_click(display, event)
end

function tracks_view:init(state)
    self.state = state
    push_utils.clear_display(display.push)
    push_utils.text(display.push, "Tracks", 1, 1)
    push_utils.clear_notes(display.push)
    for tid, t in ipairs(self.state.tracks) do
      local x, y = push_utils.id_to_xy(tid)
      push_utils.lit(display.push, x, y, 3)
    end
    return self
end

function tracks_view:on_click(display, event)
    if event.type == "note_on" then
        local tid = push_utils.midi_note_to_track_id(event.note)
        if display.state:track(tid) == nil then
          tid = display.state:add_track()
        end
        display:set_patterns_view(tid)
    end
end

function patterns_view:init(state, track_id)
    self.state = state
    self.track_id = track_id
    push_utils.clear_display(display.push)
    push_utils.text(display.push, "Patterns for track: " .. self.track_id, 1, 1)
    push_utils.clear_notes(display.push)
    for pid, t in ipairs(self.state:track(self.track_id).patterns) do
      local x, y = push_utils.id_to_xy(pid)
      push_utils.lit(display.push, x, y, 3)
    end
    return self
end

function patterns_view:on_click(display, event)
    if event.type == "note_on" then
        local pid = push_utils.midi_note_to_pattern_id(event.note)
        if display.state:pattern(self.track_id, pid) == nil then
            pid = display.state:add_pattern(self.track_id)
        end
        display:set_notes_view(self.track_id, pid)
    end
end

function notes_view:init(state, track_id, pattern_id)
    self.state = state
    self.track_id = track_id
    self.pattern_id = pattern_id
    push_utils.clear_display(display.push)
    push_utils.text(display.push, "Notes for pattern: " .. self.pattern_id .. " on track " .. self.track_id, 1, 1)
    push_utils.clear_notes(display.push)
    for i, step in ipairs(self.state:pattern(self.track_id, self.pattern_id).notes) do
        if(step.type ~= "off") then
          local x, y = push_utils.id_to_xy(i)
          push_utils.lit(display.push, x, y, step.note)
        end
    end
    return self
end

function notes_view:on_click(display, event)
    if event.type == "note_on" then

    end
end

return display