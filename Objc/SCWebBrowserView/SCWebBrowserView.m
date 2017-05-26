//
//  SCWebBrowserView.m
//  SCWebBrowserView
//
//  Created by ShannonChen on 2017/5/24.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "SCWebBrowserView.h"

#define UIApplicationKeyWindow [UIApplication sharedApplication].keyWindow

// Why do we need a seperate class for WKScriptMessage handling? http://www.jianshu.com/p/6ba2507445e4
// WKWebView causes my view controller to leak https://stackoverflow.com/questions/26383031/wkwebview-causes-my-view-controller-to-leak

@interface SCWKScriptMessageHandler : NSObject <WKScriptMessageHandler>

@property (weak, nonatomic) id <WKScriptMessageHandler> delegate;

- (instancetype)initWithDelegate:(id <WKScriptMessageHandler>)delegate;

@end

@implementation SCWKScriptMessageHandler

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate {
    
    if (self = [super init]) {
        _delegate = delegate;
    }
    
    return self;
}

#pragma mark - <WKScriptMessageHandler>
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([self.delegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end



///////////////////////////////////////////////////////////////////////////////////////////////////////

@interface SCWebBrowserView ()

@end

@implementation SCWebBrowserView

- (void)dealloc {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame configuration:nil];
}


- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    if (self = [super initWithFrame:frame]) {
        
        if (NSClassFromString(@"WKWebView")) {
            
            if (configuration != nil) {
                _wkWebView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
            } else {
                _wkWebView = [[WKWebView alloc] initWithFrame:frame];
            }
            
        } else {
            _uiWebView = [[UIWebView alloc] initWithFrame:frame];
        }
        
    }
    
    return self;
}


#pragma mark - <UIWebViewDelegate>



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([self.delegate respondsToSelector:@selector(webBrowserView:shouldStartLoadWithRequest:)]) {
        return [self.delegate webBrowserView:self shouldStartLoadWithRequest:request];
    }
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}


#pragma mark - <WKNavigationDelegate>


// Called when web content begins to load in a web view.
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

// Called when the web view begins to receive web content.
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}


// Called when the navigation is complete.
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    
    
    // WKWebView didn't finish loading, when didFinishNavigation is called - Bug in WKWebView?
    // https://stackoverflow.com/questions/30291534/wkwebview-didnt-finish-loading-when-didfinishnavigation-is-called-bug-in-wkw?rq=1
}

// Called when an error occurs during navigation.
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    
    [self handleError:error];
    
    
}

// Called when an error occurs while the web view is loading content
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    
    [self handleError:error];
}

// Decides whether to allow or cancel a navigation.
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    
    if ([self.delegate respondsToSelector:@selector(webBrowserView:shouldStartLoadWithRequest:)] &&
        [self.delegate webBrowserView:self shouldStartLoadWithRequest:navigationAction.request] == NO) {
        
        if (decisionHandler) {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
        
    } else {
    
        if (decisionHandler) {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    }
    
}

// Decides whether to allow or cancel a navigation after its response is known.
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    
    if (decisionHandler) {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
    
}

// Called when a web view receives a server redirect.
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
}

// Called when the web view needs to respond to an authentication challenge.
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    
    
    if (completionHandler) {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
    
}

// MARK: ??? Called when the web view’s web content process is terminated
// MARK: iOS (9.0 and later)
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    
    
    // What actions trigger webViewWebContentProcessDidTerminate function  https://stackoverflow.com/questions/39039840/what-actions-trigger-webviewwebcontentprocessdidterminate-function
    // WKWebView goes blank after memory warning  https://stackoverflow.com/questions/27565301/wkwebview-goes-blank-after-memory-warning/41706111#41706111
    
    [self.wkWebView reload];
}



#pragma mark - <WKUIDelegate>

// Creates a new web view.
// The web view returned must be created with the specified configuration. WebKit loads the request in the returned web view.
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    // http://stackoverflow.com/a/26683888/7088321
//    // If the page uses window.open() or target="_blank", open the page in a new view controller.
//    WKWebViewController *wkWebViewController = [[WKWebViewController alloc] init];
//    wkWebViewController.URL = navigationAction.request.URL;
//    wkWebViewController.navigationItem.title = @"New WKWebView";
//    wkWebViewController.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:wkWebViewController animated:YES];
//    
//    return wkWebViewController.webView;
    
    // or
    
     
     if (navigationAction.targetFrame.isMainFrame == nil) {
         [webView loadRequest:navigationAction.request];
     }
     
     return nil;
     
    
    
}


// MARK: iOS (9.0 and later)
// Notifies your app that the DOM window closed successfully
- (void)webViewDidClose:(WKWebView *)webView {
    
    // Close a webview by call `window.close();`
    // Using UIWebView there is no way of achieving this without injecting some JavaScript
    // https://stackoverflow.com/questions/31842899/handling-window-close-in-javascript-through-uiwebview-obj-c/36143847#36143847
    
    
}


// Alert Dialog Box
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // MARK: Must call completion handler
        if (completionHandler) {
            completionHandler();
        }
    }];
    [alertController addAction:okAction];
    [UIApplicationKeyWindow.rootViewController presentViewController:alertController animated:YES completion:NULL];
}


// Confirmation Dialog Box
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // MARK: Must call completion handler
        if (completionHandler) {
            completionHandler(YES);
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // MARK: Must call completion handler
        if (completionHandler) {
            completionHandler(NO);
        }
    }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [UIApplicationKeyWindow.rootViewController presentViewController:alertController animated:YES completion:NULL];
}

// Prompt Dialog Box
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = defaultText;
    }];
    
    __weak typeof(UIAlertController) *weakAlert = alertController;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // MARK: Must call completion handler
        if (completionHandler) {
            if (weakAlert.textFields.count > 0) {
                completionHandler(weakAlert.textFields.firstObject.text);
            }
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // MARK: Must call completion handler
        if (completionHandler) {
            completionHandler(nil);
        }
    }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [UIApplicationKeyWindow.rootViewController presentViewController:alertController animated:YES completion:NULL];
}



#pragma mark - <WKScriptMessageHandler>



#pragma mark - Private Methods
- (void)handleError:(NSError *)error {
    
    
    NSString *failingURL = error.userInfo[NSErrorFailingURLStringKey];
    NSURL *urlToOpen = [NSURL URLWithString:failingURL];
    
    if (urlToOpen && [[UIApplication sharedApplication] canOpenURL:urlToOpen]) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] openURL:urlToOpen];
#pragma clang diagnostic pop
        
        /*
         // MARK: This method is only available on iOS 10 and later
         [[UIApplication sharedApplication] openURL:urlToOpen options:@{} completionHandler:^(BOOL success) {
         NSLog(@"%@", success ? @"Open URL successfully" : @"Open URL failed");
         }];
         */
    }
}


@end
