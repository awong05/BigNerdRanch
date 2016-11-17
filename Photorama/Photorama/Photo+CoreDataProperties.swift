//
//  Photo+CoreDataProperties.swift
//  Photorama
//
//  Created by Andy Wong on 11/15/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import CoreData

extension Photo {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var dateTaken: Date
    @NSManaged public var numberOfViews: Int64
    @NSManaged public var photoID: String
    @NSManaged public var photoKey: String
    @NSManaged public var remoteURL: URL
    @NSManaged public var title: String
    @NSManaged public var tags: Set<NSManagedObject>
}
