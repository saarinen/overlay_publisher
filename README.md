Overlay Publisher
==================

Overview
------------------

OverlayPublisher is a Sinatra web application managing pub/sub for Github Webhooks.  Due to Github limits on the number of webhooks
allowed (20), production Overlay environments are limited in their ability to scale.  This application allows Overlay enabled applications
to register to a Github repository and recieve updates via a Redis channel, using OverlayPublisher as the dispatcher.

Currently, OverlayPubliser does not use any local storage and optomistically publishes to a redis channel.  In the future, we hope to support both
redis subscribers as well as Overlay http update registrants.

Configuration
------------------

Configuration can be found in config/config.yml.  Avalable options include:

  * publish_url           - URL to use when registering a webhook with Github
  * redis.service_port    - Redis port
  * redis.service_host    - Redis host
  * redis.default_timeout - Timeout for Redis commands

Usage
------------------

OverlayPublisher is a simple rack application with two routes:

  * POST /register -  Applications wishing to subscribe to a GitHub repo need to post
                      to '/register' with the following json body:
                      {
                        organization: <repo org>,
                        repo:         <repository_name>,
                        auth:         <username:pass for authorized repo contributor>
                        enpoint:      <api endpoint eg. https://api.github.com or https://github.dev.pages/api/v3>
                        site:         <github root site eg. https://github.com or https://github.dev.pages>
                      }
                      The call will return the redis publish key if sucessfull and an error if not. eg.

                      {
                        publish_key: <key>
                      }

  * POST /publish - The registered webhook route.  This route relays the body of the post to subscribed recipients.
