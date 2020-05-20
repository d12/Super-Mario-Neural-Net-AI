require_relative "../network_helper"
require_relative "../base"

class AI
  class GeneticLearning < Base
    class Generation
      GENERATION_SIZE = 10
      WINNERS_PER_GEN = 4

      attr_reader :runs

      def initialize(seed_runs = [], logger:)
        @logger = logger
        @runs = seed_runs.dup

        # Mutate seeds
        seed_runs.each do |seed_run|
          break if @runs.length == GENERATION_SIZE

          @runs << Run.new(network: NetworkHelper.mutate_network(seed_run.network), age: seed_run.age + 1)
        end

        # If there's more capacity, create random networks
        while @runs.length < GENERATION_SIZE
          @runs << Run.new(dimensions: [10240, 20, 20, 6])
        end
      end

      def winners
        @winners ||= begin
          sorted_runs = @runs.sort_by do |run|
            [-run.score, -run.age]
          end

          # Only take one winner of each score
          runs_taken = {}

          sorted_runs.each do |run|
            break if runs_taken.length == WINNERS_PER_GEN
            next if runs_taken[run.score]

            runs_taken[run.score] = run
          end

          runs_taken.values
        end
      end

      def announce_winners(index)
        @logger.info "**"

        @logger.info  "** Generation #{index} winners:"
        winners.each_with_index do |winner, index|
          @logger.info "** #{index + 1}. #{winner.key} - #{winner.score} (#{winner.age})"
        end

        @logger.info "**"
        @logger.info "**"
      end

      def save_winners
        winners.each do |winner|
          NetworkHelper.save_network(winner.network, winner.key)
        end
      end

      def generation_size
        GENERATION_SIZE
      end

      def highest_score
        winners.first.score
      end
    end
  end
end
