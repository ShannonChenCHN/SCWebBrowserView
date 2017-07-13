# SCWebBrowserView [中文介绍](https://github.com/ShannonChenCHN/SCWebBrowserView#中文介绍)

![](https://camo.githubusercontent.com/fc56303af12c023343f338a762b6bfb2a5f1e4dc/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f6c6963656e73652d4d49542d677265656e2e7376673f7374796c653d666c6174) ![](https://camo.githubusercontent.com/8ddec955b9dd8da6ba9daa89ad5c282c7865b9bb/687474703a2f2f696d672e736869656c64732e696f2f636f636f61706f64732f702f59594b69742e7376673f7374796c653d666c6174) ![](https://camo.githubusercontent.com/eb5485388cd282c0139df4ed308b825420589a7c/68747470733a2f2f696d672e736869656c64732e696f2f6769746875622f6c6963656e73652f6861636b696674656b6861722f49514b6579626f6172644d616e616765722e737667)

A `UIView` subclass designed to wrapper `UIWebView` and `WKWebView`, using `UIWebView` on the version prior to iOS 8 and `WKWebView` on iOS 8 and later by default.


## Feature
- [x] iOS 7+ support for iPhone and iPad devices
- [x] Cookie synchronizing for WKWebView
- [x] Provide muitilpe level of Custom URL Scheme handling  
- [x] Supports subclassing(e.g. custom cookie filter, custom handling logic for Custom URL Scheme)


## Usage

#### 1. Create your configuration object if you need some custom configuration.

```
SCWebBrowserViewConfiguration *configuration = [[SCWebBrowserViewConfiguration alloc] init];
configuration.mediaPlaybackRequiresUserAction = NO;
configuration.allowsInlineMediaPlayback = YES;
configuration.scalesPageToFit = YES;
configuration.webViewType = SCWebBrowserViewTypeUIWebView;
```

#### 2. Create your web browser view with your custom configuration, or create your web browser view with default configuration by using initializer `-initWithFrame:`.

```
SCWebBrowserView *webBrowserView = [[SCWebBrowserView alloc] initWithFrame:self.view.bounds configuration:configuration];
webBrowserView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
webBrowserView.delegate = self;
webBrowserView.allowsBackForwardNavigationGestures = YES;
[self.view addSubview:webBrowserView];
```

#### 3. Load a URL address. 
```
[webBrowserView loadURLString:@"https://www.apple.com"];
```

#### 4. Implement `SCWebBrowserViewDelegate` methods if needed.
```
- (void)webBrowserViewDidStartLoad:(SCWebBrowserView *)webBrowserView;
- (void)webBrowserViewDidFinishLoad:(SCWebBrowserView *)webBrowserView;
- (void)webBrowserView:(SCWebBrowserView *)webBrowserView didFailLoadWithError:(NSError *)error;
- (BOOL)webBrowserView:(SCWebBrowserView *)webBrowserView shouldStartLoadWithRequest:(NSURLRequest *)request;

- (void)webBrowserView:(SCWebBrowserView *)webBrowserView didUpdateTitle:(nullable NSString *)title;
- (void)webBrowserView:(SCWebBrowserView *)webBrowserView didUpdateProgress:(double)progress;
```

## TODO
- [ ] Swift edition
- [ ] CocoaPods

## License
`SCWebBrowserView` is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.


-----
# 中文介绍

`SCWebBrowserView` 是一个基于 `UIWebView` 和 `WKWebView` 的封装，继承于 `UIView`。默认情况下，在 iOS 8.0 及以后，使用 `WKWebView`，在 iOS 8.0 以前使用 `UIWebView`。

## 功能
- [x] 支持 iOS 7 以上的 iOS 设备
- [x] 在 `WKWebView` 模式下，自动同步 Shared Cookie Storage 中的 cookie 到 `WKWebView`
- [x] 提供不同层次的 Custom URL Scheme 的处理机制  
- [x] 支持一些子类自定义的操作(比如，为 `WKWebView` 的 cookie 同步自定义 cookie filter, 自定义 Custom URL Scheme 的处理逻辑)

## 使用

#### 1. 如果你需要一些自定义配置的话，你可以先创建一个 `SCWebBrowserViewConfiguration` 对象。

```
SCWebBrowserViewConfiguration *configuration = [[SCWebBrowserViewConfiguration alloc] init];
configuration.mediaPlaybackRequiresUserAction = NO;
configuration.allowsInlineMediaPlayback = YES;
configuration.scalesPageToFit = YES;
configuration.webViewType = SCWebBrowserViewTypeUIWebView;
```

#### 2. 根据上一步创建的 configuration，创建一个 `SCWebBrowserView` 对象，或者直接使用 `-initWithFrame:` 创建一个 `SCWebBrowserView` 对象（此时，使用的是默认的 configuration）。

```
SCWebBrowserView *webBrowserView = [[SCWebBrowserView alloc] initWithFrame:self.view.bounds configuration:configuration];
webBrowserView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
webBrowserView.delegate = self;
webBrowserView.allowsBackForwardNavigationGestures = YES;
[self.view addSubview:webBrowserView];
```

#### 3. 加载一个 URL 地址。 
```
[webBrowserView loadURLString:@"https://www.apple.com"];
```

#### 4. 如果你需要监听一些事件，可以实现 `SCWebBrowserViewDelegate` 中的方法。
```
- (void)webBrowserViewDidStartLoad:(SCWebBrowserView *)webBrowserView;
- (void)webBrowserViewDidFinishLoad:(SCWebBrowserView *)webBrowserView;
- (void)webBrowserView:(SCWebBrowserView *)webBrowserView didFailLoadWithError:(NSError *)error;
- (BOOL)webBrowserView:(SCWebBrowserView *)webBrowserView shouldStartLoadWithRequest:(NSURLRequest *)request;

- (void)webBrowserView:(SCWebBrowserView *)webBrowserView didUpdateTitle:(nullable NSString *)title;
- (void)webBrowserView:(SCWebBrowserView *)webBrowserView didUpdateProgress:(double)progress;
```

## TODO
- [ ] Swift 版本
- [ ] CocoaPods

## License
`SCWebBrowserView` 使用的是 MIT 许可证。 详情见 [LICENSE](./LICENSE) 文件。



