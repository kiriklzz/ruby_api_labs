Sequel.seed(:development, :test) do
  def run
    [[1, 1, true, false], [2, 3, false, false], [1, 2, true, true],
     [3, 1, false, false], [5, 2, false, false], [2, 4, true, true]].each do |job_id, geek_id, read, invited|
      DB[:applies].insert(job_id: job_id, geek_id: geek_id, read: read, invited: invited)
    end
  end
end
