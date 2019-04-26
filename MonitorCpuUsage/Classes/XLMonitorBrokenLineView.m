//
//  XLMonitorBrokenLineView.m
//  MonitorCpuUsage
//
//  Created by HeXiuLian on 2019/4/25.
//  Copyright © 2019 HeXiuLian. All rights reserved.
//

#import "XLMonitorBrokenLineView.h"
#import <iOS_Echarts/iOS-Echarts.h>

@interface XLMonitorBrokenLineView ()

@property (nonatomic, strong) PYZoomEchartsView *kEchartView;

@property (nonatomic, strong) UITextView  *selectText;

@end

@implementation XLMonitorBrokenLineView

- (instancetype)initWithFrame:(CGRect)frame brokenLineData:(NSArray *)arrData {
    if (self = [super initWithFrame:frame]) {
        _arrData = arrData;
        [self creatScrollView];
        [self showBrokenLine];
        [self.kEchartView loadEcharts];
    }
    return self;
}

- (void)creatScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 300)];
    self.selectText = [[UITextView alloc] initWithFrame:CGRectMake(0, 300, self.frame.size.width, self.frame.size.height - 340)];
    self.selectText.editable = NO;
    self.selectText.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    [self addSubview:self.selectText];
    ///30个点一页
    long page = (self.arrData.count / 50) + 1;
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width * page, 0);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    /** 初始化图表 */
    self.kEchartView = [[PYZoomEchartsView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.frame.size.height)];
    // 添加到 scrollView 上
    [self.scrollView addSubview:self.kEchartView];
    self.kEchartView.backgroundColor = [UIColor whiteColor];
    __weak typeof(self) weak_self = self;
    [weak_self.kEchartView addHandlerForAction:PYEchartActionClick withBlock:^(NSDictionary *params) {
        __strong typeof(weak_self) self = weak_self;
        NSLog(@"params:%@",params);
        NSInteger index = [params[@"dataIndex"] integerValue];
        NSLog(@"%@----",self.arrData[index]);
        [self setSelectTextWithDictionary:self.arrData[index]];
    }];
}

- (void)setSelectTextWithDictionary:(NSDictionary *)dict {
    NSArray *arr = dict[@"arrThreadInfo"];
    NSString *threadStack = [arr componentsJoinedByString:@"\n\n"];
    NSString *text = [NSString stringWithFormat:@"CPUUsage: <%@> \n fps: <%@>\n VCName: <%@> \n time: <%@> \n threadStack:%@",dict[@"cpuUsage"],dict[@"fps"],dict[@"vcName"],dict[@"time"],threadStack];
    self.selectText.text = text;
}

-(void)showBrokenLine {
    /** 图表选项 */
    PYOption *option = [[PYOption alloc] init];
    //是否启用拖拽重计算特性，默认关闭
    option.calculable = NO;
    //数值系列的颜色列表(折线颜色)
    option.color = @[@"#20BCFC", @"#ff6347"];
    /** 提示框 */
    PYTooltip *tooltip = [[PYTooltip alloc] init];
    // 触发类型 默认数据触发
    tooltip.trigger = @"axis";
    // 竖线宽度
    tooltip.axisPointer.lineStyle.width = @1;
    // 提示框 文字样式设置
    tooltip.textStyle = [[PYTextStyle alloc] init];
    tooltip.textStyle.fontSize = @12;
    // 添加到图标选择中
    option.tooltip = tooltip;
    
    /** 图例 */
    PYLegend *legend = [[PYLegend alloc] init];
//    legend
    // 设置数据
    legend.data = @[@"CPU",@"FPS"];
    // 添加到图标选择中
    option.legend = legend;
    
    /** 直角坐标系内绘图网格, 说明见下图 */
    PYGrid *grid = [[PYGrid alloc] init];
    // 左上角位置
    grid.x = @(45);
    grid.y = @(20);
    // 右下角位置
    grid.x2 = @(20);
    grid.y2 = @(30);
    grid.borderWidth = @(0);
    // 添加到图标选择中
    option.grid = grid;
    /** X轴设置 */
    PYAxis *xAxis = [[PYAxis  alloc] init];
    //横轴默认为类目型(就是坐标自己设置)
    xAxis.type = @"category";    // 起始和结束两端空白
    xAxis.boundaryGap = @(YES);    // 分隔线
    xAxis.splitLine.show = NO;    // 坐标轴线
    xAxis.axisLine.show = NO;    // X轴坐标数据
    //
    xAxis.data = [self.arrData valueForKeyPath:@"index"];
    // 坐标轴小标记
    xAxis.axisTick = [[PYAxisTick alloc] init];
    xAxis.axisTick.show = YES;    // 添加到图标选择中
    option.xAxis = [[NSMutableArray alloc] initWithObjects:xAxis, nil];
    
    /** Y轴设置 */
    PYAxis *yAxis = [[PYAxis alloc] init];
    yAxis.axisLine.show = NO;
    // 纵轴默认为数值型(就是坐标系统生成), 改为 @"category" 会有问题, 读者可以自行尝试
    yAxis.type = @"value";    // 分割段数，默认为5
    yAxis.splitNumber = @4;    // 分割线类型
    
    // 添加到图标选择中  ( y轴更多设置, 自行查看官方文档)
    option.yAxis = [[NSMutableArray alloc] initWithObjects:yAxis, nil];
    
    /** 定义坐标点数组 */
    NSMutableArray *seriesArr = [NSMutableArray array];
    /** 第一条折线设置 */
    PYCartesianSeries *series1 = [[PYCartesianSeries alloc] init];
    series1.name = @"CPU";    // 类型为折线
    series1.type = @"line";    // 曲线平滑
    series1.smooth = YES;
    // 坐标点大小
    series1.symbolSize = @(1.5);
    // 坐标点样式, 设置连线的宽度
    series1.itemStyle = [[PYItemStyle alloc] init];
    series1.itemStyle.normal = [[PYItemStyleProp alloc] init];
    series1.itemStyle.normal.lineStyle = [[PYLineStyle alloc] init];
    series1.itemStyle.normal.lineStyle.width = @(1.5);
    // 添加坐标点 y 轴数据 ( 如果某一点 无数据, 可以传 @"-" 断开连线 如 : @[@"7566", @"-", @"7571"]  )
    
    series1.data = [self.arrData valueForKeyPath:@"cpuUsage"];
    [seriesArr addObject:series1];
    /** 第二条折线设置 */
    PYCartesianSeries *series2 = [[PYCartesianSeries alloc] init];
    series2.name = @"FPS";
    series2.type = @"line";
    series2.symbolSize = @(1.5);
    series2.itemStyle = [[PYItemStyle alloc] init];
    series2.itemStyle.normal = [[PYItemStyleProp alloc] init];
    series2.itemStyle.normal.lineStyle = [[PYLineStyle alloc] init];
    series2.itemStyle.normal.lineStyle.width = @(1.5);
    series2.data = [self.arrData valueForKeyPath:@"fps"];
    [seriesArr addObject:series2];
    [option setSeries:seriesArr];
    // 图表选项添加到图表上
    [self.kEchartView setOption:option];
}

- (void)setArrData:(NSArray *)arrData {
    _arrData = arrData;
    [self showBrokenLine];
    [self.kEchartView loadEcharts];
}

- (void)dealloc {
    [self.kEchartView removeHandlerForAction:PYEchartActionClick];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
