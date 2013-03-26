
match both(/per/, no(/piper/)) do
  set manufacturer: 'Per'
end

match /piper/ do
  set manufacturer: 'Piper'

  include_subfolder 'piper'
end
