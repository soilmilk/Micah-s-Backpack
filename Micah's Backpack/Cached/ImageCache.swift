//
//  ImageCache.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 2/9/24.
//

import Foundation

class ImageCache {
    
    typealias CacheType = NSCache<NSString, NSData>
    
    static let shared = ImageCache()
    
    private init() {}
    
    private lazy var cache: CacheType = {
        //Creating the image cache when we actually use this function
        let cache = CacheType()
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024
        return cache
    }()
    
    func object(forkey key: NSString) -> Data? {
        cache.object(forKey: key) as? Data
    }
    
    func set(object: NSData, forkey key: NSString) {
        cache.setObject(object, forKey: key)
    }
    
}
