require "sinatra"
require "json"

require_relative "ai/debug/debug"
require_relative "ai/genetic_learning/genetic_learning"
require_relative "ai/random_inputs/random_inputs"

set :logging, false

available_ais = {
  genetic: AI::GeneticLearning,
  debug: AI::Debug,
  random_inputs: AI::RandomInputs
}

config = JSON.parse(File.read("config/config.json"))

selected_ai_name = config["ai"].to_sym
ai = available_ais[selected_ai_name].new(config)

before do
  if request.body.size > 0
    request.body.rewind
    @payload = JSON.parse(request.body.read)
  end
end

post "/prompt" do
  ai.query(@payload).join(",")
end
