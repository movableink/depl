require 'yaml'

module Depl
  class Main
    def initialize(options)
      config_path = options[:config_file] || "./.deploy"
      @config = options[:config]

      if File.exist? config_path
        @config ||= YAML::load_file(config_path)
      else
        @config ||= {}
      end

      @options = options
    end

    def environment
      @options[:environment]
    end

    def prefix
      @config[:prefix] || "deploy-"
    end

    def deploy_branch
      "#{prefix}#{environment}"
    end

    def save_sha
      execute("git push --force origin #{local_sha}:refs/heads/#{deploy_branch}")
    end

    def run!
      if @config['before_hook']
        `#{@config['before_hook']}`
      end

      save_sha

      if @config['after_hook']
        `#{@config['after_hook']}`
      end
    end

    def remote_sha
      `git fetch origin`
      sha = execute("git rev-parse -q --verify origin/#{deploy_branch}").chomp
      sha if sha != ""
    end

    def up_to_date
      local_sha == remote_sha
    end

    def local_sha
      rev = @options[:rev] || @config[:branch] || 'head'
      sha = execute("git rev-parse -q --verify #{rev}").chomp
      sha if sha != ""
    end

    def diff
      execute "git log --pretty=format:'    %h %<(20)%an %ar\t   %s' -10 #{remote_sha}..#{local_sha}"
    end

    def reverse_diff
      execute "git log --pretty=format:'    %h %<(20)%an %ar\t   %s' -10 #{local_sha}..#{remote_sha}"
    end

    def older_local_sha
      return false unless remote_sha
      execute("git merge-base --is-ancestor #{local_sha} #{remote_sha}") && $?.exitstatus == 0
    end

    def commit_count
      diff.split("\n").size
    end

  protected

    def execute(cmd)
      `#{cmd}`
    end
  end
end
