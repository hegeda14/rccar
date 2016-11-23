package com.example.phil.rc_car_app_v2;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.SeekBar;
import android.widget.Switch;
import android.widget.TextView;

import java.text.DecimalFormat;

public class RCCarControl extends Activity {

    private Button main;
    private Switch onOff;
    private SeekBarVertical dBar;
    private SeekBar aBar;
    private TextView sVField, dVField, aVField;
    private static int angle, speed;
    private static DecimalFormat formatter;
    private int dValueMax = 99, aValueMax = 99;
    private int dValueStart = 50, sValueStart = 50, aValueStart = 50;
    private static char directionChar = ' ';
    private final char endOFCommand = 'E';
    // speedZero and angleZero have to be initialized like in the app,
    // because otherwise the value of angle is '0' and not '50'
    private static String angleZero = "50", speedZero = "00", angleTen, speedTen, command;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_rccarcontrol);

        mainButtonControl();
        angleBar();
        directionBar();
        switchListener();
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
                sendRCCar();
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
        dVField.setText(Integer.toString(dValueStart - 50));

        sVField = (TextView) findViewById(R.id.speed_value);
        sVField.setText(Integer.toString(sValueStart - 50));

        dBar.setOnSeekBarChangeListener(new SeekBarVertical.OnSeekBarChangeListener() {
            // This method keep the Text Field under the Seek Bar up to date,
            // so that there is always the right value in the Text Field.
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (progress > 50) {
                    progress = progress - 50;
                    directionChar = 'F';
                    dVField.setText("F");
                } else {
                    progress = (progress - 50) * -1;
                    directionChar = 'R';
                    dVField.setText("R");
                }

                if (progress <= 9) {
                    if (progress == 0 & progress <= 5) {
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

                sVField.setText(progress + "");
                sendRCCar();
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
     * Switch, witch connects the device (where the the android app run)
     * with the RC-Car to be able to send specific data.
     */
    private void switchListener() {
        onOff = (Switch) findViewById(R.id.switch2);
        // attach a listener to check for changes in state
        onOff.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    // switch on
                    if(Bluetooth.blConnection == true) {
                        command = "S00A00OE";
                        Bluetooth.sendData(command);
                    }else{aVField.setText("Bluetooth Connection is not available / on");}
                } else {
                    // switch off
                    command = "S00A00CE";
                    Bluetooth.sendData(command);
                }
            }
        });
    }

    /**
     * method to set the right command for the controlling of the rc car
     */
    private void sendRCCar(){
        if(directionChar != ' ' & Bluetooth.blConnection == true) {
            if(speed == 0 | speed <= 5){
                if(angle == 0) {
                    command = "S" + speedZero + "A" + angleZero + directionChar + endOFCommand;
                }else if(angle <= 9){
                    command = "S" + speedZero + "A" + angleTen + directionChar + endOFCommand;
                }else{
                    command = "S" + speedZero + "A" + angle + directionChar + endOFCommand;
                }
            }else if(angle == 0){
                if(speed == 0 | speed <= 5) {
                    command = "S" + speedZero + "A" + angleZero + directionChar + endOFCommand;
                }else if(speed <= 9 & speed > 5){
                    command = "S" + speedTen + "A" + angleZero + directionChar + endOFCommand;
                } else{
                    command = "S" + speed + "A" + angleZero + directionChar + endOFCommand;
                }
            }else if(speed <= 9 & speed > 5){
                if(angle <= 9) {
                    command = "S" + speedTen + "A" + angleTen + directionChar + endOFCommand;
                }else{
                    command = "S" + speedTen + "A" + angle + directionChar + endOFCommand;
                }
            }else if(angle <= 9){
                if(speed <= 9 & speed > 5) {
                    command = "S" + speedTen + "A" + angleTen + directionChar + endOFCommand;
                }else{
                    command = "S" + speed + "A" + angleTen + directionChar + endOFCommand;
                }
            }else{
                command = "S" + speed + "A" + angle + directionChar + endOFCommand;
            }
            Bluetooth.sendData(command);
        }else{aVField.setText("Bluetooth Connection is not available / on");}
    }

}
