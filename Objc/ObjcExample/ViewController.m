//
//  ViewController.m
//  ObjcExample
//
//  Created by ShannonChen on 2017/5/26.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "ViewController.h"
#import "SCCustomWebBrowserView.h"


@interface ViewController () <SCWebBrowserViewDelegate>

@property (weak, nonatomic) SCWebBrowserView *webBrowserView;

@end

@implementation ViewController

static NSString *const defaultAddress = @"https://www.apple.com";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    SCWebBrowserViewConfiguration *configuration = [[SCWebBrowserViewConfiguration alloc] init];
    configuration.mediaPlaybackRequiresUserAction = NO;
    configuration.allowsInlineMediaPlayback = YES;
    configuration.scalesPageToFit = YES;
    configuration.webViewType = SCWebBrowserViewTypeUIWebView;
    
    SCWebBrowserView *webBrowserView = [[SCWebBrowserView alloc] initWithFrame:self.view.bounds configuration:configuration];
    webBrowserView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    webBrowserView.delegate = self;
    webBrowserView.allowsBackForwardNavigationGestures = YES;
    self.webBrowserView = webBrowserView;
    [self.view addSubview:webBrowserView];
    

    [self.webBrowserView loadHTMLString:[self HTMLStringWithFileName:@"WebViewTest.html"]];
    
//    [self.webBrowserView loadURLString:defaultAddress];
    
    self.navigationItem.title = self.webBrowserView.title;
    
}
    
- (IBAction)back:(id)sender {
    
//    [self.webBrowserView reload];
}

- (IBAction)refresh:(id)sender {
    
    [self.webBrowserView reload];
}


#pragma mark - <SCWebBrowserViewDelegate>

- (void)webBrowserViewDidStartLoad:(SCWebBrowserView *)webBrowserView {
    NSLog(@"%s", __FUNCTION__);
}

- (void)webBrowserViewDidFinishLoad:(SCWebBrowserView *)webBrowserView {
    NSLog(@"%s", __FUNCTION__);
}

- (void)webBrowserView:(SCWebBrowserView *)webBrowserView didFailLoadWithError:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
}

- (BOOL)webBrowserView:(SCWebBrowserView *)webBrowserView shouldStartLoadWithRequest:(NSURLRequest *)request {
    
    NSLog(@"%s", __FUNCTION__);
    
    if([request.URL.scheme isEqualToString:@"webviewdemo"]) {
        
        if ([request.URL.host isEqualToString:@"playVideo"]) {
            [self.webBrowserView loadHTMLString:[self HTMLStringWithFileName:@"VideoPlaybackTest.html"]];
        }
        
        return NO;
    }
    
    return YES;
}

- (void)webBrowserView:(SCWebBrowserView *)webBrowserView didUpdateTitle:(NSString *)title {
    self.navigationItem.title = title;
}

- (void)webBrowserView:(SCWebBrowserView *)webBrowserView didUpdateProgress:(double)progress {
    NSLog(@"%s progress:%g", __FUNCTION__, progress);
}

    
#pragma mark - Helper
- (NSString *)HTMLStringWithFileName:(NSString *)file {
    
    NSString *typeString = [file containsString:@"html"] ? @"" : @"html";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:typeString];
    NSString *HTMLString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    return HTMLString;
}

@end
