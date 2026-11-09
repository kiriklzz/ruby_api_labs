Sequel.seed(:development, :test) do
  def run
    [:applies, :geeks, :jobs, :companies].each do |table|
      DB[table].truncate(cascade: true, restart: true)
    end
  end
end
