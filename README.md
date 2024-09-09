# Work in progress!
# Usage
Exports function raspi_uart_9600_send.
```
raspi_uart_9600_send(set_reg*, clr_reg*, nth_bit, const data*, data_len);
if data_len is 0, data is null terminated string.
return:  0(no error) or -1(error)
uart settings: 
     baud rate:  9600
     data frame: 8 bits
     parity bit: none
     stop bit:   2
```
