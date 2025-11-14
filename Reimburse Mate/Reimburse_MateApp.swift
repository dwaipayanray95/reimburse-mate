// ReimburseMate — SwiftUI + SwiftData MVP (iOS 17+)
// Drop this into a new Xcode iOS App project (Interface: SwiftUI, Language: Swift)
// Targets → iOS 17 or later. Enable SwiftData in Signing & Capabilities if prompted.
// Add the following Info.plist keys under the target's Info tab:
//  • NSPhotoLibraryUsageDescription = "Allow access to pick payment screenshots for reimbursement."
//  • NSLocationWhenInUseUsageDescription = "Capture where a payment happened to help with reimbursements."
// Optional (if you later save to Photos):
//  • NSPhotoLibraryAddUsageDescription = "Allow saving receipts to Photo Library."

import SwiftUI
import SwiftData
import PhotosUI
import CoreLocation
import Combine

@main
struct ReimburseMateApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Reimbursement.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [configuration])
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Data Model

enum ClaimStatus: String, Codable, CaseIterable, Identifiable {
    case unclaimed = "Yet to Claim"
    case claimed = "Claimed"
    var id: String { rawValue }
}

@Model
final class Reimbursement {
    @Attribute(.unique) var id: UUID
    var date: Date
    var projectCode: String
    var note: String
    var statusRaw: String
    var latitude: Double?
    var longitude: Double?
    var placeName: String?
    var amount: Double?
    var invoiceImageData: Data? // invoice image
    var paymentImageData: Data? // payment screenshot (was receiptImageData)

    init(id: UUID = UUID(), date: Date = .now, projectCode: String, note: String, status: ClaimStatus = .unclaimed, latitude: Double? = nil, longitude: Double? = nil, placeName: String? = nil, amount: Double? = nil, invoiceImageData: Data? = nil, paymentImageData: Data? = nil) {
        self.id = id
        self.date = date
        self.projectCode = projectCode
        self.note = note
        self.statusRaw = status.rawValue
        self.latitude = latitude
        self.longitude = longitude
        self.placeName = placeName
        self.amount = amount
        self.invoiceImageData = invoiceImageData
        self.paymentImageData = paymentImageData
    }

    var status: ClaimStatus {
        get { ClaimStatus(rawValue: statusRaw) ?? .unclaimed }
        set { statusRaw = newValue.rawValue }
    }

    var coordinateString: String {
        if let lat = latitude, let lon = longitude { return String(format: "%.5f, %.5f", lat, lon) }
        return "—"
    }

    func thumbnailImage(maxDimension: CGFloat = 600) -> UIImage? {
        // Prefer payment image for the row thumbnail, else fall back to invoice image
        let dataChoice = paymentImageData ?? invoiceImageData
        guard let data = dataChoice, let image = UIImage(data: data) else { return nil }
        let size = image.size
        let scale = min(maxDimension/size.width, maxDimension/size.height, 1)
        let newSize = CGSize(width: size.width*scale, height: size.height*scale)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized
    }

    func csvRow(delimiter: String = ",") -> String {
        func esc(_ s: String) -> String {
            let needsQuotes = s.contains(delimiter) || s.contains("\n") || s.contains("\"")
            let escaped = s.replacingOccurrences(of: "\"", with: "\"\"")
            return needsQuotes ? "\"\(escaped)\"" : escaped
        }
        let dateStr = ISO8601DateFormatter().string(from: date)
        let fields = [id.uuidString, dateStr, projectCode, note, status.rawValue, placeName ?? "", coordinateString, amount != nil ? String(format: "%.2f", amount!) : ""]
        return fields.map(esc).joined(separator: delimiter)
    }
}

// MARK: - Root & Tabs

struct RootView: View {
    var body: some View {
        TabView {
            AddEntryView()
                .tabItem { Label("Log", systemImage: "plus.square.on.square") }
            ListView()
                .tabItem { Label("All", systemImage: "list.bullet.rectangle") }
        }
    }
}

// MARK: - Add / Edit Entry

struct AddEntryView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var location = LocationHelper()

    @State private var date: Date = .now
    @State private var projectCode: String = ""
    @State private var note: String = ""

    @State private var invoicePhotoItem: PhotosPickerItem? = nil
    @State private var invoiceImage: UIImage? = nil
    @State private var paymentPhotoItem: PhotosPickerItem? = nil
    @State private var paymentImage: UIImage? = nil
    @State private var amountString: String = ""
    @State private var isSaving = false
    @State private var showSavedToast = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Invoice Image") {
                    PhotosPicker(selection: $invoicePhotoItem, matching: .images) {
                        HStack {
                            Image(systemName: "doc.text.image")
                            Text(invoiceImage == nil ? "Pick invoice image" : "Change invoice image")
                        }
                    }
                    .onChange(of: invoicePhotoItem) { old, newItem in
                        Task { invoiceImage = try await newItem?.loadUIImageDownscaled() }
                    }

                    if let img = invoiceImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(alignment: .bottomTrailing) {
                                Text("Tap above to change")
                                    .font(.caption2)
                                    .padding(6)
                                    .background(.thinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .padding(6)
                            }
                    }
                }

                Section("Payment Screenshot") {
                    PhotosPicker(selection: $paymentPhotoItem, matching: .images) {
                        HStack {
                            Image(systemName: "photo")
                            Text(paymentImage == nil ? "Pick payment screenshot" : "Change payment screenshot")
                        }
                    }
                    .onChange(of: paymentPhotoItem) { old, newItem in
                        Task { paymentImage = try await newItem?.loadUIImageDownscaled() }
                    }

                    if let img = paymentImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(alignment: .bottomTrailing) {
                                Text("Tap above to change")
                                    .font(.caption2)
                                    .padding(6)
                                    .background(.thinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .padding(6)
                            }
                    }
                }

                Section("Details") {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    TextField("Project code (e.g. ACC-2025-07)", text: $projectCode)
                        .textInputAutocapitalization(.characters)
                    TextField("Expense description", text: $note, axis: .vertical)
                    TextField("Amount (₹)", text: $amountString)
                        .keyboardType(.decimalPad)
                }

                Section("Location") {
                    if let placename = location.placemarkString, !placename.isEmpty {
                        Label(placename, systemImage: "mappin.and.ellipse")
                        if let c = location.coordinate {
                            Text("\(c.latitude), \(c.longitude)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("No location captured yet").foregroundStyle(.secondary)
                    }
                    Button {
                        location.requestOneShot()
                    } label: {
                        Label("Use current location", systemImage: "location.fill")
                    }
                }

                Section {
                    Button(action: save) {
                        if isSaving { ProgressView() } else { Label("Save Entry", systemImage: "tray.and.arrow.down.fill") }
                    }
                    .disabled(projectCode.trimmingCharacters(in: .whitespaces).isEmpty || invoiceImage == nil || paymentImage == nil || amountString.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("Log Reimbursement")
            .overlay(alignment: .top) {
                if showSavedToast {
                    ToastView(text: "Saved")
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }

    private func save() {
        isSaving = true
        defer { isSaving = false }
        let invoiceCompressed = invoiceImage?.jpegData(compressionQuality: 0.7)
        let paymentCompressed = paymentImage?.jpegData(compressionQuality: 0.7)
        let amount = Double(amountString.replacingOccurrences(of: ",", with: ""))
        let model = Reimbursement(
            date: date,
            projectCode: projectCode.trimmingCharacters(in: .whitespaces),
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            status: .unclaimed,
            latitude: location.coordinate?.latitude,
            longitude: location.coordinate?.longitude,
            placeName: location.placemarkString,
            amount: amount,
            invoiceImageData: invoiceCompressed,
            paymentImageData: paymentCompressed
        )
        context.insert(model)
        try? context.save()
        withAnimation { showSavedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now()+1.2) { withAnimation { showSavedToast = false } }
        // Reset form (keep project code for faster batch entry)
        note = ""
        amountString = ""
        invoiceImage = nil
        paymentImage = nil
        invoicePhotoItem = nil
        paymentPhotoItem = nil
    }
}

// MARK: - List & Detail

struct ListView: View {
    @Environment(\.modelContext) private var context
    @State private var filter: ClaimStatus? = nil
    @State private var queryText: String = ""

    var predicate: Predicate<Reimbursement>? {
        // Only use a SwiftData predicate for status (Predicates don't allow .lowercased())
        if let f = filter {
            return #Predicate<Reimbursement> { $0.statusRaw == f.rawValue }
        }
        // No predicate when doing text search; we'll filter in memory in filtered(_:)
        return nil
    }

    @Query(sort: [SortDescriptor(\Reimbursement.date, order: .reverse)], animation: .snappy)
    private var all: [Reimbursement]

    var body: some View {
        NavigationStack {
            let items = filtered(all)
            List {
                ForEach(items, id: \.id) { r in
                    NavigationLink(value: r) {
                        RowView(r: r)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet { context.delete(items[index]) }
                    try? context.save()
                }
            }
            .navigationTitle("Reimbursements")
            .navigationDestination(for: Reimbursement.self) { r in DetailView(r: r) }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("All") { filter = nil }
                        Divider()
                        ForEach(ClaimStatus.allCases) { s in
                            Button(s.rawValue) { filter = s }
                        }
                    } label: {
                        Label(filter == nil ? "All" : filter!.rawValue, systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ExportView(items: items)) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .searchable(text: $queryText)
            .overlay {
                if items.isEmpty { ContentUnavailableView("No reimbursements", systemImage: "doc.text.magnifyingglass", description: Text("Log some on the first tab.")) }
            }
        }
    }

    private func filtered(_ src: [Reimbursement]) -> [Reimbursement] {
        if let predicate {
            // evaluate(_:) can throw; treat failures as false
            return src.filter { (try? predicate.evaluate($0)) == true }
        }
        // Text search happens in-memory (case-insensitive)
        if queryText.isEmpty { return src }
        return src.filter {
            $0.projectCode.localizedCaseInsensitiveContains(queryText)
            || $0.note.localizedCaseInsensitiveContains(queryText)
            || ($0.placeName ?? "").localizedCaseInsensitiveContains(queryText)
        }
    }
}

struct RowView: View {
    let r: Reimbursement
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let img = r.thumbnailImage(maxDimension: 80) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.quaternary)
                    .frame(width: 56, height: 56)
                    .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(r.projectCode).bold()
                    Spacer()
                    Text(r.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(r.note).lineLimit(2)
                HStack(spacing: 8) {
                    if let amt = r.amount {
                        Text(amt, format: .currency(code: "INR"))
                            .font(.caption)
                            .bold()
                    }
                    Label(r.placeName ?? "No place", systemImage: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Tag(r.status == .claimed ? "Claimed" : "Yet to Claim", tint: r.status == .claimed ? .green : .orange)
                }
            }
        }
    }
}

struct DetailView: View {
    @Environment(\.modelContext) private var context
    @State var r: Reimbursement

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let img = r.thumbnailImage(maxDimension: 1200) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                GroupBox("Details") {
                    Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 12, verticalSpacing: 8) {
                        GridRow { Text("Date").foregroundStyle(.secondary); Text(r.date.formatted(date: .abbreviated, time: .shortened)) }
                        GridRow { Text("Project").foregroundStyle(.secondary); Text(r.projectCode) }
                        if let amt = r.amount { GridRow { Text("Amount").foregroundStyle(.secondary); Text(amt, format: .currency(code: "INR")) } }
                        GridRow { Text("Status").foregroundStyle(.secondary); Tag(r.status == .claimed ? "Claimed" : "Yet to Claim", tint: r.status == .claimed ? .green : .orange) }
                        if let p = r.placeName { GridRow { Text("Place").foregroundStyle(.secondary); Text(p) } }
                        if r.latitude != nil && r.longitude != nil { GridRow { Text("Coords").foregroundStyle(.secondary); Text(r.coordinateString) } }
                    }
                }
                GroupBox("Description") {
                    Text(r.note)
                    HStack {
                        Button { UIPasteboard.general.string = r.note } label: { Label("Copy text", systemImage: "doc.on.doc") }
                        Spacer()
                        Button { toggleStatus() } label: { Label(r.status == .claimed ? "Mark Unclaimed" : "Mark Claimed", systemImage: "checkmark.seal") }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Entry")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: r.shareText()) { Image(systemName: "square.and.arrow.up") }
            }
        }
    }

    private func toggleStatus() { r.status = (r.status == .claimed ? .unclaimed : .claimed); try? context.save() }
}

// MARK: - Export

struct ExportView: View {
    let items: [Reimbursement]
    @State private var csvURL: URL? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("Export all visible items to CSV for easy filing.\nOpen in Numbers/Excel or attach to email.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top)
            Button(action: makeCSV) {
                Label("Generate CSV", systemImage: "doc.text")
            }
            if let url = csvURL {
                ShareLink("Share CSV", item: url)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Export")
    }

    private func makeCSV() {
        let header = ["id","date","projectCode","note","status","placeName","coordinate","amount"].joined(separator: ",")
        let rows = items.map { $0.csvRow() }
        let csv = ([header] + rows).joined(separator: "\n")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("reimbursements.csv")
        try? csv.data(using: .utf8)?.write(to: url)
        csvURL = url
    }
}


// MARK: - Utilities & UI bits

final class LocationHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var placemarkString: String?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestOneShot() {
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .denied, .restricted: return
        default: manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways { manager.requestLocation() }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        coordinate = loc.coordinate
        Task { [weak self] in
            let geocoder = CLGeocoder()
            if let placemark = try? await geocoder.reverseGeocodeLocation(loc).first {
                self?.placemarkString = [placemark.name, placemark.locality, placemark.country].compactMap { $0 }.joined(separator: ", ")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}

extension PhotosPickerItem {
    func loadUIImageDownscaled(maxSide: CGFloat = 2000) async throws -> UIImage? {
        guard let data = try await self.loadTransferable(type: Data.self), let image = UIImage(data: data) else { return nil }
        let size = image.size
        let scale = min(maxSide/size.width, maxSide/size.height, 1)
        let newSize = CGSize(width: size.width*scale, height: size.height*scale)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized
    }
}


extension Reimbursement {
    func shareText() -> String {
        var lines: [String] = []
        lines.append("Project: \(projectCode)")
        lines.append("Date: \(date.formatted(date: .abbreviated, time: .shortened))")
        lines.append("Status: \(status.rawValue)")
        if let amt = amount {
            let f = NumberFormatter()
            f.numberStyle = .currency
            f.currencyCode = "INR"
            let s = f.string(from: NSNumber(value: amt)) ?? String(format: "₹%.2f", amt)
            lines.append("Amount: \(s)")
        }
        if let p = placeName { lines.append("Place: \(p)") }
        if let lat = latitude, let lon = longitude { lines.append(String(format: "Coords: %.5f, %.5f", lat, lon)) }
        lines.append("Description: \n\(note)")
        return lines.joined(separator: "\n")
    }
}

struct Tag: View {
    var text: String
    var tint: Color = .blue
    init(_ text: String, tint: Color = .blue) { self.text = text; self.tint = tint }
    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(tint.opacity(0.15))
            .foregroundStyle(tint)
            .clipShape(Capsule())
    }
}

struct ToastView: View {
    var text: String
    var body: some View {
        Text(text)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(radius: 4)
            .padding(.top, 12)
    }
}
