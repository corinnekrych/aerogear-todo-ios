/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "TextViewCell.h"

@implementation TextViewCell

@synthesize txtView = _txtView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
  
        _txtView = [[UITextView alloc] initWithFrame:CGRectZero];
        _txtView.font = [UIFont boldSystemFontOfSize:14.0];
        _txtView.backgroundColor = [UIColor clearColor];
       
        [self.contentView addSubview:_txtView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;        
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

	CGRect r = CGRectInset(self.contentView.bounds, 4, 8);
	_txtView.frame = r;
}

@end
