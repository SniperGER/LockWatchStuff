//
//  WatchLabel.h
//  LockWatch
//
//  Created by Janik Schmidt on 25.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WatchLabel : UILabel

- (void)setContent:(NSDictionary*)userInfo;

@property NSString* notificationChannel;

@end
