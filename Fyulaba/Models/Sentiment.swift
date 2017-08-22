//
//  Sentiment.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 18/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit


enum Sentiment {
    case neutral
    case positive
    case negative

    var emoji: String {
        switch self {
        case .neutral:
            return "😐"
        case .positive:
            return "😃"
        case .negative:
            return "😔"
        }
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
