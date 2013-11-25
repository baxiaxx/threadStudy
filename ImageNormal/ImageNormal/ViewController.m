//
//  ViewController.m
//  ImageNormal
//
//  Created by samuel on 13-11-25.
//  Copyright (c) 2013年 meandlife. All rights reserved.
//

#import "ViewController.h"
#import "MyCell.h"
#import "MyViewCell.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.layer.borderWidth = 1;
    
	// Do any additional setup after loading the view, typically from a nib.
    CGRect frame = [UIScreen mainScreen].bounds;
    UITableView *table = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    //table.layer.borderWidth = 1;
    //table.layer.borderColor = [UIColor redColor].CGColor;
    [self.view addSubview:table];
    self.tableView = table;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //MyCell里面用重载了drawRect函数，自己绘制图片，而MyViewCell里面是加了一个UIImageView，设置image，结果效率高了很多，自己绘制的模式即使是在4S上面，也需要230ms绘制一个图片，而用系统的UIImageView滑动起来毫无压力
    //是系统做了优化吗？我们自己可不可以做到呢？
    
#if 1
    MyCell *cell = (MyCell *)[tableView dequeueReusableCellWithIdentifier:@"ImageNormal"];
    
    if (cell == nil)
    {
        cell = [[MyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ImageNormal"];
    }
#else

    MyViewCell *cell = (MyViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ImageNormal"];
    
    if (cell == nil)
    {
        cell = [[MyViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ImageNormal"];
    }
    
#endif
    NSString *fname = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d", indexPath.row + 1] ofType:@"jpg"];
    //注意这里模拟的是网络下载的图片，只能从文件加载，imageWithContentsOfFile没有对图片进行cache，cache需要自己维护
    //另外，这个测试在4S及以上机型不会有卡顿，在iPhone4，以及touch4等配置机型上面有卡顿效果，原理是一样的，用线程来解决滑动的卡顿问题
    //UIImage *image = [UIImage imageNamed:fname];
    
    [cell loadImage:fname];
    
    //cell.layer.borderWidth = 1;
    //cell.layer.borderColor = [UIColor redColor].CGColor;

    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 330.0;
}

@end
