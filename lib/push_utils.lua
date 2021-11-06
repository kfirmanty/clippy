local utils = {}

function utils.midi_note_to_track_id(note)
    return 1 --FIXME
end

function utils.midi_note_to_pattern_id(note)
    return 1 --FIXME
end

function utils.connect()
  return midi.connect()
end

return utils