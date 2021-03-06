/*
 Copyright 2016 OpenMarket Ltd
 Copyright 2017 Vector Creations Ltd

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "FilesSearchCellData.h"

#import "MXRoom+Riot.h"

@implementation FilesSearchCellData
@synthesize roomId, senderDisplayName;
@synthesize searchResult, title, message, date, shouldShowRoomDisplayName, roomDisplayName, attachment, isAttachmentWithThumbnail, attachmentIcon;

- (instancetype)initWithSearchResult:(MXSearchResult *)searchResult2 andSearchDataSource:(MXKSearchDataSource *)searchDataSource2
{
    self = [super init];
    if (self)
    {
        searchResult = searchResult2;
        searchDataSource = searchDataSource2;
        
        MXEvent *event = searchResult.result;

        roomId = event.roomId;
        
        // Title is here the file name stored in event body
        title = [event.content[@"body"] isKindOfClass:[NSString class]] ? event.content[@"body"] : nil;
        
        // Append the file size if any
        if (attachment.contentInfo[@"size"])
        {
            NSInteger size = [attachment.contentInfo[@"size"] integerValue];
            if (size)
            {
                title = [NSString stringWithFormat:@"%@ (%@)", title, [MXTools fileSizeToString:size round:YES]];
            }
        }
        
        date = [searchDataSource.eventFormatter dateStringFromEvent:event withTime:NO];
        
        // Retrieve the sender display name from the current room state
        MXRoom *room = [searchDataSource.mxSession roomWithRoomId:roomId];
        if (room)
        {
            senderDisplayName = [room.state memberName:event.sender];
        }
        else
        {
            senderDisplayName = event.sender;
        }
        
        message = senderDisplayName;
    }
    return self;
}

- (void)setShouldShowRoomDisplayName:(BOOL)shouldShowRoomDisplayName2
{
    shouldShowRoomDisplayName = shouldShowRoomDisplayName2;
    
    if (shouldShowRoomDisplayName)
    {
        MXRoom *room = [searchDataSource.mxSession roomWithRoomId:roomId];
        if (room)
        {
            roomDisplayName = room.riotDisplayname;
            if (!roomDisplayName.length)
            {
                roomDisplayName = NSLocalizedStringFromTable(@"room_displayname_no_title", @"Vector", nil);
            }
        }
        else
        {
            roomDisplayName = roomId;
        }
        
        message = [NSString stringWithFormat:@"%@ - %@", roomDisplayName, senderDisplayName];
    }
    else
    {
        message = senderDisplayName;
    }
}

- (BOOL)isAttachmentWithThumbnail
{
    return (attachment && (attachment.type == MXKAttachmentTypeImage || attachment.type == MXKAttachmentTypeVideo));
}

- (UIImage*)attachmentIcon
{
    MXEvent *event = searchResult.result;
    NSString *msgtype;
    MXJSONModelSetString(msgtype, event.content[@"msgtype"]);
    
    if ([msgtype isEqualToString:kMXMessageTypeImage])
    {
        return [UIImage imageNamed:@"file_photo_icon"];
    }
    else if ([msgtype isEqualToString:kMXMessageTypeAudio])
    {
        return [UIImage imageNamed:@"file_audio_icon"];
    }
    else if ([msgtype isEqualToString:kMXMessageTypeVideo])
    {
       return [UIImage imageNamed:@"file_video_icon"];
    }
    else if ([msgtype isEqualToString:kMXMessageTypeLocation])
    {
        // Not supported yet
    }
    else if ([msgtype isEqualToString:kMXMessageTypeFile])
    {
        return [UIImage imageNamed:@"file_doc_icon"];
    }
    
    return nil;
}

@end
