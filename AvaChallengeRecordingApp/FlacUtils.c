//
//  FlacUtils.c
//  AvaChallengeRecordingApp
//
//  Created by Richard Martinez on 8/12/16.
//  Copyright © 2016 PhantomUniversalMediaProductions. All rights reserved.
//

#include "FlacUtils.h"
#include <stdlib.h>

char** flac_file_array() {
    char** flac_files = (char**) malloc(sizeof(char*) * 1024);
    for (int i = 0; i < 1024; i++) {
        *(flac_files + i) = NULL;
    }
    return flac_files;
}