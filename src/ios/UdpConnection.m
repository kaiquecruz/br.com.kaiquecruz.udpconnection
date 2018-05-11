/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 
 Based on Changxi Wu's code from the github: https://gist.github.com/chancyWu/8349411
 */

#import "UdpConnection.h"

@implementation UdpConnection

CDVInvokedUrlCommand* cmd;
CDVPluginResult* pluginResult;

// receive the message to send data
- (void) clientSendAndListen:(CDVInvokedUrlCommand*)command {
    cmd = command;
    
    int socketSD = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (socketSD <= 0) {
        NSLog(@"Error: Could not open socket.");
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error: Could not open socket."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
        
        return;
    }
    
    // set socket options enable broadcast
    int broadcastEnable = 1;
    long ret = setsockopt(socketSD, SOL_SOCKET, SO_BROADCAST, &broadcastEnable, sizeof(broadcastEnable));
    if (ret) {
        NSLog(@"Error: Could not open set socket to broadcast mode");
        close(socketSD);
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error: Could not open set socket to broadcast mode"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
        
        return;
    }
    
    // bind the port
    struct sockaddr_in sockaddr;
    memset(&sockaddr, 0, sizeof(sockaddr));
    
    sockaddr.sin_len = sizeof(sockaddr);
    sockaddr.sin_family = AF_INET;
    sockaddr.sin_port = htons(4999); //CLIENT PORT
    sockaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    
    int status = bind(socketSD, (struct sockaddr *)&sockaddr, sizeof(sockaddr));
    if (status == -1) {
        close(socketSD);
        NSLog(@"Error: listenForPackets - bind() failed.");
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error: listenForPackets - bind() failed."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
        
        return;
    }
    
    
    // Configure the port and ip we want to send to
    struct sockaddr_in broadcastAddr;
    memset(&broadcastAddr, 0, sizeof(broadcastAddr));
    broadcastAddr.sin_family = AF_INET;
    inet_pton(AF_INET, "255.255.255.255", &broadcastAddr.sin_addr);
    broadcastAddr.sin_port = htons(5000); //SERVER PORT
    
    const char * request = ((NSString *)[command.arguments objectAtIndex:0]).cString;
    ret = sendto(socketSD, request, strlen(request), 0, (struct sockaddr*)&broadcastAddr, sizeof(broadcastAddr));
    if (ret < 0) {
        NSLog(@"Error: Could not open send broadcast.");
        close(socketSD);
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error: Could not open send broadcast."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
        
        return;
    }
    
    
    // set timeout to 3 seconds.
    struct timeval timeV;
    timeV.tv_sec = 3;
    timeV.tv_usec = 0;
    
    if (setsockopt(socketSD, SOL_SOCKET, SO_RCVTIMEO, &timeV, sizeof(timeV)) == -1) {
        NSLog(@"Error: listenForPackets - setsockopt failed");
        close(socketSD);
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error: listenForPackets - setsockopt failed"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
        
        return;
    }
    
    
    // receive
    struct sockaddr_in receiveSockaddr;
    socklen_t receiveSockaddrLen = sizeof(receiveSockaddr);
    
    size_t bufSize = 10000;
    void *buf = malloc(bufSize);
    ssize_t result = recvfrom(socketSD, buf, bufSize, 0, (struct sockaddr *)&receiveSockaddr, &receiveSockaddrLen);
    
    NSData *data = nil;
    
    NSLog(@"result: %zd", result);
    
    if (result > 0) {
        if ((size_t)result != bufSize) {
            buf = realloc(buf, result);
        }
        data = [NSData dataWithBytesNoCopy:buf length:result freeWhenDone:YES];
        
        char addrBuf[INET_ADDRSTRLEN];
        if (inet_ntop(AF_INET, &receiveSockaddr.sin_addr, addrBuf, (size_t)sizeof(addrBuf)) == NULL) {
            addrBuf[0] = '\0';
        }
        
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        close(socketSD);
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:msg];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
    } else {
        free(buf);
        close(socketSD);
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error receiving UDP packet"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
    }
    
}


// receive the message to send data
- (void) clientSendAndListenCreateProjectOnIOS:(CDVInvokedUrlCommand*)command {
    cmd = command;
    
    int socketSD = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (socketSD <= 0) {
        NSLog(@"Error: Could not open socket.");
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error: Could not open socket."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
        
        return;
    }
    
    // set socket options enable broadcast
    int broadcastEnable = 1;
    long ret = setsockopt(socketSD, SOL_SOCKET, SO_BROADCAST, &broadcastEnable, sizeof(broadcastEnable));
    if (ret) {
        NSLog(@"Error: Could not open set socket to broadcast mode");
        close(socketSD);
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error: Could not open set socket to broadcast mode"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
        
        return;
    }
    
    // bind the port
    struct sockaddr_in sockaddr;
    memset(&sockaddr, 0, sizeof(sockaddr));
    
    sockaddr.sin_len = sizeof(sockaddr);
    sockaddr.sin_family = AF_INET;
    sockaddr.sin_port = htons(4999); //CLIENT PORT
    sockaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    
    int status = bind(socketSD, (struct sockaddr *)&sockaddr, sizeof(sockaddr));
    if (status == -1) {
        close(socketSD);
        NSLog(@"Error: listenForPackets - bind() failed.");
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error: listenForPackets - bind() failed."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
        
        return;
    }
    
    
    // Configure the port and ip we want to send to
    struct sockaddr_in broadcastAddr;
    memset(&broadcastAddr, 0, sizeof(broadcastAddr));
    broadcastAddr.sin_family = AF_INET;
    inet_pton(AF_INET, "255.255.255.255", &broadcastAddr.sin_addr);
    broadcastAddr.sin_port = htons(5000); //SERVER PORT
    
    const char * request = ((NSString *)[command.arguments objectAtIndex:0]).cString;
    ret = sendto(socketSD, request, strlen(request), 0, (struct sockaddr*)&broadcastAddr, sizeof(broadcastAddr));
    if (ret < 0) {
        NSLog(@"Error: Could not open send broadcast.");
        close(socketSD);
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error: Could not open send broadcast."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
        
        return;
    }
    
    
    // set timeout to 10 seconds.
    struct timeval timeV;
    timeV.tv_sec = 10;
    timeV.tv_usec = 0;
    
    if (setsockopt(socketSD, SOL_SOCKET, SO_RCVTIMEO, &timeV, sizeof(timeV)) == -1) {
        NSLog(@"Error: listenForPackets - setsockopt failed");
        close(socketSD);
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error: listenForPackets - setsockopt failed"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
        
        return;
    }
    
    
    // receive
    struct sockaddr_in receiveSockaddr;
    socklen_t receiveSockaddrLen = sizeof(receiveSockaddr);
    
    size_t bufSize = 10000;
    void *buf = malloc(bufSize);
    ssize_t result = recvfrom(socketSD, buf, bufSize, 0, (struct sockaddr *)&receiveSockaddr, &receiveSockaddrLen);
    
    NSData *data = nil;
    
    NSLog(@"result: %zd", result);
    
    if (result > 0) {
        if ((size_t)result != bufSize) {
            buf = realloc(buf, result);
        }
        data = [NSData dataWithBytesNoCopy:buf length:result freeWhenDone:YES];
        
        char addrBuf[INET_ADDRSTRLEN];
        if (inet_ntop(AF_INET, &receiveSockaddr.sin_addr, addrBuf, (size_t)sizeof(addrBuf)) == NULL) {
            addrBuf[0] = '\0';
        }
        
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        close(socketSD);
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:msg];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
    } else {
        free(buf);
        close(socketSD);
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error receiving UDP packet"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:cmd.callbackId];
    }
    
}

@end