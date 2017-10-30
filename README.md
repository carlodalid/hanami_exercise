# Search

A simple search API built using Hanami framework and Ruby

## Requirements

- ruby 2.4.0
- hanami 1.1.0
- redis 4.0.1

## Setup

Assuming you have Redis already installed, make sure it's running at PORT 6379

```
% redis-server --port=6379
```

How to run tests:

```
% bundle exec rake
```

How to run the development console:

```
% bundle exec hanami console
```

How to run the development server:

```
% bundle exec hanami server
```

How to prepare (create and migrate) DB for `development` and `test` environments:

```
% bundle exec hanami db prepare

% HANAMI_ENV=test bundle exec hanami db prepare
```

Explore Hanami [guides](http://hanamirb.org/guides/), [API docs](http://hanamirb.org/docs/1.0.0/), or jump in [chat](http://chat.hanamirb.org) for help. Enjoy! 🌸
