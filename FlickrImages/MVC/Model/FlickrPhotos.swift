//
//  FlickrPhotos.swift
//  FlickrImages
//
//  Created by Sandeep Kumar on 05/07/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

class FlickrPhotosData: Codable {
    var photos: FlickerPhotos?
}

class FlickerPhotos: Codable {
    var page: Int?
    var pages: Int?
    var perpage: Int?
    var photo: [FlickerImage]?
}

class FlickerImage: Codable {
    var id: String?
    var owner: String?
    var secret: String?
    var server: String?
    var farm: Int?
    var title: String?
    var ispublic: Int?
    var isfriend: Int?
    var isfamily: Int?
    
    func getImageURL() -> URL? {
        let path = "http://farm\(/farm).static.flickr.com/\(/server)/\(/id)_\(/secret).jpg"
        return URL(string: path)
    }
}
