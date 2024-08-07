import SwiftUI

struct ContentView: View {
    @State private var scannedBarcode: String?

    var body: some View {
        NavigationView {
            VStack {
                if let barcode = scannedBarcode {
                    Text("Scanned Barcode: \(barcode)")
                        .padding()
                        .background(Color.white)
                        .foregroundColor(Color.black)
                        .cornerRadius(10)
                        .padding()
                }

                NavigationLink(destination: ScannerView(scannedBarcode: $scannedBarcode)) {
                    Text("Start Scanning")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationBarTitle("Barcode Scanner")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
