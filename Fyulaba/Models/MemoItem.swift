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


//extension NSRange {
//    func range(for str: String) -> Range<String.Index>? {
//        guard location != NSNotFound else { return nil }
//
//        guard let fromUTFIndex = str.utf16.index(str.utf16.startIndex, offsetBy: location, limitedBy: str.utf16.endIndex) else { return nil }
//        guard let toUTFIndex = str.utf16.index(fromUTFIndex, offsetBy: length, limitedBy: str.utf16.endIndex) else { return nil }
//        guard let fromIndex = String.Index(fromUTFIndex, within: str) else { return nil }
//        guard let toIndex = String.Index(toUTFIndex, within: str) else { return nil }
//
//        return fromIndex ..< toIndex
//    }
//}

struct MemoItem: Codable, Equatable {
    
    let uuid: String
    var text: String
    let createdAt: Date
    var sentiment: SentimentType?
    var fileName: String?
    var fileExt: String?
    var fileURL: URL?

    private enum CodingKeys: String, CodingKey {
        case uuid
        case text
        case createdAt = "created_at"
        case sentiment
        case fileName = "file_name"
        case fileExt = "file_extension"
        case fileURL = "file_url"
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
    
    var fileNamePlusExtension: String? {
        return fileURL?.lastPathComponent
    }
    
    var duration: Double {
        guard let url = self.fileURL else { return 0.0 }
        let file = try? AKAudioFile(forReading: url)
        return file?.duration ?? 0.0
    }
    
    public static func ==(lhs: MemoItem, rhs: MemoItem) -> Bool {
        return lhs.uuid == rhs.uuid
    }

}
