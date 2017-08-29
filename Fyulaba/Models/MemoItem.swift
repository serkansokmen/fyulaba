//
//  Recording.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 18/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation
import SwiftDate
import CoreML
import AudioKit
import Disk

struct MemoItem: Codable, Equatable {
    
    let uuid: String
    let createdAt: Date
    
    var text: String = ""
    var sentiment: SentimentType?
    var features = [TranscriptionFeature]()

    var file: AKAudioFile
    var fileURL: URL?
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case createdAt = "created_at"
        case text
        case sentiment
        case features
        case fileURL = "file_url"
    }
    
    init() {
        self.uuid = UUID().uuidString
        self.file = MemoItem.createWorkingFile()
        self.createdAt = DateInRegion().absoluteDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uuid = try container.decode(String.self, forKey: CodingKeys.uuid)
        self.createdAt = try container.decode(Date.self, forKey: CodingKeys.createdAt)
        self.text = try container.decode(String.self, forKey: CodingKeys.text)
        self.sentiment = try container.decode(SentimentType.self, forKey: CodingKeys.sentiment)
        self.features = try container.decode([TranscriptionFeature].self, forKey: CodingKeys.features)
        
        self.fileURL = try container.decode(URL.self, forKey: CodingKeys.fileURL)
        guard let file = try? AKAudioFile(readFileName: self.fileURL!.absoluteString) else {
            self.file = MemoItem.createWorkingFile()
            return
        }
        self.file = file
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(text, forKey: .text)
        try container.encode(sentiment, forKey: .sentiment)
        try container.encode(features, forKey: .features)
        try container.encode(self.file.url, forKey: .fileURL)
    }

    var title: String {
        return self.text
    }

    var subtitle: String {
        let dateInRegion: DateInRegion = DateInRegion(absoluteDate: self.createdAt)
        do {
            let (colloquial, relevantTime) = try dateInRegion.colloquialSinceNow()
            if let relevantTime = relevantTime {
                return "\(colloquial), \(relevantTime)"
            }
            return "\(colloquial)"
        } catch {
            return ""
        }
    }
    
    public static func ==(lhs: MemoItem, rhs: MemoItem) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    static func createWorkingFile() -> AKAudioFile {
        guard let tempFile = try? AKAudioFile() else {
            fatalError("could not setup audio file")
        }
        do {
            try Disk.move(tempFile.fileNamePlusExtension, in: .temporary, to: .documents)
        } catch let err {
            fatalError(err.localizedDescription)
        }
        
        guard let file = try? AKAudioFile(readFileName: tempFile.fileNamePlusExtension, baseDir: .documents) else {
            fatalError("could not setup audio file")
        }
        return file
    }

}
