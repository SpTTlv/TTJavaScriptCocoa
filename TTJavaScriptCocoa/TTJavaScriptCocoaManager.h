//
//  TTJavaScriptCocoaManager.h
//  TTJavaScriptCocoa
//
//  Created by Lv on 2018/1/10.
//  Copyright © 2018年 iboxPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>


@interface WeakScriptMessageDelegate : NSObject<WKScriptMessageHandler>

/** delegate */
@property (nonatomic,weak) id<WKScriptMessageHandler> scriptDelegate;


- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end




@protocol TTScriptMessageHandler <NSObject>

@optional
- (void)ttScriptMessagedidReceiveScriptMessage:(NSString *)message withBody:(id)body;

@end


@interface TTJavaScriptCocoaManager : NSObject<WKScriptMessageHandler>

//+ (instancetype)shareInstance;

/** 接收js回调消息代理 */
@property (nonatomic,weak) id<TTScriptMessageHandler> messageDelegate;


- (void)registerWithWebView:(WKWebView * )webView;

/** 浏览模式  YES:日间模式  NO:夜间模式*/
@property (nonatomic,assign,getter=isWatchMode) BOOL watchMode;


/** 获取当前网页所有img的url数组*/
- (void)getWebViewAllImgUrlsArr:(void (^)(NSMutableArray * urlArr, NSError * error))completionHandler;
/** 给当前网页所有img添加点击事件*/
- (void)addWebViewImgUrlClickAction;
/** 判断当前点击的是否是图片url YES:是  并且返回该url*/
- (BOOL)didIsImgClickPolicyForNavigationAction:(WKNavigationAction *)wkAction withImgUrlBlock:(void (^_Nullable)(NSString *_Nullable url))completionHandler;



/** 执行js代码*/
- (void)evaluateRunJavaScript:(NSString *_Nullable)javaScriptString withCompletionHandler:(void (^ _Nullable)(id _Nullable object,NSError * _Nullable error))completionHandler;


/** 绑定js方法*/
- (void)addScriptMessageHandlerWithDelegate:(id _Nonnull)viewController withName:(NSString *_Nullable)name;
/** 移除绑定的js方法*/
- (void)removeTTScriptMessageHandlerForName:(NSString *_Nullable)name;
/** 移除所有通过该类绑定的js方法*/
- (void)removeAllTTScriptMessageHandlerForNameArr;


@end


