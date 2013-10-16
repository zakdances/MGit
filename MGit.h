//
//  MGit.h
//  Pods
//
//  Created by Zak.
//
//

#if TARGET_OS_IPHONE
	#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
	#import <Foundation/Foundation.h>
#endif

#import "MGITRepository.h"
#import "MGITCommit.h"

@interface MGit : NSObject

@end
