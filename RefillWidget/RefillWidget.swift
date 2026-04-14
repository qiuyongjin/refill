//
//  RefillWidget.swift
//  RefillWidget
//
//  Created by Jake on 2026/4/14.
//

import WidgetKit
import SwiftUI

// MARK: - Shared Data Store
final class SharedDataStore {
  static let shared = SharedDataStore()
  private let appGroupID = "group.cn.yourhero.Refill"
  private let usageKey = "cached_usage"
  private lazy var defaults = UserDefaults(suiteName: appGroupID) ?? UserDefaults.standard
  
  private init() {}
  
  func loadUsage() -> ModelRemain? {
    guard let data = defaults.data(forKey: usageKey) else { return nil }
    return try? JSONDecoder().decode(ModelRemain.self, from: data)
  }
}

// MARK: - Model (duplicated for widget target)
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
  
  var usagePercent: Double {
    guard currentIntervalTotalCount > 0 else { return 0 }
    let used = currentIntervalTotalCount - currentIntervalUsageCount
    return Double(used) / Double(currentIntervalTotalCount)
  }
  
  var weeklyUsagePercent: Double {
    guard currentWeeklyTotalCount > 0 else { return 0 }
    let used = currentWeeklyTotalCount - currentWeeklyUsageCount
    return Double(used) / Double(currentWeeklyTotalCount)
  }
  
  var remainsHours: Int {
    remainsTime / 3600000
  }
  
  var remainsMinutes: Int {
    (remainsTime % 3600000) / 60000
  }
}

// MARK: - Helper
private func formatDuration(seconds: Int) -> String {
  if seconds < 60 {
    return "\(seconds) 秒"
  } else if seconds < 3600 {
    let minutes = seconds / 60
    let secs = seconds % 60
    return "\(minutes) 分钟 \(secs) 秒"
  } else if seconds < 86400 {
    let hours = seconds / 3600
    let mins = (seconds % 3600) / 60
    return "\(hours) 小时 \(mins) 分钟"
  } else {
    let days = seconds / 86400
    let hours = (seconds % 86400) / 3600
    let mins = (seconds % 3600) / 60
    return "\(days) 天 \(hours) 小时 \(mins) 分钟"
  }
}

// MARK: - Provider
struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), usage: nil)
  }
  
  func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    let usage = SharedDataStore.shared.loadUsage()
    let entry = SimpleEntry(date: Date(), usage: usage)
    completion(entry)
  }
  
  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    let usage = SharedDataStore.shared.loadUsage()
    let currentDate = Date()
    var entries: [SimpleEntry] = []
    
    for minuteOffset in stride(from: 0, to: 15, by: 3) {
      let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
      let entry = SimpleEntry(date: entryDate, usage: usage)
      entries.append(entry)
    }
    
    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }
}

// MARK: - Entry
struct SimpleEntry: TimelineEntry {
  let date: Date
  let usage: ModelRemain?
}

// MARK: - Widget Entry View
struct RefillWidgetEntryView : View {
  @Environment(\.widgetFamily) var family
  var entry: Provider.Entry
  
  var body: some View {
    switch family {
      case .accessoryCircular:
        AccessoryCircularView(entry: entry)
      case .accessoryRectangular:
        AccessoryRectangularView(entry: entry)
      case .accessoryInline:
        AccessoryInlineView(entry: entry)
      default:
        EmptyView()
    }
  }
}

// MARK: - Widget
struct RefillWidget: Widget {
  let kind: String = "RefillWidget"
  
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      RefillWidgetEntryView(entry: entry)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .supportedFamilies([
      .accessoryCircular,
      .accessoryRectangular,
      .accessoryInline
    ])
    .configurationDisplayName("Coding Plan")
    .description("显示 Coding Plan 用量")
  }
}

// MARK: - Circular View
struct AccessoryCircularView: View {
  var entry: Provider.Entry
  
  var body: some View {
    if let usage = entry.usage {
      Gauge(value: 1 - usage.usagePercent) {
        Image(systemName: "battery.75")
      } currentValueLabel: {
        Text(String(format: "%.2f", (usage.usagePercent) * 100) + "%")
      }
      .gaugeStyle(.accessoryCircular)
    } else {
      Gauge(value: 0) {
        Image(systemName: "battery.0")
      } currentValueLabel: {
        Text("--")
      }
      .gaugeStyle(.accessoryCircular)
    }
  }
}

// MARK: - Rectangular View
struct AccessoryRectangularView: View {
  var entry: Provider.Entry
  
  var body: some View {
    if let usage = entry.usage {
      VStack(alignment: .leading, spacing: 2) {
        Text(String(format: "%.2f", usage.usagePercent * 100) + "% Used")
          .font(.headline)
        Text("剩余 \(formatDuration(seconds: usage.remainsTime / 1000))")
          .font(.caption)
      }
    } else {
      VStack(alignment: .leading, spacing: 2) {
        Text("暂无数据")
          .font(.headline)
        Text("请打开 App 刷新")
          .font(.caption)
      }
    }
  }
}

// MARK: - Inline View
struct AccessoryInlineView: View {
  var entry: Provider.Entry
  
  var body: some View {
    if let usage = entry.usage {
      Text("Refill: \(String(format: "%.2f", (1 - usage.usagePercent) * 100))%")
    } else {
      Text("Refill: --")
    }
  }
}

#Preview(as: .accessoryRectangular) {
  RefillWidget()
} timeline: {
  SimpleEntry(date: .now, usage: ModelRemain(
    remainsTime: 1368946,
    currentIntervalTotalCount: 4500,
    currentIntervalUsageCount: 4403,
    modelName: "Pro",
    currentWeeklyTotalCount: 500,
    currentWeeklyUsageCount: 150,
    weeklyRemainsTime: 259200000,
    startTime: nil,
    endTime: nil,
    weeklyStartTime: nil,
    weeklyEndTime: nil
  ))
}
