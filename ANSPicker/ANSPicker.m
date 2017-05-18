//
//  ANSPicker.m
//  ANSPicker
//
//  Created by viktyz on 17/5/18.
//  Copyright © 2017 Alfred Jiang. All rights reserved.
//

#import "ANSPicker.h"
#import "ANSPickerUI.h"

@implementation ANSPickerModel

- (instancetype)initWithSource:(NSURL *)source
{
    self = [super init];
    
    if (self) {
        
        _source = source;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.source forKey:@"source"];
    [coder encodeObject:self.dest forKey:@"dest"];
    [coder encodeFloat:self.lastRequestTime forKey:@"lastRequestTime"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.source = [coder decodeObjectForKey:@"source"];
        self.dest = [coder decodeObjectForKey:@"dest"];
        self.count = 0;
        self.lastRequestTime = [coder decodeFloatForKey:@"lastRequestTime"];
    }
    return self;
}

@end


@interface ANSPicker()

@property (nonatomic, strong) NSMutableArray<ANSPickerModel *> *records;
@property (nonatomic, strong) ANSPickerUI *pickerUI;
@property (nonatomic, assign) NSInteger tCount;

@end

@implementation ANSPicker

+ (instancetype)sharedPicker
{
    static ANSPicker *_sharedPicker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedPicker = [[ANSPicker alloc] init];
        _sharedPicker.tCount = 0;
    });
    
    return _sharedPicker;
}

- (void)pickerEnter:(BOOL)open
{
    self.pickerUI = [[ANSPickerUI alloc] init];
    [self.pickerUI pickerEnter:open];
}

- (NSArray *)recordList
{
    [self.records sortUsingComparator:^NSComparisonResult(ANSPickerModel *obj1, ANSPickerModel *obj2) {
        return (obj2.lastRequestTime - obj1.lastRequestTime);
    }];
    return [self.records copy];
}

- (NSURL *)exchange:(NSURL *)url
{
    _tCount++;
    [self.pickerUI updateTitle:[NSString stringWithFormat:@"%ld(%ld)",[self.records count] + 1,_tCount]];
    
    if ([url.absoluteString length] == 0) {
        return url;
    }
    
    __block NSURL *dest = url;
    __block BOOL exist = NO;
    
    [self.records enumerateObjectsUsingBlock:^(ANSPickerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([url.absoluteString isEqualToString:obj.source.absoluteString]) {
            
            if ([obj.dest.absoluteString length] != 0) {
                
                dest = obj.dest;
                
                NSLog(@"ANSPicker - Change %@ to %@",url,dest);
            }
            
            obj.count++;
            exist = YES;
            *stop = YES;
        }
        else if([url.absoluteString isEqualToString:obj.dest.absoluteString]){
            
            obj.count++;
            exist = YES;
            *stop = YES;
        }
    }];
    
    if (!exist) {
        
        ANSPickerModel *model = [[ANSPickerModel alloc] initWithSource:url];
        model.count = 1;
        model.lastRequestTime = [[NSDate new] timeIntervalSince1970];
        
        [self.records addObject:model];
    }
    
    [self saveRecords];
    
    return dest;
}

- (void)clear
{
    [self.records removeAllObjects];
    [self saveRecords];
}

- (void)changeSource:(NSURL *)source dest:(NSURL *)dest
{
    if ([source.absoluteString isEqualToString:dest.absoluteString]) {
        
        return;
    }
    
    [self.records enumerateObjectsUsingBlock:^(ANSPickerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([source.absoluteString isEqualToString:obj.source.absoluteString]) {
            
            obj.dest = dest;
        }
    }];
    
    [self saveRecords];
}

#pragma mark -

- (NSMutableArray *)records
{
    if (_records) {
        
        return _records;
    }
    
    NSArray *list = [[NSUserDefaults standardUserDefaults] objectForKey:@"ANSPicker_Records"];
    
    if (list) {
        
        _records = [NSMutableArray arrayWithCapacity:list.count];
        
        for (NSData *recordEncodedObjectt in list) {
            
            ANSPickerModel *recordObject = [NSKeyedUnarchiver unarchiveObjectWithData:recordEncodedObjectt];
            [_records addObject:recordObject];
        }
    }
    else{
    
        _records = [NSMutableArray array];
    }
    
    return _records;
}

- (void)saveRecords
{
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:_records.count];
    
    for (ANSPickerModel *object in _records) {
        
        NSData *recordEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
        [archiveArray addObject:recordEncodedObject];
    }
    
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    [userData setObject:archiveArray forKey:@"ANSPicker_Records"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
