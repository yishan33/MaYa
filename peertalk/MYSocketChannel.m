//
//  MYSocketChannel.m
//  MaYa
//
//  Created by liufushan on 2023/6/8.
//

#import "MYSocketChannel.h"
#import "PTChannel.h"


@interface MYSocketChannel ()

@property (nonatomic, strong) PTProtocol *protocol;
@property (nonatomic, strong) dispatch_io_t innerChannel;

@end

@implementation MYSocketChannel

- (id)initWithProtocol:(PTProtocol*)protocol delegate:(id<MYSocketChannelDelegate>)delegate
{
    if (self = [super init]) {
        self.protocol = protocol;
        self.delegate = delegate;
        return self;
    }
    return nil;
}

+ (MYSocketChannel*)channelWithDelegate:(id<MYSocketChannelDelegate>)delegate
{
    PTProtocol *protocol = [[PTProtocol alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    MYSocketChannel *channel = [[MYSocketChannel alloc] initWithProtocol:protocol delegate:delegate];
    return channel;
}

- (BOOL)startReadingFromConnectedChannel:(dispatch_io_t)channel error:(__autoreleasing NSError**)error
{
    self.innerChannel = channel;
    __weak typeof (self) weakSelf = self;
    [self.protocol readFramesOverChannel:channel onFrame:^(NSError *error, uint32_t type, uint32_t tag, uint32_t payloadSize, dispatch_block_t resumeReadingFrames) {
        __weak typeof (weakSelf) self = weakSelf;
        if (error) {
            NSLog(@"readFramesOverChannel error: %@", error);
            [self close];
            return;
        }
      
        if (type == PTFrameTypeEndOfStream) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onSocketChannel:didReceiveEnd:)]) {
                [self.delegate onSocketChannel:self didReceiveEnd:type];
            }
            [self cancel];
            return;
        }
      
        if (payloadSize == 0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onSocketChannel:didReceiveDataType:tag:payload:)]) {
                [self.delegate onSocketChannel:self didReceiveDataType:type tag:tag payload:nil];
            }
            resumeReadingFrames();
        } else {
            [self.protocol readPayloadOfSize:payloadSize overChannel:channel callback:^(NSError *error, dispatch_data_t contiguousData, const uint8_t *buffer, size_t bufferSize) {
                if (error) {
                    NSLog(@"readPayloadOfSize error: %@", error);
                    [self close];
                    return;
                }
                if (bufferSize == 0) {
                    [self cancel];
                    return;
              }
            
                if (self.delegate && [self.delegate respondsToSelector:@selector(onSocketChannel:didReceiveDataType:tag:payload:)]) {
                    PTData *payload = [[PTData alloc] initWithMappedDispatchData:contiguousData data:(void*)buffer length:bufferSize];
                    [self.delegate onSocketChannel:self didReceiveDataType:type tag:tag payload:payload];
                }
                resumeReadingFrames();
            }];
        }
    }];
    return YES;
}

#pragma mark - Sending

- (void)sendFrameOfType:(uint32_t)frameType
                    tag:(uint32_t)tag
            withPayload:(dispatch_data_t)payload
               callback:(void(^)(NSError *error))callback
{
    [self.protocol sendFrameOfType:frameType tag:tag
                       withPayload:payload
                       overChannel:self.innerChannel
                          callback:callback];
}

#pragma mark -

- (dispatch_queue_t)queue
{
    return self.protocol.queue;
}


#pragma mark - Close & Cancel

- (void)close {
    if (self.innerChannel) {
        dispatch_io_close(self.innerChannel, DISPATCH_IO_STOP);
        self.innerChannel = NULL;
    }
}

- (void)cancel {
    if (self.innerChannel) {
        dispatch_io_close(self.innerChannel, 0);
        self.innerChannel = NULL;
    }
}


@end
