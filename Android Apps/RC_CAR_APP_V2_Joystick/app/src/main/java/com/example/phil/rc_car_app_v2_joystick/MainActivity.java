package com.example.phil.rc_car_app_v2_joystick;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import com.example.phil.rc_car_app_v2.R;

public class MainActivity extends Activity{
    Button b_connect, rc_control;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        b_connect = (Button) findViewById(R.id.bluetooth_connect);
        b_connect.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent inB = new Intent(MainActivity.this, Bluetooth.class);
                startActivity(inB);
            }
        });

        rc_control = (Button) findViewById(R.id.rc_car_control);
        rc_control.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent inRC = new Intent(MainActivity.this, RCCarControl.class);
                startActivity(inRC);
            }
        });
    }
}

