//
//  ClearCacheTool.h
//  TMW025_iOS
//
//  Created by RND on 2020/4/13.
//  Copyright © 2020 RND. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ClearCacheTool : NSObject

/**
 *  获取缓存大小
 */
+ (NSString *)getCacheSize;


/**
 *  清理缓存
 */
+ (BOOL)clearCaches;

@end

NS_ASSUME_NONNULL_END
