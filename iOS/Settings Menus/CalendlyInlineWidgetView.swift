//
//  CalendlyInlineWidgetView.swift
//  TimeDraw
//

import SwiftUI
import WebKit

struct CalendlyInlineWidgetView: View {
    var body: some View {
        CalendlyInlineWebView()
            .navigationTitle("Contact")
            .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CalendlyInlineWebView: UIViewRepresentable {

    private static let html = """
    <!DOCTYPE html>
    <html>
    <head>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <style>
    html, body { margin: 0; padding: 0; height: 100%; }
    .calendly-inline-widget { min-width: 320px; height: 700px; }
    </style>
    </head>
    <body>
    <!-- Calendly inline widget begin -->
    <div class="calendly-inline-widget" data-url="https://calendly.com/michael94ellis/30min?hide_gdpr_banner=1" style="min-width:320px;height:700px;"></div>
    <script type="text/javascript" src="https://assets.calendly.com/assets/external/widget.js" async></script>
    <!-- Calendly inline widget end -->
    </body>
    </html>
    """

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard !context.coordinator.didLoad else { return }
        context.coordinator.didLoad = true
        webView.loadHTMLString(Self.html, baseURL: URL(string: "https://calendly.com"))
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var didLoad = false
    }
}
