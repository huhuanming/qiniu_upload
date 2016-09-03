//
//  ALAssetsLibrary+POS.m
//  POSInputStreamLibrary
//
//  Created by Osipov on 31.08.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "ALAssetsLibrary+POS.h"

@implementation ALAssetsLibrary (POS)

- (void)pos_assetForURL:(NSURL *)assetURL
            resultBlock:(POSAssetLookupResultBlock)resultBlock
           failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock {
    [self assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        if (asset) {
            resultBlock(asset, nil);
            return;
        }
        __block BOOL groupAssetFound = NO;
        [self
         enumerateGroupsWithTypes:ALAssetsGroupPhotoStream
         usingBlock:^(ALAssetsGroup *group, BOOL *stopEnumeratingGroups) {
             if (groupAssetFound) {
                 *stopEnumeratingGroups = YES;
                 return;
             }
             if (!group) {
                 resultBlock(nil, nil);
                 return;
             }
             [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stopEnumeratingAssets) {
                 if (!asset) {
                     return;
                 }
                 // For iOS 5 you should use another check:
                 // [[[asset valueForProperty:ALAssetPropertyURLs] allObjects] lastObject]
                 if ([[asset valueForProperty:ALAssetPropertyAssetURL] isEqual:assetURL]) {
                     resultBlock(asset, group);
                     groupAssetFound = YES;
                     *stopEnumeratingAssets = YES;
                 }
             }];
         } failureBlock:failureBlock];
    } failureBlock:failureBlock];
}

@end
