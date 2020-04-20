require "simple_neural_network"

class NetworkHelper
  class << self
    SAVES_DIRECTORY = "saves"

    def create_network(*layers)
      network = SimpleNeuralNetwork::Network.new

      layers.each do |neuron_count|
        network.create_layer(neurons: neuron_count)
      end

      network
    end

    def mutate_network(network)
      duped_network = SimpleNeuralNetwork::Network.deserialize(network.serialize)
      duped_network.layers[0..-2].each_with_index do |layer, index|
        4.times do
          edges_count = duped_network.layers[index].neurons.sample.edges.count
          duped_network.layers[index].neurons.sample.edges[(0..(edges_count-1)).to_a.sample] += random_num(-2, 2)
        end

        4.times do
          duped_network.layers[index].neurons.sample.bias += random_num(-1, 1)
        end
      end

      duped_network.clear_edge_caches
      duped_network
    end

    def save_network(network, key)
      return if File.exists?(saves_path(key))

      File.write(saves_path(key), network.serialize)
    end

    def load_network(key)
      return unless File.exists?(saves_path(key))
      json = File.read(saves_path(key))

      SimpleNeuralNetwork::Network.deserialize(json)
    end

    private

    def saves_path(key)
      "#{SAVES_DIRECTORY}/#{key}"
    end

    # Random number between a and b, 1 decimal place.
    def random_num(a, b)
      rand((a * 10)..(b * 10)) / 10.0
    end
  end
end
