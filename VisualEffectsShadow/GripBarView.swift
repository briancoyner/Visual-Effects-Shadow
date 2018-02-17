//
//  Created by Brian M Coyner on 4/17/17.
//  Copyright © 2017 Brian Coyner. All rights reserved.
//

import Foundation
import UIKit

/// A simple view subclass that draws a small "capsule" in the center of the view.

final class GripBarView: UIView {

    fileprivate lazy var barLayer: CAShapeLayer = self.lazyBarLayer()
    fileprivate lazy var separatorLine: UIView = self.lazySeparatorLine()

    init() {
        super.init(frame: CGRect())

        selfInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        selfInit()
    }

    private func selfInit() {
        layer.addSublayer(barLayer)

        addSubview(separatorLine)
        NSLayoutConstraint.activate([
            separatorLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorLine.topAnchor.constraint(equalTo: topAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}

extension GripBarView {

    override func layoutSubviews() {
        super.layoutSubviews()

        let width = bounds.width * 0.15
        let height: CGFloat = 6.0
        let rect = CGRect(x: bounds.midX - (width / 2.0), y: bounds.midY - (height / 2.0), width: width, height: height)
        barLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height / 2.0).cgPath
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()

        barLayer.fillColor = tintColor.cgColor
    }
}

extension GripBarView {

    fileprivate func lazySeparatorLine() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray

        return view
    }

    fileprivate func lazyBarLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = tintColor.cgColor

        return layer
    }
}
