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
        return Double(used) / Double(total)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            Text(usedText)
                .font(.system(.title2, design: .monospaced))
                .fontWeight(.semibold)

            ProgressView(value: progress)
                .tint(.blue)

            Text(percentText)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("剩余 \(remainText)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
