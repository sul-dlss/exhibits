# SUL Spotlight Exhibit template project

The project's `master` branch provides a template Spotlight application with SUL branding and functionality. 

## Configuration

Exhibits need to provide the following configuration files:

* `config/database.yml` - Standard Rails database configuration
* `config/solr.yml` - Blacklight solr configuration
* `config/harvestdor.yml` - Harvestdor indexer configuration
* `config/exhibit.yml` - Exhibit indexing directives (in addition to the harvestdor configuration above.). It should contain environment-specific sets that should be synchronized using the `rake spotlight:reindex` task. E.g.:
    ```
    production:
      sets: 
        - is_member_of_oo000oo0000
        - is_member_of_oo000oo0001
    ```

* config/initializers/secret_token.rb - Rails secret token
* config/initializers/squash.rb - Squash error reporting configuration
* public/.htaccess - An Apache .htaccess file with the necessary passenger configuration, e.g.:
    ```
    PassengerBaseURI /my-exhibit
    PassengerAppRoot /home/lyberadmin/exhibits/my-exhibit/current
    WebAuthLdapPrivgroup dlss:exhibits-admin
    ```

## Reindexing content

A rake task is provided to (re)index content into the Solr index. It uses the configured sets in `config/exhibit.yml`.

```console
$ rake spotlight:index
```

A whenever-based cron task is configured to run nightly to keep the exhibit synchronized with the latest upstream changes. At this time, the task only adds or modifies records, and does not remove records that have been deleted or disassociated with the given OAI set.
