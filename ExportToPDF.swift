import Foundation
import WebKit

class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
		private let outputURL: URL
		
		var onFinished: (@Sendable () -> Void)?
		
		init(outputURL: URL) {
				self.outputURL = outputURL
		}
		
		func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
			Task { @MainActor [outputURL, onFinished] in
				let margins = NSEdgeInsets(
					top: 0,
					left: -40,
					bottom: 0,
					right: -40
				)            
				let pageWidth: CGFloat = 595.22
				let pageHeight: CGFloat = 841.85
				let printableWidth = pageWidth - margins.left - margins.right
				let printableHeight = pageHeight - margins.top - margins.bottom
				let rect = CGRect(
						x: margins.left,
						y: margins.top,
						width: printableWidth,
						height: printableHeight
				)

				webView.frame = rect
				webView.createPDF { result in
						switch result {
						case .success(let data):
								do {
										try FileManager.default.createDirectory(
												at: outputURL.deletingLastPathComponent(),
												withIntermediateDirectories: true,
												attributes: nil
										)
										try data.write(to: outputURL)
										print("Saved PDF to \(outputURL.path)")
								} catch {
										print("Failed to save PDF: \(error)")
								}
						case .failure(let error):
								print("Failed to create PDF: \(error)")
						}
						if let onFinished {
								onFinished()
						}
					}
				}
		}
}

let cvFile = URL(fileURLWithPath: "index.html", isDirectory: false)
let rawHTML = try String(contentsOf: cvFile)
let request = URLRequest(url: cvFile)

let webView = WKWebView(frame: .zero)
let webViewDelegate = WebViewNavigationDelegate(outputURL: URL(fileURLWithPath: "cv.pdf", isDirectory: false))
webView.navigationDelegate = webViewDelegate
webView.load(request)
await withCheckedContinuation { continuation in
	webViewDelegate.onFinished = {
		continuation.resume()
	}
}
