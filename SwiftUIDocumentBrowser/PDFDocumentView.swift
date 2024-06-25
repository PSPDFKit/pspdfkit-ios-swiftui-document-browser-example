//
//  Copyright © 2020-2024 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import SwiftUI
import PSPDFKit
import PSPDFKitUI
import Combine
import os.log

struct PDFDocumentView: View {
    let logger = Logger(subsystem: subsystem, category: "content-view")
    private var cancelSet = Set<AnyCancellable>()

    @Binding var document: PDFDocument

    init(document: Binding<PDFDocument>) {
        _document = document

        // Install a listener to trigger the binding to indicate that we need to save data.
        let referenceDocument = document.wrappedValue.referenceDocument
        referenceDocument.annotationChangePublisher.sink { _ in
            // Set property to mark document as needing a write to disk whenever annotations changes.
            document.wrappedValue.referenceDocument = referenceDocument
        }.store(in: &cancelSet)

        referenceDocument.savePublisher.sink { _ in
            // Set property to mark document as needing a write to disk whenever the document was saved.
            document.wrappedValue.referenceDocument = referenceDocument
        }.store(in: &cancelSet)
    }

    var body: some View {
        logger.info("Preparing ContentView for \(document)")

        // Wrap in a navigation controller to get the default toolbar
        return PDFView(document: document.referenceDocument)
            .useParentNavigationBar(true)
            .updateControllerConfiguration { controller in
                // Disable the Document Editor
                controller.navigationItem.setRightBarButtonItems([controller.thumbnailsButtonItem],
                                                                 for: .thumbnails, animated: false)
            }
            // By default this would be within the safe area, but PSPDFKit already has logic to deal with this
            .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PDFDocumentView(document: .constant(PDFDocument()))
    }
}
