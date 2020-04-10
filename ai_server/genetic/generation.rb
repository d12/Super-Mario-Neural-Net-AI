require_relative "../run"

class Genetic
  class Generation
    attr_reader :runs

    def initialize
      a = create_network
      b = create_network
      @runs = [::Run.new(network: a[:network], key: a[:key]), ::Run.new(network: b[:network], key: b[:key])]
      @scores = []
    end

    def create_network
      network = SimpleNeuralNetwork::Network.new

      network.create_layer(neurons: 10240)
      network.create_layer(neurons: 20)
      network.create_layer(neurons: 20)
      network.create_layer(neurons: 6) # 4 directions, a, b

      key = Random.srand.to_s

      { network: network, key: key }
    end
  end
end
