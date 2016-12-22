package com.example.phil.rc_car_app;

/**
 * Created by Phil on 21.03.2016.
 */
public class forwardButtonRunnable implements Runnable {
    private boolean stop = false;

    @Override
    public void run() {
        stop = false;
        while (true) {
            if (isStop() == true) {
            } else {
                MainActivity.sendData("w");
            }
        }
    }

    public void setStop(boolean stop) {
        this.stop = stop;
    }

    public boolean isStop() {
        return stop;
    }
}
