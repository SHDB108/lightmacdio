# MyMacMusicPlayer

## Overview

MyMacMusicPlayer is a macOS music player developed using Swift and SwiftUI. It implements features such as playlist management, song playback, shuffle play, and single-song loop. This project is submitted as an assignment, and the code is organized in a modular structure. [cite: 1]

## How to Run

1.  **Unzip the Project**
    -   Unzip the submitted `MyMacMusicPlayer.zip` file to obtain the `MyMacMusicPlayer` folder. [cite: 1]

2.  **Open the Project**
    -   Open `MyMacMusicPlayer/MyMacMusicPlayer.xcodeproj` using Xcode. [cite: 1]

3.  **Check Permission Configuration**
    -   Ensure that `MyMacMusicPlayer/Info.plist` contains the following key-value pair to allow access to user-selected files:
        `com.apple.security.files.user-selected.read-write = true`
    -   If the file is missing, create it using these steps:
        -   In Xcode, right-click on the project folder and select `New File > Property List`, and name it `Info.plist`.
        -   Add the permission key-value pair mentioned above. [cite: 1]

4.  **Build and Run**
    -   In Xcode, press `Command + B` to build the project and confirm there are no compilation errors. [cite: 1]
    -   Press `Command + R` to run the project. [cite: 1]
    -   The main interface of the music player will be displayed after the project starts. [cite: 1]

## Usage Instructions

1.  **Load Songs**
    -   Click the "folder" icon in the toolbar to select a folder containing `.mp3` files. [cite: 1]
    -   Or click the "music note" icon to import a single `.mp3` file. [cite: 1]
    -   The songs will be automatically added to the playlist. [cite: 1, 2]

2.  **Play Songs**
    -   Click on the song name in the song list to start playing. [cite: 2]
    -   Use the NowPlayingBar at the bottom to control play, pause, previous, and next. [cite: 2]
    -   Drag the progress bar to adjust the playback position. [cite: 2]

3.  **Manage Playlist**
    -   The sidebar displays the playlist; click to switch views. [cite: 2]
    -   Hold down the Control key and left-click on the playlist to bring up a delete confirmation. [cite: 2]

4.  **Enhanced Features**
    -   In the NowPlayingBar, click the play mode button to switch between normal, shuffle, and single-song loop modes. [cite: 2]
    -   Click the "rectangle" icon in the toolbar to switch to the mini player. [cite: 2]

## Feature List

-   Playlist Management: Create, delete, switch. [cite: 2]
-   Song Loading: Supports folder and single-file `.mp3` import. [cite: 2]
-   Playback Control: Play, pause, previous, next, progress adjustment. [cite: 2]
-   Play Mode: Shuffle play, single-song loop. [cite: 2]
-   Mini Player: Independent window playback control. [cite: 2]
-   User Experience: Search songs, temporary prompts (Toast). [cite: 2]

## Submission Information

-   Student Name: Your Name [cite: 2]
-   Student ID: Your Student ID [cite: 2]
-   Submission Date: May 2, 2025 [cite: 2]
-   Instructor: Your Instructor's Name [cite: 2]
-   Remarks: The project has been tested, all functions are working properly, and the code is organized in a modular structure. [cite: 2]

## Precautions

-   Ensure that your Xcode version supports SwiftUI (Xcode 15 or later is recommended). [cite: 2]
-   If you encounter permission issues at runtime, check the `Info.plist` configuration. [cite: 2]
-   The project relies on local `.mp3` files; please prepare test songs. [cite: 2]
