//
//  MYConnectChannel.h
//  MaYa
//
//  Created by liufushan on 2023/6/8.
//

#import <Foundation/Foundation.h>
#import "MYSocketChannel.h"

@class PTData;
@class PTUSBHub;
@class MYConnectChannel;

@protocol MYConnectChannelDelegate <NSObject>

- (void)onChannel:(MYConnectChannel *)channel didReceiveEnd:(uint32_t)type;

- (void)onChannel:(MYConnectChannel *)channel didEndWithError:(NSError *)error;

- (void)onChannel:(MYConnectChannel *)channel didReceiveDataType:(uint32_t)type tag:(uint32_t)tag payload:(PTData *)payload;

@end

@interface MYConnectChannel : NSObject

@property (nonatomic, assign, readonly) BOOL isConnected;
@property (nonatomic, weak) id <MYConnectChannelDelegate> delegate;
@property (nonatomic, strong) MYSocketChannel *socketChannel;

- (void)connectToPort:(int)port
           overUSBHub:(PTUSBHub *)usbHub
             deviceID:(NSNumber *)deviceID
             callback:(void(^)(NSError *error))callback;

- (void)sendFrameOfType:(uint32_t)frameType
                    tag:(uint32_t)tag
            withPayload:(dispatch_data_t)payload
               callback:(void(^)(NSError *error))callback;

+ (MYConnectChannel *)channelWithDelegate:(id<MYConnectChannelDelegate>)delegate;

- (void)close;

@end


