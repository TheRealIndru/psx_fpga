.text
addiu $8, $zero, 10
addiu $9, $zero, 20
addiu $10, $zero, -10
addiu $11, $zero, -20
slt $12, $8, $9
slt $13, $9, $8
slt $14, $8, $10
slt $15, $10, $8
slt $16, $10, $11
slt $17, $11, $10
addiu $2, $0, 10
syscall
