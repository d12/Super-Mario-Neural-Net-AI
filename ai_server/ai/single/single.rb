require_relative "../base"

class AI
  class Single < Base
    attr_accessor :run, :network

    def initialize(key)
      @network = NetworkHelper.load_network(key)
      @run = Run.new(network: @network)
    end

    private

    def prepare_next_run
      @run = Run.new(network: network)
    end
  end
end
