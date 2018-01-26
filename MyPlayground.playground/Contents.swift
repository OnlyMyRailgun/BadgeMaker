//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import ObjectiveC

class BadgeMaker<Base>: NSObject {
    let base: Base
    var offset: CGPoint = .zero
    var radius: CGFloat = 5
    var color: UIColor = .red
    private let dot = CAShapeLayer()
    private let keyPaths = [
        #keyPath(UIView.frame),
        #keyPath(UIView.bounds)
    ]

    init(_ base: Base) {
        self.base = base
    }

    func hide() {
        dot.removeFromSuperlayer()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let objectView = object as? UIView,
            let keyPathNotNil = keyPath,
            keyPaths.contains(keyPathNotNil) {
            generatePath(on: objectView)
        }
    }

    fileprivate func registListener(on view: UIView) {
        keyPaths.forEach { [weak self] in
            guard let `self` = self else { return }
            view.addObserver(
                self,
                forKeyPath: $0,
                options: [.new, .initial],
                context: nil
            )
        }
    }

    fileprivate func generatePath(on view: UIView) {
        let center = CGPoint(
            x: view.bounds.width + offset.x,
            y: offset.y
        )
        let bezierPath = UIBezierPath()
        bezierPath.addArc(
            withCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: false
        )
        dot.fillColor = color.cgColor
        dot.path = bezierPath.cgPath
    }
}

extension BadgeMaker where Base: UIBarButtonItem {
    func show() {
        var container: UIView? = base.customView

        if container == nil {
            let button = UIButton()
            button.setTitle(base.title, for: .normal)
            button.setImage(base.image, for: .normal)
            button.tintColor = base.tintColor
            if let action = base.action {
                button.addTarget(base.target, action: action, for: .touchUpInside)
            }
            base.customView = button
            container = button
        }

        guard let view = container else { return }
        generatePath(on: view)
        if dot.superlayer == nil {
            view.layer.addSublayer(dot)
            registListener(on: view)
        }
    }
}

extension BadgeMaker where Base: UIView {
    func show() {
        generatePath(on: base)
        if dot.superlayer == nil {
            base.layer.addSublayer(dot)
            registListener(on: base)
        }
    }
}

private let kSystemVersion = (UIDevice.current.systemVersion as NSString).doubleValue
private var kBadgeMaker: Void?

protocol BadgeMakerCompatible {
    associatedtype CompatibleType
    var badge: CompatibleType { get }
}

extension BadgeMakerCompatible {
    public var badge: BadgeMaker<Self> {
        get {
            if let object = objc_getAssociatedObject(self, &kBadgeMaker) as? BadgeMaker<Self> {
                return object
            }
            let object = BadgeMaker(self)
            objc_setAssociatedObject(self, &kBadgeMaker, object, .OBJC_ASSOCIATION_RETAIN)
            return object
        }
    }
}

extension UIView: BadgeMakerCompatible { }
extension UIBarButtonItem: BadgeMakerCompatible { }

class MyViewController : UIViewController {
    override func loadView() {
        navigationItem.title = "ViewController"
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black
        label.badge.show()
        
        view.addSubview(label)

        let button = UIButton()
        button.setImage(UIImage(named: "ic_android"), for: .normal)
        button.frame = CGRect(x: 150, y: 260, width: 24, height: 24)
        button.badge.show()
        view.addSubview(button)
        
        let barButton = UIBarButtonItem(image: UIImage(named: "ic_android"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = barButton
        navigationItem.leftBarButtonItem?.badge.show()
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = UINavigationController(rootViewController: MyViewController())
