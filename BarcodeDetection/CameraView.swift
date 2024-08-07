import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var scannedBarcode: String?

    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.delegate = context.coordinator
        //print("makeUIViewController")
        scannedBarcode = nil
        return viewController
    }

    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
        print("updateUIViewController")
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(scannedBarcode: $scannedBarcode)
    }

    class Coordinator: NSObject, BarcodeScannerViewControllerDelegate {
        @Binding var scannedBarcode: String?

        init(scannedBarcode: Binding<String?>) {
            _scannedBarcode = scannedBarcode
        }

        func barcodeScannerViewController(_ viewController: BarcodeScannerViewController, didDetectBarcode barcode: String) {
            scannedBarcode = barcode
            viewController.stopSession()
        }
    }
}
