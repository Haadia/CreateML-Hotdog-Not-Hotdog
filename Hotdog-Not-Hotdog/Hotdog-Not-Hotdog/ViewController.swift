//
//  ViewController.swift
//  Hotdog-Not-Hotdog
//
//  Created by Hadia Jalil on 06/04/2019.
//  Copyright © 2019 Hadia Jalil. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var hotdogLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var takeImageButton: UIButton!
    
    let model = HotdogClassifier()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 15
        takeImageButton.layer.cornerRadius = 10
    }

    override func viewWillAppear(_ animated: Bool) {
    
    }
    
    
    @IBAction func cameraPressed(_ sender: Any) {
        if UIImagePickerController.isCameraDeviceAvailable( UIImagePickerController.CameraDevice.front) {
            let imagePicker = UIImagePickerController()
            imagePicker.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            print("Not available")
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        takeImageButton.titleLabel?.text = "Retake Image"
        imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
    
        //Get captured image
        let userImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        //Make prediction while converting image to CVPixelBuffer
        guard let output = try? model.prediction(image: buffer(from: userImage!)!) else {
            return
        }
        
        //Display predicted output
        if output.classLabel == "hot_dog" {
            hotdogLabel.text = "Hotdog!!! 🌭"
        }
        else if output.classLabel == "not_hot_dog" {
            hotdogLabel.text = "Not Hotdog!!! ☹️"
        }
    }
    
    public func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }

    
}

