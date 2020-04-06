import nintaco.api.*;

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

  private final int CONTROLLER = 0;

  // Various memory addresses of different relevant pieces of data in the SMB1 game.
  private final int CPU_MARIO_X_POS = 0x0086;
  private final int CPU_MARIO_X_PAGE = 0x006d;
  private final int CPU_FREEZE_TIMER = 0x0747;
  private final int CPU_FRAME_COUNTER = 0x0009;

  public Emulator(EmulatorHook hook) {
    api = ApiSource.getAPI();
    api.run();

    api.addControllersListener(hook::controllerListener);
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

    // On a standard NES controller, you cannot press up + down or left + right
    // without breaking your controller. Ensure our AI doesn't do this.

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
  }
}
