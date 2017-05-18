//
//  ANSPicker.h
//  ANSPicker
//
//  Created by viktyz on 17/5/18.
//  Copyright © 2017 Alfred Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANSPickerModel : NSObject

@property (nonatomic, strong) NSURL *source;
@property (nonatomic, strong) NSURL *dest;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSTimeInterval lastRequestTime;

- (instancetype)initWithSource:(NSURL *)source;

@end

@interface ANSPicker : NSObject

+ (instancetype)sharedPicker;

- (void)pickerEnter:(BOOL)open;

- (NSURL *)exchange:(NSURL *)url;

- (NSArray *)recordList;

- (void)clear;

- (void)changeSource:(NSURL *)source dest:(NSURL *)dest;

@end
