//
//  cdRepository.h
//  Codesaur
//
//  Created by Zak.
//  Copyright (c) 2013 Zak. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MGITCommit.h"

@protocol MGITRepositoryDelegate <NSObject>

@optional

- (void)didCommitChange:(MGITCommit *)commit;

@end

@interface MGITRepository : NSTreeController {
    __strong NSMutableSet *_commits;
}

@property (strong,readonly) NSSet *commits;
@property (strong) MGITCommit *stagedCommit;
@property (weak) id <MGITRepositoryDelegate> delegate;

//- (void)makeCommit:(cdCommit *)commit;

- (void)mergeChangeFromStage;
- (BOOL)isForwardCommit:(MGITCommit *)commit;

@end
