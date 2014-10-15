//
//  GalleryViewController.swift
//  PhotoFilters
//
//  Created by Kevin Pham on 10/13/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

// 3.2 UICollectionViewDataSource | 8.3 UICollectionViewDelegate
class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var images = [UIImage]() // 6 Initialize empty array of UIImages
    weak var delegate : GalleryDelegate? // 8.1 Instantiate GalleryDelegate
    
    @IBOutlet weak var collectionView: UICollectionView! // 3.1 UICollectionView and Outlet

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 3.3 UICollectionView Data Source and Delegate (Similar to UITableView work flow)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        // 7 Append to images array
        for imageIndex in 1...17 {
            var image = UIImage(named: "unsplash_\(imageIndex).jpg")
            self.images.append(image)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 3.4
    // MARK: - Collection View Data Source
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // CV0 UIImage onto prototype cell. Create GalleryCollectionViewCell custom class.
        // CV1 Dequeue reusable cell using custom cell class
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCollectionViewCell
        
        // CV2 Configure cell
        cell.galleryImageView.image = self.images[indexPath.row]
        
        // CV3 Return cell
        return cell
    }
    
    // 8.4
    // MARK: - Collection View Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.didTapOnPicture(self.images[indexPath.row])
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
