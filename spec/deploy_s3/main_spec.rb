require 'spec_helper'

describe DeployS3::Main do
  let(:deploy) {
    DeployS3::Main.new(:environment => 'production',
                       :config => {'s3' => 'my-bucket/deployments/foo'})
  }

  describe '#environment' do
    it 'uses the passed environment' do
      expect(deploy.environment).to eq('production')
    end
  end

  describe '#filename' do
    it 'computes the filename' do
      expect(deploy.filename).to eql('production.sha')
    end
  end

  describe '#key' do
    it 'computes the key' do
      expect(deploy.key).to eq('deployments/foo/production.sha')
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
