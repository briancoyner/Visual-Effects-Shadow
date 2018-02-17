//
//  Created by Brian M Coyner on 5/11/17.
//  Copyright © 2017 Brian Coyner. All rights reserved.
//

import Foundation
import UIKit
import MapKit

/// A "demo" view controller with the following:
/// - full screen `MKMapView`
/// - a resizable `PassThroughView` centered over the map view
///
/// You can switch the map type between `.standard` and `.hybrid` by tapping a "Switch Map Type" button.
/// - `.standard` renders the visual effect view as "light" (with shadow)
/// - `.hybrid` renders the visual effect view as "dark" (no shadow)
///
/// There are two "debug" options in this demo:
/// - show/ hide the generated shadow image cap inset lines
/// - show/ hide the shadow

final class MainViewController: UIViewController {

    fileprivate lazy var mapView: MKMapView = self.lazyMapView()
    fileprivate lazy var passThroughView: PassThroughView = self.lazyPassThroughView()

    fileprivate var passThroughViewHeightConstraint: NSLayoutConstraint!
    fileprivate var passThroughViewBottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Visual Effect View + Shadow"

        view.addSubview(mapView)
        view.addSubview(passThroughView)

        passThroughViewHeightConstraint = passThroughView.heightAnchor.constraint(equalToConstant: 0)
        passThroughViewBottomConstraint = passThroughView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32)

        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            passThroughView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
            passThroughView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passThroughView.widthAnchor.constraint(greaterThanOrEqualToConstant: 240),
            passThroughViewBottomConstraint
        ])

        transition(to: .standard)
    }
}

// MARK: User Interactions (Buttons)

extension MainViewController {

    @objc
    fileprivate func userWantsToSwitchMapType() {
        let mapType: MKMapType = (mapView.mapType == .standard) ? .hybrid : .standard
        transition(to: mapType)
    }

    fileprivate func transition(to mapType: MKMapType) {
        switch mapType {
        case .standard:
            mapView.mapType = .standard
            passThroughView.theme = .light
        default:
            mapView.mapType = .hybrid
            passThroughView.theme = .dark
        }
    }

    @objc
    fileprivate func userWantsToToggleCapInsetLines() {
        passThroughView.showCapInsetLines = !passThroughView.showCapInsetLines
    }

    @objc
    fileprivate func userWantsToToggleShadow() {
        passThroughView.showShadow = !passThroughView.showShadow
    }
}

// MARK: User Interactions (Resizing Debug View)

extension MainViewController {

    @objc
    fileprivate func userDidPan(_ gestureRecognizer: UIPanGestureRecognizer) {

        let translation = gestureRecognizer.translation(in: gestureRecognizer.view)

        switch gestureRecognizer.state {
        case .began:
            passThroughViewHeightConstraint.constant = passThroughView.bounds.height
            passThroughViewHeightConstraint.isActive = true
            passThroughViewBottomConstraint.isActive = false
        case .changed:

            passThroughViewHeightConstraint.constant = passThroughViewHeightConstraint.constant + translation.y
            gestureRecognizer.setTranslation(CGPoint(), in: gestureRecognizer.view)
        case .ended, .cancelled:

            let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view).y
            if didUserFlickViewDown(basedOnVelocity: velocity) || didUserDragViewIntoBottomLayoutMargin() {
                passThroughViewHeightConstraint.isActive = false
                passThroughViewBottomConstraint.isActive = true
            } else if didUserFlickViewUp(basedOnVelocity: velocity) || didUserDragViewTooSmall() {
                passThroughViewHeightConstraint.isActive = true
                passThroughViewBottomConstraint.isActive = false
                passThroughViewHeightConstraint.constant = 144.0
            }

            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveLinear, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        default:
            break
        }
    }

    private func didUserFlickViewDown(basedOnVelocity velocity: CGFloat) -> Bool {
        return didUserFlickView(basedOnVelocity: velocity)
    }

    private func didUserFlickViewUp(basedOnVelocity velocity: CGFloat) -> Bool {
        return didUserFlickView(basedOnVelocity: abs(velocity))
    }

    private func didUserFlickView(basedOnVelocity velocity: CGFloat) -> Bool {
        return velocity > 973
    }

    private func didUserDragViewIntoBottomLayoutMargin() -> Bool {
        return passThroughView.bounds.height + passThroughView.frame.origin.y > view.frame.height + passThroughViewBottomConstraint.constant
    }

    private func didUserDragViewTooSmall() -> Bool {
        return passThroughView.bounds.height < 144 // arbitrary value for this demo.
    }
}

// MARK: Lazy View Creation

extension MainViewController {

    fileprivate func lazyMapView() -> MKMapView {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.mapType = .standard
        view.showsTraffic = true
        view.showsBuildings = true
        view.showsPointsOfInterest = true

        return view
    }

    fileprivate func lazyPassThroughView() -> PassThroughView {
        let view = PassThroughView()
        view.translatesAutoresizingMaskIntoConstraints = false

        addContent(to: view.contentView)

        return view
    }
}

extension MainViewController {

    fileprivate func addContent(to contentView: UIView) {
        let stackView = makeStackView()
        contentView.addSubview(stackView)

        let bottomGripBar = makeGripBarView()
        contentView.addSubview(bottomGripBar)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomGripBar.topAnchor),

            bottomGripBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomGripBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomGripBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomGripBar.heightAnchor.constraint(equalToConstant: 28.0)
        ])
    }

    private func makeStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [
            makeSwitchMapTypeButton(),
            makeToggleShadowButton(),
            makeToggleCapInsetsButton()
        ])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 2
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill

        return stackView
    }

    private func makeSwitchMapTypeButton() -> UIButton {
        return makeButton(with: "Switch Map Type", selector: #selector(userWantsToSwitchMapType))
    }

    private func makeToggleCapInsetsButton() -> UIButton {
        return makeButton(with: "Toggle Cap Insets", selector: #selector(userWantsToToggleCapInsetLines))
    }

    private func makeToggleShadowButton() -> UIButton {
        return makeButton(with: "Toggle Shadow", selector: #selector(userWantsToToggleShadow))
    }

    private func makeButton(with title: String, selector: Selector) -> UIButton {
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false

        view.setTitle(title, for: .normal)
        view.addTarget(self, action: selector, for: .primaryActionTriggered)

        return view
    }

    private func makeGripBarView() -> GripBarView {
        let view = GripBarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .lightGray

        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(userDidPan(_:))))

        return view
    }
}
