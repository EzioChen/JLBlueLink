//
//  JLBlueManager.swift
//  JLBlueLink_Example
//
//  Created by EzioChan on 2024/12/25.
//  Copyright © 2024 Jieli. All rights reserved.
//

import CoreBluetooth
import JL_BLEKit
import UIKit

@objcMembers public class JLBlueManager: NSObject {
    /// 单例化蓝牙连接库，外边可选择这个实现，避免多个蓝牙连接库不释放导致的异常问题
    /// Singleton implementation of the Bluetooth connection library, which can be selected outside to avoid exceptions caused by multiple Bluetooth connection libraries not being released
    public static let shared = JLBlueManager()

    /// 发现的蓝牙设备，外边可用 dynamic 监听变化
    /// The discovered Bluetooth devices, which can be used outside to listen for changes
    public dynamic var devices: [JLBleEntity] = []

    /// 连接的蓝牙设备，外边可用 dynamic 监听变化
    /// The connected Bluetooth devices, which can be used outside to listen for changes
    public dynamic var connectedDevices: [JLDeviceHandler] = []

    /// 连接的蓝牙设备，外边可用 dynamic 监听变化
    /// The connected Bluetooth devices, which can be used outside to listen for changes
    public dynamic var currentHandler: JLDeviceHandler?

    /// 是否在扫描中
    /// Whether the scan is in progress
    public dynamic var isScaning: Bool = false
    public lazy var centerManager = CBCentralManager(delegate: self, queue: .main)
    private var isReady: Bool = false
    private var tempHandler: JLDeviceHandler?
    private var filterDevice: JLScanFilter = .init()
    private var _config = JLConnectConfig()
    private var listener: [JLBlueLinkProtocol] = []
    /// 连接配置
    /// Connection configuration
    public var config: JLConnectConfig {
        get {
            return _config
        }
        set {
            _config = newValue
        }
    }

    /// 命令对象，用于作为收发命令的句柄
    /// Command object, used as a handle for sending and receiving commands
    public var cmdManager: JL_ManagerM? {
        currentHandler?.mCmdManager
    }

    override public init() {
        super.init()
    }

    /// 设备过滤,是否过滤杰理以外的设备
    /// Device filtering, whether to filter out Jieli devices
    /// - Parameter filter: filter
    public func filterDevice(_ filter: JLScanFilter) {
        filterDevice = filter
    }

    /// 添加监听
    /// Add listener
    /// - Parameter listener: listener
    public func addListener(_ listener: JLBlueLinkProtocol) {
        self.listener.append(listener)
    }

    /// 移除监听
    /// - Parameter listener: listener
    public func removeListener(_ listener: JLBlueLinkProtocol) {
        self.listener = self.listener.filter { $0 !== listener }
    }

    /// 开始扫描蓝牙设备
    /// Start scanning for Bluetooth devices
    public func bleScan() {
        devices = []
        beginScan()
        for listener in listener {
            listener.didIsScaning(isScaning: true)
        }
        isScaning = true
    }

    /// 停止扫描蓝牙设备
    /// Stop scanning for Bluetooth devices
    public func stopScan() {
        centerManager.stopScan()
        isScaning = false
        for listener in listener {
            listener.didIsScaning(isScaning: true)
        }
    }

    /// 连接蓝牙设备
    /// Connect Bluetooth devices
    /// - Parameter device: device
    public func connectDevice(_ device: CBPeripheral) {
        centerManager.connect(device, options: nil)
    }

    /// 断开蓝牙设备
    /// Disconnect Bluetooth devices
    /// - Parameter device: device
    public func disconnectDevice(_ device: CBPeripheral) {
        centerManager.cancelPeripheralConnection(device)
    }

    /// 注册连接事件，主要用于发现 GATT Over EDR 设备
    /// Register connection events, mainly used to find GATT Over EDR devices
    /// - Parameter uuids: device UUIDs
    public func registerForConnections(_ uuids: [String]) {
        var services: [CBUUID] = []
        for uuid in uuids {
            services.append(CBUUID(string: uuid))
        }
        if #available(iOS 13.0, *) {
            let machingUUID = [CBConnectionEventMatchingOption.serviceUUIDs: services]
            centerManager.registerForConnectionEvents(options: machingUUID)
        } else {
            // Fallback on earlier versions
            JLLogManager.logLevel(.ERROR, content: "iOS version is not support, please upgrade to iOS 13")
        }
    }

    /// 查找已连接的 ANCS 蓝牙设备
    /// Find connected ANCS Bluetooth devices
    /// - Parameter uuids: device UUID
    /// - Returns: Array of JLBleEntity
    public func findAncsDevices(_ uuids: [String]) -> [JLBleEntity] {
        var devices: [JLBleEntity] = []
        var uuidns: [CBUUID] = []
        for uuid in uuids {
            uuidns.append(CBUUID(string: uuid))
        }
        let array = centerManager.retrieveConnectedPeripherals(withServices: uuidns)
        for peripheral in array {
            let entity = JLBleEntity(device: peripheral, rssi: 0, advData: nil)
            devices.append(entity)
        }
        return devices
    }

    /// 查找已连接的设备
    /// Find connected devices
    /// - Parameter peripheral: device
    /// - Returns: JLDeviceHandler
    private func findDevice(_ peripheral: CBPeripheral) -> JLDeviceHandler? {
        for device in connectedDevices where
            device.peripheral.identifier.uuidString == peripheral.identifier.uuidString
        {
            return device
        }
        return nil
    }

    private func beginScan() {
        centerManager.scanForPeripherals(withServices: nil, options: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + filterDevice.timeout) { [weak self] in
            guard let self = self else {
                return
            }
            self.stopScan()
        }
    }
}

extension JLBlueManager: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isReady = true
            beginScan()
        } else {
            isReady = false
            JLLogManager.logLevel(.ERROR, content: "Ble is not ready")
        }
        for assistant in connectedDevices {
            assistant.assistUpdate(central.state)
        }
        for listener in listener {
            listener.didUpdateState(state: central.state)
        }
    }

    public func centralManager(_: CBCentralManager,
                               didDiscover peripheral: CBPeripheral,
                               advertisementData: [String: Any],
                               rssi RSSI: NSNumber)
    {
        let entity = JLBleEntity(device: peripheral, rssi: RSSI, advData: advertisementData)
        devices = devices.filter {
            $0.device()?.identifier.uuidString != peripheral.identifier.uuidString
        }
        JLLogManager.logLevel(.DEBUG,
                              content: "Find device name:\(peripheral.name ?? "") \nuuid: \(peripheral.identifier.uuidString)")
        if filterDevice.filter(peripheral) {
            devices.append(entity)
            for listener in listener {
                listener.didUpdateDevices(devices: devices)
            }
        }
    }

    public func centralManager(_: CBCentralManager,
                               connectionEventDidOccur event: CBConnectionEvent,
                               for peripheral: CBPeripheral)
    {
        switch event {
        case .peerConnected:
            JLLogManager.logLevel(.INFO,
                                  content: "peerConnected name:\(peripheral.name ?? "") uuid: \(peripheral.identifier.uuidString)")
            let entity = JLBleEntity(device: peripheral, rssi: 0, advData: nil)
            devices = devices.filter {
                $0.device()?.identifier.uuidString == peripheral.identifier.uuidString
            }
            devices.append(entity)
        case .peerDisconnected:
            JLLogManager.logLevel(.INFO,
                                  content: "peerDisconnected name:\(peripheral.name ?? "") uuid: \(peripheral.identifier.uuidString)")
            devices = devices.filter {
                $0.device()?.identifier.uuidString != peripheral.identifier.uuidString
            }
            connectedDevices = connectedDevices.filter {
                $0.peripheral.identifier.uuidString != peripheral.identifier.uuidString
            }
        }
        for listener in listener {
            listener.didUpdateDevices(devices: devices)
            listener.didConnectedDevices(devices: connectedDevices)
        }
    }

    public func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
        JLLogManager.logLevel(.INFO,
                              content: "Connect success name:\(peripheral.name ?? "") uuid: \(peripheral.identifier.uuidString)")
        tempHandler = JLDeviceHandler(peripheral, config)
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    public func centralManager(_: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        JLLogManager.logLevel(.ERROR,
                              content: "Connect failed:\(peripheral) reason:\(String(describing: error?.localizedDescription))")
        tempHandler = nil
    }

    public func centralManager(_: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        JLLogManager.logLevel(.ERROR,
                              content: "Disconnect:\(peripheral) reason:\(String(describing: error?.localizedDescription))")
        guard let assistant = findDevice(peripheral) else {
            return
        }
        assistant.assistDisconnectPeripheral(peripheral)
        connectedDevices = connectedDevices.filter {
            $0.peripheral.identifier.uuidString != peripheral.identifier.uuidString
        }
        if peripheral.identifier.uuidString == currentHandler?.peripheral.identifier.uuidString {
            if connectedDevices.count > 0 {
                JLLogManager.logLevel(.INFO,
                                      content: "Switch to:\(connectedDevices.first?.peripheral.identifier.uuidString ?? "")")
                currentHandler = connectedDevices.first
            } else {
                currentHandler = nil
                JLLogManager.logLevel(.INFO, content: "Switch to nil")
            }
        }
        for listener in listener {
            listener.didConnectedDevices(devices: connectedDevices)
            listener.didCurrentDevice(device: currentHandler)
            listener.didDisConnectDevice(device: assistant)
        }
    }
}

extension JLBlueManager: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices _: (any Error)?) {
        for service in peripheral.services ?? [] {
            JLLogManager.logLevel(.DEBUG, content: "uuid:\(service.uuid.uuidString)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error _: (any Error)?) {
        guard let assistant = findDevice(peripheral) ?? tempHandler else {
            return
        }
        assistant.assistDiscoverCharacteristics(for: service, peripheral: peripheral)
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error _: (any Error)?) {
        guard let assistant = findDevice(peripheral) ?? tempHandler else {
            return
        }
        assistant.assistUpdate(characteristic, peripheral: peripheral) { [weak self] connectStatus in
            guard let self = self else {
                return
            }
            if connectStatus {
                JLLogManager.logLevel(.INFO,
                                      content: "Pairing success:\(peripheral)")
                self.connectedDevices.append(assistant)
                self.currentHandler = assistant
                self.tempHandler = nil
                devices = devices.filter {
                    $0.device()?.identifier.uuidString != peripheral.identifier.uuidString
                }
                for listener in listener {
                    listener.didUpdateDevices(devices: devices)
                    listener.didConnectedDevices(devices: connectedDevices)
                    listener.didCurrentDevice(device: assistant)
                }
            } else {
                JLLogManager.logLevel(.ERROR,
                                      content: "Pairing failed:\(peripheral)")
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error _: (any Error)?) {
        guard let assistant = findDevice(peripheral) ?? tempHandler else {
            return
        }
        assistant.assistUpdateValue(for: characteristic)
    }
}
