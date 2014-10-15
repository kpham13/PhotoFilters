//
//  GalleryDelegate.swift
//  PhotoFilters
//
//  Created by Kevin Pham on 10/13/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

//8 Custom protocol
protocol GalleryDelegate : class {
    func didTapOnPicture(image : UIImage)
}