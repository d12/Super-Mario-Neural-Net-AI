require "simple_neural_network"
class AI
  class Run
    INITIAL_DEATH_TIMER = 100

    def initialize(network: nil, dimensions: [], key: nil, age: 0)
      @frame = 0
      @age = age
      @death_timer = INITIAL_DEATH_TIMER
      @dead = false
      @key = key || Random.srand.to_s # TODO: Stop using srand, it's not a random number generator lol

      @network = if network
        network
      elsif dimensions
        NetworkHelper.create_network(*dimensions)
      else
        NetworkHelper.create_network(10240, 20, 20, 6)
      end
    end

    def age
      @age
    end

    def dead?
      @dead
    end

    def calculate_controller_output
      if skip_frame?
        @last_output
      else
        @last_output = [*@network.run(@image, skip_validation: true).map(&:round), 0, 0]
      end
    end

    def update(payload)
      @frame += 1
      @image = payload["image"]

      @last_x_position = @x_position
      @x_position = payload["x_position"]

      update_dead_flag
    end

    def score
      @x_position
    end

    def key
      @key
    end

    def network
      @network
    end

    def inspect
      "#<Run##{object_id}>"
    end

    private

    def update_dead_flag
      return if @dead

      if @x_position == @last_x_position
        @death_timer -= 1
      else
        @death_timer = INITIAL_DEATH_TIMER
      end

      if @death_timer <= 0
        @dead = true
      end
    end

    def skip_frame?
      (@frame % 8 != 0) && @last_output
    end
  end
end
