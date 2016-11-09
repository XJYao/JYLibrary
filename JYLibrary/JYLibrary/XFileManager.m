//
//  XFileManager.m
//  JYLibrary
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import "XFileManager.h"
#import "XTool.h"

@implementation XFileManager

+ (NSString *)appendingPathComponent:(NSString *)componentStr sourcePath:(NSString *)sourcePath {
    NSString *newPath = [sourcePath stringByAppendingPathComponent:componentStr];
    return newPath;
}

+ (NSString *)getHomeDirectory {
    return NSHomeDirectory();
}

+ (NSString *)getDocumentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths x_objectAtIndex:0];
    return path;
}

+ (NSString *)getCachesDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths x_objectAtIndex:0];
    return path;
}

+ (NSString *)getLibraryDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [paths x_objectAtIndex:0];
    return path;
}

+ (NSString *)getTempDirectory {
    return NSTemporaryDirectory();
}

+ (BOOL)isDirectoryExist:(NSString *)directoryPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    BOOL result = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
    if (result) {
        if (!isDir) {
            result = NO;
        }
    }
    return result;
}

+ (BOOL)isFileExist:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    return result;
}

+ (BOOL)createDirectory:(NSString *)directoryPath {
    if ([self isDirectoryExist:directoryPath]) {
        return YES;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:NULL];
    return result;
}

+ (BOOL)createFile:(NSString *)fileName directoryPath:(NSString *)directoryPath contents:(NSData *)contents allowMulti:(BOOL)allowMulti {
    if ([XTool isStringEmpty:fileName]) {
        return NO;
    }
    if ([XTool isStringEmpty:directoryPath]) {
        return NO;
    }
    
    BOOL fileResult = NO;
    BOOL directoryResult = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectoryExist = [self isDirectoryExist:directoryPath];
    if (isDirectoryExist) {
        directoryResult = YES;
    } else {
        directoryResult = [self createDirectory:directoryPath];
    }
    if (directoryResult) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        BOOL isFileExist = [self isFileExist:filePath];
        if (isFileExist) {
            if (allowMulti) {
                NSString *componentsStr = @".";
                NSString *appendingStr = [XTool getCurrentTime:@"yyyyMMddHHmmss"];
                NSString *newFileName = @"";
                NSRange range = [fileName rangeOfString:componentsStr];
                if (range.location == NSNotFound) {
                    newFileName = [fileName stringByAppendingString:appendingStr];
                } else {
                    NSArray *fileNameArr = [fileName componentsSeparatedByString:componentsStr];
                    NSString *fileNameWithoudType = [fileNameArr firstObject];
                    NSString *fileType = [fileNameArr lastObject];
                    fileNameWithoudType = [fileNameWithoudType stringByAppendingString:appendingStr];
                    newFileName = [fileNameWithoudType stringByAppendingString:componentsStr];
                    newFileName = [newFileName stringByAppendingString:fileType];
                }
                filePath = [directoryPath stringByAppendingPathComponent:newFileName];
            } else {
                NSError *error = nil;
                [fileManager removeItemAtPath:filePath error:&error];
                if (error) {
                    return NO;
                }
            }
        }
        fileResult = [fileManager createFileAtPath:filePath contents:contents attributes:nil];
    } else {
        fileResult = NO;
    }
    return fileResult;
}

+ (BOOL)createFile:(NSString *)filePath contents:(NSData *)contents allowMulti:(BOOL)allowMulti {
    if ([XTool isStringEmpty:filePath]) {
        return NO;
    }
    
    NSArray *filePathArray = [filePath componentsSeparatedByString:@"/"];
    NSString *fileName = [filePathArray lastObject];
    
    NSString *directoryPath = @"";
    for (NSInteger i = 0; i < filePathArray.count - 1; i ++) {
        directoryPath = [directoryPath stringByAppendingPathComponent:[filePathArray x_objectAtIndex:i]];
    }
    
    return [self createFile:fileName directoryPath:directoryPath contents:contents allowMulti:allowMulti];
}

+ (NSData *)readFile:(NSString *)filePath {
    NSData *data = nil;
    BOOL isFileExist = [self isFileExist:filePath];
    if (isFileExist) {
        data = [NSData dataWithContentsOfFile:filePath];
    }
    return data;
}

+ (BOOL)removeFile:(NSString *)filePath {
    if ([XTool isStringEmpty:filePath]) {
        return NO;
    }
    
    if (![self isFileExist:filePath]) {
        return YES;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL result = [fileManager removeItemAtPath:filePath error:&error];
    if (error) {
        result = NO;
    }
    return result;
}

+ (BOOL)removeDirectory:(NSString *)directory {
    if ([XTool isStringEmpty:directory]) {
        return NO;
    }
    
    if (![self isDirectoryExist:directory]) {
        return YES;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL result = [fileManager removeItemAtPath:directory error:&error];
    if (error) {
        result = NO;
    }
    return result;
}

+ (BOOL)removeFile:(NSString *)fileName directoryPath:(NSString *)directoryPath {
    if ([XTool isStringEmpty:fileName] || [XTool isStringEmpty:directoryPath]) {
        return NO;
    }
    
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    if (![self isFileExist:filePath]) {
        return YES;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL result = [fileManager removeItemAtPath:filePath error:&error];
    if (error) {
        result = NO;
    }
    return result;
}

+ (void)appendData:(NSData *)data toFile:(NSString *)path {
    if ([self isFileExist:path]) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
        [fileHandle closeFile];
    } else {
        [self createFile:path contents:data allowMulti:NO];
    }
}

+ (BOOL)copyFileAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
    if ([XTool isStringEmpty:srcPath] || [XTool isStringEmpty:dstPath]) {
        return NO;
    }
    
    if ([self isFileExist:dstPath]) {
        [self removeFile:dstPath];
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    return [fileManager copyItemAtPath:srcPath toPath:dstPath error:&error];
}

+ (BOOL)copyBundleFileWithName:(NSString *)name fileType:(NSString *)type toLocalPath:(NSString *)dstPath {
    NSString *srcPath = [self getBundleResourcePathWithName:name type:type];
    return [self copyFileAtPath:srcPath toPath:dstPath];
}

+ (BOOL)copyBundleFileWithName:(NSString *)name fileType:(NSString *)type inDirectory:(NSString *)directory toLocalPath:(NSString *)dstPath {
    NSString *srcPath = [self getBundleResourcePathWithName:name type:type inDirectory:directory];
    return [self copyFileAtPath:srcPath toPath:dstPath];
}

+ (BOOL)copyBundleFileWithBundleName:(NSString *)bundleName fileName:(NSString *)fileName fileType:(NSString *)type toLocalPath:(NSString *)dstPath {
    NSString *srcPath = [self getBundleResourcePathWithBundleName:bundleName resourceName:fileName type:type];
    return [self copyFileAtPath:srcPath toPath:dstPath];
}

+ (BOOL)copyBundleFileWithBundleName:(NSString *)bundleName fileName:(NSString *)fileName fileType:(NSString *)type inDirectory:(NSString *)directory toLocalPath:(NSString *)dstPath {
    NSString *srcPath = [self getBundleResourcePathWithBundleName:bundleName resourceName:fileName type:type inDirectory:directory];
    return [self copyFileAtPath:srcPath toPath:dstPath];
}

+ (NSString *)getFileNameWithSufixForPath:(NSString *)filePath {
    NSString *fileNameWithSufix = @"";
    if (![XTool isStringEmpty:filePath]) {
        if ([filePath rangeOfString:@"/"].location != NSNotFound) {
            NSArray *filePathComponentsArr = [filePath componentsSeparatedByString:@"/"];
            fileNameWithSufix = [filePathComponentsArr lastObject];
        }
    }
    return fileNameWithSufix;
}

+ (NSString *)getFileNameWithoutSufixForPath:(NSString *)filePath {
    NSString *fileNameWithSufix = [self getFileNameWithSufixForPath:filePath];
    NSString *fileNameWithoutSufix = [self getFileNameWithoutSufixForName:fileNameWithSufix];
    return fileNameWithoutSufix;
}

+ (NSString *)getFileNameWithoutSufixForName:(NSString *)fileNameWithSufix {
    NSString *fileNameWithoutSufix = @"";
    if (![XTool isStringEmpty:fileNameWithSufix]) {
        if ([fileNameWithSufix rangeOfString:@"."].location != NSNotFound) {
            NSArray *fileNameArr = [fileNameWithSufix componentsSeparatedByString:@"."];
            fileNameWithoutSufix = [fileNameArr firstObject];
        } else {
            fileNameWithoutSufix = fileNameWithSufix;
        }
    }
    return fileNameWithoutSufix;
}

+ (NSString *)getSufixForPath:(NSString *)filePath {
    NSString *fileNameWithSufix = [self getFileNameWithSufixForPath:filePath];
    NSString *fileNameSufix = [self getSufixForName:fileNameWithSufix];
    return fileNameSufix;
}

+ (NSString *)getSufixForName:(NSString *)fileNameWithSufix {
    NSString *fileNameSufix = @"";
    if (![XTool isStringEmpty:fileNameWithSufix]) {
        if ([fileNameWithSufix rangeOfString:@"."].location != NSNotFound) {
            NSArray *fileNameArr = [fileNameWithSufix componentsSeparatedByString:@"."];
            fileNameSufix = [fileNameArr lastObject];
        }
    }
    return fileNameSufix;
}

+ (NSArray *)getAllFiles:(NSString *)directoryPath {
    if ([XTool isStringEmpty:directoryPath]) {
        return nil;
    }
    if ([self isDirectoryExist:directoryPath]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        NSArray *allFiles = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
        if (error != nil) {
            return nil;
        } else {
            return allFiles;
        }
    } else {
        return nil;
    }
}

+ (void)getAllFilesPathWithRootPath:(NSString *)directoryPath fileNames:(NSMutableArray *)fileNamesArray {
    if ([XTool isStringEmpty:directoryPath]) {
        return;
    }
    
    if (!fileNamesArray) {
        return;
    }
    
    NSArray *allFiles = [self getAllFiles:directoryPath];
    if ([XTool isArrayEmpty:allFiles]) {
        return;
    }
    for (NSString *fileName in allFiles) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        [fileNamesArray x_addObject:filePath];
        [self getAllFilesPathWithRootPath:filePath fileNames:fileNamesArray];
        
    }
}

+ (NSString *)getBundleResourcePathWithName:(NSString *)resourceName type:(NSString *)type {
    NSString *localResourcePath = @"";
    if ([XTool isStringEmpty:resourceName]) {
        localResourcePath = @"";
    } else {
        localResourcePath = [[NSBundle mainBundle] pathForResource:resourceName ofType:type];
    }
    return localResourcePath;
}

+ (NSString *)getBundleResourcePathWithName:(NSString *)resourceName type:(NSString *)type inDirectory:(NSString *)directory {
    NSString *localResourcePath = @"";
    if ([XTool isStringEmpty:resourceName]) {
        localResourcePath = @"";
    } else {
        localResourcePath = [[NSBundle mainBundle] pathForResource:resourceName ofType:type inDirectory:directory];
    }
    return localResourcePath;
}

+ (NSString *)getBundleResourcePathWithBundleName:(NSString *)bundleName resourceName:(NSString *)resourceName type:(NSString *)type {
    return [self getBundleResourcePathWithBundleName:bundleName resourceName:resourceName type:type inDirectory:nil];
}

+ (NSString *)getBundleResourcePathWithBundleName:(NSString *)bundleName resourceName:(NSString *)resourceName type:(NSString *)type inDirectory:(NSString *)directory {
    if ([XTool isStringEmpty:bundleName] || [XTool isStringEmpty:resourceName]) {
        return nil;
    }
    
    if ([bundleName rangeOfString:@".bundle"].location == NSNotFound) {
        bundleName = [bundleName stringByAppendingString:@".bundle"];
    }
    
    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:bundleName];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    if ([XTool isStringEmpty:directory]) {
        return [bundle pathForResource:resourceName ofType:type];
    } else {
        return [bundle pathForResource:resourceName ofType:type inDirectory:directory];
    }
}

+ (BOOL)archive:(id)rootObject keyedArchiveName:(NSString *)keyedArchiveName directoryPath:(NSString *)directoryPath {
    if (![self isDirectoryExist:directoryPath]) {
        [self createDirectory:directoryPath];
    }
    
    NSString *keyedArchivePath = [directoryPath stringByAppendingPathComponent:keyedArchiveName];
    
    if ([self isFileExist:keyedArchivePath]) {
        [self removeFile:keyedArchivePath];
    }
    
    if (!rootObject) {
        return NO;
    }
    
    return [NSKeyedArchiver archiveRootObject:rootObject toFile:keyedArchivePath];
}

+ (BOOL)archive:(id)rootObject keyedArchivePath:(NSString *)keyedArchivePath {
    NSArray *filePathArray = [keyedArchivePath componentsSeparatedByString:@"/"];
    NSString *fileName = [filePathArray lastObject];
    
    NSString *directoryPath = @"";
    for (NSInteger i = 0; i < filePathArray.count - 1; i ++) {
        directoryPath = [directoryPath stringByAppendingPathComponent:[filePathArray x_objectAtIndex:i]];
    }
    
    return [self archive:rootObject keyedArchiveName:fileName directoryPath:directoryPath];
}

+ (id)unarchive:(NSString *)filePath {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

+ (id)unarchive:(NSString *)fileName directoryPath:(NSString *)directoryPath {
    if (![self isDirectoryExist:directoryPath]) {
        return nil;
    }
    
    NSString *keyedArchivePath = [directoryPath stringByAppendingPathComponent:fileName];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:keyedArchivePath];
}

+ (NSDictionary *)getFileAttributes:(NSString *)filePath {
    if ([XTool isStringEmpty:filePath]) {
        return nil;
    }
    if (![self isFileExist:filePath]) {
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:filePath error:&error];
    if (error) {
        return nil;
    }
    
    return attributes;
}

+ (unsigned long long)getFileSize:(NSString *)filePath {
    NSDictionary *attributes = [self getFileAttributes:filePath];
    if ([XTool isDictionaryEmpty:attributes]) {
        return 0;
    }
    
    return [attributes fileSize];
}

+ (NSDate *)getFileCreateDate:(NSString *)filePath {
    NSDictionary *attributes = [self getFileAttributes:filePath];
    if ([XTool isDictionaryEmpty:attributes]) {
        return nil;
    }
    
    return [attributes fileCreationDate];
}

+ (NSDate *)getFileModificationDate:(NSString *)filePath {
    NSDictionary *attributes = [self getFileAttributes:filePath];
    if ([XTool isDictionaryEmpty:attributes]) {
        return nil;
    }
    
    return [attributes fileModificationDate];
}

+ (NSString *)getFileType:(NSString *)filePath {
    NSDictionary *attributes = [self getFileAttributes:filePath];
    if ([XTool isDictionaryEmpty:attributes]) {
        return nil;
    }
    
    return [attributes fileType];
}

+ (unsigned long long)getDirectorySize:(NSString *)directoryPath {
    if ([XTool isStringEmpty:directoryPath] || ![self isDirectoryExist:directoryPath]) {
        return 0;
    }
    
    NSArray *allFiles = [[NSFileManager defaultManager] subpathsAtPath:directoryPath];
    if ([XTool isArrayEmpty:allFiles]) {
        return 0;
    }
    
    unsigned long long totalSize = 0;
    
    for (NSString *subFilePath in allFiles) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:subFilePath];
        totalSize += [self getFileSize:filePath];
    }
    
    return totalSize;
}

@end
