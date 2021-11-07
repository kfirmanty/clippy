local push_utils = include("clippy/lib/push_utils")

local notes_view = {
    state = nil,
    track_id = nil,
    pattern_id = nil,
    push = nil
}

function notes_view:init(state, push, track_id, pattern_id)
    self.state = state
    self.track_id = track_id
    self.pattern_id = pattern_id
    self.push = push
    push_utils.clear_display(self.push)
    push_utils.text(self.push, "Notes for pattern: " .. self.pattern_id .. " on track " .. self.track_id, 1, 1)
    push_utils.clear_notes(self.push)
    for i, step in ipairs(self.state:pattern(self.track_id, self.pattern_id).notes) do
        local x, y = push_utils.id_to_xy(i)
        if(step.type ~= "off") then
          push_utils.lit(self.push, x, y, step.note)
        else
          push_utils.lit(self.push, x, y, 2)
        end
    end
    return self
end

function notes_view:on_click(display, event)
    if event.type == "note_on" then

    end
end

return notes_view