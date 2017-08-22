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


extension NSRange {
    func range(for str: String) -> Range<String.Index>? {
        guard location != NSNotFound else { return nil }

        guard let fromUTFIndex = str.utf16.index(str.utf16.startIndex, offsetBy: location, limitedBy: str.utf16.endIndex) else { return nil }
        guard let toUTFIndex = str.utf16.index(fromUTFIndex, offsetBy: length, limitedBy: str.utf16.endIndex) else { return nil }
        guard let fromIndex = String.Index(fromUTFIndex, within: str) else { return nil }
        guard let toIndex = String.Index(toUTFIndex, within: str) else { return nil }

        return fromIndex ..< toIndex
    }
}


struct Recording: Codable, Equatable {

    let uuid: String
    let text: String
    let createdAt: Date
    var fileURL: URL?

    private enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case text = "text"
        case createdAt = "created_at"
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

    public static func ==(lhs: Recording, rhs: Recording) -> Bool {
        return lhs.uuid == rhs.uuid &&
            lhs.text == rhs.text &&
            lhs.createdAt == rhs.createdAt &&
            lhs.fileURL == rhs.fileURL
    }

}
