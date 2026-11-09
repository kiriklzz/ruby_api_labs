require 'dotenv/load'
require 'sequel'
require 'yaml'

environment = ENV.fetch('RACK_ENV', 'development')
config = YAML.safe_load_file(File.join(__dir__, 'database.yml')).fetch(environment)
DB = Sequel.connect(ENV['DATABASE_URL'] || {
  adapter: 'postgres',
  host: ENV.fetch('PGHOST', 'localhost'),
  database: config.fetch('database'),
  user: ENV.fetch('PGUSER', ENV['USER']),
  password: ENV['PGPASSWORD']
})
