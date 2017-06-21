//
//  SCCustomWebBrowserView.h
//  ObjcExample
//
//  Created by ShannonChen on 17/6/21.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "SCWebBrowserView.h"


/**
 自定义 webView 容器，基于 WKWebView 进行封装，兼容 iOS 7.x （UIWebView）
 SCCustomWebBrowserView 主要负责一些强业务逻辑，其继承的 SCWebBrowserView 主要负责底层逻辑。
 */
@interface SCCustomWebBrowserView : SCWebBrowserView

@end
