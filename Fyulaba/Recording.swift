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


struct Recording: Codable {

    let key: String
    let text: String
    let createdAt: Date

    private enum CodingKeys: String, CodingKey {
        case key = "$key"
        case text = "text"
        case createdAt = "created_at"
    }

    var title: String? {
        return self.text
    }

    var subtitle: String? {
        let dateInRegion: DateInRegion = DateInRegion(absoluteDate: self.createdAt)
        do {
            let (colloquial, relevantTime) = try dateInRegion.colloquialSinceNow()
            if let relevantTime = relevantTime {
                return "\(colloquial), \(relevantTime)"
            }
            return "\(colloquial)"
        } catch let error {
            return error.localizedDescription
        }
    }

    var sentiment: String {
        let options = NSLinguisticTagger.Options.omitWhitespace.rawValue | NSLinguisticTagger.Options.joinNames.rawValue
        let tagger = NSLinguisticTagger(tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "en"), options: Int(options))

        let inputString = self.text
        tagger.string = inputString

        let range = NSRange(location: 0, length: inputString.utf16.count)
        var result = ""
        tagger.enumerateTags(in: range,
                             scheme: NSLinguisticTagScheme.nameTypeOrLexicalClass,
                             options: NSLinguisticTagger.Options(rawValue: options))
        { tag, tokenRange, sentenceRange, stop in
            let token = inputString.substring(with: tokenRange.range(for: inputString)!)
            guard let tag = tag else { return }
            result += "\(tag.rawValue): \(token)\n"
        }
        return result
    }

}

enum Sentiment: String {
    case terrible = "terrible"
    case great = "great"
    case bad = "bad"
    case good = "good"
    case awful = "awful"
    case awesome = "awesome"

    var value: Double {
        switch self {
        case .terrible:
            return 1.0
        case .great:
            return 2.0
        case .bad:
            return 3.0
        case .good:
            return 4.0
        case .awful:
            return 5.0
        case .awesome:
            return 6.0
        }
    }
}


