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
    var flowLayout : UICollectionViewFlowLayout!
    
    weak var delegate : GalleryDelegate? // 8.1 Instantiate GalleryDelegate
    
    @IBOutlet weak var collectionView: UICollectionView! // 3.1 UICollectionView and Outlet
    @IBOutlet weak var navigationTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupVC()
        
        self.flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        
        // Gesture Recognizer
        var galleryPinch = UIPinchGestureRecognizer(target: self, action: "pinchAction:")
        self.collectionView.addGestureRecognizer(galleryPinch)
        
        // 3.3 UICollectionView Data Source and Delegate (Similar to UITableView work flow)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView
        
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HEADER_VIEW", forIndexPath: indexPath) as CollectionHeaderView
            
            var label = headerView.galleryHeaderLabel
            label.text = "Random Album Title"
            
            reusableView = headerView
        } else {
            let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "FOOTER_VIEW", forIndexPath: indexPath) as CollectionFooterView
            
            var label = footerView.galleryFooterLabel
            label.text = "\(self.images.count) Photos"
            
            reusableView = footerView
        }
        
        return reusableView
    }
    
    // 8.4
    // MARK: - Collection View Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.didTapOnPicture(self.images[indexPath.row])
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Gesture Recognizer
    
    func pinchAction(pinch: UIPinchGestureRecognizer) {
        if pinch.state == UIGestureRecognizerState.Ended {
            self.collectionView.performBatchUpdates({ () -> Void in
                if pinch.velocity > 0 {
                    if self.flowLayout.itemSize.width < 360 {
                        self.flowLayout.itemSize = CGSize(width: self.flowLayout.itemSize.width * 2, height: self.flowLayout.itemSize.height * 2)
                        println(self.flowLayout.itemSize)
                    }
                } else {
                    if self.flowLayout.itemSize.width > 22.5 {
                        self.flowLayout.itemSize = CGSize(width: self.flowLayout.itemSize.width * 0.5, height: self.flowLayout.itemSize.height * 0.5)
                        println(self.flowLayout.itemSize)
                    }
                }
            }, completion: nil)
        }
    }
    
    // MARK: - Navigation Actions
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissVC()
    }
    
    func dismissVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - viewDidLoad
    
    func setupVC() {
        self.navigationTitle.title = "Gallery"
        
        // 7 Append to images array
        for imageIndex in 1...17 {
            var image = UIImage(named: "unsplash_\(imageIndex).jpg")
            self.images.append(image)
        }
    }
    
}
