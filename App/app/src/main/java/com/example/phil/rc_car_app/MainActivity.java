package com.example.phil.rc_car_app;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.ListView;
import android.widget.SeekBar;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ArrayAdapter;
import java.io.IOException;
import java.io.OutputStream;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Set;
import java.util.UUID;

public class MainActivity extends Activity {

    private ListView myListView;
    private ArrayList<String> myBluetoothDeviceList = new ArrayList<String>();
    private BluetoothSocket myBluetoothSocket;
    private BluetoothAdapter myBluetoothAdapter;
    private Set<BluetoothDevice> pairedDevices;
    private Button forwardButton, backwardButton;
    private Switch bluetoothConnect;
    private SeekBar sBar1, sBar2;
    private static TextView tValue1, tValue2, connectionView;
    private static OutputStream outStream = null;
    private int sBar1Value, sBar2Value;
    private int sBar1Max = 100, sBar2Max = 100;
    private int sBar1Start = 0, sBar2Start = 50;
    private boolean isBluetoothOn = false;
    private forwardButtonRunnable fBRunnableWorker;
    private Thread fBRunnableThread;
    // SPP UUID service
    private static final UUID myUUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");

    private static final int BLUETOOTH_ON = 1;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        myBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

        /**
         * connectionView is a View, so that you can see that a bluetooth connection is enabled
         * and show you the bluetooth devices and show a 'w' if you drive forward, or a 's' if you drive backward.
         */
        connectionView = (TextView) findViewById(R.id.connectTextField);

        switchListener();
        forwardButtonControl();
        backwardButtonControl();
        seekBarOne();
        seekBarTwo();

        fBRunnableWorker = new forwardButtonRunnable();
        fBRunnableThread = new Thread(fBRunnableWorker);
        fBRunnableWorker.setStop(true);
    }

    @Override
    protected void onDestroy() {
        unregisterReceiver(mReceiver);
        fBRunnableThread.interrupt();
        fBRunnableThread = null;
        try {
            myBluetoothSocket.close();
        } catch (Exception e) {
        }
        super.onDestroy();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == BLUETOOTH_ON) {
            if (resultCode == RESULT_OK) {
                Toast.makeText(getApplicationContext(), "Turned bluetooth on", Toast.LENGTH_LONG).show();
                connectionView.setText("Bluetooth is on.");
                isBluetoothOn = true;
                getBluetoothDevices();
            }
        }
    }

    /**
     * The forward Button have the Activity, to snd the RC-Car the signal to drive foreward('w')
     * the signal is represented in the connection View
     */
    private void forwardButtonControl() {
        forwardButton = (Button) findViewById(R.id.fButton);
        forwardButton.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                Thread.State status = fBRunnableThread.getState();
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN: {
                        if (Thread.State.NEW.equals(status)) {
                            fBRunnableThread.start();
                            break;
                        } else {
                            fBRunnableWorker.setStop(false);
                            break;
                        }
                    }
                    /*case MotionEvent.ACTION_MOVE: {
                        sendData("w");
                    }*/
                    case MotionEvent.ACTION_UP: {
                        fBRunnableWorker.setStop(true);
                        break;
                    }
                }
                return false;
            }
        });
    }

    /**
     * The backward Button have the Activity, to snd the RC-Car the signal to drive backward('s')
     * the signal is represented in the connection View
     */
    private void backwardButtonControl() {
        backwardButton = (Button) findViewById(R.id.bButton);
        backwardButton.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN: {
                        break;
                    }
                    case MotionEvent.ACTION_MOVE: {
                        sendData("s");
                        break;
                    }
                    case MotionEvent.ACTION_UP: {
                        break;
                    }
                }
                /*
                if (sBar1Value != 0) {
                    while (event.getAction() == MotionEvent.ACTION_DOWN || event.getAction() == MotionEvent.ACTION_MOVE) {
                        connectionView.setText("s");
                        sendData("s");
                        return true;
                    }
                } else {
                    connectionView.setText("Please select the speed and the angle before"
                            + " you push the forward- / backward-button");
                }*/
                return false;
            }
        });
    }

    /**
     * With the seek Bar one you be able to set the speed of the RC-Car.
     */
    private void seekBarOne() {
        sBar1 = (SeekBar) findViewById(R.id.seekBar);
        tValue1 = (TextView) findViewById(R.id.textFieldSeekBox1);
        sBar1.setMax(sBar1Max);
        sBar1.setProgress(sBar1Start);
        tValue1.setText(Integer.toString(sBar1Start));
        sBar1.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                // not used at the moment
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                // not used at the moment
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                sBar1Value = sBar1.getProgress();
                tValue1.setText(Integer.toString(sBar1Value));
            }
        });
    }

    /**
     * With the Seek Bar Two you can set the angel of the RC-Car.
     */
    private void seekBarTwo() {
        sBar2 = (SeekBar) findViewById(R.id.seekBar2);
        tValue2 = (TextView) findViewById(R.id.textFieldSeekBox2);
        sBar2.setMax(sBar2Max);
        sBar2.setProgress(sBar2Start);
        tValue2.setText(Integer.toString(sBar2Start));
        sBar2.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                // not used at the moment
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                // not used at the moment
            }

            // This method keep the Text Field under the Seek Bar up to date,
            // so that there is always the right value in the Text Field.
            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                sBar2Value = sBar2.getProgress();
                tValue2.setText(Integer.toString(sBar2Value));
                if (sBar2Value >= 60) {
                    // angle right
                    sendData("d");
                } else if (sBar2Value <= 40) {
                    // angle left
                    sendData("a");
                } else {
                    // no angle
                    if (forwardButton.isPressed()) {
                        sendData("w");
                    } else if (backwardButton.isPressed()) {
                        sendData("s");
                    } else {
                        sendData("w");
                    }
                }
            }
        });
    }

    /**
     * Switch, witch connects the device (where the the android app run)
     * with the RC-Car to be able to send specific data.
     */
    private void switchListener() {
        bluetoothConnect = (Switch) findViewById(R.id.connect);
        // attach a listener to check for changes in state
        bluetoothConnect.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    // switch bluetooth on
                    bluetoothOn(buttonView);
                    if (isBluetoothOn == true) {
                        visible(buttonView);
                        connectionView.setText("Bluetooth is on.");
                    }
                } else {
                    // switch bluetooth off
                    bluetoothOff(buttonView);
                    if (isBluetoothOn == false) {
                        connectionView.setText("Bluetooth is off.");
                    }
                }
            }
        });
    }


    /**
     * bluetoothOn activates the bluetooth Connection and inform ypu, when bluetooth is already on
     */
    private void bluetoothOn(View view) {
        if (myBluetoothAdapter == null) {
            connectionView.setText("Bluetooth not available");
        } else if (!myBluetoothAdapter.isEnabled()) {
            Intent turnBluetoothOn = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(turnBluetoothOn, BLUETOOTH_ON);
        } else {
            Toast.makeText(getApplicationContext(), "Bluetooth is already on", Toast.LENGTH_LONG).show();
            isBluetoothOn = true;
            //bluetoothPairedList(listView);
        }
    }

    /**
     * bluetoothOff deactivates the bluetooth Connection
     */
    private void bluetoothOff(View view) {
        myBluetoothAdapter.disable();
        Toast.makeText(getApplicationContext(), "Turned bluetooth off", Toast.LENGTH_LONG).show();
        isBluetoothOn = false;
        myBluetoothDeviceList.clear();
    }

    /**
     * show a list of all paired bluetooth devices
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
     * make the bluetooth device for 120 seconds visible for other bluetooth devices
     */
    private void visible(View view) {
        Intent getVisible = new Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE);
        startActivityForResult(getVisible, 0);
    }

    /**
     * to get the bluetooth devices in the near of the used bluetooth device
     */
    private void getBluetoothDevices() {
        if (myBluetoothAdapter.isEnabled()) {
            myBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
            myBluetoothAdapter.startDiscovery();
            myBluetoothDeviceList.clear();
            // Register the BroadcastReceiver
            IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
            registerReceiver(mReceiver, filter);
            myListView = (ListView) findViewById(R.id.listView);
            myListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    myBluetoothAdapter.cancelDiscovery();
                    // Get the device MAC address, which is the last 17 chars in the View
                    String info = ((TextView) view).getText().toString();
                    //get the device address when click the device item
                    String address = info.substring(info.length() - 17);

                    connectionView.setText(address);
                    //connect the device when item is click
                    BluetoothDevice connectBluetoothDevice = myBluetoothAdapter.getRemoteDevice(address);
                    try {
                        Method m = connectBluetoothDevice.getClass().getMethod("createRfcommSocket", new Class[]{int.class});
                        myBluetoothSocket = (BluetoothSocket) m.invoke(connectBluetoothDevice, 1);
                        myBluetoothSocket = createBluetoothSocket(connectBluetoothDevice);
                        if (myBluetoothAdapter.isDiscovering()) {
                            myBluetoothAdapter.cancelDiscovery();
                        }
                        myBluetoothSocket.connect();
                        outStream = myBluetoothSocket.getOutputStream();
                        sendData(">rc");
                        connectionView.setText("connected to " + connectBluetoothDevice);
                    } catch (Exception e) {
                        try {
                            myBluetoothSocket.close();
                        } catch (Exception e1) {
                        }
                        e.printStackTrace();
                    }
                }
            });
        }
    }

    private BluetoothSocket createBluetoothSocket(BluetoothDevice device) throws IOException {
        try {
                final Method m = device.getClass().getMethod("createInsecureRfcommSocketToServiceRecord", new Class[]{UUID.class});
                return (BluetoothSocket) m.invoke(device, myUUID);
            } catch (Exception e) {
                connectionView.setText("Could not create Insecure RFComm Connection");
            }
        return device.createRfcommSocketToServiceRecord(myUUID);
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
                myBluetoothDeviceList.add(device.getName() + "\n" + device.getAddress());
                myListView.setAdapter(new ArrayAdapter<String>(context,
                        android.R.layout.simple_list_item_1, myBluetoothDeviceList));
            }
        }
    };
    /**
     * Send data to the RC-Car
     * @param message
     */
    public static void sendData(String message) {
        byte[] msgBuffer = message.getBytes();
        if (outStream != null) {
            try {
                outStream.write(msgBuffer);
                outStream.flush();
            } catch (IOException e) {}
        } else connectionView.setText("outStream is Null.");
    }
}

