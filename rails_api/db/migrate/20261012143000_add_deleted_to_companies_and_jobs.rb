class AddDeletedToCompaniesAndJobs < ActiveRecord::Migration[7.2]
  def change
    add_column :companies, :deleted, :boolean, default: false, null: false
    add_column :jobs, :deleted, :boolean, default: false, null: false
  end
end
