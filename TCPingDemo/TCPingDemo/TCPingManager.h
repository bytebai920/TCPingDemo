//
//  TCPingManager.h
//  TCPingDemo
//
//  Created by 白永炳 on 16/12/28.
//  Copyright © 2016年 BYB. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^delayBlock)(double delay);
typedef void(^successBlock)(double max,double min, double avg);
typedef void(^failedBlock)(NSString *errorInfo);

@interface TCPingManager : NSObject

@property(nonatomic, copy)delayBlock delay;
@property(nonatomic, copy)successBlock success;
@property(nonatomic, copy)failedBlock failed;

+ (TCPingManager *)sharedInstance;

- (void)OTSTCPingWithHostName:(NSString *)pingTarget time:(NSNumber *)num currentDelay:(delayBlock)delay success:(successBlock)success failed:(failedBlock)failed;

@end
