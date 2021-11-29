local push_utils = include("clippy/lib/push_utils")

local patterns_view = {
    state = nil,
    track_id = nil,
    push = nil,
    edit_pattern_on_press = false
}

function patterns_view:init(state, push, track_id)
    self.state = state
    self.track_id = track_id
    self.push = push
    push_utils.clear_display(self.push)
    push_utils.text(self.push, "Patterns for track: " .. self.track_id, 1, 1)
    push_utils.clear_notes(self.push)
    push_utils.clear_steps(self.push)
    for pid, t in ipairs(self.state:track(self.track_id).patterns) do
      local x, y = push_utils.id_to_xy(pid)
      push_utils.lit(self.push, x, y, push_utils.pad_colors.WHITE)
    end
    return self
end

function patterns_view:on_click(display, event)
    if event.type == "note_on" then
        local pid = push_utils.midi_note_to_pattern_id(event.note)
        if self.edit_pattern_on_press then
          if display.state:pattern(self.track_id, pid) == nil then
              pid = display.state:add_pattern(self.track_id)
          end
          display:set_notes_view(self.track_id, pid)
        elseif display.state:pattern(self.track_id, pid) ~= nil then
          self.state:set_track_pattern(self.track_id, pid)
        end
    elseif push_utils.is_button_press(event, push_utils.buttons.RECORD) then
      self.edit_pattern_on_press = not self.edit_pattern_on_press
      if self.edit_pattern_on_press then
        push_utils.lit_button(self.push, push_utils.buttons.RECORD)
      else
        push_utils.unlit_button(self.push, push_utils.buttons.RECORD)
      end
    end
end

return patterns_view