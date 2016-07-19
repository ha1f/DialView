//
//  ViewController.swift
//  dialView
//
//  Created by 山口智生 on 2016/07/18.
//  Copyright © 2016年 ha1f. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var dialView: DialView!
    var addButton: UIButton!
    
    var currentIndex = 0
    
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
        
        (0...5).map{ _ in buildCell() }.forEach{ dialView.addCellView($0) }
        
        addButton.frame = CGRectMake(0, 0, 100, 40)
        addButton.backgroundColor = UIColor.blueColor()
        addButton.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height - 80)
        addButton.addTarget(self, action: #selector(self.onClickAddButton(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(addButton)
    }
    
    func onClickAddButton(button: UIButton!) {
        dialView.addCellView(buildCell())
    }
    
    func buildCell() -> UIView {
        let v = UILabel(frame: CGRectMake(0, 0, DialView.CELL_WIDTH, DialView.CELL_WIDTH))
        v.backgroundColor = UIColor.redColor()
        v.text = "\(currentIndex)"
        v.textAlignment = .Center
        currentIndex += 1
        return v
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

