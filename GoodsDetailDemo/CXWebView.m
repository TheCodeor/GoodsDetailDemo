//
//  CXWebView.m
//  htmlTest
//
//  Created by jone Green on 17/4/13.
//  Copyright © 2017年 jone Green. All rights reserved.
//

#import "CXWebView.h"

@implementation CXWebView

- (id)initWithFrame:(CGRect)frame {
    
    if(self  = [super initWithFrame:frame]){
        [self setKVO];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
 
    [self setKVO];
}

- (void)setKVO {
    //一次性设置
    self.scalesPageToFit = YES;
    self.userInteractionEnabled = YES;
    self.opaque = YES;
    [self.scrollView addObserver:self
                      forKeyPath:@"contentSize"
                         options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                         context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%@",change);
    CGSize size = [change[@"new"]CGSizeValue];
    self.webHeight = size.height;
}

- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}
@end
