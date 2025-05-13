import SwiftUI
import AppKit

class MiniPlayerController: ObservableObject {
    var miniPlayerWindow: NSPanel?
    var onExit: (() -> Void)?
    
    func showMiniPlayer(playerManager: PlayerManager, musicState: MusicPlayerState, onExit: @escaping () -> Void) {
        self.onExit = onExit
        if miniPlayerWindow == nil {
            miniPlayerWindow = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 100),
                styleMask: [.nonactivatingPanel, .titled],
                backing: .buffered,
                defer: false
            )
            miniPlayerWindow?.isFloatingPanel = true
            miniPlayerWindow?.level = .floating
            miniPlayerWindow?.hasShadow = true
            miniPlayerWindow?.isMovableByWindowBackground = true
            miniPlayerWindow?.center()
            let hostingView = NSHostingView(rootView: MiniPlayerView(
                playerManager: playerManager,
                musicState: musicState,
                onExit: onExit
            ))
            miniPlayerWindow?.contentView = hostingView
        }
        miniPlayerWindow?.makeKeyAndOrderFront(nil)
        if let mainWindow = NSApplication.shared.windows.first {
            mainWindow.orderOut(nil)
        }
    }
    
    func hideMiniPlayer() {
        miniPlayerWindow?.close()
        miniPlayerWindow = nil
        if let mainWindow = NSApplication.shared.windows.first {
            mainWindow.makeKeyAndOrderFront(nil)
        }
    }
}
