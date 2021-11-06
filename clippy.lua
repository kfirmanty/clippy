local state = require("clippy/lib/state")
local sequencer = require("clippy/lib/sequencer")
local display = require("clippy/lib/display")

engine.name = "PolyPerc"

state:add_track()
state:add_pattern(1)
state:toggle_step(1, 1, 1)
state:add_track()
state:add_pattern(2)
state:toggle_step(2, 1, 1)
state:toggle_step(2, 1, 1)
state:edit_step(2, 1, 1, "note", 48)
state:toggle_step(2, 1, 2)
state:edit_step(2, 1, 2, "note", 46)

print("testing sequencer")
sequencer:init(state)
sequencer:tick()
sequencer:tick()

print("testing display")
display:init(state)
display:on_click({type = "note_on",
                  note = 36})
display:on_click({type = "note_on",
                  note = 36})
                
                
function init()

end

function redraw()
  screen.clear()
  screen.level(10)
  screen.text("hello")
  screen.update()
end

function key(n,z)
  redraw()
end

function enc(n,d)
  redraw()
end