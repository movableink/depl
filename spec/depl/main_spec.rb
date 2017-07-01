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
      expect(deploy).to receive(:remote_sha).and_return("remote")
      expect(deploy).to receive(:local_sha).and_return("local")

      cmd = "git log --pretty=format:'    %h %<(20)%an %ar\t   %s' remote..local"
      expect(deploy).to receive(:execute).with(cmd)

      deploy.diff
    end
  end

  describe '#advance_branch_pointer' do
    it 'pushes a sha to the origin' do
      expect(deploy).to receive(:local_sha).and_return("12345")

      cmd = "git push --force origin 12345:refs/heads/deploy-production"
      expect(deploy).to receive(:execute).with(cmd)

      deploy.advance_branch_pointer
    end
  end

  describe '#up_to_date' do
    it 'returns true when shas match' do
      expect(deploy).to receive(:remote_sha).and_return("same")
      expect(deploy).to receive(:local_sha).and_return("same")

      expect(deploy.up_to_date?).to be true
    end

    it 'returns true when shas differ' do
      expect(deploy).to receive(:remote_sha).and_return("remote")
      expect(deploy).to receive(:local_sha).and_return("local")

      expect(deploy.up_to_date?).to be false
    end
  end
end
