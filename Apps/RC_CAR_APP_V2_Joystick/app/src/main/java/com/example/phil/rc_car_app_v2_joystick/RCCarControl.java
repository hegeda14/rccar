package com.example.phil.rc_car_app_v2_joystick;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.Switch;
import android.widget.TextView;
import com.example.phil.rc_car_app_v2.R;

import java.text.DecimalFormat;

public class RCCarControl extends Activity {

    Button main;
    private Switch onOff;
    private TextView angleTextView;
    private TextView powerTextView;
    private TextView directionTextView;
    // Importing also other views
    private JoystickView joystick;
    private static DecimalFormat formatter;
    private static char directionChar = ' ';
    private static int aValue, direction, speed;
    private final char endOFCommand = 'E';
    // speedZero and angleZero have to be initialized like in the app,
    // because otherwise the value of angle is '0' and not '50'
    private static String angleZero = "50", directionZero = "00", speedZero = "00", angleTen, speedTen, directionTen, command;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_rccarcontrol);

        angleTextView = (TextView) findViewById(R.id.angleTextView);
        powerTextView = (TextView) findViewById(R.id.powerTextView);
        directionTextView = (TextView) findViewById(R.id.directionTextView);

        mainButton();
        joystickControl();
        switchListener();
    }

    private void mainButton(){
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
                    if(Bluetooth.blConnection == true){
                        command = "S00A00OE";
                        Bluetooth.sendData(command);
                    }else{powerTextView.setText("Bluetooth Connection is not available / on");}
                } else {
                    // switch off
                    command = "S00A00CE";
                    Bluetooth.sendData(command);
                }
            }
        });
    }

    private void joystickControl(){
        //Referencing also other views
        joystick = (JoystickView) findViewById(R.id.joystickView);

        //Event listener that always returns the variation of the angle in degrees, motion power in percentage and direction of movement
        joystick.setOnJoystickMoveListener(new JoystickView.OnJoystickMoveListener() {

            @Override
            public void onValueChanged(int angle, int power, int direction) {

                angleTextView.setText(" " + String.valueOf(angle) + "°");
                powerTextView.setText(" " + String.valueOf(power) + "%");

                //control of the speed value
                if (power <= 9) {
                    if (power == 0) {
                        speed = power;
                        formatter = new DecimalFormat("00");
                        speedZero = formatter.format(speed);
                    } else {
                        speed = power;
                        formatter = new DecimalFormat("0" + power);
                        speedTen = formatter.format(speed);
                    }
                } else if(power == 100){
                            speed = power - 1;
                        }else {
                            speed = power;
                        }

                switch (direction) {
                    case JoystickView.FRONT:
                        directionTextView.setText("front");
                        directionChar = 'F';
                        aValue = 50;
                        sendRCCar();
                        break;
                    case JoystickView.FRONT_RIGHT:
                        directionTextView.setText("front_right");
                        directionChar = 'F';
                        aValue = 75;
                        sendRCCar();
                        break;
                    case JoystickView.RIGHT:
                        directionTextView.setText("right");
                        directionChar = 'F';
                        aValue = 99;
                        sendRCCar();
                        break;
                    case JoystickView.RIGHT_BOTTOM:
                        directionTextView.setText("right_bottum");
                        directionChar = 'R';
                        aValue = 75;
                        sendRCCar();
                        break;
                    case JoystickView.BOTTOM:
                        directionChar = 'R';
                        directionTextView.setText("bottum");
                        aValue = 50;
                        sendRCCar();
                        break;
                    case JoystickView.BOTTOM_LEFT:
                        directionTextView.setText("bottum_left");
                        aValue = 25;
                        directionChar = 'R';
                        sendRCCar();
                        break;
                    case JoystickView.LEFT:
                        directionTextView.setText("left");
                        directionChar = 'F';
                        aValue = 0;
                        formatter = new DecimalFormat("00");
                        angleZero = formatter.format(aValue);
                        sendRCCar();
                        break;
                    case JoystickView.LEFT_FRONT:
                        directionTextView.setText("left_front");
                        directionChar = 'F';
                        aValue = 25;
                        sendRCCar();
                        break;
                    default:
                        directionTextView.setText("center");
                        command = "S00A50E";
                        if(Bluetooth.blConnection == true) {
                            Bluetooth.sendData(command);
                        }else{powerTextView.setText("Bluetooth Connection is not available / on");}
                }
            }
        }, JoystickView.DEFAULT_LOOP_INTERVAL);
    }

    /**
     * method to set the right command for the controlling of the rc car
     */
    private void sendRCCar(){
        if(directionChar != ' ' & Bluetooth.blConnection == true) {
            if(speed == 0){
                if(aValue == 0) {
                    command = "S" + speedZero + "A" + angleZero + directionChar + endOFCommand;
                }else if(aValue <= 9){
                    command = "S" + speedZero + "A" + angleTen + directionChar + endOFCommand;
                }else{
                    command = "S" + speedZero + "A" + aValue + directionChar + endOFCommand;
                }
            }else if(aValue == 0){
                if(speed == 0) {
                    command = "S" + speedZero + "A" + angleZero + directionChar + endOFCommand;
                }else if(speed <= 9){
                    command = "S" + speedTen + "A" + angleZero + directionChar + endOFCommand;
                } else{
                    command = "S" + speed + "A" + angleZero + directionChar + endOFCommand;
                }
            }else if(speed <= 9){
                if(aValue <= 9) {
                    command = "S" + speedTen + "A" + angleTen + directionChar + endOFCommand;
                }else{
                    command = "S" + speedTen + "A" + aValue + directionChar + endOFCommand;
                }
            }else if(aValue <= 9){
                if(speed <= 9) {
                    command = "S" + speedTen + "A" + angleTen + directionChar + endOFCommand;
                }else{
                    command = "S" + speed + "A" + angleTen + directionChar + endOFCommand;
                }
            }else{
                command = "S" + speed + "A" + aValue + directionChar + endOFCommand;
            }
            Bluetooth.sendData(command);
        }else{powerTextView.setText("Bluetooth Connection is not available / on");}
    }
}
