//
//  ViewController.m
//  TomVoice
//
//  Created by tom on 2017/4/10.
//  Copyright © 2017年 tom. All rights reserved.
//

#import "ViewController.h"
#import "TomActivity.h"
@interface ViewController ()<TomActivityDelegate>
@property (weak, nonatomic) IBOutlet UIButton *luyinClick;
- (IBAction)luyin:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)luyin:(id)sender {
    
    TomActivity *lxActivity = [[TomActivity alloc] initWithTitle:@"准备录音" delegate:self height:0];
    
    [lxActivity showInView:self.view];
    
}
- (void)didClickOnButtonWithUrl:(NSURL *)url
{
    
    NSLog(@"文件存放在%@",url.absoluteString);
}
@end
