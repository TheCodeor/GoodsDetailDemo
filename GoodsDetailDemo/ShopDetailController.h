//
//  ShopDetailController.h
//  YiDaoHuo
//
//  Created by Sunny Zhang on 16/8/26.
//  Copyright © 2016年 ZhaiJia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface ShopDetailController : BaseVC

@property (nonatomic, strong) void(^changeCollectTypeBlock)(SGoods *goods);
@property(nonatomic,strong)NSString *goods_id;

@property (nonatomic, strong) NSMutableArray <SCarSeller *>*shoppingList;

- (instancetype)initWithGoodID:(NSString *)goods_id;

@end
