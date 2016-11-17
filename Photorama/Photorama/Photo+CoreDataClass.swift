//
//  Photo+CoreDataClass.swift
//  Photorama
//
//  Created by Andy Wong on 11/15/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit
import CoreData

public class Photo: NSManagedObject {
    var image: UIImage?

    override public func awakeFromInsert() {
        super.awakeFromInsert()

        title = ""
        photoID = ""
        remoteURL = URLComponents().url!
        photoKey = UUID().uuidString
        dateTaken = Date()
        numberOfViews = 0
    }
}
