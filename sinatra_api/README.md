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

## Часть 4: запросы API

Все маршруты ниже начинаются с `http://localhost:4567/api/v1`:

| Метод | Путь | Что возвращает |
| --- | --- | --- |
| GET | `/companies?name=Mo&location=Ne` | Компании, оба фильтра необязательны |
| GET | `/company/2` | Компания со всеми полями |
| GET | `/company_jobs?name=Mo` | Вакансии подходящих компаний |
| POST | `/companies` | Новая компания, статус 201 |
| GET | `/jobs?name=React&place=Rem&company=Mo` | Вакансии с необязательными фильтрами |
| GET | `/jobs_company/MoGo` | Вакансии компании с точным именем |
| GET | `/job/1` | Вакансия со всеми полями |
| GET | `/geeks`, `/geek/1` | Соискатели |
| GET | `/applies`, `/apply/1` | Отклики |
| GET | `/applies_read`, `/applies_unread` | Прочитанные/непрочитанные отклики |

Поиск — по подстроке без учёта регистра. Несколько фильтров соединяются через `&`.
Пустая выборка возвращает `[]`, неизвестный ID — 404, неверное тело — 400/422.
POST принимает JSON или form data; разрешены только `name` и `location`.

```sh
curl 'http://localhost:4567/api/v1/companies?name=Mo&location=Ne'
curl -X POST http://localhost:4567/api/v1/companies \
  -H 'Content-Type: application/json' \
  -d '{"name":"Dieter","location":"Ubud"}'
```

В Postman импортируйте `sinatra-api.postman_collection.json`. Переменная `base_url`
уже задана. Запрос POST добавляет запись в development-базу.
Учебное API запускается локально; авторизация в заданиях 2–4 не предусмотрена.
