local push_utils = require("clippy/lib/push_utils")

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
    self:set_tracks_view()
    self.push = push_utils.connect()
    push_utils.init_user_mode(self.push)
    push_utils.clear_display(self.push)
    push_utils.text(self.push, "Hello from Norns!", 1, 1)
    push_utils.lit(self.push, 1, 1, 3)
    push_utils.lit(self.push, 4, 4, 64)
    local on_midi = function(m) self:on_click(m) end
    self.push.event = on_midi
end

function display:on_click(m)
    local event = midi.to_msg(m)
    print("recv midi event " .. event.type)
    self.view:on_click(display, event)
end

function display:text(text)

end

function tracks_view:init(state)
    self.state = state
    print("tracks view")
    return self
end

function tracks_view:on_click(display, event)
    if event.type == "note_on" then
        local tid = push_utils.midi_note_to_track_id(event.note)
        display:set_patterns_view(tid)
    end
end

function patterns_view:init(state, track_id)
    self.state = state
    self.track_id = track_id
    print("patterns view for track: " .. self.track_id)
    return self
end

function patterns_view:on_click(display, event)
    if event.type == "note_on" then
        local pid = push_utils.midi_note_to_pattern_id(event.note)
        if pid == nil then
            pid = display.state:add_pattern(self.track_id)
        end
        display:set_notes_view(self.track_id, pid)
    end
end

function notes_view:init(state, track_id, pattern_id)
    self.state = state
    self.track_id = track_id
    self.pattern_id = pattern_id
    print("notes view for track: " .. self.track_id .. " and pattern: " .. self.pattern_id)
    return self
end

function notes_view:on_click(display, event)
    if event.type == "note_on" then
        
    end
end

return display