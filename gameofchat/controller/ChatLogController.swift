//
//  ChatLogController.swift
//  gameofchat
//
//  Created by Ma Wai Hung on 3/8/2018.
//  Copyright © 2018 EasyEngineering. All rights reserved.
//

import UIKit
import Firebase

class ChatLogContoller: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var user: User?{
        didSet{
            navigationItem.title = user?.name
            observeMessages()
        }
        
    }
    
    var messages = [Message]()
    
    func observeMessages(){
        
        print("observeMessages")
        
        guard let uid = Auth.auth().currentUser?.uid else{return}
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value , with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String:AnyObject] else{return}
                let message = Message(from:dictionary)
                if message.chatPartnerId() == self.user?.id{
                self.messages.append(message)
                    
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    self.scrollToLastItem()
                }
                    
                }
            }, withCancel: nil)
            
        }, withCancel: nil)
        
    }
    
    
    let cellId = "cellId"
    

    override func viewDidLoad() {
        super .viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        //collectionView?.alwaysBounceVertical = true
        
        collectionView?.keyboardDismissMode = .interactive
        
        setupKeyBoardObservers()
    }
    
    //these three method or variable helps keyboard to interactive
    lazy var inputContainerView: ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.chatLogController = self
        return chatInputContainerView
    }()
    override var inputAccessoryView: UIView? {
        return inputContainerView
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    
    func setupKeyBoardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            scrollToLastItem()
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        messages.removeAll()
        self.collectionView = nil
        super.viewDidDisappear(animated)
        //stop playing
        NotificationCenter.default.removeObserver(self)
    }
    
    var containerHeightAnchor: NSLayoutConstraint?
    var containerViewBottomAnchor: NSLayoutConstraint?

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("total message: \(messages.count)")
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        
        let message = messages[indexPath.item]
        
        setupCell(message, cell, itemNo: indexPath.item)
        
        cell.chatText.text = message.text
        if let text = message.text{
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.chatText.isHidden = false
        }else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
        }
        
        return cell
    }
    
    fileprivate func setupCell(_ message: Message, _ cell: ChatMessageCell, itemNo: Int) {
        if message.fromId == user?.id {
            cell.bubbleView.backgroundColor = ChatMessageCell.grayColor
            cell.orientation = .left
            cell.chatText.textColor = .black
            cell.profileImageURL = user?.profileImageUrl
            print("left: \(itemNo)")
        } else {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.orientation = .right
            cell.chatText.textColor = .white
            print("right: \(itemNo)")
        }
        if let imageUrl = message.imageUrl {
            print("hi image again: \(itemNo)")
            cell.bubbleView.backgroundColor = .clear
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: imageUrl)
            cell.messageImageView.isHidden = false
            cell.chatText.isHidden = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height:CGFloat = 80
        
        let message = messages[indexPath.item]
        
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
        } else if let imageHeight = message.imageHeight, let imageWidth = message.imageWidth {
            // h1/w1 = h2/w2
            // h1 = h2 / w2 * w1
            height = round(CGFloat(imageHeight) / CGFloat(imageWidth) * CGFloat(200))
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize.init(width: width, height: height)
    }
    
    func scrollToLastItem() {
        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    
    private func estimateFrameForText(text:String) -> CGRect{
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 16) ], context: nil)
        
    }
    
    @objc func handleSend(){
        sendMessageWithProperties(properties: ["text": inputContainerView.inputTextField.text! as AnyObject])
        self.inputContainerView.inputTextField.text = nil
    }
    
    
    func sendMessageWithProperties(properties:[String: AnyObject]){
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        var values = ["toId":toId, "fromId": fromId, "timestamp":timestamp] as [String : Any]
        
        properties.forEach({values[$0] = $1})
        
        
        childRef.updateChildValues(values) { (err, ref) in
            if let err = err{
                print(err)
                return
            }
            let userMessagesRef = Database.database().reference().child("user-messages")
            let messageId = childRef.key
            let userMessagesDictionary = ["/\(fromId)/\(messageId)": 1, "/\(toId)/\(messageId)": 1]
            userMessagesRef.updateChildValues(userMessagesDictionary)
            
        }

        
    }
    
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    func performZoomInForStartingImageView(startingImageView: UIImageView){
        self.startingImageView = startingImageView
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        guard let image = startingImageView.image, let startingFrame = startingFrame else{
            return
        }
        let zoomingImageView = UIImageView(frame: startingFrame)
        zoomingImageView.image = image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOutImage)))
        
        guard let keyWindow = UIApplication.shared.keyWindow else{
            return
        }
        
        blackBackgroundView = UIView(frame: keyWindow.frame)
        blackBackgroundView?.backgroundColor = .black
        blackBackgroundView?.alpha = 0
        blackBackgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOutOnBackgroundTap)))
        keyWindow.addSubview(blackBackgroundView!)
        
        blackBackgroundView?.addSubview(zoomingImageView)
        startingImageView.isHidden = true
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.blackBackgroundView?.alpha = 1
            self.inputContainerView.alpha = 0
            
            let height = startingFrame.height / startingFrame.width * keyWindow.frame.width
            
            zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
            zoomingImageView.center = keyWindow.center
        }, completion: nil)

    }
    
    @objc func handleZoomOutOnBackgroundTap(tapGesture: UITapGestureRecognizer){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            tapGesture.view?.alpha = 0
            self.inputContainerView.alpha = 1
        }, completion: nil)
    }
    
    @objc func handleZoomOutImage(tapGesture: UITapGestureRecognizer){
        
        guard let zoomOutImageView = tapGesture.view, let startingFrame = startingFrame else{
            return
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            zoomOutImageView.frame = startingFrame
            self.blackBackgroundView?.alpha = 0
            self.inputContainerView.alpha = 1
            self.startingImageView?.isHidden = false
        },completion:{ (completed) in
            zoomOutImageView.removeFromSuperview()
        })
    }
    
    
}

extension ChatLogContoller: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @objc func handleUploadTap() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
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
            uploadtoFirebasewithImage(image: selectimage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadtoFirebasewithImage(image: UIImage){
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child("\(imageName).png")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2){
            ref.putData(uploadData, metadata: metadata) { (metadata, err) in
                if let err = err{
                    print(err)
                    return
                }
                ref.downloadURL(completion: { (url, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    let ImageUrl = url?.absoluteString
                    let properties = ["imageUrl": ImageUrl!, "imageWidth": image.size.width ,"imageHeight": image.size.height] as [String : AnyObject]
                    
                    self.sendMessageWithProperties(properties: properties)
                    
                })
            }
        }
    }
}
