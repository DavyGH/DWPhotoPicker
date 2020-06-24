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
        tableView?.register(DWAlbumListCell.self, forCellReuseIdentifier: "cell")
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DWAlbumListCell
        cell.uploadCell(albumLists[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        pushToImagePickerVC(index: indexPath.row, animated: true)
    }
}

class DWAlbumListCell: UITableViewCell {
    
    var iconView: UIImageView!
    
    var titleLabel: UILabel!
    
    var numberLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        iconView = UIImageView(frame: CGRect(x: 8, y: 8, width: 40, height: 40))
        iconView.contentMode = .scaleAspectFill
        iconView.clipsToBounds = true
        contentView.addSubview(iconView)
        
        titleLabel = UILabel(frame: CGRect(x: 56, y: 20, width: 100, height: 16))
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textAlignment = NSTextAlignment.left
        titleLabel.numberOfLines = 1
        contentView.addSubview(titleLabel)
        
        numberLabel = UILabel(frame: CGRect(x: 156, y: 20, width: 100, height: 16))
        numberLabel.textColor = UIColor.lightGray
        numberLabel.font = UIFont.systemFont(ofSize: 16)
        numberLabel.textAlignment = NSTextAlignment.left
        numberLabel.numberOfLines = 1
        contentView.addSubview(numberLabel)
    }
    
    func uploadCell(_ item: DWAlbumItem) {
        titleLabel.text = item.title
        numberLabel.text = "（\(item.result.count)）"

        if let asset = item.result.first?.asset {
            PhotoPickerManager.requestImage(asset: asset, size: PhotoPickerManager.config.thumbnailSize) {[weak self] (image) in
                self?.iconView.image = image
            }
        }
    }
}
