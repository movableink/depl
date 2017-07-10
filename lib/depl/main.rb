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

    def origin
      @config[:origin] || "origin"
    end

    def deploy_branch
      [prefix, environment].join('')
    end

    def tag_name
      date = Time.now.strftime('%Y-%m-%d-%H-%M-%S')
      [prefix, environment, '-', date].join('')
    end

    def tag_release
      execute("git tag -a '#{tag_name}' #{local_sha}")
    end

    def advance_branch_pointer
      execute("git push --follow-tags --force #{origin} #{local_sha}:refs/heads/#{deploy_branch}")
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
      `git fetch #{origin}`
      sha = execute_output("git rev-parse -q --verify #{origin}/#{deploy_branch}")
      sha && sha.chomp || raise("missing remote sha for #{origin}/#{deploy_branch}")
    end

    def up_to_date?
      local_sha == remote_sha
    end

    def local_sha
      rev = @options[:rev] || @config[:branch] || 'head'
      sha = execute_output("git rev-parse -q --verify #{rev}")
      sha && sha.chomp || raise("missing local sha: #{rev}")
    end

    def diff
      execute_output "git log --pretty=format:'    %h %<(20)%an %ar\t   %s' #{remote_sha}..#{local_sha}"
    end

    def reverse_diff
      execute_output "git log --pretty=format:'    %h %<(20)%an %ar\t   %s' #{local_sha}..#{remote_sha}"
    end

    def older_local_sha
      return false unless remote_sha
      !!execute_output("git merge-base --is-ancestor #{local_sha} #{remote_sha}")
    end

    def commit_count
      diff.split("\n").size
    end

  protected

    def execute_output(cmd)
      rd, wr = IO.pipe

      pid = spawn(cmd, out: wr, err: wr)
      pid, status = Process.wait2(pid)

      wr.close
      status.exitstatus == 0 && rd.read
    end

    def execute(cmd)
      pid = spawn(cmd)
      pid, status = Process.wait2(pid)

      status.exitstatus == 0
    end
  end
end
