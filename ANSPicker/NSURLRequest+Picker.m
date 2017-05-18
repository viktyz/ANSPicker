//
//  NSURLRequest+Picker.m
//  ANSPicker
//
//  Created by viktyz on 17/5/18.
//  Copyright © 2017 Alfred Jiang. All rights reserved.
//

#import "NSURLRequest+Picker.h"
#import "ANSPicker.h"
#import <objc/runtime.h>

@implementation NSURLRequest (Picker)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class targetClass = NSClassFromString(@"NSURLRequest");
        swizzleMethod(targetClass, @selector(requestWithURL:), @selector(nsp_requestWithURL:));
        swizzleMethod(targetClass, @selector(requestWithURL:cachePolicy:timeoutInterval:), @selector(nsp_requestWithURL:cachePolicy:timeoutInterval:));
        swizzleMethod(targetClass, @selector(initWithURL:), @selector(nsp_initWithURL:));
        swizzleMethod(targetClass, @selector(initWithURL:cachePolicy:timeoutInterval:), @selector(nsp_initWithURL:cachePolicy:timeoutInterval:));
    });
}

void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    IMP swizzledImp = method_getImplementation(swizzledMethod);
    char *swizzledTypes = (char *)method_getTypeEncoding(swizzledMethod);
    
    IMP originalImp = method_getImplementation(originalMethod);
    
    char *originalTypes = (char *)method_getTypeEncoding(originalMethod);
    BOOL success = class_addMethod(class, originalSelector, swizzledImp, swizzledTypes);
    if (success) {
        class_replaceMethod(class, swizzledSelector, originalImp, originalTypes);
    }else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (instancetype)nsp_requestWithURL:(NSURL *)URL
{
    URL = [[ANSPicker sharedPicker] exchange:URL];
    return [self nsp_requestWithURL:URL];
}

+ (instancetype)nsp_requestWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval
{
    URL = [[ANSPicker sharedPicker] exchange:URL];
    return [self nsp_requestWithURL:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval];
}

- (instancetype)nsp_initWithURL:(NSURL *)URL
{
    URL = [[ANSPicker sharedPicker] exchange:URL];
    return [self nsp_initWithURL:URL];
}

- (instancetype)nsp_initWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval
{
    URL = [[ANSPicker sharedPicker] exchange:URL];
    return [self nsp_initWithURL:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval];
}

@end
