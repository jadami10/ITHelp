//
//  ViewController.swift
//  BriskIT
//
//  Created by X on 9/21/15.
//  Copyright © 2015 ITHelp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let parameters: [String: AnyObject] = ["messages":"good day to you"] // fill in your params
        // Do any additional setup after loading the view, typically from a nib.
        /*Alamofire.request(.GET, "http://localhost:3000/messages").responseJSON(){ data in
            print(String(data))
        }*/

        Alamofire.request(.PUT, "http://localhost:3000/messages", parameters: parameters, encoding: .JSON).responseJSON(){
            (data) in
            let x = data.result.value!.valueForKey("howdy")!
            print(x)
            //NSJSONSerialization.JSONObjectWithData(data: data, options: <#T##NSJSONReadingOptions#>)

        }
            }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}