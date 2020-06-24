//
//  DWPhotoDetailViewController.swift
//  DWPhotoPickerDemo
//
//  Created by Davy on 2020/6/19.
//  Copyright © 2020 Davy. All rights reserved.
//

import UIKit
import Photos

class DWPhotoDetailViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool { true }
    
    var collectionView: UICollectionView?
    
    var albumItem: DWAlbumItem! /// 相册数据
    
    var block: DWSelectPhotoBlock? /// 确定回调
    
    var selectBtn: UIButton! /// 选中按钮
    
    var index: Int! /// 图片位于相册的角标
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupCollectionView()
        setupBottomView()
        uploadSelect()
    }
    
    func setupCollectionView() {
        let cellMargin = CGFloat(PhotoPickerManager.config.photoMargin)
        
        let cellH = view.bounds.height - cellMargin * 2 /// cell高度
        let cellW = view.bounds.width - cellMargin * 2 /// cell宽度
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = cellMargin * 2
        flowLayout.minimumInteritemSpacing = cellMargin * 2
        flowLayout.itemSize = CGSize(width: cellW, height: cellH)
        flowLayout.sectionInset = UIEdgeInsets(top: cellMargin, left: cellMargin, bottom: cellMargin, right: cellMargin)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(DWPhotoDetailViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.backgroundColor = UIColor.black
        collectionView?.isPagingEnabled = true
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        view.backgroundColor = UIColor.white
        view.addSubview(collectionView!)
        
        collectionView?.setContentOffset(CGPoint(x: view.bounds.width * CGFloat(index), y: 0), animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.375) {
            if let cell = self.collectionView?.visibleCells.first as? DWPhotoDetailViewCell {
                let asset = self.albumItem.result[self.index]
                cell.uploadCell(result: asset, size: PhotoPickerManager.config.originalSize)
            }
        }
    }
    
    func setupBottomView() {
        let bottom = UIView(frame: CGRect(x: 0, y: view.bounds.height - 80, width: view.bounds.width, height: 80))
        bottom.backgroundColor = UIColor.black
        
        let sureBtn = UIButton(type: .custom)
        sureBtn.frame = CGRect(x: view.bounds.width - 80, y: 10, width: 65, height: 30)
        sureBtn.backgroundColor = UIColor(red: 52/255.0, green: 212/255.0, blue: 172/255.0, alpha: 1.0)
        sureBtn.addTarget(self, action: #selector(clickOK), for: UIControl.Event.touchUpInside)
        sureBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        sureBtn.setTitle("确定", for: UIControl.State.normal)
        sureBtn.layer.cornerRadius = 3.0
        
        if isMultiSelect() {
            selectBtn = UIButton(type: .custom)
            selectBtn.frame = CGRect(x: 15, y: 10, width: 30, height: 30)
            selectBtn.setBackgroundImage(UIImage(named: "check_off"), for: UIControl.State.normal)
            selectBtn.setBackgroundImage(UIImage(named: "check_on"), for: UIControl.State.selected)
            selectBtn.addTarget(self, action: #selector(clickSelect(sender:)), for: UIControl.Event.touchUpInside)
            bottom.addSubview(selectBtn)
        }
        
        bottom.addSubview(sureBtn)
        view.addSubview(bottom)
    }
    
    func uploadSelect() {
        if isMultiSelect() {
            let asset = albumItem.result[index]
            selectBtn.isSelected = asset.isSelected
            let title = asset.isSelected ? "\(asset.index! + 1)" : ""
            selectBtn.setTitle(title, for: UIControl.State.normal)
        }
    }
    
    @objc func clickOK() {
        if !isMultiSelect() { /// 单选
            selectCurrentImage()
        }
        dismiss(animated: false, completion: nil)
        block?(PhotoPickerManager.selectAssets)
    }
    
    @objc func clickSelect(sender: UIButton) {
        if isMultiSelect() {
            let asset = albumItem.result[index]
            if !sender.isSelected {
                PhotoPickerManager.addSelectAsset(asset: asset)
            } else {
                PhotoPickerManager.removeSelectAsset(asset: asset)
            }
            uploadSelect()
        }
    }
    
    /// 添加当前图片
    func selectCurrentImage() {
        let asset = albumItem.result[index]
        PhotoPickerManager.addSelectAsset(asset: asset)
    }
    
    /// 是否是多选
    func isMultiSelect() -> Bool {
        return PhotoPickerManager.config.maxCount > 1
    }
    
    func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("deinit -> DWPhotoDetailViewController")
    }
}

extension DWPhotoDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, DWPhotoDetailViewCellProtocol {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumItem.result.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DWPhotoDetailViewCell
        let asset = albumItem.result[indexPath.row]
        cell.uploadCell(result: asset, size: PhotoPickerManager.config.thumbnailSize)
        cell.delegate = self
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let cell = collectionView?.visibleCells.first as? DWPhotoDetailViewCell else { return }
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        let asset = albumItem.result[indexPath.row]
        cell.uploadCell(result: asset, size: PhotoPickerManager.config.originalSize)
        index = indexPath.row
        uploadSelect()
    }
    
    func tapCell() {
        dismissVC()
    }
}
