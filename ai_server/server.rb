require "simple_neural_network"
require "byebug"
require "sinatra"
require "json"

set :logging, false

before do
  if request.body.size > 0
    request.body.rewind
    @request_payload = JSON.parse(request.body.read)
  end
end

post "/prompt" do
  sleep(0.05)
  [6.times.map{|a| ran}.join(",")]
end

def ran
  [0,1].sample
end
