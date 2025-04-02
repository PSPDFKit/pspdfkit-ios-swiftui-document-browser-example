//
//  Copyright © 2020-2025 PSPDFKit GmbH. All rights reserved.
//
//  The Nutrient Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import SwiftUI
import PSPDFKit
import PSPDFKitUI
import Combine
import os.log

struct PDFDocumentView: View {
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
        // Wrap in a navigation controller to get the default toolbar
        PDFView(document: document.referenceDocument)
            .useParentNavigationBar(true)
            .updateControllerConfiguration { controller in
                // Disable the Document Editor
                controller.navigationItem.setRightBarButtonItems([controller.thumbnailsButtonItem],
                                                                 for: .thumbnails, animated: false)
            }
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PDFDocumentView(document: .constant(PDFDocument()))
    }
}
