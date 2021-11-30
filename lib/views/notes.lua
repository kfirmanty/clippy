local push_utils = include("clippy/lib/push_utils")
local melodic_view = include("clippy/lib/views/notes/melodic")
local steps_view = include("clippy/lib/views/notes/steps")

local notes_view = {
    state = nil,
    track_id = nil,
    pattern_id = nil,
    push = nil,
    keyboard_view = nil,
    steps_view = nil,
}

function notes_view:display_step_info()
  local step = self.state:step(self.track_id, self.pattern_id, self.steps_view.selected_step)
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
    
    self.keyboard_view = melodic_view:init(state, push, track_id, pattern_id)
    self.steps_view = steps_view:init(state, push, track_id, pattern_id)

    self:display_step_info()
    
    return self
end

function notes_view:on_click(display, event)
    if event.type == "cc" and event.cc >= 71 and event.cc <= 79 then -- parameters encoders touched
        local pattern = self.state:pattern(self.track_id, self.pattern_id)
        local inc = push_utils.enc_to_inc(event.val)
      if(event.cc == 73) then --change pattern length
        pattern.length = math.max(1, math.min(16, pattern.length + inc))
        push_utils.clear_steps(self.push)
        self.steps_view:draw_steps()
      elseif(event.cc == 75) then
        pattern.ticks = math.max(1, pattern.ticks + inc)
      end
      self:display_step_info()
    end
    
    local new_step = self.steps_view:on_click(display, event)
    if new_step ~= nil then
      self.keyboard_view.selected_step = new_step
      self.keyboard_view:redraw()
      self:display_step_info()
    end
    
    if self.keyboard_view:on_click(display, event) == "SELECTED_NOTE_CHANGED" then
      self:display_step_info()
    end
end

function notes_view:on_tick()
  self.steps_view:on_tick()
end

return notes_view