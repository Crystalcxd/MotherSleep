//
//  QNPartsUploadApiV2.m
//  QiniuSDK
//
//  Created by yangsen on 2020/11/30.
//  Copyright © 2020 Qiniu. All rights reserved.
//

#import "QNLogUtil.h"
#import "QNDefine.h"
#import "QNRequestTransaction.h"
#import "QNUploadFileInfoPartV2.h"
#import "QNPartsUploadPerformerV2.h"

@interface QNPartsUploadPerformerV2()
@end
@implementation QNPartsUploadPerformerV2

- (QNUploadFileInfo *)getFileInfoWithDictionary:(NSDictionary *)fileInfoDictionary {
    return [QNUploadFileInfoPartV2 infoFromDictionary:fileInfoDictionary];
}

- (QNUploadFileInfo *)getDefaultUploadFileInfo {
    return [[QNUploadFileInfoPartV2 alloc] initWithFileSize:[self.file size]
                                                   dataSize:self.config.chunkSize
                                                 modifyTime:(NSInteger)[self.file modifyTime]];
}

- (void)serverInit:(void(^)(QNResponseInfo * _Nullable responseInfo,
                            QNUploadRegionRequestMetrics * _Nullable metrics,
                            NSDictionary * _Nullable response))completeHandler {
    
    QNUploadFileInfoPartV2 *fileInfo = (QNUploadFileInfoPartV2 *)self.fileInfo;
    if (fileInfo && [fileInfo isValid]) {
        QNLogInfo(@"key:%@ serverInit success", self.key);
        QNResponseInfo *responseInfo = [QNResponseInfo successResponse];
        completeHandler(responseInfo, nil, nil);
        return;
    }
    
    QNRequestTransaction *transaction = [self createUploadRequestTransaction];

    kQNWeakSelf;
    kQNWeakObj(transaction);
    [transaction initPart:^(QNResponseInfo * _Nullable responseInfo, QNUploadRegionRequestMetrics * _Nullable metrics, NSDictionary * _Nullable response) {
        kQNStrongSelf;
        kQNStrongObj(transaction);
                
        NSString *uploadId = response[@"uploadId"];
        NSNumber *expireAt = response[@"expireAt"];
        if (responseInfo.isOK && uploadId && expireAt) {
            fileInfo.uploadId = uploadId;
            fileInfo.expireAt = expireAt;
            [self recordUploadInfo];
        }
        completeHandler(responseInfo, metrics, response);
        [self destroyUploadRequestTransaction:transaction];
    }];
}

- (void)uploadNextData:(void(^)(BOOL stop,
                                QNResponseInfo * _Nullable responseInfo,
                                QNUploadRegionRequestMetrics * _Nullable metrics,
                                NSDictionary * _Nullable response))completeHandler {
    QNUploadFileInfoPartV2 *fileInfo = (QNUploadFileInfoPartV2 *)self.fileInfo;
    QNUploadData *data = nil;
    @synchronized (self) {
        data = [fileInfo nextUploadData];
        data.isUploading = YES;
        data.isCompleted = NO;
    }
    // 上传完毕
    if (data == nil) {
        QNLogInfo(@"key:%@ no data left", self.key);
        
        QNResponseInfo *responseInfo = [QNResponseInfo responseInfoWithSDKInteriorError:@"no data left"];
        completeHandler(YES, responseInfo, nil, nil);
        return;
    }
    
    // 本地读异常
    NSData *uploadData = [self getUploadData:data];
    if (uploadData == nil) {
        QNLogInfo(@"key:%@ get data error", self.key);
        
        data.isUploading = NO;
        data.isCompleted = NO;
        QNResponseInfo *responseInfo = [QNResponseInfo responseInfoWithLocalIOError:@"get data error"];
        completeHandler(YES, responseInfo, nil, responseInfo.responseDictionary);
        return;
    }
    
    kQNWeakSelf;
    void (^progress)(long long, long long) = ^(long long totalBytesWritten, long long totalBytesExpectedToWrite){
        kQNStrongSelf;
        
        data.progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
        [self notifyProgress];
    };
    
    QNRequestTransaction *transaction = [self createUploadRequestTransaction];
    
    kQNWeakObj(transaction);
    [transaction uploadPart:fileInfo.uploadId
                  partIndex:data.index
                   partData:uploadData
                   progress:progress
                   complete:^(QNResponseInfo * _Nullable responseInfo, QNUploadRegionRequestMetrics * _Nullable metrics, NSDictionary * _Nullable response) {
        kQNStrongSelf;
        kQNStrongObj(transaction);

        NSString *etag = response[@"etag"];
        NSString *md5 = response[@"md5"];
        if (responseInfo.isOK && etag && md5) {
            data.etag = etag;
            data.progress = 1;
            data.isUploading = NO;
            data.isCompleted = YES;
            [self recordUploadInfo];
            [self notifyProgress];
        } else {
            data.isUploading = NO;
            data.isCompleted = NO;
        }
        completeHandler(NO, responseInfo, metrics, response);
        [self destroyUploadRequestTransaction:transaction];
    }];
}

- (void)completeUpload:(void(^)(QNResponseInfo * _Nullable responseInfo,
                                QNUploadRegionRequestMetrics * _Nullable metrics,
                                NSDictionary * _Nullable response))completeHandler {
    
    QNUploadFileInfoPartV2 *fileInfo = (QNUploadFileInfoPartV2 *)self.fileInfo;
    
    NSArray *partInfoArray = [(QNUploadFileInfoPartV2 *)self.fileInfo getPartInfoArray];
    QNRequestTransaction *transaction = [self createUploadRequestTransaction];
    
    kQNWeakSelf;
    kQNWeakObj(transaction);
    [transaction completeParts:self.fileName uploadId:fileInfo.uploadId partInfoArray:partInfoArray complete:^(QNResponseInfo * _Nullable responseInfo, QNUploadRegionRequestMetrics * _Nullable metrics, NSDictionary * _Nullable response) {
        kQNStrongSelf;
        kQNStrongObj(transaction);
        
        completeHandler(responseInfo, metrics, response);
        [self destroyUploadRequestTransaction:transaction];
    }];
}

- (NSData *)getUploadData:(QNUploadData *)data{
    if (!self.file) {
        return nil;
    }
    NSError *error = nil;
    NSData *dataByte = [self.file read:(long)data.offset
                                  size:(long)data.size
                                 error:&error];
    return error ? nil : dataByte;
}

@end
