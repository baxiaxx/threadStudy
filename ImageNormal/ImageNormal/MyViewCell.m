//
//  MyViewCell.m
//  ImageNormal
//
//  Created by samuel on 13-11-25.
//  Copyright (c) 2013年 meandlife. All rights reserved.
//

#import "MyViewCell.h"

@interface MyViewCell()
@property (nonatomic, strong) UIImageView *cellImageView;
@end

@implementation MyViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 310, 310)];
        [self addSubview:imageView];
        self.cellImageView = imageView;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadImage:(NSString *)fname;
{
    NSLog(@"view cell fname: %@", fname);
    UIImage *image = [UIImage imageWithContentsOfFile:fname];
    self.cellImageView.image = image;
    //NSLog(@"--load image file: %f", total);
    //加载文件只需要4~5个毫秒
    
    /*注意由于重用机制，导致我们如果只是修改了这个image，那么这个cell view并不会被标记为重绘，所以只会显示前面的3张图片*/
    [self setNeedsDisplay];
}

@end
