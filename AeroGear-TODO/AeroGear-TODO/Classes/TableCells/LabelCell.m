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

#import "LabelCell.h"

@implementation LabelCell

@synthesize label = _label;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {

        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = UITextAlignmentRight;
        _label.textColor = [UIColor grayColor];
        _label.font = [UIFont boldSystemFontOfSize:12.0];
        _label.adjustsFontSizeToFitWidth = YES;
        _label.baselineAdjustment = UIBaselineAdjustmentNone;
        
        [self.contentView addSubview:_label];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
	
	CGRect r = CGRectInset(self.contentView.bounds, 8, 8);
	r.size = CGSizeMake(75,27);
	_label.frame = r;
}

@end
