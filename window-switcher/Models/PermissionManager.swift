import AppKit
import ScreenCaptureKit
import Observation

enum PermissionStatus {
    case granted
    case denied
    case unknown
}

@MainActor
@Observable
final class PermissionManager {
    static let shared = PermissionManager()

    private(set) var accessibilityStatus: PermissionStatus = .unknown
    private(set) var screenRecordingStatus: PermissionStatus = .unknown

    var allGranted: Bool {
        accessibilityStatus == .granted && screenRecordingStatus == .granted
    }

    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding") }
    }

    var shouldShowOnboarding: Bool {
        !hasCompletedOnboarding
    }

    private init() {
        refreshAll()
    }

    // MARK: - Accessibility

    func refreshAccessibility() {
        accessibilityStatus = AXIsProcessTrusted() ? .granted : .denied
    }

    func requestAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
        refreshAccessibility()
    }

    func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Screen Recording

    func refreshScreenRecording() {
        screenRecordingStatus = CGPreflightScreenCaptureAccess() ? .granted : .denied
    }

    func requestScreenRecording() {
        CGRequestScreenCaptureAccess()
        refreshScreenRecording()
    }

    func openScreenRecordingSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Aggregate

    func refreshAll() {
        refreshAccessibility()
        refreshScreenRecording()
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}
