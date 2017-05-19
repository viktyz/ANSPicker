//
//  ViewController.m
//  ANSPickerDemo
//
//  Created by viktyz on 2017/5/19.
//  Copyright © 2017年 Alfred Jiang. All rights reserved.
//

#import "ViewController.h"
#import "ANSPicker.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)clickOpenPicker:(UIButton *)sender {
    [self sendRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)sendRequest
{
    NSURL *url = [NSURL URLWithString:@"http://wthrcdn.etouch.cn/weather_mini?city=%E4%B8%8A%E6%B5%B7"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            
            NSLog(@"%@",dict);
        }
    }];
    
    [dataTask resume];
}

@end
