//
//  SCWebBrowserView.m
//  SCWebBrowserView
//
//  Created by ShannonChen on 2017/5/24.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "SCWebBrowserView.h"

#define UIApplicationKeyWindow [UIApplication sharedApplication].keyWindow

/**
 A private category on NSHTTPCookie
 */
@interface NSHTTPCookie (WebView)

/// Convert a NSHTTPCookie object to a NSString object
- (NSString *)sc_javaScriptString;

@end

@implementation NSHTTPCookie (WebView)

/// Convert a NSHTTPCookie object to a NSString object
/// https://stackoverflow.com/a/32845148/7088321
- (NSString *)sc_javaScriptString {
    
    NSString *string = [NSString stringWithFormat:@"%@=%@; domain=%@; path=%@",
                        self.name,
                        self.value,
                        self.domain,
                        self.path ?: @"/"];
    
    if (self.secure) {
        string = [string stringByAppendingString:@"; secure=true"];
    }
    
    return string;
}

@end

////////////////////////////////////////////////////////////////////////

@interface SCWebBrowserView ()
    
@property (nonatomic, readwrite, copy) SCWebBrowserViewConfiguration *configuration;

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

// https://stackoverflow.com/a/27146880/7088321
// https://stackoverflow.com/a/24565513/7088321
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
        _configuration = [[SCWebBrowserViewConfiguration alloc] init];
        
        [self commonInit];
    }
    return self;
}
#pragma clang diagnostic pop

- (instancetype)initWithFrame:(CGRect)frame {
    
    SCWebBrowserViewConfiguration *configuration = [[SCWebBrowserViewConfiguration alloc] init];
    
    return [self initWithFrame:frame configuration:configuration];
}


- (instancetype)initWithFrame:(CGRect)frame configuration:(nonnull SCWebBrowserViewConfiguration *)configuration {
    if (self = [super initWithFrame:frame]) {
        _configuration = configuration.copy;
        
        [self commonInit];
    }
    return self;
}



- (void)commonInit {
    
    _allowsOpenExternalAppURL = YES;
    
    if (NSClassFromString(@"WKWebView") &&
        _configuration.webViewType == SCWebBrowserViewTypeWKWebView) {
        
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:[self cookieJavaScriptString] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [userContentController addUserScript:cookieScript];
        
        if (_configuration.scalesPageToFit) {
            NSString *scalesPageToFitScriptString = @"\
            var meta = document.createElement('meta');\
            meta.setAttribute('name', 'viewport');\
            meta.setAttribute('content', 'width=device-width'); \
            document.getElementsByTagName('head')[0].appendChild(meta);";
            WKUserScript *scalesPageToFitScript = [[WKUserScript alloc] initWithSource:scalesPageToFitScriptString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
            [userContentController addUserScript:scalesPageToFitScript];
        }
        
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = userContentController;
        configuration.allowsInlineMediaPlayback = _configuration.allowsInlineMediaPlayback;
        // TODO: iOS 10+ use `mediaTypesRequiringUserActionForPlayback` instead
        configuration.mediaPlaybackRequiresUserAction = _configuration.mediaPlaybackRequiresUserAction;
        
        _wkWebView = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];
        _wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _wkWebView.UIDelegate = self;
        _wkWebView.navigationDelegate = self;
        
        [self addSubview:_wkWebView];
        
        [_wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:nil];
        [_wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(title)) options:NSKeyValueObservingOptionNew context:nil];
        
        
    } else {
        _uiWebView = [[UIWebView alloc] initWithFrame:self.bounds];
        _uiWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _uiWebView.delegate = self;
        _uiWebView.mediaPlaybackRequiresUserAction = _configuration.mediaPlaybackRequiresUserAction;
        _uiWebView.allowsInlineMediaPlayback = _configuration.allowsInlineMediaPlayback;
        _uiWebView.scalesPageToFit = _configuration.scalesPageToFit;
        
        [self addSubview:_uiWebView];
        
        [_uiWebView.scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionNew context:nil];
        
    }
}


#pragma mark - Public methods
- (void)loadURLString:(NSString *)URLString {
    if ([URLString isKindOfClass:[NSString class]] == NO) return;
    
    // https://stackoverflow.com/a/7920424/7088321
    NSString *decodedURLString = [URLString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    decodedURLString = [decodedURLString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self loadURL:[NSURL URLWithString:decodedURLString]];
}

- (void)loadURL:(NSURL *)URL {
    [self loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)loadRequest:(NSURLRequest *)request {
    
    if (self.wkWebView) {
        
        // Workaround: Can I set the cookies to be used by a WKWebView?
        // http://stackoverflow.com/a/32845148/7088321
        NSMutableURLRequest *modifiedRequest = [self cookieSettedRquestWithOriginalRequest:request];
        [self.wkWebView loadRequest:modifiedRequest];
        
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


- (void)evaluateSetCookieScriptWithCompletionHandler:(void (^)())completionHandler {
    if (self.wkWebView) {
        
        [self evaluateJavaScript:[self cookieJavaScriptString] completionHandler:completionHandler];
    }
}

- (NSString *)cookieJavaScriptString {
    
    NSMutableString *cookieScript = [NSMutableString string];
    
    // Get all cookie names
    [cookieScript appendString:@"\
     var cookieNames = document.cookie.split('; ').map(\
         function(cookie) {\
             return cookie.split('=')[0];\
         }\
     );\n"];
    
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        // Skip cookies that will break our script
        if ([cookie.value rangeOfString:@"'"].location != NSNotFound) {
            continue;
        }
        
        // Skip unnecessary cookies
        if (self.cookieFilter(cookie) == NO) {
            continue;
        }
        
        // Create a line that appends this cookie to the web view's document's cookies
        [cookieScript appendFormat:@"\
         if (cookieNames.indexOf('%@') == -1) {\
             document.cookie = '%@';\
         };\n",
         cookie.name, cookie.sc_javaScriptString];
    }
    
    return cookieScript;
}

- (NSMutableURLRequest *)cookieSettedRquestWithOriginalRequest:(NSURLRequest *)request {
    
    // 1.Retrieve cookies from shared storage
    NSMutableArray *setCookieScriptArray = [NSMutableArray array];
    for (NSHTTPCookie *aCookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
        
        if (self.cookieFilter(aCookie) == NO) {
            continue;
        }
        
        NSString *singleSetCookieScript = [NSString stringWithFormat:@"%@=%@", aCookie.name, aCookie.value];
        [setCookieScriptArray addObject:singleSetCookieScript];
    }
    NSString *headerCookieValue = [setCookieScriptArray componentsJoinedByString:@";"];
    
    // 2.Set cookie in request header
    NSMutableURLRequest *modifiedRequest = [request mutableCopy];
    [modifiedRequest setValue:headerCookieValue forHTTPHeaderField:@"Cookie"];
    
    return modifiedRequest;
}

#pragma mark - Setter
- (void)setAllowsBackForwardNavigationGestures:(BOOL)allowsBackForwardNavigationGestures {
    
    if (self.wkWebView) {
        self.wkWebView.allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures;
    }
}
    

#pragma mark - Getter

- (BOOL)allowsBackForwardNavigationGestures {
    if (self.wkWebView) {
        return self.wkWebView.allowsBackForwardNavigationGestures;
    } else {
        return NO;
    }
}

- (SCWebBrowserViewConfiguration *)configuration {
    return _configuration.copy;
}

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
            
            [self didUpdateProgress:self.wkWebView.estimatedProgress];
        }
        
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(title))]) {
            [self didUpdateTitle:self.wkWebView.title];
        }
        
    }
}

#pragma mark - Progress
// TODO: Progress for UIWebView


#pragma mark - <UIWebViewDelegate>

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(webView == self.uiWebView) {
        
        BOOL shouldLoad = [self shouldStartLoadWithRequest:request];
        
        if (shouldLoad) {
            
            if(![self externalAppRequiredToOpenURL:request.URL]) {
                
                self.estimatedProgress = 0;
                return YES;
                
            } else {
                
                [self launchExternalAppWithURL:request.URL];
                return NO;
            }
        } else {
            return NO;
        }
        
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    if(webView == self.uiWebView) {
        [self didStartLoad];
    }

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    if(webView == self.uiWebView) {
        [self didFinishLoad];
        
        self.estimatedProgress = 1.0;
        
        // https://stackoverflow.com/questions/2275876/how-to-get-the-title-of-a-html-page-displayed-in-uiwebview
        self.title = [self.uiWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
        
        [self didUpdateTitle:self.title];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    self.estimatedProgress = 1.0;
    self.title = nil;
    
    // How do I fix NSURLErrorDomain error -999 in iPhone 3.0 OS
    // https://stackoverflow.com/a/1053411/7088321
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    
    if(webView == self.uiWebView) {
        [self didFailLoadWithError:error];
        
    }
}


#pragma mark - <WKNavigationDelegate>


// Decides whether to allow or cancel a navigation.
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if(webView != self.wkWebView && decisionHandler) decisionHandler(WKNavigationActionPolicyAllow);
    
    
    BOOL shouldLoad = [self shouldStartLoadWithRequest:navigationAction.request];
    
    
    if (shouldLoad) {
        NSURL *URL = navigationAction.request.URL;
        if([self externalAppRequiredToOpenURL:URL] == NO) {
            
            // TODO: What action would invoke a new window navigation??
            // https://github.com/dfmuir/KINWebBrowser
            // https://stackoverflow.com/questions/25713069/why-is-wkwebview-not-opening-links-with-target-blank
            if(navigationAction.targetFrame == nil) {
                
                [self loadURL:URL];
                
                if (decisionHandler) decisionHandler(WKNavigationActionPolicyCancel);
                
            } else {
                
                if (decisionHandler) decisionHandler(WKNavigationActionPolicyAllow);
            }
            
        } else {
            [self launchExternalAppWithURL:URL];
            if (decisionHandler) decisionHandler(WKNavigationActionPolicyCancel);
        }
    } else {
        if (decisionHandler) decisionHandler(WKNavigationActionPolicyCancel);
    }
}


// Called when web content begins to load in a web view.
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    if(webView == self.wkWebView) {
        [self didStartLoad];
    }
}


// Called when the navigation is complete.
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    // WKWebView didn't finish loading, when didFinishNavigation is called - Bug in WKWebView?
    // https://stackoverflow.com/questions/30291534/wkwebview-didnt-finish-loading-when-didfinishnavigation-is-called-bug-in-wkw?rq=1
    
    if(webView == self.wkWebView) {
        [self didFinishLoad];
    }
}

// Called when an error occurs during navigation.
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    
    if(webView == self.wkWebView) {
        [self didFailLoadWithError:error];
    }
    
}

// Called when an error occurs while the web view is loading content
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    
    if(webView == self.wkWebView) {
        [self didFailLoadWithError:error];
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


#pragma mark - Methods for subclasses
// 拦截器的功能可以由子类通过继承实现，也可以由其它对象实现,两种做法可以共存
// https://github.com/casatwy/RTNetworking/blob/master/CTNetworking/CTNetworking/Components/BaseAPIManager/CTAPIBaseManager.m#L258

- (BOOL)shouldStartLoadWithRequest:(NSURLRequest *)request {
    BOOL shouldLoad = YES;
    
    if ((id)self != self.delegate && [self.delegate respondsToSelector:@selector(webBrowserView:shouldStartLoadWithRequest:)]) {
        shouldLoad = [self.delegate webBrowserView:self shouldStartLoadWithRequest:request];
    }
    
    return shouldLoad;
}

- (void)didStartLoad {
    
    if ((id)self != self.delegate && [self.delegate respondsToSelector:@selector(webBrowserViewDidStartLoad:)]) {
        [self.delegate webBrowserViewDidStartLoad:self];
    }
}

- (void)didFinishLoad {
    if ((id)self != self.delegate && [self.delegate respondsToSelector:@selector(webBrowserViewDidFinishLoad:)]) {
        [self.delegate webBrowserViewDidFinishLoad:self];
    }
}

- (void)didFailLoadWithError:(NSError *)error {
    if ((id)self != self.delegate && [self.delegate respondsToSelector:@selector(webBrowserView:didFailLoadWithError:)]) {
        [self.delegate webBrowserView:self didFailLoadWithError:error];
    }
}

- (void)didUpdateTitle:(NSString *)title {
    if ((id)self != self.delegate && [self.delegate respondsToSelector:@selector(webBrowserView:didUpdateTitle:)]) {
        [self.delegate webBrowserView:self didUpdateTitle:self.title];
    }
}

- (void)didUpdateProgress:(double)progress {
    if ((id)self != self.delegate && [self.delegate respondsToSelector:@selector(webBrowserView:didUpdateProgress:)]) {
        [self.delegate webBrowserView:self didUpdateProgress:self.wkWebView.estimatedProgress];
    }
}

#pragma mark - External App Support

- (BOOL)externalAppRequiredToOpenURL:(NSURL *)URL {
    if (self.allowsOpenExternalAppURL == NO) return NO;
    if ([[UIApplication sharedApplication] canOpenURL:URL] == NO) return NO;
    
    NSArray *validSchemes = @[@"http", @"https"];
    
    BOOL shouldOpen = ![validSchemes containsObject:URL.scheme];
    
    return shouldOpen;
}

- (void)launchExternalAppWithURL:(NSURL *)URL {
    
    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] openURL:URL];
#pragma clang diagnostic pop
        
        // TODO: This method is only available on iOS 10 and later
        /*
         [[UIApplication sharedApplication] openURL:urlToOpen options:@{} completionHandler:^(BOOL success) {
         NSLog(@"%@", success ? @"Open URL successfully" : @"Open URL failed");
         }];
         */
        
    }
    
}


@end

////////////////////////////////////////////////////////////////////////////////////

@implementation SCWebBrowserViewConfiguration

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _webViewType = SCWebBrowserViewTypeDefault;
        
        _mediaPlaybackRequiresUserAction = YES;
        _allowsInlineMediaPlayback = NO;
        _scalesPageToFit = NO;
    }
    return self;
}
    
- (id)copyWithZone:(NSZone *)zone {
    
    SCWebBrowserViewConfiguration *configuration = [[self.class allocWithZone:zone] init];
    configuration->_webViewType = _webViewType;
    configuration->_mediaPlaybackRequiresUserAction = _mediaPlaybackRequiresUserAction;
    configuration->_allowsInlineMediaPlayback = _allowsInlineMediaPlayback;
    configuration->_scalesPageToFit = _scalesPageToFit;
    
    return configuration;
}

@end
