require_relative "../../ai/network_helper"

describe NetworkHelper do
  subject { NetworkHelper }

  describe ".create_network" do
    it "returns a valid 4 layer network" do
      network = subject.create_network(10240, 20, 20, 6)
      expect(network.layers.count).to eq(4)
    end
  end

  describe ".mutate_network" do
    it "returns a new mutated network" do
      original_network = subject.create_network(10240, 20, 20, 6)
      mutated = subject.mutate_network(original_network)

      expect(mutated.serialize).to_not eq(original_network.serialize)
    end

    it "does not mutate the original network" do
      original_network = subject.create_network(10240, 20, 20, 6)
      original_serialized = original_network.serialize

      subject.mutate_network(original_network)
      original_serialized_again = original_network.serialize

      expect(original_serialized).to eq(original_serialized_again)
    end
  end

  describe ".load_network" do
    describe "when the save does not exist" do
      it "returns nil" do
        allow(File).to receive(:exists?).and_return(false)

        expect(subject.load_network("string")).to be_nil
      end
    end

    describe "when the save exists" do
      it "loads the correct network" do
        network = subject.create_network(10240, 20, 20, 6)
        serialized_network = network.serialize

        key = "key"
        key_path = "saves/#{key}"

        allow(File).to receive(:exists?).with(key_path).and_return(true)
        allow(File).to receive(:read).with(key_path).and_return(serialized_network)

        loaded_network = subject.load_network(key)
        serialized_loaded_network = loaded_network.serialize

        expect(serialized_network).to eq(serialized_loaded_network)
      end
    end
  end

  describe ".save_network" do
    describe "when the save already exists" do
      it "returns nil" do
        key = "key"
        key_path = "saves/#{key}"

        allow(File).to receive(:exists?).with(key_path).and_return(true)

        expect(subject.save_network(double, key)).to be_nil
      end
    end

    describe "when the does not exist" do
      it "saves the network" do
        network = subject.create_network(10240, 20, 20, 6)

        key = "key"
        key_path = "saves/#{key}"

        allow(File).to receive(:exists?).with(key_path).and_return(false)
        allow(File).to receive(:write).with(key_path, network.serialize).and_return(true)

        subject.save_network(network, key)
      end
    end
  end
end
