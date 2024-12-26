//
//  JLScanFilter.swift
//  JLBlueLink_Example
//
//  Created by EzioChan on 2024/12/26.
//  Copyright © 2024 Jieli. All rights reserved.
//

import CoreBluetooth
import UIKit

/// 扫描过滤
/// Scan filter
@objcMembers public class JLScanFilter: NSObject {
    /// 是否需要过滤蓝牙名称
    /// Whether to filter the Bluetooth name
    public var needBleName: Bool = true
    /// 蓝牙名称
    /// Bluetooth name
    public var filterName: String = ""

    /// 搜索超时时间
    /// Search timeout
    public var timeout: Double = 4

    /// 过滤蓝牙设备
    /// Filter Bluetooth devices
    /// - Parameter device: device
    public func filter(_ device: CBPeripheral) -> Bool {
        let devName = device.name ?? ""
        if device.name == nil {
            if needBleName {
                return false
            } else {
                return true
            }
        }
        if needBleName && devName.contains(filterName) {
            return false
        }
        return true
    }
}
