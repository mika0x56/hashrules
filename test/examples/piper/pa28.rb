
match /pa 28/, /pa28/ do
  set family: 'PA-28 Cherokee'
  set engine_count: 1
  set category: 'piston'

  match /pa28 181/, /pa 28 181/ do
    set model: 'PA-28-181'
    set horsepower: 180

    match /archer ii/, /archer 2/, /ii/ do
      set model: 'PA-28-181 Archer II'
    end

    match /archer iii/, /archer 3/, /iii/ do
      set model: 'PA-28-181 Archer III'
    end
  end
end
