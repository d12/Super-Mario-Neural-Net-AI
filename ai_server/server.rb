require "sinatra"

require_relative "network_helper"
require_relative "ai/genetic_learning/genetic_learning"
require_relative "ai/single/single"

set :logging, false

# ai = Genetic::AI.new
ai = AI::Single.new("297393060850357012097200129934942449002")

before do
  if request.body.size > 0
    request.body.rewind
    @payload = JSON.parse(request.body.read)
  end
end

post "/prompt" do
  ai.query(@payload).join(",")
end
