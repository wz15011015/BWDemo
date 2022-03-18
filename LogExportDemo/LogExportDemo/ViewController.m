//
//  ViewController.m
//  LogExportDemo
//
//  Created by hadlinks on 2020/9/9.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "BWLogExportManager.h"

static NSString *URLString = @"https://www.jianshu.com/u/00084b53d83c";


@interface ViewController () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView; // 加载指示器

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 开始日志记录
    [BWLogExportManagerShared addExportButtonInViewController:self];
    [BWLogExportManagerShared startLogRecordWithXcodeEnable:YES];
    
    [self setupUI];
}


- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 添加控件
    // WKWebView
    [self.view addSubview:self.webView];
    // 加载指示器
    [self.view addSubview:self.indicatorView];
    

    // 加载页面
    NSURL *url = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    [self.indicatorView startAnimating];
}


#pragma mark - WKNavigationDelegate

/**
 *  当开始发送请求时调用
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"WKWebView_开始发送请求");
}

/**
 *  当内容开始返回时调用
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"WKWebView_开始返回内容");
}

/**
 *  当请求过程中出现错误时调用
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"WKWebView_请求过程中出现错误, %@", error);
    
    [self.indicatorView stopAnimating];
}

/**
 *  当开始发送请求时出现错误时调用
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"WKWebView_开始发送请求时出现错误, %@", error);
    
    [self.indicatorView stopAnimating];
}

/**
 *  当网页加载完毕时调用：该方法使用最频繁
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"WKWebView_加载完毕");
    
    [self.indicatorView stopAnimating];
}


#pragma mark - Getters

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        _webView.navigationDelegate = self;
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.opaque = NO;
    }
    return _webView;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        if (@available(iOS 13.0, *)) {
            _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        } else {
            _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
        _indicatorView.frame = CGRectOffset(_webView.frame, 0, -40);
    }
    return _indicatorView;
}

@end
