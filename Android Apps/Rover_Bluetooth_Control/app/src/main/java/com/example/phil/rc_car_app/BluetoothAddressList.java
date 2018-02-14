package com.example.phil.rc_car_app;

import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.app.ListFragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.TextView;

/**
 * Created by hegedus_attila on 2017.10.29..
 */

public class BluetoothAddressList extends ListFragment
{
    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {

        final String address = ((TextView)v.findViewById(android.R.id.text2)).getText().toString();

        new Thread(new Runnable() {
            @Override
            public void run() {
                ((MainActivity) getActivity()).connectBluetoothDevice(address);
            }
        }).start();

        FragmentManager fragmentManager = getFragmentManager();
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        fragmentTransaction.setCustomAnimations(android.R.anim.fade_in, android.R.anim.fade_out);
        fragmentTransaction.remove(fragmentManager.findFragmentById(android.R.id.content));
        fragmentTransaction.commit();
        fragmentManager.executePendingTransactions();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return super.onCreateView(inflater, container, savedInstanceState);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        this.getView().setBackgroundResource(R.color.colorPrimaryOpaque);
        ListView listView = getListView();
        listView.setPadding(0, 70, 0, 0);
    }

    public void fillListView (ListAdapter list) {
        setListAdapter(list);
    }
}