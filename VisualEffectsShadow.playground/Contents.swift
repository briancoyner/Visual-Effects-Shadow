import UIKit
import XCPlayground
import PlaygroundSupport

// Note: you'll need to rebuild the embedded framework to pick up changes to the `UIImage+Shadow`.
import VisualEffectsUI

let cornerRadius: CGFloat = 100.0 // The radius is larger than normal so it's easier to visually see the generated image.
let sideLength = cornerRadius * 5 // trial and error: a multiple of 5 seems to produce a nice corner radius suitable for placing under sibling view.
let blur = cornerRadius * 0.6
let shouldDrawCapInsets = true

let shadow = Shadow(offset: CGSize(width: 0, height: 0), blur: blur, color: .lightGray)
let image = UIImage.resizableShadowImage(withSideLength: sideLength, cornerRadius: cornerRadius, shadow: shadow, shouldDrawCapInsets: shouldDrawCapInsets)
let imageView = UIImageView(image: image)

PlaygroundPage.current.liveView = imageView
