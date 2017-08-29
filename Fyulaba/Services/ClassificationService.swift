//
//  ClassificationService.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 18/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import CoreML

struct TranscriptionFeature: Codable {
    let key: String
    let value: Double
}

final class ClassificationService {

    static let shared: ClassificationService = {
        let instance = ClassificationService()
        // setup code
        return instance
    }()

    private var locale: Locale = Locale.autoupdatingCurrent
    
    private enum Error: Swift.Error {
        case featuresMissing
    }
    
    init() {
    }

    private let model = SentimentPolarity()
    private let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther]
    private lazy var tagger: NSLinguisticTagger = .init(
        tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: locale.identifier),
        options: Int(self.options.rawValue)
    )

    // MARK: - Prediction
    func predictSentiment(from text: String) -> SentimentType {
        do {
            let inputFeatures = features(from: text)
            // Make prediction only with 2 or more words
            guard inputFeatures.count > 1 else {
                throw Error.featuresMissing
            }
            
            var dict: [String:Double] = [:]
            inputFeatures.forEach { feature in
                dict[feature.key] = feature.value
            }
            let output = try model.prediction(input: dict)

            switch output.classLabel {
            case "Pos":
                return .positive
            case "Neg":
                return .negative
            default:
                return .neutral
            }
        } catch {
            return .neutral
        }
    }

    func features(from text: String) -> [TranscriptionFeature] {
        var wordCounts = [String:Double]()

        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)

        // Tokenize and count the sentence
        tagger.enumerateTags(in: range, scheme: .nameType, options: options) { _, tokenRange, _, _ in
            let token = (text as NSString).substring(with: tokenRange).lowercased()
            // Skip small words
            guard token.count >= 3 else {
                return
            }

            if let value = wordCounts[token] {
                wordCounts[token] = value + 1.0
            } else {
                wordCounts[token] = 1.0
            }
        }

        return wordCounts.map { key, value in
            return TranscriptionFeature(key: key, value: value)
        }
    }
}
