//
//  ANSPickerUI.m
//  ANSPicker
//
//  Created by viktyz on 17/5/18.
//  Copyright © 2017 Alfred Jiang. All rights reserved.
//

#import "ANSPickerUI.h"
#import "ANSPicker.h"

#define anspScreenWidth [[UIScreen mainScreen] bounds].size.width
#define anspScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface ANSPickerWindow : UIWindow
<
UITableViewDelegate,
UITableViewDataSource,
UIAlertViewDelegate
>

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) UITableView *tableViewList;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSArray *recordList;
@property (nonatomic, assign) CGRect btnFrame;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSString *cTitle;

@end

@implementation ANSPickerWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert + 1;
        self.rootViewController = [UIViewController new];
        [self makeKeyAndVisible];
        
        self.btnFrame = frame;
        
        [self createButton];
        [self addPan];
    }
    
    return self;
}

- (void)updateTitle:(NSString *)title
{
    _cTitle = title;
    
    if (self.frame.size.width == self.btnFrame.size.width) {
        title = [NSString stringWithFormat:@"%@\nURL(COUNTS)",title];
    }
    else{
        title = [NSString stringWithFormat:@"%@\nDouble Clear",title];
    }
    
    [self.label setText:title];
}

#pragma marl -

- (void)tabButtonTapped:(UIButton *)sender forEvent:(UIEvent *)event {
    [self performSelector:@selector(tabButtonTap:) withObject:sender afterDelay:0.2];
}

- (void)tabButtonTap:(UIButton *)sender {
    [self clickPickerBtn];
}

- (void)repeatBtnTapped:(UIButton *)sender forEvent:(UIEvent *)event {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(tabButtonTap:) object:sender];
    
    if (self.frame.size.width != self.btnFrame.size.width) {
        [self clickClearBtn];
    }
}

- (void)clickPickerBtn
{
    if (self.frame.size.width == self.btnFrame.size.width) {
        [self showList];
    }
    else
    {
        [self showButton];
    }
    
    [self updateTitle:_cTitle];
}

- (void)clickClearBtn
{
    [self updateTitle:@"0(0)"];
    [[ANSPicker sharedPicker] clear];
    [self reloadData];
}

- (void)showList
{
    [self removePan];
    
    [self setFrame:[[[[UIApplication sharedApplication] windows] firstObject] frame]];
    
    if (!_tableViewList) {
        self.tableViewList = [[UITableView alloc] initWithFrame:self.frame];
        self.tableViewList.delegate = self;
        self.tableViewList.dataSource = self;
        [self addSubview:self.tableViewList];
    }
    
    self.tableViewList.hidden = NO;
    [self bringSubviewToFront:self.button];
    [self.button setFrame:CGRectMake(CGRectGetWidth(self.frame) - self.btnFrame.size.width, 0, self.btnFrame.size.width, self.btnFrame.size.height)];
    
    [self reloadData];
}

- (void)showButton
{
    self.tableViewList.hidden = YES;
    [self setFrame:self.btnFrame];
    [self.button setFrame:CGRectMake(0, 0, self.btnFrame.size.width, self.btnFrame.size.height)];
    [self addPan];
}

- (void)createButton
{
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.alpha = 0.8;
    self.button.frame = CGRectMake(0, 0, self.btnFrame.size.width, self.btnFrame.size.height);
    [self.button addTarget:self action:@selector(tabButtonTapped:forEvent:) forControlEvents:UIControlEventTouchDown];
    [self.button addTarget:self action:@selector(repeatBtnTapped:forEvent:) forControlEvents:UIControlEventTouchDownRepeat];
    self.button.backgroundColor = [UIColor blackColor];
    
    self.label = [[UILabel alloc] initWithFrame:self.button.bounds];
    self.label.numberOfLines = 2;
    self.label.textColor = [UIColor whiteColor];
    self.label.font = [UIFont systemFontOfSize:10.0];
    self.label.minimumScaleFactor = 0.5;
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.button addSubview:self.label];
    
    [self addSubview:self.button];
}

#pragma mark - Pan

- (void)addPan
{
    if (!_pan) {
        self.pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
        self.pan.delaysTouchesBegan = NO;
        [self addGestureRecognizer:self.pan];
    }
}

- (void)removePan
{
    [self removeGestureRecognizer:self.pan];
    self.pan = nil;
}

- (void)locationChange:(UIPanGestureRecognizer*)recognizer
{
    CGPoint translation = [recognizer locationInView:[[UIApplication sharedApplication] keyWindow]];
    
    [UIView animateWithDuration:0.1
                     animations:^{
                         recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                                              recognizer.view.center.y + translation.y);
                     }];
}

#pragma mark -

- (void)reloadData
{
    self.recordList = [[ANSPicker sharedPicker] recordList];
    [self.tableViewList reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.recordList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ANSPickerModel *model = [self.recordList objectAtIndex:indexPath.row];
    
    NSString * identifier= @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld - %@ (%ld)",([self.recordList count] - indexPath.row),model.source.absoluteString,model.count];
    cell.detailTextLabel.text = model.dest.absoluteString;
    
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    cell.detailTextLabel.textColor = [UIColor redColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ANSPickerModel *model = [self.recordList objectAtIndex:indexPath.row];
    
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Edit URL"
                                                message:model.source.absoluteString
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"Change",@"Reset",nil];
    
    self.alertView.tag = indexPath.row;
    
    self.textView = [[UITextView alloc] init];
    self.textView.font = [UIFont systemFontOfSize:18.0];
    [self.alertView setValue:self.textView forKey:@"accessoryView"];
    
    [self.alertView show];
    
    if ([model.dest.absoluteString length] == 0) {
        self.textView.text = model.source.absoluteString;
    }
    else{
        self.textView.text = model.dest.absoluteString;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        
        ANSPickerModel *model = [self.recordList objectAtIndex:alertView.tag];
        
        if ([self.textView.text length] > 7){
            [[ANSPicker sharedPicker] changeSource:model.source
                                              dest:[NSURL URLWithString:self.textView.text]];
        }
        else{
            [[ANSPicker sharedPicker] changeSource:model.source
                                              dest:nil];
        }
        
        [self reloadData];
    }
    else if (buttonIndex == 2){
        
        ANSPickerModel *model = [self.recordList objectAtIndex:alertView.tag];
        
        [[ANSPicker sharedPicker] changeSource:model.source
                                          dest:nil];
        
        [self reloadData];
    }
}

@end


@interface ANSPickerUI ()
@property(strong,nonatomic) ANSPickerWindow *window;
@property(strong,nonatomic) UIButton *button;
@end

@implementation ANSPickerUI

- (void)pickerEnter:(BOOL)open
{
    if (open) {
        [self createPickerEnter];
    }
    else{
        [self resignPickerEnter];
    }
}

- (void)updateTitle:(NSString *)title
{
    [self.window updateTitle:title];
}

- (void)createPickerEnter
{
    if (!_window) {
        
        self.window = [[ANSPickerWindow alloc] initWithFrame:CGRectMake(100, 100, 80, 80)];
    }
}

- (void)resignPickerEnter
{
    [self.window resignKeyWindow];
    self.window = nil;
}

@end
