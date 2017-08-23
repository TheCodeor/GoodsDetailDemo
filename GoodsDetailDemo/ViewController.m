//
//  ViewController.m
//  GoodsDetailDemo
//
//  Created by fanpeng on 2017/8/22.
//  Copyright © 2017年 fanpeng. All rights reserved.
//

#import "ViewController.h"
#import "ShopDetailController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)showGoodsDetailVC:(id)sender {
    
    ShopDetailController *vc = [[ShopDetailController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
