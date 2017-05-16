//
//  XFileManager.h
//  JYLibrary
//
//  Created by XJY on 15-7-26.
//  Copyright (c) 2015年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XFileManager : NSObject

/**
 将字符串追加到地址末尾,自动补上‘/’
 */
+ (NSString *)appendingPathComponent:(NSString *)componentStr sourcePath:(NSString *)sourcePath;

/**
 获取沙盒中的Home路径
 */
+ (NSString *)getHomeDirectory;

/**
 获取沙盒中的documents路径
 */
+ (NSString *)getDocumentDirectory;

/**
 获取沙盒中的缓存路径
 */
+ (NSString *)getCachesDirectory;

/**
 获取沙盒中的Library路径
 */
+ (NSString *)getLibraryDirectory;

/**
 获取沙盒中的Temp路径
 */
+ (NSString *)getTempDirectory;

/**
 判断文件夹是否存在
 */
+ (BOOL)isDirectoryExist:(NSString *)directoryPath;

/**
 判断文件是否存在
 */
+ (BOOL)isFileExist:(NSString *)filePath;

/**
 创建文件夹
 */
+ (BOOL)createDirectory:(NSString *)directoryPath;

/**
 创建文件,文件名和文件所在文件夹路径分开传入,allowMulti表示是否允许重名.YES则在文件名后补上当前时间保存;NO则覆盖同名文件,只保留最新文件.
 */
+ (BOOL)createFile:(NSString *)fileName directoryPath:(NSString *)directoryPath contents:(NSData *)contents allowMulti:(BOOL)allowMulti;

/**
 创建文件,传入文件完整路径,allowMulti表示是否允许重名.YES则在文件名后补上当前时间保存;NO则覆盖同名文件,只保留最新文件.
 */
+ (BOOL)createFile:(NSString *)filePath contents:(NSData *)contents allowMulti:(BOOL)allowMulti;

/**
 读取文件
 */
+ (NSData *)readFile:(NSString *)filePath;

/**
 删除文件，传入文件路径
 */
+ (BOOL)removeFile:(NSString *)filePath;

/**
 删除文件夹，传入文件夹路径
 */
+ (BOOL)removeDirectory:(NSString *)directory;

/**
 删除文件，传入文件名和文件夹
 */
+ (BOOL)removeFile:(NSString *)fileName directoryPath:(NSString *)directoryPath;

/**
 追加内容到文件
 */
+ (void)appendData:(NSData *)data toFile:(NSString *)path;

/**
 复制文件到指定目录下
 */
+ (BOOL)copyFileAtPath:(NSString *)srcPath toPath:(NSString *)dstPath;

/**
 复制工程资源下的文件到指定的本地目录下
 */
+ (BOOL)copyBundleFileWithName:(NSString *)name fileType:(NSString *)type toLocalPath:(NSString *)dstPath;

/**
 复制工程资源指定文件夹下的文件到指定的本地目录下
 */
+ (BOOL)copyBundleFileWithName:(NSString *)name fileType:(NSString *)type inDirectory:(NSString *)directory toLocalPath:(NSString *)dstPath;

/**
 复制指定Bundle下的文件到指定的本地目录下
 */
+ (BOOL)copyBundleFileWithBundleName:(NSString *)bundleName fileName:(NSString *)fileName fileType:(NSString *)type toLocalPath:(NSString *)dstPath;

/**
 复制指定Bundle下的指定文件夹下的文件到指定的本地目录下
 */
+ (BOOL)copyBundleFileWithBundleName:(NSString *)bundleName fileName:(NSString *)fileName fileType:(NSString *)type inDirectory:(NSString *)directory toLocalPath:(NSString *)dstPath;

/**
 从文件路径获取带后缀的文件名,如果传入的参数不是合法路径或者为空,则返回空字符串.
 */
+ (NSString *)getFileNameWithSufixForPath:(NSString *)filePath;

/**
 从文件路径获取不带后缀的文件名,如果传入的参数不是合法路径或者为空,则返回空字符串.
 */
+ (NSString *)getFileNameWithoutSufixForPath:(NSString *)filePath;

/**
 从文件名获取不带后缀的文件名,如果传入的参数为空,则返回空字符串.
 */
+ (NSString *)getFileNameWithoutSufixForName:(NSString *)fileNameWithSufix;

/**
 从文件路径获取文件名后缀,如果传入的参数不是合法路径或者为空,则返回空字符串.
 */
+ (NSString *)getSufixForPath:(NSString *)filePath;

/**
 从文件名获取后缀,如果传入的参数为空或者无点符号,则返回空字符串.
 */
+ (NSString *)getSufixForName:(NSString *)fileNameWithSufix;

/**
 获取指定文件夹下的所有文件列表
 */
+ (NSArray *)getAllFiles:(NSString *)directoryPath;

/**
 获取指定文件夹下的所有文件路径
 */
+ (void)getAllFilesPathWithRootPath:(NSString *)directoryPath fileNames:(NSMutableArray *)fileNamesArray;

/**
 获取工程中的资源文件路径
 */
+ (NSString *)getBundleResourcePathWithName:(NSString *)resourceName type:(NSString *)type;

/**
 获取工程中指定文件夹下的资源文件路径
 */
+ (NSString *)getBundleResourcePathWithName:(NSString *)resourceName type:(NSString *)type inDirectory:(NSString *)directory;

/**
 获取指定Bundle文件下的资源文件路径
 */
+ (NSString *)getBundleResourcePathWithBundleName:(NSString *)bundleName resourceName:(NSString *)resourceName type:(NSString *)type;

/**
 获取指定Bundle文件下指定文件夹下的资源文件路径
 */
+ (NSString *)getBundleResourcePathWithBundleName:(NSString *)bundleName resourceName:(NSString *)resourceName type:(NSString *)type inDirectory:(NSString *)directory;

/**
 归档保存实例对象，传入文件名和文件夹
 */
+ (BOOL)archive:(id)rootObject keyedArchiveName:(NSString *)keyedArchiveName directoryPath:(NSString *)directoryPath;

/**
 归档保存实例对象，传入文件路径
 */
+ (BOOL)archive:(id)rootObject keyedArchivePath:(NSString *)keyedArchivePath;

/**
 从归档文件读取实例对象，传入文件路径
 */
+ (id)unarchive:(NSString *)filePath;

/**
 从归档文件读取实例对象，传入文件名和文件夹
 */
+ (id)unarchive:(NSString *)fileName directoryPath:(NSString *)directoryPath;

/**
 获取文件属性
 */
+ (NSDictionary *)getFileAttributes:(NSString *)filePath;

/**
 获取文件大小
 */
+ (unsigned long long)getFileSize:(NSString *)filePath;

/**
 获取文件创建时间
 */
+ (NSDate *)getFileCreateDate:(NSString *)filePath;

/**
 获取文件修改时间
 */
+ (NSDate *)getFileModificationDate:(NSString *)filePath;

/**
 获取文件类型
 */
+ (NSString *)getFileType:(NSString *)filePath;

/**
 获取文件夹大小
 */
+ (unsigned long long)getDirectorySize:(NSString *)directoryPath;

@end
