//
//  CodingPlanModel.swift
//  Refill
//
//  Created by Jake on 2026/4/14.
//

import Foundation

struct CodingPlanResponse: Codable {
  let modelRemains: [ModelRemain]
  
  enum CodingKeys: String, CodingKey {
    case modelRemains = "model_remains"
  }
}

struct ModelRemain: Codable {
  let remainsTime: Int
  let currentIntervalTotalCount: Int
  let currentIntervalUsageCount: Int
  let modelName: String
  let currentWeeklyTotalCount: Int
  let currentWeeklyUsageCount: Int
  let weeklyRemainsTime: Int
  let startTime: Int?
  let endTime: Int?
  let weeklyStartTime: Int?
  let weeklyEndTime: Int?
  
  enum CodingKeys: String, CodingKey {
    case remainsTime = "remains_time"
    case currentIntervalTotalCount = "current_interval_total_count"
    case currentIntervalUsageCount = "current_interval_usage_count"
    case modelName = "model_name"
    case currentWeeklyTotalCount = "current_weekly_total_count"
    case currentWeeklyUsageCount = "current_weekly_usage_count"
    case weeklyRemainsTime = "weekly_remains_time"
    case startTime = "start_time"
    case endTime = "end_time"
    case weeklyStartTime = "weekly_start_time"
    case weeklyEndTime = "weekly_end_time"
  }
}
