//
//  ChatTableCell.m
//  TwitterChatApplication
//
//  Created by Preety Pednekar on 7/12/15.
//  Copyright (c) 2015 Preety Pednekar. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "ChatTableCell.h"
#import "Constants.h"

@implementation ChatTableCell

@synthesize chatText;
@synthesize chatBackgroundImage;
@synthesize isMyChat;
@synthesize message;

-(void) layoutSubviews
{
    CGSize maxSize = self.frame.size;
    maxSize.width -= (maxSize.width)/4;
    maxSize.height = UILABEL_MAX_HEIGHT;

    // get expected size for the text
    CGRect expectedRect = [self.message boundingRectWithSize: maxSize
                                                options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                             attributes: @{NSFontAttributeName: [UIFont fontWithName: FONT_NAME size: FONT_SIZE]}
                                                context: nil];
    
    CGRect labelFrame = self.chatText.frame;
    labelFrame.size.height = (expectedRect.size.height > CHAT_TEXT_MIN_HEIGHT) ? expectedRect.size.height : CHAT_TEXT_MIN_HEIGHT;
    labelFrame.size.width  = expectedRect.size.width;
    labelFrame.origin.y    = 2 * CHAT_CELL_BUFFERS;
    
    CGRect imageFrame = self.chatBackgroundImage.frame;
    imageFrame.size.height = expectedRect.size.height + 2 * CHAT_CELL_BUFFERS;
    imageFrame.size.width  = expectedRect.size.width  + 2 * CHAT_CELL_BUFFERS + 10; // 10px is for the left/right arrow
    imageFrame.origin.y    = CHAT_CELL_BUFFERS;
    
    CGRect selfFrame = self.frame;
    selfFrame.size.height = imageFrame.size.height + 2 * CHAT_CELL_BUFFERS;
    if (selfFrame.size.height > CHAT_CELL_MIN_HEIGHT)
    {
        // if cell height is more than minimum height, then only change the cell frame
        self.frame = selfFrame;
    }
    
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(12, 20, 13, 12);
    
    if (isMyChat)
    {
        // if it is my chat, edge inset will change as the bubble will start from right side.
        imageFrame.origin.x = self.frame.size.width - imageFrame.size.width - 10.0f;
        labelFrame.origin.x = imageFrame.origin.x + CHAT_CELL_BUFFERS;
        edgeInsets = UIEdgeInsetsMake(12, 12, 13, 20);
    }
    else
    {
        labelFrame.origin.x = imageFrame.origin.x + 10 + CHAT_CELL_BUFFERS;
    }
    
    self.chatText.frame = labelFrame;
    self.chatBackgroundImage.frame = imageFrame;
    
    // resize the bubble image as per the size of chat text
    UIImage *backgroundImage = self.chatBackgroundImage.image;
    self.chatBackgroundImage.image = [backgroundImage resizableImageWithCapInsets: edgeInsets resizingMode: UIImageResizingModeStretch];
    
    self.chatText.text = self.message;
}

@end
