//
//  GAEMessenger.swift
//  Dex
//
//  Created by Charles Wang on 8/20/16.
//  Copyright © 2016 Charles Wang. All rights reserved.
//

import Foundation
import UIKit

public class GAEMessenger {
    
    class func sendImage(image: UIImage, imageName:String, completionHandler:(NSData?, NSURLResponse?, NSError?) -> Void) {
        let url = "https://dexapp-2016.appspot.com/upload"
        let data: NSData = UIImageJPEGRepresentation(image, 1)!
        
        // TODO: figure out how to get a unique image name
        // TODO: adding the ".jpg" is kinda hacky. better design plz.
        sendFile(url, fileName:imageName+".jpg", data:data, completionHandler:completionHandler)
    }
    
    private class func sendFile(urlPath:String, fileName:String, data:NSData,
        completionHandler:(NSData?, NSURLResponse?, NSError?) -> Void){
        
        let url: NSURL = NSURL(string: urlPath)!
        let request1: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        
        request1.HTTPMethod = "POST"
        
        let boundary = generateBoundary()
        let fullData = photoDataToFormData(data,boundary:boundary,fileName:fileName)
        
        request1.setValue("multipart/form-data; boundary=" + boundary,
                          forHTTPHeaderField: "Content-Type")
        
        // REQUIRED!
        request1.setValue(String(fullData.length), forHTTPHeaderField: "Content-Length")
        
        request1.HTTPBody = fullData
        request1.HTTPShouldHandleCookies = false
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request1, completionHandler: completionHandler)
        task.resume()
        
//        let conn = NSURLConnection(request: request1, delegate: self)
//        if((conn) != nil) {
//            NSLog("Connection Successful")
//        } else {
//            NSLog("Connection could not be made")
//        }
    }
    
    private class func generateBoundary() -> String {
        return "cvwang"
    }
    
    // this is a very verbose version of that function
    // you can shorten it, but i left it as-is for clarity
    // and as an example
    private class func photoDataToFormData(data:NSData,boundary:String,fileName:String) -> NSData {
        let fullData = NSMutableData()
        
        // 1 - Boundary should start with --
        let lineOne = "--" + boundary + "\r\n"
        fullData.appendData(lineOne.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 2
        let lineTwo = "Content-Disposition: form-data; name=\"file\"; filename=\"" + fileName + "\"\r\n"
        NSLog(lineTwo)
        fullData.appendData(lineTwo.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 3
        let lineThree = "Content-Type: image/jpg\r\n\r\n"
        fullData.appendData(lineThree.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 4
        fullData.appendData(data)
        
        // 5
        let lineFive = "\r\n"
        fullData.appendData(lineFive.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 6 - The end. Notice -- at the start and at the end
        let lineSix = "--" + boundary + "--\r\n"
        fullData.appendData(lineSix.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        return fullData
    }
    
}