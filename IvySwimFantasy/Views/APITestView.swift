//
//  APITestView.swift
//  IvySwimFantasy
//
//  API Connection Test View
//  Add this to your tab bar temporarily to test the backend connection
//

import SwiftUI

struct APITestView: View {
    @State private var testResults: [String] = []
    @State private var isLoading = false

    private let baseURL = "http://localhost:8000"

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Backend API Test")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Testing connection to: \(baseURL)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(testResults, id: \.self) { result in
                            HStack {
                                if result.contains("✅") {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else if result.contains("❌") {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                } else {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                }
                                Text(result)
                                    .font(.system(.body, design: .monospaced))
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .frame(maxHeight: 400)

                VStack(spacing: 12) {
                    Button(action: runAllTests) {
                        Label("Run All Tests", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(isLoading)

                    Button(action: { testResults = [] }) {
                        Label("Clear Results", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Test Functions

    func runAllTests() {
        Task {
            await MainActor.run { isLoading = true }
            testResults = []

            await testHealthEndpoint()
            await testRootEndpoint()
            await testSchoolsEndpoint()
            await testSwimmersEndpoint()
            await testSwimmersWithFilter()

            await MainActor.run { isLoading = false }
        }
    }

    func testHealthEndpoint() async {
        await addResult("Testing /health endpoint...")

        do {
            guard let url = URL(string: "\(baseURL)/health") else {
                await addResult("❌ Invalid URL")
                return
            }

            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let status = json["status"] as? String {
                        await addResult("✅ Health check: \(status)")
                    } else {
                        await addResult("✅ Health endpoint returned 200")
                    }
                } else {
                    await addResult("❌ Health check failed: HTTP \(httpResponse.statusCode)")
                }
            }
        } catch {
            await addResult("❌ Health check error: \(error.localizedDescription)")
        }
    }

    func testRootEndpoint() async {
        await addResult("Testing / endpoint...")

        do {
            guard let url = URL(string: "\(baseURL)/") else {
                await addResult("❌ Invalid URL")
                return
            }

            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let swimmersLoaded = json["swimmers_loaded"] as? Int {
                        await addResult("✅ Swimmers loaded: \(swimmersLoaded)")
                    }
                    if let version = json["version"] as? String {
                        await addResult("   API version: \(version)")
                    }
                }
            } else {
                await addResult("❌ Root endpoint failed")
            }
        } catch {
            await addResult("❌ Root endpoint error: \(error.localizedDescription)")
        }
    }

    func testSchoolsEndpoint() async {
        await addResult("Testing /api/schools endpoint...")

        do {
            guard let url = URL(string: "\(baseURL)/api/schools") else {
                await addResult("❌ Invalid URL")
                return
            }

            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let schools = json["schools"] as? [[String: Any]] {
                    await addResult("✅ Schools endpoint: \(schools.count) schools")

                    // Show first 3 schools
                    for school in schools.prefix(3) {
                        if let name = school["name"] as? String,
                           let count = school["swimmer_count"] as? Int {
                            await addResult("   - \(name): \(count) swimmers")
                        }
                    }
                } else {
                    await addResult("✅ Schools endpoint returned 200")
                }
            } else {
                await addResult("❌ Schools endpoint failed")
            }
        } catch {
            await addResult("❌ Schools error: \(error.localizedDescription)")
        }
    }

    func testSwimmersEndpoint() async {
        await addResult("Testing /api/swimmers endpoint...")

        do {
            guard let url = URL(string: "\(baseURL)/api/swimmers") else {
                await addResult("❌ Invalid URL")
                return
            }

            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let count = json["count"] as? Int {
                    await addResult("✅ All swimmers: \(count) total")
                } else {
                    await addResult("✅ Swimmers endpoint returned 200")
                }
            } else {
                await addResult("❌ Swimmers endpoint failed")
            }
        } catch {
            await addResult("❌ Swimmers error: \(error.localizedDescription)")
        }
    }

    func testSwimmersWithFilter() async {
        await addResult("Testing /api/swimmers?school=Harvard...")

        do {
            guard let url = URL(string: "\(baseURL)/api/swimmers?school=Harvard") else {
                await addResult("❌ Invalid URL")
                return
            }

            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let count = json["count"] as? Int,
                   let swimmers = json["swimmers"] as? [[String: Any]] {
                    await addResult("✅ Harvard swimmers: \(count)")

                    // Show first swimmer
                    if let firstSwimmer = swimmers.first,
                       let name = firstSwimmer["name"] as? String,
                       let school = firstSwimmer["school"] as? String {
                        await addResult("   - \(name) (\(school))")
                    }
                } else {
                    await addResult("✅ Filter endpoint returned 200")
                }
            } else {
                await addResult("❌ Filter endpoint failed")
            }
        } catch {
            await addResult("❌ Filter error: \(error.localizedDescription)")
        }
    }

    @MainActor
    func addResult(_ result: String) {
        testResults.append(result)
    }
}

#Preview {
    APITestView()
}
