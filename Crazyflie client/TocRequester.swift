//
//  TocRequester.swift
//  Crazyflie client
//
//  Created by Martin Eberl on 16.02.17.
//  Copyright © 2017 Bitcraze. All rights reserved.
//

import Foundation

final class TocRequester: CrazyFlieTocRequester {
    
    enum Status {
        case tocChannel
        case cmdTocElement
        case cmdTocInfo
    }
    
    private var requestStatus: Status?
    private var index: Int = 0
    private let bluetoothLink: BluetoothLink
    
    private(set) var status: String?
    
    init(bluetoothLink: BluetoothLink) {
        self.bluetoothLink = bluetoothLink
    }
    
    func request() {
        
        let commandPacket = TocRequestPacket(header: CrazyFlieHeader.logging.rawValue)
        guard let data = PacketCreator.data(fromToc: commandPacket) else { return }
        
        requestStatus = .tocChannel
        bluetoothLink.rxCallback = self.onLinkRx
        bluetoothLink.sendPacket(data, callback: nil)
        status = "Requesting toc data"
    }
    
    //MARK: - Helper
    
    private func request(toc: Int) {
        
        let commandPacket = TocRequestPacket(header: CrazyFlieHeader.logging.rawValue)
        guard let data = PacketCreator.data(fromToc: commandPacket) else { return }
        
        requestStatus = .cmdTocElement
        bluetoothLink.sendPacket(data, callback: nil)
        status = "Requesting toc data"
    }
    
    private func onLinkRx(_ packet: Data) {
        print("Packet received by bootloader \(packet.count) bytes")
        var packetArray = [UInt8](repeating: 0, count: packet.count)
        (packet as NSData).getBytes(&packetArray, length:packetArray.count)
        print(packetArray)
        
        if requestStatus == .tocChannel {
            let integer = TypeConverter<Int>.fromByteArray(packetArray)
            let string = String(format: "%08X.json", arguments: [packetArray[0]])
            print("")
            
            index = 0
            request(toc: index)
        } else if requestStatus == .cmdTocElement {
            guard let first = packetArray.first, index == Int(first & 0x00ff) else {
                return
            }
            
        }
    }
}
