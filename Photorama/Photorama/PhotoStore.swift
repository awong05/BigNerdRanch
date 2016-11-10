//
//  PhotoStore.swift
//  Photorama
//
//  Created by Andy Wong on 11/9/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

enum PhotoError: Error {
    case imageCreationError
}

class PhotoStore {
    let session: URLSession = {
        let config: URLSessionConfiguration = .default
        return URLSession(configuration: config)
    }()

    func fetchRecentPhotos(completion: @escaping (PhotosResult) -> Void) {
        let url = FlickrAPI.recentPhotosURL()
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) in

            let result = self.processRecentPhotosRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }

    func processRecentPhotosRequest(data: Data?, error: Error?) -> PhotosResult {
        guard let jsonData = data else { return .failure(error!) }

        return FlickrAPI.photosFromJSONData(jsonData)
    }

    func fetchImageForPhoto(_ photo: Photo, completion: @escaping (ImageResult) -> Void) {
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
}
