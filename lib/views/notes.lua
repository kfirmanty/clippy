local push_utils = include("clippy/lib/push_utils")

local notes_view = {
    state = nil,
    track_id = nil,
    pattern_id = nil,
    push = nil,
    selected_step = 1,
    base_note = 36
}

function notes_view:draw_melodic()
  local step = self.state:step(self.track_id, self.pattern_id, self.selected_step)
  local i = 1
  for y = 8,1,-1 do
    for x = 1,8 do
      local color = (i - 1) % 12 == 0 and 9 or 40
      if(i - 1 + self.base_note == step.note) then color = 29 end -- note of selected step
      push_utils.lit(self.push, x, y, color) 
      i = i + 1
    end
  end
end

function notes_view:draw_steps()
      for i, step in ipairs(self.state:pattern(self.track_id, self.pattern_id).notes) do
        local color = nil
        if(step.type == "on" and i == self.selected_step) then
          color = "green"
        elseif(i == self.selected_step) then
          color = "red"
        elseif(step.type ~= "off") then
          color = "green_dim"
        else
          color = "red_dim"
        end
        push_utils.lit_step(self.push, i, color)
    end
end

function notes_view:display_step_info()
  local step = self.state:step(self.track_id, self.pattern_id, self.selected_step)
  if(step ~= nil) then
    push_utils.text(self.push, "Note:", 3, 1)
    push_utils.text(self.push, step.note .. "  ", 4, 1)
  end
end

function notes_view:init(state, push, track_id, pattern_id)
    self.state = state
    self.track_id = track_id
    self.pattern_id = pattern_id
    self.push = push
    push_utils.clear_display(self.push)
    push_utils.text(self.push, "Notes for pattern: " .. self.pattern_id .. " on track " .. self.track_id, 1, 1)
    push_utils.clear_notes(self.push)
    self:draw_steps()
    self:display_step_info()
    self:draw_melodic()
    return self
end

function notes_view:on_click(display, event)
    if event.type == "note_on" then
        local note = event.note - push_utils.base_note + notes_view.base_note
        self.state:edit_step(self.track_id, self.pattern_id, self.selected_step, "note", note)
        self:draw_melodic()
        self:display_step_info()
    elseif (event.type == "cc" and event.val == 127) then
        local prev_selected = self.selected_step
        self.selected_step = push_utils.cc_to_step(event.cc)
        if(prev_selected ~= self.selected_step) then
          self:draw_steps()
          self:draw_melodic()
          self:display_step_info()
        else
          self.state:toggle_step(self.track_id, self.pattern_id, self.selected_step)
          self:draw_steps()
        end
    end
end

return notes_view