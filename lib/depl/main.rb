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

    def tag_name
      date = Time.now.strftime('%Y-%m-%d-%H-%M-%S')
      [prefix, date].join('')
    end

    def tag_release
      execute("git tag -a #{tag_name} #{local_sha}")
    end

    def advance_branch_pointer
      execute("git push --force origin #{local_sha}:refs/heads/#{deploy_branch}")
    end

    def run!
      if @config['before_hook']
        `#{@config['before_hook']}`
      end

      tag_release
      advance_branch_pointer

      if @config['after_hook']
        `#{@config['after_hook']}`
      end
    end

    def remote_sha
      `git fetch origin`
      sha = execute("git rev-parse -q --verify origin/#{deploy_branch}").chomp
      sha if sha != ""
    end

    def up_to_date?
      local_sha == remote_sha
    end

    def local_sha
      rev = @options[:rev] || @config[:branch] || 'head'
      sha = execute("git rev-parse -q --verify #{rev}").chomp
      sha if sha != ""
    end

    def diff
      execute "git log --pretty=format:'    %h %<(20)%an %ar\t   %s' #{remote_sha}..#{local_sha}"
    end

    def reverse_diff
      execute "git log --pretty=format:'    %h %<(20)%an %ar\t   %s' #{local_sha}..#{remote_sha}"
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
