.section .text
.global _start
_start:
    li sp, 8192
    call main

1:
    ebreak
    j 1b
  
