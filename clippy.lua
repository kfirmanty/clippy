local state = include("clippy/lib/state")
local sequencer = include("clippy/lib/sequencer")
local display = include("clippy/lib/display")

engine.name = "PolyPerc"

state:add_track()
state:add_pattern(1)
state:toggle_step(1, 1, 1)
state:edit_step(1, 1, 1, "note", 48)
state:edit_step(1, 1, 5, "note", 51)
state:toggle_step(1, 1, 5)

sequencer:init(state)

display:init(state, sequencer)

function init()
end

function redraw()
  screen.clear()
  screen.level(10)
  screen.update()
end

function key(n,z)
  
end

function enc(n,d)
end
