//
//  JLBlueManager.swift
//  JLBlueLink_Example
//
//  Created by EzioChan on 2024/12/25.
//  Copyright © 2024 Jieli. All rights reserved.
//

import UIKit
import CoreBluetooth
import JL_BLEKit

@objcMembers public class JLBlueManager: NSObject {
    static let shared = JLBlueManager()
    lazy var centerManager = {
        CBCentralManager(delegate: self, queue: .main)
    }()
    dynamic var devices:[JLBleEntity] = []
    dynamic var connectedDevices:[CBPeripheral] = []
    private var isReady:Bool = false
    
    override init() {
        super.init()
    }
    
    func bleScan() {
        devices = []
        centerManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScan() {
        centerManager.stopScan()
    }
    
    func connectDevice(_ device:CBPeripheral) {
        centerManager.connect(device, options: nil)
    }
    
    
    
    

}


extension JLBlueManager: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            if !isReady {
                centerManager.scanForPeripherals(withServices: nil, options: nil)
            }
            isReady = true
        } else {
            isReady = false
            JLLogManager.logLevel(.ERROR, content: "Ble is not ready")
        }
        
    }
}
