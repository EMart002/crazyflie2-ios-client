//
//  TypeConverter.swift
//  Crazyflie client
//
//  Created by Martin Eberl on 16.02.17.
//  Copyright © 2017 Bitcraze. All rights reserved.
//

import Foundation

class TypeConverter<T>: NSObject {
    
    static func toByteArray(_ value: T) -> [UInt8] {
        var value = value
        return withUnsafePointer(to: &value) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<T>.size) {
                Array(UnsafeBufferPointer(start: $0, count: MemoryLayout<T>.size))
            }
        }
    }
    
    static func fromByteArray(_ value: [UInt8]) -> T {
        return value.withUnsafeBufferPointer {
            $0.baseAddress!.withMemoryRebound(to: T.self, capacity: 1) {
                $0.pointee
            }
        }
    }
}
