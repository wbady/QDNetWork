//
//  ViewController.swift
//  NetWork
//
//  Created by ADY on 09/04/2024.
//  Copyright (c) 2024 ADY. All rights reserved.
//

import UIKit
import NetWork

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        QDNetworkService.request(_, target: QDNetworkConfig.showAccounts, completion: @escaping successCallBack)
    }
}

