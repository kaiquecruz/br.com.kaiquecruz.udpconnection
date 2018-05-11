/*#import <Cordova/CDVPlugin.h>
#import <CoreFoundation/CFSocket.h>
#include <CFNetwork/CFNetwork.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>*/

#import <Cordova/CDVPlugin.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
#include <arpa/inet.h>

@interface UdpConnection : CDVPlugin

- (void)clientSendAndListen:(CDVInvokedUrlCommand*)command;

@end