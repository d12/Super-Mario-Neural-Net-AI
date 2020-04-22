require_relative "../../../ai/genetic_learning/generation"
require_relative "../../../ai/network_helper"
require_relative "../../../ai/run"

require "logger"

describe AI::GeneticLearning::Generation do
  let(:logger) { Logger.new(STDOUT) }

  subject { AI::GeneticLearning::Generation.new(logger: logger) }

  let(:generation_size) { subject.generation_size }

  before do
    logger.level = Logger::ERROR
  end

  describe "#initialize" do
    context "when no seed runs are given" do
      it "creates the correct number of runs" do
        expect(NetworkHelper).to receive(:create_network).exactly(10).times

        AI::GeneticLearning::Generation.new(logger: logger)
      end

      it "does not mutate any new networks" do
        expect(NetworkHelper).to receive(:mutate_network).never

        AI::GeneticLearning::Generation.new(logger: logger)
      end
    end

    context "when less than half of the max seed runs are provided" do
      it "creates the correct number of runs" do
        new_runs_count = (generation_size / 2) - 1

        seed_runs = new_runs_count.times.map do |n|
          AI::Run.new(dimensions: [10240, 20, 20, 6])
        end

        runs_expected_to_be_created = generation_size - (2 * new_runs_count)
        expect(NetworkHelper).to receive(:create_network).exactly(runs_expected_to_be_created).times

        AI::GeneticLearning::Generation.new(seed_runs, logger: logger)
      end

      it "mutates all runs provided" do
        new_runs_count = (generation_size / 2) - 1

        seed_runs = new_runs_count.times.map do |n|
          AI::Run.new(dimensions: [10240, 20, 20, 6])
        end

        expect(NetworkHelper).to receive(:mutate_network).exactly(new_runs_count).times

        AI::GeneticLearning::Generation.new(seed_runs, logger: logger)
      end
    end

    context "when more than half of the max seed runs are provided" do
      let(:new_runs_count) { (generation_size / 2) + 1 }

      it "creates no runs" do
        seed_runs = new_runs_count.times.map do |n|
          AI::Run.new(dimensions: [10240, 20, 20, 6])
        end

        expect(NetworkHelper).to receive(:create_network).never

        AI::GeneticLearning::Generation.new(seed_runs, logger: logger)
      end

      it "mutates enough runs to fill the generation_size, but not all" do
        seed_runs = new_runs_count.times.map do |n|
          AI::Run.new(dimensions: [10240, 20, 20, 6])
        end

        expected_mutations = generation_size - new_runs_count
        expect(NetworkHelper).to receive(:mutate_network).exactly(expected_mutations).times

        AI::GeneticLearning::Generation.new(seed_runs, logger: logger)
      end
    end
  end

  describe "#winners" do
    before do
      @runs = []

      (1..10).each do |i|
        run = AI::Run.new
        allow(run).to receive(:score).and_return(i)

        @runs << run
      end

      @generation = AI::GeneticLearning::Generation.new(@runs, logger: logger)
    end

    it "returns the correct winners in the correct order" do
      expected_winners = @runs.last(3).reverse

      expect(@generation.winners).to eq(expected_winners)
    end
  end

  describe "#save_winners" do
    before do
      @runs = []

      (1..10).each do |i|
        run = AI::Run.new
        allow(run).to receive(:score).and_return(i)

        @runs << run
      end

      @generation = AI::GeneticLearning::Generation.new(@runs, logger: logger)
    end

    it "saves all winners" do
      expect(NetworkHelper).to receive(:save_network).exactly(3).times

      @generation.save_winners
    end
  end
end
