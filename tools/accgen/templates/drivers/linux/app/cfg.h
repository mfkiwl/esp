// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"
#include "acc_full_name.h"

typedef /* <<--token-type-->> */ token_t;

/* <<--params-def-->> */

/* <<--params-->> */

#define NACC 1

struct acc_full_name_access accelerator_name_cfg_000[] = {{
    /* <<--descriptor-->> */
    .src_offset    = 0,
    .dst_offset    = 0,
    .esp.coherence = ACC_COH_NONE,
    .esp.p2p_store = 0,
    .esp.p2p_nsrcs = 0,
    .esp.p2p_srcs  = {"", "", "", ""},
}};

esp_thread_info_t cfg_000[] = {{
    .run       = true,
    .devname   = "acc_full_name.0",
    .ioctl_req = ACC_FULL_NAME_IOC_ACCESS,
    .esp_desc  = &(accelerator_name_cfg_000[0].esp),
}};

#endif /* __ESP_CFG_000_H__ */
