//
//  DataStruct.m
//  Crazyflie client
//
//  Created by Martin Eberl on 12.02.17.
//  Copyright © 2017 Bitcraze. All rights reserved.
//

#import "PacketCreator.h"

@implementation PacketCreator

+ (NSData *)dataFromCommander:(CommanderPacket) packet {
    NSData *data = [NSData dataWithBytes:&packet length:sizeof(CommanderPacket)];
    //NSLog(@"%@", data);
    //30000000 00000000 80000000 000000 -> Default data package without any input
    return data;
}

+ (NSData *)dataFromGetInfo:(LogGetInfoRequestPacket)packet{
    NSData *data = [NSData dataWithBytes:&packet length:sizeof(LogGetInfoRequestPacket)];
    //NSLog(@"%@", data);
    //30000000 00000000 80000000 000000 -> Default data package without any input
    return data;
}

@end
