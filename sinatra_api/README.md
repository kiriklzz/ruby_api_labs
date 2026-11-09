# API, части 2–4

Ruby 3.2+, PostgreSQL. Rails из части 1 находится отдельно в `../rails_api`.

## Часть 2: маршруты Sinatra

```sh
bundle install
bundle exec ruby my_sinatra.rb
# или:
bundle exec rackup -p 4567 config.ru
bundle exec ruby -Itest test/routes_test.rb
```

Примеры: `/hello/Peter`, `/redirect`, `/say/hello/to/world`,
`/download/path/to/file.xml`, `/jobs.json`, `/api/v1/friends`.
