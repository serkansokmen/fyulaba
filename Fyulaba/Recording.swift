//
//  Recording.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 18/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation


struct Recording {
    let title: String
    let subtitle: String
    let audio: URL
    let locale: Locale?

    init(title: String, subtitle: String, filename: String, locale: Locale?) {
        self.title = title
        self.subtitle = subtitle
        self.audio = Bundle.main.url(forResource: filename, withExtension: .none)!
        self.locale = locale
    }
}
