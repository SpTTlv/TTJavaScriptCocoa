//
//  TTJavaScriptCocoaManager.m
//  TTJavaScriptCocoa
//
//  Created by Lv on 2018/1/10.
//  Copyright © 2018年 iboxPay. All rights reserved.
//


#import "TTJavaScriptCocoaManager.h"

#pragma mark - WeakScriptMessageDelegate

@implementation WeakScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate
{
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end


@interface TTJavaScriptCocoaManager ()


@property (nonatomic,strong) WKWebView *webView;


/** 绑定js方法名 数组 */
@property (nonatomic,strong) NSMutableArray *jsMethodNameArr;


@end


static TTJavaScriptCocoaManager * _instance  = nil;
@implementation TTJavaScriptCocoaManager

- (void)registerWithWebView:(WKWebView *)webView
{
    self.webView = webView;
}
- (void)evaluateRunJavaScript:(NSString *)javaScriptString withCompletionHandler:(void (^)(id , NSError *))completionHandler
{
    [self.webView evaluateJavaScript:javaScriptString completionHandler:^(id wh, NSError * error) {
        if (completionHandler) {
            completionHandler(wh,error);
        }
    }];
}
- (void)addScriptMessageHandlerWithDelegate:(id)viewController withName:(NSString *)name
{
    [self.jsMethodNameArr addObject:name];
    [[self.webView configuration].userContentController addScriptMessageHandler:[[WeakScriptMessageDelegate alloc] initWithDelegate:self] name:name];
    self.messageDelegate = viewController;

}
#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if (_messageDelegate && [_messageDelegate respondsToSelector:@selector(ttScriptMessagedidReceiveScriptMessage:withBody:)]) {
        [_messageDelegate ttScriptMessagedidReceiveScriptMessage:message.name withBody:message.body];
    }
}


- (void)setWatchMode:(BOOL)watchMode
{
    _watchMode = watchMode;

    NSString * js = @"";
    NSString * js2 = @"";
    if (watchMode) { //正常模式
        js = @"document.getElementsByTagName('body')[0].style.webkitTextFillColor= '#3c3c3c'";
        js2 = @"document.getElementsByTagName('body')[0].style.background='#ffffff'";
    }else {   //夜间模式
        js = @"document.getElementsByTagName('body')[0].style.webkitTextFillColor= '#fed037'";
        js2 = @"document.getElementsByTagName('body')[0].style.background='#2C2C2C'";
    }
    
    [self.webView evaluateJavaScript:js completionHandler:nil];
    [self.webView evaluateJavaScript:js2 completionHandler:nil];
}
- (NSMutableArray *)jsMethodNameArr
{
    if (!_jsMethodNameArr) {
        _jsMethodNameArr = [NSMutableArray array];
    }
    return _jsMethodNameArr;
}
- (void)removeTTScriptMessageHandlerForName:(NSString *)name
{
    if (name.length == 0) {
        return;
    }
    [[self.webView configuration].userContentController removeScriptMessageHandlerForName:name];
}
- (void)removeAllTTScriptMessageHandlerForNameArr
{
    [self removeAllJsName];
}
- (void)removeAllJsName
{
    [self.jsMethodNameArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * name = [NSString stringWithFormat:@"%@",obj];
        [[self.webView configuration].userContentController removeScriptMessageHandlerForName:name];
    }];
}
- (void)dealloc
{
    [self removeAllJsName];
}
- (void)addWebViewImgUrlClickAction
{
    NSString * js = @"function registerImageClickAction(){\
    var imgs=document.getElementsByTagName('img');\
    var length=imgs.length;\
    for(var i=0;i<length;i++){\
    img=imgs[i];\
    img.onclick=function(){\
    window.location.href='image-preview:'+this.src}\
    }\
    }";
    [self.webView evaluateJavaScript:js completionHandler:nil];
    
    [self.webView evaluateJavaScript:@"registerImageClickAction()" completionHandler:nil];
}
- (void)getWebViewAllImgUrlsArr:(void (^)(NSMutableArray *, NSError *))completionHandler
{
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgScr = '';\
    for(var i=0;i<objs.length;i++){\
    imgScr = imgScr + objs[i].src + '+';\
    };\
    return imgScr;\
    };";
    
    [self.webView evaluateJavaScript:jsGetImages completionHandler:nil];
    [self.webView evaluateJavaScript:@"getImages()" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
        NSMutableArray *urlArray = [NSMutableArray arrayWithArray:[result componentsSeparatedByString:@"+"]];
        if (urlArray.count >= 2) {
            [urlArray removeLastObject];
        }
        if (completionHandler) {
            completionHandler(urlArray,error);
        }
    }];
}
- (BOOL)didIsImgClickPolicyForNavigationAction:(WKNavigationAction *)wkAction withImgUrlBlock:(void (^)(NSString * _Nullable))completionHandler
{
    NSString *strRequest = [wkAction.request.URL.scheme stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    if([strRequest isEqualToString:@"image-preview"]) {//主页面加载内容
        
        NSString * imageUrl = [wkAction.request.URL.absoluteString substringFromIndex:[@"image-preview:" length]];
        imageUrl = [imageUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        if (completionHandler) {
            completionHandler(imageUrl);
        }
        
        return YES;
    }
    if (completionHandler) {
        completionHandler(nil);
    }
    return NO;
}


#pragma mark - 单例
//+ (void)load
//{
//    _instance = [[TTJavaScriptCocoaManager alloc] init];
//}
//+ (instancetype)shareInstance
//{
//    return [[self alloc] init];
//}
//+ (instancetype)alloc
//{
//    if (_instance) {
//        NSException * excp = [NSException exceptionWithName:@"NSInternalInconsistencyException" reason:@"There can only be one TTJavaScriptCocoaManager instance." userInfo:nil];
//        [excp raise];
//    }
//    return [super alloc];
//}

@end




