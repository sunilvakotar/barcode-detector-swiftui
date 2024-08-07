import SwiftUI

struct ScannerView: View {
    @Binding var scannedBarcode: String?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            CameraView(scannedBarcode: $scannedBarcode)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
            }
        }
        .onChange(of: scannedBarcode) { newValue in
            if newValue != nil {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
