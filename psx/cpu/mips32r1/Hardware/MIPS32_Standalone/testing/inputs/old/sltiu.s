.text
addiu $8, $zero, 0xfffffff0
addiu $9, $zero, 0x00ff
addiu $11, $zero, 0xff00

sltiu $3, $zero, 0x7fff
sltiu $4, $zero, 0x0000
sltiu $5, $zero, -0x8000
sltiu $6, $8, 0xffff
sltiu $20, $8, 0x4
sltiu $21, $11, -0x4
sltiu $22, $11, 0xfff 
addiu $2, $0, 10
syscall

