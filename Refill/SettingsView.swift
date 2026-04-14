//
//  SettingsView.swift
//  Refill
//
//  Created by Jake on 2026/4/14.
//

import SwiftUI

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var apiKey: String = UserDefaultsAPIKeyStore.shared.get()
  
  var body: some View {
    NavigationStack {
      Form {
        Section {
          SecureField("API Key", text: $apiKey)
            .textContentType(.password)
            .autocapitalization(.none)
            .autocorrectionDisabled()
        } header: {
          Text("MiniMax API Key")
        } footer: {
          Text("用于调用 Coding Plan 接口获取用量数据")
        }
      }
      .navigationTitle("设置")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("取消") {
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("保存") {
            UserDefaultsAPIKeyStore.shared.set(apiKey)
            dismiss()
          }
        }
      }
    }
  }
}

#Preview {
  SettingsView()
}
