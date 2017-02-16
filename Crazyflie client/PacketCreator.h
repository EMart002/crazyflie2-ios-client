//
//  DataStruct.m
//  Crazyflie client
//
//  Created by Martin Eberl on 12.02.17.
//  Copyright © 2017 Bitcraze. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct __attribute__((packed)) {
    uint8_t header;
    float roll;
    float pitch;
    float yaw;
    uint16_t thrust;
} CommanderPacket;

typedef struct __attribute__((packed)) {
    uint8_t header;
} TocRequestPacket;

@interface PacketCreator : NSObject

+ (NSData *)dataFromCommander:(CommanderPacket)packet;
+ (NSData *)dataFromToc:(TocRequestPacket)packet;

@end
