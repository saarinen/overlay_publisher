Overlay Publisher
=================

Overview
---------

OverlayPublisher is a Sinatra web application managing pub/sub for Github Webhooks.  Due to Github limits on the number of webhooks
allowed (20), production Overlay environments are limited in their ability to scale.  This application allows Overlay enabled applications
to register to a Github repository and recieve updates via a Redis channel, using OverlayPublisher as the dispatcher.
