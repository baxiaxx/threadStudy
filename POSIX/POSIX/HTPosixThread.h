//
//  HTPosixThread.h
//  threadStudy
//
//  Created by samuel on 13-10-29.
//  Copyright (c) 2013年 meandlife. All rights reserved.
//

#import <Foundation/Foundation.h>

void pthread_test(void);

//主线程初始化
void *safe_buffer_init(void);

//生产者插入数据
void safe_buffer_insert(void *handle, int value);

//消费者取出数据并删除
int safe_buffer_remove(void *handle);
