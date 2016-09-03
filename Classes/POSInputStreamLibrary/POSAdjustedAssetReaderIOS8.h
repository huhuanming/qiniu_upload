//
//  POSAdjustedAssetReaderIOS8.h
//  POSInputStreamLibrary
//
//  Created by Pavel Osipov on 12.05.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSAssetReader.h"

@interface POSAdjustedAssetReaderIOS8 : NSObject <POSAssetReader>

/// When you try to get adjusted photo just after taking it in Camera app,
/// Photos framework will provide data of 'SubstandardFullSizeRender.jpg'.
/// Asset reader will force Photos framework to generate 'FullSizeRender.jpg'
/// making 2nd attempt to open asset. I think a "suspicious" image size is
/// more adequate parameter to rely on, than the name of the file which you
/// can take from the info dictionary with 'PHImageFileURLKey' key.
@property (nonatomic, assign) long long suspiciousSize;

/*!
    @brief Dispatch queue for fetching ALAsset from ALAssetsLibrary.
    @remarks See POSBlobInputStreamAssetDataSource.h
 */
@property (nonatomic, strong) dispatch_queue_t completionDispatchQueue;

@end
