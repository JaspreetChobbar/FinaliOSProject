//
//  AddDetailViewController.swift
//  FinaliOSProject
//
//  Created by Jaspreet Singh on 2020-01-20.
//  Copyright © 2020 Jaspreet Singh. All rights reserved.
//

import UIKit

class AddDetailViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDataSource, UIPickerViewDelegate ,UITextFieldDelegate{
    
    // Variables
    
    var image: UIImage?
    var userData = UserData()
    var index = 0
    let datePicker = UIDatePicker()
    var formatter = DateFormatter()
    
    //Outlets
    
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var countryTxtField: UITextField!
    @IBOutlet weak var genderTxtField: UITextField!
    @IBOutlet weak var latitudeTxtField: UITextField!
    @IBOutlet weak var longitudeTxtField: UITextField!
    @IBOutlet weak var birthdayTxtField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
        
    // dynamic picker start
    let picker = UIPickerView()
    var gender_list = ["Male","Female","Other"]
    
     func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
     }
     
     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return  gender_list.count
     }
     
     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return gender_list[row]
     }
     
     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
         genderTxtField.text = gender_list[row]
     }
    
    // pickerview end
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchHappen))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        
        showDatePicker()
        
        UserDefaults.standard.set("", forKey: "country")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        picker.delegate = self
        picker.dataSource = self
        genderTxtField.inputView = picker
        
        let toolbarNew = UIToolbar();
           toolbarNew.sizeToFit()
           let doneButton1 = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker1));
           let spaceButton1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
           let cancelButton1 = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
           
           toolbarNew.setItems([doneButton1,spaceButton1,cancelButton1], animated: false)
        
        genderTxtField.inputAccessoryView = toolbarNew
        genderTxtField.inputView = picker
        
        countryTxtField.delegate = self
        
            let selectedCountry = UserDefaults.standard.string(forKey: "country")
            countryTxtField.text = selectedCountry
        
        
    }

    @objc func donedatePicker1(){
       // genderTxtField.text = picker. datePicker.date)
        self.view.endEditing(true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool   {

        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CountryList") as? CountryList {
                   
                   if let navigator = navigationController {
                       navigator.pushViewController(viewController, animated: true)
                   }
        }
        
        self.view.endEditing(true)
        return false
    }
    
    @objc func touchHappen() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
        pickPhoto()
    }
    
    func insertRecord(name:String, country:String,latitude: Double,longitude: Double,gender:String,birthday: Date,userImage: NSNumber){
        
        let userData = UserData(context: HomeViewController.managedContext)
        
        userData.name = name
        userData.country = country
        userData.gender = gender
        userData.latitude = latitude
        userData.longitude = longitude
        userData.birthday = birthday
        
        if let image = image {
            userData.photoID = nil
            
            if !userData.hasPhoto {
                userData.photoID = UserData.nextPhotoID() as NSNumber
            }
            
            if let data = image.jpegData(compressionQuality: 0.5) {
                do {
                    try data.write(to: userData.photoURL, options: .atomic)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }
        do {
            try! HomeViewController.managedContext.save()
            afterDelay(0.6) {
                
                //   self.navigationController?.popViewController(animated: true)
            }
        } catch {
            fatalCoreDataError(error)
        }
        
        //        if let img = UIImage(named: "dog.png") {
        //            // let data = img.pngData() as NSData?
        //
        //        }
        
        try! HomeViewController.managedContext.save()
    }
}

extension AddDetailViewController{
    
    // Button Actions
    
    @IBAction func submitBtnTapped(_ sender: Any) {
        
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        insertRecord(name: nameTxtField.text!, country: countryTxtField.text!, latitude: Double(latitudeTxtField.text!)!, longitude: Double(longitudeTxtField.text!)!, gender: genderTxtField.text!, birthday: formatter.date(from: birthdayTxtField.text ?? "") ?? Date() , userImage: NSNumber(value: index))
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        
    }
    
    //Date picker
    func showDatePicker(){
        
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        birthdayTxtField.inputAccessoryView = toolbar
        birthdayTxtField.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        birthdayTxtField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    
    
    //  Functions for picking image from gallery
    
    func show(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
    }
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actCancel)
        let actPhoto = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.takePhotoWithCamera()
        })
        alert.addAction(actPhoto)
        let actLibrary = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in
            self.choosePhotoFromLibrary()
        })
        alert.addAction(actLibrary)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK:- Image Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if let theImage = image {
            show(image: theImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
