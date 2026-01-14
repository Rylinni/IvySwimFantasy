import SwiftUI

struct ResultsView: View {
    private let mockData = MockData.shared
    @State private var selectedSession: MeetSession?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Meet info header
                    meetHeader

                    // Session selector
                    sessionSelector

                    // Events list
                    if let session = selectedSession ?? mockData.meet.sessions.first {
                        eventsListView(session: session)
                    }
                }
                .padding()
            }
            .background(AppTheme.background)
            .navigationTitle("Results")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                if selectedSession == nil {
                    selectedSession = mockData.meet.currentSession ?? mockData.meet.sessions.first
                }
            }
        }
    }

    var meetHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        if mockData.meet.isLive {
                            Circle()
                                .fill(AppTheme.success)
                                .frame(width: 8, height: 8)
                            Text("LIVE")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppTheme.success)
                        }
                    }

                    Text(mockData.meet.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                }

                Spacer()

                Text(mockData.meet.dateRange)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Text(mockData.meet.location)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textMuted)
        }
        .padding()
        .cardStyle()
    }

    var sessionSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(mockData.meet.sessions) { session in
                    Button {
                        withAnimation {
                            selectedSession = session
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(session.name)
                                .font(.system(size: 12, weight: .semibold))

                            if session.isComplete {
                                Text("Complete")
                                    .font(.system(size: 10))
                            } else {
                                Text("In Progress")
                                    .font(.system(size: 10))
                            }
                        }
                        .foregroundColor(selectedSession?.id == session.id ? AppTheme.background : AppTheme.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(selectedSession?.id == session.id ? AppTheme.accent : AppTheme.cardBackground)
                        .cornerRadius(20)
                    }
                }
            }
        }
    }

    func eventsListView(session: MeetSession) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(session.sessionType.rawValue.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppTheme.textMuted)

                Spacer()

                if session.isComplete {
                    Label("Complete", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.success)
                }
            }
            .padding(.horizontal, 4)

            ForEach(session.events) { event in
                eventCard(event: event)
            }
        }
    }

    func eventCard(event: MeetEvent) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(event.event.rawValue)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                if event.isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.success)
                } else {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(AppTheme.warning)
                            .frame(width: 6, height: 6)
                        Text("Pending")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.warning)
                    }
                }
            }

            if event.isComplete {
                // Show placeholder results
                VStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { place in
                        placeholderResultRow(place: place, event: event.event)
                    }
                }
            } else {
                Text("Results pending...")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            }
        }
        .padding()
        .cardStyle()
    }

    func placeholderResultRow(place: Int, event: SwimEvent) -> some View {
        HStack(spacing: 12) {
            // Place
            Text("\(place)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(place == 1 ? AppTheme.gold : (place == 2 ? AppTheme.silver : (place == 3 ? AppTheme.bronze : AppTheme.textMuted)))
                .frame(width: 20)

            // Swimmer placeholder
            Circle()
                .fill(AppTheme.cardBackgroundLight)
                .frame(width: 32, height: 32)
                .overlay(
                    Text("--")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.textMuted)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Swimmer Name")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                Text("School")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("--:--.--")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(AppTheme.textPrimary)

                Text("+\(place * 5) pts")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.accent)
            }
        }
    }
}

#Preview {
    ResultsView()
}
