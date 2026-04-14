//
//  ContentView.swift
//  Refill
//
//  Created by Jake on 2026/4/14.
//

import SwiftUI

struct ContentView: View {
    @State private var hourlyUsage: ModelRemain?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingSettings = false

    private let service = CodingPlanService()

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

                    if let usage = hourlyUsage {
                        UsageCardView(
                            title: "5小时用量",
                            used: usage.currentIntervalUsageCount,
                            total: usage.currentIntervalTotalCount,
                            remainSeconds: usage.remainsTime / 1000
                        )

                        UsageCardView(
                            title: "一周用量",
                            used: usage.currentWeeklyUsageCount,
                            total: usage.currentWeeklyTotalCount,
                            remainSeconds: usage.weeklyRemainsTime / 1000
                        )
                    } else if isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Coding Plan 用量")
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
    }

    private func fetchData() async {
        isLoading = true
        errorMessage = nil

        switch await service.fetchUsage() {
        case .success(let data):
            hourlyUsage = data
        case .failure(let error):
            switch error {
            case .networkError:
                errorMessage = "网络错误，请检查网络连接"
            case .decodingError:
                errorMessage = "数据解析错误"
            case .invalidURL, .noData:
                errorMessage = "数据异常"
            }
        }

        isLoading = false
    }
}

#Preview {
    ContentView()
}
