//
//  cdRepository.h
//  Codesaur
//
//  Created by Zak.
//  Copyright (c) 2013 Zak. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MGITStage.h"
@class MGITRepository;
@class MGITCommit;

typedef NS_ENUM(NSUInteger, MGITRepositoryMode) {
    MGITRepositoryModeRepository,
    MGITRepositoryModeStage
};

@protocol MGITRepositoryDelegate <NSObject>

@optional

- (void)didStageChange:(MGITCommit *)change toRepository:(MGITRepository *)repository;
- (void)didMergeStagedChange:(MGITCommit *)commit toRepository:(MGITRepository *)repository;

@end

@interface MGITRepository : NSTreeController {
    __strong	NSMutableOrderedSet	*_stagedChangesOrCommits;
//	__strong	NSMutableOrderedSet	*_stagedChanges;
	__strong	MGITRepository		*_stage;
	
	MGITRepositoryMode				_mode;
}

@property (strong,readonly) NSOrderedSet		*commits;
@property (strong,readonly) NSOrderedSet		*stagedChanges;
//@property (strong,readonly)	MGITRepository		*stage;
//@property (readonly)		MGITRepositoryMode	mode;


@property (weak) id <MGITRepositoryDelegate> delegate;
// Private property for stages to reference back to owner repository
@property (weak) MGITRepository *owner;

// Designated initters
// new repository with the same capacity as it's stage
+ (instancetype)repositoryWithCapacity:(NSUInteger)repositoryCapacity;
// new repository with a stage of differing capacity
+ (instancetype)repositoryWithCapacity:(NSUInteger)repositoryCapacity stageCapacity:(NSUInteger)stageCapacity;

- (void)stageChange:(MGITCommit *)change;
- (MGITCommit *)lastStagedChange;
- (void)mergeLastStagedChange;

- (BOOL)isForwardCommit:(MGITCommit *)commit;
- (BOOL)isForwardStagedChange:(MGITCommit *)commit;
- (BOOL)isForwardStagedChangeOrCommit:(MGITCommit *)commit;

@end
