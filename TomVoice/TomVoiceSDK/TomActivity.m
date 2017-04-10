//
//  LXActivity.m
//  LXActivityDemo
//
//  Created by lixiang on 14-3-17.
//  Copyright (c) 2014年 lcolco. All rights reserved.
//

#import "TomActivity.h"

#define WINDOW_COLOR                            [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]
#define ACTIONSHEET_BACKGROUNDCOLOR             [UIColor colorWithRed:106/255.00f green:106/255.00f blue:106/255.00f alpha:0.8]
#define ANIMATE_DURATION                        0.25f

#define CORNER_RADIUS                           5
#define SHAREBUTTON_BORDER_WIDTH                0.5f
#define SHAREBUTTON_BORDER_COLOR                [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8].CGColor
#define SHAREBUTTONTITLE_FONT                   [UIFont fontWithName:@"HelveticaNeue-Bold" size:18]

#define CANCEL_BUTTON_COLOR                     [UIColor colorWithRed:53/255.00f green:53/255.00f blue:53/255.00f alpha:1]

#define SHAREBUTTON_WIDTH                       50
#define SHAREBUTTON_HEIGHT                      50
#define SHAREBUTTON_INTERVAL_WIDTH              42.5
#define SHAREBUTTON_INTERVAL_HEIGHT             35

#define SHARETITLE_WIDTH                        50
#define SHARETITLE_HEIGHT                       20
#define SHARETITLE_INTERVAL_WIDTH               42.5
#define SHARETITLE_INTERVAL_HEIGHT              SHAREBUTTON_WIDTH+SHAREBUTTON_INTERVAL_HEIGHT
#define SHARETITLE_FONT                         [UIFont fontWithName:@"Helvetica-Bold" size:14]

#define TITLE_INTERVAL_HEIGHT                   15
#define TITLE_HEIGHT                            35
#define TITLE_INTERVAL_WIDTH                    30
#define TITLE_WIDTH                             260
#define TITLE_FONT                              [UIFont fontWithName:@"Helvetica-Bold" size:10]
#define SHADOW_OFFSET                           CGSizeMake(0, 0.8f)
#define TITLE_NUMBER_LINES                      2

#define BUTTON_INTERVAL_HEIGHT                  20
#define BUTTON_HEIGHT                           40
#define BUTTON_INTERVAL_WIDTH                   40
#define BUTTON_WIDTH                            240
#define BUTTONTITLE_FONT                        [UIFont fontWithName:@"HelveticaNeue-Bold" size:18]
#define BUTTON_BORDER_WIDTH                     0.5f
#define BUTTON_BORDER_COLOR                     [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8].CGColor


@interface UIImage (custom)

+ (UIImage *)imageWithColor:(UIColor *)color;

@end


@implementation UIImage (custom)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end

@interface TomActivity ()<AVAudioRecorderDelegate>
{
    UILabel *tipLabel;
}

@property (nonatomic,strong) UIView *backGroundView;
@property (nonatomic,assign) CGFloat TomActivityHeight;
@property (nonatomic,assign) id<TomActivityDelegate>delegate;
@property (nonatomic,strong) SpectrumView * spectrumView;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) NSInteger miao;

@end

@implementation TomActivity

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Public method

- (id)initWithTitle:(NSString *)title delegate:(id<TomActivityDelegate>)delegate height:(CGFloat)heigt
{
    self = [super init];
    if (self) {
        //初始化背景视图，添加手势
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.backgroundColor = WINDOW_COLOR;
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
        [self addGestureRecognizer:tapGesture];
        
        if (delegate) {
            self.delegate = delegate;
        }
        if (heigt==0) {
            self.TomActivityHeight = 200;
        }else
        {
            self.TomActivityHeight = heigt;
        }
        [self creatButtonsWithTitle:title];
        
    }
    return self;
}

- (void)showInView:(UIView *)view
{
    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
}

#pragma mark - Praviate method

- (void)creatButtonsWithTitle:(NSString *)title
{
    
    //生成TomActionSheetView
    self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
    self.backGroundView.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.backGroundView];
    
    self.spectrumView = [[SpectrumView alloc] initWithFrame:CGRectMake(CGRectGetMidX([UIScreen mainScreen].bounds)-100,10,200, 50.0)];
    self.spectrumView.text = [NSString stringWithFormat:@"%d",0];
    
    __weak SpectrumView * weakSpectrum1 =  self.spectrumView;
    __weak __typeof(&*self)weakSelf = self;
    self.spectrumView.itemLevelCallback = ^() {
        
        [weakSelf.audioRecorder updateMeters];
        //取得第一个通道的音频，音频强度范围时-160到0
        float power= [weakSelf.audioRecorder averagePowerForChannel:0];
        weakSpectrum1.level = power;
    };
    [self.backGroundView addSubview:self.spectrumView];
    
    
    [self.backGroundView addSubview:[self setRecordButton]];
    
    
    [self setTipLabel];
    
    self.spectrumView.hidden = YES;
    
    tipLabel.text = @"点击录音";
    
    self.spectrumView.timeLabel.text = @"准备中";
    
    [self.spectrumView.timeLabel setFont:[UIFont systemFontOfSize:10]];
    
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        [self.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-self.TomActivityHeight, [UIScreen mainScreen].bounds.size.width, self.TomActivityHeight)];
    } completion:^(BOOL finished) {
    }];
}





- (void)tappedCancel
{
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        [self.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}


- (UIButton*)setRecordButton
{
    UIButton *recordButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMidX([UIScreen mainScreen].bounds)-40, 60, 80, 80)];
    
    [recordButton setBackgroundImage:[UIImage imageNamed:@"voicestar"] forState:UIControlStateNormal];
 
    [recordButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];

    
    return recordButton;
}

- (void)setTipLabel
{
    tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10,[UIScreen mainScreen].bounds.size.width,30)];
    tipLabel.textColor = [UIColor lightGrayColor];
    [tipLabel setTextAlignment:NSTextAlignmentCenter];
    [self.backGroundView addSubview:tipLabel];
}

-(void)timeRun
{
    self.miao++;
    
    self.spectrumView.timeLabel.text = [NSString stringWithFormat:@"%ld秒",(long)self.miao];
}

- (void)buttonClick:(UIButton *)button
{
    
    
    if (self.status ==VoiceStatusLuyinStar) {
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeRun) userInfo:nil repeats:YES];
        
        self.spectrumView.hidden = NO;
        
        tipLabel.hidden = YES;
        
        [self recordStart:button];
        
        self.status = VoiceStatusLuyinIng;
        
        [button setBackgroundImage:[UIImage imageNamed:@"voiceing"] forState:UIControlStateNormal];
        
        
    }else if (self.status ==VoiceStatusLuyinIng)
    {
        [self recordFinish:button];
        
        [self.timer invalidate];
        
        self.status = VoiceStatusLuyinEnd;
        
        [self addActiviButton];
        
        [button setBackgroundImage:[UIImage imageNamed:@"voiceend"] forState:UIControlStateNormal];
    }
    
    
}

-(void)addActiviButton
{
    
    UIButton *cancel = [[UIButton alloc]init];
    [cancel setFrame:CGRectMake(0, self.backGroundView.frame.size.height-30, self.backGroundView.frame.size.width/2, 30)];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    cancel.layer.borderWidth=.5;
    cancel.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    [cancel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchDown];
    cancel.tag=0;
    [self.backGroundView addSubview:cancel];
    UIButton *send = [[UIButton alloc]init];
    send.layer.borderWidth=.5;
    send.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    [send setFrame:CGRectMake(self.backGroundView.frame.size.width/2, self.backGroundView.frame.size.height-30, self.backGroundView.frame.size.width/2, 30)];
    [send setTitle:@"发送" forState:UIControlStateNormal];
    [send addTarget:self action:@selector(sendClick:) forControlEvents:UIControlEventTouchDown];
    send.tag=1;
    [send setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.backGroundView addSubview:send];
    
}

-(void)cancelClick
{
    [self tappedCancel];
    
}
-(void)sendClick:(UIButton *)button
{
    if (self.delegate) {
        
        [self.delegate didClickOnButtonWithUrl:[self getSavePath]];
    }
     [self tappedCancel];
    
}


- (void)recordStart:(UIButton *)button
{
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        //7.0第一次运行会提示，是否允许使用麦克风
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *sessionError;
        //AVAudioSessionCategoryPlayAndRecord用于录音和播放
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        if(session == nil)
            NSLog(@"Error creating session: %@", [sessionError description]);
        else
            [session setActive:YES error:nil];
    }
    
    if (![self.audioRecorder isRecording]) {
        
        [self.audioRecorder record];
        [self.audioRecorder record];
        tipLabel.text = @"正在录音";
        NSLog(@"录音开始");
        
    }
    
}


- (void)recordCancel:(UIButton *)button
{
    
    if ([self.audioRecorder isRecording]) {
        
        NSLog(@"取消");
        [self.audioRecorder stop];
        tipLabel.text = @"";
        
    }
}

- (void)recordFinish:(UIButton *)button
{
    
    if ([self.audioRecorder isRecording]) {
        
        NSLog(@"完成");
        [self.audioRecorder stop];
        tipLabel.text = @"";
        
    }
    
}

- (void)recordTouchDragExit:(UIButton *)button
{
    if([self.audioRecorder isRecording]){
        tipLabel.text = @"松开取消";
    }
}

- (void)recordTouchDragEnter:(UIButton *)button
{
    if([self.audioRecorder isRecording]){
        tipLabel.text = @"正在录音";
    }
}



/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url=[self getSavePath];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath{
    //  在Documents目录下创建一个名为FileData的文件夹
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"AudioData"];
    NSLog(@"%@",path);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if(!(isDirExist && isDir))
        
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建文件夹失败！");
        }
        NSLog(@"创建文件夹成功，文件路径%@",path);
    }
    
    path = [path stringByAppendingPathComponent:@"myRecord.aac"];
    NSLog(@"file path:%@",path);
    //:/var/mobile/Containers/Data/Application/543E94B4-4DC2-4A14-8657-68D705251F73/Documents/AudioData/
    NSURL *url=[NSURL fileURLWithPath:path];
    return url;
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    
    
}


@end
