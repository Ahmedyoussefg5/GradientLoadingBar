//
//  GradientLoadingBar.swift
//  GradientLoadingBar
//
//  Created by Felix Mau on 11.12.16.
//  Copyright © 2016 Felix Mau. All rights reserved.
//

import Foundation
import UIKit

// Handler for GradientView
open class GradientLoadingBar {

    public struct DefaultValues {
        public static let height = 2.5

        public static let durations =
            Durations(fadeIn: 0.33, fadeOut: 0.66, progress: 3.33)

        // iOS color palette
        // From: http://www.cssscript.com/ios-style-gradient-progress-bar-with-pure-css-css3/
        public static let gradientColors: GradientColors = [
            UIColor(hexString:"#4cd964").cgColor,
            UIColor(hexString:"#5ac8fa").cgColor,
            UIColor(hexString:"#007aff").cgColor,
            UIColor(hexString:"#34aadc").cgColor,
            UIColor(hexString:"#5856d6").cgColor,
            UIColor(hexString:"#ff2d55").cgColor
        ]
    }

    // View containing the gradient view.
    public var superview: UIView?

    // View with the gradient layer.
    public let gradientView: GradientView

    // Used to handle mutliple calls to show at the same time.
    public private(set) var isVisible = false

    // Height of gradient bar.
    public private(set) var height = 0.0

    // Instance variable for singleton.
    private static var instance: GradientLoadingBar?

    // MARK: - Initializers

    public init (
        height: Double = DefaultValues.height,
        durations: Durations = DefaultValues.durations,
        gradientColors: GradientColors = DefaultValues.gradientColors,
        onView superview: UIView? = UIApplication.shared.keyWindow
    ) {
        self.height = height
        self.superview = superview

        gradientView = GradientView(
            durations: durations,
            gradientColors: gradientColors
        )

        addGradientViewToSuperview()
    }

    deinit {
        if gradientView.superview != nil {
            gradientView.removeFromSuperview()
        }
    }

    // MARK: - Layout

    private func addGradientViewToSuperview() {
        // If initializer called in "appDelegate" key window will not be available..
        guard let superview = superview else {
            // .. so we setup an observer to add "gradientView" to key window (by saving it as superview) when it's ready.
            let notificationCenter = NotificationCenter.default
            notificationCenter.observeOnce(forName: NSNotification.Name.UIWindowDidBecomeKey) { (_ notification) in
                self.superview = UIApplication.shared.keyWindow
                self.addGradientViewToSuperview()
            }

            // Stop here and wait for observer to finish.
            return
        }

        // Add gradient view to superview..
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(gradientView)

        // .. and apply layout anchors.
        setupConstraints()
    }

    open func setupConstraints() {
        guard let superview = superview else { return }

        gradientView.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true

        gradientView.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        gradientView.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
    }

    // MARK: - Helper to use as a Singleton

    public func saveInstance() {
        type(of: self).instance = self
    }

    public static func sharedInstance() -> GradientLoadingBar {
        if instance == nil {
            instance = GradientLoadingBar()
        }

        return instance!
    }

    // MARK: - Show / Hide

    public func show() {
        if !isVisible {
            isVisible = true

            gradientView.show()
        }
    }

    public func hide() {
        if isVisible {
            isVisible = false

            gradientView.hide()
        }
    }

    public func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }
}
