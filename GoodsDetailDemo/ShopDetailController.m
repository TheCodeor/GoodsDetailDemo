//
//  ShopDetailController.m
//  YiDaoHuo
//
//  Created by Sunny Zhang on 16/8/26.
//  Copyright © 2016年 ZhaiJia. All rights reserved.
//

#import "ShopDetailController.h"

#import "CXWebView.h"
#import "SDCycleScrollView.h"
#import "FPCycleScrollView.h"
#import "SDAutoLayout.h"
#import "CustomNavView.h"

#define UIScreenWidth [UIScreen mainScreen].bounds.size.width
#define UIScreenHeight [UIScreen mainScreen].bounds.size.height

#define UI_IS_LANDSCAPE             ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)
#define UI_IS_IPAD                  ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define UI_IS_IPHONE                ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define UI_IS_IPHONE4               (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height < 568.0)
#define UI_IS_IPHONE5               (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define UI_IS_IPHONE6_OR_7          (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define UI_IS_IPHONE6PLUS_OR_7PLUS  (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0 || [[UIScreen mainScreen] bounds].size.width == 736.0) // Both orientations
#define UI_IS_IOS8_AND_HIGHER   ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)


#define DetailOffSet (UIScreenWidth + 179 - 39 - 44)
#define AlphaOffSet (UIScreenWidth - 39 - 44 - 20)

@interface ShopDetailController ()
<UIWebViewDelegate,
SDCycleScrollViewDelegate,
CustomNavViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollContentView;
@property (nonatomic, weak) IBOutlet UIView *iconView;
@property (nonatomic, weak) IBOutlet CustomNavView *customNavView;
@property (nonatomic, weak) IBOutlet CXWebView *webView;   //图文详情
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *webViewHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imgIconTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgIconBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imgIconHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imgIconWidth;

@property (nonatomic, strong) FPCycleScrollView *cycleView;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) CGFloat detailOffsetY;

@end

@implementation ShopDetailController

- (CGFloat)detailOffsetY {
   
    //这个应该是可以计算出来的 ，还没想出来
    if (UI_IS_IPHONE4 || UI_IS_IPHONE5) {
        _detailOffsetY = 210;
    } else if (UI_IS_IPHONE6_OR_7) {
        _detailOffsetY = 236;
    } else if (UI_IS_IPHONE6PLUS_OR_7PLUS){
        _detailOffsetY = 260;
    } else {
        _detailOffsetY = 236;
    }
 
    return _detailOffsetY;
}

- (IBAction)custonBackButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)layoutImgIcon {
    
    self.currentIndex = 0;
    self.imgIconHeight.constant = UIScreenWidth;
    self.imgIconWidth.constant = UIScreenWidth;
    [self.scrollContentView layoutIfNeeded];
}

- (void)setCycleView {
    _cycleView = [FPCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenWidth)
                                                    delegate:self
                                            placeholderImage:[UIImage imageNamed:@"ImgDefaultBig"]];
    _cycleView.backgroundColor = [UIColor whiteColor];
    _cycleView.autoScroll = NO;
    _cycleView.infiniteLoop = NO;
    _cycleView.showPageControl = NO;
    _cycleView.showPageNumberLabel = YES;

    [_iconView addSubview:_cycleView];
    _cycleView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.customNavView.customNavViewDelegate = self;
    [self layoutImgIcon];
    [self setCycleView];
    [self setGoods];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self refreshNavigationBar];

    [self.scrollContentView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
   
    [self.scrollContentView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)setGoods {
   
    NSArray *imagesArray = @[@"http://image.o2o.zhaioto.com/wholesale/goodsstandard/991001/991001002/c8f1e6578357dc9d52815fdb21b09d13.jpg",
                             @"http://image.o2o.zhaioto.com/wholesale/goodsstandard/991001/991001002/9a28791abbff196ec53468e851d8039b.jpg",
                             @"http://image.o2o.zhaioto.com/wholesale/goodsstandard/991001/991001002/9edbb56933713cfc8701add343f1780b.jpg"];
        
    _cycleView.imageURLStringsGroup = imagesArray;
    _cycleView.currentPage = 1;

    NSString *htmlString = @"<img src=\"http://mingtesst.img-cn-shanghai.aliyuncs.com/wholesale/goodsstandard/991001/991001002/brief/fda6c42659102107a3baed1796cc55db.jpg\" alt=\"\" />";
    [_webView loadHTMLString:htmlString baseURL:nil];

    
 }

#pragma mark UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {

    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width;initial-scale=1.0; maximum-scale=1.0; user-scalable=0;'); document.getElementsByTagName('head')[0].appendChild(meta);";
    //添加JS
    [webView stringByEvaluatingJavaScriptFromString:jScript];
    
    _webView.hidden = NO;
    _webViewHeight.constant = _webView.webHeight;
}

#pragma mark SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index {
    self.currentIndex = index;
    self.cycleView.currentPage = index + 1;
}


#pragma mark DetailTopChooseViewDelegate
- (void)clickGoodsButton:(UIButton *)button {
    [self.scrollContentView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)clickDetailButton:(UIButton *)button {
    [self.scrollContentView setContentOffset:CGPointMake(0, self.detailOffsetY) animated:YES];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if ([object isEqual:self.scrollContentView] && [keyPath isEqualToString:@"contentOffset"]) {
        [self refreshNavigationBar];
    }
}


#pragma mark NavigationBar
- (void)refreshNavigationBar {
    
    CGPoint offset = self.scrollContentView.contentOffset;
    NSLog(@"%@",NSStringFromCGPoint(offset));
    CGFloat offsetY = offset.y;
    if (offset.y < 0) {
       
        //下拉放大图片
        self.imgIconTop.constant    = offsetY;
        self.imgIconHeight.constant = -offsetY+UIScreenWidth;
        self.imgIconWidth.constant  = -offsetY+UIScreenWidth;
        [self.scrollContentView layoutIfNeeded];
        [self.cycleView scrollToItemAtIndex:self.currentIndex];
        
    } else {
        
        //通过offset.y与 图片高度 减去自定义头部高度再减去图片下标的偏移量 比例来决定透明度
        CGFloat alpha = MIN(1, fabs(offsetY/(AlphaOffSet - offsetY)));
        self.customNavView.alpha = alpha;
        //偏移量超过一定程度就不用改变 否则影响整体滑动，如果不存在商品详情也停止滑动
        if (offsetY <= DetailOffSet - self.detailOffsetY && _webView.hidden == NO) {
            self.imgIconBottom.constant = -offsetY;
            self.cycleView.pageNumberLabelOffset = offsetY;
        }
        
        if (offsetY >= DetailOffSet - self.detailOffsetY) {
            [self.customNavView selectDetailButton];
        } else {
            [self.customNavView selectGoodsButton];
        }
    }
}


@end
