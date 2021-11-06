local utils = {}

function utils.midi_note_to_track_id(note)
    return 1 --FIXME
end

function utils.midi_note_to_pattern_id(note)
    return 1 --FIXME
end

function utils.connect()
  return midi.connect(2)
end

function utils.send_sysex(m, d)
  print("sending sysex to push")
  m:send{0xf0}
  for i,v in ipairs(d) do
    m:send{d[i]}
  end
  m:send{0xf7}  
end

function utils.init_user_mode(m)
  utils.send_sysex(m, {71,127,21,98,0,1,1})
end

function utils.text(m, text, line, offset)
  local text_len = string.len(text)
  local msg = {71,127,21,24 + line - 1 ,0,text_len + 1,offset - 1}
  for i = 1, text_len do
    table.insert(msg, string.byte(text, i))
  end
  utils.send_sysex(m, msg)
end

local pad_notes = {
  {56, 57, 58, 59, 60, 61, 62, 63},
  {48, 49, 50, 51, 52, 53, 54, 55},
  {40, 41, 42, 43, 44, 45, 46, 47},
  {32, 33, 34, 35, 36, 37, 38, 39},
  {24, 25, 26, 27, 28, 29, 30, 31},
  {16, 17, 18, 19, 20, 21, 22, 23},
  {8, 9, 10, 11, 12, 13, 14, 15},
  {0, 1, 2, 3, 4, 5, 6, 7}
}

function utils.lit(m, x, y, v)
  m:note_on(pad_notes[x][y], v)
end

return utils