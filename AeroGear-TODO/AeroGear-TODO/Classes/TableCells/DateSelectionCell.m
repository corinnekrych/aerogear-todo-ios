/*
 * JBoss, Home of Professional Open Source.
 * Copyright 2012 Red Hat, Inc., and individual contributors
 * as indicated by the @author tags.
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

#import "DateSelectionCell.h"

@implementation DateSelectionCell {
    UIToolbar *_toolbar;
}

@synthesize dateValue = _dateValue;
@synthesize datePicker = _datePicker;

@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier])) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        _datePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;        
    }
    
    return self;
}

- (UIView *)inputView {
    return self.datePicker;
}

- (UIView *)inputAccessoryView {
    if (!_toolbar) {
        _toolbar = [[UIToolbar alloc] init];
        _toolbar.barStyle = UIBarStyleBlackTranslucent;
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [_toolbar sizeToFit];
        
        CGRect frame = _toolbar.frame;
        frame.size.height = 44.0f;
        _toolbar.frame = frame;

        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem *closeBtn =[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"Set" style:UIBarButtonItemStyleDone target:self action:@selector(done)];

        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, closeBtn, doneBtn, nil];
        [_toolbar setItems:array];
    }
    return _toolbar;
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (BOOL)becomeFirstResponder {
    if (self.dateValue != nil)
        self.datePicker.date = self.dateValue;
    
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
	UITableView *tableView = (UITableView *)self.superview;
	[tableView deselectRowAtIndexPath:[tableView indexPathForCell:self] animated:YES];
	
    return [super resignFirstResponder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
	if (selected) {
		[self becomeFirstResponder];
	}
}

- (void)close {
	[self resignFirstResponder];
}

- (void)done {
    [delegate tableViewCell:self didEndEditingWithDate:self.datePicker.date];
    [self resignFirstResponder];
}

@end
