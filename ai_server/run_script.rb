require "sinatra"
require "json"
require "logger"

require_relative "ai/genetic_learning/genetic_learning"

set :logging, false

logger = Logger.new(STDOUT)
logger.level = :info

# Some AIs take config options. Pass them here
config = {}

ai = AI::GeneticLearning.new(config, logger: logger)

post "/prompt" do
  payload = JSON.parse(request.body.read)

  ai.query(payload).join(",")
end
