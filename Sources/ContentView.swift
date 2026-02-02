import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("enableSigning") private var enableSigning = true
    @AppStorage("enableQuarantine") private var enableQuarantine = true
    
    @State private var isTargeted = false
    @State private var isHovering = false
    @State private var appState: AppState = .idle
    @State private var statusMessage = "Drop an app, DMG, or PKG here"
    @State private var fileName: String = ""
    @State private var gradientRotation: Double = 0
    @State private var errorDetails: String = ""
    
    enum AppState {
        case idle
        case processing
        case success
        case error
    }

    var body: some View {
        ZStack {
            // Background with subtle gradient
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top spacing for traffic lights
                Spacer()
                    .frame(height: 40)
                
                // Main content
                VStack(spacing: 20) {
                    // Icon container
                    iconView
                    
                    // Text content
                    VStack(spacing: 10) {
                        Text(stateTitle)
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text(statusMessage)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .frame(maxWidth: 280)
                        

                        
                        // Close button for error state
                        if appState == .error {
                            Button(action: resetToIdle) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(.secondary.opacity(0.8))
                                    .contentShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 16)
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        }
                    }
                    
                    // Click to select button (only in idle state)
                    if appState == .idle {
                        Button(action: openFilePicker) {
                            HStack(spacing: 6) {
                                Image(systemName: "folder.badge.plus")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Or click to browse")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background {
                                Capsule()
                                    .fill(.blue.opacity(0.1))
                            }
                        }
                        .buttonStyle(.plain)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    }
                    
                    // Settings toggles (only in idle state)
                    if appState == .idle {
                        VStack(spacing: 12) {
                            Divider()
                                .padding(.horizontal, 32)
                            
                            VStack(spacing: 6) {
                                // Quarantine toggle
                                HStack(spacing: 10) {
                                    Image(systemName: "shield.lefthalf.filled")
                                        .font(.system(size: 16))
                                        .foregroundStyle(enableQuarantine ? .blue : .secondary)
                                        .frame(width: 20)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Remove quarantine")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(.primary)
                                        Text("Fixes 'damaged' & verification warnings")
                                            .font(.system(size: 11))
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $enableQuarantine)
                                        .labelsHidden()
                                        .toggleStyle(.switch)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color.primary.opacity(0.03))
                                }
                                
                                // Signing toggle
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(enableSigning ? .blue : .secondary)
                                        .frame(width: 20)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Ad-hoc sign apps")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(.primary)
                                        Text("Removes 'unverified developer' warning")
                                            .font(.system(size: 11))
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $enableSigning)
                                        .labelsHidden()
                                        .toggleStyle(.switch)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color.primary.opacity(0.03))
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Bottom hint
                if appState == .idle {
                    VStack(spacing: 4) {
                        HStack(spacing: 5) {
                            Image(systemName: "wrench.and.screwdriver.fill")
                                .font(.system(size: 11))
                            Text("Fixes common macOS security issues")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundStyle(.tertiary)
                    }
                    .padding(.bottom, 20)
                }
            }
            
            // Drop overlay
            if isTargeted {
                dropOverlay
            }
        }
        .frame(minWidth: 420, maxWidth: .infinity, minHeight: 480, maxHeight: .infinity)
        .contentShape(Rectangle()) // Make entire area clickable
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
        }
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isHovering = hovering
            }
        }
    }
    
    // MARK: - Subviews
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: colorScheme == .dark ? [
                Color(red: 0.1, green: 0.1, blue: 0.12),
                Color(red: 0.15, green: 0.12, blue: 0.18)
            ] : [
                Color(red: 0.98, green: 0.98, blue: 0.99),
                Color(red: 0.95, green: 0.96, blue: 0.98)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var iconView: some View {
        ZStack {
            // Animated ring for processing/targeted states only
            if appState == .processing || isTargeted {
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: gradientColors + [gradientColors[0]],
                            center: .center
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 156, height: 156)
                    .blur(radius: 4)
                    .opacity(0.6)
                    .rotationEffect(.degrees(gradientRotation))
                    .onAppear {
                        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                            gradientRotation = 360
                        }
                    }
            }
            
            // Main icon container
            Circle()
                .fill(.regularMaterial)
                .frame(width: 140, height: 140)
                .overlay {
                    Circle()
                        .strokeBorder(.quaternary, lineWidth: 0.5)
                }
                .shadow(
                    color: .black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                    radius: isHovering ? 25 : 20,
                    y: isHovering ? 10 : 8
                )
            
            // Icon
            Image(systemName: stateIconName)
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(stateColor)
                .symbolEffect(.bounce.up, value: isTargeted)
                .symbolEffect(.pulse, isActive: appState == .processing)
                .contentTransition(.symbolEffect(.replace))
        }
        .frame(width: 160, height: 160) // Fixed size to prevent layout shift when ring appears
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState)
    }
    
    private var dropOverlay: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [12, 8]))
            .foregroundStyle(.blue)
            .padding(32)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.blue.opacity(0.08))
                    .padding(32)
            }
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    // MARK: - Computed Properties
    
    private var gradientColors: [Color] {
        switch appState {
        case .success: return [.green, .mint, .teal]
        case .error: return [.red, .orange, .pink]
        default: return [.blue, .cyan, .purple]
        }
    }
    
    private var stateIconName: String {
        switch appState {
        case .idle: return isTargeted ? "arrow.down.circle.fill" : "wrench.and.screwdriver"
        case .processing: return "gearshape.2"
        case .success: return "checkmark.circle.fill"
        case .error: return "exclamationmark.triangle.fill"
        }
    }
    
    private var stateColor: AnyShapeStyle {
        switch appState {
        case .idle:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [.blue, .cyan],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .processing: return AnyShapeStyle(Color.blue.gradient)
        case .success: return AnyShapeStyle(Color.green.gradient)
        case .error: return AnyShapeStyle(Color.red.gradient)
        }
    }
    
    private var stateTitle: String {
        switch appState {
        case .idle: return isTargeted ? "Drop to Fix" : "MacApp Fixer"
        case .processing: return "Processing..."
        case .success: return "Success!"
        case .error: return "Failed"
        }
    }
    
    // MARK: - Logic
    
    private func resetToIdle() {
        withAnimation(.easeInOut(duration: 0.3)) {
            appState = .idle
            statusMessage = "Drop an app, DMG, or PKG here"
            fileName = ""
            errorDetails = ""
        }
    }
    
    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.title = "Select an app, DMG, or PKG to fix"
        panel.message = "Choose a file to fix security issues"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            .application,
            .bundle,
            UTType(filenameExtension: "dmg") ?? .data,
            UTType(filenameExtension: "pkg") ?? .data
        ]
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                processFile(at: url)
            }
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (item, error) in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else {
                return
            }
            
            DispatchQueue.main.async {
                processFile(at: url)
            }
        }
        return true
    }
    
    private func processFile(at url: URL) {
        fileName = url.lastPathComponent
        statusMessage = "Processing \(fileName)..."
        
        withAnimation(.easeInOut(duration: 0.3)) {
            appState = .processing
        }
        
        // Detect file type
        let fileExtension = url.pathExtension.lowercased()
        let isDMG = fileExtension == "dmg"
        let isPKG = fileExtension == "pkg"
        let isNonAppFile = isDMG || isPKG
        
        // Capture preferences before async work
        // For DMG/PKG files, signing doesn't make sense - only quarantine removal
        let userEnabledSigning = enableSigning  // Original user preference
        let shouldSign = isNonAppFile ? false : enableSigning
        let shouldRemoveQuarantine = enableQuarantine
        
        // Check if at least one operation is enabled (or applicable)
        guard shouldSign || shouldRemoveQuarantine else {
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    self.appState = .error
                    self.statusMessage = "Please enable at least one operation"
                }
            }
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            Thread.sleep(forTimeInterval: 0.5)
            
            var allSuccess = true
            var results: [String] = []
            var errorLog: [String] = []
            
            // Step 1: Remove quarantine (if enabled)
            if shouldRemoveQuarantine {
                let (quarantineSuccess, quarantineError) = runUnquarantine(path: url.path)
                if quarantineSuccess {
                    results.append("✓ Quarantine removed")
                } else {
                    results.append("✗ Quarantine removal failed")
                    allSuccess = false
                    if let error = quarantineError {
                        errorLog.append(error)
                    }
                }
            }
            
            // Step 2: Ad-hoc sign (if enabled and applicable)
            if shouldSign {
                let (signSuccess, signError) = self.runAdHocSign(path: url.path)
                if signSuccess {
                    results.append("✓ App signed")
                } else {
                    results.append("✗ Signing failed")
                    allSuccess = false
                    if let error = signError {
                        errorLog.append(error)
                    }
                }
            } else if isNonAppFile && userEnabledSigning {
                // Inform user that signing was skipped for non-app files
                results.append("ℹ Signing skipped (not applicable for \(fileExtension.uppercased()))")
            }
            
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    if allSuccess {
                        appState = .success
                        statusMessage = results.joined(separator: "\n")
                        errorDetails = ""
                    } else {
                        appState = .error
                        statusMessage = results.joined(separator: "\n")
                        errorDetails = errorLog.joined(separator: "\n\n")
                    }
                }
                
                if allSuccess {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.resetToIdle()
                    }
                }
            }
        }
    }
    
    private nonisolated func runUnquarantine(path: String) -> (success: Bool, error: String?) {
        let escapedPath = path.replacingOccurrences(of: "\"", with: "\\\"")
        let scriptSource = """
        do shell script "xattr -d com.apple.quarantine \\"\(escapedPath)\\"" with administrator privileges
        """
        
        if let script = NSAppleScript(source: scriptSource) {
            var errorInfo: NSDictionary?
            script.executeAndReturnError(&errorInfo)
            
            if let error = errorInfo {
                let errorMessage = error[NSAppleScript.errorMessage] as? String ?? "Unknown error"
                let errorNumber = error[NSAppleScript.errorNumber] as? Int ?? -1
                return (false, "Quarantine Removal Error (\(errorNumber)):\n\(errorMessage)")
            }
            return (true, nil)
        }
        return (false, "Failed to create AppleScript for quarantine removal")
    }
    
    private nonisolated func runAdHocSign(path: String) -> (success: Bool, error: String?) {
        let escapedPath = path.replacingOccurrences(of: "\"", with: "\\\"")
        
        // Ad-hoc signing: -s - means no certificate (ad-hoc), --deep signs nested code, -f forces re-signing
        let scriptSource = """
        do shell script "codesign -s - -f --deep \\"\(escapedPath)\\"" with administrator privileges
        """
        
        if let script = NSAppleScript(source: scriptSource) {
            var errorInfo: NSDictionary?
            script.executeAndReturnError(&errorInfo)
            
            if let error = errorInfo {
                let errorMessage = error[NSAppleScript.errorMessage] as? String ?? "Unknown error"
                let errorNumber = error[NSAppleScript.errorNumber] as? Int ?? -1
                return (false, "Code Signing Error (\(errorNumber)):\n\(errorMessage)")
            }
            return (true, nil)
        }
        return (false, "Failed to create AppleScript for code signing")
    }
}
