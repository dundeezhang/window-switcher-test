import SwiftUI

struct OnboardingView: View {
    let permissionManager: PermissionManager
    let onDismiss: () -> Void

    let pollTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            headerSection
                .padding(.bottom, 24)

            VStack(spacing: 12) {
                permissionRow(
                    title: "Accessibility",
                    description: "Required to list and switch between open windows.",
                    status: permissionManager.accessibilityStatus,
                    onRequest: { permissionManager.requestAccessibility() },
                    onOpenSettings: { permissionManager.openAccessibilitySettings() }
                )

                permissionRow(
                    title: "Screen Recording",
                    description: "Required for window preview thumbnails.",
                    status: permissionManager.screenRecordingStatus,
                    onRequest: { permissionManager.requestScreenRecording() },
                    onOpenSettings: { permissionManager.openScreenRecordingSettings() }
                )
            }

            if permissionManager.screenRecordingStatus == .granted {
                Text("You may need to relaunch the app for Screen Recording to take effect.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }

            Spacer()

            continueButton
        }
        .padding(32)
        .frame(width: 480, height: 360)
        .onReceive(pollTimer) { _ in
            permissionManager.refreshAll()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "macwindow.on.rectangle")
                .font(.system(size: 40))
                .foregroundStyle(Color.accentColor)

            Text("Welcome to Window Switcher")
                .font(.title2.bold())

            Text("Grant the following permissions to get started.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func permissionRow(
        title: String,
        description: String,
        status: PermissionStatus,
        onRequest: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: status == .granted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundStyle(status == .granted ? .green : .yellow)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if status != .granted {
                Button("Grant Access") {
                    onRequest()
                }
                Button("Open Settings") {
                    onOpenSettings()
                }
                .buttonStyle(.borderless)
                .foregroundStyle(Color.accentColor)
            } else {
                Text("Granted")
                    .font(.subheadline)
                    .foregroundStyle(.green)
            }
        }
        .padding(12)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
    }

    private var continueButton: some View {
        Button {
            permissionManager.completeOnboarding()
            onDismiss()
        } label: {
            Text(permissionManager.allGranted ? "Continue" : "Continue Without Full Access")
                .frame(maxWidth: .infinity)
        }
        .controlSize(.large)
        .keyboardShortcut(.defaultAction)
    }
}
