//
//  RequestViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Johan Adami on 10/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class RequestViewController: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate , UITextFieldDelegate, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var imagePickerButton: UIButton!
    @IBOutlet weak var imageCancelButton: UIButton!
    @IBOutlet weak var requestTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imagePicker: UIImageView!
    var imagePickerView: UIImagePickerController!
    var photoFile: NSData!

    @IBOutlet weak var tagCollectionView: UICollectionView!
    var busyFrame: UIView?
    
    @IBOutlet weak var titleTextFieldCount: UILabel!
    @IBOutlet weak var requestTextViewCount: UILabel!
    let maxTitleLength = 50
    let maxRequestLength = 500
    var selectedTags = [Bool](count: TagManager.sharedInstance.getNumTags(), repeatedValue: false)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        titleTextField.delegate = self
        requestTextView.delegate = self
        tagCollectionView.allowsMultipleSelection = true
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        self.getMaxTickets()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        checkImageButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelImagePressed(sender: AnyObject) {
        imagePicker.image = nil
        checkImageButton()
    }
    
    
    //adding photo functionality - need to test with real device
    @IBAction func takePhoto() {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            imagePickerView =  UIImagePickerController()
            imagePickerView.delegate = self
            imagePickerView.sourceType = .Camera
            presentViewController(imagePickerView, animated: true, completion: checkImageButton)
        } else {
            self.presentAlert("No Rear Camera", message: "Camera not available", completion: nil)
        }

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePickerView.dismissViewControllerAnimated(true, completion: nil)
        imagePicker.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }

    func checkImageButton() {
        if imagePicker.image != nil {
            imageCancelButton.hidden = false
        } else {
            imageCancelButton.hidden = true
        }
    }


    @IBAction func requestPressed(sender: AnyObject) {
        
        var goodRequest = true
        let ticketTitle = titleTextField.text
        let ticketMsg = requestTextView.text
        
        if (ticketTitle == nil || ticketTitle!.isEmpty) {
            goodRequest = false
            titleTextField.shakeTextField()
        }
        if (ticketMsg == nil || ticketMsg!.isEmpty) {
            goodRequest = false
            requestTextView.shakeTextView()
        }
        
        if (goodRequest) {

            self.asyncBlockingAction("Sending Request", taskToRun: sendRequest)

        }
    }
    
    func sendRequest(activityFrame:UIView) -> Void {
        self.busyFrame = activityFrame
        let ticketTitle = titleTextField.text
        let ticketMsg = requestTextView.text
        let currentUser = PFUser.currentUser()
        let requestObject = PFObject(className:"Request")
        if (imagePicker.image != nil){
            let file = PFFile(name: "image", data: UIImageJPEGRepresentation(imagePicker.image!, 0.5)!)
            requestObject["photoFile"] = file
        }
        requestObject["requester"] = currentUser?.username
        requestObject["requesterPointer"] = currentUser
        requestObject["requestMessage"] = ticketMsg
        requestObject["title"] = ticketTitle
        requestObject["taken"] = 0
        requestObject["tags"] = self.getSelectedTags()
        
        if AppConstants.curTicketsNum < AppConstants.maxTickets {
            RequestHandler.postRequest(requestObject, completion: self.checkRequest)
        } else {
            self.presentAlert("Too many requests", message: String(format: "At max requests: %d", AppConstants.maxTickets), completion: nil)
            self.releaseUI()
        }
    }

    
    func checkRequest(result: NSError?) -> Void {
        if let error = result {
            
            let errorString = error.userInfo["error"] as? NSString
            let errorCode = error.code
            
            switch errorCode {
            case 100:
                self.presentAlert("No Connection", message: "Please check network connection", completion: nil)
                break
            case 142:
                if errorString != nil && errorString == "Too many open requests" {
                    self.presentAlert("Too many requests", message: String(format: "At max requests: %d", AppConstants.maxTickets), completion: nil)
                } else {
                    print(NSString(format: "Unhandled Error: %d", errorCode))
                    self.presentAlert("Error", message: "Please try again later", completion: nil)
                }
                break
            default:
                self.presentAlert("Error", message: "Please try again later", completion: nil)
                print(NSString(format: "Unhandled Error: %d", errorCode))
                break
            }
            print(errorString)
            
        } else {
            self.clearUI()
            self.releaseUI()
            goBackToHelpView()
        }
        self.releaseUI()
    }
    
    @IBAction func titleTextFieldChanged(sender: AnyObject) {
        if (sender as! NSObject == titleTextField) {
            titleTextFieldCount.text = String(format: "%d/%d", (titleTextField.text?.characters.count)!, maxTitleLength)
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text!
        let newString: NSString =
        currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxTitleLength
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        let curLength = textView.text.characters.count + text.characters.count - range.length
        if (curLength <= maxRequestLength) {
            requestTextViewCount.text = String(format: "%d/%d", curLength, maxRequestLength)
            return true
        } else {
            return false
        }

    }
    
    func getMaxTickets() {
        if let maxTickets = PFUser.currentUser()?.objectForKey("MaxTickets") as? Int {
            AppConstants.maxTickets = maxTickets
        } else {
            AppConstants.maxTickets = 5
        }
        print(String(format: "Max Tickets: %d", AppConstants.maxTickets))
    }
    
    func clearUI() {
        requestTextView.text = ""
        titleTextField.text = ""
        imagePicker.image = nil
        requestTextViewCount.text = String(format: "%d/%d", 0, maxRequestLength)
        titleTextFieldCount.text = String(format: "%d/%d", (titleTextField.text?.characters.count)!, maxTitleLength)
        for i in 0 ... selectedTags.count - 1 {
            selectedTags[i] = false
        }
        self.tagCollectionView.reloadData()
    }
    
    func releaseUI() {
        self.view.userInteractionEnabled = true
        self.busyFrame?.removeFromSuperview()
    }
    
    func goBackToHelpView() {
        let storyboard = UIStoryboard(name: "request", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("HelpView") as! HelpOnWayViewController
        controller.modalTransitionStyle = .CrossDissolve
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TagManager.sharedInstance.getNumTags()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TagCell", forIndexPath: indexPath) as! RequestTagCell
        if indexPath.section == 0 {
            let tag = TagManager.sharedInstance.getTag(indexPath)
            cell.tagVal.text = tag.tagName
            cell.backgroundColor = tag.tagColor
            
            if selectedTags[indexPath.row] {
                cell.layer.borderWidth = 2.0
                cell.layer.borderColor = UIConstants.mainUIColor.CGColor
            } else {
                cell.layer.borderWidth = 0.0
                cell.layer.borderColor = UIConstants.mainUIColor.CGColor
            }
//            cell.tagVal.sizeToFit()
        } else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let myHeight : CGFloat = 30
        var myWidth:CGFloat
        
        let tagNum = TagManager.sharedInstance.getNumTags()
        if tagNum > 0 {
            myWidth = collectionView.frame.width/CGFloat(tagNum) - 5
        } else {
            myWidth = 0
        }

        return CGSizeMake(myWidth, myHeight)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.layer.borderWidth = 2.0
        cell?.layer.borderColor = UIConstants.mainUIColor.CGColor
        self.selectedTags[indexPath.row] = true
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.layer.borderWidth = 0.0
        cell?.layer.borderColor = UIConstants.mainUIColor.CGColor
        self.selectedTags[indexPath.row] = false
    }

    func getSelectedTags() -> [PFObject] {
        var selTags = [PFObject]()
        let paths = self.tagCollectionView.indexPathsForSelectedItems()
        if paths != nil {
            for path in paths! {
                selTags.append(TagManager.sharedInstance.getTag(path).tagObject)
            }
        }
        if selTags.count > 0 {
            return selTags
        } else {
            return TagManager.sharedInstance.defaultTags
        }

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
