//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import ObjectiveC

struct BadgeMaker<Base> {
    let base: Base
    var offset: CGPoint = .zero
    var radius: CGFloat = 5
    var color: UIColor = .red
    private let dot = CAShapeLayer()

    init(_ base: Base) {
        self.base = base
    }

    func hide() {
        dot.removeFromSuperlayer()
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
        var container: UIView?
        guard let navigationButton = base.value(forKey: "_view") as? UIView else { return }
        let controlName = (kSystemVersion < 11.0 ? "UIImageView" : "UIButton" )
        for subView in navigationButton.subviews {
            if subView.isKind(of: NSClassFromString(controlName)!) {
                subView.layer.masksToBounds = false
                container = subView
                break
            }
        }
        guard let view = container else { return }
        generatePath(on: view)
        if dot.superlayer == nil {
            view.layer.addSublayer(dot)
        }
    }
}

extension BadgeMaker where Base: UIView {
    func show() {
        generatePath(on: base)
        if dot.superlayer == nil {
            base.layer.addSublayer(dot)
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
