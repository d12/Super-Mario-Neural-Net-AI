require_relative "../base"
require_relative "../network_helper"

class AI
  class RandomNetworks < Base
    def initialize(_config)
      @run_index = 0
      @run = random_run

      @best_run = {
        key: nil,
        score: 0
      }
    end

    private

    def run
      @run
    end

    def random_run
      Run.new(network: NetworkHelper.create_network)
    end

    def reset?
      @run.dead?
    end

    def prepare_next_run
      puts "Run #{@run_index}"
      @run.report_score

      @run_index += 1

      if run.score > @best_run[:score]
        @best_run[:key] = @run.key
        @best_run[:score] = @run.score

        puts "Saving network..."
        NetworkHelper.save_network(@run.network, @run.key)
      end

      @run = random_run

      puts "Best: #{@best_run[:key]} (#{@best_run[:score]})"
      puts
    end
  end
end
