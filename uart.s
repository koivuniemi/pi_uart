    .equ    UART_BIT_DELAY, 0xe000      // CPU freq: ~1000Mhz
    .global raspi_uart_9600_send

    .text
// raspi_uart_9600_send(set_reg*, clr_reg*, n'th_bit, const data*, data_len);
// if data_len is 0, data is null terminated string.
// return:  0(no error) or -1(error)
// uart settings: 
//      baud rate:  9600
//      data frame: 8 bits
//      parity bit: none
//      stop bit:   2
raspi_uart_9600_send:
    stp     x29, x30, [sp, #-32]!

    cmp     x4, #0              // if data_len = 0; calc str len
    b.ne    raspi_uart_9600_send_start
    mov     x5, x3
raspi_uart_9600_send_calc_str_len_loop:
    ldrb    w6, [x5], #1 
    cmp     x6, #0
    b.eq    raspi_uart_9600_send_calc_str_len_end
    add     x4, x4, #1
    b       raspi_uart_9600_send_calc_str_len_loop
raspi_uart_9600_send_calc_str_len_end:
    cmp     x4, #0              // if data_len = 0; empty str, exit func
    b.eq    raspi_uart_9600_send_ret

raspi_uart_9600_send_start:
    str     w2, [x0]            // Make sure wire is set high...
    mov     x14, #UART_BIT_DELAY    // ...before starting protocol
    bl      delay
raspi_uart_9600_send_frame_loop:
    mov     x5, #1
    ldrb    w6, [x3], #1        // load data byte
    str     w2, [x1]            // clr, start bit
    mov     x14, #UART_BIT_DELAY
    bl      delay
raspi_uart_9600_send_bit_loop:
    and     x7, x6, x5          // if bit high; set, else; clr
    cmp     x7, #0
    b.eq    raspi_uart_9600_send_clr
raspi_uart_9600_send_set:
    str     w2, [x0]            // set, data bit
    b       raspi_uart_9600_send_set_clr_end
raspi_uart_9600_send_clr:
    str     w2, [x1]            // clr, data bit
    b       raspi_uart_9600_send_set_clr_end
raspi_uart_9600_send_set_clr_end:
    mov     x14, #UART_BIT_DELAY
    bl      delay

    lsl     x5, x5, #1          // if last bit, next byte
    cmp     x5, #0b100000000
    b.ne    raspi_uart_9600_send_bit_loop

    str     w2, [x0]            // set, 2 stop bits
    mov     x14, #UART_BIT_DELAY * 2
    bl      delay

    sub     x4, x4, #1          // if last byte, exit func
    cmp     x4, #0
    b.ne    raspi_uart_9600_send_frame_loop

raspi_uart_9600_send_ret:
    mov     x0, #0              // no error
    ldp     x29, x30, [sp], #32
    ret

// x14: delay_len
delay:
    sub     x14, x14, #1
    cmp     x14, #0
    b.ne    delay
    ret
