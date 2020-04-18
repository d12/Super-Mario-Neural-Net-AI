require_relative "../../ai/base"
require_relative "../../ai/run"

class TestStrategy < AI::Base
  def initialize
    @run = AI::Run.new(network: nil)
  end

  def reset?
    false
  end

  def run
    @run
  end

  def prepare_next_run
    nil
  end
end


describe AI::Base do
  context "when not subclassed" do
    it "cannot be initialized" do
      expect { AI::Base.new }.to raise_error(NotImplementedError)
    end
  end

  context "when subclassed" do
    it "can be initialized" do
      TestStrategy.new
    end

    describe "#query" do
      before do
        @strategy = TestStrategy.new
        @payload = {
          "image" => [1, 0, 1, 0],
          "x_position" => 15
        }
      end

      it "updates the run with an image and x position" do
        allow_any_instance_of(AI::Run).to receive(:calculate_controller_output)
        expect_any_instance_of(AI::Run).to receive(:update).with(@payload).once

        @strategy.query(@payload)
      end

      it "will prepare new run if reset? is true" do
        allow_any_instance_of(AI::Run).to receive(:calculate_controller_output)

        expect(@strategy).to receive(:reset?).and_return(true)
        expect(@strategy).to receive(:prepare_next_run).once

        @strategy.query(@payload)
      end

      it "will not prepare new run if reset? is false" do
        allow_any_instance_of(AI::Run).to receive(:calculate_controller_output)

        expect(@strategy).to receive(:reset?).and_return(false)
        expect(@strategy).to receive(:prepare_next_run).never

        @strategy.query(@payload)
      end

      it "returns controller output and reset bit correctly" do
        expected_controller_output = [0, 1, 0, 1, 0, 1]
        expected_reset_bit = 0

        expect(@strategy).to receive(:reset?).and_return(false)
        expect_any_instance_of(AI::Run).to receive(:calculate_controller_output).and_return(expected_controller_output)

        strategy_output = @strategy.query(@payload)

        expect(strategy_output).to eq([*expected_controller_output, expected_reset_bit])
      end
    end
  end
end
