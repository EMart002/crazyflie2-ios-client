//
//  TocRequester.swift
//  Crazyflie client
//
//  Created by Martin Eberl on 16.02.17.
//  Copyright © 2017 Bitcraze. All rights reserved.
//

import Foundation

final class TocRequester: CrazyFlieTocRequester {
    private let bluetoothLink: BluetoothLink
    
    init(bluetoothLink: BluetoothLink) {
        self.bluetoothLink = bluetoothLink
        bluetoothLink.rxCallback = onLinkRx
    }
    
    func request() {
        let commandPacket = TocRequestPacket(header: CrazyFlieHeader.logging.rawValue)
        guard let data = PacketCreator.data(fromToc: commandPacket) else { return }
        
        bluetoothLink.sendPacket(data, callback: nil)
    }
    
    //MARK: - Helper
    
    private func onLinkRx(_ packet: Data) {
        print("Packet received by bootloader \(packet.count) bytes")
        var packetArray = [UInt8](repeating: 0, count: packet.count)
        (packet as NSData).getBytes(&packetArray, length:packetArray.count)
        print(packetArray)
        
        let integer = TypeConverter<Int>.fromByteArray(packetArray)
        let string = String(format: "%08X.json", arguments: [packetArray[0]])
        print("")
    }
}
