//
//  AsyncImageLoader.swift
//  Shared image loading utility — replaces AFNetworking/AlamofireImage
//

import UIKit

private let imageCache = NSCache<NSURL, UIImage>()

extension UIImageView {

    func loadImage(from url: URL, placeholder: UIImage? = nil) {
        image = placeholder
        let cacheKey = url as NSURL
        if let cached = imageCache.object(forKey: cacheKey) {
            image = cached
            return
        }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let loaded = UIImage(data: data) else { return }
                imageCache.setObject(loaded, forKey: cacheKey)
                await MainActor.run { self.image = loaded }
            } catch {
                // silently fail; placeholder remains
            }
        }
    }

    func loadImageWithFade(from url: URL) {
        loadImage(from: url)
        alpha = 0
        UIView.animate(withDuration: 0.3) { self.alpha = 1 }
    }
}
