//
//  main.m
//  SocketServiceDemo
//
//  Created by IndusGoo on 2017/3/25.
//  Copyright © 2017年 Indus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceListener.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        ServiceListener * listener = [[ServiceListener alloc]init];
        [listener start];
        [[NSRunLoop mainRunLoop] run];

    }
    return 0;
}
