import SwiftUI
import VisionKit
import UIKit

struct ScanResult {
    var productName: String?
    var storeName: String?
    var purchaseDate: Date?
    var imageData: Data?
}

struct ReceiptScanner: UIViewControllerRepresentable {
    let onScan: (ScanResult?) -> Void

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let onScan: (ScanResult?) -> Void

        init(onScan: @escaping (ScanResult?) -> Void) {
            self.onScan = onScan
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                onScan(nil)
                return
            }

            let image = scan.imageOfPage(at: 0)
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                onScan(nil)
                return
            }

            performOCR(on: image, imageData: imageData)
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            onScan(nil)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            onScan(nil)
        }

        func performOCR(on image: UIImage, imageData: Data) {
            guard let cgImage = image.cgImage else {
                onScan(nil)
                return
            }

            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    DispatchQueue.main.async {
                        self?.onScan(ScanResult(imageData: imageData))
                    }
                    return
                }

                let lines = observations.compactMap { obs -> String? in
                    obs.topCandidates(1).first?.string
                }

                let text = lines.joined(separator: "\n")
                let result = self?.parseReceiptText(text, imageData: imageData)

                DispatchQueue.main.async {
                    self?.onScan(result)
                }
            }

            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US"]

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                try? handler.perform([request])
            }
        }

        func parseReceiptText(_ text: String, imageData: Data) -> ScanResult {
            var result = ScanResult(imageData: imageData)

            // Extract product name (first non-trivial line that looks like an item)
            let lines = text.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
            for line in lines {
                if line.count > 3 && !isDateLine(line) && !isTotalLine(line) && !isStoreLine(line) && !isAddressLine(line) {
                    result.productName = line
                    break
                }
            }

            // Extract store name (usually first line or after common prefixes)
            if let firstLine = lines.first, firstLine.count > 2 {
                result.storeName = firstLine
            }

            // Extract date
            let datePatterns = [
                "\\d{1,2}[/\\-]\\d{1,2}[/\\-]\\d{2,4}",
                "\\d{4}[/\\-]\\d{1,2}[/\\-]\\d{1,2}",
                "\\w+ \\d{1,2},? \\d{4}",
                "\\d{1,2} \\w+ \\d{4}"
            ]

            for line in lines {
                for pattern in datePatterns {
                    if let range = line.range(of: pattern, options: .regularExpression) {
                        let dateStr = String(line[range])
                        if let date = parseDate(dateStr) {
                            result.purchaseDate = date
                            return result
                        }
                    }
                }
            }

            return result
        }

        func isDateLine(_ line: String) -> Bool {
            let datePatterns = ["\\d{1,2}[/\\-]\\d{1,2}[/\\-]\\d{2,4}", "\\w+ \\d{1,2}, \\d{4}"]
            for pattern in datePatterns {
                if line.range(of: pattern, options: .regularExpression) != nil {
                    return true
                }
            }
            return false
        }

        func isTotalLine(_ line: String) -> Bool {
            let lower = line.lowercased()
            return lower.contains("total") || lower.contains("subtotal") || lower.contains("tax") || lower.contains("change")
        }

        func isStoreLine(_ line: String) -> Bool {
            let lower = line.lowercased()
            return lower.contains("www.") || lower.contains(".com") || lower.contains("@") || line.count > 40
        }

        func isAddressLine(_ line: String) -> Bool {
            let patterns = ["\\d+\\s+\\w+\\s+(st|ave|rd|blvd|dr|way|ln)", "\\(\\d{3}\\)", "\\d{5}"]
            for pattern in patterns {
                if line.range(of: pattern, options: .regularExpression) != nil {
                    return true
                }
            }
            return false
        }

        func parseDate(_ string: String) -> Date? {
            let formatters: [DateFormatter] = {
                let formats = ["MM/dd/yyyy", "MM-dd-yyyy", "dd/MM/yyyy", "yyyy-MM-dd", "MMM dd, yyyy", "MMMM dd, yyyy", "dd MMM yyyy"]
                return formats.map { fmt in
                    let f = DateFormatter()
                    f.dateFormat = fmt
                    f.locale = Locale(identifier: "en_US_POSIX")
                    return f
                }
            }()

            for formatter in formatters {
                if let date = formatter.date(from: string) {
                    return date
                }
            }

            // Try flexible parsing
            let cleaned = string.replacingOccurrences(of: ",", with: "")
            for formatter in formatters {
                if let date = formatter.date(from: cleaned) {
                    return date
                }
            }
            return nil
        }
    }
}
