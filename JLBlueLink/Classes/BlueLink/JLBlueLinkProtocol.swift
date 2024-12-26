//
//  JLBlueLinkProtocol.swift
//
//  Created by EzioChan on 2024/12/25.
//  Copyright © 2024 Jieli. All rights reserved.
//

import CoreBluetooth
import UIKit

/// 蓝牙连接协议
/// Bluetooth connection protocol
public protocol JLBlueLinkProtocol: NSObject {
    /// 更新蓝牙状态
    /// Update Bluetooth status
    func didUpdateState(state: CBManagerState)

    /// 更新蓝牙设备
    /// Update Bluetooth devices
    func didUpdateDevices(devices: [JLBleEntity])

    /// 更新连接设备
    /// Update connected devices
    func didConnectedDevices(devices: [JLDeviceHandler])

    /// 更新当前连接设备
    /// Update the currently connected device
    func didCurrentDevice(device: JLDeviceHandler?)

    /// 断开连接设备
    /// Disconnect device
    func didDisConnectDevice(device: JLDeviceHandler)

    /// 是否正在扫描
    /// - Parameter isScaning: isScaning
    func didIsScaning(isScaning: Bool)
}
