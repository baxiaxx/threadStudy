//
//  HTPosixThread.m
//  threadStudy
//
//  Created by samuel on 13-10-29.
//  Copyright (c) 2013年 meandlife. All rights reserved.
//

#import "HTPosixThread.h"
#import <pthread.h>
#import <semaphore.h>

#define MAX_SAFE_BUFFER_SIZE (10 + 1) //为了判空,一个空间多余

#define lock(sem) sem_wait((sem))
#define unlock(sem) sem_post((sem))

typedef struct
{
    int buffer[MAX_SAFE_BUFFER_SIZE];
    int front;
    int rear;
    
    sem_t *buffer_lock; //保护buffer
    sem_t *slot; //空槽，初始值为MAX_SAFE_BUFFER_SIZE，如果满了生产者等待，消费者释放
    sem_t *items; //数据项，初始值为空, 消费者等待，生产者释放
    
} safe_buffer_struct;

static void *consumer(void *param)
{
    pthread_t tid = pthread_self();
    pthread_detach(tid);
    
    NSLog(@"I'm thread: 0x%x", tid);
    
    while (1)
    {
        int value = safe_buffer_remove(param);
        NSLog(@"0x%x: I got value: %d", tid, value);
    }
    
    return 0;
}

static void *producer(void *param)
{
    pthread_t tid = pthread_self();
    pthread_detach(tid);
    
    NSLog(@"I'm thread: 0x%x", tid);
    
    while (1)
    {
        int value = arc4random() % 10;
        safe_buffer_insert(param, value);
        NSLog(@"0x%x: I make value: %d", tid, value);
        sleep(1);
    }
    
    return 0;
}

void pthread_test(void)
{
    void *handle = safe_buffer_init();
    
    //创建生产者
    for (int i = 0; i < 1; i++)
    {
        pthread_t tid;
        pthread_create(&tid, NULL, producer, handle);
    }
    
    //创建消费者
    for (int i = 0; i < 5; i++)
    {
        pthread_t tid;
        pthread_create(&tid, NULL, consumer, handle);
    }
}

void *safe_buffer_init(void)
{
    safe_buffer_struct *p = (safe_buffer_struct *)malloc(sizeof(safe_buffer_struct));
    if (p)
    {
        p->rear = 0;
        p->front = 0;
        
        sem_t *sem = sem_open("ht_buffer_lock", O_CREAT, 0644, 1); //iOS上面不支持无名信号, 不能用sem_init
        if (sem == SEM_FAILED)
        {
            NSLog(@"create sem error: %s", strerror(errno));
        }
        p->buffer_lock = sem;

        sem = sem_open("ht_buffer_full", O_CREAT, 0644, MAX_SAFE_BUFFER_SIZE);
        if (sem == SEM_FAILED)
        {
            NSLog(@"create sem error: %s", strerror(errno));
        }
        p->slot = sem;
        
        sem = sem_open("ht_buffer_empty", O_CREAT, 0644, 0);
        if (sem == SEM_FAILED)
        {
            NSLog(@"create sem error: %s", strerror(errno));
        }
        p->items = sem;
    }
    
    return p;
}

//生产者插入数据
void safe_buffer_insert(void *handle, int value)
{
    safe_buffer_struct *p = (safe_buffer_struct *)handle;
    if (p)
    {
        lock(p->slot);          //等待空槽
        
        //插入数据
        lock(p->buffer_lock);
        p->buffer[p->rear] = value;
        p->rear = (p->rear++) % MAX_SAFE_BUFFER_SIZE;
        unlock(p->buffer_lock);
        
        unlock(p->items);       //数据已经准备好
    }
}

//消费者取出数据并删除
int safe_buffer_remove(void *handle)
{
    int value = -1;
    
    safe_buffer_struct *p = (safe_buffer_struct *)handle;
    if (p)
    {
        lock(p->items);         //等待数据
        
        //取出数据
        lock(p->buffer_lock);
        value = p->buffer[p->front];
        p->front = (p->front++) % MAX_SAFE_BUFFER_SIZE;
        unlock(p->buffer_lock);
        
        unlock(p->slot);        //空槽已经准备好
    }
    
    return value;
}

