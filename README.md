# LostNFound API

API for LostNFound, a lost and found system.

## Routes

All routes return JSON

- GET `/`: Root route shows if Web API is running
- GET `api/v1/items`: returns all items
- POST `api/v1/items`: creates a new lost or found item
- GET `api/v1/items/:item_id`: returns details about a single item with given id
- GET `api/v1/items/:item_id/contacts`: returns all contacts for a given item id
- GET `api/v1/items/:item_id/contacts/:contact_id`: returns details about a single contact with given id for a given item id
- POST `api/v1/items/:item_id/contacts`: creates a new contact for a given item id

## Install

Install this API by cloning the *relevant branch* and use bundler to install specified gems from `Gemfile.lock`:

```shell
bundle install
```

Setup development database once:

```shell
rake db:migrate
```

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test specification script in `Rakefile`:

```shell
rake spec
```

## Execute

Launch the API using:

```shell
puma
```

## Release check

Before submitting pull requests, please check if specs, style, and dependency audits pass (will need to be online to update dependency database):

```shell
rake release_check
```