//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

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
        label.badge.color = .orange
        label.badge.offset = CGPoint(x: -100, y: 0)
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
