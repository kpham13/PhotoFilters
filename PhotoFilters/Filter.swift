//
//  Filter.swift
//  PhotoFilters
//
//  Created by Kevin Pham on 10/14/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import Foundation
import CoreData

class Filter: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var favorite: NSNumber
}
