//
//  AppLanguage.swift
//  jiu-jitsu-App
//
//  Created by Alisson Soares Alves Tomazelli on 21/10/2026.
//
// Aqui sera guardado os idiomas do App

import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case portuguese = "pt-BR"
    case english = "en"
    case spanish = "es"
    case french = "fr"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .portuguese: return "Português (Brasil)"
        case .english: return "English (International)"
        case .spanish: return "Español"
        case .french: return "Français"
        }
    }

    func text(_ key: String) -> String {
        let path = Bundle.main.path(
            forResource: rawValue,
            ofType: "lproj"
        )

        guard
            let path,
            let bundle = Bundle(path: path)
        else {
            return NSLocalizedString(
                key,
                tableName: "Localizable",
                bundle: .main,
                value: key,
                comment: ""
            )
        }

        return NSLocalizedString(
            key,
            tableName: "Localizable",
            bundle: bundle,
            value: key,
            comment: ""
        )
    }
}

