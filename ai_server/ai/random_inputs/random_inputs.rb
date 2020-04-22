require_relative "../base"

class AI
  class RandomInputs < Base
    attr_accessor :run, :network

    def initialize(_config, logger:)
    end

    def query(_payload)
      reset_bit = reset? ? 1 : 0

      controller_output = 6.times.map { [0, 1].sample }

      [*controller_output, reset_bit]
    end

    private

    def reset?
    end

    def prepare_next_run
    end
  end
end
