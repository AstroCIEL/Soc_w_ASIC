// Copyright 2020 ETH Zurich and University of Bologna.
//
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Author: Matheus Cavalcante, ETH Zurich

#include <stdint.h>
#include <string.h>

#include "serial.h"
#include "printf.h"


#define SYS_CLK_HZ  500000000UL   /* 500 MHz — matches tb.sv */
#define BAUD_RATE   6250000UL     /* 500 MHz / (16*5) = 6.25 Mbaud; divisor=5 exact */


int main() {
  uart_init(SYS_CLK_HZ, BAUD_RATE);
  // printf("Ariane says Hello!\n");
  uart_puts("Ariane says Hello!\n");
  uart_flush_safe(SYS_CLK_HZ, BAUD_RATE);   

  return 0;
}
