/*
 * Copyright 2018 Kaique Cruz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *  Based on Mustafa Alparslan's code from the blog: http://msdalp.github.io/2014/03/09/Udp-on-Android/
 */
package br.com.kaiquecruz.udpconnection;

import org.apache.cordova.*;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.SocketException;
import java.net.UnknownHostException;
import android.content.Context;
import android.util.Log;

public class UdpConnection extends CordovaPlugin {
	
    private static final String CLIENT_SEND_AND_LISTEN = "clientSendAndListen";
    private String ip_server = "255.255.255.255";
    private int port_server = 5000, port_client = 4999;
    private DatagramSocket udpSocket;	
    private CallbackContext callbackContext;
	private static final String TAG = "UDP_CONNECTION";
    
    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
    }
    
    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext)
      throws JSONException {
        
        this.callbackContext = callbackContext;
        
        if(action.equals(CLIENT_SEND_AND_LISTEN)) {
            return this.clientSendAndListen(callbackContext, data);
        }
        else {
            callbackContext.error("Incorrect action parameter: " + action);
        }
        
        return false;
    }
    
    /**
     *    This method is used to send a text message to the server and get the response.
     *
     *    @param    callbackContext        A Cordova callback context
     *    @param    data                JSON Array, with [0] being SSID to remove
     *    @return   if true returns the server's message response, false if failed
     */
    private boolean clientSendAndListen(CallbackContext callbackContext, JSONArray data) {
        Log.d(TAG, "UdpConnection: clientSendAndListen entered.");
        boolean run = true;
		try {
			this.udpSocket = new DatagramSocket(this.port_client);
			InetAddress serverAddr = InetAddress.getByName(this.ip_server);
			byte[] buf = data.getString(0).getBytes();
			DatagramPacket packet = new DatagramPacket(buf, buf.length, serverAddr, this.port_server);
			this.udpSocket.send(packet);
			while (run) {
				try {
					byte[] message = new byte[10000];
					DatagramPacket packetII = new DatagramPacket(message,message.length);
					Log.i(TAG, "UDP client: about to wait to receive");
					this.udpSocket.setSoTimeout(10000);//10s
					this.udpSocket.receive(packetII);
					String text = new String(message, 0, packetII.getLength());
					
					Log.d(TAG, "Received text: "+ text);
					
					callbackContext.success(text);
					
					return true;
				} catch (IOException e) {
					Log.e(TAG, "Error: "+ e);
					run = false;
					this.udpSocket.close();
					
					callbackContext.error(e.getMessage());
					
					return false;
				}
			}
		} catch (SocketException e) {
			Log.e(TAG, "Error: "+ e);
			callbackContext.error(e.getMessage());
			return false;
		} catch (UnknownHostException e) {
			e.printStackTrace();
			Log.e(TAG, "Error: "+ e);
			callbackContext.error(e.getMessage());
			return false;
		} catch (IOException e) {
			e.printStackTrace();
			Log.e(TAG, "Error: "+ e);
			callbackContext.error(e.getMessage());
			return false;
        }
    }
	
}