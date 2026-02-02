import SwiftUI
import AppKit
import UniformTypeIdentifiers
import Darwin

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
                        

                        
                            // Error details
                        if appState == .error && !errorDetails.isEmpty {
                            ZStack(alignment: .topTrailing) {
                                ScrollView {
                                    Text(errorDetails)
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundStyle(.red.opacity(0.8))
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(8)
                                        .padding(.trailing, 24) // Make room for copy button
                                }
                                .frame(height: 80)
                                .background {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.red.opacity(0.05))
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 6)
                                        .strokeBorder(Color.red.opacity(0.2), lineWidth: 1)
                                }
                                
                                // Copy Button
                                Button(action: {
                                    let pasteboard = NSPasteboard.general
                                    pasteboard.clearContents()
                                    pasteboard.setString(errorDetails, forType: .string)
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.red.opacity(0.6))
                                        .padding(6)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .help("Copy error log")
                                .padding(2)
                            }
                            .padding(.top, 4)
                        }
                        
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
                let (quarantineSuccess, quarantineError) = runUnquarantine(url: url)
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
    
    private nonisolated func runUnquarantine(url: URL) -> (success: Bool, error: String?) {
        // Access security scoped resource (needed for drag & drop files)
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        let path = url.path
        let attribute = "com.apple.quarantine"
        
        // 0 = Success, -1 = Error
        let result = removexattr(path, attribute, 0)
        
        if result == 0 {
            return (true, nil)
        } else {
            let errorNumber = errno
            // ENOATTR (93) means the attribute doesn't exist, which counts as success
            if errorNumber == 93 {
                return (true, nil)
            }
            
            let errorMessage = String(cString: strerror(errorNumber))
            return (false, "Quarantine Removal Error (\(errorNumber)): \(errorMessage)")
        }
    }
    
    private nonisolated func runAdHocSign(path: String) -> (success: Bool, error: String?) {
        let task = Process()
        task.launchPath = "/usr/bin/codesign"
        // Ad-hoc signing: -s - means no certificate (ad-hoc), --deep signs nested code, -f forces re-signing
        task.arguments = ["-s", "-", "-f", "--deep", path]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            if task.terminationStatus == 0 {
                return (true, nil)
            } else {
                return (false, "Code Signing Error (Exit Code \(task.terminationStatus)):\n\(output)")
            }
        } catch {
            return (false, "Failed to run codesign process: \(error.localizedDescription)")
        }
    }
}
