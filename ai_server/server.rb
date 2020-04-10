require "sinatra"
require_relative "genetic/ai"

set :logging, false

ai = Genetic::AI.new

before do
  if request.body.size > 0
    request.body.rewind
    @payload = JSON.parse(request.body.read)
  end
end

post "/prompt" do
  ai.query(@payload).join(",")
end
