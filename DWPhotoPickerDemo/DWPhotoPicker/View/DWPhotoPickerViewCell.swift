//
//  DWPhotoPickerViewCell.swift
//  DWPhotoPickerDemo
//
//  Created by Davy on 2020/6/22.
//  Copyright © 2020 Davy. All rights reserved.
//

import UIKit

protocol DWPhotoPickerCellProtocol: class {
    func uploadAsset(asset: DWAsset, isSelected: Bool)
}

class DWPhotoPickerViewCell: UICollectionViewCell {
    
    weak var delegate: DWPhotoPickerCellProtocol?
    
    var iconView: UIImageView!
    
    var selectBtn: UIButton!
    
    var asset: DWAsset?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        iconView = UIImageView(frame: contentView.bounds)
        iconView.contentMode = .scaleAspectFill
        iconView.clipsToBounds = true
        contentView.addSubview(iconView)
        
        selectBtn = UIButton(type: .custom)
        selectBtn.frame = CGRect(x: contentView.bounds.width - 33, y: 3, width: 30, height: 30)
        selectBtn.setBackgroundImage(UIImage(named: "check_off"), for: UIControl.State.normal)
        selectBtn.setBackgroundImage(UIImage(named: "check_on"), for: UIControl.State.selected)
        selectBtn.addTarget(self, action: #selector(clickBtn(sender:)), for: UIControl.Event.touchUpInside)
        contentView.addSubview(selectBtn!)
        
        selectBtn.isHidden = true
    }
    
    func uploadCell(result: DWAsset) {
        self.asset = result
        
        if PhotoPickerManager.config.maxCount > 1 {
            selectBtn.isHidden = false
            selectBtn.isSelected = result.isSelected
            let title = result.isSelected ? "\(result.index! + 1)" : ""
            selectBtn.setTitle(title, for: UIControl.State.selected)
        }
        
        if let res = result.asset {
            PhotoPickerManager.requestImage(asset: res, size: PhotoPickerManager.config.thumbnailSize) {[weak self] (image) in
                self?.iconView.image = image
            }
        }
    }
    
    @objc func clickBtn(sender: UIButton) {
        delegate?.uploadAsset(asset: asset!, isSelected: !sender.isSelected)
    }
}
