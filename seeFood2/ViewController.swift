//
//  ViewController.swift
//  seeFood2
//
//  Created by 刘祥 on 7/24/18.
//  Copyright © 2018 shaneliu90. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import Social

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var imageView: UIImageView!

    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let apiObj = Api()
    
    let imagePicker = UIImagePickerController()
    var classificationResults : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imagePicker.delegate = self
        shareButton.isHidden = true

        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        cameraButton.isEnabled = false
        SVProgressHUD.show()

        if let pickImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let apiKey = apiObj.key
            let version = "2018-07-24"
            
            imageView.image = pickImage
            imagePicker.dismiss(animated: true, completion: nil)
            let visualRecognition = VisualRecognition(version: version, apiKey: apiKey)
            
            let imageData = UIImageJPEGRepresentation(pickImage, 0.01)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            try? imageData?.write(to: fileURL, options: [])
        
            visualRecognition.classify(imagesFile: fileURL) { (classifiedImage) in
                
                let classes = classifiedImage.images.first!.classifiers.first!.classes
                self.classificationResults = []
                for index in 0..<classes.count {
                    self.classificationResults.append(classes[index].className)
                }
                print(self.classificationResults)
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                    self.shareButton.isHidden = false
                
                }
                if self.classificationResults.contains("hotdog"){
                    DispatchQueue.main.async {
                        self.navigationItem.title = "HotDog"
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.imgLogo.image = UIImage(named: "hotdog")
                    }
                }else{
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Not a Hotdog"
                        self.navigationController?.navigationBar.barTintColor = UIColor.red
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.imgLogo.image = UIImage(named: "not-hotdog")
                        
                    }
                }
            }
        }
    }
    
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
            let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            vc?.setInitialText("my food is \(navigationItem.title ?? "no value yet")")
            vc?.add(#imageLiteral(resourceName: "hotdogBackground"))
            present(vc!, animated: true, completion: nil)
        }else{
            self.navigationItem.title = "please login facebook"
        }
    }
    
}



