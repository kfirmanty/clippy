local push_utils = include("clippy/lib/push_utils")

local tracks_view = {
    state = nil,
    push = nil
}

function tracks_view:init(state, push)
    self.state = state
    self.push = push
    push_utils.clear_display(self.push)
    push_utils.text(self.push, "Tracks", 1, 1)
    push_utils.clear_notes(self.push)
    push_utils.clear_steps(self.push)
    for tid, t in ipairs(self.state.tracks) do
      local x, y = push_utils.id_to_xy(tid)
      push_utils.lit(self.push, x, y, 3)
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

return tracks_view