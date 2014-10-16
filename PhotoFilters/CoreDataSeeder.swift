//
//  CoreDataSeeder.swift
//  PhotoFilters
//
//  Created by Kevin Pham on 10/14/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import Foundation
import CoreData

// 12.2 Core Data Seeder
class CoreDataSeeder {
    
    var managedObjectContext : NSManagedObjectContext!
    
    init(context : NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    func seedCoreData() {
        var sepia = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        sepia.name = "CISepiaTone"
        
        var gaussianBlur = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        gaussianBlur.name = "CIGaussianBlur"
        //gaussianBlur.favorite = true
        
        var pixellate = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        pixellate.name = "CIPixellate"
        
        var gammaAdjust = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        gammaAdjust.name = "CIGammaAdjust"
        
        var exposureAdjust = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        exposureAdjust.name = "CIExposureAdjust"
        
        var photoEffectChrome = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectChrome.name = "CIPhotoEffectChrome"
        
        var photoEffectInstant = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectInstant.name = "CIPhotoEffectInstant"
        
        var photoEffectMono = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectMono.name = "CIPhotoEffectMono"
        
        var photoEffectNoir = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectNoir.name = "CIPhotoEffectNoir"
        
        var photoEffectTonal = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectTonal.name = "CIPhotoEffectTonal"
        
        var photoEffectTransfer = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectTransfer.name = "CIPhotoEffectTransfer"
        
        var error : NSError?
        self.managedObjectContext?.save(&error)
        
        if error != nil {
            println("Yay!")
        }
    }
}