require_relative "../../../ai/genetic_learning/genetic_learning"
require_relative "../../../ai/genetic_learning/generation"
require_relative "../../../ai/network_helper"
require_relative "../../../ai/run"

describe AI::GeneticLearning do
  let(:payload) { {"image" => [0] * 10240, "x_position" => 15} }

  describe "#query" do
    context "when mario is not dead" do
      let!(:strategy) { AI::GeneticLearning.new(nil) }

      before do
        allow_any_instance_of(AI::Run).to receive(:dead?).and_return(false)
      end

      it "does not report scores" do
        expect_any_instance_of(AI::Run).to receive(:report_score).never
        expect_any_instance_of(AI::GeneticLearning::Generation).to receive(:announce_winners).never

        strategy.query(payload)
      end

      it "does not create a new generation" do
        expect(AI::GeneticLearning::Generation).to receive(:new).never

        strategy.query(payload)
      end

      it "returns valid controller outputs" do
        *outputs, _reset_bit = strategy.query(payload)

        expect(outputs.length).to eq(6)
        expect(outputs.all?{|output| output == 0 || output == 1}).to be_truthy
      end

      it "returns false reset bit" do
        *_outputs, reset_bit = strategy.query(payload)
        expect(reset_bit == 0 || reset_bit == 1).to be_truthy
      end
    end

    context "when mario has died once" do
      before do
        @strategy = AI::GeneticLearning.new(nil)
        @gen = @strategy.instance_variable_get(:@generation)
        @runs = @gen.runs

        allow(@runs.first).to receive(:dead?).and_return(true)
      end

      it "reports the run score" do
        expect_any_instance_of(AI::Run).to receive(:report_score).once

        @strategy.query(payload)
      end

      it "updates the current run" do
        expect(@runs[1]).to receive(:dead?).and_return(true)
        @strategy.query(payload)
      end
    end

    context "when mario has died ten times" do
      before do
        @strategy = AI::GeneticLearning.new(nil)
        @gen = @strategy.instance_variable_get(:@generation)
        @runs = @gen.runs

        @runs.each_with_index do |run, i|
          allow(run).to receive(:dead?).and_return(true)
          allow(run).to receive(:score).and_return(i)
        end

        allow(@gen).to receive(:save_winners)
      end

      it "will create a new generation with the correct winners" do
        expect(AI::GeneticLearning::Generation).to receive(:new).with(@runs.reverse.first(3)).and_call_original

        @strategy.query(payload)
      end

      it "will announce winners" do
        expect(@gen).to receive(:announce_winners).once

        @strategy.query(payload)
      end

      it "will save runs" do
        expect(@gen).to receive(:save_winners)

        @strategy.query(payload)
      end
    end
  end
end
