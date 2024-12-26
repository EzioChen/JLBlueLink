//
//  JLConnectConfig.swift
//  JLBlueLink_Example
//
//  Created by EzioChan on 2024/12/26.
//  Copyright © 2024 Jieli. All rights reserved.
//

import UIKit

/// 连接配置
/// Connection configuration
@objcMembers public class JLConnectConfig: NSObject {
    /// 写入UUID
    /// Write UUID
    public var mWriteUUID = JLCommonDefine.writeCharUUID
    /// 通知UUID
    /// Notification UUID
    public var mNoteUUID = JLCommonDefine.noteCharUUID
    /// 服务UUID
    /// Service UUID
    public var mServiceUUID = JLCommonDefine.serviceUUID
    /// 是否需要配对
    /// Whether to pair
    public var mNeedPaired = true
    /// 打印更详细的数据
    /// Print more detailed data
    public var mLogDetail = false
    override public init() {
        super.init()
    }
}
