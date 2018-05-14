//
//  GCDTestViewController.m
//  GCDDemo
//
//  Created by gaochongyang on 2018/5/14.
//  Copyright © 2018年 gaochongyang. All rights reserved.
//

#import "GCDTestViewController.h"

@interface GCDTestViewController () {
    dispatch_semaphore_t semaphore;
}
@property (nonatomic, assign) NSInteger ticketSurplusCount;

@end

@implementation GCDTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
   
//    [self syncConcurrent];
//    [self asyncConcurrent];
//    [self syncSerial];
//    [self asyncSerial];
//    [self syncMain];
//    [NSThread detachNewThreadSelector:@selector(syncMain) toTarget:self withObject:nil];
//    [self asyncMain];
    
//    [self communication];
//    [self barrier];
//    [self after];
//    [self apply];
//    [self groupNotify];
//    [self groupWait];
//    [self groupEnterAndLeave];
//    [self semaphoreSync];
//    [self initTicketStatusNotSave];
    [self initTicketStatusSave];
}
#pragma mark 信号量

- (void)initTicketStatusSave {
    NSLog(@"currentThread---%@", [NSThread currentThread]);
    NSLog(@"semaphoreSync--begin");
    
    semaphore = dispatch_semaphore_create(1);
    self.ticketSurplusCount = 50;
    dispatch_queue_t queue1 = dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("queue2", DISPATCH_QUEUE_SERIAL);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue1, ^{
        [weakSelf saleTicketSafe];
    });
    
    dispatch_async(queue2, ^{
        [weakSelf saleTicketSafe];
    });

}

- (void)saleTicketSafe {
    while (1) {
        // 相当于加锁
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        if (self.ticketSurplusCount > 0) {
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld, 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        } else {
            NSLog(@"已售完");
            // 相当于解锁
            dispatch_semaphore_signal(semaphore);
            break;
        }
        // 相当于解锁
        dispatch_semaphore_signal(semaphore);
    }
}
/**
 非线程安全
 */
- (void)initTicketStatusNotSave {
    NSLog(@"currentThread---%@", [NSThread currentThread]);
    NSLog(@"semaphoreSync--begin");
    
    self.ticketSurplusCount = 50;
    dispatch_queue_t queue1 = dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("queue2", DISPATCH_QUEUE_SERIAL);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue1, ^{
        [weakSelf saleTicketNotSafe];
    });
    
    dispatch_async(queue2, ^{
        [weakSelf saleTicketNotSafe];
    });

}

- (void)saleTicketNotSafe {
    while (1) {
        if (self.ticketSurplusCount > 0) {
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld, 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        } else {
            NSLog(@"已售完");
            break;
        }
    }
}

- (void)semaphoreSync {
    NSLog(@"currentThread---%@", [NSThread currentThread]);
    NSLog(@"semaphoreSync--begin");
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block int number = 0;
    dispatch_async(queue, ^{
        // 追加任务1
        [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
        NSLog(@"1----%@", [NSThread currentThread]); // 打印当前线程
        number = 100;
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"semaphoreSync--end, number== %d", number);
}

#pragma mark 队列组
- (void)groupEnterAndLeave {
//   dispatch_group_enter() 标志着一个任务追加到 group，执行一次，相当于 group 中未执行完毕任务数+1
//    dispatch_group_leave() 标志着一个任务离开了 group，执行一次，相当于 group 中未执行完毕任务数-1。
//    当 group 中未执行完毕任务数为0的时候，才会使dispatch_group_wait解除阻塞，以及执行追加到dispatch_group_notify中的任务。
    
    NSLog(@"currentThread---%@", [NSThread currentThread]);
    NSLog(@"groupEnterAndLeave--begin");
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1----%@", [NSThread currentThread]); // 打印当前线程
        }
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2----%@", [NSThread currentThread]); // 打印当前线程
        }
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步任务1，2执行完后，回到主线程
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3----%@", [NSThread currentThread]); // 打印当前线程
        }
        NSLog(@"group -- end");
    });
    
    
    
}
- (void)groupWait {
    NSLog(@"currentThread---%@", [NSThread currentThread]);
    NSLog(@"groupWait--begin");
    
    dispatch_group_t group = dispatch_group_create();

    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务1
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务2
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    // 等待上面任务执行完成后，会继续执行下面
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"groupWait--end");
}
/**
 队列组
 */
- (void)groupNotify {
    NSLog(@"currentThread---%@", [NSThread currentThread]);
    NSLog(@"groupNotify--begin");
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务1
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务2
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步任务1，2执行完后，回到主线程
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3----%@", [NSThread currentThread]); // 打印当前线程
        }
        NSLog(@"group -- end");
    });
    NSLog(@"我什么时间执行呢");
    // 党所有任务都执行完成之后，才执行dispatch_group_notify Block中的任务
}
#pragma mark 快速迭代方法

/**
 快速迭代方法
 */
- (void)apply {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"apply -- begin");
    dispatch_apply(6, queue, ^(size_t index) {
        NSLog(@"%zd--%@", index, [NSThread currentThread]);
    });
    NSLog(@"apply -- end");
}

#pragma mark -- 执行一次
/**
 一次性代码，只执行一次
 */
- (void)once {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 只执行一次，这里默认是线程安全的
    });
}
#pragma mark -- 延时执行

/**
 延时执行方法 dispatch_after
 */
- (void)after {
    NSLog(@"currentThread---%@", [NSThread currentThread]);
    NSLog(@"asyncMain--begin");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20.0*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"after --%@", [NSThread currentThread]);
    });
}
#pragma mark -- 栅栏

/**
 栅栏方法
 */
- (void)barrier {
    dispatch_queue_t queue = dispatch_queue_create("barrier", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_barrier_async(queue, ^{
        // 追加任务barrier
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"barrier----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        // 追加任务4
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"4----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    // 在执行完栅栏前面的操作之后，才执行栅栏操作，最后在执行栅栏后面的操作
}
#pragma mark -- 通信
/**
 线程间通信
 */
- (void)communication {
    // 获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainqueue = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        // 异步追加任务
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1----%@", [NSThread currentThread]); // 打印当前线程
        }
        // 回到主线程
        dispatch_async(mainqueue, ^{
            // 追加在主线程执行的任务
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2----%@", [NSThread currentThread]); // 打印当前线程
        });
    });
    // 可以看到在其他线程中先执行任务，执行完了之后回到主线程执行主线程的相应操作
}

#pragma mark -- 队列+任务
/**
 异步+主队列
 只在主线程中执行任务，执行完成一个任务，在执行下一个任务
 */
- (void)asyncMain {
    NSLog(@"currentThread---%@", [NSThread currentThread]);
    NSLog(@"asyncMain--begin");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    NSLog(@"asyncMain--end");
}
/**
 同步+主队列
 互等卡住不执行
 不会开启新的线程，执行完一个任务，在执行下一个任务
 */
- (void)syncMain {
    NSLog(@"currentThread---%@", [NSThread currentThread]);
    NSLog(@"syncMain--begin");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_sync(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_sync(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_sync(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    NSLog(@"syncMain--end");
}
/**
 异步+串行队列
 会开启新的线程，但是因为任务是串行的，执行完一个任务后，在执行下一个任务
 */
- (void)asyncSerial {
    NSLog(@"currentThread---%@", [NSThread currentThread]);
    NSLog(@"asyncSerial--begin");
    
    dispatch_queue_t queue = dispatch_queue_create("asyncSerial", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    NSLog(@"asyncSerial--end");
}
/**
 同步+串行
 不会开启新线程，在当前线程执行任务，任务是串行的，执行完一个任务，在执行下一个任务
 */
- (void)syncSerial {
    NSLog(@"currentThread---%@", [NSThread currentThread]);
    NSLog(@"syncSerial--begin");
    
    dispatch_queue_t queue = dispatch_queue_create("syncSerial", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_sync(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_sync(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    NSLog(@"syncSerial--end");
}
/**
 异步+并发
 可以开发多个线程，任务交替（同时）执行
 */
- (void)asyncConcurrent {
    NSLog(@"currentThread---%@", [NSThread currentThread]);
    NSLog(@"asyncConcurrent--begin");
    
    dispatch_queue_t queue = dispatch_queue_create("asyncConcurrent", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    NSLog(@"asyncConcurrent--end");
}
/**
 同步+并发
 在当前线程中执行任务，不会开启新的线程，执行完一个任务，在执行下一个任务
 */
- (void)syncConcurrent {
    NSLog(@"currentThread---%@", [NSThread currentThread]);
    NSLog(@"syncConcurrent--begin");
    
    dispatch_queue_t queue = dispatch_queue_create("syncConcurrent", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_sync(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_sync(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_sync(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3----%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    NSLog(@"syncConcurrent--end");
}

- (void)createTask {
    dispatch_queue_t queue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    // 同步执行任务创建方法
    dispatch_sync(queue, ^{
        // 同步执行任务代码
    });
    // 异步执行任务创建方法
    dispatch_async(queue, ^{
        // 异步执行任务代码
    });
}


/**
 队列的创建方法/获取方法
 */
- (void)createDispatchQueue {
    //创建串行对列 SERIAL
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    // 创建并发队列 CONCURRENT
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    //串行队列 获取主队列的方法
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    //并发队列，获取全局并发队列
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
