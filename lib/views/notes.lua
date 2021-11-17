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
  local pattern = self.state:pattern(self.track_id, self.pattern_id)
      for i, step in ipairs(pattern.notes) do
        if(i > pattern.length) then
          break
        end
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
  local pattern = self.state:pattern(self.track_id, self.pattern_id)
  push_utils.text(self.push, "Length:", 3, 18)
  push_utils.text(self.push, pattern.length .. "  ", 4, 18)
  
  push_utils.text(self.push, "Ticks:", 3, 35)
  push_utils.text(self.push, pattern.ticks .. "  ", 4, 35)
end

function notes_view:init(state, push, track_id, pattern_id)
    self.state = state
    self.track_id = track_id
    self.pattern_id = pattern_id
    self.push = push
    push_utils.clear_display(self.push)
    push_utils.text(self.push, "Notes for pattern: " .. self.pattern_id .. " on track " .. self.track_id, 1, 1)
    push_utils.clear_notes(self.push)
    push_utils.clear_steps(self.push)
    self:draw_steps()
    self:display_step_info()
    self:draw_melodic()
    return self
end

function notes_view:on_click(display, event)
    if event.type == "note_on" and event.note >= push_utils.base_note then -- notes keyboard touched
        local note = event.note - push_utils.base_note + notes_view.base_note
        self.state:edit_step(self.track_id, self.pattern_id, self.selected_step, "note", note)
        self:draw_melodic()
        self:display_step_info()
    elseif (event.type == "cc" and event.val == 127 and ((event.cc >= 20 and event.cc <= 27) or (event.cc >= 102 and event.cc <= 109))) then -- step sequencer touched
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
    elseif event.type == "cc" and event.cc >= 71 and event.cc <= 79 then -- parameters encoders touched
        local pattern = self.state:pattern(self.track_id, self.pattern_id)
        local inc = push_utils.enc_to_inc(event.val)
      if(event.cc == 73) then --change pattern length
        pattern.length = math.max(1, math.min(16, pattern.length + inc))
        push_utils.clear_steps(self.push)
        self:draw_steps()
      elseif(event.cc == 75) then
        pattern.ticks = math.max(1, pattern.ticks + inc)
      end
      self:display_step_info()
    end
end

return notes_view