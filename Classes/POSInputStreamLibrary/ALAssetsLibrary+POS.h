//
//  ALAssetsLibrary+POS.h
//  POSInputStreamLibrary
//
//  Created by Osipov on 31.08.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^POSAssetLookupResultBlock)(ALAsset *asset, ALAssetsGroup *assetsGroup);

@interface ALAssetsLibrary (POS)

- (void)pos_assetForURL:(NSURL *)assetURL
            resultBlock:(POSAssetLookupResultBlock)resultBlock
           failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock;

@end
