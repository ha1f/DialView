//
//  DialView.swift
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
    private var velocity: CGFloat = 0.0
    private var brakeTimer: NSTimer? = nil
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
            self._rotationOffset = CGFloat(DialView.normalizeDegree(Double(newValue)))
        }
    }
    
    var activeCellIndex: Int {
        let cellViewsCount = cellViews.count
        let iDouble = -(Double(rotationOffset) - M_PI / 2) * Double(cellViewsCount) / 2 / M_PI
        let i = Int(round(iDouble))
        return i >= 0 ? i : i + cellViewsCount
    }
    
    var cellViewsCount: Int {
        return cellViews.count
    }
    
    override var frame: CGRect {
        didSet {
            reLayoutCellViews(0)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        let touchPos = touches.first!.locationInView(self)
        let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        
        let deg = atan(-Double((touchPos.y - center.y) / (touchPos.x - center.x)))
        preTouchDeg = deg
        
        if brakeTimer?.valid ?? false {
            brakeTimer!.invalidate()
        }
        velocity = 0
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        
        let touchPos = touches.first!.locationInView(self)
        let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        
        let diffX = touchPos.x - center.x
        let diffY = touchPos.y - center.y
        let degTan = -Double(diffY / diffX)
        let deg = atan(diffX == 0 ? Double.infinity : degTan)
        
        if let preDeg = preTouchDeg {
            let d = deg - preDeg
            if abs(d) < (M_PI/2) {
                velocity = CGFloat(d)
            } else {
                velocity = -CGFloat(M_PI - d)
            }
            rotationOffset += velocity
        }
        preTouchDeg = deg
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        preTouchDeg = nil
        if brakeTimer?.valid ?? false {
            brakeTimer!.invalidate()
        }
        brakeTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.onBrakeTimerUpdated) , userInfo: nil, repeats: true)
    }
    
    func onBrakeTimerUpdated() {
        velocity = max(-1.3, min(1.3, velocity))
        
        print(velocity)
        rotationOffset += velocity

        velocity -= velocity > 0 ? 0.03 : -0.03
        
        if abs(velocity) <= 0.03 {
            velocity = 0
            brakeTimer?.invalidate()
        }
    }
    
    static func normalizeDegree(deg: Double) -> Double {
        var tmp = deg
        while tmp > M_PI {
            tmp -= 2*M_PI
        }
        while tmp < -M_PI {
            tmp += 2*M_PI
        }
        return tmp
    }
    
    private func reLayoutCellViews(duration: Double) {
        let cellViewsCount = cellViews.count
        let radius = (min(self.bounds.width, self.bounds.height) - DialView.CELL_WIDTH)/2
        let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        
        let activeCellIndex = self.activeCellIndex
        
        UIView.animateWithDuration(duration) {[weak self] in
            guard let `self` = self else {
                return
            }
            self.cellViews.enumerate().forEach {i, v in
                let theta = 2 * CGFloat(M_PI) * CGFloat(i) / CGFloat(cellViewsCount) + self.rotationOffset
                let pos = CGPoint(x: center.x + radius * cos(theta), y: center.y - radius * sin(theta))
                v.center = pos
                
                if i == activeCellIndex {
                    v.backgroundColor = UIColor.yellowColor()
                } else {
                    v.backgroundColor = UIColor.redColor()
                }
            }
        }
    }
    
    func rotationOffsetAtIndex(index: Int) -> Double {
        let cellViewsCount = cellViews.count
        return -2 * M_PI * Double(index % cellViewsCount) / Double(cellViewsCount) + M_PI / 2
    }
    
    func scrollTo(index: Int) {
        rotationOffset = CGFloat(rotationOffsetAtIndex(index))
    }
    
    func addCellView(view: UIView) {
        let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        view.center = center
        cellViews.append(view)
        self.addSubview(view)
        reLayoutCellViews(0.3)
    }
}
