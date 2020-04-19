# SMB1 Neural Net AI - Ruby

An SMB1 Neural Net AI written in Ruby, using the Nintaco NES emulator.

![](https://user-images.githubusercontent.com/30920216/78512703-9b155680-7774-11ea-80c6-ddebb6c2a019.gif)

## How it works

`emulator_hook/` is a small Java project meant to act as the interface between the Emulator (written in Java) and my AI (written in Ruby). It sets up hooks for "Controller input requested", and fires off a POST request to the Ruby service when this happens. The request includes a compressed image of the emulator and Mario's X position, extracted from the emulator RAM.

`ai_server`/ is a Sinatra server that houses the AI. The emulator hook will send requests to the AI server asking for controller inputs. The AI server calculates inputs and maintains various types of state.

## The AI Server

At it's core, the AI server accepts POST requests with an image of the NES screen and mario's X position, and decides what the output controller state should be. The image passed to the AI is heavily compressed and looks like this:

![](https://i.imgur.com/EwA6ijI.png)

The AI server has swappable AI strategies that serve different purposess. Most strategies uses neural networks because I wanted to try applying neural nets, not because they're better than some other AI.

The neural networks have an input node per pixel in the input image, and have 6 outputs, one per button on the controller.

The AI server's response to the emulator hook also includes a 7th bit, a "reset bit" which can be used to inform the emulator that the AI would like to reset the console. This is used in training.

## Available Strategies

#### Genetic Learning

Attempts to discover an optimal neural net that gets as far into the level as possible via a genetic algorithm.

The first generation is seeded with `GENERATION_SIZE` random networks. We do a run of the level using each network and assign a "fitness" based on how far to the right Mario got.

At the end of every generation, `WINNERS_PER_GEN` winners are selected based on their fitness values. These winners are saved to the filesystem as serialized network save files. The next generation is composed of the winners, a mutation of each winner, and new random networks if needed to fill the generation.

Mutations are made by making small changes to the edge weights of the neural networks. That logic can be found [here](https://github.com/d12/Super-Mario-Neural-Net-AI/blob/01b5d91cc2af79cd0a9b4e83853f88298e7240a9/ai_server/ai/network_helper.rb#L18).

#### Debug

Debug is a simple strategy to manually see a specific network play Mario. The debug strategy accepts a network save key, so is only useful when you have a key from some strategy that generates save files.

#### Random Inputs

Literally just random controller inputs. This strategy doesn't reset when Mario dies. Just random button mashing, all day.

## Saved Networks

When training, we'd want to be able to "save" the good networks to be able to use them or review them later. The `NetworkHelper` class has methods to serialize and save neural networks to the file system, and later deserialize them back to a network. Networks are identified by a random `key` that is assigned on creation.

## How to run

1. In the emulator_hook dir, compile the Java program: `script/compile `
2. In the ai_server dir, start the AI server: `ruby server.rb -p 5000`
3. Open nintaco.jar (Found here https://nintaco.com/)
4. In Nintaco, Open a .nes ROM of smb1
5. In Nintaco, Tools > Run Program
6. Load the compiled .jar from step 1, then hit Run
