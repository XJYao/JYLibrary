//
//  XPerson.m
//  JYLibrary
//
//  Created by XJY on 16/3/15.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XPerson.h"
#import "XTool.h"

@implementation XPerson

@synthesize Name;

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _RecordID = 0;
        [self Phone];
        [self Email];
        [self Address];
    }
    
    return self;
}

- (NSString *)Name {
    NSString *name = nil;
    if (![XTool isStringEmpty:_Last]) {
        name = _Last;
    }
    if (![XTool isStringEmpty:_First]) {
        if ([XTool isStringEmpty:name]) {
            name = _First;
        } else {
            name = [NSString stringWithFormat:@"%@ %@", name, _First];
        }
    }
    return name;
}

- (NSMutableDictionary *)Phone {
    if (!_Phone) {
        _Phone = [[NSMutableDictionary alloc] init];
        
        NSMutableArray *labels = [[NSMutableArray alloc] initWithObjects:
                                  xPersonPhoneLabelHome,
                                  xPersonPhoneLabelWork,
                                  xPersonPhoneLabelOther,
                                  xPersonPhoneLabelMobile,
                                  xPersonPhoneLabelIPhone,
                                  xPersonPhoneLabelMain,
                                  xPersonPhoneLabelHomeFAX,
                                  xPersonPhoneLabelWorkFAX,
                                  xPersonPhoneLabelOtherFAX,
                                  xPersonPhoneLabelPager,
                                  nil
                                  ];
        
        [_Phone x_setObject:labels forKey:xPersonLabelsKey];
        for (NSString *label in labels) {
            [_Phone x_setObject:[[NSMutableArray alloc] init] forKey:label];
        }
    }
    
    return _Phone;
}

- (NSMutableDictionary *)Email {
    if (!_Email) {
        _Email = [[NSMutableDictionary alloc] init];
        
        NSMutableArray *labels = [[NSMutableArray alloc] initWithObjects:
                                  xPersonEmailLabelHome,
                                  xPersonEmailLabelWork,
                                  xPersonEmailLabelOther,
                                  xPersonEmailLabelICloud,
                                  nil
                                  ];
        
        [_Email x_setObject:labels forKey:xPersonLabelsKey];
        for (NSString *label in labels) {
            [_Email x_setObject:[[NSMutableArray alloc] init] forKey:label];
        }
    }
    
    return _Email;
}

- (NSMutableDictionary *)Address {
    if (!_Address) {
        _Address = [[NSMutableDictionary alloc] init];
        
        
        NSMutableArray *labels = [[NSMutableArray alloc] initWithObjects:
                                  xPersonAddressLabelHome,
                                  xPersonAddressLabelWork,
                                  xPersonAddressLabelOther,
                                  nil
                                  ];
        
        [_Address x_setObject:labels forKey:xPersonLabelsKey];
        for (NSString *label in labels) {
            [_Address x_setObject:[[NSMutableArray alloc] init] forKey:label];
        }
    }
    
    return _Address;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[NSNumber numberWithInteger:_RecordID] forKey:@"RecordID"];
    [encoder encodeObject:_First forKey:@"First"];
    [encoder encodeObject:_Last forKey:@"Last"];
    [encoder encodeObject:Name forKey:@"Name"];
    [encoder encodeObject:_ThumbnailImage forKey:@"ThumbnailImage"];
    [encoder encodeObject:_OriginalImage forKey:@"OriginalImage"];
    [encoder encodeObject:_Phone forKey:@"Phone"];
    [encoder encodeObject:_Email forKey:@"Email"];
    [encoder encodeObject:_Address forKey:@"Address"];
    [encoder encodeObject:_Group forKey:@"Group"];
    [encoder encodeObject:_Company forKey:@"Company"];
    [encoder encodeObject:_Department forKey:@"Department"];
    [encoder encodeObject:_JobTitle forKey:@"JobTitle"];
    [encoder encodeObject:_Birthday forKey:@"Birthday"];
    [encoder encodeObject:_Notes forKey:@"Notes"];
    [encoder encodeObject:_CreationDate forKey:@"CreationDate"];
    [encoder encodeObject:_ModificationDate forKey:@"ModificationDate"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _RecordID = [[decoder decodeObjectForKey:@"RecordID"] integerValue];
        _First = [decoder decodeObjectForKey:@"First"];
        _Last = [decoder decodeObjectForKey:@"Last"];
        Name = [decoder decodeObjectForKey:@"Name"];
        _ThumbnailImage = [decoder decodeObjectForKey:@"ThumbnailImage"];
        _OriginalImage = [decoder decodeObjectForKey:@"OriginalImage"];
        _Phone = [decoder decodeObjectForKey:@"Phone"];
        _Email = [decoder decodeObjectForKey:@"Email"];
        _Address = [decoder decodeObjectForKey:@"Address"];
        _Group = [decoder decodeObjectForKey:@"Group"];
        _Company = [decoder decodeObjectForKey:@"Company"];
        _Department = [decoder decodeObjectForKey:@"Department"];
        _JobTitle = [decoder decodeObjectForKey:@"JobTitle"];
        _Birthday = [decoder decodeObjectForKey:@"Birthday"];
        _Notes = [decoder decodeObjectForKey:@"Notes"];
        _CreationDate = [decoder decodeObjectForKey:@"CreationDate"];
        _ModificationDate = [decoder decodeObjectForKey:@"ModificationDate"];
        
    }
    return self;
}

@end