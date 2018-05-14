//
//  ViewController.m
//  GCDDemo
//
//  Created by gaochongyang on 2018/5/14.
//  Copyright © 2018年 gaochongyang. All rights reserved.
//

#import "ViewController.h"
#import "GCDTestViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIButton *imageButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    _imageButton.backgroundColor = [UIColor blueColor];
    [_imageButton setTitle:@"click" forState:UIControlStateNormal];
    [_imageButton addTarget:self action:@selector(showImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_imageButton];
    
}

- (void)showImage:(UIButton *)sender {
    
    GCDTestViewController *VC = [[GCDTestViewController alloc] init];
    [self presentViewController:VC animated:YES completion:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
