mywords-api
===========

## Installattion

Copy config.rb.sample to config.rb. Edit the file to add necessary information.

```
# Install dependencies
bundle
# Copy the config sample
cp config.rb.sample config.rb
# Edit the config file
vim config.rb
```
You are good to go!

## Running the app

### Using rack up

```
rackup config.ru
```

### Using thin

Thin is "a Ruby web server that glues together 3 of the best Ruby libraries in web history." I like using thin with nginx.

```
# Install thin
gem install thin
# Run the app
# I'm using sockets here but you can also use a port.
thin start -s1 --socket /tmp/thin.sock
```

## REST API

| Resource | Description|
| ------------- |:-----|
| GET inbox/:login_user | Inbox for login user |
| GET api/message/:login_user/:target_user     | Frequency list for a given user |
| GET api/message/:login_user | Joint messages of a given user. Ready to parse. |
