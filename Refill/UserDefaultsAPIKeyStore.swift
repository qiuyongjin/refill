//
//  UserDefaultsAPIKeyStore.swift
//  Refill
//
//  Created by Jake on 2026/4/14.
//

import Foundation

final class UserDefaultsAPIKeyStore {
    static let shared = UserDefaultsAPIKeyStore()
    private let key = "api_key"
    private let defaults = UserDefaults.standard

    private init() {}

    func get() -> String {
        defaults.string(forKey: key) ?? ""
    }

    func set(_ value: String) {
        defaults.set(value, forKey: key)
    }

    var hasAPIKey: Bool {
        !get().isEmpty
    }
}
