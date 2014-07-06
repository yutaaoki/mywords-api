mywords-api
===========

## Instlattion

Copy config.rb.sample to config.rb. Edit the file to add necessary information.

```
bundle
```

You are good to go!

## REST API

| Resource | Description|
| ------------- |:-----|
| GET inbox/:login_user | Inbox for login user |
| GET api/message/:login_user/:target_user     | Frequency list for a given user |
| GET api/message/:login_user | Joint messages of a given user. Ready to parse. |
