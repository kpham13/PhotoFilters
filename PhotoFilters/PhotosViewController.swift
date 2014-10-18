//
//  PhotosViewController.swift
//  PhotoFilters
//
//  Created by Kevin Pham on 10/15/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit
import Photos

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var imageManager : PHCachingImageManager!
    var assetFetchResult : PHFetchResult!
    var assetCellSize : CGSize!
    var originalSize : CGSize! //
    var flowLayout : UICollectionViewFlowLayout!
    var delegate : GalleryDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupVC()
        self.setupPhotos()
        self.setupPinchGesture()
        self.flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Collection View Data Source
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetFetchResult.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PHOTOS_CELL", forIndexPath: indexPath) as PhotosCollectionViewCell
        
        var currentTag = cell.tag + 1
        cell.tag = currentTag
        
        var asset = self.assetFetchResult[indexPath.row] as PHAsset
        cell.imageView.backgroundColor = UIColor.blueColor()
        self.imageManager.requestImageForAsset(asset, targetSize: self.assetCellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
            if cell.tag == currentTag {
                cell.imageView.image = image
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "FOOTER_VIEW", forIndexPath: indexPath) as CollectionFooterView
        
        var label = footerView.photosFooterLabel
        label.text = "# of Photos"
        
        return footerView
    }
    
    // MARK: - Collection View Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var asset = self.assetFetchResult[indexPath.row] as PHAsset
        self.imageManager.requestImageForAsset(asset, targetSize: self.originalSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
            self.delegate?.didTapOnPicture(image)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: - Photos Framework
    
    func setupPhotos() {
        // Getting the image manager
        self.imageManager = PHCachingImageManager()
        // Fetch all results
        self.assetFetchResult = PHAsset.fetchAssetsWithOptions(nil)
        // Determine device scale + adjust asset cell size
        var scale = UIScreen.mainScreen().scale
        var flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        var cellSize = flowLayout.itemSize
        self.assetCellSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale)
        self.originalSize = CGSize(width: 300, height: 300)
    }
    
    // MARK: - Gesture Recognizer
    
    func setupPinchGesture() {
        var photosPinch = UIPinchGestureRecognizer(target: self, action: "pinchAction:")
        self.collectionView.addGestureRecognizer(photosPinch)
    }
    
    func pinchAction(pinch: UIPinchGestureRecognizer) {
        if pinch.state == UIGestureRecognizerState.Ended {
            self.collectionView.performBatchUpdates({ () -> Void in
                if pinch.velocity > 0 {
                    if self.flowLayout.itemSize.width < 312 { // iPhone 6: 360
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
    
    // MARK: - Navigation
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - viewDidLoad
    
    func setupVC() {
        self.navigationTitle.title = "Photos Framework"
    }
    
}
