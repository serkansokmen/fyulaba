//
//  SleepDiariesTableViewController.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 17/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit
import Firebase
import SwiftDate


class SleepDiariesTableViewController: UITableViewController {

    var ref: DatabaseReference!
    var recordings = [Recording]()
    var recordingsRef: DatabaseReference?
    var recordingsHandle: DatabaseHandle?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.ref = Database.database().reference()

        self.clearsSelectionOnViewWillAppear = true

        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.handleAdd))

        self.navigationItem.rightBarButtonItems = [addItem, self.editButtonItem]

        guard let user = Auth.auth().currentUser else { return }
        self.recordingsRef = self.ref.child("users").child(user.uid).child("recordings")
        self.recordingsHandle = recordingsRef?.observe(.value) { (snapshot) in

            self.recordings.removeAll()
            snapshot.children
                .flatMap { $0 as? DataSnapshot }
                .flatMap { snapshot in

                    let key = snapshot.key
                    guard let value = snapshot.value as? [String: AnyObject] else { return nil }
                    let text = value["text"] as! String
                    let timeInterval = value["created_at"] as! Double
                    let date = Date(timeIntervalSince1970: TimeInterval(timeInterval))
                    return Recording(key: key, text: text, createdAt: date)
                }
                .forEach { self.recordings.append($0) }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    deinit {
        self.recordingsRef?.removeObserver(withHandle: self.recordingsHandle!)
    }

    @objc func handleAdd(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "ToAddSegue", sender: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.recordings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell", for: indexPath)
        let recording = self.recordings[indexPath.row]
        cell.textLabel?.text = recording.title
//        cell.detailTextLabel?.text = recording.subtitle
        cell.detailTextLabel?.text = recording.sentiment
        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let recording = self.recordings[indexPath.row]
            self.recordingsRef?.child(recording.key).removeValue()
//            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // Override to support rearranging the table view.
//    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
//
//    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier,
            identifier == "ToAddSegue",
        let nav = segue.destination as? UINavigationController,
        let vc = nav.topViewController as? SpeechRecorderViewController
            else { return }

        vc.delegate = self
    }

}

extension SleepDiariesTableViewController: SpeechRecordingDelegate {
    func didRecordSpeech(transcription result: String) {
        self.recordingsRef?.childByAutoId().setValue([
            "text": result,
            "created_at": Date().timeIntervalSince1970
        ])
    }
}
