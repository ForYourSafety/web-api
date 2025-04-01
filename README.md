# LostNFound API

API for LostNFound, a lost and found system.

## Routes

All routes return JSON

- GET `/`: Root route shows if Web API is running
- GET `api/v1/item/`: returns all item UUIDs
- GET `api/v1/item/[UUID]`: returns details about a single item with given UUID
- POST `api/v1/item/`: creates a new lost or found item

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Run the test script:

```shell
ruby spec/api_spec.rb
```

## Execute

Run this API using:

```shell
rackup
```