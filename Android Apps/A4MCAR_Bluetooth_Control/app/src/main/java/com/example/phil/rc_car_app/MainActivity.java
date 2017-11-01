/*
 * Copyright (c) 2017 Eclipse Foundation and FH Dortmund.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    A4MCAR Project - Android Application Main Activity
 *
 * Authors:
 *    originally created by Phil Naerdemann, Fachhochschule Dortmund
 *    new version Joystick, deadzone, communication updates by M. Ozcelikors <mozcelikors@gmail.com>, Fachhochschule Dortmund
 *
 * Update History:
 *
 */

package com.example.phil.rc_car_app;

import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.SystemClock;
import android.support.design.widget.Snackbar;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.GestureDetectorCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.GestureDetector;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.SeekBar;
import android.widget.SimpleAdapter;
import android.widget.TextView;
import android.widget.Toast;

import com.sccomponents.gauges.ScArcGauge;
import com.sccomponents.gauges.ScGauge;

import java.io.IOException;
import java.io.OutputStream;
import java.lang.reflect.Method;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import io.github.controlwear.virtual.joystick.android.JoystickView;

import static com.example.phil.rc_car_app.R.string.activateBluetooth;

class BluetoothState {
    private boolean isBluetoothOn = false;
    private ChangeListener changeListener;

    public boolean get() {
        return isBluetoothOn;
    }

    public void set(boolean isBluetoothOn) {
        if(this.isBluetoothOn == isBluetoothOn) return;
        this.isBluetoothOn = isBluetoothOn;
        if (changeListener != null) changeListener.onChange();
    }

    public ChangeListener getListener() {
        return changeListener;
    }

    public void setListener(ChangeListener changeListener) {
        this.changeListener = changeListener;
    }

    public interface ChangeListener {
        void onChange();
    }
}

public class MainActivity extends AppCompatActivity {
    private ListView myListView;
    private BluetoothSocket myBluetoothSocket;
    private BluetoothAdapter myBluetoothAdapter;
    private Set<BluetoothDevice> pairedDevices;
    private SeekBar sBar2;
    private SeekBarVertical verticalSB;
    private static TextView speedValueField, angleValueField;
    public static TextView connectionView;
    private static OutputStream outStream = null;
    private int speedValueMax = 99, angleValueMax = 99;
    private int speedValueStart = 0, angleValueStart = 50;
    private BluetoothState isBluetoothOn = null;
    private static final int BLUETOOTH_ON = 1;
    private static DecimalFormat formatter;
    private static char direction = 'F';
    private static int angle, speed;
    private static int last_angle = 50, last_speed = 0;
    // speedZero and angleZero have to be initialized like in the app,
    // because otherwise the value of angle is '0' and not '50'
    private static String speedZero = "00", angleZero = "50", speedTen, angleTen, command;
    private static final char endOFCommand = 'E';
    // SPP UUID service
    private static final UUID myUUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");
    ImageView image;

    private Snackbar infoMessageSnack = null;
    private Snackbar errorMessageSnack = null;
    private Snackbar activateBluetoothSnack = null;

    private String[] menuTitles;
    private ListView menuList;

    private GestureDetectorCompat mDetector;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        initializeBaseics();
        initializeBluetooth();
        initializeGauges();
        initializeJoystick();
    }

    private void initializeBaseics() {
        // Initialization for the toolbar
        Toolbar myToolbar = (Toolbar) findViewById(R.id.my_toolbar);
        setSupportActionBar(myToolbar);
        // Initialization for the navigation drawer element (right sidebar)
        menuTitles = getResources().getStringArray(R.array.menuArray);
        menuList = (ListView)findViewById(R.id.left_drawer);
        // Set the adapter for the list view
        menuList.setAdapter(new ArrayAdapter<String>(this, R.layout.drawer_list_item, menuTitles));
        // Set the list's click listener
        menuList.setOnItemClickListener(new DrawerItemClickListener());
        // Disable the list at startup
        menuList.setEnabled(false);
        // The default init state: Bluetooth turned OFF, show the alert snack
        ((ImageButton)findViewById(R.id.connectButton)).setImageResource(R.drawable.ic_bluetooth_off_white_36dp);
        activateBluetoothSnack = Snackbar.make(findViewById(R.id.drawer_layout), activateBluetooth, Snackbar.LENGTH_INDEFINITE);
        activateBluetoothSnack.getView().setBackgroundColor(ContextCompat.getColor(getApplicationContext(), R.color.materialRed500));
        activateBluetoothSnack.show();
        // Snack for info messages
        infoMessageSnack = Snackbar.make(findViewById(R.id.drawer_layout), null, Snackbar.LENGTH_LONG);
        infoMessageSnack.getView().setBackgroundColor(ContextCompat.getColor(getApplicationContext(), R.color.materialBlue500));
        // Snack for error messages
        errorMessageSnack = Snackbar.make(findViewById(R.id.drawer_layout), null, Snackbar.LENGTH_LONG);
        errorMessageSnack.getView().setBackgroundColor(ContextCompat.getColor(getApplicationContext(), R.color.materialRed500));
    }

    private void initializeBluetooth() {
        // Get the default bluetooth adapter and it's state
        myBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        // Observe the state change of the bluetooth adapter
        isBluetoothOn = new BluetoothState();
        isBluetoothOn.setListener(new BluetoothState.ChangeListener() {
            @Override
            public void onChange() {
                if(isBluetoothOn.get()) {
                    ((ImageButton)findViewById(R.id.connectButton)).setImageResource(R.drawable.ic_bluetooth_white_36dp);
                    findViewById(R.id.joystickView).setEnabled(true);
                    menuList.setEnabled(true);
                    activateBluetoothSnack.dismiss();
                } else {
                    ((ImageButton)findViewById(R.id.connectButton)).setImageResource(R.drawable.ic_bluetooth_off_white_36dp);
                    findViewById(R.id.joystickView).setEnabled(false);
                    menuList.setEnabled(false);
                    activateBluetoothSnack.show();
                }
            }
        });
        // Always inspect the adapter's state in an anonymous thread
        new Thread(new Runnable() {
            @Override
            public void run() {
                while(true) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            isBluetoothOn.set(myBluetoothAdapter.isEnabled());
                        }
                    });
                    SystemClock.sleep(500);
                }
            }
        }).start();

        // Listener for the bluetooth button
        (findViewById(R.id.connectButton)).setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if(event.getAction() == MotionEvent.ACTION_DOWN) {
                    if (!isBluetoothOn.get()) {
                        Intent turnBluetoothOn = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
                        startActivityForResult(turnBluetoothOn, BLUETOOTH_ON);
                    } else {
                        myBluetoothAdapter.disable();
                    }
                }
                return false;
            }
        });
    }

    private void initializeGauges() {

        // Find the components
        final ScArcGauge speedoMeter = (ScArcGauge)this.findViewById(R.id.speedoMeter);
        assert speedoMeter != null;
        final TextView speedoMeterCounter = (TextView)this.findViewById(R.id.speedoMeterCounter);
        assert speedoMeterCounter != null;
        // As the progress feature by default the last to be draw I must bring the notches feature on top.
        speedoMeter.bringOnTop(ScGauge.NOTCHES_IDENTIFIER);
        // If you set the value from the xml that not produce an event so I will change the value from code.
        speedoMeter.setHighValue(0);
        // Each time I will change the value I must write it inside the counter text.
        speedoMeter.setOnEventListener(new ScGauge.OnEventListener() {
            @Override
            public void onValueChange(float lowValue, float highValue) {
                // Write the value
                int value = (int)ScGauge.percentageToValue(highValue, 0.0f, 100.0f);
                speedoMeterCounter.setText(value + "");
            }
        });

        // Find the components
        final ScArcGauge angleMeter = (ScArcGauge)this.findViewById(R.id.angleMeter);
        assert angleMeter != null;
        final TextView angleMeterCounter = (TextView)this.findViewById(R.id.angleMeterCounter);
        assert angleMeterCounter != null;
        // As the progress feature by default the last to be draw I must bring the notches feature on top.
        angleMeter.bringOnTop(ScGauge.NOTCHES_IDENTIFIER);
        // If you set the value from the xml that not produce an event so I will change the value from code.
        angleMeter.setHighValue(50);
        // Each time I will change the value I must write it inside the counter text.
        angleMeter.setOnEventListener(new ScGauge.OnEventListener() {
            @Override
            public void onValueChange(float lowValue, float highValue) {
                // Write the value
                int value = (int)ScGauge.percentageToValue(highValue, 0.0f, 100.0f);
                angleMeterCounter.setText(value + "");
            }
        });
    }

    private void initializeJoystick() {
        final ScArcGauge speedoMeter = (ScArcGauge)this.findViewById(R.id.speedoMeter);
        final ScArcGauge angleMeter = (ScArcGauge)this.findViewById(R.id.angleMeter);

        JoystickView joystick = (JoystickView) findViewById(R.id.joystickView);
        joystick.setButtonDrawable(ContextCompat.getDrawable(getApplicationContext(), R.drawable.ic_arrow_up_bold_circle_black));
        joystick.setEnabled(false);

        mDetector = new GestureDetectorCompat(getApplicationContext(), new GestureDetector.SimpleOnGestureListener(){
            @Override
            public boolean onDoubleTap(MotionEvent e) {
                changeDirection();
                return true;
            }
        });

        joystick.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                return mDetector.onTouchEvent(event);
            }
        });

        joystick.setOnMoveListener(new JoystickView.OnMoveListener() {
            @Override
            public void onMove(int retrieved_angle, int retrieved_speed)
            {
                if (retrieved_speed > 99)
                    retrieved_speed = 99;

                angleMeter.setHighValue(angle);

                if(retrieved_speed <= 9) {
                    if(retrieved_speed == 0) {
                        speed = retrieved_speed;
                        formatter = new DecimalFormat("00");
                        speedZero = formatter.format(speed);
                    }else {
                        speed = retrieved_speed;
                        formatter = new DecimalFormat("0" + retrieved_speed);
                        speedTen = formatter.format(speed);
                    }
                }else{
                    speed = retrieved_speed;
                }

                if (retrieved_angle >= 0 && retrieved_angle <= 180)
                {
                    if (retrieved_angle >= 0 && retrieved_angle <= 30) {
                        retrieved_angle = 99;
                        //direction = 'F';
                    } else if (retrieved_angle > 30 && retrieved_angle < 150) {
                        retrieved_angle = (int) ((1 - ((retrieved_angle - 30) / 120.0)) * 100); //((150-retrieved_angle)/120)*100
                        //direction = 'F';
                    } else if (retrieved_angle >= 150 && retrieved_angle <= 180) {
                        retrieved_angle = 0;
                        //direction = 'F';
                    }
                    if (direction == 'R')
                    {
                        speed = 0;
                    }
                }
                else
                {
                    if (retrieved_angle>180 && retrieved_angle<=210)
                    {
                        retrieved_angle = 0;
                        //direction = 'R';
                    }
                    else if (retrieved_angle>210 && retrieved_angle<330)
                    {
                        retrieved_angle = (int) (((retrieved_angle-210)/120.0) * 100);
                        //direction = 'R';
                    }
                    else if (retrieved_angle>=330 && retrieved_angle<=360)
                    {
                        retrieved_angle = 99;
                        //direction = 'R';
                    }
                    if (direction == 'F')
                    {
                        speed = 0;
                    }
                }

                speedoMeter.setHighValue(speed);

                if (retrieved_angle > 99)
                    retrieved_angle = 99;

                if (retrieved_speed > 99)
                    retrieved_speed = 99;

                if (retrieved_speed == 0)
                {
                    retrieved_angle = 50;
                }

                if (retrieved_angle <= 9)
                {
                    if (retrieved_angle == 0) {
                        angle = retrieved_angle;
                        formatter = new DecimalFormat("00");
                        angleZero = formatter.format(angle);
                    } else {
                        angle = retrieved_angle;
                        formatter = new DecimalFormat("0" + retrieved_angle);
                        angleTen = formatter.format(angle);
                    }
                } else {
                    angle = retrieved_angle;
                }

                if (Math.abs(last_angle-angle) > 8 || Math.abs(last_speed - speed) > 8)
                {
                    last_angle = angle;
                    last_speed = speed;
                    //Log.d("Sent","sent");

                    new Thread(new Runnable() {
                        @Override
                        public void run() {
                            sendRCCar();
                        }
                    }).start();
                }
            }
        });
    }

    private class DrawerItemClickListener implements ListView.OnItemClickListener {
        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
            // Highlight the selected item, update the title, and close the drawer
            menuList.setItemChecked(position, false);
            //Toast.makeText(getApplicationContext(), menuTitles[position], Toast.LENGTH_SHORT).show();
            ((DrawerLayout)findViewById(R.id.drawer_layout)).closeDrawer(Gravity.LEFT);

            FragmentManager fragmentManager = getFragmentManager();
            final BluetoothAddressList list = new BluetoothAddressList();


            if (fragmentManager.findFragmentById(android.R.id.content) == null) {

                FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
                fragmentTransaction.setCustomAnimations(android.R.animator.fade_in, android.R.animator.fade_out);
                fragmentTransaction.add(android.R.id.content, list);
                fragmentTransaction.commit();
                getSupportFragmentManager().executePendingTransactions();

                //fragmentTransaction.remove(fragmentManager.findFragmentByTag("Note"));


            }

            if(position == 0) {
                pairedDevices = myBluetoothAdapter.getBondedDevices();


                ArrayList<HashMap<String,String>> pairedDevicesList = new ArrayList<>();

                HashMap<String,String> item;
                for (BluetoothDevice device : pairedDevices) {
                    item = new HashMap<>();
                    item.put( "name", device.getName());
                    item.put( "address", device.getAddress());
                    pairedDevicesList.add( item );
                }

                final ListAdapter adapter =  new SimpleAdapter(getApplicationContext(), pairedDevicesList,
                        android.R.layout.simple_list_item_2,
                        new String[] { "name","address" },
                        new int[] {android.R.id.text1, android.R.id.text2});

                list.fillListView(adapter);


            } else {


                myBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
                myBluetoothAdapter.startDiscovery();

                final ArrayList<HashMap<String,String>> scannedDevicesList = new ArrayList<>();

                // Register the BroadcastReceiver
                IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
                registerReceiver(new BroadcastReceiver() {
                    public void onReceive(Context context, Intent intent) {
                        String action = intent.getAction();
                        // When discovery finds a device
                        if (BluetoothDevice.ACTION_FOUND.equals(action)) {

                            // Get the BluetoothDevice object from the Intent
                            BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                            // Add the name and address to an array adapter to show in a ListView
                            //myBluetoothDeviceList.add(device.getName() + "\n" + device.getAddress());
                            //adapter.setAdapter(new ArrayAdapter<String>(context, android.R.layout.simple_list_item_1, myBluetoothDeviceList));

                            HashMap<String,String> item = new HashMap<>();
                            item.put( "name", device.getName());
                            item.put( "address", device.getAddress());
                            scannedDevicesList.add( item );

                            final ListAdapter adapter =  new SimpleAdapter(getApplicationContext(), scannedDevicesList,
                                    android.R.layout.simple_list_item_2,
                                    new String[] { "name","address" },
                                    new int[] {android.R.id.text1, android.R.id.text2});

                            list.fillListView(adapter);


                        }
                    }
                }, filter);

            }
        }
    }


    private void changeDirection() {
        JoystickView joystick = (JoystickView) findViewById(R.id.joystickView);
        if(direction == 'F') {
            direction = 'R';
            joystick.setButtonDrawable(ContextCompat.getDrawable(getApplicationContext(), R.drawable.ic_arrow_down_bold_circle_black));
        } else {
            direction = 'F';
            joystick.setButtonDrawable(ContextCompat.getDrawable(getApplicationContext(), R.drawable.ic_arrow_up_bold_circle_black));
        }

        new Thread(new Runnable() {
            @Override
            public void run() {
                sendRCCar();
            }
        }).start();
    }



    @Override
    protected void onDestroy() {
        //unregisterReceiver(mReceiver);
        try {
            myBluetoothSocket.close();
        } catch (Exception e) {
        }
        super.onDestroy();
    }

    @Override
    public void onBackPressed() {

        FragmentManager fragmentManager = getFragmentManager();

        if (fragmentManager.findFragmentById(android.R.id.content) != null) {

            FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
            fragmentTransaction.setCustomAnimations(android.R.animator.fade_in, android.R.animator.fade_out);
            fragmentTransaction.remove(fragmentManager.findFragmentById(android.R.id.content));
            fragmentTransaction.commit();
            fragmentManager.executePendingTransactions();
        } else {

            super.onBackPressed();
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        /*if (requestCode == BLUETOOTH_ON) {
            if (resultCode == RESULT_OK) {
                Toast.makeText(getApplicationContext(), "Turned bluetooth on", Toast.LENGTH_LONG).show();
                connectionView.setText("Bluetooth is on.");
                isBluetoothOn.set(true);
                getBluetoothDevices();
            }
        }*/
    }

    /**
     * Switch, witch connects the device (where the the android app run)
     * with the RC-Car to be able to send specific data.
     */
    /*private void switchListener() {
        bluetoothConnect = (Switch) findViewById(R.id.connect);
        // attach a listener to check for changes in state
        bluetoothConnect.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    // switch bluetooth on
                    bluetoothOn(buttonView);
                    if (isBluetoothOn.get() == true) {
                        visible(buttonView);
                        connectionView.setText("Bluetooth is on.");
                    }
                } else {
                    // switch bluetooth off
                    bluetoothOff(buttonView);
                    if (isBluetoothOn.get() == false) {
                        connectionView.setText("Bluetooth is off.");
                    }
                }
            }
        });
    }*/


    /**
     * method bluetoothOff deactivates the bluetooth Connection
     * @param view
     */
    /*private void bluetoothOff(View view) {
        myBluetoothAdapter.disable();
        Toast.makeText(getApplicationContext(), "Turned bluetooth off", Toast.LENGTH_LONG).show();
        isBluetoothOn.set(false);
        myBluetoothDeviceList.clear();
    }*/

    /**
     * method to show a list of all paired bluetooth devices
     * @param view
     */
    private void bluetoothPairedList(View view) {
        pairedDevices = myBluetoothAdapter.getBondedDevices();
        ArrayList list = new ArrayList();

        for (BluetoothDevice bt : pairedDevices)
            list.add(bt.getName());
        Toast.makeText(getApplicationContext(), "Showing Paired Devices", Toast.LENGTH_SHORT).show();

        final ArrayAdapter adapter = new ArrayAdapter(this, android.R.layout.simple_list_item_1, list);
        myListView.setAdapter(adapter);
    }
    

    /**
     * Connect to the specified bluetooth address with the predefined method
     * @param bluetoothAddress
     * @return
     * @throws Exception
     */

    protected boolean connectBluetoothDevice(String bluetoothAddress) {

        try {
            if (myBluetoothAdapter.isDiscovering()) {
                myBluetoothAdapter.cancelDiscovery();
            }

            BluetoothDevice remoteBluetoothDevice = myBluetoothAdapter.getRemoteDevice(bluetoothAddress);
            myBluetoothSocket = createRfcommSocket(remoteBluetoothDevice);


            myBluetoothSocket.connect();
            outStream = myBluetoothSocket.getOutputStream();

            messageFromThread("INFO", "Connected to " + remoteBluetoothDevice);

            return true;

        } catch (Exception open_exception) {
            try {
                Log.v("ERROR", open_exception.getMessage());
                messageFromThread("ERROR", "Bluetooth connection failed!");
                myBluetoothSocket.close();
            } catch (Exception close_exception) {
                Log.v("ERROR", close_exception.getMessage());
            }
        }

        return false;
    }


    /**
     * Method to create a Bluetooth createRfcommSocket socket
     * @param bluetoothDevice
     * @return
     * @throws IOException
     */
    private BluetoothSocket createRfcommSocket(BluetoothDevice bluetoothDevice) throws IOException {
        try {
            final Method m = bluetoothDevice.getClass().getMethod("createRfcommSocket", new Class[]{int.class});
            return (BluetoothSocket) m.invoke(bluetoothDevice, 1);
        } catch (Exception exception) {
            Log.v("ERROR", exception.getMessage());
            Toast.makeText(getApplicationContext(), "Could not create RFComm Connection", Toast.LENGTH_SHORT).show();
        }
        //return device.createRfcommSocketToServiceRecord(myUUID);
        return null;
    }

    /**
     * Method to create a Bluetooth createInsecureRfcommSocketToServiceRecord socket
     * @param bluetoothDevice
     * @return
     * @throws IOException
     */
    private BluetoothSocket createInsecureRfcommSocket(BluetoothDevice bluetoothDevice) throws IOException {
        try {
            final Method m = bluetoothDevice.getClass().getMethod("createInsecureRfcommSocketToServiceRecord", new Class[]{UUID.class});
            return (BluetoothSocket) m.invoke(bluetoothDevice, myUUID);
        } catch (Exception exception) {
            Log.v("ERROR", exception.getMessage());
            Toast.makeText(getApplicationContext(), "Could not create Insecure RFComm Connection", Toast.LENGTH_SHORT).show();
        }
        //return device.createRfcommSocketToServiceRecord(myUUID);
        return null;
    }






    /**
     * Create a BroadcastReceiver for ACTION_FOUND
     */
    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            // When discovery finds a device
            if (BluetoothDevice.ACTION_FOUND.equals(action)) {
                // Get the BluetoothDevice object from the Intent
                BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                // Add the name and address to an array adapter to show in a ListView
                /*myBluetoothDeviceList.add(device.getName() + "\n" + device.getAddress());
                myListView.setAdapter(new ArrayAdapter<String>(context,
                        android.R.layout.simple_list_item_1, myBluetoothDeviceList));*/
            }
        }
    };

    /**
     * method to set the right command for the controlling of the rc car
     */
    private void sendRCCar(){
        if(direction != ' ') {
            if(speed == 0){
                if(angle == 0) {
                    command = "S" + speedZero + "A" + angleZero + direction + endOFCommand;
                }else if(angle <= 9){
                    command = "S" + speedZero + "A" + angleTen + direction + endOFCommand;
                }else{
                    command = "S" + speedZero + "A" + angle + direction + endOFCommand;
                }
            }else if(angle == 0){
                if(speed == 0) {
                    command = "S" + speedZero + "A" + angleZero + direction + endOFCommand;
                }else if(speed <= 9){
                    command = "S" + speedTen + "A" + angleZero + direction + endOFCommand;
                } else{
                    command = "S" + speed + "A" + angleZero + direction + endOFCommand;
                }
            }else if(speed <= 9){
                if(angle <= 9) {
                    command = "S" + speedTen + "A" + angleTen + direction + endOFCommand;
                }else{
                    command = "S" + speedTen + "A" + angle + direction + endOFCommand;
                }
            }else if(angle <= 9){
                if(speed <= 9) {
                    command = "S" + speedTen + "A" + angleTen + direction + endOFCommand;
                }else{
                    command = "S" + speed + "A" + angleTen + direction + endOFCommand;
                }
            }else{
                command = "S" + speed + "A" + angle + direction + endOFCommand;
            }
            sendData(command);
        }else{

        }
    }

    /**
     * Send data to the RC-Car
     * @param message
     */
    public void sendData(String message) {
        char[] msgBuffer = message.toCharArray();
        if (outStream != null) {
            try {
                for(char c : msgBuffer) {
                    outStream.write(c);
                    TimeUnit.MILLISECONDS.sleep(10);
                }
                outStream.flush();
            } catch (Exception e) {}
        } else {
            messageFromThread("ERROR", command + " - outStream is Null.");
        }
    }

    private void messageFromThread(final String type, final String message) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                switch(type){
                    case "ERROR": {
                        errorMessageSnack.setText(message);
                        errorMessageSnack.show();
                    } break;
                    case "INFO": {
                        infoMessageSnack.setText(message);
                        infoMessageSnack.show();
                    }
                    default: break;
                }
            }
        });
    }

    /**
     * method to make the bluetooth device for 120 seconds visible for other bluetooth devices
     * @param view
     */
    /*private void visible(View view) {
        Intent getVisible = new Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE);
        startActivityForResult(getVisible, 0);
    }*/

}