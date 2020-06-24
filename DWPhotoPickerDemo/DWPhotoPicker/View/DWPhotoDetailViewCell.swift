//
//  DWPhotoDetailViewCell.swift
//  DWPhotoPickerDemo
//
//  Created by Davy on 2020/6/22.
//  Copyright © 2020 Davy. All rights reserved.
//

import UIKit
import Photos
import AudioToolbox

protocol DWPhotoDetailViewCellProtocol: class {
    func tapCell()
}

class DWPhotoDetailViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    weak var delegate: DWPhotoDetailViewCellProtocol?
    
    var imageView: UIImageView?
    
    var lastScale: CGFloat = 1.0 /// 记录上一次缩放比例
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        imageView = UIImageView(frame: contentView.bounds)
        imageView?.contentMode = .scaleAspectFit
        imageView?.isUserInteractionEnabled = true
        imageView?.clipsToBounds = true
        contentView.addSubview(imageView!)
        
        /// 单击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(ges:)))
        imageView?.addGestureRecognizer(tap)
        
        /// 双击手势
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap(ges:)))
        doubleTap.numberOfTapsRequired = 2
        imageView?.addGestureRecognizer(doubleTap)
        
        /// 捏合手势
        imageView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinch(ges:))))
        
        /// 拖动手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(ges:)))
        pan.delegate = self
        imageView?.addGestureRecognizer(pan)
        
        tap.require(toFail: doubleTap) /// 解决单击双击冲突
    }
    
    func uploadCell(result: DWAsset, size: CGSize) {
        if let asset = result.asset {
            PhotoPickerManager.requestImage(asset: asset, size: size) {[weak self] (image) in
                DispatchQueue.main.async {
                    self?.imageView?.image = image
                }
            }            
        }
    }
    
    /// 捏合
    @objc func pinch(ges: UIPinchGestureRecognizer) {
        var scale = lastScale + ges.scale - 1.0
//        print(ges.scale)

        if ges.state == .began || ges.state == .changed {
            ges.view?.transform = CGAffineTransform(scaleX: scale, y: scale)
        }

        if ges.state == .ended {
            
            if scale < 0.9 || scale > 3.6 { /// 超出范围回弹
                scale = 1.0
                if #available(iOS 10.0, *) { /// 振动反馈
                    let impact = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.light)
                    impact.impactOccurred()
                } else {
                    AudioServicesPlaySystemSound(1519)
                }
                
                UIView.animate(withDuration: 0.25) {
                    ges.view?.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
            
            lastScale = scale
        }
    }
    
    /// 双击
    @objc func doubleTap(ges: UITapGestureRecognizer) {
        
        if ges.view?.transform.a != 1.0 || ges.view?.transform.d != 1.0 {
            lastScale = 1.0
            UIView.animate(withDuration: 0.25) {
                ges.view?.transform = CGAffineTransform(scaleX: self.lastScale, y: self.lastScale)
            }
            return
        }
        
        lastScale = 1.8
        var point = ges.location(in: contentView)
        
        if point.x > contentView.bounds.width / 2.0 {
            point.x *= -0.3
        }
        
        if point.y > contentView.bounds.height / 2.0 {
            point.y *= -0.3
        }
        
//        print(point)
        UIView.animate(withDuration: 0.25) {
            ges.view?.transform = CGAffineTransform(a: self.lastScale, b: 0, c: 0, d: self.lastScale, tx: point.x, ty: point.y)
        }
    }
    
    /// 拖动
    @objc func pan(ges: UIPanGestureRecognizer) {
        let point = ges.translation(in: contentView)
//        print(point)
        
        if ges.state == .began || ges.state == .changed {
            ges.view?.transform = CGAffineTransform(a: lastScale, b: 0, c: 0, d: lastScale, tx: point.x, ty: point.y)
        }
        
        if ges.state == .ended {
            if lastScale == 1.0 && point.y > 50.0 { /// 滑动超过50直接退出
                delegate?.tapCell()
                return
            }
            
            lastScale = 1.0
            UIView.animate(withDuration: 0.25) {
                ges.view?.transform = CGAffineTransform(translationX: self.lastScale, y: self.lastScale)
            }
        }
    }
    
    /// 点击
    @objc func tap(ges: UITapGestureRecognizer) {
        delegate?.tapCell()
    }
    
    /// 解决手势冲突 (这个代理方法默认返回NO，会阻断继续向下识别手势，如果返回YES则可以继续向下传播识别)
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer is UIPanGestureRecognizer {
            if lastScale == 1.0 {
                return true
            }
            return false
        }
        return false
    }
}
