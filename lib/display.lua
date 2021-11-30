local push_utils = include("clippy/lib/push_utils")
local notes_view = include("clippy/lib/views/notes")
local patterns_view = include("clippy/lib/views/patterns")
local tracks_view = include("clippy/lib/views/tracks")

local display = {
    state = nil,
    view = nil,
    push = nil,
    pattern_id = nil,
    view_name = "tracks",
    sequencer = nil,
    is_playing = false,
    clock_id = nil
}

function display:back()
  if self.view_name == "notes" then
    self:set_patterns_view()  
  end
end

function display:set_tracks_view()
    self.view_name = "tracks"
    self.view = tracks_view:init(self.state, self.push)
end

function display:set_patterns_view()
    self.view_name = "patterns"
    self.view = patterns_view:init(self.state, self.push, track_id)
end

function display:set_notes_view(track_id, pattern_id)
    self.view_name = "notes"
    self.pattern_id = pattern_id
    self.view = notes_view:init(self.state, self.push, track_id, pattern_id)
end

function display:init(state, sequencer)
    self.state = state
    self.sequencer = sequencer
    self.push = push_utils.connect()
    push_utils.init_user_mode(self.push)
    local on_midi = function(m) self:on_click(m) end
    self.push.event = on_midi
    self:set_patterns_view()
end

function display:tick_sequencer()
  while true do
      clock.sync(1/8)
      self.sequencer:tick()
      if(self.view.on_tick) then
        self.view:on_tick()
      end
    end
end

function display:handle_start_button()
  if(self.is_playing) then
    self.is_playing = false
    clock.cancel(self.clock_id)
        push_utils.unlit_button(self.push, push_utils.buttons.PLAY)
  else
    self.is_playing = true
    self.clock_id = clock.run(function() self:tick_sequencer() end)
    push_utils.lit_button(self.push, push_utils.buttons.PLAY)
  end
end

local function print_debug_midi_info(event)
  if(event.type ~= "key_pressure") then
      print("recv midi event " .. event.type)
    end
    if event.type == "note_on" then
    print("val " .. event.note)  
    elseif event.type == "cc" then
      print("cc " .. event.cc .. " val " .. event.val)
    end
end

function display:on_click(m)
    local event = midi.to_msg(m)
    if push_utils.is_button_press(event, push_utils.buttons.LEFT_ARROW) then
      self:back()
      return nil
    elseif push_utils.is_button_press(event, push_utils.buttons.PLAY) then
      self:handle_start_button()
      return nil
    end
    
    print_debug_midi_info(event)
    self.view:on_click(display, event)
end

return display