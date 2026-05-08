//
//  PrivacyWebView.swift
//  101RoastLog
//
//  Created by Ethit Hu on 19.03.2026.
//

import SwiftUI
import WebKit

struct PrivacyWebView: View {
    let urlString: String
    var onFailure: () -> Void
    var onSuccess: (() -> Void)? = nil
    
    @State private var webView: WKWebView = WKWebView()
    @State private var canGoBack: Bool = false
    @State private var isLoading: Bool = true
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button(action: {
                        webView.goBack()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(canGoBack ? .white : .gray)
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                    }
                    .disabled(!canGoBack)
                    
                    Spacer()
                    
                    Button(action: {
                        webView.reload()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                    }
                }
                .frame(height: 60)
                .background(Color.black)
                
                // WebView
                WebViewRepresentable(
                    webView: webView,
                    urlString: urlString,
                    canGoBack: $canGoBack,
                    isLoading: $isLoading,
                    onFailure: onFailure,
                    onSuccess: onSuccess
                )
            }
            .ignoresSafeArea()
            .statusBar(hidden: true)
            
            // Loading Indicator
            if isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2.0)
                }
            }
        }
        
    }
}

// MARK: - UIViewRepresentable
struct WebViewRepresentable: UIViewRepresentable {
    let webView: WKWebView
    let urlString: String
    @Binding var canGoBack: Bool
    @Binding var isLoading: Bool
    var onFailure: () -> Void
    var onSuccess: (() -> Void)?
    
    func makeUIView(context: Context) -> WKWebView {
        // Configuration
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        // Fix for "Gray Bottom" / Safe Area issues
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.backgroundColor = .black
        webView.isOpaque = false

        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        webView.allowsBackForwardNavigationGestures = true
        
        // Load initial URL
        if let url = URL(string: urlString) {
            print("🌐 WebView: LOADING URL: \(url.absoluteString)")
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Updates handled by coordinator state
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebViewRepresentable
        private var failureCalled = false
        
        init(parent: WebViewRepresentable) {
            self.parent = parent
        }
        
        // MARK: - WKUIDelegate (Handle Popups / window.open)
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // Intercept target="_blank" or window.open
            if navigationAction.targetFrame == nil {
                print("🌐 WebView: Intercepting Popup/New Window -> Loading in same view")
                webView.load(navigationAction.request)
            }
            return nil
        }
        
        // Handle HTTP Response Codes
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if let httpResponse = navigationResponse.response as? HTTPURLResponse {
                print("🌐 WebView: HTTP Status Code: \(httpResponse.statusCode)")
                
                // Only check for failure if we haven't locked in yet (Initial Check)
                if PersistenceManager.shared.savedUrl == nil && !failureCalled {
                    if (400...599).contains(httpResponse.statusCode) {
                        print("🌐 WebView: Initial Load 404/Error. Failing back to native.")
                        failureCalled = true
                        // Устанавливаем флаг, что ContentView был показан
                        PersistenceManager.shared.hasShownContentView = true
                        decisionHandler(.cancel)
                        
                        DispatchQueue.main.async {
                            self.parent.onFailure()
                        }
                        return
                    }
                }
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                 // Open mailto, tel, etc. externally
                 if ["mailto", "tel", "sms"].contains(url.scheme) {
                     if UIApplication.shared.canOpenURL(url) {
                         UIApplication.shared.open(url)
                     }
                     decisionHandler(.cancel)
                     return
                 }
                
                print("🌐 WebView: DECIDE POLICY for URL: \(url.absoluteString)")
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            if let url = webView.url {
                print("🌐 WebView: DID START NAVIGATION: \(url.absoluteString)")
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.canGoBack = webView.canGoBack
            parent.isLoading = false

            // Persist LastUrl only after a real document load (not after AppRouter HEAD check).
            if PersistenceManager.shared.savedUrl == nil {
                if let currentUrl = webView.url?.absoluteString {
                    print("🌐 WebView: FIRST NAVIGATION FINISHED. SAVING LastUrl: \(currentUrl)")
                    PersistenceManager.shared.savedUrl = currentUrl
                    PersistenceManager.shared.hasSuccessfulWebViewLoad = true
                    DispatchQueue.main.async {
                        self.parent.onSuccess?()
                    }
                }
            } else {
                PersistenceManager.shared.hasSuccessfulWebViewLoad = true
                DispatchQueue.main.async {
                    self.parent.onSuccess?()
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            print("🌐 WebView: DID FAIL PROVISIONAL: \(error.localizedDescription)")
            
            // If initial load fails, trigger onFailure (only once)
            if PersistenceManager.shared.savedUrl == nil && !failureCalled {
                failureCalled = true
                
                PersistenceManager.shared.hasShownContentView = true
                DispatchQueue.main.async {
                    self.parent.onFailure()
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            print("🌐 WebView: DID FAIL: \(error.localizedDescription)")
        }
    }
}
