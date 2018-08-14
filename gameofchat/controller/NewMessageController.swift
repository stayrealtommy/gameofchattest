//
//  NewMessageController.swift
//  gameofchat
//
//  Created by Ma Wai Hung on 2/8/2018.
//  Copyright © 2018 EasyEngineering. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handlecancel))
        
        tableView.register(Usercell.self, forCellReuseIdentifier: "cellId")
        
        fetchUser()
        
    }
    
    
    func fetchUser(){
        
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let snapshotValue = snapshot.value as? [String: String]{
                let user = User()
                user.id = snapshot.key
                user.name = snapshotValue["name"]
                user.email = snapshotValue["email"]
                user.profileImageUrl = snapshotValue["profileImageUrl"]
                self.users.append(user)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    
    @objc func handlecancel(){
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! Usercell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        return cell
    }
    
    var messageController: MessageController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        let user = self.users[indexPath.row]
        self.messageController?.showChatControllerForUser(user: user)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

}




