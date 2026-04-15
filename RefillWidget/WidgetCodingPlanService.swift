//
//  WidgetCodingPlanService.swift
//  RefillWidget
//
//  Created by Jake on 2026/4/15.
//

import Foundation

enum WidgetCodingPlanServiceError: Error {
  case networkError(Error)
  case decodingError(Error)
  case noData
  case noAPIKey
}

struct WidgetCodingPlanService {
  private let apiKey: String
  private let url = URL(string: "https://www.minimaxi.com/v1/api/openplatform/coding_plan/remains")!

  init(apiKey: String) {
    self.apiKey = apiKey
  }

  func fetchUsage() async -> Result<ModelRemain, WidgetCodingPlanServiceError> {
    guard !apiKey.isEmpty else {
      return .failure(.noAPIKey)
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = 15

    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      let response = try JSONDecoder().decode(CodingPlanResponse.self, from: data)
      guard let first = response.modelRemains.first else {
        return .failure(.noData)
      }
      return .success(first)
    } catch let error as DecodingError {
      return .failure(.decodingError(error))
    } catch {
      return .failure(.networkError(error))
    }
  }
}