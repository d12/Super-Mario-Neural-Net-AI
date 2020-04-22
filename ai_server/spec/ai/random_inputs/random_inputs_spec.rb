require_relative "../../../ai/random_inputs/random_inputs"

require "logger"

describe AI::RandomInputs do
  let(:logger) { Logger.new(STDOUT) }
  subject { AI::RandomInputs.new(nil, logger: logger) }

  before do
    # Seed the randomness so we always get the same random outputs
    srand("01189998819991197253".to_i)
  end

  describe "#query" do
    it "returns a valid random output" do
      output = subject.query(nil)
      second_output = subject.query(nil)

      expect(output).to eq([1, 1, 1, 0, 0, 1, 0])
      expect(second_output).to eq([1, 1, 1, 0, 0, 0, 0])
    end
  end
end
