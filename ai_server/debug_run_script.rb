require "sinatra"
require "json"
require "logger"

require_relative "ai/debug/debug"

set :logging, false

logger = Logger.new(STDOUT)
logger.level = :info

# Some AIs take config options. Pass them here
config = {
  key: "146630000273818290342035196087564640008"
}

ai = AI::Debug.new(config, logger: logger)

post "/prompt" do
  # return if ai.generation_index > 500

  payload = JSON.parse(request.body.read)

  ai.query(payload).join(",")
end
