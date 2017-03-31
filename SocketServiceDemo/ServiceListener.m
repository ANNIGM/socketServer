//
//  ServiceListener.m
//  SocketDemo
//
//  Created by IndusGoo on 2017/3/24.
//  Copyright © 2017年 Annie. All rights reserved.
//

#import "ServiceListener.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncSocket+Extension.h"
@interface ServiceListener()<GCDAsyncSocketDelegate>

@property(nonatomic,strong) GCDAsyncSocket * socket;// 服务器端建立10086socket
@property(nonatomic,strong) GCDAsyncSocket * socketIM;// 服务器端建立IM的socket
@property (nonatomic,copy) NSMutableArray * clientSockets;// 长连接 如果没有强引用，就是短连接
@property (nonatomic,copy) NSMutableArray * clientSocketsIM;
@end
@implementation ServiceListener
- (NSMutableArray *)clientSockets
{
    if (!_clientSockets) {
        _clientSockets = [NSMutableArray array];;
    }
    return _clientSockets;
}
- (NSMutableArray *)clientSocketsIM
{
    if (!_clientSocketsIM) {
        _clientSocketsIM = [NSMutableArray array];
    }
    return _clientSocketsIM;
}
// 开始监听
- (void) start
{
    //10086服务器的 socket 监听5528的 端口（ port）
    self.socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    NSError * error = nil;
    [self.socket acceptOnPort:5528 error:&error];
    if (!error) {
        NSLog(@"5528连接成功");
    }
    else
    {
        NSLog(@"5528连接失败");
    }
    // IM服务器的 socket 监听5538的 端口（ port）
    self.socketIM = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    [self.socketIM acceptOnPort:5538 error:&error];
    if (!error) {
        NSLog(@"5538连接成功");
    }
    else
    {
        NSLog(@"5538连接失败");
    }
}
#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    // 如果客户端请求的端口是5528
    if (newSocket.localPort == 5528) {
        // 对客户端的 socket 进行强引用，保证客户端 socket 不死
        [self.clientSockets addObject:newSocket];
//        NSLog(@"%@--->---%@",sock,newSocket);
//        NSLog(@"%@--->---%@",sock.localHost,newSocket.localHost);
//        NSLog(@"%zd--->---%zd",sock.localPort,newSocket.localPort);
        
        // 返回 "服务" 选项
        NSMutableString *options = [NSMutableString string];
        [options appendString:@"欢迎来到10086在在线服务 请输入下面的数字选择服务\n"];
        [options appendString:@"[0]在线充值\n"];
        [options appendString:@"[1]在线投诉\n"];
        [options appendString:@"[2]优惠信息\n"];
        [options appendString:@"[3]special services\n"];
        [options appendString:@"[4]退出\n"];

        //响应客户端
        [newSocket writeString:options];
        // 监听客户端的数据
        [newSocket readDataWithTimeout:-1 tag:0];

    }
    // 如果客户端请求的端口是5538
    else if (newSocket.localPort == 5538)
    {
        [self.clientSocketsIM addObject:newSocket];
        [newSocket writeString:@"请输入聊天内容"];
        [newSocket readDataWithTimeout:-1 tag:0];
    }
    
}
- (void)socket:(GCDAsyncSocket *)clientSocket didReadData:(NSData *)data withTag:(long)tag
{
// 接收5528端口的 socket 连接
    if(clientSocket.localPort == 5528) {
        NSInteger serverCode = [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] integerValue];;
        switch (serverCode) {
            case 0:
                [clientSocket writeString:@"充值服务暂停，系统维护...\n"];
                break;
            case 1:
                [clientSocket writeString:@"投诉服务暂停，系统维护\n"];
                break;
            case 2:
                [clientSocket writeString:@"最近优惠服务，充一万，送5千。。\n"];
                break;
            case 3:
                [clientSocket writeString:@"你傻啊，还真以为有特殊服务...\n"];
                break;
            case 4:
                [self exitWithSocket:clientSocket];
                break;
                
            default:
                [clientSocket writeString:@"请说人话...\n"];
                break;
        }
        [clientSocket readDataWithTimeout:-1 tag:0];

    }
    else if (clientSocket.localPort == 5538)
    {
        for (GCDAsyncSocket * enumSocket in self.clientSocketsIM) {
//            if (enumSocket != clientSocket) {
                [enumSocket writeData:data withTimeout:-1 tag:0];
                NSLog(@"%zd",enumSocket.connectedPort);
//            }
        }
        [clientSocket readDataWithTimeout:-1 tag:0];
    }
    
}
//private
-(void)writeDataWithSocket:(GCDAsyncSocket *)clientSocket str:(NSString *)str{
    
    [clientSocket writeData:[str dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
}
-(void)exitWithSocket:(GCDAsyncSocket *)clientSocket{
    [self writeDataWithSocket:clientSocket str:@"成功退出\n"];
    [self.clientSockets removeObject:clientSocket];
    
    NSLog(@"当前在线用户个数:%ld",self.clientSockets.count);
}
@end
