require "sinatra"
require "json"
require "logger"
require "chartkick"

require_relative "ai/genetic_learning/genetic_learning"

set :logging, false

logger = Logger.new(STDOUT)
logger.level = :info

# Some AIs take config options. Pass them here
config = {
  seed_run_keys: []
}

ai = AI::GeneticLearning.new(config, logger: logger)

post "/prompt" do
  # return if ai.generation_index > 500

  payload = JSON.parse(request.body.read)

  ai.query(payload).join(",")
end

get "/diagnostics" do
  @stats = ai.stats
  erb :diagnostics
end
