//
//  JSONHelper.swift
//  FlickrImages
//
//  Created by Sandeep Kumar on 05/07/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation


class JSONHelper<T: Codable> {
  
  init() {
    
  }
  /* MARK:- Convert any Data to Specific model
  Use case: Used for api responses to map into models */
  func getCodableModel(data: Data) -> T? {
    let model = try? JSONDecoder().decode(T.self, from: data)
    return model
  }

}
