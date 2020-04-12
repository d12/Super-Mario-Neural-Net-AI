require_relative "../../ai/run"
require_relative "../../ai/network_helper"
require "simple_neural_network"

describe Run do
  let(:network) { NetworkHelper.create_network }
  let(:run) { Run.new(network: network) }

  describe "#key" do
    it "assigns a random key to the network" do
      expect(run.key).to_not be_nil
    end
  end

  describe "#calculate_controller_output" do
    context "if on a skip frame" do
      it "does not run the network and returns a cached value" do
        expect_any_instance_of(Run).to receive(:skip_frame?).and_return(true)
        expect_any_instance_of(SimpleNeuralNetwork::Network).to receive(:run).never

        run.calculate_controller_output
      end
    end

    context "if not on a skip frame" do
      it "runs the network" do
        expect_any_instance_of(Run).to receive(:skip_frame?).and_return(false)
        expect_any_instance_of(SimpleNeuralNetwork::Network).to receive(:run).once.and_return([0]*6)

        run.calculate_controller_output
      end
    end
  end

  describe "#update" do
    it "marks mario as dead if he doesn't move for over 100 frames" do
      expect(run.dead?).to be_falsey

      101.times do
        run.update(image: [0], x_position: 0)
      end

      expect(run.dead?).to be_truthy
    end

    it "does not mark mario as dead if he moves during a 101 frame window" do
      expect(run.dead?).to be_falsey

      100.times do
        run.update(image: [0], x_position: 0)
      end

      run.update(image: [0], x_position: 1)

      expect(run.dead?).to be_falsey
    end
  end
end
