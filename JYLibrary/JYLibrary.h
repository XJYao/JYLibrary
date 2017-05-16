//
//  JYLibrary.h
//  JYLibrary
//
//  Created by XJY on 16/7/30.
//  Copyright © 2016年 XJY. All rights reserved.
//

/*
 主工程中需要导入的库
 libz.1.2.5.tbd
 AudioToolbox.framework
 AVFoundation.famework
 CoreImage.framework
 WebKit.framework
 AddressBook.framework
 */

#import <Foundation/Foundation.h>

//XClass
#import "XMacro.h"
#import "XAnimation.h"
#import "XCookieManager.h"
#import "XEncoding.h"
#import "XFileManager.h"
#import "XGzip.h"
#import "XHttpRequest.h"
#import "XIOSVersion.h"
#import "XJsonParser.h"
#import "XLock.h"
#import "XNavigationHelper.h"
#import "XPhone.h"
#import "XContact.h"
#import "XPhoto.h"
#import "XSocket.h"
#import "XTimer.h"
#import "XTool.h"
#import "XNetwork.h"
#import "XThread.h"
#import "XNotification.h"
#import "XExpObject.h"
#import "XTask.h"
#import "XTaskQueue.h"
#import "XClassInfo.h"
#import "XFPS.h"
#import "NSObject+XModelParser.h"
#import "XKeyboard.h"
#import "XClass.h"

//XKit
#import "UIView+XView.h"
#import "UIControl+XControl.h"
#import "UIImageView+XImageView.h"
#import "UILabel+XLabel.h"
#import "UIAlertView+XAlertView.h"
#import "UIScrollView+XScrollView.h"
#import "UITableView+XTableView.h"
#import "UIWebView+XWebView.h"
#import "UIImage+XImage.h"
#import "UIImage+XGif.h"
#import "UIColor+XColor.h"
#import "UIViewController+XViewController.h"
#import "UIViewController+XBackButtonHandler.h"
#import "UIDevice+XDevice.h"
#import "UIView+XDataBindingView.h"
#import "UIActionSheet+XActionSheet.h"

#import "XImageView.h"
#import "XScrollView.h"
#import "XSearchBar.h"
#import "XTableView.h"
#import "XTableViewCell.h"
#import "XTextField.h"
#import "XTextView.h"
#import "XWebView.h"
#import "XWebManager.h"
#import "XLabel.h"
#import "XFullScreenPopGestureNavigationController.h"
#import "XEaseInOutImageView.h"

//XFoundation
#import "NSArray+XArray.h"
#import "NSDictionary+XDictionary.h"
#import "NSSet+XSet.h"
#import "NSString+XString.h"
#import "NSString+XMD5Addition.h"
#import "NSData+XAES.h"
#import "NSDate+XDate.h"
#import "NSString+XPinyin.h"
#import "NSAttributedString+XAttributedString.h"

//XUIControl
#import "XAlertContainer.h"
#import "XBottomBar.h"
#import "XPhotoBrowser.h"
#import "XPhotoView.h"
#import "XGallery.h"
#import "XGroupTable.h"
#import "XGroupTableCell.h"
#import "XGroupTableModel.h"
#import "XPickerView.h"
#import "XTabBar.h"
#import "XTitleView.h"
#import "XCircleProgress.h"
#import "XCurvesDrawer.h"
#import "XCurveInfo.h"
#import "XGradientProgress.h"
#import "XIndexView.h"

//Web Image
#import "XImageManager.h"
#import "XImageCache.h"
#import "UIImageView+XWebImageView.h"

//XConstraint
#import "XConstraint.h"

//XScan
#import "XScan.h"
#import "XImageCode.h"

//XViewController
#import "XPageViewController.h"


@interface JYLibrary : NSObject

@end
