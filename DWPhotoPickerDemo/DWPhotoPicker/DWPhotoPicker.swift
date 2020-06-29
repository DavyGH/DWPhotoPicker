//
//  DWPhotoPicker.swift
//  DWPhotoPickerDemo
//
//  Created by Davy on 2020/6/23.
//  Copyright © 2020 Davy. All rights reserved.
//

import UIKit

class DWPhotoPicker {
    
    /// 配置项
    var config = DWPhotoConfig()
    
    /// 弹出相册VC
    var sourceVC: UIViewController = (UIApplication.shared.keyWindow?.rootViewController)!
    
    /// show
    func show(complete: @escaping ([UIImage]) -> Void) {
        
        PhotoPickerManager.config = config
        
        let vc = DWAlbumListViewController()
        vc.block = { (assets) in
            
            var array = [UIImage]()
            for asset in assets {
                array.append(asset.originalImage ?? asset.thumbnail ?? UIImage())
            }
            
            complete(array)
        }
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        sourceVC.present(nav, animated: true, completion: nil)
    }
    
    deinit {
        print("deinit -> DWPhotoPicker")
    }
}
