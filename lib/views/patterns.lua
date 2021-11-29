local push_utils = include("clippy/lib/push_utils")

local patterns_view = {
    state = nil,
    push = nil,
    edit_pattern_on_press = false
}

function patterns_view:draw_patterns()
  for tid = 1, 8 do
    local track = self.state:track(tid)
    if track ~= nil then
      for pid, p in ipairs(track.patterns) do
        local color = track.current_pattern == pid and push_utils.pad_colors.LIGHT_GREEN or tid * 2
        push_utils.lit(self.push, tid, pid, color)
      end
    end
  end
end

function patterns_view:init(state, push)
    self.state = state
    self.push = push
    push_utils.clear_display(self.push)
    push_utils.text(self.push, "All patterns", 1, 1)
    push_utils.clear_notes(self.push)
    push_utils.clear_steps(self.push)
    self:draw_patterns()
    return self
end

function patterns_view:on_click(display, event)
    if event.type == "note_on" then
        local tid, pid = push_utils.midi_note_to_tid_pid(event.note)
        if self.edit_pattern_on_press then
          if display.state:track(tid) == nil then
            tid = display.state:add_track()
          end
          if display.state:pattern(tid, pid) == nil then
              pid = display.state:add_pattern(tid)
          end
          display:set_notes_view(tid, pid)
        elseif display.state:pattern(tid, pid) ~= nil then
          self.state:set_track_pattern(tid, pid)
          self:draw_patterns()
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