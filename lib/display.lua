local push_utils = include("clippy/lib/push_utils")
local notes_view = include("clippy/lib/views/notes")
local patterns_view = include("clippy/lib/views/patterns")
local tracks_view = include("clippy/lib/views/tracks")

local display = {
    state = nil,
    view = nil,
    push = nil
}

function display:set_tracks_view()
    self.view = tracks_view:init(self.state, self.push)
end

function display:set_patterns_view(track_id)
    self.view = patterns_view:init(self.state, self.push, track_id)
end

function display:set_notes_view(track_id, pattern_id)
    self.view = notes_view:init(self.state, self.push, track_id, pattern_id)
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
    if(event.type ~= "key_pressure") then
      print("recv midi event " .. event.type)
    end
    if event.type == "note_on" then
    print("val " .. event.note)  
    end
    self.view:on_click(display, event)
end

return display