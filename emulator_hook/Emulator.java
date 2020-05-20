import nintaco.api.*;
import java.util.*;

public class Emulator {
  private final API api;

  // % of normal speed to run the emulator.
  // 0 is interpreted as max speed.
  private final int SPEED = 0;

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
    loadLevel();
  }

  public void loadLevel() {
    api.quickLoadState(LEVEL);
  }

  public void setSpeed() {
    api.setSpeed(SPEED);
  }

  public void writeResultToGamepad(int[] result) {
    boolean up = result[0] == 1;
    boolean down = result[1] == 1;
    boolean left = result[2] == 1;
    boolean right = result[3] == 1;
    boolean a = result[4] == 1;
    boolean b = result[5] == 1;
    boolean start = result[6] == 1;
    boolean select = result[7] == 1;

    if(left && right){
      left = false;
    }

    if(up && down){
      down = false;
    }

    api.writeGamepad(CONTROLLER, BUTTON_UP, up);
    api.writeGamepad(CONTROLLER, BUTTON_DOWN, down);
    api.writeGamepad(CONTROLLER, BUTTON_LEFT, left);
    api.writeGamepad(CONTROLLER, BUTTON_RIGHT, right);
    api.writeGamepad(CONTROLLER, BUTTON_A, a);
    api.writeGamepad(CONTROLLER, BUTTON_B, b);
    api.writeGamepad(CONTROLLER, BUTTON_START, start);
    api.writeGamepad(CONTROLLER, BUTTON_SELECT, select);
  }

  public String requestPayload() {
    double[] image = getImage();
    int xPos = getMarioXPos();

    String imageString = Arrays.toString(image);
    String xPosString = Integer.toString(xPos);

    return String.format("{\"image\":%s,\"x_position\":%s}", imageString, xPosString);
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
