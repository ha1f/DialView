//
//  ViewController.swift
//  dialView
//
//  Created by 山口智生 on 2016/07/18.
//  Copyright © 2016年 ha1f. All rights reserved.
//

import UIKit

class DialView: UIView {
    
    static let CELL_WIDTH: CGFloat = 40.0
    
    private var cellViews = [UIView]()
    private var preTouchDeg: Double? = nil
    private var _rotationOffset: CGFloat = 0.0 {
        didSet {
            reLayoutCellViews(0.1)
        }
    }
    var rotationOffset: CGFloat {
        get {
            return self._rotationOffset
        }
        set {
            var tmp = newValue
            while tmp > CGFloat(M_PI) {
                tmp -= CGFloat(2*M_PI)
            }
            while tmp < CGFloat(-M_PI) {
                tmp += CGFloat(2*M_PI)
            }
            self._rotationOffset = tmp
        }
    }
    
    var cellViewsCount: Int {
        return cellViews.count
    }
    
    override var frame: CGRect {
        didSet {
            reLayoutCellViews(0)
        }
    }
    
    static var currentIndex = 0
    static let cellBuilder: () -> UIView = {
        let v = UILabel(frame: CGRectMake(0, 0, DialView.CELL_WIDTH, DialView.CELL_WIDTH))
        v.backgroundColor = UIColor.redColor()
        v.text = "\(currentIndex)"
        currentIndex += 1
        return v
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addCellView(DialView.cellBuilder())
        addCellView(DialView.cellBuilder())
        addCellView(DialView.cellBuilder())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        let touchPos = touches.first!.locationInView(self)
        let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        
        let deg = atan(-Double((touchPos.y - center.y) / (touchPos.x - center.x)))
        preTouchDeg = deg
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        
        let touchPos = touches.first!.locationInView(self)
        let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        let deg = atan(-Double((touchPos.y - center.y) / (touchPos.x - center.x)))
        
        if let preDeg = preTouchDeg {
            let d = deg-preDeg
            if abs(d) < (M_PI/2) {
                rotationOffset += CGFloat(d)
            } else {
                rotationOffset -= CGFloat(M_PI - d)
            }
        }
        preTouchDeg = deg
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        preTouchDeg = nil
    }
    
    // -M_PI〜M_PIに正規化
    func normalizeRotationOffset() {
        
    }
    
    func scrollTo(index: Int) {
        let cellViewsCount = cellViews.count
        guard index >= 0 && index < cellViewsCount else {
            return
        }
        
        rotationOffset = CGFloat(-2 * M_PI * Double(index) / Double(cellViewsCount) + M_PI / 2)
    }
    
    func reLayoutCellViews(duration: Double) {
        let cellViewsCount = cellViews.count
        let radius = (min(self.bounds.width, self.bounds.height) - DialView.CELL_WIDTH)/2
        let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        
        UIView.animateWithDuration(duration) {[weak self] in
            guard let `self` = self else {
                return
            }
            self.cellViews.enumerate().forEach {i, v in
                let theta = 2 * CGFloat(M_PI) * CGFloat(i) / CGFloat(cellViewsCount) + self.rotationOffset
                let pos = CGPoint(x: center.x + radius * cos(theta), y: center.y - radius * sin(theta))
                v.center = pos
            }
        }
    }
    
    func addCellView(view: UIView) {
        let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        view.center = center
        cellViews.append(view)
        self.addSubview(view)
        reLayoutCellViews(0.3)
    }
    
}

class ViewController: UIViewController {
    
    var dialView: DialView!
    var addButton: UIButton!
    
    override func loadView() {
        super.loadView()
        dialView = DialView()
        addButton = UIButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dialView.frame = CGRect(x: (self.view.frame.width-300)/2, y: (self.view.frame.height-300)/2, width: 300, height: 300)
        dialView.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(dialView)
        
        addButton.frame = CGRectMake(0, 0, 100, 40)
        addButton.backgroundColor = UIColor.blueColor()
        addButton.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height - 80)
        addButton.addTarget(self, action: #selector(self.onClickAddButton(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(addButton)
    }
    
    func onClickAddButton(button: UIButton!) {
        dialView.addCellView(DialView.cellBuilder())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

