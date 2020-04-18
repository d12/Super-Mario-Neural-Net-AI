require_relative "../base"
require_relative "../network_helper"

class AI
  class Debug < Base
    attr_accessor :run, :network

    def initialize(config)
      @network = NetworkHelper.load_network(config["key"])
      @run = Run.new(network: @network)
    end

    private

    def reset?
      @run.dead?
    end

    def prepare_next_run
      @run = Run.new(network: network)
    end
  end
end
