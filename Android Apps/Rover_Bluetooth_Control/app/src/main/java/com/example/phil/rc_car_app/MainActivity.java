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
 *    full redesign, improved layout and operation by Attila Hegedüs <hegedus.attila.1992@gmail.com>, Fachhochschule Dortmund
 *
 * Update History:
 *
 */

package com.example.phil.rc_car_app;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.ContextCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.TextView;

import com.sccomponents.gauges.ScArcGauge;
import com.sccomponents.gauges.ScGauge;

import java.io.IOException;
import java.io.OutputStream;
import java.lang.reflect.Method;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.UUID;

import io.github.controlwear.virtual.joystick.android.JoystickView;

class BluetoothState {

    private boolean isBluetoothOn = false;
    private boolean isBluetoothConnected = false;

    private ChangeListener changeListener;
    public BroadcastReceiver stateChangedReceiver;

    public boolean getIsBluetoothOn() {
        return isBluetoothOn;
    }

    public void setIsBluetoothOn(boolean isBluetoothOn) {
        if(this.isBluetoothOn == isBluetoothOn) return;
        this.isBluetoothOn = isBluetoothOn;
        if (changeListener != null) changeListener.onChange();
    }

    public boolean getIsBluetoothConnected() {
        return isBluetoothConnected;
    }

    public void setIsBluetoothConnected(boolean isBluetoothConnected) {
        if(this.isBluetoothConnected == isBluetoothConnected) return;
        this.isBluetoothConnected = isBluetoothConnected;
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

    private static final int speedValueMax = 99, angleValueMax = 99;
    private static final int speedValueStart = 0, angleValueStart = 50;

    // End of command marker
    private static final char endOFCommand = 'E';
    // SPP UUID service
    private static final UUID myUUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");
    // Necessary for the Bluetooth starting Activity
    private static final int BLUETOOTH_ON = 1;

    // Global Bluetooth handler variables
    private BluetoothSocket bluetoothSocket = null;
    private BluetoothAdapter bluetoothAdapter = null;
    private BluetoothState bluetoothState = null;
    public int connectionMethod = R.id.radioButton;

    // GUI Snack elements
    private Snackbar infoMessageSnack = null;
    private Snackbar errorMessageSnack = null;
    private Snackbar connectBluetoothSnack = null;
    private Snackbar activateBluetoothSnack = null;

    private ListView menuList = null;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        initializeBasics();
        initializeGauges();
        initializeJoystick();
        initializeBluetooth();
    }

    private void initializeBasics() {
        // Modify the orientation dependent parameters
        orientationConfig(this.getResources().getConfiguration().orientation);
        // Load back the saved settings
        SharedPreferences settings = getPreferences(MODE_PRIVATE);
        connectionMethod = settings.getInt(getResources().getString(R.string.setting1), R.id.radioButton);
        // Initialization for the toolbar
        Toolbar myToolbar = (Toolbar) findViewById(R.id.my_toolbar);
        setSupportActionBar(myToolbar);
        // Initialization for the navigation drawer element (right sidebar)
        String[] menuTitles = getResources().getStringArray(R.array.menuArray);
        menuList = (ListView)findViewById(R.id.left_drawer);
        // Set the adapter for the list view
        menuList.setAdapter(new ArrayAdapter<>(this, R.layout.drawer_list_item, menuTitles));
        // Set the list's click listener
        menuList.setOnItemClickListener(new DrawerItemClickListener());
        // Disable the list at startup
        menuList.setEnabled(false);
        // The default init state: Bluetooth turned OFF, show the alert snack
        ((ImageButton)findViewById(R.id.connectButton)).setImageResource(R.drawable.ic_bluetooth_off_white_36dp);
        activateBluetoothSnack = Snackbar.make(findViewById(R.id.drawer_layout), R.string.activateBluetooth, Snackbar.LENGTH_INDEFINITE);
        activateBluetoothSnack.getView().setBackgroundColor(ContextCompat.getColor(getApplicationContext(), R.color.materialRed500));
        activateBluetoothSnack.show();
        // Alert snack to show the disconnected state
        connectBluetoothSnack = Snackbar.make(findViewById(R.id.drawer_layout), R.string.connectBluetooth, Snackbar.LENGTH_INDEFINITE);
        connectBluetoothSnack.getView().setBackgroundColor(ContextCompat.getColor(getApplicationContext(), R.color.materialBlue500));
        // Snack for info messages
        infoMessageSnack = Snackbar.make(findViewById(R.id.drawer_layout), null, Snackbar.LENGTH_LONG);
        infoMessageSnack.getView().setBackgroundColor(ContextCompat.getColor(getApplicationContext(), R.color.materialBlue500));
        // Snack for error messages
        errorMessageSnack = Snackbar.make(findViewById(R.id.drawer_layout), null, Snackbar.LENGTH_LONG);
        errorMessageSnack.getView().setBackgroundColor(ContextCompat.getColor(getApplicationContext(), R.color.materialRed500));
    }

    private void initializeBluetooth() {
        // Get the default bluetooth adapter and it's state
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        // Observe the state change of the bluetooth adapter
        bluetoothState = new BluetoothState();
        bluetoothState.setListener(new BluetoothState.ChangeListener() {
            @Override
            public void onChange() {
                if(bluetoothState.getIsBluetoothOn()) {
                    ((ImageButton)findViewById(R.id.connectButton)).setImageResource(R.drawable.ic_bluetooth_white_36dp);
                    findViewById(R.id.joystickView).setEnabled(true);
                    menuList.setEnabled(true);
                    activateBluetoothSnack.dismiss();
                    // Show if we connected to a remote device
                    if(bluetoothState.getIsBluetoothConnected()) {
                        ((ImageButton)findViewById(R.id.connectButton)).setImageResource(R.drawable.ic_bluetooth_connect_white_36dp);
                        connectBluetoothSnack.dismiss();
                    } else {
                        ((ImageButton)findViewById(R.id.connectButton)).setImageResource(R.drawable.ic_bluetooth_white_36dp);
                    }
                } else {
                    ((ImageButton)findViewById(R.id.connectButton)).setImageResource(R.drawable.ic_bluetooth_off_white_36dp);
                    findViewById(R.id.joystickView).setEnabled(false);
                    menuList.setEnabled(false);
                    connectBluetoothSnack.dismiss();
                    activateBluetoothSnack.show();
                }
            }
        });

        bluetoothState.setIsBluetoothOn(bluetoothAdapter.isEnabled());

        // Adapter state change listener
        IntentFilter filterStateChanged = new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED);
        registerReceiver(bluetoothState.stateChangedReceiver = new BroadcastReceiver() {
            public void onReceive(Context context, Intent intent) {
                if (BluetoothAdapter.ACTION_STATE_CHANGED.equals(intent.getAction())) {
                    bluetoothState.setIsBluetoothOn(bluetoothAdapter.isEnabled());
                }
            }
        }, filterStateChanged);
        // Adapter connection change listener
        IntentFilter filterConnectionChanged = new IntentFilter();
        filterConnectionChanged.addAction(BluetoothDevice.ACTION_ACL_CONNECTED);
        filterConnectionChanged.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED);
        registerReceiver(new BroadcastReceiver() {
            public void onReceive(Context context, Intent intent) {
                if (BluetoothDevice.ACTION_ACL_CONNECTED.equals(intent.getAction())) {
                    bluetoothState.setIsBluetoothConnected(true);
                } else if (BluetoothDevice.ACTION_ACL_DISCONNECTED.equals(intent.getAction())) {
                    bluetoothState.setIsBluetoothConnected(false);
                    messageFromGUI("ERROR", getResources().getString(R.string.connectionLost));
                }
            }
        }, filterConnectionChanged);
        // Listener for the bluetooth button
        (findViewById(R.id.connectButton)).setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if(event.getAction() == MotionEvent.ACTION_DOWN) {
                    if (!bluetoothState.getIsBluetoothOn()) {
                        Intent turnBluetoothOn = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
                        startActivityForResult(turnBluetoothOn, BLUETOOTH_ON);
                    } else {
                        bluetoothAdapter.disable();
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
        speedoMeter.setHighValue(speedValueStart);
        // Each time I will change the value I must write it inside the counter text.
        speedoMeter.setOnEventListener(new ScGauge.OnEventListener() {
            @Override
            public void onValueChange(float lowValue, float highValue) {
                // Write the value
                int value = (int)ScGauge.percentageToValue(highValue, 0.0f, 100.0f);
                speedoMeterCounter.setText(Integer.toString(value));
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
        angleMeter.setHighValue(angleValueStart);
        // Each time I will change the value I must write it inside the counter text.
        angleMeter.setOnEventListener(new ScGauge.OnEventListener() {
            @Override
            public void onValueChange(float lowValue, float highValue) {
                // Write the value
                int value = (int)ScGauge.percentageToValue(highValue, 0.0f, 100.0f);
                angleMeterCounter.setText(Integer.toString(value));
            }
        });
    }

    private void initializeJoystick() {
        final ScArcGauge speedoMeter = (ScArcGauge)this.findViewById(R.id.speedoMeter);
        final ScArcGauge angleMeter = (ScArcGauge)this.findViewById(R.id.angleMeter);

        JoystickView joystick = (JoystickView) findViewById(R.id.joystickView);
        joystick.setEnabled(false);

        joystick.setOnMoveListener(new JoystickView.OnMoveListener() {
            // Just remember to the previous values
            private int last_angle = angleValueStart, last_speed = speedValueStart;
            @Override
            public void onMove(int retrieved_angle, int retrieved_speed)
            {
                // Set the direction, based on the angle's value
                final String direction;
                if(retrieved_angle >= 180) direction = "R";
                else direction = "F";

                if (retrieved_angle >= 0 && retrieved_angle <= 180)
                {
                    if (retrieved_angle >= 0 && retrieved_angle <= 30) {
                        retrieved_angle = angleValueMax;
                        //direction = 'F';
                    } else if (retrieved_angle > 30 && retrieved_angle < 150) {
                        retrieved_angle = (int) ((1 - ((retrieved_angle - 30) / 120.0)) * 100); //((150-retrieved_angle)/120)*100
                        //direction = 'F';
                    } else if (retrieved_angle >= 150 && retrieved_angle <= 180) {
                        retrieved_angle = 0;
                        //direction = 'F';
                    }
                } else {
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
                }
                if (retrieved_speed == 0)
                {
                    retrieved_angle = 50;
                }



                if (retrieved_speed > speedValueMax)
                    retrieved_speed = speedValueMax;
                if (retrieved_angle > angleValueMax)
                    retrieved_angle = angleValueMax;


                angleMeter.setHighValue(retrieved_angle);
                speedoMeter.setHighValue(retrieved_speed);


                DecimalFormat formatter = new DecimalFormat("00");
                final String speed = formatter.format(retrieved_speed);
                final String angle = formatter.format(retrieved_angle);


                if (Math.abs(last_angle - retrieved_angle) > 8 || Math.abs(last_speed - retrieved_speed) > 8)
                {
                    last_angle = retrieved_angle;
                    last_speed = retrieved_speed;

                    new Thread(new Runnable() {
                        @Override
                        public void run() {
                            sendRCCar(direction, speed, angle);
                        }
                    }).start();
                }


            }
        });
    }

    private void orientationConfig(int orientation) {
        if(orientation == Configuration.ORIENTATION_PORTRAIT)
            ((LinearLayout)findViewById(R.id.mainLayout)).setOrientation(LinearLayout.VERTICAL);
        else
            ((LinearLayout)findViewById(R.id.mainLayout)).setOrientation(LinearLayout.HORIZONTAL);
    }

    private class DrawerItemClickListener implements ListView.OnItemClickListener {
        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
            // Highlight the selected item, update the title, and close the drawer
            menuList.setItemChecked(position, false);
            ((DrawerLayout)findViewById(R.id.drawer_layout)).closeDrawer(Gravity.LEFT);

            FragmentManager fragmentManager = getSupportFragmentManager();
            if (fragmentManager.findFragmentById(android.R.id.content) != null) return;
            FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
            fragmentTransaction.setCustomAnimations(android.R.anim.fade_in, android.R.anim.fade_out);

            switch (position) {
                case 0: {
                    final BluetoothAddressList listFragment = new BluetoothAddressList();
                    fragmentTransaction.add(android.R.id.content, listFragment);

                    ArrayList<HashMap<String,String>> pairedDevicesList = new ArrayList<>();

                    HashMap<String,String> item;
                    for (BluetoothDevice device : bluetoothAdapter.getBondedDevices()) {
                        item = new HashMap<>();
                        item.put( "name", device.getName());
                        item.put( "address", device.getAddress());
                        pairedDevicesList.add( item );
                    }

                    final ListAdapter adapter =  new SimpleAdapter(getApplicationContext(), pairedDevicesList,
                            android.R.layout.simple_list_item_2,
                            new String[] {"name", "address"},
                            new int[] {android.R.id.text1, android.R.id.text2});

                    listFragment.fillListView(adapter);

                } break;
                case 1: {

                    if(!bluetoothAdapter.isDiscovering())
                        bluetoothAdapter.startDiscovery();
                    else return;

                    final BluetoothAddressList listFragment = new BluetoothAddressList();
                    fragmentTransaction.add(android.R.id.content, listFragment);

                    final ArrayList<HashMap<String,String>> scannedDevicesList = new ArrayList<>();

                    // Register the BroadcastReceiver
                    final BroadcastReceiver deviceFoundReceiver;
                    IntentFilter filterDeviceFound = new IntentFilter(BluetoothDevice.ACTION_FOUND);
                    registerReceiver(deviceFoundReceiver = new BroadcastReceiver() {
                        public void onReceive(Context context, Intent intent) {
                            // When discovery finds a device
                            if (BluetoothDevice.ACTION_FOUND.equals(intent.getAction())) {
                                // Get the BluetoothDevice object from the Intent
                                BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                                // Add the name and address to the hashmap to show in a ListView
                                HashMap<String,String> item = new HashMap<>();
                                item.put( "name", device.getName() == null ? "N/A" : device.getName());
                                item.put( "address", device.getAddress());
                                scannedDevicesList.add( item );

                                final ListAdapter adapter =  new SimpleAdapter(getApplicationContext(), scannedDevicesList,
                                        android.R.layout.simple_list_item_2,
                                        new String[] {"name", "address"},
                                        new int[] {android.R.id.text1, android.R.id.text2});

                                listFragment.fillListView(adapter);
                            }
                        }
                    }, filterDeviceFound);

                    IntentFilter filterDiscoveryFinished = new IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);
                    registerReceiver(new BroadcastReceiver() {
                        public void onReceive(Context context, Intent intent) {
                            // When discovery finished
                            if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED.equals(intent.getAction())) {

                                unregisterReceiver(deviceFoundReceiver);
                                unregisterReceiver(this);

                                if(!scannedDevicesList.isEmpty()) {
                                    messageFromGUI("INFO", getResources().getString(R.string.searchingFinished));
                                    return;
                                }

                                messageFromGUI("INFO", getResources().getString(R.string.deviceNotFound));

                                FragmentManager fragmentManager = getSupportFragmentManager();
                                if (fragmentManager.findFragmentById(android.R.id.content) != null) {
                                    FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
                                    fragmentTransaction.setCustomAnimations(android.R.anim.fade_in, android.R.anim.fade_out);
                                    fragmentTransaction.remove(fragmentManager.findFragmentById(android.R.id.content));
                                    fragmentTransaction.commit();
                                    fragmentManager.executePendingTransactions();
                                }
                            }
                        }
                    }, filterDiscoveryFinished);

                } break;
                case 2: {
                    fragmentTransaction.add(android.R.id.content, Settings.newInstance());
                } break;
            }

            fragmentTransaction.commit();
            getSupportFragmentManager().executePendingTransactions();
        }
    }

    @Override
    protected void onDestroy() {
        try {
            unregisterReceiver(bluetoothState.stateChangedReceiver);
            bluetoothSocket.close();
        } catch (Exception exception) {
            Log.v("ERROR", exception.getMessage());
        }
        super.onDestroy();
    }

    @Override
    public void onConfigurationChanged (Configuration config) {
        orientationConfig(config.orientation);
        super.onConfigurationChanged(config);
    }

    /**
     * On the press of the back button search for active fragment and remove it
     * If not found any, then use the default handler
     */
    @Override
    public void onBackPressed() {
        FragmentManager fragmentManager = getSupportFragmentManager();
        if (fragmentManager.findFragmentById(android.R.id.content) != null) {

            if (bluetoothAdapter.isDiscovering())
                bluetoothAdapter.cancelDiscovery();

            FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
            fragmentTransaction.setCustomAnimations(android.R.anim.fade_in, android.R.anim.fade_out);
            fragmentTransaction.remove(fragmentManager.findFragmentById(android.R.id.content));
            fragmentTransaction.commit();
            fragmentManager.executePendingTransactions();
        } else {
            super.onBackPressed();
        }
    }

    /**
     * Connect to the specified bluetooth address with the predefined method
     * @param bluetoothAddress
     * @return
     * @throws Exception
     */

    protected boolean connectBluetoothDevice(String bluetoothAddress) {
        try {
            if (bluetoothAdapter.isDiscovering())
                bluetoothAdapter.cancelDiscovery();

            final BluetoothDevice remoteBluetoothDevice = bluetoothAdapter.getRemoteDevice(bluetoothAddress);
            switch (connectionMethod) {
                case R.id.radioButton:
                    bluetoothSocket = createRfcommSocketToServiceRecord(remoteBluetoothDevice);
                    break;
                case R.id.radioButton2:
                    bluetoothSocket = createInsecureRfcommSocketToServiceRecord(remoteBluetoothDevice);
                    break;
                case R.id.radioButton3:
                    bluetoothSocket = createRfcommSocket(remoteBluetoothDevice);
                    break;
                case R.id.radioButton4:
                    bluetoothSocket = createInsecureRfcommSocket(remoteBluetoothDevice);
                    break;
            }
            bluetoothSocket.connect();

            messageFromThread("INFO", getResources().getString(R.string.connectedTo) + remoteBluetoothDevice);

            return true;

        } catch (Exception open_exception) {
            try {
                Log.v("ERROR", open_exception.getMessage());
                messageFromThread("ERROR", getResources().getString(R.string.connectionFailed));
                bluetoothSocket.close();
            } catch (Exception close_exception) {
                Log.v("ERROR", close_exception.getMessage());
            }
        }

        return false;
    }

    /**
     * Method to create a Bluetooth createRfcommSocketToServiceRecord socket
     * @param bluetoothDevice
     * @return BluetoothSocket
     * @throws IOException
     */
    private BluetoothSocket createRfcommSocketToServiceRecord(BluetoothDevice bluetoothDevice) throws IOException {
        try {
            return bluetoothDevice.createRfcommSocketToServiceRecord(myUUID);
        } catch (Exception exception) {
            Log.v("ERROR", exception.getMessage());
        }
        return null;
    }

    /**
     * Method to create a Bluetooth createInsecureRfcommSocketToServiceRecord socket
     * @param bluetoothDevice
     * @return BluetoothSocket
     * @throws IOException
     */
    private BluetoothSocket createInsecureRfcommSocketToServiceRecord(BluetoothDevice bluetoothDevice) throws IOException {
        try {
            return bluetoothDevice.createInsecureRfcommSocketToServiceRecord(myUUID);
        } catch (Exception exception) {
            Log.v("ERROR", exception.getMessage());
        }
        return null;
    }

    /**
     * Method to create a Bluetooth createRfcommSocket socket
     * @param bluetoothDevice
     * @return BluetoothSocket
     * @throws IOException
     */
    private BluetoothSocket createRfcommSocket(BluetoothDevice bluetoothDevice) throws IOException {
        try {
            final Method m = bluetoothDevice.getClass().getMethod("createRfcommSocket", new Class[]{int.class});
            return (BluetoothSocket) m.invoke(bluetoothDevice, 1);
        } catch (Exception exception) {
            Log.v("ERROR", exception.getMessage());
        }
        return null;
    }

    /**
     * Method to create a Bluetooth createInsecureRfcommSocketToServiceRecord socket
     * @param bluetoothDevice
     * @return BluetoothSocket
     * @throws IOException
     */
    private BluetoothSocket createInsecureRfcommSocket(BluetoothDevice bluetoothDevice) throws IOException {
        try {
            final Method m = bluetoothDevice.getClass().getMethod("createInsecureRfcommSocketToServiceRecord", new Class[]{UUID.class});
            return (BluetoothSocket) m.invoke(bluetoothDevice, myUUID);
        } catch (Exception exception) {
            Log.v("ERROR", exception.getMessage());
        }
        return null;
    }

    /**
     * Method to set the right command for the controlling of the rc car
     */
    private void sendRCCar(String direction, String speed, String angle){
        String command = "S" + speed + "A" + angle + direction + endOFCommand;
        sendData(command);
    }

    /**
     * Send data to the RC-Car
     * @param   message Moving instruction, which sent to the rover
     * @exception Exception
     * @ThreadSafe
     */
    public void sendData(String message) {
        try {
            OutputStream outStream = bluetoothSocket.getOutputStream();
            outStream.write(message.getBytes());
            outStream.flush();
        }  catch (Exception exception) {
            messageFromThread("ERROR", message + getResources().getString(R.string.outStreamNull));
        }
    }

    /**
     * Non-thread-safe messaging from the GUI
     * @param   type The type of the message ["ERROR", "INFO"]
     * @param   message The message text
     * @NonThreadSafe
     */
    private void messageFromGUI(final String type, final String message) {
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

    /**
     * Thread-safe messaging towards the GUI
     * @param   type The type of the message ["ERROR", "INFO"]
     * @param   message The message text
     * @ThreadSafe
     */
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
}