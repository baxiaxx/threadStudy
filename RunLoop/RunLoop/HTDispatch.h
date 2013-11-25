//
//  Header.h
//  threadStudy
//
//  Created by samuel on 13-10-24.
//  Copyright (c) 2013年 meandlife. All rights reserved.
//

#ifndef threadStudy_Header_h
#define threadStudy_Header_h

typedef void (^ht_block)();

void *ht_dispatch_init(void);

void ht_dispatch(void *handle, ht_block block);

void ht_dispatch_release(void *handle);

#endif
