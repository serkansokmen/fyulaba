//
//  Extensions.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 21/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit

extension UIViewController {

    enum AlertType: String {
        case error = "Error"
        case warning = "Warning"
        case success = "Success"

        var color: UIColor {
            switch self {
            case .error:
                return .red
            case .warning:
                return .orange
            case .success:
                return .green
            }
        }
    }

    func showAlert(_ message: String?, type: AlertType) {
        let alert = UIAlertController(title: type.rawValue, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

protocol Identifiable {
    static var identifier: String { get }
}

extension Identifiable where Self: UIViewController {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UIViewController: Identifiable { }
