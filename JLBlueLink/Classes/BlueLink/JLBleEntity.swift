//
//  JLBleEntity.swift
//  JLBlueLink_Example
//
//  Created by EzioChan on 2024/12/25.
//  Copyright © 2024 Jieli. All rights reserved.
//

import CoreBluetooth
import JL_AdvParse
import UIKit

@objcMembers public class JLBleEntity: NSObject {
    private var _rssi: NSNumber = 0
    private var _device: CBPeripheral?
    private var _advData: [String: Any]?
    private var _uid: UInt16 = 0
    private var _pid: UInt16 = 0
    private var _advInfo: JLDevicesAdv?

    public init(device: CBPeripheral, rssi: NSNumber, advData: [String: Any]?) {
        super.init()
        _device = device
        _rssi = rssi
        _advData = advData
        if let manufactureData = advData?["kCBAdvDataManufacturerData"] as? Data {
            if let advInfo = JLDevicesAdv.advertData(toModel: manufactureData) {
                _advInfo = advInfo
                _uid = advInfo.uid
                _pid = advInfo.pid
            }
        }
    }

    public func rssi() -> NSNumber {
        return _rssi
    }

    public func device() -> CBPeripheral? {
        return _device
    }

    public func advData() -> [String: Any]? {
        return _advData
    }

    public func uid() -> UInt16 {
        return _uid
    }

    public func pid() -> UInt16 {
        return _pid
    }

    public func advInfo() -> JLDevicesAdv? {
        return _advInfo
    }
}
