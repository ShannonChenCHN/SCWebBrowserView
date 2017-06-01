//
//  SCWebBrowserView.m
//  SCWebBrowserView
//
//  Created by ShannonChen on 2017/5/24.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "SCWebBrowserView.h"

#define UIApplicationKeyWindow [UIApplication sharedApplication].keyWindow

@interface SCWebBrowserView ()

@property (strong, nonatomic) WKWebViewConfiguration *configuration;

@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite) double estimatedProgress;

@end

@implementation SCWebBrowserView

#pragma mark - Lifecycle
- (void)dealloc {
    self.uiWebView.delegate = nil;
    
    self.wkWebView.UIDelegate = nil;
    self.wkWebView.navigationDelegate = nil;
    
    [self.wkWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [self.wkWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(title))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame configuration:nil];
}


- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    if (self = [super initWithFrame:frame]) {
        
        _configuration = configuration;
        
        [self setup];
    }
    
    return self;
}

- (void)setup {
    
    // TODO: How to deal with UIWebView?
    _allowsBackForwardNavigationGestures = YES;
    
    if (NSClassFromString(@"WKWebView")) {
        
        if (_configuration != nil) {
            _wkWebView = [[WKWebView alloc] initWithFrame:self.bounds configuration:_configuration];
        } else {
            _wkWebView = [[WKWebView alloc] initWithFrame:self.bounds];
        }
        
        _wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _wkWebView.UIDelegate = self;
        _wkWebView.navigationDelegate = self;
        _wkWebView.allowsBackForwardNavigationGestures = _allowsBackForwardNavigationGestures;
        
        [_wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:nil];
         [_wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(title)) options:NSKeyValueObservingOptionNew context:nil];
        
        [self addSubview:_wkWebView];
        
    } else {
        _uiWebView = [[UIWebView alloc] initWithFrame:self.bounds];
        _uiWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _uiWebView.delegate = self;
        
        [self addSubview:_uiWebView];
    }
}


#pragma mark - Public methods
- (void)loadURLString:(NSString *)URLString {
    [self loadURL:[NSURL URLWithString:URLString]];
}

- (void)loadURL:(NSURL *)URL {
    [self loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)loadRequest:(NSURLRequest *)request {
    
    if (self.wkWebView) {
        
        [self.wkWebView loadRequest:request];
        
    } else if (self.uiWebView) {
        
        [self.uiWebView loadRequest:request];
    }
}

- (void)loadHTMLString:(NSString *)HTMLString {
    
    if (self.wkWebView) {
        
        [self.wkWebView loadHTMLString:HTMLString baseURL:nil];
        
    } else if (self.uiWebView) {
        
        [self.uiWebView loadHTMLString:HTMLString baseURL:nil];
    }
}

- (void)reload {
    if (self.wkWebView) {
        
        [self.wkWebView reload];
        
    } else if (self.uiWebView) {
        
        [self.uiWebView reload];
    }
}

- (void)stopLoading {
    if (self.wkWebView) {
        
        [self.wkWebView stopLoading];
        
    } else if (self.uiWebView) {
        
        [self.uiWebView stopLoading];
    }
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id result, NSError * _Nullable error))completionHandler {
    
    if (self.wkWebView) {
        
        [self.wkWebView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
        
    } else if (self.uiWebView) {
        
        NSString *result = [self.uiWebView stringByEvaluatingJavaScriptFromString:javaScriptString];
        
        
        // TODO: How to create a proper error object for UIWebView?
        NSError *error = result ? nil : [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:nil];
        
        if (completionHandler) {
            completionHandler(result, error);
        }
    }
    
}


#pragma mark - Getter


- (NSURL *)URL {
    if (self.wkWebView) {
        
        return self.wkWebView.URL;
        
    } else if (self.uiWebView) {
        
        return self.uiWebView.request.URL;
    }
    
    return nil;
}


- (NSString *)title {
    if (self.wkWebView) {
        
        _title = self.wkWebView.title;
        
    }
    
    return _title;
}


// TODO: KVO support needed ???
- (BOOL)isLoading {
    if (self.wkWebView) {
        
        return self.wkWebView.isLoading;
        
    } else if (self.uiWebView) {
        
        return self.uiWebView.isLoading;
        
    }
    
    return NO;
}

- (double)estimatedProgress {
    
    if (self.wkWebView) {
        
        _estimatedProgress = self.wkWebView.estimatedProgress;
    }
    
    return _estimatedProgress;
}

- (UIScrollView *)scrollView {
    if (self.wkWebView) {
        
        return self.wkWebView.scrollView;
        
    } else if (self.uiWebView) {
        
        return self.uiWebView.scrollView;
    }
    
    return nil;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (object == self.wkWebView) {
        
        if([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]) {
        
            if ([self.delegate respondsToSelector:@selector(webBrowserView:didUpdateProgress:)]) {
                [self.delegate webBrowserView:self didUpdateProgress:self.wkWebView.estimatedProgress];
            }
        }
        
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(title))]) {
            if ([self.delegate respondsToSelector:@selector(webBrowserView:didUpdateTitle:)]) {
                [self.delegate webBrowserView:self didUpdateTitle:self.wkWebView.title];
            }
        }
        
    } else {
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Progress
// TODO: Progress for UIWebView


#pragma mark - <UIWebViewDelegate>

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(webView == self.uiWebView) {
    
        if(![self externalAppRequiredToOpenURL:request.URL]) {
            
            BOOL shouldLoad = YES;
            if([self.delegate respondsToSelector:@selector(webBrowserView:shouldStartLoadWithRequest:)]) {
                shouldLoad = [self.delegate webBrowserView:self shouldStartLoadWithRequest:request];
            }
            
            if (shouldLoad) {
                self.estimatedProgress = 0;
            }
            
            return shouldLoad;
        }
        else {
            [self launchExternalAppWithURL:request.URL];
            return NO;
        }
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    if(webView == self.uiWebView) {
        if ([self.delegate respondsToSelector:@selector(webBrowserViewDidStartLoad:)]) {
            [self.delegate webBrowserViewDidStartLoad:self];
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    if(webView == self.uiWebView) {
        if ([self.delegate respondsToSelector:@selector(webBrowserViewDidFinishLoad:)]) {
            [self.delegate webBrowserViewDidFinishLoad:self];
        }
        
        self.estimatedProgress = 1.0;
        
        // https://stackoverflow.com/questions/2275876/how-to-get-the-title-of-a-html-page-displayed-in-uiwebview
        self.title = [self.uiWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
        
        if ([self.delegate respondsToSelector:@selector(webBrowserView:didUpdateTitle:)]) {
            [self.delegate webBrowserView:self didUpdateTitle:self.title];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    if(webView == self.uiWebView) {
        if ([self.delegate respondsToSelector:@selector(webBrowserView:didFailLoadWithError:)]) {
            [self.delegate webBrowserView:self didFailLoadWithError:error];
        }
        
        self.estimatedProgress = 1.0;
    }
}


#pragma mark - <WKNavigationDelegate>


// Called when web content begins to load in a web view.
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    if(webView == self.wkWebView) {
        if ([self.delegate respondsToSelector:@selector(webBrowserViewDidStartLoad:)]) {
            [self.delegate webBrowserViewDidStartLoad:self];
        }
    }
}


// Called when the navigation is complete.
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    // WKWebView didn't finish loading, when didFinishNavigation is called - Bug in WKWebView?
    // https://stackoverflow.com/questions/30291534/wkwebview-didnt-finish-loading-when-didfinishnavigation-is-called-bug-in-wkw?rq=1
    
    if(webView == self.wkWebView) {
        if ([self.delegate respondsToSelector:@selector(webBrowserViewDidFinishLoad:)]) {
            [self.delegate webBrowserViewDidFinishLoad:self];
        }
    }
}

// Called when an error occurs during navigation.
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    if(webView == self.wkWebView) {
        if ([self.delegate respondsToSelector:@selector(webBrowserView:didFailLoadWithError:)]) {
            [self.delegate webBrowserView:self didFailLoadWithError:error];
        }
    }
    
}

// Called when an error occurs while the web view is loading content
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    if(webView == self.wkWebView) {
        if ([self.delegate respondsToSelector:@selector(webBrowserView:didFailLoadWithError:)]) {
            [self.delegate webBrowserView:self didFailLoadWithError:error];
        }
    }
}

// Decides whether to allow or cancel a navigation.
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if(webView != self.wkWebView) decisionHandler(WKNavigationActionPolicyAllow);
    
    NSURL *URL = navigationAction.request.URL;
    if([self externalAppRequiredToOpenURL:URL] == NO) {
        
        BOOL shouldLoad = YES;
        if ([self.delegate respondsToSelector:@selector(webBrowserView:shouldStartLoadWithRequest:)]) {
            shouldLoad = [self.delegate webBrowserView:self shouldStartLoadWithRequest:navigationAction.request];
        }
        
        // TODO: What action would invoke a new window navigation??
        // https://github.com/dfmuir/KINWebBrowser
        // https://stackoverflow.com/questions/25713069/why-is-wkwebview-not-opening-links-with-target-blank
        if(navigationAction.targetFrame == nil) {
            
            if (shouldLoad) [self loadURL:URL];
            
            if (decisionHandler) decisionHandler(WKNavigationActionPolicyCancel);
            
        } else {
            
            if (decisionHandler) decisionHandler(shouldLoad ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
        }
        
    } else {
        [self launchExternalAppWithURL:URL];
        if (decisionHandler) decisionHandler(WKNavigationActionPolicyCancel);
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
     if (navigationAction.targetFrame.isMainFrame == NO) {
         [webView loadRequest:navigationAction.request];
     }
    
     return nil;
    
}


// Alert Dialog Box
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    // TODO: 国际化
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



#pragma mark - External App Support

- (BOOL)externalAppRequiredToOpenURL:(NSURL *)URL {
    NSArray *validSchemes = @[@"http", @"https"];
    return ![validSchemes containsObject:URL.scheme] && [[UIApplication sharedApplication] canOpenURL:URL];
}

- (void)launchExternalAppWithURL:(NSURL *)URL {
    
    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] openURL:URL];
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
