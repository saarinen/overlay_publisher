require 'github_api'

module OverlayPublisher
  class Github
    def self.register_webhooks(repo_config, hook_url)
      configure

      repo_config.each do |config|
        # Retrieve current web hooks
        current_hooks = github_repo.hooks.list(config['user'], config['repo']).response.body
        if current_hooks.find {|hook| hook.config.url == hook_url}.nil?
          # register hook
          github_repo.hooks.create(config['user'], config['repo'], name: 'web', active: true, config: {:url => hook_url, :content_type => 'json'})
        end
      end
    end

    private

    def self.github_repo
      @@github ||= ::Github::Repos.new
    end

    # Configure the github api
    def self.configure
      # Validate required config
      raise 'Configuration github_overlays.basic_auth not set' if (!App.settings.github['auth'] || App.settings.github['auth'].nil?)

      ::Github.configure do |github_config|
        github_config.endpoint    = App.settings.github['endpoint'] if App.settings.github['endpoint']
        github_config.site        = App.settings.github['site'] if App.settings.github['site']
        github_config.basic_auth  = App.settings.github['auth']
        github_config.adapter     = :net_http
        github_config.ssl         = {:verify => false}
      end
    end
  end
end