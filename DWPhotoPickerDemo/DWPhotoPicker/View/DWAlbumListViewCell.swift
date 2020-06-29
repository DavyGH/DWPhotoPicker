//
//  DWAlbumListViewCell.swift
//  DWPhotoPickerDemo
//
//  Created by Davy on 2020/6/29.
//  Copyright © 2020 Davy. All rights reserved.
//

import UIKit

class DWAlbumListViewCell: UITableViewCell {
    
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
                DispatchQueue.main.async {
                    self?.iconView.image = image
                }
            }
        }
    }
}
