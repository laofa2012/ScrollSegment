//
//  ViewController.m
//  ScrollSegment
//
//  Created by Yuanhai on 18/3/19.
//  Copyright © 2019年 Yuanhai. All rights reserved.
//

#import "ViewController.h"
#import "CVScrollSegmentView.h"

@interface ViewController () <CVScrollSegmentViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *titleArray = @[@"黄",@"天蓝色的海洋",@"橘色是好",@"紫色",@"绿色是一种很环保色"];
    CVScrollSegmentView *segmentView = [[CVScrollSegmentView alloc] initWithFrame:CGRectMake(10.0f, 100, [UIScreen mainScreen].bounds.size.width - 20.0f, 50)];
    [segmentView setupWithTitleArray:titleArray];
    segmentView.backgroundColor = [UIColor darkGrayColor];
    segmentView.segmentDelegate = self;
    [self.view addSubview:segmentView];
}

#pragma mark - CVScrollSegmentViewDelegate

- (void)scrollSegmentViewSelectIndex:(NSInteger)index
{
    NSLog(@"index:%d", (int)index);
}

@end
