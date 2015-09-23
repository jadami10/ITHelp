//
//  ViewController.swift
//  GetHelpSwift
//
//  Created by X on 9/21/15.
//  Copyright © 2015 ITHelp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var trialLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Alamofire.request(.GET, "http://localhost:3000/post").responseJSON(){
            (data) in
            let json = JSON(data: data)
            self.trialLabel.text = String(data)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}