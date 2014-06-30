//
//  TodayViewController.swift
//  MyTodayExtension
//
//  Created by Pfeil, Brian on 6/4/14.
//  Copyright (c) 2014 Pfeil, Brian. All rights reserved.
//

import UIKit
import NotificationCenter

@objc(BPTodayViewController)
class TodayViewController: UIViewController {
    
    override func viewDidLoad() {
        let sz = CGSizeMake(0.0, 100.0)
        self.preferredContentSize = sz
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.yellowColor()
        view.frame = CGRectMake(0, 0, 320, 100)
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encoutered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
}
