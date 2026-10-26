//Build TESTE 1.0
// NECESSARIO FAZER CORREÇÃO EM CORES (PARA DARK MODE)
// BUILD TESTE 1.1.0
// CORREÇÃO REALIZADA AS 12:09
// BUILD TESTANDO CONSUMO DE MEMORIA NO APARELHO.


import SwiftUI
import Combine
import AVKit
import UniformTypeIdentifiers

// MARK: - Design System


private enum JJStyle {
    static let background = Color.black
    static let surface1 = Color(red: 21/255, green: 26/255, blue: 29/255)
    static let surface2 = Color(red: 31/255, green: 37/255, blue: 40/255)
    static let surface3 = Color(red: 42/255, green: 50/255, blue: 54/255)

    static let sage = Color(red: 143/255, green: 165/255, blue: 139/255)
    static let mint = Color(red: 183/255, green: 200/255, blue: 177/255)
    static let green = Color(red: 100/255, green: 127/255, blue: 101/255)
    static let orange = Color.orange
}


// MARK: - Video Model

struct JJVideo: Identifiable, Codable {
    var id = UUID()
    var title: String
    var category: String
    var fileName: String
    var isFavorite = false

    var fileURL: URL {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent(fileName)
    }
}

// MARK: - Local Video Storage

@MainActor
final class JJVideoStore: ObservableObject {
    @Published var videos: [JJVideo] = []

    private let storageKey = "jiujitsu.localVideos"

    init() {
        load()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(
            forKey: storageKey
        ) else { return }

        videos = (try? JSONDecoder().decode(
            [JJVideo].self,
            from: data
        )) ?? []

        // Remove entries whose local files no longer exist.
        videos.removeAll { !FileManager.default.fileExists(atPath: $0.fileURL.path) }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(videos) else {
            return
        }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    func addVideo(from sourceURL: URL) throws {
        let accessGranted = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if accessGranted {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        let fileName = UUID().uuidString + "-" + sourceURL.lastPathComponent
        let destination = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent(fileName)

        try FileManager.default.copyItem(
            at: sourceURL,
            to: destination
        )

        let video = JJVideo(
            title: sourceURL.deletingPathExtension().lastPathComponent,
            category: "Technique",
            fileName: fileName
        )

        videos.insert(video, at: 0)
        save()
    }

    func toggleFavorite(_ video: JJVideo) {
        guard let index = videos.firstIndex(where: {
            $0.id == video.id
        }) else { return }

        videos[index].isFavorite.toggle()
        save()
    }

    func delete(_ video: JJVideo) {
        try? FileManager.default.removeItem(at: video.fileURL)
        videos.removeAll { $0.id == video.id }
        save()
    }
}

// MARK: - Main Navigation (Menu Principal)

struct ContentView: View {
    @AppStorage("appLanguage") private var appLanguage = "pt-BR"
    @StateObject private var videoStore = JJVideoStore()
    @StateObject private var bookingStore = JJBookingStore()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(
                    videoCount: videoStore.videos.count,
                    bookingStore: bookingStore,
                    selectedTab: $selectedTab
                )
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(0)
            
            NavigationStack {
                CalendarView()
            }
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
            .tag(1)
            
            NavigationStack {
                GamePlanView()
            }
            .tabItem {
                Label(
                    "Game Plan",
                    systemImage: "point.3.connected.trianglepath.dotted"
                )
            }
            .tag(2)
            
            NavigationStack {
                VideoLibraryView(store: videoStore)
            }
            .tabItem {
                Label("Library", systemImage: "rectangle.stack")
            }
            .tag(3)
            
            NavigationStack {
                ProfileView(appLanguage: $appLanguage)
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
        
        }
        .background(JJStyle.background.ignoresSafeArea())
        .tint(JJStyle.sage)
        .preferredColorScheme(.dark)
    }
    
    
   
    // MARK: - Home

   private struct HomeView: View {
       let videoCount: Int

       @ObservedObject var bookingStore: JJBookingStore
       @State private var showingBookingSheet = false
       @Binding var selectedTab: Int

       var body: some View {
           ScrollView {
               VStack(alignment: .leading, spacing: 24) {

                   // MARK: Welcome

                   VStack(alignment: .leading, spacing: 5) {
                       Text("Hey, Alex")
                           .font(.largeTitle.bold())

                       Text("Keep showing up.")
                           .foregroundStyle(.secondary)
                   }
                   

                   // MARK: Next Private Lesson

                   VStack(alignment: .leading, spacing: 12) {
                       Label(
                           "NEXT PRIVATE LESSON",
                           systemImage: "calendar"
                       )
                       .font(.caption.bold())
                       .foregroundStyle(JJStyle.sage)

                       if let lesson = bookingStore.nextLesson {

                           Text(lesson.lessonType)
                               .font(.title3.bold())

                           Label {
                               Text(
                                   lesson.date.formatted(
                                       date: .abbreviated,
                                       time: .shortened
                                   )
                               )
                           } icon: {
                               Image(systemName: "clock")
                           }
                           .foregroundStyle(.secondary)

                           HStack(spacing: 6) {
                               Circle()
                                   .fill(JJStyle.sage)
                                   .frame(width: 7, height: 7)

                               Text("Status: \(lesson.status)")
                                   .font(.caption)
                                   .foregroundStyle(JJStyle.sage)
                           }

                           if !lesson.notes.isEmpty {
                               Text(lesson.notes)
                                   .font(.subheadline)
                                   .foregroundStyle(.secondary)
                           }

                       } else {

                           Text("No upcoming lessons")
                               .font(.title3.bold())

                           Text("Book your next training session.")
                               .font(.subheadline)
                               .foregroundStyle(.secondary)

                           Button {
                               showingBookingSheet = true
                           } label: {
                               Label(
                                   "Book Lesson",
                                   systemImage: "plus.circle.fill"
                               )
                               .font(.subheadline.bold())
                               .foregroundStyle(JJStyle.sage)
                           }
                           .buttonStyle(.plain)
                       }
                   }
                   .padding()
                   .frame(maxWidth: .infinity, alignment: .leading)
                   .background(
                       JJStyle.surface1,
                       in: RoundedRectangle(cornerRadius: 20)
                   )

                   // MARK: Your Progress

                   VStack(alignment: .leading, spacing: 14) {
                       HStack {
                           Text("Your Progress")
                               .font(.title2.bold())

                           Spacer()

                           Text("72%")
                               .font(.headline)
                               .foregroundStyle(JJStyle.sage)
                       }

                       ProgressView(value: 0.72)
                           .tint(JJStyle.sage)

                       Text("Guard Passing · Week 3 of 6")
                           .font(.subheadline)
                           .foregroundStyle(.secondary)
                   }
                   .padding()
                   .background(
                       JJStyle.surface1,
                       in: RoundedRectangle(cornerRadius: 20)
                   )

                   // MARK: Quick Actions

                   Text("Quick Actions")
                       .font(.title2.bold())

                   HStack(spacing: 12) {
                       //BookLesson Section
                       Button {
                           showingBookingSheet = true
                       } label: {
                           QuickAction(
                               title: "Book Lesson",
                               icon: "calendar.badge.plus"
                           )
                       }
                       .buttonStyle(.plain)
                       //GamePlan Section
                       Button {
                           selectedTab = 2
                       } label: {
                           QuickAction(
                               title: "Game Plan",
                               icon: "point.3.connected.trianglepath.dotted"
                           )
                       }
                       .buttonStyle(.plain)
                       //QuickButton to Video
                       QuickAction(
                           title: "Videos",
                           icon: "play.rectangle"
                       )
                       //Quick Notes
                       QuickAction(
                           title: "Notes",
                           icon: "note.text"
                       )
                   }

                   // MARK: Your Library

                   VStack(alignment: .leading, spacing: 8) {
                       Text("Your Library")
                           .font(.title3.bold())

                       Text("\(videoCount) videos saved on this device")
                           .foregroundStyle(.secondary)
                   }
               }
               .padding()
           }
           .background(JJStyle.background)
           .navigationTitle("JIUJITSU")
           .sheet(isPresented: $showingBookingSheet) {
               BookingView(bookingStore: bookingStore)
           }
       }
   }

    // MARK: - Calendar
    
    private struct CalendarView: View {
        var body: some View {
            List {
                Section("Upcoming Lessons") {
                    Label {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Guard Passing System")
                            Text("Tomorrow · 12:00")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundStyle(JJStyle.sage)
                    }
                    
                    Label {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Position Review")
                            Text("Friday · 14:00")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundStyle(JJStyle.sage)
                    }
                }
                
                Section {
                    Text("Lesson booking will be connected to a real calendar in a later development stage.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Calendar")
        }
    }
    private struct QuickAction: View {
        let title: String
        let icon: String

        var body: some View {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(JJStyle.sage)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 84)
            .padding(8)
            .background(
                JJStyle.surface1,
                in: RoundedRectangle(cornerRadius: 14)
            )
        }
    }
    
    
    // MARK: - Game Plan
    
    private struct GamePlanView: View {
        private let systems: [(String, String, Color)] = [
            ("Takedowns", "Build your standing game", .blue),
            ("Submissions", "Develop finishing sequences", .red),
            ("Guard Passing", "Improve positional control", JJStyle.sage),
            ("Sweeps", "Create reversal opportunities", .purple),
            ("Top Control", "Maintain dominant positions", .orange),
            ("Transitions", "Connect techniques together", .cyan)
        ]
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Jiu-Jitsu systems")
                        .font(.title3.bold())
                    
                    Text("Choose a system to start organizing your techniques.")
                        .foregroundStyle(.secondary)
                    
                    ForEach(systems, id: \.0) { system in
                        HStack(spacing: 14) {
                            Image(systemName: "figure.grappling")
                                .font(.title2)
                                .foregroundStyle(system.2)
                                .frame(width: 48, height: 48)
                                .background(system.2.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(system.0)
                                    .font(.headline)
                                Text(system.1)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding()
            }
            .navigationTitle("Game Plan")
        }
    }
    
    // MARK: - Video Library and Upload
    
    private struct VideoLibraryView: View {
        @ObservedObject var store: JJVideoStore
        
        @State private var showingImporter = false
        @State private var selectedVideo: JJVideo?
        @State private var searchText = ""
        @State private var showingFavorites = false
        @State private var errorMessage: String?
        
        private var filteredVideos: [JJVideo] {
            store.videos.filter { video in
                let matchesSearch = searchText.isEmpty ||
                video.title.localizedCaseInsensitiveContains(searchText)
                
                return matchesSearch &&
                (!showingFavorites || video.isFavorite)
            }
        }
        
        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    TextField("Search videos", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        showingImporter = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(width: 42, height: 42)
                            .background(JJStyle.green, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .accessibilityLabel("Upload video")
                }
                .padding()
                
                Picker("Video filter", selection: $showingFavorites) {
                    Text("All").tag(false)
                    Text("Favorites").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if filteredVideos.isEmpty {
                    ContentUnavailableView(
                        "No Videos Yet",
                        systemImage: "video",
                        description: Text("Upload a lesson video to start building your personal library.")
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredVideos) { video in
                            Button {
                                selectedVideo = video
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "play.rectangle.fill")
                                        .font(.system(size: 34))
                                        .foregroundStyle(JJStyle.sage)
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(video.title)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        
                                        Text(video.category)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        store.toggleFavorite(video)
                                    } label: {
                                        Image(systemName: video.isFavorite ? "star.fill" : "star")
                                            .foregroundStyle(video.isFavorite ? .orange : .secondary)
                                    }
                                    .buttonStyle(.borderless)
                                }
                                .padding(.vertical, 5)
                            }
                            .buttonStyle(.plain)
                            .swipeActions {
                                Button(role: .destructive) {
                                    store.delete(video)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Video Library")
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.movie, .mpeg4Movie, .video],
                allowsMultipleSelection: false
            ) { result in
                do {
                    let urls = try result.get()
                    guard let url = urls.first else { return }
                    try store.addVideo(from: url)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
            .alert("Unable to Import Video", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Please try again.")
            }
            .sheet(item: $selectedVideo) { video in
                NavigationStack {
                    VideoPlayer(player: AVPlayer(url: video.fileURL))
                        .navigationTitle(video.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") {
                                    selectedVideo = nil
                                }
                            }
                        }
                }
            }
        }
    }
    
    // MARK: - Profile and Settings
    
    private struct ProfileView: View {
        @Binding var appLanguage: String
        
        var body: some View {
            Form {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(JJStyle.sage)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Alex Pereira")
                                .font(.title3.bold())
                            Text("Black Belt · 15 years")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Progress") {
                    LabeledContent("Overall Progress", value: "72%")
                    ProgressView(value: 0.72)
                        .tint(JJStyle.sage)
                    
                    LabeledContent("Takedown System", value: "4/6")
                    LabeledContent("Guard System", value: "3/6")
                    LabeledContent("Back Take System", value: "2/6")
                }
                
                Section("Settings") {
                    Picker("App Language", selection: $appLanguage) {
                        Text("Português (Brasil)").tag("pt-BR")
                        Text("English").tag("en")
                        Text("Español").tag("es")
                        Text("Français").tag("fr")
                    }
                    
                    Text("Language selection is saved locally. Full translations will be added in a later stage.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Booking Request

private struct JJBookingRequest: Codable, Identifiable {
   var id = UUID()
   var lessonType: String
   var date: Date
   var notes: String
   var status: String
    var createdAt = Date()
}

@MainActor
private final class JJBookingStore: ObservableObject {
    @Published private(set) var requests: [JJBookingRequest] = []

    private let storageKey = "jiujitsu.bookingRequests"

    init() {
        load()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return
        }

        requests = (try? JSONDecoder().decode(
            [JJBookingRequest].self,
            from: data
        )) ?? []
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(requests) else {
            return
        }

        UserDefaults.standard.set(data, forKey: storageKey)
    }

    func addRequest(
        lessonType: String,
        date: Date,
        notes: String
    ) {
        let request = JJBookingRequest(
            lessonType: lessonType,
            date: date,
            notes: notes,
            status: "Pending"
        )

        requests.append(request)
        save()
    }

    var nextLesson: JJBookingRequest? {
        requests
                .filter {
                    $0.date >= Date() &&
                    $0.status != "Cancelled"
                }
                .sorted { $0.createdAt > $1.createdAt }
                        .first
    }
}


private struct BookingView: View {
   @Environment(\.dismiss) private var dismiss
    @ObservedObject var bookingStore: JJBookingStore
    @State private var lessonType = "Private Lesson"
   @State private var lessonDate = Calendar.current.date(
       byAdding: .day,
       value: 1,
       to: Date()
   ) ?? Date()

   @State private var notes = ""
   @State private var showingConfirmation = false
   @State private var errorMessage: String?

   private let lessonTypes = [
       "Private Lesson",
       "Technique Review",
       "Sparring Session",
       "Group Training"
   ]

   var body: some View {
       NavigationStack {
           Form {
               Section {
                   VStack(alignment: .leading, spacing: 8) {
                       Text("Book a Lesson")
                           .font(.title2.bold())

                       Text("Choose your preferred session and request a time.")
                           .foregroundStyle(.secondary)
                   }
                   .padding(.vertical, 8)
               }

               Section("Lesson Details") {
                   Picker("Lesson Type", selection: $lessonType) {
                       ForEach(lessonTypes, id: \.self) { type in
                           Text(type).tag(type)
                       }
                   }

                   DatePicker(
                       "Date & Time",
                       selection: $lessonDate,
                       in: Date()...,
                       displayedComponents: [.date, .hourAndMinute]
                   )
               }

               Section("Additional Notes") {
                   TextField(
                       "e.g. Guard passing techniques",
                       text: $notes,
                       axis: .vertical
                   )
                   .lineLimit(3...5)
               }

               Section {
                   Label(
                       "Your request will be saved on this device. The time is not confirmed with a teacher yet.",
                       systemImage: "info.circle"
                   )
                   .font(.footnote)
                   .foregroundStyle(.secondary)
               }
           }
           .scrollContentBackground(.hidden)
           .background(JJStyle.background)
           .navigationTitle("Book Lesson")
           .navigationBarTitleDisplayMode(.inline)
           .toolbar {
               ToolbarItem(placement: .cancellationAction) {
                   Button("Cancel") {
                       dismiss()
                   }
               }

               ToolbarItem(placement: .confirmationAction) {
                   Button("Request") {
                       saveRequest()
                   }
                   .fontWeight(.semibold)
                   .tint(JJStyle.sage)
               }
           }
           .alert("Request Saved", isPresented: $showingConfirmation) {
               Button("OK") {
                   dismiss()
               }
           } message: {
               Text("Your lesson request has been saved on this device.")
           }
           .alert(
               "Unable to Save",
               isPresented: Binding(
                   get: { errorMessage != nil },
                   set: { if !$0 { errorMessage = nil } }
               )
           ) {
               Button("OK", role: .cancel) {}
           } message: {
               Text(errorMessage ?? "Please try again.")
           }
       }
       .preferredColorScheme(.dark)
   }

   private func saveRequest() {bookingStore.addRequest(
    lessonType: lessonType,
    date: lessonDate,
    notes: notes
)

showingConfirmation = true
       }
    
   }

#Preview {
    ContentView()
}

