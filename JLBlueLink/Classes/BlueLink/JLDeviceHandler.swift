//
//  JLDeviceHandler.swift
//  JLBlueLink_Example
//
//  Created by EzioChan on 2024/12/26.
//  Copyright © 2024 Jieli. All rights reserved.
//

import CoreBluetooth
import JL_BLEKit
import UIKit

/// 扩展JL_Assist 用于多设备连接
/// extend JL_Assist for devices connect
@objcMembers public class JLDeviceHandler: JL_Assist {
    /// 设备
    /// device
    public var peripheral: CBPeripheral

    public init(_ peripheral: CBPeripheral, _ config: JLConnectConfig) {
        self.peripheral = peripheral
        super.init()
        mService = config.mServiceUUID
        mRcsp_W = config.mWriteUUID
        mRcsp_R = config.mNoteUUID
        mNeedPaired = config.mNeedPaired
        mLogData = config.mLogDetail
    }
}
