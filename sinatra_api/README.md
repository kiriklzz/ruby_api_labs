# API, части 2–4

Ruby 3.2+, PostgreSQL. Rails из части 1 находится отдельно в `../rails_api`.

## Часть 2: маршруты Sinatra

```sh
bundle install
bundle exec ruby my_sinatra.rb
bundle exec ruby -Itest test/routes_test.rb
```

Примеры: `/hello/Peter`, `/redirect`, `/say/hello/to/world`,
`/download/path/to/file.xml`, `/jobs.json`, `/api/v1/friends`.

## Часть 3: PostgreSQL и Sequel

```sh
createdb -h localhost sinatra_seq_dev
createdb -h localhost sinatra_seq_test
cp .env.example .env
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rake db:version
bundle exec rackup -p 4567 config.ru
```

Подключение берётся из `config/database.yml` и переменных `PGHOST`, `PGUSER`,
`PGPASSWORD`. `DATABASE_URL` имеет приоритет. Пароли в репозитории не хранятся.
`RACK_ENV` выбирает development/test/production.

`db:migrate[2]` мигрирует до версии 2, `db:rollback[0]` откатывает всё,
`db:reset` пересоздаёт таблицы. Эти команды могут удалить данные.
`db:seed` очищает учебные таблицы и сбрасывает их ID; работает только в development/test.
Чтобы повторить seeds, удалите записи `schema_seeds` в своей учебной БД.

```sh
RACK_ENV=test bundle exec rake db:migrate
RACK_ENV=test bundle exec rake test
bundle exec sequel postgres://localhost/sinatra_seq_dev
```

В консоли: `DB[:companies].select(:id, :name).order(:name).where { id < 3 }.all`.
