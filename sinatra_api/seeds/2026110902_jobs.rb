Sequel.seed(:development, :test) do
  def run
    [['Sinatra React', 'Remote', 1], ['Ruby React', 'Contract', 2],
     ['React', 'Remote', 3], ['Node React', 'Permanent', 1],
     ['Ruby on Rails', 'Remote', 4], ['Node', 'Permanent', 4],
     ['Javascript CSS HTML', 'Permanent', 4], ['Jira', 'Remote', 2]].each do |name, place, company_id|
      DB[:jobs].insert(name: name, place: place, company_id: company_id)
    end
    DB[:jobs].insert(id: 11, name: 'C++', place: 'Contract', company_id: 2)
    DB.reset_primary_key_sequence(:jobs)
  end
end
