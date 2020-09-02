describe Fastlane::Actions::HyPgyerAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The hy_pgyer plugin is working!")

      Fastlane::Actions::HyPgyerAction.run(nil)
    end
  end
end
