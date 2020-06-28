//
//  DWPhotoPickerManager.swift
//  DWPhotoPickerDemo
//
//  Created by Davy on 2020/6/19.
//  Copyright © 2020 Davy. All rights reserved.
//

import UIKit
import Photos

let PhotoPickerManager = DWPhotoPickerManager.shared

class DWPhotoPickerManager: NSObject {
    
    static let shared = DWPhotoPickerManager()
    
    let imageManager = PHCachingImageManager()
    
    var allResults = [DWAlbumItem]() /// 获取所有相册列表
    
    var cacheAssets = [DWAsset]() /// 缓存原质量图片
    
    var selectAssets = [DWAsset]() /// 选中图片数组
    
    var config = DWPhotoConfig() /// 配置项
    
    // MARK: - 用户是否授权
    func checkAuthorized(finished: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .notDetermined:
            print("不确定是否授权，第一次打开")
            PHPhotoLibrary.requestAuthorization({[weak self] (status) in
                if status == .denied || status == .restricted {
                    finished(false)
                } else {
                    self?.getAllPhotos()
                    finished(true)
                }
            })
        case .restricted, .denied:
            print("拒绝授权")
            finished(false)
        case .authorized:
            print("已经授权")
            getAllPhotos()
            finished(true)
        default:
            break
        }
    }
    
    // MARK: 获取所有图片
    func getAllPhotos() {
        //清空所有数据
        allResults.removeAll()
        
        //系统的智能相册
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        convertCollection(smartAlbums as! PHFetchResult<PHCollection>)
        
        //用户创建的相册
        let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        convertCollection(userCollections)
        
        //按照照片数量多少排序
        allResults.sort(by: { item1, item2  in
            item1.result.count > item2.result.count
        })
    }
    
    // MARK: 筛选数据
    func convertCollection(_ collection: PHFetchResult<PHCollection>) {
        
        for i in 0..<collection.count {
            let resultsOptions = PHFetchOptions()
            resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            resultsOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            
            let c = collection[i]
            let assetsFetchResult = PHAsset.fetchAssets(in: c as! PHAssetCollection, options: resultsOptions)
            
            if let title = albumChinseTitle(title: c.localizedTitle) {
                if assetsFetchResult.count > 0 {
                    
                    var array = [DWAsset]()
                    for j in 0..<assetsFetchResult.count {
                        let res = assetsFetchResult[j]
                        let asset = DWAsset()
                        asset.asset = res
                        array.append(asset)
                    }
                    
                    let item = DWAlbumItem(title: title, result: array)
                    allResults.append(item)
                }
            }
        }
    }
    
    /// 请求指定质量图片
    func requestImage(asset: PHAsset, size: CGSize, cpmplete: ((UIImage) -> Void)?) {
        
        var cacheModel: DWAsset? /// 有缩略图没有原图时（去下载原图）
        
        for model in cacheAssets {
            if asset == model.asset {
                
                if model.originalImage != nil { /// 有原图先取原图
                    cpmplete?(model.originalImage!)
                    print("找到图片缓存 size \(size.debugDescription)")
                    return
                }
                
                if model.thumbnail != nil {
                    if size == config.thumbnailSize { /// 需要缩略图直接返回
                        cpmplete?(model.thumbnail!)
                        print("找到图片缓存 size \(size.debugDescription)")
                        return
                    } else { /// 需要原图就去下载
                        cacheModel = model
                        break
                    }
                }
            }
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isSynchronous = true
        
        autoreleasepool {
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: {[weak self] (result, dict) in
                
                if let image = result {
                    
                    if cacheModel != nil {
                        if size == self?.config.originalSize {
                            cacheModel?.originalImage = image
                        } else {
                            cacheModel?.thumbnail = image
                        }
                        print("已加入缓存 size \(size.debugDescription)")
                        cpmplete?(image)
                        return
                    }
                    
                    /// 存入缓存池
                    let model = DWAsset()
                    if size == self?.config.originalSize {
                        model.originalImage = image
                    } else {
                        model.thumbnail = image
                    }
                    model.asset = asset
                    self?.cacheAssets.append(model)
                    print("已加入缓存 size \(size.debugDescription)")
                    
                    cpmplete?(image)
                }
            })
        }
    }
    
    /// 添加图片
    func addSelectAsset(asset: DWAsset) {
        if selectAssets.count < config.maxCount {
            asset.isSelected = true
            selectAssets.append(asset)
            asset.index = selectAssets.count - 1 /// 赋值角标
            
            requestImage(asset: asset.asset!, size: config.originalSize) { (image) in
                asset.originalImage = image
            }
        }
    }
    
    /// 删除图片
    func removeSelectAsset(asset: DWAsset) {
        
        asset.isSelected = false
        asset.originalImage = nil
        selectAssets.remove(at: asset.index!)
        
        for value in selectAssets { /// 后面的index向前进1
            if value.index! > asset.index! {
                value.index! -= 1
            }
        }
    }
    
    /// 清除缓存数据
    func cleanCacheAssets() {
        cacheAssets.removeAll()
    }
    
    /// 清除已选图片
    func cleanSelectAssets() {
        selectAssets.removeAll()
    }
    
    /// 清除所有相册
    func cleanAlbum() {
        allResults.removeAll()
    }
    
    func albumChinseTitle(title: String?) -> String? {
        guard let title = title else {
            return nil
        }
        switch title {
        case "Slo-mo":
            return "慢动作"
        case "Recently Added":
            return "最近添加"
        case "Favorites":
            return "个人收藏"
        case "Recently Deleted":
            return "最近删除"
        case "Videos":
            return "视频"
        case "All Photos":
            return "所有照片"
        case "Selfies":
            return "自拍"
        case "Screenshots":
            return "屏幕快照"
        case "Camera Roll":
            return "相机胶卷"
        case "Panoramas":
            return "全景照片"
        case "Time-lapse":
            return "延时摄影"
        case "Animated":
            return "动图"
        case "Long Exposure":
            return "长曝光"
        case "Portrait":
            return "人像"
        case "Hidden":
            return nil
        case "Bursts":
            return "连拍快照"
        case "Recents":
            return "最近项目"
        case "Live Photos":
            return "实况照片"
        default:
            return title
        }
    }
}
