require_relative "run"

# An abstract base AI class. Specific AIs subclass the Base and implement missing methods.

class AI
  class Base
    def initialize
      raise NotImplementedError, "Subclasses must implement #initialize"
    end

    def query(payload)
      run.update(payload)

      controller_output = run.calculate_controller_output

      reset_bit = reset? ? 1 : 0

      if reset_bit == 1
        prepare_next_run
      end

      [*controller_output, reset_bit]
    end

    private

    # If true, the console will be reset on the next frame.
    def reset?
      raise NotImplementedError, "Subclasses must implement #reset"
    end

    # The current run. Must return an instance of Run.
    def run
      raise NotImplementedError, "Subclasses must implement #run"
    end

    def logger
      raise NotImplementedError, "Subclasses must implement #logger"
    end

    # Called when the console is reset.
    # Performs any necessary logic needed to start a new run.
    def prepare_next_run
      raise NotImplementedError, "Subclasses must implement #prepare_next_run"
    end
  end
end
