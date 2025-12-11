//
//  Copyright © 2020-2025 PSPDFKit GmbH. All rights reserved.
//
//  The Nutrient Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import SwiftUI
import UniformTypeIdentifiers
import os.log
import PSPDFKit
import Combine

enum StringError: Error {
    case runtimeError(String)
}

/// Represents a PDF document via the FileDocument protocol.
///
/// Conformance to `FileDocument` is expected to have value semantics and be
/// thread-safe. Serialization and deserialization will be done on a background thread.
struct PDFDocument: FileDocument {
    let logger = Logger(subsystem: subsystem, category: "document")

    /// Access the Nutrient document data model
    var referenceDocument: Document

    static var readableContentTypes: [UTType] { [.pdf, .jpeg, .png] }

    init(data: Data = Data(), contentType: UTType = .pdf) {
        guard let document = PDFDocument.createDocument(data: data, contentType: contentType) else {
            logger.error("Unsupported contentType: \(contentType)")
            referenceDocument = Document()
            return
        }
        referenceDocument = document
    }

    init(configuration: ReadConfiguration) throws {
        guard let fileData = configuration.file.regularFileContents else {
            logger.error("Unable to read file.")
            throw CocoaError(.fileReadCorruptFile)
        }
        guard let document = PDFDocument.createDocument(data: fileData, contentType: configuration.contentType) else {
            logger.error("Unsupported contentType: \(configuration.contentType)")
            throw StringError.runtimeError("Unsupported contentType: \(configuration.contentType)")
        }
        logger.info("Initialized \(document)")
        referenceDocument = document
    }

    /// Create a document subclass based on the content type
    private static func createDocument(data: Data = Data(), contentType: UTType) -> Document? {
        let provider = DataContainerProvider(data: data)
        switch contentType {
        case .pdf:
            return Document(dataProviders: [provider])
        case .jpeg, .png:
            return ImageDocument(imageDataProvider: provider)
        default:
            return nil
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        logger.info("Write document \(self)")
        return .init(regularFileWithContents: referenceDocument.data!)
    }

    /// Generate a blank PDF document
    static func blankDocument() -> PDFDocument {
        let pageRect = CGRect(x: 0.0, y: 0.0, width: 210.0 * 3, height: 297.0 * 3)
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData(actions: { context in
            context.beginPage()
        })
        return PDFDocument(data: data)
    }
}

extension PDFDocument: CustomStringConvertible {
    var description: String {
        return "Document wrapping \(referenceDocument)"
    }
}
