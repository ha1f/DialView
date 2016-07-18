//
//  DialView.swift
//  dialView
//
//  Created by 山口智生 on 2016/07/18.
//  Copyright © 2016年 ha1f. All rights reserved.
//

import UIKit

// TODO: 慣性の計算
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
    
    func scrollTo(index: Int) {
        let cellViewsCount = cellViews.count
        guard index >= 0 && index < cellViewsCount else {
            return
        }
        
        rotationOffset = CGFloat(-2 * M_PI * Double(index) / Double(cellViewsCount) + M_PI / 2)
    }
    
    func addCellView(view: UIView) {
        let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        view.center = center
        cellViews.append(view)
        self.addSubview(view)
        reLayoutCellViews(0.3)
    }
}
