//
//  ImageCell.swift
//  FlickrImages
//
//  Created by Sandeep Kumar on 05/07/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell, ReusableCellCollection {
    
    @IBOutlet weak var imgView: UIImageView!
    
    var item: Any? {
        didSet {
            let image = item as? FlickerImage
            imgView.image = #imageLiteral(resourceName: "placeholder")
            if let url = image?.getImageURL() {
                let image = ImageProvider.init().cache.object(forKey: url as NSURL)
                imgView.image = image
                ImageProvider.init().requestImage(from: url) { [weak self] (img) in
                    self?.imgView.image = img
                }
            }
        }
    }
}
