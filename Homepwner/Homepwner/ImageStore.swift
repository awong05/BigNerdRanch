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

        let imageURL = imageURLForKey(key)

        if let data = UIImagePNGRepresentation(image) {
            do {
                try data.write(to: imageURL, options: .atomic)
            } catch {
                print("Failed to write image data to disk")
            }
        }
    }

    func imageForKey(_ key: String) -> UIImage? {
        if let existingImage = cache.object(forKey: key as NSString) {
            return existingImage
        }

        let imageURL = imageURLForKey(key)
        guard let imageFromDisk = UIImage(contentsOfFile: imageURL.path) else {
            return nil }

        cache.setObject(imageFromDisk, forKey: key as NSString)
        return imageFromDisk
    }

    func deleteImageForKey(_ key: String) {
        cache.removeObject(forKey: key as NSString)

        let imageURL = imageURLForKey(key)
        do {
            try FileManager.default.removeItem(at: imageURL)
        } catch let deleteError {
            print("Error removing the image from disk: \(deleteError)")
        }
    }

    func imageURLForKey(_ key: String) -> URL {
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        
        return documentDirectory.appendingPathComponent(key)
    }
}
