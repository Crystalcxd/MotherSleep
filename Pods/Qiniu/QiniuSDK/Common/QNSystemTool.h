//
//  QNSystemTool.h
//  QiniuSDK
//
//  Created by WorkSpace_Sun on 2020/4/2.
//  Copyright © 2020 Qiniu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QNSystemTool : NSObject

// 获取当前进程ID
+ (int64_t)getCurrentProcessID;

// 获取当前线程ID
+ (int64_t)getCurrentThreadID;

@end
