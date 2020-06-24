//
//  DWPhotoPickerViewController.swift
//  DWPhotoPickerDemo
//
//  Created by Davy on 2020/6/22.
//  Copyright © 2020 Davy. All rights reserved.
//

import UIKit
import Photos

class DWPhotoPickerViewController: UIViewController {
    
    var collectionView: UICollectionView?
    
    var albumItem: DWAlbumItem? /// 本相册数据
    
    var block: DWSelectPhotoBlock? /// 确定回调

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
        uploadRight()
    }
    
    func setupNav() {
        navigationItem.title = albumItem?.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确定", style: .plain, target: self, action: #selector(clickOK))
    }

    func setup() {
        let config = PhotoPickerManager.config
        
        let cellMargin = CGFloat(config.cellMargin) /// 间隙
        let count = CGFloat(config.cellCount) /// 横排个数
        let cellW = (view.bounds.width - (cellMargin * (count + 1.0))) / count /// cell宽度
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = cellMargin
        flowLayout.minimumLineSpacing = cellMargin
        flowLayout.itemSize = CGSize(width: cellW, height: cellW)
        flowLayout.sectionInset = UIEdgeInsets(top: cellMargin, left: cellMargin, bottom: cellMargin, right: cellMargin)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(DWPhotoPickerViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.backgroundColor = UIColor.white
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        view.backgroundColor = UIColor.white
        view.addSubview(collectionView!)
    }
    
    func uploadRight() {
        var title = "确定"
        let count = PhotoPickerManager.selectAssets.count
        if count > 0 { title = "(\(count)) 确定" }
        navigationItem.rightBarButtonItem?.title = title
    }
    
    @objc func clickOK() {
        navigationController?.popViewController(animated: false)
        block?(PhotoPickerManager.selectAssets)
    }
    
    deinit {
        PhotoPickerManager.cleanCacheAssets()
        print("deinit -> DWPhotoPickerViewController")
    }
}

extension DWPhotoPickerViewController: UICollectionViewDataSource, UICollectionViewDelegate, DWPhotoPickerCellProtocol {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumItem?.result.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DWPhotoPickerViewCell
        let asset = self.albumItem?.result[indexPath.row]
        cell.uploadCell(result: asset!)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let vc = DWPhotoDetailViewController()
        vc.albumItem = albumItem
        vc.index = indexPath.row
        vc.block = {[weak self] (assets) in
            self?.navigationController?.popViewController(animated: false)
            self?.block?(assets)
        }
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func uploadAsset(asset: DWAsset, isSelected: Bool) {
        
        if isSelected { /// 添加
            PhotoPickerManager.addSelectAsset(asset: asset)
        } else { /// 删除
            PhotoPickerManager.removeSelectAsset(asset: asset)
        }
        
        collectionView?.reloadData()
        uploadRight()
    }
}

