require_relative '../../config/database'
Sequel.extension :migration

namespace :db do
  migrations = File.expand_path('../../db/migrations', __dir__)

  desc 'Show schema version'
  task :version do
    puts "Schema Version: #{DB.table_exists?(:schema_info) ? DB[:schema_info].get(:version) : 0}"
  end

  desc 'Migrate to latest or given version'
  task :migrate, [:version] do |_, args|
    options = args[:version] ? { target: Integer(args[:version]) } : {}
    Sequel::Migrator.run(DB, migrations, **options)
  end

  desc 'Rollback to given version (default: 0)'
  task :rollback, [:target] do |_, args|
    Sequel::Migrator.run(DB, migrations, target: Integer(args[:target] || 0))
  end

  desc 'Drop and recreate the schema'
  task :reset do
    Sequel::Migrator.run(DB, migrations, target: 0)
    Sequel::Migrator.run(DB, migrations)
  end

  desc 'Replace development/test data with example records'
  task :seed do
    environment = ENV.fetch('RACK_ENV', 'development').to_sym
    abort 'Seeds are only for development and test' unless [:development, :test].include?(environment)
    Sequel.extension :seed
    Sequel::Seed.setup environment
    Sequel::Seeder.apply(DB, File.expand_path('../../seeds', __dir__))
  end
end
