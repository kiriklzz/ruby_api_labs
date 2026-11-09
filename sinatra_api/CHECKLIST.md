# Сверка с методичками API 2–4

Проверено 09.11.2026. Источники — документы в [папке курса](https://drive.google.com/drive/folders/1JL0DHaFfD9O-uubXGXFqVMIMBrYG9TPA).

## Часть 2

| Практический пункт | Реализация и проверка |
| --- | --- |
| Ruby, Sinatra, Rack, установка зависимостей | `.ruby-version`, `Gemfile`, `Gemfile.lock`; Ruby 3.2.2, Sinatra 4.2.1 |
| Классический стиль, корень, имя, общий splat | `classic.rb`; прямой запуск и HTTP-запросы |
| Классический запуск через Rack | `classic.ru`; проверен `rackup` |
| Namespace внутри и за пределами `/api/v1` | `classic.rb`, `my_sinatra.rb`; `/friends`, `/api/v1/friends` |
| Модульный стиль, `Sinatra::Base`, регистрация Namespace | `MyAppModule::App` в `my_sinatra.rb` |
| Модульный запуск через Rack | `modular.ru`; проверен `rackup` |
| Именованные параметры | `/hello/:name`, `/players/:sport_id` |
| Именованные параметры в аргументах блока | `/hello_block/:name` |
| Сочетание splat и параметра | `/players/*/:year` |
| Redirect | `/redirect` → `/hello/World` |
| Регулярное выражение | `/meta/hello/world`, `/meta/hello/12345/world` |
| Два splat, путь и расширение | `/say/*/to/*`, `/download/*.*` |
| Необязательный формат | `/jobs`, `/jobs.json`, `/jobs.xml` |
| Структура итогового проекта и загрузка файлов | `config`, `models`, `helpers`, `lib`, `routes`; загрузка относительно `__dir__` |
| Классическая сборка итогового API и корень | `api_sinatra_postgres.rb`, `config.ru`; реальный HTTP-запуск |
| Запуск в RubyMine | Ручной пункт IDE: инструкции в README; саму IDE не запускали |

## Часть 3

| Практический пункт | Реализация и проверка |
| --- | --- |
| PostgreSQL, отдельные окружения | PostgreSQL установлен; dev/test созданы, production задан в `database.yml` |
| Роль и пароль | Используется существующая локальная роль; другую роль можно задать через `PGUSER`/`PGPASSWORD` |
| Подключение через Sequel | `config/database.rb`, `DATABASE_URL` или настройки окружения |
| Четыре модели и ассоциации | `models/*.rb`; тест связей и внешних ключей |
| Четыре обратимые миграции | `db/migrations/001...004` |
| Rake version/migrate/rollback/reset | `lib/tasks/db.rb`; проверены latest, target 2, rollback, reset, версия |
| Seeds: очистка, порядок, reset ID | Пять файлов `seeds/20261109*.rb`, `sequel-seed`; проверено в одноразовой БД |
| Отслеживание seeds и повторный запуск | `schema_seeds`; повторный запуск не дублирует записи |
| Проверка данных и dataset | Проверены количества, `select`, `order`, `where`, `all` |
| JSON-сериализация, to_api, Content-Type | `models/*.rb`, `helpers/serialization.rb` |
| Отдельные файлы ресурсов и namespace | `routes/*.rb`, `/api/v1` |
| Консоль Sequel / просмотр в RubyMine | Dataset проверен Ruby-командой; интерактивный просмотр в IDE — ручной пункт |

## Часть 4

| Практический пункт | Реализация и проверка |
| --- | --- |
| Список компаний и оба независимых фильтра | `GET /api/v1/companies`, name/location, комбинации и пустая выборка |
| Разделитель `;` из методички | Поддерживается вместе с `&`; есть тесты, кодированный `%3B` остаётся частью значения |
| Компания по ID | `/api/v1/company/:id` |
| Вакансии компании по части имени | `/api/v1/company_jobs?name=Mo` |
| POST companies | JSON и form data; валидация и разрешённые поля, 201 |
| Read/unread отклики | `/api/v1/applies_read`, `/api/v1/applies_unread` |
| Вакансии с фильтрами name/place/company | `/api/v1/jobs` |
| Вакансии по точному имени компании | `/api/v1/jobs_company/:name` |
| Вакансия по ID, пример ID 11 | `/api/v1/job/:id`; seed C++ с ID 11 и корректной последовательностью |
| Неизвестная вакансия / компания | JSON 404 |
| Postman | Коллекция `sinatra-api.postman_collection.json`; HTTP-проверки выполнены программно, GUI Postman не использовался |

## Отличия от старых примеров

- Сервер Puma вместо Thin/WEBrick. Проверены оба способа запуска: Ruby-файл и Rack.
- В проекте используются `routes` и `helpers`; пустые контроллеры не нужны. Имена файлов загружаются относительно файла приложения, а не текущей папки терминала.
- `JSON.generate` вместо MultiJson; формат ответа тот же. `updated_at` написан без опечатки из методички.
- Вакансии везде имеют префикс `/api/v1`, как требует раздел о namespace. В главе 4 часть URL приведена без этого префикса.
- Вместо примера с широкими `trust`-правилами и суперпользователем используются существующее локальное подключение и переменные окружения. Production-база не создавалась и не изменялась.
- Проверка неверного URI `/jobs.[xml` зависит от HTTP-сервера и клиента; это не отдельная функция приложения. Неподдерживаемый путь не следует использовать как пример успешного запроса.
- Конфигурация RubyMine и интерактивная работа в Postman остаются ручными действиями; их выполнение не заявляется.

Подробные протоколы запусков и проверок сохранены рядом с отчётом: `../otchet/report_lab2_overleaf/evidence/`.
