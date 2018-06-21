[![Build Status](https://travis-ci.org/sul-dlss/exhibits.svg)](https://travis-ci.org/sul-dlss/exhibits) [![Coverage Status](https://coveralls.io/repos/sul-dlss/exhibits/badge.svg?branch=master&service=github)](https://coveralls.io/github/sul-dlss/exhibits?branch=master)

# SUL Spotlight Exhibit

The project's `master` branch provides a template Spotlight application with SUL branding and functionality.

## Configuration

Exhibits need to provide the following configuration files:

* `config/database.yml` - Standard Rails database configuration
* `config/honeybadger.yml` - Honeybadger.io exception reporting configuration
* `config/blacklight.yml` - Blacklight solr configuration
* config/initializers/secret_token.rb - Rails secret token

## Reindexing content

A Rake task is provided to (re)index content into the Solr index. It uses the configured sets in `config/exhibit.yml`.

```console
$ rake spotlight:index
```

A whenever-based cron task is configured to run nightly to keep the exhibit synchronized with the latest upstream changes. At this time, the task only adds or modifies records, and does not remove records that have been deleted or disassociated with the given OAI set.

## Development

### Requirements
- Redis (for running background jobs with Sidekiq)

See [projectblacklight/spotlight](https://github.com/projectblacklight/spotlight) for additional requirements.

Install dependencies, set up the databases and run migrations:
```console
$ bundle install
$ bundle exec rake db:setup
```

You can spin up the Rails server, solr_wrapper, and populate the Solr index using this command:
```console
$ REMOTE_USER="archivist1@example.com" bundle exec rake server
```
When prompted to create an admin user, the email should match the email provided in  `REMOTE_USER`. This will allow you to bypass the webauth authentication.

## Testing
Run RuboCop and tests:
```console
$ bundle exec rake
```

**Tip:** if you receive the error message `ERROR: Core 'blacklight-core' already exists!` you have an instance of Solr running elsewhere. Clean out your data with `solr_wrapper clean` or search for rogue instances with `ps aux | grep solr`.

## Deploying

You must be on VPN to deploy the worker machine.  Then deploy as usual using Capistrano:

```console
$ cap stage deploy
```
