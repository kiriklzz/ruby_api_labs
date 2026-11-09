Sequel.seed(:development, :test) do
  def run
    [['MoGo', 'New York'], ['Wirkkle', 'London'],
     ['Artesis', 'Saint-Petersburg'], ['BuildEmpire', 'London']].each do |name, location|
      DB[:companies].insert(name: name, location: location)
    end
  end
end
