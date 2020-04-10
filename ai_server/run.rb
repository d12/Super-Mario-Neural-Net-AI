require "simple_neural_network"

class Run
  INITIAL_DEATH_TIMER = 100

  attr_accessor :key

  def initialize(network:, key:)
    @frame = 0
    @death_timer = INITIAL_DEATH_TIMER
    @dead = false
    @network = network
    @key = key
  end

  def dead?
    @dead
  end

  def calculate_controller_output
    if skip_frame?
      @last_output
    else
      @last_output = @network.run(@image).map(&:round)
    end
  end

  def update(image:, x_position:)
    @frame += 1
    @image = image

    @last_x_position = @x_position
    @x_position = x_position

    update_dead_flag
  end

  def score
    @x_position
  end

  def report_score
    puts "  #{run.key} - #{run.score}"
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
