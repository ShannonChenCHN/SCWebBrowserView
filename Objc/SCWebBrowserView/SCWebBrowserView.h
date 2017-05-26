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

@end


/**
 A `UIView` subclass designed to wrapper `UIWebView` and `WKWebView`, using `UIWebView` on the version prior to iOS 8 and `WKWebView` on iOS 8 and later.
 */
@interface SCWebBrowserView : UIView <UIWebViewDelegate, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>


// The actual web views
// `WKWebView` would be used on iOS 8 and later, while `UIWebView` would be used on the version prior to iOS 8.
@property (strong, nonatomic, nullable) UIWebView *uiWebView;
@property (strong, nonatomic, nullable) WKWebView *wkWebView;

@property (weak, nonatomic, nullable) id <SCWebBrowserViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame configuration:(nullable WKWebViewConfiguration *)configuration NS_DESIGNATED_INITIALIZER;


// Loads a `NSURLURLRequest` to web view
- (void)loadRequest:(NSURLRequest *)request;

// Load a `NSURL` to web view
- (void)loadURL:(NSURL *)URL;

// Loads a URL as `NSString` to web view
- (void)loadURLString:(NSString *)URLString;


// Loads an string containing HTML to web view
- (void)loadHTMLString:(NSString *)HTMLString;

@end

NS_ASSUME_NONNULL_END
