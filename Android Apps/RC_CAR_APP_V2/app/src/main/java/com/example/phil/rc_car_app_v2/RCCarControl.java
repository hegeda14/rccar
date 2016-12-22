package com.example.phil.rc_car_app_v2;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.SeekBar;
import android.widget.TextView;

import java.text.DecimalFormat;

public class RCCarControl extends Activity {

    private Button main;
    private SeekBarVertical sBar, dBar;
    private SeekBar aBar;
    private TextView sVField, dVField, aVField;
    private static int angle, speed, direction;
    private static DecimalFormat formatter;
    private int sValueMax = 99, dValueMax = 99, aValueMax = 99;
    private int sValueStart = 0, dValueStart = 50, aValueStart = 50;
    private static char directionChar = ' ';
    // speedZero and angleZero have to be initialized like in the app,
    // because otherwise the value of angle is '0' and not '50'
    private static String speedZero = "00", angleZero = "50", directionZero = "50", speedTen, angleTen, directionTen, command;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_rccarcontrol);

        mainButtonControl();
        speedBar();
        angleBar();
        directionBar();

    }

    /**
     * MainButtonControl go back to the main menu
     */
    private void mainButtonControl(){
        main = (Button) findViewById(R.id.rc_main_menu);
        main.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent inM = new Intent(RCCarControl.this, MainActivity.class);
                startActivity(inM);
            }
        });
    }

    /**
     * With the seek Bar one you be able to set the speed of the RC-Car.
     */
    private void speedBar(){
        sBar = (SeekBarVertical) findViewById(R.id.speed);
        sVField = (TextView) findViewById(R.id.speed_value);
        sBar.setMax(sValueMax);
        sBar.setProgress(sValueStart);
        sVField.setText(Integer.toString(sValueStart));
        sBar.setOnSeekBarChangeListener(new SeekBarVertical.OnSeekBarChangeListener() {
            // This method keep the Text Field under the Seek Bar up to date,
            // so that there is always the right value in the Text Field.
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                sVField.setText(progress + "");
                if (progress <= 9) {
                    if (progress == 0) {
                        speed = progress;
                        formatter = new DecimalFormat("00");
                        speedZero = formatter.format(speed);
                    } else {
                        speed = progress;
                        formatter = new DecimalFormat("0" + progress);
                        speedTen = formatter.format(speed);
                    }
                } else {
                    speed = progress;
                }
                //sendRCCar();
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                // not used at the moment
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                // not used at the moment
            }
        });
    }

    /**
     * With the Seek Bar Two you can set the angel of the RC-Car.
     */
    private void angleBar() {
        aBar = (SeekBar) findViewById(R.id.angle);
        aVField = (TextView) findViewById(R.id.angle_value);
        aBar.setMax(aValueMax);
        aBar.setProgress(aValueStart);
        aVField.setText(Integer.toString(aValueStart));
        aBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            // This method keep the Text Field under the Seek Bar up to date,
            // so that there is always the right value in the Text Field.
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                aVField.setText(progress + "");
                if (progress <= 9) {
                    if (progress == 0) {
                        angle = progress;
                        formatter = new DecimalFormat("00");
                        angleZero = formatter.format(angle);
                    } else {
                        angle = progress;
                        formatter = new DecimalFormat("0" + progress);
                        angleTen = formatter.format(angle);
                    }
                } else {
                    angle = progress;
                }
                //sendRCCar();
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                // not used at the moment
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                // not used at the moment
            }
        });
    }

    /**
     * With the seek Bar one you be able to set the speed of the RC-Car.
     */
    private void directionBar(){
        dBar = (SeekBarVertical) findViewById(R.id.direction);
        dVField = (TextView) findViewById(R.id.direction_value);
        dBar.setMax(dValueMax);
        dBar.setProgress(dValueStart);
        dVField.setText(Integer.toString(dValueStart));
        dBar.setOnSeekBarChangeListener(new SeekBarVertical.OnSeekBarChangeListener() {
            // This method keep the Text Field under the Seek Bar up to date,
            // so that there is always the right value in the Text Field.
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                dVField.setText(progress + "");
                if (progress <= 9) {
                    if (progress == 0) {
                        direction = progress;
                        formatter = new DecimalFormat("00");
                        directionZero = formatter.format(direction);
                    } else {
                        direction = progress;
                        formatter = new DecimalFormat("0" + progress);
                        directionTen = formatter.format(direction);
                    }
                } else {
                    direction = progress;
                }
                //sendRCCar();
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                // not used at the moment
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                // not used at the moment
            }
        });
    }

}
