//
//  WMMacro.h
//  WeMedia
//
//  Created by Kyle on 14-3-26.
//  Copyright (c) 2014年 Tap Tech. All rights reserved.
//

#undef weak_delegate
#undef __weak_delegate

#if __has_feature(objc_arc_weak) && \
(!(defined __MAC_OS_X_VERSION_MIN_REQUIRED) || \
__MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_8)
#define weak_delegate weak
#define __weak_delegate __weak
#else
#define weak_delegate unsafe_unretained
#define __weak_delegate __unsafe_unretained
#endif
