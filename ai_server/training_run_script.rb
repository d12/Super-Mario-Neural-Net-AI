require "sinatra"
require "json"
require "logger"

require_relative "ai/record_inputs/record_inputs"

set :logging, false

logger = Logger.new(STDOUT)
logger.level = :info

# Some AIs take config options. Pass them here
config = {}

ai = AI::RecordInputs.new(config, logger: logger)

post "/prompt" do
  data = request.body.read
  Thread.new do
    ai.query(data)
  end
end
