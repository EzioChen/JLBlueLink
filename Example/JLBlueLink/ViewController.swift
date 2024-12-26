//
//  ViewController.swift
//  JLBlueLink
//
//  Created by 16433934 on 12/25/2024.
//  Copyright (c) 2024 16433934. All rights reserved.
//

import UIKit
import JLBlueLink
import RxSwift
import RxCocoa
import SnapKit
import MJRefresh
import CoreBluetooth
import JL_BLEKit


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
            guard let self = self else {return}
            JLBlueManager.shared.bleScan()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: DispatchWorkItem(block: {
                JLBlueManager.shared.stopScan()
                self.subTableView.mj_header?.endRefreshing()
            }))
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
        
        findItems.bind(to: subTableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) {
            row, item, cell in
            cell.textLabel?.text = item.device()?.name
        }.disposed(by: disposeBag)
        
        subTableView.rx.modelSelected(JLBleEntity.self).subscribe(onNext: { item in
            guard let device = item.device() else {
                return
            }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: JLBlueLinkProtocol {
    
    func didIsScaning(isScaning: Bool) {
       
    }
    
    func didUpdateState(state: CBManagerState) {
       if state == .poweredOn {
           /// 注册GATT Over Edr 连接，这里需要填入设备对应的支持服务 UUID，所搜到的设备会在 didUpdateDevices 中回调
           /// Register GATT Over Edr connection, here you need to fill in the service UUID supported by the device, the devices found will be returned in didUpdateDevices
           JLBlueManager.shared.registerForConnections([JLCommonDefine.serviceUUID])
       }
    }
    
    func didUpdateDevices(devices: [JLBleEntity]) {
        findItems.accept(devices)
    }
    
    func didConnectedDevices(devices: [JLDeviceHandler]) {
        connectedItems.accept(devices)
    }
    
    func didCurrentDevice(device: JLDeviceHandler?) {
        
    }
    
    func didDisConnectDevice(device: JLDeviceHandler) {
        
    }
}
