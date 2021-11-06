local state = require("lib/state")
local sequencer = require("lib/sequencer")
local display = require("lib/display")
sequencer:init(state)
display:init(state)

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
sequencer:tick()
sequencer:tick()

print("testing display")
display:on_click({type = "note_on",
                  note = 36})
display:on_click({type = "note_on",
                  note = 36})