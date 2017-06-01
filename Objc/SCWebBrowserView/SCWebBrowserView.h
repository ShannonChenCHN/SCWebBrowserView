//
//  SCWebBrowserView.h
//  SCWebBrowserView
//
//  Created by ShannonChen on 2017/5/24.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@class SCWebBrowserView;

NS_ASSUME_NONNULL_BEGIN


@protocol SCWebBrowserViewDelegate <NSObject>

@optional

- (void)webBrowserViewDidStartLoad:(SCWebBrowserView *)webBrowserView;
- (void)webBrowserViewDidFinishLoad:(SCWebBrowserView *)webBrowserView;
- (void)webBrowserView:(SCWebBrowserView *)webBrowserView didFailLoadWithError:(NSError *)error;
- (BOOL)webBrowserView:(SCWebBrowserView *)webBrowserView shouldStartLoadWithRequest:(NSURLRequest *)request;

- (void)webBrowserView:(SCWebBrowserView *)webBrowserView didUpdateTitle:(nullable NSString *)title;
- (void)webBrowserView:(SCWebBrowserView *)webBrowserView didUpdateProgress:(double)progress;

@end


/**
 A `UIView` subclass designed to wrapper `UIWebView` and `WKWebView`, using `UIWebView` on the version prior to iOS 8 and `WKWebView` on iOS 8 and later.
 */
@interface SCWebBrowserView : UIView <UIWebViewDelegate, WKUIDelegate, WKNavigationDelegate>



// The actual web views, `WKWebView` would be used on iOS 8 and later, while `UIWebView` would be used on the version prior to iOS 8.
@property (strong, nonatomic, nullable) UIWebView *uiWebView;
@property (strong, nonatomic, nullable) WKWebView *wkWebView;

@property (weak, nonatomic, nullable) IBInspectable id <SCWebBrowserViewDelegate> delegate;

// KVO is not supported for the following 4 properties
// if you need to observe `title`'s changing and `estimatedProgress`'s changing, implement those provided `SCWebBrowserViewDelegate` methods.
@property (copy, nonatomic, readonly, nullable) NSURL *URL;
@property (nullable, nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly) double estimatedProgress;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

@property (strong, nonatomic, readonly) UIScrollView *scrollView;

/// A Boolean value indicating whether horizontal swipe gestures will trigger back-forward list navigations.
/// @discussion The default value is YES.
@property (nonatomic) BOOL allowsBackForwardNavigationGestures;

- (instancetype)initWithFrame:(CGRect)frame configuration:(nullable WKWebViewConfiguration *)configuration;


/// Loads a `NSURLURLRequest` to web view.
- (void)loadRequest:(NSURLRequest *)request;

/// Load a `NSURL` to web view.
- (void)loadURL:(NSURL *)URL;

/// Loads a URL as `NSString` to web view.
- (void)loadURLString:(NSString *)URLString;


/// Loads an string containing HTML to web view.
- (void)loadHTMLString:(NSString *)HTMLString;

/// Reloads the current page in webview.
- (void)reload;

/// Stops loading all resources on the current page.
- (void)stopLoading;



/// Evaluates a JavaScript string. The completion handler always runs on the main thread.
/// @discussion When using `UIWebView`, this method waits synchronously for JavaScript evaluation to complete.
/// When using `WKWebView`, this method valuates a JavaScript string asynchronously.
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id result, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
