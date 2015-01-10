module DeployS3
  class Remote
    def self.comparison(from, to)
      origin_url = `git config --get remote.origin.url`.chomp

      github_url = self.github_from_url origin_url
      "#{github_url}/compare/#{from}...#{to}" if github_url
    end

    def self.github_from_url(url)
      if url =~ /git@github.com:(.*?).git/
        "https://github.com/#{$1}"
      elsif url =~ /(.*?):\/\/github.com\/(.*?).git/
        "https://github.com/#{$1}"
      end
    end
  end
end
