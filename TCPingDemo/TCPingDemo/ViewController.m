//
//  ViewController.m
//  TCPingDemo
//
//  Created by 白永炳 on 16/12/27.
//  Copyright © 2016年 BYB. All rights reserved.
//

#import "ViewController.h"
#import "TCPingManager.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *delayLab;
@property (weak, nonatomic) IBOutlet UILabel *maxLab;
@property (weak, nonatomic) IBOutlet UILabel *minLab;
@property (weak, nonatomic) IBOutlet UILabel *avgLab;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    char *argv[]={"61.147.115.29"}; // 222.187.221.65:37018  // 61.147.115.29:27015
//    setup("27015", argv, 1);
    
    
}

- (IBAction)startPing:(UIButton *)sender {
    
    self.delayLab.text = @"";
    
    TCPingManager *manager = [TCPingManager sharedInstance];
    // ping 4 次 取平均 最大值 最小值
    [manager OTSTCPingWithHostName:@"222.187.221.65:37018" time:@(4) currentDelay:^(double delay) {

        NSLog(@"delay == %.2f", delay);
        NSString *delayStr = [_delayLab.text stringByAppendingString:[NSString stringWithFormat:@"\\%.2lf", delay]];
        self.delayLab.text = delayStr;
        [self.delayLab adjustsFontSizeToFitWidth];

        
    } success:^(double max, double min, double avg) {
        
        NSLog(@"max = %.2f, min = %.2f, avg = %.2f", max, min, avg);
        self.maxLab.text = [NSString stringWithFormat:@"%.2lf", max];
        self.minLab.text = [NSString stringWithFormat:@"%.2lf", min];
        self.avgLab.text = [NSString stringWithFormat:@"%.2lf", avg];

        
    } failed:^(NSString *errorInfo) {
        
        NSLog(@"errorInfo == %@", errorInfo);
        
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
