//
//  ChatViewController.swift
//  gogochat
//
//  Created by KimJungtae on 2017. 2. 8..
//  Copyright © 2017년 Dolmong. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import FirebaseDatabase
import AVKit
import FirebaseStorage
import FirebaseAuth
import SDWebImage

class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    var messages = [JSQMessage]()
    
    var messageRef = FIRDatabase.database().reference().child("message")
    
    var avatarImage = [String:JSQMessagesAvatarImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currenUser = FIRAuth.auth()?.currentUser {

            self.senderId = currenUser.uid
            
            if currenUser.isAnonymous {
                
                self.senderDisplayName = "jtk"
                
            } else {
                
                self.senderDisplayName = currenUser.displayName
            }
            
            
        }
        
        
        observeMessage()
        
    }
    

    @IBAction func logout(_ sender: Any) {
        
        do {
        
            try FIRAuth.auth()?.signOut()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            
            appdelegate.window?.rootViewController = loginVC
            
            
        } catch {
            
            print("logout failed")
            
        }
        
        

    }
    
    
    func observeUser(id: String) {
        
        FIRDatabase.database().reference().child("users").child(id).observe(.value, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject]{
                
                let avatarUrl = dict["photoUrl"] as! String
                self.setupAvatar(url: avatarUrl, id: id)
                
            }
        })
        
        
        
    }
    
    func setupAvatar(url: String, id: String) {
        
        if url != "" {
            
            let urlurl = URL(string: url)
            let data = try? Data(contentsOf: urlurl!)
            let image = UIImage(data: data!)
            let userImg = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
            avatarImage[id] = userImg
            self.collectionView.reloadData()
            
        } else {
            
            avatarImage[id] = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profileImage"), diameter: 30)
            self.collectionView.reloadData()
        }
        
        
    }
    
    
    func observeMessage() {
        
        messageRef.observe(.childAdded, with: { (snapshot) in
            
            if let dict = snapshot.value as? [String: AnyObject] {
                
                
                let senderId = dict["senderId"] as! String
                let senderName = dict["senderName"] as! String
                let type = dict["type"] as! String
                
                self.observeUser(id: senderId)
                
                switch type {
                case "TEXT" :
                    
                    if let text = dict["text"] as? String {
                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                        }
                case "PHOTO" :
                    
                    
                    
// 스위프트에서 자체적으로 지원하는 백그라운드 작업 asyncronization 
                    
//                    var photo = JSQPhotoMediaItem(image: nil)
//                    let fileUrl = dict["fileUrl"] as! String
//
//                    if let cachedPhoto = self.photoCache.objectForKey(fileUrl) as? JSQPhotoMediaItem { JT: 미리 받아둔캐시가있는지
//                        photo = cachedPhoto
//                        self.collectionView.reloadData()
//                    } else {
//                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), {
//                            let data = try Data(contentsOf: url!)
//                            dispatch_async(dispatch_get_main_queue(), {
//                                let image = UIImage(data: data!)
//                                photo.image = image
//                                self.collectionView.reloadData()
//                                self.photoCache.setObject(photo, forKey: fileUrl) JT: 처음 본 파일은 캐시로 저장
//                            })
//                        })
//                    }
                    
                    
                    
// 내가 짠 코드, asyncronization 적용 전
//                   if let fileUrl = dict["fileUrl"] as? String {
//                        let url = URL(string: fileUrl)
//
//                    do {
//                        
//                        let data = try Data(contentsOf: url!)
//                        let picture = UIImage(data: data)
//                        let photo = JSQPhotoMediaItem(image: picture!)
//                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))
//                        
//                        if self.senderId == senderId {
//                            photo?.appliesMediaViewMaskAsOutgoing = true
//                        } else {
//                            photo?.appliesMediaViewMaskAsOutgoing = false
//                            
//                        }
//                    
//                    }
//                    catch {
//                        print("data convert error")
//                    }
//                    
//                    }

                    
// SD WEB IMAGE 이용한 ayncronization, cache 적용 코드
                    let fileUrl = dict["fileUrl"] as! String
                    
                    let photo = JSQPhotoMediaItem(image: nil)
                    
                    let url = URL(string: fileUrl)

                    let downloader = SDWebImageDownloader.shared()
                    
                    downloader.downloadImage(with: url!, options: [], progress: nil, completed: { (image, data, error, success) in
                        
                        DispatchQueue.main.async(execute: { 
                            photo?.image = image
                            self.collectionView.reloadData()
                        })
                        
                    })
                    
                    
                    
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))

                    if self.senderId == senderId {
                        photo?.appliesMediaViewMaskAsOutgoing = true
                    } else {
                        photo?.appliesMediaViewMaskAsOutgoing = false
                        
                    }
                
                
                    
                    
                
                case "VIDEO" :
                    
                    if let fileUrl = dict["fileUrl"] as? String {
                        let video = URL(string: fileUrl)!
                        let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: videoItem))
                        
                        
                        if self.senderId == senderId {
                            videoItem?.appliesMediaViewMaskAsOutgoing = true
                        } else {
                            videoItem?.appliesMediaViewMaskAsOutgoing = false
                            
                        }
                    }
                    
                default :
                    print("unknown type of messages")
                }
                
            self.collectionView.reloadData()
                
                
            }
            
            
        })
 
        
    }
    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let newMessage = messageRef.childByAutoId()
        
        let messageData = ["text":text, "senderId":senderId, "senderName":senderDisplayName, "type":"TEXT"]
            
        newMessage.setValue(messageData)
        
        self.finishSendingMessage() // textfield 값을 초기화해줌
        
        
        
    }
    
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let sheet = UIAlertController(title: "Medias", message: "Choose youe media type", preferredStyle: .actionSheet)
        
        self.present(sheet, animated: true, completion: nil)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (alert) in
            
            self.mediaPicker(type: kUTTypeImage)
            
        }
        
        let videoLibrary = UIAlertAction(title: "Video Library", style: .default) { (alert) in
            
            self.mediaPicker(type: kUTTypeMovie)
            
        }
        
        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        
        
        
        
    }
    
    func mediaPicker(type: CFString) {
        
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
        
        
    }
    
    func sendMedia(picture: UIImage?, video: NSURL?) {
        
        let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(NSDate.timeIntervalSinceReferenceDate)"
        
        
        if let picture = picture {
            
            let data = UIImageJPEGRepresentation(picture, 0.1)
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpg"
            
            
            FIRStorage.storage().reference().child(filePath).put(data!, metadata: metaData) { (metaData, error) in
                if error != nil {
                    print((error?.localizedDescription)!)
                }
                
                
                let fileUrl = metaData?.downloadURLs![0].absoluteString
                
                
                let newMediamessage = self.messageRef.childByAutoId()
                let mediaMessageData = ["fileUrl" : fileUrl, "senderId":self.senderId, "senderName" : self.senderDisplayName, "type":"PHOTO"]
                newMediamessage.setValue(mediaMessageData)
                // database does not support url type so we should configure it to String
            }
            
        } else if let video = video {
            
            do {
                
                let data = try Data(contentsOf: video as URL)
                
                let metaData = FIRStorageMetadata()
                metaData.contentType = "video/mp4"
                
                FIRStorage.storage().reference().child(filePath).put(data, metadata: metaData, completion: { (metaData, error) in
                    if error != nil {
                        
                        print((error?.localizedDescription)!)
                        
                    } else {
                        
                        
                        let fileUrl = metaData?.downloadURLs![0].absoluteString
                        
                        let newMediamessage = self.messageRef.childByAutoId()
                        let mediaMessageData = ["fileUrl" : fileUrl, "senderId":self.senderId, "senderName" : self.senderDisplayName, "type":"VIDEO"]
                        newMediamessage.setValue(mediaMessageData)
                        
                        
                    }
                })
                
            } catch {
                
                
            }
            
            
        }
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            sendMedia(picture: image, video: nil)
            
        }
            
        else if let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL {
            
            sendMedia(picture: nil, video: videoURL)
            
        }
        
        collectionView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }

    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = messages[indexPath.item]
        
        if message.isMediaMessage {
            
            if let mediamessage = message.media as? JSQVideoMediaItem {
                
                let media = mediamessage.fileURL
                
                let player = AVPlayer(url: media!)
                
                let playerViewController = AVPlayerViewController()
                
                playerViewController.player = player
                
                self.present(playerViewController, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    // JT: collectionview conventions are below
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
     
        let message = messages[indexPath.item]
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        
        if message.senderId == self.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: .black)

            
        } else {
        
            return bubbleFactory?.incomingMessagesBubbleImage(with: .blue)
            
        }
        
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.item]
        
        return avatarImage[message.senderId]
        
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        return cell
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
