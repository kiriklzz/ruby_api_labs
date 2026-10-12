ActiveRecord::Base.transaction do
  companies = [
    ["MoGo", "New York"],
    ["Wirkkle", "London"],
    ["Artesis", "Saint-Petersburg"],
    ["BuildEmpire", "London"]
  ].map do |name, location|
    Company.find_or_create_by!(name: name, location: location)
  end

  jobs = [
    ["Sinatra React", "Remote", companies[0]],
    ["Ruby React", "Contract", companies[1]],
    ["React", "Remote", companies[2]],
    ["Node React", "Permanent", companies[0]],
    ["Ruby on Rails", "Remote", companies[3]],
    ["Node", "Permanent", companies[3]],
    ["Javascript CSS HTML", "Permanent", companies[3]]
  ].map do |name, place, company|
    Job.find_or_create_by!(name: name, place: place, company: company)
  end

  geeks = [
    ["Mike", "Sinatra React", "Sinatra and React developer"],
    ["Alex", "Ruby React", "Ruby and React developer"],
    ["Martha", "Rails", nil],
    ["Juri", "Java", "Java developer"],
    ["Andrew", "PHP", nil],
    ["Nina", "Node", "Node.js developer"],
    ["Bob", "Front end", "Frontend developer"],
    ["Kate", "PHP", nil],
    ["Boris", "Full stack", "Full stack developer"]
  ].map do |name, stack, resume|
    Geek.find_or_create_by!(name: name, stack: stack) do |geek|
      geek.resume = resume
    end
  end

  [
    [jobs[0], geeks[0], true, true],
    [jobs[0], geeks[1], false, false],
    [jobs[4], geeks[4], true, false],
    [jobs[5], geeks[7], false, false]
  ].each do |job, geek, read, invited|
    Apply.find_or_create_by!(job: job, geek: geek) do |apply|
      apply.read = read
      apply.invited = invited
    end
  end
end
