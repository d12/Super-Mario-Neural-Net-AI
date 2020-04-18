require_relative "../base"
require_relative "generation"

class AI
  class GeneticLearning < Base
    def initialize #TODO: Take seed keys as a config option
      @generation = Generation.new
      @run_index = 0
      @generation_index = 0
    end

    private

    def reset?
      run.dead?
    end

    def run
      @generation.runs[@run_index]
    end

    def prepare_next_run
      run.report_score

      @run_index += 1

      if !run
        setup_new_generation
      elsif run.dead?
        prepare_next_run
      end
    end

    def setup_new_generation
      @generation.announce_winners(@generation_index)
      @generation.save_winners

      @generation_index += 1
      @run_index = 0
      @generation = Generation.new(@generation.winners)

      prepare_next_run if run.dead?
    end
  end
end
