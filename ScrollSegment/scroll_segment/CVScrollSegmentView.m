//
//  CVScrollSegmentView.m
//  ScrollSegment
//
//  Created by Yuanhai on 18/3/19.
//  Copyright © 2019年 Yuanhai. All rights reserved.
//

#import "CVScrollSegmentView.h"

#define lineHeight 2.0f
#define lineHeightSpacing 5.0f

@interface CVScrollSegmentView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) NSMutableArray *titlesArray;
@property (nonatomic, strong) UIView *lineView;

/*
 *按钮的宽度，高度与scrollview相同
 */
@property float buttonWidth;

/*
 *gsv -- gray scale values
 *灰阶值，取值范围：0 - 1
 */
@property float gsv_selected;
@property float gsv_default;

/*
 *缩放大小
 */
@property float scale_max;
@property float scale_min;

@end

@implementation CVScrollSegmentView

-(void)dealloc
{
    self.segmentDelegate = nil;
    self.scrollView.delegate = nil;
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.frame = self.bounds;
        self.scrollView.delegate = self;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.decelerationRate = 0;
        [self addSubview:self.scrollView];
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:self.lineView];
        
        // 初始化
        self.buttonArray = [NSMutableArray array];
        self.titlesArray = [NSMutableArray array];
        self.backgroundColor = [UIColor clearColor];
        self.buttonWidth = frame.size.width / 3;
        self.scale_max = 1.0f;
        self.scale_min = 0.7;
        self.gsv_selected = 1.0f;
        self.gsv_default = 0.7;
    }
    return self;
}

- (void)setupWithTitleArray:(NSArray *)array
{
    self.titlesArray = [NSMutableArray arrayWithArray:array];
    self.buttonArray = [NSMutableArray array];
    
    // 左右空一个
    self.scrollView.contentSize = CGSizeMake(self.buttonWidth * (array.count + 2), self.frame.size.height);
    
    // 布局Buttons
    for (int f = 0; f < self.titlesArray.count; f++)
    {
        [self initButtonsWithIndex:f];
    }
    
    // 监听滑动
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    // 默认按钮选中状态
    [self clickButton:(UIButton *)[self.buttonArray objectAtIndex:1]];
    [self setButtonStatusWithOffsetX:self.scrollView.contentOffset.x];
}

#pragma mark - 按钮

- (void)initButtonsWithIndex:(int)index
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((index + 1) * self.buttonWidth, 0.0f, self.buttonWidth, self.frame.size.height);
    button.tag = index;
    [button setTitle:[self.titlesArray objectAtIndex:index] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.scrollView addSubview:button];
    [self.buttonArray addObject:button];
    
    // 字体颜色
    [button setTitleColor:[UIColor colorWithWhite:self.gsv_default alpha:1] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:self.gsv_selected alpha:1] forState:UIControlStateSelected];
    
    // 缩放
    button.transform = CGAffineTransformMakeScale(self.scale_min, self.scale_min);
}

- (void)clickButton:(UIButton *)button
{
    CGFloat left = ((button.tag) * self.buttonWidth);
    [self.scrollView setContentOffset:CGPointMake(left, 0.0f) animated:YES];
    [self selectIndex:button.tag];
}

- (void)selectIndex:(NSInteger)index
{
    // 自适应
    UIButton *button = self.buttonArray[index];
    NSString *title = [button titleForState:UIControlStateNormal];
    CGRect tmpRect = [title boundingRectWithSize:CGSizeMake(100000, 100000) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:button.titleLabel.font, NSFontAttributeName, nil] context:nil];
    
    // Line Frame
    float lineWidth = tmpRect.size.width + 5.0f;
    CGRect lineFrame = CGRectMake(button.center.x - lineWidth / 2, self.scrollView.frame.size.height - lineHeightSpacing, lineWidth, lineHeight);
    if (self.lineView.frame.size.width <= 0)
    {
        self.lineView.frame = lineFrame;
    }
    else
    {
        [UIView animateWithDuration:0.22 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.lineView.frame = lineFrame;
        } completion:nil];
    }
    
    // 回调
    if (self.segmentDelegate && [self.segmentDelegate respondsToSelector:@selector(scrollSegmentViewSelectIndex:)])
    {
        [self.segmentDelegate scrollSegmentViewSelectIndex:index];
    }
}

#pragma mark - Observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"])
    {
        [self setButtonStatusWithOffsetX:self.scrollView.contentOffset.x];
    }
}

#pragma mark - 核心内容

- (void)setButtonStatusWithOffsetX:(CGFloat)offsetX
{
    if (offsetX < 0)
    {
        return;
    }
    
    if (offsetX > (self.scrollView.contentSize.width - self.buttonWidth))
    {
        return;
    }
    
    int tempTag = (offsetX / self.buttonWidth);
    if (tempTag > self.titlesArray.count - 1)
    {
        return;
    }
    
    for (UIButton *button in self.buttonArray)
    {
        [button setTitleColor:[UIColor colorWithWhite:self.gsv_default alpha:1] forState:UIControlStateNormal];
        button.transform = CGAffineTransformMakeScale(self.scale_min, self.scale_min);
        
        CGPoint center = button.center;
        center.x = (button.tag + 1) * self.buttonWidth + self.buttonWidth / 2.0f;
        button.center = center;
    }
    
    UIButton *buttonleft = [self.buttonArray objectAtIndex:tempTag];
    UIButton *buttonRight = self.buttonArray.count > (tempTag + 1) ? [self.buttonArray objectAtIndex:(tempTag + 1)] : nil;
    
    float leftcolorValue = self.gsv_selected - fmod((double)offsetX, self.buttonWidth) / self.buttonWidth * (self.gsv_selected - self.gsv_default);
    float leftScale = self.scale_max - fmod((double)offsetX, self.buttonWidth) / self.buttonWidth * (self.scale_max - self.scale_min);
    
    [buttonleft setTitleColor:[UIColor colorWithWhite:(leftcolorValue) alpha:1] forState:UIControlStateNormal];
    buttonleft.transform = CGAffineTransformMakeScale(leftScale, leftScale);
    
    float rightcolorValue = self.gsv_default + fmod((double)offsetX,self.buttonWidth) / self.buttonWidth;
    float rightScale = self.scale_min + fmod((double)offsetX,self.buttonWidth) / self.buttonWidth*(self.scale_max - self.scale_min);
    
    [buttonRight setTitleColor:[UIColor colorWithWhite:(rightcolorValue) alpha:1] forState:UIControlStateNormal];
    buttonRight.transform = CGAffineTransformMakeScale(rightScale, rightScale);
}

// 停止滚动调用
- (void)resetScrollOffset
{
    CGPoint offset = self.scrollView.contentOffset;
    int newPageIndex = offset.x / self.buttonWidth;
    if(offset.x / self.buttonWidth - newPageIndex >= 0.5)
    {
        newPageIndex++;
    }
    
    CGFloat left = newPageIndex * self.buttonWidth;
    [self.scrollView setContentOffset:CGPointMake(left, 0.0f) animated:YES];
    [self selectIndex:newPageIndex];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!scrollView.tracking && !scrollView.dragging && !scrollView.decelerating)
    {
        [self resetScrollOffset];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate && scrollView.tracking && !scrollView.dragging && !scrollView.decelerating)
    {
        [self resetScrollOffset];
    }
}

@end
