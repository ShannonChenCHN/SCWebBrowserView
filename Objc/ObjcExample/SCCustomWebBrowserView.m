//
//  SCCustomWebBrowserView.m
//  ObjcExample
//
//  Created by ShannonChen on 17/6/21.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "SCCustomWebBrowserView.h"


@implementation SCCustomWebBrowserView

- (BOOL)shouldStartLoadWithRequest:(NSURLRequest *)request {
    
    
    if([request.URL.scheme isEqualToString:@"webviewdemo"]) {
        
        if ([request.URL.host isEqualToString:@"test"]) {
            [self evaluateJavaScript:@"alert('自定义 scheme');" completionHandler:NULL];
            return NO;
        }
        
    }
    
    return [super shouldStartLoadWithRequest:request];

}

@end
