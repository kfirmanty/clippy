local push_utils = require("lib/push_utils")

local display = {
    state = nil,
    view = nil
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
end

function display:on_click(event)
    self.view:on_click(display, event)
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