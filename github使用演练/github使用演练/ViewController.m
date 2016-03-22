//
//  ViewController.m
//  github使用演练
//
//  Created by lumf on 16/3/22.
//  Copyright © 2016年 lumf. All rights reserved.
//

#import "ViewController.h"
#import "RACSignal.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController ()
@property (nonatomic, strong) NSString *racString;
@property (weak, nonatomic) IBOutlet UITextField *racTF;
@property (weak, nonatomic) IBOutlet UILabel *racL;
@property (weak, nonatomic) IBOutlet UIButton *myBtn;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"老账号");
    self.view.backgroundColor = [UIColor yellowColor];
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height+50);
    [self.view addSubview:scrollView];
    
    UIView *redView = [[UIView alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
    redView.backgroundColor = [UIColor redColor];
    [scrollView addSubview:redView];
    
    [[[RACObserve(scrollView, contentOffset) map:^id(id value) {
//        NSLog(@"value:%@",value);
//        CGPoint pointV = CGPointFromString(value);
        if (scrollView.contentOffset.y<-20) {
            return @"1";
        }else if(scrollView.contentOffset.y>30){
            return @"2";
        }
        return nil;
    }] distinctUntilChanged] subscribeNext:^(id x) {
        if ([x intValue]==1) {
            NSLog(@"下拉刷新");
        }else if([x intValue]==2){
            NSLog(@"上啦刷新");
        }
    }];
}

-(void)test{
    //1、监听textField的内容变化
    [self.racTF.rac_textSignal subscribeNext:^(id x) {
        self.racL.text = x;
    }];
    
    [[self.racTF.rac_textSignal filter:^BOOL(id value) {
        return [value length]>3;
    }] subscribeNext:^(id x) {
        self.racL.backgroundColor = [UIColor redColor];
    }];
    
    [[[self.racTF.rac_textSignal map:^id(id value) {
        return @([value length]);
    }] filter:^BOOL(id value) {
        return [value integerValue]>5;
    }] subscribeNext:^(id x) {
        self.racL.backgroundColor = [UIColor yellowColor];
    }];
    
    [[self.racTF rac_signalForControlEvents:UIControlEventEditingChanged] subscribeNext:^(id x) {
        NSLog(@"EditingChanged----%@",x);
    }];
    
    //2、监听按钮的点击
    [[self.myBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"myBtn:%@",x);
    }];
    
    //3、手势
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]init];
    [tapGes.rac_gestureSignal subscribeNext:^(id x) {
        NSLog(@"tap-------");
    }];
    [self.view addGestureRecognizer:tapGes];
    
    //4、UIAlertViw
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"view" message:@"subview---" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [[alertView rac_buttonClickedSignal] subscribeNext:^(id x) {
        NSLog(@"xxxxxx:%@",x);
    }];
    [alertView show];
    
    //5、通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"postdata" object:@"name"];
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:@"postdata" object:nil] subscribeNext:^(NSNotification* x) {
        NSLog(@"object:%@",x.object);
        NSLog(@"name:%@",x.name);
        
    }];
    
    //6、KVO
    UIScrollView *scrolView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 200, 400)];
    scrolView.contentSize = CGSizeMake(200, 800);
    scrolView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:scrolView];
    [RACObserve(scrolView, contentOffset) subscribeNext:^(id x) {
        NSLog(@"success");
    }];
    
    
    /////////
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:self.racString];
        return nil;
    }];
    [signal subscribeNext:^(id x) {
        NSLog(@"订阅了信号：%@",x);
    }];
}

@end
