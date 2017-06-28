//
//  ViewController.m
//  LookAtSearchFor
//
//  Created by Ruiwen Feng on 2017/6/28.
//  Copyright © 2017年 Ruiwen Feng. All rights reserved.
//

#import "ViewController.h"
#import "SearchLookAtFunction.h"
@interface ViewController ()
@property (strong,nonatomic) SearchLookAtFunction * lookAtSquareView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frame = self.view.frame;
    frame.origin.y = 20;
    frame.size.height = frame.size.width;
    _lookAtSquareView = [[SearchLookAtFunction alloc]initWithFrame:frame];
    [self.view addSubview:_lookAtSquareView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click)];
    tap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void)click {
    [_lookAtSquareView disPlay];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
