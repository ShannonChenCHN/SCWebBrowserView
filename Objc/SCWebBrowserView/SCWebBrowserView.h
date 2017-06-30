//
//  SCWebBrowserView.h
//  SCWebBrowserView
//
//  Created by ShannonChen on 2017/5/24.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@class SCWebBrowserView, SCWebBrowserViewConfiguration;

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, SCWebBrowserViewType) {
    SCWebBrowserViewTypeDefault = 0,
    SCWebBrowserViewTypeWKWebView = SCWebBrowserViewTypeDefault,
    SCWebBrowserViewTypeUIWebView,
};


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



/// The actual web views, `WKWebView` would be used on iOS 8 and later, while `UIWebView` would be used on the version prior to iOS 8.
@property (strong, nonatomic, nullable) UIWebView *uiWebView;
@property (strong, nonatomic, nullable) WKWebView *wkWebView;

/// A copy of the configuration with which the web view was initialized.
@property (copy, nonatomic, readonly) SCWebBrowserViewConfiguration *configuration;

@property (weak, nonatomic, nullable) IBInspectable id <SCWebBrowserViewDelegate> delegate;

/// KVO is not supported for the following 4 properties
/// if you need to observe `title`'s changing and `estimatedProgress`'s changing, implement those provided `YHWebBrowserViewDelegate` methods.
@property (copy, nonatomic, readonly, nullable) NSURL *URL;
@property (nullable, nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly) double estimatedProgress;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

@property (strong, nonatomic, readonly) UIScrollView *scrollView;

/// A Boolean value indicating whether horizontal swipe gestures will trigger back-forward list navigations.
/// @discussion The default value is `NO`.
/// @note This feature is only supported on `WKWebView`.
@property (nonatomic) BOOL allowsBackForwardNavigationGestures;

/// A Boolean value indicating a external app URL link should be allowed to open.
/// @discussion The default value is YES.
@property (assign, nonatomic) BOOL allowsOpenExternalAppURL;
    

/// Initializes and returns a web browser view object having the given frame and configuration.
/// @note You must specify the web view's type of a web browser view when you create it and you cannot thereafter modify the type. If you initialize the web browser view with the UIView method `initWithFrame:`, the `SCWebBrowserViewTypeDefault` type is used as a default.
- (instancetype)initWithFrame:(CGRect)frame configuration:(nonnull SCWebBrowserViewConfiguration *)configuration NS_DESIGNATED_INITIALIZER;


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

/// Retrieve cookies from shared `NSHTTPCookieStorage` and evaluates a JavaScript string to set cookie for `WKWebView`.
- (void)evaluateSetCookieScriptWithCompletionHandler:(void (^)())completionHandler;



/********** Methods for subclasses ********/

- (void)didStartLoad NS_REQUIRES_SUPER;
- (void)didFinishLoad NS_REQUIRES_SUPER;
- (void)didFailLoadWithError:(NSError *)error NS_REQUIRES_SUPER;
- (BOOL)shouldStartLoadWithRequest:(NSURLRequest *)request NS_REQUIRES_SUPER;

- (void)didUpdateTitle:(nullable NSString *)title NS_REQUIRES_SUPER;
- (void)didUpdateProgress:(double)progress NS_REQUIRES_SUPER;

@end

////////////////////////////////////////////////////////////////////////////////////


/**
 A SCWebBrowserViewConfiguration object is a collection of properties with which to initialize a SCWebBrowserView object.
 */
@interface SCWebBrowserViewConfiguration : NSObject <NSCopying>
    

@property (assign, nonatomic) SCWebBrowserViewType webViewType;

    
/// A Boolean value that determines whether HTML5 videos play inline or use the native full-screen controller.
/// @discussion The default value is NO.
/// @important When adding a video element to a HTML document on the iPhone, you must also include the playsinline attribute. Apps created before iOS 10.0 must use the webkit-playsinline attribute.
@property (nonatomic) BOOL allowsInlineMediaPlayback;

/// A Boolean value that determines whether HTML5 videos can play automatically or require the user to start playing them.
/// @discussion The default value is YES.
/// @important To make media play automatically when loaded, set this property to NO and ensure the <audio> or <video> element you want to play has the autoplay attribute set.
@property (nonatomic) BOOL mediaPlaybackRequiresUserAction;
    
    
/// A Boolean value determining whether the webpage scales to fit the view and the user can change the scale.
/// @discussion If YES, the webpage is scaled to fit and the user can zoom in and zoom out. If NO, user zooming is disabled.
/// The default value is NO.
@property (nonatomic) BOOL scalesPageToFit;
    
@end

NS_ASSUME_NONNULL_END
