//
//  XLMonitorBrokenLineView.h
//  MonitorCpuUsage
//
//  Created by HeXiuLian on 2019/4/25.
//  Copyright © 2019 HeXiuLian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOS-Echarts.h"

NS_ASSUME_NONNULL_BEGIN

@interface XLMonitorBrokenLineView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) PYZoomEchartsView *kEchartView;
@property (nonatomic, strong) NSArray  *arrData;

- (instancetype)initWithFrame:(CGRect)frame brokenLineData:(NSArray *)arrData;


@end

NS_ASSUME_NONNULL_END
