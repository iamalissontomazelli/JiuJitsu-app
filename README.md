# Jiu-Jitsu App

A personal project to organize Brazilian Jiu-Jitsu training, study
techniques, and build a structured game plan. The app is being developed
with **SwiftUI** in **Xcode** for Apple platforms.

> **Project status:** In development. The current focus is the **Game
> Plan** section. Features described as planned are not necessarily
> implemented yet.

## Goals

-   Organize Jiu-Jitsu training and technique study in one place.
-   Help practitioners build and refine a personal game plan.
-   Keep the interface clear and easy to navigate.
-   Support multiple interface languages.

## Planned features

The app's feature set is being developed incrementally. The current
product plan includes:

-   **Home:** A central overview with quick actions.
-   **Calendar:** View and organize training sessions.
-   **Game Plan:** Build a personal game plan organized by systems,
    positions, and techniques.
-   **Library:** Keep class videos and learning resources together.
-   **Profile:** Student profile and, in a future iteration, instructor
    profile.
-   **Language settings:** Choose the app's display language.
-   **Future possibilities:** Class requests, student groups, group
    messaging, challenges or competitions, membership and purchase
    options, invoices, and sponsorship partnerships.

These are planned product ideas; availability depends on implementation
progress.

## Game Plan

The Game Plan is the current development priority. The intended
experience is to let a practitioner organize their approach by system
(for example, takedowns), then add techniques and supporting material.

Potential elements include:

-   Systems and techniques.
-   Technique descriptions and personal notes.
-   Video links or class-study references.
-   Status and progress tracking.

The implementation should build on the existing project code, keeping
the main navigation intact and moving feature-specific code into
separate Swift files when that improves maintainability.

## Languages

The app is intended to support:

-   Brazilian Portuguese (`pt-BR`)
-   English
-   Spanish
-   French

Language selection is part of the planned settings experience. The app
uses an `appLanguage` preference in its current SwiftUI work; language
switching and localized content should be verified as implementation
progresses.

## Technology

-   **Language:** Swift
-   **UI framework:** SwiftUI
-   **IDE:** Xcode
-   **Version control:** Git and GitHub

## Project structure

The repository is expected to contain the Xcode project, application
source, and test targets. The exact files may change as development
continues.

``` text
JiuJitsu-app/
├── jiu-jitsu-App.xcodeproj/
├── jiu-jitsu-App/
│   ├── ContentView.swift
│   └── AppLanguage.swift
├── jiu-jitsu-AppTests/
├── jiu-jitsu-AppUITests/
└── README.md
```

This is an indicative structure, not a guaranteed complete listing of
every file currently in the project.

## Getting started

1.  Clone or download this repository.
2.  Open `jiu-jitsu-App.xcodeproj` in Xcode.
3.  Select the app scheme and an available iPhone simulator or connected
    Apple device.
4.  Build and run the project from Xcode.
5.  To inspect the source, use the Project Navigator in Xcode. You do
    not need to run a build just to browse or edit files.

> Exact build requirements, supported OS versions, and device
> requirements should be added once they are confirmed in the Xcode
> project settings.

## Development approach

Development is incremental:

1.  Preserve the current working app and navigation.
2.  Complete and test the Game Plan experience first.
3.  Separate feature-specific views and models into their own Swift
    files where appropriate.
4.  Verify navigation and language selection in the simulator.
5.  Add and test the remaining sections one at a time.

## Testing

The repository includes app test and UI test targets:

-   `jiu-jitsu-AppTests`
-   `jiu-jitsu-AppUITests`

Add tests alongside new functionality and run the relevant test schemes
in Xcode as the project evolves.

## Roadmap

-   [ ] Finalize the Game Plan user experience.
-   [ ] Organize Game Plan views and models into maintainable files.
-   [ ] Verify navigation between Home, Game Plan, Calendar, Library,
    and Profile.
-   [ ] Implement and verify language selection and localized interface
    text.
-   [ ] Develop the remaining sections incrementally.
-   [ ] Confirm offline/online behavior and data storage requirements.
-   [ ] Define the membership and purchase model before implementing
    payments.
-   [ ] Review future community features such as groups, messaging, and
    challenges.

## Contributing and feedback

This is a work in progress. Suggestions, bug reports, and improvements
are welcome through the repository's GitHub issues or project
discussions, where enabled.

## License

No license has been specified yet. Unless a license is added to this
repository, reuse, distribution, and modification are not automatically
granted.
