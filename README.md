# SMB1 Neural Net AI - Ruby

An SMB1 Neural Net AI written in Ruby, using the Nintaco NES emulator.

![](https://user-images.githubusercontent.com/30920216/78512703-9b155680-7774-11ea-80c6-ddebb6c2a019.gif)

## How it works

`emulator_hook/` is a small Java project meant to act as the interface between the Emulator (written in Java) and my AI (written in Ruby). It sets up hooks for "Controller input requested", and fires off a POST request to the Ruby service when this happens. The request includes a compressed image of the emulator and Mario's X position, extracted from the emulator RAM.

`ai_server`/ is a Sinatra server that houses the AI. The emulator hook will send requests to the AI server asking for controller inputs. The AI server calculates inputs and maintains various types of state.

The AI server also houses various training strategies that can be used to compute a neural net that performs optimally. The neural nets take an array of pixel brightnesses as input, and return the controller output. The image passed to the network is heavily compressed and cropped for performance reasons, and looks like this:

![](https://i.imgur.com/EwA6ijI.png)

The network output is an array of 6 bits, each representing whether a specific button on the NES controller should be pressed or not pressed for this frame.

The AI server's response to the emulator hook also includes a 7th bit, a "reset bit" which can be used to inform the emulator that the AI would like to reset the console. This is used in training.

## How to run

1. In the emulator_hook dir, compile the Java program: script/compile `
2. In the ai_server dir, start the AI server: `ruby server.rb -p 5000`
3. Open nintaco.jar (Found here https://nintaco.com/)
4. In Nintaco, Open a .nes ROM of smb1
5. In Nintaco, Tools > Run Program
6. Load the compiled .jar from step 1, then hit Run
