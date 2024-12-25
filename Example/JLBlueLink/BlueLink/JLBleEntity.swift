//
//  JLBleEntity.swift
//  JLBlueLink_Example
//
//  Created by EzioChan on 2024/12/25.
//  Copyright © 2024 Jieli. All rights reserved.
//

import UIKit
import JL_AdvParse
import CoreBluetooth

@objcMembers public class JLBleEntity: NSObject {
    private var _rssi: NSNumber = 0
    private var _device: CBPeripheral?
    private var _advData: [String:Any]?
    private var _uid: UInt16 = 0
    private var _pid: UInt16 = 0
    
    init(device:CBPeripheral, rssi:NSNumber, advData:[String:Any]?) {
        super.init()
        self._device = device
        self._rssi = rssi
        self._advData = advData
        
    }
    
    public func rssi() -> NSNumber {
        return self._rssi
    }
    
    public func device() -> CBPeripheral? {
        return self._device
    }
    
    public func advData() -> [String:Any]? {
        return self._advData
    }

}
