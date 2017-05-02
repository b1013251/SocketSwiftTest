//
//  ViewController.swift
//  SocketTest
//
//  Created by hogehoge on 2017/05/02.
//  Copyright © 2017年 hogehoge. All rights reserved.
//

import UIKit
import SocketIO
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    
    var socket : SocketIOClient!
    var messages : [String] = []

    var miyakoImage : Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        tableView.dataSource = self
        
        let miyakoPath = NSURL.fileURL(withPath: Bundle.main.path(forResource: "miyako", ofType: "jpg")!)
        do {
            self.miyakoImage = try Data(contentsOf: miyakoPath)
            imageView.image = UIImage(data: miyakoImage)
        } catch {
            print("error")
        }
        
        let url = "http://192.168.116.72:8000"
        
        self.socket = SocketIOClient(socketURL: URL(string: url)!, config: [.forceWebsockets(true)])
        
        socket.on("connect") { data, ack in
            print("socket connected")
        }
        
        socket.on("chat message") { data, ack in
            if let msg = data[0] as? String {
                print("receive: " + msg)
                self.messages.append(msg)
                self.tableView.reloadData()
            }
        }
        
        socket.on("image_from_server") {data, ack in
            self.imageView.image = UIImage(data: data[0] as! Data)
        }
        
        socket.on("json_from_server") {data, ack in
            let j = data[0] as? String
            guard let jsonstring = j else {
                print("cast error")
                return
            }
            
            let jsondata = jsonstring.data(using: String.Encoding.utf8, allowLossyConversion: true)
            
            do {
                let json = try JSON(data: jsondata!)
                print("name:" + json["name"].string!)
                print("job:" + json["job"].string!)
            }
            catch {
                print("json parse error")
            }
            
        }
        
        socket.connect()
    }
    
    func sendMessage() {
        guard let text = textField.text else {
            return
        }
        self.socket.emit("chat message", text)
        self.textField.resignFirstResponder()
        self.textField.text = ""
    }
    
    @IBAction func pushImageUpload(_ sender: Any) {
        self.socket.emit("image_from_client", self.miyakoImage)
    }
    
    
    @IBAction func pushJSONUpload(_ sender: Any) {
        let dict : [String:String] = [
            "name": "newsoku de yaruo",
            "job": "neet"
        ]
        let json = JSON(dict).rawString()
        self.socket.emit("json_from_client", json!)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendMessage()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textField.resignFirstResponder()
    }
    
    @IBAction func pushSend(_ sender: Any) {
        self.sendMessage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "defualt")
        cell.textLabel?.text = self.messages[indexPath.row]
        return cell
    }

}

