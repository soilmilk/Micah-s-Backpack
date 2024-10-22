//
//  CachedImageManager.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 2/9/24.
//

import Foundation

final class CachedImageManager: ObservableObject {
    
    @Published private(set) var currentState: CurrentState?

    @MainActor
    func load(_ imgPath: String,
              cache: ImageCache = .shared) async {
        
        self.currentState = .loading
        
        if let imageData = cache.object(forkey: imgPath as NSString) {
            self.currentState = .success(data: imageData)
            return
        }
        
        do {
            let data = try await StorageManager.shared.getData(path: imgPath)
            self.currentState = .success(data: data)
            cache.set(object: data as NSData, forkey: imgPath as NSString)
        } catch {
            self.currentState = .failed(error: error)
        }
    }
}


extension CachedImageManager{
    enum CurrentState{
        case loading
        case failed(error: Error)
        case success(data: Data)
    }
}

extension CachedImageManager.CurrentState: Equatable {
    static func == (lhs: CachedImageManager.CurrentState,
                    rhs: CachedImageManager.CurrentState) -> Bool {
        switch(lhs, rhs){
        case(.loading, .loading):
            return true
        case (let .failed(lhsError), let .failed(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (let .success(lhsSuccess), let .success(rhsSuccess)):
            return lhsSuccess == rhsSuccess
        default:
            return false
        }
    }
}

