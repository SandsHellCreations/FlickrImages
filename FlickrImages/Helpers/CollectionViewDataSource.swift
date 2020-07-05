//
//  CollectionViewDataSource.swift
//  GasItUpDriver
//
//  Created by Sandeep Kumar on 31/03/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//


import UIKit

protocol ReusableCellCollection {
    static var identfier: String { get }
    var item: Any? { get set }
}

extension ReusableCellCollection {
    static var identfier: String {
        return String.init(describing: self)
    }
}

class CollectionDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    typealias DidChangeCurrentIndex = (_ indexPath : IndexPath) -> Void
    typealias DidSelectedItem = (_ indexPath : IndexPath, _ item: Any?) -> Void
    typealias ListCellConfigureBlock = (_ cell : UICollectionViewCell , _ item : Any?, _ indexpath: IndexPath) -> ()
    typealias DirectionForScroll = (_ direction: ScrollDirection) -> Void
    typealias Pulled = () -> Void
    typealias InfiniteScroll = () -> Void
    
    private var items: Array<Any>?
    private var identifier: String?
    private var collectionView: UICollectionView?
    public var size: CGSize?
    private var edgeInsets: UIEdgeInsets?
    private var minLineSpacing: CGFloat?
    private var minInterItemSpacing: CGFloat?
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = ColorAsset.activityIndicator.color
        
        return refreshControl
    }()
    private var infiniteLoadingStatus: InfiniteScrollStatus = .FinishLoading
    private var pulled: Pulled?
    
    
    public var didSelectItem: DidSelectedItem?
    public var configureCell: ListCellConfigureBlock?
    public var scrollDirection: DirectionForScroll?
    public var addInfiniteScrollVertically: InfiniteScroll?
    public var didChangeCurrentIndex: DidChangeCurrentIndex?
    
    
    init(_ _items: Array<Any>?, _ _identifier: String?, _ _collectionView: UICollectionView, _ _size: CGSize?, _ _edgeInsets: UIEdgeInsets?, _ _lineSpacing: CGFloat?, _ _interItemSpacing: CGFloat?) {
        super.init()
        items = _items
        identifier = _identifier
        collectionView = _collectionView
        size = _size
        edgeInsets = _edgeInsets
        minLineSpacing = _lineSpacing
        minInterItemSpacing = _interItemSpacing
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.reloadData()
    }
    
    public func addPullToRefreshVertically(_ _pulled: Pulled?) {
        collectionView?.addSubview(refreshControl)
        pulled = _pulled
    }
    
    public func stopInfiniteLoading(_ status: InfiniteScrollStatus) {
        infiniteLoadingStatus = status
        refreshControl.endRefreshing()
    }
    
    public func updateData(_ _items: Array<Any>?) {
        items = _items
        collectionView?.reloadData()
    }
    
    public func refreshProgrammatically() {
        infiniteLoadingStatus = .LoadingContent
        refreshControl.beginRefreshing()
        let offsetPoint = CGPoint.init(x: 0, y: -refreshControl.frame.size.height)
        collectionView?.setContentOffset(offsetPoint, animated: true)
        pulled?()
    }
    
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        infiniteLoadingStatus = .LoadingContent
        pulled?()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier ?? "", for: indexPath)
        configureCell?(cell, items?[indexPath.item], indexPath)
        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        didChangeCurrentIndex?(indexPath)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return edgeInsets ?? UIEdgeInsets.zero
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minLineSpacing ?? CGFloat.leastNonzeroMagnitude
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minInterItemSpacing ?? CGFloat.leastNonzeroMagnitude
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return size ?? CGSize.zero
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItem?(indexPath, items?[indexPath.item])
    }
    
    internal func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        switch velocity {
        case _ where velocity.y < 0:
            // swipes from top to bottom of screen -> down
            scrollDirection?(.Down)
        case _ where velocity.y > 0:
            // swipes from bottom to top of screen -> up
            scrollDirection?(.Up)
        default: break
        }
    }
    
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let verticalInfiniteScroll = addInfiniteScrollVertically {
            
            if refreshControl.isRefreshing {
                return
            }
            
            switch infiniteLoadingStatus {
            case .LoadingContent, .NoContentAnyMore:
                return
            case .FinishLoading:
                // calculates where the user is in the y-axis
                let offsetY = scrollView.contentOffset.y
                let contentHeight = scrollView.contentSize.height
                
                if offsetY > contentHeight - scrollView.frame.size.height {
                    infiniteLoadingStatus = .LoadingContent
                    verticalInfiniteScroll()
                }
            }
            
        }
    }
}
