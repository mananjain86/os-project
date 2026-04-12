
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	87010113          	addi	sp,sp,-1936 # 80007870 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04e000ef          	jal	80000064 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002c:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000003a:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000046:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000058:	14d79073          	csrw	stimecmp,a5
}
    8000005c:	60a2                	ld	ra,8(sp)
    8000005e:	6402                	ld	s0,0(sp)
    80000060:	0141                	addi	sp,sp,16
    80000062:	8082                	ret

0000000080000064 <start>:
{
    80000064:	1141                	addi	sp,sp,-16
    80000066:	e406                	sd	ra,8(sp)
    80000068:	e022                	sd	s0,0(sp)
    8000006a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdda87>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	e2a78793          	addi	a5,a5,-470 # 80000eae <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a6:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c8:	30200073          	mret
}
    800000cc:	60a2                	ld	ra,8(sp)
    800000ce:	6402                	ld	s0,0(sp)
    800000d0:	0141                	addi	sp,sp,16
    800000d2:	8082                	ret

00000000800000d4 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d4:	7119                	addi	sp,sp,-128
    800000d6:	fc86                	sd	ra,120(sp)
    800000d8:	f8a2                	sd	s0,112(sp)
    800000da:	f4a6                	sd	s1,104(sp)
    800000dc:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000de:	06c05b63          	blez	a2,80000154 <consolewrite+0x80>
    800000e2:	f0ca                	sd	s2,96(sp)
    800000e4:	ecce                	sd	s3,88(sp)
    800000e6:	e8d2                	sd	s4,80(sp)
    800000e8:	e4d6                	sd	s5,72(sp)
    800000ea:	e0da                	sd	s6,64(sp)
    800000ec:	fc5e                	sd	s7,56(sp)
    800000ee:	f862                	sd	s8,48(sp)
    800000f0:	f466                	sd	s9,40(sp)
    800000f2:	f06a                	sd	s10,32(sp)
    800000f4:	8b2a                	mv	s6,a0
    800000f6:	8bae                	mv	s7,a1
    800000f8:	8a32                	mv	s4,a2
  int i = 0;
    800000fa:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000fc:	02000c93          	li	s9,32
    80000100:	02000d13          	li	s10,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000104:	f8040a93          	addi	s5,s0,-128
    80000108:	5c7d                	li	s8,-1
    8000010a:	a025                	j	80000132 <consolewrite+0x5e>
    if(nn > n - i)
    8000010c:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000110:	86ce                	mv	a3,s3
    80000112:	01748633          	add	a2,s1,s7
    80000116:	85da                	mv	a1,s6
    80000118:	8556                	mv	a0,s5
    8000011a:	1c8020ef          	jal	800022e2 <either_copyin>
    8000011e:	03850d63          	beq	a0,s8,80000158 <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000122:	85ce                	mv	a1,s3
    80000124:	8556                	mv	a0,s5
    80000126:	7b4000ef          	jal	800008da <uartwrite>
    i += nn;
    8000012a:	009904bb          	addw	s1,s2,s1
  while(i < n){
    8000012e:	0144d963          	bge	s1,s4,80000140 <consolewrite+0x6c>
    if(nn > n - i)
    80000132:	409a07bb          	subw	a5,s4,s1
    80000136:	893e                	mv	s2,a5
    80000138:	fcfcdae3          	bge	s9,a5,8000010c <consolewrite+0x38>
    8000013c:	896a                	mv	s2,s10
    8000013e:	b7f9                	j	8000010c <consolewrite+0x38>
    80000140:	7906                	ld	s2,96(sp)
    80000142:	69e6                	ld	s3,88(sp)
    80000144:	6a46                	ld	s4,80(sp)
    80000146:	6aa6                	ld	s5,72(sp)
    80000148:	6b06                	ld	s6,64(sp)
    8000014a:	7be2                	ld	s7,56(sp)
    8000014c:	7c42                	ld	s8,48(sp)
    8000014e:	7ca2                	ld	s9,40(sp)
    80000150:	7d02                	ld	s10,32(sp)
    80000152:	a821                	j	8000016a <consolewrite+0x96>
  int i = 0;
    80000154:	4481                	li	s1,0
    80000156:	a811                	j	8000016a <consolewrite+0x96>
    80000158:	7906                	ld	s2,96(sp)
    8000015a:	69e6                	ld	s3,88(sp)
    8000015c:	6a46                	ld	s4,80(sp)
    8000015e:	6aa6                	ld	s5,72(sp)
    80000160:	6b06                	ld	s6,64(sp)
    80000162:	7be2                	ld	s7,56(sp)
    80000164:	7c42                	ld	s8,48(sp)
    80000166:	7ca2                	ld	s9,40(sp)
    80000168:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000016a:	8526                	mv	a0,s1
    8000016c:	70e6                	ld	ra,120(sp)
    8000016e:	7446                	ld	s0,112(sp)
    80000170:	74a6                	ld	s1,104(sp)
    80000172:	6109                	addi	sp,sp,128
    80000174:	8082                	ret

0000000080000176 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000176:	711d                	addi	sp,sp,-96
    80000178:	ec86                	sd	ra,88(sp)
    8000017a:	e8a2                	sd	s0,80(sp)
    8000017c:	e4a6                	sd	s1,72(sp)
    8000017e:	e0ca                	sd	s2,64(sp)
    80000180:	fc4e                	sd	s3,56(sp)
    80000182:	f852                	sd	s4,48(sp)
    80000184:	f05a                	sd	s6,32(sp)
    80000186:	ec5e                	sd	s7,24(sp)
    80000188:	1080                	addi	s0,sp,96
    8000018a:	8b2a                	mv	s6,a0
    8000018c:	8a2e                	mv	s4,a1
    8000018e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000190:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    80000192:	0000f517          	auipc	a0,0xf
    80000196:	6de50513          	addi	a0,a0,1758 # 8000f870 <cons>
    8000019a:	28f000ef          	jal	80000c28 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	0000f497          	auipc	s1,0xf
    800001a2:	6d248493          	addi	s1,s1,1746 # 8000f870 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	0000f917          	auipc	s2,0xf
    800001aa:	76290913          	addi	s2,s2,1890 # 8000f908 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	770010ef          	jal	8000192e <myproc>
    800001c2:	7b9010ef          	jal	8000217a <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	573010ef          	jal	80001f3e <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	0000f717          	auipc	a4,0xf
    800001e2:	69270713          	addi	a4,a4,1682 # 8000f870 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070a9b          	sext.w	s5,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	04da8663          	beq	s5,a3,8000024a <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	855a                	mv	a0,s6
    80000210:	088020ef          	jal	80002298 <either_copyout>
    80000214:	57fd                	li	a5,-1
    80000216:	04f50663          	beq	a0,a5,80000262 <consoleread+0xec>
      break;

    dst++;
    8000021a:	0a05                	addi	s4,s4,1
    --n;
    8000021c:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000021e:	47a9                	li	a5,10
    80000220:	04fa8b63          	beq	s5,a5,80000276 <consoleread+0x100>
    80000224:	7aa2                	ld	s5,40(sp)
    80000226:	b761                	j	800001ae <consoleread+0x38>
        release(&cons.lock);
    80000228:	0000f517          	auipc	a0,0xf
    8000022c:	64850513          	addi	a0,a0,1608 # 8000f870 <cons>
    80000230:	28d000ef          	jal	80000cbc <release>
        return -1;
    80000234:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000236:	60e6                	ld	ra,88(sp)
    80000238:	6446                	ld	s0,80(sp)
    8000023a:	64a6                	ld	s1,72(sp)
    8000023c:	6906                	ld	s2,64(sp)
    8000023e:	79e2                	ld	s3,56(sp)
    80000240:	7a42                	ld	s4,48(sp)
    80000242:	7b02                	ld	s6,32(sp)
    80000244:	6be2                	ld	s7,24(sp)
    80000246:	6125                	addi	sp,sp,96
    80000248:	8082                	ret
      if(n < target){
    8000024a:	0179fa63          	bgeu	s3,s7,8000025e <consoleread+0xe8>
        cons.r--;
    8000024e:	0000f717          	auipc	a4,0xf
    80000252:	6af72d23          	sw	a5,1722(a4) # 8000f908 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	0000f517          	auipc	a0,0xf
    80000268:	60c50513          	addi	a0,a0,1548 # 8000f870 <cons>
    8000026c:	251000ef          	jal	80000cbc <release>
  return target - n;
    80000270:	413b853b          	subw	a0,s7,s3
    80000274:	b7c9                	j	80000236 <consoleread+0xc0>
    80000276:	7aa2                	ld	s5,40(sp)
    80000278:	b7f5                	j	80000264 <consoleread+0xee>

000000008000027a <consputc>:
{
    8000027a:	1141                	addi	sp,sp,-16
    8000027c:	e406                	sd	ra,8(sp)
    8000027e:	e022                	sd	s0,0(sp)
    80000280:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000282:	10000793          	li	a5,256
    80000286:	00f50863          	beq	a0,a5,80000296 <consputc+0x1c>
    uartputc_sync(c);
    8000028a:	6e4000ef          	jal	8000096e <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	6d6000ef          	jal	8000096e <uartputc_sync>
    8000029c:	02000513          	li	a0,32
    800002a0:	6ce000ef          	jal	8000096e <uartputc_sync>
    800002a4:	4521                	li	a0,8
    800002a6:	6c8000ef          	jal	8000096e <uartputc_sync>
    800002aa:	b7d5                	j	8000028e <consputc+0x14>

00000000800002ac <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ac:	1101                	addi	sp,sp,-32
    800002ae:	ec06                	sd	ra,24(sp)
    800002b0:	e822                	sd	s0,16(sp)
    800002b2:	e426                	sd	s1,8(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	0000f517          	auipc	a0,0xf
    800002bc:	5b850513          	addi	a0,a0,1464 # 8000f870 <cons>
    800002c0:	169000ef          	jal	80000c28 <acquire>

  switch(c){
    800002c4:	47d5                	li	a5,21
    800002c6:	08f48d63          	beq	s1,a5,80000360 <consoleintr+0xb4>
    800002ca:	0297c563          	blt	a5,s1,800002f4 <consoleintr+0x48>
    800002ce:	47a1                	li	a5,8
    800002d0:	0ef48263          	beq	s1,a5,800003b4 <consoleintr+0x108>
    800002d4:	47c1                	li	a5,16
    800002d6:	10f49363          	bne	s1,a5,800003dc <consoleintr+0x130>
  case C('P'):  // Print process list.
    procdump();
    800002da:	052020ef          	jal	8000232c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	0000f517          	auipc	a0,0xf
    800002e2:	59250513          	addi	a0,a0,1426 # 8000f870 <cons>
    800002e6:	1d7000ef          	jal	80000cbc <release>
}
    800002ea:	60e2                	ld	ra,24(sp)
    800002ec:	6442                	ld	s0,16(sp)
    800002ee:	64a2                	ld	s1,8(sp)
    800002f0:	6105                	addi	sp,sp,32
    800002f2:	8082                	ret
  switch(c){
    800002f4:	07f00793          	li	a5,127
    800002f8:	0af48e63          	beq	s1,a5,800003b4 <consoleintr+0x108>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fc:	0000f717          	auipc	a4,0xf
    80000300:	57470713          	addi	a4,a4,1396 # 8000f870 <cons>
    80000304:	0a072783          	lw	a5,160(a4)
    80000308:	09872703          	lw	a4,152(a4)
    8000030c:	9f99                	subw	a5,a5,a4
    8000030e:	07f00713          	li	a4,127
    80000312:	fcf766e3          	bltu	a4,a5,800002de <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000316:	47b5                	li	a5,13
    80000318:	0cf48563          	beq	s1,a5,800003e2 <consoleintr+0x136>
      consputc(c);
    8000031c:	8526                	mv	a0,s1
    8000031e:	f5dff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000322:	0000f717          	auipc	a4,0xf
    80000326:	54e70713          	addi	a4,a4,1358 # 8000f870 <cons>
    8000032a:	0a072683          	lw	a3,160(a4)
    8000032e:	0016879b          	addiw	a5,a3,1
    80000332:	863e                	mv	a2,a5
    80000334:	0af72023          	sw	a5,160(a4)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	9736                	add	a4,a4,a3
    8000033e:	00970c23          	sb	s1,24(a4)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	ff648713          	addi	a4,s1,-10
    80000346:	c371                	beqz	a4,8000040a <consoleintr+0x15e>
    80000348:	14f1                	addi	s1,s1,-4
    8000034a:	c0e1                	beqz	s1,8000040a <consoleintr+0x15e>
    8000034c:	0000f717          	auipc	a4,0xf
    80000350:	5bc72703          	lw	a4,1468(a4) # 8000f908 <cons+0x98>
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	08000713          	li	a4,128
    8000035a:	f8e792e3          	bne	a5,a4,800002de <consoleintr+0x32>
    8000035e:	a075                	j	8000040a <consoleintr+0x15e>
    80000360:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000362:	0000f717          	auipc	a4,0xf
    80000366:	50e70713          	addi	a4,a4,1294 # 8000f870 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000372:	0000f497          	auipc	s1,0xf
    80000376:	4fe48493          	addi	s1,s1,1278 # 8000f870 <cons>
    while(cons.e != cons.w &&
    8000037a:	4929                	li	s2,10
    8000037c:	02f70863          	beq	a4,a5,800003ac <consoleintr+0x100>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000380:	37fd                	addiw	a5,a5,-1
    80000382:	07f7f713          	andi	a4,a5,127
    80000386:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000388:	01874703          	lbu	a4,24(a4)
    8000038c:	03270263          	beq	a4,s2,800003b0 <consoleintr+0x104>
      cons.e--;
    80000390:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000394:	10000513          	li	a0,256
    80000398:	ee3ff0ef          	jal	8000027a <consputc>
    while(cons.e != cons.w &&
    8000039c:	0a04a783          	lw	a5,160(s1)
    800003a0:	09c4a703          	lw	a4,156(s1)
    800003a4:	fcf71ee3          	bne	a4,a5,80000380 <consoleintr+0xd4>
    800003a8:	6902                	ld	s2,0(sp)
    800003aa:	bf15                	j	800002de <consoleintr+0x32>
    800003ac:	6902                	ld	s2,0(sp)
    800003ae:	bf05                	j	800002de <consoleintr+0x32>
    800003b0:	6902                	ld	s2,0(sp)
    800003b2:	b735                	j	800002de <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b4:	0000f717          	auipc	a4,0xf
    800003b8:	4bc70713          	addi	a4,a4,1212 # 8000f870 <cons>
    800003bc:	0a072783          	lw	a5,160(a4)
    800003c0:	09c72703          	lw	a4,156(a4)
    800003c4:	f0f70de3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003c8:	37fd                	addiw	a5,a5,-1
    800003ca:	0000f717          	auipc	a4,0xf
    800003ce:	54f72323          	sw	a5,1350(a4) # 8000f910 <cons+0xa0>
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	ea5ff0ef          	jal	8000027a <consputc>
    800003da:	b711                	j	800002de <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003dc:	f00481e3          	beqz	s1,800002de <consoleintr+0x32>
    800003e0:	bf31                	j	800002fc <consoleintr+0x50>
      consputc(c);
    800003e2:	4529                	li	a0,10
    800003e4:	e97ff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003e8:	0000f797          	auipc	a5,0xf
    800003ec:	48878793          	addi	a5,a5,1160 # 8000f870 <cons>
    800003f0:	0a07a703          	lw	a4,160(a5)
    800003f4:	0017069b          	addiw	a3,a4,1
    800003f8:	8636                	mv	a2,a3
    800003fa:	0ad7a023          	sw	a3,160(a5)
    800003fe:	07f77713          	andi	a4,a4,127
    80000402:	97ba                	add	a5,a5,a4
    80000404:	4729                	li	a4,10
    80000406:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040a:	0000f797          	auipc	a5,0xf
    8000040e:	50c7a123          	sw	a2,1282(a5) # 8000f90c <cons+0x9c>
        wakeup(&cons.r);
    80000412:	0000f517          	auipc	a0,0xf
    80000416:	4f650513          	addi	a0,a0,1270 # 8000f908 <cons+0x98>
    8000041a:	371010ef          	jal	80001f8a <wakeup>
    8000041e:	b5c1                	j	800002de <consoleintr+0x32>

0000000080000420 <consoleinit>:

void
consoleinit(void)
{
    80000420:	1141                	addi	sp,sp,-16
    80000422:	e406                	sd	ra,8(sp)
    80000424:	e022                	sd	s0,0(sp)
    80000426:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000428:	00007597          	auipc	a1,0x7
    8000042c:	bd858593          	addi	a1,a1,-1064 # 80007000 <etext>
    80000430:	0000f517          	auipc	a0,0xf
    80000434:	44050513          	addi	a0,a0,1088 # 8000f870 <cons>
    80000438:	766000ef          	jal	80000b9e <initlock>

  uartinit();
    8000043c:	448000ef          	jal	80000884 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	0001f797          	auipc	a5,0x1f
    80000444:	7a078793          	addi	a5,a5,1952 # 8001fbe0 <devsw>
    80000448:	00000717          	auipc	a4,0x0
    8000044c:	d2e70713          	addi	a4,a4,-722 # 80000176 <consoleread>
    80000450:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000452:	00000717          	auipc	a4,0x0
    80000456:	c8270713          	addi	a4,a4,-894 # 800000d4 <consolewrite>
    8000045a:	ef98                	sd	a4,24(a5)
}
    8000045c:	60a2                	ld	ra,8(sp)
    8000045e:	6402                	ld	s0,0(sp)
    80000460:	0141                	addi	sp,sp,16
    80000462:	8082                	ret

0000000080000464 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000464:	7139                	addi	sp,sp,-64
    80000466:	fc06                	sd	ra,56(sp)
    80000468:	f822                	sd	s0,48(sp)
    8000046a:	f04a                	sd	s2,32(sp)
    8000046c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000046e:	c219                	beqz	a2,80000474 <printint+0x10>
    80000470:	08054163          	bltz	a0,800004f2 <printint+0x8e>
    x = -xx;
  else
    x = xx;
    80000474:	4301                	li	t1,0

  i = 0;
    80000476:	fc840913          	addi	s2,s0,-56
    x = xx;
    8000047a:	86ca                	mv	a3,s2
  i = 0;
    8000047c:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00007817          	auipc	a6,0x7
    80000482:	29280813          	addi	a6,a6,658 # 80007710 <digits>
    80000486:	88ba                	mv	a7,a4
    80000488:	0017061b          	addiw	a2,a4,1
    8000048c:	8732                	mv	a4,a2
    8000048e:	02b577b3          	remu	a5,a0,a1
    80000492:	97c2                	add	a5,a5,a6
    80000494:	0007c783          	lbu	a5,0(a5)
    80000498:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    8000049c:	87aa                	mv	a5,a0
    8000049e:	02b55533          	divu	a0,a0,a1
    800004a2:	0685                	addi	a3,a3,1
    800004a4:	feb7f1e3          	bgeu	a5,a1,80000486 <printint+0x22>

  if(sign)
    800004a8:	00030c63          	beqz	t1,800004c0 <printint+0x5c>
    buf[i++] = '-';
    800004ac:	fe060793          	addi	a5,a2,-32
    800004b0:	00878633          	add	a2,a5,s0
    800004b4:	02d00793          	li	a5,45
    800004b8:	fef60423          	sb	a5,-24(a2)
    800004bc:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
    800004c0:	02e05463          	blez	a4,800004e8 <printint+0x84>
    800004c4:	f426                	sd	s1,40(sp)
    800004c6:	377d                	addiw	a4,a4,-1
    800004c8:	00e904b3          	add	s1,s2,a4
    800004cc:	197d                	addi	s2,s2,-1
    800004ce:	993a                	add	s2,s2,a4
    800004d0:	1702                	slli	a4,a4,0x20
    800004d2:	9301                	srli	a4,a4,0x20
    800004d4:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    800004d8:	0004c503          	lbu	a0,0(s1)
    800004dc:	d9fff0ef          	jal	8000027a <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x74>
    800004e6:	74a2                	ld	s1,40(sp)
}
    800004e8:	70e2                	ld	ra,56(sp)
    800004ea:	7442                	ld	s0,48(sp)
    800004ec:	7902                	ld	s2,32(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4305                	li	t1,1
    x = -xx;
    800004f8:	bfbd                	j	80000476 <printint+0x12>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	f0ca                	sd	s2,96(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	892a                	mv	s2,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	00007797          	auipc	a5,0x7
    8000051c:	32c7a783          	lw	a5,812(a5) # 80007844 <panicking>
    80000520:	cf9d                	beqz	a5,8000055e <printf+0x64>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	00094503          	lbu	a0,0(s2)
    8000052e:	22050663          	beqz	a0,8000075a <printf+0x260>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	ecce                	sd	s3,88(sp)
    80000536:	e8d2                	sd	s4,80(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	fc5e                	sd	s7,56(sp)
    8000053e:	f862                	sd	s8,48(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4a01                	li	s4,0
    if(cx != '%'){
    80000546:	02500993          	li	s3,37
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000054a:	07500c13          	li	s8,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    8000054e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000552:	07000d93          	li	s11,112
      printint(va_arg(ap, uint64), 10, 0);
    80000556:	4b29                	li	s6,10
    if(c0 == 'd'){
    80000558:	06400b93          	li	s7,100
    8000055c:	a015                	j	80000580 <printf+0x86>
    acquire(&pr.lock);
    8000055e:	0000f517          	auipc	a0,0xf
    80000562:	3ba50513          	addi	a0,a0,954 # 8000f918 <pr>
    80000566:	6c2000ef          	jal	80000c28 <acquire>
    8000056a:	bf65                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056c:	d0fff0ef          	jal	8000027a <consputc>
      continue;
    80000570:	84d2                	mv	s1,s4
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000572:	2485                	addiw	s1,s1,1
    80000574:	8a26                	mv	s4,s1
    80000576:	94ca                	add	s1,s1,s2
    80000578:	0004c503          	lbu	a0,0(s1)
    8000057c:	1c050663          	beqz	a0,80000748 <printf+0x24e>
    if(cx != '%'){
    80000580:	ff3516e3          	bne	a0,s3,8000056c <printf+0x72>
    i++;
    80000584:	001a079b          	addiw	a5,s4,1
    80000588:	84be                	mv	s1,a5
    c0 = fmt[i+0] & 0xff;
    8000058a:	00f90733          	add	a4,s2,a5
    8000058e:	00074a83          	lbu	s5,0(a4)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000592:	200a8963          	beqz	s5,800007a4 <printf+0x2aa>
    80000596:	00174683          	lbu	a3,1(a4)
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059a:	1e068c63          	beqz	a3,80000792 <printf+0x298>
    if(c0 == 'd'){
    8000059e:	037a8863          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    800005a2:	f94a8713          	addi	a4,s5,-108
    800005a6:	00173713          	seqz	a4,a4
    800005aa:	f9c68613          	addi	a2,a3,-100
    800005ae:	ee05                	bnez	a2,800005e6 <printf+0xec>
    800005b0:	cb1d                	beqz	a4,800005e6 <printf+0xec>
      printint(va_arg(ap, uint64), 10, 1);
    800005b2:	f8843783          	ld	a5,-120(s0)
    800005b6:	00878713          	addi	a4,a5,8
    800005ba:	f8e43423          	sd	a4,-120(s0)
    800005be:	4605                	li	a2,1
    800005c0:	85da                	mv	a1,s6
    800005c2:	6388                	ld	a0,0(a5)
    800005c4:	ea1ff0ef          	jal	80000464 <printint>
      i += 1;
    800005c8:	002a049b          	addiw	s1,s4,2
    800005cc:	b75d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, int), 10, 1);
    800005ce:	f8843783          	ld	a5,-120(s0)
    800005d2:	00878713          	addi	a4,a5,8
    800005d6:	f8e43423          	sd	a4,-120(s0)
    800005da:	4605                	li	a2,1
    800005dc:	85da                	mv	a1,s6
    800005de:	4388                	lw	a0,0(a5)
    800005e0:	e85ff0ef          	jal	80000464 <printint>
    800005e4:	b779                	j	80000572 <printf+0x78>
    if(c1) c2 = fmt[i+2] & 0xff;
    800005e6:	97ca                	add	a5,a5,s2
    800005e8:	8636                	mv	a2,a3
    800005ea:	0027c683          	lbu	a3,2(a5)
    800005ee:	a2c9                	j	800007b0 <printf+0x2b6>
      printint(va_arg(ap, uint64), 10, 1);
    800005f0:	f8843783          	ld	a5,-120(s0)
    800005f4:	00878713          	addi	a4,a5,8
    800005f8:	f8e43423          	sd	a4,-120(s0)
    800005fc:	4605                	li	a2,1
    800005fe:	45a9                	li	a1,10
    80000600:	6388                	ld	a0,0(a5)
    80000602:	e63ff0ef          	jal	80000464 <printint>
      i += 2;
    80000606:	003a049b          	addiw	s1,s4,3
    8000060a:	b7a5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 10, 0);
    8000060c:	f8843783          	ld	a5,-120(s0)
    80000610:	00878713          	addi	a4,a5,8
    80000614:	f8e43423          	sd	a4,-120(s0)
    80000618:	4601                	li	a2,0
    8000061a:	85da                	mv	a1,s6
    8000061c:	0007e503          	lwu	a0,0(a5)
    80000620:	e45ff0ef          	jal	80000464 <printint>
    80000624:	b7b9                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000626:	f8843783          	ld	a5,-120(s0)
    8000062a:	00878713          	addi	a4,a5,8
    8000062e:	f8e43423          	sd	a4,-120(s0)
    80000632:	4601                	li	a2,0
    80000634:	85da                	mv	a1,s6
    80000636:	6388                	ld	a0,0(a5)
    80000638:	e2dff0ef          	jal	80000464 <printint>
      i += 1;
    8000063c:	002a049b          	addiw	s1,s4,2
    80000640:	bf0d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000642:	f8843783          	ld	a5,-120(s0)
    80000646:	00878713          	addi	a4,a5,8
    8000064a:	f8e43423          	sd	a4,-120(s0)
    8000064e:	4601                	li	a2,0
    80000650:	45a9                	li	a1,10
    80000652:	6388                	ld	a0,0(a5)
    80000654:	e11ff0ef          	jal	80000464 <printint>
      i += 2;
    80000658:	003a049b          	addiw	s1,s4,3
    8000065c:	bf19                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 16, 0);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4601                	li	a2,0
    8000066c:	45c1                	li	a1,16
    8000066e:	0007e503          	lwu	a0,0(a5)
    80000672:	df3ff0ef          	jal	80000464 <printint>
    80000676:	bdf5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	45c1                	li	a1,16
    80000686:	6388                	ld	a0,0(a5)
    80000688:	dddff0ef          	jal	80000464 <printint>
      i += 1;
    8000068c:	002a049b          	addiw	s1,s4,2
    80000690:	b5cd                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000692:	f8843783          	ld	a5,-120(s0)
    80000696:	00878713          	addi	a4,a5,8
    8000069a:	f8e43423          	sd	a4,-120(s0)
    8000069e:	4601                	li	a2,0
    800006a0:	45c1                	li	a1,16
    800006a2:	6388                	ld	a0,0(a5)
    800006a4:	dc1ff0ef          	jal	80000464 <printint>
      i += 2;
    800006a8:	003a049b          	addiw	s1,s4,3
    800006ac:	b5d9                	j	80000572 <printf+0x78>
    800006ae:	f466                	sd	s9,40(sp)
      printptr(va_arg(ap, uint64));
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	0007ba83          	ld	s5,0(a5)
  consputc('0');
    800006c0:	03000513          	li	a0,48
    800006c4:	bb7ff0ef          	jal	8000027a <consputc>
  consputc('x');
    800006c8:	07800513          	li	a0,120
    800006cc:	bafff0ef          	jal	8000027a <consputc>
    800006d0:	4a41                	li	s4,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d2:	00007c97          	auipc	s9,0x7
    800006d6:	03ec8c93          	addi	s9,s9,62 # 80007710 <digits>
    800006da:	03cad793          	srli	a5,s5,0x3c
    800006de:	97e6                	add	a5,a5,s9
    800006e0:	0007c503          	lbu	a0,0(a5)
    800006e4:	b97ff0ef          	jal	8000027a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e8:	0a92                	slli	s5,s5,0x4
    800006ea:	3a7d                	addiw	s4,s4,-1
    800006ec:	fe0a17e3          	bnez	s4,800006da <printf+0x1e0>
    800006f0:	7ca2                	ld	s9,40(sp)
    800006f2:	b541                	j	80000572 <printf+0x78>
    } else if(c0 == 'c'){
      consputc(va_arg(ap, uint));
    800006f4:	f8843783          	ld	a5,-120(s0)
    800006f8:	00878713          	addi	a4,a5,8
    800006fc:	f8e43423          	sd	a4,-120(s0)
    80000700:	4388                	lw	a0,0(a5)
    80000702:	b79ff0ef          	jal	8000027a <consputc>
    80000706:	b5b5                	j	80000572 <printf+0x78>
    } else if(c0 == 's'){
      if((s = va_arg(ap, char*)) == 0)
    80000708:	f8843783          	ld	a5,-120(s0)
    8000070c:	00878713          	addi	a4,a5,8
    80000710:	f8e43423          	sd	a4,-120(s0)
    80000714:	0007ba03          	ld	s4,0(a5)
    80000718:	000a0d63          	beqz	s4,80000732 <printf+0x238>
        s = "(null)";
      for(; *s; s++)
    8000071c:	000a4503          	lbu	a0,0(s4)
    80000720:	e40509e3          	beqz	a0,80000572 <printf+0x78>
        consputc(*s);
    80000724:	b57ff0ef          	jal	8000027a <consputc>
      for(; *s; s++)
    80000728:	0a05                	addi	s4,s4,1
    8000072a:	000a4503          	lbu	a0,0(s4)
    8000072e:	f97d                	bnez	a0,80000724 <printf+0x22a>
    80000730:	b589                	j	80000572 <printf+0x78>
        s = "(null)";
    80000732:	00007a17          	auipc	s4,0x7
    80000736:	8d6a0a13          	addi	s4,s4,-1834 # 80007008 <etext+0x8>
      for(; *s; s++)
    8000073a:	02800513          	li	a0,40
    8000073e:	b7dd                	j	80000724 <printf+0x22a>
    } else if(c0 == '%'){
      consputc('%');
    80000740:	8556                	mv	a0,s5
    80000742:	b39ff0ef          	jal	8000027a <consputc>
    80000746:	b535                	j	80000572 <printf+0x78>
    80000748:	74a6                	ld	s1,104(sp)
    8000074a:	69e6                	ld	s3,88(sp)
    8000074c:	6a46                	ld	s4,80(sp)
    8000074e:	6aa6                	ld	s5,72(sp)
    80000750:	6b06                	ld	s6,64(sp)
    80000752:	7be2                	ld	s7,56(sp)
    80000754:	7c42                	ld	s8,48(sp)
    80000756:	7d02                	ld	s10,32(sp)
    80000758:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    8000075a:	00007797          	auipc	a5,0x7
    8000075e:	0ea7a783          	lw	a5,234(a5) # 80007844 <panicking>
    80000762:	c38d                	beqz	a5,80000784 <printf+0x28a>
    release(&pr.lock);

  return 0;
}
    80000764:	4501                	li	a0,0
    80000766:	70e6                	ld	ra,120(sp)
    80000768:	7446                	ld	s0,112(sp)
    8000076a:	7906                	ld	s2,96(sp)
    8000076c:	6129                	addi	sp,sp,192
    8000076e:	8082                	ret
    80000770:	74a6                	ld	s1,104(sp)
    80000772:	69e6                	ld	s3,88(sp)
    80000774:	6a46                	ld	s4,80(sp)
    80000776:	6aa6                	ld	s5,72(sp)
    80000778:	6b06                	ld	s6,64(sp)
    8000077a:	7be2                	ld	s7,56(sp)
    8000077c:	7c42                	ld	s8,48(sp)
    8000077e:	7d02                	ld	s10,32(sp)
    80000780:	6de2                	ld	s11,24(sp)
    80000782:	bfe1                	j	8000075a <printf+0x260>
    release(&pr.lock);
    80000784:	0000f517          	auipc	a0,0xf
    80000788:	19450513          	addi	a0,a0,404 # 8000f918 <pr>
    8000078c:	530000ef          	jal	80000cbc <release>
  return 0;
    80000790:	bfd1                	j	80000764 <printf+0x26a>
    if(c0 == 'd'){
    80000792:	e37a8ee3          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    80000796:	f94a8713          	addi	a4,s5,-108
    8000079a:	00173713          	seqz	a4,a4
    8000079e:	8636                	mv	a2,a3
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007a0:	4781                	li	a5,0
    800007a2:	a00d                	j	800007c4 <printf+0x2ca>
    } else if(c0 == 'l' && c1 == 'd'){
    800007a4:	f94a8713          	addi	a4,s5,-108
    800007a8:	00173713          	seqz	a4,a4
    c1 = c2 = 0;
    800007ac:	8656                	mv	a2,s5
    800007ae:	86d6                	mv	a3,s5
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007b0:	f9460793          	addi	a5,a2,-108
    800007b4:	0017b793          	seqz	a5,a5
    800007b8:	8ff9                	and	a5,a5,a4
    800007ba:	f9c68593          	addi	a1,a3,-100
    800007be:	e199                	bnez	a1,800007c4 <printf+0x2ca>
    800007c0:	e20798e3          	bnez	a5,800005f0 <printf+0xf6>
    } else if(c0 == 'u'){
    800007c4:	e58a84e3          	beq	s5,s8,8000060c <printf+0x112>
    } else if(c0 == 'l' && c1 == 'u'){
    800007c8:	f8b60593          	addi	a1,a2,-117
    800007cc:	e199                	bnez	a1,800007d2 <printf+0x2d8>
    800007ce:	e4071ce3          	bnez	a4,80000626 <printf+0x12c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800007d2:	f8b68593          	addi	a1,a3,-117
    800007d6:	e199                	bnez	a1,800007dc <printf+0x2e2>
    800007d8:	e60795e3          	bnez	a5,80000642 <printf+0x148>
    } else if(c0 == 'x'){
    800007dc:	e9aa81e3          	beq	s5,s10,8000065e <printf+0x164>
    } else if(c0 == 'l' && c1 == 'x'){
    800007e0:	f8860613          	addi	a2,a2,-120
    800007e4:	e219                	bnez	a2,800007ea <printf+0x2f0>
    800007e6:	e80719e3          	bnez	a4,80000678 <printf+0x17e>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800007ea:	f8868693          	addi	a3,a3,-120
    800007ee:	e299                	bnez	a3,800007f4 <printf+0x2fa>
    800007f0:	ea0791e3          	bnez	a5,80000692 <printf+0x198>
    } else if(c0 == 'p'){
    800007f4:	ebba8de3          	beq	s5,s11,800006ae <printf+0x1b4>
    } else if(c0 == 'c'){
    800007f8:	06300793          	li	a5,99
    800007fc:	eefa8ce3          	beq	s5,a5,800006f4 <printf+0x1fa>
    } else if(c0 == 's'){
    80000800:	07300793          	li	a5,115
    80000804:	f0fa82e3          	beq	s5,a5,80000708 <printf+0x20e>
    } else if(c0 == '%'){
    80000808:	02500793          	li	a5,37
    8000080c:	f2fa8ae3          	beq	s5,a5,80000740 <printf+0x246>
    } else if(c0 == 0){
    80000810:	f60a80e3          	beqz	s5,80000770 <printf+0x276>
      consputc('%');
    80000814:	02500513          	li	a0,37
    80000818:	a63ff0ef          	jal	8000027a <consputc>
      consputc(c0);
    8000081c:	8556                	mv	a0,s5
    8000081e:	a5dff0ef          	jal	8000027a <consputc>
    80000822:	bb81                	j	80000572 <printf+0x78>

0000000080000824 <panic>:

void
panic(char *s)
{
    80000824:	1101                	addi	sp,sp,-32
    80000826:	ec06                	sd	ra,24(sp)
    80000828:	e822                	sd	s0,16(sp)
    8000082a:	e426                	sd	s1,8(sp)
    8000082c:	e04a                	sd	s2,0(sp)
    8000082e:	1000                	addi	s0,sp,32
    80000830:	892a                	mv	s2,a0
  panicking = 1;
    80000832:	4485                	li	s1,1
    80000834:	00007797          	auipc	a5,0x7
    80000838:	0097a823          	sw	s1,16(a5) # 80007844 <panicking>
  printf("panic: ");
    8000083c:	00006517          	auipc	a0,0x6
    80000840:	7dc50513          	addi	a0,a0,2012 # 80007018 <etext+0x18>
    80000844:	cb7ff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000848:	85ca                	mv	a1,s2
    8000084a:	00006517          	auipc	a0,0x6
    8000084e:	7d650513          	addi	a0,a0,2006 # 80007020 <etext+0x20>
    80000852:	ca9ff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000856:	00007797          	auipc	a5,0x7
    8000085a:	fe97a523          	sw	s1,-22(a5) # 80007840 <panicked>
  for(;;)
    8000085e:	a001                	j	8000085e <panic+0x3a>

0000000080000860 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000860:	1141                	addi	sp,sp,-16
    80000862:	e406                	sd	ra,8(sp)
    80000864:	e022                	sd	s0,0(sp)
    80000866:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000868:	00006597          	auipc	a1,0x6
    8000086c:	7c058593          	addi	a1,a1,1984 # 80007028 <etext+0x28>
    80000870:	0000f517          	auipc	a0,0xf
    80000874:	0a850513          	addi	a0,a0,168 # 8000f918 <pr>
    80000878:	326000ef          	jal	80000b9e <initlock>
}
    8000087c:	60a2                	ld	ra,8(sp)
    8000087e:	6402                	ld	s0,0(sp)
    80000880:	0141                	addi	sp,sp,16
    80000882:	8082                	ret

0000000080000884 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000884:	1141                	addi	sp,sp,-16
    80000886:	e406                	sd	ra,8(sp)
    80000888:	e022                	sd	s0,0(sp)
    8000088a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000088c:	100007b7          	lui	a5,0x10000
    80000890:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000894:	10000737          	lui	a4,0x10000
    80000898:	f8000693          	li	a3,-128
    8000089c:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008a0:	468d                	li	a3,3
    800008a2:	10000637          	lui	a2,0x10000
    800008a6:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008aa:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800008ae:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008b2:	8732                	mv	a4,a2
    800008b4:	461d                	li	a2,7
    800008b6:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008ba:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    800008be:	00006597          	auipc	a1,0x6
    800008c2:	77258593          	addi	a1,a1,1906 # 80007030 <etext+0x30>
    800008c6:	0000f517          	auipc	a0,0xf
    800008ca:	06a50513          	addi	a0,a0,106 # 8000f930 <tx_lock>
    800008ce:	2d0000ef          	jal	80000b9e <initlock>
}
    800008d2:	60a2                	ld	ra,8(sp)
    800008d4:	6402                	ld	s0,0(sp)
    800008d6:	0141                	addi	sp,sp,16
    800008d8:	8082                	ret

00000000800008da <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008da:	715d                	addi	sp,sp,-80
    800008dc:	e486                	sd	ra,72(sp)
    800008de:	e0a2                	sd	s0,64(sp)
    800008e0:	fc26                	sd	s1,56(sp)
    800008e2:	ec56                	sd	s5,24(sp)
    800008e4:	0880                	addi	s0,sp,80
    800008e6:	8aaa                	mv	s5,a0
    800008e8:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008ea:	0000f517          	auipc	a0,0xf
    800008ee:	04650513          	addi	a0,a0,70 # 8000f930 <tx_lock>
    800008f2:	336000ef          	jal	80000c28 <acquire>

  int i = 0;
  while(i < n){ 
    800008f6:	06905063          	blez	s1,80000956 <uartwrite+0x7c>
    800008fa:	f84a                	sd	s2,48(sp)
    800008fc:	f44e                	sd	s3,40(sp)
    800008fe:	f052                	sd	s4,32(sp)
    80000900:	e85a                	sd	s6,16(sp)
    80000902:	e45e                	sd	s7,8(sp)
    80000904:	8a56                	mv	s4,s5
    80000906:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    80000908:	00007497          	auipc	s1,0x7
    8000090c:	f4448493          	addi	s1,s1,-188 # 8000784c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000910:	0000f997          	auipc	s3,0xf
    80000914:	02098993          	addi	s3,s3,32 # 8000f930 <tx_lock>
    80000918:	00007917          	auipc	s2,0x7
    8000091c:	f3090913          	addi	s2,s2,-208 # 80007848 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000920:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80000924:	4b05                	li	s6,1
    80000926:	a005                	j	80000946 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    80000928:	85ce                	mv	a1,s3
    8000092a:	854a                	mv	a0,s2
    8000092c:	612010ef          	jal	80001f3e <sleep>
    while(tx_busy != 0){
    80000930:	409c                	lw	a5,0(s1)
    80000932:	fbfd                	bnez	a5,80000928 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80000934:	000a4783          	lbu	a5,0(s4)
    80000938:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    8000093c:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    80000940:	0a05                	addi	s4,s4,1
    80000942:	015a0563          	beq	s4,s5,8000094c <uartwrite+0x72>
    while(tx_busy != 0){
    80000946:	409c                	lw	a5,0(s1)
    80000948:	f3e5                	bnez	a5,80000928 <uartwrite+0x4e>
    8000094a:	b7ed                	j	80000934 <uartwrite+0x5a>
    8000094c:	7942                	ld	s2,48(sp)
    8000094e:	79a2                	ld	s3,40(sp)
    80000950:	7a02                	ld	s4,32(sp)
    80000952:	6b42                	ld	s6,16(sp)
    80000954:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000956:	0000f517          	auipc	a0,0xf
    8000095a:	fda50513          	addi	a0,a0,-38 # 8000f930 <tx_lock>
    8000095e:	35e000ef          	jal	80000cbc <release>
}
    80000962:	60a6                	ld	ra,72(sp)
    80000964:	6406                	ld	s0,64(sp)
    80000966:	74e2                	ld	s1,56(sp)
    80000968:	6ae2                	ld	s5,24(sp)
    8000096a:	6161                	addi	sp,sp,80
    8000096c:	8082                	ret

000000008000096e <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000096e:	1101                	addi	sp,sp,-32
    80000970:	ec06                	sd	ra,24(sp)
    80000972:	e822                	sd	s0,16(sp)
    80000974:	e426                	sd	s1,8(sp)
    80000976:	1000                	addi	s0,sp,32
    80000978:	84aa                	mv	s1,a0
  if(panicking == 0)
    8000097a:	00007797          	auipc	a5,0x7
    8000097e:	eca7a783          	lw	a5,-310(a5) # 80007844 <panicking>
    80000982:	cf95                	beqz	a5,800009be <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000984:	00007797          	auipc	a5,0x7
    80000988:	ebc7a783          	lw	a5,-324(a5) # 80007840 <panicked>
    8000098c:	ef85                	bnez	a5,800009c4 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000098e:	10000737          	lui	a4,0x10000
    80000992:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000994:	00074783          	lbu	a5,0(a4)
    80000998:	0207f793          	andi	a5,a5,32
    8000099c:	dfe5                	beqz	a5,80000994 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000099e:	0ff4f513          	zext.b	a0,s1
    800009a2:	100007b7          	lui	a5,0x10000
    800009a6:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    800009aa:	00007797          	auipc	a5,0x7
    800009ae:	e9a7a783          	lw	a5,-358(a5) # 80007844 <panicking>
    800009b2:	cb91                	beqz	a5,800009c6 <uartputc_sync+0x58>
    pop_off();
}
    800009b4:	60e2                	ld	ra,24(sp)
    800009b6:	6442                	ld	s0,16(sp)
    800009b8:	64a2                	ld	s1,8(sp)
    800009ba:	6105                	addi	sp,sp,32
    800009bc:	8082                	ret
    push_off();
    800009be:	226000ef          	jal	80000be4 <push_off>
    800009c2:	b7c9                	j	80000984 <uartputc_sync+0x16>
    for(;;)
    800009c4:	a001                	j	800009c4 <uartputc_sync+0x56>
    pop_off();
    800009c6:	2a6000ef          	jal	80000c6c <pop_off>
}
    800009ca:	b7ed                	j	800009b4 <uartputc_sync+0x46>

00000000800009cc <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009cc:	1141                	addi	sp,sp,-16
    800009ce:	e406                	sd	ra,8(sp)
    800009d0:	e022                	sd	s0,0(sp)
    800009d2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    800009d4:	100007b7          	lui	a5,0x10000
    800009d8:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009dc:	8b85                	andi	a5,a5,1
    800009de:	cb89                	beqz	a5,800009f0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009e0:	100007b7          	lui	a5,0x10000
    800009e4:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009e8:	60a2                	ld	ra,8(sp)
    800009ea:	6402                	ld	s0,0(sp)
    800009ec:	0141                	addi	sp,sp,16
    800009ee:	8082                	ret
    return -1;
    800009f0:	557d                	li	a0,-1
    800009f2:	bfdd                	j	800009e8 <uartgetc+0x1c>

00000000800009f4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009f4:	1101                	addi	sp,sp,-32
    800009f6:	ec06                	sd	ra,24(sp)
    800009f8:	e822                	sd	s0,16(sp)
    800009fa:	e426                	sd	s1,8(sp)
    800009fc:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009fe:	100007b7          	lui	a5,0x10000
    80000a02:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    80000a06:	0000f517          	auipc	a0,0xf
    80000a0a:	f2a50513          	addi	a0,a0,-214 # 8000f930 <tx_lock>
    80000a0e:	21a000ef          	jal	80000c28 <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000a12:	100007b7          	lui	a5,0x10000
    80000a16:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a1a:	0207f793          	andi	a5,a5,32
    80000a1e:	ef99                	bnez	a5,80000a3c <uartintr+0x48>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000a20:	0000f517          	auipc	a0,0xf
    80000a24:	f1050513          	addi	a0,a0,-240 # 8000f930 <tx_lock>
    80000a28:	294000ef          	jal	80000cbc <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a2c:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a2e:	f9fff0ef          	jal	800009cc <uartgetc>
    if(c == -1)
    80000a32:	02950063          	beq	a0,s1,80000a52 <uartintr+0x5e>
      break;
    consoleintr(c);
    80000a36:	877ff0ef          	jal	800002ac <consoleintr>
  while(1){
    80000a3a:	bfd5                	j	80000a2e <uartintr+0x3a>
    tx_busy = 0;
    80000a3c:	00007797          	auipc	a5,0x7
    80000a40:	e007a823          	sw	zero,-496(a5) # 8000784c <tx_busy>
    wakeup(&tx_chan);
    80000a44:	00007517          	auipc	a0,0x7
    80000a48:	e0450513          	addi	a0,a0,-508 # 80007848 <tx_chan>
    80000a4c:	53e010ef          	jal	80001f8a <wakeup>
    80000a50:	bfc1                	j	80000a20 <uartintr+0x2c>
  }
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret

0000000080000a5c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a5c:	1101                	addi	sp,sp,-32
    80000a5e:	ec06                	sd	ra,24(sp)
    80000a60:	e822                	sd	s0,16(sp)
    80000a62:	e426                	sd	s1,8(sp)
    80000a64:	e04a                	sd	s2,0(sp)
    80000a66:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a68:	00020797          	auipc	a5,0x20
    80000a6c:	31078793          	addi	a5,a5,784 # 80020d78 <end>
    80000a70:	00f53733          	sltu	a4,a0,a5
    80000a74:	47c5                	li	a5,17
    80000a76:	07ee                	slli	a5,a5,0x1b
    80000a78:	17fd                	addi	a5,a5,-1
    80000a7a:	00a7b7b3          	sltu	a5,a5,a0
    80000a7e:	8fd9                	or	a5,a5,a4
    80000a80:	ef95                	bnez	a5,80000abc <kfree+0x60>
    80000a82:	84aa                	mv	s1,a0
    80000a84:	03451793          	slli	a5,a0,0x34
    80000a88:	eb95                	bnez	a5,80000abc <kfree+0x60>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a8a:	6605                	lui	a2,0x1
    80000a8c:	4585                	li	a1,1
    80000a8e:	26a000ef          	jal	80000cf8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a92:	0000f917          	auipc	s2,0xf
    80000a96:	eb690913          	addi	s2,s2,-330 # 8000f948 <kmem>
    80000a9a:	854a                	mv	a0,s2
    80000a9c:	18c000ef          	jal	80000c28 <acquire>
  r->next = kmem.freelist;
    80000aa0:	01893783          	ld	a5,24(s2)
    80000aa4:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aa6:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000aaa:	854a                	mv	a0,s2
    80000aac:	210000ef          	jal	80000cbc <release>
}
    80000ab0:	60e2                	ld	ra,24(sp)
    80000ab2:	6442                	ld	s0,16(sp)
    80000ab4:	64a2                	ld	s1,8(sp)
    80000ab6:	6902                	ld	s2,0(sp)
    80000ab8:	6105                	addi	sp,sp,32
    80000aba:	8082                	ret
    panic("kfree");
    80000abc:	00006517          	auipc	a0,0x6
    80000ac0:	57c50513          	addi	a0,a0,1404 # 80007038 <etext+0x38>
    80000ac4:	d61ff0ef          	jal	80000824 <panic>

0000000080000ac8 <freerange>:
{
    80000ac8:	7179                	addi	sp,sp,-48
    80000aca:	f406                	sd	ra,40(sp)
    80000acc:	f022                	sd	s0,32(sp)
    80000ace:	ec26                	sd	s1,24(sp)
    80000ad0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ad2:	6785                	lui	a5,0x1
    80000ad4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad8:	00e504b3          	add	s1,a0,a4
    80000adc:	777d                	lui	a4,0xfffff
    80000ade:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae0:	94be                	add	s1,s1,a5
    80000ae2:	0295e263          	bltu	a1,s1,80000b06 <freerange+0x3e>
    80000ae6:	e84a                	sd	s2,16(sp)
    80000ae8:	e44e                	sd	s3,8(sp)
    80000aea:	e052                	sd	s4,0(sp)
    80000aec:	892e                	mv	s2,a1
    kfree(p);
    80000aee:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af0:	89be                	mv	s3,a5
    kfree(p);
    80000af2:	01448533          	add	a0,s1,s4
    80000af6:	f67ff0ef          	jal	80000a5c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000afa:	94ce                	add	s1,s1,s3
    80000afc:	fe997be3          	bgeu	s2,s1,80000af2 <freerange+0x2a>
    80000b00:	6942                	ld	s2,16(sp)
    80000b02:	69a2                	ld	s3,8(sp)
    80000b04:	6a02                	ld	s4,0(sp)
}
    80000b06:	70a2                	ld	ra,40(sp)
    80000b08:	7402                	ld	s0,32(sp)
    80000b0a:	64e2                	ld	s1,24(sp)
    80000b0c:	6145                	addi	sp,sp,48
    80000b0e:	8082                	ret

0000000080000b10 <kinit>:
{
    80000b10:	1141                	addi	sp,sp,-16
    80000b12:	e406                	sd	ra,8(sp)
    80000b14:	e022                	sd	s0,0(sp)
    80000b16:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b18:	00006597          	auipc	a1,0x6
    80000b1c:	52858593          	addi	a1,a1,1320 # 80007040 <etext+0x40>
    80000b20:	0000f517          	auipc	a0,0xf
    80000b24:	e2850513          	addi	a0,a0,-472 # 8000f948 <kmem>
    80000b28:	076000ef          	jal	80000b9e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00020517          	auipc	a0,0x20
    80000b34:	24850513          	addi	a0,a0,584 # 80020d78 <end>
    80000b38:	f91ff0ef          	jal	80000ac8 <freerange>
}
    80000b3c:	60a2                	ld	ra,8(sp)
    80000b3e:	6402                	ld	s0,0(sp)
    80000b40:	0141                	addi	sp,sp,16
    80000b42:	8082                	ret

0000000080000b44 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b44:	1101                	addi	sp,sp,-32
    80000b46:	ec06                	sd	ra,24(sp)
    80000b48:	e822                	sd	s0,16(sp)
    80000b4a:	e426                	sd	s1,8(sp)
    80000b4c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b4e:	0000f517          	auipc	a0,0xf
    80000b52:	dfa50513          	addi	a0,a0,-518 # 8000f948 <kmem>
    80000b56:	0d2000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b5a:	0000f497          	auipc	s1,0xf
    80000b5e:	e064b483          	ld	s1,-506(s1) # 8000f960 <kmem+0x18>
  if(r)
    80000b62:	c49d                	beqz	s1,80000b90 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b64:	609c                	ld	a5,0(s1)
    80000b66:	0000f717          	auipc	a4,0xf
    80000b6a:	def73d23          	sd	a5,-518(a4) # 8000f960 <kmem+0x18>
  release(&kmem.lock);
    80000b6e:	0000f517          	auipc	a0,0xf
    80000b72:	dda50513          	addi	a0,a0,-550 # 8000f948 <kmem>
    80000b76:	146000ef          	jal	80000cbc <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7a:	6605                	lui	a2,0x1
    80000b7c:	4595                	li	a1,5
    80000b7e:	8526                	mv	a0,s1
    80000b80:	178000ef          	jal	80000cf8 <memset>
  return (void*)r;
}
    80000b84:	8526                	mv	a0,s1
    80000b86:	60e2                	ld	ra,24(sp)
    80000b88:	6442                	ld	s0,16(sp)
    80000b8a:	64a2                	ld	s1,8(sp)
    80000b8c:	6105                	addi	sp,sp,32
    80000b8e:	8082                	ret
  release(&kmem.lock);
    80000b90:	0000f517          	auipc	a0,0xf
    80000b94:	db850513          	addi	a0,a0,-584 # 8000f948 <kmem>
    80000b98:	124000ef          	jal	80000cbc <release>
  if(r)
    80000b9c:	b7e5                	j	80000b84 <kalloc+0x40>

0000000080000b9e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b9e:	1141                	addi	sp,sp,-16
    80000ba0:	e406                	sd	ra,8(sp)
    80000ba2:	e022                	sd	s0,0(sp)
    80000ba4:	0800                	addi	s0,sp,16
  lk->name = name;
    80000ba6:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000ba8:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bac:	00053823          	sd	zero,16(a0)
}
    80000bb0:	60a2                	ld	ra,8(sp)
    80000bb2:	6402                	ld	s0,0(sp)
    80000bb4:	0141                	addi	sp,sp,16
    80000bb6:	8082                	ret

0000000080000bb8 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bb8:	411c                	lw	a5,0(a0)
    80000bba:	e399                	bnez	a5,80000bc0 <holding+0x8>
    80000bbc:	4501                	li	a0,0
  return r;
}
    80000bbe:	8082                	ret
{
    80000bc0:	1101                	addi	sp,sp,-32
    80000bc2:	ec06                	sd	ra,24(sp)
    80000bc4:	e822                	sd	s0,16(sp)
    80000bc6:	e426                	sd	s1,8(sp)
    80000bc8:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bca:	691c                	ld	a5,16(a0)
    80000bcc:	84be                	mv	s1,a5
    80000bce:	541000ef          	jal	8000190e <mycpu>
    80000bd2:	40a48533          	sub	a0,s1,a0
    80000bd6:	00153513          	seqz	a0,a0
}
    80000bda:	60e2                	ld	ra,24(sp)
    80000bdc:	6442                	ld	s0,16(sp)
    80000bde:	64a2                	ld	s1,8(sp)
    80000be0:	6105                	addi	sp,sp,32
    80000be2:	8082                	ret

0000000080000be4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000be4:	1101                	addi	sp,sp,-32
    80000be6:	ec06                	sd	ra,24(sp)
    80000be8:	e822                	sd	s0,16(sp)
    80000bea:	e426                	sd	s1,8(sp)
    80000bec:	1000                	addi	s0,sp,32

static inline uint64
r_sstatus()
{
  uint64 x;
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bee:	100027f3          	csrr	a5,sstatus
    80000bf2:	84be                	mv	s1,a5
    80000bf4:	100027f3          	csrr	a5,sstatus

// disable device interrupts
static inline void
intr_off()
{
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bf8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bfa:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000bfe:	511000ef          	jal	8000190e <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	509000ef          	jal	8000190e <mycpu>
    80000c0a:	5d3c                	lw	a5,120(a0)
    80000c0c:	2785                	addiw	a5,a5,1
    80000c0e:	dd3c                	sw	a5,120(a0)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    mycpu()->intena = old;
    80000c1a:	4f5000ef          	jal	8000190e <mycpu>
// are device interrupts enabled?
static inline int
intr_get()
{
  uint64 x = r_sstatus();
  return (x & SSTATUS_SIE) != 0;
    80000c1e:	0014d793          	srli	a5,s1,0x1
    80000c22:	8b85                	andi	a5,a5,1
    80000c24:	dd7c                	sw	a5,124(a0)
    80000c26:	b7c5                	j	80000c06 <push_off+0x22>

0000000080000c28 <acquire>:
{
    80000c28:	1101                	addi	sp,sp,-32
    80000c2a:	ec06                	sd	ra,24(sp)
    80000c2c:	e822                	sd	s0,16(sp)
    80000c2e:	e426                	sd	s1,8(sp)
    80000c30:	1000                	addi	s0,sp,32
    80000c32:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c34:	fb1ff0ef          	jal	80000be4 <push_off>
  if(holding(lk))
    80000c38:	8526                	mv	a0,s1
    80000c3a:	f7fff0ef          	jal	80000bb8 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c3e:	4705                	li	a4,1
  if(holding(lk))
    80000c40:	e105                	bnez	a0,80000c60 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c42:	87ba                	mv	a5,a4
    80000c44:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c48:	2781                	sext.w	a5,a5
    80000c4a:	ffe5                	bnez	a5,80000c42 <acquire+0x1a>
  __sync_synchronize();
    80000c4c:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c50:	4bf000ef          	jal	8000190e <mycpu>
    80000c54:	e888                	sd	a0,16(s1)
}
    80000c56:	60e2                	ld	ra,24(sp)
    80000c58:	6442                	ld	s0,16(sp)
    80000c5a:	64a2                	ld	s1,8(sp)
    80000c5c:	6105                	addi	sp,sp,32
    80000c5e:	8082                	ret
    panic("acquire");
    80000c60:	00006517          	auipc	a0,0x6
    80000c64:	3e850513          	addi	a0,a0,1000 # 80007048 <etext+0x48>
    80000c68:	bbdff0ef          	jal	80000824 <panic>

0000000080000c6c <pop_off>:

void
pop_off(void)
{
    80000c6c:	1141                	addi	sp,sp,-16
    80000c6e:	e406                	sd	ra,8(sp)
    80000c70:	e022                	sd	s0,0(sp)
    80000c72:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c74:	49b000ef          	jal	8000190e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c78:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c7c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c7e:	e39d                	bnez	a5,80000ca4 <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c80:	5d3c                	lw	a5,120(a0)
    80000c82:	02f05763          	blez	a5,80000cb0 <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000c86:	37fd                	addiw	a5,a5,-1
    80000c88:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c8a:	eb89                	bnez	a5,80000c9c <pop_off+0x30>
    80000c8c:	5d7c                	lw	a5,124(a0)
    80000c8e:	c799                	beqz	a5,80000c9c <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c90:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c94:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c98:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c9c:	60a2                	ld	ra,8(sp)
    80000c9e:	6402                	ld	s0,0(sp)
    80000ca0:	0141                	addi	sp,sp,16
    80000ca2:	8082                	ret
    panic("pop_off - interruptible");
    80000ca4:	00006517          	auipc	a0,0x6
    80000ca8:	3ac50513          	addi	a0,a0,940 # 80007050 <etext+0x50>
    80000cac:	b79ff0ef          	jal	80000824 <panic>
    panic("pop_off");
    80000cb0:	00006517          	auipc	a0,0x6
    80000cb4:	3b850513          	addi	a0,a0,952 # 80007068 <etext+0x68>
    80000cb8:	b6dff0ef          	jal	80000824 <panic>

0000000080000cbc <release>:
{
    80000cbc:	1101                	addi	sp,sp,-32
    80000cbe:	ec06                	sd	ra,24(sp)
    80000cc0:	e822                	sd	s0,16(sp)
    80000cc2:	e426                	sd	s1,8(sp)
    80000cc4:	1000                	addi	s0,sp,32
    80000cc6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cc8:	ef1ff0ef          	jal	80000bb8 <holding>
    80000ccc:	c105                	beqz	a0,80000cec <release+0x30>
  lk->cpu = 0;
    80000cce:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cd2:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000cd6:	0310000f          	fence	rw,w
    80000cda:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cde:	f8fff0ef          	jal	80000c6c <pop_off>
}
    80000ce2:	60e2                	ld	ra,24(sp)
    80000ce4:	6442                	ld	s0,16(sp)
    80000ce6:	64a2                	ld	s1,8(sp)
    80000ce8:	6105                	addi	sp,sp,32
    80000cea:	8082                	ret
    panic("release");
    80000cec:	00006517          	auipc	a0,0x6
    80000cf0:	38450513          	addi	a0,a0,900 # 80007070 <etext+0x70>
    80000cf4:	b31ff0ef          	jal	80000824 <panic>

0000000080000cf8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cf8:	1141                	addi	sp,sp,-16
    80000cfa:	e406                	sd	ra,8(sp)
    80000cfc:	e022                	sd	s0,0(sp)
    80000cfe:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d00:	ca19                	beqz	a2,80000d16 <memset+0x1e>
    80000d02:	87aa                	mv	a5,a0
    80000d04:	1602                	slli	a2,a2,0x20
    80000d06:	9201                	srli	a2,a2,0x20
    80000d08:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d0c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d10:	0785                	addi	a5,a5,1
    80000d12:	fee79de3          	bne	a5,a4,80000d0c <memset+0x14>
  }
  return dst;
}
    80000d16:	60a2                	ld	ra,8(sp)
    80000d18:	6402                	ld	s0,0(sp)
    80000d1a:	0141                	addi	sp,sp,16
    80000d1c:	8082                	ret

0000000080000d1e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d1e:	1141                	addi	sp,sp,-16
    80000d20:	e406                	sd	ra,8(sp)
    80000d22:	e022                	sd	s0,0(sp)
    80000d24:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d26:	c61d                	beqz	a2,80000d54 <memcmp+0x36>
    80000d28:	1602                	slli	a2,a2,0x20
    80000d2a:	9201                	srli	a2,a2,0x20
    80000d2c:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000d30:	00054783          	lbu	a5,0(a0)
    80000d34:	0005c703          	lbu	a4,0(a1)
    80000d38:	00e79863          	bne	a5,a4,80000d48 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d3c:	0505                	addi	a0,a0,1
    80000d3e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d40:	fed518e3          	bne	a0,a3,80000d30 <memcmp+0x12>
  }

  return 0;
    80000d44:	4501                	li	a0,0
    80000d46:	a019                	j	80000d4c <memcmp+0x2e>
      return *s1 - *s2;
    80000d48:	40e7853b          	subw	a0,a5,a4
}
    80000d4c:	60a2                	ld	ra,8(sp)
    80000d4e:	6402                	ld	s0,0(sp)
    80000d50:	0141                	addi	sp,sp,16
    80000d52:	8082                	ret
  return 0;
    80000d54:	4501                	li	a0,0
    80000d56:	bfdd                	j	80000d4c <memcmp+0x2e>

0000000080000d58 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d58:	1141                	addi	sp,sp,-16
    80000d5a:	e406                	sd	ra,8(sp)
    80000d5c:	e022                	sd	s0,0(sp)
    80000d5e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d60:	c205                	beqz	a2,80000d80 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d62:	02a5e363          	bltu	a1,a0,80000d88 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d66:	1602                	slli	a2,a2,0x20
    80000d68:	9201                	srli	a2,a2,0x20
    80000d6a:	00c587b3          	add	a5,a1,a2
{
    80000d6e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d70:	0585                	addi	a1,a1,1
    80000d72:	0705                	addi	a4,a4,1
    80000d74:	fff5c683          	lbu	a3,-1(a1)
    80000d78:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d7c:	feb79ae3          	bne	a5,a1,80000d70 <memmove+0x18>

  return dst;
}
    80000d80:	60a2                	ld	ra,8(sp)
    80000d82:	6402                	ld	s0,0(sp)
    80000d84:	0141                	addi	sp,sp,16
    80000d86:	8082                	ret
  if(s < d && s + n > d){
    80000d88:	02061693          	slli	a3,a2,0x20
    80000d8c:	9281                	srli	a3,a3,0x20
    80000d8e:	00d58733          	add	a4,a1,a3
    80000d92:	fce57ae3          	bgeu	a0,a4,80000d66 <memmove+0xe>
    d += n;
    80000d96:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d98:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000d9c:	1782                	slli	a5,a5,0x20
    80000d9e:	9381                	srli	a5,a5,0x20
    80000da0:	fff7c793          	not	a5,a5
    80000da4:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000da6:	177d                	addi	a4,a4,-1
    80000da8:	16fd                	addi	a3,a3,-1
    80000daa:	00074603          	lbu	a2,0(a4)
    80000dae:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000db2:	fee79ae3          	bne	a5,a4,80000da6 <memmove+0x4e>
    80000db6:	b7e9                	j	80000d80 <memmove+0x28>

0000000080000db8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e406                	sd	ra,8(sp)
    80000dbc:	e022                	sd	s0,0(sp)
    80000dbe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dc0:	f99ff0ef          	jal	80000d58 <memmove>
}
    80000dc4:	60a2                	ld	ra,8(sp)
    80000dc6:	6402                	ld	s0,0(sp)
    80000dc8:	0141                	addi	sp,sp,16
    80000dca:	8082                	ret

0000000080000dcc <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dcc:	1141                	addi	sp,sp,-16
    80000dce:	e406                	sd	ra,8(sp)
    80000dd0:	e022                	sd	s0,0(sp)
    80000dd2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dd4:	ce11                	beqz	a2,80000df0 <strncmp+0x24>
    80000dd6:	00054783          	lbu	a5,0(a0)
    80000dda:	cf89                	beqz	a5,80000df4 <strncmp+0x28>
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	00f71a63          	bne	a4,a5,80000df4 <strncmp+0x28>
    n--, p++, q++;
    80000de4:	367d                	addiw	a2,a2,-1
    80000de6:	0505                	addi	a0,a0,1
    80000de8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dea:	f675                	bnez	a2,80000dd6 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000dec:	4501                	li	a0,0
    80000dee:	a801                	j	80000dfe <strncmp+0x32>
    80000df0:	4501                	li	a0,0
    80000df2:	a031                	j	80000dfe <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000df4:	00054503          	lbu	a0,0(a0)
    80000df8:	0005c783          	lbu	a5,0(a1)
    80000dfc:	9d1d                	subw	a0,a0,a5
}
    80000dfe:	60a2                	ld	ra,8(sp)
    80000e00:	6402                	ld	s0,0(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e406                	sd	ra,8(sp)
    80000e0a:	e022                	sd	s0,0(sp)
    80000e0c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e0e:	87aa                	mv	a5,a0
    80000e10:	a011                	j	80000e14 <strncpy+0xe>
    80000e12:	8636                	mv	a2,a3
    80000e14:	02c05863          	blez	a2,80000e44 <strncpy+0x3e>
    80000e18:	fff6069b          	addiw	a3,a2,-1
    80000e1c:	8836                	mv	a6,a3
    80000e1e:	0785                	addi	a5,a5,1
    80000e20:	0005c703          	lbu	a4,0(a1)
    80000e24:	fee78fa3          	sb	a4,-1(a5)
    80000e28:	0585                	addi	a1,a1,1
    80000e2a:	f765                	bnez	a4,80000e12 <strncpy+0xc>
    ;
  while(n-- > 0)
    80000e2c:	873e                	mv	a4,a5
    80000e2e:	01005b63          	blez	a6,80000e44 <strncpy+0x3e>
    80000e32:	9fb1                	addw	a5,a5,a2
    80000e34:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e36:	0705                	addi	a4,a4,1
    80000e38:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e3c:	40e786bb          	subw	a3,a5,a4
    80000e40:	fed04be3          	bgtz	a3,80000e36 <strncpy+0x30>
  return os;
}
    80000e44:	60a2                	ld	ra,8(sp)
    80000e46:	6402                	ld	s0,0(sp)
    80000e48:	0141                	addi	sp,sp,16
    80000e4a:	8082                	ret

0000000080000e4c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e4c:	1141                	addi	sp,sp,-16
    80000e4e:	e406                	sd	ra,8(sp)
    80000e50:	e022                	sd	s0,0(sp)
    80000e52:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e54:	02c05363          	blez	a2,80000e7a <safestrcpy+0x2e>
    80000e58:	fff6069b          	addiw	a3,a2,-1
    80000e5c:	1682                	slli	a3,a3,0x20
    80000e5e:	9281                	srli	a3,a3,0x20
    80000e60:	96ae                	add	a3,a3,a1
    80000e62:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e64:	00d58963          	beq	a1,a3,80000e76 <safestrcpy+0x2a>
    80000e68:	0585                	addi	a1,a1,1
    80000e6a:	0785                	addi	a5,a5,1
    80000e6c:	fff5c703          	lbu	a4,-1(a1)
    80000e70:	fee78fa3          	sb	a4,-1(a5)
    80000e74:	fb65                	bnez	a4,80000e64 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e76:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e7a:	60a2                	ld	ra,8(sp)
    80000e7c:	6402                	ld	s0,0(sp)
    80000e7e:	0141                	addi	sp,sp,16
    80000e80:	8082                	ret

0000000080000e82 <strlen>:

int
strlen(const char *s)
{
    80000e82:	1141                	addi	sp,sp,-16
    80000e84:	e406                	sd	ra,8(sp)
    80000e86:	e022                	sd	s0,0(sp)
    80000e88:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e8a:	00054783          	lbu	a5,0(a0)
    80000e8e:	cf91                	beqz	a5,80000eaa <strlen+0x28>
    80000e90:	00150793          	addi	a5,a0,1
    80000e94:	86be                	mv	a3,a5
    80000e96:	0785                	addi	a5,a5,1
    80000e98:	fff7c703          	lbu	a4,-1(a5)
    80000e9c:	ff65                	bnez	a4,80000e94 <strlen+0x12>
    80000e9e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000ea2:	60a2                	ld	ra,8(sp)
    80000ea4:	6402                	ld	s0,0(sp)
    80000ea6:	0141                	addi	sp,sp,16
    80000ea8:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eaa:	4501                	li	a0,0
    80000eac:	bfdd                	j	80000ea2 <strlen+0x20>

0000000080000eae <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000eae:	1141                	addi	sp,sp,-16
    80000eb0:	e406                	sd	ra,8(sp)
    80000eb2:	e022                	sd	s0,0(sp)
    80000eb4:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000eb6:	245000ef          	jal	800018fa <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eba:	00007717          	auipc	a4,0x7
    80000ebe:	99670713          	addi	a4,a4,-1642 # 80007850 <started>
  if(cpuid() == 0){
    80000ec2:	c51d                	beqz	a0,80000ef0 <main+0x42>
    while(started == 0)
    80000ec4:	431c                	lw	a5,0(a4)
    80000ec6:	2781                	sext.w	a5,a5
    80000ec8:	dff5                	beqz	a5,80000ec4 <main+0x16>
      ;
    __sync_synchronize();
    80000eca:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000ece:	22d000ef          	jal	800018fa <cpuid>
    80000ed2:	85aa                	mv	a1,a0
    80000ed4:	00006517          	auipc	a0,0x6
    80000ed8:	1c450513          	addi	a0,a0,452 # 80007098 <etext+0x98>
    80000edc:	e1eff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000ee0:	080000ef          	jal	80000f60 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee4:	57a010ef          	jal	8000245e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee8:	610040ef          	jal	800054f8 <plicinithart>
  }

  scheduler();        
    80000eec:	6b9000ef          	jal	80001da4 <scheduler>
    consoleinit();
    80000ef0:	d30ff0ef          	jal	80000420 <consoleinit>
    printfinit();
    80000ef4:	96dff0ef          	jal	80000860 <printfinit>
    printf("\n");
    80000ef8:	00006517          	auipc	a0,0x6
    80000efc:	18050513          	addi	a0,a0,384 # 80007078 <etext+0x78>
    80000f00:	dfaff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000f04:	00006517          	auipc	a0,0x6
    80000f08:	17c50513          	addi	a0,a0,380 # 80007080 <etext+0x80>
    80000f0c:	deeff0ef          	jal	800004fa <printf>
    printf("\n");
    80000f10:	00006517          	auipc	a0,0x6
    80000f14:	16850513          	addi	a0,a0,360 # 80007078 <etext+0x78>
    80000f18:	de2ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000f1c:	bf5ff0ef          	jal	80000b10 <kinit>
    kvminit();       // create kernel page table
    80000f20:	2cc000ef          	jal	800011ec <kvminit>
    kvminithart();   // turn on paging
    80000f24:	03c000ef          	jal	80000f60 <kvminithart>
    procinit();      // process table
    80000f28:	11d000ef          	jal	80001844 <procinit>
    trapinit();      // trap vectors
    80000f2c:	50e010ef          	jal	8000243a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f30:	52e010ef          	jal	8000245e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f34:	5aa040ef          	jal	800054de <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f38:	5c0040ef          	jal	800054f8 <plicinithart>
    binit();         // buffer cache
    80000f3c:	431010ef          	jal	80002b6c <binit>
    iinit();         // inode table
    80000f40:	182020ef          	jal	800030c2 <iinit>
    fileinit();      // file table
    80000f44:	0ae030ef          	jal	80003ff2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	6a0040ef          	jal	800055e8 <virtio_disk_init>
    userinit();      // first user process
    80000f4c:	4ad000ef          	jal	80001bf8 <userinit>
    __sync_synchronize();
    80000f50:	0330000f          	fence	rw,rw
    started = 1;
    80000f54:	4785                	li	a5,1
    80000f56:	00007717          	auipc	a4,0x7
    80000f5a:	8ef72d23          	sw	a5,-1798(a4) # 80007850 <started>
    80000f5e:	b779                	j	80000eec <main+0x3e>

0000000080000f60 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f60:	1141                	addi	sp,sp,-16
    80000f62:	e406                	sd	ra,8(sp)
    80000f64:	e022                	sd	s0,0(sp)
    80000f66:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f68:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f6c:	00007797          	auipc	a5,0x7
    80000f70:	8ec7b783          	ld	a5,-1812(a5) # 80007858 <kernel_pagetable>
    80000f74:	83b1                	srli	a5,a5,0xc
    80000f76:	577d                	li	a4,-1
    80000f78:	177e                	slli	a4,a4,0x3f
    80000f7a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f7c:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f80:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f84:	60a2                	ld	ra,8(sp)
    80000f86:	6402                	ld	s0,0(sp)
    80000f88:	0141                	addi	sp,sp,16
    80000f8a:	8082                	ret

0000000080000f8c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f8c:	7139                	addi	sp,sp,-64
    80000f8e:	fc06                	sd	ra,56(sp)
    80000f90:	f822                	sd	s0,48(sp)
    80000f92:	f426                	sd	s1,40(sp)
    80000f94:	f04a                	sd	s2,32(sp)
    80000f96:	ec4e                	sd	s3,24(sp)
    80000f98:	e852                	sd	s4,16(sp)
    80000f9a:	e456                	sd	s5,8(sp)
    80000f9c:	e05a                	sd	s6,0(sp)
    80000f9e:	0080                	addi	s0,sp,64
    80000fa0:	84aa                	mv	s1,a0
    80000fa2:	89ae                	mv	s3,a1
    80000fa4:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80000fa6:	57fd                	li	a5,-1
    80000fa8:	83e9                	srli	a5,a5,0x1a
    80000faa:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fac:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80000fae:	04b7e263          	bltu	a5,a1,80000ff2 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fb2:	0149d933          	srl	s2,s3,s4
    80000fb6:	1ff97913          	andi	s2,s2,511
    80000fba:	090e                	slli	s2,s2,0x3
    80000fbc:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fbe:	00093483          	ld	s1,0(s2)
    80000fc2:	0014f793          	andi	a5,s1,1
    80000fc6:	cf85                	beqz	a5,80000ffe <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fc8:	80a9                	srli	s1,s1,0xa
    80000fca:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80000fcc:	3a5d                	addiw	s4,s4,-9
    80000fce:	ff5a12e3          	bne	s4,s5,80000fb2 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fd2:	00c9d513          	srli	a0,s3,0xc
    80000fd6:	1ff57513          	andi	a0,a0,511
    80000fda:	050e                	slli	a0,a0,0x3
    80000fdc:	9526                	add	a0,a0,s1
}
    80000fde:	70e2                	ld	ra,56(sp)
    80000fe0:	7442                	ld	s0,48(sp)
    80000fe2:	74a2                	ld	s1,40(sp)
    80000fe4:	7902                	ld	s2,32(sp)
    80000fe6:	69e2                	ld	s3,24(sp)
    80000fe8:	6a42                	ld	s4,16(sp)
    80000fea:	6aa2                	ld	s5,8(sp)
    80000fec:	6b02                	ld	s6,0(sp)
    80000fee:	6121                	addi	sp,sp,64
    80000ff0:	8082                	ret
    panic("walk");
    80000ff2:	00006517          	auipc	a0,0x6
    80000ff6:	0be50513          	addi	a0,a0,190 # 800070b0 <etext+0xb0>
    80000ffa:	82bff0ef          	jal	80000824 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ffe:	020b0263          	beqz	s6,80001022 <walk+0x96>
    80001002:	b43ff0ef          	jal	80000b44 <kalloc>
    80001006:	84aa                	mv	s1,a0
    80001008:	d979                	beqz	a0,80000fde <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    8000100a:	6605                	lui	a2,0x1
    8000100c:	4581                	li	a1,0
    8000100e:	cebff0ef          	jal	80000cf8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001012:	00c4d793          	srli	a5,s1,0xc
    80001016:	07aa                	slli	a5,a5,0xa
    80001018:	0017e793          	ori	a5,a5,1
    8000101c:	00f93023          	sd	a5,0(s2)
    80001020:	b775                	j	80000fcc <walk+0x40>
        return 0;
    80001022:	4501                	li	a0,0
    80001024:	bf6d                	j	80000fde <walk+0x52>

0000000080001026 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001026:	57fd                	li	a5,-1
    80001028:	83e9                	srli	a5,a5,0x1a
    8000102a:	00b7f463          	bgeu	a5,a1,80001032 <walkaddr+0xc>
    return 0;
    8000102e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001030:	8082                	ret
{
    80001032:	1141                	addi	sp,sp,-16
    80001034:	e406                	sd	ra,8(sp)
    80001036:	e022                	sd	s0,0(sp)
    80001038:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000103a:	4601                	li	a2,0
    8000103c:	f51ff0ef          	jal	80000f8c <walk>
  if(pte == 0)
    80001040:	c901                	beqz	a0,80001050 <walkaddr+0x2a>
  if((*pte & PTE_V) == 0)
    80001042:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001044:	0117f693          	andi	a3,a5,17
    80001048:	4745                	li	a4,17
    return 0;
    8000104a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000104c:	00e68663          	beq	a3,a4,80001058 <walkaddr+0x32>
}
    80001050:	60a2                	ld	ra,8(sp)
    80001052:	6402                	ld	s0,0(sp)
    80001054:	0141                	addi	sp,sp,16
    80001056:	8082                	ret
  pa = PTE2PA(*pte);
    80001058:	83a9                	srli	a5,a5,0xa
    8000105a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000105e:	bfcd                	j	80001050 <walkaddr+0x2a>

0000000080001060 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001060:	715d                	addi	sp,sp,-80
    80001062:	e486                	sd	ra,72(sp)
    80001064:	e0a2                	sd	s0,64(sp)
    80001066:	fc26                	sd	s1,56(sp)
    80001068:	f84a                	sd	s2,48(sp)
    8000106a:	f44e                	sd	s3,40(sp)
    8000106c:	f052                	sd	s4,32(sp)
    8000106e:	ec56                	sd	s5,24(sp)
    80001070:	e85a                	sd	s6,16(sp)
    80001072:	e45e                	sd	s7,8(sp)
    80001074:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001076:	03459793          	slli	a5,a1,0x34
    8000107a:	eba1                	bnez	a5,800010ca <mappages+0x6a>
    8000107c:	8a2a                	mv	s4,a0
    8000107e:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001080:	03461793          	slli	a5,a2,0x34
    80001084:	eba9                	bnez	a5,800010d6 <mappages+0x76>
    panic("mappages: size not aligned");

  if(size == 0)
    80001086:	ce31                	beqz	a2,800010e2 <mappages+0x82>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001088:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    8000108c:	80060613          	addi	a2,a2,-2048
    80001090:	00b60933          	add	s2,a2,a1
  a = va;
    80001094:	84ae                	mv	s1,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    80001096:	4b05                	li	s6,1
    80001098:	40b689b3          	sub	s3,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000109c:	6b85                	lui	s7,0x1
    if((pte = walk(pagetable, a, 1)) == 0)
    8000109e:	865a                	mv	a2,s6
    800010a0:	85a6                	mv	a1,s1
    800010a2:	8552                	mv	a0,s4
    800010a4:	ee9ff0ef          	jal	80000f8c <walk>
    800010a8:	c929                	beqz	a0,800010fa <mappages+0x9a>
    if(*pte & PTE_V)
    800010aa:	611c                	ld	a5,0(a0)
    800010ac:	8b85                	andi	a5,a5,1
    800010ae:	e3a1                	bnez	a5,800010ee <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010b0:	013487b3          	add	a5,s1,s3
    800010b4:	83b1                	srli	a5,a5,0xc
    800010b6:	07aa                	slli	a5,a5,0xa
    800010b8:	0157e7b3          	or	a5,a5,s5
    800010bc:	0017e793          	ori	a5,a5,1
    800010c0:	e11c                	sd	a5,0(a0)
    if(a == last)
    800010c2:	05248863          	beq	s1,s2,80001112 <mappages+0xb2>
    a += PGSIZE;
    800010c6:	94de                	add	s1,s1,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010c8:	bfd9                	j	8000109e <mappages+0x3e>
    panic("mappages: va not aligned");
    800010ca:	00006517          	auipc	a0,0x6
    800010ce:	fee50513          	addi	a0,a0,-18 # 800070b8 <etext+0xb8>
    800010d2:	f52ff0ef          	jal	80000824 <panic>
    panic("mappages: size not aligned");
    800010d6:	00006517          	auipc	a0,0x6
    800010da:	00250513          	addi	a0,a0,2 # 800070d8 <etext+0xd8>
    800010de:	f46ff0ef          	jal	80000824 <panic>
    panic("mappages: size");
    800010e2:	00006517          	auipc	a0,0x6
    800010e6:	01650513          	addi	a0,a0,22 # 800070f8 <etext+0xf8>
    800010ea:	f3aff0ef          	jal	80000824 <panic>
      panic("mappages: remap");
    800010ee:	00006517          	auipc	a0,0x6
    800010f2:	01a50513          	addi	a0,a0,26 # 80007108 <etext+0x108>
    800010f6:	f2eff0ef          	jal	80000824 <panic>
      return -1;
    800010fa:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010fc:	60a6                	ld	ra,72(sp)
    800010fe:	6406                	ld	s0,64(sp)
    80001100:	74e2                	ld	s1,56(sp)
    80001102:	7942                	ld	s2,48(sp)
    80001104:	79a2                	ld	s3,40(sp)
    80001106:	7a02                	ld	s4,32(sp)
    80001108:	6ae2                	ld	s5,24(sp)
    8000110a:	6b42                	ld	s6,16(sp)
    8000110c:	6ba2                	ld	s7,8(sp)
    8000110e:	6161                	addi	sp,sp,80
    80001110:	8082                	ret
  return 0;
    80001112:	4501                	li	a0,0
    80001114:	b7e5                	j	800010fc <mappages+0x9c>

0000000080001116 <kvmmap>:
{
    80001116:	1141                	addi	sp,sp,-16
    80001118:	e406                	sd	ra,8(sp)
    8000111a:	e022                	sd	s0,0(sp)
    8000111c:	0800                	addi	s0,sp,16
    8000111e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001120:	86b2                	mv	a3,a2
    80001122:	863e                	mv	a2,a5
    80001124:	f3dff0ef          	jal	80001060 <mappages>
    80001128:	e509                	bnez	a0,80001132 <kvmmap+0x1c>
}
    8000112a:	60a2                	ld	ra,8(sp)
    8000112c:	6402                	ld	s0,0(sp)
    8000112e:	0141                	addi	sp,sp,16
    80001130:	8082                	ret
    panic("kvmmap");
    80001132:	00006517          	auipc	a0,0x6
    80001136:	fe650513          	addi	a0,a0,-26 # 80007118 <etext+0x118>
    8000113a:	eeaff0ef          	jal	80000824 <panic>

000000008000113e <kvmmake>:
{
    8000113e:	1101                	addi	sp,sp,-32
    80001140:	ec06                	sd	ra,24(sp)
    80001142:	e822                	sd	s0,16(sp)
    80001144:	e426                	sd	s1,8(sp)
    80001146:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001148:	9fdff0ef          	jal	80000b44 <kalloc>
    8000114c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000114e:	6605                	lui	a2,0x1
    80001150:	4581                	li	a1,0
    80001152:	ba7ff0ef          	jal	80000cf8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001156:	4719                	li	a4,6
    80001158:	6685                	lui	a3,0x1
    8000115a:	10000637          	lui	a2,0x10000
    8000115e:	85b2                	mv	a1,a2
    80001160:	8526                	mv	a0,s1
    80001162:	fb5ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001166:	4719                	li	a4,6
    80001168:	6685                	lui	a3,0x1
    8000116a:	10001637          	lui	a2,0x10001
    8000116e:	85b2                	mv	a1,a2
    80001170:	8526                	mv	a0,s1
    80001172:	fa5ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001176:	4719                	li	a4,6
    80001178:	040006b7          	lui	a3,0x4000
    8000117c:	0c000637          	lui	a2,0xc000
    80001180:	85b2                	mv	a1,a2
    80001182:	8526                	mv	a0,s1
    80001184:	f93ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001188:	4729                	li	a4,10
    8000118a:	80006697          	auipc	a3,0x80006
    8000118e:	e7668693          	addi	a3,a3,-394 # 7000 <_entry-0x7fff9000>
    80001192:	4605                	li	a2,1
    80001194:	067e                	slli	a2,a2,0x1f
    80001196:	85b2                	mv	a1,a2
    80001198:	8526                	mv	a0,s1
    8000119a:	f7dff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000119e:	4719                	li	a4,6
    800011a0:	00006697          	auipc	a3,0x6
    800011a4:	e6068693          	addi	a3,a3,-416 # 80007000 <etext>
    800011a8:	47c5                	li	a5,17
    800011aa:	07ee                	slli	a5,a5,0x1b
    800011ac:	40d786b3          	sub	a3,a5,a3
    800011b0:	00006617          	auipc	a2,0x6
    800011b4:	e5060613          	addi	a2,a2,-432 # 80007000 <etext>
    800011b8:	85b2                	mv	a1,a2
    800011ba:	8526                	mv	a0,s1
    800011bc:	f5bff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011c0:	4729                	li	a4,10
    800011c2:	6685                	lui	a3,0x1
    800011c4:	00005617          	auipc	a2,0x5
    800011c8:	e3c60613          	addi	a2,a2,-452 # 80006000 <_trampoline>
    800011cc:	040005b7          	lui	a1,0x4000
    800011d0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011d2:	05b2                	slli	a1,a1,0xc
    800011d4:	8526                	mv	a0,s1
    800011d6:	f41ff0ef          	jal	80001116 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011da:	8526                	mv	a0,s1
    800011dc:	5c4000ef          	jal	800017a0 <proc_mapstacks>
}
    800011e0:	8526                	mv	a0,s1
    800011e2:	60e2                	ld	ra,24(sp)
    800011e4:	6442                	ld	s0,16(sp)
    800011e6:	64a2                	ld	s1,8(sp)
    800011e8:	6105                	addi	sp,sp,32
    800011ea:	8082                	ret

00000000800011ec <kvminit>:
{
    800011ec:	1141                	addi	sp,sp,-16
    800011ee:	e406                	sd	ra,8(sp)
    800011f0:	e022                	sd	s0,0(sp)
    800011f2:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011f4:	f4bff0ef          	jal	8000113e <kvmmake>
    800011f8:	00006797          	auipc	a5,0x6
    800011fc:	66a7b023          	sd	a0,1632(a5) # 80007858 <kernel_pagetable>
}
    80001200:	60a2                	ld	ra,8(sp)
    80001202:	6402                	ld	s0,0(sp)
    80001204:	0141                	addi	sp,sp,16
    80001206:	8082                	ret

0000000080001208 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001208:	1101                	addi	sp,sp,-32
    8000120a:	ec06                	sd	ra,24(sp)
    8000120c:	e822                	sd	s0,16(sp)
    8000120e:	e426                	sd	s1,8(sp)
    80001210:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001212:	933ff0ef          	jal	80000b44 <kalloc>
    80001216:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001218:	c509                	beqz	a0,80001222 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000121a:	6605                	lui	a2,0x1
    8000121c:	4581                	li	a1,0
    8000121e:	adbff0ef          	jal	80000cf8 <memset>
  return pagetable;
}
    80001222:	8526                	mv	a0,s1
    80001224:	60e2                	ld	ra,24(sp)
    80001226:	6442                	ld	s0,16(sp)
    80001228:	64a2                	ld	s1,8(sp)
    8000122a:	6105                	addi	sp,sp,32
    8000122c:	8082                	ret

000000008000122e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000122e:	7139                	addi	sp,sp,-64
    80001230:	fc06                	sd	ra,56(sp)
    80001232:	f822                	sd	s0,48(sp)
    80001234:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001236:	03459793          	slli	a5,a1,0x34
    8000123a:	e38d                	bnez	a5,8000125c <uvmunmap+0x2e>
    8000123c:	f04a                	sd	s2,32(sp)
    8000123e:	ec4e                	sd	s3,24(sp)
    80001240:	e852                	sd	s4,16(sp)
    80001242:	e456                	sd	s5,8(sp)
    80001244:	e05a                	sd	s6,0(sp)
    80001246:	8a2a                	mv	s4,a0
    80001248:	892e                	mv	s2,a1
    8000124a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000124c:	0632                	slli	a2,a2,0xc
    8000124e:	00b609b3          	add	s3,a2,a1
    80001252:	6b05                	lui	s6,0x1
    80001254:	0535f963          	bgeu	a1,s3,800012a6 <uvmunmap+0x78>
    80001258:	f426                	sd	s1,40(sp)
    8000125a:	a015                	j	8000127e <uvmunmap+0x50>
    8000125c:	f426                	sd	s1,40(sp)
    8000125e:	f04a                	sd	s2,32(sp)
    80001260:	ec4e                	sd	s3,24(sp)
    80001262:	e852                	sd	s4,16(sp)
    80001264:	e456                	sd	s5,8(sp)
    80001266:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    80001268:	00006517          	auipc	a0,0x6
    8000126c:	eb850513          	addi	a0,a0,-328 # 80007120 <etext+0x120>
    80001270:	db4ff0ef          	jal	80000824 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001274:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001278:	995a                	add	s2,s2,s6
    8000127a:	03397563          	bgeu	s2,s3,800012a4 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    8000127e:	4601                	li	a2,0
    80001280:	85ca                	mv	a1,s2
    80001282:	8552                	mv	a0,s4
    80001284:	d09ff0ef          	jal	80000f8c <walk>
    80001288:	84aa                	mv	s1,a0
    8000128a:	d57d                	beqz	a0,80001278 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    8000128c:	611c                	ld	a5,0(a0)
    8000128e:	0017f713          	andi	a4,a5,1
    80001292:	d37d                	beqz	a4,80001278 <uvmunmap+0x4a>
    if(do_free){
    80001294:	fe0a80e3          	beqz	s5,80001274 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001298:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    8000129a:	00c79513          	slli	a0,a5,0xc
    8000129e:	fbeff0ef          	jal	80000a5c <kfree>
    800012a2:	bfc9                	j	80001274 <uvmunmap+0x46>
    800012a4:	74a2                	ld	s1,40(sp)
    800012a6:	7902                	ld	s2,32(sp)
    800012a8:	69e2                	ld	s3,24(sp)
    800012aa:	6a42                	ld	s4,16(sp)
    800012ac:	6aa2                	ld	s5,8(sp)
    800012ae:	6b02                	ld	s6,0(sp)
  }
}
    800012b0:	70e2                	ld	ra,56(sp)
    800012b2:	7442                	ld	s0,48(sp)
    800012b4:	6121                	addi	sp,sp,64
    800012b6:	8082                	ret

00000000800012b8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012b8:	1101                	addi	sp,sp,-32
    800012ba:	ec06                	sd	ra,24(sp)
    800012bc:	e822                	sd	s0,16(sp)
    800012be:	e426                	sd	s1,8(sp)
    800012c0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800012c2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800012c4:	00b67d63          	bgeu	a2,a1,800012de <uvmdealloc+0x26>
    800012c8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800012ca:	6785                	lui	a5,0x1
    800012cc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012ce:	00f60733          	add	a4,a2,a5
    800012d2:	76fd                	lui	a3,0xfffff
    800012d4:	8f75                	and	a4,a4,a3
    800012d6:	97ae                	add	a5,a5,a1
    800012d8:	8ff5                	and	a5,a5,a3
    800012da:	00f76863          	bltu	a4,a5,800012ea <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800012de:	8526                	mv	a0,s1
    800012e0:	60e2                	ld	ra,24(sp)
    800012e2:	6442                	ld	s0,16(sp)
    800012e4:	64a2                	ld	s1,8(sp)
    800012e6:	6105                	addi	sp,sp,32
    800012e8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012ea:	8f99                	sub	a5,a5,a4
    800012ec:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012ee:	4685                	li	a3,1
    800012f0:	0007861b          	sext.w	a2,a5
    800012f4:	85ba                	mv	a1,a4
    800012f6:	f39ff0ef          	jal	8000122e <uvmunmap>
    800012fa:	b7d5                	j	800012de <uvmdealloc+0x26>

00000000800012fc <uvmalloc>:
  if(newsz < oldsz)
    800012fc:	0ab66163          	bltu	a2,a1,8000139e <uvmalloc+0xa2>
{
    80001300:	715d                	addi	sp,sp,-80
    80001302:	e486                	sd	ra,72(sp)
    80001304:	e0a2                	sd	s0,64(sp)
    80001306:	f84a                	sd	s2,48(sp)
    80001308:	f052                	sd	s4,32(sp)
    8000130a:	ec56                	sd	s5,24(sp)
    8000130c:	e45e                	sd	s7,8(sp)
    8000130e:	0880                	addi	s0,sp,80
    80001310:	8aaa                	mv	s5,a0
    80001312:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001314:	6785                	lui	a5,0x1
    80001316:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001318:	95be                	add	a1,a1,a5
    8000131a:	77fd                	lui	a5,0xfffff
    8000131c:	00f5f933          	and	s2,a1,a5
    80001320:	8bca                	mv	s7,s2
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001322:	08c97063          	bgeu	s2,a2,800013a2 <uvmalloc+0xa6>
    80001326:	fc26                	sd	s1,56(sp)
    80001328:	f44e                	sd	s3,40(sp)
    8000132a:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    8000132c:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000132e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001332:	813ff0ef          	jal	80000b44 <kalloc>
    80001336:	84aa                	mv	s1,a0
    if(mem == 0){
    80001338:	c50d                	beqz	a0,80001362 <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    8000133a:	864e                	mv	a2,s3
    8000133c:	4581                	li	a1,0
    8000133e:	9bbff0ef          	jal	80000cf8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001342:	875a                	mv	a4,s6
    80001344:	86a6                	mv	a3,s1
    80001346:	864e                	mv	a2,s3
    80001348:	85ca                	mv	a1,s2
    8000134a:	8556                	mv	a0,s5
    8000134c:	d15ff0ef          	jal	80001060 <mappages>
    80001350:	e915                	bnez	a0,80001384 <uvmalloc+0x88>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001352:	994e                	add	s2,s2,s3
    80001354:	fd496fe3          	bltu	s2,s4,80001332 <uvmalloc+0x36>
  return newsz;
    80001358:	8552                	mv	a0,s4
    8000135a:	74e2                	ld	s1,56(sp)
    8000135c:	79a2                	ld	s3,40(sp)
    8000135e:	6b42                	ld	s6,16(sp)
    80001360:	a811                	j	80001374 <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    80001362:	865e                	mv	a2,s7
    80001364:	85ca                	mv	a1,s2
    80001366:	8556                	mv	a0,s5
    80001368:	f51ff0ef          	jal	800012b8 <uvmdealloc>
      return 0;
    8000136c:	4501                	li	a0,0
    8000136e:	74e2                	ld	s1,56(sp)
    80001370:	79a2                	ld	s3,40(sp)
    80001372:	6b42                	ld	s6,16(sp)
}
    80001374:	60a6                	ld	ra,72(sp)
    80001376:	6406                	ld	s0,64(sp)
    80001378:	7942                	ld	s2,48(sp)
    8000137a:	7a02                	ld	s4,32(sp)
    8000137c:	6ae2                	ld	s5,24(sp)
    8000137e:	6ba2                	ld	s7,8(sp)
    80001380:	6161                	addi	sp,sp,80
    80001382:	8082                	ret
      kfree(mem);
    80001384:	8526                	mv	a0,s1
    80001386:	ed6ff0ef          	jal	80000a5c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000138a:	865e                	mv	a2,s7
    8000138c:	85ca                	mv	a1,s2
    8000138e:	8556                	mv	a0,s5
    80001390:	f29ff0ef          	jal	800012b8 <uvmdealloc>
      return 0;
    80001394:	4501                	li	a0,0
    80001396:	74e2                	ld	s1,56(sp)
    80001398:	79a2                	ld	s3,40(sp)
    8000139a:	6b42                	ld	s6,16(sp)
    8000139c:	bfe1                	j	80001374 <uvmalloc+0x78>
    return oldsz;
    8000139e:	852e                	mv	a0,a1
}
    800013a0:	8082                	ret
  return newsz;
    800013a2:	8532                	mv	a0,a2
    800013a4:	bfc1                	j	80001374 <uvmalloc+0x78>

00000000800013a6 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013a6:	7179                	addi	sp,sp,-48
    800013a8:	f406                	sd	ra,40(sp)
    800013aa:	f022                	sd	s0,32(sp)
    800013ac:	ec26                	sd	s1,24(sp)
    800013ae:	e84a                	sd	s2,16(sp)
    800013b0:	e44e                	sd	s3,8(sp)
    800013b2:	1800                	addi	s0,sp,48
    800013b4:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013b6:	84aa                	mv	s1,a0
    800013b8:	6905                	lui	s2,0x1
    800013ba:	992a                	add	s2,s2,a0
    800013bc:	a811                	j	800013d0 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    800013be:	00006517          	auipc	a0,0x6
    800013c2:	d7a50513          	addi	a0,a0,-646 # 80007138 <etext+0x138>
    800013c6:	c5eff0ef          	jal	80000824 <panic>
  for(int i = 0; i < 512; i++){
    800013ca:	04a1                	addi	s1,s1,8
    800013cc:	03248163          	beq	s1,s2,800013ee <freewalk+0x48>
    pte_t pte = pagetable[i];
    800013d0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013d2:	0017f713          	andi	a4,a5,1
    800013d6:	db75                	beqz	a4,800013ca <freewalk+0x24>
    800013d8:	00e7f713          	andi	a4,a5,14
    800013dc:	f36d                	bnez	a4,800013be <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800013de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800013e0:	00c79513          	slli	a0,a5,0xc
    800013e4:	fc3ff0ef          	jal	800013a6 <freewalk>
      pagetable[i] = 0;
    800013e8:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013ec:	bff9                	j	800013ca <freewalk+0x24>
    }
  }
  kfree((void*)pagetable);
    800013ee:	854e                	mv	a0,s3
    800013f0:	e6cff0ef          	jal	80000a5c <kfree>
}
    800013f4:	70a2                	ld	ra,40(sp)
    800013f6:	7402                	ld	s0,32(sp)
    800013f8:	64e2                	ld	s1,24(sp)
    800013fa:	6942                	ld	s2,16(sp)
    800013fc:	69a2                	ld	s3,8(sp)
    800013fe:	6145                	addi	sp,sp,48
    80001400:	8082                	ret

0000000080001402 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001402:	1101                	addi	sp,sp,-32
    80001404:	ec06                	sd	ra,24(sp)
    80001406:	e822                	sd	s0,16(sp)
    80001408:	e426                	sd	s1,8(sp)
    8000140a:	1000                	addi	s0,sp,32
    8000140c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000140e:	e989                	bnez	a1,80001420 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001410:	8526                	mv	a0,s1
    80001412:	f95ff0ef          	jal	800013a6 <freewalk>
}
    80001416:	60e2                	ld	ra,24(sp)
    80001418:	6442                	ld	s0,16(sp)
    8000141a:	64a2                	ld	s1,8(sp)
    8000141c:	6105                	addi	sp,sp,32
    8000141e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001420:	6785                	lui	a5,0x1
    80001422:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001424:	95be                	add	a1,a1,a5
    80001426:	4685                	li	a3,1
    80001428:	00c5d613          	srli	a2,a1,0xc
    8000142c:	4581                	li	a1,0
    8000142e:	e01ff0ef          	jal	8000122e <uvmunmap>
    80001432:	bff9                	j	80001410 <uvmfree+0xe>

0000000080001434 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001434:	ca59                	beqz	a2,800014ca <uvmcopy+0x96>
{
    80001436:	715d                	addi	sp,sp,-80
    80001438:	e486                	sd	ra,72(sp)
    8000143a:	e0a2                	sd	s0,64(sp)
    8000143c:	fc26                	sd	s1,56(sp)
    8000143e:	f84a                	sd	s2,48(sp)
    80001440:	f44e                	sd	s3,40(sp)
    80001442:	f052                	sd	s4,32(sp)
    80001444:	ec56                	sd	s5,24(sp)
    80001446:	e85a                	sd	s6,16(sp)
    80001448:	e45e                	sd	s7,8(sp)
    8000144a:	0880                	addi	s0,sp,80
    8000144c:	8b2a                	mv	s6,a0
    8000144e:	8bae                	mv	s7,a1
    80001450:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001452:	4481                	li	s1,0
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001454:	6a05                	lui	s4,0x1
    80001456:	a021                	j	8000145e <uvmcopy+0x2a>
  for(i = 0; i < sz; i += PGSIZE){
    80001458:	94d2                	add	s1,s1,s4
    8000145a:	0554fc63          	bgeu	s1,s5,800014b2 <uvmcopy+0x7e>
    if((pte = walk(old, i, 0)) == 0)
    8000145e:	4601                	li	a2,0
    80001460:	85a6                	mv	a1,s1
    80001462:	855a                	mv	a0,s6
    80001464:	b29ff0ef          	jal	80000f8c <walk>
    80001468:	d965                	beqz	a0,80001458 <uvmcopy+0x24>
    if((*pte & PTE_V) == 0)
    8000146a:	00053983          	ld	s3,0(a0)
    8000146e:	0019f793          	andi	a5,s3,1
    80001472:	d3fd                	beqz	a5,80001458 <uvmcopy+0x24>
    if((mem = kalloc()) == 0)
    80001474:	ed0ff0ef          	jal	80000b44 <kalloc>
    80001478:	892a                	mv	s2,a0
    8000147a:	c11d                	beqz	a0,800014a0 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    8000147c:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char*)pa, PGSIZE);
    80001480:	8652                	mv	a2,s4
    80001482:	05b2                	slli	a1,a1,0xc
    80001484:	8d5ff0ef          	jal	80000d58 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001488:	3ff9f713          	andi	a4,s3,1023
    8000148c:	86ca                	mv	a3,s2
    8000148e:	8652                	mv	a2,s4
    80001490:	85a6                	mv	a1,s1
    80001492:	855e                	mv	a0,s7
    80001494:	bcdff0ef          	jal	80001060 <mappages>
    80001498:	d161                	beqz	a0,80001458 <uvmcopy+0x24>
      kfree(mem);
    8000149a:	854a                	mv	a0,s2
    8000149c:	dc0ff0ef          	jal	80000a5c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014a0:	4685                	li	a3,1
    800014a2:	00c4d613          	srli	a2,s1,0xc
    800014a6:	4581                	li	a1,0
    800014a8:	855e                	mv	a0,s7
    800014aa:	d85ff0ef          	jal	8000122e <uvmunmap>
  return -1;
    800014ae:	557d                	li	a0,-1
    800014b0:	a011                	j	800014b4 <uvmcopy+0x80>
  return 0;
    800014b2:	4501                	li	a0,0
}
    800014b4:	60a6                	ld	ra,72(sp)
    800014b6:	6406                	ld	s0,64(sp)
    800014b8:	74e2                	ld	s1,56(sp)
    800014ba:	7942                	ld	s2,48(sp)
    800014bc:	79a2                	ld	s3,40(sp)
    800014be:	7a02                	ld	s4,32(sp)
    800014c0:	6ae2                	ld	s5,24(sp)
    800014c2:	6b42                	ld	s6,16(sp)
    800014c4:	6ba2                	ld	s7,8(sp)
    800014c6:	6161                	addi	sp,sp,80
    800014c8:	8082                	ret
  return 0;
    800014ca:	4501                	li	a0,0
}
    800014cc:	8082                	ret

00000000800014ce <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014ce:	1141                	addi	sp,sp,-16
    800014d0:	e406                	sd	ra,8(sp)
    800014d2:	e022                	sd	s0,0(sp)
    800014d4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800014d6:	4601                	li	a2,0
    800014d8:	ab5ff0ef          	jal	80000f8c <walk>
  if(pte == 0)
    800014dc:	c901                	beqz	a0,800014ec <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014de:	611c                	ld	a5,0(a0)
    800014e0:	9bbd                	andi	a5,a5,-17
    800014e2:	e11c                	sd	a5,0(a0)
}
    800014e4:	60a2                	ld	ra,8(sp)
    800014e6:	6402                	ld	s0,0(sp)
    800014e8:	0141                	addi	sp,sp,16
    800014ea:	8082                	ret
    panic("uvmclear");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	c5c50513          	addi	a0,a0,-932 # 80007148 <etext+0x148>
    800014f4:	b30ff0ef          	jal	80000824 <panic>

00000000800014f8 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800014f8:	cac5                	beqz	a3,800015a8 <copyinstr+0xb0>
{
    800014fa:	715d                	addi	sp,sp,-80
    800014fc:	e486                	sd	ra,72(sp)
    800014fe:	e0a2                	sd	s0,64(sp)
    80001500:	fc26                	sd	s1,56(sp)
    80001502:	f84a                	sd	s2,48(sp)
    80001504:	f44e                	sd	s3,40(sp)
    80001506:	f052                	sd	s4,32(sp)
    80001508:	ec56                	sd	s5,24(sp)
    8000150a:	e85a                	sd	s6,16(sp)
    8000150c:	e45e                	sd	s7,8(sp)
    8000150e:	0880                	addi	s0,sp,80
    80001510:	8aaa                	mv	s5,a0
    80001512:	84ae                	mv	s1,a1
    80001514:	8bb2                	mv	s7,a2
    80001516:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001518:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000151a:	6a05                	lui	s4,0x1
    8000151c:	a82d                	j	80001556 <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000151e:	00078023          	sb	zero,0(a5)
        got_null = 1;
    80001522:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001524:	0017c793          	xori	a5,a5,1
    80001528:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000152c:	60a6                	ld	ra,72(sp)
    8000152e:	6406                	ld	s0,64(sp)
    80001530:	74e2                	ld	s1,56(sp)
    80001532:	7942                	ld	s2,48(sp)
    80001534:	79a2                	ld	s3,40(sp)
    80001536:	7a02                	ld	s4,32(sp)
    80001538:	6ae2                	ld	s5,24(sp)
    8000153a:	6b42                	ld	s6,16(sp)
    8000153c:	6ba2                	ld	s7,8(sp)
    8000153e:	6161                	addi	sp,sp,80
    80001540:	8082                	ret
    80001542:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    80001546:	9726                	add	a4,a4,s1
      --max;
    80001548:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    8000154c:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    80001550:	04e58463          	beq	a1,a4,80001598 <copyinstr+0xa0>
{
    80001554:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001556:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    8000155a:	85ca                	mv	a1,s2
    8000155c:	8556                	mv	a0,s5
    8000155e:	ac9ff0ef          	jal	80001026 <walkaddr>
    if(pa0 == 0)
    80001562:	cd0d                	beqz	a0,8000159c <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001564:	417906b3          	sub	a3,s2,s7
    80001568:	96d2                	add	a3,a3,s4
    if(n > max)
    8000156a:	00d9f363          	bgeu	s3,a3,80001570 <copyinstr+0x78>
    8000156e:	86ce                	mv	a3,s3
    while(n > 0){
    80001570:	ca85                	beqz	a3,800015a0 <copyinstr+0xa8>
    char *p = (char *) (pa0 + (srcva - va0));
    80001572:	01750633          	add	a2,a0,s7
    80001576:	41260633          	sub	a2,a2,s2
    8000157a:	87a6                	mv	a5,s1
      if(*p == '\0'){
    8000157c:	8e05                	sub	a2,a2,s1
    while(n > 0){
    8000157e:	96a6                	add	a3,a3,s1
    80001580:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001582:	00f60733          	add	a4,a2,a5
    80001586:	00074703          	lbu	a4,0(a4)
    8000158a:	db51                	beqz	a4,8000151e <copyinstr+0x26>
        *dst = *p;
    8000158c:	00e78023          	sb	a4,0(a5)
      dst++;
    80001590:	0785                	addi	a5,a5,1
    while(n > 0){
    80001592:	fed797e3          	bne	a5,a3,80001580 <copyinstr+0x88>
    80001596:	b775                	j	80001542 <copyinstr+0x4a>
    80001598:	4781                	li	a5,0
    8000159a:	b769                	j	80001524 <copyinstr+0x2c>
      return -1;
    8000159c:	557d                	li	a0,-1
    8000159e:	b779                	j	8000152c <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    800015a0:	6b85                	lui	s7,0x1
    800015a2:	9bca                	add	s7,s7,s2
    800015a4:	87a6                	mv	a5,s1
    800015a6:	b77d                	j	80001554 <copyinstr+0x5c>
  int got_null = 0;
    800015a8:	4781                	li	a5,0
  if(got_null){
    800015aa:	0017c793          	xori	a5,a5,1
    800015ae:	40f0053b          	negw	a0,a5
}
    800015b2:	8082                	ret

00000000800015b4 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800015b4:	1141                	addi	sp,sp,-16
    800015b6:	e406                	sd	ra,8(sp)
    800015b8:	e022                	sd	s0,0(sp)
    800015ba:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800015bc:	4601                	li	a2,0
    800015be:	9cfff0ef          	jal	80000f8c <walk>
  if (pte == 0) {
    800015c2:	c119                	beqz	a0,800015c8 <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V){
    800015c4:	6108                	ld	a0,0(a0)
    800015c6:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800015c8:	60a2                	ld	ra,8(sp)
    800015ca:	6402                	ld	s0,0(sp)
    800015cc:	0141                	addi	sp,sp,16
    800015ce:	8082                	ret

00000000800015d0 <vmfault>:
{
    800015d0:	7179                	addi	sp,sp,-48
    800015d2:	f406                	sd	ra,40(sp)
    800015d4:	f022                	sd	s0,32(sp)
    800015d6:	e84a                	sd	s2,16(sp)
    800015d8:	e44e                	sd	s3,8(sp)
    800015da:	1800                	addi	s0,sp,48
    800015dc:	89aa                	mv	s3,a0
    800015de:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800015e0:	34e000ef          	jal	8000192e <myproc>
  if (va >= p->sz)
    800015e4:	653c                	ld	a5,72(a0)
    800015e6:	00f96a63          	bltu	s2,a5,800015fa <vmfault+0x2a>
    return 0;
    800015ea:	4981                	li	s3,0
}
    800015ec:	854e                	mv	a0,s3
    800015ee:	70a2                	ld	ra,40(sp)
    800015f0:	7402                	ld	s0,32(sp)
    800015f2:	6942                	ld	s2,16(sp)
    800015f4:	69a2                	ld	s3,8(sp)
    800015f6:	6145                	addi	sp,sp,48
    800015f8:	8082                	ret
    800015fa:	ec26                	sd	s1,24(sp)
    800015fc:	e052                	sd	s4,0(sp)
    800015fe:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    80001600:	77fd                	lui	a5,0xfffff
    80001602:	00f97a33          	and	s4,s2,a5
  if(ismapped(pagetable, va)) {
    80001606:	85d2                	mv	a1,s4
    80001608:	854e                	mv	a0,s3
    8000160a:	fabff0ef          	jal	800015b4 <ismapped>
    return 0;
    8000160e:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001610:	c501                	beqz	a0,80001618 <vmfault+0x48>
    80001612:	64e2                	ld	s1,24(sp)
    80001614:	6a02                	ld	s4,0(sp)
    80001616:	bfd9                	j	800015ec <vmfault+0x1c>
  mem = (uint64) kalloc();
    80001618:	d2cff0ef          	jal	80000b44 <kalloc>
    8000161c:	892a                	mv	s2,a0
  if(mem == 0)
    8000161e:	c905                	beqz	a0,8000164e <vmfault+0x7e>
  mem = (uint64) kalloc();
    80001620:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    80001622:	6605                	lui	a2,0x1
    80001624:	4581                	li	a1,0
    80001626:	ed2ff0ef          	jal	80000cf8 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    8000162a:	4759                	li	a4,22
    8000162c:	86ca                	mv	a3,s2
    8000162e:	6605                	lui	a2,0x1
    80001630:	85d2                	mv	a1,s4
    80001632:	68a8                	ld	a0,80(s1)
    80001634:	a2dff0ef          	jal	80001060 <mappages>
    80001638:	e501                	bnez	a0,80001640 <vmfault+0x70>
    8000163a:	64e2                	ld	s1,24(sp)
    8000163c:	6a02                	ld	s4,0(sp)
    8000163e:	b77d                	j	800015ec <vmfault+0x1c>
    kfree((void *)mem);
    80001640:	854a                	mv	a0,s2
    80001642:	c1aff0ef          	jal	80000a5c <kfree>
    return 0;
    80001646:	4981                	li	s3,0
    80001648:	64e2                	ld	s1,24(sp)
    8000164a:	6a02                	ld	s4,0(sp)
    8000164c:	b745                	j	800015ec <vmfault+0x1c>
    8000164e:	64e2                	ld	s1,24(sp)
    80001650:	6a02                	ld	s4,0(sp)
    80001652:	bf69                	j	800015ec <vmfault+0x1c>

0000000080001654 <copyout>:
  while(len > 0){
    80001654:	cad1                	beqz	a3,800016e8 <copyout+0x94>
{
    80001656:	711d                	addi	sp,sp,-96
    80001658:	ec86                	sd	ra,88(sp)
    8000165a:	e8a2                	sd	s0,80(sp)
    8000165c:	e4a6                	sd	s1,72(sp)
    8000165e:	e0ca                	sd	s2,64(sp)
    80001660:	fc4e                	sd	s3,56(sp)
    80001662:	f852                	sd	s4,48(sp)
    80001664:	f456                	sd	s5,40(sp)
    80001666:	f05a                	sd	s6,32(sp)
    80001668:	ec5e                	sd	s7,24(sp)
    8000166a:	e862                	sd	s8,16(sp)
    8000166c:	e466                	sd	s9,8(sp)
    8000166e:	e06a                	sd	s10,0(sp)
    80001670:	1080                	addi	s0,sp,96
    80001672:	8baa                	mv	s7,a0
    80001674:	8a2e                	mv	s4,a1
    80001676:	8b32                	mv	s6,a2
    80001678:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    8000167a:	7d7d                	lui	s10,0xfffff
    if(va0 >= MAXVA)
    8000167c:	5cfd                	li	s9,-1
    8000167e:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    80001682:	6c05                	lui	s8,0x1
    80001684:	a005                	j	800016a4 <copyout+0x50>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001686:	409a0533          	sub	a0,s4,s1
    8000168a:	0009061b          	sext.w	a2,s2
    8000168e:	85da                	mv	a1,s6
    80001690:	954e                	add	a0,a0,s3
    80001692:	ec6ff0ef          	jal	80000d58 <memmove>
    len -= n;
    80001696:	412a8ab3          	sub	s5,s5,s2
    src += n;
    8000169a:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    8000169c:	01848a33          	add	s4,s1,s8
  while(len > 0){
    800016a0:	040a8263          	beqz	s5,800016e4 <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    800016a4:	01aa74b3          	and	s1,s4,s10
    if(va0 >= MAXVA)
    800016a8:	049ce263          	bltu	s9,s1,800016ec <copyout+0x98>
    pa0 = walkaddr(pagetable, va0);
    800016ac:	85a6                	mv	a1,s1
    800016ae:	855e                	mv	a0,s7
    800016b0:	977ff0ef          	jal	80001026 <walkaddr>
    800016b4:	89aa                	mv	s3,a0
    if(pa0 == 0) {
    800016b6:	e901                	bnez	a0,800016c6 <copyout+0x72>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800016b8:	4601                	li	a2,0
    800016ba:	85a6                	mv	a1,s1
    800016bc:	855e                	mv	a0,s7
    800016be:	f13ff0ef          	jal	800015d0 <vmfault>
    800016c2:	89aa                	mv	s3,a0
    800016c4:	c139                	beqz	a0,8000170a <copyout+0xb6>
    pte = walk(pagetable, va0, 0);
    800016c6:	4601                	li	a2,0
    800016c8:	85a6                	mv	a1,s1
    800016ca:	855e                	mv	a0,s7
    800016cc:	8c1ff0ef          	jal	80000f8c <walk>
    if((*pte & PTE_W) == 0)
    800016d0:	611c                	ld	a5,0(a0)
    800016d2:	8b91                	andi	a5,a5,4
    800016d4:	cf8d                	beqz	a5,8000170e <copyout+0xba>
    n = PGSIZE - (dstva - va0);
    800016d6:	41448933          	sub	s2,s1,s4
    800016da:	9962                	add	s2,s2,s8
    if(n > len)
    800016dc:	fb2af5e3          	bgeu	s5,s2,80001686 <copyout+0x32>
    800016e0:	8956                	mv	s2,s5
    800016e2:	b755                	j	80001686 <copyout+0x32>
  return 0;
    800016e4:	4501                	li	a0,0
    800016e6:	a021                	j	800016ee <copyout+0x9a>
    800016e8:	4501                	li	a0,0
}
    800016ea:	8082                	ret
      return -1;
    800016ec:	557d                	li	a0,-1
}
    800016ee:	60e6                	ld	ra,88(sp)
    800016f0:	6446                	ld	s0,80(sp)
    800016f2:	64a6                	ld	s1,72(sp)
    800016f4:	6906                	ld	s2,64(sp)
    800016f6:	79e2                	ld	s3,56(sp)
    800016f8:	7a42                	ld	s4,48(sp)
    800016fa:	7aa2                	ld	s5,40(sp)
    800016fc:	7b02                	ld	s6,32(sp)
    800016fe:	6be2                	ld	s7,24(sp)
    80001700:	6c42                	ld	s8,16(sp)
    80001702:	6ca2                	ld	s9,8(sp)
    80001704:	6d02                	ld	s10,0(sp)
    80001706:	6125                	addi	sp,sp,96
    80001708:	8082                	ret
        return -1;
    8000170a:	557d                	li	a0,-1
    8000170c:	b7cd                	j	800016ee <copyout+0x9a>
      return -1;
    8000170e:	557d                	li	a0,-1
    80001710:	bff9                	j	800016ee <copyout+0x9a>

0000000080001712 <copyin>:
  while(len > 0){
    80001712:	c6c9                	beqz	a3,8000179c <copyin+0x8a>
{
    80001714:	715d                	addi	sp,sp,-80
    80001716:	e486                	sd	ra,72(sp)
    80001718:	e0a2                	sd	s0,64(sp)
    8000171a:	fc26                	sd	s1,56(sp)
    8000171c:	f84a                	sd	s2,48(sp)
    8000171e:	f44e                	sd	s3,40(sp)
    80001720:	f052                	sd	s4,32(sp)
    80001722:	ec56                	sd	s5,24(sp)
    80001724:	e85a                	sd	s6,16(sp)
    80001726:	e45e                	sd	s7,8(sp)
    80001728:	e062                	sd	s8,0(sp)
    8000172a:	0880                	addi	s0,sp,80
    8000172c:	8baa                	mv	s7,a0
    8000172e:	8aae                	mv	s5,a1
    80001730:	8932                	mv	s2,a2
    80001732:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001734:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001736:	6b05                	lui	s6,0x1
    80001738:	a035                	j	80001764 <copyin+0x52>
    8000173a:	412984b3          	sub	s1,s3,s2
    8000173e:	94da                	add	s1,s1,s6
    if(n > len)
    80001740:	009a7363          	bgeu	s4,s1,80001746 <copyin+0x34>
    80001744:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001746:	413905b3          	sub	a1,s2,s3
    8000174a:	0004861b          	sext.w	a2,s1
    8000174e:	95aa                	add	a1,a1,a0
    80001750:	8556                	mv	a0,s5
    80001752:	e06ff0ef          	jal	80000d58 <memmove>
    len -= n;
    80001756:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000175a:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000175c:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001760:	020a0163          	beqz	s4,80001782 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001764:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001768:	85ce                	mv	a1,s3
    8000176a:	855e                	mv	a0,s7
    8000176c:	8bbff0ef          	jal	80001026 <walkaddr>
    if(pa0 == 0) {
    80001770:	f569                	bnez	a0,8000173a <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001772:	4601                	li	a2,0
    80001774:	85ce                	mv	a1,s3
    80001776:	855e                	mv	a0,s7
    80001778:	e59ff0ef          	jal	800015d0 <vmfault>
    8000177c:	fd5d                	bnez	a0,8000173a <copyin+0x28>
        return -1;
    8000177e:	557d                	li	a0,-1
    80001780:	a011                	j	80001784 <copyin+0x72>
  return 0;
    80001782:	4501                	li	a0,0
}
    80001784:	60a6                	ld	ra,72(sp)
    80001786:	6406                	ld	s0,64(sp)
    80001788:	74e2                	ld	s1,56(sp)
    8000178a:	7942                	ld	s2,48(sp)
    8000178c:	79a2                	ld	s3,40(sp)
    8000178e:	7a02                	ld	s4,32(sp)
    80001790:	6ae2                	ld	s5,24(sp)
    80001792:	6b42                	ld	s6,16(sp)
    80001794:	6ba2                	ld	s7,8(sp)
    80001796:	6c02                	ld	s8,0(sp)
    80001798:	6161                	addi	sp,sp,80
    8000179a:	8082                	ret
  return 0;
    8000179c:	4501                	li	a0,0
}
    8000179e:	8082                	ret

00000000800017a0 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800017a0:	715d                	addi	sp,sp,-80
    800017a2:	e486                	sd	ra,72(sp)
    800017a4:	e0a2                	sd	s0,64(sp)
    800017a6:	fc26                	sd	s1,56(sp)
    800017a8:	f84a                	sd	s2,48(sp)
    800017aa:	f44e                	sd	s3,40(sp)
    800017ac:	f052                	sd	s4,32(sp)
    800017ae:	ec56                	sd	s5,24(sp)
    800017b0:	e85a                	sd	s6,16(sp)
    800017b2:	e45e                	sd	s7,8(sp)
    800017b4:	e062                	sd	s8,0(sp)
    800017b6:	0880                	addi	s0,sp,80
    800017b8:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800017ba:	0000e497          	auipc	s1,0xe
    800017be:	5de48493          	addi	s1,s1,1502 # 8000fd98 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800017c2:	8c26                	mv	s8,s1
    800017c4:	ff4df937          	lui	s2,0xff4df
    800017c8:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bdc45>
    800017cc:	0936                	slli	s2,s2,0xd
    800017ce:	6f590913          	addi	s2,s2,1781
    800017d2:	0936                	slli	s2,s2,0xd
    800017d4:	bd390913          	addi	s2,s2,-1069
    800017d8:	0932                	slli	s2,s2,0xc
    800017da:	7a790913          	addi	s2,s2,1959
    800017de:	040009b7          	lui	s3,0x4000
    800017e2:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017e4:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017e6:	4b99                	li	s7,6
    800017e8:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    800017ea:	00014a97          	auipc	s5,0x14
    800017ee:	1aea8a93          	addi	s5,s5,430 # 80015998 <tickslock>
    char *pa = kalloc();
    800017f2:	b52ff0ef          	jal	80000b44 <kalloc>
    800017f6:	862a                	mv	a2,a0
    if(pa == 0)
    800017f8:	c121                	beqz	a0,80001838 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int) (p - proc));
    800017fa:	418485b3          	sub	a1,s1,s8
    800017fe:	8591                	srai	a1,a1,0x4
    80001800:	032585b3          	mul	a1,a1,s2
    80001804:	05b6                	slli	a1,a1,0xd
    80001806:	6789                	lui	a5,0x2
    80001808:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000180a:	875e                	mv	a4,s7
    8000180c:	86da                	mv	a3,s6
    8000180e:	40b985b3          	sub	a1,s3,a1
    80001812:	8552                	mv	a0,s4
    80001814:	903ff0ef          	jal	80001116 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001818:	17048493          	addi	s1,s1,368
    8000181c:	fd549be3          	bne	s1,s5,800017f2 <proc_mapstacks+0x52>
  }
}
    80001820:	60a6                	ld	ra,72(sp)
    80001822:	6406                	ld	s0,64(sp)
    80001824:	74e2                	ld	s1,56(sp)
    80001826:	7942                	ld	s2,48(sp)
    80001828:	79a2                	ld	s3,40(sp)
    8000182a:	7a02                	ld	s4,32(sp)
    8000182c:	6ae2                	ld	s5,24(sp)
    8000182e:	6b42                	ld	s6,16(sp)
    80001830:	6ba2                	ld	s7,8(sp)
    80001832:	6c02                	ld	s8,0(sp)
    80001834:	6161                	addi	sp,sp,80
    80001836:	8082                	ret
      panic("kalloc");
    80001838:	00006517          	auipc	a0,0x6
    8000183c:	92050513          	addi	a0,a0,-1760 # 80007158 <etext+0x158>
    80001840:	fe5fe0ef          	jal	80000824 <panic>

0000000080001844 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001844:	7139                	addi	sp,sp,-64
    80001846:	fc06                	sd	ra,56(sp)
    80001848:	f822                	sd	s0,48(sp)
    8000184a:	f426                	sd	s1,40(sp)
    8000184c:	f04a                	sd	s2,32(sp)
    8000184e:	ec4e                	sd	s3,24(sp)
    80001850:	e852                	sd	s4,16(sp)
    80001852:	e456                	sd	s5,8(sp)
    80001854:	e05a                	sd	s6,0(sp)
    80001856:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001858:	00006597          	auipc	a1,0x6
    8000185c:	90858593          	addi	a1,a1,-1784 # 80007160 <etext+0x160>
    80001860:	0000e517          	auipc	a0,0xe
    80001864:	10850513          	addi	a0,a0,264 # 8000f968 <pid_lock>
    80001868:	b36ff0ef          	jal	80000b9e <initlock>
  initlock(&wait_lock, "wait_lock");
    8000186c:	00006597          	auipc	a1,0x6
    80001870:	8fc58593          	addi	a1,a1,-1796 # 80007168 <etext+0x168>
    80001874:	0000e517          	auipc	a0,0xe
    80001878:	10c50513          	addi	a0,a0,268 # 8000f980 <wait_lock>
    8000187c:	b22ff0ef          	jal	80000b9e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001880:	0000e497          	auipc	s1,0xe
    80001884:	51848493          	addi	s1,s1,1304 # 8000fd98 <proc>
      initlock(&p->lock, "proc");
    80001888:	00006b17          	auipc	s6,0x6
    8000188c:	8f0b0b13          	addi	s6,s6,-1808 # 80007178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001890:	8aa6                	mv	s5,s1
    80001892:	ff4df937          	lui	s2,0xff4df
    80001896:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bdc45>
    8000189a:	0936                	slli	s2,s2,0xd
    8000189c:	6f590913          	addi	s2,s2,1781
    800018a0:	0936                	slli	s2,s2,0xd
    800018a2:	bd390913          	addi	s2,s2,-1069
    800018a6:	0932                	slli	s2,s2,0xc
    800018a8:	7a790913          	addi	s2,s2,1959
    800018ac:	040009b7          	lui	s3,0x4000
    800018b0:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018b2:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018b4:	00014a17          	auipc	s4,0x14
    800018b8:	0e4a0a13          	addi	s4,s4,228 # 80015998 <tickslock>
      initlock(&p->lock, "proc");
    800018bc:	85da                	mv	a1,s6
    800018be:	8526                	mv	a0,s1
    800018c0:	adeff0ef          	jal	80000b9e <initlock>
      p->state = UNUSED;
    800018c4:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800018c8:	415487b3          	sub	a5,s1,s5
    800018cc:	8791                	srai	a5,a5,0x4
    800018ce:	032787b3          	mul	a5,a5,s2
    800018d2:	07b6                	slli	a5,a5,0xd
    800018d4:	6709                	lui	a4,0x2
    800018d6:	9fb9                	addw	a5,a5,a4
    800018d8:	40f987b3          	sub	a5,s3,a5
    800018dc:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800018de:	17048493          	addi	s1,s1,368
    800018e2:	fd449de3          	bne	s1,s4,800018bc <procinit+0x78>
  }
}
    800018e6:	70e2                	ld	ra,56(sp)
    800018e8:	7442                	ld	s0,48(sp)
    800018ea:	74a2                	ld	s1,40(sp)
    800018ec:	7902                	ld	s2,32(sp)
    800018ee:	69e2                	ld	s3,24(sp)
    800018f0:	6a42                	ld	s4,16(sp)
    800018f2:	6aa2                	ld	s5,8(sp)
    800018f4:	6b02                	ld	s6,0(sp)
    800018f6:	6121                	addi	sp,sp,64
    800018f8:	8082                	ret

00000000800018fa <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018fa:	1141                	addi	sp,sp,-16
    800018fc:	e406                	sd	ra,8(sp)
    800018fe:	e022                	sd	s0,0(sp)
    80001900:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001902:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001904:	2501                	sext.w	a0,a0
    80001906:	60a2                	ld	ra,8(sp)
    80001908:	6402                	ld	s0,0(sp)
    8000190a:	0141                	addi	sp,sp,16
    8000190c:	8082                	ret

000000008000190e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    8000190e:	1141                	addi	sp,sp,-16
    80001910:	e406                	sd	ra,8(sp)
    80001912:	e022                	sd	s0,0(sp)
    80001914:	0800                	addi	s0,sp,16
    80001916:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001918:	2781                	sext.w	a5,a5
    8000191a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000191c:	0000e517          	auipc	a0,0xe
    80001920:	07c50513          	addi	a0,a0,124 # 8000f998 <cpus>
    80001924:	953e                	add	a0,a0,a5
    80001926:	60a2                	ld	ra,8(sp)
    80001928:	6402                	ld	s0,0(sp)
    8000192a:	0141                	addi	sp,sp,16
    8000192c:	8082                	ret

000000008000192e <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    8000192e:	1101                	addi	sp,sp,-32
    80001930:	ec06                	sd	ra,24(sp)
    80001932:	e822                	sd	s0,16(sp)
    80001934:	e426                	sd	s1,8(sp)
    80001936:	1000                	addi	s0,sp,32
  push_off();
    80001938:	aacff0ef          	jal	80000be4 <push_off>
    8000193c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    8000193e:	2781                	sext.w	a5,a5
    80001940:	079e                	slli	a5,a5,0x7
    80001942:	0000e717          	auipc	a4,0xe
    80001946:	02670713          	addi	a4,a4,38 # 8000f968 <pid_lock>
    8000194a:	97ba                	add	a5,a5,a4
    8000194c:	7b9c                	ld	a5,48(a5)
    8000194e:	84be                	mv	s1,a5
  pop_off();
    80001950:	b1cff0ef          	jal	80000c6c <pop_off>
  return p;
}
    80001954:	8526                	mv	a0,s1
    80001956:	60e2                	ld	ra,24(sp)
    80001958:	6442                	ld	s0,16(sp)
    8000195a:	64a2                	ld	s1,8(sp)
    8000195c:	6105                	addi	sp,sp,32
    8000195e:	8082                	ret

0000000080001960 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001960:	7179                	addi	sp,sp,-48
    80001962:	f406                	sd	ra,40(sp)
    80001964:	f022                	sd	s0,32(sp)
    80001966:	ec26                	sd	s1,24(sp)
    80001968:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    8000196a:	fc5ff0ef          	jal	8000192e <myproc>
    8000196e:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001970:	b4cff0ef          	jal	80000cbc <release>

  if (first) {
    80001974:	00006797          	auipc	a5,0x6
    80001978:	ebc7a783          	lw	a5,-324(a5) # 80007830 <first.1>
    8000197c:	cf95                	beqz	a5,800019b8 <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    8000197e:	4505                	li	a0,1
    80001980:	3ff010ef          	jal	8000357e <fsinit>

    first = 0;
    80001984:	00006797          	auipc	a5,0x6
    80001988:	ea07a623          	sw	zero,-340(a5) # 80007830 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    8000198c:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001990:	00005797          	auipc	a5,0x5
    80001994:	7f078793          	addi	a5,a5,2032 # 80007180 <etext+0x180>
    80001998:	fcf43823          	sd	a5,-48(s0)
    8000199c:	fc043c23          	sd	zero,-40(s0)
    800019a0:	fd040593          	addi	a1,s0,-48
    800019a4:	853e                	mv	a0,a5
    800019a6:	561020ef          	jal	80004706 <kexec>
    800019aa:	6cbc                	ld	a5,88(s1)
    800019ac:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019ae:	6cbc                	ld	a5,88(s1)
    800019b0:	7bb8                	ld	a4,112(a5)
    800019b2:	57fd                	li	a5,-1
    800019b4:	02f70d63          	beq	a4,a5,800019ee <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800019b8:	2c3000ef          	jal	8000247a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019bc:	68a8                	ld	a0,80(s1)
    800019be:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019c0:	04000737          	lui	a4,0x4000
    800019c4:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800019c6:	0732                	slli	a4,a4,0xc
    800019c8:	00004797          	auipc	a5,0x4
    800019cc:	6d478793          	addi	a5,a5,1748 # 8000609c <userret>
    800019d0:	00004697          	auipc	a3,0x4
    800019d4:	63068693          	addi	a3,a3,1584 # 80006000 <_trampoline>
    800019d8:	8f95                	sub	a5,a5,a3
    800019da:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019dc:	577d                	li	a4,-1
    800019de:	177e                	slli	a4,a4,0x3f
    800019e0:	8d59                	or	a0,a0,a4
    800019e2:	9782                	jalr	a5
}
    800019e4:	70a2                	ld	ra,40(sp)
    800019e6:	7402                	ld	s0,32(sp)
    800019e8:	64e2                	ld	s1,24(sp)
    800019ea:	6145                	addi	sp,sp,48
    800019ec:	8082                	ret
      panic("exec");
    800019ee:	00005517          	auipc	a0,0x5
    800019f2:	79a50513          	addi	a0,a0,1946 # 80007188 <etext+0x188>
    800019f6:	e2ffe0ef          	jal	80000824 <panic>

00000000800019fa <allocpid>:
{
    800019fa:	1101                	addi	sp,sp,-32
    800019fc:	ec06                	sd	ra,24(sp)
    800019fe:	e822                	sd	s0,16(sp)
    80001a00:	e426                	sd	s1,8(sp)
    80001a02:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a04:	0000e517          	auipc	a0,0xe
    80001a08:	f6450513          	addi	a0,a0,-156 # 8000f968 <pid_lock>
    80001a0c:	a1cff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a10:	00006797          	auipc	a5,0x6
    80001a14:	e2478793          	addi	a5,a5,-476 # 80007834 <nextpid>
    80001a18:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a1a:	0014871b          	addiw	a4,s1,1
    80001a1e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a20:	0000e517          	auipc	a0,0xe
    80001a24:	f4850513          	addi	a0,a0,-184 # 8000f968 <pid_lock>
    80001a28:	a94ff0ef          	jal	80000cbc <release>
}
    80001a2c:	8526                	mv	a0,s1
    80001a2e:	60e2                	ld	ra,24(sp)
    80001a30:	6442                	ld	s0,16(sp)
    80001a32:	64a2                	ld	s1,8(sp)
    80001a34:	6105                	addi	sp,sp,32
    80001a36:	8082                	ret

0000000080001a38 <proc_pagetable>:
{
    80001a38:	1101                	addi	sp,sp,-32
    80001a3a:	ec06                	sd	ra,24(sp)
    80001a3c:	e822                	sd	s0,16(sp)
    80001a3e:	e426                	sd	s1,8(sp)
    80001a40:	e04a                	sd	s2,0(sp)
    80001a42:	1000                	addi	s0,sp,32
    80001a44:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a46:	fc2ff0ef          	jal	80001208 <uvmcreate>
    80001a4a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a4c:	cd05                	beqz	a0,80001a84 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a4e:	4729                	li	a4,10
    80001a50:	00004697          	auipc	a3,0x4
    80001a54:	5b068693          	addi	a3,a3,1456 # 80006000 <_trampoline>
    80001a58:	6605                	lui	a2,0x1
    80001a5a:	040005b7          	lui	a1,0x4000
    80001a5e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a60:	05b2                	slli	a1,a1,0xc
    80001a62:	dfeff0ef          	jal	80001060 <mappages>
    80001a66:	02054663          	bltz	a0,80001a92 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a6a:	4719                	li	a4,6
    80001a6c:	05893683          	ld	a3,88(s2)
    80001a70:	6605                	lui	a2,0x1
    80001a72:	020005b7          	lui	a1,0x2000
    80001a76:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a78:	05b6                	slli	a1,a1,0xd
    80001a7a:	8526                	mv	a0,s1
    80001a7c:	de4ff0ef          	jal	80001060 <mappages>
    80001a80:	00054f63          	bltz	a0,80001a9e <proc_pagetable+0x66>
}
    80001a84:	8526                	mv	a0,s1
    80001a86:	60e2                	ld	ra,24(sp)
    80001a88:	6442                	ld	s0,16(sp)
    80001a8a:	64a2                	ld	s1,8(sp)
    80001a8c:	6902                	ld	s2,0(sp)
    80001a8e:	6105                	addi	sp,sp,32
    80001a90:	8082                	ret
    uvmfree(pagetable, 0);
    80001a92:	4581                	li	a1,0
    80001a94:	8526                	mv	a0,s1
    80001a96:	96dff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001a9a:	4481                	li	s1,0
    80001a9c:	b7e5                	j	80001a84 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a9e:	4681                	li	a3,0
    80001aa0:	4605                	li	a2,1
    80001aa2:	040005b7          	lui	a1,0x4000
    80001aa6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aa8:	05b2                	slli	a1,a1,0xc
    80001aaa:	8526                	mv	a0,s1
    80001aac:	f82ff0ef          	jal	8000122e <uvmunmap>
    uvmfree(pagetable, 0);
    80001ab0:	4581                	li	a1,0
    80001ab2:	8526                	mv	a0,s1
    80001ab4:	94fff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001ab8:	4481                	li	s1,0
    80001aba:	b7e9                	j	80001a84 <proc_pagetable+0x4c>

0000000080001abc <proc_freepagetable>:
{
    80001abc:	1101                	addi	sp,sp,-32
    80001abe:	ec06                	sd	ra,24(sp)
    80001ac0:	e822                	sd	s0,16(sp)
    80001ac2:	e426                	sd	s1,8(sp)
    80001ac4:	e04a                	sd	s2,0(sp)
    80001ac6:	1000                	addi	s0,sp,32
    80001ac8:	84aa                	mv	s1,a0
    80001aca:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001acc:	4681                	li	a3,0
    80001ace:	4605                	li	a2,1
    80001ad0:	040005b7          	lui	a1,0x4000
    80001ad4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ad6:	05b2                	slli	a1,a1,0xc
    80001ad8:	f56ff0ef          	jal	8000122e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001adc:	4681                	li	a3,0
    80001ade:	4605                	li	a2,1
    80001ae0:	020005b7          	lui	a1,0x2000
    80001ae4:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ae6:	05b6                	slli	a1,a1,0xd
    80001ae8:	8526                	mv	a0,s1
    80001aea:	f44ff0ef          	jal	8000122e <uvmunmap>
  uvmfree(pagetable, sz);
    80001aee:	85ca                	mv	a1,s2
    80001af0:	8526                	mv	a0,s1
    80001af2:	911ff0ef          	jal	80001402 <uvmfree>
}
    80001af6:	60e2                	ld	ra,24(sp)
    80001af8:	6442                	ld	s0,16(sp)
    80001afa:	64a2                	ld	s1,8(sp)
    80001afc:	6902                	ld	s2,0(sp)
    80001afe:	6105                	addi	sp,sp,32
    80001b00:	8082                	ret

0000000080001b02 <freeproc>:
{
    80001b02:	1101                	addi	sp,sp,-32
    80001b04:	ec06                	sd	ra,24(sp)
    80001b06:	e822                	sd	s0,16(sp)
    80001b08:	e426                	sd	s1,8(sp)
    80001b0a:	1000                	addi	s0,sp,32
    80001b0c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b0e:	6d28                	ld	a0,88(a0)
    80001b10:	c119                	beqz	a0,80001b16 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001b12:	f4bfe0ef          	jal	80000a5c <kfree>
  p->trapframe = 0;
    80001b16:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b1a:	68a8                	ld	a0,80(s1)
    80001b1c:	c501                	beqz	a0,80001b24 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b1e:	64ac                	ld	a1,72(s1)
    80001b20:	f9dff0ef          	jal	80001abc <proc_freepagetable>
  p->pagetable = 0;
    80001b24:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b28:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b2c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b30:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b34:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b38:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b3c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b40:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b44:	0004ac23          	sw	zero,24(s1)
}
    80001b48:	60e2                	ld	ra,24(sp)
    80001b4a:	6442                	ld	s0,16(sp)
    80001b4c:	64a2                	ld	s1,8(sp)
    80001b4e:	6105                	addi	sp,sp,32
    80001b50:	8082                	ret

0000000080001b52 <allocproc>:
{
    80001b52:	1101                	addi	sp,sp,-32
    80001b54:	ec06                	sd	ra,24(sp)
    80001b56:	e822                	sd	s0,16(sp)
    80001b58:	e426                	sd	s1,8(sp)
    80001b5a:	e04a                	sd	s2,0(sp)
    80001b5c:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b5e:	0000e497          	auipc	s1,0xe
    80001b62:	23a48493          	addi	s1,s1,570 # 8000fd98 <proc>
    80001b66:	00014917          	auipc	s2,0x14
    80001b6a:	e3290913          	addi	s2,s2,-462 # 80015998 <tickslock>
    acquire(&p->lock);
    80001b6e:	8526                	mv	a0,s1
    80001b70:	8b8ff0ef          	jal	80000c28 <acquire>
    if(p->state == UNUSED) {
    80001b74:	4c9c                	lw	a5,24(s1)
    80001b76:	cb91                	beqz	a5,80001b8a <allocproc+0x38>
      release(&p->lock);
    80001b78:	8526                	mv	a0,s1
    80001b7a:	942ff0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b7e:	17048493          	addi	s1,s1,368
    80001b82:	ff2496e3          	bne	s1,s2,80001b6e <allocproc+0x1c>
  return 0;
    80001b86:	4481                	li	s1,0
    80001b88:	a089                	j	80001bca <allocproc+0x78>
  p->pid = allocpid();
    80001b8a:	e71ff0ef          	jal	800019fa <allocpid>
    80001b8e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b90:	4785                	li	a5,1
    80001b92:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b94:	fb1fe0ef          	jal	80000b44 <kalloc>
    80001b98:	892a                	mv	s2,a0
    80001b9a:	eca8                	sd	a0,88(s1)
    80001b9c:	cd15                	beqz	a0,80001bd8 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b9e:	8526                	mv	a0,s1
    80001ba0:	e99ff0ef          	jal	80001a38 <proc_pagetable>
    80001ba4:	892a                	mv	s2,a0
    80001ba6:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001ba8:	c121                	beqz	a0,80001be8 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001baa:	07000613          	li	a2,112
    80001bae:	4581                	li	a1,0
    80001bb0:	06048513          	addi	a0,s1,96
    80001bb4:	944ff0ef          	jal	80000cf8 <memset>
  p->context.ra = (uint64)forkret;
    80001bb8:	00000797          	auipc	a5,0x0
    80001bbc:	da878793          	addi	a5,a5,-600 # 80001960 <forkret>
    80001bc0:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001bc2:	60bc                	ld	a5,64(s1)
    80001bc4:	6705                	lui	a4,0x1
    80001bc6:	97ba                	add	a5,a5,a4
    80001bc8:	f4bc                	sd	a5,104(s1)
}
    80001bca:	8526                	mv	a0,s1
    80001bcc:	60e2                	ld	ra,24(sp)
    80001bce:	6442                	ld	s0,16(sp)
    80001bd0:	64a2                	ld	s1,8(sp)
    80001bd2:	6902                	ld	s2,0(sp)
    80001bd4:	6105                	addi	sp,sp,32
    80001bd6:	8082                	ret
    freeproc(p);
    80001bd8:	8526                	mv	a0,s1
    80001bda:	f29ff0ef          	jal	80001b02 <freeproc>
    release(&p->lock);
    80001bde:	8526                	mv	a0,s1
    80001be0:	8dcff0ef          	jal	80000cbc <release>
    return 0;
    80001be4:	84ca                	mv	s1,s2
    80001be6:	b7d5                	j	80001bca <allocproc+0x78>
    freeproc(p);
    80001be8:	8526                	mv	a0,s1
    80001bea:	f19ff0ef          	jal	80001b02 <freeproc>
    release(&p->lock);
    80001bee:	8526                	mv	a0,s1
    80001bf0:	8ccff0ef          	jal	80000cbc <release>
    return 0;
    80001bf4:	84ca                	mv	s1,s2
    80001bf6:	bfd1                	j	80001bca <allocproc+0x78>

0000000080001bf8 <userinit>:
{
    80001bf8:	1101                	addi	sp,sp,-32
    80001bfa:	ec06                	sd	ra,24(sp)
    80001bfc:	e822                	sd	s0,16(sp)
    80001bfe:	e426                	sd	s1,8(sp)
    80001c00:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c02:	f51ff0ef          	jal	80001b52 <allocproc>
    80001c06:	84aa                	mv	s1,a0
  initproc = p;
    80001c08:	00006797          	auipc	a5,0x6
    80001c0c:	c4a7bc23          	sd	a0,-936(a5) # 80007860 <initproc>
  p->cwd = namei("/");
    80001c10:	00005517          	auipc	a0,0x5
    80001c14:	58050513          	addi	a0,a0,1408 # 80007190 <etext+0x190>
    80001c18:	6a1010ef          	jal	80003ab8 <namei>
    80001c1c:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c20:	478d                	li	a5,3
    80001c22:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c24:	8526                	mv	a0,s1
    80001c26:	896ff0ef          	jal	80000cbc <release>
}
    80001c2a:	60e2                	ld	ra,24(sp)
    80001c2c:	6442                	ld	s0,16(sp)
    80001c2e:	64a2                	ld	s1,8(sp)
    80001c30:	6105                	addi	sp,sp,32
    80001c32:	8082                	ret

0000000080001c34 <growproc>:
{
    80001c34:	1101                	addi	sp,sp,-32
    80001c36:	ec06                	sd	ra,24(sp)
    80001c38:	e822                	sd	s0,16(sp)
    80001c3a:	e426                	sd	s1,8(sp)
    80001c3c:	e04a                	sd	s2,0(sp)
    80001c3e:	1000                	addi	s0,sp,32
    80001c40:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c42:	cedff0ef          	jal	8000192e <myproc>
    80001c46:	892a                	mv	s2,a0
  sz = p->sz;
    80001c48:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001c4a:	02905963          	blez	s1,80001c7c <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001c4e:	00b48633          	add	a2,s1,a1
    80001c52:	020007b7          	lui	a5,0x2000
    80001c56:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c58:	07b6                	slli	a5,a5,0xd
    80001c5a:	02c7ea63          	bltu	a5,a2,80001c8e <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c5e:	4691                	li	a3,4
    80001c60:	6928                	ld	a0,80(a0)
    80001c62:	e9aff0ef          	jal	800012fc <uvmalloc>
    80001c66:	85aa                	mv	a1,a0
    80001c68:	c50d                	beqz	a0,80001c92 <growproc+0x5e>
  p->sz = sz;
    80001c6a:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c6e:	4501                	li	a0,0
}
    80001c70:	60e2                	ld	ra,24(sp)
    80001c72:	6442                	ld	s0,16(sp)
    80001c74:	64a2                	ld	s1,8(sp)
    80001c76:	6902                	ld	s2,0(sp)
    80001c78:	6105                	addi	sp,sp,32
    80001c7a:	8082                	ret
  } else if(n < 0){
    80001c7c:	fe04d7e3          	bgez	s1,80001c6a <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c80:	00b48633          	add	a2,s1,a1
    80001c84:	6928                	ld	a0,80(a0)
    80001c86:	e32ff0ef          	jal	800012b8 <uvmdealloc>
    80001c8a:	85aa                	mv	a1,a0
    80001c8c:	bff9                	j	80001c6a <growproc+0x36>
      return -1;
    80001c8e:	557d                	li	a0,-1
    80001c90:	b7c5                	j	80001c70 <growproc+0x3c>
      return -1;
    80001c92:	557d                	li	a0,-1
    80001c94:	bff1                	j	80001c70 <growproc+0x3c>

0000000080001c96 <kfork>:
{
    80001c96:	7139                	addi	sp,sp,-64
    80001c98:	fc06                	sd	ra,56(sp)
    80001c9a:	f822                	sd	s0,48(sp)
    80001c9c:	f426                	sd	s1,40(sp)
    80001c9e:	e456                	sd	s5,8(sp)
    80001ca0:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001ca2:	c8dff0ef          	jal	8000192e <myproc>
    80001ca6:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001ca8:	eabff0ef          	jal	80001b52 <allocproc>
    80001cac:	0e050a63          	beqz	a0,80001da0 <kfork+0x10a>
    80001cb0:	e852                	sd	s4,16(sp)
    80001cb2:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001cb4:	048ab603          	ld	a2,72(s5)
    80001cb8:	692c                	ld	a1,80(a0)
    80001cba:	050ab503          	ld	a0,80(s5)
    80001cbe:	f76ff0ef          	jal	80001434 <uvmcopy>
    80001cc2:	04054863          	bltz	a0,80001d12 <kfork+0x7c>
    80001cc6:	f04a                	sd	s2,32(sp)
    80001cc8:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001cca:	048ab783          	ld	a5,72(s5)
    80001cce:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001cd2:	058ab683          	ld	a3,88(s5)
    80001cd6:	87b6                	mv	a5,a3
    80001cd8:	058a3703          	ld	a4,88(s4)
    80001cdc:	12068693          	addi	a3,a3,288
    80001ce0:	6388                	ld	a0,0(a5)
    80001ce2:	678c                	ld	a1,8(a5)
    80001ce4:	6b90                	ld	a2,16(a5)
    80001ce6:	e308                	sd	a0,0(a4)
    80001ce8:	e70c                	sd	a1,8(a4)
    80001cea:	eb10                	sd	a2,16(a4)
    80001cec:	6f90                	ld	a2,24(a5)
    80001cee:	ef10                	sd	a2,24(a4)
    80001cf0:	02078793          	addi	a5,a5,32
    80001cf4:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001cf8:	fed794e3          	bne	a5,a3,80001ce0 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001cfc:	058a3783          	ld	a5,88(s4)
    80001d00:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001d04:	0d0a8493          	addi	s1,s5,208
    80001d08:	0d0a0913          	addi	s2,s4,208
    80001d0c:	150a8993          	addi	s3,s5,336
    80001d10:	a831                	j	80001d2c <kfork+0x96>
    freeproc(np);
    80001d12:	8552                	mv	a0,s4
    80001d14:	defff0ef          	jal	80001b02 <freeproc>
    release(&np->lock);
    80001d18:	8552                	mv	a0,s4
    80001d1a:	fa3fe0ef          	jal	80000cbc <release>
    return -1;
    80001d1e:	54fd                	li	s1,-1
    80001d20:	6a42                	ld	s4,16(sp)
    80001d22:	a885                	j	80001d92 <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001d24:	04a1                	addi	s1,s1,8
    80001d26:	0921                	addi	s2,s2,8
    80001d28:	01348963          	beq	s1,s3,80001d3a <kfork+0xa4>
    if(p->ofile[i])
    80001d2c:	6088                	ld	a0,0(s1)
    80001d2e:	d97d                	beqz	a0,80001d24 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d30:	344020ef          	jal	80004074 <filedup>
    80001d34:	00a93023          	sd	a0,0(s2)
    80001d38:	b7f5                	j	80001d24 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d3a:	150ab503          	ld	a0,336(s5)
    80001d3e:	516010ef          	jal	80003254 <idup>
    80001d42:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d46:	4641                	li	a2,16
    80001d48:	158a8593          	addi	a1,s5,344
    80001d4c:	158a0513          	addi	a0,s4,344
    80001d50:	8fcff0ef          	jal	80000e4c <safestrcpy>
  pid = np->pid;
    80001d54:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d58:	8552                	mv	a0,s4
    80001d5a:	f63fe0ef          	jal	80000cbc <release>
  acquire(&wait_lock);
    80001d5e:	0000e517          	auipc	a0,0xe
    80001d62:	c2250513          	addi	a0,a0,-990 # 8000f980 <wait_lock>
    80001d66:	ec3fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001d6a:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d6e:	0000e517          	auipc	a0,0xe
    80001d72:	c1250513          	addi	a0,a0,-1006 # 8000f980 <wait_lock>
    80001d76:	f47fe0ef          	jal	80000cbc <release>
  acquire(&np->lock);
    80001d7a:	8552                	mv	a0,s4
    80001d7c:	eadfe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001d80:	478d                	li	a5,3
    80001d82:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d86:	8552                	mv	a0,s4
    80001d88:	f35fe0ef          	jal	80000cbc <release>
  return pid;
    80001d8c:	7902                	ld	s2,32(sp)
    80001d8e:	69e2                	ld	s3,24(sp)
    80001d90:	6a42                	ld	s4,16(sp)
}
    80001d92:	8526                	mv	a0,s1
    80001d94:	70e2                	ld	ra,56(sp)
    80001d96:	7442                	ld	s0,48(sp)
    80001d98:	74a2                	ld	s1,40(sp)
    80001d9a:	6aa2                	ld	s5,8(sp)
    80001d9c:	6121                	addi	sp,sp,64
    80001d9e:	8082                	ret
    return -1;
    80001da0:	54fd                	li	s1,-1
    80001da2:	bfc5                	j	80001d92 <kfork+0xfc>

0000000080001da4 <scheduler>:
{
    80001da4:	715d                	addi	sp,sp,-80
    80001da6:	e486                	sd	ra,72(sp)
    80001da8:	e0a2                	sd	s0,64(sp)
    80001daa:	fc26                	sd	s1,56(sp)
    80001dac:	f84a                	sd	s2,48(sp)
    80001dae:	f44e                	sd	s3,40(sp)
    80001db0:	f052                	sd	s4,32(sp)
    80001db2:	ec56                	sd	s5,24(sp)
    80001db4:	e85a                	sd	s6,16(sp)
    80001db6:	e45e                	sd	s7,8(sp)
    80001db8:	e062                	sd	s8,0(sp)
    80001dba:	0880                	addi	s0,sp,80
    80001dbc:	8792                	mv	a5,tp
  int id = r_tp();
    80001dbe:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001dc0:	00779b13          	slli	s6,a5,0x7
    80001dc4:	0000e717          	auipc	a4,0xe
    80001dc8:	ba470713          	addi	a4,a4,-1116 # 8000f968 <pid_lock>
    80001dcc:	975a                	add	a4,a4,s6
    80001dce:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001dd2:	0000e717          	auipc	a4,0xe
    80001dd6:	bce70713          	addi	a4,a4,-1074 # 8000f9a0 <cpus+0x8>
    80001dda:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001ddc:	4c11                	li	s8,4
        c->proc = p;
    80001dde:	079e                	slli	a5,a5,0x7
    80001de0:	0000ea17          	auipc	s4,0xe
    80001de4:	b88a0a13          	addi	s4,s4,-1144 # 8000f968 <pid_lock>
    80001de8:	9a3e                	add	s4,s4,a5
        found = 1;
    80001dea:	4b85                	li	s7,1
    80001dec:	a83d                	j	80001e2a <scheduler+0x86>
      release(&p->lock);
    80001dee:	8526                	mv	a0,s1
    80001df0:	ecdfe0ef          	jal	80000cbc <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001df4:	17048493          	addi	s1,s1,368
    80001df8:	03248563          	beq	s1,s2,80001e22 <scheduler+0x7e>
      acquire(&p->lock);
    80001dfc:	8526                	mv	a0,s1
    80001dfe:	e2bfe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE) {
    80001e02:	4c9c                	lw	a5,24(s1)
    80001e04:	ff3795e3          	bne	a5,s3,80001dee <scheduler+0x4a>
        p->state = RUNNING;
    80001e08:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001e0c:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001e10:	06048593          	addi	a1,s1,96
    80001e14:	855a                	mv	a0,s6
    80001e16:	5ba000ef          	jal	800023d0 <swtch>
        c->proc = 0;
    80001e1a:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001e1e:	8ade                	mv	s5,s7
    80001e20:	b7f9                	j	80001dee <scheduler+0x4a>
    if(found == 0) {
    80001e22:	000a9463          	bnez	s5,80001e2a <scheduler+0x86>
      asm volatile("wfi");
    80001e26:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e2a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e2e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e32:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e36:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001e3a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e3c:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001e40:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e42:	0000e497          	auipc	s1,0xe
    80001e46:	f5648493          	addi	s1,s1,-170 # 8000fd98 <proc>
      if(p->state == RUNNABLE) {
    80001e4a:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e4c:	00014917          	auipc	s2,0x14
    80001e50:	b4c90913          	addi	s2,s2,-1204 # 80015998 <tickslock>
    80001e54:	b765                	j	80001dfc <scheduler+0x58>

0000000080001e56 <sched>:
{
    80001e56:	7179                	addi	sp,sp,-48
    80001e58:	f406                	sd	ra,40(sp)
    80001e5a:	f022                	sd	s0,32(sp)
    80001e5c:	ec26                	sd	s1,24(sp)
    80001e5e:	e84a                	sd	s2,16(sp)
    80001e60:	e44e                	sd	s3,8(sp)
    80001e62:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e64:	acbff0ef          	jal	8000192e <myproc>
    80001e68:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e6a:	d4ffe0ef          	jal	80000bb8 <holding>
    80001e6e:	c935                	beqz	a0,80001ee2 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e70:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e72:	2781                	sext.w	a5,a5
    80001e74:	079e                	slli	a5,a5,0x7
    80001e76:	0000e717          	auipc	a4,0xe
    80001e7a:	af270713          	addi	a4,a4,-1294 # 8000f968 <pid_lock>
    80001e7e:	97ba                	add	a5,a5,a4
    80001e80:	0a87a703          	lw	a4,168(a5)
    80001e84:	4785                	li	a5,1
    80001e86:	06f71463          	bne	a4,a5,80001eee <sched+0x98>
  if(p->state == RUNNING)
    80001e8a:	4c98                	lw	a4,24(s1)
    80001e8c:	4791                	li	a5,4
    80001e8e:	06f70663          	beq	a4,a5,80001efa <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e92:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e96:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e98:	e7bd                	bnez	a5,80001f06 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e9a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e9c:	0000e917          	auipc	s2,0xe
    80001ea0:	acc90913          	addi	s2,s2,-1332 # 8000f968 <pid_lock>
    80001ea4:	2781                	sext.w	a5,a5
    80001ea6:	079e                	slli	a5,a5,0x7
    80001ea8:	97ca                	add	a5,a5,s2
    80001eaa:	0ac7a983          	lw	s3,172(a5)
    80001eae:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001eb0:	2781                	sext.w	a5,a5
    80001eb2:	079e                	slli	a5,a5,0x7
    80001eb4:	07a1                	addi	a5,a5,8
    80001eb6:	0000e597          	auipc	a1,0xe
    80001eba:	ae258593          	addi	a1,a1,-1310 # 8000f998 <cpus>
    80001ebe:	95be                	add	a1,a1,a5
    80001ec0:	06048513          	addi	a0,s1,96
    80001ec4:	50c000ef          	jal	800023d0 <swtch>
    80001ec8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001eca:	2781                	sext.w	a5,a5
    80001ecc:	079e                	slli	a5,a5,0x7
    80001ece:	993e                	add	s2,s2,a5
    80001ed0:	0b392623          	sw	s3,172(s2)
}
    80001ed4:	70a2                	ld	ra,40(sp)
    80001ed6:	7402                	ld	s0,32(sp)
    80001ed8:	64e2                	ld	s1,24(sp)
    80001eda:	6942                	ld	s2,16(sp)
    80001edc:	69a2                	ld	s3,8(sp)
    80001ede:	6145                	addi	sp,sp,48
    80001ee0:	8082                	ret
    panic("sched p->lock");
    80001ee2:	00005517          	auipc	a0,0x5
    80001ee6:	2b650513          	addi	a0,a0,694 # 80007198 <etext+0x198>
    80001eea:	93bfe0ef          	jal	80000824 <panic>
    panic("sched locks");
    80001eee:	00005517          	auipc	a0,0x5
    80001ef2:	2ba50513          	addi	a0,a0,698 # 800071a8 <etext+0x1a8>
    80001ef6:	92ffe0ef          	jal	80000824 <panic>
    panic("sched RUNNING");
    80001efa:	00005517          	auipc	a0,0x5
    80001efe:	2be50513          	addi	a0,a0,702 # 800071b8 <etext+0x1b8>
    80001f02:	923fe0ef          	jal	80000824 <panic>
    panic("sched interruptible");
    80001f06:	00005517          	auipc	a0,0x5
    80001f0a:	2c250513          	addi	a0,a0,706 # 800071c8 <etext+0x1c8>
    80001f0e:	917fe0ef          	jal	80000824 <panic>

0000000080001f12 <yield>:
{
    80001f12:	1101                	addi	sp,sp,-32
    80001f14:	ec06                	sd	ra,24(sp)
    80001f16:	e822                	sd	s0,16(sp)
    80001f18:	e426                	sd	s1,8(sp)
    80001f1a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f1c:	a13ff0ef          	jal	8000192e <myproc>
    80001f20:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f22:	d07fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80001f26:	478d                	li	a5,3
    80001f28:	cc9c                	sw	a5,24(s1)
  sched();
    80001f2a:	f2dff0ef          	jal	80001e56 <sched>
  release(&p->lock);
    80001f2e:	8526                	mv	a0,s1
    80001f30:	d8dfe0ef          	jal	80000cbc <release>
}
    80001f34:	60e2                	ld	ra,24(sp)
    80001f36:	6442                	ld	s0,16(sp)
    80001f38:	64a2                	ld	s1,8(sp)
    80001f3a:	6105                	addi	sp,sp,32
    80001f3c:	8082                	ret

0000000080001f3e <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001f3e:	7179                	addi	sp,sp,-48
    80001f40:	f406                	sd	ra,40(sp)
    80001f42:	f022                	sd	s0,32(sp)
    80001f44:	ec26                	sd	s1,24(sp)
    80001f46:	e84a                	sd	s2,16(sp)
    80001f48:	e44e                	sd	s3,8(sp)
    80001f4a:	1800                	addi	s0,sp,48
    80001f4c:	89aa                	mv	s3,a0
    80001f4e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f50:	9dfff0ef          	jal	8000192e <myproc>
    80001f54:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001f56:	cd3fe0ef          	jal	80000c28 <acquire>
  release(lk);
    80001f5a:	854a                	mv	a0,s2
    80001f5c:	d61fe0ef          	jal	80000cbc <release>

  // Go to sleep.
  p->chan = chan;
    80001f60:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f64:	4789                	li	a5,2
    80001f66:	cc9c                	sw	a5,24(s1)

  sched();
    80001f68:	eefff0ef          	jal	80001e56 <sched>

  // Tidy up.
  p->chan = 0;
    80001f6c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f70:	8526                	mv	a0,s1
    80001f72:	d4bfe0ef          	jal	80000cbc <release>
  acquire(lk);
    80001f76:	854a                	mv	a0,s2
    80001f78:	cb1fe0ef          	jal	80000c28 <acquire>
}
    80001f7c:	70a2                	ld	ra,40(sp)
    80001f7e:	7402                	ld	s0,32(sp)
    80001f80:	64e2                	ld	s1,24(sp)
    80001f82:	6942                	ld	s2,16(sp)
    80001f84:	69a2                	ld	s3,8(sp)
    80001f86:	6145                	addi	sp,sp,48
    80001f88:	8082                	ret

0000000080001f8a <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001f8a:	7139                	addi	sp,sp,-64
    80001f8c:	fc06                	sd	ra,56(sp)
    80001f8e:	f822                	sd	s0,48(sp)
    80001f90:	f426                	sd	s1,40(sp)
    80001f92:	f04a                	sd	s2,32(sp)
    80001f94:	ec4e                	sd	s3,24(sp)
    80001f96:	e852                	sd	s4,16(sp)
    80001f98:	e456                	sd	s5,8(sp)
    80001f9a:	0080                	addi	s0,sp,64
    80001f9c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f9e:	0000e497          	auipc	s1,0xe
    80001fa2:	dfa48493          	addi	s1,s1,-518 # 8000fd98 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001fa6:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001fa8:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001faa:	00014917          	auipc	s2,0x14
    80001fae:	9ee90913          	addi	s2,s2,-1554 # 80015998 <tickslock>
    80001fb2:	a801                	j	80001fc2 <wakeup+0x38>
      }
      release(&p->lock);
    80001fb4:	8526                	mv	a0,s1
    80001fb6:	d07fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fba:	17048493          	addi	s1,s1,368
    80001fbe:	03248263          	beq	s1,s2,80001fe2 <wakeup+0x58>
    if(p != myproc()){
    80001fc2:	96dff0ef          	jal	8000192e <myproc>
    80001fc6:	fe950ae3          	beq	a0,s1,80001fba <wakeup+0x30>
      acquire(&p->lock);
    80001fca:	8526                	mv	a0,s1
    80001fcc:	c5dfe0ef          	jal	80000c28 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001fd0:	4c9c                	lw	a5,24(s1)
    80001fd2:	ff3791e3          	bne	a5,s3,80001fb4 <wakeup+0x2a>
    80001fd6:	709c                	ld	a5,32(s1)
    80001fd8:	fd479ee3          	bne	a5,s4,80001fb4 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001fdc:	0154ac23          	sw	s5,24(s1)
    80001fe0:	bfd1                	j	80001fb4 <wakeup+0x2a>
    }
  }
}
    80001fe2:	70e2                	ld	ra,56(sp)
    80001fe4:	7442                	ld	s0,48(sp)
    80001fe6:	74a2                	ld	s1,40(sp)
    80001fe8:	7902                	ld	s2,32(sp)
    80001fea:	69e2                	ld	s3,24(sp)
    80001fec:	6a42                	ld	s4,16(sp)
    80001fee:	6aa2                	ld	s5,8(sp)
    80001ff0:	6121                	addi	sp,sp,64
    80001ff2:	8082                	ret

0000000080001ff4 <reparent>:
{
    80001ff4:	7179                	addi	sp,sp,-48
    80001ff6:	f406                	sd	ra,40(sp)
    80001ff8:	f022                	sd	s0,32(sp)
    80001ffa:	ec26                	sd	s1,24(sp)
    80001ffc:	e84a                	sd	s2,16(sp)
    80001ffe:	e44e                	sd	s3,8(sp)
    80002000:	e052                	sd	s4,0(sp)
    80002002:	1800                	addi	s0,sp,48
    80002004:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002006:	0000e497          	auipc	s1,0xe
    8000200a:	d9248493          	addi	s1,s1,-622 # 8000fd98 <proc>
      pp->parent = initproc;
    8000200e:	00006a17          	auipc	s4,0x6
    80002012:	852a0a13          	addi	s4,s4,-1966 # 80007860 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002016:	00014997          	auipc	s3,0x14
    8000201a:	98298993          	addi	s3,s3,-1662 # 80015998 <tickslock>
    8000201e:	a029                	j	80002028 <reparent+0x34>
    80002020:	17048493          	addi	s1,s1,368
    80002024:	01348b63          	beq	s1,s3,8000203a <reparent+0x46>
    if(pp->parent == p){
    80002028:	7c9c                	ld	a5,56(s1)
    8000202a:	ff279be3          	bne	a5,s2,80002020 <reparent+0x2c>
      pp->parent = initproc;
    8000202e:	000a3503          	ld	a0,0(s4)
    80002032:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002034:	f57ff0ef          	jal	80001f8a <wakeup>
    80002038:	b7e5                	j	80002020 <reparent+0x2c>
}
    8000203a:	70a2                	ld	ra,40(sp)
    8000203c:	7402                	ld	s0,32(sp)
    8000203e:	64e2                	ld	s1,24(sp)
    80002040:	6942                	ld	s2,16(sp)
    80002042:	69a2                	ld	s3,8(sp)
    80002044:	6a02                	ld	s4,0(sp)
    80002046:	6145                	addi	sp,sp,48
    80002048:	8082                	ret

000000008000204a <kexit>:
{
    8000204a:	7179                	addi	sp,sp,-48
    8000204c:	f406                	sd	ra,40(sp)
    8000204e:	f022                	sd	s0,32(sp)
    80002050:	ec26                	sd	s1,24(sp)
    80002052:	e84a                	sd	s2,16(sp)
    80002054:	e44e                	sd	s3,8(sp)
    80002056:	e052                	sd	s4,0(sp)
    80002058:	1800                	addi	s0,sp,48
    8000205a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000205c:	8d3ff0ef          	jal	8000192e <myproc>
    80002060:	89aa                	mv	s3,a0
  if(p == initproc)
    80002062:	00005797          	auipc	a5,0x5
    80002066:	7fe7b783          	ld	a5,2046(a5) # 80007860 <initproc>
    8000206a:	0d050493          	addi	s1,a0,208
    8000206e:	15050913          	addi	s2,a0,336
    80002072:	00a79b63          	bne	a5,a0,80002088 <kexit+0x3e>
    panic("init exiting");
    80002076:	00005517          	auipc	a0,0x5
    8000207a:	16a50513          	addi	a0,a0,362 # 800071e0 <etext+0x1e0>
    8000207e:	fa6fe0ef          	jal	80000824 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    80002082:	04a1                	addi	s1,s1,8
    80002084:	01248963          	beq	s1,s2,80002096 <kexit+0x4c>
    if(p->ofile[fd]){
    80002088:	6088                	ld	a0,0(s1)
    8000208a:	dd65                	beqz	a0,80002082 <kexit+0x38>
      fileclose(f);
    8000208c:	02e020ef          	jal	800040ba <fileclose>
      p->ofile[fd] = 0;
    80002090:	0004b023          	sd	zero,0(s1)
    80002094:	b7fd                	j	80002082 <kexit+0x38>
  begin_op();
    80002096:	401010ef          	jal	80003c96 <begin_op>
  iput(p->cwd);
    8000209a:	1509b503          	ld	a0,336(s3)
    8000209e:	36e010ef          	jal	8000340c <iput>
  end_op();
    800020a2:	465010ef          	jal	80003d06 <end_op>
  p->cwd = 0;
    800020a6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800020aa:	0000e517          	auipc	a0,0xe
    800020ae:	8d650513          	addi	a0,a0,-1834 # 8000f980 <wait_lock>
    800020b2:	b77fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    800020b6:	854e                	mv	a0,s3
    800020b8:	f3dff0ef          	jal	80001ff4 <reparent>
  wakeup(p->parent);
    800020bc:	0389b503          	ld	a0,56(s3)
    800020c0:	ecbff0ef          	jal	80001f8a <wakeup>
  acquire(&p->lock);
    800020c4:	854e                	mv	a0,s3
    800020c6:	b63fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    800020ca:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800020ce:	4795                	li	a5,5
    800020d0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800020d4:	0000e517          	auipc	a0,0xe
    800020d8:	8ac50513          	addi	a0,a0,-1876 # 8000f980 <wait_lock>
    800020dc:	be1fe0ef          	jal	80000cbc <release>
  sched();
    800020e0:	d77ff0ef          	jal	80001e56 <sched>
  panic("zombie exit");
    800020e4:	00005517          	auipc	a0,0x5
    800020e8:	10c50513          	addi	a0,a0,268 # 800071f0 <etext+0x1f0>
    800020ec:	f38fe0ef          	jal	80000824 <panic>

00000000800020f0 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800020f0:	7179                	addi	sp,sp,-48
    800020f2:	f406                	sd	ra,40(sp)
    800020f4:	f022                	sd	s0,32(sp)
    800020f6:	ec26                	sd	s1,24(sp)
    800020f8:	e84a                	sd	s2,16(sp)
    800020fa:	e44e                	sd	s3,8(sp)
    800020fc:	1800                	addi	s0,sp,48
    800020fe:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002100:	0000e497          	auipc	s1,0xe
    80002104:	c9848493          	addi	s1,s1,-872 # 8000fd98 <proc>
    80002108:	00014997          	auipc	s3,0x14
    8000210c:	89098993          	addi	s3,s3,-1904 # 80015998 <tickslock>
    acquire(&p->lock);
    80002110:	8526                	mv	a0,s1
    80002112:	b17fe0ef          	jal	80000c28 <acquire>
    if(p->pid == pid){
    80002116:	589c                	lw	a5,48(s1)
    80002118:	01278b63          	beq	a5,s2,8000212e <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000211c:	8526                	mv	a0,s1
    8000211e:	b9ffe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002122:	17048493          	addi	s1,s1,368
    80002126:	ff3495e3          	bne	s1,s3,80002110 <kkill+0x20>
  }
  return -1;
    8000212a:	557d                	li	a0,-1
    8000212c:	a819                	j	80002142 <kkill+0x52>
      p->killed = 1;
    8000212e:	4785                	li	a5,1
    80002130:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002132:	4c98                	lw	a4,24(s1)
    80002134:	4789                	li	a5,2
    80002136:	00f70d63          	beq	a4,a5,80002150 <kkill+0x60>
      release(&p->lock);
    8000213a:	8526                	mv	a0,s1
    8000213c:	b81fe0ef          	jal	80000cbc <release>
      return 0;
    80002140:	4501                	li	a0,0
}
    80002142:	70a2                	ld	ra,40(sp)
    80002144:	7402                	ld	s0,32(sp)
    80002146:	64e2                	ld	s1,24(sp)
    80002148:	6942                	ld	s2,16(sp)
    8000214a:	69a2                	ld	s3,8(sp)
    8000214c:	6145                	addi	sp,sp,48
    8000214e:	8082                	ret
        p->state = RUNNABLE;
    80002150:	478d                	li	a5,3
    80002152:	cc9c                	sw	a5,24(s1)
    80002154:	b7dd                	j	8000213a <kkill+0x4a>

0000000080002156 <setkilled>:

void
setkilled(struct proc *p)
{
    80002156:	1101                	addi	sp,sp,-32
    80002158:	ec06                	sd	ra,24(sp)
    8000215a:	e822                	sd	s0,16(sp)
    8000215c:	e426                	sd	s1,8(sp)
    8000215e:	1000                	addi	s0,sp,32
    80002160:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002162:	ac7fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    80002166:	4785                	li	a5,1
    80002168:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000216a:	8526                	mv	a0,s1
    8000216c:	b51fe0ef          	jal	80000cbc <release>
}
    80002170:	60e2                	ld	ra,24(sp)
    80002172:	6442                	ld	s0,16(sp)
    80002174:	64a2                	ld	s1,8(sp)
    80002176:	6105                	addi	sp,sp,32
    80002178:	8082                	ret

000000008000217a <killed>:

int
killed(struct proc *p)
{
    8000217a:	1101                	addi	sp,sp,-32
    8000217c:	ec06                	sd	ra,24(sp)
    8000217e:	e822                	sd	s0,16(sp)
    80002180:	e426                	sd	s1,8(sp)
    80002182:	e04a                	sd	s2,0(sp)
    80002184:	1000                	addi	s0,sp,32
    80002186:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002188:	aa1fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    8000218c:	549c                	lw	a5,40(s1)
    8000218e:	893e                	mv	s2,a5
  release(&p->lock);
    80002190:	8526                	mv	a0,s1
    80002192:	b2bfe0ef          	jal	80000cbc <release>
  return k;
}
    80002196:	854a                	mv	a0,s2
    80002198:	60e2                	ld	ra,24(sp)
    8000219a:	6442                	ld	s0,16(sp)
    8000219c:	64a2                	ld	s1,8(sp)
    8000219e:	6902                	ld	s2,0(sp)
    800021a0:	6105                	addi	sp,sp,32
    800021a2:	8082                	ret

00000000800021a4 <kwait>:
{
    800021a4:	715d                	addi	sp,sp,-80
    800021a6:	e486                	sd	ra,72(sp)
    800021a8:	e0a2                	sd	s0,64(sp)
    800021aa:	fc26                	sd	s1,56(sp)
    800021ac:	f84a                	sd	s2,48(sp)
    800021ae:	f44e                	sd	s3,40(sp)
    800021b0:	f052                	sd	s4,32(sp)
    800021b2:	ec56                	sd	s5,24(sp)
    800021b4:	e85a                	sd	s6,16(sp)
    800021b6:	e45e                	sd	s7,8(sp)
    800021b8:	0880                	addi	s0,sp,80
    800021ba:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800021bc:	f72ff0ef          	jal	8000192e <myproc>
    800021c0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800021c2:	0000d517          	auipc	a0,0xd
    800021c6:	7be50513          	addi	a0,a0,1982 # 8000f980 <wait_lock>
    800021ca:	a5ffe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    800021ce:	4a15                	li	s4,5
        havekids = 1;
    800021d0:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021d2:	00013997          	auipc	s3,0x13
    800021d6:	7c698993          	addi	s3,s3,1990 # 80015998 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021da:	0000db17          	auipc	s6,0xd
    800021de:	7a6b0b13          	addi	s6,s6,1958 # 8000f980 <wait_lock>
    800021e2:	a869                	j	8000227c <kwait+0xd8>
          pid = pp->pid;
    800021e4:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800021e8:	000b8c63          	beqz	s7,80002200 <kwait+0x5c>
    800021ec:	4691                	li	a3,4
    800021ee:	02c48613          	addi	a2,s1,44
    800021f2:	85de                	mv	a1,s7
    800021f4:	05093503          	ld	a0,80(s2)
    800021f8:	c5cff0ef          	jal	80001654 <copyout>
    800021fc:	02054a63          	bltz	a0,80002230 <kwait+0x8c>
          freeproc(pp);
    80002200:	8526                	mv	a0,s1
    80002202:	901ff0ef          	jal	80001b02 <freeproc>
          release(&pp->lock);
    80002206:	8526                	mv	a0,s1
    80002208:	ab5fe0ef          	jal	80000cbc <release>
          release(&wait_lock);
    8000220c:	0000d517          	auipc	a0,0xd
    80002210:	77450513          	addi	a0,a0,1908 # 8000f980 <wait_lock>
    80002214:	aa9fe0ef          	jal	80000cbc <release>
}
    80002218:	854e                	mv	a0,s3
    8000221a:	60a6                	ld	ra,72(sp)
    8000221c:	6406                	ld	s0,64(sp)
    8000221e:	74e2                	ld	s1,56(sp)
    80002220:	7942                	ld	s2,48(sp)
    80002222:	79a2                	ld	s3,40(sp)
    80002224:	7a02                	ld	s4,32(sp)
    80002226:	6ae2                	ld	s5,24(sp)
    80002228:	6b42                	ld	s6,16(sp)
    8000222a:	6ba2                	ld	s7,8(sp)
    8000222c:	6161                	addi	sp,sp,80
    8000222e:	8082                	ret
            release(&pp->lock);
    80002230:	8526                	mv	a0,s1
    80002232:	a8bfe0ef          	jal	80000cbc <release>
            release(&wait_lock);
    80002236:	0000d517          	auipc	a0,0xd
    8000223a:	74a50513          	addi	a0,a0,1866 # 8000f980 <wait_lock>
    8000223e:	a7ffe0ef          	jal	80000cbc <release>
            return -1;
    80002242:	59fd                	li	s3,-1
    80002244:	bfd1                	j	80002218 <kwait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002246:	17048493          	addi	s1,s1,368
    8000224a:	03348063          	beq	s1,s3,8000226a <kwait+0xc6>
      if(pp->parent == p){
    8000224e:	7c9c                	ld	a5,56(s1)
    80002250:	ff279be3          	bne	a5,s2,80002246 <kwait+0xa2>
        acquire(&pp->lock);
    80002254:	8526                	mv	a0,s1
    80002256:	9d3fe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    8000225a:	4c9c                	lw	a5,24(s1)
    8000225c:	f94784e3          	beq	a5,s4,800021e4 <kwait+0x40>
        release(&pp->lock);
    80002260:	8526                	mv	a0,s1
    80002262:	a5bfe0ef          	jal	80000cbc <release>
        havekids = 1;
    80002266:	8756                	mv	a4,s5
    80002268:	bff9                	j	80002246 <kwait+0xa2>
    if(!havekids || killed(p)){
    8000226a:	cf19                	beqz	a4,80002288 <kwait+0xe4>
    8000226c:	854a                	mv	a0,s2
    8000226e:	f0dff0ef          	jal	8000217a <killed>
    80002272:	e919                	bnez	a0,80002288 <kwait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002274:	85da                	mv	a1,s6
    80002276:	854a                	mv	a0,s2
    80002278:	cc7ff0ef          	jal	80001f3e <sleep>
    havekids = 0;
    8000227c:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000227e:	0000e497          	auipc	s1,0xe
    80002282:	b1a48493          	addi	s1,s1,-1254 # 8000fd98 <proc>
    80002286:	b7e1                	j	8000224e <kwait+0xaa>
      release(&wait_lock);
    80002288:	0000d517          	auipc	a0,0xd
    8000228c:	6f850513          	addi	a0,a0,1784 # 8000f980 <wait_lock>
    80002290:	a2dfe0ef          	jal	80000cbc <release>
      return -1;
    80002294:	59fd                	li	s3,-1
    80002296:	b749                	j	80002218 <kwait+0x74>

0000000080002298 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002298:	7179                	addi	sp,sp,-48
    8000229a:	f406                	sd	ra,40(sp)
    8000229c:	f022                	sd	s0,32(sp)
    8000229e:	ec26                	sd	s1,24(sp)
    800022a0:	e84a                	sd	s2,16(sp)
    800022a2:	e44e                	sd	s3,8(sp)
    800022a4:	e052                	sd	s4,0(sp)
    800022a6:	1800                	addi	s0,sp,48
    800022a8:	84aa                	mv	s1,a0
    800022aa:	8a2e                	mv	s4,a1
    800022ac:	89b2                	mv	s3,a2
    800022ae:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800022b0:	e7eff0ef          	jal	8000192e <myproc>
  if(user_dst){
    800022b4:	cc99                	beqz	s1,800022d2 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800022b6:	86ca                	mv	a3,s2
    800022b8:	864e                	mv	a2,s3
    800022ba:	85d2                	mv	a1,s4
    800022bc:	6928                	ld	a0,80(a0)
    800022be:	b96ff0ef          	jal	80001654 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800022c2:	70a2                	ld	ra,40(sp)
    800022c4:	7402                	ld	s0,32(sp)
    800022c6:	64e2                	ld	s1,24(sp)
    800022c8:	6942                	ld	s2,16(sp)
    800022ca:	69a2                	ld	s3,8(sp)
    800022cc:	6a02                	ld	s4,0(sp)
    800022ce:	6145                	addi	sp,sp,48
    800022d0:	8082                	ret
    memmove((char *)dst, src, len);
    800022d2:	0009061b          	sext.w	a2,s2
    800022d6:	85ce                	mv	a1,s3
    800022d8:	8552                	mv	a0,s4
    800022da:	a7ffe0ef          	jal	80000d58 <memmove>
    return 0;
    800022de:	8526                	mv	a0,s1
    800022e0:	b7cd                	j	800022c2 <either_copyout+0x2a>

00000000800022e2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800022e2:	7179                	addi	sp,sp,-48
    800022e4:	f406                	sd	ra,40(sp)
    800022e6:	f022                	sd	s0,32(sp)
    800022e8:	ec26                	sd	s1,24(sp)
    800022ea:	e84a                	sd	s2,16(sp)
    800022ec:	e44e                	sd	s3,8(sp)
    800022ee:	e052                	sd	s4,0(sp)
    800022f0:	1800                	addi	s0,sp,48
    800022f2:	8a2a                	mv	s4,a0
    800022f4:	84ae                	mv	s1,a1
    800022f6:	89b2                	mv	s3,a2
    800022f8:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800022fa:	e34ff0ef          	jal	8000192e <myproc>
  if(user_src){
    800022fe:	cc99                	beqz	s1,8000231c <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002300:	86ca                	mv	a3,s2
    80002302:	864e                	mv	a2,s3
    80002304:	85d2                	mv	a1,s4
    80002306:	6928                	ld	a0,80(a0)
    80002308:	c0aff0ef          	jal	80001712 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000230c:	70a2                	ld	ra,40(sp)
    8000230e:	7402                	ld	s0,32(sp)
    80002310:	64e2                	ld	s1,24(sp)
    80002312:	6942                	ld	s2,16(sp)
    80002314:	69a2                	ld	s3,8(sp)
    80002316:	6a02                	ld	s4,0(sp)
    80002318:	6145                	addi	sp,sp,48
    8000231a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000231c:	0009061b          	sext.w	a2,s2
    80002320:	85ce                	mv	a1,s3
    80002322:	8552                	mv	a0,s4
    80002324:	a35fe0ef          	jal	80000d58 <memmove>
    return 0;
    80002328:	8526                	mv	a0,s1
    8000232a:	b7cd                	j	8000230c <either_copyin+0x2a>

000000008000232c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000232c:	715d                	addi	sp,sp,-80
    8000232e:	e486                	sd	ra,72(sp)
    80002330:	e0a2                	sd	s0,64(sp)
    80002332:	fc26                	sd	s1,56(sp)
    80002334:	f84a                	sd	s2,48(sp)
    80002336:	f44e                	sd	s3,40(sp)
    80002338:	f052                	sd	s4,32(sp)
    8000233a:	ec56                	sd	s5,24(sp)
    8000233c:	e85a                	sd	s6,16(sp)
    8000233e:	e45e                	sd	s7,8(sp)
    80002340:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002342:	00005517          	auipc	a0,0x5
    80002346:	d3650513          	addi	a0,a0,-714 # 80007078 <etext+0x78>
    8000234a:	9b0fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000234e:	0000e497          	auipc	s1,0xe
    80002352:	ba248493          	addi	s1,s1,-1118 # 8000fef0 <proc+0x158>
    80002356:	00013917          	auipc	s2,0x13
    8000235a:	79a90913          	addi	s2,s2,1946 # 80015af0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000235e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002360:	00005997          	auipc	s3,0x5
    80002364:	ea098993          	addi	s3,s3,-352 # 80007200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    80002368:	00005a97          	auipc	s5,0x5
    8000236c:	ea0a8a93          	addi	s5,s5,-352 # 80007208 <etext+0x208>
    printf("\n");
    80002370:	00005a17          	auipc	s4,0x5
    80002374:	d08a0a13          	addi	s4,s4,-760 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002378:	00005b97          	auipc	s7,0x5
    8000237c:	3b0b8b93          	addi	s7,s7,944 # 80007728 <states.0>
    80002380:	a829                	j	8000239a <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002382:	ed86a583          	lw	a1,-296(a3)
    80002386:	8556                	mv	a0,s5
    80002388:	972fe0ef          	jal	800004fa <printf>
    printf("\n");
    8000238c:	8552                	mv	a0,s4
    8000238e:	96cfe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002392:	17048493          	addi	s1,s1,368
    80002396:	03248263          	beq	s1,s2,800023ba <procdump+0x8e>
    if(p->state == UNUSED)
    8000239a:	86a6                	mv	a3,s1
    8000239c:	ec04a783          	lw	a5,-320(s1)
    800023a0:	dbed                	beqz	a5,80002392 <procdump+0x66>
      state = "???";
    800023a2:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023a4:	fcfb6fe3          	bltu	s6,a5,80002382 <procdump+0x56>
    800023a8:	02079713          	slli	a4,a5,0x20
    800023ac:	01d75793          	srli	a5,a4,0x1d
    800023b0:	97de                	add	a5,a5,s7
    800023b2:	6390                	ld	a2,0(a5)
    800023b4:	f679                	bnez	a2,80002382 <procdump+0x56>
      state = "???";
    800023b6:	864e                	mv	a2,s3
    800023b8:	b7e9                	j	80002382 <procdump+0x56>
  }
}
    800023ba:	60a6                	ld	ra,72(sp)
    800023bc:	6406                	ld	s0,64(sp)
    800023be:	74e2                	ld	s1,56(sp)
    800023c0:	7942                	ld	s2,48(sp)
    800023c2:	79a2                	ld	s3,40(sp)
    800023c4:	7a02                	ld	s4,32(sp)
    800023c6:	6ae2                	ld	s5,24(sp)
    800023c8:	6b42                	ld	s6,16(sp)
    800023ca:	6ba2                	ld	s7,8(sp)
    800023cc:	6161                	addi	sp,sp,80
    800023ce:	8082                	ret

00000000800023d0 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800023d0:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800023d4:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800023d8:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800023da:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800023dc:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800023e0:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800023e4:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800023e8:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800023ec:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800023f0:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800023f4:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800023f8:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800023fc:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002400:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002404:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002408:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000240c:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000240e:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002410:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002414:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002418:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000241c:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002420:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002424:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002428:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000242c:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002430:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002434:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002438:	8082                	ret

000000008000243a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000243a:	1141                	addi	sp,sp,-16
    8000243c:	e406                	sd	ra,8(sp)
    8000243e:	e022                	sd	s0,0(sp)
    80002440:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002442:	00005597          	auipc	a1,0x5
    80002446:	e0658593          	addi	a1,a1,-506 # 80007248 <etext+0x248>
    8000244a:	00013517          	auipc	a0,0x13
    8000244e:	54e50513          	addi	a0,a0,1358 # 80015998 <tickslock>
    80002452:	f4cfe0ef          	jal	80000b9e <initlock>
}
    80002456:	60a2                	ld	ra,8(sp)
    80002458:	6402                	ld	s0,0(sp)
    8000245a:	0141                	addi	sp,sp,16
    8000245c:	8082                	ret

000000008000245e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000245e:	1141                	addi	sp,sp,-16
    80002460:	e406                	sd	ra,8(sp)
    80002462:	e022                	sd	s0,0(sp)
    80002464:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002466:	00003797          	auipc	a5,0x3
    8000246a:	01a78793          	addi	a5,a5,26 # 80005480 <kernelvec>
    8000246e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002472:	60a2                	ld	ra,8(sp)
    80002474:	6402                	ld	s0,0(sp)
    80002476:	0141                	addi	sp,sp,16
    80002478:	8082                	ret

000000008000247a <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000247a:	1141                	addi	sp,sp,-16
    8000247c:	e406                	sd	ra,8(sp)
    8000247e:	e022                	sd	s0,0(sp)
    80002480:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002482:	cacff0ef          	jal	8000192e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002486:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000248a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000248c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002490:	04000737          	lui	a4,0x4000
    80002494:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002496:	0732                	slli	a4,a4,0xc
    80002498:	00004797          	auipc	a5,0x4
    8000249c:	b6878793          	addi	a5,a5,-1176 # 80006000 <_trampoline>
    800024a0:	00004697          	auipc	a3,0x4
    800024a4:	b6068693          	addi	a3,a3,-1184 # 80006000 <_trampoline>
    800024a8:	8f95                	sub	a5,a5,a3
    800024aa:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024ac:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800024b0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800024b2:	18002773          	csrr	a4,satp
    800024b6:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800024b8:	6d38                	ld	a4,88(a0)
    800024ba:	613c                	ld	a5,64(a0)
    800024bc:	6685                	lui	a3,0x1
    800024be:	97b6                	add	a5,a5,a3
    800024c0:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800024c2:	6d3c                	ld	a5,88(a0)
    800024c4:	00000717          	auipc	a4,0x0
    800024c8:	0fc70713          	addi	a4,a4,252 # 800025c0 <usertrap>
    800024cc:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800024ce:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800024d0:	8712                	mv	a4,tp
    800024d2:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024d4:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800024d8:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800024dc:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024e0:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800024e4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800024e6:	6f9c                	ld	a5,24(a5)
    800024e8:	14179073          	csrw	sepc,a5
}
    800024ec:	60a2                	ld	ra,8(sp)
    800024ee:	6402                	ld	s0,0(sp)
    800024f0:	0141                	addi	sp,sp,16
    800024f2:	8082                	ret

00000000800024f4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800024f4:	1141                	addi	sp,sp,-16
    800024f6:	e406                	sd	ra,8(sp)
    800024f8:	e022                	sd	s0,0(sp)
    800024fa:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800024fc:	bfeff0ef          	jal	800018fa <cpuid>
    80002500:	cd11                	beqz	a0,8000251c <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002502:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002506:	000f4737          	lui	a4,0xf4
    8000250a:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000250e:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002510:	14d79073          	csrw	stimecmp,a5
}
    80002514:	60a2                	ld	ra,8(sp)
    80002516:	6402                	ld	s0,0(sp)
    80002518:	0141                	addi	sp,sp,16
    8000251a:	8082                	ret
    acquire(&tickslock);
    8000251c:	00013517          	auipc	a0,0x13
    80002520:	47c50513          	addi	a0,a0,1148 # 80015998 <tickslock>
    80002524:	f04fe0ef          	jal	80000c28 <acquire>
    ticks++;
    80002528:	00005717          	auipc	a4,0x5
    8000252c:	34070713          	addi	a4,a4,832 # 80007868 <ticks>
    80002530:	431c                	lw	a5,0(a4)
    80002532:	2785                	addiw	a5,a5,1
    80002534:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002536:	853a                	mv	a0,a4
    80002538:	a53ff0ef          	jal	80001f8a <wakeup>
    release(&tickslock);
    8000253c:	00013517          	auipc	a0,0x13
    80002540:	45c50513          	addi	a0,a0,1116 # 80015998 <tickslock>
    80002544:	f78fe0ef          	jal	80000cbc <release>
    80002548:	bf6d                	j	80002502 <clockintr+0xe>

000000008000254a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000254a:	1101                	addi	sp,sp,-32
    8000254c:	ec06                	sd	ra,24(sp)
    8000254e:	e822                	sd	s0,16(sp)
    80002550:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002552:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002556:	57fd                	li	a5,-1
    80002558:	17fe                	slli	a5,a5,0x3f
    8000255a:	07a5                	addi	a5,a5,9
    8000255c:	00f70c63          	beq	a4,a5,80002574 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002560:	57fd                	li	a5,-1
    80002562:	17fe                	slli	a5,a5,0x3f
    80002564:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002566:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002568:	04f70863          	beq	a4,a5,800025b8 <devintr+0x6e>
  }
}
    8000256c:	60e2                	ld	ra,24(sp)
    8000256e:	6442                	ld	s0,16(sp)
    80002570:	6105                	addi	sp,sp,32
    80002572:	8082                	ret
    80002574:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002576:	7b7020ef          	jal	8000552c <plic_claim>
    8000257a:	872a                	mv	a4,a0
    8000257c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000257e:	47a9                	li	a5,10
    80002580:	00f50963          	beq	a0,a5,80002592 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    80002584:	4785                	li	a5,1
    80002586:	00f50963          	beq	a0,a5,80002598 <devintr+0x4e>
    return 1;
    8000258a:	4505                	li	a0,1
    } else if(irq){
    8000258c:	eb09                	bnez	a4,8000259e <devintr+0x54>
    8000258e:	64a2                	ld	s1,8(sp)
    80002590:	bff1                	j	8000256c <devintr+0x22>
      uartintr();
    80002592:	c62fe0ef          	jal	800009f4 <uartintr>
    if(irq)
    80002596:	a819                	j	800025ac <devintr+0x62>
      virtio_disk_intr();
    80002598:	42a030ef          	jal	800059c2 <virtio_disk_intr>
    if(irq)
    8000259c:	a801                	j	800025ac <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    8000259e:	85ba                	mv	a1,a4
    800025a0:	00005517          	auipc	a0,0x5
    800025a4:	cb050513          	addi	a0,a0,-848 # 80007250 <etext+0x250>
    800025a8:	f53fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    800025ac:	8526                	mv	a0,s1
    800025ae:	79f020ef          	jal	8000554c <plic_complete>
    return 1;
    800025b2:	4505                	li	a0,1
    800025b4:	64a2                	ld	s1,8(sp)
    800025b6:	bf5d                	j	8000256c <devintr+0x22>
    clockintr();
    800025b8:	f3dff0ef          	jal	800024f4 <clockintr>
    return 2;
    800025bc:	4509                	li	a0,2
    800025be:	b77d                	j	8000256c <devintr+0x22>

00000000800025c0 <usertrap>:
{
    800025c0:	1101                	addi	sp,sp,-32
    800025c2:	ec06                	sd	ra,24(sp)
    800025c4:	e822                	sd	s0,16(sp)
    800025c6:	e426                	sd	s1,8(sp)
    800025c8:	e04a                	sd	s2,0(sp)
    800025ca:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025cc:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800025d0:	1007f793          	andi	a5,a5,256
    800025d4:	eba5                	bnez	a5,80002644 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025d6:	00003797          	auipc	a5,0x3
    800025da:	eaa78793          	addi	a5,a5,-342 # 80005480 <kernelvec>
    800025de:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800025e2:	b4cff0ef          	jal	8000192e <myproc>
    800025e6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800025e8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025ea:	14102773          	csrr	a4,sepc
    800025ee:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025f0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800025f4:	47a1                	li	a5,8
    800025f6:	04f70d63          	beq	a4,a5,80002650 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    800025fa:	f51ff0ef          	jal	8000254a <devintr>
    800025fe:	892a                	mv	s2,a0
    80002600:	e945                	bnez	a0,800026b0 <usertrap+0xf0>
    80002602:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002606:	47bd                	li	a5,15
    80002608:	08f70863          	beq	a4,a5,80002698 <usertrap+0xd8>
    8000260c:	14202773          	csrr	a4,scause
    80002610:	47b5                	li	a5,13
    80002612:	08f70363          	beq	a4,a5,80002698 <usertrap+0xd8>
    80002616:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000261a:	5890                	lw	a2,48(s1)
    8000261c:	00005517          	auipc	a0,0x5
    80002620:	c7450513          	addi	a0,a0,-908 # 80007290 <etext+0x290>
    80002624:	ed7fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002628:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000262c:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002630:	00005517          	auipc	a0,0x5
    80002634:	c9050513          	addi	a0,a0,-880 # 800072c0 <etext+0x2c0>
    80002638:	ec3fd0ef          	jal	800004fa <printf>
    setkilled(p);
    8000263c:	8526                	mv	a0,s1
    8000263e:	b19ff0ef          	jal	80002156 <setkilled>
    80002642:	a035                	j	8000266e <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002644:	00005517          	auipc	a0,0x5
    80002648:	c2c50513          	addi	a0,a0,-980 # 80007270 <etext+0x270>
    8000264c:	9d8fe0ef          	jal	80000824 <panic>
    if(killed(p))
    80002650:	b2bff0ef          	jal	8000217a <killed>
    80002654:	ed15                	bnez	a0,80002690 <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002656:	6cb8                	ld	a4,88(s1)
    80002658:	6f1c                	ld	a5,24(a4)
    8000265a:	0791                	addi	a5,a5,4
    8000265c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000265e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002662:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002666:	10079073          	csrw	sstatus,a5
    syscall();
    8000266a:	240000ef          	jal	800028aa <syscall>
  if(killed(p))
    8000266e:	8526                	mv	a0,s1
    80002670:	b0bff0ef          	jal	8000217a <killed>
    80002674:	e139                	bnez	a0,800026ba <usertrap+0xfa>
  prepare_return();
    80002676:	e05ff0ef          	jal	8000247a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000267a:	68a8                	ld	a0,80(s1)
    8000267c:	8131                	srli	a0,a0,0xc
    8000267e:	57fd                	li	a5,-1
    80002680:	17fe                	slli	a5,a5,0x3f
    80002682:	8d5d                	or	a0,a0,a5
}
    80002684:	60e2                	ld	ra,24(sp)
    80002686:	6442                	ld	s0,16(sp)
    80002688:	64a2                	ld	s1,8(sp)
    8000268a:	6902                	ld	s2,0(sp)
    8000268c:	6105                	addi	sp,sp,32
    8000268e:	8082                	ret
      kexit(-1);
    80002690:	557d                	li	a0,-1
    80002692:	9b9ff0ef          	jal	8000204a <kexit>
    80002696:	b7c1                	j	80002656 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002698:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000269c:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    800026a0:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    800026a2:	00163613          	seqz	a2,a2
    800026a6:	68a8                	ld	a0,80(s1)
    800026a8:	f29fe0ef          	jal	800015d0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800026ac:	f169                	bnez	a0,8000266e <usertrap+0xae>
    800026ae:	b7a5                	j	80002616 <usertrap+0x56>
  if(killed(p))
    800026b0:	8526                	mv	a0,s1
    800026b2:	ac9ff0ef          	jal	8000217a <killed>
    800026b6:	c511                	beqz	a0,800026c2 <usertrap+0x102>
    800026b8:	a011                	j	800026bc <usertrap+0xfc>
    800026ba:	4901                	li	s2,0
    kexit(-1);
    800026bc:	557d                	li	a0,-1
    800026be:	98dff0ef          	jal	8000204a <kexit>
  if(which_dev == 2)
    800026c2:	4789                	li	a5,2
    800026c4:	faf919e3          	bne	s2,a5,80002676 <usertrap+0xb6>
    yield();
    800026c8:	84bff0ef          	jal	80001f12 <yield>
    800026cc:	b76d                	j	80002676 <usertrap+0xb6>

00000000800026ce <kerneltrap>:
{
    800026ce:	7179                	addi	sp,sp,-48
    800026d0:	f406                	sd	ra,40(sp)
    800026d2:	f022                	sd	s0,32(sp)
    800026d4:	ec26                	sd	s1,24(sp)
    800026d6:	e84a                	sd	s2,16(sp)
    800026d8:	e44e                	sd	s3,8(sp)
    800026da:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026dc:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026e0:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026e4:	142027f3          	csrr	a5,scause
    800026e8:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    800026ea:	1004f793          	andi	a5,s1,256
    800026ee:	c795                	beqz	a5,8000271a <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026f0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800026f4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800026f6:	eb85                	bnez	a5,80002726 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    800026f8:	e53ff0ef          	jal	8000254a <devintr>
    800026fc:	c91d                	beqz	a0,80002732 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    800026fe:	4789                	li	a5,2
    80002700:	04f50a63          	beq	a0,a5,80002754 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002704:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002708:	10049073          	csrw	sstatus,s1
}
    8000270c:	70a2                	ld	ra,40(sp)
    8000270e:	7402                	ld	s0,32(sp)
    80002710:	64e2                	ld	s1,24(sp)
    80002712:	6942                	ld	s2,16(sp)
    80002714:	69a2                	ld	s3,8(sp)
    80002716:	6145                	addi	sp,sp,48
    80002718:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000271a:	00005517          	auipc	a0,0x5
    8000271e:	bce50513          	addi	a0,a0,-1074 # 800072e8 <etext+0x2e8>
    80002722:	902fe0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    80002726:	00005517          	auipc	a0,0x5
    8000272a:	bea50513          	addi	a0,a0,-1046 # 80007310 <etext+0x310>
    8000272e:	8f6fe0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002732:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002736:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000273a:	85ce                	mv	a1,s3
    8000273c:	00005517          	auipc	a0,0x5
    80002740:	bf450513          	addi	a0,a0,-1036 # 80007330 <etext+0x330>
    80002744:	db7fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80002748:	00005517          	auipc	a0,0x5
    8000274c:	c1050513          	addi	a0,a0,-1008 # 80007358 <etext+0x358>
    80002750:	8d4fe0ef          	jal	80000824 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002754:	9daff0ef          	jal	8000192e <myproc>
    80002758:	d555                	beqz	a0,80002704 <kerneltrap+0x36>
    yield();
    8000275a:	fb8ff0ef          	jal	80001f12 <yield>
    8000275e:	b75d                	j	80002704 <kerneltrap+0x36>

0000000080002760 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002760:	1101                	addi	sp,sp,-32
    80002762:	ec06                	sd	ra,24(sp)
    80002764:	e822                	sd	s0,16(sp)
    80002766:	e426                	sd	s1,8(sp)
    80002768:	1000                	addi	s0,sp,32
    8000276a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000276c:	9c2ff0ef          	jal	8000192e <myproc>
  switch (n) {
    80002770:	4795                	li	a5,5
    80002772:	0497e163          	bltu	a5,s1,800027b4 <argraw+0x54>
    80002776:	048a                	slli	s1,s1,0x2
    80002778:	00005717          	auipc	a4,0x5
    8000277c:	fe070713          	addi	a4,a4,-32 # 80007758 <states.0+0x30>
    80002780:	94ba                	add	s1,s1,a4
    80002782:	409c                	lw	a5,0(s1)
    80002784:	97ba                	add	a5,a5,a4
    80002786:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002788:	6d3c                	ld	a5,88(a0)
    8000278a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000278c:	60e2                	ld	ra,24(sp)
    8000278e:	6442                	ld	s0,16(sp)
    80002790:	64a2                	ld	s1,8(sp)
    80002792:	6105                	addi	sp,sp,32
    80002794:	8082                	ret
    return p->trapframe->a1;
    80002796:	6d3c                	ld	a5,88(a0)
    80002798:	7fa8                	ld	a0,120(a5)
    8000279a:	bfcd                	j	8000278c <argraw+0x2c>
    return p->trapframe->a2;
    8000279c:	6d3c                	ld	a5,88(a0)
    8000279e:	63c8                	ld	a0,128(a5)
    800027a0:	b7f5                	j	8000278c <argraw+0x2c>
    return p->trapframe->a3;
    800027a2:	6d3c                	ld	a5,88(a0)
    800027a4:	67c8                	ld	a0,136(a5)
    800027a6:	b7dd                	j	8000278c <argraw+0x2c>
    return p->trapframe->a4;
    800027a8:	6d3c                	ld	a5,88(a0)
    800027aa:	6bc8                	ld	a0,144(a5)
    800027ac:	b7c5                	j	8000278c <argraw+0x2c>
    return p->trapframe->a5;
    800027ae:	6d3c                	ld	a5,88(a0)
    800027b0:	6fc8                	ld	a0,152(a5)
    800027b2:	bfe9                	j	8000278c <argraw+0x2c>
  panic("argraw");
    800027b4:	00005517          	auipc	a0,0x5
    800027b8:	bb450513          	addi	a0,a0,-1100 # 80007368 <etext+0x368>
    800027bc:	868fe0ef          	jal	80000824 <panic>

00000000800027c0 <fetchaddr>:
{
    800027c0:	1101                	addi	sp,sp,-32
    800027c2:	ec06                	sd	ra,24(sp)
    800027c4:	e822                	sd	s0,16(sp)
    800027c6:	e426                	sd	s1,8(sp)
    800027c8:	e04a                	sd	s2,0(sp)
    800027ca:	1000                	addi	s0,sp,32
    800027cc:	84aa                	mv	s1,a0
    800027ce:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800027d0:	95eff0ef          	jal	8000192e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800027d4:	653c                	ld	a5,72(a0)
    800027d6:	02f4f663          	bgeu	s1,a5,80002802 <fetchaddr+0x42>
    800027da:	00848713          	addi	a4,s1,8
    800027de:	02e7e463          	bltu	a5,a4,80002806 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800027e2:	46a1                	li	a3,8
    800027e4:	8626                	mv	a2,s1
    800027e6:	85ca                	mv	a1,s2
    800027e8:	6928                	ld	a0,80(a0)
    800027ea:	f29fe0ef          	jal	80001712 <copyin>
    800027ee:	00a03533          	snez	a0,a0
    800027f2:	40a0053b          	negw	a0,a0
}
    800027f6:	60e2                	ld	ra,24(sp)
    800027f8:	6442                	ld	s0,16(sp)
    800027fa:	64a2                	ld	s1,8(sp)
    800027fc:	6902                	ld	s2,0(sp)
    800027fe:	6105                	addi	sp,sp,32
    80002800:	8082                	ret
    return -1;
    80002802:	557d                	li	a0,-1
    80002804:	bfcd                	j	800027f6 <fetchaddr+0x36>
    80002806:	557d                	li	a0,-1
    80002808:	b7fd                	j	800027f6 <fetchaddr+0x36>

000000008000280a <fetchstr>:
{
    8000280a:	7179                	addi	sp,sp,-48
    8000280c:	f406                	sd	ra,40(sp)
    8000280e:	f022                	sd	s0,32(sp)
    80002810:	ec26                	sd	s1,24(sp)
    80002812:	e84a                	sd	s2,16(sp)
    80002814:	e44e                	sd	s3,8(sp)
    80002816:	1800                	addi	s0,sp,48
    80002818:	89aa                	mv	s3,a0
    8000281a:	84ae                	mv	s1,a1
    8000281c:	8932                	mv	s2,a2
  struct proc *p = myproc();
    8000281e:	910ff0ef          	jal	8000192e <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002822:	86ca                	mv	a3,s2
    80002824:	864e                	mv	a2,s3
    80002826:	85a6                	mv	a1,s1
    80002828:	6928                	ld	a0,80(a0)
    8000282a:	ccffe0ef          	jal	800014f8 <copyinstr>
    8000282e:	00054c63          	bltz	a0,80002846 <fetchstr+0x3c>
  return strlen(buf);
    80002832:	8526                	mv	a0,s1
    80002834:	e4efe0ef          	jal	80000e82 <strlen>
}
    80002838:	70a2                	ld	ra,40(sp)
    8000283a:	7402                	ld	s0,32(sp)
    8000283c:	64e2                	ld	s1,24(sp)
    8000283e:	6942                	ld	s2,16(sp)
    80002840:	69a2                	ld	s3,8(sp)
    80002842:	6145                	addi	sp,sp,48
    80002844:	8082                	ret
    return -1;
    80002846:	557d                	li	a0,-1
    80002848:	bfc5                	j	80002838 <fetchstr+0x2e>

000000008000284a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000284a:	1101                	addi	sp,sp,-32
    8000284c:	ec06                	sd	ra,24(sp)
    8000284e:	e822                	sd	s0,16(sp)
    80002850:	e426                	sd	s1,8(sp)
    80002852:	1000                	addi	s0,sp,32
    80002854:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002856:	f0bff0ef          	jal	80002760 <argraw>
    8000285a:	c088                	sw	a0,0(s1)
}
    8000285c:	60e2                	ld	ra,24(sp)
    8000285e:	6442                	ld	s0,16(sp)
    80002860:	64a2                	ld	s1,8(sp)
    80002862:	6105                	addi	sp,sp,32
    80002864:	8082                	ret

0000000080002866 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002866:	1101                	addi	sp,sp,-32
    80002868:	ec06                	sd	ra,24(sp)
    8000286a:	e822                	sd	s0,16(sp)
    8000286c:	e426                	sd	s1,8(sp)
    8000286e:	1000                	addi	s0,sp,32
    80002870:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002872:	eefff0ef          	jal	80002760 <argraw>
    80002876:	e088                	sd	a0,0(s1)
}
    80002878:	60e2                	ld	ra,24(sp)
    8000287a:	6442                	ld	s0,16(sp)
    8000287c:	64a2                	ld	s1,8(sp)
    8000287e:	6105                	addi	sp,sp,32
    80002880:	8082                	ret

0000000080002882 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002882:	1101                	addi	sp,sp,-32
    80002884:	ec06                	sd	ra,24(sp)
    80002886:	e822                	sd	s0,16(sp)
    80002888:	e426                	sd	s1,8(sp)
    8000288a:	e04a                	sd	s2,0(sp)
    8000288c:	1000                	addi	s0,sp,32
    8000288e:	892e                	mv	s2,a1
    80002890:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002892:	ecfff0ef          	jal	80002760 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002896:	8626                	mv	a2,s1
    80002898:	85ca                	mv	a1,s2
    8000289a:	f71ff0ef          	jal	8000280a <fetchstr>
}
    8000289e:	60e2                	ld	ra,24(sp)
    800028a0:	6442                	ld	s0,16(sp)
    800028a2:	64a2                	ld	s1,8(sp)
    800028a4:	6902                	ld	s2,0(sp)
    800028a6:	6105                	addi	sp,sp,32
    800028a8:	8082                	ret

00000000800028aa <syscall>:
[SYS_setpriority] sys_setpriority,
};

void
syscall(void)
{
    800028aa:	1101                	addi	sp,sp,-32
    800028ac:	ec06                	sd	ra,24(sp)
    800028ae:	e822                	sd	s0,16(sp)
    800028b0:	e426                	sd	s1,8(sp)
    800028b2:	e04a                	sd	s2,0(sp)
    800028b4:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800028b6:	878ff0ef          	jal	8000192e <myproc>
    800028ba:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800028bc:	05853903          	ld	s2,88(a0)
    800028c0:	0a893783          	ld	a5,168(s2)
    800028c4:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800028c8:	37fd                	addiw	a5,a5,-1
    800028ca:	4759                	li	a4,22
    800028cc:	00f76f63          	bltu	a4,a5,800028ea <syscall+0x40>
    800028d0:	00369713          	slli	a4,a3,0x3
    800028d4:	00005797          	auipc	a5,0x5
    800028d8:	e9c78793          	addi	a5,a5,-356 # 80007770 <syscalls>
    800028dc:	97ba                	add	a5,a5,a4
    800028de:	639c                	ld	a5,0(a5)
    800028e0:	c789                	beqz	a5,800028ea <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800028e2:	9782                	jalr	a5
    800028e4:	06a93823          	sd	a0,112(s2)
    800028e8:	a829                	j	80002902 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800028ea:	15848613          	addi	a2,s1,344
    800028ee:	588c                	lw	a1,48(s1)
    800028f0:	00005517          	auipc	a0,0x5
    800028f4:	a8050513          	addi	a0,a0,-1408 # 80007370 <etext+0x370>
    800028f8:	c03fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800028fc:	6cbc                	ld	a5,88(s1)
    800028fe:	577d                	li	a4,-1
    80002900:	fbb8                	sd	a4,112(a5)
  }
}
    80002902:	60e2                	ld	ra,24(sp)
    80002904:	6442                	ld	s0,16(sp)
    80002906:	64a2                	ld	s1,8(sp)
    80002908:	6902                	ld	s2,0(sp)
    8000290a:	6105                	addi	sp,sp,32
    8000290c:	8082                	ret

000000008000290e <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    8000290e:	1101                	addi	sp,sp,-32
    80002910:	ec06                	sd	ra,24(sp)
    80002912:	e822                	sd	s0,16(sp)
    80002914:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002916:	fec40593          	addi	a1,s0,-20
    8000291a:	4501                	li	a0,0
    8000291c:	f2fff0ef          	jal	8000284a <argint>
  kexit(n);
    80002920:	fec42503          	lw	a0,-20(s0)
    80002924:	f26ff0ef          	jal	8000204a <kexit>
  return 0;  // not reached
}
    80002928:	4501                	li	a0,0
    8000292a:	60e2                	ld	ra,24(sp)
    8000292c:	6442                	ld	s0,16(sp)
    8000292e:	6105                	addi	sp,sp,32
    80002930:	8082                	ret

0000000080002932 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002932:	1141                	addi	sp,sp,-16
    80002934:	e406                	sd	ra,8(sp)
    80002936:	e022                	sd	s0,0(sp)
    80002938:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000293a:	ff5fe0ef          	jal	8000192e <myproc>
}
    8000293e:	5908                	lw	a0,48(a0)
    80002940:	60a2                	ld	ra,8(sp)
    80002942:	6402                	ld	s0,0(sp)
    80002944:	0141                	addi	sp,sp,16
    80002946:	8082                	ret

0000000080002948 <sys_fork>:

uint64
sys_fork(void)
{
    80002948:	1141                	addi	sp,sp,-16
    8000294a:	e406                	sd	ra,8(sp)
    8000294c:	e022                	sd	s0,0(sp)
    8000294e:	0800                	addi	s0,sp,16
  return kfork();
    80002950:	b46ff0ef          	jal	80001c96 <kfork>
}
    80002954:	60a2                	ld	ra,8(sp)
    80002956:	6402                	ld	s0,0(sp)
    80002958:	0141                	addi	sp,sp,16
    8000295a:	8082                	ret

000000008000295c <sys_wait>:

uint64
sys_wait(void)
{
    8000295c:	1101                	addi	sp,sp,-32
    8000295e:	ec06                	sd	ra,24(sp)
    80002960:	e822                	sd	s0,16(sp)
    80002962:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002964:	fe840593          	addi	a1,s0,-24
    80002968:	4501                	li	a0,0
    8000296a:	efdff0ef          	jal	80002866 <argaddr>
  return kwait(p);
    8000296e:	fe843503          	ld	a0,-24(s0)
    80002972:	833ff0ef          	jal	800021a4 <kwait>
}
    80002976:	60e2                	ld	ra,24(sp)
    80002978:	6442                	ld	s0,16(sp)
    8000297a:	6105                	addi	sp,sp,32
    8000297c:	8082                	ret

000000008000297e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000297e:	7179                	addi	sp,sp,-48
    80002980:	f406                	sd	ra,40(sp)
    80002982:	f022                	sd	s0,32(sp)
    80002984:	ec26                	sd	s1,24(sp)
    80002986:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002988:	fd840593          	addi	a1,s0,-40
    8000298c:	4501                	li	a0,0
    8000298e:	ebdff0ef          	jal	8000284a <argint>
  argint(1, &t);
    80002992:	fdc40593          	addi	a1,s0,-36
    80002996:	4505                	li	a0,1
    80002998:	eb3ff0ef          	jal	8000284a <argint>
  addr = myproc()->sz;
    8000299c:	f93fe0ef          	jal	8000192e <myproc>
    800029a0:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    800029a2:	fdc42703          	lw	a4,-36(s0)
    800029a6:	4785                	li	a5,1
    800029a8:	02f70763          	beq	a4,a5,800029d6 <sys_sbrk+0x58>
    800029ac:	fd842783          	lw	a5,-40(s0)
    800029b0:	0207c363          	bltz	a5,800029d6 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    800029b4:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    800029b6:	02000737          	lui	a4,0x2000
    800029ba:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    800029bc:	0736                	slli	a4,a4,0xd
    800029be:	02f76a63          	bltu	a4,a5,800029f2 <sys_sbrk+0x74>
    800029c2:	0297e863          	bltu	a5,s1,800029f2 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    800029c6:	f69fe0ef          	jal	8000192e <myproc>
    800029ca:	fd842703          	lw	a4,-40(s0)
    800029ce:	653c                	ld	a5,72(a0)
    800029d0:	97ba                	add	a5,a5,a4
    800029d2:	e53c                	sd	a5,72(a0)
    800029d4:	a039                	j	800029e2 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    800029d6:	fd842503          	lw	a0,-40(s0)
    800029da:	a5aff0ef          	jal	80001c34 <growproc>
    800029de:	00054863          	bltz	a0,800029ee <sys_sbrk+0x70>
  }
  return addr;
}
    800029e2:	8526                	mv	a0,s1
    800029e4:	70a2                	ld	ra,40(sp)
    800029e6:	7402                	ld	s0,32(sp)
    800029e8:	64e2                	ld	s1,24(sp)
    800029ea:	6145                	addi	sp,sp,48
    800029ec:	8082                	ret
      return -1;
    800029ee:	54fd                	li	s1,-1
    800029f0:	bfcd                	j	800029e2 <sys_sbrk+0x64>
      return -1;
    800029f2:	54fd                	li	s1,-1
    800029f4:	b7fd                	j	800029e2 <sys_sbrk+0x64>

00000000800029f6 <sys_pause>:

uint64
sys_pause(void)
{
    800029f6:	7139                	addi	sp,sp,-64
    800029f8:	fc06                	sd	ra,56(sp)
    800029fa:	f822                	sd	s0,48(sp)
    800029fc:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800029fe:	fcc40593          	addi	a1,s0,-52
    80002a02:	4501                	li	a0,0
    80002a04:	e47ff0ef          	jal	8000284a <argint>
  if(n < 0)
    80002a08:	fcc42783          	lw	a5,-52(s0)
    80002a0c:	0607c863          	bltz	a5,80002a7c <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002a10:	00013517          	auipc	a0,0x13
    80002a14:	f8850513          	addi	a0,a0,-120 # 80015998 <tickslock>
    80002a18:	a10fe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002a1c:	fcc42783          	lw	a5,-52(s0)
    80002a20:	c3b9                	beqz	a5,80002a66 <sys_pause+0x70>
    80002a22:	f426                	sd	s1,40(sp)
    80002a24:	f04a                	sd	s2,32(sp)
    80002a26:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002a28:	00005997          	auipc	s3,0x5
    80002a2c:	e409a983          	lw	s3,-448(s3) # 80007868 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a30:	00013917          	auipc	s2,0x13
    80002a34:	f6890913          	addi	s2,s2,-152 # 80015998 <tickslock>
    80002a38:	00005497          	auipc	s1,0x5
    80002a3c:	e3048493          	addi	s1,s1,-464 # 80007868 <ticks>
    if(killed(myproc())){
    80002a40:	eeffe0ef          	jal	8000192e <myproc>
    80002a44:	f36ff0ef          	jal	8000217a <killed>
    80002a48:	ed0d                	bnez	a0,80002a82 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002a4a:	85ca                	mv	a1,s2
    80002a4c:	8526                	mv	a0,s1
    80002a4e:	cf0ff0ef          	jal	80001f3e <sleep>
  while(ticks - ticks0 < n){
    80002a52:	409c                	lw	a5,0(s1)
    80002a54:	413787bb          	subw	a5,a5,s3
    80002a58:	fcc42703          	lw	a4,-52(s0)
    80002a5c:	fee7e2e3          	bltu	a5,a4,80002a40 <sys_pause+0x4a>
    80002a60:	74a2                	ld	s1,40(sp)
    80002a62:	7902                	ld	s2,32(sp)
    80002a64:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a66:	00013517          	auipc	a0,0x13
    80002a6a:	f3250513          	addi	a0,a0,-206 # 80015998 <tickslock>
    80002a6e:	a4efe0ef          	jal	80000cbc <release>
  return 0;
    80002a72:	4501                	li	a0,0
}
    80002a74:	70e2                	ld	ra,56(sp)
    80002a76:	7442                	ld	s0,48(sp)
    80002a78:	6121                	addi	sp,sp,64
    80002a7a:	8082                	ret
    n = 0;
    80002a7c:	fc042623          	sw	zero,-52(s0)
    80002a80:	bf41                	j	80002a10 <sys_pause+0x1a>
      release(&tickslock);
    80002a82:	00013517          	auipc	a0,0x13
    80002a86:	f1650513          	addi	a0,a0,-234 # 80015998 <tickslock>
    80002a8a:	a32fe0ef          	jal	80000cbc <release>
      return -1;
    80002a8e:	557d                	li	a0,-1
    80002a90:	74a2                	ld	s1,40(sp)
    80002a92:	7902                	ld	s2,32(sp)
    80002a94:	69e2                	ld	s3,24(sp)
    80002a96:	bff9                	j	80002a74 <sys_pause+0x7e>

0000000080002a98 <sys_kill>:

uint64
sys_kill(void)
{
    80002a98:	1101                	addi	sp,sp,-32
    80002a9a:	ec06                	sd	ra,24(sp)
    80002a9c:	e822                	sd	s0,16(sp)
    80002a9e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002aa0:	fec40593          	addi	a1,s0,-20
    80002aa4:	4501                	li	a0,0
    80002aa6:	da5ff0ef          	jal	8000284a <argint>
  return kkill(pid);
    80002aaa:	fec42503          	lw	a0,-20(s0)
    80002aae:	e42ff0ef          	jal	800020f0 <kkill>
}
    80002ab2:	60e2                	ld	ra,24(sp)
    80002ab4:	6442                	ld	s0,16(sp)
    80002ab6:	6105                	addi	sp,sp,32
    80002ab8:	8082                	ret

0000000080002aba <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002aba:	1101                	addi	sp,sp,-32
    80002abc:	ec06                	sd	ra,24(sp)
    80002abe:	e822                	sd	s0,16(sp)
    80002ac0:	e426                	sd	s1,8(sp)
    80002ac2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ac4:	00013517          	auipc	a0,0x13
    80002ac8:	ed450513          	addi	a0,a0,-300 # 80015998 <tickslock>
    80002acc:	95cfe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002ad0:	00005797          	auipc	a5,0x5
    80002ad4:	d987a783          	lw	a5,-616(a5) # 80007868 <ticks>
    80002ad8:	84be                	mv	s1,a5
  release(&tickslock);
    80002ada:	00013517          	auipc	a0,0x13
    80002ade:	ebe50513          	addi	a0,a0,-322 # 80015998 <tickslock>
    80002ae2:	9dafe0ef          	jal	80000cbc <release>
  return xticks;
}
    80002ae6:	02049513          	slli	a0,s1,0x20
    80002aea:	9101                	srli	a0,a0,0x20
    80002aec:	60e2                	ld	ra,24(sp)
    80002aee:	6442                	ld	s0,16(sp)
    80002af0:	64a2                	ld	s1,8(sp)
    80002af2:	6105                	addi	sp,sp,32
    80002af4:	8082                	ret

0000000080002af6 <sys_getprocinfo>:

uint64
sys_getprocinfo(void)
{
    80002af6:	1101                	addi	sp,sp,-32
    80002af8:	ec06                	sd	ra,24(sp)
    80002afa:	e822                	sd	s0,16(sp)
    80002afc:	e426                	sd	s1,8(sp)
    80002afe:	e04a                	sd	s2,0(sp)
    80002b00:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002b02:	e2dfe0ef          	jal	8000192e <myproc>
    80002b06:	84aa                	mv	s1,a0
  uint64 pid_addr  = p->trapframe->a0;
    80002b08:	6d3c                	ld	a5,88(a0)
  uint64 prio_addr = p->trapframe->a1;
    80002b0a:	0787b903          	ld	s2,120(a5)

  if(copyout(p->pagetable, pid_addr,
    80002b0e:	4691                	li	a3,4
    80002b10:	03050613          	addi	a2,a0,48
    80002b14:	7bac                	ld	a1,112(a5)
    80002b16:	6928                	ld	a0,80(a0)
    80002b18:	b3dfe0ef          	jal	80001654 <copyout>
    80002b1c:	87aa                	mv	a5,a0
             (char*)&p->pid, sizeof(p->pid)) < 0)
    return -1;
    80002b1e:	557d                	li	a0,-1
  if(copyout(p->pagetable, pid_addr,
    80002b20:	0007ca63          	bltz	a5,80002b34 <sys_getprocinfo+0x3e>
  if(copyout(p->pagetable, prio_addr,
    80002b24:	4691                	li	a3,4
    80002b26:	16848613          	addi	a2,s1,360
    80002b2a:	85ca                	mv	a1,s2
    80002b2c:	68a8                	ld	a0,80(s1)
    80002b2e:	b27fe0ef          	jal	80001654 <copyout>
    80002b32:	957d                	srai	a0,a0,0x3f
             (char*)&p->priority, sizeof(p->priority)) < 0)
    return -1;
  return 0;
}
    80002b34:	60e2                	ld	ra,24(sp)
    80002b36:	6442                	ld	s0,16(sp)
    80002b38:	64a2                	ld	s1,8(sp)
    80002b3a:	6902                	ld	s2,0(sp)
    80002b3c:	6105                	addi	sp,sp,32
    80002b3e:	8082                	ret

0000000080002b40 <sys_setpriority>:

uint64
sys_setpriority(void)
{
    80002b40:	1141                	addi	sp,sp,-16
    80002b42:	e406                	sd	ra,8(sp)
    80002b44:	e022                	sd	s0,0(sp)
    80002b46:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b48:	de7fe0ef          	jal	8000192e <myproc>
    80002b4c:	87aa                	mv	a5,a0
  int prio = (int)p->trapframe->a0;
    80002b4e:	6d38                	ld	a4,88(a0)
    80002b50:	7b38                	ld	a4,112(a4)
  if(prio < 0 || prio > 19)
    80002b52:	0007061b          	sext.w	a2,a4
    80002b56:	46cd                	li	a3,19
    return -1;
    80002b58:	557d                	li	a0,-1
  if(prio < 0 || prio > 19)
    80002b5a:	00c6e563          	bltu	a3,a2,80002b64 <sys_setpriority+0x24>
  int prio = (int)p->trapframe->a0;
    80002b5e:	16e7a423          	sw	a4,360(a5)
  p->priority = prio;
  return 0;
    80002b62:	4501                	li	a0,0
}
    80002b64:	60a2                	ld	ra,8(sp)
    80002b66:	6402                	ld	s0,0(sp)
    80002b68:	0141                	addi	sp,sp,16
    80002b6a:	8082                	ret

0000000080002b6c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b6c:	7179                	addi	sp,sp,-48
    80002b6e:	f406                	sd	ra,40(sp)
    80002b70:	f022                	sd	s0,32(sp)
    80002b72:	ec26                	sd	s1,24(sp)
    80002b74:	e84a                	sd	s2,16(sp)
    80002b76:	e44e                	sd	s3,8(sp)
    80002b78:	e052                	sd	s4,0(sp)
    80002b7a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b7c:	00005597          	auipc	a1,0x5
    80002b80:	81458593          	addi	a1,a1,-2028 # 80007390 <etext+0x390>
    80002b84:	00013517          	auipc	a0,0x13
    80002b88:	e2c50513          	addi	a0,a0,-468 # 800159b0 <bcache>
    80002b8c:	812fe0ef          	jal	80000b9e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b90:	0001b797          	auipc	a5,0x1b
    80002b94:	e2078793          	addi	a5,a5,-480 # 8001d9b0 <bcache+0x8000>
    80002b98:	0001b717          	auipc	a4,0x1b
    80002b9c:	08070713          	addi	a4,a4,128 # 8001dc18 <bcache+0x8268>
    80002ba0:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ba4:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ba8:	00013497          	auipc	s1,0x13
    80002bac:	e2048493          	addi	s1,s1,-480 # 800159c8 <bcache+0x18>
    b->next = bcache.head.next;
    80002bb0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002bb2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002bb4:	00004a17          	auipc	s4,0x4
    80002bb8:	7e4a0a13          	addi	s4,s4,2020 # 80007398 <etext+0x398>
    b->next = bcache.head.next;
    80002bbc:	2b893783          	ld	a5,696(s2)
    80002bc0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002bc2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002bc6:	85d2                	mv	a1,s4
    80002bc8:	01048513          	addi	a0,s1,16
    80002bcc:	328010ef          	jal	80003ef4 <initsleeplock>
    bcache.head.next->prev = b;
    80002bd0:	2b893783          	ld	a5,696(s2)
    80002bd4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002bd6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002bda:	45848493          	addi	s1,s1,1112
    80002bde:	fd349fe3          	bne	s1,s3,80002bbc <binit+0x50>
  }
}
    80002be2:	70a2                	ld	ra,40(sp)
    80002be4:	7402                	ld	s0,32(sp)
    80002be6:	64e2                	ld	s1,24(sp)
    80002be8:	6942                	ld	s2,16(sp)
    80002bea:	69a2                	ld	s3,8(sp)
    80002bec:	6a02                	ld	s4,0(sp)
    80002bee:	6145                	addi	sp,sp,48
    80002bf0:	8082                	ret

0000000080002bf2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002bf2:	7179                	addi	sp,sp,-48
    80002bf4:	f406                	sd	ra,40(sp)
    80002bf6:	f022                	sd	s0,32(sp)
    80002bf8:	ec26                	sd	s1,24(sp)
    80002bfa:	e84a                	sd	s2,16(sp)
    80002bfc:	e44e                	sd	s3,8(sp)
    80002bfe:	1800                	addi	s0,sp,48
    80002c00:	892a                	mv	s2,a0
    80002c02:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002c04:	00013517          	auipc	a0,0x13
    80002c08:	dac50513          	addi	a0,a0,-596 # 800159b0 <bcache>
    80002c0c:	81cfe0ef          	jal	80000c28 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002c10:	0001b497          	auipc	s1,0x1b
    80002c14:	0584b483          	ld	s1,88(s1) # 8001dc68 <bcache+0x82b8>
    80002c18:	0001b797          	auipc	a5,0x1b
    80002c1c:	00078793          	mv	a5,a5
    80002c20:	02f48b63          	beq	s1,a5,80002c56 <bread+0x64>
    80002c24:	873e                	mv	a4,a5
    80002c26:	a021                	j	80002c2e <bread+0x3c>
    80002c28:	68a4                	ld	s1,80(s1)
    80002c2a:	02e48663          	beq	s1,a4,80002c56 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002c2e:	449c                	lw	a5,8(s1)
    80002c30:	ff279ce3          	bne	a5,s2,80002c28 <bread+0x36>
    80002c34:	44dc                	lw	a5,12(s1)
    80002c36:	ff3799e3          	bne	a5,s3,80002c28 <bread+0x36>
      b->refcnt++;
    80002c3a:	40bc                	lw	a5,64(s1)
    80002c3c:	2785                	addiw	a5,a5,1 # ffffffff8001dc19 <end+0xfffffffeffffcea1>
    80002c3e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c40:	00013517          	auipc	a0,0x13
    80002c44:	d7050513          	addi	a0,a0,-656 # 800159b0 <bcache>
    80002c48:	874fe0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002c4c:	01048513          	addi	a0,s1,16
    80002c50:	2da010ef          	jal	80003f2a <acquiresleep>
      return b;
    80002c54:	a889                	j	80002ca6 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c56:	0001b497          	auipc	s1,0x1b
    80002c5a:	00a4b483          	ld	s1,10(s1) # 8001dc60 <bcache+0x82b0>
    80002c5e:	0001b797          	auipc	a5,0x1b
    80002c62:	fba78793          	addi	a5,a5,-70 # 8001dc18 <bcache+0x8268>
    80002c66:	00f48863          	beq	s1,a5,80002c76 <bread+0x84>
    80002c6a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002c6c:	40bc                	lw	a5,64(s1)
    80002c6e:	cb91                	beqz	a5,80002c82 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c70:	64a4                	ld	s1,72(s1)
    80002c72:	fee49de3          	bne	s1,a4,80002c6c <bread+0x7a>
  panic("bget: no buffers");
    80002c76:	00004517          	auipc	a0,0x4
    80002c7a:	72a50513          	addi	a0,a0,1834 # 800073a0 <etext+0x3a0>
    80002c7e:	ba7fd0ef          	jal	80000824 <panic>
      b->dev = dev;
    80002c82:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c86:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c8a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c8e:	4785                	li	a5,1
    80002c90:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c92:	00013517          	auipc	a0,0x13
    80002c96:	d1e50513          	addi	a0,a0,-738 # 800159b0 <bcache>
    80002c9a:	822fe0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002c9e:	01048513          	addi	a0,s1,16
    80002ca2:	288010ef          	jal	80003f2a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002ca6:	409c                	lw	a5,0(s1)
    80002ca8:	cb89                	beqz	a5,80002cba <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002caa:	8526                	mv	a0,s1
    80002cac:	70a2                	ld	ra,40(sp)
    80002cae:	7402                	ld	s0,32(sp)
    80002cb0:	64e2                	ld	s1,24(sp)
    80002cb2:	6942                	ld	s2,16(sp)
    80002cb4:	69a2                	ld	s3,8(sp)
    80002cb6:	6145                	addi	sp,sp,48
    80002cb8:	8082                	ret
    virtio_disk_rw(b, 0);
    80002cba:	4581                	li	a1,0
    80002cbc:	8526                	mv	a0,s1
    80002cbe:	2f3020ef          	jal	800057b0 <virtio_disk_rw>
    b->valid = 1;
    80002cc2:	4785                	li	a5,1
    80002cc4:	c09c                	sw	a5,0(s1)
  return b;
    80002cc6:	b7d5                	j	80002caa <bread+0xb8>

0000000080002cc8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002cc8:	1101                	addi	sp,sp,-32
    80002cca:	ec06                	sd	ra,24(sp)
    80002ccc:	e822                	sd	s0,16(sp)
    80002cce:	e426                	sd	s1,8(sp)
    80002cd0:	1000                	addi	s0,sp,32
    80002cd2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002cd4:	0541                	addi	a0,a0,16
    80002cd6:	2d2010ef          	jal	80003fa8 <holdingsleep>
    80002cda:	c911                	beqz	a0,80002cee <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002cdc:	4585                	li	a1,1
    80002cde:	8526                	mv	a0,s1
    80002ce0:	2d1020ef          	jal	800057b0 <virtio_disk_rw>
}
    80002ce4:	60e2                	ld	ra,24(sp)
    80002ce6:	6442                	ld	s0,16(sp)
    80002ce8:	64a2                	ld	s1,8(sp)
    80002cea:	6105                	addi	sp,sp,32
    80002cec:	8082                	ret
    panic("bwrite");
    80002cee:	00004517          	auipc	a0,0x4
    80002cf2:	6ca50513          	addi	a0,a0,1738 # 800073b8 <etext+0x3b8>
    80002cf6:	b2ffd0ef          	jal	80000824 <panic>

0000000080002cfa <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002cfa:	1101                	addi	sp,sp,-32
    80002cfc:	ec06                	sd	ra,24(sp)
    80002cfe:	e822                	sd	s0,16(sp)
    80002d00:	e426                	sd	s1,8(sp)
    80002d02:	e04a                	sd	s2,0(sp)
    80002d04:	1000                	addi	s0,sp,32
    80002d06:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d08:	01050913          	addi	s2,a0,16
    80002d0c:	854a                	mv	a0,s2
    80002d0e:	29a010ef          	jal	80003fa8 <holdingsleep>
    80002d12:	c125                	beqz	a0,80002d72 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002d14:	854a                	mv	a0,s2
    80002d16:	25a010ef          	jal	80003f70 <releasesleep>

  acquire(&bcache.lock);
    80002d1a:	00013517          	auipc	a0,0x13
    80002d1e:	c9650513          	addi	a0,a0,-874 # 800159b0 <bcache>
    80002d22:	f07fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002d26:	40bc                	lw	a5,64(s1)
    80002d28:	37fd                	addiw	a5,a5,-1
    80002d2a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d2c:	e79d                	bnez	a5,80002d5a <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002d2e:	68b8                	ld	a4,80(s1)
    80002d30:	64bc                	ld	a5,72(s1)
    80002d32:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002d34:	68b8                	ld	a4,80(s1)
    80002d36:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d38:	0001b797          	auipc	a5,0x1b
    80002d3c:	c7878793          	addi	a5,a5,-904 # 8001d9b0 <bcache+0x8000>
    80002d40:	2b87b703          	ld	a4,696(a5)
    80002d44:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d46:	0001b717          	auipc	a4,0x1b
    80002d4a:	ed270713          	addi	a4,a4,-302 # 8001dc18 <bcache+0x8268>
    80002d4e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d50:	2b87b703          	ld	a4,696(a5)
    80002d54:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d56:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002d5a:	00013517          	auipc	a0,0x13
    80002d5e:	c5650513          	addi	a0,a0,-938 # 800159b0 <bcache>
    80002d62:	f5bfd0ef          	jal	80000cbc <release>
}
    80002d66:	60e2                	ld	ra,24(sp)
    80002d68:	6442                	ld	s0,16(sp)
    80002d6a:	64a2                	ld	s1,8(sp)
    80002d6c:	6902                	ld	s2,0(sp)
    80002d6e:	6105                	addi	sp,sp,32
    80002d70:	8082                	ret
    panic("brelse");
    80002d72:	00004517          	auipc	a0,0x4
    80002d76:	64e50513          	addi	a0,a0,1614 # 800073c0 <etext+0x3c0>
    80002d7a:	aabfd0ef          	jal	80000824 <panic>

0000000080002d7e <bpin>:

void
bpin(struct buf *b) {
    80002d7e:	1101                	addi	sp,sp,-32
    80002d80:	ec06                	sd	ra,24(sp)
    80002d82:	e822                	sd	s0,16(sp)
    80002d84:	e426                	sd	s1,8(sp)
    80002d86:	1000                	addi	s0,sp,32
    80002d88:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d8a:	00013517          	auipc	a0,0x13
    80002d8e:	c2650513          	addi	a0,a0,-986 # 800159b0 <bcache>
    80002d92:	e97fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002d96:	40bc                	lw	a5,64(s1)
    80002d98:	2785                	addiw	a5,a5,1
    80002d9a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d9c:	00013517          	auipc	a0,0x13
    80002da0:	c1450513          	addi	a0,a0,-1004 # 800159b0 <bcache>
    80002da4:	f19fd0ef          	jal	80000cbc <release>
}
    80002da8:	60e2                	ld	ra,24(sp)
    80002daa:	6442                	ld	s0,16(sp)
    80002dac:	64a2                	ld	s1,8(sp)
    80002dae:	6105                	addi	sp,sp,32
    80002db0:	8082                	ret

0000000080002db2 <bunpin>:

void
bunpin(struct buf *b) {
    80002db2:	1101                	addi	sp,sp,-32
    80002db4:	ec06                	sd	ra,24(sp)
    80002db6:	e822                	sd	s0,16(sp)
    80002db8:	e426                	sd	s1,8(sp)
    80002dba:	1000                	addi	s0,sp,32
    80002dbc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002dbe:	00013517          	auipc	a0,0x13
    80002dc2:	bf250513          	addi	a0,a0,-1038 # 800159b0 <bcache>
    80002dc6:	e63fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002dca:	40bc                	lw	a5,64(s1)
    80002dcc:	37fd                	addiw	a5,a5,-1
    80002dce:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002dd0:	00013517          	auipc	a0,0x13
    80002dd4:	be050513          	addi	a0,a0,-1056 # 800159b0 <bcache>
    80002dd8:	ee5fd0ef          	jal	80000cbc <release>
}
    80002ddc:	60e2                	ld	ra,24(sp)
    80002dde:	6442                	ld	s0,16(sp)
    80002de0:	64a2                	ld	s1,8(sp)
    80002de2:	6105                	addi	sp,sp,32
    80002de4:	8082                	ret

0000000080002de6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002de6:	1101                	addi	sp,sp,-32
    80002de8:	ec06                	sd	ra,24(sp)
    80002dea:	e822                	sd	s0,16(sp)
    80002dec:	e426                	sd	s1,8(sp)
    80002dee:	e04a                	sd	s2,0(sp)
    80002df0:	1000                	addi	s0,sp,32
    80002df2:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002df4:	00d5d79b          	srliw	a5,a1,0xd
    80002df8:	0001b597          	auipc	a1,0x1b
    80002dfc:	2945a583          	lw	a1,660(a1) # 8001e08c <sb+0x1c>
    80002e00:	9dbd                	addw	a1,a1,a5
    80002e02:	df1ff0ef          	jal	80002bf2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002e06:	0074f713          	andi	a4,s1,7
    80002e0a:	4785                	li	a5,1
    80002e0c:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002e10:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80002e12:	90d9                	srli	s1,s1,0x36
    80002e14:	00950733          	add	a4,a0,s1
    80002e18:	05874703          	lbu	a4,88(a4)
    80002e1c:	00e7f6b3          	and	a3,a5,a4
    80002e20:	c29d                	beqz	a3,80002e46 <bfree+0x60>
    80002e22:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002e24:	94aa                	add	s1,s1,a0
    80002e26:	fff7c793          	not	a5,a5
    80002e2a:	8f7d                	and	a4,a4,a5
    80002e2c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002e30:	000010ef          	jal	80003e30 <log_write>
  brelse(bp);
    80002e34:	854a                	mv	a0,s2
    80002e36:	ec5ff0ef          	jal	80002cfa <brelse>
}
    80002e3a:	60e2                	ld	ra,24(sp)
    80002e3c:	6442                	ld	s0,16(sp)
    80002e3e:	64a2                	ld	s1,8(sp)
    80002e40:	6902                	ld	s2,0(sp)
    80002e42:	6105                	addi	sp,sp,32
    80002e44:	8082                	ret
    panic("freeing free block");
    80002e46:	00004517          	auipc	a0,0x4
    80002e4a:	58250513          	addi	a0,a0,1410 # 800073c8 <etext+0x3c8>
    80002e4e:	9d7fd0ef          	jal	80000824 <panic>

0000000080002e52 <balloc>:
{
    80002e52:	715d                	addi	sp,sp,-80
    80002e54:	e486                	sd	ra,72(sp)
    80002e56:	e0a2                	sd	s0,64(sp)
    80002e58:	fc26                	sd	s1,56(sp)
    80002e5a:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80002e5c:	0001b797          	auipc	a5,0x1b
    80002e60:	2187a783          	lw	a5,536(a5) # 8001e074 <sb+0x4>
    80002e64:	0e078263          	beqz	a5,80002f48 <balloc+0xf6>
    80002e68:	f84a                	sd	s2,48(sp)
    80002e6a:	f44e                	sd	s3,40(sp)
    80002e6c:	f052                	sd	s4,32(sp)
    80002e6e:	ec56                	sd	s5,24(sp)
    80002e70:	e85a                	sd	s6,16(sp)
    80002e72:	e45e                	sd	s7,8(sp)
    80002e74:	e062                	sd	s8,0(sp)
    80002e76:	8baa                	mv	s7,a0
    80002e78:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e7a:	0001bb17          	auipc	s6,0x1b
    80002e7e:	1f6b0b13          	addi	s6,s6,502 # 8001e070 <sb>
      m = 1 << (bi % 8);
    80002e82:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e84:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002e86:	6c09                	lui	s8,0x2
    80002e88:	a09d                	j	80002eee <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002e8a:	97ca                	add	a5,a5,s2
    80002e8c:	8e55                	or	a2,a2,a3
    80002e8e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e92:	854a                	mv	a0,s2
    80002e94:	79d000ef          	jal	80003e30 <log_write>
        brelse(bp);
    80002e98:	854a                	mv	a0,s2
    80002e9a:	e61ff0ef          	jal	80002cfa <brelse>
  bp = bread(dev, bno);
    80002e9e:	85a6                	mv	a1,s1
    80002ea0:	855e                	mv	a0,s7
    80002ea2:	d51ff0ef          	jal	80002bf2 <bread>
    80002ea6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002ea8:	40000613          	li	a2,1024
    80002eac:	4581                	li	a1,0
    80002eae:	05850513          	addi	a0,a0,88
    80002eb2:	e47fd0ef          	jal	80000cf8 <memset>
  log_write(bp);
    80002eb6:	854a                	mv	a0,s2
    80002eb8:	779000ef          	jal	80003e30 <log_write>
  brelse(bp);
    80002ebc:	854a                	mv	a0,s2
    80002ebe:	e3dff0ef          	jal	80002cfa <brelse>
}
    80002ec2:	7942                	ld	s2,48(sp)
    80002ec4:	79a2                	ld	s3,40(sp)
    80002ec6:	7a02                	ld	s4,32(sp)
    80002ec8:	6ae2                	ld	s5,24(sp)
    80002eca:	6b42                	ld	s6,16(sp)
    80002ecc:	6ba2                	ld	s7,8(sp)
    80002ece:	6c02                	ld	s8,0(sp)
}
    80002ed0:	8526                	mv	a0,s1
    80002ed2:	60a6                	ld	ra,72(sp)
    80002ed4:	6406                	ld	s0,64(sp)
    80002ed6:	74e2                	ld	s1,56(sp)
    80002ed8:	6161                	addi	sp,sp,80
    80002eda:	8082                	ret
    brelse(bp);
    80002edc:	854a                	mv	a0,s2
    80002ede:	e1dff0ef          	jal	80002cfa <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002ee2:	015c0abb          	addw	s5,s8,s5
    80002ee6:	004b2783          	lw	a5,4(s6)
    80002eea:	04faf863          	bgeu	s5,a5,80002f3a <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002eee:	40dad59b          	sraiw	a1,s5,0xd
    80002ef2:	01cb2783          	lw	a5,28(s6)
    80002ef6:	9dbd                	addw	a1,a1,a5
    80002ef8:	855e                	mv	a0,s7
    80002efa:	cf9ff0ef          	jal	80002bf2 <bread>
    80002efe:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f00:	004b2503          	lw	a0,4(s6)
    80002f04:	84d6                	mv	s1,s5
    80002f06:	4701                	li	a4,0
    80002f08:	fca4fae3          	bgeu	s1,a0,80002edc <balloc+0x8a>
      m = 1 << (bi % 8);
    80002f0c:	00777693          	andi	a3,a4,7
    80002f10:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002f14:	41f7579b          	sraiw	a5,a4,0x1f
    80002f18:	01d7d79b          	srliw	a5,a5,0x1d
    80002f1c:	9fb9                	addw	a5,a5,a4
    80002f1e:	4037d79b          	sraiw	a5,a5,0x3
    80002f22:	00f90633          	add	a2,s2,a5
    80002f26:	05864603          	lbu	a2,88(a2)
    80002f2a:	00c6f5b3          	and	a1,a3,a2
    80002f2e:	ddb1                	beqz	a1,80002e8a <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f30:	2705                	addiw	a4,a4,1
    80002f32:	2485                	addiw	s1,s1,1
    80002f34:	fd471ae3          	bne	a4,s4,80002f08 <balloc+0xb6>
    80002f38:	b755                	j	80002edc <balloc+0x8a>
    80002f3a:	7942                	ld	s2,48(sp)
    80002f3c:	79a2                	ld	s3,40(sp)
    80002f3e:	7a02                	ld	s4,32(sp)
    80002f40:	6ae2                	ld	s5,24(sp)
    80002f42:	6b42                	ld	s6,16(sp)
    80002f44:	6ba2                	ld	s7,8(sp)
    80002f46:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80002f48:	00004517          	auipc	a0,0x4
    80002f4c:	49850513          	addi	a0,a0,1176 # 800073e0 <etext+0x3e0>
    80002f50:	daafd0ef          	jal	800004fa <printf>
  return 0;
    80002f54:	4481                	li	s1,0
    80002f56:	bfad                	j	80002ed0 <balloc+0x7e>

0000000080002f58 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f58:	7179                	addi	sp,sp,-48
    80002f5a:	f406                	sd	ra,40(sp)
    80002f5c:	f022                	sd	s0,32(sp)
    80002f5e:	ec26                	sd	s1,24(sp)
    80002f60:	e84a                	sd	s2,16(sp)
    80002f62:	e44e                	sd	s3,8(sp)
    80002f64:	1800                	addi	s0,sp,48
    80002f66:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002f68:	47ad                	li	a5,11
    80002f6a:	02b7e363          	bltu	a5,a1,80002f90 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80002f6e:	02059793          	slli	a5,a1,0x20
    80002f72:	01e7d593          	srli	a1,a5,0x1e
    80002f76:	00b509b3          	add	s3,a0,a1
    80002f7a:	0509a483          	lw	s1,80(s3)
    80002f7e:	e0b5                	bnez	s1,80002fe2 <bmap+0x8a>
      addr = balloc(ip->dev);
    80002f80:	4108                	lw	a0,0(a0)
    80002f82:	ed1ff0ef          	jal	80002e52 <balloc>
    80002f86:	84aa                	mv	s1,a0
      if(addr == 0)
    80002f88:	cd29                	beqz	a0,80002fe2 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80002f8a:	04a9a823          	sw	a0,80(s3)
    80002f8e:	a891                	j	80002fe2 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f90:	ff45879b          	addiw	a5,a1,-12
    80002f94:	873e                	mv	a4,a5
    80002f96:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    80002f98:	0ff00793          	li	a5,255
    80002f9c:	06e7e763          	bltu	a5,a4,8000300a <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002fa0:	08052483          	lw	s1,128(a0)
    80002fa4:	e891                	bnez	s1,80002fb8 <bmap+0x60>
      addr = balloc(ip->dev);
    80002fa6:	4108                	lw	a0,0(a0)
    80002fa8:	eabff0ef          	jal	80002e52 <balloc>
    80002fac:	84aa                	mv	s1,a0
      if(addr == 0)
    80002fae:	c915                	beqz	a0,80002fe2 <bmap+0x8a>
    80002fb0:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002fb2:	08a92023          	sw	a0,128(s2)
    80002fb6:	a011                	j	80002fba <bmap+0x62>
    80002fb8:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002fba:	85a6                	mv	a1,s1
    80002fbc:	00092503          	lw	a0,0(s2)
    80002fc0:	c33ff0ef          	jal	80002bf2 <bread>
    80002fc4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002fc6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002fca:	02099713          	slli	a4,s3,0x20
    80002fce:	01e75593          	srli	a1,a4,0x1e
    80002fd2:	97ae                	add	a5,a5,a1
    80002fd4:	89be                	mv	s3,a5
    80002fd6:	4384                	lw	s1,0(a5)
    80002fd8:	cc89                	beqz	s1,80002ff2 <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002fda:	8552                	mv	a0,s4
    80002fdc:	d1fff0ef          	jal	80002cfa <brelse>
    return addr;
    80002fe0:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002fe2:	8526                	mv	a0,s1
    80002fe4:	70a2                	ld	ra,40(sp)
    80002fe6:	7402                	ld	s0,32(sp)
    80002fe8:	64e2                	ld	s1,24(sp)
    80002fea:	6942                	ld	s2,16(sp)
    80002fec:	69a2                	ld	s3,8(sp)
    80002fee:	6145                	addi	sp,sp,48
    80002ff0:	8082                	ret
      addr = balloc(ip->dev);
    80002ff2:	00092503          	lw	a0,0(s2)
    80002ff6:	e5dff0ef          	jal	80002e52 <balloc>
    80002ffa:	84aa                	mv	s1,a0
      if(addr){
    80002ffc:	dd79                	beqz	a0,80002fda <bmap+0x82>
        a[bn] = addr;
    80002ffe:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003002:	8552                	mv	a0,s4
    80003004:	62d000ef          	jal	80003e30 <log_write>
    80003008:	bfc9                	j	80002fda <bmap+0x82>
    8000300a:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000300c:	00004517          	auipc	a0,0x4
    80003010:	3ec50513          	addi	a0,a0,1004 # 800073f8 <etext+0x3f8>
    80003014:	811fd0ef          	jal	80000824 <panic>

0000000080003018 <iget>:
{
    80003018:	7179                	addi	sp,sp,-48
    8000301a:	f406                	sd	ra,40(sp)
    8000301c:	f022                	sd	s0,32(sp)
    8000301e:	ec26                	sd	s1,24(sp)
    80003020:	e84a                	sd	s2,16(sp)
    80003022:	e44e                	sd	s3,8(sp)
    80003024:	e052                	sd	s4,0(sp)
    80003026:	1800                	addi	s0,sp,48
    80003028:	892a                	mv	s2,a0
    8000302a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000302c:	0001b517          	auipc	a0,0x1b
    80003030:	06450513          	addi	a0,a0,100 # 8001e090 <itable>
    80003034:	bf5fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    80003038:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000303a:	0001b497          	auipc	s1,0x1b
    8000303e:	06e48493          	addi	s1,s1,110 # 8001e0a8 <itable+0x18>
    80003042:	0001d697          	auipc	a3,0x1d
    80003046:	af668693          	addi	a3,a3,-1290 # 8001fb38 <log>
    8000304a:	a809                	j	8000305c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000304c:	e781                	bnez	a5,80003054 <iget+0x3c>
    8000304e:	00099363          	bnez	s3,80003054 <iget+0x3c>
      empty = ip;
    80003052:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003054:	08848493          	addi	s1,s1,136
    80003058:	02d48563          	beq	s1,a3,80003082 <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000305c:	449c                	lw	a5,8(s1)
    8000305e:	fef057e3          	blez	a5,8000304c <iget+0x34>
    80003062:	4098                	lw	a4,0(s1)
    80003064:	ff2718e3          	bne	a4,s2,80003054 <iget+0x3c>
    80003068:	40d8                	lw	a4,4(s1)
    8000306a:	ff4715e3          	bne	a4,s4,80003054 <iget+0x3c>
      ip->ref++;
    8000306e:	2785                	addiw	a5,a5,1
    80003070:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003072:	0001b517          	auipc	a0,0x1b
    80003076:	01e50513          	addi	a0,a0,30 # 8001e090 <itable>
    8000307a:	c43fd0ef          	jal	80000cbc <release>
      return ip;
    8000307e:	89a6                	mv	s3,s1
    80003080:	a015                	j	800030a4 <iget+0x8c>
  if(empty == 0)
    80003082:	02098a63          	beqz	s3,800030b6 <iget+0x9e>
  ip->dev = dev;
    80003086:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000308a:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    8000308e:	4785                	li	a5,1
    80003090:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003094:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003098:	0001b517          	auipc	a0,0x1b
    8000309c:	ff850513          	addi	a0,a0,-8 # 8001e090 <itable>
    800030a0:	c1dfd0ef          	jal	80000cbc <release>
}
    800030a4:	854e                	mv	a0,s3
    800030a6:	70a2                	ld	ra,40(sp)
    800030a8:	7402                	ld	s0,32(sp)
    800030aa:	64e2                	ld	s1,24(sp)
    800030ac:	6942                	ld	s2,16(sp)
    800030ae:	69a2                	ld	s3,8(sp)
    800030b0:	6a02                	ld	s4,0(sp)
    800030b2:	6145                	addi	sp,sp,48
    800030b4:	8082                	ret
    panic("iget: no inodes");
    800030b6:	00004517          	auipc	a0,0x4
    800030ba:	35a50513          	addi	a0,a0,858 # 80007410 <etext+0x410>
    800030be:	f66fd0ef          	jal	80000824 <panic>

00000000800030c2 <iinit>:
{
    800030c2:	7179                	addi	sp,sp,-48
    800030c4:	f406                	sd	ra,40(sp)
    800030c6:	f022                	sd	s0,32(sp)
    800030c8:	ec26                	sd	s1,24(sp)
    800030ca:	e84a                	sd	s2,16(sp)
    800030cc:	e44e                	sd	s3,8(sp)
    800030ce:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800030d0:	00004597          	auipc	a1,0x4
    800030d4:	35058593          	addi	a1,a1,848 # 80007420 <etext+0x420>
    800030d8:	0001b517          	auipc	a0,0x1b
    800030dc:	fb850513          	addi	a0,a0,-72 # 8001e090 <itable>
    800030e0:	abffd0ef          	jal	80000b9e <initlock>
  for(i = 0; i < NINODE; i++) {
    800030e4:	0001b497          	auipc	s1,0x1b
    800030e8:	fd448493          	addi	s1,s1,-44 # 8001e0b8 <itable+0x28>
    800030ec:	0001d997          	auipc	s3,0x1d
    800030f0:	a5c98993          	addi	s3,s3,-1444 # 8001fb48 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800030f4:	00004917          	auipc	s2,0x4
    800030f8:	33490913          	addi	s2,s2,820 # 80007428 <etext+0x428>
    800030fc:	85ca                	mv	a1,s2
    800030fe:	8526                	mv	a0,s1
    80003100:	5f5000ef          	jal	80003ef4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003104:	08848493          	addi	s1,s1,136
    80003108:	ff349ae3          	bne	s1,s3,800030fc <iinit+0x3a>
}
    8000310c:	70a2                	ld	ra,40(sp)
    8000310e:	7402                	ld	s0,32(sp)
    80003110:	64e2                	ld	s1,24(sp)
    80003112:	6942                	ld	s2,16(sp)
    80003114:	69a2                	ld	s3,8(sp)
    80003116:	6145                	addi	sp,sp,48
    80003118:	8082                	ret

000000008000311a <ialloc>:
{
    8000311a:	7139                	addi	sp,sp,-64
    8000311c:	fc06                	sd	ra,56(sp)
    8000311e:	f822                	sd	s0,48(sp)
    80003120:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003122:	0001b717          	auipc	a4,0x1b
    80003126:	f5a72703          	lw	a4,-166(a4) # 8001e07c <sb+0xc>
    8000312a:	4785                	li	a5,1
    8000312c:	06e7f063          	bgeu	a5,a4,8000318c <ialloc+0x72>
    80003130:	f426                	sd	s1,40(sp)
    80003132:	f04a                	sd	s2,32(sp)
    80003134:	ec4e                	sd	s3,24(sp)
    80003136:	e852                	sd	s4,16(sp)
    80003138:	e456                	sd	s5,8(sp)
    8000313a:	e05a                	sd	s6,0(sp)
    8000313c:	8aaa                	mv	s5,a0
    8000313e:	8b2e                	mv	s6,a1
    80003140:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003142:	0001ba17          	auipc	s4,0x1b
    80003146:	f2ea0a13          	addi	s4,s4,-210 # 8001e070 <sb>
    8000314a:	00495593          	srli	a1,s2,0x4
    8000314e:	018a2783          	lw	a5,24(s4)
    80003152:	9dbd                	addw	a1,a1,a5
    80003154:	8556                	mv	a0,s5
    80003156:	a9dff0ef          	jal	80002bf2 <bread>
    8000315a:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000315c:	05850993          	addi	s3,a0,88
    80003160:	00f97793          	andi	a5,s2,15
    80003164:	079a                	slli	a5,a5,0x6
    80003166:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003168:	00099783          	lh	a5,0(s3)
    8000316c:	cb9d                	beqz	a5,800031a2 <ialloc+0x88>
    brelse(bp);
    8000316e:	b8dff0ef          	jal	80002cfa <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003172:	0905                	addi	s2,s2,1
    80003174:	00ca2703          	lw	a4,12(s4)
    80003178:	0009079b          	sext.w	a5,s2
    8000317c:	fce7e7e3          	bltu	a5,a4,8000314a <ialloc+0x30>
    80003180:	74a2                	ld	s1,40(sp)
    80003182:	7902                	ld	s2,32(sp)
    80003184:	69e2                	ld	s3,24(sp)
    80003186:	6a42                	ld	s4,16(sp)
    80003188:	6aa2                	ld	s5,8(sp)
    8000318a:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000318c:	00004517          	auipc	a0,0x4
    80003190:	2a450513          	addi	a0,a0,676 # 80007430 <etext+0x430>
    80003194:	b66fd0ef          	jal	800004fa <printf>
  return 0;
    80003198:	4501                	li	a0,0
}
    8000319a:	70e2                	ld	ra,56(sp)
    8000319c:	7442                	ld	s0,48(sp)
    8000319e:	6121                	addi	sp,sp,64
    800031a0:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800031a2:	04000613          	li	a2,64
    800031a6:	4581                	li	a1,0
    800031a8:	854e                	mv	a0,s3
    800031aa:	b4ffd0ef          	jal	80000cf8 <memset>
      dip->type = type;
    800031ae:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800031b2:	8526                	mv	a0,s1
    800031b4:	47d000ef          	jal	80003e30 <log_write>
      brelse(bp);
    800031b8:	8526                	mv	a0,s1
    800031ba:	b41ff0ef          	jal	80002cfa <brelse>
      return iget(dev, inum);
    800031be:	0009059b          	sext.w	a1,s2
    800031c2:	8556                	mv	a0,s5
    800031c4:	e55ff0ef          	jal	80003018 <iget>
    800031c8:	74a2                	ld	s1,40(sp)
    800031ca:	7902                	ld	s2,32(sp)
    800031cc:	69e2                	ld	s3,24(sp)
    800031ce:	6a42                	ld	s4,16(sp)
    800031d0:	6aa2                	ld	s5,8(sp)
    800031d2:	6b02                	ld	s6,0(sp)
    800031d4:	b7d9                	j	8000319a <ialloc+0x80>

00000000800031d6 <iupdate>:
{
    800031d6:	1101                	addi	sp,sp,-32
    800031d8:	ec06                	sd	ra,24(sp)
    800031da:	e822                	sd	s0,16(sp)
    800031dc:	e426                	sd	s1,8(sp)
    800031de:	e04a                	sd	s2,0(sp)
    800031e0:	1000                	addi	s0,sp,32
    800031e2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800031e4:	415c                	lw	a5,4(a0)
    800031e6:	0047d79b          	srliw	a5,a5,0x4
    800031ea:	0001b597          	auipc	a1,0x1b
    800031ee:	e9e5a583          	lw	a1,-354(a1) # 8001e088 <sb+0x18>
    800031f2:	9dbd                	addw	a1,a1,a5
    800031f4:	4108                	lw	a0,0(a0)
    800031f6:	9fdff0ef          	jal	80002bf2 <bread>
    800031fa:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800031fc:	05850793          	addi	a5,a0,88
    80003200:	40d8                	lw	a4,4(s1)
    80003202:	8b3d                	andi	a4,a4,15
    80003204:	071a                	slli	a4,a4,0x6
    80003206:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003208:	04449703          	lh	a4,68(s1)
    8000320c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003210:	04649703          	lh	a4,70(s1)
    80003214:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003218:	04849703          	lh	a4,72(s1)
    8000321c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003220:	04a49703          	lh	a4,74(s1)
    80003224:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003228:	44f8                	lw	a4,76(s1)
    8000322a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000322c:	03400613          	li	a2,52
    80003230:	05048593          	addi	a1,s1,80
    80003234:	00c78513          	addi	a0,a5,12
    80003238:	b21fd0ef          	jal	80000d58 <memmove>
  log_write(bp);
    8000323c:	854a                	mv	a0,s2
    8000323e:	3f3000ef          	jal	80003e30 <log_write>
  brelse(bp);
    80003242:	854a                	mv	a0,s2
    80003244:	ab7ff0ef          	jal	80002cfa <brelse>
}
    80003248:	60e2                	ld	ra,24(sp)
    8000324a:	6442                	ld	s0,16(sp)
    8000324c:	64a2                	ld	s1,8(sp)
    8000324e:	6902                	ld	s2,0(sp)
    80003250:	6105                	addi	sp,sp,32
    80003252:	8082                	ret

0000000080003254 <idup>:
{
    80003254:	1101                	addi	sp,sp,-32
    80003256:	ec06                	sd	ra,24(sp)
    80003258:	e822                	sd	s0,16(sp)
    8000325a:	e426                	sd	s1,8(sp)
    8000325c:	1000                	addi	s0,sp,32
    8000325e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003260:	0001b517          	auipc	a0,0x1b
    80003264:	e3050513          	addi	a0,a0,-464 # 8001e090 <itable>
    80003268:	9c1fd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    8000326c:	449c                	lw	a5,8(s1)
    8000326e:	2785                	addiw	a5,a5,1
    80003270:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003272:	0001b517          	auipc	a0,0x1b
    80003276:	e1e50513          	addi	a0,a0,-482 # 8001e090 <itable>
    8000327a:	a43fd0ef          	jal	80000cbc <release>
}
    8000327e:	8526                	mv	a0,s1
    80003280:	60e2                	ld	ra,24(sp)
    80003282:	6442                	ld	s0,16(sp)
    80003284:	64a2                	ld	s1,8(sp)
    80003286:	6105                	addi	sp,sp,32
    80003288:	8082                	ret

000000008000328a <ilock>:
{
    8000328a:	1101                	addi	sp,sp,-32
    8000328c:	ec06                	sd	ra,24(sp)
    8000328e:	e822                	sd	s0,16(sp)
    80003290:	e426                	sd	s1,8(sp)
    80003292:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003294:	cd19                	beqz	a0,800032b2 <ilock+0x28>
    80003296:	84aa                	mv	s1,a0
    80003298:	451c                	lw	a5,8(a0)
    8000329a:	00f05c63          	blez	a5,800032b2 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000329e:	0541                	addi	a0,a0,16
    800032a0:	48b000ef          	jal	80003f2a <acquiresleep>
  if(ip->valid == 0){
    800032a4:	40bc                	lw	a5,64(s1)
    800032a6:	cf89                	beqz	a5,800032c0 <ilock+0x36>
}
    800032a8:	60e2                	ld	ra,24(sp)
    800032aa:	6442                	ld	s0,16(sp)
    800032ac:	64a2                	ld	s1,8(sp)
    800032ae:	6105                	addi	sp,sp,32
    800032b0:	8082                	ret
    800032b2:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800032b4:	00004517          	auipc	a0,0x4
    800032b8:	19450513          	addi	a0,a0,404 # 80007448 <etext+0x448>
    800032bc:	d68fd0ef          	jal	80000824 <panic>
    800032c0:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032c2:	40dc                	lw	a5,4(s1)
    800032c4:	0047d79b          	srliw	a5,a5,0x4
    800032c8:	0001b597          	auipc	a1,0x1b
    800032cc:	dc05a583          	lw	a1,-576(a1) # 8001e088 <sb+0x18>
    800032d0:	9dbd                	addw	a1,a1,a5
    800032d2:	4088                	lw	a0,0(s1)
    800032d4:	91fff0ef          	jal	80002bf2 <bread>
    800032d8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800032da:	05850593          	addi	a1,a0,88
    800032de:	40dc                	lw	a5,4(s1)
    800032e0:	8bbd                	andi	a5,a5,15
    800032e2:	079a                	slli	a5,a5,0x6
    800032e4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800032e6:	00059783          	lh	a5,0(a1)
    800032ea:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800032ee:	00259783          	lh	a5,2(a1)
    800032f2:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800032f6:	00459783          	lh	a5,4(a1)
    800032fa:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800032fe:	00659783          	lh	a5,6(a1)
    80003302:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003306:	459c                	lw	a5,8(a1)
    80003308:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000330a:	03400613          	li	a2,52
    8000330e:	05b1                	addi	a1,a1,12
    80003310:	05048513          	addi	a0,s1,80
    80003314:	a45fd0ef          	jal	80000d58 <memmove>
    brelse(bp);
    80003318:	854a                	mv	a0,s2
    8000331a:	9e1ff0ef          	jal	80002cfa <brelse>
    ip->valid = 1;
    8000331e:	4785                	li	a5,1
    80003320:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003322:	04449783          	lh	a5,68(s1)
    80003326:	c399                	beqz	a5,8000332c <ilock+0xa2>
    80003328:	6902                	ld	s2,0(sp)
    8000332a:	bfbd                	j	800032a8 <ilock+0x1e>
      panic("ilock: no type");
    8000332c:	00004517          	auipc	a0,0x4
    80003330:	12450513          	addi	a0,a0,292 # 80007450 <etext+0x450>
    80003334:	cf0fd0ef          	jal	80000824 <panic>

0000000080003338 <iunlock>:
{
    80003338:	1101                	addi	sp,sp,-32
    8000333a:	ec06                	sd	ra,24(sp)
    8000333c:	e822                	sd	s0,16(sp)
    8000333e:	e426                	sd	s1,8(sp)
    80003340:	e04a                	sd	s2,0(sp)
    80003342:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003344:	c505                	beqz	a0,8000336c <iunlock+0x34>
    80003346:	84aa                	mv	s1,a0
    80003348:	01050913          	addi	s2,a0,16
    8000334c:	854a                	mv	a0,s2
    8000334e:	45b000ef          	jal	80003fa8 <holdingsleep>
    80003352:	cd09                	beqz	a0,8000336c <iunlock+0x34>
    80003354:	449c                	lw	a5,8(s1)
    80003356:	00f05b63          	blez	a5,8000336c <iunlock+0x34>
  releasesleep(&ip->lock);
    8000335a:	854a                	mv	a0,s2
    8000335c:	415000ef          	jal	80003f70 <releasesleep>
}
    80003360:	60e2                	ld	ra,24(sp)
    80003362:	6442                	ld	s0,16(sp)
    80003364:	64a2                	ld	s1,8(sp)
    80003366:	6902                	ld	s2,0(sp)
    80003368:	6105                	addi	sp,sp,32
    8000336a:	8082                	ret
    panic("iunlock");
    8000336c:	00004517          	auipc	a0,0x4
    80003370:	0f450513          	addi	a0,a0,244 # 80007460 <etext+0x460>
    80003374:	cb0fd0ef          	jal	80000824 <panic>

0000000080003378 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003378:	7179                	addi	sp,sp,-48
    8000337a:	f406                	sd	ra,40(sp)
    8000337c:	f022                	sd	s0,32(sp)
    8000337e:	ec26                	sd	s1,24(sp)
    80003380:	e84a                	sd	s2,16(sp)
    80003382:	e44e                	sd	s3,8(sp)
    80003384:	1800                	addi	s0,sp,48
    80003386:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003388:	05050493          	addi	s1,a0,80
    8000338c:	08050913          	addi	s2,a0,128
    80003390:	a021                	j	80003398 <itrunc+0x20>
    80003392:	0491                	addi	s1,s1,4
    80003394:	01248b63          	beq	s1,s2,800033aa <itrunc+0x32>
    if(ip->addrs[i]){
    80003398:	408c                	lw	a1,0(s1)
    8000339a:	dde5                	beqz	a1,80003392 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000339c:	0009a503          	lw	a0,0(s3)
    800033a0:	a47ff0ef          	jal	80002de6 <bfree>
      ip->addrs[i] = 0;
    800033a4:	0004a023          	sw	zero,0(s1)
    800033a8:	b7ed                	j	80003392 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800033aa:	0809a583          	lw	a1,128(s3)
    800033ae:	ed89                	bnez	a1,800033c8 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800033b0:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800033b4:	854e                	mv	a0,s3
    800033b6:	e21ff0ef          	jal	800031d6 <iupdate>
}
    800033ba:	70a2                	ld	ra,40(sp)
    800033bc:	7402                	ld	s0,32(sp)
    800033be:	64e2                	ld	s1,24(sp)
    800033c0:	6942                	ld	s2,16(sp)
    800033c2:	69a2                	ld	s3,8(sp)
    800033c4:	6145                	addi	sp,sp,48
    800033c6:	8082                	ret
    800033c8:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800033ca:	0009a503          	lw	a0,0(s3)
    800033ce:	825ff0ef          	jal	80002bf2 <bread>
    800033d2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800033d4:	05850493          	addi	s1,a0,88
    800033d8:	45850913          	addi	s2,a0,1112
    800033dc:	a021                	j	800033e4 <itrunc+0x6c>
    800033de:	0491                	addi	s1,s1,4
    800033e0:	01248963          	beq	s1,s2,800033f2 <itrunc+0x7a>
      if(a[j])
    800033e4:	408c                	lw	a1,0(s1)
    800033e6:	dde5                	beqz	a1,800033de <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800033e8:	0009a503          	lw	a0,0(s3)
    800033ec:	9fbff0ef          	jal	80002de6 <bfree>
    800033f0:	b7fd                	j	800033de <itrunc+0x66>
    brelse(bp);
    800033f2:	8552                	mv	a0,s4
    800033f4:	907ff0ef          	jal	80002cfa <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800033f8:	0809a583          	lw	a1,128(s3)
    800033fc:	0009a503          	lw	a0,0(s3)
    80003400:	9e7ff0ef          	jal	80002de6 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003404:	0809a023          	sw	zero,128(s3)
    80003408:	6a02                	ld	s4,0(sp)
    8000340a:	b75d                	j	800033b0 <itrunc+0x38>

000000008000340c <iput>:
{
    8000340c:	1101                	addi	sp,sp,-32
    8000340e:	ec06                	sd	ra,24(sp)
    80003410:	e822                	sd	s0,16(sp)
    80003412:	e426                	sd	s1,8(sp)
    80003414:	1000                	addi	s0,sp,32
    80003416:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003418:	0001b517          	auipc	a0,0x1b
    8000341c:	c7850513          	addi	a0,a0,-904 # 8001e090 <itable>
    80003420:	809fd0ef          	jal	80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003424:	4498                	lw	a4,8(s1)
    80003426:	4785                	li	a5,1
    80003428:	02f70063          	beq	a4,a5,80003448 <iput+0x3c>
  ip->ref--;
    8000342c:	449c                	lw	a5,8(s1)
    8000342e:	37fd                	addiw	a5,a5,-1
    80003430:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003432:	0001b517          	auipc	a0,0x1b
    80003436:	c5e50513          	addi	a0,a0,-930 # 8001e090 <itable>
    8000343a:	883fd0ef          	jal	80000cbc <release>
}
    8000343e:	60e2                	ld	ra,24(sp)
    80003440:	6442                	ld	s0,16(sp)
    80003442:	64a2                	ld	s1,8(sp)
    80003444:	6105                	addi	sp,sp,32
    80003446:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003448:	40bc                	lw	a5,64(s1)
    8000344a:	d3ed                	beqz	a5,8000342c <iput+0x20>
    8000344c:	04a49783          	lh	a5,74(s1)
    80003450:	fff1                	bnez	a5,8000342c <iput+0x20>
    80003452:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003454:	01048793          	addi	a5,s1,16
    80003458:	893e                	mv	s2,a5
    8000345a:	853e                	mv	a0,a5
    8000345c:	2cf000ef          	jal	80003f2a <acquiresleep>
    release(&itable.lock);
    80003460:	0001b517          	auipc	a0,0x1b
    80003464:	c3050513          	addi	a0,a0,-976 # 8001e090 <itable>
    80003468:	855fd0ef          	jal	80000cbc <release>
    itrunc(ip);
    8000346c:	8526                	mv	a0,s1
    8000346e:	f0bff0ef          	jal	80003378 <itrunc>
    ip->type = 0;
    80003472:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003476:	8526                	mv	a0,s1
    80003478:	d5fff0ef          	jal	800031d6 <iupdate>
    ip->valid = 0;
    8000347c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003480:	854a                	mv	a0,s2
    80003482:	2ef000ef          	jal	80003f70 <releasesleep>
    acquire(&itable.lock);
    80003486:	0001b517          	auipc	a0,0x1b
    8000348a:	c0a50513          	addi	a0,a0,-1014 # 8001e090 <itable>
    8000348e:	f9afd0ef          	jal	80000c28 <acquire>
    80003492:	6902                	ld	s2,0(sp)
    80003494:	bf61                	j	8000342c <iput+0x20>

0000000080003496 <iunlockput>:
{
    80003496:	1101                	addi	sp,sp,-32
    80003498:	ec06                	sd	ra,24(sp)
    8000349a:	e822                	sd	s0,16(sp)
    8000349c:	e426                	sd	s1,8(sp)
    8000349e:	1000                	addi	s0,sp,32
    800034a0:	84aa                	mv	s1,a0
  iunlock(ip);
    800034a2:	e97ff0ef          	jal	80003338 <iunlock>
  iput(ip);
    800034a6:	8526                	mv	a0,s1
    800034a8:	f65ff0ef          	jal	8000340c <iput>
}
    800034ac:	60e2                	ld	ra,24(sp)
    800034ae:	6442                	ld	s0,16(sp)
    800034b0:	64a2                	ld	s1,8(sp)
    800034b2:	6105                	addi	sp,sp,32
    800034b4:	8082                	ret

00000000800034b6 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034b6:	0001b717          	auipc	a4,0x1b
    800034ba:	bc672703          	lw	a4,-1082(a4) # 8001e07c <sb+0xc>
    800034be:	4785                	li	a5,1
    800034c0:	0ae7fe63          	bgeu	a5,a4,8000357c <ireclaim+0xc6>
{
    800034c4:	7139                	addi	sp,sp,-64
    800034c6:	fc06                	sd	ra,56(sp)
    800034c8:	f822                	sd	s0,48(sp)
    800034ca:	f426                	sd	s1,40(sp)
    800034cc:	f04a                	sd	s2,32(sp)
    800034ce:	ec4e                	sd	s3,24(sp)
    800034d0:	e852                	sd	s4,16(sp)
    800034d2:	e456                	sd	s5,8(sp)
    800034d4:	e05a                	sd	s6,0(sp)
    800034d6:	0080                	addi	s0,sp,64
    800034d8:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034da:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800034dc:	0001ba17          	auipc	s4,0x1b
    800034e0:	b94a0a13          	addi	s4,s4,-1132 # 8001e070 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800034e4:	00004b17          	auipc	s6,0x4
    800034e8:	f84b0b13          	addi	s6,s6,-124 # 80007468 <etext+0x468>
    800034ec:	a099                	j	80003532 <ireclaim+0x7c>
    800034ee:	85ce                	mv	a1,s3
    800034f0:	855a                	mv	a0,s6
    800034f2:	808fd0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    800034f6:	85ce                	mv	a1,s3
    800034f8:	8556                	mv	a0,s5
    800034fa:	b1fff0ef          	jal	80003018 <iget>
    800034fe:	89aa                	mv	s3,a0
    brelse(bp);
    80003500:	854a                	mv	a0,s2
    80003502:	ff8ff0ef          	jal	80002cfa <brelse>
    if (ip) {
    80003506:	00098f63          	beqz	s3,80003524 <ireclaim+0x6e>
      begin_op();
    8000350a:	78c000ef          	jal	80003c96 <begin_op>
      ilock(ip);
    8000350e:	854e                	mv	a0,s3
    80003510:	d7bff0ef          	jal	8000328a <ilock>
      iunlock(ip);
    80003514:	854e                	mv	a0,s3
    80003516:	e23ff0ef          	jal	80003338 <iunlock>
      iput(ip);
    8000351a:	854e                	mv	a0,s3
    8000351c:	ef1ff0ef          	jal	8000340c <iput>
      end_op();
    80003520:	7e6000ef          	jal	80003d06 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003524:	0485                	addi	s1,s1,1
    80003526:	00ca2703          	lw	a4,12(s4)
    8000352a:	0004879b          	sext.w	a5,s1
    8000352e:	02e7fd63          	bgeu	a5,a4,80003568 <ireclaim+0xb2>
    80003532:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003536:	0044d593          	srli	a1,s1,0x4
    8000353a:	018a2783          	lw	a5,24(s4)
    8000353e:	9dbd                	addw	a1,a1,a5
    80003540:	8556                	mv	a0,s5
    80003542:	eb0ff0ef          	jal	80002bf2 <bread>
    80003546:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003548:	05850793          	addi	a5,a0,88
    8000354c:	00f9f713          	andi	a4,s3,15
    80003550:	071a                	slli	a4,a4,0x6
    80003552:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003554:	00079703          	lh	a4,0(a5)
    80003558:	c701                	beqz	a4,80003560 <ireclaim+0xaa>
    8000355a:	00679783          	lh	a5,6(a5)
    8000355e:	dbc1                	beqz	a5,800034ee <ireclaim+0x38>
    brelse(bp);
    80003560:	854a                	mv	a0,s2
    80003562:	f98ff0ef          	jal	80002cfa <brelse>
    if (ip) {
    80003566:	bf7d                	j	80003524 <ireclaim+0x6e>
}
    80003568:	70e2                	ld	ra,56(sp)
    8000356a:	7442                	ld	s0,48(sp)
    8000356c:	74a2                	ld	s1,40(sp)
    8000356e:	7902                	ld	s2,32(sp)
    80003570:	69e2                	ld	s3,24(sp)
    80003572:	6a42                	ld	s4,16(sp)
    80003574:	6aa2                	ld	s5,8(sp)
    80003576:	6b02                	ld	s6,0(sp)
    80003578:	6121                	addi	sp,sp,64
    8000357a:	8082                	ret
    8000357c:	8082                	ret

000000008000357e <fsinit>:
fsinit(int dev) {
    8000357e:	1101                	addi	sp,sp,-32
    80003580:	ec06                	sd	ra,24(sp)
    80003582:	e822                	sd	s0,16(sp)
    80003584:	e426                	sd	s1,8(sp)
    80003586:	e04a                	sd	s2,0(sp)
    80003588:	1000                	addi	s0,sp,32
    8000358a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000358c:	4585                	li	a1,1
    8000358e:	e64ff0ef          	jal	80002bf2 <bread>
    80003592:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003594:	02000613          	li	a2,32
    80003598:	05850593          	addi	a1,a0,88
    8000359c:	0001b517          	auipc	a0,0x1b
    800035a0:	ad450513          	addi	a0,a0,-1324 # 8001e070 <sb>
    800035a4:	fb4fd0ef          	jal	80000d58 <memmove>
  brelse(bp);
    800035a8:	8526                	mv	a0,s1
    800035aa:	f50ff0ef          	jal	80002cfa <brelse>
  if(sb.magic != FSMAGIC)
    800035ae:	0001b717          	auipc	a4,0x1b
    800035b2:	ac272703          	lw	a4,-1342(a4) # 8001e070 <sb>
    800035b6:	102037b7          	lui	a5,0x10203
    800035ba:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800035be:	02f71263          	bne	a4,a5,800035e2 <fsinit+0x64>
  initlog(dev, &sb);
    800035c2:	0001b597          	auipc	a1,0x1b
    800035c6:	aae58593          	addi	a1,a1,-1362 # 8001e070 <sb>
    800035ca:	854a                	mv	a0,s2
    800035cc:	648000ef          	jal	80003c14 <initlog>
  ireclaim(dev);
    800035d0:	854a                	mv	a0,s2
    800035d2:	ee5ff0ef          	jal	800034b6 <ireclaim>
}
    800035d6:	60e2                	ld	ra,24(sp)
    800035d8:	6442                	ld	s0,16(sp)
    800035da:	64a2                	ld	s1,8(sp)
    800035dc:	6902                	ld	s2,0(sp)
    800035de:	6105                	addi	sp,sp,32
    800035e0:	8082                	ret
    panic("invalid file system");
    800035e2:	00004517          	auipc	a0,0x4
    800035e6:	ea650513          	addi	a0,a0,-346 # 80007488 <etext+0x488>
    800035ea:	a3afd0ef          	jal	80000824 <panic>

00000000800035ee <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800035ee:	1141                	addi	sp,sp,-16
    800035f0:	e406                	sd	ra,8(sp)
    800035f2:	e022                	sd	s0,0(sp)
    800035f4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800035f6:	411c                	lw	a5,0(a0)
    800035f8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800035fa:	415c                	lw	a5,4(a0)
    800035fc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800035fe:	04451783          	lh	a5,68(a0)
    80003602:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003606:	04a51783          	lh	a5,74(a0)
    8000360a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000360e:	04c56783          	lwu	a5,76(a0)
    80003612:	e99c                	sd	a5,16(a1)
}
    80003614:	60a2                	ld	ra,8(sp)
    80003616:	6402                	ld	s0,0(sp)
    80003618:	0141                	addi	sp,sp,16
    8000361a:	8082                	ret

000000008000361c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000361c:	457c                	lw	a5,76(a0)
    8000361e:	0ed7e663          	bltu	a5,a3,8000370a <readi+0xee>
{
    80003622:	7159                	addi	sp,sp,-112
    80003624:	f486                	sd	ra,104(sp)
    80003626:	f0a2                	sd	s0,96(sp)
    80003628:	eca6                	sd	s1,88(sp)
    8000362a:	e0d2                	sd	s4,64(sp)
    8000362c:	fc56                	sd	s5,56(sp)
    8000362e:	f85a                	sd	s6,48(sp)
    80003630:	f45e                	sd	s7,40(sp)
    80003632:	1880                	addi	s0,sp,112
    80003634:	8b2a                	mv	s6,a0
    80003636:	8bae                	mv	s7,a1
    80003638:	8a32                	mv	s4,a2
    8000363a:	84b6                	mv	s1,a3
    8000363c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000363e:	9f35                	addw	a4,a4,a3
    return 0;
    80003640:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003642:	0ad76b63          	bltu	a4,a3,800036f8 <readi+0xdc>
    80003646:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003648:	00e7f463          	bgeu	a5,a4,80003650 <readi+0x34>
    n = ip->size - off;
    8000364c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003650:	080a8b63          	beqz	s5,800036e6 <readi+0xca>
    80003654:	e8ca                	sd	s2,80(sp)
    80003656:	f062                	sd	s8,32(sp)
    80003658:	ec66                	sd	s9,24(sp)
    8000365a:	e86a                	sd	s10,16(sp)
    8000365c:	e46e                	sd	s11,8(sp)
    8000365e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003660:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003664:	5c7d                	li	s8,-1
    80003666:	a80d                	j	80003698 <readi+0x7c>
    80003668:	020d1d93          	slli	s11,s10,0x20
    8000366c:	020ddd93          	srli	s11,s11,0x20
    80003670:	05890613          	addi	a2,s2,88
    80003674:	86ee                	mv	a3,s11
    80003676:	963e                	add	a2,a2,a5
    80003678:	85d2                	mv	a1,s4
    8000367a:	855e                	mv	a0,s7
    8000367c:	c1dfe0ef          	jal	80002298 <either_copyout>
    80003680:	05850363          	beq	a0,s8,800036c6 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003684:	854a                	mv	a0,s2
    80003686:	e74ff0ef          	jal	80002cfa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000368a:	013d09bb          	addw	s3,s10,s3
    8000368e:	009d04bb          	addw	s1,s10,s1
    80003692:	9a6e                	add	s4,s4,s11
    80003694:	0559f363          	bgeu	s3,s5,800036da <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003698:	00a4d59b          	srliw	a1,s1,0xa
    8000369c:	855a                	mv	a0,s6
    8000369e:	8bbff0ef          	jal	80002f58 <bmap>
    800036a2:	85aa                	mv	a1,a0
    if(addr == 0)
    800036a4:	c139                	beqz	a0,800036ea <readi+0xce>
    bp = bread(ip->dev, addr);
    800036a6:	000b2503          	lw	a0,0(s6)
    800036aa:	d48ff0ef          	jal	80002bf2 <bread>
    800036ae:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800036b0:	3ff4f793          	andi	a5,s1,1023
    800036b4:	40fc873b          	subw	a4,s9,a5
    800036b8:	413a86bb          	subw	a3,s5,s3
    800036bc:	8d3a                	mv	s10,a4
    800036be:	fae6f5e3          	bgeu	a3,a4,80003668 <readi+0x4c>
    800036c2:	8d36                	mv	s10,a3
    800036c4:	b755                	j	80003668 <readi+0x4c>
      brelse(bp);
    800036c6:	854a                	mv	a0,s2
    800036c8:	e32ff0ef          	jal	80002cfa <brelse>
      tot = -1;
    800036cc:	59fd                	li	s3,-1
      break;
    800036ce:	6946                	ld	s2,80(sp)
    800036d0:	7c02                	ld	s8,32(sp)
    800036d2:	6ce2                	ld	s9,24(sp)
    800036d4:	6d42                	ld	s10,16(sp)
    800036d6:	6da2                	ld	s11,8(sp)
    800036d8:	a831                	j	800036f4 <readi+0xd8>
    800036da:	6946                	ld	s2,80(sp)
    800036dc:	7c02                	ld	s8,32(sp)
    800036de:	6ce2                	ld	s9,24(sp)
    800036e0:	6d42                	ld	s10,16(sp)
    800036e2:	6da2                	ld	s11,8(sp)
    800036e4:	a801                	j	800036f4 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800036e6:	89d6                	mv	s3,s5
    800036e8:	a031                	j	800036f4 <readi+0xd8>
    800036ea:	6946                	ld	s2,80(sp)
    800036ec:	7c02                	ld	s8,32(sp)
    800036ee:	6ce2                	ld	s9,24(sp)
    800036f0:	6d42                	ld	s10,16(sp)
    800036f2:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800036f4:	854e                	mv	a0,s3
    800036f6:	69a6                	ld	s3,72(sp)
}
    800036f8:	70a6                	ld	ra,104(sp)
    800036fa:	7406                	ld	s0,96(sp)
    800036fc:	64e6                	ld	s1,88(sp)
    800036fe:	6a06                	ld	s4,64(sp)
    80003700:	7ae2                	ld	s5,56(sp)
    80003702:	7b42                	ld	s6,48(sp)
    80003704:	7ba2                	ld	s7,40(sp)
    80003706:	6165                	addi	sp,sp,112
    80003708:	8082                	ret
    return 0;
    8000370a:	4501                	li	a0,0
}
    8000370c:	8082                	ret

000000008000370e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000370e:	457c                	lw	a5,76(a0)
    80003710:	0ed7eb63          	bltu	a5,a3,80003806 <writei+0xf8>
{
    80003714:	7159                	addi	sp,sp,-112
    80003716:	f486                	sd	ra,104(sp)
    80003718:	f0a2                	sd	s0,96(sp)
    8000371a:	e8ca                	sd	s2,80(sp)
    8000371c:	e0d2                	sd	s4,64(sp)
    8000371e:	fc56                	sd	s5,56(sp)
    80003720:	f85a                	sd	s6,48(sp)
    80003722:	f45e                	sd	s7,40(sp)
    80003724:	1880                	addi	s0,sp,112
    80003726:	8aaa                	mv	s5,a0
    80003728:	8bae                	mv	s7,a1
    8000372a:	8a32                	mv	s4,a2
    8000372c:	8936                	mv	s2,a3
    8000372e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003730:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003734:	00043737          	lui	a4,0x43
    80003738:	0cf76963          	bltu	a4,a5,8000380a <writei+0xfc>
    8000373c:	0cd7e763          	bltu	a5,a3,8000380a <writei+0xfc>
    80003740:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003742:	0a0b0a63          	beqz	s6,800037f6 <writei+0xe8>
    80003746:	eca6                	sd	s1,88(sp)
    80003748:	f062                	sd	s8,32(sp)
    8000374a:	ec66                	sd	s9,24(sp)
    8000374c:	e86a                	sd	s10,16(sp)
    8000374e:	e46e                	sd	s11,8(sp)
    80003750:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003752:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003756:	5c7d                	li	s8,-1
    80003758:	a825                	j	80003790 <writei+0x82>
    8000375a:	020d1d93          	slli	s11,s10,0x20
    8000375e:	020ddd93          	srli	s11,s11,0x20
    80003762:	05848513          	addi	a0,s1,88
    80003766:	86ee                	mv	a3,s11
    80003768:	8652                	mv	a2,s4
    8000376a:	85de                	mv	a1,s7
    8000376c:	953e                	add	a0,a0,a5
    8000376e:	b75fe0ef          	jal	800022e2 <either_copyin>
    80003772:	05850663          	beq	a0,s8,800037be <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003776:	8526                	mv	a0,s1
    80003778:	6b8000ef          	jal	80003e30 <log_write>
    brelse(bp);
    8000377c:	8526                	mv	a0,s1
    8000377e:	d7cff0ef          	jal	80002cfa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003782:	013d09bb          	addw	s3,s10,s3
    80003786:	012d093b          	addw	s2,s10,s2
    8000378a:	9a6e                	add	s4,s4,s11
    8000378c:	0369fc63          	bgeu	s3,s6,800037c4 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003790:	00a9559b          	srliw	a1,s2,0xa
    80003794:	8556                	mv	a0,s5
    80003796:	fc2ff0ef          	jal	80002f58 <bmap>
    8000379a:	85aa                	mv	a1,a0
    if(addr == 0)
    8000379c:	c505                	beqz	a0,800037c4 <writei+0xb6>
    bp = bread(ip->dev, addr);
    8000379e:	000aa503          	lw	a0,0(s5)
    800037a2:	c50ff0ef          	jal	80002bf2 <bread>
    800037a6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800037a8:	3ff97793          	andi	a5,s2,1023
    800037ac:	40fc873b          	subw	a4,s9,a5
    800037b0:	413b06bb          	subw	a3,s6,s3
    800037b4:	8d3a                	mv	s10,a4
    800037b6:	fae6f2e3          	bgeu	a3,a4,8000375a <writei+0x4c>
    800037ba:	8d36                	mv	s10,a3
    800037bc:	bf79                	j	8000375a <writei+0x4c>
      brelse(bp);
    800037be:	8526                	mv	a0,s1
    800037c0:	d3aff0ef          	jal	80002cfa <brelse>
  }

  if(off > ip->size)
    800037c4:	04caa783          	lw	a5,76(s5)
    800037c8:	0327f963          	bgeu	a5,s2,800037fa <writei+0xec>
    ip->size = off;
    800037cc:	052aa623          	sw	s2,76(s5)
    800037d0:	64e6                	ld	s1,88(sp)
    800037d2:	7c02                	ld	s8,32(sp)
    800037d4:	6ce2                	ld	s9,24(sp)
    800037d6:	6d42                	ld	s10,16(sp)
    800037d8:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800037da:	8556                	mv	a0,s5
    800037dc:	9fbff0ef          	jal	800031d6 <iupdate>

  return tot;
    800037e0:	854e                	mv	a0,s3
    800037e2:	69a6                	ld	s3,72(sp)
}
    800037e4:	70a6                	ld	ra,104(sp)
    800037e6:	7406                	ld	s0,96(sp)
    800037e8:	6946                	ld	s2,80(sp)
    800037ea:	6a06                	ld	s4,64(sp)
    800037ec:	7ae2                	ld	s5,56(sp)
    800037ee:	7b42                	ld	s6,48(sp)
    800037f0:	7ba2                	ld	s7,40(sp)
    800037f2:	6165                	addi	sp,sp,112
    800037f4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800037f6:	89da                	mv	s3,s6
    800037f8:	b7cd                	j	800037da <writei+0xcc>
    800037fa:	64e6                	ld	s1,88(sp)
    800037fc:	7c02                	ld	s8,32(sp)
    800037fe:	6ce2                	ld	s9,24(sp)
    80003800:	6d42                	ld	s10,16(sp)
    80003802:	6da2                	ld	s11,8(sp)
    80003804:	bfd9                	j	800037da <writei+0xcc>
    return -1;
    80003806:	557d                	li	a0,-1
}
    80003808:	8082                	ret
    return -1;
    8000380a:	557d                	li	a0,-1
    8000380c:	bfe1                	j	800037e4 <writei+0xd6>

000000008000380e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000380e:	1141                	addi	sp,sp,-16
    80003810:	e406                	sd	ra,8(sp)
    80003812:	e022                	sd	s0,0(sp)
    80003814:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003816:	4639                	li	a2,14
    80003818:	db4fd0ef          	jal	80000dcc <strncmp>
}
    8000381c:	60a2                	ld	ra,8(sp)
    8000381e:	6402                	ld	s0,0(sp)
    80003820:	0141                	addi	sp,sp,16
    80003822:	8082                	ret

0000000080003824 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003824:	711d                	addi	sp,sp,-96
    80003826:	ec86                	sd	ra,88(sp)
    80003828:	e8a2                	sd	s0,80(sp)
    8000382a:	e4a6                	sd	s1,72(sp)
    8000382c:	e0ca                	sd	s2,64(sp)
    8000382e:	fc4e                	sd	s3,56(sp)
    80003830:	f852                	sd	s4,48(sp)
    80003832:	f456                	sd	s5,40(sp)
    80003834:	f05a                	sd	s6,32(sp)
    80003836:	ec5e                	sd	s7,24(sp)
    80003838:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000383a:	04451703          	lh	a4,68(a0)
    8000383e:	4785                	li	a5,1
    80003840:	00f71f63          	bne	a4,a5,8000385e <dirlookup+0x3a>
    80003844:	892a                	mv	s2,a0
    80003846:	8aae                	mv	s5,a1
    80003848:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000384a:	457c                	lw	a5,76(a0)
    8000384c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000384e:	fa040a13          	addi	s4,s0,-96
    80003852:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003854:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003858:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000385a:	e39d                	bnez	a5,80003880 <dirlookup+0x5c>
    8000385c:	a8b9                	j	800038ba <dirlookup+0x96>
    panic("dirlookup not DIR");
    8000385e:	00004517          	auipc	a0,0x4
    80003862:	c4250513          	addi	a0,a0,-958 # 800074a0 <etext+0x4a0>
    80003866:	fbffc0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    8000386a:	00004517          	auipc	a0,0x4
    8000386e:	c4e50513          	addi	a0,a0,-946 # 800074b8 <etext+0x4b8>
    80003872:	fb3fc0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003876:	24c1                	addiw	s1,s1,16
    80003878:	04c92783          	lw	a5,76(s2)
    8000387c:	02f4fe63          	bgeu	s1,a5,800038b8 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003880:	874e                	mv	a4,s3
    80003882:	86a6                	mv	a3,s1
    80003884:	8652                	mv	a2,s4
    80003886:	4581                	li	a1,0
    80003888:	854a                	mv	a0,s2
    8000388a:	d93ff0ef          	jal	8000361c <readi>
    8000388e:	fd351ee3          	bne	a0,s3,8000386a <dirlookup+0x46>
    if(de.inum == 0)
    80003892:	fa045783          	lhu	a5,-96(s0)
    80003896:	d3e5                	beqz	a5,80003876 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003898:	85da                	mv	a1,s6
    8000389a:	8556                	mv	a0,s5
    8000389c:	f73ff0ef          	jal	8000380e <namecmp>
    800038a0:	f979                	bnez	a0,80003876 <dirlookup+0x52>
      if(poff)
    800038a2:	000b8463          	beqz	s7,800038aa <dirlookup+0x86>
        *poff = off;
    800038a6:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800038aa:	fa045583          	lhu	a1,-96(s0)
    800038ae:	00092503          	lw	a0,0(s2)
    800038b2:	f66ff0ef          	jal	80003018 <iget>
    800038b6:	a011                	j	800038ba <dirlookup+0x96>
  return 0;
    800038b8:	4501                	li	a0,0
}
    800038ba:	60e6                	ld	ra,88(sp)
    800038bc:	6446                	ld	s0,80(sp)
    800038be:	64a6                	ld	s1,72(sp)
    800038c0:	6906                	ld	s2,64(sp)
    800038c2:	79e2                	ld	s3,56(sp)
    800038c4:	7a42                	ld	s4,48(sp)
    800038c6:	7aa2                	ld	s5,40(sp)
    800038c8:	7b02                	ld	s6,32(sp)
    800038ca:	6be2                	ld	s7,24(sp)
    800038cc:	6125                	addi	sp,sp,96
    800038ce:	8082                	ret

00000000800038d0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800038d0:	711d                	addi	sp,sp,-96
    800038d2:	ec86                	sd	ra,88(sp)
    800038d4:	e8a2                	sd	s0,80(sp)
    800038d6:	e4a6                	sd	s1,72(sp)
    800038d8:	e0ca                	sd	s2,64(sp)
    800038da:	fc4e                	sd	s3,56(sp)
    800038dc:	f852                	sd	s4,48(sp)
    800038de:	f456                	sd	s5,40(sp)
    800038e0:	f05a                	sd	s6,32(sp)
    800038e2:	ec5e                	sd	s7,24(sp)
    800038e4:	e862                	sd	s8,16(sp)
    800038e6:	e466                	sd	s9,8(sp)
    800038e8:	e06a                	sd	s10,0(sp)
    800038ea:	1080                	addi	s0,sp,96
    800038ec:	84aa                	mv	s1,a0
    800038ee:	8b2e                	mv	s6,a1
    800038f0:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800038f2:	00054703          	lbu	a4,0(a0)
    800038f6:	02f00793          	li	a5,47
    800038fa:	00f70f63          	beq	a4,a5,80003918 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800038fe:	830fe0ef          	jal	8000192e <myproc>
    80003902:	15053503          	ld	a0,336(a0)
    80003906:	94fff0ef          	jal	80003254 <idup>
    8000390a:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000390c:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003910:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003912:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003914:	4b85                	li	s7,1
    80003916:	a879                	j	800039b4 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003918:	4585                	li	a1,1
    8000391a:	852e                	mv	a0,a1
    8000391c:	efcff0ef          	jal	80003018 <iget>
    80003920:	8a2a                	mv	s4,a0
    80003922:	b7ed                	j	8000390c <namex+0x3c>
      iunlockput(ip);
    80003924:	8552                	mv	a0,s4
    80003926:	b71ff0ef          	jal	80003496 <iunlockput>
      return 0;
    8000392a:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000392c:	8552                	mv	a0,s4
    8000392e:	60e6                	ld	ra,88(sp)
    80003930:	6446                	ld	s0,80(sp)
    80003932:	64a6                	ld	s1,72(sp)
    80003934:	6906                	ld	s2,64(sp)
    80003936:	79e2                	ld	s3,56(sp)
    80003938:	7a42                	ld	s4,48(sp)
    8000393a:	7aa2                	ld	s5,40(sp)
    8000393c:	7b02                	ld	s6,32(sp)
    8000393e:	6be2                	ld	s7,24(sp)
    80003940:	6c42                	ld	s8,16(sp)
    80003942:	6ca2                	ld	s9,8(sp)
    80003944:	6d02                	ld	s10,0(sp)
    80003946:	6125                	addi	sp,sp,96
    80003948:	8082                	ret
      iunlock(ip);
    8000394a:	8552                	mv	a0,s4
    8000394c:	9edff0ef          	jal	80003338 <iunlock>
      return ip;
    80003950:	bff1                	j	8000392c <namex+0x5c>
      iunlockput(ip);
    80003952:	8552                	mv	a0,s4
    80003954:	b43ff0ef          	jal	80003496 <iunlockput>
      return 0;
    80003958:	8a4a                	mv	s4,s2
    8000395a:	bfc9                	j	8000392c <namex+0x5c>
  len = path - s;
    8000395c:	40990633          	sub	a2,s2,s1
    80003960:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003964:	09ac5463          	bge	s8,s10,800039ec <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80003968:	8666                	mv	a2,s9
    8000396a:	85a6                	mv	a1,s1
    8000396c:	8556                	mv	a0,s5
    8000396e:	beafd0ef          	jal	80000d58 <memmove>
    80003972:	84ca                	mv	s1,s2
  while(*path == '/')
    80003974:	0004c783          	lbu	a5,0(s1)
    80003978:	01379763          	bne	a5,s3,80003986 <namex+0xb6>
    path++;
    8000397c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000397e:	0004c783          	lbu	a5,0(s1)
    80003982:	ff378de3          	beq	a5,s3,8000397c <namex+0xac>
    ilock(ip);
    80003986:	8552                	mv	a0,s4
    80003988:	903ff0ef          	jal	8000328a <ilock>
    if(ip->type != T_DIR){
    8000398c:	044a1783          	lh	a5,68(s4)
    80003990:	f9779ae3          	bne	a5,s7,80003924 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003994:	000b0563          	beqz	s6,8000399e <namex+0xce>
    80003998:	0004c783          	lbu	a5,0(s1)
    8000399c:	d7dd                	beqz	a5,8000394a <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000399e:	4601                	li	a2,0
    800039a0:	85d6                	mv	a1,s5
    800039a2:	8552                	mv	a0,s4
    800039a4:	e81ff0ef          	jal	80003824 <dirlookup>
    800039a8:	892a                	mv	s2,a0
    800039aa:	d545                	beqz	a0,80003952 <namex+0x82>
    iunlockput(ip);
    800039ac:	8552                	mv	a0,s4
    800039ae:	ae9ff0ef          	jal	80003496 <iunlockput>
    ip = next;
    800039b2:	8a4a                	mv	s4,s2
  while(*path == '/')
    800039b4:	0004c783          	lbu	a5,0(s1)
    800039b8:	01379763          	bne	a5,s3,800039c6 <namex+0xf6>
    path++;
    800039bc:	0485                	addi	s1,s1,1
  while(*path == '/')
    800039be:	0004c783          	lbu	a5,0(s1)
    800039c2:	ff378de3          	beq	a5,s3,800039bc <namex+0xec>
  if(*path == 0)
    800039c6:	cf8d                	beqz	a5,80003a00 <namex+0x130>
  while(*path != '/' && *path != 0)
    800039c8:	0004c783          	lbu	a5,0(s1)
    800039cc:	fd178713          	addi	a4,a5,-47
    800039d0:	cb19                	beqz	a4,800039e6 <namex+0x116>
    800039d2:	cb91                	beqz	a5,800039e6 <namex+0x116>
    800039d4:	8926                	mv	s2,s1
    path++;
    800039d6:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    800039d8:	00094783          	lbu	a5,0(s2)
    800039dc:	fd178713          	addi	a4,a5,-47
    800039e0:	df35                	beqz	a4,8000395c <namex+0x8c>
    800039e2:	fbf5                	bnez	a5,800039d6 <namex+0x106>
    800039e4:	bfa5                	j	8000395c <namex+0x8c>
    800039e6:	8926                	mv	s2,s1
  len = path - s;
    800039e8:	4d01                	li	s10,0
    800039ea:	4601                	li	a2,0
    memmove(name, s, len);
    800039ec:	2601                	sext.w	a2,a2
    800039ee:	85a6                	mv	a1,s1
    800039f0:	8556                	mv	a0,s5
    800039f2:	b66fd0ef          	jal	80000d58 <memmove>
    name[len] = 0;
    800039f6:	9d56                	add	s10,s10,s5
    800039f8:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffde288>
    800039fc:	84ca                	mv	s1,s2
    800039fe:	bf9d                	j	80003974 <namex+0xa4>
  if(nameiparent){
    80003a00:	f20b06e3          	beqz	s6,8000392c <namex+0x5c>
    iput(ip);
    80003a04:	8552                	mv	a0,s4
    80003a06:	a07ff0ef          	jal	8000340c <iput>
    return 0;
    80003a0a:	4a01                	li	s4,0
    80003a0c:	b705                	j	8000392c <namex+0x5c>

0000000080003a0e <dirlink>:
{
    80003a0e:	715d                	addi	sp,sp,-80
    80003a10:	e486                	sd	ra,72(sp)
    80003a12:	e0a2                	sd	s0,64(sp)
    80003a14:	f84a                	sd	s2,48(sp)
    80003a16:	ec56                	sd	s5,24(sp)
    80003a18:	e85a                	sd	s6,16(sp)
    80003a1a:	0880                	addi	s0,sp,80
    80003a1c:	892a                	mv	s2,a0
    80003a1e:	8aae                	mv	s5,a1
    80003a20:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003a22:	4601                	li	a2,0
    80003a24:	e01ff0ef          	jal	80003824 <dirlookup>
    80003a28:	ed1d                	bnez	a0,80003a66 <dirlink+0x58>
    80003a2a:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a2c:	04c92483          	lw	s1,76(s2)
    80003a30:	c4b9                	beqz	s1,80003a7e <dirlink+0x70>
    80003a32:	f44e                	sd	s3,40(sp)
    80003a34:	f052                	sd	s4,32(sp)
    80003a36:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a38:	fb040a13          	addi	s4,s0,-80
    80003a3c:	49c1                	li	s3,16
    80003a3e:	874e                	mv	a4,s3
    80003a40:	86a6                	mv	a3,s1
    80003a42:	8652                	mv	a2,s4
    80003a44:	4581                	li	a1,0
    80003a46:	854a                	mv	a0,s2
    80003a48:	bd5ff0ef          	jal	8000361c <readi>
    80003a4c:	03351163          	bne	a0,s3,80003a6e <dirlink+0x60>
    if(de.inum == 0)
    80003a50:	fb045783          	lhu	a5,-80(s0)
    80003a54:	c39d                	beqz	a5,80003a7a <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a56:	24c1                	addiw	s1,s1,16
    80003a58:	04c92783          	lw	a5,76(s2)
    80003a5c:	fef4e1e3          	bltu	s1,a5,80003a3e <dirlink+0x30>
    80003a60:	79a2                	ld	s3,40(sp)
    80003a62:	7a02                	ld	s4,32(sp)
    80003a64:	a829                	j	80003a7e <dirlink+0x70>
    iput(ip);
    80003a66:	9a7ff0ef          	jal	8000340c <iput>
    return -1;
    80003a6a:	557d                	li	a0,-1
    80003a6c:	a83d                	j	80003aaa <dirlink+0x9c>
      panic("dirlink read");
    80003a6e:	00004517          	auipc	a0,0x4
    80003a72:	a5a50513          	addi	a0,a0,-1446 # 800074c8 <etext+0x4c8>
    80003a76:	daffc0ef          	jal	80000824 <panic>
    80003a7a:	79a2                	ld	s3,40(sp)
    80003a7c:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003a7e:	4639                	li	a2,14
    80003a80:	85d6                	mv	a1,s5
    80003a82:	fb240513          	addi	a0,s0,-78
    80003a86:	b80fd0ef          	jal	80000e06 <strncpy>
  de.inum = inum;
    80003a8a:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a8e:	4741                	li	a4,16
    80003a90:	86a6                	mv	a3,s1
    80003a92:	fb040613          	addi	a2,s0,-80
    80003a96:	4581                	li	a1,0
    80003a98:	854a                	mv	a0,s2
    80003a9a:	c75ff0ef          	jal	8000370e <writei>
    80003a9e:	1541                	addi	a0,a0,-16
    80003aa0:	00a03533          	snez	a0,a0
    80003aa4:	40a0053b          	negw	a0,a0
    80003aa8:	74e2                	ld	s1,56(sp)
}
    80003aaa:	60a6                	ld	ra,72(sp)
    80003aac:	6406                	ld	s0,64(sp)
    80003aae:	7942                	ld	s2,48(sp)
    80003ab0:	6ae2                	ld	s5,24(sp)
    80003ab2:	6b42                	ld	s6,16(sp)
    80003ab4:	6161                	addi	sp,sp,80
    80003ab6:	8082                	ret

0000000080003ab8 <namei>:

struct inode*
namei(char *path)
{
    80003ab8:	1101                	addi	sp,sp,-32
    80003aba:	ec06                	sd	ra,24(sp)
    80003abc:	e822                	sd	s0,16(sp)
    80003abe:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ac0:	fe040613          	addi	a2,s0,-32
    80003ac4:	4581                	li	a1,0
    80003ac6:	e0bff0ef          	jal	800038d0 <namex>
}
    80003aca:	60e2                	ld	ra,24(sp)
    80003acc:	6442                	ld	s0,16(sp)
    80003ace:	6105                	addi	sp,sp,32
    80003ad0:	8082                	ret

0000000080003ad2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003ad2:	1141                	addi	sp,sp,-16
    80003ad4:	e406                	sd	ra,8(sp)
    80003ad6:	e022                	sd	s0,0(sp)
    80003ad8:	0800                	addi	s0,sp,16
    80003ada:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003adc:	4585                	li	a1,1
    80003ade:	df3ff0ef          	jal	800038d0 <namex>
}
    80003ae2:	60a2                	ld	ra,8(sp)
    80003ae4:	6402                	ld	s0,0(sp)
    80003ae6:	0141                	addi	sp,sp,16
    80003ae8:	8082                	ret

0000000080003aea <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003aea:	1101                	addi	sp,sp,-32
    80003aec:	ec06                	sd	ra,24(sp)
    80003aee:	e822                	sd	s0,16(sp)
    80003af0:	e426                	sd	s1,8(sp)
    80003af2:	e04a                	sd	s2,0(sp)
    80003af4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003af6:	0001c917          	auipc	s2,0x1c
    80003afa:	04290913          	addi	s2,s2,66 # 8001fb38 <log>
    80003afe:	01892583          	lw	a1,24(s2)
    80003b02:	02492503          	lw	a0,36(s2)
    80003b06:	8ecff0ef          	jal	80002bf2 <bread>
    80003b0a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003b0c:	02892603          	lw	a2,40(s2)
    80003b10:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b12:	00c05f63          	blez	a2,80003b30 <write_head+0x46>
    80003b16:	0001c717          	auipc	a4,0x1c
    80003b1a:	04e70713          	addi	a4,a4,78 # 8001fb64 <log+0x2c>
    80003b1e:	87aa                	mv	a5,a0
    80003b20:	060a                	slli	a2,a2,0x2
    80003b22:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003b24:	4314                	lw	a3,0(a4)
    80003b26:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003b28:	0711                	addi	a4,a4,4
    80003b2a:	0791                	addi	a5,a5,4
    80003b2c:	fec79ce3          	bne	a5,a2,80003b24 <write_head+0x3a>
  }
  bwrite(buf);
    80003b30:	8526                	mv	a0,s1
    80003b32:	996ff0ef          	jal	80002cc8 <bwrite>
  brelse(buf);
    80003b36:	8526                	mv	a0,s1
    80003b38:	9c2ff0ef          	jal	80002cfa <brelse>
}
    80003b3c:	60e2                	ld	ra,24(sp)
    80003b3e:	6442                	ld	s0,16(sp)
    80003b40:	64a2                	ld	s1,8(sp)
    80003b42:	6902                	ld	s2,0(sp)
    80003b44:	6105                	addi	sp,sp,32
    80003b46:	8082                	ret

0000000080003b48 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b48:	0001c797          	auipc	a5,0x1c
    80003b4c:	0187a783          	lw	a5,24(a5) # 8001fb60 <log+0x28>
    80003b50:	0cf05163          	blez	a5,80003c12 <install_trans+0xca>
{
    80003b54:	715d                	addi	sp,sp,-80
    80003b56:	e486                	sd	ra,72(sp)
    80003b58:	e0a2                	sd	s0,64(sp)
    80003b5a:	fc26                	sd	s1,56(sp)
    80003b5c:	f84a                	sd	s2,48(sp)
    80003b5e:	f44e                	sd	s3,40(sp)
    80003b60:	f052                	sd	s4,32(sp)
    80003b62:	ec56                	sd	s5,24(sp)
    80003b64:	e85a                	sd	s6,16(sp)
    80003b66:	e45e                	sd	s7,8(sp)
    80003b68:	e062                	sd	s8,0(sp)
    80003b6a:	0880                	addi	s0,sp,80
    80003b6c:	8b2a                	mv	s6,a0
    80003b6e:	0001ca97          	auipc	s5,0x1c
    80003b72:	ff6a8a93          	addi	s5,s5,-10 # 8001fb64 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b76:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b78:	00004c17          	auipc	s8,0x4
    80003b7c:	960c0c13          	addi	s8,s8,-1696 # 800074d8 <etext+0x4d8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003b80:	0001ca17          	auipc	s4,0x1c
    80003b84:	fb8a0a13          	addi	s4,s4,-72 # 8001fb38 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003b88:	40000b93          	li	s7,1024
    80003b8c:	a025                	j	80003bb4 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b8e:	000aa603          	lw	a2,0(s5)
    80003b92:	85ce                	mv	a1,s3
    80003b94:	8562                	mv	a0,s8
    80003b96:	965fc0ef          	jal	800004fa <printf>
    80003b9a:	a839                	j	80003bb8 <install_trans+0x70>
    brelse(lbuf);
    80003b9c:	854a                	mv	a0,s2
    80003b9e:	95cff0ef          	jal	80002cfa <brelse>
    brelse(dbuf);
    80003ba2:	8526                	mv	a0,s1
    80003ba4:	956ff0ef          	jal	80002cfa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ba8:	2985                	addiw	s3,s3,1
    80003baa:	0a91                	addi	s5,s5,4
    80003bac:	028a2783          	lw	a5,40(s4)
    80003bb0:	04f9d563          	bge	s3,a5,80003bfa <install_trans+0xb2>
    if(recovering) {
    80003bb4:	fc0b1de3          	bnez	s6,80003b8e <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003bb8:	018a2583          	lw	a1,24(s4)
    80003bbc:	013585bb          	addw	a1,a1,s3
    80003bc0:	2585                	addiw	a1,a1,1
    80003bc2:	024a2503          	lw	a0,36(s4)
    80003bc6:	82cff0ef          	jal	80002bf2 <bread>
    80003bca:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003bcc:	000aa583          	lw	a1,0(s5)
    80003bd0:	024a2503          	lw	a0,36(s4)
    80003bd4:	81eff0ef          	jal	80002bf2 <bread>
    80003bd8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003bda:	865e                	mv	a2,s7
    80003bdc:	05890593          	addi	a1,s2,88
    80003be0:	05850513          	addi	a0,a0,88
    80003be4:	974fd0ef          	jal	80000d58 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003be8:	8526                	mv	a0,s1
    80003bea:	8deff0ef          	jal	80002cc8 <bwrite>
    if(recovering == 0)
    80003bee:	fa0b17e3          	bnez	s6,80003b9c <install_trans+0x54>
      bunpin(dbuf);
    80003bf2:	8526                	mv	a0,s1
    80003bf4:	9beff0ef          	jal	80002db2 <bunpin>
    80003bf8:	b755                	j	80003b9c <install_trans+0x54>
}
    80003bfa:	60a6                	ld	ra,72(sp)
    80003bfc:	6406                	ld	s0,64(sp)
    80003bfe:	74e2                	ld	s1,56(sp)
    80003c00:	7942                	ld	s2,48(sp)
    80003c02:	79a2                	ld	s3,40(sp)
    80003c04:	7a02                	ld	s4,32(sp)
    80003c06:	6ae2                	ld	s5,24(sp)
    80003c08:	6b42                	ld	s6,16(sp)
    80003c0a:	6ba2                	ld	s7,8(sp)
    80003c0c:	6c02                	ld	s8,0(sp)
    80003c0e:	6161                	addi	sp,sp,80
    80003c10:	8082                	ret
    80003c12:	8082                	ret

0000000080003c14 <initlog>:
{
    80003c14:	7179                	addi	sp,sp,-48
    80003c16:	f406                	sd	ra,40(sp)
    80003c18:	f022                	sd	s0,32(sp)
    80003c1a:	ec26                	sd	s1,24(sp)
    80003c1c:	e84a                	sd	s2,16(sp)
    80003c1e:	e44e                	sd	s3,8(sp)
    80003c20:	1800                	addi	s0,sp,48
    80003c22:	84aa                	mv	s1,a0
    80003c24:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003c26:	0001c917          	auipc	s2,0x1c
    80003c2a:	f1290913          	addi	s2,s2,-238 # 8001fb38 <log>
    80003c2e:	00004597          	auipc	a1,0x4
    80003c32:	8ca58593          	addi	a1,a1,-1846 # 800074f8 <etext+0x4f8>
    80003c36:	854a                	mv	a0,s2
    80003c38:	f67fc0ef          	jal	80000b9e <initlock>
  log.start = sb->logstart;
    80003c3c:	0149a583          	lw	a1,20(s3)
    80003c40:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003c44:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003c48:	8526                	mv	a0,s1
    80003c4a:	fa9fe0ef          	jal	80002bf2 <bread>
  log.lh.n = lh->n;
    80003c4e:	4d30                	lw	a2,88(a0)
    80003c50:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003c54:	00c05f63          	blez	a2,80003c72 <initlog+0x5e>
    80003c58:	87aa                	mv	a5,a0
    80003c5a:	0001c717          	auipc	a4,0x1c
    80003c5e:	f0a70713          	addi	a4,a4,-246 # 8001fb64 <log+0x2c>
    80003c62:	060a                	slli	a2,a2,0x2
    80003c64:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003c66:	4ff4                	lw	a3,92(a5)
    80003c68:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003c6a:	0791                	addi	a5,a5,4
    80003c6c:	0711                	addi	a4,a4,4
    80003c6e:	fec79ce3          	bne	a5,a2,80003c66 <initlog+0x52>
  brelse(buf);
    80003c72:	888ff0ef          	jal	80002cfa <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003c76:	4505                	li	a0,1
    80003c78:	ed1ff0ef          	jal	80003b48 <install_trans>
  log.lh.n = 0;
    80003c7c:	0001c797          	auipc	a5,0x1c
    80003c80:	ee07a223          	sw	zero,-284(a5) # 8001fb60 <log+0x28>
  write_head(); // clear the log
    80003c84:	e67ff0ef          	jal	80003aea <write_head>
}
    80003c88:	70a2                	ld	ra,40(sp)
    80003c8a:	7402                	ld	s0,32(sp)
    80003c8c:	64e2                	ld	s1,24(sp)
    80003c8e:	6942                	ld	s2,16(sp)
    80003c90:	69a2                	ld	s3,8(sp)
    80003c92:	6145                	addi	sp,sp,48
    80003c94:	8082                	ret

0000000080003c96 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003c96:	1101                	addi	sp,sp,-32
    80003c98:	ec06                	sd	ra,24(sp)
    80003c9a:	e822                	sd	s0,16(sp)
    80003c9c:	e426                	sd	s1,8(sp)
    80003c9e:	e04a                	sd	s2,0(sp)
    80003ca0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003ca2:	0001c517          	auipc	a0,0x1c
    80003ca6:	e9650513          	addi	a0,a0,-362 # 8001fb38 <log>
    80003caa:	f7ffc0ef          	jal	80000c28 <acquire>
  while(1){
    if(log.committing){
    80003cae:	0001c497          	auipc	s1,0x1c
    80003cb2:	e8a48493          	addi	s1,s1,-374 # 8001fb38 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003cb6:	4979                	li	s2,30
    80003cb8:	a029                	j	80003cc2 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003cba:	85a6                	mv	a1,s1
    80003cbc:	8526                	mv	a0,s1
    80003cbe:	a80fe0ef          	jal	80001f3e <sleep>
    if(log.committing){
    80003cc2:	509c                	lw	a5,32(s1)
    80003cc4:	fbfd                	bnez	a5,80003cba <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003cc6:	4cd8                	lw	a4,28(s1)
    80003cc8:	2705                	addiw	a4,a4,1
    80003cca:	0027179b          	slliw	a5,a4,0x2
    80003cce:	9fb9                	addw	a5,a5,a4
    80003cd0:	0017979b          	slliw	a5,a5,0x1
    80003cd4:	5494                	lw	a3,40(s1)
    80003cd6:	9fb5                	addw	a5,a5,a3
    80003cd8:	00f95763          	bge	s2,a5,80003ce6 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003cdc:	85a6                	mv	a1,s1
    80003cde:	8526                	mv	a0,s1
    80003ce0:	a5efe0ef          	jal	80001f3e <sleep>
    80003ce4:	bff9                	j	80003cc2 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003ce6:	0001c797          	auipc	a5,0x1c
    80003cea:	e6e7a723          	sw	a4,-402(a5) # 8001fb54 <log+0x1c>
      release(&log.lock);
    80003cee:	0001c517          	auipc	a0,0x1c
    80003cf2:	e4a50513          	addi	a0,a0,-438 # 8001fb38 <log>
    80003cf6:	fc7fc0ef          	jal	80000cbc <release>
      break;
    }
  }
}
    80003cfa:	60e2                	ld	ra,24(sp)
    80003cfc:	6442                	ld	s0,16(sp)
    80003cfe:	64a2                	ld	s1,8(sp)
    80003d00:	6902                	ld	s2,0(sp)
    80003d02:	6105                	addi	sp,sp,32
    80003d04:	8082                	ret

0000000080003d06 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003d06:	7139                	addi	sp,sp,-64
    80003d08:	fc06                	sd	ra,56(sp)
    80003d0a:	f822                	sd	s0,48(sp)
    80003d0c:	f426                	sd	s1,40(sp)
    80003d0e:	f04a                	sd	s2,32(sp)
    80003d10:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003d12:	0001c497          	auipc	s1,0x1c
    80003d16:	e2648493          	addi	s1,s1,-474 # 8001fb38 <log>
    80003d1a:	8526                	mv	a0,s1
    80003d1c:	f0dfc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003d20:	4cdc                	lw	a5,28(s1)
    80003d22:	37fd                	addiw	a5,a5,-1
    80003d24:	893e                	mv	s2,a5
    80003d26:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003d28:	509c                	lw	a5,32(s1)
    80003d2a:	e7b1                	bnez	a5,80003d76 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    80003d2c:	04091e63          	bnez	s2,80003d88 <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    80003d30:	0001c497          	auipc	s1,0x1c
    80003d34:	e0848493          	addi	s1,s1,-504 # 8001fb38 <log>
    80003d38:	4785                	li	a5,1
    80003d3a:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003d3c:	8526                	mv	a0,s1
    80003d3e:	f7ffc0ef          	jal	80000cbc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003d42:	549c                	lw	a5,40(s1)
    80003d44:	06f04463          	bgtz	a5,80003dac <end_op+0xa6>
    acquire(&log.lock);
    80003d48:	0001c517          	auipc	a0,0x1c
    80003d4c:	df050513          	addi	a0,a0,-528 # 8001fb38 <log>
    80003d50:	ed9fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003d54:	0001c797          	auipc	a5,0x1c
    80003d58:	e007a223          	sw	zero,-508(a5) # 8001fb58 <log+0x20>
    wakeup(&log);
    80003d5c:	0001c517          	auipc	a0,0x1c
    80003d60:	ddc50513          	addi	a0,a0,-548 # 8001fb38 <log>
    80003d64:	a26fe0ef          	jal	80001f8a <wakeup>
    release(&log.lock);
    80003d68:	0001c517          	auipc	a0,0x1c
    80003d6c:	dd050513          	addi	a0,a0,-560 # 8001fb38 <log>
    80003d70:	f4dfc0ef          	jal	80000cbc <release>
}
    80003d74:	a035                	j	80003da0 <end_op+0x9a>
    80003d76:	ec4e                	sd	s3,24(sp)
    80003d78:	e852                	sd	s4,16(sp)
    80003d7a:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003d7c:	00003517          	auipc	a0,0x3
    80003d80:	78450513          	addi	a0,a0,1924 # 80007500 <etext+0x500>
    80003d84:	aa1fc0ef          	jal	80000824 <panic>
    wakeup(&log);
    80003d88:	0001c517          	auipc	a0,0x1c
    80003d8c:	db050513          	addi	a0,a0,-592 # 8001fb38 <log>
    80003d90:	9fafe0ef          	jal	80001f8a <wakeup>
  release(&log.lock);
    80003d94:	0001c517          	auipc	a0,0x1c
    80003d98:	da450513          	addi	a0,a0,-604 # 8001fb38 <log>
    80003d9c:	f21fc0ef          	jal	80000cbc <release>
}
    80003da0:	70e2                	ld	ra,56(sp)
    80003da2:	7442                	ld	s0,48(sp)
    80003da4:	74a2                	ld	s1,40(sp)
    80003da6:	7902                	ld	s2,32(sp)
    80003da8:	6121                	addi	sp,sp,64
    80003daa:	8082                	ret
    80003dac:	ec4e                	sd	s3,24(sp)
    80003dae:	e852                	sd	s4,16(sp)
    80003db0:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003db2:	0001ca97          	auipc	s5,0x1c
    80003db6:	db2a8a93          	addi	s5,s5,-590 # 8001fb64 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003dba:	0001ca17          	auipc	s4,0x1c
    80003dbe:	d7ea0a13          	addi	s4,s4,-642 # 8001fb38 <log>
    80003dc2:	018a2583          	lw	a1,24(s4)
    80003dc6:	012585bb          	addw	a1,a1,s2
    80003dca:	2585                	addiw	a1,a1,1
    80003dcc:	024a2503          	lw	a0,36(s4)
    80003dd0:	e23fe0ef          	jal	80002bf2 <bread>
    80003dd4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003dd6:	000aa583          	lw	a1,0(s5)
    80003dda:	024a2503          	lw	a0,36(s4)
    80003dde:	e15fe0ef          	jal	80002bf2 <bread>
    80003de2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003de4:	40000613          	li	a2,1024
    80003de8:	05850593          	addi	a1,a0,88
    80003dec:	05848513          	addi	a0,s1,88
    80003df0:	f69fc0ef          	jal	80000d58 <memmove>
    bwrite(to);  // write the log
    80003df4:	8526                	mv	a0,s1
    80003df6:	ed3fe0ef          	jal	80002cc8 <bwrite>
    brelse(from);
    80003dfa:	854e                	mv	a0,s3
    80003dfc:	efffe0ef          	jal	80002cfa <brelse>
    brelse(to);
    80003e00:	8526                	mv	a0,s1
    80003e02:	ef9fe0ef          	jal	80002cfa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e06:	2905                	addiw	s2,s2,1
    80003e08:	0a91                	addi	s5,s5,4
    80003e0a:	028a2783          	lw	a5,40(s4)
    80003e0e:	faf94ae3          	blt	s2,a5,80003dc2 <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003e12:	cd9ff0ef          	jal	80003aea <write_head>
    install_trans(0); // Now install writes to home locations
    80003e16:	4501                	li	a0,0
    80003e18:	d31ff0ef          	jal	80003b48 <install_trans>
    log.lh.n = 0;
    80003e1c:	0001c797          	auipc	a5,0x1c
    80003e20:	d407a223          	sw	zero,-700(a5) # 8001fb60 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003e24:	cc7ff0ef          	jal	80003aea <write_head>
    80003e28:	69e2                	ld	s3,24(sp)
    80003e2a:	6a42                	ld	s4,16(sp)
    80003e2c:	6aa2                	ld	s5,8(sp)
    80003e2e:	bf29                	j	80003d48 <end_op+0x42>

0000000080003e30 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003e30:	1101                	addi	sp,sp,-32
    80003e32:	ec06                	sd	ra,24(sp)
    80003e34:	e822                	sd	s0,16(sp)
    80003e36:	e426                	sd	s1,8(sp)
    80003e38:	1000                	addi	s0,sp,32
    80003e3a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003e3c:	0001c517          	auipc	a0,0x1c
    80003e40:	cfc50513          	addi	a0,a0,-772 # 8001fb38 <log>
    80003e44:	de5fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003e48:	0001c617          	auipc	a2,0x1c
    80003e4c:	d1862603          	lw	a2,-744(a2) # 8001fb60 <log+0x28>
    80003e50:	47f5                	li	a5,29
    80003e52:	04c7cd63          	blt	a5,a2,80003eac <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003e56:	0001c797          	auipc	a5,0x1c
    80003e5a:	cfe7a783          	lw	a5,-770(a5) # 8001fb54 <log+0x1c>
    80003e5e:	04f05d63          	blez	a5,80003eb8 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003e62:	4781                	li	a5,0
    80003e64:	06c05063          	blez	a2,80003ec4 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e68:	44cc                	lw	a1,12(s1)
    80003e6a:	0001c717          	auipc	a4,0x1c
    80003e6e:	cfa70713          	addi	a4,a4,-774 # 8001fb64 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003e72:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e74:	4314                	lw	a3,0(a4)
    80003e76:	04b68763          	beq	a3,a1,80003ec4 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003e7a:	2785                	addiw	a5,a5,1
    80003e7c:	0711                	addi	a4,a4,4
    80003e7e:	fef61be3          	bne	a2,a5,80003e74 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003e82:	060a                	slli	a2,a2,0x2
    80003e84:	02060613          	addi	a2,a2,32
    80003e88:	0001c797          	auipc	a5,0x1c
    80003e8c:	cb078793          	addi	a5,a5,-848 # 8001fb38 <log>
    80003e90:	97b2                	add	a5,a5,a2
    80003e92:	44d8                	lw	a4,12(s1)
    80003e94:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003e96:	8526                	mv	a0,s1
    80003e98:	ee7fe0ef          	jal	80002d7e <bpin>
    log.lh.n++;
    80003e9c:	0001c717          	auipc	a4,0x1c
    80003ea0:	c9c70713          	addi	a4,a4,-868 # 8001fb38 <log>
    80003ea4:	571c                	lw	a5,40(a4)
    80003ea6:	2785                	addiw	a5,a5,1
    80003ea8:	d71c                	sw	a5,40(a4)
    80003eaa:	a815                	j	80003ede <log_write+0xae>
    panic("too big a transaction");
    80003eac:	00003517          	auipc	a0,0x3
    80003eb0:	66450513          	addi	a0,a0,1636 # 80007510 <etext+0x510>
    80003eb4:	971fc0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    80003eb8:	00003517          	auipc	a0,0x3
    80003ebc:	67050513          	addi	a0,a0,1648 # 80007528 <etext+0x528>
    80003ec0:	965fc0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    80003ec4:	00279693          	slli	a3,a5,0x2
    80003ec8:	02068693          	addi	a3,a3,32
    80003ecc:	0001c717          	auipc	a4,0x1c
    80003ed0:	c6c70713          	addi	a4,a4,-916 # 8001fb38 <log>
    80003ed4:	9736                	add	a4,a4,a3
    80003ed6:	44d4                	lw	a3,12(s1)
    80003ed8:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003eda:	faf60ee3          	beq	a2,a5,80003e96 <log_write+0x66>
  }
  release(&log.lock);
    80003ede:	0001c517          	auipc	a0,0x1c
    80003ee2:	c5a50513          	addi	a0,a0,-934 # 8001fb38 <log>
    80003ee6:	dd7fc0ef          	jal	80000cbc <release>
}
    80003eea:	60e2                	ld	ra,24(sp)
    80003eec:	6442                	ld	s0,16(sp)
    80003eee:	64a2                	ld	s1,8(sp)
    80003ef0:	6105                	addi	sp,sp,32
    80003ef2:	8082                	ret

0000000080003ef4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003ef4:	1101                	addi	sp,sp,-32
    80003ef6:	ec06                	sd	ra,24(sp)
    80003ef8:	e822                	sd	s0,16(sp)
    80003efa:	e426                	sd	s1,8(sp)
    80003efc:	e04a                	sd	s2,0(sp)
    80003efe:	1000                	addi	s0,sp,32
    80003f00:	84aa                	mv	s1,a0
    80003f02:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003f04:	00003597          	auipc	a1,0x3
    80003f08:	64458593          	addi	a1,a1,1604 # 80007548 <etext+0x548>
    80003f0c:	0521                	addi	a0,a0,8
    80003f0e:	c91fc0ef          	jal	80000b9e <initlock>
  lk->name = name;
    80003f12:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003f16:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f1a:	0204a423          	sw	zero,40(s1)
}
    80003f1e:	60e2                	ld	ra,24(sp)
    80003f20:	6442                	ld	s0,16(sp)
    80003f22:	64a2                	ld	s1,8(sp)
    80003f24:	6902                	ld	s2,0(sp)
    80003f26:	6105                	addi	sp,sp,32
    80003f28:	8082                	ret

0000000080003f2a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003f2a:	1101                	addi	sp,sp,-32
    80003f2c:	ec06                	sd	ra,24(sp)
    80003f2e:	e822                	sd	s0,16(sp)
    80003f30:	e426                	sd	s1,8(sp)
    80003f32:	e04a                	sd	s2,0(sp)
    80003f34:	1000                	addi	s0,sp,32
    80003f36:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f38:	00850913          	addi	s2,a0,8
    80003f3c:	854a                	mv	a0,s2
    80003f3e:	cebfc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80003f42:	409c                	lw	a5,0(s1)
    80003f44:	c799                	beqz	a5,80003f52 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003f46:	85ca                	mv	a1,s2
    80003f48:	8526                	mv	a0,s1
    80003f4a:	ff5fd0ef          	jal	80001f3e <sleep>
  while (lk->locked) {
    80003f4e:	409c                	lw	a5,0(s1)
    80003f50:	fbfd                	bnez	a5,80003f46 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003f52:	4785                	li	a5,1
    80003f54:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003f56:	9d9fd0ef          	jal	8000192e <myproc>
    80003f5a:	591c                	lw	a5,48(a0)
    80003f5c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003f5e:	854a                	mv	a0,s2
    80003f60:	d5dfc0ef          	jal	80000cbc <release>
}
    80003f64:	60e2                	ld	ra,24(sp)
    80003f66:	6442                	ld	s0,16(sp)
    80003f68:	64a2                	ld	s1,8(sp)
    80003f6a:	6902                	ld	s2,0(sp)
    80003f6c:	6105                	addi	sp,sp,32
    80003f6e:	8082                	ret

0000000080003f70 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003f70:	1101                	addi	sp,sp,-32
    80003f72:	ec06                	sd	ra,24(sp)
    80003f74:	e822                	sd	s0,16(sp)
    80003f76:	e426                	sd	s1,8(sp)
    80003f78:	e04a                	sd	s2,0(sp)
    80003f7a:	1000                	addi	s0,sp,32
    80003f7c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f7e:	00850913          	addi	s2,a0,8
    80003f82:	854a                	mv	a0,s2
    80003f84:	ca5fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    80003f88:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f8c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003f90:	8526                	mv	a0,s1
    80003f92:	ff9fd0ef          	jal	80001f8a <wakeup>
  release(&lk->lk);
    80003f96:	854a                	mv	a0,s2
    80003f98:	d25fc0ef          	jal	80000cbc <release>
}
    80003f9c:	60e2                	ld	ra,24(sp)
    80003f9e:	6442                	ld	s0,16(sp)
    80003fa0:	64a2                	ld	s1,8(sp)
    80003fa2:	6902                	ld	s2,0(sp)
    80003fa4:	6105                	addi	sp,sp,32
    80003fa6:	8082                	ret

0000000080003fa8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003fa8:	7179                	addi	sp,sp,-48
    80003faa:	f406                	sd	ra,40(sp)
    80003fac:	f022                	sd	s0,32(sp)
    80003fae:	ec26                	sd	s1,24(sp)
    80003fb0:	e84a                	sd	s2,16(sp)
    80003fb2:	1800                	addi	s0,sp,48
    80003fb4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003fb6:	00850913          	addi	s2,a0,8
    80003fba:	854a                	mv	a0,s2
    80003fbc:	c6dfc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003fc0:	409c                	lw	a5,0(s1)
    80003fc2:	ef81                	bnez	a5,80003fda <holdingsleep+0x32>
    80003fc4:	4481                	li	s1,0
  release(&lk->lk);
    80003fc6:	854a                	mv	a0,s2
    80003fc8:	cf5fc0ef          	jal	80000cbc <release>
  return r;
}
    80003fcc:	8526                	mv	a0,s1
    80003fce:	70a2                	ld	ra,40(sp)
    80003fd0:	7402                	ld	s0,32(sp)
    80003fd2:	64e2                	ld	s1,24(sp)
    80003fd4:	6942                	ld	s2,16(sp)
    80003fd6:	6145                	addi	sp,sp,48
    80003fd8:	8082                	ret
    80003fda:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003fdc:	0284a983          	lw	s3,40(s1)
    80003fe0:	94ffd0ef          	jal	8000192e <myproc>
    80003fe4:	5904                	lw	s1,48(a0)
    80003fe6:	413484b3          	sub	s1,s1,s3
    80003fea:	0014b493          	seqz	s1,s1
    80003fee:	69a2                	ld	s3,8(sp)
    80003ff0:	bfd9                	j	80003fc6 <holdingsleep+0x1e>

0000000080003ff2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003ff2:	1141                	addi	sp,sp,-16
    80003ff4:	e406                	sd	ra,8(sp)
    80003ff6:	e022                	sd	s0,0(sp)
    80003ff8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003ffa:	00003597          	auipc	a1,0x3
    80003ffe:	55e58593          	addi	a1,a1,1374 # 80007558 <etext+0x558>
    80004002:	0001c517          	auipc	a0,0x1c
    80004006:	c7e50513          	addi	a0,a0,-898 # 8001fc80 <ftable>
    8000400a:	b95fc0ef          	jal	80000b9e <initlock>
}
    8000400e:	60a2                	ld	ra,8(sp)
    80004010:	6402                	ld	s0,0(sp)
    80004012:	0141                	addi	sp,sp,16
    80004014:	8082                	ret

0000000080004016 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004016:	1101                	addi	sp,sp,-32
    80004018:	ec06                	sd	ra,24(sp)
    8000401a:	e822                	sd	s0,16(sp)
    8000401c:	e426                	sd	s1,8(sp)
    8000401e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004020:	0001c517          	auipc	a0,0x1c
    80004024:	c6050513          	addi	a0,a0,-928 # 8001fc80 <ftable>
    80004028:	c01fc0ef          	jal	80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000402c:	0001c497          	auipc	s1,0x1c
    80004030:	c6c48493          	addi	s1,s1,-916 # 8001fc98 <ftable+0x18>
    80004034:	0001d717          	auipc	a4,0x1d
    80004038:	c0470713          	addi	a4,a4,-1020 # 80020c38 <disk>
    if(f->ref == 0){
    8000403c:	40dc                	lw	a5,4(s1)
    8000403e:	cf89                	beqz	a5,80004058 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004040:	02848493          	addi	s1,s1,40
    80004044:	fee49ce3          	bne	s1,a4,8000403c <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004048:	0001c517          	auipc	a0,0x1c
    8000404c:	c3850513          	addi	a0,a0,-968 # 8001fc80 <ftable>
    80004050:	c6dfc0ef          	jal	80000cbc <release>
  return 0;
    80004054:	4481                	li	s1,0
    80004056:	a809                	j	80004068 <filealloc+0x52>
      f->ref = 1;
    80004058:	4785                	li	a5,1
    8000405a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000405c:	0001c517          	auipc	a0,0x1c
    80004060:	c2450513          	addi	a0,a0,-988 # 8001fc80 <ftable>
    80004064:	c59fc0ef          	jal	80000cbc <release>
}
    80004068:	8526                	mv	a0,s1
    8000406a:	60e2                	ld	ra,24(sp)
    8000406c:	6442                	ld	s0,16(sp)
    8000406e:	64a2                	ld	s1,8(sp)
    80004070:	6105                	addi	sp,sp,32
    80004072:	8082                	ret

0000000080004074 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004074:	1101                	addi	sp,sp,-32
    80004076:	ec06                	sd	ra,24(sp)
    80004078:	e822                	sd	s0,16(sp)
    8000407a:	e426                	sd	s1,8(sp)
    8000407c:	1000                	addi	s0,sp,32
    8000407e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004080:	0001c517          	auipc	a0,0x1c
    80004084:	c0050513          	addi	a0,a0,-1024 # 8001fc80 <ftable>
    80004088:	ba1fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    8000408c:	40dc                	lw	a5,4(s1)
    8000408e:	02f05063          	blez	a5,800040ae <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004092:	2785                	addiw	a5,a5,1
    80004094:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004096:	0001c517          	auipc	a0,0x1c
    8000409a:	bea50513          	addi	a0,a0,-1046 # 8001fc80 <ftable>
    8000409e:	c1ffc0ef          	jal	80000cbc <release>
  return f;
}
    800040a2:	8526                	mv	a0,s1
    800040a4:	60e2                	ld	ra,24(sp)
    800040a6:	6442                	ld	s0,16(sp)
    800040a8:	64a2                	ld	s1,8(sp)
    800040aa:	6105                	addi	sp,sp,32
    800040ac:	8082                	ret
    panic("filedup");
    800040ae:	00003517          	auipc	a0,0x3
    800040b2:	4b250513          	addi	a0,a0,1202 # 80007560 <etext+0x560>
    800040b6:	f6efc0ef          	jal	80000824 <panic>

00000000800040ba <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800040ba:	7139                	addi	sp,sp,-64
    800040bc:	fc06                	sd	ra,56(sp)
    800040be:	f822                	sd	s0,48(sp)
    800040c0:	f426                	sd	s1,40(sp)
    800040c2:	0080                	addi	s0,sp,64
    800040c4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800040c6:	0001c517          	auipc	a0,0x1c
    800040ca:	bba50513          	addi	a0,a0,-1094 # 8001fc80 <ftable>
    800040ce:	b5bfc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    800040d2:	40dc                	lw	a5,4(s1)
    800040d4:	04f05a63          	blez	a5,80004128 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800040d8:	37fd                	addiw	a5,a5,-1
    800040da:	c0dc                	sw	a5,4(s1)
    800040dc:	06f04063          	bgtz	a5,8000413c <fileclose+0x82>
    800040e0:	f04a                	sd	s2,32(sp)
    800040e2:	ec4e                	sd	s3,24(sp)
    800040e4:	e852                	sd	s4,16(sp)
    800040e6:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800040e8:	0004a903          	lw	s2,0(s1)
    800040ec:	0094c783          	lbu	a5,9(s1)
    800040f0:	89be                	mv	s3,a5
    800040f2:	689c                	ld	a5,16(s1)
    800040f4:	8a3e                	mv	s4,a5
    800040f6:	6c9c                	ld	a5,24(s1)
    800040f8:	8abe                	mv	s5,a5
  f->ref = 0;
    800040fa:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800040fe:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004102:	0001c517          	auipc	a0,0x1c
    80004106:	b7e50513          	addi	a0,a0,-1154 # 8001fc80 <ftable>
    8000410a:	bb3fc0ef          	jal	80000cbc <release>

  if(ff.type == FD_PIPE){
    8000410e:	4785                	li	a5,1
    80004110:	04f90163          	beq	s2,a5,80004152 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004114:	ffe9079b          	addiw	a5,s2,-2
    80004118:	4705                	li	a4,1
    8000411a:	04f77563          	bgeu	a4,a5,80004164 <fileclose+0xaa>
    8000411e:	7902                	ld	s2,32(sp)
    80004120:	69e2                	ld	s3,24(sp)
    80004122:	6a42                	ld	s4,16(sp)
    80004124:	6aa2                	ld	s5,8(sp)
    80004126:	a00d                	j	80004148 <fileclose+0x8e>
    80004128:	f04a                	sd	s2,32(sp)
    8000412a:	ec4e                	sd	s3,24(sp)
    8000412c:	e852                	sd	s4,16(sp)
    8000412e:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004130:	00003517          	auipc	a0,0x3
    80004134:	43850513          	addi	a0,a0,1080 # 80007568 <etext+0x568>
    80004138:	eecfc0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    8000413c:	0001c517          	auipc	a0,0x1c
    80004140:	b4450513          	addi	a0,a0,-1212 # 8001fc80 <ftable>
    80004144:	b79fc0ef          	jal	80000cbc <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004148:	70e2                	ld	ra,56(sp)
    8000414a:	7442                	ld	s0,48(sp)
    8000414c:	74a2                	ld	s1,40(sp)
    8000414e:	6121                	addi	sp,sp,64
    80004150:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004152:	85ce                	mv	a1,s3
    80004154:	8552                	mv	a0,s4
    80004156:	348000ef          	jal	8000449e <pipeclose>
    8000415a:	7902                	ld	s2,32(sp)
    8000415c:	69e2                	ld	s3,24(sp)
    8000415e:	6a42                	ld	s4,16(sp)
    80004160:	6aa2                	ld	s5,8(sp)
    80004162:	b7dd                	j	80004148 <fileclose+0x8e>
    begin_op();
    80004164:	b33ff0ef          	jal	80003c96 <begin_op>
    iput(ff.ip);
    80004168:	8556                	mv	a0,s5
    8000416a:	aa2ff0ef          	jal	8000340c <iput>
    end_op();
    8000416e:	b99ff0ef          	jal	80003d06 <end_op>
    80004172:	7902                	ld	s2,32(sp)
    80004174:	69e2                	ld	s3,24(sp)
    80004176:	6a42                	ld	s4,16(sp)
    80004178:	6aa2                	ld	s5,8(sp)
    8000417a:	b7f9                	j	80004148 <fileclose+0x8e>

000000008000417c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000417c:	715d                	addi	sp,sp,-80
    8000417e:	e486                	sd	ra,72(sp)
    80004180:	e0a2                	sd	s0,64(sp)
    80004182:	fc26                	sd	s1,56(sp)
    80004184:	f052                	sd	s4,32(sp)
    80004186:	0880                	addi	s0,sp,80
    80004188:	84aa                	mv	s1,a0
    8000418a:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    8000418c:	fa2fd0ef          	jal	8000192e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004190:	409c                	lw	a5,0(s1)
    80004192:	37f9                	addiw	a5,a5,-2
    80004194:	4705                	li	a4,1
    80004196:	04f76263          	bltu	a4,a5,800041da <filestat+0x5e>
    8000419a:	f84a                	sd	s2,48(sp)
    8000419c:	f44e                	sd	s3,40(sp)
    8000419e:	89aa                	mv	s3,a0
    ilock(f->ip);
    800041a0:	6c88                	ld	a0,24(s1)
    800041a2:	8e8ff0ef          	jal	8000328a <ilock>
    stati(f->ip, &st);
    800041a6:	fb840913          	addi	s2,s0,-72
    800041aa:	85ca                	mv	a1,s2
    800041ac:	6c88                	ld	a0,24(s1)
    800041ae:	c40ff0ef          	jal	800035ee <stati>
    iunlock(f->ip);
    800041b2:	6c88                	ld	a0,24(s1)
    800041b4:	984ff0ef          	jal	80003338 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800041b8:	46e1                	li	a3,24
    800041ba:	864a                	mv	a2,s2
    800041bc:	85d2                	mv	a1,s4
    800041be:	0509b503          	ld	a0,80(s3)
    800041c2:	c92fd0ef          	jal	80001654 <copyout>
    800041c6:	41f5551b          	sraiw	a0,a0,0x1f
    800041ca:	7942                	ld	s2,48(sp)
    800041cc:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800041ce:	60a6                	ld	ra,72(sp)
    800041d0:	6406                	ld	s0,64(sp)
    800041d2:	74e2                	ld	s1,56(sp)
    800041d4:	7a02                	ld	s4,32(sp)
    800041d6:	6161                	addi	sp,sp,80
    800041d8:	8082                	ret
  return -1;
    800041da:	557d                	li	a0,-1
    800041dc:	bfcd                	j	800041ce <filestat+0x52>

00000000800041de <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800041de:	7179                	addi	sp,sp,-48
    800041e0:	f406                	sd	ra,40(sp)
    800041e2:	f022                	sd	s0,32(sp)
    800041e4:	e84a                	sd	s2,16(sp)
    800041e6:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800041e8:	00854783          	lbu	a5,8(a0)
    800041ec:	cfd1                	beqz	a5,80004288 <fileread+0xaa>
    800041ee:	ec26                	sd	s1,24(sp)
    800041f0:	e44e                	sd	s3,8(sp)
    800041f2:	84aa                	mv	s1,a0
    800041f4:	892e                	mv	s2,a1
    800041f6:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    800041f8:	411c                	lw	a5,0(a0)
    800041fa:	4705                	li	a4,1
    800041fc:	04e78363          	beq	a5,a4,80004242 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004200:	470d                	li	a4,3
    80004202:	04e78763          	beq	a5,a4,80004250 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004206:	4709                	li	a4,2
    80004208:	06e79a63          	bne	a5,a4,8000427c <fileread+0x9e>
    ilock(f->ip);
    8000420c:	6d08                	ld	a0,24(a0)
    8000420e:	87cff0ef          	jal	8000328a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004212:	874e                	mv	a4,s3
    80004214:	5094                	lw	a3,32(s1)
    80004216:	864a                	mv	a2,s2
    80004218:	4585                	li	a1,1
    8000421a:	6c88                	ld	a0,24(s1)
    8000421c:	c00ff0ef          	jal	8000361c <readi>
    80004220:	892a                	mv	s2,a0
    80004222:	00a05563          	blez	a0,8000422c <fileread+0x4e>
      f->off += r;
    80004226:	509c                	lw	a5,32(s1)
    80004228:	9fa9                	addw	a5,a5,a0
    8000422a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000422c:	6c88                	ld	a0,24(s1)
    8000422e:	90aff0ef          	jal	80003338 <iunlock>
    80004232:	64e2                	ld	s1,24(sp)
    80004234:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004236:	854a                	mv	a0,s2
    80004238:	70a2                	ld	ra,40(sp)
    8000423a:	7402                	ld	s0,32(sp)
    8000423c:	6942                	ld	s2,16(sp)
    8000423e:	6145                	addi	sp,sp,48
    80004240:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004242:	6908                	ld	a0,16(a0)
    80004244:	3b0000ef          	jal	800045f4 <piperead>
    80004248:	892a                	mv	s2,a0
    8000424a:	64e2                	ld	s1,24(sp)
    8000424c:	69a2                	ld	s3,8(sp)
    8000424e:	b7e5                	j	80004236 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004250:	02451783          	lh	a5,36(a0)
    80004254:	03079693          	slli	a3,a5,0x30
    80004258:	92c1                	srli	a3,a3,0x30
    8000425a:	4725                	li	a4,9
    8000425c:	02d76963          	bltu	a4,a3,8000428e <fileread+0xb0>
    80004260:	0792                	slli	a5,a5,0x4
    80004262:	0001c717          	auipc	a4,0x1c
    80004266:	97e70713          	addi	a4,a4,-1666 # 8001fbe0 <devsw>
    8000426a:	97ba                	add	a5,a5,a4
    8000426c:	639c                	ld	a5,0(a5)
    8000426e:	c78d                	beqz	a5,80004298 <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    80004270:	4505                	li	a0,1
    80004272:	9782                	jalr	a5
    80004274:	892a                	mv	s2,a0
    80004276:	64e2                	ld	s1,24(sp)
    80004278:	69a2                	ld	s3,8(sp)
    8000427a:	bf75                	j	80004236 <fileread+0x58>
    panic("fileread");
    8000427c:	00003517          	auipc	a0,0x3
    80004280:	2fc50513          	addi	a0,a0,764 # 80007578 <etext+0x578>
    80004284:	da0fc0ef          	jal	80000824 <panic>
    return -1;
    80004288:	57fd                	li	a5,-1
    8000428a:	893e                	mv	s2,a5
    8000428c:	b76d                	j	80004236 <fileread+0x58>
      return -1;
    8000428e:	57fd                	li	a5,-1
    80004290:	893e                	mv	s2,a5
    80004292:	64e2                	ld	s1,24(sp)
    80004294:	69a2                	ld	s3,8(sp)
    80004296:	b745                	j	80004236 <fileread+0x58>
    80004298:	57fd                	li	a5,-1
    8000429a:	893e                	mv	s2,a5
    8000429c:	64e2                	ld	s1,24(sp)
    8000429e:	69a2                	ld	s3,8(sp)
    800042a0:	bf59                	j	80004236 <fileread+0x58>

00000000800042a2 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800042a2:	00954783          	lbu	a5,9(a0)
    800042a6:	10078f63          	beqz	a5,800043c4 <filewrite+0x122>
{
    800042aa:	711d                	addi	sp,sp,-96
    800042ac:	ec86                	sd	ra,88(sp)
    800042ae:	e8a2                	sd	s0,80(sp)
    800042b0:	e0ca                	sd	s2,64(sp)
    800042b2:	f456                	sd	s5,40(sp)
    800042b4:	f05a                	sd	s6,32(sp)
    800042b6:	1080                	addi	s0,sp,96
    800042b8:	892a                	mv	s2,a0
    800042ba:	8b2e                	mv	s6,a1
    800042bc:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    800042be:	411c                	lw	a5,0(a0)
    800042c0:	4705                	li	a4,1
    800042c2:	02e78a63          	beq	a5,a4,800042f6 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800042c6:	470d                	li	a4,3
    800042c8:	02e78b63          	beq	a5,a4,800042fe <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800042cc:	4709                	li	a4,2
    800042ce:	0ce79f63          	bne	a5,a4,800043ac <filewrite+0x10a>
    800042d2:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800042d4:	0ac05a63          	blez	a2,80004388 <filewrite+0xe6>
    800042d8:	e4a6                	sd	s1,72(sp)
    800042da:	fc4e                	sd	s3,56(sp)
    800042dc:	ec5e                	sd	s7,24(sp)
    800042de:	e862                	sd	s8,16(sp)
    800042e0:	e466                	sd	s9,8(sp)
    int i = 0;
    800042e2:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    800042e4:	6b85                	lui	s7,0x1
    800042e6:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800042ea:	6785                	lui	a5,0x1
    800042ec:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800042f0:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800042f2:	4c05                	li	s8,1
    800042f4:	a8ad                	j	8000436e <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800042f6:	6908                	ld	a0,16(a0)
    800042f8:	204000ef          	jal	800044fc <pipewrite>
    800042fc:	a04d                	j	8000439e <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800042fe:	02451783          	lh	a5,36(a0)
    80004302:	03079693          	slli	a3,a5,0x30
    80004306:	92c1                	srli	a3,a3,0x30
    80004308:	4725                	li	a4,9
    8000430a:	0ad76f63          	bltu	a4,a3,800043c8 <filewrite+0x126>
    8000430e:	0792                	slli	a5,a5,0x4
    80004310:	0001c717          	auipc	a4,0x1c
    80004314:	8d070713          	addi	a4,a4,-1840 # 8001fbe0 <devsw>
    80004318:	97ba                	add	a5,a5,a4
    8000431a:	679c                	ld	a5,8(a5)
    8000431c:	cbc5                	beqz	a5,800043cc <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    8000431e:	4505                	li	a0,1
    80004320:	9782                	jalr	a5
    80004322:	a8b5                	j	8000439e <filewrite+0xfc>
      if(n1 > max)
    80004324:	2981                	sext.w	s3,s3
      begin_op();
    80004326:	971ff0ef          	jal	80003c96 <begin_op>
      ilock(f->ip);
    8000432a:	01893503          	ld	a0,24(s2)
    8000432e:	f5dfe0ef          	jal	8000328a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004332:	874e                	mv	a4,s3
    80004334:	02092683          	lw	a3,32(s2)
    80004338:	016a0633          	add	a2,s4,s6
    8000433c:	85e2                	mv	a1,s8
    8000433e:	01893503          	ld	a0,24(s2)
    80004342:	bccff0ef          	jal	8000370e <writei>
    80004346:	84aa                	mv	s1,a0
    80004348:	00a05763          	blez	a0,80004356 <filewrite+0xb4>
        f->off += r;
    8000434c:	02092783          	lw	a5,32(s2)
    80004350:	9fa9                	addw	a5,a5,a0
    80004352:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004356:	01893503          	ld	a0,24(s2)
    8000435a:	fdffe0ef          	jal	80003338 <iunlock>
      end_op();
    8000435e:	9a9ff0ef          	jal	80003d06 <end_op>

      if(r != n1){
    80004362:	02999563          	bne	s3,s1,8000438c <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    80004366:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    8000436a:	015a5963          	bge	s4,s5,8000437c <filewrite+0xda>
      int n1 = n - i;
    8000436e:	414a87bb          	subw	a5,s5,s4
    80004372:	89be                	mv	s3,a5
      if(n1 > max)
    80004374:	fafbd8e3          	bge	s7,a5,80004324 <filewrite+0x82>
    80004378:	89e6                	mv	s3,s9
    8000437a:	b76d                	j	80004324 <filewrite+0x82>
    8000437c:	64a6                	ld	s1,72(sp)
    8000437e:	79e2                	ld	s3,56(sp)
    80004380:	6be2                	ld	s7,24(sp)
    80004382:	6c42                	ld	s8,16(sp)
    80004384:	6ca2                	ld	s9,8(sp)
    80004386:	a801                	j	80004396 <filewrite+0xf4>
    int i = 0;
    80004388:	4a01                	li	s4,0
    8000438a:	a031                	j	80004396 <filewrite+0xf4>
    8000438c:	64a6                	ld	s1,72(sp)
    8000438e:	79e2                	ld	s3,56(sp)
    80004390:	6be2                	ld	s7,24(sp)
    80004392:	6c42                	ld	s8,16(sp)
    80004394:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004396:	034a9d63          	bne	s5,s4,800043d0 <filewrite+0x12e>
    8000439a:	8556                	mv	a0,s5
    8000439c:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000439e:	60e6                	ld	ra,88(sp)
    800043a0:	6446                	ld	s0,80(sp)
    800043a2:	6906                	ld	s2,64(sp)
    800043a4:	7aa2                	ld	s5,40(sp)
    800043a6:	7b02                	ld	s6,32(sp)
    800043a8:	6125                	addi	sp,sp,96
    800043aa:	8082                	ret
    800043ac:	e4a6                	sd	s1,72(sp)
    800043ae:	fc4e                	sd	s3,56(sp)
    800043b0:	f852                	sd	s4,48(sp)
    800043b2:	ec5e                	sd	s7,24(sp)
    800043b4:	e862                	sd	s8,16(sp)
    800043b6:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800043b8:	00003517          	auipc	a0,0x3
    800043bc:	1d050513          	addi	a0,a0,464 # 80007588 <etext+0x588>
    800043c0:	c64fc0ef          	jal	80000824 <panic>
    return -1;
    800043c4:	557d                	li	a0,-1
}
    800043c6:	8082                	ret
      return -1;
    800043c8:	557d                	li	a0,-1
    800043ca:	bfd1                	j	8000439e <filewrite+0xfc>
    800043cc:	557d                	li	a0,-1
    800043ce:	bfc1                	j	8000439e <filewrite+0xfc>
    ret = (i == n ? n : -1);
    800043d0:	557d                	li	a0,-1
    800043d2:	7a42                	ld	s4,48(sp)
    800043d4:	b7e9                	j	8000439e <filewrite+0xfc>

00000000800043d6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800043d6:	7179                	addi	sp,sp,-48
    800043d8:	f406                	sd	ra,40(sp)
    800043da:	f022                	sd	s0,32(sp)
    800043dc:	ec26                	sd	s1,24(sp)
    800043de:	e052                	sd	s4,0(sp)
    800043e0:	1800                	addi	s0,sp,48
    800043e2:	84aa                	mv	s1,a0
    800043e4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800043e6:	0005b023          	sd	zero,0(a1)
    800043ea:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800043ee:	c29ff0ef          	jal	80004016 <filealloc>
    800043f2:	e088                	sd	a0,0(s1)
    800043f4:	c549                	beqz	a0,8000447e <pipealloc+0xa8>
    800043f6:	c21ff0ef          	jal	80004016 <filealloc>
    800043fa:	00aa3023          	sd	a0,0(s4)
    800043fe:	cd25                	beqz	a0,80004476 <pipealloc+0xa0>
    80004400:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004402:	f42fc0ef          	jal	80000b44 <kalloc>
    80004406:	892a                	mv	s2,a0
    80004408:	c12d                	beqz	a0,8000446a <pipealloc+0x94>
    8000440a:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000440c:	4985                	li	s3,1
    8000440e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004412:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004416:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000441a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000441e:	00003597          	auipc	a1,0x3
    80004422:	17a58593          	addi	a1,a1,378 # 80007598 <etext+0x598>
    80004426:	f78fc0ef          	jal	80000b9e <initlock>
  (*f0)->type = FD_PIPE;
    8000442a:	609c                	ld	a5,0(s1)
    8000442c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004430:	609c                	ld	a5,0(s1)
    80004432:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004436:	609c                	ld	a5,0(s1)
    80004438:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000443c:	609c                	ld	a5,0(s1)
    8000443e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004442:	000a3783          	ld	a5,0(s4)
    80004446:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000444a:	000a3783          	ld	a5,0(s4)
    8000444e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004452:	000a3783          	ld	a5,0(s4)
    80004456:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000445a:	000a3783          	ld	a5,0(s4)
    8000445e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004462:	4501                	li	a0,0
    80004464:	6942                	ld	s2,16(sp)
    80004466:	69a2                	ld	s3,8(sp)
    80004468:	a01d                	j	8000448e <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000446a:	6088                	ld	a0,0(s1)
    8000446c:	c119                	beqz	a0,80004472 <pipealloc+0x9c>
    8000446e:	6942                	ld	s2,16(sp)
    80004470:	a029                	j	8000447a <pipealloc+0xa4>
    80004472:	6942                	ld	s2,16(sp)
    80004474:	a029                	j	8000447e <pipealloc+0xa8>
    80004476:	6088                	ld	a0,0(s1)
    80004478:	c10d                	beqz	a0,8000449a <pipealloc+0xc4>
    fileclose(*f0);
    8000447a:	c41ff0ef          	jal	800040ba <fileclose>
  if(*f1)
    8000447e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004482:	557d                	li	a0,-1
  if(*f1)
    80004484:	c789                	beqz	a5,8000448e <pipealloc+0xb8>
    fileclose(*f1);
    80004486:	853e                	mv	a0,a5
    80004488:	c33ff0ef          	jal	800040ba <fileclose>
  return -1;
    8000448c:	557d                	li	a0,-1
}
    8000448e:	70a2                	ld	ra,40(sp)
    80004490:	7402                	ld	s0,32(sp)
    80004492:	64e2                	ld	s1,24(sp)
    80004494:	6a02                	ld	s4,0(sp)
    80004496:	6145                	addi	sp,sp,48
    80004498:	8082                	ret
  return -1;
    8000449a:	557d                	li	a0,-1
    8000449c:	bfcd                	j	8000448e <pipealloc+0xb8>

000000008000449e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000449e:	1101                	addi	sp,sp,-32
    800044a0:	ec06                	sd	ra,24(sp)
    800044a2:	e822                	sd	s0,16(sp)
    800044a4:	e426                	sd	s1,8(sp)
    800044a6:	e04a                	sd	s2,0(sp)
    800044a8:	1000                	addi	s0,sp,32
    800044aa:	84aa                	mv	s1,a0
    800044ac:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800044ae:	f7afc0ef          	jal	80000c28 <acquire>
  if(writable){
    800044b2:	02090763          	beqz	s2,800044e0 <pipeclose+0x42>
    pi->writeopen = 0;
    800044b6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800044ba:	21848513          	addi	a0,s1,536
    800044be:	acdfd0ef          	jal	80001f8a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800044c2:	2204a783          	lw	a5,544(s1)
    800044c6:	e781                	bnez	a5,800044ce <pipeclose+0x30>
    800044c8:	2244a783          	lw	a5,548(s1)
    800044cc:	c38d                	beqz	a5,800044ee <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    800044ce:	8526                	mv	a0,s1
    800044d0:	fecfc0ef          	jal	80000cbc <release>
}
    800044d4:	60e2                	ld	ra,24(sp)
    800044d6:	6442                	ld	s0,16(sp)
    800044d8:	64a2                	ld	s1,8(sp)
    800044da:	6902                	ld	s2,0(sp)
    800044dc:	6105                	addi	sp,sp,32
    800044de:	8082                	ret
    pi->readopen = 0;
    800044e0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800044e4:	21c48513          	addi	a0,s1,540
    800044e8:	aa3fd0ef          	jal	80001f8a <wakeup>
    800044ec:	bfd9                	j	800044c2 <pipeclose+0x24>
    release(&pi->lock);
    800044ee:	8526                	mv	a0,s1
    800044f0:	fccfc0ef          	jal	80000cbc <release>
    kfree((char*)pi);
    800044f4:	8526                	mv	a0,s1
    800044f6:	d66fc0ef          	jal	80000a5c <kfree>
    800044fa:	bfe9                	j	800044d4 <pipeclose+0x36>

00000000800044fc <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800044fc:	7159                	addi	sp,sp,-112
    800044fe:	f486                	sd	ra,104(sp)
    80004500:	f0a2                	sd	s0,96(sp)
    80004502:	eca6                	sd	s1,88(sp)
    80004504:	e8ca                	sd	s2,80(sp)
    80004506:	e4ce                	sd	s3,72(sp)
    80004508:	e0d2                	sd	s4,64(sp)
    8000450a:	fc56                	sd	s5,56(sp)
    8000450c:	1880                	addi	s0,sp,112
    8000450e:	84aa                	mv	s1,a0
    80004510:	8aae                	mv	s5,a1
    80004512:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004514:	c1afd0ef          	jal	8000192e <myproc>
    80004518:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000451a:	8526                	mv	a0,s1
    8000451c:	f0cfc0ef          	jal	80000c28 <acquire>
  while(i < n){
    80004520:	0d405263          	blez	s4,800045e4 <pipewrite+0xe8>
    80004524:	f85a                	sd	s6,48(sp)
    80004526:	f45e                	sd	s7,40(sp)
    80004528:	f062                	sd	s8,32(sp)
    8000452a:	ec66                	sd	s9,24(sp)
    8000452c:	e86a                	sd	s10,16(sp)
  int i = 0;
    8000452e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004530:	f9f40c13          	addi	s8,s0,-97
    80004534:	4b85                	li	s7,1
    80004536:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004538:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000453c:	21c48c93          	addi	s9,s1,540
    80004540:	a82d                	j	8000457a <pipewrite+0x7e>
      release(&pi->lock);
    80004542:	8526                	mv	a0,s1
    80004544:	f78fc0ef          	jal	80000cbc <release>
      return -1;
    80004548:	597d                	li	s2,-1
    8000454a:	7b42                	ld	s6,48(sp)
    8000454c:	7ba2                	ld	s7,40(sp)
    8000454e:	7c02                	ld	s8,32(sp)
    80004550:	6ce2                	ld	s9,24(sp)
    80004552:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004554:	854a                	mv	a0,s2
    80004556:	70a6                	ld	ra,104(sp)
    80004558:	7406                	ld	s0,96(sp)
    8000455a:	64e6                	ld	s1,88(sp)
    8000455c:	6946                	ld	s2,80(sp)
    8000455e:	69a6                	ld	s3,72(sp)
    80004560:	6a06                	ld	s4,64(sp)
    80004562:	7ae2                	ld	s5,56(sp)
    80004564:	6165                	addi	sp,sp,112
    80004566:	8082                	ret
      wakeup(&pi->nread);
    80004568:	856a                	mv	a0,s10
    8000456a:	a21fd0ef          	jal	80001f8a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000456e:	85a6                	mv	a1,s1
    80004570:	8566                	mv	a0,s9
    80004572:	9cdfd0ef          	jal	80001f3e <sleep>
  while(i < n){
    80004576:	05495a63          	bge	s2,s4,800045ca <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    8000457a:	2204a783          	lw	a5,544(s1)
    8000457e:	d3f1                	beqz	a5,80004542 <pipewrite+0x46>
    80004580:	854e                	mv	a0,s3
    80004582:	bf9fd0ef          	jal	8000217a <killed>
    80004586:	fd55                	bnez	a0,80004542 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004588:	2184a783          	lw	a5,536(s1)
    8000458c:	21c4a703          	lw	a4,540(s1)
    80004590:	2007879b          	addiw	a5,a5,512
    80004594:	fcf70ae3          	beq	a4,a5,80004568 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004598:	86de                	mv	a3,s7
    8000459a:	01590633          	add	a2,s2,s5
    8000459e:	85e2                	mv	a1,s8
    800045a0:	0509b503          	ld	a0,80(s3)
    800045a4:	96efd0ef          	jal	80001712 <copyin>
    800045a8:	05650063          	beq	a0,s6,800045e8 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800045ac:	21c4a783          	lw	a5,540(s1)
    800045b0:	0017871b          	addiw	a4,a5,1
    800045b4:	20e4ae23          	sw	a4,540(s1)
    800045b8:	1ff7f793          	andi	a5,a5,511
    800045bc:	97a6                	add	a5,a5,s1
    800045be:	f9f44703          	lbu	a4,-97(s0)
    800045c2:	00e78c23          	sb	a4,24(a5)
      i++;
    800045c6:	2905                	addiw	s2,s2,1
    800045c8:	b77d                	j	80004576 <pipewrite+0x7a>
    800045ca:	7b42                	ld	s6,48(sp)
    800045cc:	7ba2                	ld	s7,40(sp)
    800045ce:	7c02                	ld	s8,32(sp)
    800045d0:	6ce2                	ld	s9,24(sp)
    800045d2:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800045d4:	21848513          	addi	a0,s1,536
    800045d8:	9b3fd0ef          	jal	80001f8a <wakeup>
  release(&pi->lock);
    800045dc:	8526                	mv	a0,s1
    800045de:	edefc0ef          	jal	80000cbc <release>
  return i;
    800045e2:	bf8d                	j	80004554 <pipewrite+0x58>
  int i = 0;
    800045e4:	4901                	li	s2,0
    800045e6:	b7fd                	j	800045d4 <pipewrite+0xd8>
    800045e8:	7b42                	ld	s6,48(sp)
    800045ea:	7ba2                	ld	s7,40(sp)
    800045ec:	7c02                	ld	s8,32(sp)
    800045ee:	6ce2                	ld	s9,24(sp)
    800045f0:	6d42                	ld	s10,16(sp)
    800045f2:	b7cd                	j	800045d4 <pipewrite+0xd8>

00000000800045f4 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800045f4:	711d                	addi	sp,sp,-96
    800045f6:	ec86                	sd	ra,88(sp)
    800045f8:	e8a2                	sd	s0,80(sp)
    800045fa:	e4a6                	sd	s1,72(sp)
    800045fc:	e0ca                	sd	s2,64(sp)
    800045fe:	fc4e                	sd	s3,56(sp)
    80004600:	f852                	sd	s4,48(sp)
    80004602:	f456                	sd	s5,40(sp)
    80004604:	1080                	addi	s0,sp,96
    80004606:	84aa                	mv	s1,a0
    80004608:	892e                	mv	s2,a1
    8000460a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000460c:	b22fd0ef          	jal	8000192e <myproc>
    80004610:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004612:	8526                	mv	a0,s1
    80004614:	e14fc0ef          	jal	80000c28 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004618:	2184a703          	lw	a4,536(s1)
    8000461c:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004620:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004624:	02f71763          	bne	a4,a5,80004652 <piperead+0x5e>
    80004628:	2244a783          	lw	a5,548(s1)
    8000462c:	cf85                	beqz	a5,80004664 <piperead+0x70>
    if(killed(pr)){
    8000462e:	8552                	mv	a0,s4
    80004630:	b4bfd0ef          	jal	8000217a <killed>
    80004634:	e11d                	bnez	a0,8000465a <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004636:	85a6                	mv	a1,s1
    80004638:	854e                	mv	a0,s3
    8000463a:	905fd0ef          	jal	80001f3e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000463e:	2184a703          	lw	a4,536(s1)
    80004642:	21c4a783          	lw	a5,540(s1)
    80004646:	fef701e3          	beq	a4,a5,80004628 <piperead+0x34>
    8000464a:	f05a                	sd	s6,32(sp)
    8000464c:	ec5e                	sd	s7,24(sp)
    8000464e:	e862                	sd	s8,16(sp)
    80004650:	a829                	j	8000466a <piperead+0x76>
    80004652:	f05a                	sd	s6,32(sp)
    80004654:	ec5e                	sd	s7,24(sp)
    80004656:	e862                	sd	s8,16(sp)
    80004658:	a809                	j	8000466a <piperead+0x76>
      release(&pi->lock);
    8000465a:	8526                	mv	a0,s1
    8000465c:	e60fc0ef          	jal	80000cbc <release>
      return -1;
    80004660:	59fd                	li	s3,-1
    80004662:	a0a5                	j	800046ca <piperead+0xd6>
    80004664:	f05a                	sd	s6,32(sp)
    80004666:	ec5e                	sd	s7,24(sp)
    80004668:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000466a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000466c:	faf40c13          	addi	s8,s0,-81
    80004670:	4b85                	li	s7,1
    80004672:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004674:	05505163          	blez	s5,800046b6 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    80004678:	2184a783          	lw	a5,536(s1)
    8000467c:	21c4a703          	lw	a4,540(s1)
    80004680:	02f70b63          	beq	a4,a5,800046b6 <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004684:	1ff7f793          	andi	a5,a5,511
    80004688:	97a6                	add	a5,a5,s1
    8000468a:	0187c783          	lbu	a5,24(a5)
    8000468e:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004692:	86de                	mv	a3,s7
    80004694:	8662                	mv	a2,s8
    80004696:	85ca                	mv	a1,s2
    80004698:	050a3503          	ld	a0,80(s4)
    8000469c:	fb9fc0ef          	jal	80001654 <copyout>
    800046a0:	03650f63          	beq	a0,s6,800046de <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800046a4:	2184a783          	lw	a5,536(s1)
    800046a8:	2785                	addiw	a5,a5,1
    800046aa:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046ae:	2985                	addiw	s3,s3,1
    800046b0:	0905                	addi	s2,s2,1
    800046b2:	fd3a93e3          	bne	s5,s3,80004678 <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800046b6:	21c48513          	addi	a0,s1,540
    800046ba:	8d1fd0ef          	jal	80001f8a <wakeup>
  release(&pi->lock);
    800046be:	8526                	mv	a0,s1
    800046c0:	dfcfc0ef          	jal	80000cbc <release>
    800046c4:	7b02                	ld	s6,32(sp)
    800046c6:	6be2                	ld	s7,24(sp)
    800046c8:	6c42                	ld	s8,16(sp)
  return i;
}
    800046ca:	854e                	mv	a0,s3
    800046cc:	60e6                	ld	ra,88(sp)
    800046ce:	6446                	ld	s0,80(sp)
    800046d0:	64a6                	ld	s1,72(sp)
    800046d2:	6906                	ld	s2,64(sp)
    800046d4:	79e2                	ld	s3,56(sp)
    800046d6:	7a42                	ld	s4,48(sp)
    800046d8:	7aa2                	ld	s5,40(sp)
    800046da:	6125                	addi	sp,sp,96
    800046dc:	8082                	ret
      if(i == 0)
    800046de:	fc099ce3          	bnez	s3,800046b6 <piperead+0xc2>
        i = -1;
    800046e2:	89aa                	mv	s3,a0
    800046e4:	bfc9                	j	800046b6 <piperead+0xc2>

00000000800046e6 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800046e6:	1141                	addi	sp,sp,-16
    800046e8:	e406                	sd	ra,8(sp)
    800046ea:	e022                	sd	s0,0(sp)
    800046ec:	0800                	addi	s0,sp,16
    800046ee:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800046f0:	0035151b          	slliw	a0,a0,0x3
    800046f4:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    800046f6:	8b89                	andi	a5,a5,2
    800046f8:	c399                	beqz	a5,800046fe <flags2perm+0x18>
      perm |= PTE_W;
    800046fa:	00456513          	ori	a0,a0,4
    return perm;
}
    800046fe:	60a2                	ld	ra,8(sp)
    80004700:	6402                	ld	s0,0(sp)
    80004702:	0141                	addi	sp,sp,16
    80004704:	8082                	ret

0000000080004706 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004706:	de010113          	addi	sp,sp,-544
    8000470a:	20113c23          	sd	ra,536(sp)
    8000470e:	20813823          	sd	s0,528(sp)
    80004712:	20913423          	sd	s1,520(sp)
    80004716:	21213023          	sd	s2,512(sp)
    8000471a:	1400                	addi	s0,sp,544
    8000471c:	892a                	mv	s2,a0
    8000471e:	dea43823          	sd	a0,-528(s0)
    80004722:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004726:	a08fd0ef          	jal	8000192e <myproc>
    8000472a:	84aa                	mv	s1,a0

  begin_op();
    8000472c:	d6aff0ef          	jal	80003c96 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004730:	854a                	mv	a0,s2
    80004732:	b86ff0ef          	jal	80003ab8 <namei>
    80004736:	cd21                	beqz	a0,8000478e <kexec+0x88>
    80004738:	fbd2                	sd	s4,496(sp)
    8000473a:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000473c:	b4ffe0ef          	jal	8000328a <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004740:	04000713          	li	a4,64
    80004744:	4681                	li	a3,0
    80004746:	e5040613          	addi	a2,s0,-432
    8000474a:	4581                	li	a1,0
    8000474c:	8552                	mv	a0,s4
    8000474e:	ecffe0ef          	jal	8000361c <readi>
    80004752:	04000793          	li	a5,64
    80004756:	00f51a63          	bne	a0,a5,8000476a <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    8000475a:	e5042703          	lw	a4,-432(s0)
    8000475e:	464c47b7          	lui	a5,0x464c4
    80004762:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004766:	02f70863          	beq	a4,a5,80004796 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000476a:	8552                	mv	a0,s4
    8000476c:	d2bfe0ef          	jal	80003496 <iunlockput>
    end_op();
    80004770:	d96ff0ef          	jal	80003d06 <end_op>
  }
  return -1;
    80004774:	557d                	li	a0,-1
    80004776:	7a5e                	ld	s4,496(sp)
}
    80004778:	21813083          	ld	ra,536(sp)
    8000477c:	21013403          	ld	s0,528(sp)
    80004780:	20813483          	ld	s1,520(sp)
    80004784:	20013903          	ld	s2,512(sp)
    80004788:	22010113          	addi	sp,sp,544
    8000478c:	8082                	ret
    end_op();
    8000478e:	d78ff0ef          	jal	80003d06 <end_op>
    return -1;
    80004792:	557d                	li	a0,-1
    80004794:	b7d5                	j	80004778 <kexec+0x72>
    80004796:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004798:	8526                	mv	a0,s1
    8000479a:	a9efd0ef          	jal	80001a38 <proc_pagetable>
    8000479e:	8b2a                	mv	s6,a0
    800047a0:	26050f63          	beqz	a0,80004a1e <kexec+0x318>
    800047a4:	ffce                	sd	s3,504(sp)
    800047a6:	f7d6                	sd	s5,488(sp)
    800047a8:	efde                	sd	s7,472(sp)
    800047aa:	ebe2                	sd	s8,464(sp)
    800047ac:	e7e6                	sd	s9,456(sp)
    800047ae:	e3ea                	sd	s10,448(sp)
    800047b0:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047b2:	e8845783          	lhu	a5,-376(s0)
    800047b6:	0e078963          	beqz	a5,800048a8 <kexec+0x1a2>
    800047ba:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047be:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047c0:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800047c2:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    800047c6:	6c85                	lui	s9,0x1
    800047c8:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800047cc:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800047d0:	6a85                	lui	s5,0x1
    800047d2:	a085                	j	80004832 <kexec+0x12c>
      panic("loadseg: address should exist");
    800047d4:	00003517          	auipc	a0,0x3
    800047d8:	dcc50513          	addi	a0,a0,-564 # 800075a0 <etext+0x5a0>
    800047dc:	848fc0ef          	jal	80000824 <panic>
    if(sz - i < PGSIZE)
    800047e0:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800047e2:	874a                	mv	a4,s2
    800047e4:	009b86bb          	addw	a3,s7,s1
    800047e8:	4581                	li	a1,0
    800047ea:	8552                	mv	a0,s4
    800047ec:	e31fe0ef          	jal	8000361c <readi>
    800047f0:	22a91b63          	bne	s2,a0,80004a26 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    800047f4:	009a84bb          	addw	s1,s5,s1
    800047f8:	0334f263          	bgeu	s1,s3,8000481c <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    800047fc:	02049593          	slli	a1,s1,0x20
    80004800:	9181                	srli	a1,a1,0x20
    80004802:	95e2                	add	a1,a1,s8
    80004804:	855a                	mv	a0,s6
    80004806:	821fc0ef          	jal	80001026 <walkaddr>
    8000480a:	862a                	mv	a2,a0
    if(pa == 0)
    8000480c:	d561                	beqz	a0,800047d4 <kexec+0xce>
    if(sz - i < PGSIZE)
    8000480e:	409987bb          	subw	a5,s3,s1
    80004812:	893e                	mv	s2,a5
    80004814:	fcfcf6e3          	bgeu	s9,a5,800047e0 <kexec+0xda>
    80004818:	8956                	mv	s2,s5
    8000481a:	b7d9                	j	800047e0 <kexec+0xda>
    sz = sz1;
    8000481c:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004820:	2d05                	addiw	s10,s10,1
    80004822:	e0843783          	ld	a5,-504(s0)
    80004826:	0387869b          	addiw	a3,a5,56
    8000482a:	e8845783          	lhu	a5,-376(s0)
    8000482e:	06fd5e63          	bge	s10,a5,800048aa <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004832:	e0d43423          	sd	a3,-504(s0)
    80004836:	876e                	mv	a4,s11
    80004838:	e1840613          	addi	a2,s0,-488
    8000483c:	4581                	li	a1,0
    8000483e:	8552                	mv	a0,s4
    80004840:	dddfe0ef          	jal	8000361c <readi>
    80004844:	1db51f63          	bne	a0,s11,80004a22 <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    80004848:	e1842783          	lw	a5,-488(s0)
    8000484c:	4705                	li	a4,1
    8000484e:	fce799e3          	bne	a5,a4,80004820 <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    80004852:	e4043483          	ld	s1,-448(s0)
    80004856:	e3843783          	ld	a5,-456(s0)
    8000485a:	1ef4e463          	bltu	s1,a5,80004a42 <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000485e:	e2843783          	ld	a5,-472(s0)
    80004862:	94be                	add	s1,s1,a5
    80004864:	1ef4e263          	bltu	s1,a5,80004a48 <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    80004868:	de843703          	ld	a4,-536(s0)
    8000486c:	8ff9                	and	a5,a5,a4
    8000486e:	1e079063          	bnez	a5,80004a4e <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004872:	e1c42503          	lw	a0,-484(s0)
    80004876:	e71ff0ef          	jal	800046e6 <flags2perm>
    8000487a:	86aa                	mv	a3,a0
    8000487c:	8626                	mv	a2,s1
    8000487e:	85ca                	mv	a1,s2
    80004880:	855a                	mv	a0,s6
    80004882:	a7bfc0ef          	jal	800012fc <uvmalloc>
    80004886:	dea43c23          	sd	a0,-520(s0)
    8000488a:	1c050563          	beqz	a0,80004a54 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000488e:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004892:	00098863          	beqz	s3,800048a2 <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004896:	e2843c03          	ld	s8,-472(s0)
    8000489a:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000489e:	4481                	li	s1,0
    800048a0:	bfb1                	j	800047fc <kexec+0xf6>
    sz = sz1;
    800048a2:	df843903          	ld	s2,-520(s0)
    800048a6:	bfad                	j	80004820 <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800048a8:	4901                	li	s2,0
  iunlockput(ip);
    800048aa:	8552                	mv	a0,s4
    800048ac:	bebfe0ef          	jal	80003496 <iunlockput>
  end_op();
    800048b0:	c56ff0ef          	jal	80003d06 <end_op>
  p = myproc();
    800048b4:	87afd0ef          	jal	8000192e <myproc>
    800048b8:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800048ba:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800048be:	6985                	lui	s3,0x1
    800048c0:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800048c2:	99ca                	add	s3,s3,s2
    800048c4:	77fd                	lui	a5,0xfffff
    800048c6:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800048ca:	4691                	li	a3,4
    800048cc:	6609                	lui	a2,0x2
    800048ce:	964e                	add	a2,a2,s3
    800048d0:	85ce                	mv	a1,s3
    800048d2:	855a                	mv	a0,s6
    800048d4:	a29fc0ef          	jal	800012fc <uvmalloc>
    800048d8:	8a2a                	mv	s4,a0
    800048da:	e105                	bnez	a0,800048fa <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    800048dc:	85ce                	mv	a1,s3
    800048de:	855a                	mv	a0,s6
    800048e0:	9dcfd0ef          	jal	80001abc <proc_freepagetable>
  return -1;
    800048e4:	557d                	li	a0,-1
    800048e6:	79fe                	ld	s3,504(sp)
    800048e8:	7a5e                	ld	s4,496(sp)
    800048ea:	7abe                	ld	s5,488(sp)
    800048ec:	7b1e                	ld	s6,480(sp)
    800048ee:	6bfe                	ld	s7,472(sp)
    800048f0:	6c5e                	ld	s8,464(sp)
    800048f2:	6cbe                	ld	s9,456(sp)
    800048f4:	6d1e                	ld	s10,448(sp)
    800048f6:	7dfa                	ld	s11,440(sp)
    800048f8:	b541                	j	80004778 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800048fa:	75f9                	lui	a1,0xffffe
    800048fc:	95aa                	add	a1,a1,a0
    800048fe:	855a                	mv	a0,s6
    80004900:	bcffc0ef          	jal	800014ce <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004904:	800a0b93          	addi	s7,s4,-2048
    80004908:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    8000490c:	e0043783          	ld	a5,-512(s0)
    80004910:	6388                	ld	a0,0(a5)
  sp = sz;
    80004912:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004914:	4481                	li	s1,0
    ustack[argc] = sp;
    80004916:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    8000491a:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    8000491e:	cd21                	beqz	a0,80004976 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004920:	d62fc0ef          	jal	80000e82 <strlen>
    80004924:	0015079b          	addiw	a5,a0,1
    80004928:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000492c:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004930:	13796563          	bltu	s2,s7,80004a5a <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004934:	e0043d83          	ld	s11,-512(s0)
    80004938:	000db983          	ld	s3,0(s11)
    8000493c:	854e                	mv	a0,s3
    8000493e:	d44fc0ef          	jal	80000e82 <strlen>
    80004942:	0015069b          	addiw	a3,a0,1
    80004946:	864e                	mv	a2,s3
    80004948:	85ca                	mv	a1,s2
    8000494a:	855a                	mv	a0,s6
    8000494c:	d09fc0ef          	jal	80001654 <copyout>
    80004950:	10054763          	bltz	a0,80004a5e <kexec+0x358>
    ustack[argc] = sp;
    80004954:	00349793          	slli	a5,s1,0x3
    80004958:	97e6                	add	a5,a5,s9
    8000495a:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffde288>
  for(argc = 0; argv[argc]; argc++) {
    8000495e:	0485                	addi	s1,s1,1
    80004960:	008d8793          	addi	a5,s11,8
    80004964:	e0f43023          	sd	a5,-512(s0)
    80004968:	008db503          	ld	a0,8(s11)
    8000496c:	c509                	beqz	a0,80004976 <kexec+0x270>
    if(argc >= MAXARG)
    8000496e:	fb8499e3          	bne	s1,s8,80004920 <kexec+0x21a>
  sz = sz1;
    80004972:	89d2                	mv	s3,s4
    80004974:	b7a5                	j	800048dc <kexec+0x1d6>
  ustack[argc] = 0;
    80004976:	00349793          	slli	a5,s1,0x3
    8000497a:	f9078793          	addi	a5,a5,-112
    8000497e:	97a2                	add	a5,a5,s0
    80004980:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004984:	00349693          	slli	a3,s1,0x3
    80004988:	06a1                	addi	a3,a3,8
    8000498a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000498e:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004992:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004994:	f57964e3          	bltu	s2,s7,800048dc <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004998:	e9040613          	addi	a2,s0,-368
    8000499c:	85ca                	mv	a1,s2
    8000499e:	855a                	mv	a0,s6
    800049a0:	cb5fc0ef          	jal	80001654 <copyout>
    800049a4:	f2054ce3          	bltz	a0,800048dc <kexec+0x1d6>
  p->trapframe->a1 = sp;
    800049a8:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800049ac:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800049b0:	df043783          	ld	a5,-528(s0)
    800049b4:	0007c703          	lbu	a4,0(a5)
    800049b8:	cf11                	beqz	a4,800049d4 <kexec+0x2ce>
    800049ba:	0785                	addi	a5,a5,1
    if(*s == '/')
    800049bc:	02f00693          	li	a3,47
    800049c0:	a029                	j	800049ca <kexec+0x2c4>
  for(last=s=path; *s; s++)
    800049c2:	0785                	addi	a5,a5,1
    800049c4:	fff7c703          	lbu	a4,-1(a5)
    800049c8:	c711                	beqz	a4,800049d4 <kexec+0x2ce>
    if(*s == '/')
    800049ca:	fed71ce3          	bne	a4,a3,800049c2 <kexec+0x2bc>
      last = s+1;
    800049ce:	def43823          	sd	a5,-528(s0)
    800049d2:	bfc5                	j	800049c2 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    800049d4:	4641                	li	a2,16
    800049d6:	df043583          	ld	a1,-528(s0)
    800049da:	158a8513          	addi	a0,s5,344
    800049de:	c6efc0ef          	jal	80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    800049e2:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800049e6:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800049ea:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    800049ee:	058ab783          	ld	a5,88(s5)
    800049f2:	e6843703          	ld	a4,-408(s0)
    800049f6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800049f8:	058ab783          	ld	a5,88(s5)
    800049fc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004a00:	85ea                	mv	a1,s10
    80004a02:	8bafd0ef          	jal	80001abc <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004a06:	0004851b          	sext.w	a0,s1
    80004a0a:	79fe                	ld	s3,504(sp)
    80004a0c:	7a5e                	ld	s4,496(sp)
    80004a0e:	7abe                	ld	s5,488(sp)
    80004a10:	7b1e                	ld	s6,480(sp)
    80004a12:	6bfe                	ld	s7,472(sp)
    80004a14:	6c5e                	ld	s8,464(sp)
    80004a16:	6cbe                	ld	s9,456(sp)
    80004a18:	6d1e                	ld	s10,448(sp)
    80004a1a:	7dfa                	ld	s11,440(sp)
    80004a1c:	bbb1                	j	80004778 <kexec+0x72>
    80004a1e:	7b1e                	ld	s6,480(sp)
    80004a20:	b3a9                	j	8000476a <kexec+0x64>
    80004a22:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004a26:	df843583          	ld	a1,-520(s0)
    80004a2a:	855a                	mv	a0,s6
    80004a2c:	890fd0ef          	jal	80001abc <proc_freepagetable>
  if(ip){
    80004a30:	79fe                	ld	s3,504(sp)
    80004a32:	7abe                	ld	s5,488(sp)
    80004a34:	7b1e                	ld	s6,480(sp)
    80004a36:	6bfe                	ld	s7,472(sp)
    80004a38:	6c5e                	ld	s8,464(sp)
    80004a3a:	6cbe                	ld	s9,456(sp)
    80004a3c:	6d1e                	ld	s10,448(sp)
    80004a3e:	7dfa                	ld	s11,440(sp)
    80004a40:	b32d                	j	8000476a <kexec+0x64>
    80004a42:	df243c23          	sd	s2,-520(s0)
    80004a46:	b7c5                	j	80004a26 <kexec+0x320>
    80004a48:	df243c23          	sd	s2,-520(s0)
    80004a4c:	bfe9                	j	80004a26 <kexec+0x320>
    80004a4e:	df243c23          	sd	s2,-520(s0)
    80004a52:	bfd1                	j	80004a26 <kexec+0x320>
    80004a54:	df243c23          	sd	s2,-520(s0)
    80004a58:	b7f9                	j	80004a26 <kexec+0x320>
  sz = sz1;
    80004a5a:	89d2                	mv	s3,s4
    80004a5c:	b541                	j	800048dc <kexec+0x1d6>
    80004a5e:	89d2                	mv	s3,s4
    80004a60:	bdb5                	j	800048dc <kexec+0x1d6>

0000000080004a62 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004a62:	7179                	addi	sp,sp,-48
    80004a64:	f406                	sd	ra,40(sp)
    80004a66:	f022                	sd	s0,32(sp)
    80004a68:	ec26                	sd	s1,24(sp)
    80004a6a:	e84a                	sd	s2,16(sp)
    80004a6c:	1800                	addi	s0,sp,48
    80004a6e:	892e                	mv	s2,a1
    80004a70:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004a72:	fdc40593          	addi	a1,s0,-36
    80004a76:	dd5fd0ef          	jal	8000284a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004a7a:	fdc42703          	lw	a4,-36(s0)
    80004a7e:	47bd                	li	a5,15
    80004a80:	02e7ea63          	bltu	a5,a4,80004ab4 <argfd+0x52>
    80004a84:	eabfc0ef          	jal	8000192e <myproc>
    80004a88:	fdc42703          	lw	a4,-36(s0)
    80004a8c:	00371793          	slli	a5,a4,0x3
    80004a90:	0d078793          	addi	a5,a5,208
    80004a94:	953e                	add	a0,a0,a5
    80004a96:	611c                	ld	a5,0(a0)
    80004a98:	c385                	beqz	a5,80004ab8 <argfd+0x56>
    return -1;
  if(pfd)
    80004a9a:	00090463          	beqz	s2,80004aa2 <argfd+0x40>
    *pfd = fd;
    80004a9e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004aa2:	4501                	li	a0,0
  if(pf)
    80004aa4:	c091                	beqz	s1,80004aa8 <argfd+0x46>
    *pf = f;
    80004aa6:	e09c                	sd	a5,0(s1)
}
    80004aa8:	70a2                	ld	ra,40(sp)
    80004aaa:	7402                	ld	s0,32(sp)
    80004aac:	64e2                	ld	s1,24(sp)
    80004aae:	6942                	ld	s2,16(sp)
    80004ab0:	6145                	addi	sp,sp,48
    80004ab2:	8082                	ret
    return -1;
    80004ab4:	557d                	li	a0,-1
    80004ab6:	bfcd                	j	80004aa8 <argfd+0x46>
    80004ab8:	557d                	li	a0,-1
    80004aba:	b7fd                	j	80004aa8 <argfd+0x46>

0000000080004abc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004abc:	1101                	addi	sp,sp,-32
    80004abe:	ec06                	sd	ra,24(sp)
    80004ac0:	e822                	sd	s0,16(sp)
    80004ac2:	e426                	sd	s1,8(sp)
    80004ac4:	1000                	addi	s0,sp,32
    80004ac6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004ac8:	e67fc0ef          	jal	8000192e <myproc>
    80004acc:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004ace:	0d050793          	addi	a5,a0,208
    80004ad2:	4501                	li	a0,0
    80004ad4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004ad6:	6398                	ld	a4,0(a5)
    80004ad8:	cb19                	beqz	a4,80004aee <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004ada:	2505                	addiw	a0,a0,1
    80004adc:	07a1                	addi	a5,a5,8
    80004ade:	fed51ce3          	bne	a0,a3,80004ad6 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004ae2:	557d                	li	a0,-1
}
    80004ae4:	60e2                	ld	ra,24(sp)
    80004ae6:	6442                	ld	s0,16(sp)
    80004ae8:	64a2                	ld	s1,8(sp)
    80004aea:	6105                	addi	sp,sp,32
    80004aec:	8082                	ret
      p->ofile[fd] = f;
    80004aee:	00351793          	slli	a5,a0,0x3
    80004af2:	0d078793          	addi	a5,a5,208
    80004af6:	963e                	add	a2,a2,a5
    80004af8:	e204                	sd	s1,0(a2)
      return fd;
    80004afa:	b7ed                	j	80004ae4 <fdalloc+0x28>

0000000080004afc <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004afc:	715d                	addi	sp,sp,-80
    80004afe:	e486                	sd	ra,72(sp)
    80004b00:	e0a2                	sd	s0,64(sp)
    80004b02:	fc26                	sd	s1,56(sp)
    80004b04:	f84a                	sd	s2,48(sp)
    80004b06:	f44e                	sd	s3,40(sp)
    80004b08:	f052                	sd	s4,32(sp)
    80004b0a:	ec56                	sd	s5,24(sp)
    80004b0c:	e85a                	sd	s6,16(sp)
    80004b0e:	0880                	addi	s0,sp,80
    80004b10:	892e                	mv	s2,a1
    80004b12:	8a2e                	mv	s4,a1
    80004b14:	8ab2                	mv	s5,a2
    80004b16:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004b18:	fb040593          	addi	a1,s0,-80
    80004b1c:	fb7fe0ef          	jal	80003ad2 <nameiparent>
    80004b20:	84aa                	mv	s1,a0
    80004b22:	10050763          	beqz	a0,80004c30 <create+0x134>
    return 0;

  ilock(dp);
    80004b26:	f64fe0ef          	jal	8000328a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004b2a:	4601                	li	a2,0
    80004b2c:	fb040593          	addi	a1,s0,-80
    80004b30:	8526                	mv	a0,s1
    80004b32:	cf3fe0ef          	jal	80003824 <dirlookup>
    80004b36:	89aa                	mv	s3,a0
    80004b38:	c131                	beqz	a0,80004b7c <create+0x80>
    iunlockput(dp);
    80004b3a:	8526                	mv	a0,s1
    80004b3c:	95bfe0ef          	jal	80003496 <iunlockput>
    ilock(ip);
    80004b40:	854e                	mv	a0,s3
    80004b42:	f48fe0ef          	jal	8000328a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004b46:	4789                	li	a5,2
    80004b48:	02f91563          	bne	s2,a5,80004b72 <create+0x76>
    80004b4c:	0449d783          	lhu	a5,68(s3)
    80004b50:	37f9                	addiw	a5,a5,-2
    80004b52:	17c2                	slli	a5,a5,0x30
    80004b54:	93c1                	srli	a5,a5,0x30
    80004b56:	4705                	li	a4,1
    80004b58:	00f76d63          	bltu	a4,a5,80004b72 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004b5c:	854e                	mv	a0,s3
    80004b5e:	60a6                	ld	ra,72(sp)
    80004b60:	6406                	ld	s0,64(sp)
    80004b62:	74e2                	ld	s1,56(sp)
    80004b64:	7942                	ld	s2,48(sp)
    80004b66:	79a2                	ld	s3,40(sp)
    80004b68:	7a02                	ld	s4,32(sp)
    80004b6a:	6ae2                	ld	s5,24(sp)
    80004b6c:	6b42                	ld	s6,16(sp)
    80004b6e:	6161                	addi	sp,sp,80
    80004b70:	8082                	ret
    iunlockput(ip);
    80004b72:	854e                	mv	a0,s3
    80004b74:	923fe0ef          	jal	80003496 <iunlockput>
    return 0;
    80004b78:	4981                	li	s3,0
    80004b7a:	b7cd                	j	80004b5c <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004b7c:	85ca                	mv	a1,s2
    80004b7e:	4088                	lw	a0,0(s1)
    80004b80:	d9afe0ef          	jal	8000311a <ialloc>
    80004b84:	892a                	mv	s2,a0
    80004b86:	cd15                	beqz	a0,80004bc2 <create+0xc6>
  ilock(ip);
    80004b88:	f02fe0ef          	jal	8000328a <ilock>
  ip->major = major;
    80004b8c:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80004b90:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80004b94:	4785                	li	a5,1
    80004b96:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004b9a:	854a                	mv	a0,s2
    80004b9c:	e3afe0ef          	jal	800031d6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004ba0:	4705                	li	a4,1
    80004ba2:	02ea0463          	beq	s4,a4,80004bca <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004ba6:	00492603          	lw	a2,4(s2)
    80004baa:	fb040593          	addi	a1,s0,-80
    80004bae:	8526                	mv	a0,s1
    80004bb0:	e5ffe0ef          	jal	80003a0e <dirlink>
    80004bb4:	06054263          	bltz	a0,80004c18 <create+0x11c>
  iunlockput(dp);
    80004bb8:	8526                	mv	a0,s1
    80004bba:	8ddfe0ef          	jal	80003496 <iunlockput>
  return ip;
    80004bbe:	89ca                	mv	s3,s2
    80004bc0:	bf71                	j	80004b5c <create+0x60>
    iunlockput(dp);
    80004bc2:	8526                	mv	a0,s1
    80004bc4:	8d3fe0ef          	jal	80003496 <iunlockput>
    return 0;
    80004bc8:	bf51                	j	80004b5c <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004bca:	00492603          	lw	a2,4(s2)
    80004bce:	00003597          	auipc	a1,0x3
    80004bd2:	9f258593          	addi	a1,a1,-1550 # 800075c0 <etext+0x5c0>
    80004bd6:	854a                	mv	a0,s2
    80004bd8:	e37fe0ef          	jal	80003a0e <dirlink>
    80004bdc:	02054e63          	bltz	a0,80004c18 <create+0x11c>
    80004be0:	40d0                	lw	a2,4(s1)
    80004be2:	00003597          	auipc	a1,0x3
    80004be6:	9e658593          	addi	a1,a1,-1562 # 800075c8 <etext+0x5c8>
    80004bea:	854a                	mv	a0,s2
    80004bec:	e23fe0ef          	jal	80003a0e <dirlink>
    80004bf0:	02054463          	bltz	a0,80004c18 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004bf4:	00492603          	lw	a2,4(s2)
    80004bf8:	fb040593          	addi	a1,s0,-80
    80004bfc:	8526                	mv	a0,s1
    80004bfe:	e11fe0ef          	jal	80003a0e <dirlink>
    80004c02:	00054b63          	bltz	a0,80004c18 <create+0x11c>
    dp->nlink++;  // for ".."
    80004c06:	04a4d783          	lhu	a5,74(s1)
    80004c0a:	2785                	addiw	a5,a5,1
    80004c0c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004c10:	8526                	mv	a0,s1
    80004c12:	dc4fe0ef          	jal	800031d6 <iupdate>
    80004c16:	b74d                	j	80004bb8 <create+0xbc>
  ip->nlink = 0;
    80004c18:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80004c1c:	854a                	mv	a0,s2
    80004c1e:	db8fe0ef          	jal	800031d6 <iupdate>
  iunlockput(ip);
    80004c22:	854a                	mv	a0,s2
    80004c24:	873fe0ef          	jal	80003496 <iunlockput>
  iunlockput(dp);
    80004c28:	8526                	mv	a0,s1
    80004c2a:	86dfe0ef          	jal	80003496 <iunlockput>
  return 0;
    80004c2e:	b73d                	j	80004b5c <create+0x60>
    return 0;
    80004c30:	89aa                	mv	s3,a0
    80004c32:	b72d                	j	80004b5c <create+0x60>

0000000080004c34 <sys_dup>:
{
    80004c34:	7179                	addi	sp,sp,-48
    80004c36:	f406                	sd	ra,40(sp)
    80004c38:	f022                	sd	s0,32(sp)
    80004c3a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004c3c:	fd840613          	addi	a2,s0,-40
    80004c40:	4581                	li	a1,0
    80004c42:	4501                	li	a0,0
    80004c44:	e1fff0ef          	jal	80004a62 <argfd>
    return -1;
    80004c48:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004c4a:	02054363          	bltz	a0,80004c70 <sys_dup+0x3c>
    80004c4e:	ec26                	sd	s1,24(sp)
    80004c50:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004c52:	fd843483          	ld	s1,-40(s0)
    80004c56:	8526                	mv	a0,s1
    80004c58:	e65ff0ef          	jal	80004abc <fdalloc>
    80004c5c:	892a                	mv	s2,a0
    return -1;
    80004c5e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004c60:	00054d63          	bltz	a0,80004c7a <sys_dup+0x46>
  filedup(f);
    80004c64:	8526                	mv	a0,s1
    80004c66:	c0eff0ef          	jal	80004074 <filedup>
  return fd;
    80004c6a:	87ca                	mv	a5,s2
    80004c6c:	64e2                	ld	s1,24(sp)
    80004c6e:	6942                	ld	s2,16(sp)
}
    80004c70:	853e                	mv	a0,a5
    80004c72:	70a2                	ld	ra,40(sp)
    80004c74:	7402                	ld	s0,32(sp)
    80004c76:	6145                	addi	sp,sp,48
    80004c78:	8082                	ret
    80004c7a:	64e2                	ld	s1,24(sp)
    80004c7c:	6942                	ld	s2,16(sp)
    80004c7e:	bfcd                	j	80004c70 <sys_dup+0x3c>

0000000080004c80 <sys_read>:
{
    80004c80:	7179                	addi	sp,sp,-48
    80004c82:	f406                	sd	ra,40(sp)
    80004c84:	f022                	sd	s0,32(sp)
    80004c86:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c88:	fd840593          	addi	a1,s0,-40
    80004c8c:	4505                	li	a0,1
    80004c8e:	bd9fd0ef          	jal	80002866 <argaddr>
  argint(2, &n);
    80004c92:	fe440593          	addi	a1,s0,-28
    80004c96:	4509                	li	a0,2
    80004c98:	bb3fd0ef          	jal	8000284a <argint>
  if(argfd(0, 0, &f) < 0)
    80004c9c:	fe840613          	addi	a2,s0,-24
    80004ca0:	4581                	li	a1,0
    80004ca2:	4501                	li	a0,0
    80004ca4:	dbfff0ef          	jal	80004a62 <argfd>
    80004ca8:	87aa                	mv	a5,a0
    return -1;
    80004caa:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004cac:	0007ca63          	bltz	a5,80004cc0 <sys_read+0x40>
  return fileread(f, p, n);
    80004cb0:	fe442603          	lw	a2,-28(s0)
    80004cb4:	fd843583          	ld	a1,-40(s0)
    80004cb8:	fe843503          	ld	a0,-24(s0)
    80004cbc:	d22ff0ef          	jal	800041de <fileread>
}
    80004cc0:	70a2                	ld	ra,40(sp)
    80004cc2:	7402                	ld	s0,32(sp)
    80004cc4:	6145                	addi	sp,sp,48
    80004cc6:	8082                	ret

0000000080004cc8 <sys_write>:
{
    80004cc8:	7179                	addi	sp,sp,-48
    80004cca:	f406                	sd	ra,40(sp)
    80004ccc:	f022                	sd	s0,32(sp)
    80004cce:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004cd0:	fd840593          	addi	a1,s0,-40
    80004cd4:	4505                	li	a0,1
    80004cd6:	b91fd0ef          	jal	80002866 <argaddr>
  argint(2, &n);
    80004cda:	fe440593          	addi	a1,s0,-28
    80004cde:	4509                	li	a0,2
    80004ce0:	b6bfd0ef          	jal	8000284a <argint>
  if(argfd(0, 0, &f) < 0)
    80004ce4:	fe840613          	addi	a2,s0,-24
    80004ce8:	4581                	li	a1,0
    80004cea:	4501                	li	a0,0
    80004cec:	d77ff0ef          	jal	80004a62 <argfd>
    80004cf0:	87aa                	mv	a5,a0
    return -1;
    80004cf2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004cf4:	0007ca63          	bltz	a5,80004d08 <sys_write+0x40>
  return filewrite(f, p, n);
    80004cf8:	fe442603          	lw	a2,-28(s0)
    80004cfc:	fd843583          	ld	a1,-40(s0)
    80004d00:	fe843503          	ld	a0,-24(s0)
    80004d04:	d9eff0ef          	jal	800042a2 <filewrite>
}
    80004d08:	70a2                	ld	ra,40(sp)
    80004d0a:	7402                	ld	s0,32(sp)
    80004d0c:	6145                	addi	sp,sp,48
    80004d0e:	8082                	ret

0000000080004d10 <sys_close>:
{
    80004d10:	1101                	addi	sp,sp,-32
    80004d12:	ec06                	sd	ra,24(sp)
    80004d14:	e822                	sd	s0,16(sp)
    80004d16:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004d18:	fe040613          	addi	a2,s0,-32
    80004d1c:	fec40593          	addi	a1,s0,-20
    80004d20:	4501                	li	a0,0
    80004d22:	d41ff0ef          	jal	80004a62 <argfd>
    return -1;
    80004d26:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004d28:	02054163          	bltz	a0,80004d4a <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004d2c:	c03fc0ef          	jal	8000192e <myproc>
    80004d30:	fec42783          	lw	a5,-20(s0)
    80004d34:	078e                	slli	a5,a5,0x3
    80004d36:	0d078793          	addi	a5,a5,208
    80004d3a:	953e                	add	a0,a0,a5
    80004d3c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004d40:	fe043503          	ld	a0,-32(s0)
    80004d44:	b76ff0ef          	jal	800040ba <fileclose>
  return 0;
    80004d48:	4781                	li	a5,0
}
    80004d4a:	853e                	mv	a0,a5
    80004d4c:	60e2                	ld	ra,24(sp)
    80004d4e:	6442                	ld	s0,16(sp)
    80004d50:	6105                	addi	sp,sp,32
    80004d52:	8082                	ret

0000000080004d54 <sys_fstat>:
{
    80004d54:	1101                	addi	sp,sp,-32
    80004d56:	ec06                	sd	ra,24(sp)
    80004d58:	e822                	sd	s0,16(sp)
    80004d5a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004d5c:	fe040593          	addi	a1,s0,-32
    80004d60:	4505                	li	a0,1
    80004d62:	b05fd0ef          	jal	80002866 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004d66:	fe840613          	addi	a2,s0,-24
    80004d6a:	4581                	li	a1,0
    80004d6c:	4501                	li	a0,0
    80004d6e:	cf5ff0ef          	jal	80004a62 <argfd>
    80004d72:	87aa                	mv	a5,a0
    return -1;
    80004d74:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d76:	0007c863          	bltz	a5,80004d86 <sys_fstat+0x32>
  return filestat(f, st);
    80004d7a:	fe043583          	ld	a1,-32(s0)
    80004d7e:	fe843503          	ld	a0,-24(s0)
    80004d82:	bfaff0ef          	jal	8000417c <filestat>
}
    80004d86:	60e2                	ld	ra,24(sp)
    80004d88:	6442                	ld	s0,16(sp)
    80004d8a:	6105                	addi	sp,sp,32
    80004d8c:	8082                	ret

0000000080004d8e <sys_link>:
{
    80004d8e:	7169                	addi	sp,sp,-304
    80004d90:	f606                	sd	ra,296(sp)
    80004d92:	f222                	sd	s0,288(sp)
    80004d94:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d96:	08000613          	li	a2,128
    80004d9a:	ed040593          	addi	a1,s0,-304
    80004d9e:	4501                	li	a0,0
    80004da0:	ae3fd0ef          	jal	80002882 <argstr>
    return -1;
    80004da4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004da6:	0c054e63          	bltz	a0,80004e82 <sys_link+0xf4>
    80004daa:	08000613          	li	a2,128
    80004dae:	f5040593          	addi	a1,s0,-176
    80004db2:	4505                	li	a0,1
    80004db4:	acffd0ef          	jal	80002882 <argstr>
    return -1;
    80004db8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004dba:	0c054463          	bltz	a0,80004e82 <sys_link+0xf4>
    80004dbe:	ee26                	sd	s1,280(sp)
  begin_op();
    80004dc0:	ed7fe0ef          	jal	80003c96 <begin_op>
  if((ip = namei(old)) == 0){
    80004dc4:	ed040513          	addi	a0,s0,-304
    80004dc8:	cf1fe0ef          	jal	80003ab8 <namei>
    80004dcc:	84aa                	mv	s1,a0
    80004dce:	c53d                	beqz	a0,80004e3c <sys_link+0xae>
  ilock(ip);
    80004dd0:	cbafe0ef          	jal	8000328a <ilock>
  if(ip->type == T_DIR){
    80004dd4:	04449703          	lh	a4,68(s1)
    80004dd8:	4785                	li	a5,1
    80004dda:	06f70663          	beq	a4,a5,80004e46 <sys_link+0xb8>
    80004dde:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004de0:	04a4d783          	lhu	a5,74(s1)
    80004de4:	2785                	addiw	a5,a5,1
    80004de6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004dea:	8526                	mv	a0,s1
    80004dec:	beafe0ef          	jal	800031d6 <iupdate>
  iunlock(ip);
    80004df0:	8526                	mv	a0,s1
    80004df2:	d46fe0ef          	jal	80003338 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004df6:	fd040593          	addi	a1,s0,-48
    80004dfa:	f5040513          	addi	a0,s0,-176
    80004dfe:	cd5fe0ef          	jal	80003ad2 <nameiparent>
    80004e02:	892a                	mv	s2,a0
    80004e04:	cd21                	beqz	a0,80004e5c <sys_link+0xce>
  ilock(dp);
    80004e06:	c84fe0ef          	jal	8000328a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004e0a:	854a                	mv	a0,s2
    80004e0c:	00092703          	lw	a4,0(s2)
    80004e10:	409c                	lw	a5,0(s1)
    80004e12:	04f71263          	bne	a4,a5,80004e56 <sys_link+0xc8>
    80004e16:	40d0                	lw	a2,4(s1)
    80004e18:	fd040593          	addi	a1,s0,-48
    80004e1c:	bf3fe0ef          	jal	80003a0e <dirlink>
    80004e20:	02054b63          	bltz	a0,80004e56 <sys_link+0xc8>
  iunlockput(dp);
    80004e24:	854a                	mv	a0,s2
    80004e26:	e70fe0ef          	jal	80003496 <iunlockput>
  iput(ip);
    80004e2a:	8526                	mv	a0,s1
    80004e2c:	de0fe0ef          	jal	8000340c <iput>
  end_op();
    80004e30:	ed7fe0ef          	jal	80003d06 <end_op>
  return 0;
    80004e34:	4781                	li	a5,0
    80004e36:	64f2                	ld	s1,280(sp)
    80004e38:	6952                	ld	s2,272(sp)
    80004e3a:	a0a1                	j	80004e82 <sys_link+0xf4>
    end_op();
    80004e3c:	ecbfe0ef          	jal	80003d06 <end_op>
    return -1;
    80004e40:	57fd                	li	a5,-1
    80004e42:	64f2                	ld	s1,280(sp)
    80004e44:	a83d                	j	80004e82 <sys_link+0xf4>
    iunlockput(ip);
    80004e46:	8526                	mv	a0,s1
    80004e48:	e4efe0ef          	jal	80003496 <iunlockput>
    end_op();
    80004e4c:	ebbfe0ef          	jal	80003d06 <end_op>
    return -1;
    80004e50:	57fd                	li	a5,-1
    80004e52:	64f2                	ld	s1,280(sp)
    80004e54:	a03d                	j	80004e82 <sys_link+0xf4>
    iunlockput(dp);
    80004e56:	854a                	mv	a0,s2
    80004e58:	e3efe0ef          	jal	80003496 <iunlockput>
  ilock(ip);
    80004e5c:	8526                	mv	a0,s1
    80004e5e:	c2cfe0ef          	jal	8000328a <ilock>
  ip->nlink--;
    80004e62:	04a4d783          	lhu	a5,74(s1)
    80004e66:	37fd                	addiw	a5,a5,-1
    80004e68:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e6c:	8526                	mv	a0,s1
    80004e6e:	b68fe0ef          	jal	800031d6 <iupdate>
  iunlockput(ip);
    80004e72:	8526                	mv	a0,s1
    80004e74:	e22fe0ef          	jal	80003496 <iunlockput>
  end_op();
    80004e78:	e8ffe0ef          	jal	80003d06 <end_op>
  return -1;
    80004e7c:	57fd                	li	a5,-1
    80004e7e:	64f2                	ld	s1,280(sp)
    80004e80:	6952                	ld	s2,272(sp)
}
    80004e82:	853e                	mv	a0,a5
    80004e84:	70b2                	ld	ra,296(sp)
    80004e86:	7412                	ld	s0,288(sp)
    80004e88:	6155                	addi	sp,sp,304
    80004e8a:	8082                	ret

0000000080004e8c <sys_unlink>:
{
    80004e8c:	7151                	addi	sp,sp,-240
    80004e8e:	f586                	sd	ra,232(sp)
    80004e90:	f1a2                	sd	s0,224(sp)
    80004e92:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004e94:	08000613          	li	a2,128
    80004e98:	f3040593          	addi	a1,s0,-208
    80004e9c:	4501                	li	a0,0
    80004e9e:	9e5fd0ef          	jal	80002882 <argstr>
    80004ea2:	14054d63          	bltz	a0,80004ffc <sys_unlink+0x170>
    80004ea6:	eda6                	sd	s1,216(sp)
  begin_op();
    80004ea8:	deffe0ef          	jal	80003c96 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004eac:	fb040593          	addi	a1,s0,-80
    80004eb0:	f3040513          	addi	a0,s0,-208
    80004eb4:	c1ffe0ef          	jal	80003ad2 <nameiparent>
    80004eb8:	84aa                	mv	s1,a0
    80004eba:	c955                	beqz	a0,80004f6e <sys_unlink+0xe2>
  ilock(dp);
    80004ebc:	bcefe0ef          	jal	8000328a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004ec0:	00002597          	auipc	a1,0x2
    80004ec4:	70058593          	addi	a1,a1,1792 # 800075c0 <etext+0x5c0>
    80004ec8:	fb040513          	addi	a0,s0,-80
    80004ecc:	943fe0ef          	jal	8000380e <namecmp>
    80004ed0:	10050b63          	beqz	a0,80004fe6 <sys_unlink+0x15a>
    80004ed4:	00002597          	auipc	a1,0x2
    80004ed8:	6f458593          	addi	a1,a1,1780 # 800075c8 <etext+0x5c8>
    80004edc:	fb040513          	addi	a0,s0,-80
    80004ee0:	92ffe0ef          	jal	8000380e <namecmp>
    80004ee4:	10050163          	beqz	a0,80004fe6 <sys_unlink+0x15a>
    80004ee8:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004eea:	f2c40613          	addi	a2,s0,-212
    80004eee:	fb040593          	addi	a1,s0,-80
    80004ef2:	8526                	mv	a0,s1
    80004ef4:	931fe0ef          	jal	80003824 <dirlookup>
    80004ef8:	892a                	mv	s2,a0
    80004efa:	0e050563          	beqz	a0,80004fe4 <sys_unlink+0x158>
    80004efe:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80004f00:	b8afe0ef          	jal	8000328a <ilock>
  if(ip->nlink < 1)
    80004f04:	04a91783          	lh	a5,74(s2)
    80004f08:	06f05863          	blez	a5,80004f78 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004f0c:	04491703          	lh	a4,68(s2)
    80004f10:	4785                	li	a5,1
    80004f12:	06f70963          	beq	a4,a5,80004f84 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80004f16:	fc040993          	addi	s3,s0,-64
    80004f1a:	4641                	li	a2,16
    80004f1c:	4581                	li	a1,0
    80004f1e:	854e                	mv	a0,s3
    80004f20:	dd9fb0ef          	jal	80000cf8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f24:	4741                	li	a4,16
    80004f26:	f2c42683          	lw	a3,-212(s0)
    80004f2a:	864e                	mv	a2,s3
    80004f2c:	4581                	li	a1,0
    80004f2e:	8526                	mv	a0,s1
    80004f30:	fdefe0ef          	jal	8000370e <writei>
    80004f34:	47c1                	li	a5,16
    80004f36:	08f51863          	bne	a0,a5,80004fc6 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    80004f3a:	04491703          	lh	a4,68(s2)
    80004f3e:	4785                	li	a5,1
    80004f40:	08f70963          	beq	a4,a5,80004fd2 <sys_unlink+0x146>
  iunlockput(dp);
    80004f44:	8526                	mv	a0,s1
    80004f46:	d50fe0ef          	jal	80003496 <iunlockput>
  ip->nlink--;
    80004f4a:	04a95783          	lhu	a5,74(s2)
    80004f4e:	37fd                	addiw	a5,a5,-1
    80004f50:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004f54:	854a                	mv	a0,s2
    80004f56:	a80fe0ef          	jal	800031d6 <iupdate>
  iunlockput(ip);
    80004f5a:	854a                	mv	a0,s2
    80004f5c:	d3afe0ef          	jal	80003496 <iunlockput>
  end_op();
    80004f60:	da7fe0ef          	jal	80003d06 <end_op>
  return 0;
    80004f64:	4501                	li	a0,0
    80004f66:	64ee                	ld	s1,216(sp)
    80004f68:	694e                	ld	s2,208(sp)
    80004f6a:	69ae                	ld	s3,200(sp)
    80004f6c:	a061                	j	80004ff4 <sys_unlink+0x168>
    end_op();
    80004f6e:	d99fe0ef          	jal	80003d06 <end_op>
    return -1;
    80004f72:	557d                	li	a0,-1
    80004f74:	64ee                	ld	s1,216(sp)
    80004f76:	a8bd                	j	80004ff4 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004f78:	00002517          	auipc	a0,0x2
    80004f7c:	65850513          	addi	a0,a0,1624 # 800075d0 <etext+0x5d0>
    80004f80:	8a5fb0ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f84:	04c92703          	lw	a4,76(s2)
    80004f88:	02000793          	li	a5,32
    80004f8c:	f8e7f5e3          	bgeu	a5,a4,80004f16 <sys_unlink+0x8a>
    80004f90:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f92:	4741                	li	a4,16
    80004f94:	86ce                	mv	a3,s3
    80004f96:	f1840613          	addi	a2,s0,-232
    80004f9a:	4581                	li	a1,0
    80004f9c:	854a                	mv	a0,s2
    80004f9e:	e7efe0ef          	jal	8000361c <readi>
    80004fa2:	47c1                	li	a5,16
    80004fa4:	00f51b63          	bne	a0,a5,80004fba <sys_unlink+0x12e>
    if(de.inum != 0)
    80004fa8:	f1845783          	lhu	a5,-232(s0)
    80004fac:	ebb1                	bnez	a5,80005000 <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004fae:	29c1                	addiw	s3,s3,16
    80004fb0:	04c92783          	lw	a5,76(s2)
    80004fb4:	fcf9efe3          	bltu	s3,a5,80004f92 <sys_unlink+0x106>
    80004fb8:	bfb9                	j	80004f16 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004fba:	00002517          	auipc	a0,0x2
    80004fbe:	62e50513          	addi	a0,a0,1582 # 800075e8 <etext+0x5e8>
    80004fc2:	863fb0ef          	jal	80000824 <panic>
    panic("unlink: writei");
    80004fc6:	00002517          	auipc	a0,0x2
    80004fca:	63a50513          	addi	a0,a0,1594 # 80007600 <etext+0x600>
    80004fce:	857fb0ef          	jal	80000824 <panic>
    dp->nlink--;
    80004fd2:	04a4d783          	lhu	a5,74(s1)
    80004fd6:	37fd                	addiw	a5,a5,-1
    80004fd8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004fdc:	8526                	mv	a0,s1
    80004fde:	9f8fe0ef          	jal	800031d6 <iupdate>
    80004fe2:	b78d                	j	80004f44 <sys_unlink+0xb8>
    80004fe4:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004fe6:	8526                	mv	a0,s1
    80004fe8:	caefe0ef          	jal	80003496 <iunlockput>
  end_op();
    80004fec:	d1bfe0ef          	jal	80003d06 <end_op>
  return -1;
    80004ff0:	557d                	li	a0,-1
    80004ff2:	64ee                	ld	s1,216(sp)
}
    80004ff4:	70ae                	ld	ra,232(sp)
    80004ff6:	740e                	ld	s0,224(sp)
    80004ff8:	616d                	addi	sp,sp,240
    80004ffa:	8082                	ret
    return -1;
    80004ffc:	557d                	li	a0,-1
    80004ffe:	bfdd                	j	80004ff4 <sys_unlink+0x168>
    iunlockput(ip);
    80005000:	854a                	mv	a0,s2
    80005002:	c94fe0ef          	jal	80003496 <iunlockput>
    goto bad;
    80005006:	694e                	ld	s2,208(sp)
    80005008:	69ae                	ld	s3,200(sp)
    8000500a:	bff1                	j	80004fe6 <sys_unlink+0x15a>

000000008000500c <sys_open>:

uint64
sys_open(void)
{
    8000500c:	7131                	addi	sp,sp,-192
    8000500e:	fd06                	sd	ra,184(sp)
    80005010:	f922                	sd	s0,176(sp)
    80005012:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005014:	f4c40593          	addi	a1,s0,-180
    80005018:	4505                	li	a0,1
    8000501a:	831fd0ef          	jal	8000284a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000501e:	08000613          	li	a2,128
    80005022:	f5040593          	addi	a1,s0,-176
    80005026:	4501                	li	a0,0
    80005028:	85bfd0ef          	jal	80002882 <argstr>
    8000502c:	87aa                	mv	a5,a0
    return -1;
    8000502e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005030:	0a07c363          	bltz	a5,800050d6 <sys_open+0xca>
    80005034:	f526                	sd	s1,168(sp)

  begin_op();
    80005036:	c61fe0ef          	jal	80003c96 <begin_op>

  if(omode & O_CREATE){
    8000503a:	f4c42783          	lw	a5,-180(s0)
    8000503e:	2007f793          	andi	a5,a5,512
    80005042:	c3dd                	beqz	a5,800050e8 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005044:	4681                	li	a3,0
    80005046:	4601                	li	a2,0
    80005048:	4589                	li	a1,2
    8000504a:	f5040513          	addi	a0,s0,-176
    8000504e:	aafff0ef          	jal	80004afc <create>
    80005052:	84aa                	mv	s1,a0
    if(ip == 0){
    80005054:	c549                	beqz	a0,800050de <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005056:	04449703          	lh	a4,68(s1)
    8000505a:	478d                	li	a5,3
    8000505c:	00f71763          	bne	a4,a5,8000506a <sys_open+0x5e>
    80005060:	0464d703          	lhu	a4,70(s1)
    80005064:	47a5                	li	a5,9
    80005066:	0ae7ee63          	bltu	a5,a4,80005122 <sys_open+0x116>
    8000506a:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000506c:	fabfe0ef          	jal	80004016 <filealloc>
    80005070:	892a                	mv	s2,a0
    80005072:	c561                	beqz	a0,8000513a <sys_open+0x12e>
    80005074:	ed4e                	sd	s3,152(sp)
    80005076:	a47ff0ef          	jal	80004abc <fdalloc>
    8000507a:	89aa                	mv	s3,a0
    8000507c:	0a054b63          	bltz	a0,80005132 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005080:	04449703          	lh	a4,68(s1)
    80005084:	478d                	li	a5,3
    80005086:	0cf70363          	beq	a4,a5,8000514c <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000508a:	4789                	li	a5,2
    8000508c:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005090:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005094:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005098:	f4c42783          	lw	a5,-180(s0)
    8000509c:	0017f713          	andi	a4,a5,1
    800050a0:	00174713          	xori	a4,a4,1
    800050a4:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800050a8:	0037f713          	andi	a4,a5,3
    800050ac:	00e03733          	snez	a4,a4
    800050b0:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800050b4:	4007f793          	andi	a5,a5,1024
    800050b8:	c791                	beqz	a5,800050c4 <sys_open+0xb8>
    800050ba:	04449703          	lh	a4,68(s1)
    800050be:	4789                	li	a5,2
    800050c0:	08f70d63          	beq	a4,a5,8000515a <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800050c4:	8526                	mv	a0,s1
    800050c6:	a72fe0ef          	jal	80003338 <iunlock>
  end_op();
    800050ca:	c3dfe0ef          	jal	80003d06 <end_op>

  return fd;
    800050ce:	854e                	mv	a0,s3
    800050d0:	74aa                	ld	s1,168(sp)
    800050d2:	790a                	ld	s2,160(sp)
    800050d4:	69ea                	ld	s3,152(sp)
}
    800050d6:	70ea                	ld	ra,184(sp)
    800050d8:	744a                	ld	s0,176(sp)
    800050da:	6129                	addi	sp,sp,192
    800050dc:	8082                	ret
      end_op();
    800050de:	c29fe0ef          	jal	80003d06 <end_op>
      return -1;
    800050e2:	557d                	li	a0,-1
    800050e4:	74aa                	ld	s1,168(sp)
    800050e6:	bfc5                	j	800050d6 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    800050e8:	f5040513          	addi	a0,s0,-176
    800050ec:	9cdfe0ef          	jal	80003ab8 <namei>
    800050f0:	84aa                	mv	s1,a0
    800050f2:	c11d                	beqz	a0,80005118 <sys_open+0x10c>
    ilock(ip);
    800050f4:	996fe0ef          	jal	8000328a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800050f8:	04449703          	lh	a4,68(s1)
    800050fc:	4785                	li	a5,1
    800050fe:	f4f71ce3          	bne	a4,a5,80005056 <sys_open+0x4a>
    80005102:	f4c42783          	lw	a5,-180(s0)
    80005106:	d3b5                	beqz	a5,8000506a <sys_open+0x5e>
      iunlockput(ip);
    80005108:	8526                	mv	a0,s1
    8000510a:	b8cfe0ef          	jal	80003496 <iunlockput>
      end_op();
    8000510e:	bf9fe0ef          	jal	80003d06 <end_op>
      return -1;
    80005112:	557d                	li	a0,-1
    80005114:	74aa                	ld	s1,168(sp)
    80005116:	b7c1                	j	800050d6 <sys_open+0xca>
      end_op();
    80005118:	beffe0ef          	jal	80003d06 <end_op>
      return -1;
    8000511c:	557d                	li	a0,-1
    8000511e:	74aa                	ld	s1,168(sp)
    80005120:	bf5d                	j	800050d6 <sys_open+0xca>
    iunlockput(ip);
    80005122:	8526                	mv	a0,s1
    80005124:	b72fe0ef          	jal	80003496 <iunlockput>
    end_op();
    80005128:	bdffe0ef          	jal	80003d06 <end_op>
    return -1;
    8000512c:	557d                	li	a0,-1
    8000512e:	74aa                	ld	s1,168(sp)
    80005130:	b75d                	j	800050d6 <sys_open+0xca>
      fileclose(f);
    80005132:	854a                	mv	a0,s2
    80005134:	f87fe0ef          	jal	800040ba <fileclose>
    80005138:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000513a:	8526                	mv	a0,s1
    8000513c:	b5afe0ef          	jal	80003496 <iunlockput>
    end_op();
    80005140:	bc7fe0ef          	jal	80003d06 <end_op>
    return -1;
    80005144:	557d                	li	a0,-1
    80005146:	74aa                	ld	s1,168(sp)
    80005148:	790a                	ld	s2,160(sp)
    8000514a:	b771                	j	800050d6 <sys_open+0xca>
    f->type = FD_DEVICE;
    8000514c:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005150:	04649783          	lh	a5,70(s1)
    80005154:	02f91223          	sh	a5,36(s2)
    80005158:	bf35                	j	80005094 <sys_open+0x88>
    itrunc(ip);
    8000515a:	8526                	mv	a0,s1
    8000515c:	a1cfe0ef          	jal	80003378 <itrunc>
    80005160:	b795                	j	800050c4 <sys_open+0xb8>

0000000080005162 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005162:	7175                	addi	sp,sp,-144
    80005164:	e506                	sd	ra,136(sp)
    80005166:	e122                	sd	s0,128(sp)
    80005168:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000516a:	b2dfe0ef          	jal	80003c96 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000516e:	08000613          	li	a2,128
    80005172:	f7040593          	addi	a1,s0,-144
    80005176:	4501                	li	a0,0
    80005178:	f0afd0ef          	jal	80002882 <argstr>
    8000517c:	02054363          	bltz	a0,800051a2 <sys_mkdir+0x40>
    80005180:	4681                	li	a3,0
    80005182:	4601                	li	a2,0
    80005184:	4585                	li	a1,1
    80005186:	f7040513          	addi	a0,s0,-144
    8000518a:	973ff0ef          	jal	80004afc <create>
    8000518e:	c911                	beqz	a0,800051a2 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005190:	b06fe0ef          	jal	80003496 <iunlockput>
  end_op();
    80005194:	b73fe0ef          	jal	80003d06 <end_op>
  return 0;
    80005198:	4501                	li	a0,0
}
    8000519a:	60aa                	ld	ra,136(sp)
    8000519c:	640a                	ld	s0,128(sp)
    8000519e:	6149                	addi	sp,sp,144
    800051a0:	8082                	ret
    end_op();
    800051a2:	b65fe0ef          	jal	80003d06 <end_op>
    return -1;
    800051a6:	557d                	li	a0,-1
    800051a8:	bfcd                	j	8000519a <sys_mkdir+0x38>

00000000800051aa <sys_mknod>:

uint64
sys_mknod(void)
{
    800051aa:	7135                	addi	sp,sp,-160
    800051ac:	ed06                	sd	ra,152(sp)
    800051ae:	e922                	sd	s0,144(sp)
    800051b0:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800051b2:	ae5fe0ef          	jal	80003c96 <begin_op>
  argint(1, &major);
    800051b6:	f6c40593          	addi	a1,s0,-148
    800051ba:	4505                	li	a0,1
    800051bc:	e8efd0ef          	jal	8000284a <argint>
  argint(2, &minor);
    800051c0:	f6840593          	addi	a1,s0,-152
    800051c4:	4509                	li	a0,2
    800051c6:	e84fd0ef          	jal	8000284a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800051ca:	08000613          	li	a2,128
    800051ce:	f7040593          	addi	a1,s0,-144
    800051d2:	4501                	li	a0,0
    800051d4:	eaefd0ef          	jal	80002882 <argstr>
    800051d8:	02054563          	bltz	a0,80005202 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800051dc:	f6841683          	lh	a3,-152(s0)
    800051e0:	f6c41603          	lh	a2,-148(s0)
    800051e4:	458d                	li	a1,3
    800051e6:	f7040513          	addi	a0,s0,-144
    800051ea:	913ff0ef          	jal	80004afc <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800051ee:	c911                	beqz	a0,80005202 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800051f0:	aa6fe0ef          	jal	80003496 <iunlockput>
  end_op();
    800051f4:	b13fe0ef          	jal	80003d06 <end_op>
  return 0;
    800051f8:	4501                	li	a0,0
}
    800051fa:	60ea                	ld	ra,152(sp)
    800051fc:	644a                	ld	s0,144(sp)
    800051fe:	610d                	addi	sp,sp,160
    80005200:	8082                	ret
    end_op();
    80005202:	b05fe0ef          	jal	80003d06 <end_op>
    return -1;
    80005206:	557d                	li	a0,-1
    80005208:	bfcd                	j	800051fa <sys_mknod+0x50>

000000008000520a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000520a:	7135                	addi	sp,sp,-160
    8000520c:	ed06                	sd	ra,152(sp)
    8000520e:	e922                	sd	s0,144(sp)
    80005210:	e14a                	sd	s2,128(sp)
    80005212:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005214:	f1afc0ef          	jal	8000192e <myproc>
    80005218:	892a                	mv	s2,a0
  
  begin_op();
    8000521a:	a7dfe0ef          	jal	80003c96 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000521e:	08000613          	li	a2,128
    80005222:	f6040593          	addi	a1,s0,-160
    80005226:	4501                	li	a0,0
    80005228:	e5afd0ef          	jal	80002882 <argstr>
    8000522c:	04054363          	bltz	a0,80005272 <sys_chdir+0x68>
    80005230:	e526                	sd	s1,136(sp)
    80005232:	f6040513          	addi	a0,s0,-160
    80005236:	883fe0ef          	jal	80003ab8 <namei>
    8000523a:	84aa                	mv	s1,a0
    8000523c:	c915                	beqz	a0,80005270 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000523e:	84cfe0ef          	jal	8000328a <ilock>
  if(ip->type != T_DIR){
    80005242:	04449703          	lh	a4,68(s1)
    80005246:	4785                	li	a5,1
    80005248:	02f71963          	bne	a4,a5,8000527a <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000524c:	8526                	mv	a0,s1
    8000524e:	8eafe0ef          	jal	80003338 <iunlock>
  iput(p->cwd);
    80005252:	15093503          	ld	a0,336(s2)
    80005256:	9b6fe0ef          	jal	8000340c <iput>
  end_op();
    8000525a:	aadfe0ef          	jal	80003d06 <end_op>
  p->cwd = ip;
    8000525e:	14993823          	sd	s1,336(s2)
  return 0;
    80005262:	4501                	li	a0,0
    80005264:	64aa                	ld	s1,136(sp)
}
    80005266:	60ea                	ld	ra,152(sp)
    80005268:	644a                	ld	s0,144(sp)
    8000526a:	690a                	ld	s2,128(sp)
    8000526c:	610d                	addi	sp,sp,160
    8000526e:	8082                	ret
    80005270:	64aa                	ld	s1,136(sp)
    end_op();
    80005272:	a95fe0ef          	jal	80003d06 <end_op>
    return -1;
    80005276:	557d                	li	a0,-1
    80005278:	b7fd                	j	80005266 <sys_chdir+0x5c>
    iunlockput(ip);
    8000527a:	8526                	mv	a0,s1
    8000527c:	a1afe0ef          	jal	80003496 <iunlockput>
    end_op();
    80005280:	a87fe0ef          	jal	80003d06 <end_op>
    return -1;
    80005284:	557d                	li	a0,-1
    80005286:	64aa                	ld	s1,136(sp)
    80005288:	bff9                	j	80005266 <sys_chdir+0x5c>

000000008000528a <sys_exec>:

uint64
sys_exec(void)
{
    8000528a:	7105                	addi	sp,sp,-480
    8000528c:	ef86                	sd	ra,472(sp)
    8000528e:	eba2                	sd	s0,464(sp)
    80005290:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005292:	e2840593          	addi	a1,s0,-472
    80005296:	4505                	li	a0,1
    80005298:	dcefd0ef          	jal	80002866 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000529c:	08000613          	li	a2,128
    800052a0:	f3040593          	addi	a1,s0,-208
    800052a4:	4501                	li	a0,0
    800052a6:	ddcfd0ef          	jal	80002882 <argstr>
    800052aa:	87aa                	mv	a5,a0
    return -1;
    800052ac:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800052ae:	0e07c063          	bltz	a5,8000538e <sys_exec+0x104>
    800052b2:	e7a6                	sd	s1,456(sp)
    800052b4:	e3ca                	sd	s2,448(sp)
    800052b6:	ff4e                	sd	s3,440(sp)
    800052b8:	fb52                	sd	s4,432(sp)
    800052ba:	f756                	sd	s5,424(sp)
    800052bc:	f35a                	sd	s6,416(sp)
    800052be:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800052c0:	e3040a13          	addi	s4,s0,-464
    800052c4:	10000613          	li	a2,256
    800052c8:	4581                	li	a1,0
    800052ca:	8552                	mv	a0,s4
    800052cc:	a2dfb0ef          	jal	80000cf8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800052d0:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800052d2:	89d2                	mv	s3,s4
    800052d4:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800052d6:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800052da:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    800052dc:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800052e0:	00391513          	slli	a0,s2,0x3
    800052e4:	85d6                	mv	a1,s5
    800052e6:	e2843783          	ld	a5,-472(s0)
    800052ea:	953e                	add	a0,a0,a5
    800052ec:	cd4fd0ef          	jal	800027c0 <fetchaddr>
    800052f0:	02054663          	bltz	a0,8000531c <sys_exec+0x92>
    if(uarg == 0){
    800052f4:	e2043783          	ld	a5,-480(s0)
    800052f8:	c7a1                	beqz	a5,80005340 <sys_exec+0xb6>
    argv[i] = kalloc();
    800052fa:	84bfb0ef          	jal	80000b44 <kalloc>
    800052fe:	85aa                	mv	a1,a0
    80005300:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005304:	cd01                	beqz	a0,8000531c <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005306:	865a                	mv	a2,s6
    80005308:	e2043503          	ld	a0,-480(s0)
    8000530c:	cfefd0ef          	jal	8000280a <fetchstr>
    80005310:	00054663          	bltz	a0,8000531c <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005314:	0905                	addi	s2,s2,1
    80005316:	09a1                	addi	s3,s3,8
    80005318:	fd7914e3          	bne	s2,s7,800052e0 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000531c:	100a0a13          	addi	s4,s4,256
    80005320:	6088                	ld	a0,0(s1)
    80005322:	cd31                	beqz	a0,8000537e <sys_exec+0xf4>
    kfree(argv[i]);
    80005324:	f38fb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005328:	04a1                	addi	s1,s1,8
    8000532a:	ff449be3          	bne	s1,s4,80005320 <sys_exec+0x96>
  return -1;
    8000532e:	557d                	li	a0,-1
    80005330:	64be                	ld	s1,456(sp)
    80005332:	691e                	ld	s2,448(sp)
    80005334:	79fa                	ld	s3,440(sp)
    80005336:	7a5a                	ld	s4,432(sp)
    80005338:	7aba                	ld	s5,424(sp)
    8000533a:	7b1a                	ld	s6,416(sp)
    8000533c:	6bfa                	ld	s7,408(sp)
    8000533e:	a881                	j	8000538e <sys_exec+0x104>
      argv[i] = 0;
    80005340:	0009079b          	sext.w	a5,s2
    80005344:	e3040593          	addi	a1,s0,-464
    80005348:	078e                	slli	a5,a5,0x3
    8000534a:	97ae                	add	a5,a5,a1
    8000534c:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005350:	f3040513          	addi	a0,s0,-208
    80005354:	bb2ff0ef          	jal	80004706 <kexec>
    80005358:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000535a:	100a0a13          	addi	s4,s4,256
    8000535e:	6088                	ld	a0,0(s1)
    80005360:	c511                	beqz	a0,8000536c <sys_exec+0xe2>
    kfree(argv[i]);
    80005362:	efafb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005366:	04a1                	addi	s1,s1,8
    80005368:	ff449be3          	bne	s1,s4,8000535e <sys_exec+0xd4>
  return ret;
    8000536c:	854a                	mv	a0,s2
    8000536e:	64be                	ld	s1,456(sp)
    80005370:	691e                	ld	s2,448(sp)
    80005372:	79fa                	ld	s3,440(sp)
    80005374:	7a5a                	ld	s4,432(sp)
    80005376:	7aba                	ld	s5,424(sp)
    80005378:	7b1a                	ld	s6,416(sp)
    8000537a:	6bfa                	ld	s7,408(sp)
    8000537c:	a809                	j	8000538e <sys_exec+0x104>
  return -1;
    8000537e:	557d                	li	a0,-1
    80005380:	64be                	ld	s1,456(sp)
    80005382:	691e                	ld	s2,448(sp)
    80005384:	79fa                	ld	s3,440(sp)
    80005386:	7a5a                	ld	s4,432(sp)
    80005388:	7aba                	ld	s5,424(sp)
    8000538a:	7b1a                	ld	s6,416(sp)
    8000538c:	6bfa                	ld	s7,408(sp)
}
    8000538e:	60fe                	ld	ra,472(sp)
    80005390:	645e                	ld	s0,464(sp)
    80005392:	613d                	addi	sp,sp,480
    80005394:	8082                	ret

0000000080005396 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005396:	7139                	addi	sp,sp,-64
    80005398:	fc06                	sd	ra,56(sp)
    8000539a:	f822                	sd	s0,48(sp)
    8000539c:	f426                	sd	s1,40(sp)
    8000539e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800053a0:	d8efc0ef          	jal	8000192e <myproc>
    800053a4:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800053a6:	fd840593          	addi	a1,s0,-40
    800053aa:	4501                	li	a0,0
    800053ac:	cbafd0ef          	jal	80002866 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800053b0:	fc840593          	addi	a1,s0,-56
    800053b4:	fd040513          	addi	a0,s0,-48
    800053b8:	81eff0ef          	jal	800043d6 <pipealloc>
    return -1;
    800053bc:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800053be:	0a054763          	bltz	a0,8000546c <sys_pipe+0xd6>
  fd0 = -1;
    800053c2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800053c6:	fd043503          	ld	a0,-48(s0)
    800053ca:	ef2ff0ef          	jal	80004abc <fdalloc>
    800053ce:	fca42223          	sw	a0,-60(s0)
    800053d2:	08054463          	bltz	a0,8000545a <sys_pipe+0xc4>
    800053d6:	fc843503          	ld	a0,-56(s0)
    800053da:	ee2ff0ef          	jal	80004abc <fdalloc>
    800053de:	fca42023          	sw	a0,-64(s0)
    800053e2:	06054263          	bltz	a0,80005446 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800053e6:	4691                	li	a3,4
    800053e8:	fc440613          	addi	a2,s0,-60
    800053ec:	fd843583          	ld	a1,-40(s0)
    800053f0:	68a8                	ld	a0,80(s1)
    800053f2:	a62fc0ef          	jal	80001654 <copyout>
    800053f6:	00054e63          	bltz	a0,80005412 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800053fa:	4691                	li	a3,4
    800053fc:	fc040613          	addi	a2,s0,-64
    80005400:	fd843583          	ld	a1,-40(s0)
    80005404:	95b6                	add	a1,a1,a3
    80005406:	68a8                	ld	a0,80(s1)
    80005408:	a4cfc0ef          	jal	80001654 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000540c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000540e:	04055f63          	bgez	a0,8000546c <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    80005412:	fc442783          	lw	a5,-60(s0)
    80005416:	078e                	slli	a5,a5,0x3
    80005418:	0d078793          	addi	a5,a5,208
    8000541c:	97a6                	add	a5,a5,s1
    8000541e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005422:	fc042783          	lw	a5,-64(s0)
    80005426:	078e                	slli	a5,a5,0x3
    80005428:	0d078793          	addi	a5,a5,208
    8000542c:	97a6                	add	a5,a5,s1
    8000542e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005432:	fd043503          	ld	a0,-48(s0)
    80005436:	c85fe0ef          	jal	800040ba <fileclose>
    fileclose(wf);
    8000543a:	fc843503          	ld	a0,-56(s0)
    8000543e:	c7dfe0ef          	jal	800040ba <fileclose>
    return -1;
    80005442:	57fd                	li	a5,-1
    80005444:	a025                	j	8000546c <sys_pipe+0xd6>
    if(fd0 >= 0)
    80005446:	fc442783          	lw	a5,-60(s0)
    8000544a:	0007c863          	bltz	a5,8000545a <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    8000544e:	078e                	slli	a5,a5,0x3
    80005450:	0d078793          	addi	a5,a5,208
    80005454:	97a6                	add	a5,a5,s1
    80005456:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000545a:	fd043503          	ld	a0,-48(s0)
    8000545e:	c5dfe0ef          	jal	800040ba <fileclose>
    fileclose(wf);
    80005462:	fc843503          	ld	a0,-56(s0)
    80005466:	c55fe0ef          	jal	800040ba <fileclose>
    return -1;
    8000546a:	57fd                	li	a5,-1
}
    8000546c:	853e                	mv	a0,a5
    8000546e:	70e2                	ld	ra,56(sp)
    80005470:	7442                	ld	s0,48(sp)
    80005472:	74a2                	ld	s1,40(sp)
    80005474:	6121                	addi	sp,sp,64
    80005476:	8082                	ret
	...

0000000080005480 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005480:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005482:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005484:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005486:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005488:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000548a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000548c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000548e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005490:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005492:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005494:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005496:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005498:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000549a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000549c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000549e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800054a0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800054a2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800054a4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800054a6:	a28fd0ef          	jal	800026ce <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800054aa:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800054ac:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800054ae:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800054b0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800054b2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800054b4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800054b6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800054b8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800054ba:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800054bc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800054be:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800054c0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800054c2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800054c4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800054c6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800054c8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800054ca:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800054cc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800054ce:	10200073          	sret
    800054d2:	00000013          	nop
    800054d6:	00000013          	nop
    800054da:	00000013          	nop

00000000800054de <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800054de:	1141                	addi	sp,sp,-16
    800054e0:	e406                	sd	ra,8(sp)
    800054e2:	e022                	sd	s0,0(sp)
    800054e4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800054e6:	0c000737          	lui	a4,0xc000
    800054ea:	4785                	li	a5,1
    800054ec:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800054ee:	c35c                	sw	a5,4(a4)
}
    800054f0:	60a2                	ld	ra,8(sp)
    800054f2:	6402                	ld	s0,0(sp)
    800054f4:	0141                	addi	sp,sp,16
    800054f6:	8082                	ret

00000000800054f8 <plicinithart>:

void
plicinithart(void)
{
    800054f8:	1141                	addi	sp,sp,-16
    800054fa:	e406                	sd	ra,8(sp)
    800054fc:	e022                	sd	s0,0(sp)
    800054fe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005500:	bfafc0ef          	jal	800018fa <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005504:	0085171b          	slliw	a4,a0,0x8
    80005508:	0c0027b7          	lui	a5,0xc002
    8000550c:	97ba                	add	a5,a5,a4
    8000550e:	40200713          	li	a4,1026
    80005512:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005516:	00d5151b          	slliw	a0,a0,0xd
    8000551a:	0c2017b7          	lui	a5,0xc201
    8000551e:	97aa                	add	a5,a5,a0
    80005520:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005524:	60a2                	ld	ra,8(sp)
    80005526:	6402                	ld	s0,0(sp)
    80005528:	0141                	addi	sp,sp,16
    8000552a:	8082                	ret

000000008000552c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000552c:	1141                	addi	sp,sp,-16
    8000552e:	e406                	sd	ra,8(sp)
    80005530:	e022                	sd	s0,0(sp)
    80005532:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005534:	bc6fc0ef          	jal	800018fa <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005538:	00d5151b          	slliw	a0,a0,0xd
    8000553c:	0c2017b7          	lui	a5,0xc201
    80005540:	97aa                	add	a5,a5,a0
  return irq;
}
    80005542:	43c8                	lw	a0,4(a5)
    80005544:	60a2                	ld	ra,8(sp)
    80005546:	6402                	ld	s0,0(sp)
    80005548:	0141                	addi	sp,sp,16
    8000554a:	8082                	ret

000000008000554c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000554c:	1101                	addi	sp,sp,-32
    8000554e:	ec06                	sd	ra,24(sp)
    80005550:	e822                	sd	s0,16(sp)
    80005552:	e426                	sd	s1,8(sp)
    80005554:	1000                	addi	s0,sp,32
    80005556:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005558:	ba2fc0ef          	jal	800018fa <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000555c:	00d5179b          	slliw	a5,a0,0xd
    80005560:	0c201737          	lui	a4,0xc201
    80005564:	97ba                	add	a5,a5,a4
    80005566:	c3c4                	sw	s1,4(a5)
}
    80005568:	60e2                	ld	ra,24(sp)
    8000556a:	6442                	ld	s0,16(sp)
    8000556c:	64a2                	ld	s1,8(sp)
    8000556e:	6105                	addi	sp,sp,32
    80005570:	8082                	ret

0000000080005572 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005572:	1141                	addi	sp,sp,-16
    80005574:	e406                	sd	ra,8(sp)
    80005576:	e022                	sd	s0,0(sp)
    80005578:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000557a:	479d                	li	a5,7
    8000557c:	04a7ca63          	blt	a5,a0,800055d0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005580:	0001b797          	auipc	a5,0x1b
    80005584:	6b878793          	addi	a5,a5,1720 # 80020c38 <disk>
    80005588:	97aa                	add	a5,a5,a0
    8000558a:	0187c783          	lbu	a5,24(a5)
    8000558e:	e7b9                	bnez	a5,800055dc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005590:	00451693          	slli	a3,a0,0x4
    80005594:	0001b797          	auipc	a5,0x1b
    80005598:	6a478793          	addi	a5,a5,1700 # 80020c38 <disk>
    8000559c:	6398                	ld	a4,0(a5)
    8000559e:	9736                	add	a4,a4,a3
    800055a0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    800055a4:	6398                	ld	a4,0(a5)
    800055a6:	9736                	add	a4,a4,a3
    800055a8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800055ac:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800055b0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800055b4:	97aa                	add	a5,a5,a0
    800055b6:	4705                	li	a4,1
    800055b8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800055bc:	0001b517          	auipc	a0,0x1b
    800055c0:	69450513          	addi	a0,a0,1684 # 80020c50 <disk+0x18>
    800055c4:	9c7fc0ef          	jal	80001f8a <wakeup>
}
    800055c8:	60a2                	ld	ra,8(sp)
    800055ca:	6402                	ld	s0,0(sp)
    800055cc:	0141                	addi	sp,sp,16
    800055ce:	8082                	ret
    panic("free_desc 1");
    800055d0:	00002517          	auipc	a0,0x2
    800055d4:	04050513          	addi	a0,a0,64 # 80007610 <etext+0x610>
    800055d8:	a4cfb0ef          	jal	80000824 <panic>
    panic("free_desc 2");
    800055dc:	00002517          	auipc	a0,0x2
    800055e0:	04450513          	addi	a0,a0,68 # 80007620 <etext+0x620>
    800055e4:	a40fb0ef          	jal	80000824 <panic>

00000000800055e8 <virtio_disk_init>:
{
    800055e8:	1101                	addi	sp,sp,-32
    800055ea:	ec06                	sd	ra,24(sp)
    800055ec:	e822                	sd	s0,16(sp)
    800055ee:	e426                	sd	s1,8(sp)
    800055f0:	e04a                	sd	s2,0(sp)
    800055f2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800055f4:	00002597          	auipc	a1,0x2
    800055f8:	03c58593          	addi	a1,a1,60 # 80007630 <etext+0x630>
    800055fc:	0001b517          	auipc	a0,0x1b
    80005600:	76450513          	addi	a0,a0,1892 # 80020d60 <disk+0x128>
    80005604:	d9afb0ef          	jal	80000b9e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005608:	100017b7          	lui	a5,0x10001
    8000560c:	4398                	lw	a4,0(a5)
    8000560e:	2701                	sext.w	a4,a4
    80005610:	747277b7          	lui	a5,0x74727
    80005614:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005618:	14f71863          	bne	a4,a5,80005768 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000561c:	100017b7          	lui	a5,0x10001
    80005620:	43dc                	lw	a5,4(a5)
    80005622:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005624:	4709                	li	a4,2
    80005626:	14e79163          	bne	a5,a4,80005768 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000562a:	100017b7          	lui	a5,0x10001
    8000562e:	479c                	lw	a5,8(a5)
    80005630:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005632:	12e79b63          	bne	a5,a4,80005768 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005636:	100017b7          	lui	a5,0x10001
    8000563a:	47d8                	lw	a4,12(a5)
    8000563c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000563e:	554d47b7          	lui	a5,0x554d4
    80005642:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005646:	12f71163          	bne	a4,a5,80005768 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000564a:	100017b7          	lui	a5,0x10001
    8000564e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005652:	4705                	li	a4,1
    80005654:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005656:	470d                	li	a4,3
    80005658:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000565a:	10001737          	lui	a4,0x10001
    8000565e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005660:	c7ffe6b7          	lui	a3,0xc7ffe
    80005664:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd9e7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005668:	8f75                	and	a4,a4,a3
    8000566a:	100016b7          	lui	a3,0x10001
    8000566e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005670:	472d                	li	a4,11
    80005672:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005674:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005678:	439c                	lw	a5,0(a5)
    8000567a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000567e:	8ba1                	andi	a5,a5,8
    80005680:	0e078a63          	beqz	a5,80005774 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005684:	100017b7          	lui	a5,0x10001
    80005688:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000568c:	43fc                	lw	a5,68(a5)
    8000568e:	2781                	sext.w	a5,a5
    80005690:	0e079863          	bnez	a5,80005780 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005694:	100017b7          	lui	a5,0x10001
    80005698:	5bdc                	lw	a5,52(a5)
    8000569a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000569c:	0e078863          	beqz	a5,8000578c <virtio_disk_init+0x1a4>
  if(max < NUM)
    800056a0:	471d                	li	a4,7
    800056a2:	0ef77b63          	bgeu	a4,a5,80005798 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800056a6:	c9efb0ef          	jal	80000b44 <kalloc>
    800056aa:	0001b497          	auipc	s1,0x1b
    800056ae:	58e48493          	addi	s1,s1,1422 # 80020c38 <disk>
    800056b2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800056b4:	c90fb0ef          	jal	80000b44 <kalloc>
    800056b8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800056ba:	c8afb0ef          	jal	80000b44 <kalloc>
    800056be:	87aa                	mv	a5,a0
    800056c0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800056c2:	6088                	ld	a0,0(s1)
    800056c4:	0e050063          	beqz	a0,800057a4 <virtio_disk_init+0x1bc>
    800056c8:	0001b717          	auipc	a4,0x1b
    800056cc:	57873703          	ld	a4,1400(a4) # 80020c40 <disk+0x8>
    800056d0:	cb71                	beqz	a4,800057a4 <virtio_disk_init+0x1bc>
    800056d2:	cbe9                	beqz	a5,800057a4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    800056d4:	6605                	lui	a2,0x1
    800056d6:	4581                	li	a1,0
    800056d8:	e20fb0ef          	jal	80000cf8 <memset>
  memset(disk.avail, 0, PGSIZE);
    800056dc:	0001b497          	auipc	s1,0x1b
    800056e0:	55c48493          	addi	s1,s1,1372 # 80020c38 <disk>
    800056e4:	6605                	lui	a2,0x1
    800056e6:	4581                	li	a1,0
    800056e8:	6488                	ld	a0,8(s1)
    800056ea:	e0efb0ef          	jal	80000cf8 <memset>
  memset(disk.used, 0, PGSIZE);
    800056ee:	6605                	lui	a2,0x1
    800056f0:	4581                	li	a1,0
    800056f2:	6888                	ld	a0,16(s1)
    800056f4:	e04fb0ef          	jal	80000cf8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800056f8:	100017b7          	lui	a5,0x10001
    800056fc:	4721                	li	a4,8
    800056fe:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005700:	4098                	lw	a4,0(s1)
    80005702:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005706:	40d8                	lw	a4,4(s1)
    80005708:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000570c:	649c                	ld	a5,8(s1)
    8000570e:	0007869b          	sext.w	a3,a5
    80005712:	10001737          	lui	a4,0x10001
    80005716:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000571a:	9781                	srai	a5,a5,0x20
    8000571c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005720:	689c                	ld	a5,16(s1)
    80005722:	0007869b          	sext.w	a3,a5
    80005726:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000572a:	9781                	srai	a5,a5,0x20
    8000572c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005730:	4785                	li	a5,1
    80005732:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005734:	00f48c23          	sb	a5,24(s1)
    80005738:	00f48ca3          	sb	a5,25(s1)
    8000573c:	00f48d23          	sb	a5,26(s1)
    80005740:	00f48da3          	sb	a5,27(s1)
    80005744:	00f48e23          	sb	a5,28(s1)
    80005748:	00f48ea3          	sb	a5,29(s1)
    8000574c:	00f48f23          	sb	a5,30(s1)
    80005750:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005754:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005758:	07272823          	sw	s2,112(a4)
}
    8000575c:	60e2                	ld	ra,24(sp)
    8000575e:	6442                	ld	s0,16(sp)
    80005760:	64a2                	ld	s1,8(sp)
    80005762:	6902                	ld	s2,0(sp)
    80005764:	6105                	addi	sp,sp,32
    80005766:	8082                	ret
    panic("could not find virtio disk");
    80005768:	00002517          	auipc	a0,0x2
    8000576c:	ed850513          	addi	a0,a0,-296 # 80007640 <etext+0x640>
    80005770:	8b4fb0ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005774:	00002517          	auipc	a0,0x2
    80005778:	eec50513          	addi	a0,a0,-276 # 80007660 <etext+0x660>
    8000577c:	8a8fb0ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    80005780:	00002517          	auipc	a0,0x2
    80005784:	f0050513          	addi	a0,a0,-256 # 80007680 <etext+0x680>
    80005788:	89cfb0ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    8000578c:	00002517          	auipc	a0,0x2
    80005790:	f1450513          	addi	a0,a0,-236 # 800076a0 <etext+0x6a0>
    80005794:	890fb0ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    80005798:	00002517          	auipc	a0,0x2
    8000579c:	f2850513          	addi	a0,a0,-216 # 800076c0 <etext+0x6c0>
    800057a0:	884fb0ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    800057a4:	00002517          	auipc	a0,0x2
    800057a8:	f3c50513          	addi	a0,a0,-196 # 800076e0 <etext+0x6e0>
    800057ac:	878fb0ef          	jal	80000824 <panic>

00000000800057b0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800057b0:	711d                	addi	sp,sp,-96
    800057b2:	ec86                	sd	ra,88(sp)
    800057b4:	e8a2                	sd	s0,80(sp)
    800057b6:	e4a6                	sd	s1,72(sp)
    800057b8:	e0ca                	sd	s2,64(sp)
    800057ba:	fc4e                	sd	s3,56(sp)
    800057bc:	f852                	sd	s4,48(sp)
    800057be:	f456                	sd	s5,40(sp)
    800057c0:	f05a                	sd	s6,32(sp)
    800057c2:	ec5e                	sd	s7,24(sp)
    800057c4:	e862                	sd	s8,16(sp)
    800057c6:	1080                	addi	s0,sp,96
    800057c8:	89aa                	mv	s3,a0
    800057ca:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800057cc:	00c52b83          	lw	s7,12(a0)
    800057d0:	001b9b9b          	slliw	s7,s7,0x1
    800057d4:	1b82                	slli	s7,s7,0x20
    800057d6:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800057da:	0001b517          	auipc	a0,0x1b
    800057de:	58650513          	addi	a0,a0,1414 # 80020d60 <disk+0x128>
    800057e2:	c46fb0ef          	jal	80000c28 <acquire>
  for(int i = 0; i < NUM; i++){
    800057e6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800057e8:	0001ba97          	auipc	s5,0x1b
    800057ec:	450a8a93          	addi	s5,s5,1104 # 80020c38 <disk>
  for(int i = 0; i < 3; i++){
    800057f0:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    800057f2:	5c7d                	li	s8,-1
    800057f4:	a095                	j	80005858 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    800057f6:	00fa8733          	add	a4,s5,a5
    800057fa:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800057fe:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005800:	0207c563          	bltz	a5,8000582a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005804:	2905                	addiw	s2,s2,1
    80005806:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005808:	05490c63          	beq	s2,s4,80005860 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    8000580c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000580e:	0001b717          	auipc	a4,0x1b
    80005812:	42a70713          	addi	a4,a4,1066 # 80020c38 <disk>
    80005816:	4781                	li	a5,0
    if(disk.free[i]){
    80005818:	01874683          	lbu	a3,24(a4)
    8000581c:	fee9                	bnez	a3,800057f6 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    8000581e:	2785                	addiw	a5,a5,1
    80005820:	0705                	addi	a4,a4,1
    80005822:	fe979be3          	bne	a5,s1,80005818 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005826:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    8000582a:	01205d63          	blez	s2,80005844 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000582e:	fa042503          	lw	a0,-96(s0)
    80005832:	d41ff0ef          	jal	80005572 <free_desc>
      for(int j = 0; j < i; j++)
    80005836:	4785                	li	a5,1
    80005838:	0127d663          	bge	a5,s2,80005844 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000583c:	fa442503          	lw	a0,-92(s0)
    80005840:	d33ff0ef          	jal	80005572 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005844:	0001b597          	auipc	a1,0x1b
    80005848:	51c58593          	addi	a1,a1,1308 # 80020d60 <disk+0x128>
    8000584c:	0001b517          	auipc	a0,0x1b
    80005850:	40450513          	addi	a0,a0,1028 # 80020c50 <disk+0x18>
    80005854:	eeafc0ef          	jal	80001f3e <sleep>
  for(int i = 0; i < 3; i++){
    80005858:	fa040613          	addi	a2,s0,-96
    8000585c:	4901                	li	s2,0
    8000585e:	b77d                	j	8000580c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005860:	fa042503          	lw	a0,-96(s0)
    80005864:	00451693          	slli	a3,a0,0x4

  if(write)
    80005868:	0001b797          	auipc	a5,0x1b
    8000586c:	3d078793          	addi	a5,a5,976 # 80020c38 <disk>
    80005870:	00451713          	slli	a4,a0,0x4
    80005874:	0a070713          	addi	a4,a4,160
    80005878:	973e                	add	a4,a4,a5
    8000587a:	01603633          	snez	a2,s6
    8000587e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005880:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005884:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005888:	6398                	ld	a4,0(a5)
    8000588a:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000588c:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005890:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005892:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005894:	6390                	ld	a2,0(a5)
    80005896:	00d60833          	add	a6,a2,a3
    8000589a:	4741                	li	a4,16
    8000589c:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800058a0:	4585                	li	a1,1
    800058a2:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    800058a6:	fa442703          	lw	a4,-92(s0)
    800058aa:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800058ae:	0712                	slli	a4,a4,0x4
    800058b0:	963a                	add	a2,a2,a4
    800058b2:	05898813          	addi	a6,s3,88
    800058b6:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800058ba:	0007b883          	ld	a7,0(a5)
    800058be:	9746                	add	a4,a4,a7
    800058c0:	40000613          	li	a2,1024
    800058c4:	c710                	sw	a2,8(a4)
  if(write)
    800058c6:	001b3613          	seqz	a2,s6
    800058ca:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800058ce:	8e4d                	or	a2,a2,a1
    800058d0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800058d4:	fa842603          	lw	a2,-88(s0)
    800058d8:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800058dc:	00451813          	slli	a6,a0,0x4
    800058e0:	02080813          	addi	a6,a6,32
    800058e4:	983e                	add	a6,a6,a5
    800058e6:	577d                	li	a4,-1
    800058e8:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800058ec:	0612                	slli	a2,a2,0x4
    800058ee:	98b2                	add	a7,a7,a2
    800058f0:	03068713          	addi	a4,a3,48
    800058f4:	973e                	add	a4,a4,a5
    800058f6:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800058fa:	6398                	ld	a4,0(a5)
    800058fc:	9732                	add	a4,a4,a2
    800058fe:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005900:	4689                	li	a3,2
    80005902:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005906:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000590a:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    8000590e:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005912:	6794                	ld	a3,8(a5)
    80005914:	0026d703          	lhu	a4,2(a3)
    80005918:	8b1d                	andi	a4,a4,7
    8000591a:	0706                	slli	a4,a4,0x1
    8000591c:	96ba                	add	a3,a3,a4
    8000591e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005922:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005926:	6798                	ld	a4,8(a5)
    80005928:	00275783          	lhu	a5,2(a4)
    8000592c:	2785                	addiw	a5,a5,1
    8000592e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005932:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005936:	100017b7          	lui	a5,0x10001
    8000593a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000593e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005942:	0001b917          	auipc	s2,0x1b
    80005946:	41e90913          	addi	s2,s2,1054 # 80020d60 <disk+0x128>
  while(b->disk == 1) {
    8000594a:	84ae                	mv	s1,a1
    8000594c:	00b79a63          	bne	a5,a1,80005960 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005950:	85ca                	mv	a1,s2
    80005952:	854e                	mv	a0,s3
    80005954:	deafc0ef          	jal	80001f3e <sleep>
  while(b->disk == 1) {
    80005958:	0049a783          	lw	a5,4(s3)
    8000595c:	fe978ae3          	beq	a5,s1,80005950 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005960:	fa042903          	lw	s2,-96(s0)
    80005964:	00491713          	slli	a4,s2,0x4
    80005968:	02070713          	addi	a4,a4,32
    8000596c:	0001b797          	auipc	a5,0x1b
    80005970:	2cc78793          	addi	a5,a5,716 # 80020c38 <disk>
    80005974:	97ba                	add	a5,a5,a4
    80005976:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000597a:	0001b997          	auipc	s3,0x1b
    8000597e:	2be98993          	addi	s3,s3,702 # 80020c38 <disk>
    80005982:	00491713          	slli	a4,s2,0x4
    80005986:	0009b783          	ld	a5,0(s3)
    8000598a:	97ba                	add	a5,a5,a4
    8000598c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005990:	854a                	mv	a0,s2
    80005992:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005996:	bddff0ef          	jal	80005572 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000599a:	8885                	andi	s1,s1,1
    8000599c:	f0fd                	bnez	s1,80005982 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000599e:	0001b517          	auipc	a0,0x1b
    800059a2:	3c250513          	addi	a0,a0,962 # 80020d60 <disk+0x128>
    800059a6:	b16fb0ef          	jal	80000cbc <release>
}
    800059aa:	60e6                	ld	ra,88(sp)
    800059ac:	6446                	ld	s0,80(sp)
    800059ae:	64a6                	ld	s1,72(sp)
    800059b0:	6906                	ld	s2,64(sp)
    800059b2:	79e2                	ld	s3,56(sp)
    800059b4:	7a42                	ld	s4,48(sp)
    800059b6:	7aa2                	ld	s5,40(sp)
    800059b8:	7b02                	ld	s6,32(sp)
    800059ba:	6be2                	ld	s7,24(sp)
    800059bc:	6c42                	ld	s8,16(sp)
    800059be:	6125                	addi	sp,sp,96
    800059c0:	8082                	ret

00000000800059c2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800059c2:	1101                	addi	sp,sp,-32
    800059c4:	ec06                	sd	ra,24(sp)
    800059c6:	e822                	sd	s0,16(sp)
    800059c8:	e426                	sd	s1,8(sp)
    800059ca:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800059cc:	0001b497          	auipc	s1,0x1b
    800059d0:	26c48493          	addi	s1,s1,620 # 80020c38 <disk>
    800059d4:	0001b517          	auipc	a0,0x1b
    800059d8:	38c50513          	addi	a0,a0,908 # 80020d60 <disk+0x128>
    800059dc:	a4cfb0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800059e0:	100017b7          	lui	a5,0x10001
    800059e4:	53bc                	lw	a5,96(a5)
    800059e6:	8b8d                	andi	a5,a5,3
    800059e8:	10001737          	lui	a4,0x10001
    800059ec:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800059ee:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800059f2:	689c                	ld	a5,16(s1)
    800059f4:	0204d703          	lhu	a4,32(s1)
    800059f8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800059fc:	04f70863          	beq	a4,a5,80005a4c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005a00:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005a04:	6898                	ld	a4,16(s1)
    80005a06:	0204d783          	lhu	a5,32(s1)
    80005a0a:	8b9d                	andi	a5,a5,7
    80005a0c:	078e                	slli	a5,a5,0x3
    80005a0e:	97ba                	add	a5,a5,a4
    80005a10:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005a12:	00479713          	slli	a4,a5,0x4
    80005a16:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005a1a:	9726                	add	a4,a4,s1
    80005a1c:	01074703          	lbu	a4,16(a4)
    80005a20:	e329                	bnez	a4,80005a62 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005a22:	0792                	slli	a5,a5,0x4
    80005a24:	02078793          	addi	a5,a5,32
    80005a28:	97a6                	add	a5,a5,s1
    80005a2a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005a2c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005a30:	d5afc0ef          	jal	80001f8a <wakeup>

    disk.used_idx += 1;
    80005a34:	0204d783          	lhu	a5,32(s1)
    80005a38:	2785                	addiw	a5,a5,1
    80005a3a:	17c2                	slli	a5,a5,0x30
    80005a3c:	93c1                	srli	a5,a5,0x30
    80005a3e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005a42:	6898                	ld	a4,16(s1)
    80005a44:	00275703          	lhu	a4,2(a4)
    80005a48:	faf71ce3          	bne	a4,a5,80005a00 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005a4c:	0001b517          	auipc	a0,0x1b
    80005a50:	31450513          	addi	a0,a0,788 # 80020d60 <disk+0x128>
    80005a54:	a68fb0ef          	jal	80000cbc <release>
}
    80005a58:	60e2                	ld	ra,24(sp)
    80005a5a:	6442                	ld	s0,16(sp)
    80005a5c:	64a2                	ld	s1,8(sp)
    80005a5e:	6105                	addi	sp,sp,32
    80005a60:	8082                	ret
      panic("virtio_disk_intr status");
    80005a62:	00002517          	auipc	a0,0x2
    80005a66:	c9650513          	addi	a0,a0,-874 # 800076f8 <etext+0x6f8>
    80005a6a:	dbbfa0ef          	jal	80000824 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
