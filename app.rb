require 'sinatra'
require 'sinatra/config_file'
require 'json'
require_relative 'lib/overlay_publisher/github'
require_relative 'lib/overlay_publisher/redis'

module OverlayPublisher
  class App < Sinatra::Application
    register Sinatra::ConfigFile

    config_file File.join(File.dirname(__FILE__), 'config', 'config.yml')

    # /publish is the endpoint for GitHubs webhooks
    # This endpoint takes a post body of JSON payload and
    # publishes it to a channel with key "overlay_publisher_{org}_#{repository}""
    post '/publish' do
      OverlayPublisher::Redis.instance.publish_hook(request.body.gets)
      200
    end

    # Applications wishing to subscribe to a GitHub repo need to post
    # to '/register' with the following json body:
    # {
    #   organization: <repo org>,
    #   repo:         <repository_name>,
    #   auth:         <username:pass for authorized repo contributor>
    #   enpoint:      <api endpoint eg. https://api.github.com or https://github.dev.pages/api/v3>
    #   site:         <github root site eg. https://github.com or https://github.dev.pages>
    # }
    # The call will return the redis publish key if sucessfull and an error if not. eg.
    #
    # {
    #   publish_key: <key>
    # }
    #
    post '/register' do
      repo_config = JSON.parse(request.body.gets)
      OverlayPublisher::Github.new.register_webhooks(repo_config, settings.publish_url)
      {'publish_key' => "overlay_publisher_#{repo_config['organization']}_#{repo_config['repo']}"}.to_json
    end

    # Monitor
    get '/ping' do
      'OK'
    end
  end
end