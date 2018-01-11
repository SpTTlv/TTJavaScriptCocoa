//
//  WebViewController.m
//  nnnnnn
//
//  Created by Lv on 2018/1/10.
//  Copyright © 2018年 iboxPay. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import "TTJavaScriptCocoaManager.h"
@interface WebViewController ()<WKNavigationDelegate,TTScriptMessageHandler>

/** webview */
@property (nonatomic,strong) WKWebView *webView;

/** d */
@property (nonatomic,strong) TTJavaScriptCocoaManager *ttJs;

@end

@implementation WebViewController
- (TTJavaScriptCocoaManager *)ttJs
{
    if (!_ttJs) {
        _ttJs = [[TTJavaScriptCocoaManager alloc] init];
    }
    return _ttJs;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL * url = [[NSBundle mainBundle] URLForResource:@"abc" withExtension:@"html"];
//    NSURL * url = [NSURL URLWithString:@"https://xw.qq.com/top/20180110002461/TOP2018011000246100"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    [self.ttJs registerWithWebView:self.webView];
    
    UIButton * btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setTitle:@"夜间" forState:UIControlStateNormal];
    [btn1 setBackgroundColor:[UIColor orangeColor]];
    [btn1 addTarget:self action:@selector(yejianmoshi) forControlEvents:UIControlEventTouchUpInside];
    btn1.frame = CGRectMake(100, 100, 60, 30);
    [self.view addSubview:btn1];
    [self.view bringSubviewToFront:btn1];
    
    UIButton * btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitle:@"日间" forState:UIControlStateNormal];
    [btn2 setBackgroundColor:[UIColor orangeColor]];
    [btn2 addTarget:self action:@selector(rijianmoshi) forControlEvents:UIControlEventTouchUpInside];
    btn2.frame = CGRectMake(100, 200, 60, 30);
    [self.view addSubview:btn2];
    [self.view bringSubviewToFront:btn2];
    
}
- (void)rijianmoshi
{
    self.ttJs.watchMode = YES;

}
- (void)yejianmoshi
{
    self.ttJs.watchMode = NO;
}
- (void)loadView
{
    [super loadView];
    self.view = self.webView;
}
#pragma mark - TTScriptMessageHandler
- (void)ttScriptMessagedidReceiveScriptMessage:(NSString *)message withBody:(id)body
{
    NSString * str = [NSString stringWithFormat:@"%@",body];
    if ([message isEqualToString:@"show"]) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:message message:str preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:sure];
        [self presentViewController:alert animated:YES completion:nil];
    }else {
        [self.ttJs evaluateRunJavaScript:[NSString stringWithFormat:@"%@('#38f67b')",str] withCompletionHandler:nil];
    }
}
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"%@",error);
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self.ttJs removeAllTTScriptMessageHandlerForNameArr];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.ttJs addScriptMessageHandlerWithDelegate:self withName:@"show"];
    [self.ttJs addScriptMessageHandlerWithDelegate:self withName:@"changeTextColor"];

    
    [self.ttJs getWebViewAllImgUrlsArr:^(NSMutableArray *urlArr, NSError *error) {
        if (!error) {
            NSLog(@"图片数组:   %@",urlArr);
        }
    }];
    
    [self.ttJs addWebViewImgUrlClickAction];
    
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    
   BOOL isImgUrl =  [self.ttJs didIsImgClickPolicyForNavigationAction:navigationAction withImgUrlBlock:^(NSString * _Nullable url) {
        NSLog(@"--点击图片的url :\n%@",url);
    }];
    if (isImgUrl) {
        decisionHandler(WKNavigationActionPolicyCancel);//不允许跳转
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);//允许跳转
    }

}

- (WKWebView *)webView
{
    if (_webView == nil) {
        _webView = [[WKWebView alloc] init];
        _webView.scrollView.bounces = NO;
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (void)dealloc{
    NSLog(@"页面 销毁");
}


@end
