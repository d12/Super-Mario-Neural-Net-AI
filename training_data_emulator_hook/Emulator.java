import nintaco.api.*;
import java.util.*;

public class Emulator {
  private final API api;

  // % of normal speed to run the emulator.
  // 0 is interpreted as max speed.
  private final int SPEED = 100;

  // Which level are we running?
  private final int LEVEL = 9;

  // Mario CPU addresses store 8 bits each. Mario stores an X pos, and an X page.
  // Every 256 (2**8) pixels, the xpos goes back to 0 and we increment the page.
  private final int MARIO_PAGE_SIZE = 256;

  // The emulator has assigned each button an integer. We need to use this identifier
  // when sending commands to the emulator
  private final int BUTTON_A = 0;
  private final int BUTTON_B = 1;
  private final int BUTTON_UP = 4;
  private final int BUTTON_DOWN = 5;
  private final int BUTTON_LEFT = 6;
  private final int BUTTON_RIGHT = 7;
  private final int BUTTON_START = 3;
  private final int BUTTON_SELECT = 2;

  private final int CONTROLLER = 0;

  // Various memory addresses of different relevant pieces of data in the SMB1 game.
  private final int CPU_MARIO_X_POS = 0x0086;
  private final int CPU_MARIO_X_PAGE = 0x006d;

  public Emulator(EmulatorHook hook) {
    api = ApiSource.getAPI();
    api.run();

    api.addControllersListener(hook::controllerListener);
  }

  public void loadLevel() {
    api.quickLoadState(LEVEL);
  }

  public void reset() {
    api.reset();
  }

  public void setSpeed() {
    api.setSpeed(SPEED);
  }

  public int[] readGamepadInputs() {
    int up = api.readGamepad(CONTROLLER, BUTTON_UP) ? 1 : 0;
    int down = api.readGamepad(CONTROLLER, BUTTON_DOWN) ? 1 : 0;
    int left = api.readGamepad(CONTROLLER, BUTTON_LEFT) ? 1 : 0;
    int right = api.readGamepad(CONTROLLER, BUTTON_RIGHT) ? 1 : 0;
    int a = api.readGamepad(CONTROLLER, BUTTON_A) ? 1 : 0;
    int b = api.readGamepad(CONTROLLER, BUTTON_B) ? 1 : 0;
    int start = api.readGamepad(CONTROLLER, BUTTON_START) ? 1 : 0;
    int select = api.readGamepad(CONTROLLER, BUTTON_SELECT) ? 1 : 0;

    int[] arr = new int[]{up, down, left, right, a, b, start, select};

    return arr;
  }

  public String requestPayload() {
    double[] image = getImage();
    int[] inputs = readGamepadInputs();

    String imageString = Arrays.toString(image);
    String inputsString = Arrays.toString(inputs);

    return String.format("{\"image\":%s,\"inputs\":%s}", imageString, inputsString);
  }

  // Get mario's X position
  private int getMarioXPos() {
    int page_num = api.readCPU(CPU_MARIO_X_PAGE);
    int x_index = api.readCPU(CPU_MARIO_X_POS);

    return ((page_num * MARIO_PAGE_SIZE) + x_index);
  }

  // Return an array of every pixel color on the screen
  // 61440 pixels total.
  private double[] getImage() {
    int[] rawPixels = new int[61440];
    api.getPixels(rawPixels);

    return processImage(rawPixels);
  }

  private double[] processImage(int[] image) {
    double[] croppedArr = new double[10240];

    for(int i = 0; i < 120; i++){
      for(int j = 0; j < 128; j++){
        if(i < 40){
          break; // Trim top 40 pixels off the top
        }

        int val = image[((i * 256) + j) * 2]; // Grab pixel from array. * 2 because we skip every other pixel, halving the resolution
        double scaled_val = scaled(val, 1);
        croppedArr[((i-40)*128) + j] = scaled_val;
      }
    }

    return croppedArr;
  }

  private double scaled(int pixel, int max_val){
    return(roundedToThreeDecimals((pixel / 64.0) * max_val));
  }

  private double roundedToThreeDecimals(double num) {
    return (Math.round(num * 100.0) / 100.0);
  }
}
