import SwiftUI
import AppKit

@main
struct MacAppFixerApp: App {
    init() {
        NSApplication.shared.setActivationPolicy(.regular)
        NSWindow.allowsAutomaticWindowTabbing = false
        
        // Set app icon
        if let appIcon = NSImage(named: "AppIcon") {
            NSApp.applicationIconImage = appIcon
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(WindowAccessor())
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 380, height: 420)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
        
    }
}



// Configure window with macOS 26 Liquid Glass styling
struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            
            // Modern macOS window configuration
            window.titlebarAppearsTransparent = true
            window.styleMask.insert(.fullSizeContentView)
            window.isMovableByWindowBackground = true
            window.titleVisibility = .hidden
            window.tabbingMode = .disallowed
            
            // Add a toolbar to trigger macOS 26's larger corner radius
            // Even an empty toolbar will cause the system to apply the new rounded corners
            let toolbar = NSToolbar(identifier: "MainToolbar")
            toolbar.displayMode = .iconOnly
            window.toolbar = toolbar
            
            // Set min/max size constraints for resizing
            window.minSize = NSSize(width: 420, height: 480)
            window.maxSize = NSSize(width: 600, height: 700)
            
            window.center()
            window.makeKeyAndOrderFront(nil)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
