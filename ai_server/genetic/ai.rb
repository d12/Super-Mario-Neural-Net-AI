require_relative "generation"

class Genetic
  class AI
    def initialize
      puts "Beginning!"

      @generation = Generation.new
      @generation_index = 0
    end

    def query(payload)
      run.update(image: payload["image"], x_position: payload["x_position"])

      controller_output = run.calculate_controller_output
      is_mario_dead = run.dead? ? 1 : 0

      if is_mario_dead == 1
        run.report_score
        setup_next_run
      end

      [*controller_output, is_mario_dead]
    end

    private

    def run
      @generation.runs[@generation_index]
    end

    def setup_next_run
      if @generation.runs[@generation_index + 1]
        @generation_index += 1
        return
      end

      puts "New Generation!"
      @generation_index = 0
      @generation = Generation.new
    end
  end
end
