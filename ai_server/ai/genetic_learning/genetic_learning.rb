require_relative "../base"
require_relative "generation"

class AI
  class GeneticLearning < Base
    def initialize(_config, logger:)
      @generation = Generation.new(logger: logger)
      @run_index = 0
      @generation_index = 0
      @logger = logger
    end

    private

    def logger
      @logger
    end

    def reset?
      run.dead?
    end

    def run
      @generation.runs[@run_index]
    end

    def prepare_next_run
      logger.info "** #{run.key} - #{run.score}"

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
      @generation = Generation.new(@generation.winners, logger: @logger)

      prepare_next_run if run.dead?
    end
  end
end
