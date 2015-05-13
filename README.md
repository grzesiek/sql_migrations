# sql-migrations

[![Gem Version](https://badge.fury.io/rb/sql_migrations.svg)](http://badge.fury.io/rb/sql_migrations)
[![Build Status](https://travis-ci.org/grzesiek/sql-migrations.svg?branch=master)](https://travis-ci.org/grzesiek/sql-migrations)

Simple standalone migrations you can use with plain SQL.

This gives you possibility to execute migrations, seed datebase (on production and in test environment with fixtures) in non-Ruby pojects.
`sql-migrations` can work with multiple different databases, and support many db adapters.

## Why ?

This is particularly useful in old projects that don't have migration support, and you really want to use Continuous Delivery strategy. 
Without migrations you wouldn't be able to setup your test environment for automated testing (functional tests, unit tests, integration tests).

For example, if you work on old Zend 1 project, and you want to take benefit from using Continuous Deployment/Continuous Integration mechanisms - you may find this project useful.

## Install

`sql-migrations` are created using Ruby, but you can use this software with non-Ruby projects, like PHP or Java. This is standalone mechanism.

1.  First - install Ruby environment, with `rbenv` or `rvm`.
2.  If your project is not using ruby, create your Gemfile:

    ```ruby
    source 'https://rubygems.org'
    gem 'mysql2'
    gem 'sql_migrations'
    ```

    It is possible to use all database adapters that are supported by `Sequel`. 
    Adapters supported by `Sequel`, by now, are:
    
    > ADO, Amalgalite, CUBRID, DataObjects, DB2, DBI, Firebird, 
    > FoundationDB SQL Layer, IBM_DB, Informix, JDBC, MySQL, Mysql2, 
    > ODBC, OpenBase, Oracle, PostgreSQL, SQLAnywhere, SQLite3, 
    > Swift, and TinyTDS

    If you are using PostgreSQL use

    ```ruby
    gem 'pg'
    ```

3.  Run `bundle install`

4.  Create database config file in `db/config/databases.yml`

    ```yaml
    production:
      databases:
        default:
          adapter: mysql2
          encoding: utf8
          database: default_db_prod
          username: prod_user
          password: prod_pass
          host: 192.168.1.1

    development:
      databases:
        default:
          adapter: mysql2
          encoding: utf8
          database: default_db_dev
          username: dev_user
          password: dev_pass
          host: 127.0.0.1

        second_db:
          adapter: mysql2
          encoding: utf8
          database: second_db_dev
          username: test_user
          password: test_pass
          host: 127.0.0.1

    test:
      databases:
        default:
          adapter: mysql2
          encoding: utf8
          database: <%= ENV['DB_DEFAULT_NAME'] %>
          username: <%= ENV['DB_DEFAULT_USER'] %>
          password: <%= ENV['DB_DEFAULT_PASS'] %>
          host:     <%= ENV['DB_DEFAULT_HOST'] %>

        second_db:
          adapter: mysql2
          encoding: utf8
          database: <%= ENV['DB_SECOND_NAME'] %>
          username: <%= ENV['DB_SECOND_USER'] %>
          password: <%= ENV['DB_SECOND_PASS'] %>
          host:     <%= ENV['DB_SECOND_HOST'] %>
    ```

    As shown above, it is possible to use ERB-like syntax to use environment variables in config.

    `default` database configuration is optional, nonetheless if supplied it will not be necessary to create additional subdirectory to store migrations (look below).


4.  Migrations/seed/fixtures can be executed using rake tasks. So you will need to create `Rakefile`:

    ```ruby
    require 'bundler'
    Bundler.require

    SqlMigrations::Config.load!('db/config/databases.yml')
    SqlMigrations.load_tasks
    ```

    You can also create Rake tasks by yourself:

    ```ruby
    require 'sql_migrations'
    SqlMigrations::Config.load!('databases.yml')

    namespace :db do
      desc 'Migrate database'
      task :migrate do
        puts '[i] Running migrations ...'
        SqlMigrations.migrate
      end

      desc 'Seed database'
      task :seed do
        puts '[i] Seeding databases ...'
        SqlMigrations.seed
      end

      desc 'Prepare databases -- migrate and seed'
      task :prepare do
        Rake::Task['db:migrate'].invoke
        Rake::Task['db:seed'].invoke
      end
    end
    ```

5.  It's ready !
  

## Usage

1.  Valid migration/seed/fixture file names match agains regexp `/(\d{8})_(\d{6})_(.*)?\.sql/`. So valid filenames would be:


        20150303_180100_test_migration.sql
        20150303_180100_whatever_description_of_seed.sql
        20150303_180100_fixture1.sql

    You can put plain SQL into that files.

2.  It is possible to create migration files, seed files and fixtures inside followig directory structure:

        db/
          migrations/
            20150303_180100_test_migration.sql
          fixtures/
            20150303_180100_fixture1.sql
          seed/
            20150303_180100_whatever_description_of_seed.sql

    If you want to use multiple databases, create also database directories:

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

    `default/` directory is optional, you can put migrations/seed data/fixtures for default database in base directories:

        db/
          migrations/
            20150303_180100_test_migration_for_default_database.sql
            second_db/
              20150303_180101_test_migration_for_second_db.sql

3.  `sql-migrations` will create table `sqlmigrations_schema` for each database specified in YAML config.

4.  If everything is set up properly, you should see new rake tasks:

        rake -T

    This should give output

        rake sqlmigrations:db:migrate    # Run migrations
        rake sqlmigrations:db:seed       # Seed database
        rake sqlmigrations:db:test:seed  # Seed test database with fixtures
        rake sqlmigrations:files:list    # List found migration and seed files


5.  Then, run tasks:


        # this will execute migrations
        rake sqlmigrations:db:migrate   

        # this will seed database with initial data
        rake sqlmigrations:db:seed 

        # this will list all migrations/seed files/fixtures that where found
        rake sqlmigration:files:list    

6.  Enviroment variables

    If you want to run migration on different database (for example test) specify ENV:

        ENV=test rake sqlmigrations:db:migrate
        ENV=test rake sqlmigrations:db:test:seed

    or in production:

        ENV=production rake sqlmigrations:db:migrate
        ENV=production rake sqlmigrations:db:seed

## TODO

1.  More tests
2.  Generator for `databases.yml`
3.  Generator for migrations

## License

This is free sofware licensed under MIT license, see LICENSE file
