//
//  ChatMessageCell.swift
//  gameofchat
//
//  Created by Ma Wai Hung on 5/8/2018.
//  Copyright © 2018 EasyEngineering. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    var chatLogController: ChatLogContoller?
    
    enum Orientation {
        case right
        case left
    }
    
    var orientation: Orientation? {
        didSet {
            if orientation == .right {
                bubbleViewLeftAnchor?.isActive = false
                bubbleViewRightAnchor?.isActive = true
                profileImageView.isHidden = true
            } else if orientation == .left{
                bubbleViewLeftAnchor?.isActive = true
                bubbleViewRightAnchor?.isActive = false
                profileImageView.isHidden = false
            }
        }
    }
    
    var profileImageURL: String? {
        didSet {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageURL!)
        }
    }
    
    static let blueColor: UIColor = UIColor(r: 0, g: 137, b: 249)
    static let grayColor: UIColor = UIColor(r: 240, g: 240, b: 240)
    
    let chatText : UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.isEditable = false
        return textView
    }()
    
    
    let bubbleView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(r: 0, g: 137, b: 249)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "slamdunk")
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return imageView
    }()
    
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer){
        if let imageView = tapGesture.view as? UIImageView{
            self.chatLogController?.performZoomInForStartingImageView(startingImageView: imageView)
        }
    }
    
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(profileImageView)
        addSubview(chatText)
        
        bubbleView.addSubview(messageImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        
        // need x, y, width and height constraints
        //orientation = .right
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleViewRightAnchor =
            bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        
        // need x, y, width and height constraints
        chatText.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        chatText.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        chatText.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        chatText.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        
        
        
        // need x, y, width and height constraints
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
