/*****************************************************************************
 * VLCCloudStorageTableViewCell.m
 * VLC for iOS
 *****************************************************************************
 * Copyright (c) 2013 VideoLAN. All rights reserved.
 * $Id$
 *
 * Authors: Carola Nitz <nitz.carola # googlemail.com>
 *          Felix Paul Kühne <fkuehne # videolan.org>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

#import "VLCCloudStorageTableViewCell.h"
@interface VLCCloudStorageTableViewCell ()
{
    NSURL *_iconURL;
}
@end

@implementation VLCCloudStorageTableViewCell

+ (VLCCloudStorageTableViewCell *)cellWithReuseIdentifier:(NSString *)ident
{
    NSArray *nibContentArray = [[NSBundle mainBundle] loadNibNamed:@"VLCCloudStorageTableViewCell" owner:nil options:nil];
    NSAssert([nibContentArray count] == 1, @"meh");
    NSAssert([[nibContentArray lastObject] isKindOfClass:[VLCCloudStorageTableViewCell class]], @"meh meh");
    VLCCloudStorageTableViewCell *cell = (VLCCloudStorageTableViewCell *)[nibContentArray lastObject];

    return cell;
}

- (void)setFileMetadata:(DBMetadata *)fileMetadata
{
    if (fileMetadata != _fileMetadata)
        _fileMetadata = fileMetadata;

    [self _updatedDisplayedInformation];
}

- (void)setDriveFile:(GTLDriveFile *)driveFile
{
    if (driveFile != _driveFile)
        _driveFile = driveFile;

    [self _updatedDisplayedInformation];
}

- (void)setBoxFile:(BoxItem *)boxFile
{
    if (boxFile != _boxFile)
        _boxFile = boxFile;

    [self _updatedDisplayedInformation];
}

- (void)setOneDriveFile:(VLCOneDriveObject *)oneDriveFile
{
    if (oneDriveFile != _oneDriveFile)
        _oneDriveFile = oneDriveFile;

    [self _updatedDisplayedInformation];
}

- (void)_updatedDisplayedInformation
{
    if (_fileMetadata != nil) {
        if (self.fileMetadata.isDirectory) {
            self.folderTitleLabel.text = self.fileMetadata.filename;
            self.titleLabel.hidden = self.subtitleLabel.hidden = YES;
            self.folderTitleLabel.hidden = NO;
        } else {
            self.titleLabel.text = self.fileMetadata.filename;
            self.subtitleLabel.text = (self.fileMetadata.totalBytes > 0) ? self.fileMetadata.humanReadableSize : @"";
            self.titleLabel.hidden = self.subtitleLabel.hidden = NO;
            self.folderTitleLabel.hidden = YES;
        }

        NSString *iconName = self.fileMetadata.icon;
        if ([iconName isEqualToString:@"folder_user"] || [iconName isEqualToString:@"folder"] || [iconName isEqualToString:@"folder_public"] || [iconName isEqualToString:@"folder_photos"] || [iconName isEqualToString:@"package"]) {
            self.thumbnailView.image = [UIImage imageNamed:@"folder"];
            self.downloadButton.hidden = YES;
        } else if ([iconName isEqualToString:@"page_white"] || [iconName isEqualToString:@"page_white_text"])
            self.thumbnailView.image = [UIImage imageNamed:@"blank"];
        else if ([iconName isEqualToString:@"page_white_film"])
            self.thumbnailView.image = [UIImage imageNamed:@"movie"];
        else if ([iconName isEqualToString:@"page_white_sound"])
            self.thumbnailView.image = [UIImage imageNamed:@"audio"];
        else {
            self.thumbnailView.image = [UIImage imageNamed:@"blank"];
            APLog(@"missing icon for type '%@'", self.fileMetadata.icon);
        }

    } else if(_driveFile != nil){
        BOOL isDirectory = [self.driveFile.mimeType isEqualToString:@"application/vnd.google-apps.folder"];
        if (isDirectory) {
            self.folderTitleLabel.text = self.driveFile.title;
            self.titleLabel.hidden = self.subtitleLabel.hidden = YES;
            self.folderTitleLabel.hidden = NO;
        } else {
            self.titleLabel.text = self.driveFile.title;
            self.subtitleLabel.text = (self.driveFile.fileSize > 0) ? [NSByteCountFormatter stringFromByteCount:[self.driveFile.fileSize longLongValue] countStyle:NSByteCountFormatterCountStyleFile]: @"";
            self.titleLabel.hidden = self.subtitleLabel.hidden = NO;
            self.folderTitleLabel.hidden = YES;
        }
        if (_driveFile.thumbnailLink != nil) {
            _iconURL = [NSURL URLWithString:_driveFile.thumbnailLink];
            [self performSelectorInBackground:@selector(_updateIconFromURL) withObject:@""];
        }
        NSString *iconName = self.driveFile.iconLink;
        if ([iconName isEqualToString:@"https://ssl.gstatic.com/docs/doclist/images/icon_11_shared_collection_list.png"] || [iconName isEqualToString:@"https://ssl.gstatic.com/docs/doclist/images/icon_11_collection_list.png"]) {
            self.thumbnailView.image = [UIImage imageNamed:@"folder"];
        } else if ([iconName isEqualToString:@"https://ssl.gstatic.com/docs/doclist/images/icon_10_audio_list.png"]) {
            self.thumbnailView.image = [UIImage imageNamed:@"audio"];
        } else if ([iconName isEqualToString:@"https://ssl.gstatic.com/docs/doclist/images/icon_11_video_list.png"]) {
            self.thumbnailView.image = [UIImage imageNamed:@"movie"];
        } else {
            self.thumbnailView.image = [UIImage imageNamed:@"blank"];
            APLog(@"missing icon for type '%@'", self.driveFile.iconLink);
        }
    } else if(_boxFile != nil) {
        BOOL isDirectory = [self.boxFile.type isEqualToString:@"folder"];
        if (isDirectory) {
            self.folderTitleLabel.text = self.boxFile.name;
            self.titleLabel.hidden = self.subtitleLabel.hidden = YES;
            self.folderTitleLabel.hidden = NO;
        } else {
            self.titleLabel.text = self.boxFile.name;
            self.subtitleLabel.text = (self.boxFile.size > 0) ? [NSByteCountFormatter stringFromByteCount:[self.boxFile.size longLongValue] countStyle:NSByteCountFormatterCountStyleFile]: @"";
            self.titleLabel.hidden = self.subtitleLabel.hidden = NO;
            self.folderTitleLabel.hidden = YES;
        }
        //TODO: correct thumbnails
//        if (_boxFile.modelID != nil) {
//            //this request needs a token in the header to work
//            NSString *thumbnailURLString = [NSString stringWithFormat:@"https://api.box.com/2.0/files/%@/thumbnail.png?min_height=32&min_width=32&max_height=64&max_width=64", _boxFile.modelID];
//            _iconURL = [NSURL URLWithString:thumbnailURLString];
//            [self performSelectorInBackground:@selector(_updateIconFromURL) withObject:@""];
//        }
        //TODO:correct icons
        if (isDirectory) {
            self.thumbnailView.image = [UIImage imageNamed:@"folder"];
        } else {
            self.thumbnailView.image = [UIImage imageNamed:@"blank"];
            APLog(@"missing icon for type '%@'", self.boxFile);
        }
    } else if(_oneDriveFile != nil) {
        if (_oneDriveFile.isFolder) {
            self.downloadButton.hidden = YES;
            self.folderTitleLabel.text = self.oneDriveFile.name;
            self.titleLabel.hidden = self.subtitleLabel.hidden = YES;
            self.folderTitleLabel.hidden = NO;
            self.thumbnailView.image = [UIImage imageNamed:@"folder"];
        } else {
            self.downloadButton.hidden = NO;
            self.titleLabel.text = self.oneDriveFile.name;
            NSMutableString *subtitle = [[NSMutableString alloc] init];
            if (self.oneDriveFile.size > 0) {
                [subtitle appendString:[NSByteCountFormatter stringFromByteCount:[self.oneDriveFile.size longLongValue] countStyle:NSByteCountFormatterCountStyleFile]];
                if (self.oneDriveFile.duration > 0) {
                    VLCTime *time = [VLCTime timeWithNumber:self.oneDriveFile.duration];
                    [subtitle appendFormat:@" — %@", [time verboseStringValue]];
                }
            } else if (self.oneDriveFile.duration > 0) {
                VLCTime *time = [VLCTime timeWithNumber:self.oneDriveFile.duration];
                [subtitle appendString:[time verboseStringValue]];
            }
            self.subtitleLabel.text = subtitle;
            self.titleLabel.hidden = self.subtitleLabel.hidden = NO;
            self.folderTitleLabel.hidden = YES;
            if (self.oneDriveFile.isAudio)
                self.thumbnailView.image = [UIImage imageNamed:@"audio"];
            else if (self.oneDriveFile.isVideo)
                self.thumbnailView.image = [UIImage imageNamed:@"movie"];
            else
                self.thumbnailView.image = [UIImage imageNamed:@"blank"];
        }
    }
    //we don't have streaming for box yet
    self.downloadButton.hidden = _boxFile != nil;

    [self setNeedsDisplay];
}

- (void)_updateIconFromURL
{
    NSData* imageData = [[NSData alloc]initWithContentsOfURL:_iconURL];
    UIImage* image = [[UIImage alloc] initWithData:imageData];
    if (image != nil) {
        self.thumbnailView.image = image;
    }
}

- (IBAction)triggerDownload:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(triggerDownloadForCell:)])
        [self.delegate triggerDownloadForCell:self];
}

+ (CGFloat)heightOfCell
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return 80.;

    return 48.;
}

@end
