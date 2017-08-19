//
//  SleepDiariesTableViewController.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 17/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit
import SwiftDate
import DZNEmptyDataSet
import Disk
import AudioKit


class SleepDiariesTableViewController: UITableViewController {

    var recordings = [Recording]()
    let classificationService = ClassificationService()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true

        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.handleAdd))

        self.navigationItem.rightBarButtonItems = [addItem, self.editButtonItem]

        guard let retrievedRecordings = try? Disk.retrieve("recordings.json", from: .documents, as: [Recording].self) else { return }
        self.recordings = retrievedRecordings
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

        let sentiment = classificationService.predictSentiment(from: recording.text)
        cell.textLabel?.text = "\(sentiment.emoji) \(recording.title)"
        cell.detailTextLabel?.text = "\(recording.subtitle)\n\n" + classificationService
            .features(from: recording.text)
            .map { "\($0.key)" }
            .joined(separator: ", ")
        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let recording = self.recordings[indexPath.row]
            self.recordings.remove(at: indexPath.row)
            do {
                try Disk.save(self.recordings, to: .documents, as: "recordings.json")
                // Delete the row from the data source
                if let fileURL = recording.fileURL {
                    try Disk.remove(fileURL.lastPathComponent, from: .documents)
                }
            } catch {}

            DispatchQueue.main.async {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

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
    func didComplete(_ recording: Recording) {
        self.recordings.append(recording)
        try? Disk.save(self.recordings, to: .documents, as: "recordings.json")
        self.tableView.reloadData()
    }
}
