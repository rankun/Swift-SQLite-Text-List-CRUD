# Simple Text List App with SQLite Persistence

This repository contains a single SwiftUI view file, `ContentView.swift`, which implements a basic text list app with SQLite persistence.

## Prerequisites

1. Xcode 13 or later
2. iOS 15 or later
3. [SQLite.swift](https://github.com/stephencelis/SQLite.swift) library

## Setup

1. Create a new SwiftUI project in Xcode.
2. Add the SQLite.swift library to your project using Swift Package Manager:
   - In Xcode, go to **File > Swift Packages > Add Package Dependency**.
   - Enter the following repository URL: `https://github.com/stephencelis/SQLite.swift.git`
   - Click **Next** and choose the latest version, then click **Finish**.
3. Replace the contents of the `ContentView.swift` file in your project with the [ContentView.swift](./ContentView.swift) file from this repository.

## Usage

1. Build and run the app on a simulator or a physical device.
2. Add new text items using the text field at the top of the list.
3. Tap on a text item to edit it.
4. Swipe left on a text item to delete it.
5. Tap the "Edit" button in the top right corner to enable editing mode, allowing you to reorder and delete items using drag handles and delete buttons.

The app uses SQLite to persist text items, so your list will be saved between app launches.
