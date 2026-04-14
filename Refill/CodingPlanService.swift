//
//  CodingPlanService.swift
//  Refill
//
//  Created by Jake on 2026/4/14.
//

import Foundation

enum CodingPlanServiceError: Error {
  case invalidURL
  case networkError(Error)
  case decodingError(Error)
  case noData
}

struct CodingPlanService {
  private let apiKey: String
  private let url = URL(string: "https://www.minimaxi.com/v1/api/openplatform/coding_plan/remains")!
  
  init(apiKey: String = UserDefaultsAPIKeyStore.shared.get()) {
    self.apiKey = apiKey
  }
  
  func fetchUsage() async -> Result<ModelRemain, CodingPlanServiceError> {
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
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
