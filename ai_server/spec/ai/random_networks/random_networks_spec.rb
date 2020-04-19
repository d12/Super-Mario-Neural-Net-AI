require_relative "../../../ai/random_networks/random_networks"

describe AI::RandomNetworks do
  before do
    @strategy = AI::RandomNetworks.new(nil)
  end

  let(:sample_payload) { {"image" => [0] * 10240, "x_position" => 0} }

  describe "#query" do
    context "when mario is alive" do
      it "returns a valid output" do
        *controller_output, reset_bit = @strategy.query(sample_payload)

        expect(controller_output.all?{|bit| bit == 0 || bit == 1 }).to be_truthy
        expect(reset_bit).to eq(0)
      end

      it "does not create a new run" do
        expect(AI::Run).to receive(:new).never

        @strategy.query(sample_payload)
      end

      it "does not write anything to the file system" do
        expect(File).to receive(:write).never

        @strategy.query(sample_payload)
      end
    end

    context "when mario dies" do
      it "creates a new run" do
        allow_any_instance_of(AI::Run).to receive(:dead?).and_return(true)

        expect(AI::Run).to receive(:new).once.and_call_original
        expect(NetworkHelper).to receive(:create_network).once.and_call_original

        @strategy.query(sample_payload)
      end

      it "sets reset bit to true" do
        allow_any_instance_of(AI::Run).to receive(:dead?).and_return(true)

        *_controller_output, reset_bit = @strategy.query(sample_payload)

        expect(reset_bit).to eq(1)
      end

      context "when run is a high score" do
        it "writes network to filesystem" do
          allow_any_instance_of(AI::Run).to receive(:score).and_return(5)
          allow_any_instance_of(AI::Run).to receive(:dead?).and_return(true)

          expect(File).to receive(:write).once

          @strategy.query(sample_payload)
        end
      end

      context "when run is not a high score" do
        it "does not write anything to the file system" do
          allow_any_instance_of(AI::Run).to receive(:score).and_return(-1)
          allow_any_instance_of(AI::Run).to receive(:dead?).and_return(true)

          expect(File).to receive(:write).never

          @strategy.query(sample_payload)
        end
      end
    end
  end
end
