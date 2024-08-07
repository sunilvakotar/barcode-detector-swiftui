import UIKit
import AVFoundation
import Vision

protocol BarcodeScannerViewControllerDelegate: AnyObject {
    func barcodeScannerViewController(_ viewController: BarcodeScannerViewController, didDetectBarcode barcode: String)
}

class BarcodeScannerViewController: UIViewController {
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var videoOutput: AVCaptureVideoDataOutput!

    weak var delegate: BarcodeScannerViewControllerDelegate?

    var detectedBarcode: String? {
        didSet {
            if let barcode = detectedBarcode {
                delegate?.barcodeScannerViewController(self, didDetectBarcode: barcode)
            }
        }
    }

    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let roiView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.red.cgColor
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupCamera()
        setupUI()
        requestCameraAccess()
    }

    private func setupCamera() {
        session = AVCaptureSession()
        session.beginConfiguration()

        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) else {
            print("No back camera available")
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            } else {
                print("Could not add video input to the session")
            }
        } catch {
            print("Could not create video input: \(error)")
        }

        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        } else {
            print("Could not add video output to the session")
        }

        session.commitConfiguration()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
    }
    
    private func setupUI() {
        view.addSubview(roiView)
        
        NSLayoutConstraint.activate([
            roiView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            roiView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            roiView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            roiView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
        ])
    }

    private func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                self.startSession()
            } else {
                print("Camera access denied")
            }
        }
    }

    private func startSession() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    public func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

}

//extension BarcodeScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//        
//        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
//        let request = VNDetectBarcodesRequest { [weak self] request, error in
//            if let results = request.results as? [VNBarcodeObservation], let firstResult = results.first {
//                self?.detectedBarcode = firstResult.payloadStringValue
//            }
//        }
//        do {
//            let roiRect = roiView.frame
//            let roiBoundingBox = CGRect(
//                x: roiRect.origin.x / view.frame.width,
//                y: roiRect.origin.y / view.frame.height,
//                width: roiRect.size.width / view.frame.width,
//                height: roiRect.size.height / view.frame.height
//            )
//            print("X:", roiRect.origin.x / view.frame.width, "  Y:", roiRect.origin.y / view.frame.width)
//            print("width:", roiRect.size.width / view.frame.width, "  Height:", roiRect.size.height / view.frame.height)
//            request.regionOfInterest = roiBoundingBox
//            try imageRequestHandler.perform([request])
//        } catch {
//            print("Failed to perform barcode detection: \(error)")
//        }
//    }
//}

extension BarcodeScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectBarcodesRequest { [weak self] request, error in
            if let results = request.results as? [VNBarcodeObservation], let firstResult = results.first {
                self?.detectedBarcode = firstResult.payloadStringValue
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        
        do {
            let roiFrame = previewLayer.metadataOutputRectConverted(fromLayerRect: roiView.frame)
            request.regionOfInterest = roiFrame
            
            try handler.perform([request])
        } catch {
            print("Failed to perform barcode detection: \(error)")
        }
    }
}
