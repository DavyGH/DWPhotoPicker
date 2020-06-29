//
//  DWAlbumListViewController.swift
//  DWPhotoPickerDemo
//
//  Created by Davy on 2020/6/19.
//  Copyright © 2020 Davy. All rights reserved.
//

import UIKit
import Photos

typealias DWSelectPhotoBlock = (_ assets: [DWAsset]) -> Void

class DWAlbumListViewController: UIViewController {
    
    var tableView: UITableView?
    
    var albumLists = [DWAlbumItem]() /// 整个相册数据
    
    var block: DWSelectPhotoBlock? /// 确定回调

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        getAlbumList()
        setupTableView()
    }
    
    func setupNav() {
        navigationItem.title = "照片"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func setupTableView() {
        tableView = UITableView(frame: view.bounds)
        tableView?.tableHeaderView = UIView()
        tableView?.tableFooterView = UIView()
        tableView?.rowHeight = 56.0
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(DWAlbumListViewCell.self, forCellReuseIdentifier: "cell")
        
        view.backgroundColor = UIColor.white
        view.addSubview(tableView!)
    }

    func getAlbumList() {
        PhotoPickerManager.checkAuthorized {[weak self] (isAuthorized) in
            if isAuthorized == false {
                DispatchQueue.main.async {
                    print("没有授权哟")
                }
                return
            }
            
            DispatchQueue.main.async {
                if PhotoPickerManager.allResults.count > 0 {
                    self?.albumLists = PhotoPickerManager.allResults
                    self?.pushToImagePickerVC(index: 0, animated: false)
                    self?.tableView?.reloadData()
                }
            }
        }
    }
    
    func pushToImagePickerVC(index: Int, animated: Bool) {
        if albumLists.count > 0 {
            let vc = DWPhotoPickerViewController()
            vc.albumItem = albumLists[index]
            
            vc.block = {[weak self] (assets) in
                self?.dismiss(animated: true, completion: nil)
                self?.block?(assets)
            }
            
            navigationController?.pushViewController(vc, animated: animated)
        }
    }
    
    deinit {
        PhotoPickerManager.cleanAlbum()
        PhotoPickerManager.cleanSelectAssets()
        PhotoPickerManager.cleanCacheAssets()
        print("deinit -> DWAlbumListViewController")
    }
}

extension DWAlbumListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DWAlbumListViewCell
        cell.uploadCell(albumLists[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        pushToImagePickerVC(index: indexPath.row, animated: true)
    }
}
