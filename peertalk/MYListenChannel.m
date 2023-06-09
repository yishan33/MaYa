//
//  MYListenChannel.m
//  MaYa
//
//  Created by liufushan on 2023/6/8.
//

#import "MYListenChannel.h"
#import "PTChannel.h"
#import "MYConnectChannel.h"

#if TARGET_OS_IPHONE
#import "MaYa_iOS-Swift.h"
#elif TARGET_OS_MAC
#import "MaYa-Swift.h"
#endif

static int kPTIPListenMaxCount = 512;

@interface MYListenChannel () <MYSocketChannelDelegate>

@property (nonatomic, strong) PTProtocol *protocol;
@property (nonatomic, strong) dispatch_io_t innerChannel;
@property (nonatomic, strong) dispatch_queue_t listenQueue;
@property (nonatomic, strong) NSMutableArray <MYSocketChannel *> *socketChannelList;
@property (nonatomic, strong) MYServerMananger *serverManager;
@end

@implementation MYListenChannel

- (instancetype)init
{
    if (self = [super init]) {
        self.listenQueue = dispatch_queue_create("com.serial.MYListenChannel", DISPATCH_QUEUE_SERIAL);
        self.socketChannelList = [[NSMutableArray alloc] init];
        self.serverManager = [[MYServerMananger alloc] init];
        return self;
    }
    return nil;
}

#pragma mark -
- (void)listenOnPort:(in_port_t)port IPv4Address:(in_addr_t)address callback:(void(^)(NSError *error))callback {
    // Create socket
    dispatch_fd_t fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd == -1) {
        if (callback) callback([NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
        return;
    }
    
    // Connect socket
    struct sockaddr_in addr;
    bzero((char *)&addr, sizeof(addr));
    
    addr.sin_len = sizeof(struct sockaddr_in);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = htonl(address);
    socklen_t socklen = sizeof(addr);
    
    int on = 1;
    if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)) == -1) {
        close(fd);
        if (callback) callback([NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
        return;
    }
    
    if (bind(fd, (struct sockaddr*)&addr, socklen) != 0) {
        close(fd);
        if (callback) callback([NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
        return;
    }
    
    if (listen(fd, kPTIPListenMaxCount) != 0) {
        close(fd);
        if (callback) callback([NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
        return;
    }
    
    dispatch_async(self.listenQueue, ^{
        struct sockaddr_in client_address;
        socklen_t address_len;
        while (1) {
            dispatch_fd_t client_socket = accept(fd, (struct sockaddr*)&client_address, &address_len );
            if (client_socket == -1) {
                NSLog(@"listenOnPort 接受客户端链接失败");
            } else{
                NSLog(@"socket编号:%@有客户端接入", @(client_socket));
                //接收客户端数据
                [self recvFromClientWithSocket:client_socket];
                
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    if (callback) callback(nil);
                });
            }
        }
    });
}

- (void)recvFromClientWithSocket:(int)client_socket {
    MYSocketChannel *socketChannel = [MYSocketChannel channelWithDelegate:self];
    [self.socketChannelList addObject:socketChannel];
    dispatch_io_t dispatchChannel = dispatch_io_create(DISPATCH_IO_STREAM, client_socket, socketChannel.queue, ^(int error) {
      // Important note: This block captures *self*, thus a reference is held to
      // *self* until the fd is truly closed.
        close(client_socket);
        NSLog(@"dispatch_io_create error");
    });
    dispatch_async(socketChannel.queue, ^{
        NSError *err = nil;
        if (![socketChannel startReadingFromConnectedChannel:dispatchChannel error:&err]) {
          NSLog(@"startReadingFromConnectedChannel failed in accept: %@", err);
        }
    });
}

- (MYListenChannel *)firstSocketChannel
{
    return self.socketChannelList.firstObject;
}

#pragma mark - MYSocketChannelDelegate

- (void)onSocketChannel:(MYSocketChannel *)channel didEndWithError:(NSError *)error
{
    NSLog(@"server didEndWithError");
}

- (void)onSocketChannel:(MYSocketChannel *)channel didReceiveDataType:(uint32_t)type tag:(uint32_t)tag payload:(PTData *)payload
{
    NSLog(@"server didReceiveDataType");
    [self.serverManager ioFrameChannel:channel didReceiveFrameOfType:type tag:tag payload:payload];
}

- (void)onSocketChannel:(MYSocketChannel *)channel didReceiveEnd:(uint32_t)type
{
    NSLog(@"server didReceiveEnd");
}

@end
