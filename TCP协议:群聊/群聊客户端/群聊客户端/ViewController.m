//
//  ViewController.m
//  群聊客户端
//
//  Created by apple on 16/3/16.
//  Copyright © 2016年 YZQ. All rights reserved.
//


#import "ViewController.h"
#import "GCDAsyncSocket.h"
@interface ViewController ()<GCDAsyncSocketDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, strong) GCDAsyncSocket *clientSocket;

/*数据源*/
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ViewController

- (NSMutableArray *)dataSource{

    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    
   
    //实现聊天室
    //1、连接到群聊的服务器
    
    //1.1创建一个客户端的socket对象
    GCDAsyncSocket *clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    self.clientSocket = clientSocket;
    
    //1.2 发送连接请求
    NSError *error = nil;
    [clientSocket connectToHost:@"172.21.62.9" onPort:5288 error:&error];
    if (!error) {
        NSLog(@"%@",error);
    }
    
    
    
    //2、发送聊天消息和接收聊天消息
}
#pragma mark - 与服务器连接成功
- (void)socket:(GCDAsyncSocket *)clientSocket didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"与服务器连接成功");
    //监听读取数据
    [clientSocket readDataWithTimeout:-1 tag:0];
    
}

#pragma mark - 与服务器连接失败
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"与服务器断开连接 %@",err);
}

#pragma mark - 读取消息

- (void)socket:(GCDAsyncSocket *)clientSocket didReadData:(NSData *)data withTag:(long)tag{

    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
    
    //把消息添加到数据源
    if (str) {
        [self.dataSource addObject:str];
        //刷新表格
#warning 刷新回到主线程
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             [self.tableView reloadData];
        }];
       
    }
    
    
    //监听读取数据
    [clientSocket readDataWithTimeout:-1 tag:0];

}

#pragma mark - 表格数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.dataSource.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    //显示文字
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    return cell;
}


- (IBAction)sendAction:(id)sender {

    NSString *str = self.textField.text;
    if (str.length == 0) {
        return;
    }
    
    //把数据添加到数据源里
    [self.dataSource addObject:self.textField.text];
    
    //刷新表格
    [self.tableView reloadData];
    
    //发数据
    
    [self.clientSocket writeData:[str dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];

}


@end
