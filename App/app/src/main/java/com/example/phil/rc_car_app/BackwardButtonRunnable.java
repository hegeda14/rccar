package com.example.phil.rc_car_app;

import android.widget.TextView;
import java.io.IOException;
import java.io.OutputStream;
/**
 * Created by Phil on 22.03.2016.
 */
public class BackwardButtonRunnable implements Runnable{

    private boolean stop = false;
    private OutputStream outStream = null;

    @Override
    public void run() {
        stop = false;
        while (true) {
            if (isStop() == true) {
            }else{
                sendData("s");
            }
        }
    }

    public void setStop(boolean stop) {
        this.stop = stop;
    }

    public boolean isStop() {
            return stop;
        }

    /**
     * Send data to the RC-Car
     * @param message
     */
    public void sendData(String message) {
        byte[] msgBuffer = message.getBytes();
        if (outStream != null) {
            try {
                outStream.write(msgBuffer);
            } catch (IOException e) {}
        }
    }
}
