local state = include("clippy/lib/state")
local sequencer = include("clippy/lib/sequencer")
local display = include("clippy/lib/display")

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

display:init(state)

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
