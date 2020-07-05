//
//  Networking.swift
//  FlickrImages
//
//  Created by Sandeep Kumar on 05/07/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

enum Result<T: Codable> {
    case success(T?)
    case failure(Error?)
}

class FlickrRouter {
    
    static let shared = FlickrRouter()
    
    fileprivate var task: URLSessionTask?

    fileprivate let FLICKER_KEY = "4d972a8eaeac4db640a75e7b8297940e"
    
    private func getFlickrSearchURL(page: String, searchText: String) -> URL? {
        guard let urlPath = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(FLICKER_KEY)&format=json&nojsoncallback=1&safe_search=\(page)&text=\(searchText)") else {
            return nil
        }
        return urlPath
    }
    
    public func cancelTask() {
        task?.cancel()
    }
}

extension FlickrRouter {
    
    func request(searchText: String, pageCount: String, comletionHandler: @escaping(Result<FlickrPhotosData>) -> Void ) {
        
        let session = URLSession.shared
        
        guard let path = getFlickrSearchURL(page: pageCount, searchText: searchText) else { return }
            
        task = session.dataTask(with: path, completionHandler: { (data, response, error) in
            
            switch  /(response as? HTTPURLResponse)?.statusCode {
            case 200...299:
                guard let apiData = data else { return }
                if let json = try? JSONSerialization.jsonObject(with: apiData, options: .allowFragments) {
                    debugPrint(json)
                }
                comletionHandler(.success(JSONHelper<FlickrPhotosData>().getCodableModel(data: apiData)))
            default:
                comletionHandler(.failure(error))
            }
            
        })
        
        task?.resume()
    }
}
