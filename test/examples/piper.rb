
match both(/per/, no(/piper/)) do
  set manufacturer: 'Per'
end

match both('string', /regex/) do
  set manufacturer: 'success'
end

match /piper/ do
  set manufacturer: 'Piper'

  include_subfolder 'piper'
end
