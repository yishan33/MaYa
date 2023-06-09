//
//  MYConnectChannel.m
//  MaYa
//
//  Created by liufushan on 2023/6/8.
//

#import "MYConnectChannel.h"
#import "PTChannel.h"
#import "MYSocketChannel.h"

@interface MYSocketChannel ()

@property (nonatomic, strong) PTProtocol *protocol;

@end

@interface MYConnectChannel () <MYSocketChannelDelegate>

@property (nonatomic, assign, readwrite) BOOL isConnected;

@end

@implementation MYConnectChannel

- (id)initWithDelegate:(id<MYConnectChannelDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
        self.socketChannel = [MYSocketChannel channelWithDelegate:self];
        return self;
    }
    return nil;
}

+ (MYConnectChannel*)channelWithDelegate:(id<MYConnectChannelDelegate>)delegate
{
    MYConnectChannel *channel = [[MYConnectChannel alloc] initWithDelegate:delegate];
    return channel;
}

- (void)connectToPort:(int)port overUSBHub:(PTUSBHub*)usbHub
             deviceID:(NSNumber*)deviceID
             callback:(void(^)(NSError *error))callback
{
    [usbHub connectToDevice:deviceID port:port onStart:^(NSError *err, dispatch_io_t dispatchChannel) {
        NSError *error = err;
        if (!error) {
            self.isConnected = YES;
            [self.socketChannel startReadingFromConnectedChannel:dispatchChannel error:&error];
        }
        if (callback) callback(error);
    } onEnd:^(NSError *error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onChannel:didEndWithError:)]) {
            [self.delegate onChannel:self didEndWithError:error];
        }
    }];
}

- (void)sendFrameOfType:(uint32_t)frameType
                    tag:(uint32_t)tag
            withPayload:(dispatch_data_t)payload
               callback:(void(^)(NSError *error))callback
{
    [self.socketChannel sendFrameOfType:frameType tag:tag withPayload:payload callback:callback];
}

#pragma mark - MYSocketChannelDelegate

- (void)onSocketChannel:(MYSocketChannel *)channel didEndWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onChannel:didEndWithError:)]) {
        [self.delegate onChannel:self didEndWithError:error];
    }
}

- (void)onSocketChannel:(MYSocketChannel *)channel didReceiveDataType:(uint32_t)type tag:(uint32_t)tag payload:(PTData *)payload
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onChannel:didReceiveDataType:tag:payload:)]) {
        [self.delegate onChannel:self didReceiveDataType:type tag:tag payload:payload];
    }
}

- (void)onSocketChannel:(MYSocketChannel *)channel didReceiveEnd:(uint32_t)type
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onChannel:didReceiveEnd:)]) {
        [self.delegate onChannel:self didReceiveEnd:type];
    }
}

#pragma mark - Close & Cancel

- (void)close {
    [self.socketChannel close];
}

- (void)cancel {
    [self.socketChannel cancel];
}

@end
