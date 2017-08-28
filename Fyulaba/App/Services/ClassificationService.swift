//
//  ClassificationService.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 18/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import CoreML

final class ClassificationService {

    static let shared: ClassificationService = {
        let instance = ClassificationService()
        // setup code
        return instance
    }()

    private enum Error: Swift.Error {
        case featuresMissing
    }

    private let model = SentimentPolarity()
    private let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther]
    private let languageCode: String
    private lazy var tagger: NSLinguisticTagger = .init(
        tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: languageCode),
        options: Int(self.options.rawValue)
    )

    init() {
        self.languageCode = Locale.preferredLanguages.first ?? "en"
    }

    // MARK: - Prediction
    func predictSentiment(from text: String) -> SentimentType {
        do {
            let inputFeatures = features(from: text)
            // Make prediction only with 2 or more words
            guard inputFeatures.count > 1 else {
                throw Error.featuresMissing
            }

            let output = try model.prediction(input: inputFeatures)

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

    func features(from text: String) -> [String: Double] {
        var wordCounts = [String: Double]()

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

        return wordCounts
    }
}
