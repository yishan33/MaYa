//
//  MYSocketChannel.h
//  MaYa
//
//  Created by liufushan on 2023/6/8.
//

#import <Foundation/Foundation.h>

@class PTData;
@class MYSocketChannel;

@protocol MYSocketChannelDelegate <NSObject>

- (void)onSocketChannel:(MYSocketChannel *)channel didReceiveEnd:(uint32_t)type;

- (void)onSocketChannel:(MYSocketChannel *)channel didEndWithError:(NSError *)error;

- (void)onSocketChannel:(MYSocketChannel *)channel didReceiveDataType:(uint32_t)type tag:(uint32_t)tag payload:(PTData *)payload;

@end

@interface MYSocketChannel : NSObject

@property (nonatomic, strong, readonly) dispatch_queue_t queue;
@property (nonatomic, weak) id<MYSocketChannelDelegate> delegate;

+ (MYSocketChannel*)channelWithDelegate:(id<MYSocketChannelDelegate>)delegate;


- (void)sendFrameOfType:(uint32_t)frameType
                    tag:(uint32_t)tag
            withPayload:(dispatch_data_t)payload
               callback:(void(^)(NSError *error))callback;

- (BOOL)startReadingFromConnectedChannel:(dispatch_io_t)channel
                                   error:(__autoreleasing NSError**)error;

- (void)close;

- (void)cancel;

@end

