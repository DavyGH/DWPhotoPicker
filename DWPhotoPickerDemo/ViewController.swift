//
//  ViewController.swift
//  DWPhotoPickerDemo
//
//  Created by Davy on 2020/6/19.
//  Copyright © 2020 Davy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var data = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func clickBtn(_ sender: Any) {
        let picker = DWPhotoPicker()
        picker.show {[weak self] (assets) in
            print(assets)
            self?.data = assets
            self?.collectionView.reloadData()
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell
        cell.imageView.image = data[indexPath.row]
        return cell
    }
}

class Cell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}
