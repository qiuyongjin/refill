//
//  ContentView.swift
//  Refill
//
//  Created by Jake on 2026/4/14.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
  @Environment(\.scenePhase) private var scenePhase
  @State private var usageResponse: CodingPlanResponse?
  @State private var isLoading = false
  @State private var errorMessage: String?
  @State private var showingSettings = false
  
  private let service = CodingPlanService()
  private let sharedStore = SharedDataStore.shared
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 16) {
          if let error = errorMessage {
            Text(error)
              .foregroundStyle(.red)
              .font(.caption)
              .padding()
          }
          
          if let response = usageResponse, let usage = response.modelRemains.first {
            UsageCardView(
              title: "Five-Hour Usage",
              used: usage.currentIntervalTotalCount - usage.currentIntervalUsageCount,
              total: usage.currentIntervalTotalCount,
              remainSeconds: usage.remainsTime / 1000,
            )

            UsageCardView(
              title: "Weekly Usage",
              used: usage.currentWeeklyTotalCount - usage.currentWeeklyUsageCount,
              total: usage.currentWeeklyTotalCount,
              remainSeconds: usage.weeklyRemainsTime / 1000,
            )

            let speechData = response.modelRemains[1]
            UsageCardView(
              title: "Text to Speech",
              used: speechData.currentIntervalTotalCount - speechData.currentIntervalUsageCount,
              total: speechData.currentIntervalTotalCount,
              remainSeconds: speechData.remainsTime / 1000,
            )
          } else if isLoading {
            ProgressView()
              .padding()
          }
        }
        .padding()
      }
      .navigationTitle("Coding Plan Usage")
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            showingSettings = true
          } label: {
            Image(systemName: "gearshape")
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            Task { await fetchData() }
          } label: {
            if isLoading {
              ProgressView()
            } else {
              Image(systemName: "arrow.clockwise")
            }
          }
          .disabled(isLoading)
        }
      }
      .sheet(isPresented: $showingSettings) {
        SettingsView()
      }
    }
    .task {
      await fetchData()
    }
    .onChange(of: scenePhase) { oldPhase, newPhase in
      if newPhase == .active && oldPhase != .active {
        Task { await fetchData() }
      }
    }
  }
  
  private func fetchData() async {
    isLoading = true
    errorMessage = nil
    
    switch await service.fetchUsage() {
      case .success(let response):
        usageResponse = response
        if let first = response.modelRemains.first {
          sharedStore.saveUsage(first)
        }
        WidgetCenter.shared.reloadAllTimelines()
      case .failure(let error):
        switch error {
          case .networkError:
            errorMessage = "网络错误，请检查网络连接"
          case .decodingError:
            errorMessage = "数据解析错误"
          case .noData:
            errorMessage = "数据异常"
        }
    }
    
    isLoading = false
  }
}

#Preview {
  ContentView()
}
