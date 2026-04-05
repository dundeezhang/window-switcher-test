import AppKit
import SwiftUI

class OnboardingWindow: NSWindow {
    init(onDismiss: @escaping () -> Void) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 360),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: true
        )

        let onboardingView = OnboardingView(
            permissionManager: PermissionManager.shared,
            onDismiss: onDismiss
        )
        contentView = NSHostingView(rootView: onboardingView)

        title = "Welcome to Window Switcher"
        center()
        isReleasedWhenClosed = false
    }
}
