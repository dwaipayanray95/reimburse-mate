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
import MessageUI
import CoreImage
import CoreImage.CIFilterBuiltins
import AVFoundation
import ImageIO
import UIKit
import Foundation

@main
struct ReimburseMateApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .task {
                try? await Task.sleep(for: .seconds(1.5))
                withAnimation(.easeInOut(duration: 0.35)) { showSplash = false }
            }
        }
        .modelContainer(for: Reimbursement.self)
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
    @Attribute(.externalStorage) var invoiceImageData: Data? // invoice image
    @Attribute(.externalStorage) var paymentImageData: Data? // payment screenshot (was receiptImageData)

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
        guard let data = (paymentImageData ?? invoiceImageData) else { return nil }
        guard let src = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let opts: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: Int(maxDimension),
            kCGImageSourceCreateThumbnailWithTransform: true
        ]
        guard let cg = CGImageSourceCreateThumbnailAtIndex(src, 0, opts as CFDictionary) else { return nil }
        return UIImage(cgImage: cg)
    }

    func invoiceThumbnailImage(maxDimension: CGFloat = 600) -> UIImage? {
        guard let data = invoiceImageData else { return nil }
        guard let src = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let opts: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: Int(maxDimension),
            kCGImageSourceCreateThumbnailWithTransform: true
        ]
        guard let cg = CGImageSourceCreateThumbnailAtIndex(src, 0, opts as CFDictionary) else { return nil }
        return UIImage(cgImage: cg)
    }

    func paymentThumbnailImage(maxDimension: CGFloat = 600) -> UIImage? {
        guard let data = paymentImageData else { return nil }
        guard let src = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let opts: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: Int(maxDimension),
            kCGImageSourceCreateThumbnailWithTransform: true
        ]
        guard let cg = CGImageSourceCreateThumbnailAtIndex(src, 0, opts as CFDictionary) else { return nil }
        return UIImage(cgImage: cg)
    }

    func invoiceDisplayImage(maxDimension: CGFloat = 2400) -> UIImage? {
        let screenMax = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * UIScreen.main.scale
        let target = min(max(1600, screenMax), 2400)
        guard let data = invoiceImageData else { return nil }
        guard let src = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let opts: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: Int(target),
            kCGImageSourceCreateThumbnailWithTransform: true
        ]
        guard let cg = CGImageSourceCreateThumbnailAtIndex(src, 0, opts as CFDictionary) else { return nil }
        return UIImage(cgImage: cg)
    }
    func paymentDisplayImage(maxDimension: CGFloat = 2400) -> UIImage? {
        let screenMax = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * UIScreen.main.scale
        let target = min(max(1600, screenMax), 2400)
        guard let data = paymentImageData else { return nil }
        guard let src = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let opts: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: Int(target),
            kCGImageSourceCreateThumbnailWithTransform: true
        ]
        guard let cg = CGImageSourceCreateThumbnailAtIndex(src, 0, opts as CFDictionary) else { return nil }
        return UIImage(cgImage: cg)
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
    @State private var tab = 0
    var body: some View {
        TabView(selection: $tab) {
            AddEntryView()
                .tabItem { Label("Log", systemImage: "plus.square.on.square") }
                .tag(0)
            Group {
                if tab == 1 { ListView() } else { Color.clear }
            }
            .tabItem { Label("All", systemImage: "list.bullet.rectangle") }
            .tag(1)
        }
    }
}

// MARK: - Splash
struct SplashView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let titleSize = min(max(w * 0.10, 36), 56)      // scales with device width
            let subtitleSize = min(max(w * 0.05, 15), 24)
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 12) {
                    Text("Reimburse Mate")
                        .font(.system(size: titleSize, weight: .heavy, design: .rounded))
                        .kerning(0.5)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 1)

                    Text("an app by @theawesomeray")
                        .font(.system(size: subtitleSize, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 4)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
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
    @State private var showExtras = false
    @State private var showInvoiceCamera = false
    @State private var showPaymentCamera = false
    @State private var showInvoiceSource = false
    @State private var showPaymentSource = false
    @State private var showInvoicePhotoPicker = false
    @State private var showPaymentPhotoPicker = false
    @State private var showCameraAlert = false
    @State private var cameraAlertMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Invoice Image") {
                    Button {
                        showInvoiceSource = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.image")
                            Text(invoiceImage == nil ? "Add invoice image" : "Change invoice image")
                        }
                    }
                    .confirmationDialog("Invoice image", isPresented: $showInvoiceSource, titleVisibility: .visible) {
                        Button("Take Photo") { openInvoiceCamera() }
                        Button("Choose from Photos") { showInvoicePhotoPicker = true }
                        Button("Cancel", role: .cancel) {}
                    }
                    .onChange(of: invoicePhotoItem) { old, newItem in
                        Task { invoiceImage = try await newItem?.loadUIImageDownscaled() }
                    }

                    if let img = invoiceImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 180)
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
                    Button {
                        showPaymentSource = true
                    } label: {
                        HStack {
                            Image(systemName: "photo")
                            Text(paymentImage == nil ? "Add payment image" : "Change payment image")
                        }
                    }
                    .confirmationDialog("Payment image", isPresented: $showPaymentSource, titleVisibility: .visible) {
                        Button("Take Photo") { openPaymentCamera() }
                        Button("Choose from Photos") { showPaymentPhotoPicker = true }
                        Button("Cancel", role: .cancel) {}
                    }
                    .onChange(of: paymentPhotoItem) { old, newItem in
                        Task { paymentImage = try await newItem?.loadUIImageDownscaled() }
                    }

                    if let img = paymentImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 180)
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
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Log Reimbursement")
            .overlay(alignment: .top) {
                if showSavedToast {
                    ToastView(text: "Saved")
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showExtras = true } label: { Image(systemName: "info.circle") }
                        .accessibilityLabel("Extras")
                }
            }
            .sheet(isPresented: $showExtras) {
                ExtrasView()
            }
            .sheet(isPresented: $showInvoiceCamera) {
                CameraPicker { img in
                    invoiceImage = img.downscaled() // default maxSide ~1400
                }
            }
            .sheet(isPresented: $showPaymentCamera) {
                CameraPicker { img in
                    paymentImage = img.downscaled() // default maxSide ~1400
                }
            }
            .photosPicker(isPresented: $showInvoicePhotoPicker, selection: $invoicePhotoItem, matching: .images)
            .photosPicker(isPresented: $showPaymentPhotoPicker, selection: $paymentPhotoItem, matching: .images)
            .alert("Camera issue", isPresented: $showCameraAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(cameraAlertMessage)
            }
            .tint(.blue)
        }
    }

    private func save() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
        isSaving = true
        defer { isSaving = false }
        let invoiceCompressed = invoiceImage?.jpegData(compressionQuality: 0.55)
        let paymentCompressed = paymentImage?.jpegData(compressionQuality: 0.55)
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
        // Reset form — clear everything
        date = .now
        projectCode = ""
        note = ""
        amountString = ""
        invoiceImage = nil
        paymentImage = nil
        invoicePhotoItem = nil
        paymentPhotoItem = nil
    }

    private func openInvoiceCamera() {
        preflightCamera(allow: { showInvoiceCamera = true },
                        fallbackToPhotos: { showInvoicePhotoPicker = true })
    }
    private func openPaymentCamera() {
        preflightCamera(allow: { showPaymentCamera = true },
                        fallbackToPhotos: { showPaymentPhotoPicker = true })
    }
    private func preflightCamera(allow: @escaping () -> Void, fallbackToPhotos: @escaping () -> Void) {
        // 1) Simulator or devices without camera
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            cameraAlertMessage = "Camera not available on this device (simulator?). Opening Photos instead."
            showCameraAlert = true
            fallbackToPhotos()
            return
        }
        // 2) Permission preflight
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            allow()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        allow()
                    } else {
                        cameraAlertMessage = "Camera access was denied. Enable it in Settings › Privacy › Camera. Opening Photos instead."
                        showCameraAlert = true
                        fallbackToPhotos()
                    }
                }
            }
        case .denied, .restricted:
            cameraAlertMessage = "Camera access is not permitted. Enable it in Settings › Privacy › Camera. Opening Photos instead."
            showCameraAlert = true
            fallbackToPhotos()
        @unknown default:
            fallbackToPhotos()
        }
    }
}

// MARK: - List & Detail

struct ListView: View {
    @Environment(\.modelContext) private var context
    @State private var filter: ClaimStatus? = nil
    @State private var queryText: String = ""
    @State private var showingMailComposer = false
    @State private var showingShareSheet = false
    @State private var mailSubject: String = ""
    @State private var mailBody: String = ""
    @State private var mailAttachments: [MailView.MailAttachment] = []
    @State private var shareItems: [Any] = []
    @State private var mailRecipients: [String] = ["accounts@tcustudios.com"]
    @State private var pendingClaimIDs: [UUID] = []

    var predicate: Predicate<Reimbursement>? {
        // Only use a SwiftData predicate for status (Predicates don't allow .lowercased())
        if let f = filter {
            return #Predicate<Reimbursement> { $0.statusRaw == f.rawValue }
        }
        // No predicate when doing text search; we'll filter in memory in filtered(_:)
        return nil
    }

    @Query(sort: [SortDescriptor(\Reimbursement.date, order: .reverse)])
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
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        claimAllUnclaimed()
                    } label: {
                        if isBuildingZip {
                            Label("Preparing…", systemImage: "hourglass")
                        } else {
                            Label("Claim Unclaimed", systemImage: "envelope.badge")
                        }
                    }
                    .disabled(isBuildingZip)
                }
            }
            .searchable(text: $queryText)
            .overlay {
                if items.isEmpty { ContentUnavailableView("No reimbursements", systemImage: "doc.text.magnifyingglass", description: Text("Log some on the first tab.")) }
            }
            .sheet(isPresented: $showingMailComposer) {
                MailView(subject: mailSubject, recipients: mailRecipients, body: mailBody, attachments: mailAttachments) { result in
                    if result == .sent { markPendingAsClaimed() }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ActivityView(activityItems: shareItems) { completed in
                    if completed { markPendingAsClaimed() }
                }
            }
            .overlay {
                if isBuildingZip {
                    ZStack {
                        Color.black.opacity(0.15).ignoresSafeArea()
                        VStack(spacing: 10) {
                            ProgressView()
                            Text("Preparing ZIP…")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(16)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .tint(.blue)
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

    // --- Helper to claim all unclaimed, build zip, and drive mail/share flow
    @State private var isBuildingZip = false
    private func claimAllUnclaimed() {
        let unclaimed = all.filter { $0.status == .unclaimed }
        guard !unclaimed.isEmpty, !isBuildingZip else { return }
        isBuildingZip = true
        pendingClaimIDs = unclaimed.map { $0.id }

        // Build mail subject/body (cheap)
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd HH:mm"
        mailSubject = "Reimbursement claim (\(unclaimed.count)) — \(df.string(from: Date()))"
        mailBody = unclaimed.map { $0.shareText() }.joined(separator: "\n\n———\n\n")

        DispatchQueue.global(qos: .userInitiated).async {
            let start = Date()
            var files: [(name: String, data: Data)] = []
            // CSV
            let header = ["id","date","projectCode","note","status","placeName","coordinate","amount"].joined(separator: ",")
            let rows = unclaimed.map { $0.csvRow() }
            if let csvData = ([header] + rows).joined(separator: "\n").data(using: .utf8) {
                files.append(("reimbursements.csv", csvData))
            }
            // Per-entry text + images
            for r in unclaimed {
                let stamp = r.date.formatted(date: .numeric, time: .shortened).replacingOccurrences(of: "/", with: "-")
                let safeProj = r.projectCode.replacingOccurrences(of: "/", with: "-")
                if let txt = r.shareText().data(using: .utf8) {
                    files.append(("\(safeProj)-\(stamp)-summary.txt", txt))
                }
                if let inv = r.invoiceImageData {
                    files.append(("\(safeProj)-\(stamp)-invoice.jpg", inv))
                }
                if let pay = r.paymentImageData {
                    files.append(("\(safeProj)-\(stamp)-payment.jpg", pay))
                }
            }

            let zipName = "reimbursements.zip"
            let zipData = ZipBuilder.makeZip(named: zipName, files: files)
            let elapsed = Date().timeIntervalSince(start)

            DispatchQueue.main.async {
                defer { isBuildingZip = false }
                guard let zipData else { return }

                let zipURL = FileManager.default.temporaryDirectory.appendingPathComponent(zipName)
                try? zipData.write(to: zipURL, options: .atomic)

                mailAttachments = [MailView.MailAttachment(data: zipData, mimeType: "application/zip", fileName: zipName)]
                shareItems = [zipURL]

                print("[ReimburseMate] claimAllUnclaimed ZIP built in \(elapsed)s — files: \(files.count), bytes: \(zipData.count)")

                if MailView.canSendMail() {
                    showingMailComposer = true
                } else {
                    showingShareSheet = true
                }
            }
        }
    }

    private func markPendingAsClaimed() {
        guard !pendingClaimIDs.isEmpty else { return }
        for id in pendingClaimIDs {
            if let idx = all.firstIndex(where: { $0.id == id }) {
                all[idx].status = .claimed
            }
        }
        try? context.save()
        pendingClaimIDs.removeAll()
    }
}

struct RowView: View {
    let r: Reimbursement
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ThumbView(r: r)
                .frame(width: 56, height: 56)
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
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false
    @State var r: Reimbursement
    @State private var showPreview = false
    @State private var previewUIImage: UIImage? = nil
    @State private var showingEntryMail = false
    @State private var showingEntryShare = false
    @State private var entryMailSubject: String = ""
    @State private var entryMailBody: String = ""
    @State private var entryMailAttachments: [MailView.MailAttachment] = []
    @State private var entryShareItems: [Any] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    if let inv = r.invoiceThumbnailImage(maxDimension: 600) {
                        VStack(spacing: 6) {
                            Image(uiImage: inv)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    previewUIImage = nil
                                    showPreview = true
                                    DispatchQueue.global(qos: .userInitiated).async {
                                        let full = r.invoiceDisplayImage()
                                        DispatchQueue.main.async { self.previewUIImage = full }
                                    }
                                }
                            HStack {
                                Tag("Invoice", tint: .blue)
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    if let pay = r.paymentThumbnailImage(maxDimension: 600) {
                        VStack(spacing: 6) {
                            Image(uiImage: pay)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    previewUIImage = nil
                                    showPreview = true
                                    DispatchQueue.global(qos: .userInitiated).async {
                                        let full = r.paymentDisplayImage()
                                        DispatchQueue.main.async { self.previewUIImage = full }
                                    }
                                }
                            HStack {
                                Tag("Payment", tint: .green)
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
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
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button { shareEntryZip() } label: {
                    if isPreparingEntryZip {
                        Image(systemName: "hourglass")
                    } else {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                .disabled(isPreparingEntryZip)
                Button(role: .destructive) { showDeleteAlert = true } label: { Image(systemName: "trash") }
            }
        }
        .alert("Delete entry?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                context.delete(r)
                try? context.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove this reimbursement.")
        }
        .fullScreenCover(isPresented: $showPreview) {
            if let ui = previewUIImage {
                ImagePreview(uiImage: ui)
            } else {
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView().tint(.white)
                        Button("Close") { showPreview = false }
                            .foregroundStyle(.white)
                            .padding(.top, 4)
                    }
                }
            }
        }
        .sheet(isPresented: $showingEntryMail) {
            MailView(subject: entryMailSubject, recipients: ["accounts@tcustudios.com"], body: entryMailBody, attachments: entryMailAttachments) { _ in }
        }
        .sheet(isPresented: $showingEntryShare) {
            ActivityView(activityItems: entryShareItems)
        }
        .overlay {
            if isPreparingEntryZip {
                ZStack {
                    Color.black.opacity(0.15).ignoresSafeArea()
                    VStack(spacing: 10) {
                        ProgressView()
                        Text("Preparing ZIP…")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private func toggleStatus() { r.status = (r.status == .claimed ? .unclaimed : .claimed); try? context.save() }

    @State private var isPreparingEntryZip = false
    private func shareEntryZip() {
        guard !isPreparingEntryZip else { return }
        isPreparingEntryZip = true

        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd HH:mm"
        entryMailSubject = "Reimbursement claim — \(r.projectCode) — \(df.string(from: r.date))"
        entryMailBody = r.shareText()

        DispatchQueue.global(qos: .userInitiated).async {
            let start = Date()
            var files: [(name: String, data: Data)] = []

            // CSV header + row
            let header = ["id","date","projectCode","note","status","placeName","coordinate","amount"].joined(separator: ",")
            let row = r.csvRow()
            if let csvData = ([header, row]).joined(separator: "\n").data(using: .utf8) {
                files.append(("reimbursement.csv", csvData))
            }

            let stamp = r.date.formatted(date: .numeric, time: .shortened).replacingOccurrences(of: "/", with: "-")
            let safeProj = r.projectCode.replacingOccurrences(of: "/", with: "-")
            if let txt = r.shareText().data(using: .utf8) {
                files.append(("\(safeProj)-\(stamp)-summary.txt", txt))
            }
            if let inv = r.invoiceImageData {
                files.append(("\(safeProj)-\(stamp)-invoice.jpg", inv))
            }
            if let pay = r.paymentImageData {
                files.append(("\(safeProj)-\(stamp)-payment.jpg", pay))
            }

            let zipName = "\(safeProj)-\(stamp).zip"
            let zipData = ZipBuilder.makeZip(named: zipName, files: files)
            let elapsed = Date().timeIntervalSince(start)

            DispatchQueue.main.async {
                defer { isPreparingEntryZip = false }
                guard let zipData else { return }

                let url = FileManager.default.temporaryDirectory.appendingPathComponent(zipName)
                try? zipData.write(to: url, options: .atomic)

                entryMailAttachments = [MailView.MailAttachment(data: zipData, mimeType: "application/zip", fileName: zipName)]
                entryShareItems = [url]

                print("[ReimburseMate] shareEntryZip built in \(elapsed)s — files: \(files.count), bytes: \(zipData.count)")

                if MailView.canSendMail() {
                    showingEntryMail = true
                } else {
                    showingEntryShare = true
                }
            }
        }
    }
}

// MARK: - ThumbCache (for thumbnail caching)
final class ThumbCache {
    static let shared: NSCache<NSString, UIImage> = {
        let c = NSCache<NSString, UIImage>()
        c.countLimit = 500
        return c
    }()
}

// MARK: - Async Thumb (avoid main-thread decode)
struct ThumbView: View {
    let r: Reimbursement
    @State private var thumb: UIImage? = nil
    var body: some View {
        ZStack {
            if let img = thumb {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.quaternary)
                    .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
                    .task { loadThumbIfNeeded() }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    private func loadThumbIfNeeded() {
        guard thumb == nil else { return }
        let key = NSString(string: r.id.uuidString)
        if let cached = ThumbCache.shared.object(forKey: key) {
            self.thumb = cached
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            autoreleasepool {
                let t = r.thumbnailImage(maxDimension: 80)
                if let t { ThumbCache.shared.setObject(t, forKey: key) }
                DispatchQueue.main.async { self.thumb = t }
            }
        }
    }
}

// MARK: - Extras (Changelog / Donate / Source)
extension UIImage {
    /// Downscale large images so the longest side is ~1400 px.
    /// This keeps invoice/payment attachments small while still readable.
    func downscaled(maxSide: CGFloat = 1400) -> UIImage {
        let size = self.size
        let scale = min(maxSide / size.width, maxSide / size.height, 1)
        if scale >= 1 { return self }

        let newSize = CGSize(width: size.width * scale,
                             height: size.height * scale)

        UIGraphicsBeginImageContextWithOptions(newSize, true, 1)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resized ?? self
    }
}
struct ExtrasView: View {
    private let upiID = "9916268695@ptaxis"
    private let upiDeepLink = "upi://pay?pa=9916268695@ptaxis&pn=Ray&cu=INR"
    private let sourceURL = URL(string: "https://github.com/dwaipayanray95/reimburse-mate")!
    @State private var showPrevious = false

    var body: some View {
        NavigationStack {
            List {
                Section("Donate (UPI)") {
                    HStack(alignment: .center, spacing: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            Button {
                                if let url = URL(string: upiDeepLink) { UIApplication.shared.open(url) }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "indianrupeesign.circle")
                                    Text("Pay via UPI").bold()
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)

                            Text("Scan QR to pay via UPI")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 12)
                        QRView(string: upiDeepLink)
                            .frame(maxWidth: 160, maxHeight: 160)
                    }
                }

                Section("Changelog") {
                    VStack(alignment: .leading, spacing: 8) {
                        // Latest version header (v0.54)
                        Text("v0.54")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Further optimise first launch & storage for large image attachments", systemImage: "checkmark.circle")
                            Label("Faster Extras screen open and QR generation", systemImage: "checkmark.circle")
                            Label("Smoother changelog expansion animation", systemImage: "checkmark.circle")
                            Label("Update GitHub source link to @dwaipayanray95 repo", systemImage: "checkmark.circle")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                        // Previous versions as a collapsible group
                        DisclosureGroup(isExpanded: $showPrevious) {
                            VStack(alignment: .leading, spacing: 8) {
                                Group {
                                    Text("v0.53").font(.subheadline).bold()
                                    VStack(alignment: .leading, spacing: 4) {
                                        Label("Faster, more reliable ZIP sharing for single entries", systemImage: "circle")
                                        Label("Improved claim-all export: background ZIP build + progress overlay", systemImage: "circle")
                                        Label("Invoice/Payment tags moved below thumbnails for better readability", systemImage: "circle")
                                    }
                                }
                                Group {
                                    Text("v0.52").font(.subheadline).bold()
                                    VStack(alignment: .leading, spacing: 4) {
                                        Label("Remove version badge from home (stuck display)", systemImage: "circle")
                                        Label("Unify image attach flow: single button with camera or Photos", systemImage: "circle")
                                        Label("Bump Marketing Version to 0.52", systemImage: "circle")
                                    }
                                }
                                Group {
                                    Text("v0.5").font(.subheadline).bold()
                                    VStack(alignment: .leading, spacing: 4) {
                                        Label("Move Extras out of tab bar; open from Log page (info button)", systemImage: "circle")
                                        Label("Donate section simplified: QR only + 'Pay in UPI app' (no raw UPI shown)", systemImage: "circle")
                                        Label("Changelog with dropdown for previous versions", systemImage: "circle")
                                    }
                                }
                                Group {
                                    Text("v0.4").font(.subheadline).bold()
                                    VStack(alignment: .leading, spacing: 4) {
                                        Label("One-tap Claim Unclaimed → build ZIP (CSV + images + summaries) and compose email", systemImage: "circle")
                                        Label("Auto-mark as Claimed after successful send/share", systemImage: "circle")
                                        Label("Remove multi-select email flow; keep only mail icon on logs page", systemImage: "circle")
                                        Label("Export screen: ZIP-only (removed CSV share)", systemImage: "circle")
                                    }
                                }
                                Group {
                                    Text("v0.3").font(.subheadline).bold()
                                    VStack(alignment: .leading, spacing: 4) {
                                        Label("Separate images: Invoice + Payment screenshot", systemImage: "circle")
                                        Label("No status picker on create; default to Unclaimed", systemImage: "circle")
                                        Label("Add Amount (₹) field; show in list/detail/export/share", systemImage: "circle")
                                        Label("Remove Quick Actions; thumbnail prefers payment image", systemImage: "circle")
                                    }
                                }
                                Group {
                                    Text("v0.2").font(.subheadline).bold()
                                    VStack(alignment: .leading, spacing: 4) {
                                        Label("Splash overlay: 'Reimburse Mate — an app by @theawesomeray'", systemImage: "circle")
                                        Label("App icon metadata fixes", systemImage: "circle")
                                        Label("Smaller image previews; keyboard dismissal; clear all fields on save", systemImage: "circle")
                                    }
                                }
                                Group {
                                    Text("v0.1").font(.subheadline).bold()
                                    VStack(alignment: .leading, spacing: 4) {
                                        Label("MVP: Log reimbursements (date, project, note, location, images)", systemImage: "circle")
                                        Label("List + Detail views; basic export", systemImage: "circle")
                                    }
                                }
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.right")
                                    .rotationEffect(.degrees(showPrevious ? 90 : 0))
                                    .animation(.snappy, value: showPrevious)
                                Text("Previous versions")
                                    .font(.subheadline.bold())
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Open Source") {
                    Link(destination: sourceURL) {
                        Label("Source on GitHub", systemImage: "link")
                    }
                }
            }
            .navigationTitle("Extras")
        }
    }
}

// MARK: - Export

struct ExportView: View {
    let items: [Reimbursement]
    @State private var zipURL: URL? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("Export all visible items as a ZIP (CSV + summaries + images).\nOpen in Files or attach to email.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top)
            Button(action: makeZIP) {
                Label("Generate ZIP", systemImage: "archivebox")
            }
            if let url = zipURL {
                ShareLink("Share ZIP", item: url)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Export")
    }

    private func makeZIP() {
        var files: [(name: String, data: Data)] = []
        // CSV
        let header = ["id","date","projectCode","note","status","placeName","coordinate","amount"].joined(separator: ",")
        let rows = items.map { $0.csvRow() }
        if let csvData = ([header] + rows).joined(separator: "\n").data(using: .utf8) {
            files.append(("reimbursements.csv", csvData))
        }
        // Per-entry text + images
        for r in items {
            let stamp = r.date.formatted(date: .numeric, time: .shortened).replacingOccurrences(of: "/", with: "-")
            let safeProj = r.projectCode.replacingOccurrences(of: "/", with: "-")
            if let txt = r.shareText().data(using: .utf8) {
                files.append(("\(safeProj)-\(stamp)-summary.txt", txt))
            }
            if let inv = r.invoiceImageData { files.append(("\(safeProj)-\(stamp)-invoice.jpg", inv)) }
            if let pay = r.paymentImageData { files.append(("\(safeProj)-\(stamp)-payment.jpg", pay)) }
        }
        guard let zipData = ZipBuilder.makeZip(named: "reimbursements.zip", files: files) else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("reimbursements.zip")
        try? zipData.write(to: url)
        zipURL = url
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
    /// Load and aggressively downscale from Photos so the longest side is ~1400 px.
    func loadUIImageDownscaled(maxSide: CGFloat = 1400) async throws -> UIImage? {
        guard let data = try await self.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return nil }
        return image.downscaled(maxSide: maxSide)
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
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1))
            .overlay(
                RoundedRectangle(cornerRadius: 10).stroke(tint.opacity(0.15), lineWidth: 1)
            )
            .foregroundStyle(tint)
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

// MARK: - Version Badge & Utilities
struct VersionBadge: View {
    var body: some View {
        Text("v\(Bundle.main.appVersion)")
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(radius: 1)
    }
}

extension Bundle {
    var appVersion: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0.0"
    }
}

struct QRView: View {
    let string: String
    @State private var image: UIImage? = nil

    var body: some View {
        Group {
            if let ui = image {
                Image(uiImage: ui)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 160, maxHeight: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary)
                    .frame(width: 120, height: 120)
            }
        }
        .task {
            guard image == nil else { return }
            image = generate()
        }
    }

    private func generate() -> UIImage? {
        let data = Data(string.utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: 6, y: 6))
        let context = CIContext()
        if let cg = context.createCGImage(scaled, from: scaled.extent) {
            return UIImage(cgImage: cg)
        }
        return nil
    }
}

// MARK: - Camera Picker (UIKit bridge)
struct CameraPicker: UIViewControllerRepresentable {
    var onImage: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraDevice = .rear
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[.originalImage] as? UIImage {
                parent.onImage(img)
            }
            parent.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Full-screen image preview (zoomable)
struct ImagePreview: View {
    let uiImage: UIImage
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ZoomableImageView(image: uiImage)
                .ignoresSafeArea()
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(radius: 2)
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 12)
                }
                Spacer()
            }
        }
    }
}

struct ZoomableImageView: UIViewRepresentable {
    let image: UIImage
    func makeUIView(context: Context) -> UIScrollView {
        let scroll = UIScrollView()
        scroll.minimumZoomScale = 1.0
        scroll.maximumZoomScale = 5.0
        scroll.backgroundColor = .black
        scroll.delegate = context.coordinator

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(imageView)
        context.coordinator.imageView = imageView

        // Pin imageView to scrollView's bounds
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: scroll.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scroll.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scroll.heightAnchor)
        ])
        return scroll
    }
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        weak var imageView: UIImageView?
        func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }
    }
}

// MARK: - Simple ZIP builder (store-only, no compression)
fileprivate enum ZipBuilder {
    static func makeZip(named: String, files: [(name: String, data: Data)]) -> Data? {
        var out = Data()
        var centralDirectory = Data()
        var offset: UInt32 = 0
        for file in files {
            let nameData = file.name.data(using: .utf8) ?? Data()
            let crc = crc32(file.data)
            // Local file header
            out.append(uint32(0x04034b50))
            out.append(uint16(20)) // version needed
            out.append(uint16(0))  // flags
            out.append(uint16(0))  // method: store
            out.append(uint16(0))  // time
            out.append(uint16(0))  // date
            out.append(uint32(crc))
            out.append(uint32(UInt32(file.data.count))) // comp size
            out.append(uint32(UInt32(file.data.count))) // uncomp size
            out.append(uint16(UInt16(nameData.count)))
            out.append(uint16(0)) // extra len
            out.append(nameData)
            out.append(file.data)

            // Central directory header
            var c = Data()
            c.append(uint32(0x02014b50))
            c.append(uint16(20)) // version made by
            c.append(uint16(20)) // version needed
            c.append(uint16(0))  // flags
            c.append(uint16(0))  // method
            c.append(uint16(0))  // time
            c.append(uint16(0))  // date
            c.append(uint32(crc))
            c.append(uint32(UInt32(file.data.count)))
            c.append(uint32(UInt32(file.data.count)))
            c.append(uint16(UInt16(nameData.count)))
            c.append(uint16(0)) // extra len
            c.append(uint16(0)) // comment len
            c.append(uint16(0)) // disk number start
            c.append(uint16(0)) // internal attrs
            c.append(uint32(0)) // external attrs
            c.append(uint32(offset)) // relative offset of local header
            c.append(nameData)
            centralDirectory.append(c)

            offset = UInt32(out.count)
        }
        let centralStart = UInt32(out.count)
        out.append(centralDirectory)
        let centralSize = UInt32(centralDirectory.count)
        // End of central directory
        out.append(uint32(0x06054b50))
        out.append(uint16(0)) // disk
        out.append(uint16(0)) // start disk
        out.append(uint16(UInt16(files.count)))
        out.append(uint16(UInt16(files.count)))
        out.append(uint32(centralSize))
        out.append(uint32(centralStart))
        out.append(uint16(0)) // comment len
        return out
    }

    private static func uint16(_ v: UInt16) -> Data { withUnsafeBytes(of: v.littleEndian, { Data($0) }) }
    private static func uint32(_ v: UInt32) -> Data { withUnsafeBytes(of: v.littleEndian, { Data($0) }) }

    private static func crc32(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xFFFF_FFFF
        for b in data { crc = (crc >> 8) ^ crcTable[Int((crc ^ UInt32(b)) & 0xFF)] }
        return crc ^ 0xFFFF_FFFF
    }

    // IEEE 802.3 CRC-32 (polynomial 0xEDB88320)
    private static let crcTable: [UInt32] = {
        (0..<256).map { i -> UInt32 in
            var c = UInt32(i)
            for _ in 0..<8 { c = (c & 1) != 0 ? (0xEDB88320 ^ (c >> 1)) : (c >> 1) }
            return c
        }
    }()
}


// MARK: - Mail / Share bridges

struct MailView: UIViewControllerRepresentable {
    struct MailAttachment { let data: Data; let mimeType: String; let fileName: String }
    let subject: String
    let recipients: [String]
    let body: String
    let attachments: [MailAttachment]
    var onResult: ((MFMailComposeResult) -> Void)? = nil

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailView
        init(parent: MailView) { self.parent = parent }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true) { self.parent.onResult?(result) }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    static func canSendMail() -> Bool { MFMailComposeViewController.canSendMail() }
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setSubject(subject)
        vc.setToRecipients(recipients)
        vc.setMessageBody(body, isHTML: false)
        for a in attachments { vc.addAttachmentData(a.data, mimeType: a.mimeType, fileName: a.fileName) }
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    var completion: ((Bool) -> Void)? = nil
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        vc.completionWithItemsHandler = { _, completed, _, _ in completion?(completed) }
        return vc
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

