//
//  XPerson.h
//  JYLibrary
//
//  Created by XJY on 16/3/15.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/ABPerson.h>

#define xPersonLabelsKey @"personLabelsKey"

#define xPersonPhoneLabelHome (__bridge NSString *) kABHomeLabel
#define xPersonPhoneLabelWork (__bridge NSString *) kABWorkLabel
#define xPersonPhoneLabelOther (__bridge NSString *) kABOtherLabel
#define xPersonPhoneLabelMobile (__bridge NSString *) kABPersonPhoneMobileLabel
#define xPersonPhoneLabelIPhone (__bridge NSString *) kABPersonPhoneIPhoneLabel
#define xPersonPhoneLabelMain (__bridge NSString *) kABPersonPhoneMainLabel
#define xPersonPhoneLabelHomeFAX (__bridge NSString *) kABPersonPhoneHomeFAXLabel
#define xPersonPhoneLabelWorkFAX (__bridge NSString *) kABPersonPhoneWorkFAXLabel
#define xPersonPhoneLabelOtherFAX (__bridge NSString *) kABPersonPhoneOtherFAXLabel
#define xPersonPhoneLabelPager (__bridge NSString *) kABPersonPhonePagerLabel

#define xPersonEmailLabelHome (__bridge NSString *) kABHomeLabel
#define xPersonEmailLabelWork (__bridge NSString *) kABWorkLabel
#define xPersonEmailLabelOther (__bridge NSString *) kABOtherLabel
#define xPersonEmailLabelICloud @"iCloud"

#define xPersonAddressLabelHome (__bridge NSString *) kABHomeLabel
#define xPersonAddressLabelWork (__bridge NSString *) kABWorkLabel
#define xPersonAddressLabelOther (__bridge NSString *) kABOtherLabel

#define xPersonAddressKeyCountry (__bridge NSString *) kABPersonAddressCountryKey
#define xPersonAddressKeyState (__bridge NSString *) kABPersonAddressStateKey
#define xPersonAddressKeyCity (__bridge NSString *) kABPersonAddressCityKey
#define xPersonAddressKeyStreet (__bridge NSString *) kABPersonAddressStreetKey
#define xPersonAddressKeyCountryCode (__bridge NSString *) kABPersonAddressCountryCodeKey
#define xPersonAddressKeyZIP (__bridge NSString *) kABPersonAddressZIPKey


@interface XPerson : NSObject

@property (nonatomic, assign) NSInteger RecordID; //Do not set it!

@property (nonatomic, copy) NSString *First;
@property (nonatomic, copy) NSString *Last;
@property (nonatomic, copy, readonly) NSString *Name;

@property (nonatomic, strong) NSData *ThumbnailImage; //Do not set it!
@property (nonatomic, strong) NSData *OriginalImage;

@property (nonatomic, strong) NSMutableDictionary *Phone;
@property (nonatomic, strong) NSMutableDictionary *Email;
@property (nonatomic, strong) NSMutableDictionary *Address;

@property (nonatomic, copy) NSString *Group;

@property (nonatomic, copy) NSString *Company;
@property (nonatomic, copy) NSString *Department;
@property (nonatomic, copy) NSString *JobTitle;

@property (nonatomic, strong) NSDate *Birthday;
@property (nonatomic, copy) NSString *Notes;

@property (nonatomic, strong) NSDate *CreationDate;
@property (nonatomic, strong) NSDate *ModificationDate;

@end
