require 'sinatra'
require 'sinatra/config_file'
require_relative 'lib/overlay_publisher/github'

module OverlayPublisher
  class App < Sinatra::Application
    register Sinatra::ConfigFile

    config_file File.join(File.dirname(__FILE__), 'config', 'config.yml')

    configure do
      repository_config = YAML.load_file(File.join(File.dirname(__FILE__), 'config', 'overlay_repositories.yml'))
      OverlayPublisher::Github.register_webhooks(repository_config['repositories'], settings.publish_url)
    end

    get '/publish' do
      publish_hook(params)
    end

    post '/publish' do
      publish_hook(params)
    end

    def publish_hook(params)
      "success"
    end

  end
end