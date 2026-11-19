[![Build Status](https://travis-ci.org/sul-dlss/exhibits.svg)](https://travis-ci.org/sul-dlss/exhibits) [![Code Climate Test Coverage](https://codeclimate.com/github/sul-dlss/exhibits/badges/coverage.svg)](https://codeclimate.com/github/sul-dlss/exhibits/coverage)

# SUL Spotlight Exhibit

The project's `main` branch provides a template Spotlight application with SUL branding and functionality.

## Configuration

Exhibits need to provide the following configuration files:

* `config/database.yml` - Standard Rails database configuration
* `config/honeybadger.yml` - Honeybadger.io exception reporting configuration
* `config/blacklight.yml` - Blacklight solr configuration
* config/initializers/secret_token.rb - Rails secret token


### Requirements
- Redis (for running background jobs with Sidekiq)

See [projectblacklight/spotlight](https://github.com/projectblacklight/spotlight) for additional requirements.


## Development


Install dependencies, set up the databases and run migrations:
```console
$ bundle
$ yarn install
$ bin/rake db:setup
```

Start Solr. Solr runs in Docker, so Docker (e.g. Docker Desktop) must be running. The following command starts a local Solr instance at `localhost:8983` with a pre-loaded core named `blacklight-core`, using the configuration in `solr/config`:
```console
$ docker compose up -d solr
```

Stop it with `docker compose stop solr`. To use a different host port, set `SOLR_PORT` and point the app at it with `SOLR_URL` (e.g. `SOLR_PORT=8984` and `SOLR_URL=http://127.0.0.1:8984/solr/blacklight-core`).

Set up an admin user. You will be prompted to enter an email.
```
rake spotlight:initialize
```

You can spin up the Rails server using this command. Use the same email created as an admin above.
```console
$ REMOTE_USER="archivist1@example.com" bin/dev
```

When prompted to create an admin user, the email should match the email provided in  `REMOTE_USER`. This will allow you to bypass authentication.

Create an exhibit while logged in as an admin user in order to navigate and search content.


## Seeding content

```console
$ bin/rake spotlight:seed
```

## Reindexing content

```console
$ bin/rake spotlight:reindex
```


## Testing
Run RuboCop and tests:
```console
$ bin/rake
```

`bin/rake` starts Solr with `docker compose` (Docker must be running) and stops it when the tests finish.

If you'd like to run a single test, you must seed the index first:
```console
bin/rails spotlight:seed
```

**Tip:** if you receive the error message `ERROR: Core 'blacklight-core' already exists!` you have an instance of Solr running elsewhere. Stop it with `docker compose stop solr`, or search for rogue instances with `ps aux | grep solr`.

## Deploying

You must be on VPN to deploy the worker machine.  Then deploy as usual using Capistrano:

```console
$ cap stage deploy
```
