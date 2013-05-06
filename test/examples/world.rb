
match 'canada' do
  set country: 'Canada'
  include_subfolder('canada')
end

match w(/u ?s ?a?/), 'united states' do
  set country: 'United States'
  include_subfolder('united states')
end
