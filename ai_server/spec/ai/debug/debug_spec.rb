require_relative "../../../ai/debug/debug"
require_relative "../../../ai/network_helper"
require_relative "../../../ai/run"

describe AI::Debug do
  let(:network) { NetworkHelper.create_network(10240, 20, 20, 6) } # TODO: bring this number down to make tests faster
  let(:key) { Random.srand.to_s }
  let(:key_path) { "saves/#{key}" }

  describe "#initialize" do
    it "reads from the correct save file" do
      expect(File).to receive(:exists?).with(key_path).and_return(true)
      expect(File).to receive(:read).with(key_path).and_return(network.serialize)

      debug_ai = AI::Debug.new({"key" => key})
    end
  end

  describe "#query" do
    before do
      expect(File).to receive(:exists?).with(key_path).and_return(true)
      expect(File).to receive(:read).with(key_path).and_return(network.serialize)

      @debug_ai = AI::Debug.new({"key" => key})
    end

    let :sample_input do
      {
        "image" => [0] * 10240,
        "x_position" => 0
      }
    end

    it "returns a valid output" do
      controller_output = [1, 0, 1, 0, 1, 0]
      expect_any_instance_of(AI::Run).to receive(:calculate_controller_output).and_return(controller_output)

      output = @debug_ai.query(sample_input)

      expect(output.length).to eq(7)
      expect(output.first(6)).to eq(controller_output)
    end

    context "when mario is dead" do
      it "returns output with enabled reset bit" do
        expect_any_instance_of(AI::Run).to receive(:dead?).and_return(true)

        output = @debug_ai.query(sample_input)
        expect(output.last).to eq(1)
      end

      it "prepares a new run" do
        expect_any_instance_of(AI::Run).to receive(:dead?).and_return(true)
        expect(@debug_ai).to receive(:prepare_next_run).once

        output = @debug_ai.query(sample_input)
      end
    end

    context "when mario is alive" do
      it "returns output with disabled reset bit" do
        expect_any_instance_of(AI::Run).to receive(:dead?).and_return(false)

        output = @debug_ai.query(sample_input)
        expect(output.last).to eq(0)
      end

      it "does not prepare a new run" do
        expect_any_instance_of(AI::Run).to receive(:dead?).and_return(false)
        expect(@debug_ai).to receive(:prepare_next_run).never

        output = @debug_ai.query(sample_input)
      end
    end
  end
end
