//
//  UsageCardView.swift
//  Refill
//
//  Created by Jake on 2026/4/14.
//

import SwiftUI

struct UsageCardView: View {
  let title: String
  let used: Int
  let total: Int
  let remainSeconds: Int
  
  private var progress: Double {
    guard total > 0, used > 0 else { return 0 }
    let rawProgress = Double(used) / Double(total)
    if rawProgress >= 0.005 && rawProgress < 0.01 {
      return 0.01
    }
    return rawProgress
  }
  
  private var percentText: String {
    String(format: "%.2f%%", progress * 100)
  }
  
  private var usedText: String {
    "\(used) / \(total)"
  }
  
  private var remainText: String {
    formatDuration(seconds: remainSeconds)
  }
  
  private func formatDuration(seconds: Int) -> String {
    if seconds < 60 {
      return "\(seconds) sec"
    } else if seconds < 3600 {
      let minutes = seconds / 60
      let secs = seconds % 60
      return "\(minutes) min \(secs) sec"
    } else if seconds < 86400 {
      let hours = seconds / 3600
      let mins = (seconds % 3600) / 60
      return "\(hours) hr \(mins) min"
    } else {
      let days = seconds / 86400
      let hours = (seconds % 86400) / 3600
      let mins = (seconds % 3600) / 60
      return "\(days) day \(hours) hr \(mins) min"
    }
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.headline)
      
      Text(percentText)
        .font(.system(.title2, design: .monospaced))
        .fontWeight(.semibold)

      ProgressView(value: progress)
        .tint(.blue)

      HStack {
        Text(usedText)

        Spacer()

        Text("Resets in \(remainText)")
      }
      .font(.subheadline)
      .foregroundStyle(.secondary)
    }
    .padding()
    .background(.ultraThinMaterial)
    .cornerRadius(12)
  }
}
