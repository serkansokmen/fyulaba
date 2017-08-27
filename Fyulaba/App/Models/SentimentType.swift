//
//  Sentiment.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 18/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit


enum SentimentType: String {

    case neutral = "😐"
    case positive = "😃"
    case negative = "😔"

    var emoji: String {
        return self.rawValue
    }

    var color: UIColor? {
        switch self {
        case .neutral:
            return UIColor(named: "NeutralColor")
        case .positive:
            return UIColor(named: "PositiveColor")
        case .negative:
            return UIColor(named: "NegativeColor")
        }
    }
}
