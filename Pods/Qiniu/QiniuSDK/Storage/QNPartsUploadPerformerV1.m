//
//  QNPartsUploadApiV1.m
//  QiniuSDK
//
//  Created by yangsen on 2020/11/30.
//  Copyright © 2020 Qiniu. All rights reserved.
//

#import "QNLogUtil.h"
#import "QNDefine.h"
#import "QNRequestTransaction.h"
#import "QNUploadFileInfoPartV1.h"
#import "QNPartsUploadPerformerV1.h"

@interface QNPartsUploadPerformerV1()
@end
@implementation QNPartsUploadPerformerV1
+ (long long)blockSize{
    return 4 * 1024 * 1024;
}

- (QNUploadFileInfo *)getFileInfoWithDictionary:(NSDictionary *)fileInfoDictionary {
    return [QNUploadFileInfoPartV1 infoFromDictionary:fileInfoDictionary];
}

- (QNUploadFileInfo *)getDefaultUploadFileInfo {
    return [[QNUploadFileInfoPartV1 alloc] initWithFileSize:[self.file size]
                                                  blockSize:[QNPartsUploadPerformerV1 blockSize]
                                                   dataSize:[self getUploadChunkSize]
                                                 modifyTime:[self.file modifyTime]];
}

- (void)serverInit:(void(^)(QNResponseInfo * _Nullable responseInfo,
                            QNUploadRegionRequestMetrics * _Nullable metrics,
                            NSDictionary * _Nullable response))completeHandler {
    QNResponseInfo *responseInfo = [QNResponseInfo successResponse];
    completeHandler(responseInfo, nil, nil);
}

- (void)uploadNextData:(void(^)(BOOL stop,
                                QNResponseInfo * _Nullable responseInfo,
                                QNUploadRegionRequestMetrics * _Nullable metrics,
                                NSDictionary * _Nullable response))completeHandler {
    QNUploadFileInfoPartV1 *fileInfo = (QNUploadFileInfoPartV1 *)self.fileInfo;
    
    QNUploadBlock *block = nil;
    QNUploadData *chunk = nil;
    @synchronized (self) {
        block = [fileInfo nextUploadBlock];
        chunk = [block nextUploadData];
        chunk.isUploading = YES;
        chunk.isCompleted = NO;
    }

    if (block == nil || chunk == nil) {
        QNLogInfo(@"key:%@ no chunk left", self.key);
        
        QNResponseInfo *responseInfo = [QNResponseInfo responseInfoWithSDKInteriorError:@"no chunk left"];
        completeHandler(YES, responseInfo, nil, nil);
        return;
    }
    
    NSData *chunkData = [self getDataWithChunk:chunk block:block];
    if (chunkData == nil) {
        QNLogInfo(@"key:%@ get chunk data error", self.key);
        
        chunk.isUploading = NO;
        chunk.isCompleted = NO;
        QNResponseInfo *responseInfo = [QNResponseInfo responseInfoWithLocalIOError:@"get chunk data error"];
        completeHandler(YES, responseInfo, nil, nil);
        return;
    }
    
    kQNWeakSelf;
    void (^progress)(long long, long long) = ^(long long totalBytesWritten, long long totalBytesExpectedToWrite){
        kQNStrongSelf;
        
        chunk.progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
        [self notifyProgress];
    };
    
    void (^completeHandlerP)(QNResponseInfo *, QNUploadRegionRequestMetrics *, NSDictionary *) = ^(QNResponseInfo * _Nullable responseInfo, QNUploadRegionRequestMetrics * _Nullable metrics, NSDictionary * _Nullable response) {
        kQNStrongSelf;
        
        NSString *blockContext = response[@"ctx"];
        if (responseInfo.isOK && blockContext) {
            block.context = blockContext;
            chunk.progress = 1;
            chunk.isUploading = NO;
            chunk.isCompleted = YES;
            [self recordUploadInfo];
            [self notifyProgress];
        } else {
            chunk.isUploading = NO;
            chunk.isCompleted = NO;
        }
        completeHandler(NO, responseInfo, metrics, response);
    };
    
    if (chunk.isFirstData) {
        QNLogInfo(@"key:%@ makeBlock", self.key);
        [self makeBlock:block firstChunk:chunk chunkData:chunkData progress:progress completeHandler:completeHandlerP];
    } else {
        QNLogInfo(@"key:%@ uploadChunk", self.key);
        [self uploadChunk:block chunk:chunk chunkData:chunkData progress:progress completeHandler:completeHandlerP];
    }
}

- (void)completeUpload:(void(^)(QNResponseInfo * _Nullable responseInfo,
                                QNUploadRegionRequestMetrics * _Nullable metrics,
                                NSDictionary * _Nullable response))completeHandler {
    QNUploadFileInfoPartV1 *fileInfo = (QNUploadFileInfoPartV1 *)self.fileInfo;
    
    QNRequestTransaction *transaction = [self createUploadRequestTransaction];
    
    kQNWeakSelf;
    kQNWeakObj(transaction);
    [transaction makeFile:fileInfo.size
                 fileName:self.fileName
            blockContexts:[fileInfo allBlocksContexts]
                 complete:^(QNResponseInfo * _Nullable responseInfo, QNUploadRegionRequestMetrics * _Nullable metrics, NSDictionary * _Nullable response) {
        kQNStrongSelf;
        kQNStrongObj(transaction);
        
        completeHandler(responseInfo, metrics, response);
        [self destroyUploadRequestTransaction:transaction];
    }];
}


- (void)makeBlock:(QNUploadBlock *)block
       firstChunk:(QNUploadData *)chunk
        chunkData:(NSData *)chunkData
         progress:(void(^)(long long totalBytesWritten,
                           long long totalBytesExpectedToWrite))progress
  completeHandler:(void(^)(QNResponseInfo * _Nullable responseInfo,
                           QNUploadRegionRequestMetrics * _Nullable metrics,
                           NSDictionary * _Nullable response))completeHandler {
    
    QNRequestTransaction *transaction = [self createUploadRequestTransaction];
    kQNWeakSelf;
    kQNWeakObj(transaction);
    [transaction makeBlock:block.offset
                 blockSize:block.size
            firstChunkData:chunkData
                  progress:progress
                  complete:^(QNResponseInfo * _Nullable responseInfo, QNUploadRegionRequestMetrics * _Nullable metrics, NSDictionary * _Nullable response) {
        kQNStrongSelf;
        kQNStrongObj(transaction);
        
        completeHandler(responseInfo, metrics, response);
        [self destroyUploadRequestTransaction:transaction];
    }];
}


- (void)uploadChunk:(QNUploadBlock *)block
              chunk:(QNUploadData *)chunk
          chunkData:(NSData *)chunkData
           progress:(void(^)(long long totalBytesWritten,
                             long long totalBytesExpectedToWrite))progress
    completeHandler:(void(^)(QNResponseInfo * _Nullable responseInfo,
                             QNUploadRegionRequestMetrics * _Nullable metrics,
                             NSDictionary * _Nullable response))completeHandler {
    
    QNRequestTransaction *transaction = [self createUploadRequestTransaction];
    kQNWeakSelf;
    kQNWeakObj(transaction);
    [transaction uploadChunk:block.context
                 blockOffset:block.offset
                   chunkData:chunkData
                 chunkOffset:chunk.offset
                    progress:progress
                    complete:^(QNResponseInfo * _Nullable responseInfo, QNUploadRegionRequestMetrics * _Nullable metrics, NSDictionary * _Nullable response) {
        kQNStrongSelf;
        kQNStrongObj(transaction);
        
        completeHandler(responseInfo, metrics, response);
        [self destroyUploadRequestTransaction:transaction];
    }];
}


- (NSData *)getDataWithChunk:(QNUploadData *)chunk block:(QNUploadBlock *)block{
    if (!self.file) {
        return nil;
    }
    NSError *error = nil;
    NSData *data = [self.file read:(long)(chunk.offset + block.offset)
                              size:(long)chunk.size
                             error:&error];
    
    return error ? nil : data;
}

- (long long)getUploadChunkSize{
    if (self.config.useConcurrentResumeUpload) {
        return [QNPartsUploadPerformerV1 blockSize];
    } else {
        return self.config.chunkSize;
    }
}

@end
