//
//  CsoundStub.h
//  TestCsoundDynLink
//
//  Created by Carlos Millan on 11/10/15.
//  Copyright © 2015 Carlos Millan. All rights reserved.
//

#ifndef CsoundMIDI_h
#define CsoundMIDI_h

#import "csound.h"

@interface CsoundMIDI : NSObject
+(void)setMidiInCallbacks:(CSOUND *)csound;
@end

#endif /* CsoundMIDI_h */
