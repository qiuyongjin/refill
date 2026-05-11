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
  private let appGroupID = "group.cn.yourhero.Refill"
  private lazy var defaults = UserDefaults(suiteName: appGroupID) ?? UserDefaults.standard
  
  private init() {}
  
  func get() -> String {
    if let stored = defaults.string(forKey: key), !stored.isEmpty {
      return stored
    }
    return Bundle.main.infoDictionary?["MINIMAX_API_KEY"] as? String ?? ""
  }
  
  func set(_ value: String) {
    defaults.set(value, forKey: key)
  }
  
  var hasAPIKey: Bool {
    !get().isEmpty
  }
}
