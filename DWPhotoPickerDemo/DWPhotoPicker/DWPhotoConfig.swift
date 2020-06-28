//
//  DWPhotoConfig.swift
//  DWPhotoPickerDemo
//
//  Created by Davy on 2020/6/19.
//  Copyright © 2020 Davy. All rights reserved.
//

import UIKit

class DWPhotoConfig {
    
    /// 多选最大张数 默认9张
    var maxCount = 9
    
    /// 相册图片间隙 默认1.0
    var cellMargin = 1.0
    
    /// 相册图片横向排版 默认一排4个
    var cellCount = 4
    
    /// 浏览大图图片上下左右间隙 默认8.0
    var photoMargin = 8.0
    
    /// 原图质量
    var originalSize = CGSize(width: 1080.0, height: 1080.0)
    
    /// 缩略图质量
    var thumbnailSize = CGSize(width: 300.0, height: 300.0)
    
    /// 弹出相册VC
    var sourceVC: UIViewController = (UIApplication.shared.keyWindow?.rootViewController)!
}
