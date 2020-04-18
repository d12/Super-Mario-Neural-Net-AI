require_relative "../network_helper"
require_relative "../base"

class AI
  class GeneticLearning < Base
    class Generation
      GENERATION_SIZE = 10
      WINNERS_PER_GEN = 3

      attr_reader :runs

      def initialize(seed_runs = [])
        @runs = seed_runs.dup

        # Mutate seeds
        seed_runs.each do |seed_run|
          break if @runs.length == GENERATION_SIZE

          @runs << Run.new(network: NetworkHelper.mutate_network(seed_run.network))
        end

        # If there's more capacity, create random networks
        while @runs.length < GENERATION_SIZE
          @runs << Run.new(network: NetworkHelper.create_network)
        end
      end

      def winners
        @winners ||= begin
          sorted_runs = @runs.sort_by do |run|
            run.score
          end

          sorted_runs.reverse.first(WINNERS_PER_GEN)
        end
      end

      def announce_winners(index)
        puts

        puts "Generation #{index} winners:"
        winners.each_with_index do |winner, index|
          puts "#{index + 1}. #{winner.key} - #{winner.score}"
        end

        puts
        puts
      end

      def save_winners
        winners.each do |winner|
          NetworkHelper.save_network(winner.network, winner.key)
        end
      end

      def generation_size
        GENERATION_SIZE
      end
    end
  end
end
