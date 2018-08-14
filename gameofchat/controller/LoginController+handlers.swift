//
//  LoginController+handlers.swift
//  gameofchat
//
//  Created by Ma Wai Hung on 2/8/2018.
//  Copyright © 2018 EasyEngineering. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @objc func handleSelectImageView(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
        print("tapped")
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        if let editImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editImage
            
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        
        if let selectimage = selectedImageFromPicker{
            profileImageView.image = selectimage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func handleRegister(){
        
        guard let email = emailTextField.text,let password = passwordTextField.text,let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (authresult, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let uid = Auth.auth().currentUser?.uid else{
                return
            }
            
            let imagename = NSUUID().uuidString
            
            let storageref = Storage.storage().reference().child("profile_images").child("\(imagename).png")
            
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1)
            {
                storageref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    
                storageref.downloadURL(completion: { (url, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    let profileImageUrl = url?.absoluteString
                    let values = ["name": name , "email": email, "profileImageUrl": profileImageUrl] as [String : AnyObject]
                    self.registerUserIntoDatabasewithUID(uid: uid, values: values)
                })
                })
            }
        }
    }
    
    private func registerUserIntoDatabasewithUID(uid:String, values:[String:AnyObject]){
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: {(err,ref) in
            if let error = err {
                print(error)
                return
            }
            let user = User()
            user.name = values["name"] as? String
            user.profileImageUrl = values["profileImageUrl"] as? String
            self.messagesController?.setupNavBarWithUser(user: user)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
}

