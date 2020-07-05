//
//  ViewController.swift
//  FlickrImages
//
//  Created by Sandeep Kumar on 05/07/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    var pageCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        FlickrRouter.shared.request(searchText: "", pageCount: pageCount.description) { (result) in
            switch result {
            case .success(let model):
                break
            case.failure(let error):
                print(/error?.localizedDescription)
            }
        }
    }


}

