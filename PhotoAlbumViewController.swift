//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Samuel Doherty on 8/9/15.
//  Copyright (c) 2015 ColombiaIOS. All rights reserved.
//

import UIKit
import MapKit


class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!


    @IBOutlet weak var album: UICollectionView!
    
    var mapPin: Pin?
    
    var photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println(mapPin)
    }
    
    // MARK: - UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        cell.image.image = photos[indexPath.row].locationImage
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
       let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        
//        // Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
//        if let index = find(selectedIndexes, indexPath) {
//            selectedIndexes.removeAtIndex(index)
//        } else {
//            selectedIndexes.append(indexPath)
//        }
//        
//        // Then reconfigure the cell
//        configureCell(cell, atIndexPath: indexPath)
//        
//        // And update the buttom button
//        updateBottomButton()
    }
    


    @IBAction func loadMoreImages(sender: UIButton) {
    }

}
