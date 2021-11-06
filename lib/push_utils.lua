local utils = {}

function utils.id_to_xy(id)
  local y = math.floor((id - 1) / 8) + 1
  local x = (id - 1 % 8) + 1
  return x, y
end

function utils.midi_note_to_xy(note)
  local y = 8 - math.floor((note - 36) / 8)
  local x = ((note - 36) % 8) + 1
  return x, y
end

function utils.midi_note_to_track_id(note)
    local x, y = utils.midi_note_to_xy(note)
    return ((y - 1) * 8) + x
end

function utils.midi_note_to_pattern_id(note)
  local x, y = utils.midi_note_to_xy(note)
  return ((y - 1) * 8) + x
end

function utils.connect()
  return midi.connect(2)
end

function utils.send_sysex(m, d)
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

function utils.clear_display(m)
  for i = 0, 3 do
    utils.send_sysex(m, {240,71,127,21, 28 + i,0,0,247})
  end
end

local pad_notes = {
  {92, 93, 94, 95, 96, 97, 98, 99},
  {84, 85, 86, 87, 88, 89, 90, 91},
  {76, 77, 78, 79, 80, 81, 82, 83},
  {68, 69, 70, 71, 72, 73, 74, 75},
  {60, 61, 62, 63, 64, 65, 66, 67},
  {52, 53, 54, 55, 56, 57, 58, 59},
  {44, 45, 46, 47, 48, 49, 50, 51},
  {36, 37, 38, 39, 40, 41, 42, 43},
}

function utils.lit(m, x, y, v)
  m:note_on(pad_notes[y][x], v)
end

function utils.clear_notes(m)
  for _, row in ipairs(pad_notes) do
    for _, v in ipairs(row) do
    m:note_off(v)
    end
  end
end

return utils