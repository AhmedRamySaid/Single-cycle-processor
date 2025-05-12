# Single-cycle-processor
Single cycle processor coded in verilog based on the MIPS processor

![project](https://hackaday.com/wp-content/uploads/2017/05/riscarch_featured.png?w=800)

# Instruction set:

• the arithmetic and logic (add, sub, and, or, andi, addi, slt),

• Memory-reference (lw, sw),

• jumping and branching (j, beq) instructions;

• In addition to three new instructions (lea, mvz, and pcm) <br><br>

lea rt, rs, K

R[rt] = K*R[rt] + R[rs] 

multiply K by the least significant 10-bits of R[rt] content, then add the result to the content of R[rs]. 

K is a 9-bit constant. <br><br>

mvz rd, rs, rt 

if R[rt] = 0 then R[rd] = R[rs]; move the content of R[rs] to

R[rd] if the content of a register R[rt]= 0 <br><br>

pcm (rt), offset(rs) 

Perform two operations:

➢ PC = Memory[R[rt]]; set the value of PC to the loaded data from

memory location Memory[R[rt]]

➢ Memory[R[rs] + offset] = PC + 4; store the new value of

PC to a memory location Memory[R[rs] + offset] <br><br>

The code for the assembler for this processor is here:
https://github.com/AhmedRamySaid/Assembler
