# sql-migrations

Simple standalone migrations gem you can use with plain SQL.

You can execute migrations, seed datebase on production and on test environment with fixtures in non-Ruby pojects.
`sql-migrations` can work with multiple different databases.

## Why ?

This is particularly useful in old projects that doesn't have migrations support, and you really want to use Continues Delivery strategy. 
Without migrations you wouldn't be able to setup your test environment for automated testing (functional tests, unit tests, integration tests).

For example, if you work in old Zend1 project, and you want to take benefit from using Continues Deployment/Continues Integration mechanisms - you may find this project useful.

## Install

`sql-migrations` are created using Ruby. 

1. First - install Ruby environment, with `rbenv` or `rvm`.
2. If your project is not created using Ruby, create your Gemfile:

  ```ruby
  source 'https://rubygems.org'
  gem 'mysql2'
  gem 'sql_migrations'
  ```

  You can use all database adapters, that are supported by `Sequel`. 
  Adapters supported by `Sequel`, by now, are:
    
      ADO, Amalgalite, CUBRID, DataObjects, DB2, DBI, Firebird, 
      FoundationDB SQL Layer, IBM_DB, Informix, JDBC, MySQL, Mysql2, 
      ODBC, OpenBase, Oracle, PostgreSQL, SQLAnywhere, SQLite3, 
      Swift, and TinyTDS

  If you are using PostgreSQL use

  ```ruby
  gem 'pg'
  ```

3. Run `bundle install`

4. Create database config file, for example in `config/databases.yml`

    ```yaml
    default:
      development:
        adapter: mysql2
        encoding: utf8
        database: test_db_dev
        username: test_user
        password: test_pass
        host: 192.168.1.1
      test:
        adapter: mysql2
        encoding: utf8
        database: test_db_test
        username: test_user
        password: test_pass
        host: 192.168.1.1
      production:
        adapter: mysql2
        encoding: utf8
        database: test_db_prod
        username: test_user
        password: test_pass
        host: 192.168.1.100
    second_db:
      development:
        adapter: mysql2
        encoding: utf8
        database: second_db_dev
        username: test_user
        password: test_pass
        host: 127.0.0.1
      test:
        adapter: mysql2
        encoding: utf8
        database: second_db_test
        username: test_user
        password: test_pass
        host: 127.0.0.1
    ```

  Note that you need to define `default` database set.

4. Migrations/seed/fixtures are executed using rake tasks. So you will need to create `Rakefile`. Example `Rakefile`:

  ```ruby
  require 'bundler'
  Bundler.require

  SqlMigrations.load!('db/config/databases.yml')
  SqlMigrations.load_tasks
  ```

5. It's ready !
  

## Usage

1. Valid migration/seed/fixture file names match agains regexp `/(\d{8})_(\d{6})_(.*)?\.sql/`. So valid filenames would be:


  ```
  20150303_180100_test_migration.sql
  20150303_180100_whatever_description_of_seed.sql
  20150303_180100_fixture1.sql
  ```

  You can put plain SQL into that files.

2. You can create migrations files, seed files and fixtures in directories like this:

  ```
  db/
    migrations/
    fixtures/
    seed/
  ```

  If you want to use multiple databases, create database directories:

      db/
        migrations/
          default/
          second_db/
        fixtures/
          default/
          second_db/
        seed/
          default/
          second_db/

  `default/` directory is mandatory, you can put migrations/seed data/fixtures for default database in base directories:

      db/
        migrations/
          20150303_180100_test_migration.sql
          second_db/
            20150303_180101_test_migration_for_second_db.sql

3. In every database that is specified in YAML config, `sql-migrations` will create table `sqlmigrations_schema`
4. If everything is set up properly, you should see `sqlmigrations` tasks after typing


        rake -T

5. Run tasks:


        rake sqlmigrations:db:migrate   # this will execute migrations
        rake sqlmigrations:db:seed      # this will seed database with initial data
        rake sqlmigration:files:list    # this will list all migrations/seed files/fixtures that where found

6. Enviroment variables

  If you want to run migration on different database (for example test) specify ENV:

  ```bash
  ENV=test rake sqlmigrations:db:migrate
  ENV=test rake sqlmigrations:db:test:seed
  ```

  or in production:

  ```bash
  ENV=production rake sqlmigrations:db:migrate
  ENV=production rake sqlmigrations:db:seed
  ```

## TODO

1. Tests
2. Generator for `databases.yml`
3. Generator for migrations

## License

This is free sofware licensed under MIT license, see LICENSE file
