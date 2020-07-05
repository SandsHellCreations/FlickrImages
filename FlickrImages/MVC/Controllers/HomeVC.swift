//
//  ViewController.swift
//  FlickrImages
//
//  Created by Sandeep Kumar on 05/07/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tfSearch: UITextField!
    
    var pageCount: Int = 1
    private var dataSource: CollectionDataSource?
    private var images: [FlickerImage]?
    private var searchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewInit()
        tfSearch.addTarget(self, action: #selector(searchTextDidChanged(tf:)), for: .editingChanged)
        tfSearch.addTarget(self, action: #selector(handleSearch), for: .editingDidEndOnExit)
        tfSearch.delegate = self
    }
    
    @objc private func searchTextDidChanged(tf: UITextField) { //Called in sync as text changed in Search textfield
        searchText = /tf.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(handleSearch), object: nil)
        perform(#selector(handleSearch), with: nil, afterDelay: 0.5)
    }
    
    @objc private func handleSearch() { //with delay in typing speed
        pageCount = 1
        searchAPI(isRefreshing: true)
    }
    
    private func collectionViewInit() {
        
        let cellWidth = (UIScreen.main.bounds.width - (16 * 3)) / 2
        
        dataSource = CollectionDataSource.init(images, ImageCell.identfier, collectionView, CGSize.init(width: cellWidth, height: cellWidth), UIEdgeInsets.init(top: 0, left: 16, bottom: 16, right: 16), 16, 16)
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? ImageCell)?.item = item
        }
        
        dataSource?.addInfiniteScrollVertically = { [weak self] in
            self?.pageCount = /self?.pageCount + 1
            self?.searchAPI(isRefreshing: false)
        }
        
        dataSource?.addPullToRefreshVertically({ [weak self] in
            self?.tfSearch.text = nil
            self?.searchText = ""
            self?.pageCount = 1
            self?.searchAPI(isRefreshing: true)
        })
        
        dataSource?.refreshProgrammatically()
        
    }
    
    private func searchAPI(isRefreshing: Bool) {
        FlickrRouter.shared.request(searchText: /searchText == "" ? "random" : searchText, pageCount: pageCount.description) { [weak self] (result) in
            switch result {
            case .success(let model):
                self?.dataSource?.stopInfiniteLoading(.FinishLoading)
                if isRefreshing {
                    self?.images = model?.photos?.photo
                } else {
                    self?.images = (self?.images ?? []) + (model?.photos?.photo ?? [])
                }
                self?.dataSource?.updateData(self?.images)
            case.failure(let error):
                print(/error?.localizedDescription)
            }
        }
    }
    
}


extension HomeVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        pageCount = 1
        searchAPI(isRefreshing: true)
        return true
    }
}
