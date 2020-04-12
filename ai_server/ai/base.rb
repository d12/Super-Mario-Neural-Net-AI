require_relative "run"

class AI
  class Base
    def initialize
      raise NotImplementedError, "Subclasses must implement #initialize"
    end

    def query(payload)
      run.update(image: payload["image"], x_position: payload["x_position"])

      controller_output = run.calculate_controller_output
      reset_bit = run.dead? ? 1 : 0

      if reset_bit == 1
        prepare_next_run
      end

      [*controller_output, reset_bit]
    end

    private

    def prepare_next_run
      raise NotImplementedError, "Subclasses must implement #prepare_next_run"
    end
  end
end
