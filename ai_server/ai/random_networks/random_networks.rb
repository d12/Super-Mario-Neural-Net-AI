require_relative "../base"
require_relative "../network_helper"

class AI
  class RandomNetworks < Base
    def initialize(_config, logger:)
      @run_index = 0
      @run = random_run

      @best_run = {
        key: nil,
        score: 0
      }

      @logger = logger
    end

    private

    def run
      @run
    end

    def logger
      @logger
    end

    def random_run
      Run.new(dimensions: [10240, 20, 20, 6])
    end

    def reset?
      @run.dead?
    end

    def prepare_next_run
      logger.info "** Run #{@run_index}"
      logger.info "** #{@run.key} - #{@run.score}"

      @run_index += 1

      if run.score > @best_run[:score]
        @best_run[:key] = @run.key
        @best_run[:score] = @run.score

        logger.info "** Saving network..."
        NetworkHelper.save_network(@run.network, @run.key)
      end

      @run = random_run

      logger.info "** Best: #{@best_run[:key]} (#{@best_run[:score]})"
      logger.info "**"
    end
  end
end
