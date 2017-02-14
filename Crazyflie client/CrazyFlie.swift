//
//  CrazyFlie.swift
//  Crazyflie client
//
//  Created by Martin Eberl on 15.07.16.
//  Copyright © 2016 Bitcraze. All rights reserved.
//

import UIKit

protocol CrazyFlieCommander {
    var pitch: Float { get }
    var roll: Float { get }
    var thrust: Float { get }
    var yaw: Float { get }
    
    func prepareData()
}

protocol CrazyFlieLog {
}

enum CrazyFlieHeader: UInt8 {
    case console = 0x00
    case parameter = 0x20
    case commander = 0x30
    case memory = 0x40
    case logging = 0x50
    case platform = 0x13
}

enum CrazyFlieState {
    case idle, connected , scanning, connecting, services, characteristics
}

protocol CrazyFlieDelegate {
    func didSend()
    func didUpdate(state: CrazyFlieState)
    func didFail(with title: String, message: String?)
}

open class CrazyFlie: NSObject {
    
    private(set) var state:CrazyFlieState {
        didSet {
            delegate?.didUpdate(state: state)
        }
    }
    private var timer:Timer?
    private var delegate: CrazyFlieDelegate?
    private(set) var bluetoothLink:BluetoothLink!

    var commander: CrazyFlieCommander?
    var logger: CrazyFlieLog?
    
    init(bluetoothLink:BluetoothLink? = BluetoothLink(), delegate: CrazyFlieDelegate?) {
        
        state = .idle
        self.delegate = delegate
        
        self.bluetoothLink = bluetoothLink
        super.init()
    
        bluetoothLink?.onStateUpdated{[weak self] (state) in
            if state.isEqual(to: "idle") {
                self?.state = .idle
            } else if state.isEqual(to: "connected") {
                self?.state = .connected
            } else if state.isEqual(to: "scanning") {
                self?.state = .scanning
            } else if state.isEqual(to: "connecting") {
                self?.state = .connecting
            } else if state.isEqual(to: "services") {
                self?.state = .services
            } else if state.isEqual(to: "characteristics") {
                self?.state = .characteristics
            }
        }
        
        startTimer()
    }
    
    func connect(_ callback:((Bool) -> Void)?) {
        guard state == .idle else {
            self.disconnect()
            return
        }
        
        bluetoothLink.connect(nil, callback: {[weak self] (connected) in
            callback?(connected)
            guard connected else {
                if self?.timer != nil {
                    self?.timer?.invalidate()
                    self?.timer = nil
                }
                
                var title:String
                var body:String?
                
                // Find the reason and prepare a message
                if self?.bluetoothLink.getError() == "Bluetooth disabled" {
                    title = "Bluetooth disabled"
                    body = "Please enable Bluetooth to connect a Crazyflie"
                } else if self?.bluetoothLink.getError() == "Timeout" {
                    title = "Connection timeout"
                    body = "Could not find Crazyflie"
                } else {
                    title = "Error";
                    body = self?.bluetoothLink.getError()
                }
                
                self?.delegate?.didFail(with: title, message: body)
                return
            }
            
            self?.startTimer()
        })
        
        bluetoothLink.rxCallback = onLinkRx
        sendReadRequest()
    }
    
    func disconnect() {
        bluetoothLink.disconnect()
        stopTimer()
    }
    
    // MARK: - Private Methods
    
    private func onLinkRx(_ packet: Data) {
        print("Packet received by bootloader \(packet.count) bytes")
        var packetArray = [UInt8](repeating: 0, count: packet.count)
        (packet as NSData).getBytes(&packetArray, length:packetArray.count)
        print(packetArray)
    }
    
    private func startTimer() {
        stopTimer()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.updateData), userInfo:nil, repeats:true)
    }
    
    private func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc private func updateData(_ timter:Timer){
        guard timer != nil, let commander = commander else {
            return
        }

        commander.prepareData()
        sendFlightData(commander.roll, pitch: commander.pitch, thrust: commander.thrust, yaw: commander.yaw)
    }
    
    private func sendFlightData(_ roll:Float, pitch:Float, thrust:Float, yaw:Float) {
        let commandPacket = CommanderPacket(header: CrazyFlieHeader.commander.rawValue, roll: roll, pitch: pitch, yaw: yaw, thrust: UInt16(thrust))
        let data = PacketCreator.data(fromCommander: commandPacket)
        bluetoothLink.sendPacket(data!, callback: nil)
    }
    
    private func sendReadRequest() {
        let commandPacket = LogGetInfoRequestPacket(header: CrazyFlieHeader.logging.rawValue)
        let data = PacketCreator.data(fromGetInfo: commandPacket)
        bluetoothLink.sendPacket(data!, callback: nil)
    }
    
    private func sendReadDataRequest() {
        let commandPacket = LogGetInfoRequestPacket(header: CrazyFlieHeader.logging.rawValue)
        let data = PacketCreator.data(fromGetInfo: commandPacket)
        bluetoothLink.sendPacket(data!, callback: nil)
    }
}
