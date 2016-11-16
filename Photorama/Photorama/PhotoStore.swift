//
//  PhotoStore.swift
//  Photorama
//
//  Created by Andy Wong on 11/9/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit
import CoreData

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

enum PhotoError: Error {
    case imageCreationError
}

class PhotoStore {
    let coreDataStack = CoreDataStack("Photorama")
    let imageStore = ImageStore()

    let session: URLSession = {
        let config: URLSessionConfiguration = .default
        return URLSession(configuration: config)
    }()

    func fetchRecentPhotos(completion: @escaping (PhotosResult) -> Void) {
        let url = FlickrAPI.recentPhotosURL()
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) in

            var result = self.processRecentPhotosRequest(data: data, error: error)

            if case let .success(photos) = result {
                let mainQueueContext = self.coreDataStack.mainQueueContext

                mainQueueContext.performAndWait() {
                    try! mainQueueContext.obtainPermanentIDs(for: photos)
                }

                let objectIDs = photos.map { $0.objectID }
                let predicate = NSPredicate(format: "self IN %@", objectIDs)
                let sortByDateTaken = NSSortDescriptor(key: "dateTaken", ascending: true)

                do {
                    try self.coreDataStack.saveChanges()

                    let mainQueuePhotos = try self.fetchMainQueuePhotos(predicate: predicate, sortDescriptors: [sortByDateTaken])
                    result = .success(mainQueuePhotos)
                } catch let error {
                    result = .failure(error)
                }
            }

            completion(result)
        }
        task.resume()
    }

    func processRecentPhotosRequest(data: Data?, error: Error?) -> PhotosResult {
        guard let jsonData = data else { return .failure(error!) }

        return FlickrAPI.photosFromJSONData(jsonData, inContext: self.coreDataStack.mainQueueContext)
    }

    func fetchImageForPhoto(_ photo: Photo, completion: @escaping (ImageResult) -> Void) {
        let photoKey = photo.photoKey

        if let image = imageStore.imageForKey(photoKey) {
            photo.image = image
            completion(.success(image))
            return
        }

        let photoURL = photo.remoteURL
        let request = URLRequest(url: photoURL)

        let task = session.dataTask(with: request) {
            (data, response, error) in

            if let response = response as? HTTPURLResponse {
                print(response.statusCode)
                print(response.allHeaderFields)
            }

            let result = self.processImageRequest(data: data, error: error)

            if case let .success(image) = result {
                photo.image = image
                self.imageStore.setImage(image, forKey: photoKey)
            }

            completion(result)
        }
        task.resume()
    }

    func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        guard let imageData = data,
              let image = UIImage(data: imageData) else {
            if data == nil {
                return .failure(error!)
            } else {
                return .failure(PhotoError.imageCreationError)
            }
        }

        return .success(image)
    }

    func fetchMainQueuePhotos(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Photo] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate

        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueuePhotos: [Photo]?
        var fetchRequestError: Error?

        mainQueueContext.performAndWait {
            do {
                mainQueuePhotos = try mainQueueContext.fetch(fetchRequest) as? [Photo]
            } catch let error {
                fetchRequestError = error
            }
        }

        guard let photos = mainQueuePhotos else {
            throw fetchRequestError! }

        return photos
    }
}
