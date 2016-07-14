package com.example.phil.rc_car_app_v2_joystick;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import com.example.phil.rc_car_app_v2.R;

public class RCCarControl extends Activity {

    Button main;
    private TextView angleTextView;
    private TextView powerTextView;
    private TextView directionTextView;
    // Importing also other views
    private JoystickView joystick;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_rccarcontrol);

        main = (Button) findViewById(R.id.rc_main_menu);
        main.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent inM = new Intent(RCCarControl.this, MainActivity.class);
                startActivity(inM);
            }
        });

        angleTextView = (TextView) findViewById(R.id.angleTextView);
        powerTextView = (TextView) findViewById(R.id.powerTextView);
        directionTextView = (TextView) findViewById(R.id.directionTextView);
        //Referencing also other views
        joystick = (JoystickView) findViewById(R.id.joystickView);

        //Event listener that always returns the variation of the angle in degrees, motion power in percentage and direction of movement
        joystick.setOnJoystickMoveListener(new JoystickView.OnJoystickMoveListener() {

            @Override
            public void onValueChanged(int angle, int power, int direction) {
                // TODO Auto-generated method stub
                angleTextView.setText(" " + String.valueOf(angle) + "°");
                powerTextView.setText(" " + String.valueOf(power) + "%");
                switch (direction) {
                    case JoystickView.FRONT:
                        directionTextView.setText("front");
                        break;
                    case JoystickView.FRONT_RIGHT:
                        directionTextView.setText("front_right");
                        break;
                    case JoystickView.RIGHT:
                        directionTextView.setText("right");
                        break;
                    case JoystickView.RIGHT_BOTTOM:
                        directionTextView.setText("right_bottum");
                        break;
                    case JoystickView.BOTTOM:
                        directionTextView.setText("bottum");
                        break;
                    case JoystickView.BOTTOM_LEFT:
                        directionTextView.setText("bottum_left");
                        break;
                    case JoystickView.LEFT:
                        directionTextView.setText("left");
                        break;
                    case JoystickView.LEFT_FRONT:
                        directionTextView.setText("left_front");
                        break;
                    default:
                        directionTextView.setText("center");
                }
            }
        }, JoystickView.DEFAULT_LOOP_INTERVAL);
    }
}
