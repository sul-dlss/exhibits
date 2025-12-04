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
Testing CI

Install dependencies, set up the databases and run migrations:
```console
$ bundle
$ yarn install
$ bin/rake db:setup
```

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

If you'd like to run a single test, you must seed the index first:
```console
bin/rails spotlight:seed
```

**Tip:** if you receive the error message `ERROR: Core 'blacklight-core' already exists!` you have an instance of Solr running elsewhere. Clean out your data with `solr_wrapper clean` or search for rogue instances with `ps aux | grep solr`.

## Deploying

You must be on VPN to deploy the worker machine.  Then deploy as usual using Capistrano:

```console
$ cap stage deploy
```
