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
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

public class MainActivity extends Activity {

    private ListView myListView;
    private ArrayList<String> myBluetoothDeviceList = new ArrayList<String>();
    private BluetoothSocket myBluetoothSocket;
    private BluetoothAdapter myBluetoothAdapter;
    private Set<BluetoothDevice> pairedDevices;
    private Button forwardButton, backwardButton;
    private Switch bluetoothConnect;
    private SeekBar sBar2;
    private SeekBarVertical verticalSB;
    private static TextView speedValueField, angleValueField, connectionView;
    private static OutputStream outStream = null;
    private int speedValueMax = 99, angleValueMax = 99;
    private int speedValueStart = 0, angleValueStart = 50;
    private boolean isBluetoothOn = false;
    private static final int BLUETOOTH_ON = 1;
    private static DecimalFormat formatter;
    private static char direction = ' ';
    private static int angle, speed;
    private static String speedZero = "00", angleZero = "50", speedTen, angleTen, command;
    private static final char endOFCommand = 'E';
    // SPP UUID service
    private static final UUID myUUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        myBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

        //connectionView is a View, so that you can see that a bluetooth connection is enabled
        //and show you the bluetooth devices and show a 'w' if you drive forward, or a 's' if you drive backward.
        connectionView = (TextView) findViewById(R.id.connectTextField);

        switchListener();
        forwardButtonControl();
        backwardButtonControl();
        seekBarOne();
        seekBarTwo();
    }

    @Override
    protected void onDestroy() {
        unregisterReceiver(mReceiver);
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
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN: {
                        // the direction will be set to forward
                        direction = 'F';
                        sendRCCar();
                        break;
                    }
                    case MotionEvent.ACTION_MOVE: {
                        break;
                    }
                    case MotionEvent.ACTION_UP: {
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
                        // direction will be set to reverse
                        direction = 'R';
                        sendRCCar();
                        break;
                    }
                    case MotionEvent.ACTION_MOVE: {
                        break;
                    }
                    case MotionEvent.ACTION_UP: {
                        break;
                    }
                }
                return false;
            }
        });
    }

    /**
     * With the seek Bar one you be able to set the speed of the RC-Car.
     */
    private void seekBarOne() {
        verticalSB = (SeekBarVertical) findViewById(R.id.seekBar1);
        speedValueField = (TextView) findViewById(R.id.textFieldSeekBox1);
        verticalSB.setMax(speedValueMax);
        verticalSB.setProgress(speedValueStart);
        speedValueField.setText(Integer.toString(speedValueStart));
        verticalSB.setOnSeekBarChangeListener(new SeekBarVertical.OnSeekBarChangeListener() {
            // This method keep the Text Field under the Seek Bar up to date,
            // so that there is always the right value in the Text Field.
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                speedValueField.setText(progress + "");
                if(progress <= 9) {
                    if(progress == 0) {
                        speed = progress;
                        formatter = new DecimalFormat("00");
                        speedZero = formatter.format(speed);
                    }else {
                        speed = progress;
                        formatter = new DecimalFormat("0" + progress);
                        speedTen = formatter.format(speed);
                    }
                }else{
                    speed = progress;
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
     * With the Seek Bar Two you can set the angel of the RC-Car.
     */
    private void seekBarTwo() {
        sBar2 = (SeekBar) findViewById(R.id.seekBar2);
        angleValueField = (TextView) findViewById(R.id.textFieldSeekBox2);
        sBar2.setMax(angleValueMax);
        sBar2.setProgress(angleValueStart);
        angleValueField.setText(Integer.toString(angleValueStart));
        sBar2.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            // This method keep the Text Field under the Seek Bar up to date,
            // so that there is always the right value in the Text Field.
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                angleValueField.setText(progress + "");
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
     * method bluetoothOff deactivates the bluetooth Connection
     * @param view
     */
    private void bluetoothOff(View view) {
        myBluetoothAdapter.disable();
        Toast.makeText(getApplicationContext(), "Turned bluetooth off", Toast.LENGTH_LONG).show();
        isBluetoothOn = false;
        myBluetoothDeviceList.clear();
    }

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
     * method to make the bluetooth device for 120 seconds visible for other bluetooth devices
     * @param view
     */
    private void visible(View view) {
        Intent getVisible = new Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE);
        startActivityForResult(getVisible, 0);
    }

    /**
     * method to get the bluetooth devices in the near of the used bluetooth device
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

    /**
     * method to create a Bluetooth socket
     * @param device
     * @return
     * @throws IOException
     */
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
        }else{connectionView.setText("please set an direction");}
        sendData(command);
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
        } else connectionView.setText("outStream is Null.");
    }
}

