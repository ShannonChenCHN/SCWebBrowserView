//
//  ViewController.m
//  ObjcExample
//
//  Created by ShannonChen on 2017/5/26.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "ViewController.h"
#import "SCWebBrowserView.h"


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


@end
