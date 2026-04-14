//
//  RefillWidget.swift
//  RefillWidget
//
//  Created by Jake on 2026/4/14.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), emoji: "😀")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

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
            VStack {
                Text("Time:")
                Text(entry.date, style: .time)
                Text("Emoji:")
                Text(entry.emoji)
            }
        }
    }
}

struct RefillWidget: Widget {
    let kind: String = "RefillWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RefillWidgetEntryView(entry: entry)
        }
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct AccessoryCircularView: View {
    var entry: Provider.Entry

    var body: some View {
        Gauge(value: 0.7) {
            Text("Refill")
        } currentValueLabel: {
            Text("70%")
        }
        .gaugeStyle(.accessoryCircular)
    }
}

struct AccessoryRectangularView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Refill")
                .font(.headline)
            Text("70% remaining")
                .font(.caption)
        }
    }
}

struct AccessoryInlineView: View {
    var entry: Provider.Entry

    var body: some View {
        Text("Refill: 70%")
    }
}

#Preview(as: .systemSmall) {
    RefillWidget()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
    SimpleEntry(date: .now, emoji: "🤩")
}
