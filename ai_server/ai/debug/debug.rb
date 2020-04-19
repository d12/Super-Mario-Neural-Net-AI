require_relative "../base"
require_relative "../network_helper"

class AI
  class Debug < Base
    attr_accessor :run, :network

    def initialize(config)
      @key = config["key"]
      @network = NetworkHelper.load_network(@key)
      @run = Run.new(network: @network, key: @key)
    end

    private

    def reset?
      @run.dead?
    end

    def prepare_next_run
      @run = Run.new(network: network, key: @key)
    end
  end
end
