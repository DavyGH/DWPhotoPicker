//
//  DWAlbumItem.swift
//  DWPhotoPickerDemo
//
//  Created by Davy on 2020/6/22.
//  Copyright © 2020 Davy. All rights reserved.
//

import UIKit
import Photos

class DWAlbumItem: NSObject {
    //相册名称
    var title: String?
    
    //相册中资源
    var result = [DWAsset]()
    
    init(title: String?, result: [DWAsset]) {
        self.result = result
        self.title = title
    }
}

class DWAsset: NSObject {
    
    var originalImage: UIImage? /// 原图
    
    var thumbnail: UIImage? /// 缩略图
    
    var isSelected = false /// 是否选中
    
    var index: Int? /// 被选中下标
    
    var asset: PHAsset?
}
