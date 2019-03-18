//
//  CVScrollSegmentView.h
//  ScrollSegment
//
//  Created by Yuanhai on 18/3/19.
//  Copyright © 2019年 Yuanhai. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CVScrollSegmentViewDelegate <NSObject>

- (void)scrollSegmentViewSelectIndex:(NSInteger)index;

@end

@interface CVScrollSegmentView : UIView

@property (assign, nonatomic) id <CVScrollSegmentViewDelegate>segmentDelegate;

- (void)setupWithTitleArray:(NSArray *)array;

@end
