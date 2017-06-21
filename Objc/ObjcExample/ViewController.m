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

@property (weak, nonatomic) IBOutlet SCWebBrowserView *webBrowserView;

@end

@implementation ViewController

static NSString *const defaultAddress = @"https://www.apple.com";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webBrowserView.delegate = self;
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"WebViewTest" ofType:@"html"];
    NSString *HTMLString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webBrowserView loadHTMLString:HTMLString];
    
//    [self.webBrowserView loadURLString:defaultAddress];
    
    self.navigationItem.title = self.webBrowserView.title;
    
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
    
    return YES;
}

- (void)webBrowserView:(SCWebBrowserView *)webBrowserView didUpdateTitle:(NSString *)title {
    self.navigationItem.title = title;
}

- (void)webBrowserView:(SCWebBrowserView *)webBrowserView didUpdateProgress:(double)progress {
    NSLog(@"%s progress:%g", __FUNCTION__, progress);
}


@end
