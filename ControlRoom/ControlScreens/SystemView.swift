//
//  SystemView.swift
//  ControlRoom
//
//  Created by Paul Hudson on 12/02/2020.
//  Copyright © 2020 Paul Hudson. All rights reserved.
//

import SwiftUI

/// Controls system-wide settings such as time and appearance.
struct SystemView: View {
    var simulator: Simulator

    /// The current time to show in the device.
    @State private var time = Date()

    /// The system-wide appearance; "Light" or "Dark".
    @State private var appearance = "Light"

    /// Formats the user's date in the way simctl expects to read it.
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }

    var body: some View {
        Form {
            Group {
                HStack {
                    DatePicker("Time:", selection: $time, displayedComponents: .hourAndMinute)
                    Button("Set", action: setTime)
                }

                Picker("Appearance:", selection: $appearance.onChange(updateAppearance)) {
                    ForEach(["Light", "Dark"], id: \.self) {
                        Text($0)
                    }
                }

                FormSpacer()
            }

            Group {
                Section {
                    Button("Trigger iCloud Sync", action: triggerSync)
                }

                FormSpacer()
            }

            Group {
                Section(header: Text("Copy Pasteboard")) {
                    HStack {
                        Button("Simulator -> Mac", action: copyPasteboardToMac)
                        Button("Mac -> Simulator", action: copyPasteboardToSim)
                    }
                }

                FormSpacer()
            }

            Group {
                Section(header: Text("Screen")) {
                    Button("Take Screenshot", action: takeScreenshot)
                }

                Spacer()
            }

            HStack {
                Spacer()
                Button("Erase Content and Settings", action: eraseDevice)
            }
        }
        .tabItem {
            Text("System")
        }
        .padding()
    }

    /// Changes the system clock to a new value.
    func setTime() {
        Command.simctl("status_bar \(self.simulator.udid) override --time \(self.timeString)")
    }

    /// Moves between light and dark mode.
    func updateAppearance() {
        Command.simctl("ui \(simulator.udid) appearance \(appearance.lowercased())")
    }

    /// Starts an immediate iCloud sync.
    func triggerSync() {
        Command.simctl("icloud_sync \(self.simulator.udid)")
    }

    /// Copies the simulator's pasteboard to the Mac.
    func copyPasteboardToMac() {
        Command.simctl("pbsync \(self.simulator.udid) host")
    }

    /// Copies the Mac's pasteboard to the simulator.
    func copyPasteboardToSim() {
        Command.simctl("pbsync host \(self.simulator.udid)")
    }

    /// Takes a screenshot of the device's current screen and saves it to the desktop.
    func takeScreenshot() {
        Command.simctl("io \(self.simulator.udid) screenshot \(makeScreenshotFilename())")
    }

    /// Erases the current device.
    func eraseDevice() {
        Command.simctl("erase \(self.simulator.udid)")
    }

    /// Creates a filename for a screenshot that ought to be unique
    func makeScreenshotFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd-HH-mm-ss"
        let dateString = formatter.string(from: Date())
        return "~/Desktop/ControlRoom-\(dateString).png"
    }
}

struct SystemView_Previews: PreviewProvider {
    static var previews: some View {
        SystemView(simulator: .example)
    }
}
