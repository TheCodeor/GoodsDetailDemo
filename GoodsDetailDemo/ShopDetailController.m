//
//  ShopDetailController.m
//  YiDaoHuo
//
//  Created by Sunny Zhang on 16/8/26.
//  Copyright © 2016年 ZhaiJia. All rights reserved.
//

#import "ShopDetailController.h"

#import "CXWebView.h"
#import "AddToCarView.h"
#import "DetailBuyView.h"
#import "DetailBuyView.h"
#import "CollectButton.h"
#import "RefundExplainView.h"
#import "SDCycleScrollView.h"
#import "FPCycleScrollView.h"
#import "DetailTopChooseView.h"

#import "Util.h"
#import "Masonry.h"
#import "APIClient.h"
#import "AppDelegate.h"
#import "ShoppingCart.h"
#import "LoginStateHelp.h"

#import "UIImageView+WebCache.h"
#import "UIButton+ImageTitleSpacing.h"
#import "NSDecimalNumber+MathEnhance.h"

#define DetailOffSet (UIScreenWidth + 179 - 39 - 44)
#define AlphaOffSet (UIScreenWidth - 39 - 44 - 20)

@interface ShopDetailController ()
<UIWebViewDelegate,
AddToCarViewDelegate,
SDCycleScrollViewDelegate,
DetailTopChooseViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollContentView;
@property (nonatomic, weak) IBOutlet UIView *iconView;
@property (nonatomic, weak) IBOutlet UIView *customNavView;
@property (nonatomic, weak) IBOutlet UILabel *customTitleLabel;
@property (nonatomic, weak) IBOutlet DetailTopChooseView *chooseView;
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet CollectButton *collectButton;
@property (nonatomic, weak) IBOutlet UILabel *lblOrigPrice;//价格
@property (nonatomic, weak) IBOutlet UILabel *lbStore;     //库存
@property (nonatomic, weak) IBOutlet UILabel *lbGuige;     //规格
@property (nonatomic, weak) IBOutlet UILabel *lbBrand;     //品牌
@property (nonatomic, weak) IBOutlet UIButton *addShopCarButton;
@property (nonatomic, weak) IBOutlet UIImageView *detailImgView;  
@property (nonatomic, weak) IBOutlet CXWebView *webView;   //图文详情
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *webViewHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imgIconTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgIconBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imgIconHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imgIconWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *detailImgHeight;

@property (nonatomic, strong) FPCycleScrollView *cycleView;
@property (nonatomic, strong) SGoods *goods;
@property (nonatomic, strong) NSArray *imagesArr;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) CGFloat detailOffsetY;

@end

@implementation ShopDetailController

- (CGFloat)detailOffsetY {
   
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
    
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)setSubviews {
    self.chooseView.chooseViewDelegate = self;
    WeakObj(self);
    self.collectButton.didSelectedButton = ^(SGoods *goods) {
        MLLog(@"%@",goods.goods_id);
        if (weakself.changeCollectTypeBlock) {
            weakself.changeCollectTypeBlock(goods);
        }
    };
}
#pragma mark init
- (instancetype)initWithGoodID:(NSString *)goods_id {
  
    self = [super init];
    if (self) {
        
        self.goods_id = goods_id;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self layoutImgIcon];
    [self setCycleView];
    [self requestGoodsDetails];
    [self setSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshNavigationBar];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.scrollContentView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [MobClick event:@"commodityDetails"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.scrollContentView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

}
#pragma mark  request
-(void)requestGoodsDetails {
    
    if (![Util networkCanUse]) {
        [MBProgressHUD showTips:@"请检测网络"];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDMessage:LOADING toView:nil];
    WeakObj(self);
    [[APIClient sharedClient] getGoodsDetails:self.goods_id
                             showErrorMessage:YES
                                        success:^(NSURLSessionDataTask *task, NSUInteger code, NSString *message, SGoods *goods, SSupplier *supplier) {
                                            weakself.goods = goods;
                                            [hud hideAnimated:YES];
                                        }  serverDataFailure:^(NSInteger code, NSString *msg) {
                                            [hud hideAnimated:YES];
                                        } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                            [hud hideAnimated:YES];
                                        }];
}

- (void)setGoods:(SGoods *)goods {
   
    _goods = goods;
    
    _customTitleLabel.text = goods.name;
    
    _lblTitle.text = goods.name;
    
    _lblOrigPrice.attributedText = [goods gainShowPrice];
   
    _collectButton.goods = goods;
    
    _lbBrand.text = goods.brand_name;
    
    _lbGuige.text = [NSString stringWithFormat:@"箱规格 %@ *%ld包",goods.norms, (long)goods.box_num];
    
    _lbStore.text = [NSString stringWithFormat:@"%ld 箱",(long)goods.stock/goods.box_num];
        
    _cycleView.imageURLStringsGroup = goods.imgArr;
    _cycleView.currentPage = 1;

    if (goods.brief.length) {
        [_webView loadHTMLString:goods.brief baseURL:nil];
        MLLog(@"loadeHtmlString:%@",goods.brief);
    } else {
        _detailImgView.hidden = YES;
        _detailImgHeight.constant = 1.0f;
    }
    
    if (goods.stock == 0) {
        _addShopCarButton.userInteractionEnabled = NO;
        [_addShopCarButton setBackgroundColor:[UIColor grayColor]];
    } else {
        _addShopCarButton.userInteractionEnabled = YES;
        [_addShopCarButton setBackgroundColor:UIPriceColor];
    }
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

#pragma mark actions
- (IBAction)btnAddToCartClick:(UIButton *)sender {
    
    if ([SUser isNeedLogin]) {
        [LoginStateHelp showLoginVC:self success:nil];
        return;
    }

    AddToCarView *carView = [AddToCarView getInstanceWithGoods:self.goods delegate:self];
    [carView show];

    [self setMobCick];
}

#pragma AddToCarViewDelegate
- (void)showWithAddToCarViewDelegate:(AddToCarView *)carView {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)cancelWithAddToCarViewDelegate:(AddToCarView *)carView {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (IBAction)goShopCar:(id)sender {
    
    self.tabBarController.selectedIndex = 2;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark DetailTopChooseViewDelegate
- (void)clickGoodsButton:(UIButton *)button {
    [self.scrollContentView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)clickDetailButton:(UIButton *)button {
    [self.scrollContentView setContentOffset:CGPointMake(0, self.detailOffsetY) animated:YES];
}

- (void)scaleIconImage:(CGFloat)offsetY {
    
    self.imgIconTop.constant    = offsetY;
    self.imgIconHeight.constant = -offsetY+UIScreenWidth;
    self.imgIconWidth.constant  = -offsetY+UIScreenWidth;
    [self.scrollContentView layoutIfNeeded];
    
    [self.cycleView scrollToItemAtIndex:self.currentIndex];
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
    MLLog(@"%@",NSStringFromCGPoint(offset));
    CGFloat offsetY = offset.y;
    if (offset.y < 0) {
       
        [self scaleIconImage:offsetY];
        
    } else {
        
        // 通过offset.y与 图片高度 减去自定义头部高度再减去图片下标的偏移量 比例来决定透明度
        CGFloat alpha = MIN(1, fabs(offsetY/(AlphaOffSet - offsetY)));
        self.customNavView.alpha = alpha;
        self.customTitleLabel.alpha = alpha;
        
        //偏移量超过一定程度就不用改变 否则影响整体滑动，如果不存在商品详情也停止滑动
        if (offsetY <= DetailOffSet - self.detailOffsetY && self.goods.brief.length && _webView.hidden == NO) {
            self.imgIconBottom.constant = -offsetY;
            self.cycleView.pageNumberLabelOffset = offsetY;
        }
        
        if (offsetY >= DetailOffSet - self.detailOffsetY) {
            [self.chooseView selectDetailButton];
        } else {
            [self .chooseView selectGoodsButton];
        }
    }
}

- (void)setMobCick {
    [MobClick event:@"detailsShopping"];
    [MobClick event:@"TR_joinShopping"];
    [MobClick event:@"HB_joinShopping"];
    [MobClick event:@"HC_joinShopping"];
    [MobClick event:@"homeSearch_joinShopping"];
    [MobClick event:@"ification_joinShopping"];
    [MobClick event:@"ificationSearch_joinShopping"];
    [MobClick event:@"collection_joinShopping"];
}

@end
