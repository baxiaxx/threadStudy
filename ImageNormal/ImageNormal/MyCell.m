//
//  MyCell.m
//  ImageNormal
//
//  Created by samuel on 13-11-25.
//  Copyright (c) 2013年 meandlife. All rights reserved.
//

#import "MyCell.h"

@interface MyCell()
//@property (nonatomic, strong) UIImageView *cellImageView;
@property (nonatomic, strong) UIImage *cellImage;
@end

@implementation MyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        //UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 310, 310)];
        //[self.contentView addSubview:imageView];
        //self.cellImageView = imageView;
        // Initialization code
    }
    return self;
}

- (void)loadImage:(NSString *)fname
{
    NSLog(@"fname: %@", fname);
    double start = CFAbsoluteTimeGetCurrent();
    UIImage *image = [UIImage imageWithContentsOfFile:fname];
    //self.cellImageView.image = image;
    self.cellImage = image;
    double total = CFAbsoluteTimeGetCurrent() - start;
    //NSLog(@"--load image file: %f", total);
    //加载文件只需要4~5个毫秒
    
    /*注意由于重用机制，导致我们如果只是修改了这个image，那么这个cell view并不会被标记为重绘，所以只会显示前面的3张图片*/
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    double start = CFAbsoluteTimeGetCurrent();
    rect.origin.x = 5;
    rect.size.width = 310;
    rect.size.height = 310;
    [self.cellImage drawInRect:rect];
    double total = CFAbsoluteTimeGetCurrent() - start;
    NSLog(@"--draw image[%@] in %@: %f", NSStringFromCGSize(self.cellImage.size), NSStringFromCGSize(rect.size), total);
    //将1000x1000的图片绘制到310x310的矩形里面，需要大概180~190ms的时间，在touch4上面卡顿严重
}

@end
