//
//  SharedDataStore.swift
//  Refill
//
//  Created by Jake on 2026/4/14.
//

import Foundation

final class SharedDataStore {
  static let shared = SharedDataStore()
  private let appGroupID = "group.cn.yourhero.Refill"
  private let usageKey = "cached_usage"
  private lazy var defaults = UserDefaults(suiteName: appGroupID) ?? UserDefaults.standard
  
  private init() {}
  
  func saveUsage(_ usage: ModelRemain) {
    if let data = try? JSONEncoder().encode(usage) {
      defaults.set(data, forKey: usageKey)
    }
  }
  
  func loadUsage() -> ModelRemain? {
    guard let data = defaults.data(forKey: usageKey) else { return nil }
    return try? JSONDecoder().decode(ModelRemain.self, from: data)
  }
}
