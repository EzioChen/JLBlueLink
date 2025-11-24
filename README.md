# JLBlueLink

[![CI](https://github.com/EzioChen/JLBlueLink/actions/workflows/ci.yml/badge.svg)](https://github.com/EzioChen/JLBlueLink/actions/workflows/ci.yml)
[![Version](https://img.shields.io/cocoapods/v/JLBlueLink.svg?style=flat)](https://cocoapods.org/pods/JLBlueLink)
[![License](https://img.shields.io/cocoapods/l/JLBlueLink.svg?style=flat)](https://cocoapods.org/pods/JLBlueLink)
[![Platform](https://img.shields.io/cocoapods/p/JLBlueLink.svg?style=flat)](https://cocoapods.org/pods/JLBlueLink)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

JLBlueLink is available through [CocoaPods](https://cocoapods.org). 

`JLBlueLink` is a framework for Bluetooth device connection and management, providing functions such as Bluetooth scanning, connection, and data transmission. This document will guide you on how to use this framework.

```ruby
pod 'JLBlueLink'
```
## User Manual([中文](https://github.com/EzioChen/JLBlueLink/blob/main/README_Chinese.md))

## Key Components

### 1. JLBleEntity

Represents a Bluetooth device entity with the following properties and methods:

#### Properties

- `_rssi`: Bluetooth signal strength.
- `_device`: Bluetooth device object (`CBPeripheral`).
- `_advData`: Advertisement data.
- `_uid`: Device UID.
- `_pid`: Device PID.
- `_advInfo`: Advanced device information.

#### Methods

- `rssi()`: Get the Bluetooth signal strength.
- `device()`: Get the Bluetooth device object.
- `advData()`: Get the advertisement data.
- `uid()`: Get the device UID.
- `pid()`: Get the device PID.
- `advInfo()`: Get the advanced device information.

### 2. JLBlueLinkProtocol

The Bluetooth connection protocol defines callback events during the connection process:

#### Methods

- `didUpdateState(state: CBManagerState)`: Update Bluetooth status.
- `didUpdateDevices(devices: [JLBleEntity])`: Update the list of Bluetooth devices.
- `didConnectedDevices(devices: [JLDeviceHandler])`: Update the list of connected devices.
- `didCurrentDevice(device: JLDeviceHandler?)`: Update the currently connected device.
- `didDisConnectDevice(device: JLDeviceHandler)`: Handle device disconnection events.
- `didIsScaning(isScaning: Bool)`: Handle scanning status.

### 3. JLBlueManager

The Bluetooth manager class is responsible for scanning, connecting, and managing devices.

#### Key Properties

- `shared`: Singleton object.
- `devices`: List of discovered Bluetooth devices.
- `connectedDevices`: List of connected Bluetooth devices.
- `currentHandler`: Handle for the currently connected device.
- `isScaning`: Current scanning status.
- `config`: Connection configuration object.

#### Key Methods

- `addListener(_ listener: JLBlueLinkProtocol)`: Add a listener.
- `removeListener(_ listener: JLBlueLinkProtocol)`: Remove a listener.
- `bleScan()`: Start scanning for Bluetooth devices.
- `stopScan()`: Stop scanning for Bluetooth devices.
- `connectDevice(_ device: CBPeripheral)`: Connect to a specified Bluetooth device.
- `disconnectDevice(_ device: CBPeripheral)`: Disconnect from a specified Bluetooth device.
- `registerForConnections(_ uuids: [String])`: Register connection events.
- `findAncsDevices(_ uuids: [String]) -> [JLBleEntity]`: Find connected ANCS Bluetooth devices.

### 4. JLCommonDefine

Defines UUIDs for Bluetooth services and characteristics:

- `JLBlueLinkVersion`: Current version.
- `serviceUUID`: Service UUID.
- `writeCharUUID`: Write characteristic UUID.
- `noteCharUUID`: Notification characteristic UUID.

### 5. JLConnectConfig

Connection configuration class defining parameters for Bluetooth device connections:

- `mWriteUUID`: Write characteristic UUID.
- `mNoteUUID`: Notification characteristic UUID.
- `mServiceUUID`: Service UUID.
- `mNeedPaired`: Whether pairing is required.
- `mLogDetail`: Whether to print detailed logs.

### 6. JLDeviceHandler

Extends `JL_Assist` for managing multiple device connections and operations for a single device.

### 7. JLScanFilter

Scan filter class:

- `needBleName`: Whether to filter Bluetooth names.
- `filterName`: Bluetooth name to filter.
- `timeout`: Scan timeout duration.
- `filter(_ device: CBPeripheral)`: Check if a device meets the filter criteria.

## Usage Steps

### 1. Initialize the Bluetooth Manager

```swift
let manager = JLBlueManager.shared
```

### 2. Add a Listener

Implement `JLBlueLinkProtocol` and add it as a listener.

```swift
manager.addListener(self)
```

### 3. Start Scanning

```swift
manager.bleScan()
```

### 4. Stop Scanning

```swift
manager.stopScan()
```

### 5. Connect to a Device

```swift
if let device = manager.devices.first?.device() {
    manager.connectDevice(device)
}
```

### 6. Disconnect from a Device

```swift
if let device = manager.currentHandler?.peripheral {
    manager.disconnectDevice(device)
}
```

## UI Integration Example

This example demonstrates how to integrate `JLBlueLink` into a view controller for managing Bluetooth devices:

### Code Example

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

        scanBtn.setTitle("Scan", for: .normal)
        scanBtn.backgroundColor = .blue
        scanBtn.setTitleColor(.white, for: .normal)
        scanBtn.layer.cornerRadius = 10
        scanBtn.layer.masksToBounds = true

        connectTitleLab.text = "Connected Devices"
        connectTitleLab.textColor = .black
        scanTitleLab.text = "Scan Devices"
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



## Notes

1. Ensure Bluetooth permissions are enabled before calling Bluetooth-related methods.
2. Update the UI on the main thread.
3. Ensure the device is not occupied by another app during connection.
4. Register GATT Over Edr connection, you need to fill in the service UUID supported by the device, the devices found will be returned in didUpdateDevices. 
    ```swift
        func didUpdateState(state: CBManagerState) {
            if state == .poweredOn {
                JLBlueManager.shared.registerForConnections([JLCommonDefine.serviceUUID])
            }
        }
    ```

## Version

- Current version: `JLBlueLinkVersion 1.0.0`

## FAQ

- **Unable to discover devices**: Ensure Bluetooth is enabled, and the app has permission to scan.
- **Connection failed**: Ensure the device is not connected to another device and is close to the phone.
- **Scan timeout**: Adjust the `timeout` parameter in the scan filter.
- **Other framework issues**: Please file an issue in the [JLBlueLink GitHub repository](https://github.com/16433934/JLBlueLink/issues).
- **Other framework usage**:[JLFrameworks](https://github.com/EzioChen/JLBlueLink/blob/main/JLFrameworks.md)


## Author

chenguanjie@zh-jieli.com

## License

Apache License, Version 2.0, January 2004 
