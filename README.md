# SCWebBrowserView
A `UIView` subclass designed to wrapper `UIWebView` and `WKWebView`, using `UIWebView` on the version prior to iOS 8 and `WKWebView` on iOS 8 and later.


## Feature
- [x] iOS 7+ support for iPhone and iPad devices
- [x] Cookie synchronizing for WKWebView
- [x] Provide muitilpe level of Custom URL Scheme handling  
- [x] Supports subclassing, e.g. you can setup your custom 


## Usage

#### 1. Create your configuration object if you need some custom configuration.

```
SCWebBrowserViewConfiguration *configuration = [[SCWebBrowserViewConfiguration alloc] init];
configuration.mediaPlaybackRequiresUserAction = NO;
configuration.allowsInlineMediaPlayback = YES;
configuration.scalesPageToFit = YES;
configuration.webViewType = SCWebBrowserViewTypeUIWebView;
```

#### 2. Create your web browser view with your custom configuration, or xreate your web browser view with default configuration by using initializer `-initWithFrame:`.

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

## TODO
- [x] Swift edition
- [x] CocoaPods

## License
SCWebBrowserView is available under the MIT license. See the LICENSE file for more info.
