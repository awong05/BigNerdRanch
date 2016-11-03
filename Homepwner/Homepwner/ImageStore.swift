//
//  ImageStore.swift
//  Homepwner
//
//  Created by Andy Wong on 11/2/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ImageStore: NSObject {
    let cache = NSCache<NSString, UIImage>()

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    func imageForKey(_ key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func deleteImageForKey(_ key: String) {
        cache.removeObject(forKey: key as NSString)
    }
}
