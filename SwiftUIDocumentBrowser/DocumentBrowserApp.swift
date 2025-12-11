//
//  Copyright © 2020-2025 PSPDFKit GmbH. All rights reserved.
//
//  The Nutrient Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import PSPDFKit
import SwiftUI
import os.log

let subsystem = "io.nutrient.swiftuibrowser"

@main
struct DocumentBrowserApp: App {
    let logger = Logger(subsystem: subsystem, category: "app")

    init() {
        // Set your license key here. Nutrient is commercial software.
        // Each Nutrient license is bound to a specific app bundle id.
        // Visit https://my.nutrient.io to get your demo or commercial license key.
        SDK.setLicenseKey("YOUR_LICENSE_KEY_GOES_HERE")
    }

    var body: some Scene {
        DocumentGroup(newDocument: PDFDocument.blankDocument()) { file -> PDFDocumentView in
            if let fileURL = file.fileURL {
                logger.info("Loading \(fileURL.path). isEditable: \(file.isEditable)")
            }
            return PDFDocumentView(document: file.$document)
        }
    }
}
