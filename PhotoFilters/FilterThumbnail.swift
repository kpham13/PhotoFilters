//
//  FilterThumbnail.swift
//  PhotoFilters
//
//  Created by Kevin Pham on 10/14/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class FilterThumbnail {
    
    var filterName : String
    var originalThumbnail : UIImage
    var filteredThumbnail : UIImage?
    var filter : CIFilter?
    var imageQueue : NSOperationQueue? // Filtering can be intensize, so use a queue.
    var gpuContext : CIContext
    
    init(name : String, thumbnail : UIImage, queue : NSOperationQueue, context : CIContext) {
        self.filterName = name
        self.originalThumbnail = thumbnail
        self.imageQueue = queue
        self.gpuContext = context
    }
    
    func generateThumbnail(completionHandler : (image : UIImage) -> (Void)) {
        // Setting up filter with a CIImage
        var image = CIImage(image: self.originalThumbnail)
        var imageFilter = CIFilter(name: self.filterName)
        imageFilter.setDefaults()
        imageFilter.setValue(image, forKey: kCIInputImageKey)
        
        // Generate the results
        var result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage // Whenever you ask for a value from a dictionary, you have to cast it.
        var extent = result.extent() // The rectangle of the image.
        var imageRef = self.gpuContext.createCGImage(result, fromRect: extent) // Creates core graphics image.
        self.filter = imageFilter
        self.filteredThumbnail = UIImage(CGImage: imageRef)
        
        NSOperationQueue.mainQueue().addOperationWithBlock ({ () -> Void in
            completionHandler(image: self.filteredThumbnail!)
        })
    }
}