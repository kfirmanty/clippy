local push_utils = include("clippy/lib/push_utils")
local scales = include("clippy/lib/views/notes/scales")

local melodic_view = {
    state = nil,
    track_id = nil,
    pattern_id = nil,
    push = nil,
    selected_step = 1,
    base_note = 36,
    scale = scales.minor
}

function melodic_view:redraw()
  local step = self.state:step(self.track_id, self.pattern_id, self.selected_step)
  for y = 8,1,-1 do
    for x = 1,8 do
      local note = self.base_note + self.scale[y][x]
      local color = note % 12 == 0 and push_utils.pad_colors.ORANGE or push_utils.pad_colors.LIGHT_BLUE
      if(note == step.note) then color = push_utils.pad_colors.LIGHT_GREEN end -- note of selected step
      push_utils.lit(self.push, x, y, color) 
    end
  end
end

function melodic_view:init(state, push, track_id, pattern_id)
    self.state = state
    self.track_id = track_id
    self.pattern_id = pattern_id
    self.push = push
    push_utils.clear_notes(self.push)
    self:redraw()
    return self
end

function melodic_view:on_click(display, event)
    if event.type == "note_on" and event.note >= push_utils.base_note then -- notes keyboard touched
       local x, y = push_utils.midi_note_to_xy(event.note)
        local note = self.scale[y][x] + self.base_note
        self.state:edit_step(self.track_id, self.pattern_id, self.selected_step, "note", note)
        self:redraw()
        return "SELECTED_NOTE_CHANGED"
    end
end

return melodic_view