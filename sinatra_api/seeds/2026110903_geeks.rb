Sequel.seed(:development, :test) do
  def run
    [['Mike', 'Sinatra React', true], ['Alex', 'Ruby React', true],
     ['Martha', 'Rails', false], ['Juri', 'Java', true]].each do |name, stack, resume|
      DB[:geeks].insert(name: name, stack: stack, resume: resume)
    end
  end
end
