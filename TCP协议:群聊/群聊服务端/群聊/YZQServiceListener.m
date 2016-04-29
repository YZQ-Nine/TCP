//
//  YZQServiceListener.m
//  群聊
//
//  Created by apple on 16/3/16.
//  Copyright © 2016年 YZQ. All rights reserved.
//

//  telnet 172.21.62.9 5288

#import "YZQServiceListener.h"
#import "GCDAsyncSocket.h"

@interface YZQServiceListener ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *serverSocket;

/*客户端的所有Socket*/
@property (nonatomic, strong) NSMutableArray *clientSocket;

@end

@implementation YZQServiceListener

- (NSMutableArray *)clientSocket{

    if (!_clientSocket) {
        _clientSocket = [NSMutableArray array];
    }
    return _clientSocket;
}

- (void)start{

    //开启10086服务 端口：5288
    
    //1、创建一个socket对象
    //服务端的Socket只监听有没有客户端请求连接
    GCDAsyncSocket *serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    
    //2、绑定端口并监听
    NSError *error = nil;
    [serverSocket acceptOnPort:5288 error:&error];
    if (!error) {
        NSLog(@"开启成功");
    } else {
        //失败原因：端口被占用
        NSLog(@"开启失败");
    }
    
    self.serverSocket = serverSocket;
    
}

#pragma mark - 有客户端的socket连接到服务器
- (void)socket:(GCDAsyncSocket *)serverSocket didAcceptNewSocket:(GCDAsyncSocket *)clientSocket{

    NSLog(@"serverSocket = %@",serverSocket);
    NSLog(@"clientSocket %@ host:%@ port:%d",clientSocket,clientSocket.connectedHost,clientSocket.connectedPort);
    
    //1、保存客户端的socket
    [self.clientSocket addObject:clientSocket];

    //2、监听客户端有没有数据上传
    //timeout -1 代表不超时
    //tag 标示作用 现在不用 就写 0
    [clientSocket readDataWithTimeout:-1 tag:0];
    
    NSLog(@"当前有%ld 客户已经连接到服务器", self.clientSocket.count);
    
    
}
#pragma mark - 读取客户端请求的数据
- (void)socket:(GCDAsyncSocket *)clientSocket didReadData:(NSData *)data withTag:(long)tag{
    
    //1.把NSData转成NSString
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //2.把当前客户端的数据 转发给其他的客户端
    NSLog(@"接收到客户端上传的而数据：%@",str);
    for (GCDAsyncSocket *socket in self.clientSocket) {
        if (socket != clientSocket) {
            [socket writeData:data withTimeout:-1 tag:0];

        }
}
    
  
    //3.处理请求，返回数据给客户端
//    [sock writeData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
#warning 每次读完数据后，都要调用一次监听数据的方法
    [clientSocket readDataWithTimeout:-1 tag:0];
 
}

#pragma mark - 读取客户端请求的数据
//- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
//    
//    //1.把NSData转成NSString
//    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"接收到数据:%@", str);
//    
//    //2.处理请求，返回数据给客户端
//    [sock writeData:data withTimeout:-1 tag:0];
//    
//#warning 每次读完数据后，都要调用一次监听数据的方法
//    [sock readDataWithTimeout:-1 tag:0];
//    
//}
@end
