require 'spec_helper'

describe Depl::Main do
  let(:deploy) {
    Depl::Main.new(:environment => 'production')
  }

  describe '#environment' do
    it 'uses the passed environment' do
      expect(deploy.environment).to eq('production')
    end
  end

  describe '#diff' do
    it 'uses git to find the commits between two shas' do
      deploy.should_receive(:remote_sha).and_return("remote")
      deploy.should_receive(:local_sha).and_return("local")

      cmd = "git log --pretty=format:'    %h %<(20)%an %ar\t   %s' -10 remote..local"
      deploy.should_receive(:execute).with(cmd)

      deploy.diff
    end
  end

  describe '#save_sha' do
    it 'pushes a sha to the origin' do
      deploy.should_receive(:local_sha).and_return("12345")

      cmd = "git push --force origin 12345:refs/heads/deploy-production"
      deploy.should_receive(:execute).with(cmd)

      deploy.save_sha
    end
  end

  describe '#up_to_date' do
    it 'returns true when shas match' do
      deploy.should_receive(:remote_sha).and_return("same")
      deploy.should_receive(:local_sha).and_return("same")
      expect(deploy.up_to_date).to be_true
    end

    it 'returns true when shas differ' do
      deploy.should_receive(:remote_sha).and_return("remote")
      deploy.should_receive(:local_sha).and_return("local")
      expect(deploy.up_to_date).to be_false
    end
  end
end
