local push_utils = include("clippy/lib/push_utils")

local steps_view = {
    state = nil,
    track_id = nil,
    pattern_id = nil,
    push = nil,
    selected_step = 1,
    base_note = 36
}

function steps_view:draw_steps()
  local pattern = self.state:pattern(self.track_id, self.pattern_id)
      for i, step in ipairs(pattern.notes) do
        if(i > pattern.length) then
          break
        end
        local color = nil
        if(i == pattern.step) then
          color = "yellow"
        elseif(step.type == "on" and i == self.selected_step) then
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

function steps_view:init(state, push, track_id, pattern_id)
    self.state = state
    self.track_id = track_id
    self.pattern_id = pattern_id
    self.push = push
    push_utils.clear_steps(self.push)
    self:draw_steps()
    return self
end

function steps_view:on_click(display, event)
    if (event.type == "cc" and event.val == 127 and ((event.cc >= 20 and event.cc <= 27) or (event.cc >= 102 and event.cc <= 109))) then
        local prev_selected = self.selected_step
        self.selected_step = push_utils.cc_to_step(event.cc)
        if(prev_selected ~= self.selected_step) then
          self:draw_steps()
          return self.selected_step
        else
          self.state:toggle_step(self.track_id, self.pattern_id, self.selected_step)
          self:draw_steps()
        end
    end
end

function steps_view:on_tick()
  self:draw_steps()
end

return steps_view