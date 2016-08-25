//
//  ViewController.swift
//  Dex
//
//  Created by Charles Wang on 8/16/16.
//  Copyright © 2016 Charles Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
//        imagePicker.sourceType = .Camera
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postPhoto(sender: AnyObject) {
        if imageView.image != nil {
            let timeInterval = Int(NSDate().timeIntervalSince1970)
            let imageName = "cvwang_" + timeInterval.description
            NSLog("Posting: \(imageName)")
            GAEMessenger.sendImage(imageView.image!, imageName:imageName, completionHandler:{(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                NSLog("Response...")
                dispatch_async(dispatch_get_main_queue(), {
                    // Check to see if post was successful
                    if ((response as! NSHTTPURLResponse).statusCode == 200) {
                        NSLog("Posted!")
                        self.imageView.makeToast(message: "Posted!")
                    } else {
                        NSLog("Failed to send!")
                        self.imageView.makeToast(message: "Failed to send!")
                    }
                })
            })
        } else {
            self.imageView.makeToast(message: "No image displayed!")
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
}

