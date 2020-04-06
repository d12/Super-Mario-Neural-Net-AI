import nintaco.api.*;

import java.net.*;
import java.util.*;
import java.io.*;

public class EmulatorHook {
  Emulator emulator;

  final String PROMPT_PATH = "http://localhost:5000/prompt";

  public EmulatorHook() {
    emulator = new Emulator(this);
  }

  public void controllerListener() {
    String response = networkRequest(PROMPT_PATH, "POST", null);
    int[] inputs = Arrays.stream(response.split(",")).mapToInt(Integer::parseInt).toArray();
    emulator.writeResultToGamepad(inputs);
    emulator.setSpeed();
  }

  private static String networkRequest(String address, String requestType, String body) {
    try {
      URL url = new URL(address);

      HttpURLConnection con = (HttpURLConnection) url.openConnection();
      con.setRequestMethod(requestType);

      if(body != null) {
        con.setDoOutput(true);
        con.setRequestProperty("Content-Length", Integer.toString(body.length()));
        con.getOutputStream().write(body.getBytes("UTF8"));
      }

      BufferedReader in = new BufferedReader(
      new InputStreamReader(con.getInputStream()));

      String inputLine;
      StringBuffer content = new StringBuffer();
      while ((inputLine = in.readLine()) != null) {
        content.append(inputLine);
      }

      in.close();

      return(content.toString());
    } catch(IOException ex) {
      System.out.println(ex.getMessage());
      return("");
    }
  }

  public static void main(final String... args) {
    new EmulatorHook();
  }
}
