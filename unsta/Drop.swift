//
//  Drop.swift
//  SwiftyDrop
//
//  Created by MORITANAOKI on 2015/06/18.
//

import UIKit

public enum DropState {
    case `default`, info, success, warning, error

    fileprivate func backgroundColor() -> UIColor? {
        switch self {
        case .info: return .red
        case .success: return .red
        case .warning: return .red
        case .error: return .red
        case .default: return .red
        }
    }
}

public enum DropBlur {
    case light, extraLight, dark

    fileprivate func blurEffect() -> UIBlurEffect {
        switch self {
        case .light: return UIBlurEffect(style: .light)
        case .extraLight: return UIBlurEffect(style: .extraLight)
        case .dark: return UIBlurEffect(style: .dark)
        }
    }
}

public final class Drop: UIView {
    fileprivate var backgroundView: UIView!
    fileprivate var statusLabel: UILabel!
    fileprivate var topConstraint: NSLayoutConstraint!
    fileprivate var heightConstraint: NSLayoutConstraint!
    fileprivate let statusTopMargin: CGFloat = 10.0
    fileprivate let statusBottomMargin: CGFloat = 10.0
    fileprivate var minimumHeight: CGFloat { return Drop.statusBarHeight() + 44.0 }
    fileprivate var upTimer: Timer?
    fileprivate var startTop: CGFloat?

    override init(frame: CGRect) {
        super.init(frame: frame)
        heightConstraint = NSLayoutConstraint(
            item: self,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height,
            multiplier: 1.0,
            constant: 100.0
        )
        self.addConstraint(heightConstraint)
        scheduleUpTimer(4.0)

        NotificationCenter.default.addObserver(self, selector:
            #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)),
                                               name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Drop.deviceOrientationDidChange(_:)),
                                               name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        stopUpTimer()
        NotificationCenter.default.removeObserver(self)
    }

    func applicationDidEnterBackground(_ notification: Notification) {
        stopUpTimer()
        removeFromSuperview()
    }

    func deviceOrientationDidChange(_ notification: Notification) {
        updateHeight()
    }

    func up() {
        scheduleUpTimer(0.0)
    }

    func upFromTimer(_ timer: Timer) {
        if let interval = timer.userInfo as? Double {
            Drop.up(self, interval: interval)
        }
    }

    fileprivate func scheduleUpTimer(_ after: Double) {
        scheduleUpTimer(after, interval: 0.25)
    }

    fileprivate func scheduleUpTimer(_ after: Double, interval: Double) {
        stopUpTimer()
        upTimer = Timer.scheduledTimer(timeInterval: after, target: self, selector: #selector(Drop.upFromTimer(_:)),
                                       userInfo: interval, repeats: false)
    }

    fileprivate func stopUpTimer() {
        upTimer?.invalidate()
        upTimer = nil
    }

    fileprivate func updateHeight() {
        let calculatedHeight = (self.statusLabel.frame.size.height + Drop.statusBarHeight() + statusTopMargin +
            statusBottomMargin)
        heightConstraint.constant = calculatedHeight > minimumHeight ? calculatedHeight : minimumHeight
        self.layoutIfNeeded()
    }
}

extension Drop {
    public class func down(_ status: String) {
        down(status, state: .default)
    }

    public class func down(_ status: String, state: DropState) {
        down(status, state: state, blur: nil)
    }

    public class func down(_ status: String, blur: DropBlur) {
        down(status, state: nil, blur: blur)
    }

    fileprivate class func down(_ status: String, state: DropState?, blur: DropBlur?) {
        self.upAll()
        let drop = Drop(frame: CGRect.zero)
        Drop.window().addSubview(drop)

        let sideConstraints = ([.left, .right] as [NSLayoutAttribute]).map {
            return NSLayoutConstraint(
                item: drop,
                attribute: $0,
                relatedBy: .equal,
                toItem: Drop.window(),
                attribute: $0,
                multiplier: 1.0,
                constant: 0.0
            )
        }

        drop.topConstraint = NSLayoutConstraint(
            item: drop,
            attribute: .top,
            relatedBy: .equal,
            toItem: Drop.window(),
            attribute: .top,
            multiplier: 1.0,
            constant: -drop.heightConstraint.constant
        )

        Drop.window().addConstraints(sideConstraints)
        Drop.window().addConstraint(drop.topConstraint)
        drop.setup(status, state: state, blur: blur)
        drop.updateHeight()

        drop.topConstraint.constant = 0.0
        UIView.animate(
            withDuration: TimeInterval(0.25),
            delay: TimeInterval(0.0),
            options: [.allowUserInteraction, .curveEaseOut],
            animations: { [weak drop]() -> Void in
                if let drop = drop { drop.layoutIfNeeded() }
            }, completion: nil
        )
    }

    fileprivate class func up(_ drop: Drop, interval: TimeInterval) {
        drop.topConstraint.constant = -drop.heightConstraint.constant
        UIView.animate(
            withDuration: interval,
            delay: TimeInterval(0.0),
            options: [.allowUserInteraction, .curveEaseIn],
            animations: { [weak drop]() -> Void in
                if let drop = drop {
                    drop.layoutIfNeeded()
                }
        }) { [weak drop] finished -> Void in
            if let drop = drop { drop.removeFromSuperview() }
        }
    }

    public class func upAll() {
        for view in Drop.window().subviews {
            if let drop = view as? Drop {
                drop.up()
            }
        }
    }
}

extension Drop {
    fileprivate func setup(_ status: String, state: DropState?, blur: DropBlur?) {
        self.translatesAutoresizingMaskIntoConstraints = false

        if let blur = blur {
            let blurEffect = blur.blurEffect()

            // Visual Effect View
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            visualEffectView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(visualEffectView)
            let visualEffectViewConstraints = ([.right, .bottom, .left] as [NSLayoutAttribute]).map {
                return NSLayoutConstraint(
                    item: visualEffectView,
                    attribute: $0,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: $0,
                    multiplier: 1.0,
                    constant: 0.0
                )
            }
            let topConstraint = NSLayoutConstraint(
                item: visualEffectView,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1.0,
                constant: -UIScreen.main.bounds.height
            )

            self.addConstraints(visualEffectViewConstraints)
            self.addConstraint(topConstraint)
            self.backgroundView = visualEffectView

            // Vibrancy Effect View
            let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
            vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false
            visualEffectView.contentView.addSubview(vibrancyEffectView)
            let vibrancyLeft = NSLayoutConstraint(
                item: vibrancyEffectView,
                attribute: .left,
                relatedBy: .equal,
                toItem: visualEffectView.contentView,
                attribute: .leftMargin,
                multiplier: 1.0,
                constant: 0.0
            )
            let vibrancyRight = NSLayoutConstraint(
                item: vibrancyEffectView,
                attribute: .right,
                relatedBy: .equal,
                toItem: visualEffectView.contentView,
                attribute: .rightMargin,
                multiplier: 1.0,
                constant: 0.0
            )
            let vibrancyTop = NSLayoutConstraint(
                item: vibrancyEffectView,
                attribute: .top,
                relatedBy: .equal,
                toItem: visualEffectView.contentView,
                attribute: .top,
                multiplier: 1.0,
                constant: 0.0
            )
            let vibrancyBottom = NSLayoutConstraint(
                item: vibrancyEffectView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: visualEffectView.contentView,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0.0
            )
            visualEffectView.contentView.addConstraints([vibrancyTop, vibrancyRight, vibrancyBottom, vibrancyLeft])

            // STATUS LABEL
            let statusLabel = createStatusLabel(status, isVisualEffect: true)
            vibrancyEffectView.contentView.addSubview(statusLabel)
            let statusLeft = NSLayoutConstraint(
                item: statusLabel,
                attribute: .left,
                relatedBy: .equal,
                toItem: vibrancyEffectView.contentView,
                attribute: .left,
                multiplier: 1.0,
                constant: 0.0
            )
            let statusRight = NSLayoutConstraint(
                item: statusLabel,
                attribute: .right,
                relatedBy: .equal,
                toItem: vibrancyEffectView.contentView,
                attribute: .right,
                multiplier: 1.0,
                constant: 0.0
            )
            let statusBottom = NSLayoutConstraint(
                item: statusLabel,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: vibrancyEffectView.contentView,
                attribute: .bottom,
                multiplier: 1.0,
                constant: -statusBottomMargin
            )
            vibrancyEffectView.contentView.addConstraints([statusRight, statusLeft, statusBottom])
            self.statusLabel = statusLabel
        }

        if let state = state {
            // Background View
            let backgroundView = UIView(frame: CGRect.zero)
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.alpha = 0.9
            backgroundView.backgroundColor = state.backgroundColor()
            self.addSubview(backgroundView)
            let backgroundConstraints = ([.right, .bottom, .left] as [NSLayoutAttribute]).map {
                return NSLayoutConstraint(
                    item: backgroundView,
                    attribute: $0,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: $0,
                    multiplier: 1.0,
                    constant: 0.0
                )
            }

            let topConstraint = NSLayoutConstraint(
                item: backgroundView,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1.0,
                constant: -UIScreen.main.bounds.height
            )

            self.addConstraints(backgroundConstraints)
            self.addConstraint(topConstraint)
            self.backgroundView = backgroundView

            // Status Label
            let statusLabel = createStatusLabel(status, isVisualEffect: false)
            self.addSubview(statusLabel)
            let statusLeft = NSLayoutConstraint(
                item: statusLabel,
                attribute: .left,
                relatedBy: .equal,
                toItem: self,
                attribute: .leftMargin,
                multiplier: 1.0,
                constant: 0.0
            )
            let statusRight = NSLayoutConstraint(
                item: statusLabel,
                attribute: .right,
                relatedBy: .equal,
                toItem: self,
                attribute: .rightMargin,
                multiplier: 1.0,
                constant: 0.0
            )
            let statusBottom = NSLayoutConstraint(
                item: statusLabel,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self,
                attribute: .bottom,
                multiplier: 1.0,
                constant: -statusBottomMargin
            )
            self.addConstraints([statusLeft, statusRight, statusBottom])
            self.statusLabel = statusLabel
        }

        self.layoutIfNeeded()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(Drop.up(_:)))
        self.addGestureRecognizer(tapRecognizer)

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(Drop.pan(_:)))
        self.addGestureRecognizer(panRecognizer)
    }

    fileprivate func createStatusLabel(_ status: String, isVisualEffect: Bool) -> UILabel {
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        label.textAlignment = .center
        label.text = status
        if !isVisualEffect { label.textColor = UIColor.white }
        return label
    }
}

extension Drop {
    func up(_ sender: AnyObject) {
        self.up()
    }

    func pan(_ sender: AnyObject) {
        guard let pan = sender as? UIPanGestureRecognizer else {
            return
        }

        switch pan.state {
        case .began:
            stopUpTimer()
            startTop = topConstraint.constant
        case .changed:
            let translation = pan.translation(in: Drop.window())
            let top = startTop! + translation.y
            if top > 0.0 {
                topConstraint.constant = top * 0.2
            } else {
                topConstraint.constant = top
            }
        case .ended:
            startTop = nil
            if topConstraint.constant < 0.0 {
                scheduleUpTimer(0.0, interval: 0.1)
            } else {
                scheduleUpTimer(4.0)
                topConstraint.constant = 0.0
                UIView.animate(
                    withDuration: TimeInterval(0.1),
                    delay: TimeInterval(0.0),
                    options: [.allowUserInteraction, .curveEaseOut],
                    animations: { [weak self]() -> Void in
                        if let s = self { s.layoutIfNeeded() }
                    }, completion: nil
                )
            }
        case .failed, .cancelled:
            startTop = nil
            scheduleUpTimer(2.0)
        case .possible: break
        }
    }
}

extension Drop {
    fileprivate class func window() -> UIWindow {
        return UIApplication.shared.keyWindow!
    }
    
    fileprivate class func statusBarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
}
