//
//  RecordingsTableViewController.swift
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
import Hero

enum HeroConstants: String {
    case recordings = "recordings"

}


final class RecordingsTableViewController: UITableViewController {

    var recordings = [Recording]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true
        self.tableView.emptyDataSetSource = self

        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.handleAdd))
        self.navigationItem.rightBarButtonItems = [addItem, self.editButtonItem]

        guard let retrievedRecordings = try? Disk.retrieve("recordings.json", from: .documents, as: [Recording].self) else { return }
        self.recordings = retrievedRecordings

        
    }

    @objc func handleAdd(_ sender: UIBarButtonItem) {
        self.presentRecorder(with: nil)
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
        let sentiment = ClassificationService.shared.predictSentiment(from: recording.text)
        cell.textLabel?.text = "\(sentiment.emoji) \(recording.title)"
        cell.detailTextLabel?.text = "\(recording.subtitle)\n\n"
            + ClassificationService.shared
                .features(from: recording.text)
                .map { "\($0.key)" }
                .joined(separator: ", ")

        cell.heroID = "cell_\(indexPath.row)"
        cell.heroModifiers = [.arc]

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recording = self.recordings[indexPath.row]
        self.presentRecorder(with: recording)
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
                tableView.reloadEmptyDataSet()
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
    private func presentRecorder(with recording: Recording?) {
        guard let navVc = self.storyboard?.instantiateViewController(withIdentifier: "Recorder") as? UINavigationController else { return }
        guard let vc = navVc.topViewController as? RecordingViewController else { return }
        vc.delegate = self
        vc.recording = recording
        self.navigationController?.present(navVc, animated: true, completion: nil)
    }
}

extension RecordingsTableViewController: SpeechRecordingDelegate {

    func saveRecording(_ recording: Recording, completionHandler: (() -> Void)?) {
        guard let fileURL = recording.fileURL else { return }
        do {
            try Disk.move(fileURL.lastPathComponent, in: .temporary, to: .documents)
            let newFileURL = try Disk.getURL(for: fileURL.lastPathComponent, in: .documents)
            let newRecording = Recording(uuid: recording.uuid,
                                               text: recording.text,
                                               createdAt: recording.createdAt,
                                               fileURL: newFileURL)
            if let existingIndex = self.recordings.index(where: { $0.uuid == newRecording.uuid }) {
                self.recordings[existingIndex] = newRecording
            } else {
                self.recordings.append(newRecording)
            }
            try Disk.save(self.recordings, to: .documents, as: "recordings.json")
            completionHandler?()
        } catch let error {
            self.showAlert(error.localizedDescription, type: .error)
        }

        self.tableView.reloadData()
    }

    func delete(_ recording: Recording) {
        let newRecordings = self.recordings.filter { $0.uuid != recording.uuid }
        do {
            try Disk.save(newRecordings, to: .documents, as: "recordings.json")
            // Delete the row from the data source
            if let fileURL = recording.fileURL {
                try Disk.remove(fileURL.lastPathComponent, from: .documents)
            }
        } catch {}
        self.recordings = newRecordings
    }
}

extension RecordingsTableViewController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)]
        return NSAttributedString(string: "You don't seem to have any recordings", attributes: attributes)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)]
        return NSAttributedString(string: "Go ahead and save speak and save some words.", attributes: attributes)
    }
}

