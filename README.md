# SMB1 Neural Net AI - Ruby

An SMB1 Neural Net AI written in Ruby, using the Nintaco NES emulator.

![](https://user-images.githubusercontent.com/30920216/78512703-9b155680-7774-11ea-80c6-ddebb6c2a019.gif)

## How it works

`emulator_hook/` is a small Java project meant to act as the interface between the Emulator (written in Java) and my AI (written in Ruby). It sets up hooks for "Controller input requested", and fires off a POST request to the Ruby service when this happens. The request includes a compressed image of the emulator and Mario's X position, extracted from the emulator RAM.

`ai_server`/ is a Sinatra server that houses the AI. The emulator hook will send requests to the AI server asking for controller inputs. The AI server calculates inputs and maintains various types of state.

## The AI Server

At it's core, the AI server accepts POST requests with an image of the NES screen and mario's X position, and decides what the output controller state should be. The image passed to the AI is heavily compressed and looks like this:

![](https://i.imgur.com/EwA6ijI.png)

The AI server has swappable AI strategies that serve different purposess. Each strategy uses Neural networks because I wanted to try applying neural nets, not because they're better than some other AI.

The neural networks have an input node per pixel in the input image, and have 6 outputs, one per button on the controller.

The `debug` strategy runs the game with a specified neural network. When mario dies or gets stuck, it resets and does it again.

The `genetic_learning` strategy implements a [Genetic algorithm](https://en.wikipedia.org/wiki/Genetic_algorithm) to try to discover an optimal neural network to solve the game. When Mario dies, we mutate and breed AIs according to a typical genetic learning algorithm. 

The AI server's response to the emulator hook also includes a 7th bit, a "reset bit" which can be used to inform the emulator that the AI would like to reset the console. This is used in training.

## Saved Networks

When training, we'd want to be able to "save" the good networks to be able to use them or review them later. The NetworkHelper class has methods to serialize and save neural networks to the filessystem, and later deserialize them back to a network. Networks are identified by a random `key` that is assigned on creation.

## How to run

1. In the emulator_hook dir, compile the Java program: script/compile `
2. In the ai_server dir, start the AI server: `ruby server.rb -p 5000`
3. Open nintaco.jar (Found here https://nintaco.com/)
4. In Nintaco, Open a .nes ROM of smb1
5. In Nintaco, Tools > Run Program
6. Load the compiled .jar from step 1, then hit Run
