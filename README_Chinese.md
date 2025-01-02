# 使用说明文档

## 简介

`JLBlueLink` 是一个用于蓝牙设备连接和管理的框架，提供蓝牙扫描、连接和数据传输等功能。本文档将指导您如何使用该框架。

## 主要组件

### 1. JLBleEntity

表示一个蓝牙设备实体，具有以下属性和方法：

#### 属性

- `_rssi`：蓝牙信号强度。
- `_device`：蓝牙设备对象（`CBPeripheral`）。
- `_advData`：广播数据。
- `_uid`：设备 UID。
- `_pid`：设备 PID。
- `_advInfo`：设备的高级信息。

#### 方法

- `rssi()`：获取蓝牙信号强度。
- `device()`：获取蓝牙设备对象。
- `advData()`：获取广播数据。
- `uid()`：获取设备 UID。
- `pid()`：获取设备 PID。
- `advInfo()`：获取设备的高级信息。

### 2. JLBlueLinkProtocol

蓝牙连接协议定义了连接过程中的回调事件：

#### 方法

- `didUpdateState(state: CBManagerState)`：更新蓝牙状态。
- `didUpdateDevices(devices: [JLBleEntity])`：更新蓝牙设备列表。
- `didConnectedDevices(devices: [JLDeviceHandler])`：更新已连接设备列表。
- `didCurrentDevice(device: JLDeviceHandler?)`：更新当前连接设备。
- `didDisConnectDevice(device: JLDeviceHandler)`：处理设备断开连接事件。
- `didIsScaning(isScaning: Bool)`：处理扫描状态。

### 3. JLBlueManager

蓝牙管理类，负责设备扫描、连接和管理。

#### 关键属性

- `shared`：单例对象。
- `devices`：已发现的蓝牙设备列表。
- `connectedDevices`：已连接的蓝牙设备列表。
- `currentHandler`：当前连接设备的句柄。
- `isScaning`：当前扫描状态。
- `config`：连接配置对象。

#### 关键方法

- `addListener(_ listener: JLBlueLinkProtocol)`：添加监听器。
- `removeListener(_ listener: JLBlueLinkProtocol)`：移除监听器。
- `bleScan()`：开始扫描蓝牙设备。
- `stopScan()`：停止扫描蓝牙设备。
- `connectDevice(_ device: CBPeripheral)`：连接指定蓝牙设备。
- `disconnectDevice(_ device: CBPeripheral)`：断开指定蓝牙设备。
- `registerForConnections(_ uuids: [String])`：注册连接事件。
- `findAncsDevices(_ uuids: [String]) -> [JLBleEntity]`：查找已连接的 ANCS 蓝牙设备。

### 4. JLCommonDefine

定义了蓝牙服务和特性 UUID：

- `JLBlueLinkVersion`：当前版本。
- `serviceUUID`：服务 UUID。
- `writeCharUUID`：写特性 UUID。
- `noteCharUUID`：通知特性 UUID。

### 5. JLConnectConfig

连接配置类，定义蓝牙设备连接的参数：

- `mWriteUUID`：写特性 UUID。
- `mNoteUUID`：通知特性 UUID。
- `mServiceUUID`：服务 UUID。
- `mNeedPaired`：是否需要配对。
- `mLogDetail`：是否打印详细日志。

### 6. JLDeviceHandler

扩展 `JL_Assist`，用于管理多个设备连接和单个设备的操作。

### 7. JLScanFilter

扫描过滤器类：

- `needBleName`：是否过滤蓝牙名称。
- `filterName`：要过滤的蓝牙名称。
- `timeout`：扫描超时时间。
- `filter(_ device: CBPeripheral)`：检查设备是否符合过滤条件。

## 使用步骤

### 1. 初始化蓝牙管理器

```swift
let manager = JLBlueManager.shared
```

### 2. 添加监听器

实现 `JLBlueLinkProtocol` 并将其添加为监听器。

```swift
manager.addListener(self)
```

### 3. 开始扫描

```swift
manager.bleScan()
```

### 4. 停止扫描

```swift
manager.stopScan()
```

### 5. 连接设备

```swift
if let device = manager.devices.first?.device() {
    manager.connectDevice(device)
}
```

### 6. 断开设备

```swift
if let device = manager.currentHandler?.peripheral {
    manager.disconnectDevice(device)
}
```

## UI 集成示例

以下示例演示如何将 `JLBlueLink` 集成到视图控制器中，用于管理蓝牙设备：

### 示例代码

```swift
import UIKit
import JLBlueLink
import RxSwift
import RxCocoa
import SnapKit
import MJRefresh
import CoreBluetooth

class ViewController: UIViewController {

    let subTableView = UITableView()
    let connectedTable = UITableView()
    let connectTitleLab = UILabel()
    let scanTitleLab = UILabel()
    let scanBtn = UIButton()

    let connectedItems = BehaviorRelay<[JLDeviceHandler]>(value: [])
    let findItems = BehaviorRelay<[JLBleEntity]>(value: [])

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
        bindUIData()
    }

    func initUI() {
        view.backgroundColor = .white
        view.addSubview(scanBtn)
        view.addSubview(connectTitleLab)
        view.addSubview(connectedTable)
        view.addSubview(scanTitleLab)
        view.addSubview(subTableView)

        scanBtn.setTitle("扫描", for: .normal)
        scanBtn.backgroundColor = .blue
        scanBtn.setTitleColor(.white, for: .normal)
        scanBtn.layer.cornerRadius = 10
        scanBtn.layer.masksToBounds = true

        connectTitleLab.text = "已连接设备"
        connectTitleLab.textColor = .black
        scanTitleLab.text = "扫描设备"
        scanTitleLab.textColor = .black

        connectedTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        connectedTable.rowHeight = 50

        subTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        subTableView.rowHeight = 50
        let headRefresh = MJRefreshNormalHeader { [weak self] in
            guard let self = self else { return }
            JLBlueManager.shared.bleScan()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                JLBlueManager.shared.stopScan()
                self.subTableView.mj_header?.endRefreshing()
            }
        }
        subTableView.mj_header = headRefresh

        scanBtn.snp.makeConstraints { make in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(view).offset(100)
            make.height.equalTo(40)
        }

        connectTitleLab.snp.makeConstraints { make in
            make.left.equalTo(view).offset(20)
            make.top.equalTo(scanBtn.snp.bottom).offset(8)
        }

        connectedTable.snp.makeConstraints { make in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(200)
            make.top.equalTo(connectTitleLab.snp.bottom)
        }

        scanTitleLab.snp.makeConstraints { make in
            make.left.equalTo(view).offset(20)
            make.top.equalTo(connectedTable.snp.bottom).offset(8)
        }

        subTableView.snp.makeConstraints { make in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(scanTitleLab.snp.bottom)
            make.bottom.equalTo(view).offset(-20)
        }
    }

    func bindUIData() {
        connectedItems.bind(to: connectedTable.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { row, item, cell in
            cell.textLabel?.text = item.peripheral.name
        }.disposed(by: disposeBag)

        findItems.bind(to: subTableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { row, item, cell in
            cell.textLabel?.text = item.device()?.name
        }.disposed(by: disposeBag)

        subTableView.rx.modelSelected(JLBleEntity.self).subscribe(onNext: { item in
            guard let device = item.device() else { return }
            JLBlueManager.shared.connectDevice(device)
        }).disposed(by: disposeBag)

        scanBtn.rx.tap.subscribe(onNext: {
            JLBlueManager.shared.bleScan()
        }).disposed(by: disposeBag)
    }

    func initData() {
        JLBlueManager.shared.addListener(self)
        JLBlueManager.shared.bleScan()
    }
}

extension ViewController: JLBlueLinkProtocol {

    func didIsScaning(isScaning: Bool) {}

    func didUpdateState(state: CBManagerState) {
        if state == .poweredOn {
            JLBlueManager.shared.registerForConnections([JLCommonDefine.serviceUUID])
        }
    }

    func didUpdateDevices(devices: [JLBleEntity]) {
        findItems.accept(devices)
    }

    func didConnectedDevices(devices: [JLDeviceHandler]) {
        connectedItems.accept(devices)
    }

    func didCurrentDevice(device: JLDeviceHandler?) {}

    func didDisConnectDevice(device: JLDeviceHandler) {}
}
```

## 注意事项

1. 确保在调用蓝牙相关方法之前启用了蓝牙权限。

2. 在主线程更新 UI。

3. 确保设备未被其他应用占用。

4. 注册GATT Over Edr 连接，需要填入设备对应的支持服务 UUID，所搜到的设备会在 didUpdateDevices 中回调.

   ```swift
    func didUpdateState(state: CBManagerState) {
           if state == .poweredOn {
               JLBlueManager.shared.registerForConnections([JLCommonDefine.serviceUUID])
           }
       }
   ```

   

## 版本

- 当前版本：`JLBlueLinkVersion 1.0.0`

## 常见问题

- **无法发现设备**：确保已开启蓝牙并授予应用扫描权限。
- **连接失败**：确保设备未连接到其他设备且靠近手机。
- **扫描超时**：调整扫描过滤器的 `timeout` 参数。