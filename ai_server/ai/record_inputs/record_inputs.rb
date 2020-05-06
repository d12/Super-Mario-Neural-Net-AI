require_relative "../base"

class AI
  class RecordInputs < Base
    LAST_RUN_ID_PATH = "training_data/last_run_id"

    def initialize(config, logger:)
      @logger = logger
      @training_data_dir = setup_training_dir
      @frame = 0
    end

    def query(payload)
      File.write(File.join(@training_data_dir, @frame.to_s), payload)
      @frame += 1
    end

    private

    def setup_training_dir
      last_run_id = File.read(LAST_RUN_ID_PATH).to_i
      new_dir = "training_data/#{last_run_id}"
      Dir.mkdir(new_dir)
      File.write(LAST_RUN_ID_PATH, last_run_id + 1)

      new_dir
    end
  end
end
