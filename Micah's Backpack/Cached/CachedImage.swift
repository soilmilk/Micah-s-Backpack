//
//  CachedImage.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 2/9/24.
//

import SwiftUI

struct CachedImage<Content: View>: View {
    
    
    @StateObject private var manager = CachedImageManager()
    let imgPath: String
    let animation: Animation?
    let transition: AnyTransition
    let content: (AsyncImagePhase) -> Content
    
    init(imgPath: String,
         animation: Animation? = nil,
         transition: AnyTransition = .identity,
         @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.imgPath = imgPath
        self.animation = animation
        self.transition = transition
        self.content = content
    }
    
    
    var body: some View {
        ZStack {
            switch manager.currentState {
            case .loading:
                content(.empty)
                    .transition(transition)
            case .failed(let error):
                content(.failure(error))
                    .transition(transition)
            case .success(let data):
                if let image = UIImage(data: data) {
                    content(.success(Image(uiImage: image)))
                        .transition(transition)
                } else {
                    content(.failure(CachedImageError.invalidData))
                        .transition(transition)
                }
            default:
                content(.empty)
                    .transition(transition)     
            }
        }
        .animation(animation, value: manager.currentState)
        .task {
            await manager.load(imgPath)
        }
    }
}

#Preview {
    CachedImage(imgPath: "https://picsum.photos/200") {_ in EmptyView() }
}

extension CachedImage {
    enum CachedImageError: Error {
        case invalidData
    }
}
