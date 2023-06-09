//
//  MYListenChannel.h
//  MaYa
//
//  Created by liufushan on 2023/6/8.
//

#import <Foundation/Foundation.h>

@class PTData;
@class MYSocketChannel;
@class MYListenChannel;

//@protocol MYListenChannelDelegate <NSObject>
//
//- (void)onChannel:(MYListenChannel *)channel didEndWithError:(NSError *)error;
//
//- (void)onChannel:(MYListenChannel *)channel didReceiveDataType:(uint32_t)type tag:(uint32_t)tag payload:(PTData *)payload;
//
//@end

@interface MYListenChannel : NSObject

@property (nonatomic, strong, readonly) MYSocketChannel *firstSocketChannel;

- (void)listenOnPort:(in_port_t)port IPv4Address:(in_addr_t)address callback:(void(^)(NSError *error))callback;

@end
