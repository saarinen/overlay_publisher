require 'github_api'

module OverlayPublisher
  class Github
    def register_webhooks(repo_config, hook_url)
      configure(repo_config)

      begin
        # Retrieve current web hooks
        current_hooks = github_repo.hooks.list(repo_config['organization'], repo_config['repo']).response.body
        if current_hooks.find {|hook| hook.config.url == hook_url}.nil?
          # register hook
          github_repo.hooks.create(repo_config['organization'], repo_config['repo'], name: 'web', active: true, config: {:url => hook_url, :content_type => 'json'})
        end
      rescue => e
        raise "Registration of webhook for repo #{repo_config['repo']} failed with message: #{e.message}"
      end
    end

    private

    def github_repo
      @github ||= ::Github::Repos.new
    end

    # Configure the github api
    def configure(repo_config)
      # Validate required config
      validate_config(repo_config)

      ::Github.configure do |github_config|
        github_config.endpoint    = repo_config['endpoint']
        github_config.site        = repo_config['site']
        github_config.basic_auth  = repo_config['auth']
        github_config.adapter     = :net_http
        github_config.ssl         = {:verify => false}
      end
    end

    def validate_config(repo_config)
      raise "Repository name ('repo') is required"      if (repo_config['repo'].nil?          || repo_config['repo'].empty?)
      raise "Organization is required"                  if (repo_config['organization'].nil?  || repo_config['organization'].empty?)
      raise "Authorization string ('auth') is required" if (repo_config['auth'].nil?          || repo_config['auth'].empty?)
      raise "Endpoint is required"                      if (repo_config['endpoint'].nil?      || repo_config['endpoint'].empty?)
      raise "Site is required"                          if (repo_config['site'].nil?          || repo_config['site'].empty?)
    end
  end
end