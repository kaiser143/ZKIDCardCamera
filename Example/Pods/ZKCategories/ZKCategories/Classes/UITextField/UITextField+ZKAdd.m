//
//  UITextField+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//
#import "UITextField+ZKAdd.h"
#import "ZKCategoriesMacro.h"
#import "NSObject+ZKAdd.h"
#import <objc/runtime.h>

static void *const UITextFieldDelegateKey = (void *)&UITextFieldDelegateKey;

ZKSYNTH_DUMMY_CLASS(UITextField_ZKAdd)

@implementation UITextField (ZKAdd)

- (NSRange)selectedRange {
    UITextPosition *beginning = self.beginningOfDocument;

    UITextRange *selectedRange     = self.selectedTextRange;
    UITextPosition *selectionStart = selectedRange.start;
    UITextPosition *selectionEnd   = selectedRange.end;

    NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    NSInteger length   = [self offsetFromPosition:selectionStart toPosition:selectionEnd];

    return NSMakeRange(location, length);
}

- (void)selectAllText {
    UITextRange *range = [self textRangeFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
    [self setSelectedTextRange:range];
}

- (void)setSelectedRange:(NSRange)range {
    UITextPosition *beginning     = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition   = [self positionFromPosition:beginning offset:NSMaxRange(range)];
    UITextRange *selectionRange   = [self textRangeFromPosition:startPosition toPosition:endPosition];
    [self setSelectedTextRange:selectionRange];
}

#pragma mark UITextField Delegate methods

+ (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.shouldBegindEditingBlock) {
        return textField.shouldBegindEditingBlock(textField);
    }

    id delegate = [self associatedValueForKey:UITextFieldDelegateKey];
    if ([delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [delegate textFieldShouldBeginEditing:textField];
    }
    // return default value just in case
    return YES;
}

+ (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField.shouldEndEditingBlock) {
        return textField.shouldEndEditingBlock(textField);
    }
    id delegate = [self associatedValueForKey:UITextFieldDelegateKey];
    if ([delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [delegate textFieldShouldEndEditing:textField];
    }
    // return default value just in case
    return YES;
}

+ (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.didBeginEditingBlock) {
        textField.didBeginEditingBlock(textField);
    }

    id delegate = [self associatedValueForKey:UITextFieldDelegateKey];
    if ([delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [delegate textFieldDidBeginEditing:textField];
    }
}

+ (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.didEndEditingBlock) {
        textField.didEndEditingBlock(textField);
    }
    id delegate = [self associatedValueForKey:UITextFieldDelegateKey];
    if ([delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [delegate textFieldDidBeginEditing:textField];
    }
}

+ (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.shouldChangeCharactersInRangeBlock) {
        return textField.shouldChangeCharactersInRangeBlock(textField, range, string);
    }
    id delegate = [self associatedValueForKey:UITextFieldDelegateKey];
    if ([delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return [delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return YES;
}

+ (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField.shouldClearBlock) {
        return textField.shouldClearBlock(textField);
    }
    id delegate = [self associatedValueForKey:UITextFieldDelegateKey];
    if ([delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [delegate textFieldShouldClear:textField];
    }
    return YES;
}

+ (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.shouldReturnBlock) {
        return textField.shouldReturnBlock(textField);
    }
    id delegate = [self associatedValueForKey:UITextFieldDelegateKey];
    if ([delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [delegate textFieldShouldReturn:textField];
    }
    return YES;
}

#pragma mark Block setting/getting methods

- (BOOL (^)(UITextField *))shouldBegindEditingBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)setShouldBegindEditingBlock:(BOOL (^)(UITextField *))shouldBegindEditingBlock {
    [self setDelegateIfNoDelegateSet];
    [self setAssociateCopyValue:shouldBegindEditingBlock withKey:@selector(shouldBegindEditingBlock)];
}

- (BOOL (^)(UITextField *))shouldEndEditingBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)setShouldEndEditingBlock:(BOOL (^)(UITextField *))shouldEndEditingBlock {
    [self setDelegateIfNoDelegateSet];
    [self setAssociateCopyValue:shouldEndEditingBlock withKey:@selector(shouldEndEditingBlock)];
}

- (void (^)(UITextField *))didBeginEditingBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)setDidBeginEditingBlock:(void (^)(UITextField *))didBeginEditingBlock {
    [self setDelegateIfNoDelegateSet];
    [self setAssociateCopyValue:didBeginEditingBlock withKey:@selector(didBeginEditingBlock)];
}

- (void (^)(UITextField *))didEndEditingBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)setDidEndEditingBlock:(void (^)(UITextField *))didEndEditingBlock {
    [self setDelegateIfNoDelegateSet];
    [self setAssociateCopyValue:didEndEditingBlock withKey:@selector(didEndEditingBlock)];
}

- (BOOL (^)(UITextField *, NSRange, NSString *))shouldChangeCharactersInRangeBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)setShouldChangeCharactersInRangeBlock:(BOOL (^)(UITextField *, NSRange, NSString *))shouldChangeCharactersInRangeBlock {
    [self setDelegateIfNoDelegateSet];
    [self setAssociateCopyValue:shouldChangeCharactersInRangeBlock withKey:@selector(shouldChangeCharactersInRangeBlock)];
}

- (BOOL (^)(UITextField *))shouldReturnBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setShouldReturnBlock:(BOOL (^)(UITextField *))shouldReturnBlock {
    [self setDelegateIfNoDelegateSet];
    [self setAssociateCopyValue:shouldReturnBlock withKey:@selector(shouldReturnBlock)];
}

- (BOOL (^)(UITextField *))shouldClearBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)setShouldClearBlock:(BOOL (^)(UITextField *textField))shouldClearBlock {
    [self setDelegateIfNoDelegateSet];
    [self setAssociateCopyValue:shouldClearBlock withKey:@selector(shouldClearBlock)];
}

#pragma mark control method
/*
 Setting itself as delegate if no other delegate has been set. This ensures the UITextField will use blocks if no delegate is set.
 */
- (void)setDelegateIfNoDelegateSet {
    if (self.delegate != (id<UITextFieldDelegate>)[self class]) {
        [self setAssociateWeakValue:self.delegate withKey:UITextFieldDelegateKey];
        self.delegate = (id<UITextFieldDelegate>)[self class];
    }
}

@end
