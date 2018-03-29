@objc(UdpConnection) class UdpConnection : NSObject, GCDAsyncUdpSocketDelegate, CDVPlugin {
	let IPSERVER = "255.255.255.255"
	let PORTCLIENT:UInt16 = 4999
	let PORTSERVER:UInt16 = 5000
	var socketServer:GCDAsyncUdpSocket!
	var socketClient:GCDAsyncUdpSocket!
   
    func clientSendAndListen(command: CDVInvokedUrlCommand) {
        let msg = command.arguments[0] as? String ?? ""

		var error : NSError?
		socketServer = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
		socketServer.bindToPort(PORTSERVER, error: &error)
		socketServer.enableBroadcast(true, error: &error)
		socketServer.joinMulticastGroup(IPSERVER, error: &error)		
		
		socketClient = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
		socketClient.bindToPort(PORTCLIENT, error: &error)
		socketClient.connectToHost(IPSERVER, onPort: PORTSERVER, error: &error)		
		socketClient.beginReceiving(&error)
		
		let data = msg.dataUsingEncoding(NSUTF8StringEncoding)
		socketClient.sendData(data, withTimeout: 10, tag: 0)		
	}

	func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {		
		self.commandDelegate!.sendPluginResult(
            status: CDVCommandStatus_OK,
            messageAsString: data,
            callbackId: command.callbackId
        )
	}

	func udpSocket(sock: GCDAsyncUdpSocket!, didNotConnect error: NSError!) {
		self.commandDelegate!.sendPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAsString: error,
            callbackId: command.callbackId
        )
	}

	func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
        self.commandDelegate!.sendPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAsString: error,
            callbackId: command.callbackId
        )
	}
    
}