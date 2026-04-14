
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
    80000004:	88010113          	addi	sp,sp,-1920 # 80007880 <stack0>
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
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd877>
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
    8000011a:	1e4020ef          	jal	800022fe <either_copyin>
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
    80000196:	6ee50513          	addi	a0,a0,1774 # 8000f880 <cons>
    8000019a:	28f000ef          	jal	80000c28 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	0000f497          	auipc	s1,0xf
    800001a2:	6e248493          	addi	s1,s1,1762 # 8000f880 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	0000f917          	auipc	s2,0xf
    800001aa:	77290913          	addi	s2,s2,1906 # 8000f918 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	764010ef          	jal	80001922 <myproc>
    800001c2:	7d5010ef          	jal	80002196 <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	58f010ef          	jal	80001f5a <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	0000f717          	auipc	a4,0xf
    800001e2:	6a270713          	addi	a4,a4,1698 # 8000f880 <cons>
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
    80000210:	0a4020ef          	jal	800022b4 <either_copyout>
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
    8000022c:	65850513          	addi	a0,a0,1624 # 8000f880 <cons>
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
    80000252:	6cf72523          	sw	a5,1738(a4) # 8000f918 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	0000f517          	auipc	a0,0xf
    80000268:	61c50513          	addi	a0,a0,1564 # 8000f880 <cons>
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
    800002bc:	5c850513          	addi	a0,a0,1480 # 8000f880 <cons>
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
    800002da:	06e020ef          	jal	80002348 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	0000f517          	auipc	a0,0xf
    800002e2:	5a250513          	addi	a0,a0,1442 # 8000f880 <cons>
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
    80000300:	58470713          	addi	a4,a4,1412 # 8000f880 <cons>
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
    80000326:	55e70713          	addi	a4,a4,1374 # 8000f880 <cons>
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
    80000350:	5cc72703          	lw	a4,1484(a4) # 8000f918 <cons+0x98>
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	08000713          	li	a4,128
    8000035a:	f8e792e3          	bne	a5,a4,800002de <consoleintr+0x32>
    8000035e:	a075                	j	8000040a <consoleintr+0x15e>
    80000360:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000362:	0000f717          	auipc	a4,0xf
    80000366:	51e70713          	addi	a4,a4,1310 # 8000f880 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000372:	0000f497          	auipc	s1,0xf
    80000376:	50e48493          	addi	s1,s1,1294 # 8000f880 <cons>
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
    800003b8:	4cc70713          	addi	a4,a4,1228 # 8000f880 <cons>
    800003bc:	0a072783          	lw	a5,160(a4)
    800003c0:	09c72703          	lw	a4,156(a4)
    800003c4:	f0f70de3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003c8:	37fd                	addiw	a5,a5,-1
    800003ca:	0000f717          	auipc	a4,0xf
    800003ce:	54f72b23          	sw	a5,1366(a4) # 8000f920 <cons+0xa0>
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
    800003ec:	49878793          	addi	a5,a5,1176 # 8000f880 <cons>
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
    8000040e:	50c7a923          	sw	a2,1298(a5) # 8000f91c <cons+0x9c>
        wakeup(&cons.r);
    80000412:	0000f517          	auipc	a0,0xf
    80000416:	50650513          	addi	a0,a0,1286 # 8000f918 <cons+0x98>
    8000041a:	38d010ef          	jal	80001fa6 <wakeup>
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
    80000434:	45050513          	addi	a0,a0,1104 # 8000f880 <cons>
    80000438:	766000ef          	jal	80000b9e <initlock>

  uartinit();
    8000043c:	448000ef          	jal	80000884 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	00020797          	auipc	a5,0x20
    80000444:	9b078793          	addi	a5,a5,-1616 # 8001fdf0 <devsw>
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
    8000051c:	33c7a783          	lw	a5,828(a5) # 80007854 <panicking>
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
    80000562:	3ca50513          	addi	a0,a0,970 # 8000f928 <pr>
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
    8000075e:	0fa7a783          	lw	a5,250(a5) # 80007854 <panicking>
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
    80000788:	1a450513          	addi	a0,a0,420 # 8000f928 <pr>
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
    80000838:	0297a023          	sw	s1,32(a5) # 80007854 <panicking>
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
    8000085a:	fe97ad23          	sw	s1,-6(a5) # 80007850 <panicked>
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
    80000874:	0b850513          	addi	a0,a0,184 # 8000f928 <pr>
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
    800008ca:	07a50513          	addi	a0,a0,122 # 8000f940 <tx_lock>
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
    800008ee:	05650513          	addi	a0,a0,86 # 8000f940 <tx_lock>
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
    8000090c:	f5448493          	addi	s1,s1,-172 # 8000785c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000910:	0000f997          	auipc	s3,0xf
    80000914:	03098993          	addi	s3,s3,48 # 8000f940 <tx_lock>
    80000918:	00007917          	auipc	s2,0x7
    8000091c:	f4090913          	addi	s2,s2,-192 # 80007858 <tx_chan>
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
    8000092c:	62e010ef          	jal	80001f5a <sleep>
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
    8000095a:	fea50513          	addi	a0,a0,-22 # 8000f940 <tx_lock>
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
    8000097e:	eda7a783          	lw	a5,-294(a5) # 80007854 <panicking>
    80000982:	cf95                	beqz	a5,800009be <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000984:	00007797          	auipc	a5,0x7
    80000988:	ecc7a783          	lw	a5,-308(a5) # 80007850 <panicked>
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
    800009ae:	eaa7a783          	lw	a5,-342(a5) # 80007854 <panicking>
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
    80000a0a:	f3a50513          	addi	a0,a0,-198 # 8000f940 <tx_lock>
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
    80000a24:	f2050513          	addi	a0,a0,-224 # 8000f940 <tx_lock>
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
    80000a40:	e207a023          	sw	zero,-480(a5) # 8000785c <tx_busy>
    wakeup(&tx_chan);
    80000a44:	00007517          	auipc	a0,0x7
    80000a48:	e1450513          	addi	a0,a0,-492 # 80007858 <tx_chan>
    80000a4c:	55a010ef          	jal	80001fa6 <wakeup>
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
    80000a6c:	52078793          	addi	a5,a5,1312 # 80020f88 <end>
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
    80000a96:	ec690913          	addi	s2,s2,-314 # 8000f958 <kmem>
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
    80000b24:	e3850513          	addi	a0,a0,-456 # 8000f958 <kmem>
    80000b28:	076000ef          	jal	80000b9e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00020517          	auipc	a0,0x20
    80000b34:	45850513          	addi	a0,a0,1112 # 80020f88 <end>
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
    80000b52:	e0a50513          	addi	a0,a0,-502 # 8000f958 <kmem>
    80000b56:	0d2000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b5a:	0000f497          	auipc	s1,0xf
    80000b5e:	e164b483          	ld	s1,-490(s1) # 8000f970 <kmem+0x18>
  if(r)
    80000b62:	c49d                	beqz	s1,80000b90 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b64:	609c                	ld	a5,0(s1)
    80000b66:	0000f717          	auipc	a4,0xf
    80000b6a:	e0f73523          	sd	a5,-502(a4) # 8000f970 <kmem+0x18>
  release(&kmem.lock);
    80000b6e:	0000f517          	auipc	a0,0xf
    80000b72:	dea50513          	addi	a0,a0,-534 # 8000f958 <kmem>
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
    80000b94:	dc850513          	addi	a0,a0,-568 # 8000f958 <kmem>
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
    80000bce:	535000ef          	jal	80001902 <mycpu>
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
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bee:	100027f3          	csrr	a5,sstatus
    80000bf2:	84be                	mv	s1,a5
    80000bf4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bf8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bfa:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000bfe:	505000ef          	jal	80001902 <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	4fd000ef          	jal	80001902 <mycpu>
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
    80000c1a:	4e9000ef          	jal	80001902 <mycpu>
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
    80000c50:	4b3000ef          	jal	80001902 <mycpu>
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
    80000c74:	48f000ef          	jal	80001902 <mycpu>
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
    80000eb6:	239000ef          	jal	800018ee <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eba:	00007717          	auipc	a4,0x7
    80000ebe:	9a670713          	addi	a4,a4,-1626 # 80007860 <started>
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
    80000ece:	221000ef          	jal	800018ee <cpuid>
    80000ed2:	85aa                	mv	a1,a0
    80000ed4:	00006517          	auipc	a0,0x6
    80000ed8:	1c450513          	addi	a0,a0,452 # 80007098 <etext+0x98>
    80000edc:	e1eff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000ee0:	080000ef          	jal	80000f60 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee4:	596010ef          	jal	8000247a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee8:	790040ef          	jal	80005678 <plicinithart>
  }

  scheduler();        
    80000eec:	6d5000ef          	jal	80001dc0 <scheduler>
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
    80000f28:	117000ef          	jal	8000183e <procinit>
    trapinit();      // trap vectors
    80000f2c:	52a010ef          	jal	80002456 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f30:	54a010ef          	jal	8000247a <trapinithart>
    plicinit();      // set up interrupt controller
    80000f34:	72a040ef          	jal	8000565e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f38:	740040ef          	jal	80005678 <plicinithart>
    binit();         // buffer cache
    80000f3c:	5b3010ef          	jal	80002cee <binit>
    iinit();         // inode table
    80000f40:	304020ef          	jal	80003244 <iinit>
    fileinit();      // file table
    80000f44:	230030ef          	jal	80004174 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	021040ef          	jal	80005768 <virtio_disk_init>
    userinit();      // first user process
    80000f4c:	4c9000ef          	jal	80001c14 <userinit>
    __sync_synchronize();
    80000f50:	0330000f          	fence	rw,rw
    started = 1;
    80000f54:	4785                	li	a5,1
    80000f56:	00007717          	auipc	a4,0x7
    80000f5a:	90f72523          	sw	a5,-1782(a4) # 80007860 <started>
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
    80000f70:	8fc7b783          	ld	a5,-1796(a5) # 80007868 <kernel_pagetable>
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
    800011fc:	66a7b823          	sd	a0,1648(a5) # 80007868 <kernel_pagetable>
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
    800015e0:	342000ef          	jal	80001922 <myproc>
  if (va >= p->sz)
    800015e4:	693c                	ld	a5,80(a0)
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
    80001632:	6ca8                	ld	a0,88(s1)
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
    800017be:	5ee48493          	addi	s1,s1,1518 # 8000fda8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800017c2:	8c26                	mv	s8,s1
    800017c4:	677d47b7          	lui	a5,0x677d4
    800017c8:	6cf78793          	addi	a5,a5,1743 # 677d46cf <_entry-0x1882b931>
    800017cc:	51b3c937          	lui	s2,0x51b3c
    800017d0:	ea390913          	addi	s2,s2,-349 # 51b3bea3 <_entry-0x2e4c415d>
    800017d4:	1902                	slli	s2,s2,0x20
    800017d6:	993e                	add	s2,s2,a5
    800017d8:	040009b7          	lui	s3,0x4000
    800017dc:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017de:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017e0:	4b99                	li	s7,6
    800017e2:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    800017e4:	00014a97          	auipc	s5,0x14
    800017e8:	3c4a8a93          	addi	s5,s5,964 # 80015ba8 <tickslock>
    char *pa = kalloc();
    800017ec:	b58ff0ef          	jal	80000b44 <kalloc>
    800017f0:	862a                	mv	a2,a0
    if(pa == 0)
    800017f2:	c121                	beqz	a0,80001832 <proc_mapstacks+0x92>
    uint64 va = KSTACK((int) (p - proc));
    800017f4:	418485b3          	sub	a1,s1,s8
    800017f8:	858d                	srai	a1,a1,0x3
    800017fa:	032585b3          	mul	a1,a1,s2
    800017fe:	05b6                	slli	a1,a1,0xd
    80001800:	6789                	lui	a5,0x2
    80001802:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001804:	875e                	mv	a4,s7
    80001806:	86da                	mv	a3,s6
    80001808:	40b985b3          	sub	a1,s3,a1
    8000180c:	8552                	mv	a0,s4
    8000180e:	909ff0ef          	jal	80001116 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001812:	17848493          	addi	s1,s1,376
    80001816:	fd549be3          	bne	s1,s5,800017ec <proc_mapstacks+0x4c>
  }
}
    8000181a:	60a6                	ld	ra,72(sp)
    8000181c:	6406                	ld	s0,64(sp)
    8000181e:	74e2                	ld	s1,56(sp)
    80001820:	7942                	ld	s2,48(sp)
    80001822:	79a2                	ld	s3,40(sp)
    80001824:	7a02                	ld	s4,32(sp)
    80001826:	6ae2                	ld	s5,24(sp)
    80001828:	6b42                	ld	s6,16(sp)
    8000182a:	6ba2                	ld	s7,8(sp)
    8000182c:	6c02                	ld	s8,0(sp)
    8000182e:	6161                	addi	sp,sp,80
    80001830:	8082                	ret
      panic("kalloc");
    80001832:	00006517          	auipc	a0,0x6
    80001836:	92650513          	addi	a0,a0,-1754 # 80007158 <etext+0x158>
    8000183a:	febfe0ef          	jal	80000824 <panic>

000000008000183e <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000183e:	7139                	addi	sp,sp,-64
    80001840:	fc06                	sd	ra,56(sp)
    80001842:	f822                	sd	s0,48(sp)
    80001844:	f426                	sd	s1,40(sp)
    80001846:	f04a                	sd	s2,32(sp)
    80001848:	ec4e                	sd	s3,24(sp)
    8000184a:	e852                	sd	s4,16(sp)
    8000184c:	e456                	sd	s5,8(sp)
    8000184e:	e05a                	sd	s6,0(sp)
    80001850:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001852:	00006597          	auipc	a1,0x6
    80001856:	90e58593          	addi	a1,a1,-1778 # 80007160 <etext+0x160>
    8000185a:	0000e517          	auipc	a0,0xe
    8000185e:	11e50513          	addi	a0,a0,286 # 8000f978 <pid_lock>
    80001862:	b3cff0ef          	jal	80000b9e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001866:	00006597          	auipc	a1,0x6
    8000186a:	90258593          	addi	a1,a1,-1790 # 80007168 <etext+0x168>
    8000186e:	0000e517          	auipc	a0,0xe
    80001872:	12250513          	addi	a0,a0,290 # 8000f990 <wait_lock>
    80001876:	b28ff0ef          	jal	80000b9e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000187a:	0000e497          	auipc	s1,0xe
    8000187e:	52e48493          	addi	s1,s1,1326 # 8000fda8 <proc>
      initlock(&p->lock, "proc");
    80001882:	00006b17          	auipc	s6,0x6
    80001886:	8f6b0b13          	addi	s6,s6,-1802 # 80007178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000188a:	8aa6                	mv	s5,s1
    8000188c:	677d47b7          	lui	a5,0x677d4
    80001890:	6cf78793          	addi	a5,a5,1743 # 677d46cf <_entry-0x1882b931>
    80001894:	51b3c937          	lui	s2,0x51b3c
    80001898:	ea390913          	addi	s2,s2,-349 # 51b3bea3 <_entry-0x2e4c415d>
    8000189c:	1902                	slli	s2,s2,0x20
    8000189e:	993e                	add	s2,s2,a5
    800018a0:	040009b7          	lui	s3,0x4000
    800018a4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018a6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a8:	00014a17          	auipc	s4,0x14
    800018ac:	300a0a13          	addi	s4,s4,768 # 80015ba8 <tickslock>
      initlock(&p->lock, "proc");
    800018b0:	85da                	mv	a1,s6
    800018b2:	8526                	mv	a0,s1
    800018b4:	aeaff0ef          	jal	80000b9e <initlock>
      p->state = UNUSED;
    800018b8:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800018bc:	415487b3          	sub	a5,s1,s5
    800018c0:	878d                	srai	a5,a5,0x3
    800018c2:	032787b3          	mul	a5,a5,s2
    800018c6:	07b6                	slli	a5,a5,0xd
    800018c8:	6709                	lui	a4,0x2
    800018ca:	9fb9                	addw	a5,a5,a4
    800018cc:	40f987b3          	sub	a5,s3,a5
    800018d0:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800018d2:	17848493          	addi	s1,s1,376
    800018d6:	fd449de3          	bne	s1,s4,800018b0 <procinit+0x72>
  }
}
    800018da:	70e2                	ld	ra,56(sp)
    800018dc:	7442                	ld	s0,48(sp)
    800018de:	74a2                	ld	s1,40(sp)
    800018e0:	7902                	ld	s2,32(sp)
    800018e2:	69e2                	ld	s3,24(sp)
    800018e4:	6a42                	ld	s4,16(sp)
    800018e6:	6aa2                	ld	s5,8(sp)
    800018e8:	6b02                	ld	s6,0(sp)
    800018ea:	6121                	addi	sp,sp,64
    800018ec:	8082                	ret

00000000800018ee <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018ee:	1141                	addi	sp,sp,-16
    800018f0:	e406                	sd	ra,8(sp)
    800018f2:	e022                	sd	s0,0(sp)
    800018f4:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018f6:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018f8:	2501                	sext.w	a0,a0
    800018fa:	60a2                	ld	ra,8(sp)
    800018fc:	6402                	ld	s0,0(sp)
    800018fe:	0141                	addi	sp,sp,16
    80001900:	8082                	ret

0000000080001902 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001902:	1141                	addi	sp,sp,-16
    80001904:	e406                	sd	ra,8(sp)
    80001906:	e022                	sd	s0,0(sp)
    80001908:	0800                	addi	s0,sp,16
    8000190a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000190c:	2781                	sext.w	a5,a5
    8000190e:	079e                	slli	a5,a5,0x7
  return c;
}
    80001910:	0000e517          	auipc	a0,0xe
    80001914:	09850513          	addi	a0,a0,152 # 8000f9a8 <cpus>
    80001918:	953e                	add	a0,a0,a5
    8000191a:	60a2                	ld	ra,8(sp)
    8000191c:	6402                	ld	s0,0(sp)
    8000191e:	0141                	addi	sp,sp,16
    80001920:	8082                	ret

0000000080001922 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001922:	1101                	addi	sp,sp,-32
    80001924:	ec06                	sd	ra,24(sp)
    80001926:	e822                	sd	s0,16(sp)
    80001928:	e426                	sd	s1,8(sp)
    8000192a:	1000                	addi	s0,sp,32
  push_off();
    8000192c:	ab8ff0ef          	jal	80000be4 <push_off>
    80001930:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001932:	2781                	sext.w	a5,a5
    80001934:	079e                	slli	a5,a5,0x7
    80001936:	0000e717          	auipc	a4,0xe
    8000193a:	04270713          	addi	a4,a4,66 # 8000f978 <pid_lock>
    8000193e:	97ba                	add	a5,a5,a4
    80001940:	7b9c                	ld	a5,48(a5)
    80001942:	84be                	mv	s1,a5
  pop_off();
    80001944:	b28ff0ef          	jal	80000c6c <pop_off>
  return p;
}
    80001948:	8526                	mv	a0,s1
    8000194a:	60e2                	ld	ra,24(sp)
    8000194c:	6442                	ld	s0,16(sp)
    8000194e:	64a2                	ld	s1,8(sp)
    80001950:	6105                	addi	sp,sp,32
    80001952:	8082                	ret

0000000080001954 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001954:	7179                	addi	sp,sp,-48
    80001956:	f406                	sd	ra,40(sp)
    80001958:	f022                	sd	s0,32(sp)
    8000195a:	ec26                	sd	s1,24(sp)
    8000195c:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    8000195e:	fc5ff0ef          	jal	80001922 <myproc>
    80001962:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001964:	b58ff0ef          	jal	80000cbc <release>

  if (first) {
    80001968:	00006797          	auipc	a5,0x6
    8000196c:	ed87a783          	lw	a5,-296(a5) # 80007840 <first.1>
    80001970:	cf95                	beqz	a5,800019ac <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001972:	4505                	li	a0,1
    80001974:	58d010ef          	jal	80003700 <fsinit>

    first = 0;
    80001978:	00006797          	auipc	a5,0x6
    8000197c:	ec07a423          	sw	zero,-312(a5) # 80007840 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001980:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001984:	00005797          	auipc	a5,0x5
    80001988:	7fc78793          	addi	a5,a5,2044 # 80007180 <etext+0x180>
    8000198c:	fcf43823          	sd	a5,-48(s0)
    80001990:	fc043c23          	sd	zero,-40(s0)
    80001994:	fd040593          	addi	a1,s0,-48
    80001998:	853e                	mv	a0,a5
    8000199a:	6ef020ef          	jal	80004888 <kexec>
    8000199e:	70bc                	ld	a5,96(s1)
    800019a0:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019a2:	70bc                	ld	a5,96(s1)
    800019a4:	7bb8                	ld	a4,112(a5)
    800019a6:	57fd                	li	a5,-1
    800019a8:	02f70d63          	beq	a4,a5,800019e2 <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800019ac:	2eb000ef          	jal	80002496 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019b0:	6ca8                	ld	a0,88(s1)
    800019b2:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019b4:	04000737          	lui	a4,0x4000
    800019b8:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800019ba:	0732                	slli	a4,a4,0xc
    800019bc:	00004797          	auipc	a5,0x4
    800019c0:	6e078793          	addi	a5,a5,1760 # 8000609c <userret>
    800019c4:	00004697          	auipc	a3,0x4
    800019c8:	63c68693          	addi	a3,a3,1596 # 80006000 <_trampoline>
    800019cc:	8f95                	sub	a5,a5,a3
    800019ce:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019d0:	577d                	li	a4,-1
    800019d2:	177e                	slli	a4,a4,0x3f
    800019d4:	8d59                	or	a0,a0,a4
    800019d6:	9782                	jalr	a5
}
    800019d8:	70a2                	ld	ra,40(sp)
    800019da:	7402                	ld	s0,32(sp)
    800019dc:	64e2                	ld	s1,24(sp)
    800019de:	6145                	addi	sp,sp,48
    800019e0:	8082                	ret
      panic("exec");
    800019e2:	00005517          	auipc	a0,0x5
    800019e6:	7a650513          	addi	a0,a0,1958 # 80007188 <etext+0x188>
    800019ea:	e3bfe0ef          	jal	80000824 <panic>

00000000800019ee <allocpid>:
{
    800019ee:	1101                	addi	sp,sp,-32
    800019f0:	ec06                	sd	ra,24(sp)
    800019f2:	e822                	sd	s0,16(sp)
    800019f4:	e426                	sd	s1,8(sp)
    800019f6:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019f8:	0000e517          	auipc	a0,0xe
    800019fc:	f8050513          	addi	a0,a0,-128 # 8000f978 <pid_lock>
    80001a00:	a28ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a04:	00006797          	auipc	a5,0x6
    80001a08:	e4078793          	addi	a5,a5,-448 # 80007844 <nextpid>
    80001a0c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a0e:	0014871b          	addiw	a4,s1,1
    80001a12:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a14:	0000e517          	auipc	a0,0xe
    80001a18:	f6450513          	addi	a0,a0,-156 # 8000f978 <pid_lock>
    80001a1c:	aa0ff0ef          	jal	80000cbc <release>
}
    80001a20:	8526                	mv	a0,s1
    80001a22:	60e2                	ld	ra,24(sp)
    80001a24:	6442                	ld	s0,16(sp)
    80001a26:	64a2                	ld	s1,8(sp)
    80001a28:	6105                	addi	sp,sp,32
    80001a2a:	8082                	ret

0000000080001a2c <proc_pagetable>:
{
    80001a2c:	1101                	addi	sp,sp,-32
    80001a2e:	ec06                	sd	ra,24(sp)
    80001a30:	e822                	sd	s0,16(sp)
    80001a32:	e426                	sd	s1,8(sp)
    80001a34:	e04a                	sd	s2,0(sp)
    80001a36:	1000                	addi	s0,sp,32
    80001a38:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a3a:	fceff0ef          	jal	80001208 <uvmcreate>
    80001a3e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a40:	cd05                	beqz	a0,80001a78 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a42:	4729                	li	a4,10
    80001a44:	00004697          	auipc	a3,0x4
    80001a48:	5bc68693          	addi	a3,a3,1468 # 80006000 <_trampoline>
    80001a4c:	6605                	lui	a2,0x1
    80001a4e:	040005b7          	lui	a1,0x4000
    80001a52:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a54:	05b2                	slli	a1,a1,0xc
    80001a56:	e0aff0ef          	jal	80001060 <mappages>
    80001a5a:	02054663          	bltz	a0,80001a86 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a5e:	4719                	li	a4,6
    80001a60:	06093683          	ld	a3,96(s2)
    80001a64:	6605                	lui	a2,0x1
    80001a66:	020005b7          	lui	a1,0x2000
    80001a6a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a6c:	05b6                	slli	a1,a1,0xd
    80001a6e:	8526                	mv	a0,s1
    80001a70:	df0ff0ef          	jal	80001060 <mappages>
    80001a74:	00054f63          	bltz	a0,80001a92 <proc_pagetable+0x66>
}
    80001a78:	8526                	mv	a0,s1
    80001a7a:	60e2                	ld	ra,24(sp)
    80001a7c:	6442                	ld	s0,16(sp)
    80001a7e:	64a2                	ld	s1,8(sp)
    80001a80:	6902                	ld	s2,0(sp)
    80001a82:	6105                	addi	sp,sp,32
    80001a84:	8082                	ret
    uvmfree(pagetable, 0);
    80001a86:	4581                	li	a1,0
    80001a88:	8526                	mv	a0,s1
    80001a8a:	979ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001a8e:	4481                	li	s1,0
    80001a90:	b7e5                	j	80001a78 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a92:	4681                	li	a3,0
    80001a94:	4605                	li	a2,1
    80001a96:	040005b7          	lui	a1,0x4000
    80001a9a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a9c:	05b2                	slli	a1,a1,0xc
    80001a9e:	8526                	mv	a0,s1
    80001aa0:	f8eff0ef          	jal	8000122e <uvmunmap>
    uvmfree(pagetable, 0);
    80001aa4:	4581                	li	a1,0
    80001aa6:	8526                	mv	a0,s1
    80001aa8:	95bff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001aac:	4481                	li	s1,0
    80001aae:	b7e9                	j	80001a78 <proc_pagetable+0x4c>

0000000080001ab0 <proc_freepagetable>:
{
    80001ab0:	1101                	addi	sp,sp,-32
    80001ab2:	ec06                	sd	ra,24(sp)
    80001ab4:	e822                	sd	s0,16(sp)
    80001ab6:	e426                	sd	s1,8(sp)
    80001ab8:	e04a                	sd	s2,0(sp)
    80001aba:	1000                	addi	s0,sp,32
    80001abc:	84aa                	mv	s1,a0
    80001abe:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ac0:	4681                	li	a3,0
    80001ac2:	4605                	li	a2,1
    80001ac4:	040005b7          	lui	a1,0x4000
    80001ac8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aca:	05b2                	slli	a1,a1,0xc
    80001acc:	f62ff0ef          	jal	8000122e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ad0:	4681                	li	a3,0
    80001ad2:	4605                	li	a2,1
    80001ad4:	020005b7          	lui	a1,0x2000
    80001ad8:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ada:	05b6                	slli	a1,a1,0xd
    80001adc:	8526                	mv	a0,s1
    80001ade:	f50ff0ef          	jal	8000122e <uvmunmap>
  uvmfree(pagetable, sz);
    80001ae2:	85ca                	mv	a1,s2
    80001ae4:	8526                	mv	a0,s1
    80001ae6:	91dff0ef          	jal	80001402 <uvmfree>
}
    80001aea:	60e2                	ld	ra,24(sp)
    80001aec:	6442                	ld	s0,16(sp)
    80001aee:	64a2                	ld	s1,8(sp)
    80001af0:	6902                	ld	s2,0(sp)
    80001af2:	6105                	addi	sp,sp,32
    80001af4:	8082                	ret

0000000080001af6 <freeproc>:
{
    80001af6:	1101                	addi	sp,sp,-32
    80001af8:	ec06                	sd	ra,24(sp)
    80001afa:	e822                	sd	s0,16(sp)
    80001afc:	e426                	sd	s1,8(sp)
    80001afe:	1000                	addi	s0,sp,32
    80001b00:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b02:	7128                	ld	a0,96(a0)
    80001b04:	c119                	beqz	a0,80001b0a <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001b06:	f57fe0ef          	jal	80000a5c <kfree>
  p->trapframe = 0;
    80001b0a:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001b0e:	6ca8                	ld	a0,88(s1)
    80001b10:	c501                	beqz	a0,80001b18 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b12:	68ac                	ld	a1,80(s1)
    80001b14:	f9dff0ef          	jal	80001ab0 <proc_freepagetable>
  p->pagetable = 0;
    80001b18:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001b1c:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001b20:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b24:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001b28:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001b2c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b30:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b34:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b38:	0004ac23          	sw	zero,24(s1)
}
    80001b3c:	60e2                	ld	ra,24(sp)
    80001b3e:	6442                	ld	s0,16(sp)
    80001b40:	64a2                	ld	s1,8(sp)
    80001b42:	6105                	addi	sp,sp,32
    80001b44:	8082                	ret

0000000080001b46 <allocproc>:
{
    80001b46:	1101                	addi	sp,sp,-32
    80001b48:	ec06                	sd	ra,24(sp)
    80001b4a:	e822                	sd	s0,16(sp)
    80001b4c:	e426                	sd	s1,8(sp)
    80001b4e:	e04a                	sd	s2,0(sp)
    80001b50:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b52:	0000e497          	auipc	s1,0xe
    80001b56:	25648493          	addi	s1,s1,598 # 8000fda8 <proc>
    80001b5a:	00014917          	auipc	s2,0x14
    80001b5e:	04e90913          	addi	s2,s2,78 # 80015ba8 <tickslock>
    acquire(&p->lock);
    80001b62:	8526                	mv	a0,s1
    80001b64:	8c4ff0ef          	jal	80000c28 <acquire>
    if(p->state == UNUSED) {
    80001b68:	4c9c                	lw	a5,24(s1)
    80001b6a:	cb91                	beqz	a5,80001b7e <allocproc+0x38>
      release(&p->lock);
    80001b6c:	8526                	mv	a0,s1
    80001b6e:	94eff0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b72:	17848493          	addi	s1,s1,376
    80001b76:	ff2496e3          	bne	s1,s2,80001b62 <allocproc+0x1c>
  return 0;
    80001b7a:	4481                	li	s1,0
    80001b7c:	a089                	j	80001bbe <allocproc+0x78>
  p->pid = allocpid();
    80001b7e:	e71ff0ef          	jal	800019ee <allocpid>
    80001b82:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b84:	4785                	li	a5,1
    80001b86:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b88:	fbdfe0ef          	jal	80000b44 <kalloc>
    80001b8c:	892a                	mv	s2,a0
    80001b8e:	f0a8                	sd	a0,96(s1)
    80001b90:	cd15                	beqz	a0,80001bcc <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b92:	8526                	mv	a0,s1
    80001b94:	e99ff0ef          	jal	80001a2c <proc_pagetable>
    80001b98:	892a                	mv	s2,a0
    80001b9a:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001b9c:	c121                	beqz	a0,80001bdc <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b9e:	07000613          	li	a2,112
    80001ba2:	4581                	li	a1,0
    80001ba4:	06848513          	addi	a0,s1,104
    80001ba8:	950ff0ef          	jal	80000cf8 <memset>
  p->context.ra = (uint64)forkret;
    80001bac:	00000797          	auipc	a5,0x0
    80001bb0:	da878793          	addi	a5,a5,-600 # 80001954 <forkret>
    80001bb4:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001bb6:	64bc                	ld	a5,72(s1)
    80001bb8:	6705                	lui	a4,0x1
    80001bba:	97ba                	add	a5,a5,a4
    80001bbc:	f8bc                	sd	a5,112(s1)
}
    80001bbe:	8526                	mv	a0,s1
    80001bc0:	60e2                	ld	ra,24(sp)
    80001bc2:	6442                	ld	s0,16(sp)
    80001bc4:	64a2                	ld	s1,8(sp)
    80001bc6:	6902                	ld	s2,0(sp)
    80001bc8:	6105                	addi	sp,sp,32
    80001bca:	8082                	ret
    freeproc(p);
    80001bcc:	8526                	mv	a0,s1
    80001bce:	f29ff0ef          	jal	80001af6 <freeproc>
    release(&p->lock);
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	8e8ff0ef          	jal	80000cbc <release>
    return 0;
    80001bd8:	84ca                	mv	s1,s2
    80001bda:	b7d5                	j	80001bbe <allocproc+0x78>
    freeproc(p);
    80001bdc:	8526                	mv	a0,s1
    80001bde:	f19ff0ef          	jal	80001af6 <freeproc>
    release(&p->lock);
    80001be2:	8526                	mv	a0,s1
    80001be4:	8d8ff0ef          	jal	80000cbc <release>
    return 0;
    80001be8:	84ca                	mv	s1,s2
    80001bea:	bfd1                	j	80001bbe <allocproc+0x78>

0000000080001bec <kallocproc>:
{
    80001bec:	1141                	addi	sp,sp,-16
    80001bee:	e406                	sd	ra,8(sp)
    80001bf0:	e022                	sd	s0,0(sp)
    80001bf2:	0800                	addi	s0,sp,16
  return allocproc();
    80001bf4:	f53ff0ef          	jal	80001b46 <allocproc>
}
    80001bf8:	60a2                	ld	ra,8(sp)
    80001bfa:	6402                	ld	s0,0(sp)
    80001bfc:	0141                	addi	sp,sp,16
    80001bfe:	8082                	ret

0000000080001c00 <kfreeproc>:
{
    80001c00:	1141                	addi	sp,sp,-16
    80001c02:	e406                	sd	ra,8(sp)
    80001c04:	e022                	sd	s0,0(sp)
    80001c06:	0800                	addi	s0,sp,16
  freeproc(p);
    80001c08:	eefff0ef          	jal	80001af6 <freeproc>
}
    80001c0c:	60a2                	ld	ra,8(sp)
    80001c0e:	6402                	ld	s0,0(sp)
    80001c10:	0141                	addi	sp,sp,16
    80001c12:	8082                	ret

0000000080001c14 <userinit>:
{
    80001c14:	1101                	addi	sp,sp,-32
    80001c16:	ec06                	sd	ra,24(sp)
    80001c18:	e822                	sd	s0,16(sp)
    80001c1a:	e426                	sd	s1,8(sp)
    80001c1c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c1e:	f29ff0ef          	jal	80001b46 <allocproc>
    80001c22:	84aa                	mv	s1,a0
  initproc = p;
    80001c24:	00006797          	auipc	a5,0x6
    80001c28:	c4a7b623          	sd	a0,-948(a5) # 80007870 <initproc>
  p->cwd = namei("/");
    80001c2c:	00005517          	auipc	a0,0x5
    80001c30:	56450513          	addi	a0,a0,1380 # 80007190 <etext+0x190>
    80001c34:	006020ef          	jal	80003c3a <namei>
    80001c38:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001c3c:	478d                	li	a5,3
    80001c3e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c40:	8526                	mv	a0,s1
    80001c42:	87aff0ef          	jal	80000cbc <release>
}
    80001c46:	60e2                	ld	ra,24(sp)
    80001c48:	6442                	ld	s0,16(sp)
    80001c4a:	64a2                	ld	s1,8(sp)
    80001c4c:	6105                	addi	sp,sp,32
    80001c4e:	8082                	ret

0000000080001c50 <growproc>:
{
    80001c50:	1101                	addi	sp,sp,-32
    80001c52:	ec06                	sd	ra,24(sp)
    80001c54:	e822                	sd	s0,16(sp)
    80001c56:	e426                	sd	s1,8(sp)
    80001c58:	e04a                	sd	s2,0(sp)
    80001c5a:	1000                	addi	s0,sp,32
    80001c5c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c5e:	cc5ff0ef          	jal	80001922 <myproc>
    80001c62:	892a                	mv	s2,a0
  sz = p->sz;
    80001c64:	692c                	ld	a1,80(a0)
  if(n > 0){
    80001c66:	02905963          	blez	s1,80001c98 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001c6a:	00b48633          	add	a2,s1,a1
    80001c6e:	020007b7          	lui	a5,0x2000
    80001c72:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c74:	07b6                	slli	a5,a5,0xd
    80001c76:	02c7ea63          	bltu	a5,a2,80001caa <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c7a:	4691                	li	a3,4
    80001c7c:	6d28                	ld	a0,88(a0)
    80001c7e:	e7eff0ef          	jal	800012fc <uvmalloc>
    80001c82:	85aa                	mv	a1,a0
    80001c84:	c50d                	beqz	a0,80001cae <growproc+0x5e>
  p->sz = sz;
    80001c86:	04b93823          	sd	a1,80(s2)
  return 0;
    80001c8a:	4501                	li	a0,0
}
    80001c8c:	60e2                	ld	ra,24(sp)
    80001c8e:	6442                	ld	s0,16(sp)
    80001c90:	64a2                	ld	s1,8(sp)
    80001c92:	6902                	ld	s2,0(sp)
    80001c94:	6105                	addi	sp,sp,32
    80001c96:	8082                	ret
  } else if(n < 0){
    80001c98:	fe04d7e3          	bgez	s1,80001c86 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c9c:	00b48633          	add	a2,s1,a1
    80001ca0:	6d28                	ld	a0,88(a0)
    80001ca2:	e16ff0ef          	jal	800012b8 <uvmdealloc>
    80001ca6:	85aa                	mv	a1,a0
    80001ca8:	bff9                	j	80001c86 <growproc+0x36>
      return -1;
    80001caa:	557d                	li	a0,-1
    80001cac:	b7c5                	j	80001c8c <growproc+0x3c>
      return -1;
    80001cae:	557d                	li	a0,-1
    80001cb0:	bff1                	j	80001c8c <growproc+0x3c>

0000000080001cb2 <kfork>:
{
    80001cb2:	7139                	addi	sp,sp,-64
    80001cb4:	fc06                	sd	ra,56(sp)
    80001cb6:	f822                	sd	s0,48(sp)
    80001cb8:	f426                	sd	s1,40(sp)
    80001cba:	e456                	sd	s5,8(sp)
    80001cbc:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001cbe:	c65ff0ef          	jal	80001922 <myproc>
    80001cc2:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001cc4:	e83ff0ef          	jal	80001b46 <allocproc>
    80001cc8:	0e050a63          	beqz	a0,80001dbc <kfork+0x10a>
    80001ccc:	e852                	sd	s4,16(sp)
    80001cce:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001cd0:	050ab603          	ld	a2,80(s5)
    80001cd4:	6d2c                	ld	a1,88(a0)
    80001cd6:	058ab503          	ld	a0,88(s5)
    80001cda:	f5aff0ef          	jal	80001434 <uvmcopy>
    80001cde:	04054863          	bltz	a0,80001d2e <kfork+0x7c>
    80001ce2:	f04a                	sd	s2,32(sp)
    80001ce4:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001ce6:	050ab783          	ld	a5,80(s5)
    80001cea:	04fa3823          	sd	a5,80(s4)
  *(np->trapframe) = *(p->trapframe);
    80001cee:	060ab683          	ld	a3,96(s5)
    80001cf2:	87b6                	mv	a5,a3
    80001cf4:	060a3703          	ld	a4,96(s4)
    80001cf8:	12068693          	addi	a3,a3,288
    80001cfc:	6388                	ld	a0,0(a5)
    80001cfe:	678c                	ld	a1,8(a5)
    80001d00:	6b90                	ld	a2,16(a5)
    80001d02:	e308                	sd	a0,0(a4)
    80001d04:	e70c                	sd	a1,8(a4)
    80001d06:	eb10                	sd	a2,16(a4)
    80001d08:	6f90                	ld	a2,24(a5)
    80001d0a:	ef10                	sd	a2,24(a4)
    80001d0c:	02078793          	addi	a5,a5,32
    80001d10:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d14:	fed794e3          	bne	a5,a3,80001cfc <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d18:	060a3783          	ld	a5,96(s4)
    80001d1c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001d20:	0d8a8493          	addi	s1,s5,216
    80001d24:	0d8a0913          	addi	s2,s4,216
    80001d28:	158a8993          	addi	s3,s5,344
    80001d2c:	a831                	j	80001d48 <kfork+0x96>
    freeproc(np);
    80001d2e:	8552                	mv	a0,s4
    80001d30:	dc7ff0ef          	jal	80001af6 <freeproc>
    release(&np->lock);
    80001d34:	8552                	mv	a0,s4
    80001d36:	f87fe0ef          	jal	80000cbc <release>
    return -1;
    80001d3a:	54fd                	li	s1,-1
    80001d3c:	6a42                	ld	s4,16(sp)
    80001d3e:	a885                	j	80001dae <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001d40:	04a1                	addi	s1,s1,8
    80001d42:	0921                	addi	s2,s2,8
    80001d44:	01348963          	beq	s1,s3,80001d56 <kfork+0xa4>
    if(p->ofile[i])
    80001d48:	6088                	ld	a0,0(s1)
    80001d4a:	d97d                	beqz	a0,80001d40 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d4c:	4aa020ef          	jal	800041f6 <filedup>
    80001d50:	00a93023          	sd	a0,0(s2)
    80001d54:	b7f5                	j	80001d40 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d56:	158ab503          	ld	a0,344(s5)
    80001d5a:	67c010ef          	jal	800033d6 <idup>
    80001d5e:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d62:	4641                	li	a2,16
    80001d64:	160a8593          	addi	a1,s5,352
    80001d68:	160a0513          	addi	a0,s4,352
    80001d6c:	8e0ff0ef          	jal	80000e4c <safestrcpy>
  pid = np->pid;
    80001d70:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d74:	8552                	mv	a0,s4
    80001d76:	f47fe0ef          	jal	80000cbc <release>
  acquire(&wait_lock);
    80001d7a:	0000e517          	auipc	a0,0xe
    80001d7e:	c1650513          	addi	a0,a0,-1002 # 8000f990 <wait_lock>
    80001d82:	ea7fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001d86:	055a3023          	sd	s5,64(s4)
  release(&wait_lock);
    80001d8a:	0000e517          	auipc	a0,0xe
    80001d8e:	c0650513          	addi	a0,a0,-1018 # 8000f990 <wait_lock>
    80001d92:	f2bfe0ef          	jal	80000cbc <release>
  acquire(&np->lock);
    80001d96:	8552                	mv	a0,s4
    80001d98:	e91fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001d9c:	478d                	li	a5,3
    80001d9e:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001da2:	8552                	mv	a0,s4
    80001da4:	f19fe0ef          	jal	80000cbc <release>
  return pid;
    80001da8:	7902                	ld	s2,32(sp)
    80001daa:	69e2                	ld	s3,24(sp)
    80001dac:	6a42                	ld	s4,16(sp)
}
    80001dae:	8526                	mv	a0,s1
    80001db0:	70e2                	ld	ra,56(sp)
    80001db2:	7442                	ld	s0,48(sp)
    80001db4:	74a2                	ld	s1,40(sp)
    80001db6:	6aa2                	ld	s5,8(sp)
    80001db8:	6121                	addi	sp,sp,64
    80001dba:	8082                	ret
    return -1;
    80001dbc:	54fd                	li	s1,-1
    80001dbe:	bfc5                	j	80001dae <kfork+0xfc>

0000000080001dc0 <scheduler>:
{
    80001dc0:	715d                	addi	sp,sp,-80
    80001dc2:	e486                	sd	ra,72(sp)
    80001dc4:	e0a2                	sd	s0,64(sp)
    80001dc6:	fc26                	sd	s1,56(sp)
    80001dc8:	f84a                	sd	s2,48(sp)
    80001dca:	f44e                	sd	s3,40(sp)
    80001dcc:	f052                	sd	s4,32(sp)
    80001dce:	ec56                	sd	s5,24(sp)
    80001dd0:	e85a                	sd	s6,16(sp)
    80001dd2:	e45e                	sd	s7,8(sp)
    80001dd4:	e062                	sd	s8,0(sp)
    80001dd6:	0880                	addi	s0,sp,80
    80001dd8:	8792                	mv	a5,tp
  int id = r_tp();
    80001dda:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ddc:	00779b13          	slli	s6,a5,0x7
    80001de0:	0000e717          	auipc	a4,0xe
    80001de4:	b9870713          	addi	a4,a4,-1128 # 8000f978 <pid_lock>
    80001de8:	975a                	add	a4,a4,s6
    80001dea:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001dee:	0000e717          	auipc	a4,0xe
    80001df2:	bc270713          	addi	a4,a4,-1086 # 8000f9b0 <cpus+0x8>
    80001df6:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001df8:	4c11                	li	s8,4
        c->proc = p;
    80001dfa:	079e                	slli	a5,a5,0x7
    80001dfc:	0000ea17          	auipc	s4,0xe
    80001e00:	b7ca0a13          	addi	s4,s4,-1156 # 8000f978 <pid_lock>
    80001e04:	9a3e                	add	s4,s4,a5
        found = 1;
    80001e06:	4b85                	li	s7,1
    80001e08:	a83d                	j	80001e46 <scheduler+0x86>
      release(&p->lock);
    80001e0a:	8526                	mv	a0,s1
    80001e0c:	eb1fe0ef          	jal	80000cbc <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e10:	17848493          	addi	s1,s1,376
    80001e14:	03248563          	beq	s1,s2,80001e3e <scheduler+0x7e>
      acquire(&p->lock);
    80001e18:	8526                	mv	a0,s1
    80001e1a:	e0ffe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE) {
    80001e1e:	4c9c                	lw	a5,24(s1)
    80001e20:	ff3795e3          	bne	a5,s3,80001e0a <scheduler+0x4a>
        p->state = RUNNING;
    80001e24:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001e28:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001e2c:	06848593          	addi	a1,s1,104
    80001e30:	855a                	mv	a0,s6
    80001e32:	5ba000ef          	jal	800023ec <swtch>
        c->proc = 0;
    80001e36:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001e3a:	8ade                	mv	s5,s7
    80001e3c:	b7f9                	j	80001e0a <scheduler+0x4a>
    if(found == 0) {
    80001e3e:	000a9463          	bnez	s5,80001e46 <scheduler+0x86>
      asm volatile("wfi");
    80001e42:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e46:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e4a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e4e:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001e56:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e58:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001e5c:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e5e:	0000e497          	auipc	s1,0xe
    80001e62:	f4a48493          	addi	s1,s1,-182 # 8000fda8 <proc>
      if(p->state == RUNNABLE) {
    80001e66:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e68:	00014917          	auipc	s2,0x14
    80001e6c:	d4090913          	addi	s2,s2,-704 # 80015ba8 <tickslock>
    80001e70:	b765                	j	80001e18 <scheduler+0x58>

0000000080001e72 <sched>:
{
    80001e72:	7179                	addi	sp,sp,-48
    80001e74:	f406                	sd	ra,40(sp)
    80001e76:	f022                	sd	s0,32(sp)
    80001e78:	ec26                	sd	s1,24(sp)
    80001e7a:	e84a                	sd	s2,16(sp)
    80001e7c:	e44e                	sd	s3,8(sp)
    80001e7e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e80:	aa3ff0ef          	jal	80001922 <myproc>
    80001e84:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e86:	d33fe0ef          	jal	80000bb8 <holding>
    80001e8a:	c935                	beqz	a0,80001efe <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e8c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e8e:	2781                	sext.w	a5,a5
    80001e90:	079e                	slli	a5,a5,0x7
    80001e92:	0000e717          	auipc	a4,0xe
    80001e96:	ae670713          	addi	a4,a4,-1306 # 8000f978 <pid_lock>
    80001e9a:	97ba                	add	a5,a5,a4
    80001e9c:	0a87a703          	lw	a4,168(a5)
    80001ea0:	4785                	li	a5,1
    80001ea2:	06f71463          	bne	a4,a5,80001f0a <sched+0x98>
  if(p->state == RUNNING)
    80001ea6:	4c98                	lw	a4,24(s1)
    80001ea8:	4791                	li	a5,4
    80001eaa:	06f70663          	beq	a4,a5,80001f16 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001eae:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001eb2:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001eb4:	e7bd                	bnez	a5,80001f22 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001eb6:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001eb8:	0000e917          	auipc	s2,0xe
    80001ebc:	ac090913          	addi	s2,s2,-1344 # 8000f978 <pid_lock>
    80001ec0:	2781                	sext.w	a5,a5
    80001ec2:	079e                	slli	a5,a5,0x7
    80001ec4:	97ca                	add	a5,a5,s2
    80001ec6:	0ac7a983          	lw	s3,172(a5)
    80001eca:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001ecc:	2781                	sext.w	a5,a5
    80001ece:	079e                	slli	a5,a5,0x7
    80001ed0:	07a1                	addi	a5,a5,8
    80001ed2:	0000e597          	auipc	a1,0xe
    80001ed6:	ad658593          	addi	a1,a1,-1322 # 8000f9a8 <cpus>
    80001eda:	95be                	add	a1,a1,a5
    80001edc:	06848513          	addi	a0,s1,104
    80001ee0:	50c000ef          	jal	800023ec <swtch>
    80001ee4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001ee6:	2781                	sext.w	a5,a5
    80001ee8:	079e                	slli	a5,a5,0x7
    80001eea:	993e                	add	s2,s2,a5
    80001eec:	0b392623          	sw	s3,172(s2)
}
    80001ef0:	70a2                	ld	ra,40(sp)
    80001ef2:	7402                	ld	s0,32(sp)
    80001ef4:	64e2                	ld	s1,24(sp)
    80001ef6:	6942                	ld	s2,16(sp)
    80001ef8:	69a2                	ld	s3,8(sp)
    80001efa:	6145                	addi	sp,sp,48
    80001efc:	8082                	ret
    panic("sched p->lock");
    80001efe:	00005517          	auipc	a0,0x5
    80001f02:	29a50513          	addi	a0,a0,666 # 80007198 <etext+0x198>
    80001f06:	91ffe0ef          	jal	80000824 <panic>
    panic("sched locks");
    80001f0a:	00005517          	auipc	a0,0x5
    80001f0e:	29e50513          	addi	a0,a0,670 # 800071a8 <etext+0x1a8>
    80001f12:	913fe0ef          	jal	80000824 <panic>
    panic("sched RUNNING");
    80001f16:	00005517          	auipc	a0,0x5
    80001f1a:	2a250513          	addi	a0,a0,674 # 800071b8 <etext+0x1b8>
    80001f1e:	907fe0ef          	jal	80000824 <panic>
    panic("sched interruptible");
    80001f22:	00005517          	auipc	a0,0x5
    80001f26:	2a650513          	addi	a0,a0,678 # 800071c8 <etext+0x1c8>
    80001f2a:	8fbfe0ef          	jal	80000824 <panic>

0000000080001f2e <yield>:
{
    80001f2e:	1101                	addi	sp,sp,-32
    80001f30:	ec06                	sd	ra,24(sp)
    80001f32:	e822                	sd	s0,16(sp)
    80001f34:	e426                	sd	s1,8(sp)
    80001f36:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f38:	9ebff0ef          	jal	80001922 <myproc>
    80001f3c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f3e:	cebfe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80001f42:	478d                	li	a5,3
    80001f44:	cc9c                	sw	a5,24(s1)
  sched();
    80001f46:	f2dff0ef          	jal	80001e72 <sched>
  release(&p->lock);
    80001f4a:	8526                	mv	a0,s1
    80001f4c:	d71fe0ef          	jal	80000cbc <release>
}
    80001f50:	60e2                	ld	ra,24(sp)
    80001f52:	6442                	ld	s0,16(sp)
    80001f54:	64a2                	ld	s1,8(sp)
    80001f56:	6105                	addi	sp,sp,32
    80001f58:	8082                	ret

0000000080001f5a <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001f5a:	7179                	addi	sp,sp,-48
    80001f5c:	f406                	sd	ra,40(sp)
    80001f5e:	f022                	sd	s0,32(sp)
    80001f60:	ec26                	sd	s1,24(sp)
    80001f62:	e84a                	sd	s2,16(sp)
    80001f64:	e44e                	sd	s3,8(sp)
    80001f66:	1800                	addi	s0,sp,48
    80001f68:	89aa                	mv	s3,a0
    80001f6a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f6c:	9b7ff0ef          	jal	80001922 <myproc>
    80001f70:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001f72:	cb7fe0ef          	jal	80000c28 <acquire>
  release(lk);
    80001f76:	854a                	mv	a0,s2
    80001f78:	d45fe0ef          	jal	80000cbc <release>

  // Go to sleep.
  p->chan = chan;
    80001f7c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f80:	4789                	li	a5,2
    80001f82:	cc9c                	sw	a5,24(s1)

  sched();
    80001f84:	eefff0ef          	jal	80001e72 <sched>

  // Tidy up.
  p->chan = 0;
    80001f88:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f8c:	8526                	mv	a0,s1
    80001f8e:	d2ffe0ef          	jal	80000cbc <release>
  acquire(lk);
    80001f92:	854a                	mv	a0,s2
    80001f94:	c95fe0ef          	jal	80000c28 <acquire>
}
    80001f98:	70a2                	ld	ra,40(sp)
    80001f9a:	7402                	ld	s0,32(sp)
    80001f9c:	64e2                	ld	s1,24(sp)
    80001f9e:	6942                	ld	s2,16(sp)
    80001fa0:	69a2                	ld	s3,8(sp)
    80001fa2:	6145                	addi	sp,sp,48
    80001fa4:	8082                	ret

0000000080001fa6 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001fa6:	7139                	addi	sp,sp,-64
    80001fa8:	fc06                	sd	ra,56(sp)
    80001faa:	f822                	sd	s0,48(sp)
    80001fac:	f426                	sd	s1,40(sp)
    80001fae:	f04a                	sd	s2,32(sp)
    80001fb0:	ec4e                	sd	s3,24(sp)
    80001fb2:	e852                	sd	s4,16(sp)
    80001fb4:	e456                	sd	s5,8(sp)
    80001fb6:	0080                	addi	s0,sp,64
    80001fb8:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001fba:	0000e497          	auipc	s1,0xe
    80001fbe:	dee48493          	addi	s1,s1,-530 # 8000fda8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001fc2:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001fc4:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fc6:	00014917          	auipc	s2,0x14
    80001fca:	be290913          	addi	s2,s2,-1054 # 80015ba8 <tickslock>
    80001fce:	a801                	j	80001fde <wakeup+0x38>
      }
      release(&p->lock);
    80001fd0:	8526                	mv	a0,s1
    80001fd2:	cebfe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fd6:	17848493          	addi	s1,s1,376
    80001fda:	03248263          	beq	s1,s2,80001ffe <wakeup+0x58>
    if(p != myproc()){
    80001fde:	945ff0ef          	jal	80001922 <myproc>
    80001fe2:	fe950ae3          	beq	a0,s1,80001fd6 <wakeup+0x30>
      acquire(&p->lock);
    80001fe6:	8526                	mv	a0,s1
    80001fe8:	c41fe0ef          	jal	80000c28 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001fec:	4c9c                	lw	a5,24(s1)
    80001fee:	ff3791e3          	bne	a5,s3,80001fd0 <wakeup+0x2a>
    80001ff2:	709c                	ld	a5,32(s1)
    80001ff4:	fd479ee3          	bne	a5,s4,80001fd0 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001ff8:	0154ac23          	sw	s5,24(s1)
    80001ffc:	bfd1                	j	80001fd0 <wakeup+0x2a>
    }
  }
}
    80001ffe:	70e2                	ld	ra,56(sp)
    80002000:	7442                	ld	s0,48(sp)
    80002002:	74a2                	ld	s1,40(sp)
    80002004:	7902                	ld	s2,32(sp)
    80002006:	69e2                	ld	s3,24(sp)
    80002008:	6a42                	ld	s4,16(sp)
    8000200a:	6aa2                	ld	s5,8(sp)
    8000200c:	6121                	addi	sp,sp,64
    8000200e:	8082                	ret

0000000080002010 <reparent>:
{
    80002010:	7179                	addi	sp,sp,-48
    80002012:	f406                	sd	ra,40(sp)
    80002014:	f022                	sd	s0,32(sp)
    80002016:	ec26                	sd	s1,24(sp)
    80002018:	e84a                	sd	s2,16(sp)
    8000201a:	e44e                	sd	s3,8(sp)
    8000201c:	e052                	sd	s4,0(sp)
    8000201e:	1800                	addi	s0,sp,48
    80002020:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002022:	0000e497          	auipc	s1,0xe
    80002026:	d8648493          	addi	s1,s1,-634 # 8000fda8 <proc>
      pp->parent = initproc;
    8000202a:	00006a17          	auipc	s4,0x6
    8000202e:	846a0a13          	addi	s4,s4,-1978 # 80007870 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002032:	00014997          	auipc	s3,0x14
    80002036:	b7698993          	addi	s3,s3,-1162 # 80015ba8 <tickslock>
    8000203a:	a029                	j	80002044 <reparent+0x34>
    8000203c:	17848493          	addi	s1,s1,376
    80002040:	01348b63          	beq	s1,s3,80002056 <reparent+0x46>
    if(pp->parent == p){
    80002044:	60bc                	ld	a5,64(s1)
    80002046:	ff279be3          	bne	a5,s2,8000203c <reparent+0x2c>
      pp->parent = initproc;
    8000204a:	000a3503          	ld	a0,0(s4)
    8000204e:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    80002050:	f57ff0ef          	jal	80001fa6 <wakeup>
    80002054:	b7e5                	j	8000203c <reparent+0x2c>
}
    80002056:	70a2                	ld	ra,40(sp)
    80002058:	7402                	ld	s0,32(sp)
    8000205a:	64e2                	ld	s1,24(sp)
    8000205c:	6942                	ld	s2,16(sp)
    8000205e:	69a2                	ld	s3,8(sp)
    80002060:	6a02                	ld	s4,0(sp)
    80002062:	6145                	addi	sp,sp,48
    80002064:	8082                	ret

0000000080002066 <kexit>:
{
    80002066:	7179                	addi	sp,sp,-48
    80002068:	f406                	sd	ra,40(sp)
    8000206a:	f022                	sd	s0,32(sp)
    8000206c:	ec26                	sd	s1,24(sp)
    8000206e:	e84a                	sd	s2,16(sp)
    80002070:	e44e                	sd	s3,8(sp)
    80002072:	e052                	sd	s4,0(sp)
    80002074:	1800                	addi	s0,sp,48
    80002076:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002078:	8abff0ef          	jal	80001922 <myproc>
    8000207c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000207e:	00005797          	auipc	a5,0x5
    80002082:	7f27b783          	ld	a5,2034(a5) # 80007870 <initproc>
    80002086:	0d850493          	addi	s1,a0,216
    8000208a:	15850913          	addi	s2,a0,344
    8000208e:	00a79b63          	bne	a5,a0,800020a4 <kexit+0x3e>
    panic("init exiting");
    80002092:	00005517          	auipc	a0,0x5
    80002096:	14e50513          	addi	a0,a0,334 # 800071e0 <etext+0x1e0>
    8000209a:	f8afe0ef          	jal	80000824 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    8000209e:	04a1                	addi	s1,s1,8
    800020a0:	01248963          	beq	s1,s2,800020b2 <kexit+0x4c>
    if(p->ofile[fd]){
    800020a4:	6088                	ld	a0,0(s1)
    800020a6:	dd65                	beqz	a0,8000209e <kexit+0x38>
      fileclose(f);
    800020a8:	194020ef          	jal	8000423c <fileclose>
      p->ofile[fd] = 0;
    800020ac:	0004b023          	sd	zero,0(s1)
    800020b0:	b7fd                	j	8000209e <kexit+0x38>
  begin_op();
    800020b2:	567010ef          	jal	80003e18 <begin_op>
  iput(p->cwd);
    800020b6:	1589b503          	ld	a0,344(s3)
    800020ba:	4d4010ef          	jal	8000358e <iput>
  end_op();
    800020be:	5cb010ef          	jal	80003e88 <end_op>
  p->cwd = 0;
    800020c2:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    800020c6:	0000e517          	auipc	a0,0xe
    800020ca:	8ca50513          	addi	a0,a0,-1846 # 8000f990 <wait_lock>
    800020ce:	b5bfe0ef          	jal	80000c28 <acquire>
  reparent(p);
    800020d2:	854e                	mv	a0,s3
    800020d4:	f3dff0ef          	jal	80002010 <reparent>
  wakeup(p->parent);
    800020d8:	0409b503          	ld	a0,64(s3)
    800020dc:	ecbff0ef          	jal	80001fa6 <wakeup>
  acquire(&p->lock);
    800020e0:	854e                	mv	a0,s3
    800020e2:	b47fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    800020e6:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800020ea:	4795                	li	a5,5
    800020ec:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800020f0:	0000e517          	auipc	a0,0xe
    800020f4:	8a050513          	addi	a0,a0,-1888 # 8000f990 <wait_lock>
    800020f8:	bc5fe0ef          	jal	80000cbc <release>
  sched();
    800020fc:	d77ff0ef          	jal	80001e72 <sched>
  panic("zombie exit");
    80002100:	00005517          	auipc	a0,0x5
    80002104:	0f050513          	addi	a0,a0,240 # 800071f0 <etext+0x1f0>
    80002108:	f1cfe0ef          	jal	80000824 <panic>

000000008000210c <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    8000210c:	7179                	addi	sp,sp,-48
    8000210e:	f406                	sd	ra,40(sp)
    80002110:	f022                	sd	s0,32(sp)
    80002112:	ec26                	sd	s1,24(sp)
    80002114:	e84a                	sd	s2,16(sp)
    80002116:	e44e                	sd	s3,8(sp)
    80002118:	1800                	addi	s0,sp,48
    8000211a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000211c:	0000e497          	auipc	s1,0xe
    80002120:	c8c48493          	addi	s1,s1,-884 # 8000fda8 <proc>
    80002124:	00014997          	auipc	s3,0x14
    80002128:	a8498993          	addi	s3,s3,-1404 # 80015ba8 <tickslock>
    acquire(&p->lock);
    8000212c:	8526                	mv	a0,s1
    8000212e:	afbfe0ef          	jal	80000c28 <acquire>
    if(p->pid == pid){
    80002132:	589c                	lw	a5,48(s1)
    80002134:	01278b63          	beq	a5,s2,8000214a <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002138:	8526                	mv	a0,s1
    8000213a:	b83fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000213e:	17848493          	addi	s1,s1,376
    80002142:	ff3495e3          	bne	s1,s3,8000212c <kkill+0x20>
  }
  return -1;
    80002146:	557d                	li	a0,-1
    80002148:	a819                	j	8000215e <kkill+0x52>
      p->killed = 1;
    8000214a:	4785                	li	a5,1
    8000214c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000214e:	4c98                	lw	a4,24(s1)
    80002150:	4789                	li	a5,2
    80002152:	00f70d63          	beq	a4,a5,8000216c <kkill+0x60>
      release(&p->lock);
    80002156:	8526                	mv	a0,s1
    80002158:	b65fe0ef          	jal	80000cbc <release>
      return 0;
    8000215c:	4501                	li	a0,0
}
    8000215e:	70a2                	ld	ra,40(sp)
    80002160:	7402                	ld	s0,32(sp)
    80002162:	64e2                	ld	s1,24(sp)
    80002164:	6942                	ld	s2,16(sp)
    80002166:	69a2                	ld	s3,8(sp)
    80002168:	6145                	addi	sp,sp,48
    8000216a:	8082                	ret
        p->state = RUNNABLE;
    8000216c:	478d                	li	a5,3
    8000216e:	cc9c                	sw	a5,24(s1)
    80002170:	b7dd                	j	80002156 <kkill+0x4a>

0000000080002172 <setkilled>:

void
setkilled(struct proc *p)
{
    80002172:	1101                	addi	sp,sp,-32
    80002174:	ec06                	sd	ra,24(sp)
    80002176:	e822                	sd	s0,16(sp)
    80002178:	e426                	sd	s1,8(sp)
    8000217a:	1000                	addi	s0,sp,32
    8000217c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000217e:	aabfe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    80002182:	4785                	li	a5,1
    80002184:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002186:	8526                	mv	a0,s1
    80002188:	b35fe0ef          	jal	80000cbc <release>
}
    8000218c:	60e2                	ld	ra,24(sp)
    8000218e:	6442                	ld	s0,16(sp)
    80002190:	64a2                	ld	s1,8(sp)
    80002192:	6105                	addi	sp,sp,32
    80002194:	8082                	ret

0000000080002196 <killed>:

int
killed(struct proc *p)
{
    80002196:	1101                	addi	sp,sp,-32
    80002198:	ec06                	sd	ra,24(sp)
    8000219a:	e822                	sd	s0,16(sp)
    8000219c:	e426                	sd	s1,8(sp)
    8000219e:	e04a                	sd	s2,0(sp)
    800021a0:	1000                	addi	s0,sp,32
    800021a2:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800021a4:	a85fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    800021a8:	549c                	lw	a5,40(s1)
    800021aa:	893e                	mv	s2,a5
  release(&p->lock);
    800021ac:	8526                	mv	a0,s1
    800021ae:	b0ffe0ef          	jal	80000cbc <release>
  return k;
}
    800021b2:	854a                	mv	a0,s2
    800021b4:	60e2                	ld	ra,24(sp)
    800021b6:	6442                	ld	s0,16(sp)
    800021b8:	64a2                	ld	s1,8(sp)
    800021ba:	6902                	ld	s2,0(sp)
    800021bc:	6105                	addi	sp,sp,32
    800021be:	8082                	ret

00000000800021c0 <kwait>:
{
    800021c0:	715d                	addi	sp,sp,-80
    800021c2:	e486                	sd	ra,72(sp)
    800021c4:	e0a2                	sd	s0,64(sp)
    800021c6:	fc26                	sd	s1,56(sp)
    800021c8:	f84a                	sd	s2,48(sp)
    800021ca:	f44e                	sd	s3,40(sp)
    800021cc:	f052                	sd	s4,32(sp)
    800021ce:	ec56                	sd	s5,24(sp)
    800021d0:	e85a                	sd	s6,16(sp)
    800021d2:	e45e                	sd	s7,8(sp)
    800021d4:	0880                	addi	s0,sp,80
    800021d6:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800021d8:	f4aff0ef          	jal	80001922 <myproc>
    800021dc:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800021de:	0000d517          	auipc	a0,0xd
    800021e2:	7b250513          	addi	a0,a0,1970 # 8000f990 <wait_lock>
    800021e6:	a43fe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    800021ea:	4a15                	li	s4,5
        havekids = 1;
    800021ec:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ee:	00014997          	auipc	s3,0x14
    800021f2:	9ba98993          	addi	s3,s3,-1606 # 80015ba8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021f6:	0000db17          	auipc	s6,0xd
    800021fa:	79ab0b13          	addi	s6,s6,1946 # 8000f990 <wait_lock>
    800021fe:	a869                	j	80002298 <kwait+0xd8>
          pid = pp->pid;
    80002200:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002204:	000b8c63          	beqz	s7,8000221c <kwait+0x5c>
    80002208:	4691                	li	a3,4
    8000220a:	02c48613          	addi	a2,s1,44
    8000220e:	85de                	mv	a1,s7
    80002210:	05893503          	ld	a0,88(s2)
    80002214:	c40ff0ef          	jal	80001654 <copyout>
    80002218:	02054a63          	bltz	a0,8000224c <kwait+0x8c>
          freeproc(pp);
    8000221c:	8526                	mv	a0,s1
    8000221e:	8d9ff0ef          	jal	80001af6 <freeproc>
          release(&pp->lock);
    80002222:	8526                	mv	a0,s1
    80002224:	a99fe0ef          	jal	80000cbc <release>
          release(&wait_lock);
    80002228:	0000d517          	auipc	a0,0xd
    8000222c:	76850513          	addi	a0,a0,1896 # 8000f990 <wait_lock>
    80002230:	a8dfe0ef          	jal	80000cbc <release>
}
    80002234:	854e                	mv	a0,s3
    80002236:	60a6                	ld	ra,72(sp)
    80002238:	6406                	ld	s0,64(sp)
    8000223a:	74e2                	ld	s1,56(sp)
    8000223c:	7942                	ld	s2,48(sp)
    8000223e:	79a2                	ld	s3,40(sp)
    80002240:	7a02                	ld	s4,32(sp)
    80002242:	6ae2                	ld	s5,24(sp)
    80002244:	6b42                	ld	s6,16(sp)
    80002246:	6ba2                	ld	s7,8(sp)
    80002248:	6161                	addi	sp,sp,80
    8000224a:	8082                	ret
            release(&pp->lock);
    8000224c:	8526                	mv	a0,s1
    8000224e:	a6ffe0ef          	jal	80000cbc <release>
            release(&wait_lock);
    80002252:	0000d517          	auipc	a0,0xd
    80002256:	73e50513          	addi	a0,a0,1854 # 8000f990 <wait_lock>
    8000225a:	a63fe0ef          	jal	80000cbc <release>
            return -1;
    8000225e:	59fd                	li	s3,-1
    80002260:	bfd1                	j	80002234 <kwait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002262:	17848493          	addi	s1,s1,376
    80002266:	03348063          	beq	s1,s3,80002286 <kwait+0xc6>
      if(pp->parent == p){
    8000226a:	60bc                	ld	a5,64(s1)
    8000226c:	ff279be3          	bne	a5,s2,80002262 <kwait+0xa2>
        acquire(&pp->lock);
    80002270:	8526                	mv	a0,s1
    80002272:	9b7fe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    80002276:	4c9c                	lw	a5,24(s1)
    80002278:	f94784e3          	beq	a5,s4,80002200 <kwait+0x40>
        release(&pp->lock);
    8000227c:	8526                	mv	a0,s1
    8000227e:	a3ffe0ef          	jal	80000cbc <release>
        havekids = 1;
    80002282:	8756                	mv	a4,s5
    80002284:	bff9                	j	80002262 <kwait+0xa2>
    if(!havekids || killed(p)){
    80002286:	cf19                	beqz	a4,800022a4 <kwait+0xe4>
    80002288:	854a                	mv	a0,s2
    8000228a:	f0dff0ef          	jal	80002196 <killed>
    8000228e:	e919                	bnez	a0,800022a4 <kwait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002290:	85da                	mv	a1,s6
    80002292:	854a                	mv	a0,s2
    80002294:	cc7ff0ef          	jal	80001f5a <sleep>
    havekids = 0;
    80002298:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000229a:	0000e497          	auipc	s1,0xe
    8000229e:	b0e48493          	addi	s1,s1,-1266 # 8000fda8 <proc>
    800022a2:	b7e1                	j	8000226a <kwait+0xaa>
      release(&wait_lock);
    800022a4:	0000d517          	auipc	a0,0xd
    800022a8:	6ec50513          	addi	a0,a0,1772 # 8000f990 <wait_lock>
    800022ac:	a11fe0ef          	jal	80000cbc <release>
      return -1;
    800022b0:	59fd                	li	s3,-1
    800022b2:	b749                	j	80002234 <kwait+0x74>

00000000800022b4 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800022b4:	7179                	addi	sp,sp,-48
    800022b6:	f406                	sd	ra,40(sp)
    800022b8:	f022                	sd	s0,32(sp)
    800022ba:	ec26                	sd	s1,24(sp)
    800022bc:	e84a                	sd	s2,16(sp)
    800022be:	e44e                	sd	s3,8(sp)
    800022c0:	e052                	sd	s4,0(sp)
    800022c2:	1800                	addi	s0,sp,48
    800022c4:	84aa                	mv	s1,a0
    800022c6:	8a2e                	mv	s4,a1
    800022c8:	89b2                	mv	s3,a2
    800022ca:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800022cc:	e56ff0ef          	jal	80001922 <myproc>
  if(user_dst){
    800022d0:	cc99                	beqz	s1,800022ee <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800022d2:	86ca                	mv	a3,s2
    800022d4:	864e                	mv	a2,s3
    800022d6:	85d2                	mv	a1,s4
    800022d8:	6d28                	ld	a0,88(a0)
    800022da:	b7aff0ef          	jal	80001654 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800022de:	70a2                	ld	ra,40(sp)
    800022e0:	7402                	ld	s0,32(sp)
    800022e2:	64e2                	ld	s1,24(sp)
    800022e4:	6942                	ld	s2,16(sp)
    800022e6:	69a2                	ld	s3,8(sp)
    800022e8:	6a02                	ld	s4,0(sp)
    800022ea:	6145                	addi	sp,sp,48
    800022ec:	8082                	ret
    memmove((char *)dst, src, len);
    800022ee:	0009061b          	sext.w	a2,s2
    800022f2:	85ce                	mv	a1,s3
    800022f4:	8552                	mv	a0,s4
    800022f6:	a63fe0ef          	jal	80000d58 <memmove>
    return 0;
    800022fa:	8526                	mv	a0,s1
    800022fc:	b7cd                	j	800022de <either_copyout+0x2a>

00000000800022fe <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800022fe:	7179                	addi	sp,sp,-48
    80002300:	f406                	sd	ra,40(sp)
    80002302:	f022                	sd	s0,32(sp)
    80002304:	ec26                	sd	s1,24(sp)
    80002306:	e84a                	sd	s2,16(sp)
    80002308:	e44e                	sd	s3,8(sp)
    8000230a:	e052                	sd	s4,0(sp)
    8000230c:	1800                	addi	s0,sp,48
    8000230e:	8a2a                	mv	s4,a0
    80002310:	84ae                	mv	s1,a1
    80002312:	89b2                	mv	s3,a2
    80002314:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002316:	e0cff0ef          	jal	80001922 <myproc>
  if(user_src){
    8000231a:	cc99                	beqz	s1,80002338 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000231c:	86ca                	mv	a3,s2
    8000231e:	864e                	mv	a2,s3
    80002320:	85d2                	mv	a1,s4
    80002322:	6d28                	ld	a0,88(a0)
    80002324:	beeff0ef          	jal	80001712 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002328:	70a2                	ld	ra,40(sp)
    8000232a:	7402                	ld	s0,32(sp)
    8000232c:	64e2                	ld	s1,24(sp)
    8000232e:	6942                	ld	s2,16(sp)
    80002330:	69a2                	ld	s3,8(sp)
    80002332:	6a02                	ld	s4,0(sp)
    80002334:	6145                	addi	sp,sp,48
    80002336:	8082                	ret
    memmove(dst, (char*)src, len);
    80002338:	0009061b          	sext.w	a2,s2
    8000233c:	85ce                	mv	a1,s3
    8000233e:	8552                	mv	a0,s4
    80002340:	a19fe0ef          	jal	80000d58 <memmove>
    return 0;
    80002344:	8526                	mv	a0,s1
    80002346:	b7cd                	j	80002328 <either_copyin+0x2a>

0000000080002348 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002348:	715d                	addi	sp,sp,-80
    8000234a:	e486                	sd	ra,72(sp)
    8000234c:	e0a2                	sd	s0,64(sp)
    8000234e:	fc26                	sd	s1,56(sp)
    80002350:	f84a                	sd	s2,48(sp)
    80002352:	f44e                	sd	s3,40(sp)
    80002354:	f052                	sd	s4,32(sp)
    80002356:	ec56                	sd	s5,24(sp)
    80002358:	e85a                	sd	s6,16(sp)
    8000235a:	e45e                	sd	s7,8(sp)
    8000235c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000235e:	00005517          	auipc	a0,0x5
    80002362:	d1a50513          	addi	a0,a0,-742 # 80007078 <etext+0x78>
    80002366:	994fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000236a:	0000e497          	auipc	s1,0xe
    8000236e:	b9e48493          	addi	s1,s1,-1122 # 8000ff08 <proc+0x160>
    80002372:	00014917          	auipc	s2,0x14
    80002376:	99690913          	addi	s2,s2,-1642 # 80015d08 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000237a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000237c:	00005997          	auipc	s3,0x5
    80002380:	e8498993          	addi	s3,s3,-380 # 80007200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    80002384:	00005a97          	auipc	s5,0x5
    80002388:	e84a8a93          	addi	s5,s5,-380 # 80007208 <etext+0x208>
    printf("\n");
    8000238c:	00005a17          	auipc	s4,0x5
    80002390:	ceca0a13          	addi	s4,s4,-788 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002394:	00005b97          	auipc	s7,0x5
    80002398:	394b8b93          	addi	s7,s7,916 # 80007728 <states.0>
    8000239c:	a829                	j	800023b6 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000239e:	ed06a583          	lw	a1,-304(a3)
    800023a2:	8556                	mv	a0,s5
    800023a4:	956fe0ef          	jal	800004fa <printf>
    printf("\n");
    800023a8:	8552                	mv	a0,s4
    800023aa:	950fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800023ae:	17848493          	addi	s1,s1,376
    800023b2:	03248263          	beq	s1,s2,800023d6 <procdump+0x8e>
    if(p->state == UNUSED)
    800023b6:	86a6                	mv	a3,s1
    800023b8:	eb84a783          	lw	a5,-328(s1)
    800023bc:	dbed                	beqz	a5,800023ae <procdump+0x66>
      state = "???";
    800023be:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023c0:	fcfb6fe3          	bltu	s6,a5,8000239e <procdump+0x56>
    800023c4:	02079713          	slli	a4,a5,0x20
    800023c8:	01d75793          	srli	a5,a4,0x1d
    800023cc:	97de                	add	a5,a5,s7
    800023ce:	6390                	ld	a2,0(a5)
    800023d0:	f679                	bnez	a2,8000239e <procdump+0x56>
      state = "???";
    800023d2:	864e                	mv	a2,s3
    800023d4:	b7e9                	j	8000239e <procdump+0x56>
  }
}
    800023d6:	60a6                	ld	ra,72(sp)
    800023d8:	6406                	ld	s0,64(sp)
    800023da:	74e2                	ld	s1,56(sp)
    800023dc:	7942                	ld	s2,48(sp)
    800023de:	79a2                	ld	s3,40(sp)
    800023e0:	7a02                	ld	s4,32(sp)
    800023e2:	6ae2                	ld	s5,24(sp)
    800023e4:	6b42                	ld	s6,16(sp)
    800023e6:	6ba2                	ld	s7,8(sp)
    800023e8:	6161                	addi	sp,sp,80
    800023ea:	8082                	ret

00000000800023ec <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800023ec:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800023f0:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800023f4:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800023f6:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800023f8:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800023fc:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002400:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002404:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002408:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000240c:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002410:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002414:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002418:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000241c:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002420:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002424:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002428:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000242a:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000242c:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002430:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002434:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002438:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    8000243c:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002440:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002444:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002448:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    8000244c:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002450:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002454:	8082                	ret

0000000080002456 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002456:	1141                	addi	sp,sp,-16
    80002458:	e406                	sd	ra,8(sp)
    8000245a:	e022                	sd	s0,0(sp)
    8000245c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000245e:	00005597          	auipc	a1,0x5
    80002462:	dea58593          	addi	a1,a1,-534 # 80007248 <etext+0x248>
    80002466:	00013517          	auipc	a0,0x13
    8000246a:	74250513          	addi	a0,a0,1858 # 80015ba8 <tickslock>
    8000246e:	f30fe0ef          	jal	80000b9e <initlock>
}
    80002472:	60a2                	ld	ra,8(sp)
    80002474:	6402                	ld	s0,0(sp)
    80002476:	0141                	addi	sp,sp,16
    80002478:	8082                	ret

000000008000247a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000247a:	1141                	addi	sp,sp,-16
    8000247c:	e406                	sd	ra,8(sp)
    8000247e:	e022                	sd	s0,0(sp)
    80002480:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002482:	00003797          	auipc	a5,0x3
    80002486:	17e78793          	addi	a5,a5,382 # 80005600 <kernelvec>
    8000248a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000248e:	60a2                	ld	ra,8(sp)
    80002490:	6402                	ld	s0,0(sp)
    80002492:	0141                	addi	sp,sp,16
    80002494:	8082                	ret

0000000080002496 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002496:	1141                	addi	sp,sp,-16
    80002498:	e406                	sd	ra,8(sp)
    8000249a:	e022                	sd	s0,0(sp)
    8000249c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000249e:	c84ff0ef          	jal	80001922 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024a2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800024a6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024a8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800024ac:	04000737          	lui	a4,0x4000
    800024b0:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800024b2:	0732                	slli	a4,a4,0xc
    800024b4:	00004797          	auipc	a5,0x4
    800024b8:	b4c78793          	addi	a5,a5,-1204 # 80006000 <_trampoline>
    800024bc:	00004697          	auipc	a3,0x4
    800024c0:	b4468693          	addi	a3,a3,-1212 # 80006000 <_trampoline>
    800024c4:	8f95                	sub	a5,a5,a3
    800024c6:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024c8:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800024cc:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800024ce:	18002773          	csrr	a4,satp
    800024d2:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800024d4:	7138                	ld	a4,96(a0)
    800024d6:	653c                	ld	a5,72(a0)
    800024d8:	6685                	lui	a3,0x1
    800024da:	97b6                	add	a5,a5,a3
    800024dc:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800024de:	713c                	ld	a5,96(a0)
    800024e0:	00000717          	auipc	a4,0x0
    800024e4:	0fc70713          	addi	a4,a4,252 # 800025dc <usertrap>
    800024e8:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800024ea:	713c                	ld	a5,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800024ec:	8712                	mv	a4,tp
    800024ee:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024f0:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800024f4:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800024f8:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024fc:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002500:	713c                	ld	a5,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002502:	6f9c                	ld	a5,24(a5)
    80002504:	14179073          	csrw	sepc,a5
}
    80002508:	60a2                	ld	ra,8(sp)
    8000250a:	6402                	ld	s0,0(sp)
    8000250c:	0141                	addi	sp,sp,16
    8000250e:	8082                	ret

0000000080002510 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002510:	1141                	addi	sp,sp,-16
    80002512:	e406                	sd	ra,8(sp)
    80002514:	e022                	sd	s0,0(sp)
    80002516:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80002518:	bd6ff0ef          	jal	800018ee <cpuid>
    8000251c:	cd11                	beqz	a0,80002538 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000251e:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002522:	000f4737          	lui	a4,0xf4
    80002526:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000252a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    8000252c:	14d79073          	csrw	stimecmp,a5
}
    80002530:	60a2                	ld	ra,8(sp)
    80002532:	6402                	ld	s0,0(sp)
    80002534:	0141                	addi	sp,sp,16
    80002536:	8082                	ret
    acquire(&tickslock);
    80002538:	00013517          	auipc	a0,0x13
    8000253c:	67050513          	addi	a0,a0,1648 # 80015ba8 <tickslock>
    80002540:	ee8fe0ef          	jal	80000c28 <acquire>
    ticks++;
    80002544:	00005717          	auipc	a4,0x5
    80002548:	33470713          	addi	a4,a4,820 # 80007878 <ticks>
    8000254c:	431c                	lw	a5,0(a4)
    8000254e:	2785                	addiw	a5,a5,1
    80002550:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002552:	853a                	mv	a0,a4
    80002554:	a53ff0ef          	jal	80001fa6 <wakeup>
    release(&tickslock);
    80002558:	00013517          	auipc	a0,0x13
    8000255c:	65050513          	addi	a0,a0,1616 # 80015ba8 <tickslock>
    80002560:	f5cfe0ef          	jal	80000cbc <release>
    80002564:	bf6d                	j	8000251e <clockintr+0xe>

0000000080002566 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002566:	1101                	addi	sp,sp,-32
    80002568:	ec06                	sd	ra,24(sp)
    8000256a:	e822                	sd	s0,16(sp)
    8000256c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000256e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002572:	57fd                	li	a5,-1
    80002574:	17fe                	slli	a5,a5,0x3f
    80002576:	07a5                	addi	a5,a5,9
    80002578:	00f70c63          	beq	a4,a5,80002590 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000257c:	57fd                	li	a5,-1
    8000257e:	17fe                	slli	a5,a5,0x3f
    80002580:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002582:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002584:	04f70863          	beq	a4,a5,800025d4 <devintr+0x6e>
  }
}
    80002588:	60e2                	ld	ra,24(sp)
    8000258a:	6442                	ld	s0,16(sp)
    8000258c:	6105                	addi	sp,sp,32
    8000258e:	8082                	ret
    80002590:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002592:	11a030ef          	jal	800056ac <plic_claim>
    80002596:	872a                	mv	a4,a0
    80002598:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000259a:	47a9                	li	a5,10
    8000259c:	00f50963          	beq	a0,a5,800025ae <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    800025a0:	4785                	li	a5,1
    800025a2:	00f50963          	beq	a0,a5,800025b4 <devintr+0x4e>
    return 1;
    800025a6:	4505                	li	a0,1
    } else if(irq){
    800025a8:	eb09                	bnez	a4,800025ba <devintr+0x54>
    800025aa:	64a2                	ld	s1,8(sp)
    800025ac:	bff1                	j	80002588 <devintr+0x22>
      uartintr();
    800025ae:	c46fe0ef          	jal	800009f4 <uartintr>
    if(irq)
    800025b2:	a819                	j	800025c8 <devintr+0x62>
      virtio_disk_intr();
    800025b4:	58e030ef          	jal	80005b42 <virtio_disk_intr>
    if(irq)
    800025b8:	a801                	j	800025c8 <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    800025ba:	85ba                	mv	a1,a4
    800025bc:	00005517          	auipc	a0,0x5
    800025c0:	c9450513          	addi	a0,a0,-876 # 80007250 <etext+0x250>
    800025c4:	f37fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    800025c8:	8526                	mv	a0,s1
    800025ca:	102030ef          	jal	800056cc <plic_complete>
    return 1;
    800025ce:	4505                	li	a0,1
    800025d0:	64a2                	ld	s1,8(sp)
    800025d2:	bf5d                	j	80002588 <devintr+0x22>
    clockintr();
    800025d4:	f3dff0ef          	jal	80002510 <clockintr>
    return 2;
    800025d8:	4509                	li	a0,2
    800025da:	b77d                	j	80002588 <devintr+0x22>

00000000800025dc <usertrap>:
{
    800025dc:	1101                	addi	sp,sp,-32
    800025de:	ec06                	sd	ra,24(sp)
    800025e0:	e822                	sd	s0,16(sp)
    800025e2:	e426                	sd	s1,8(sp)
    800025e4:	e04a                	sd	s2,0(sp)
    800025e6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025e8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800025ec:	1007f793          	andi	a5,a5,256
    800025f0:	eba5                	bnez	a5,80002660 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025f2:	00003797          	auipc	a5,0x3
    800025f6:	00e78793          	addi	a5,a5,14 # 80005600 <kernelvec>
    800025fa:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800025fe:	b24ff0ef          	jal	80001922 <myproc>
    80002602:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002604:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002606:	14102773          	csrr	a4,sepc
    8000260a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000260c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002610:	47a1                	li	a5,8
    80002612:	04f70d63          	beq	a4,a5,8000266c <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002616:	f51ff0ef          	jal	80002566 <devintr>
    8000261a:	892a                	mv	s2,a0
    8000261c:	e945                	bnez	a0,800026cc <usertrap+0xf0>
    8000261e:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002622:	47bd                	li	a5,15
    80002624:	08f70863          	beq	a4,a5,800026b4 <usertrap+0xd8>
    80002628:	14202773          	csrr	a4,scause
    8000262c:	47b5                	li	a5,13
    8000262e:	08f70363          	beq	a4,a5,800026b4 <usertrap+0xd8>
    80002632:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002636:	5890                	lw	a2,48(s1)
    80002638:	00005517          	auipc	a0,0x5
    8000263c:	c5850513          	addi	a0,a0,-936 # 80007290 <etext+0x290>
    80002640:	ebbfd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002644:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002648:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000264c:	00005517          	auipc	a0,0x5
    80002650:	c7450513          	addi	a0,a0,-908 # 800072c0 <etext+0x2c0>
    80002654:	ea7fd0ef          	jal	800004fa <printf>
    setkilled(p);
    80002658:	8526                	mv	a0,s1
    8000265a:	b19ff0ef          	jal	80002172 <setkilled>
    8000265e:	a035                	j	8000268a <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002660:	00005517          	auipc	a0,0x5
    80002664:	c1050513          	addi	a0,a0,-1008 # 80007270 <etext+0x270>
    80002668:	9bcfe0ef          	jal	80000824 <panic>
    if(killed(p))
    8000266c:	b2bff0ef          	jal	80002196 <killed>
    80002670:	ed15                	bnez	a0,800026ac <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002672:	70b8                	ld	a4,96(s1)
    80002674:	6f1c                	ld	a5,24(a4)
    80002676:	0791                	addi	a5,a5,4
    80002678:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000267a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000267e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002682:	10079073          	csrw	sstatus,a5
    syscall();
    80002686:	240000ef          	jal	800028c6 <syscall>
  if(killed(p))
    8000268a:	8526                	mv	a0,s1
    8000268c:	b0bff0ef          	jal	80002196 <killed>
    80002690:	e139                	bnez	a0,800026d6 <usertrap+0xfa>
  prepare_return();
    80002692:	e05ff0ef          	jal	80002496 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002696:	6ca8                	ld	a0,88(s1)
    80002698:	8131                	srli	a0,a0,0xc
    8000269a:	57fd                	li	a5,-1
    8000269c:	17fe                	slli	a5,a5,0x3f
    8000269e:	8d5d                	or	a0,a0,a5
}
    800026a0:	60e2                	ld	ra,24(sp)
    800026a2:	6442                	ld	s0,16(sp)
    800026a4:	64a2                	ld	s1,8(sp)
    800026a6:	6902                	ld	s2,0(sp)
    800026a8:	6105                	addi	sp,sp,32
    800026aa:	8082                	ret
      kexit(-1);
    800026ac:	557d                	li	a0,-1
    800026ae:	9b9ff0ef          	jal	80002066 <kexit>
    800026b2:	b7c1                	j	80002672 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026b4:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026b8:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    800026bc:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    800026be:	00163613          	seqz	a2,a2
    800026c2:	6ca8                	ld	a0,88(s1)
    800026c4:	f0dfe0ef          	jal	800015d0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800026c8:	f169                	bnez	a0,8000268a <usertrap+0xae>
    800026ca:	b7a5                	j	80002632 <usertrap+0x56>
  if(killed(p))
    800026cc:	8526                	mv	a0,s1
    800026ce:	ac9ff0ef          	jal	80002196 <killed>
    800026d2:	c511                	beqz	a0,800026de <usertrap+0x102>
    800026d4:	a011                	j	800026d8 <usertrap+0xfc>
    800026d6:	4901                	li	s2,0
    kexit(-1);
    800026d8:	557d                	li	a0,-1
    800026da:	98dff0ef          	jal	80002066 <kexit>
  if(which_dev == 2)
    800026de:	4789                	li	a5,2
    800026e0:	faf919e3          	bne	s2,a5,80002692 <usertrap+0xb6>
    yield();
    800026e4:	84bff0ef          	jal	80001f2e <yield>
    800026e8:	b76d                	j	80002692 <usertrap+0xb6>

00000000800026ea <kerneltrap>:
{
    800026ea:	7179                	addi	sp,sp,-48
    800026ec:	f406                	sd	ra,40(sp)
    800026ee:	f022                	sd	s0,32(sp)
    800026f0:	ec26                	sd	s1,24(sp)
    800026f2:	e84a                	sd	s2,16(sp)
    800026f4:	e44e                	sd	s3,8(sp)
    800026f6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026f8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026fc:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002700:	142027f3          	csrr	a5,scause
    80002704:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002706:	1004f793          	andi	a5,s1,256
    8000270a:	c795                	beqz	a5,80002736 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000270c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002710:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002712:	eb85                	bnez	a5,80002742 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    80002714:	e53ff0ef          	jal	80002566 <devintr>
    80002718:	c91d                	beqz	a0,8000274e <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    8000271a:	4789                	li	a5,2
    8000271c:	04f50a63          	beq	a0,a5,80002770 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002720:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002724:	10049073          	csrw	sstatus,s1
}
    80002728:	70a2                	ld	ra,40(sp)
    8000272a:	7402                	ld	s0,32(sp)
    8000272c:	64e2                	ld	s1,24(sp)
    8000272e:	6942                	ld	s2,16(sp)
    80002730:	69a2                	ld	s3,8(sp)
    80002732:	6145                	addi	sp,sp,48
    80002734:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002736:	00005517          	auipc	a0,0x5
    8000273a:	bb250513          	addi	a0,a0,-1102 # 800072e8 <etext+0x2e8>
    8000273e:	8e6fe0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    80002742:	00005517          	auipc	a0,0x5
    80002746:	bce50513          	addi	a0,a0,-1074 # 80007310 <etext+0x310>
    8000274a:	8dafe0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000274e:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002752:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002756:	85ce                	mv	a1,s3
    80002758:	00005517          	auipc	a0,0x5
    8000275c:	bd850513          	addi	a0,a0,-1064 # 80007330 <etext+0x330>
    80002760:	d9bfd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80002764:	00005517          	auipc	a0,0x5
    80002768:	bf450513          	addi	a0,a0,-1036 # 80007358 <etext+0x358>
    8000276c:	8b8fe0ef          	jal	80000824 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002770:	9b2ff0ef          	jal	80001922 <myproc>
    80002774:	d555                	beqz	a0,80002720 <kerneltrap+0x36>
    yield();
    80002776:	fb8ff0ef          	jal	80001f2e <yield>
    8000277a:	b75d                	j	80002720 <kerneltrap+0x36>

000000008000277c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000277c:	1101                	addi	sp,sp,-32
    8000277e:	ec06                	sd	ra,24(sp)
    80002780:	e822                	sd	s0,16(sp)
    80002782:	e426                	sd	s1,8(sp)
    80002784:	1000                	addi	s0,sp,32
    80002786:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002788:	99aff0ef          	jal	80001922 <myproc>
  switch (n) {
    8000278c:	4795                	li	a5,5
    8000278e:	0497e163          	bltu	a5,s1,800027d0 <argraw+0x54>
    80002792:	048a                	slli	s1,s1,0x2
    80002794:	00005717          	auipc	a4,0x5
    80002798:	fc470713          	addi	a4,a4,-60 # 80007758 <states.0+0x30>
    8000279c:	94ba                	add	s1,s1,a4
    8000279e:	409c                	lw	a5,0(s1)
    800027a0:	97ba                	add	a5,a5,a4
    800027a2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800027a4:	713c                	ld	a5,96(a0)
    800027a6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800027a8:	60e2                	ld	ra,24(sp)
    800027aa:	6442                	ld	s0,16(sp)
    800027ac:	64a2                	ld	s1,8(sp)
    800027ae:	6105                	addi	sp,sp,32
    800027b0:	8082                	ret
    return p->trapframe->a1;
    800027b2:	713c                	ld	a5,96(a0)
    800027b4:	7fa8                	ld	a0,120(a5)
    800027b6:	bfcd                	j	800027a8 <argraw+0x2c>
    return p->trapframe->a2;
    800027b8:	713c                	ld	a5,96(a0)
    800027ba:	63c8                	ld	a0,128(a5)
    800027bc:	b7f5                	j	800027a8 <argraw+0x2c>
    return p->trapframe->a3;
    800027be:	713c                	ld	a5,96(a0)
    800027c0:	67c8                	ld	a0,136(a5)
    800027c2:	b7dd                	j	800027a8 <argraw+0x2c>
    return p->trapframe->a4;
    800027c4:	713c                	ld	a5,96(a0)
    800027c6:	6bc8                	ld	a0,144(a5)
    800027c8:	b7c5                	j	800027a8 <argraw+0x2c>
    return p->trapframe->a5;
    800027ca:	713c                	ld	a5,96(a0)
    800027cc:	6fc8                	ld	a0,152(a5)
    800027ce:	bfe9                	j	800027a8 <argraw+0x2c>
  panic("argraw");
    800027d0:	00005517          	auipc	a0,0x5
    800027d4:	b9850513          	addi	a0,a0,-1128 # 80007368 <etext+0x368>
    800027d8:	84cfe0ef          	jal	80000824 <panic>

00000000800027dc <fetchaddr>:
{
    800027dc:	1101                	addi	sp,sp,-32
    800027de:	ec06                	sd	ra,24(sp)
    800027e0:	e822                	sd	s0,16(sp)
    800027e2:	e426                	sd	s1,8(sp)
    800027e4:	e04a                	sd	s2,0(sp)
    800027e6:	1000                	addi	s0,sp,32
    800027e8:	84aa                	mv	s1,a0
    800027ea:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800027ec:	936ff0ef          	jal	80001922 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800027f0:	693c                	ld	a5,80(a0)
    800027f2:	02f4f663          	bgeu	s1,a5,8000281e <fetchaddr+0x42>
    800027f6:	00848713          	addi	a4,s1,8
    800027fa:	02e7e463          	bltu	a5,a4,80002822 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800027fe:	46a1                	li	a3,8
    80002800:	8626                	mv	a2,s1
    80002802:	85ca                	mv	a1,s2
    80002804:	6d28                	ld	a0,88(a0)
    80002806:	f0dfe0ef          	jal	80001712 <copyin>
    8000280a:	00a03533          	snez	a0,a0
    8000280e:	40a0053b          	negw	a0,a0
}
    80002812:	60e2                	ld	ra,24(sp)
    80002814:	6442                	ld	s0,16(sp)
    80002816:	64a2                	ld	s1,8(sp)
    80002818:	6902                	ld	s2,0(sp)
    8000281a:	6105                	addi	sp,sp,32
    8000281c:	8082                	ret
    return -1;
    8000281e:	557d                	li	a0,-1
    80002820:	bfcd                	j	80002812 <fetchaddr+0x36>
    80002822:	557d                	li	a0,-1
    80002824:	b7fd                	j	80002812 <fetchaddr+0x36>

0000000080002826 <fetchstr>:
{
    80002826:	7179                	addi	sp,sp,-48
    80002828:	f406                	sd	ra,40(sp)
    8000282a:	f022                	sd	s0,32(sp)
    8000282c:	ec26                	sd	s1,24(sp)
    8000282e:	e84a                	sd	s2,16(sp)
    80002830:	e44e                	sd	s3,8(sp)
    80002832:	1800                	addi	s0,sp,48
    80002834:	89aa                	mv	s3,a0
    80002836:	84ae                	mv	s1,a1
    80002838:	8932                	mv	s2,a2
  struct proc *p = myproc();
    8000283a:	8e8ff0ef          	jal	80001922 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000283e:	86ca                	mv	a3,s2
    80002840:	864e                	mv	a2,s3
    80002842:	85a6                	mv	a1,s1
    80002844:	6d28                	ld	a0,88(a0)
    80002846:	cb3fe0ef          	jal	800014f8 <copyinstr>
    8000284a:	00054c63          	bltz	a0,80002862 <fetchstr+0x3c>
  return strlen(buf);
    8000284e:	8526                	mv	a0,s1
    80002850:	e32fe0ef          	jal	80000e82 <strlen>
}
    80002854:	70a2                	ld	ra,40(sp)
    80002856:	7402                	ld	s0,32(sp)
    80002858:	64e2                	ld	s1,24(sp)
    8000285a:	6942                	ld	s2,16(sp)
    8000285c:	69a2                	ld	s3,8(sp)
    8000285e:	6145                	addi	sp,sp,48
    80002860:	8082                	ret
    return -1;
    80002862:	557d                	li	a0,-1
    80002864:	bfc5                	j	80002854 <fetchstr+0x2e>

0000000080002866 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002866:	1101                	addi	sp,sp,-32
    80002868:	ec06                	sd	ra,24(sp)
    8000286a:	e822                	sd	s0,16(sp)
    8000286c:	e426                	sd	s1,8(sp)
    8000286e:	1000                	addi	s0,sp,32
    80002870:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002872:	f0bff0ef          	jal	8000277c <argraw>
    80002876:	c088                	sw	a0,0(s1)
}
    80002878:	60e2                	ld	ra,24(sp)
    8000287a:	6442                	ld	s0,16(sp)
    8000287c:	64a2                	ld	s1,8(sp)
    8000287e:	6105                	addi	sp,sp,32
    80002880:	8082                	ret

0000000080002882 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002882:	1101                	addi	sp,sp,-32
    80002884:	ec06                	sd	ra,24(sp)
    80002886:	e822                	sd	s0,16(sp)
    80002888:	e426                	sd	s1,8(sp)
    8000288a:	1000                	addi	s0,sp,32
    8000288c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000288e:	eefff0ef          	jal	8000277c <argraw>
    80002892:	e088                	sd	a0,0(s1)
}
    80002894:	60e2                	ld	ra,24(sp)
    80002896:	6442                	ld	s0,16(sp)
    80002898:	64a2                	ld	s1,8(sp)
    8000289a:	6105                	addi	sp,sp,32
    8000289c:	8082                	ret

000000008000289e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000289e:	1101                	addi	sp,sp,-32
    800028a0:	ec06                	sd	ra,24(sp)
    800028a2:	e822                	sd	s0,16(sp)
    800028a4:	e426                	sd	s1,8(sp)
    800028a6:	e04a                	sd	s2,0(sp)
    800028a8:	1000                	addi	s0,sp,32
    800028aa:	892e                	mv	s2,a1
    800028ac:	84b2                	mv	s1,a2
  *ip = argraw(n);
    800028ae:	ecfff0ef          	jal	8000277c <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    800028b2:	8626                	mv	a2,s1
    800028b4:	85ca                	mv	a1,s2
    800028b6:	f71ff0ef          	jal	80002826 <fetchstr>
}
    800028ba:	60e2                	ld	ra,24(sp)
    800028bc:	6442                	ld	s0,16(sp)
    800028be:	64a2                	ld	s1,8(sp)
    800028c0:	6902                	ld	s2,0(sp)
    800028c2:	6105                	addi	sp,sp,32
    800028c4:	8082                	ret

00000000800028c6 <syscall>:
[SYS_thread_join] sys_thread_join,
};

void
syscall(void)
{
    800028c6:	1101                	addi	sp,sp,-32
    800028c8:	ec06                	sd	ra,24(sp)
    800028ca:	e822                	sd	s0,16(sp)
    800028cc:	e426                	sd	s1,8(sp)
    800028ce:	e04a                	sd	s2,0(sp)
    800028d0:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800028d2:	850ff0ef          	jal	80001922 <myproc>
    800028d6:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800028d8:	06053903          	ld	s2,96(a0)
    800028dc:	0a893783          	ld	a5,168(s2)
    800028e0:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800028e4:	37fd                	addiw	a5,a5,-1
    800028e6:	4761                	li	a4,24
    800028e8:	00f76f63          	bltu	a4,a5,80002906 <syscall+0x40>
    800028ec:	00369713          	slli	a4,a3,0x3
    800028f0:	00005797          	auipc	a5,0x5
    800028f4:	e8078793          	addi	a5,a5,-384 # 80007770 <syscalls>
    800028f8:	97ba                	add	a5,a5,a4
    800028fa:	639c                	ld	a5,0(a5)
    800028fc:	c789                	beqz	a5,80002906 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800028fe:	9782                	jalr	a5
    80002900:	06a93823          	sd	a0,112(s2)
    80002904:	a829                	j	8000291e <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002906:	16048613          	addi	a2,s1,352
    8000290a:	588c                	lw	a1,48(s1)
    8000290c:	00005517          	auipc	a0,0x5
    80002910:	a6450513          	addi	a0,a0,-1436 # 80007370 <etext+0x370>
    80002914:	be7fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002918:	70bc                	ld	a5,96(s1)
    8000291a:	577d                	li	a4,-1
    8000291c:	fbb8                	sd	a4,112(a5)
  }
}
    8000291e:	60e2                	ld	ra,24(sp)
    80002920:	6442                	ld	s0,16(sp)
    80002922:	64a2                	ld	s1,8(sp)
    80002924:	6902                	ld	s2,0(sp)
    80002926:	6105                	addi	sp,sp,32
    80002928:	8082                	ret

000000008000292a <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    8000292a:	1101                	addi	sp,sp,-32
    8000292c:	ec06                	sd	ra,24(sp)
    8000292e:	e822                	sd	s0,16(sp)
    80002930:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002932:	fec40593          	addi	a1,s0,-20
    80002936:	4501                	li	a0,0
    80002938:	f2fff0ef          	jal	80002866 <argint>
  kexit(n);
    8000293c:	fec42503          	lw	a0,-20(s0)
    80002940:	f26ff0ef          	jal	80002066 <kexit>
  return 0;  // not reached
}
    80002944:	4501                	li	a0,0
    80002946:	60e2                	ld	ra,24(sp)
    80002948:	6442                	ld	s0,16(sp)
    8000294a:	6105                	addi	sp,sp,32
    8000294c:	8082                	ret

000000008000294e <sys_getpid>:

uint64
sys_getpid(void)
{
    8000294e:	1141                	addi	sp,sp,-16
    80002950:	e406                	sd	ra,8(sp)
    80002952:	e022                	sd	s0,0(sp)
    80002954:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002956:	fcdfe0ef          	jal	80001922 <myproc>
}
    8000295a:	5908                	lw	a0,48(a0)
    8000295c:	60a2                	ld	ra,8(sp)
    8000295e:	6402                	ld	s0,0(sp)
    80002960:	0141                	addi	sp,sp,16
    80002962:	8082                	ret

0000000080002964 <sys_fork>:

uint64
sys_fork(void)
{
    80002964:	1141                	addi	sp,sp,-16
    80002966:	e406                	sd	ra,8(sp)
    80002968:	e022                	sd	s0,0(sp)
    8000296a:	0800                	addi	s0,sp,16
  return kfork();
    8000296c:	b46ff0ef          	jal	80001cb2 <kfork>
}
    80002970:	60a2                	ld	ra,8(sp)
    80002972:	6402                	ld	s0,0(sp)
    80002974:	0141                	addi	sp,sp,16
    80002976:	8082                	ret

0000000080002978 <sys_wait>:

uint64
sys_wait(void)
{
    80002978:	1101                	addi	sp,sp,-32
    8000297a:	ec06                	sd	ra,24(sp)
    8000297c:	e822                	sd	s0,16(sp)
    8000297e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002980:	fe840593          	addi	a1,s0,-24
    80002984:	4501                	li	a0,0
    80002986:	efdff0ef          	jal	80002882 <argaddr>
  return kwait(p);
    8000298a:	fe843503          	ld	a0,-24(s0)
    8000298e:	833ff0ef          	jal	800021c0 <kwait>
}
    80002992:	60e2                	ld	ra,24(sp)
    80002994:	6442                	ld	s0,16(sp)
    80002996:	6105                	addi	sp,sp,32
    80002998:	8082                	ret

000000008000299a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000299a:	7179                	addi	sp,sp,-48
    8000299c:	f406                	sd	ra,40(sp)
    8000299e:	f022                	sd	s0,32(sp)
    800029a0:	ec26                	sd	s1,24(sp)
    800029a2:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800029a4:	fd840593          	addi	a1,s0,-40
    800029a8:	4501                	li	a0,0
    800029aa:	ebdff0ef          	jal	80002866 <argint>
  argint(1, &t);
    800029ae:	fdc40593          	addi	a1,s0,-36
    800029b2:	4505                	li	a0,1
    800029b4:	eb3ff0ef          	jal	80002866 <argint>
  addr = myproc()->sz;
    800029b8:	f6bfe0ef          	jal	80001922 <myproc>
    800029bc:	6924                	ld	s1,80(a0)

  if(t == SBRK_EAGER || n < 0) {
    800029be:	fdc42703          	lw	a4,-36(s0)
    800029c2:	4785                	li	a5,1
    800029c4:	02f70763          	beq	a4,a5,800029f2 <sys_sbrk+0x58>
    800029c8:	fd842783          	lw	a5,-40(s0)
    800029cc:	0207c363          	bltz	a5,800029f2 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    800029d0:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    800029d2:	02000737          	lui	a4,0x2000
    800029d6:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    800029d8:	0736                	slli	a4,a4,0xd
    800029da:	02f76a63          	bltu	a4,a5,80002a0e <sys_sbrk+0x74>
    800029de:	0297e863          	bltu	a5,s1,80002a0e <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    800029e2:	f41fe0ef          	jal	80001922 <myproc>
    800029e6:	fd842703          	lw	a4,-40(s0)
    800029ea:	693c                	ld	a5,80(a0)
    800029ec:	97ba                	add	a5,a5,a4
    800029ee:	e93c                	sd	a5,80(a0)
    800029f0:	a039                	j	800029fe <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    800029f2:	fd842503          	lw	a0,-40(s0)
    800029f6:	a5aff0ef          	jal	80001c50 <growproc>
    800029fa:	00054863          	bltz	a0,80002a0a <sys_sbrk+0x70>
  }
  return addr;
}
    800029fe:	8526                	mv	a0,s1
    80002a00:	70a2                	ld	ra,40(sp)
    80002a02:	7402                	ld	s0,32(sp)
    80002a04:	64e2                	ld	s1,24(sp)
    80002a06:	6145                	addi	sp,sp,48
    80002a08:	8082                	ret
      return -1;
    80002a0a:	54fd                	li	s1,-1
    80002a0c:	bfcd                	j	800029fe <sys_sbrk+0x64>
      return -1;
    80002a0e:	54fd                	li	s1,-1
    80002a10:	b7fd                	j	800029fe <sys_sbrk+0x64>

0000000080002a12 <sys_pause>:

uint64
sys_pause(void)
{
    80002a12:	7139                	addi	sp,sp,-64
    80002a14:	fc06                	sd	ra,56(sp)
    80002a16:	f822                	sd	s0,48(sp)
    80002a18:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a1a:	fcc40593          	addi	a1,s0,-52
    80002a1e:	4501                	li	a0,0
    80002a20:	e47ff0ef          	jal	80002866 <argint>
  if(n < 0)
    80002a24:	fcc42783          	lw	a5,-52(s0)
    80002a28:	0607c863          	bltz	a5,80002a98 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002a2c:	00013517          	auipc	a0,0x13
    80002a30:	17c50513          	addi	a0,a0,380 # 80015ba8 <tickslock>
    80002a34:	9f4fe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002a38:	fcc42783          	lw	a5,-52(s0)
    80002a3c:	c3b9                	beqz	a5,80002a82 <sys_pause+0x70>
    80002a3e:	f426                	sd	s1,40(sp)
    80002a40:	f04a                	sd	s2,32(sp)
    80002a42:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002a44:	00005997          	auipc	s3,0x5
    80002a48:	e349a983          	lw	s3,-460(s3) # 80007878 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a4c:	00013917          	auipc	s2,0x13
    80002a50:	15c90913          	addi	s2,s2,348 # 80015ba8 <tickslock>
    80002a54:	00005497          	auipc	s1,0x5
    80002a58:	e2448493          	addi	s1,s1,-476 # 80007878 <ticks>
    if(killed(myproc())){
    80002a5c:	ec7fe0ef          	jal	80001922 <myproc>
    80002a60:	f36ff0ef          	jal	80002196 <killed>
    80002a64:	ed0d                	bnez	a0,80002a9e <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002a66:	85ca                	mv	a1,s2
    80002a68:	8526                	mv	a0,s1
    80002a6a:	cf0ff0ef          	jal	80001f5a <sleep>
  while(ticks - ticks0 < n){
    80002a6e:	409c                	lw	a5,0(s1)
    80002a70:	413787bb          	subw	a5,a5,s3
    80002a74:	fcc42703          	lw	a4,-52(s0)
    80002a78:	fee7e2e3          	bltu	a5,a4,80002a5c <sys_pause+0x4a>
    80002a7c:	74a2                	ld	s1,40(sp)
    80002a7e:	7902                	ld	s2,32(sp)
    80002a80:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a82:	00013517          	auipc	a0,0x13
    80002a86:	12650513          	addi	a0,a0,294 # 80015ba8 <tickslock>
    80002a8a:	a32fe0ef          	jal	80000cbc <release>
  return 0;
    80002a8e:	4501                	li	a0,0
}
    80002a90:	70e2                	ld	ra,56(sp)
    80002a92:	7442                	ld	s0,48(sp)
    80002a94:	6121                	addi	sp,sp,64
    80002a96:	8082                	ret
    n = 0;
    80002a98:	fc042623          	sw	zero,-52(s0)
    80002a9c:	bf41                	j	80002a2c <sys_pause+0x1a>
      release(&tickslock);
    80002a9e:	00013517          	auipc	a0,0x13
    80002aa2:	10a50513          	addi	a0,a0,266 # 80015ba8 <tickslock>
    80002aa6:	a16fe0ef          	jal	80000cbc <release>
      return -1;
    80002aaa:	557d                	li	a0,-1
    80002aac:	74a2                	ld	s1,40(sp)
    80002aae:	7902                	ld	s2,32(sp)
    80002ab0:	69e2                	ld	s3,24(sp)
    80002ab2:	bff9                	j	80002a90 <sys_pause+0x7e>

0000000080002ab4 <sys_kill>:

uint64
sys_kill(void)
{
    80002ab4:	1101                	addi	sp,sp,-32
    80002ab6:	ec06                	sd	ra,24(sp)
    80002ab8:	e822                	sd	s0,16(sp)
    80002aba:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002abc:	fec40593          	addi	a1,s0,-20
    80002ac0:	4501                	li	a0,0
    80002ac2:	da5ff0ef          	jal	80002866 <argint>
  return kkill(pid);
    80002ac6:	fec42503          	lw	a0,-20(s0)
    80002aca:	e42ff0ef          	jal	8000210c <kkill>
}
    80002ace:	60e2                	ld	ra,24(sp)
    80002ad0:	6442                	ld	s0,16(sp)
    80002ad2:	6105                	addi	sp,sp,32
    80002ad4:	8082                	ret

0000000080002ad6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ad6:	1101                	addi	sp,sp,-32
    80002ad8:	ec06                	sd	ra,24(sp)
    80002ada:	e822                	sd	s0,16(sp)
    80002adc:	e426                	sd	s1,8(sp)
    80002ade:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ae0:	00013517          	auipc	a0,0x13
    80002ae4:	0c850513          	addi	a0,a0,200 # 80015ba8 <tickslock>
    80002ae8:	940fe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002aec:	00005797          	auipc	a5,0x5
    80002af0:	d8c7a783          	lw	a5,-628(a5) # 80007878 <ticks>
    80002af4:	84be                	mv	s1,a5
  release(&tickslock);
    80002af6:	00013517          	auipc	a0,0x13
    80002afa:	0b250513          	addi	a0,a0,178 # 80015ba8 <tickslock>
    80002afe:	9befe0ef          	jal	80000cbc <release>
  return xticks;
}
    80002b02:	02049513          	slli	a0,s1,0x20
    80002b06:	9101                	srli	a0,a0,0x20
    80002b08:	60e2                	ld	ra,24(sp)
    80002b0a:	6442                	ld	s0,16(sp)
    80002b0c:	64a2                	ld	s1,8(sp)
    80002b0e:	6105                	addi	sp,sp,32
    80002b10:	8082                	ret

0000000080002b12 <sys_getprocinfo>:

uint64
sys_getprocinfo(void)
{
    80002b12:	1101                	addi	sp,sp,-32
    80002b14:	ec06                	sd	ra,24(sp)
    80002b16:	e822                	sd	s0,16(sp)
    80002b18:	e426                	sd	s1,8(sp)
    80002b1a:	e04a                	sd	s2,0(sp)
    80002b1c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002b1e:	e05fe0ef          	jal	80001922 <myproc>
    80002b22:	84aa                	mv	s1,a0
  uint64 pid_addr  = p->trapframe->a0;
    80002b24:	713c                	ld	a5,96(a0)
  uint64 prio_addr = p->trapframe->a1;
    80002b26:	0787b903          	ld	s2,120(a5)

  if(copyout(p->pagetable, pid_addr,
    80002b2a:	4691                	li	a3,4
    80002b2c:	03050613          	addi	a2,a0,48
    80002b30:	7bac                	ld	a1,112(a5)
    80002b32:	6d28                	ld	a0,88(a0)
    80002b34:	b21fe0ef          	jal	80001654 <copyout>
    80002b38:	87aa                	mv	a5,a0
             (char*)&p->pid, sizeof(p->pid)) < 0)
    return -1;
    80002b3a:	557d                	li	a0,-1
  if(copyout(p->pagetable, pid_addr,
    80002b3c:	0007ca63          	bltz	a5,80002b50 <sys_getprocinfo+0x3e>
  if(copyout(p->pagetable, prio_addr,
    80002b40:	4691                	li	a3,4
    80002b42:	17048613          	addi	a2,s1,368
    80002b46:	85ca                	mv	a1,s2
    80002b48:	6ca8                	ld	a0,88(s1)
    80002b4a:	b0bfe0ef          	jal	80001654 <copyout>
    80002b4e:	957d                	srai	a0,a0,0x3f
             (char*)&p->priority, sizeof(p->priority)) < 0)
    return -1;
  return 0;
}
    80002b50:	60e2                	ld	ra,24(sp)
    80002b52:	6442                	ld	s0,16(sp)
    80002b54:	64a2                	ld	s1,8(sp)
    80002b56:	6902                	ld	s2,0(sp)
    80002b58:	6105                	addi	sp,sp,32
    80002b5a:	8082                	ret

0000000080002b5c <sys_setpriority>:

uint64
sys_setpriority(void)
{
    80002b5c:	1141                	addi	sp,sp,-16
    80002b5e:	e406                	sd	ra,8(sp)
    80002b60:	e022                	sd	s0,0(sp)
    80002b62:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b64:	dbffe0ef          	jal	80001922 <myproc>
    80002b68:	87aa                	mv	a5,a0
  int prio = (int)p->trapframe->a0;
    80002b6a:	7138                	ld	a4,96(a0)
    80002b6c:	7b38                	ld	a4,112(a4)
  if(prio < 0 || prio > 19)
    80002b6e:	0007061b          	sext.w	a2,a4
    80002b72:	46cd                	li	a3,19
    return -1;
    80002b74:	557d                	li	a0,-1
  if(prio < 0 || prio > 19)
    80002b76:	00c6e563          	bltu	a3,a2,80002b80 <sys_setpriority+0x24>
  int prio = (int)p->trapframe->a0;
    80002b7a:	16e7a823          	sw	a4,368(a5)
  p->priority = prio;
  return 0;
    80002b7e:	4501                	li	a0,0
}
    80002b80:	60a2                	ld	ra,8(sp)
    80002b82:	6402                	ld	s0,0(sp)
    80002b84:	0141                	addi	sp,sp,16
    80002b86:	8082                	ret

0000000080002b88 <sys_thread_create>:
#include "spinlock.h" 
#include "proc.h"

extern struct proc proc[NPROC];

uint64 sys_thread_create(void){
    80002b88:	7139                	addi	sp,sp,-64
    80002b8a:	fc06                	sd	ra,56(sp)
    80002b8c:	f822                	sd	s0,48(sp)
    80002b8e:	f426                	sd	s1,40(sp)
    80002b90:	f04a                	sd	s2,32(sp)
    80002b92:	e456                	sd	s5,8(sp)
    80002b94:	0080                	addi	s0,sp,64
    struct proc *parent = myproc();
    80002b96:	d8dfe0ef          	jal	80001922 <myproc>
    80002b9a:	8aaa                	mv	s5,a0

    uint64 fn = parent->trapframe->a0;
    80002b9c:	713c                	ld	a5,96(a0)
    80002b9e:	7ba4                	ld	s1,112(a5)
    uint64 arg = parent->trapframe->a1;
    80002ba0:	0787b903          	ld	s2,120(a5)

    struct proc *np;

    if((np = kallocproc()) ==0){
    80002ba4:	848ff0ef          	jal	80001bec <kallocproc>
    80002ba8:	c955                	beqz	a0,80002c5c <sys_thread_create+0xd4>
    80002baa:	ec4e                	sd	s3,24(sp)
    80002bac:	e852                	sd	s4,16(sp)
    80002bae:	8a2a                	mv	s4,a0
        return -1;
    }

    np->pagetable = parent->pagetable;
    80002bb0:	058ab783          	ld	a5,88(s5)
    80002bb4:	ed3c                	sd	a5,88(a0)
    np->sz = parent->sz;
    80002bb6:	050ab783          	ld	a5,80(s5)
    80002bba:	e93c                	sd	a5,80(a0)

    np->is_thread = 1;
    80002bbc:	4785                	li	a5,1
    80002bbe:	d95c                	sw	a5,52(a0)
    np->thread_parent = parent->pid;
    80002bc0:	030aa783          	lw	a5,48(s5)
    80002bc4:	dd1c                	sw	a5,56(a0)

    *(np->trapframe) = *(parent->trapframe);
    80002bc6:	060ab683          	ld	a3,96(s5)
    80002bca:	87b6                	mv	a5,a3
    80002bcc:	7138                	ld	a4,96(a0)
    80002bce:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    80002bd2:	6388                	ld	a0,0(a5)
    80002bd4:	678c                	ld	a1,8(a5)
    80002bd6:	6b90                	ld	a2,16(a5)
    80002bd8:	e308                	sd	a0,0(a4)
    80002bda:	e70c                	sd	a1,8(a4)
    80002bdc:	eb10                	sd	a2,16(a4)
    80002bde:	6f90                	ld	a2,24(a5)
    80002be0:	ef10                	sd	a2,24(a4)
    80002be2:	02078793          	addi	a5,a5,32
    80002be6:	02070713          	addi	a4,a4,32
    80002bea:	fed794e3          	bne	a5,a3,80002bd2 <sys_thread_create+0x4a>
    np->trapframe->epc = fn;   // thread entry point (RISC-V: epc not eip)
    80002bee:	060a3783          	ld	a5,96(s4)
    80002bf2:	ef84                	sd	s1,24(a5)
    np->trapframe->a0  = arg;  // argument passed in register a0
    80002bf4:	060a3783          	ld	a5,96(s4)
    80002bf8:	0727b823          	sd	s2,112(a5)

    // Inherit open files and working directory from parent
    for (int i = 0; i < NOFILE; i++)
    80002bfc:	0d8a8493          	addi	s1,s5,216
    80002c00:	0d8a0913          	addi	s2,s4,216
    80002c04:	158a8993          	addi	s3,s5,344
    80002c08:	a029                	j	80002c12 <sys_thread_create+0x8a>
    80002c0a:	04a1                	addi	s1,s1,8
    80002c0c:	0921                	addi	s2,s2,8
    80002c0e:	01348963          	beq	s1,s3,80002c20 <sys_thread_create+0x98>
        if (parent->ofile[i])
    80002c12:	6088                	ld	a0,0(s1)
    80002c14:	d97d                	beqz	a0,80002c0a <sys_thread_create+0x82>
            np->ofile[i] = filedup(parent->ofile[i]);
    80002c16:	5e0010ef          	jal	800041f6 <filedup>
    80002c1a:	00a93023          	sd	a0,0(s2)
    80002c1e:	b7f5                	j	80002c0a <sys_thread_create+0x82>
    np->cwd = idup(parent->cwd);
    80002c20:	158ab503          	ld	a0,344(s5)
    80002c24:	7b2000ef          	jal	800033d6 <idup>
    80002c28:	14aa3c23          	sd	a0,344(s4)

    safestrcpy(np->name, parent->name, sizeof(parent->name));
    80002c2c:	4641                	li	a2,16
    80002c2e:	160a8593          	addi	a1,s5,352
    80002c32:	160a0513          	addi	a0,s4,352
    80002c36:	a16fe0ef          	jal	80000e4c <safestrcpy>

    // kallocproc() returns with np->lock held.
    np->state = RUNNABLE;
    80002c3a:	478d                	li	a5,3
    80002c3c:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    80002c40:	8552                	mv	a0,s4
    80002c42:	87afe0ef          	jal	80000cbc <release>

    return np->pid;  // return tid to caller
    80002c46:	030a2503          	lw	a0,48(s4)
    80002c4a:	69e2                	ld	s3,24(sp)
    80002c4c:	6a42                	ld	s4,16(sp)
}
    80002c4e:	70e2                	ld	ra,56(sp)
    80002c50:	7442                	ld	s0,48(sp)
    80002c52:	74a2                	ld	s1,40(sp)
    80002c54:	7902                	ld	s2,32(sp)
    80002c56:	6aa2                	ld	s5,8(sp)
    80002c58:	6121                	addi	sp,sp,64
    80002c5a:	8082                	ret
        return -1;
    80002c5c:	557d                	li	a0,-1
    80002c5e:	bfc5                	j	80002c4e <sys_thread_create+0xc6>

0000000080002c60 <sys_thread_join>:

uint64
sys_thread_join(void)
{
    80002c60:	7139                	addi	sp,sp,-64
    80002c62:	fc06                	sd	ra,56(sp)
    80002c64:	f822                	sd	s0,48(sp)
    80002c66:	f426                	sd	s1,40(sp)
    80002c68:	f04a                	sd	s2,32(sp)
    80002c6a:	ec4e                	sd	s3,24(sp)
    80002c6c:	e852                	sd	s4,16(sp)
    80002c6e:	e456                	sd	s5,8(sp)
    80002c70:	e05a                	sd	s6,0(sp)
    80002c72:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002c74:	caffe0ef          	jal	80001922 <myproc>

  // Read tid from trapframe register a0
  int tid = (int)p->trapframe->a0;
    80002c78:	713c                	ld	a5,96(a0)
    80002c7a:	0707a903          	lw	s2,112(a5)
      acquire(&target->lock);

      if (target->pid == tid && target->is_thread) {
        found = 1;

        if (target->state == ZOMBIE) {
    80002c7e:	4a95                	li	s5,5
        found = 1;
    80002c80:	4b05                	li	s6,1
    for (target = proc; target < &proc[NPROC]; target++) {
    80002c82:	00013997          	auipc	s3,0x13
    80002c86:	f2698993          	addi	s3,s3,-218 # 80015ba8 <tickslock>
    found = 0;
    80002c8a:	4a01                	li	s4,0
    for (target = proc; target < &proc[NPROC]; target++) {
    80002c8c:	0000d497          	auipc	s1,0xd
    80002c90:	11c48493          	addi	s1,s1,284 # 8000fda8 <proc>
    80002c94:	a80d                	j	80002cc6 <sys_thread_join+0x66>
          // Thread finished — reap it
          kfreeproc(target);         // frees kstack, trapframe, etc.
    80002c96:	8526                	mv	a0,s1
    80002c98:	f69fe0ef          	jal	80001c00 <kfreeproc>
          release(&target->lock);
    80002c9c:	8526                	mv	a0,s1
    80002c9e:	81efe0ef          	jal	80000cbc <release>
          return 0;
    80002ca2:	4501                	li	a0,0
      return -1;  // no thread with that TID exists

    // Thread exists but hasn't exited yet — yield and retry
    yield();
  }
    80002ca4:	70e2                	ld	ra,56(sp)
    80002ca6:	7442                	ld	s0,48(sp)
    80002ca8:	74a2                	ld	s1,40(sp)
    80002caa:	7902                	ld	s2,32(sp)
    80002cac:	69e2                	ld	s3,24(sp)
    80002cae:	6a42                	ld	s4,16(sp)
    80002cb0:	6aa2                	ld	s5,8(sp)
    80002cb2:	6b02                	ld	s6,0(sp)
    80002cb4:	6121                	addi	sp,sp,64
    80002cb6:	8082                	ret
      release(&target->lock);
    80002cb8:	8526                	mv	a0,s1
    80002cba:	802fe0ef          	jal	80000cbc <release>
    for (target = proc; target < &proc[NPROC]; target++) {
    80002cbe:	17848493          	addi	s1,s1,376
    80002cc2:	01348f63          	beq	s1,s3,80002ce0 <sys_thread_join+0x80>
      acquire(&target->lock);
    80002cc6:	8526                	mv	a0,s1
    80002cc8:	f61fd0ef          	jal	80000c28 <acquire>
      if (target->pid == tid && target->is_thread) {
    80002ccc:	589c                	lw	a5,48(s1)
    80002cce:	ff2795e3          	bne	a5,s2,80002cb8 <sys_thread_join+0x58>
    80002cd2:	58dc                	lw	a5,52(s1)
    80002cd4:	d3f5                	beqz	a5,80002cb8 <sys_thread_join+0x58>
        if (target->state == ZOMBIE) {
    80002cd6:	4c9c                	lw	a5,24(s1)
    80002cd8:	fb578fe3          	beq	a5,s5,80002c96 <sys_thread_join+0x36>
        found = 1;
    80002cdc:	8a5a                	mv	s4,s6
    80002cde:	bfe9                	j	80002cb8 <sys_thread_join+0x58>
    if (!found)
    80002ce0:	000a0563          	beqz	s4,80002cea <sys_thread_join+0x8a>
    yield();
    80002ce4:	a4aff0ef          	jal	80001f2e <yield>
    found = 0;
    80002ce8:	b74d                	j	80002c8a <sys_thread_join+0x2a>
      return -1;  // no thread with that TID exists
    80002cea:	557d                	li	a0,-1
    80002cec:	bf65                	j	80002ca4 <sys_thread_join+0x44>

0000000080002cee <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002cee:	7179                	addi	sp,sp,-48
    80002cf0:	f406                	sd	ra,40(sp)
    80002cf2:	f022                	sd	s0,32(sp)
    80002cf4:	ec26                	sd	s1,24(sp)
    80002cf6:	e84a                	sd	s2,16(sp)
    80002cf8:	e44e                	sd	s3,8(sp)
    80002cfa:	e052                	sd	s4,0(sp)
    80002cfc:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002cfe:	00004597          	auipc	a1,0x4
    80002d02:	69258593          	addi	a1,a1,1682 # 80007390 <etext+0x390>
    80002d06:	00013517          	auipc	a0,0x13
    80002d0a:	eba50513          	addi	a0,a0,-326 # 80015bc0 <bcache>
    80002d0e:	e91fd0ef          	jal	80000b9e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002d12:	0001b797          	auipc	a5,0x1b
    80002d16:	eae78793          	addi	a5,a5,-338 # 8001dbc0 <bcache+0x8000>
    80002d1a:	0001b717          	auipc	a4,0x1b
    80002d1e:	10e70713          	addi	a4,a4,270 # 8001de28 <bcache+0x8268>
    80002d22:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002d26:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d2a:	00013497          	auipc	s1,0x13
    80002d2e:	eae48493          	addi	s1,s1,-338 # 80015bd8 <bcache+0x18>
    b->next = bcache.head.next;
    80002d32:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002d34:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002d36:	00004a17          	auipc	s4,0x4
    80002d3a:	662a0a13          	addi	s4,s4,1634 # 80007398 <etext+0x398>
    b->next = bcache.head.next;
    80002d3e:	2b893783          	ld	a5,696(s2)
    80002d42:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d44:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d48:	85d2                	mv	a1,s4
    80002d4a:	01048513          	addi	a0,s1,16
    80002d4e:	328010ef          	jal	80004076 <initsleeplock>
    bcache.head.next->prev = b;
    80002d52:	2b893783          	ld	a5,696(s2)
    80002d56:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d58:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d5c:	45848493          	addi	s1,s1,1112
    80002d60:	fd349fe3          	bne	s1,s3,80002d3e <binit+0x50>
  }
}
    80002d64:	70a2                	ld	ra,40(sp)
    80002d66:	7402                	ld	s0,32(sp)
    80002d68:	64e2                	ld	s1,24(sp)
    80002d6a:	6942                	ld	s2,16(sp)
    80002d6c:	69a2                	ld	s3,8(sp)
    80002d6e:	6a02                	ld	s4,0(sp)
    80002d70:	6145                	addi	sp,sp,48
    80002d72:	8082                	ret

0000000080002d74 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002d74:	7179                	addi	sp,sp,-48
    80002d76:	f406                	sd	ra,40(sp)
    80002d78:	f022                	sd	s0,32(sp)
    80002d7a:	ec26                	sd	s1,24(sp)
    80002d7c:	e84a                	sd	s2,16(sp)
    80002d7e:	e44e                	sd	s3,8(sp)
    80002d80:	1800                	addi	s0,sp,48
    80002d82:	892a                	mv	s2,a0
    80002d84:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002d86:	00013517          	auipc	a0,0x13
    80002d8a:	e3a50513          	addi	a0,a0,-454 # 80015bc0 <bcache>
    80002d8e:	e9bfd0ef          	jal	80000c28 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002d92:	0001b497          	auipc	s1,0x1b
    80002d96:	0e64b483          	ld	s1,230(s1) # 8001de78 <bcache+0x82b8>
    80002d9a:	0001b797          	auipc	a5,0x1b
    80002d9e:	08e78793          	addi	a5,a5,142 # 8001de28 <bcache+0x8268>
    80002da2:	02f48b63          	beq	s1,a5,80002dd8 <bread+0x64>
    80002da6:	873e                	mv	a4,a5
    80002da8:	a021                	j	80002db0 <bread+0x3c>
    80002daa:	68a4                	ld	s1,80(s1)
    80002dac:	02e48663          	beq	s1,a4,80002dd8 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002db0:	449c                	lw	a5,8(s1)
    80002db2:	ff279ce3          	bne	a5,s2,80002daa <bread+0x36>
    80002db6:	44dc                	lw	a5,12(s1)
    80002db8:	ff3799e3          	bne	a5,s3,80002daa <bread+0x36>
      b->refcnt++;
    80002dbc:	40bc                	lw	a5,64(s1)
    80002dbe:	2785                	addiw	a5,a5,1
    80002dc0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002dc2:	00013517          	auipc	a0,0x13
    80002dc6:	dfe50513          	addi	a0,a0,-514 # 80015bc0 <bcache>
    80002dca:	ef3fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002dce:	01048513          	addi	a0,s1,16
    80002dd2:	2da010ef          	jal	800040ac <acquiresleep>
      return b;
    80002dd6:	a889                	j	80002e28 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002dd8:	0001b497          	auipc	s1,0x1b
    80002ddc:	0984b483          	ld	s1,152(s1) # 8001de70 <bcache+0x82b0>
    80002de0:	0001b797          	auipc	a5,0x1b
    80002de4:	04878793          	addi	a5,a5,72 # 8001de28 <bcache+0x8268>
    80002de8:	00f48863          	beq	s1,a5,80002df8 <bread+0x84>
    80002dec:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002dee:	40bc                	lw	a5,64(s1)
    80002df0:	cb91                	beqz	a5,80002e04 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002df2:	64a4                	ld	s1,72(s1)
    80002df4:	fee49de3          	bne	s1,a4,80002dee <bread+0x7a>
  panic("bget: no buffers");
    80002df8:	00004517          	auipc	a0,0x4
    80002dfc:	5a850513          	addi	a0,a0,1448 # 800073a0 <etext+0x3a0>
    80002e00:	a25fd0ef          	jal	80000824 <panic>
      b->dev = dev;
    80002e04:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002e08:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002e0c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002e10:	4785                	li	a5,1
    80002e12:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e14:	00013517          	auipc	a0,0x13
    80002e18:	dac50513          	addi	a0,a0,-596 # 80015bc0 <bcache>
    80002e1c:	ea1fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002e20:	01048513          	addi	a0,s1,16
    80002e24:	288010ef          	jal	800040ac <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002e28:	409c                	lw	a5,0(s1)
    80002e2a:	cb89                	beqz	a5,80002e3c <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002e2c:	8526                	mv	a0,s1
    80002e2e:	70a2                	ld	ra,40(sp)
    80002e30:	7402                	ld	s0,32(sp)
    80002e32:	64e2                	ld	s1,24(sp)
    80002e34:	6942                	ld	s2,16(sp)
    80002e36:	69a2                	ld	s3,8(sp)
    80002e38:	6145                	addi	sp,sp,48
    80002e3a:	8082                	ret
    virtio_disk_rw(b, 0);
    80002e3c:	4581                	li	a1,0
    80002e3e:	8526                	mv	a0,s1
    80002e40:	2f1020ef          	jal	80005930 <virtio_disk_rw>
    b->valid = 1;
    80002e44:	4785                	li	a5,1
    80002e46:	c09c                	sw	a5,0(s1)
  return b;
    80002e48:	b7d5                	j	80002e2c <bread+0xb8>

0000000080002e4a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002e4a:	1101                	addi	sp,sp,-32
    80002e4c:	ec06                	sd	ra,24(sp)
    80002e4e:	e822                	sd	s0,16(sp)
    80002e50:	e426                	sd	s1,8(sp)
    80002e52:	1000                	addi	s0,sp,32
    80002e54:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e56:	0541                	addi	a0,a0,16
    80002e58:	2d2010ef          	jal	8000412a <holdingsleep>
    80002e5c:	c911                	beqz	a0,80002e70 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002e5e:	4585                	li	a1,1
    80002e60:	8526                	mv	a0,s1
    80002e62:	2cf020ef          	jal	80005930 <virtio_disk_rw>
}
    80002e66:	60e2                	ld	ra,24(sp)
    80002e68:	6442                	ld	s0,16(sp)
    80002e6a:	64a2                	ld	s1,8(sp)
    80002e6c:	6105                	addi	sp,sp,32
    80002e6e:	8082                	ret
    panic("bwrite");
    80002e70:	00004517          	auipc	a0,0x4
    80002e74:	54850513          	addi	a0,a0,1352 # 800073b8 <etext+0x3b8>
    80002e78:	9adfd0ef          	jal	80000824 <panic>

0000000080002e7c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002e7c:	1101                	addi	sp,sp,-32
    80002e7e:	ec06                	sd	ra,24(sp)
    80002e80:	e822                	sd	s0,16(sp)
    80002e82:	e426                	sd	s1,8(sp)
    80002e84:	e04a                	sd	s2,0(sp)
    80002e86:	1000                	addi	s0,sp,32
    80002e88:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e8a:	01050913          	addi	s2,a0,16
    80002e8e:	854a                	mv	a0,s2
    80002e90:	29a010ef          	jal	8000412a <holdingsleep>
    80002e94:	c125                	beqz	a0,80002ef4 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002e96:	854a                	mv	a0,s2
    80002e98:	25a010ef          	jal	800040f2 <releasesleep>

  acquire(&bcache.lock);
    80002e9c:	00013517          	auipc	a0,0x13
    80002ea0:	d2450513          	addi	a0,a0,-732 # 80015bc0 <bcache>
    80002ea4:	d85fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002ea8:	40bc                	lw	a5,64(s1)
    80002eaa:	37fd                	addiw	a5,a5,-1
    80002eac:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002eae:	e79d                	bnez	a5,80002edc <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002eb0:	68b8                	ld	a4,80(s1)
    80002eb2:	64bc                	ld	a5,72(s1)
    80002eb4:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002eb6:	68b8                	ld	a4,80(s1)
    80002eb8:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002eba:	0001b797          	auipc	a5,0x1b
    80002ebe:	d0678793          	addi	a5,a5,-762 # 8001dbc0 <bcache+0x8000>
    80002ec2:	2b87b703          	ld	a4,696(a5)
    80002ec6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ec8:	0001b717          	auipc	a4,0x1b
    80002ecc:	f6070713          	addi	a4,a4,-160 # 8001de28 <bcache+0x8268>
    80002ed0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002ed2:	2b87b703          	ld	a4,696(a5)
    80002ed6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002ed8:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002edc:	00013517          	auipc	a0,0x13
    80002ee0:	ce450513          	addi	a0,a0,-796 # 80015bc0 <bcache>
    80002ee4:	dd9fd0ef          	jal	80000cbc <release>
}
    80002ee8:	60e2                	ld	ra,24(sp)
    80002eea:	6442                	ld	s0,16(sp)
    80002eec:	64a2                	ld	s1,8(sp)
    80002eee:	6902                	ld	s2,0(sp)
    80002ef0:	6105                	addi	sp,sp,32
    80002ef2:	8082                	ret
    panic("brelse");
    80002ef4:	00004517          	auipc	a0,0x4
    80002ef8:	4cc50513          	addi	a0,a0,1228 # 800073c0 <etext+0x3c0>
    80002efc:	929fd0ef          	jal	80000824 <panic>

0000000080002f00 <bpin>:

void
bpin(struct buf *b) {
    80002f00:	1101                	addi	sp,sp,-32
    80002f02:	ec06                	sd	ra,24(sp)
    80002f04:	e822                	sd	s0,16(sp)
    80002f06:	e426                	sd	s1,8(sp)
    80002f08:	1000                	addi	s0,sp,32
    80002f0a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f0c:	00013517          	auipc	a0,0x13
    80002f10:	cb450513          	addi	a0,a0,-844 # 80015bc0 <bcache>
    80002f14:	d15fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002f18:	40bc                	lw	a5,64(s1)
    80002f1a:	2785                	addiw	a5,a5,1
    80002f1c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f1e:	00013517          	auipc	a0,0x13
    80002f22:	ca250513          	addi	a0,a0,-862 # 80015bc0 <bcache>
    80002f26:	d97fd0ef          	jal	80000cbc <release>
}
    80002f2a:	60e2                	ld	ra,24(sp)
    80002f2c:	6442                	ld	s0,16(sp)
    80002f2e:	64a2                	ld	s1,8(sp)
    80002f30:	6105                	addi	sp,sp,32
    80002f32:	8082                	ret

0000000080002f34 <bunpin>:

void
bunpin(struct buf *b) {
    80002f34:	1101                	addi	sp,sp,-32
    80002f36:	ec06                	sd	ra,24(sp)
    80002f38:	e822                	sd	s0,16(sp)
    80002f3a:	e426                	sd	s1,8(sp)
    80002f3c:	1000                	addi	s0,sp,32
    80002f3e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f40:	00013517          	auipc	a0,0x13
    80002f44:	c8050513          	addi	a0,a0,-896 # 80015bc0 <bcache>
    80002f48:	ce1fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002f4c:	40bc                	lw	a5,64(s1)
    80002f4e:	37fd                	addiw	a5,a5,-1
    80002f50:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f52:	00013517          	auipc	a0,0x13
    80002f56:	c6e50513          	addi	a0,a0,-914 # 80015bc0 <bcache>
    80002f5a:	d63fd0ef          	jal	80000cbc <release>
}
    80002f5e:	60e2                	ld	ra,24(sp)
    80002f60:	6442                	ld	s0,16(sp)
    80002f62:	64a2                	ld	s1,8(sp)
    80002f64:	6105                	addi	sp,sp,32
    80002f66:	8082                	ret

0000000080002f68 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002f68:	1101                	addi	sp,sp,-32
    80002f6a:	ec06                	sd	ra,24(sp)
    80002f6c:	e822                	sd	s0,16(sp)
    80002f6e:	e426                	sd	s1,8(sp)
    80002f70:	e04a                	sd	s2,0(sp)
    80002f72:	1000                	addi	s0,sp,32
    80002f74:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002f76:	00d5d79b          	srliw	a5,a1,0xd
    80002f7a:	0001b597          	auipc	a1,0x1b
    80002f7e:	3225a583          	lw	a1,802(a1) # 8001e29c <sb+0x1c>
    80002f82:	9dbd                	addw	a1,a1,a5
    80002f84:	df1ff0ef          	jal	80002d74 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002f88:	0074f713          	andi	a4,s1,7
    80002f8c:	4785                	li	a5,1
    80002f8e:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002f92:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80002f94:	90d9                	srli	s1,s1,0x36
    80002f96:	00950733          	add	a4,a0,s1
    80002f9a:	05874703          	lbu	a4,88(a4)
    80002f9e:	00e7f6b3          	and	a3,a5,a4
    80002fa2:	c29d                	beqz	a3,80002fc8 <bfree+0x60>
    80002fa4:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002fa6:	94aa                	add	s1,s1,a0
    80002fa8:	fff7c793          	not	a5,a5
    80002fac:	8f7d                	and	a4,a4,a5
    80002fae:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002fb2:	000010ef          	jal	80003fb2 <log_write>
  brelse(bp);
    80002fb6:	854a                	mv	a0,s2
    80002fb8:	ec5ff0ef          	jal	80002e7c <brelse>
}
    80002fbc:	60e2                	ld	ra,24(sp)
    80002fbe:	6442                	ld	s0,16(sp)
    80002fc0:	64a2                	ld	s1,8(sp)
    80002fc2:	6902                	ld	s2,0(sp)
    80002fc4:	6105                	addi	sp,sp,32
    80002fc6:	8082                	ret
    panic("freeing free block");
    80002fc8:	00004517          	auipc	a0,0x4
    80002fcc:	40050513          	addi	a0,a0,1024 # 800073c8 <etext+0x3c8>
    80002fd0:	855fd0ef          	jal	80000824 <panic>

0000000080002fd4 <balloc>:
{
    80002fd4:	715d                	addi	sp,sp,-80
    80002fd6:	e486                	sd	ra,72(sp)
    80002fd8:	e0a2                	sd	s0,64(sp)
    80002fda:	fc26                	sd	s1,56(sp)
    80002fdc:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80002fde:	0001b797          	auipc	a5,0x1b
    80002fe2:	2a67a783          	lw	a5,678(a5) # 8001e284 <sb+0x4>
    80002fe6:	0e078263          	beqz	a5,800030ca <balloc+0xf6>
    80002fea:	f84a                	sd	s2,48(sp)
    80002fec:	f44e                	sd	s3,40(sp)
    80002fee:	f052                	sd	s4,32(sp)
    80002ff0:	ec56                	sd	s5,24(sp)
    80002ff2:	e85a                	sd	s6,16(sp)
    80002ff4:	e45e                	sd	s7,8(sp)
    80002ff6:	e062                	sd	s8,0(sp)
    80002ff8:	8baa                	mv	s7,a0
    80002ffa:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002ffc:	0001bb17          	auipc	s6,0x1b
    80003000:	284b0b13          	addi	s6,s6,644 # 8001e280 <sb>
      m = 1 << (bi % 8);
    80003004:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003006:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003008:	6c09                	lui	s8,0x2
    8000300a:	a09d                	j	80003070 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000300c:	97ca                	add	a5,a5,s2
    8000300e:	8e55                	or	a2,a2,a3
    80003010:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003014:	854a                	mv	a0,s2
    80003016:	79d000ef          	jal	80003fb2 <log_write>
        brelse(bp);
    8000301a:	854a                	mv	a0,s2
    8000301c:	e61ff0ef          	jal	80002e7c <brelse>
  bp = bread(dev, bno);
    80003020:	85a6                	mv	a1,s1
    80003022:	855e                	mv	a0,s7
    80003024:	d51ff0ef          	jal	80002d74 <bread>
    80003028:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000302a:	40000613          	li	a2,1024
    8000302e:	4581                	li	a1,0
    80003030:	05850513          	addi	a0,a0,88
    80003034:	cc5fd0ef          	jal	80000cf8 <memset>
  log_write(bp);
    80003038:	854a                	mv	a0,s2
    8000303a:	779000ef          	jal	80003fb2 <log_write>
  brelse(bp);
    8000303e:	854a                	mv	a0,s2
    80003040:	e3dff0ef          	jal	80002e7c <brelse>
}
    80003044:	7942                	ld	s2,48(sp)
    80003046:	79a2                	ld	s3,40(sp)
    80003048:	7a02                	ld	s4,32(sp)
    8000304a:	6ae2                	ld	s5,24(sp)
    8000304c:	6b42                	ld	s6,16(sp)
    8000304e:	6ba2                	ld	s7,8(sp)
    80003050:	6c02                	ld	s8,0(sp)
}
    80003052:	8526                	mv	a0,s1
    80003054:	60a6                	ld	ra,72(sp)
    80003056:	6406                	ld	s0,64(sp)
    80003058:	74e2                	ld	s1,56(sp)
    8000305a:	6161                	addi	sp,sp,80
    8000305c:	8082                	ret
    brelse(bp);
    8000305e:	854a                	mv	a0,s2
    80003060:	e1dff0ef          	jal	80002e7c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003064:	015c0abb          	addw	s5,s8,s5
    80003068:	004b2783          	lw	a5,4(s6)
    8000306c:	04faf863          	bgeu	s5,a5,800030bc <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80003070:	40dad59b          	sraiw	a1,s5,0xd
    80003074:	01cb2783          	lw	a5,28(s6)
    80003078:	9dbd                	addw	a1,a1,a5
    8000307a:	855e                	mv	a0,s7
    8000307c:	cf9ff0ef          	jal	80002d74 <bread>
    80003080:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003082:	004b2503          	lw	a0,4(s6)
    80003086:	84d6                	mv	s1,s5
    80003088:	4701                	li	a4,0
    8000308a:	fca4fae3          	bgeu	s1,a0,8000305e <balloc+0x8a>
      m = 1 << (bi % 8);
    8000308e:	00777693          	andi	a3,a4,7
    80003092:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003096:	41f7579b          	sraiw	a5,a4,0x1f
    8000309a:	01d7d79b          	srliw	a5,a5,0x1d
    8000309e:	9fb9                	addw	a5,a5,a4
    800030a0:	4037d79b          	sraiw	a5,a5,0x3
    800030a4:	00f90633          	add	a2,s2,a5
    800030a8:	05864603          	lbu	a2,88(a2)
    800030ac:	00c6f5b3          	and	a1,a3,a2
    800030b0:	ddb1                	beqz	a1,8000300c <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030b2:	2705                	addiw	a4,a4,1
    800030b4:	2485                	addiw	s1,s1,1
    800030b6:	fd471ae3          	bne	a4,s4,8000308a <balloc+0xb6>
    800030ba:	b755                	j	8000305e <balloc+0x8a>
    800030bc:	7942                	ld	s2,48(sp)
    800030be:	79a2                	ld	s3,40(sp)
    800030c0:	7a02                	ld	s4,32(sp)
    800030c2:	6ae2                	ld	s5,24(sp)
    800030c4:	6b42                	ld	s6,16(sp)
    800030c6:	6ba2                	ld	s7,8(sp)
    800030c8:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    800030ca:	00004517          	auipc	a0,0x4
    800030ce:	31650513          	addi	a0,a0,790 # 800073e0 <etext+0x3e0>
    800030d2:	c28fd0ef          	jal	800004fa <printf>
  return 0;
    800030d6:	4481                	li	s1,0
    800030d8:	bfad                	j	80003052 <balloc+0x7e>

00000000800030da <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800030da:	7179                	addi	sp,sp,-48
    800030dc:	f406                	sd	ra,40(sp)
    800030de:	f022                	sd	s0,32(sp)
    800030e0:	ec26                	sd	s1,24(sp)
    800030e2:	e84a                	sd	s2,16(sp)
    800030e4:	e44e                	sd	s3,8(sp)
    800030e6:	1800                	addi	s0,sp,48
    800030e8:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800030ea:	47ad                	li	a5,11
    800030ec:	02b7e363          	bltu	a5,a1,80003112 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    800030f0:	02059793          	slli	a5,a1,0x20
    800030f4:	01e7d593          	srli	a1,a5,0x1e
    800030f8:	00b509b3          	add	s3,a0,a1
    800030fc:	0509a483          	lw	s1,80(s3)
    80003100:	e0b5                	bnez	s1,80003164 <bmap+0x8a>
      addr = balloc(ip->dev);
    80003102:	4108                	lw	a0,0(a0)
    80003104:	ed1ff0ef          	jal	80002fd4 <balloc>
    80003108:	84aa                	mv	s1,a0
      if(addr == 0)
    8000310a:	cd29                	beqz	a0,80003164 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    8000310c:	04a9a823          	sw	a0,80(s3)
    80003110:	a891                	j	80003164 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003112:	ff45879b          	addiw	a5,a1,-12
    80003116:	873e                	mv	a4,a5
    80003118:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    8000311a:	0ff00793          	li	a5,255
    8000311e:	06e7e763          	bltu	a5,a4,8000318c <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003122:	08052483          	lw	s1,128(a0)
    80003126:	e891                	bnez	s1,8000313a <bmap+0x60>
      addr = balloc(ip->dev);
    80003128:	4108                	lw	a0,0(a0)
    8000312a:	eabff0ef          	jal	80002fd4 <balloc>
    8000312e:	84aa                	mv	s1,a0
      if(addr == 0)
    80003130:	c915                	beqz	a0,80003164 <bmap+0x8a>
    80003132:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003134:	08a92023          	sw	a0,128(s2)
    80003138:	a011                	j	8000313c <bmap+0x62>
    8000313a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000313c:	85a6                	mv	a1,s1
    8000313e:	00092503          	lw	a0,0(s2)
    80003142:	c33ff0ef          	jal	80002d74 <bread>
    80003146:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003148:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000314c:	02099713          	slli	a4,s3,0x20
    80003150:	01e75593          	srli	a1,a4,0x1e
    80003154:	97ae                	add	a5,a5,a1
    80003156:	89be                	mv	s3,a5
    80003158:	4384                	lw	s1,0(a5)
    8000315a:	cc89                	beqz	s1,80003174 <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000315c:	8552                	mv	a0,s4
    8000315e:	d1fff0ef          	jal	80002e7c <brelse>
    return addr;
    80003162:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003164:	8526                	mv	a0,s1
    80003166:	70a2                	ld	ra,40(sp)
    80003168:	7402                	ld	s0,32(sp)
    8000316a:	64e2                	ld	s1,24(sp)
    8000316c:	6942                	ld	s2,16(sp)
    8000316e:	69a2                	ld	s3,8(sp)
    80003170:	6145                	addi	sp,sp,48
    80003172:	8082                	ret
      addr = balloc(ip->dev);
    80003174:	00092503          	lw	a0,0(s2)
    80003178:	e5dff0ef          	jal	80002fd4 <balloc>
    8000317c:	84aa                	mv	s1,a0
      if(addr){
    8000317e:	dd79                	beqz	a0,8000315c <bmap+0x82>
        a[bn] = addr;
    80003180:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003184:	8552                	mv	a0,s4
    80003186:	62d000ef          	jal	80003fb2 <log_write>
    8000318a:	bfc9                	j	8000315c <bmap+0x82>
    8000318c:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000318e:	00004517          	auipc	a0,0x4
    80003192:	26a50513          	addi	a0,a0,618 # 800073f8 <etext+0x3f8>
    80003196:	e8efd0ef          	jal	80000824 <panic>

000000008000319a <iget>:
{
    8000319a:	7179                	addi	sp,sp,-48
    8000319c:	f406                	sd	ra,40(sp)
    8000319e:	f022                	sd	s0,32(sp)
    800031a0:	ec26                	sd	s1,24(sp)
    800031a2:	e84a                	sd	s2,16(sp)
    800031a4:	e44e                	sd	s3,8(sp)
    800031a6:	e052                	sd	s4,0(sp)
    800031a8:	1800                	addi	s0,sp,48
    800031aa:	892a                	mv	s2,a0
    800031ac:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800031ae:	0001b517          	auipc	a0,0x1b
    800031b2:	0f250513          	addi	a0,a0,242 # 8001e2a0 <itable>
    800031b6:	a73fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    800031ba:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800031bc:	0001b497          	auipc	s1,0x1b
    800031c0:	0fc48493          	addi	s1,s1,252 # 8001e2b8 <itable+0x18>
    800031c4:	0001d697          	auipc	a3,0x1d
    800031c8:	b8468693          	addi	a3,a3,-1148 # 8001fd48 <log>
    800031cc:	a809                	j	800031de <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800031ce:	e781                	bnez	a5,800031d6 <iget+0x3c>
    800031d0:	00099363          	bnez	s3,800031d6 <iget+0x3c>
      empty = ip;
    800031d4:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800031d6:	08848493          	addi	s1,s1,136
    800031da:	02d48563          	beq	s1,a3,80003204 <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800031de:	449c                	lw	a5,8(s1)
    800031e0:	fef057e3          	blez	a5,800031ce <iget+0x34>
    800031e4:	4098                	lw	a4,0(s1)
    800031e6:	ff2718e3          	bne	a4,s2,800031d6 <iget+0x3c>
    800031ea:	40d8                	lw	a4,4(s1)
    800031ec:	ff4715e3          	bne	a4,s4,800031d6 <iget+0x3c>
      ip->ref++;
    800031f0:	2785                	addiw	a5,a5,1
    800031f2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800031f4:	0001b517          	auipc	a0,0x1b
    800031f8:	0ac50513          	addi	a0,a0,172 # 8001e2a0 <itable>
    800031fc:	ac1fd0ef          	jal	80000cbc <release>
      return ip;
    80003200:	89a6                	mv	s3,s1
    80003202:	a015                	j	80003226 <iget+0x8c>
  if(empty == 0)
    80003204:	02098a63          	beqz	s3,80003238 <iget+0x9e>
  ip->dev = dev;
    80003208:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000320c:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003210:	4785                	li	a5,1
    80003212:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003216:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    8000321a:	0001b517          	auipc	a0,0x1b
    8000321e:	08650513          	addi	a0,a0,134 # 8001e2a0 <itable>
    80003222:	a9bfd0ef          	jal	80000cbc <release>
}
    80003226:	854e                	mv	a0,s3
    80003228:	70a2                	ld	ra,40(sp)
    8000322a:	7402                	ld	s0,32(sp)
    8000322c:	64e2                	ld	s1,24(sp)
    8000322e:	6942                	ld	s2,16(sp)
    80003230:	69a2                	ld	s3,8(sp)
    80003232:	6a02                	ld	s4,0(sp)
    80003234:	6145                	addi	sp,sp,48
    80003236:	8082                	ret
    panic("iget: no inodes");
    80003238:	00004517          	auipc	a0,0x4
    8000323c:	1d850513          	addi	a0,a0,472 # 80007410 <etext+0x410>
    80003240:	de4fd0ef          	jal	80000824 <panic>

0000000080003244 <iinit>:
{
    80003244:	7179                	addi	sp,sp,-48
    80003246:	f406                	sd	ra,40(sp)
    80003248:	f022                	sd	s0,32(sp)
    8000324a:	ec26                	sd	s1,24(sp)
    8000324c:	e84a                	sd	s2,16(sp)
    8000324e:	e44e                	sd	s3,8(sp)
    80003250:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003252:	00004597          	auipc	a1,0x4
    80003256:	1ce58593          	addi	a1,a1,462 # 80007420 <etext+0x420>
    8000325a:	0001b517          	auipc	a0,0x1b
    8000325e:	04650513          	addi	a0,a0,70 # 8001e2a0 <itable>
    80003262:	93dfd0ef          	jal	80000b9e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003266:	0001b497          	auipc	s1,0x1b
    8000326a:	06248493          	addi	s1,s1,98 # 8001e2c8 <itable+0x28>
    8000326e:	0001d997          	auipc	s3,0x1d
    80003272:	aea98993          	addi	s3,s3,-1302 # 8001fd58 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003276:	00004917          	auipc	s2,0x4
    8000327a:	1b290913          	addi	s2,s2,434 # 80007428 <etext+0x428>
    8000327e:	85ca                	mv	a1,s2
    80003280:	8526                	mv	a0,s1
    80003282:	5f5000ef          	jal	80004076 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003286:	08848493          	addi	s1,s1,136
    8000328a:	ff349ae3          	bne	s1,s3,8000327e <iinit+0x3a>
}
    8000328e:	70a2                	ld	ra,40(sp)
    80003290:	7402                	ld	s0,32(sp)
    80003292:	64e2                	ld	s1,24(sp)
    80003294:	6942                	ld	s2,16(sp)
    80003296:	69a2                	ld	s3,8(sp)
    80003298:	6145                	addi	sp,sp,48
    8000329a:	8082                	ret

000000008000329c <ialloc>:
{
    8000329c:	7139                	addi	sp,sp,-64
    8000329e:	fc06                	sd	ra,56(sp)
    800032a0:	f822                	sd	s0,48(sp)
    800032a2:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800032a4:	0001b717          	auipc	a4,0x1b
    800032a8:	fe872703          	lw	a4,-24(a4) # 8001e28c <sb+0xc>
    800032ac:	4785                	li	a5,1
    800032ae:	06e7f063          	bgeu	a5,a4,8000330e <ialloc+0x72>
    800032b2:	f426                	sd	s1,40(sp)
    800032b4:	f04a                	sd	s2,32(sp)
    800032b6:	ec4e                	sd	s3,24(sp)
    800032b8:	e852                	sd	s4,16(sp)
    800032ba:	e456                	sd	s5,8(sp)
    800032bc:	e05a                	sd	s6,0(sp)
    800032be:	8aaa                	mv	s5,a0
    800032c0:	8b2e                	mv	s6,a1
    800032c2:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800032c4:	0001ba17          	auipc	s4,0x1b
    800032c8:	fbca0a13          	addi	s4,s4,-68 # 8001e280 <sb>
    800032cc:	00495593          	srli	a1,s2,0x4
    800032d0:	018a2783          	lw	a5,24(s4)
    800032d4:	9dbd                	addw	a1,a1,a5
    800032d6:	8556                	mv	a0,s5
    800032d8:	a9dff0ef          	jal	80002d74 <bread>
    800032dc:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800032de:	05850993          	addi	s3,a0,88
    800032e2:	00f97793          	andi	a5,s2,15
    800032e6:	079a                	slli	a5,a5,0x6
    800032e8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800032ea:	00099783          	lh	a5,0(s3)
    800032ee:	cb9d                	beqz	a5,80003324 <ialloc+0x88>
    brelse(bp);
    800032f0:	b8dff0ef          	jal	80002e7c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800032f4:	0905                	addi	s2,s2,1
    800032f6:	00ca2703          	lw	a4,12(s4)
    800032fa:	0009079b          	sext.w	a5,s2
    800032fe:	fce7e7e3          	bltu	a5,a4,800032cc <ialloc+0x30>
    80003302:	74a2                	ld	s1,40(sp)
    80003304:	7902                	ld	s2,32(sp)
    80003306:	69e2                	ld	s3,24(sp)
    80003308:	6a42                	ld	s4,16(sp)
    8000330a:	6aa2                	ld	s5,8(sp)
    8000330c:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000330e:	00004517          	auipc	a0,0x4
    80003312:	12250513          	addi	a0,a0,290 # 80007430 <etext+0x430>
    80003316:	9e4fd0ef          	jal	800004fa <printf>
  return 0;
    8000331a:	4501                	li	a0,0
}
    8000331c:	70e2                	ld	ra,56(sp)
    8000331e:	7442                	ld	s0,48(sp)
    80003320:	6121                	addi	sp,sp,64
    80003322:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003324:	04000613          	li	a2,64
    80003328:	4581                	li	a1,0
    8000332a:	854e                	mv	a0,s3
    8000332c:	9cdfd0ef          	jal	80000cf8 <memset>
      dip->type = type;
    80003330:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003334:	8526                	mv	a0,s1
    80003336:	47d000ef          	jal	80003fb2 <log_write>
      brelse(bp);
    8000333a:	8526                	mv	a0,s1
    8000333c:	b41ff0ef          	jal	80002e7c <brelse>
      return iget(dev, inum);
    80003340:	0009059b          	sext.w	a1,s2
    80003344:	8556                	mv	a0,s5
    80003346:	e55ff0ef          	jal	8000319a <iget>
    8000334a:	74a2                	ld	s1,40(sp)
    8000334c:	7902                	ld	s2,32(sp)
    8000334e:	69e2                	ld	s3,24(sp)
    80003350:	6a42                	ld	s4,16(sp)
    80003352:	6aa2                	ld	s5,8(sp)
    80003354:	6b02                	ld	s6,0(sp)
    80003356:	b7d9                	j	8000331c <ialloc+0x80>

0000000080003358 <iupdate>:
{
    80003358:	1101                	addi	sp,sp,-32
    8000335a:	ec06                	sd	ra,24(sp)
    8000335c:	e822                	sd	s0,16(sp)
    8000335e:	e426                	sd	s1,8(sp)
    80003360:	e04a                	sd	s2,0(sp)
    80003362:	1000                	addi	s0,sp,32
    80003364:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003366:	415c                	lw	a5,4(a0)
    80003368:	0047d79b          	srliw	a5,a5,0x4
    8000336c:	0001b597          	auipc	a1,0x1b
    80003370:	f2c5a583          	lw	a1,-212(a1) # 8001e298 <sb+0x18>
    80003374:	9dbd                	addw	a1,a1,a5
    80003376:	4108                	lw	a0,0(a0)
    80003378:	9fdff0ef          	jal	80002d74 <bread>
    8000337c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000337e:	05850793          	addi	a5,a0,88
    80003382:	40d8                	lw	a4,4(s1)
    80003384:	8b3d                	andi	a4,a4,15
    80003386:	071a                	slli	a4,a4,0x6
    80003388:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000338a:	04449703          	lh	a4,68(s1)
    8000338e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003392:	04649703          	lh	a4,70(s1)
    80003396:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000339a:	04849703          	lh	a4,72(s1)
    8000339e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800033a2:	04a49703          	lh	a4,74(s1)
    800033a6:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800033aa:	44f8                	lw	a4,76(s1)
    800033ac:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800033ae:	03400613          	li	a2,52
    800033b2:	05048593          	addi	a1,s1,80
    800033b6:	00c78513          	addi	a0,a5,12
    800033ba:	99ffd0ef          	jal	80000d58 <memmove>
  log_write(bp);
    800033be:	854a                	mv	a0,s2
    800033c0:	3f3000ef          	jal	80003fb2 <log_write>
  brelse(bp);
    800033c4:	854a                	mv	a0,s2
    800033c6:	ab7ff0ef          	jal	80002e7c <brelse>
}
    800033ca:	60e2                	ld	ra,24(sp)
    800033cc:	6442                	ld	s0,16(sp)
    800033ce:	64a2                	ld	s1,8(sp)
    800033d0:	6902                	ld	s2,0(sp)
    800033d2:	6105                	addi	sp,sp,32
    800033d4:	8082                	ret

00000000800033d6 <idup>:
{
    800033d6:	1101                	addi	sp,sp,-32
    800033d8:	ec06                	sd	ra,24(sp)
    800033da:	e822                	sd	s0,16(sp)
    800033dc:	e426                	sd	s1,8(sp)
    800033de:	1000                	addi	s0,sp,32
    800033e0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033e2:	0001b517          	auipc	a0,0x1b
    800033e6:	ebe50513          	addi	a0,a0,-322 # 8001e2a0 <itable>
    800033ea:	83ffd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    800033ee:	449c                	lw	a5,8(s1)
    800033f0:	2785                	addiw	a5,a5,1
    800033f2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033f4:	0001b517          	auipc	a0,0x1b
    800033f8:	eac50513          	addi	a0,a0,-340 # 8001e2a0 <itable>
    800033fc:	8c1fd0ef          	jal	80000cbc <release>
}
    80003400:	8526                	mv	a0,s1
    80003402:	60e2                	ld	ra,24(sp)
    80003404:	6442                	ld	s0,16(sp)
    80003406:	64a2                	ld	s1,8(sp)
    80003408:	6105                	addi	sp,sp,32
    8000340a:	8082                	ret

000000008000340c <ilock>:
{
    8000340c:	1101                	addi	sp,sp,-32
    8000340e:	ec06                	sd	ra,24(sp)
    80003410:	e822                	sd	s0,16(sp)
    80003412:	e426                	sd	s1,8(sp)
    80003414:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003416:	cd19                	beqz	a0,80003434 <ilock+0x28>
    80003418:	84aa                	mv	s1,a0
    8000341a:	451c                	lw	a5,8(a0)
    8000341c:	00f05c63          	blez	a5,80003434 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003420:	0541                	addi	a0,a0,16
    80003422:	48b000ef          	jal	800040ac <acquiresleep>
  if(ip->valid == 0){
    80003426:	40bc                	lw	a5,64(s1)
    80003428:	cf89                	beqz	a5,80003442 <ilock+0x36>
}
    8000342a:	60e2                	ld	ra,24(sp)
    8000342c:	6442                	ld	s0,16(sp)
    8000342e:	64a2                	ld	s1,8(sp)
    80003430:	6105                	addi	sp,sp,32
    80003432:	8082                	ret
    80003434:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003436:	00004517          	auipc	a0,0x4
    8000343a:	01250513          	addi	a0,a0,18 # 80007448 <etext+0x448>
    8000343e:	be6fd0ef          	jal	80000824 <panic>
    80003442:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003444:	40dc                	lw	a5,4(s1)
    80003446:	0047d79b          	srliw	a5,a5,0x4
    8000344a:	0001b597          	auipc	a1,0x1b
    8000344e:	e4e5a583          	lw	a1,-434(a1) # 8001e298 <sb+0x18>
    80003452:	9dbd                	addw	a1,a1,a5
    80003454:	4088                	lw	a0,0(s1)
    80003456:	91fff0ef          	jal	80002d74 <bread>
    8000345a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000345c:	05850593          	addi	a1,a0,88
    80003460:	40dc                	lw	a5,4(s1)
    80003462:	8bbd                	andi	a5,a5,15
    80003464:	079a                	slli	a5,a5,0x6
    80003466:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003468:	00059783          	lh	a5,0(a1)
    8000346c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003470:	00259783          	lh	a5,2(a1)
    80003474:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003478:	00459783          	lh	a5,4(a1)
    8000347c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003480:	00659783          	lh	a5,6(a1)
    80003484:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003488:	459c                	lw	a5,8(a1)
    8000348a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000348c:	03400613          	li	a2,52
    80003490:	05b1                	addi	a1,a1,12
    80003492:	05048513          	addi	a0,s1,80
    80003496:	8c3fd0ef          	jal	80000d58 <memmove>
    brelse(bp);
    8000349a:	854a                	mv	a0,s2
    8000349c:	9e1ff0ef          	jal	80002e7c <brelse>
    ip->valid = 1;
    800034a0:	4785                	li	a5,1
    800034a2:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800034a4:	04449783          	lh	a5,68(s1)
    800034a8:	c399                	beqz	a5,800034ae <ilock+0xa2>
    800034aa:	6902                	ld	s2,0(sp)
    800034ac:	bfbd                	j	8000342a <ilock+0x1e>
      panic("ilock: no type");
    800034ae:	00004517          	auipc	a0,0x4
    800034b2:	fa250513          	addi	a0,a0,-94 # 80007450 <etext+0x450>
    800034b6:	b6efd0ef          	jal	80000824 <panic>

00000000800034ba <iunlock>:
{
    800034ba:	1101                	addi	sp,sp,-32
    800034bc:	ec06                	sd	ra,24(sp)
    800034be:	e822                	sd	s0,16(sp)
    800034c0:	e426                	sd	s1,8(sp)
    800034c2:	e04a                	sd	s2,0(sp)
    800034c4:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800034c6:	c505                	beqz	a0,800034ee <iunlock+0x34>
    800034c8:	84aa                	mv	s1,a0
    800034ca:	01050913          	addi	s2,a0,16
    800034ce:	854a                	mv	a0,s2
    800034d0:	45b000ef          	jal	8000412a <holdingsleep>
    800034d4:	cd09                	beqz	a0,800034ee <iunlock+0x34>
    800034d6:	449c                	lw	a5,8(s1)
    800034d8:	00f05b63          	blez	a5,800034ee <iunlock+0x34>
  releasesleep(&ip->lock);
    800034dc:	854a                	mv	a0,s2
    800034de:	415000ef          	jal	800040f2 <releasesleep>
}
    800034e2:	60e2                	ld	ra,24(sp)
    800034e4:	6442                	ld	s0,16(sp)
    800034e6:	64a2                	ld	s1,8(sp)
    800034e8:	6902                	ld	s2,0(sp)
    800034ea:	6105                	addi	sp,sp,32
    800034ec:	8082                	ret
    panic("iunlock");
    800034ee:	00004517          	auipc	a0,0x4
    800034f2:	f7250513          	addi	a0,a0,-142 # 80007460 <etext+0x460>
    800034f6:	b2efd0ef          	jal	80000824 <panic>

00000000800034fa <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800034fa:	7179                	addi	sp,sp,-48
    800034fc:	f406                	sd	ra,40(sp)
    800034fe:	f022                	sd	s0,32(sp)
    80003500:	ec26                	sd	s1,24(sp)
    80003502:	e84a                	sd	s2,16(sp)
    80003504:	e44e                	sd	s3,8(sp)
    80003506:	1800                	addi	s0,sp,48
    80003508:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000350a:	05050493          	addi	s1,a0,80
    8000350e:	08050913          	addi	s2,a0,128
    80003512:	a021                	j	8000351a <itrunc+0x20>
    80003514:	0491                	addi	s1,s1,4
    80003516:	01248b63          	beq	s1,s2,8000352c <itrunc+0x32>
    if(ip->addrs[i]){
    8000351a:	408c                	lw	a1,0(s1)
    8000351c:	dde5                	beqz	a1,80003514 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000351e:	0009a503          	lw	a0,0(s3)
    80003522:	a47ff0ef          	jal	80002f68 <bfree>
      ip->addrs[i] = 0;
    80003526:	0004a023          	sw	zero,0(s1)
    8000352a:	b7ed                	j	80003514 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000352c:	0809a583          	lw	a1,128(s3)
    80003530:	ed89                	bnez	a1,8000354a <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003532:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003536:	854e                	mv	a0,s3
    80003538:	e21ff0ef          	jal	80003358 <iupdate>
}
    8000353c:	70a2                	ld	ra,40(sp)
    8000353e:	7402                	ld	s0,32(sp)
    80003540:	64e2                	ld	s1,24(sp)
    80003542:	6942                	ld	s2,16(sp)
    80003544:	69a2                	ld	s3,8(sp)
    80003546:	6145                	addi	sp,sp,48
    80003548:	8082                	ret
    8000354a:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000354c:	0009a503          	lw	a0,0(s3)
    80003550:	825ff0ef          	jal	80002d74 <bread>
    80003554:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003556:	05850493          	addi	s1,a0,88
    8000355a:	45850913          	addi	s2,a0,1112
    8000355e:	a021                	j	80003566 <itrunc+0x6c>
    80003560:	0491                	addi	s1,s1,4
    80003562:	01248963          	beq	s1,s2,80003574 <itrunc+0x7a>
      if(a[j])
    80003566:	408c                	lw	a1,0(s1)
    80003568:	dde5                	beqz	a1,80003560 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000356a:	0009a503          	lw	a0,0(s3)
    8000356e:	9fbff0ef          	jal	80002f68 <bfree>
    80003572:	b7fd                	j	80003560 <itrunc+0x66>
    brelse(bp);
    80003574:	8552                	mv	a0,s4
    80003576:	907ff0ef          	jal	80002e7c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000357a:	0809a583          	lw	a1,128(s3)
    8000357e:	0009a503          	lw	a0,0(s3)
    80003582:	9e7ff0ef          	jal	80002f68 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003586:	0809a023          	sw	zero,128(s3)
    8000358a:	6a02                	ld	s4,0(sp)
    8000358c:	b75d                	j	80003532 <itrunc+0x38>

000000008000358e <iput>:
{
    8000358e:	1101                	addi	sp,sp,-32
    80003590:	ec06                	sd	ra,24(sp)
    80003592:	e822                	sd	s0,16(sp)
    80003594:	e426                	sd	s1,8(sp)
    80003596:	1000                	addi	s0,sp,32
    80003598:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000359a:	0001b517          	auipc	a0,0x1b
    8000359e:	d0650513          	addi	a0,a0,-762 # 8001e2a0 <itable>
    800035a2:	e86fd0ef          	jal	80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800035a6:	4498                	lw	a4,8(s1)
    800035a8:	4785                	li	a5,1
    800035aa:	02f70063          	beq	a4,a5,800035ca <iput+0x3c>
  ip->ref--;
    800035ae:	449c                	lw	a5,8(s1)
    800035b0:	37fd                	addiw	a5,a5,-1
    800035b2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035b4:	0001b517          	auipc	a0,0x1b
    800035b8:	cec50513          	addi	a0,a0,-788 # 8001e2a0 <itable>
    800035bc:	f00fd0ef          	jal	80000cbc <release>
}
    800035c0:	60e2                	ld	ra,24(sp)
    800035c2:	6442                	ld	s0,16(sp)
    800035c4:	64a2                	ld	s1,8(sp)
    800035c6:	6105                	addi	sp,sp,32
    800035c8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800035ca:	40bc                	lw	a5,64(s1)
    800035cc:	d3ed                	beqz	a5,800035ae <iput+0x20>
    800035ce:	04a49783          	lh	a5,74(s1)
    800035d2:	fff1                	bnez	a5,800035ae <iput+0x20>
    800035d4:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800035d6:	01048793          	addi	a5,s1,16
    800035da:	893e                	mv	s2,a5
    800035dc:	853e                	mv	a0,a5
    800035de:	2cf000ef          	jal	800040ac <acquiresleep>
    release(&itable.lock);
    800035e2:	0001b517          	auipc	a0,0x1b
    800035e6:	cbe50513          	addi	a0,a0,-834 # 8001e2a0 <itable>
    800035ea:	ed2fd0ef          	jal	80000cbc <release>
    itrunc(ip);
    800035ee:	8526                	mv	a0,s1
    800035f0:	f0bff0ef          	jal	800034fa <itrunc>
    ip->type = 0;
    800035f4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800035f8:	8526                	mv	a0,s1
    800035fa:	d5fff0ef          	jal	80003358 <iupdate>
    ip->valid = 0;
    800035fe:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003602:	854a                	mv	a0,s2
    80003604:	2ef000ef          	jal	800040f2 <releasesleep>
    acquire(&itable.lock);
    80003608:	0001b517          	auipc	a0,0x1b
    8000360c:	c9850513          	addi	a0,a0,-872 # 8001e2a0 <itable>
    80003610:	e18fd0ef          	jal	80000c28 <acquire>
    80003614:	6902                	ld	s2,0(sp)
    80003616:	bf61                	j	800035ae <iput+0x20>

0000000080003618 <iunlockput>:
{
    80003618:	1101                	addi	sp,sp,-32
    8000361a:	ec06                	sd	ra,24(sp)
    8000361c:	e822                	sd	s0,16(sp)
    8000361e:	e426                	sd	s1,8(sp)
    80003620:	1000                	addi	s0,sp,32
    80003622:	84aa                	mv	s1,a0
  iunlock(ip);
    80003624:	e97ff0ef          	jal	800034ba <iunlock>
  iput(ip);
    80003628:	8526                	mv	a0,s1
    8000362a:	f65ff0ef          	jal	8000358e <iput>
}
    8000362e:	60e2                	ld	ra,24(sp)
    80003630:	6442                	ld	s0,16(sp)
    80003632:	64a2                	ld	s1,8(sp)
    80003634:	6105                	addi	sp,sp,32
    80003636:	8082                	ret

0000000080003638 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003638:	0001b717          	auipc	a4,0x1b
    8000363c:	c5472703          	lw	a4,-940(a4) # 8001e28c <sb+0xc>
    80003640:	4785                	li	a5,1
    80003642:	0ae7fe63          	bgeu	a5,a4,800036fe <ireclaim+0xc6>
{
    80003646:	7139                	addi	sp,sp,-64
    80003648:	fc06                	sd	ra,56(sp)
    8000364a:	f822                	sd	s0,48(sp)
    8000364c:	f426                	sd	s1,40(sp)
    8000364e:	f04a                	sd	s2,32(sp)
    80003650:	ec4e                	sd	s3,24(sp)
    80003652:	e852                	sd	s4,16(sp)
    80003654:	e456                	sd	s5,8(sp)
    80003656:	e05a                	sd	s6,0(sp)
    80003658:	0080                	addi	s0,sp,64
    8000365a:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000365c:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000365e:	0001ba17          	auipc	s4,0x1b
    80003662:	c22a0a13          	addi	s4,s4,-990 # 8001e280 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003666:	00004b17          	auipc	s6,0x4
    8000366a:	e02b0b13          	addi	s6,s6,-510 # 80007468 <etext+0x468>
    8000366e:	a099                	j	800036b4 <ireclaim+0x7c>
    80003670:	85ce                	mv	a1,s3
    80003672:	855a                	mv	a0,s6
    80003674:	e87fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003678:	85ce                	mv	a1,s3
    8000367a:	8556                	mv	a0,s5
    8000367c:	b1fff0ef          	jal	8000319a <iget>
    80003680:	89aa                	mv	s3,a0
    brelse(bp);
    80003682:	854a                	mv	a0,s2
    80003684:	ff8ff0ef          	jal	80002e7c <brelse>
    if (ip) {
    80003688:	00098f63          	beqz	s3,800036a6 <ireclaim+0x6e>
      begin_op();
    8000368c:	78c000ef          	jal	80003e18 <begin_op>
      ilock(ip);
    80003690:	854e                	mv	a0,s3
    80003692:	d7bff0ef          	jal	8000340c <ilock>
      iunlock(ip);
    80003696:	854e                	mv	a0,s3
    80003698:	e23ff0ef          	jal	800034ba <iunlock>
      iput(ip);
    8000369c:	854e                	mv	a0,s3
    8000369e:	ef1ff0ef          	jal	8000358e <iput>
      end_op();
    800036a2:	7e6000ef          	jal	80003e88 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036a6:	0485                	addi	s1,s1,1
    800036a8:	00ca2703          	lw	a4,12(s4)
    800036ac:	0004879b          	sext.w	a5,s1
    800036b0:	02e7fd63          	bgeu	a5,a4,800036ea <ireclaim+0xb2>
    800036b4:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800036b8:	0044d593          	srli	a1,s1,0x4
    800036bc:	018a2783          	lw	a5,24(s4)
    800036c0:	9dbd                	addw	a1,a1,a5
    800036c2:	8556                	mv	a0,s5
    800036c4:	eb0ff0ef          	jal	80002d74 <bread>
    800036c8:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800036ca:	05850793          	addi	a5,a0,88
    800036ce:	00f9f713          	andi	a4,s3,15
    800036d2:	071a                	slli	a4,a4,0x6
    800036d4:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800036d6:	00079703          	lh	a4,0(a5)
    800036da:	c701                	beqz	a4,800036e2 <ireclaim+0xaa>
    800036dc:	00679783          	lh	a5,6(a5)
    800036e0:	dbc1                	beqz	a5,80003670 <ireclaim+0x38>
    brelse(bp);
    800036e2:	854a                	mv	a0,s2
    800036e4:	f98ff0ef          	jal	80002e7c <brelse>
    if (ip) {
    800036e8:	bf7d                	j	800036a6 <ireclaim+0x6e>
}
    800036ea:	70e2                	ld	ra,56(sp)
    800036ec:	7442                	ld	s0,48(sp)
    800036ee:	74a2                	ld	s1,40(sp)
    800036f0:	7902                	ld	s2,32(sp)
    800036f2:	69e2                	ld	s3,24(sp)
    800036f4:	6a42                	ld	s4,16(sp)
    800036f6:	6aa2                	ld	s5,8(sp)
    800036f8:	6b02                	ld	s6,0(sp)
    800036fa:	6121                	addi	sp,sp,64
    800036fc:	8082                	ret
    800036fe:	8082                	ret

0000000080003700 <fsinit>:
fsinit(int dev) {
    80003700:	1101                	addi	sp,sp,-32
    80003702:	ec06                	sd	ra,24(sp)
    80003704:	e822                	sd	s0,16(sp)
    80003706:	e426                	sd	s1,8(sp)
    80003708:	e04a                	sd	s2,0(sp)
    8000370a:	1000                	addi	s0,sp,32
    8000370c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000370e:	4585                	li	a1,1
    80003710:	e64ff0ef          	jal	80002d74 <bread>
    80003714:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003716:	02000613          	li	a2,32
    8000371a:	05850593          	addi	a1,a0,88
    8000371e:	0001b517          	auipc	a0,0x1b
    80003722:	b6250513          	addi	a0,a0,-1182 # 8001e280 <sb>
    80003726:	e32fd0ef          	jal	80000d58 <memmove>
  brelse(bp);
    8000372a:	8526                	mv	a0,s1
    8000372c:	f50ff0ef          	jal	80002e7c <brelse>
  if(sb.magic != FSMAGIC)
    80003730:	0001b717          	auipc	a4,0x1b
    80003734:	b5072703          	lw	a4,-1200(a4) # 8001e280 <sb>
    80003738:	102037b7          	lui	a5,0x10203
    8000373c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003740:	02f71263          	bne	a4,a5,80003764 <fsinit+0x64>
  initlog(dev, &sb);
    80003744:	0001b597          	auipc	a1,0x1b
    80003748:	b3c58593          	addi	a1,a1,-1220 # 8001e280 <sb>
    8000374c:	854a                	mv	a0,s2
    8000374e:	648000ef          	jal	80003d96 <initlog>
  ireclaim(dev);
    80003752:	854a                	mv	a0,s2
    80003754:	ee5ff0ef          	jal	80003638 <ireclaim>
}
    80003758:	60e2                	ld	ra,24(sp)
    8000375a:	6442                	ld	s0,16(sp)
    8000375c:	64a2                	ld	s1,8(sp)
    8000375e:	6902                	ld	s2,0(sp)
    80003760:	6105                	addi	sp,sp,32
    80003762:	8082                	ret
    panic("invalid file system");
    80003764:	00004517          	auipc	a0,0x4
    80003768:	d2450513          	addi	a0,a0,-732 # 80007488 <etext+0x488>
    8000376c:	8b8fd0ef          	jal	80000824 <panic>

0000000080003770 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003770:	1141                	addi	sp,sp,-16
    80003772:	e406                	sd	ra,8(sp)
    80003774:	e022                	sd	s0,0(sp)
    80003776:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003778:	411c                	lw	a5,0(a0)
    8000377a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000377c:	415c                	lw	a5,4(a0)
    8000377e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003780:	04451783          	lh	a5,68(a0)
    80003784:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003788:	04a51783          	lh	a5,74(a0)
    8000378c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003790:	04c56783          	lwu	a5,76(a0)
    80003794:	e99c                	sd	a5,16(a1)
}
    80003796:	60a2                	ld	ra,8(sp)
    80003798:	6402                	ld	s0,0(sp)
    8000379a:	0141                	addi	sp,sp,16
    8000379c:	8082                	ret

000000008000379e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000379e:	457c                	lw	a5,76(a0)
    800037a0:	0ed7e663          	bltu	a5,a3,8000388c <readi+0xee>
{
    800037a4:	7159                	addi	sp,sp,-112
    800037a6:	f486                	sd	ra,104(sp)
    800037a8:	f0a2                	sd	s0,96(sp)
    800037aa:	eca6                	sd	s1,88(sp)
    800037ac:	e0d2                	sd	s4,64(sp)
    800037ae:	fc56                	sd	s5,56(sp)
    800037b0:	f85a                	sd	s6,48(sp)
    800037b2:	f45e                	sd	s7,40(sp)
    800037b4:	1880                	addi	s0,sp,112
    800037b6:	8b2a                	mv	s6,a0
    800037b8:	8bae                	mv	s7,a1
    800037ba:	8a32                	mv	s4,a2
    800037bc:	84b6                	mv	s1,a3
    800037be:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800037c0:	9f35                	addw	a4,a4,a3
    return 0;
    800037c2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800037c4:	0ad76b63          	bltu	a4,a3,8000387a <readi+0xdc>
    800037c8:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800037ca:	00e7f463          	bgeu	a5,a4,800037d2 <readi+0x34>
    n = ip->size - off;
    800037ce:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037d2:	080a8b63          	beqz	s5,80003868 <readi+0xca>
    800037d6:	e8ca                	sd	s2,80(sp)
    800037d8:	f062                	sd	s8,32(sp)
    800037da:	ec66                	sd	s9,24(sp)
    800037dc:	e86a                	sd	s10,16(sp)
    800037de:	e46e                	sd	s11,8(sp)
    800037e0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800037e2:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800037e6:	5c7d                	li	s8,-1
    800037e8:	a80d                	j	8000381a <readi+0x7c>
    800037ea:	020d1d93          	slli	s11,s10,0x20
    800037ee:	020ddd93          	srli	s11,s11,0x20
    800037f2:	05890613          	addi	a2,s2,88
    800037f6:	86ee                	mv	a3,s11
    800037f8:	963e                	add	a2,a2,a5
    800037fa:	85d2                	mv	a1,s4
    800037fc:	855e                	mv	a0,s7
    800037fe:	ab7fe0ef          	jal	800022b4 <either_copyout>
    80003802:	05850363          	beq	a0,s8,80003848 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003806:	854a                	mv	a0,s2
    80003808:	e74ff0ef          	jal	80002e7c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000380c:	013d09bb          	addw	s3,s10,s3
    80003810:	009d04bb          	addw	s1,s10,s1
    80003814:	9a6e                	add	s4,s4,s11
    80003816:	0559f363          	bgeu	s3,s5,8000385c <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    8000381a:	00a4d59b          	srliw	a1,s1,0xa
    8000381e:	855a                	mv	a0,s6
    80003820:	8bbff0ef          	jal	800030da <bmap>
    80003824:	85aa                	mv	a1,a0
    if(addr == 0)
    80003826:	c139                	beqz	a0,8000386c <readi+0xce>
    bp = bread(ip->dev, addr);
    80003828:	000b2503          	lw	a0,0(s6)
    8000382c:	d48ff0ef          	jal	80002d74 <bread>
    80003830:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003832:	3ff4f793          	andi	a5,s1,1023
    80003836:	40fc873b          	subw	a4,s9,a5
    8000383a:	413a86bb          	subw	a3,s5,s3
    8000383e:	8d3a                	mv	s10,a4
    80003840:	fae6f5e3          	bgeu	a3,a4,800037ea <readi+0x4c>
    80003844:	8d36                	mv	s10,a3
    80003846:	b755                	j	800037ea <readi+0x4c>
      brelse(bp);
    80003848:	854a                	mv	a0,s2
    8000384a:	e32ff0ef          	jal	80002e7c <brelse>
      tot = -1;
    8000384e:	59fd                	li	s3,-1
      break;
    80003850:	6946                	ld	s2,80(sp)
    80003852:	7c02                	ld	s8,32(sp)
    80003854:	6ce2                	ld	s9,24(sp)
    80003856:	6d42                	ld	s10,16(sp)
    80003858:	6da2                	ld	s11,8(sp)
    8000385a:	a831                	j	80003876 <readi+0xd8>
    8000385c:	6946                	ld	s2,80(sp)
    8000385e:	7c02                	ld	s8,32(sp)
    80003860:	6ce2                	ld	s9,24(sp)
    80003862:	6d42                	ld	s10,16(sp)
    80003864:	6da2                	ld	s11,8(sp)
    80003866:	a801                	j	80003876 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003868:	89d6                	mv	s3,s5
    8000386a:	a031                	j	80003876 <readi+0xd8>
    8000386c:	6946                	ld	s2,80(sp)
    8000386e:	7c02                	ld	s8,32(sp)
    80003870:	6ce2                	ld	s9,24(sp)
    80003872:	6d42                	ld	s10,16(sp)
    80003874:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003876:	854e                	mv	a0,s3
    80003878:	69a6                	ld	s3,72(sp)
}
    8000387a:	70a6                	ld	ra,104(sp)
    8000387c:	7406                	ld	s0,96(sp)
    8000387e:	64e6                	ld	s1,88(sp)
    80003880:	6a06                	ld	s4,64(sp)
    80003882:	7ae2                	ld	s5,56(sp)
    80003884:	7b42                	ld	s6,48(sp)
    80003886:	7ba2                	ld	s7,40(sp)
    80003888:	6165                	addi	sp,sp,112
    8000388a:	8082                	ret
    return 0;
    8000388c:	4501                	li	a0,0
}
    8000388e:	8082                	ret

0000000080003890 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003890:	457c                	lw	a5,76(a0)
    80003892:	0ed7eb63          	bltu	a5,a3,80003988 <writei+0xf8>
{
    80003896:	7159                	addi	sp,sp,-112
    80003898:	f486                	sd	ra,104(sp)
    8000389a:	f0a2                	sd	s0,96(sp)
    8000389c:	e8ca                	sd	s2,80(sp)
    8000389e:	e0d2                	sd	s4,64(sp)
    800038a0:	fc56                	sd	s5,56(sp)
    800038a2:	f85a                	sd	s6,48(sp)
    800038a4:	f45e                	sd	s7,40(sp)
    800038a6:	1880                	addi	s0,sp,112
    800038a8:	8aaa                	mv	s5,a0
    800038aa:	8bae                	mv	s7,a1
    800038ac:	8a32                	mv	s4,a2
    800038ae:	8936                	mv	s2,a3
    800038b0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800038b2:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800038b6:	00043737          	lui	a4,0x43
    800038ba:	0cf76963          	bltu	a4,a5,8000398c <writei+0xfc>
    800038be:	0cd7e763          	bltu	a5,a3,8000398c <writei+0xfc>
    800038c2:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800038c4:	0a0b0a63          	beqz	s6,80003978 <writei+0xe8>
    800038c8:	eca6                	sd	s1,88(sp)
    800038ca:	f062                	sd	s8,32(sp)
    800038cc:	ec66                	sd	s9,24(sp)
    800038ce:	e86a                	sd	s10,16(sp)
    800038d0:	e46e                	sd	s11,8(sp)
    800038d2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800038d4:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800038d8:	5c7d                	li	s8,-1
    800038da:	a825                	j	80003912 <writei+0x82>
    800038dc:	020d1d93          	slli	s11,s10,0x20
    800038e0:	020ddd93          	srli	s11,s11,0x20
    800038e4:	05848513          	addi	a0,s1,88
    800038e8:	86ee                	mv	a3,s11
    800038ea:	8652                	mv	a2,s4
    800038ec:	85de                	mv	a1,s7
    800038ee:	953e                	add	a0,a0,a5
    800038f0:	a0ffe0ef          	jal	800022fe <either_copyin>
    800038f4:	05850663          	beq	a0,s8,80003940 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    800038f8:	8526                	mv	a0,s1
    800038fa:	6b8000ef          	jal	80003fb2 <log_write>
    brelse(bp);
    800038fe:	8526                	mv	a0,s1
    80003900:	d7cff0ef          	jal	80002e7c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003904:	013d09bb          	addw	s3,s10,s3
    80003908:	012d093b          	addw	s2,s10,s2
    8000390c:	9a6e                	add	s4,s4,s11
    8000390e:	0369fc63          	bgeu	s3,s6,80003946 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003912:	00a9559b          	srliw	a1,s2,0xa
    80003916:	8556                	mv	a0,s5
    80003918:	fc2ff0ef          	jal	800030da <bmap>
    8000391c:	85aa                	mv	a1,a0
    if(addr == 0)
    8000391e:	c505                	beqz	a0,80003946 <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003920:	000aa503          	lw	a0,0(s5)
    80003924:	c50ff0ef          	jal	80002d74 <bread>
    80003928:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000392a:	3ff97793          	andi	a5,s2,1023
    8000392e:	40fc873b          	subw	a4,s9,a5
    80003932:	413b06bb          	subw	a3,s6,s3
    80003936:	8d3a                	mv	s10,a4
    80003938:	fae6f2e3          	bgeu	a3,a4,800038dc <writei+0x4c>
    8000393c:	8d36                	mv	s10,a3
    8000393e:	bf79                	j	800038dc <writei+0x4c>
      brelse(bp);
    80003940:	8526                	mv	a0,s1
    80003942:	d3aff0ef          	jal	80002e7c <brelse>
  }

  if(off > ip->size)
    80003946:	04caa783          	lw	a5,76(s5)
    8000394a:	0327f963          	bgeu	a5,s2,8000397c <writei+0xec>
    ip->size = off;
    8000394e:	052aa623          	sw	s2,76(s5)
    80003952:	64e6                	ld	s1,88(sp)
    80003954:	7c02                	ld	s8,32(sp)
    80003956:	6ce2                	ld	s9,24(sp)
    80003958:	6d42                	ld	s10,16(sp)
    8000395a:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000395c:	8556                	mv	a0,s5
    8000395e:	9fbff0ef          	jal	80003358 <iupdate>

  return tot;
    80003962:	854e                	mv	a0,s3
    80003964:	69a6                	ld	s3,72(sp)
}
    80003966:	70a6                	ld	ra,104(sp)
    80003968:	7406                	ld	s0,96(sp)
    8000396a:	6946                	ld	s2,80(sp)
    8000396c:	6a06                	ld	s4,64(sp)
    8000396e:	7ae2                	ld	s5,56(sp)
    80003970:	7b42                	ld	s6,48(sp)
    80003972:	7ba2                	ld	s7,40(sp)
    80003974:	6165                	addi	sp,sp,112
    80003976:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003978:	89da                	mv	s3,s6
    8000397a:	b7cd                	j	8000395c <writei+0xcc>
    8000397c:	64e6                	ld	s1,88(sp)
    8000397e:	7c02                	ld	s8,32(sp)
    80003980:	6ce2                	ld	s9,24(sp)
    80003982:	6d42                	ld	s10,16(sp)
    80003984:	6da2                	ld	s11,8(sp)
    80003986:	bfd9                	j	8000395c <writei+0xcc>
    return -1;
    80003988:	557d                	li	a0,-1
}
    8000398a:	8082                	ret
    return -1;
    8000398c:	557d                	li	a0,-1
    8000398e:	bfe1                	j	80003966 <writei+0xd6>

0000000080003990 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003990:	1141                	addi	sp,sp,-16
    80003992:	e406                	sd	ra,8(sp)
    80003994:	e022                	sd	s0,0(sp)
    80003996:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003998:	4639                	li	a2,14
    8000399a:	c32fd0ef          	jal	80000dcc <strncmp>
}
    8000399e:	60a2                	ld	ra,8(sp)
    800039a0:	6402                	ld	s0,0(sp)
    800039a2:	0141                	addi	sp,sp,16
    800039a4:	8082                	ret

00000000800039a6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800039a6:	711d                	addi	sp,sp,-96
    800039a8:	ec86                	sd	ra,88(sp)
    800039aa:	e8a2                	sd	s0,80(sp)
    800039ac:	e4a6                	sd	s1,72(sp)
    800039ae:	e0ca                	sd	s2,64(sp)
    800039b0:	fc4e                	sd	s3,56(sp)
    800039b2:	f852                	sd	s4,48(sp)
    800039b4:	f456                	sd	s5,40(sp)
    800039b6:	f05a                	sd	s6,32(sp)
    800039b8:	ec5e                	sd	s7,24(sp)
    800039ba:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800039bc:	04451703          	lh	a4,68(a0)
    800039c0:	4785                	li	a5,1
    800039c2:	00f71f63          	bne	a4,a5,800039e0 <dirlookup+0x3a>
    800039c6:	892a                	mv	s2,a0
    800039c8:	8aae                	mv	s5,a1
    800039ca:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800039cc:	457c                	lw	a5,76(a0)
    800039ce:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039d0:	fa040a13          	addi	s4,s0,-96
    800039d4:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    800039d6:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800039da:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039dc:	e39d                	bnez	a5,80003a02 <dirlookup+0x5c>
    800039de:	a8b9                	j	80003a3c <dirlookup+0x96>
    panic("dirlookup not DIR");
    800039e0:	00004517          	auipc	a0,0x4
    800039e4:	ac050513          	addi	a0,a0,-1344 # 800074a0 <etext+0x4a0>
    800039e8:	e3dfc0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    800039ec:	00004517          	auipc	a0,0x4
    800039f0:	acc50513          	addi	a0,a0,-1332 # 800074b8 <etext+0x4b8>
    800039f4:	e31fc0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039f8:	24c1                	addiw	s1,s1,16
    800039fa:	04c92783          	lw	a5,76(s2)
    800039fe:	02f4fe63          	bgeu	s1,a5,80003a3a <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a02:	874e                	mv	a4,s3
    80003a04:	86a6                	mv	a3,s1
    80003a06:	8652                	mv	a2,s4
    80003a08:	4581                	li	a1,0
    80003a0a:	854a                	mv	a0,s2
    80003a0c:	d93ff0ef          	jal	8000379e <readi>
    80003a10:	fd351ee3          	bne	a0,s3,800039ec <dirlookup+0x46>
    if(de.inum == 0)
    80003a14:	fa045783          	lhu	a5,-96(s0)
    80003a18:	d3e5                	beqz	a5,800039f8 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003a1a:	85da                	mv	a1,s6
    80003a1c:	8556                	mv	a0,s5
    80003a1e:	f73ff0ef          	jal	80003990 <namecmp>
    80003a22:	f979                	bnez	a0,800039f8 <dirlookup+0x52>
      if(poff)
    80003a24:	000b8463          	beqz	s7,80003a2c <dirlookup+0x86>
        *poff = off;
    80003a28:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003a2c:	fa045583          	lhu	a1,-96(s0)
    80003a30:	00092503          	lw	a0,0(s2)
    80003a34:	f66ff0ef          	jal	8000319a <iget>
    80003a38:	a011                	j	80003a3c <dirlookup+0x96>
  return 0;
    80003a3a:	4501                	li	a0,0
}
    80003a3c:	60e6                	ld	ra,88(sp)
    80003a3e:	6446                	ld	s0,80(sp)
    80003a40:	64a6                	ld	s1,72(sp)
    80003a42:	6906                	ld	s2,64(sp)
    80003a44:	79e2                	ld	s3,56(sp)
    80003a46:	7a42                	ld	s4,48(sp)
    80003a48:	7aa2                	ld	s5,40(sp)
    80003a4a:	7b02                	ld	s6,32(sp)
    80003a4c:	6be2                	ld	s7,24(sp)
    80003a4e:	6125                	addi	sp,sp,96
    80003a50:	8082                	ret

0000000080003a52 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003a52:	711d                	addi	sp,sp,-96
    80003a54:	ec86                	sd	ra,88(sp)
    80003a56:	e8a2                	sd	s0,80(sp)
    80003a58:	e4a6                	sd	s1,72(sp)
    80003a5a:	e0ca                	sd	s2,64(sp)
    80003a5c:	fc4e                	sd	s3,56(sp)
    80003a5e:	f852                	sd	s4,48(sp)
    80003a60:	f456                	sd	s5,40(sp)
    80003a62:	f05a                	sd	s6,32(sp)
    80003a64:	ec5e                	sd	s7,24(sp)
    80003a66:	e862                	sd	s8,16(sp)
    80003a68:	e466                	sd	s9,8(sp)
    80003a6a:	e06a                	sd	s10,0(sp)
    80003a6c:	1080                	addi	s0,sp,96
    80003a6e:	84aa                	mv	s1,a0
    80003a70:	8b2e                	mv	s6,a1
    80003a72:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003a74:	00054703          	lbu	a4,0(a0)
    80003a78:	02f00793          	li	a5,47
    80003a7c:	00f70f63          	beq	a4,a5,80003a9a <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003a80:	ea3fd0ef          	jal	80001922 <myproc>
    80003a84:	15853503          	ld	a0,344(a0)
    80003a88:	94fff0ef          	jal	800033d6 <idup>
    80003a8c:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003a8e:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003a92:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003a94:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003a96:	4b85                	li	s7,1
    80003a98:	a879                	j	80003b36 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003a9a:	4585                	li	a1,1
    80003a9c:	852e                	mv	a0,a1
    80003a9e:	efcff0ef          	jal	8000319a <iget>
    80003aa2:	8a2a                	mv	s4,a0
    80003aa4:	b7ed                	j	80003a8e <namex+0x3c>
      iunlockput(ip);
    80003aa6:	8552                	mv	a0,s4
    80003aa8:	b71ff0ef          	jal	80003618 <iunlockput>
      return 0;
    80003aac:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003aae:	8552                	mv	a0,s4
    80003ab0:	60e6                	ld	ra,88(sp)
    80003ab2:	6446                	ld	s0,80(sp)
    80003ab4:	64a6                	ld	s1,72(sp)
    80003ab6:	6906                	ld	s2,64(sp)
    80003ab8:	79e2                	ld	s3,56(sp)
    80003aba:	7a42                	ld	s4,48(sp)
    80003abc:	7aa2                	ld	s5,40(sp)
    80003abe:	7b02                	ld	s6,32(sp)
    80003ac0:	6be2                	ld	s7,24(sp)
    80003ac2:	6c42                	ld	s8,16(sp)
    80003ac4:	6ca2                	ld	s9,8(sp)
    80003ac6:	6d02                	ld	s10,0(sp)
    80003ac8:	6125                	addi	sp,sp,96
    80003aca:	8082                	ret
      iunlock(ip);
    80003acc:	8552                	mv	a0,s4
    80003ace:	9edff0ef          	jal	800034ba <iunlock>
      return ip;
    80003ad2:	bff1                	j	80003aae <namex+0x5c>
      iunlockput(ip);
    80003ad4:	8552                	mv	a0,s4
    80003ad6:	b43ff0ef          	jal	80003618 <iunlockput>
      return 0;
    80003ada:	8a4a                	mv	s4,s2
    80003adc:	bfc9                	j	80003aae <namex+0x5c>
  len = path - s;
    80003ade:	40990633          	sub	a2,s2,s1
    80003ae2:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003ae6:	09ac5463          	bge	s8,s10,80003b6e <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80003aea:	8666                	mv	a2,s9
    80003aec:	85a6                	mv	a1,s1
    80003aee:	8556                	mv	a0,s5
    80003af0:	a68fd0ef          	jal	80000d58 <memmove>
    80003af4:	84ca                	mv	s1,s2
  while(*path == '/')
    80003af6:	0004c783          	lbu	a5,0(s1)
    80003afa:	01379763          	bne	a5,s3,80003b08 <namex+0xb6>
    path++;
    80003afe:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003b00:	0004c783          	lbu	a5,0(s1)
    80003b04:	ff378de3          	beq	a5,s3,80003afe <namex+0xac>
    ilock(ip);
    80003b08:	8552                	mv	a0,s4
    80003b0a:	903ff0ef          	jal	8000340c <ilock>
    if(ip->type != T_DIR){
    80003b0e:	044a1783          	lh	a5,68(s4)
    80003b12:	f9779ae3          	bne	a5,s7,80003aa6 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003b16:	000b0563          	beqz	s6,80003b20 <namex+0xce>
    80003b1a:	0004c783          	lbu	a5,0(s1)
    80003b1e:	d7dd                	beqz	a5,80003acc <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003b20:	4601                	li	a2,0
    80003b22:	85d6                	mv	a1,s5
    80003b24:	8552                	mv	a0,s4
    80003b26:	e81ff0ef          	jal	800039a6 <dirlookup>
    80003b2a:	892a                	mv	s2,a0
    80003b2c:	d545                	beqz	a0,80003ad4 <namex+0x82>
    iunlockput(ip);
    80003b2e:	8552                	mv	a0,s4
    80003b30:	ae9ff0ef          	jal	80003618 <iunlockput>
    ip = next;
    80003b34:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003b36:	0004c783          	lbu	a5,0(s1)
    80003b3a:	01379763          	bne	a5,s3,80003b48 <namex+0xf6>
    path++;
    80003b3e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003b40:	0004c783          	lbu	a5,0(s1)
    80003b44:	ff378de3          	beq	a5,s3,80003b3e <namex+0xec>
  if(*path == 0)
    80003b48:	cf8d                	beqz	a5,80003b82 <namex+0x130>
  while(*path != '/' && *path != 0)
    80003b4a:	0004c783          	lbu	a5,0(s1)
    80003b4e:	fd178713          	addi	a4,a5,-47
    80003b52:	cb19                	beqz	a4,80003b68 <namex+0x116>
    80003b54:	cb91                	beqz	a5,80003b68 <namex+0x116>
    80003b56:	8926                	mv	s2,s1
    path++;
    80003b58:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003b5a:	00094783          	lbu	a5,0(s2)
    80003b5e:	fd178713          	addi	a4,a5,-47
    80003b62:	df35                	beqz	a4,80003ade <namex+0x8c>
    80003b64:	fbf5                	bnez	a5,80003b58 <namex+0x106>
    80003b66:	bfa5                	j	80003ade <namex+0x8c>
    80003b68:	8926                	mv	s2,s1
  len = path - s;
    80003b6a:	4d01                	li	s10,0
    80003b6c:	4601                	li	a2,0
    memmove(name, s, len);
    80003b6e:	2601                	sext.w	a2,a2
    80003b70:	85a6                	mv	a1,s1
    80003b72:	8556                	mv	a0,s5
    80003b74:	9e4fd0ef          	jal	80000d58 <memmove>
    name[len] = 0;
    80003b78:	9d56                	add	s10,s10,s5
    80003b7a:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffde078>
    80003b7e:	84ca                	mv	s1,s2
    80003b80:	bf9d                	j	80003af6 <namex+0xa4>
  if(nameiparent){
    80003b82:	f20b06e3          	beqz	s6,80003aae <namex+0x5c>
    iput(ip);
    80003b86:	8552                	mv	a0,s4
    80003b88:	a07ff0ef          	jal	8000358e <iput>
    return 0;
    80003b8c:	4a01                	li	s4,0
    80003b8e:	b705                	j	80003aae <namex+0x5c>

0000000080003b90 <dirlink>:
{
    80003b90:	715d                	addi	sp,sp,-80
    80003b92:	e486                	sd	ra,72(sp)
    80003b94:	e0a2                	sd	s0,64(sp)
    80003b96:	f84a                	sd	s2,48(sp)
    80003b98:	ec56                	sd	s5,24(sp)
    80003b9a:	e85a                	sd	s6,16(sp)
    80003b9c:	0880                	addi	s0,sp,80
    80003b9e:	892a                	mv	s2,a0
    80003ba0:	8aae                	mv	s5,a1
    80003ba2:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ba4:	4601                	li	a2,0
    80003ba6:	e01ff0ef          	jal	800039a6 <dirlookup>
    80003baa:	ed1d                	bnez	a0,80003be8 <dirlink+0x58>
    80003bac:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bae:	04c92483          	lw	s1,76(s2)
    80003bb2:	c4b9                	beqz	s1,80003c00 <dirlink+0x70>
    80003bb4:	f44e                	sd	s3,40(sp)
    80003bb6:	f052                	sd	s4,32(sp)
    80003bb8:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bba:	fb040a13          	addi	s4,s0,-80
    80003bbe:	49c1                	li	s3,16
    80003bc0:	874e                	mv	a4,s3
    80003bc2:	86a6                	mv	a3,s1
    80003bc4:	8652                	mv	a2,s4
    80003bc6:	4581                	li	a1,0
    80003bc8:	854a                	mv	a0,s2
    80003bca:	bd5ff0ef          	jal	8000379e <readi>
    80003bce:	03351163          	bne	a0,s3,80003bf0 <dirlink+0x60>
    if(de.inum == 0)
    80003bd2:	fb045783          	lhu	a5,-80(s0)
    80003bd6:	c39d                	beqz	a5,80003bfc <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bd8:	24c1                	addiw	s1,s1,16
    80003bda:	04c92783          	lw	a5,76(s2)
    80003bde:	fef4e1e3          	bltu	s1,a5,80003bc0 <dirlink+0x30>
    80003be2:	79a2                	ld	s3,40(sp)
    80003be4:	7a02                	ld	s4,32(sp)
    80003be6:	a829                	j	80003c00 <dirlink+0x70>
    iput(ip);
    80003be8:	9a7ff0ef          	jal	8000358e <iput>
    return -1;
    80003bec:	557d                	li	a0,-1
    80003bee:	a83d                	j	80003c2c <dirlink+0x9c>
      panic("dirlink read");
    80003bf0:	00004517          	auipc	a0,0x4
    80003bf4:	8d850513          	addi	a0,a0,-1832 # 800074c8 <etext+0x4c8>
    80003bf8:	c2dfc0ef          	jal	80000824 <panic>
    80003bfc:	79a2                	ld	s3,40(sp)
    80003bfe:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003c00:	4639                	li	a2,14
    80003c02:	85d6                	mv	a1,s5
    80003c04:	fb240513          	addi	a0,s0,-78
    80003c08:	9fefd0ef          	jal	80000e06 <strncpy>
  de.inum = inum;
    80003c0c:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c10:	4741                	li	a4,16
    80003c12:	86a6                	mv	a3,s1
    80003c14:	fb040613          	addi	a2,s0,-80
    80003c18:	4581                	li	a1,0
    80003c1a:	854a                	mv	a0,s2
    80003c1c:	c75ff0ef          	jal	80003890 <writei>
    80003c20:	1541                	addi	a0,a0,-16
    80003c22:	00a03533          	snez	a0,a0
    80003c26:	40a0053b          	negw	a0,a0
    80003c2a:	74e2                	ld	s1,56(sp)
}
    80003c2c:	60a6                	ld	ra,72(sp)
    80003c2e:	6406                	ld	s0,64(sp)
    80003c30:	7942                	ld	s2,48(sp)
    80003c32:	6ae2                	ld	s5,24(sp)
    80003c34:	6b42                	ld	s6,16(sp)
    80003c36:	6161                	addi	sp,sp,80
    80003c38:	8082                	ret

0000000080003c3a <namei>:

struct inode*
namei(char *path)
{
    80003c3a:	1101                	addi	sp,sp,-32
    80003c3c:	ec06                	sd	ra,24(sp)
    80003c3e:	e822                	sd	s0,16(sp)
    80003c40:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003c42:	fe040613          	addi	a2,s0,-32
    80003c46:	4581                	li	a1,0
    80003c48:	e0bff0ef          	jal	80003a52 <namex>
}
    80003c4c:	60e2                	ld	ra,24(sp)
    80003c4e:	6442                	ld	s0,16(sp)
    80003c50:	6105                	addi	sp,sp,32
    80003c52:	8082                	ret

0000000080003c54 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003c54:	1141                	addi	sp,sp,-16
    80003c56:	e406                	sd	ra,8(sp)
    80003c58:	e022                	sd	s0,0(sp)
    80003c5a:	0800                	addi	s0,sp,16
    80003c5c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003c5e:	4585                	li	a1,1
    80003c60:	df3ff0ef          	jal	80003a52 <namex>
}
    80003c64:	60a2                	ld	ra,8(sp)
    80003c66:	6402                	ld	s0,0(sp)
    80003c68:	0141                	addi	sp,sp,16
    80003c6a:	8082                	ret

0000000080003c6c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003c6c:	1101                	addi	sp,sp,-32
    80003c6e:	ec06                	sd	ra,24(sp)
    80003c70:	e822                	sd	s0,16(sp)
    80003c72:	e426                	sd	s1,8(sp)
    80003c74:	e04a                	sd	s2,0(sp)
    80003c76:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003c78:	0001c917          	auipc	s2,0x1c
    80003c7c:	0d090913          	addi	s2,s2,208 # 8001fd48 <log>
    80003c80:	01892583          	lw	a1,24(s2)
    80003c84:	02492503          	lw	a0,36(s2)
    80003c88:	8ecff0ef          	jal	80002d74 <bread>
    80003c8c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003c8e:	02892603          	lw	a2,40(s2)
    80003c92:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003c94:	00c05f63          	blez	a2,80003cb2 <write_head+0x46>
    80003c98:	0001c717          	auipc	a4,0x1c
    80003c9c:	0dc70713          	addi	a4,a4,220 # 8001fd74 <log+0x2c>
    80003ca0:	87aa                	mv	a5,a0
    80003ca2:	060a                	slli	a2,a2,0x2
    80003ca4:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003ca6:	4314                	lw	a3,0(a4)
    80003ca8:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003caa:	0711                	addi	a4,a4,4
    80003cac:	0791                	addi	a5,a5,4
    80003cae:	fec79ce3          	bne	a5,a2,80003ca6 <write_head+0x3a>
  }
  bwrite(buf);
    80003cb2:	8526                	mv	a0,s1
    80003cb4:	996ff0ef          	jal	80002e4a <bwrite>
  brelse(buf);
    80003cb8:	8526                	mv	a0,s1
    80003cba:	9c2ff0ef          	jal	80002e7c <brelse>
}
    80003cbe:	60e2                	ld	ra,24(sp)
    80003cc0:	6442                	ld	s0,16(sp)
    80003cc2:	64a2                	ld	s1,8(sp)
    80003cc4:	6902                	ld	s2,0(sp)
    80003cc6:	6105                	addi	sp,sp,32
    80003cc8:	8082                	ret

0000000080003cca <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cca:	0001c797          	auipc	a5,0x1c
    80003cce:	0a67a783          	lw	a5,166(a5) # 8001fd70 <log+0x28>
    80003cd2:	0cf05163          	blez	a5,80003d94 <install_trans+0xca>
{
    80003cd6:	715d                	addi	sp,sp,-80
    80003cd8:	e486                	sd	ra,72(sp)
    80003cda:	e0a2                	sd	s0,64(sp)
    80003cdc:	fc26                	sd	s1,56(sp)
    80003cde:	f84a                	sd	s2,48(sp)
    80003ce0:	f44e                	sd	s3,40(sp)
    80003ce2:	f052                	sd	s4,32(sp)
    80003ce4:	ec56                	sd	s5,24(sp)
    80003ce6:	e85a                	sd	s6,16(sp)
    80003ce8:	e45e                	sd	s7,8(sp)
    80003cea:	e062                	sd	s8,0(sp)
    80003cec:	0880                	addi	s0,sp,80
    80003cee:	8b2a                	mv	s6,a0
    80003cf0:	0001ca97          	auipc	s5,0x1c
    80003cf4:	084a8a93          	addi	s5,s5,132 # 8001fd74 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cf8:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003cfa:	00003c17          	auipc	s8,0x3
    80003cfe:	7dec0c13          	addi	s8,s8,2014 # 800074d8 <etext+0x4d8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d02:	0001ca17          	auipc	s4,0x1c
    80003d06:	046a0a13          	addi	s4,s4,70 # 8001fd48 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003d0a:	40000b93          	li	s7,1024
    80003d0e:	a025                	j	80003d36 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d10:	000aa603          	lw	a2,0(s5)
    80003d14:	85ce                	mv	a1,s3
    80003d16:	8562                	mv	a0,s8
    80003d18:	fe2fc0ef          	jal	800004fa <printf>
    80003d1c:	a839                	j	80003d3a <install_trans+0x70>
    brelse(lbuf);
    80003d1e:	854a                	mv	a0,s2
    80003d20:	95cff0ef          	jal	80002e7c <brelse>
    brelse(dbuf);
    80003d24:	8526                	mv	a0,s1
    80003d26:	956ff0ef          	jal	80002e7c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d2a:	2985                	addiw	s3,s3,1
    80003d2c:	0a91                	addi	s5,s5,4
    80003d2e:	028a2783          	lw	a5,40(s4)
    80003d32:	04f9d563          	bge	s3,a5,80003d7c <install_trans+0xb2>
    if(recovering) {
    80003d36:	fc0b1de3          	bnez	s6,80003d10 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d3a:	018a2583          	lw	a1,24(s4)
    80003d3e:	013585bb          	addw	a1,a1,s3
    80003d42:	2585                	addiw	a1,a1,1
    80003d44:	024a2503          	lw	a0,36(s4)
    80003d48:	82cff0ef          	jal	80002d74 <bread>
    80003d4c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003d4e:	000aa583          	lw	a1,0(s5)
    80003d52:	024a2503          	lw	a0,36(s4)
    80003d56:	81eff0ef          	jal	80002d74 <bread>
    80003d5a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003d5c:	865e                	mv	a2,s7
    80003d5e:	05890593          	addi	a1,s2,88
    80003d62:	05850513          	addi	a0,a0,88
    80003d66:	ff3fc0ef          	jal	80000d58 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003d6a:	8526                	mv	a0,s1
    80003d6c:	8deff0ef          	jal	80002e4a <bwrite>
    if(recovering == 0)
    80003d70:	fa0b17e3          	bnez	s6,80003d1e <install_trans+0x54>
      bunpin(dbuf);
    80003d74:	8526                	mv	a0,s1
    80003d76:	9beff0ef          	jal	80002f34 <bunpin>
    80003d7a:	b755                	j	80003d1e <install_trans+0x54>
}
    80003d7c:	60a6                	ld	ra,72(sp)
    80003d7e:	6406                	ld	s0,64(sp)
    80003d80:	74e2                	ld	s1,56(sp)
    80003d82:	7942                	ld	s2,48(sp)
    80003d84:	79a2                	ld	s3,40(sp)
    80003d86:	7a02                	ld	s4,32(sp)
    80003d88:	6ae2                	ld	s5,24(sp)
    80003d8a:	6b42                	ld	s6,16(sp)
    80003d8c:	6ba2                	ld	s7,8(sp)
    80003d8e:	6c02                	ld	s8,0(sp)
    80003d90:	6161                	addi	sp,sp,80
    80003d92:	8082                	ret
    80003d94:	8082                	ret

0000000080003d96 <initlog>:
{
    80003d96:	7179                	addi	sp,sp,-48
    80003d98:	f406                	sd	ra,40(sp)
    80003d9a:	f022                	sd	s0,32(sp)
    80003d9c:	ec26                	sd	s1,24(sp)
    80003d9e:	e84a                	sd	s2,16(sp)
    80003da0:	e44e                	sd	s3,8(sp)
    80003da2:	1800                	addi	s0,sp,48
    80003da4:	84aa                	mv	s1,a0
    80003da6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003da8:	0001c917          	auipc	s2,0x1c
    80003dac:	fa090913          	addi	s2,s2,-96 # 8001fd48 <log>
    80003db0:	00003597          	auipc	a1,0x3
    80003db4:	74858593          	addi	a1,a1,1864 # 800074f8 <etext+0x4f8>
    80003db8:	854a                	mv	a0,s2
    80003dba:	de5fc0ef          	jal	80000b9e <initlock>
  log.start = sb->logstart;
    80003dbe:	0149a583          	lw	a1,20(s3)
    80003dc2:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003dc6:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003dca:	8526                	mv	a0,s1
    80003dcc:	fa9fe0ef          	jal	80002d74 <bread>
  log.lh.n = lh->n;
    80003dd0:	4d30                	lw	a2,88(a0)
    80003dd2:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003dd6:	00c05f63          	blez	a2,80003df4 <initlog+0x5e>
    80003dda:	87aa                	mv	a5,a0
    80003ddc:	0001c717          	auipc	a4,0x1c
    80003de0:	f9870713          	addi	a4,a4,-104 # 8001fd74 <log+0x2c>
    80003de4:	060a                	slli	a2,a2,0x2
    80003de6:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003de8:	4ff4                	lw	a3,92(a5)
    80003dea:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003dec:	0791                	addi	a5,a5,4
    80003dee:	0711                	addi	a4,a4,4
    80003df0:	fec79ce3          	bne	a5,a2,80003de8 <initlog+0x52>
  brelse(buf);
    80003df4:	888ff0ef          	jal	80002e7c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003df8:	4505                	li	a0,1
    80003dfa:	ed1ff0ef          	jal	80003cca <install_trans>
  log.lh.n = 0;
    80003dfe:	0001c797          	auipc	a5,0x1c
    80003e02:	f607a923          	sw	zero,-142(a5) # 8001fd70 <log+0x28>
  write_head(); // clear the log
    80003e06:	e67ff0ef          	jal	80003c6c <write_head>
}
    80003e0a:	70a2                	ld	ra,40(sp)
    80003e0c:	7402                	ld	s0,32(sp)
    80003e0e:	64e2                	ld	s1,24(sp)
    80003e10:	6942                	ld	s2,16(sp)
    80003e12:	69a2                	ld	s3,8(sp)
    80003e14:	6145                	addi	sp,sp,48
    80003e16:	8082                	ret

0000000080003e18 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003e18:	1101                	addi	sp,sp,-32
    80003e1a:	ec06                	sd	ra,24(sp)
    80003e1c:	e822                	sd	s0,16(sp)
    80003e1e:	e426                	sd	s1,8(sp)
    80003e20:	e04a                	sd	s2,0(sp)
    80003e22:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e24:	0001c517          	auipc	a0,0x1c
    80003e28:	f2450513          	addi	a0,a0,-220 # 8001fd48 <log>
    80003e2c:	dfdfc0ef          	jal	80000c28 <acquire>
  while(1){
    if(log.committing){
    80003e30:	0001c497          	auipc	s1,0x1c
    80003e34:	f1848493          	addi	s1,s1,-232 # 8001fd48 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003e38:	4979                	li	s2,30
    80003e3a:	a029                	j	80003e44 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003e3c:	85a6                	mv	a1,s1
    80003e3e:	8526                	mv	a0,s1
    80003e40:	91afe0ef          	jal	80001f5a <sleep>
    if(log.committing){
    80003e44:	509c                	lw	a5,32(s1)
    80003e46:	fbfd                	bnez	a5,80003e3c <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003e48:	4cd8                	lw	a4,28(s1)
    80003e4a:	2705                	addiw	a4,a4,1
    80003e4c:	0027179b          	slliw	a5,a4,0x2
    80003e50:	9fb9                	addw	a5,a5,a4
    80003e52:	0017979b          	slliw	a5,a5,0x1
    80003e56:	5494                	lw	a3,40(s1)
    80003e58:	9fb5                	addw	a5,a5,a3
    80003e5a:	00f95763          	bge	s2,a5,80003e68 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003e5e:	85a6                	mv	a1,s1
    80003e60:	8526                	mv	a0,s1
    80003e62:	8f8fe0ef          	jal	80001f5a <sleep>
    80003e66:	bff9                	j	80003e44 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003e68:	0001c797          	auipc	a5,0x1c
    80003e6c:	eee7ae23          	sw	a4,-260(a5) # 8001fd64 <log+0x1c>
      release(&log.lock);
    80003e70:	0001c517          	auipc	a0,0x1c
    80003e74:	ed850513          	addi	a0,a0,-296 # 8001fd48 <log>
    80003e78:	e45fc0ef          	jal	80000cbc <release>
      break;
    }
  }
}
    80003e7c:	60e2                	ld	ra,24(sp)
    80003e7e:	6442                	ld	s0,16(sp)
    80003e80:	64a2                	ld	s1,8(sp)
    80003e82:	6902                	ld	s2,0(sp)
    80003e84:	6105                	addi	sp,sp,32
    80003e86:	8082                	ret

0000000080003e88 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003e88:	7139                	addi	sp,sp,-64
    80003e8a:	fc06                	sd	ra,56(sp)
    80003e8c:	f822                	sd	s0,48(sp)
    80003e8e:	f426                	sd	s1,40(sp)
    80003e90:	f04a                	sd	s2,32(sp)
    80003e92:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e94:	0001c497          	auipc	s1,0x1c
    80003e98:	eb448493          	addi	s1,s1,-332 # 8001fd48 <log>
    80003e9c:	8526                	mv	a0,s1
    80003e9e:	d8bfc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003ea2:	4cdc                	lw	a5,28(s1)
    80003ea4:	37fd                	addiw	a5,a5,-1
    80003ea6:	893e                	mv	s2,a5
    80003ea8:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003eaa:	509c                	lw	a5,32(s1)
    80003eac:	e7b1                	bnez	a5,80003ef8 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    80003eae:	04091e63          	bnez	s2,80003f0a <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    80003eb2:	0001c497          	auipc	s1,0x1c
    80003eb6:	e9648493          	addi	s1,s1,-362 # 8001fd48 <log>
    80003eba:	4785                	li	a5,1
    80003ebc:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003ebe:	8526                	mv	a0,s1
    80003ec0:	dfdfc0ef          	jal	80000cbc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003ec4:	549c                	lw	a5,40(s1)
    80003ec6:	06f04463          	bgtz	a5,80003f2e <end_op+0xa6>
    acquire(&log.lock);
    80003eca:	0001c517          	auipc	a0,0x1c
    80003ece:	e7e50513          	addi	a0,a0,-386 # 8001fd48 <log>
    80003ed2:	d57fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003ed6:	0001c797          	auipc	a5,0x1c
    80003eda:	e807a923          	sw	zero,-366(a5) # 8001fd68 <log+0x20>
    wakeup(&log);
    80003ede:	0001c517          	auipc	a0,0x1c
    80003ee2:	e6a50513          	addi	a0,a0,-406 # 8001fd48 <log>
    80003ee6:	8c0fe0ef          	jal	80001fa6 <wakeup>
    release(&log.lock);
    80003eea:	0001c517          	auipc	a0,0x1c
    80003eee:	e5e50513          	addi	a0,a0,-418 # 8001fd48 <log>
    80003ef2:	dcbfc0ef          	jal	80000cbc <release>
}
    80003ef6:	a035                	j	80003f22 <end_op+0x9a>
    80003ef8:	ec4e                	sd	s3,24(sp)
    80003efa:	e852                	sd	s4,16(sp)
    80003efc:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003efe:	00003517          	auipc	a0,0x3
    80003f02:	60250513          	addi	a0,a0,1538 # 80007500 <etext+0x500>
    80003f06:	91ffc0ef          	jal	80000824 <panic>
    wakeup(&log);
    80003f0a:	0001c517          	auipc	a0,0x1c
    80003f0e:	e3e50513          	addi	a0,a0,-450 # 8001fd48 <log>
    80003f12:	894fe0ef          	jal	80001fa6 <wakeup>
  release(&log.lock);
    80003f16:	0001c517          	auipc	a0,0x1c
    80003f1a:	e3250513          	addi	a0,a0,-462 # 8001fd48 <log>
    80003f1e:	d9ffc0ef          	jal	80000cbc <release>
}
    80003f22:	70e2                	ld	ra,56(sp)
    80003f24:	7442                	ld	s0,48(sp)
    80003f26:	74a2                	ld	s1,40(sp)
    80003f28:	7902                	ld	s2,32(sp)
    80003f2a:	6121                	addi	sp,sp,64
    80003f2c:	8082                	ret
    80003f2e:	ec4e                	sd	s3,24(sp)
    80003f30:	e852                	sd	s4,16(sp)
    80003f32:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f34:	0001ca97          	auipc	s5,0x1c
    80003f38:	e40a8a93          	addi	s5,s5,-448 # 8001fd74 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003f3c:	0001ca17          	auipc	s4,0x1c
    80003f40:	e0ca0a13          	addi	s4,s4,-500 # 8001fd48 <log>
    80003f44:	018a2583          	lw	a1,24(s4)
    80003f48:	012585bb          	addw	a1,a1,s2
    80003f4c:	2585                	addiw	a1,a1,1
    80003f4e:	024a2503          	lw	a0,36(s4)
    80003f52:	e23fe0ef          	jal	80002d74 <bread>
    80003f56:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003f58:	000aa583          	lw	a1,0(s5)
    80003f5c:	024a2503          	lw	a0,36(s4)
    80003f60:	e15fe0ef          	jal	80002d74 <bread>
    80003f64:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003f66:	40000613          	li	a2,1024
    80003f6a:	05850593          	addi	a1,a0,88
    80003f6e:	05848513          	addi	a0,s1,88
    80003f72:	de7fc0ef          	jal	80000d58 <memmove>
    bwrite(to);  // write the log
    80003f76:	8526                	mv	a0,s1
    80003f78:	ed3fe0ef          	jal	80002e4a <bwrite>
    brelse(from);
    80003f7c:	854e                	mv	a0,s3
    80003f7e:	efffe0ef          	jal	80002e7c <brelse>
    brelse(to);
    80003f82:	8526                	mv	a0,s1
    80003f84:	ef9fe0ef          	jal	80002e7c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f88:	2905                	addiw	s2,s2,1
    80003f8a:	0a91                	addi	s5,s5,4
    80003f8c:	028a2783          	lw	a5,40(s4)
    80003f90:	faf94ae3          	blt	s2,a5,80003f44 <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003f94:	cd9ff0ef          	jal	80003c6c <write_head>
    install_trans(0); // Now install writes to home locations
    80003f98:	4501                	li	a0,0
    80003f9a:	d31ff0ef          	jal	80003cca <install_trans>
    log.lh.n = 0;
    80003f9e:	0001c797          	auipc	a5,0x1c
    80003fa2:	dc07a923          	sw	zero,-558(a5) # 8001fd70 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003fa6:	cc7ff0ef          	jal	80003c6c <write_head>
    80003faa:	69e2                	ld	s3,24(sp)
    80003fac:	6a42                	ld	s4,16(sp)
    80003fae:	6aa2                	ld	s5,8(sp)
    80003fb0:	bf29                	j	80003eca <end_op+0x42>

0000000080003fb2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003fb2:	1101                	addi	sp,sp,-32
    80003fb4:	ec06                	sd	ra,24(sp)
    80003fb6:	e822                	sd	s0,16(sp)
    80003fb8:	e426                	sd	s1,8(sp)
    80003fba:	1000                	addi	s0,sp,32
    80003fbc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003fbe:	0001c517          	auipc	a0,0x1c
    80003fc2:	d8a50513          	addi	a0,a0,-630 # 8001fd48 <log>
    80003fc6:	c63fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003fca:	0001c617          	auipc	a2,0x1c
    80003fce:	da662603          	lw	a2,-602(a2) # 8001fd70 <log+0x28>
    80003fd2:	47f5                	li	a5,29
    80003fd4:	04c7cd63          	blt	a5,a2,8000402e <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003fd8:	0001c797          	auipc	a5,0x1c
    80003fdc:	d8c7a783          	lw	a5,-628(a5) # 8001fd64 <log+0x1c>
    80003fe0:	04f05d63          	blez	a5,8000403a <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003fe4:	4781                	li	a5,0
    80003fe6:	06c05063          	blez	a2,80004046 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003fea:	44cc                	lw	a1,12(s1)
    80003fec:	0001c717          	auipc	a4,0x1c
    80003ff0:	d8870713          	addi	a4,a4,-632 # 8001fd74 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003ff4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003ff6:	4314                	lw	a3,0(a4)
    80003ff8:	04b68763          	beq	a3,a1,80004046 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003ffc:	2785                	addiw	a5,a5,1
    80003ffe:	0711                	addi	a4,a4,4
    80004000:	fef61be3          	bne	a2,a5,80003ff6 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004004:	060a                	slli	a2,a2,0x2
    80004006:	02060613          	addi	a2,a2,32
    8000400a:	0001c797          	auipc	a5,0x1c
    8000400e:	d3e78793          	addi	a5,a5,-706 # 8001fd48 <log>
    80004012:	97b2                	add	a5,a5,a2
    80004014:	44d8                	lw	a4,12(s1)
    80004016:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004018:	8526                	mv	a0,s1
    8000401a:	ee7fe0ef          	jal	80002f00 <bpin>
    log.lh.n++;
    8000401e:	0001c717          	auipc	a4,0x1c
    80004022:	d2a70713          	addi	a4,a4,-726 # 8001fd48 <log>
    80004026:	571c                	lw	a5,40(a4)
    80004028:	2785                	addiw	a5,a5,1
    8000402a:	d71c                	sw	a5,40(a4)
    8000402c:	a815                	j	80004060 <log_write+0xae>
    panic("too big a transaction");
    8000402e:	00003517          	auipc	a0,0x3
    80004032:	4e250513          	addi	a0,a0,1250 # 80007510 <etext+0x510>
    80004036:	feefc0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    8000403a:	00003517          	auipc	a0,0x3
    8000403e:	4ee50513          	addi	a0,a0,1262 # 80007528 <etext+0x528>
    80004042:	fe2fc0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    80004046:	00279693          	slli	a3,a5,0x2
    8000404a:	02068693          	addi	a3,a3,32
    8000404e:	0001c717          	auipc	a4,0x1c
    80004052:	cfa70713          	addi	a4,a4,-774 # 8001fd48 <log>
    80004056:	9736                	add	a4,a4,a3
    80004058:	44d4                	lw	a3,12(s1)
    8000405a:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000405c:	faf60ee3          	beq	a2,a5,80004018 <log_write+0x66>
  }
  release(&log.lock);
    80004060:	0001c517          	auipc	a0,0x1c
    80004064:	ce850513          	addi	a0,a0,-792 # 8001fd48 <log>
    80004068:	c55fc0ef          	jal	80000cbc <release>
}
    8000406c:	60e2                	ld	ra,24(sp)
    8000406e:	6442                	ld	s0,16(sp)
    80004070:	64a2                	ld	s1,8(sp)
    80004072:	6105                	addi	sp,sp,32
    80004074:	8082                	ret

0000000080004076 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004076:	1101                	addi	sp,sp,-32
    80004078:	ec06                	sd	ra,24(sp)
    8000407a:	e822                	sd	s0,16(sp)
    8000407c:	e426                	sd	s1,8(sp)
    8000407e:	e04a                	sd	s2,0(sp)
    80004080:	1000                	addi	s0,sp,32
    80004082:	84aa                	mv	s1,a0
    80004084:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004086:	00003597          	auipc	a1,0x3
    8000408a:	4c258593          	addi	a1,a1,1218 # 80007548 <etext+0x548>
    8000408e:	0521                	addi	a0,a0,8
    80004090:	b0ffc0ef          	jal	80000b9e <initlock>
  lk->name = name;
    80004094:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004098:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000409c:	0204a423          	sw	zero,40(s1)
}
    800040a0:	60e2                	ld	ra,24(sp)
    800040a2:	6442                	ld	s0,16(sp)
    800040a4:	64a2                	ld	s1,8(sp)
    800040a6:	6902                	ld	s2,0(sp)
    800040a8:	6105                	addi	sp,sp,32
    800040aa:	8082                	ret

00000000800040ac <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800040ac:	1101                	addi	sp,sp,-32
    800040ae:	ec06                	sd	ra,24(sp)
    800040b0:	e822                	sd	s0,16(sp)
    800040b2:	e426                	sd	s1,8(sp)
    800040b4:	e04a                	sd	s2,0(sp)
    800040b6:	1000                	addi	s0,sp,32
    800040b8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800040ba:	00850913          	addi	s2,a0,8
    800040be:	854a                	mv	a0,s2
    800040c0:	b69fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    800040c4:	409c                	lw	a5,0(s1)
    800040c6:	c799                	beqz	a5,800040d4 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800040c8:	85ca                	mv	a1,s2
    800040ca:	8526                	mv	a0,s1
    800040cc:	e8ffd0ef          	jal	80001f5a <sleep>
  while (lk->locked) {
    800040d0:	409c                	lw	a5,0(s1)
    800040d2:	fbfd                	bnez	a5,800040c8 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800040d4:	4785                	li	a5,1
    800040d6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800040d8:	84bfd0ef          	jal	80001922 <myproc>
    800040dc:	591c                	lw	a5,48(a0)
    800040de:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800040e0:	854a                	mv	a0,s2
    800040e2:	bdbfc0ef          	jal	80000cbc <release>
}
    800040e6:	60e2                	ld	ra,24(sp)
    800040e8:	6442                	ld	s0,16(sp)
    800040ea:	64a2                	ld	s1,8(sp)
    800040ec:	6902                	ld	s2,0(sp)
    800040ee:	6105                	addi	sp,sp,32
    800040f0:	8082                	ret

00000000800040f2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800040f2:	1101                	addi	sp,sp,-32
    800040f4:	ec06                	sd	ra,24(sp)
    800040f6:	e822                	sd	s0,16(sp)
    800040f8:	e426                	sd	s1,8(sp)
    800040fa:	e04a                	sd	s2,0(sp)
    800040fc:	1000                	addi	s0,sp,32
    800040fe:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004100:	00850913          	addi	s2,a0,8
    80004104:	854a                	mv	a0,s2
    80004106:	b23fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    8000410a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000410e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004112:	8526                	mv	a0,s1
    80004114:	e93fd0ef          	jal	80001fa6 <wakeup>
  release(&lk->lk);
    80004118:	854a                	mv	a0,s2
    8000411a:	ba3fc0ef          	jal	80000cbc <release>
}
    8000411e:	60e2                	ld	ra,24(sp)
    80004120:	6442                	ld	s0,16(sp)
    80004122:	64a2                	ld	s1,8(sp)
    80004124:	6902                	ld	s2,0(sp)
    80004126:	6105                	addi	sp,sp,32
    80004128:	8082                	ret

000000008000412a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000412a:	7179                	addi	sp,sp,-48
    8000412c:	f406                	sd	ra,40(sp)
    8000412e:	f022                	sd	s0,32(sp)
    80004130:	ec26                	sd	s1,24(sp)
    80004132:	e84a                	sd	s2,16(sp)
    80004134:	1800                	addi	s0,sp,48
    80004136:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004138:	00850913          	addi	s2,a0,8
    8000413c:	854a                	mv	a0,s2
    8000413e:	aebfc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004142:	409c                	lw	a5,0(s1)
    80004144:	ef81                	bnez	a5,8000415c <holdingsleep+0x32>
    80004146:	4481                	li	s1,0
  release(&lk->lk);
    80004148:	854a                	mv	a0,s2
    8000414a:	b73fc0ef          	jal	80000cbc <release>
  return r;
}
    8000414e:	8526                	mv	a0,s1
    80004150:	70a2                	ld	ra,40(sp)
    80004152:	7402                	ld	s0,32(sp)
    80004154:	64e2                	ld	s1,24(sp)
    80004156:	6942                	ld	s2,16(sp)
    80004158:	6145                	addi	sp,sp,48
    8000415a:	8082                	ret
    8000415c:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000415e:	0284a983          	lw	s3,40(s1)
    80004162:	fc0fd0ef          	jal	80001922 <myproc>
    80004166:	5904                	lw	s1,48(a0)
    80004168:	413484b3          	sub	s1,s1,s3
    8000416c:	0014b493          	seqz	s1,s1
    80004170:	69a2                	ld	s3,8(sp)
    80004172:	bfd9                	j	80004148 <holdingsleep+0x1e>

0000000080004174 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004174:	1141                	addi	sp,sp,-16
    80004176:	e406                	sd	ra,8(sp)
    80004178:	e022                	sd	s0,0(sp)
    8000417a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000417c:	00003597          	auipc	a1,0x3
    80004180:	3dc58593          	addi	a1,a1,988 # 80007558 <etext+0x558>
    80004184:	0001c517          	auipc	a0,0x1c
    80004188:	d0c50513          	addi	a0,a0,-756 # 8001fe90 <ftable>
    8000418c:	a13fc0ef          	jal	80000b9e <initlock>
}
    80004190:	60a2                	ld	ra,8(sp)
    80004192:	6402                	ld	s0,0(sp)
    80004194:	0141                	addi	sp,sp,16
    80004196:	8082                	ret

0000000080004198 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004198:	1101                	addi	sp,sp,-32
    8000419a:	ec06                	sd	ra,24(sp)
    8000419c:	e822                	sd	s0,16(sp)
    8000419e:	e426                	sd	s1,8(sp)
    800041a0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800041a2:	0001c517          	auipc	a0,0x1c
    800041a6:	cee50513          	addi	a0,a0,-786 # 8001fe90 <ftable>
    800041aa:	a7ffc0ef          	jal	80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800041ae:	0001c497          	auipc	s1,0x1c
    800041b2:	cfa48493          	addi	s1,s1,-774 # 8001fea8 <ftable+0x18>
    800041b6:	0001d717          	auipc	a4,0x1d
    800041ba:	c9270713          	addi	a4,a4,-878 # 80020e48 <disk>
    if(f->ref == 0){
    800041be:	40dc                	lw	a5,4(s1)
    800041c0:	cf89                	beqz	a5,800041da <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800041c2:	02848493          	addi	s1,s1,40
    800041c6:	fee49ce3          	bne	s1,a4,800041be <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800041ca:	0001c517          	auipc	a0,0x1c
    800041ce:	cc650513          	addi	a0,a0,-826 # 8001fe90 <ftable>
    800041d2:	aebfc0ef          	jal	80000cbc <release>
  return 0;
    800041d6:	4481                	li	s1,0
    800041d8:	a809                	j	800041ea <filealloc+0x52>
      f->ref = 1;
    800041da:	4785                	li	a5,1
    800041dc:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800041de:	0001c517          	auipc	a0,0x1c
    800041e2:	cb250513          	addi	a0,a0,-846 # 8001fe90 <ftable>
    800041e6:	ad7fc0ef          	jal	80000cbc <release>
}
    800041ea:	8526                	mv	a0,s1
    800041ec:	60e2                	ld	ra,24(sp)
    800041ee:	6442                	ld	s0,16(sp)
    800041f0:	64a2                	ld	s1,8(sp)
    800041f2:	6105                	addi	sp,sp,32
    800041f4:	8082                	ret

00000000800041f6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800041f6:	1101                	addi	sp,sp,-32
    800041f8:	ec06                	sd	ra,24(sp)
    800041fa:	e822                	sd	s0,16(sp)
    800041fc:	e426                	sd	s1,8(sp)
    800041fe:	1000                	addi	s0,sp,32
    80004200:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004202:	0001c517          	auipc	a0,0x1c
    80004206:	c8e50513          	addi	a0,a0,-882 # 8001fe90 <ftable>
    8000420a:	a1ffc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    8000420e:	40dc                	lw	a5,4(s1)
    80004210:	02f05063          	blez	a5,80004230 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004214:	2785                	addiw	a5,a5,1
    80004216:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004218:	0001c517          	auipc	a0,0x1c
    8000421c:	c7850513          	addi	a0,a0,-904 # 8001fe90 <ftable>
    80004220:	a9dfc0ef          	jal	80000cbc <release>
  return f;
}
    80004224:	8526                	mv	a0,s1
    80004226:	60e2                	ld	ra,24(sp)
    80004228:	6442                	ld	s0,16(sp)
    8000422a:	64a2                	ld	s1,8(sp)
    8000422c:	6105                	addi	sp,sp,32
    8000422e:	8082                	ret
    panic("filedup");
    80004230:	00003517          	auipc	a0,0x3
    80004234:	33050513          	addi	a0,a0,816 # 80007560 <etext+0x560>
    80004238:	decfc0ef          	jal	80000824 <panic>

000000008000423c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000423c:	7139                	addi	sp,sp,-64
    8000423e:	fc06                	sd	ra,56(sp)
    80004240:	f822                	sd	s0,48(sp)
    80004242:	f426                	sd	s1,40(sp)
    80004244:	0080                	addi	s0,sp,64
    80004246:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004248:	0001c517          	auipc	a0,0x1c
    8000424c:	c4850513          	addi	a0,a0,-952 # 8001fe90 <ftable>
    80004250:	9d9fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    80004254:	40dc                	lw	a5,4(s1)
    80004256:	04f05a63          	blez	a5,800042aa <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    8000425a:	37fd                	addiw	a5,a5,-1
    8000425c:	c0dc                	sw	a5,4(s1)
    8000425e:	06f04063          	bgtz	a5,800042be <fileclose+0x82>
    80004262:	f04a                	sd	s2,32(sp)
    80004264:	ec4e                	sd	s3,24(sp)
    80004266:	e852                	sd	s4,16(sp)
    80004268:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000426a:	0004a903          	lw	s2,0(s1)
    8000426e:	0094c783          	lbu	a5,9(s1)
    80004272:	89be                	mv	s3,a5
    80004274:	689c                	ld	a5,16(s1)
    80004276:	8a3e                	mv	s4,a5
    80004278:	6c9c                	ld	a5,24(s1)
    8000427a:	8abe                	mv	s5,a5
  f->ref = 0;
    8000427c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004280:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004284:	0001c517          	auipc	a0,0x1c
    80004288:	c0c50513          	addi	a0,a0,-1012 # 8001fe90 <ftable>
    8000428c:	a31fc0ef          	jal	80000cbc <release>

  if(ff.type == FD_PIPE){
    80004290:	4785                	li	a5,1
    80004292:	04f90163          	beq	s2,a5,800042d4 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004296:	ffe9079b          	addiw	a5,s2,-2
    8000429a:	4705                	li	a4,1
    8000429c:	04f77563          	bgeu	a4,a5,800042e6 <fileclose+0xaa>
    800042a0:	7902                	ld	s2,32(sp)
    800042a2:	69e2                	ld	s3,24(sp)
    800042a4:	6a42                	ld	s4,16(sp)
    800042a6:	6aa2                	ld	s5,8(sp)
    800042a8:	a00d                	j	800042ca <fileclose+0x8e>
    800042aa:	f04a                	sd	s2,32(sp)
    800042ac:	ec4e                	sd	s3,24(sp)
    800042ae:	e852                	sd	s4,16(sp)
    800042b0:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800042b2:	00003517          	auipc	a0,0x3
    800042b6:	2b650513          	addi	a0,a0,694 # 80007568 <etext+0x568>
    800042ba:	d6afc0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    800042be:	0001c517          	auipc	a0,0x1c
    800042c2:	bd250513          	addi	a0,a0,-1070 # 8001fe90 <ftable>
    800042c6:	9f7fc0ef          	jal	80000cbc <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800042ca:	70e2                	ld	ra,56(sp)
    800042cc:	7442                	ld	s0,48(sp)
    800042ce:	74a2                	ld	s1,40(sp)
    800042d0:	6121                	addi	sp,sp,64
    800042d2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800042d4:	85ce                	mv	a1,s3
    800042d6:	8552                	mv	a0,s4
    800042d8:	348000ef          	jal	80004620 <pipeclose>
    800042dc:	7902                	ld	s2,32(sp)
    800042de:	69e2                	ld	s3,24(sp)
    800042e0:	6a42                	ld	s4,16(sp)
    800042e2:	6aa2                	ld	s5,8(sp)
    800042e4:	b7dd                	j	800042ca <fileclose+0x8e>
    begin_op();
    800042e6:	b33ff0ef          	jal	80003e18 <begin_op>
    iput(ff.ip);
    800042ea:	8556                	mv	a0,s5
    800042ec:	aa2ff0ef          	jal	8000358e <iput>
    end_op();
    800042f0:	b99ff0ef          	jal	80003e88 <end_op>
    800042f4:	7902                	ld	s2,32(sp)
    800042f6:	69e2                	ld	s3,24(sp)
    800042f8:	6a42                	ld	s4,16(sp)
    800042fa:	6aa2                	ld	s5,8(sp)
    800042fc:	b7f9                	j	800042ca <fileclose+0x8e>

00000000800042fe <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800042fe:	715d                	addi	sp,sp,-80
    80004300:	e486                	sd	ra,72(sp)
    80004302:	e0a2                	sd	s0,64(sp)
    80004304:	fc26                	sd	s1,56(sp)
    80004306:	f052                	sd	s4,32(sp)
    80004308:	0880                	addi	s0,sp,80
    8000430a:	84aa                	mv	s1,a0
    8000430c:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    8000430e:	e14fd0ef          	jal	80001922 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004312:	409c                	lw	a5,0(s1)
    80004314:	37f9                	addiw	a5,a5,-2
    80004316:	4705                	li	a4,1
    80004318:	04f76263          	bltu	a4,a5,8000435c <filestat+0x5e>
    8000431c:	f84a                	sd	s2,48(sp)
    8000431e:	f44e                	sd	s3,40(sp)
    80004320:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004322:	6c88                	ld	a0,24(s1)
    80004324:	8e8ff0ef          	jal	8000340c <ilock>
    stati(f->ip, &st);
    80004328:	fb840913          	addi	s2,s0,-72
    8000432c:	85ca                	mv	a1,s2
    8000432e:	6c88                	ld	a0,24(s1)
    80004330:	c40ff0ef          	jal	80003770 <stati>
    iunlock(f->ip);
    80004334:	6c88                	ld	a0,24(s1)
    80004336:	984ff0ef          	jal	800034ba <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000433a:	46e1                	li	a3,24
    8000433c:	864a                	mv	a2,s2
    8000433e:	85d2                	mv	a1,s4
    80004340:	0589b503          	ld	a0,88(s3)
    80004344:	b10fd0ef          	jal	80001654 <copyout>
    80004348:	41f5551b          	sraiw	a0,a0,0x1f
    8000434c:	7942                	ld	s2,48(sp)
    8000434e:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004350:	60a6                	ld	ra,72(sp)
    80004352:	6406                	ld	s0,64(sp)
    80004354:	74e2                	ld	s1,56(sp)
    80004356:	7a02                	ld	s4,32(sp)
    80004358:	6161                	addi	sp,sp,80
    8000435a:	8082                	ret
  return -1;
    8000435c:	557d                	li	a0,-1
    8000435e:	bfcd                	j	80004350 <filestat+0x52>

0000000080004360 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004360:	7179                	addi	sp,sp,-48
    80004362:	f406                	sd	ra,40(sp)
    80004364:	f022                	sd	s0,32(sp)
    80004366:	e84a                	sd	s2,16(sp)
    80004368:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000436a:	00854783          	lbu	a5,8(a0)
    8000436e:	cfd1                	beqz	a5,8000440a <fileread+0xaa>
    80004370:	ec26                	sd	s1,24(sp)
    80004372:	e44e                	sd	s3,8(sp)
    80004374:	84aa                	mv	s1,a0
    80004376:	892e                	mv	s2,a1
    80004378:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    8000437a:	411c                	lw	a5,0(a0)
    8000437c:	4705                	li	a4,1
    8000437e:	04e78363          	beq	a5,a4,800043c4 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004382:	470d                	li	a4,3
    80004384:	04e78763          	beq	a5,a4,800043d2 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004388:	4709                	li	a4,2
    8000438a:	06e79a63          	bne	a5,a4,800043fe <fileread+0x9e>
    ilock(f->ip);
    8000438e:	6d08                	ld	a0,24(a0)
    80004390:	87cff0ef          	jal	8000340c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004394:	874e                	mv	a4,s3
    80004396:	5094                	lw	a3,32(s1)
    80004398:	864a                	mv	a2,s2
    8000439a:	4585                	li	a1,1
    8000439c:	6c88                	ld	a0,24(s1)
    8000439e:	c00ff0ef          	jal	8000379e <readi>
    800043a2:	892a                	mv	s2,a0
    800043a4:	00a05563          	blez	a0,800043ae <fileread+0x4e>
      f->off += r;
    800043a8:	509c                	lw	a5,32(s1)
    800043aa:	9fa9                	addw	a5,a5,a0
    800043ac:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800043ae:	6c88                	ld	a0,24(s1)
    800043b0:	90aff0ef          	jal	800034ba <iunlock>
    800043b4:	64e2                	ld	s1,24(sp)
    800043b6:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800043b8:	854a                	mv	a0,s2
    800043ba:	70a2                	ld	ra,40(sp)
    800043bc:	7402                	ld	s0,32(sp)
    800043be:	6942                	ld	s2,16(sp)
    800043c0:	6145                	addi	sp,sp,48
    800043c2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800043c4:	6908                	ld	a0,16(a0)
    800043c6:	3b0000ef          	jal	80004776 <piperead>
    800043ca:	892a                	mv	s2,a0
    800043cc:	64e2                	ld	s1,24(sp)
    800043ce:	69a2                	ld	s3,8(sp)
    800043d0:	b7e5                	j	800043b8 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800043d2:	02451783          	lh	a5,36(a0)
    800043d6:	03079693          	slli	a3,a5,0x30
    800043da:	92c1                	srli	a3,a3,0x30
    800043dc:	4725                	li	a4,9
    800043de:	02d76963          	bltu	a4,a3,80004410 <fileread+0xb0>
    800043e2:	0792                	slli	a5,a5,0x4
    800043e4:	0001c717          	auipc	a4,0x1c
    800043e8:	a0c70713          	addi	a4,a4,-1524 # 8001fdf0 <devsw>
    800043ec:	97ba                	add	a5,a5,a4
    800043ee:	639c                	ld	a5,0(a5)
    800043f0:	c78d                	beqz	a5,8000441a <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    800043f2:	4505                	li	a0,1
    800043f4:	9782                	jalr	a5
    800043f6:	892a                	mv	s2,a0
    800043f8:	64e2                	ld	s1,24(sp)
    800043fa:	69a2                	ld	s3,8(sp)
    800043fc:	bf75                	j	800043b8 <fileread+0x58>
    panic("fileread");
    800043fe:	00003517          	auipc	a0,0x3
    80004402:	17a50513          	addi	a0,a0,378 # 80007578 <etext+0x578>
    80004406:	c1efc0ef          	jal	80000824 <panic>
    return -1;
    8000440a:	57fd                	li	a5,-1
    8000440c:	893e                	mv	s2,a5
    8000440e:	b76d                	j	800043b8 <fileread+0x58>
      return -1;
    80004410:	57fd                	li	a5,-1
    80004412:	893e                	mv	s2,a5
    80004414:	64e2                	ld	s1,24(sp)
    80004416:	69a2                	ld	s3,8(sp)
    80004418:	b745                	j	800043b8 <fileread+0x58>
    8000441a:	57fd                	li	a5,-1
    8000441c:	893e                	mv	s2,a5
    8000441e:	64e2                	ld	s1,24(sp)
    80004420:	69a2                	ld	s3,8(sp)
    80004422:	bf59                	j	800043b8 <fileread+0x58>

0000000080004424 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004424:	00954783          	lbu	a5,9(a0)
    80004428:	10078f63          	beqz	a5,80004546 <filewrite+0x122>
{
    8000442c:	711d                	addi	sp,sp,-96
    8000442e:	ec86                	sd	ra,88(sp)
    80004430:	e8a2                	sd	s0,80(sp)
    80004432:	e0ca                	sd	s2,64(sp)
    80004434:	f456                	sd	s5,40(sp)
    80004436:	f05a                	sd	s6,32(sp)
    80004438:	1080                	addi	s0,sp,96
    8000443a:	892a                	mv	s2,a0
    8000443c:	8b2e                	mv	s6,a1
    8000443e:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004440:	411c                	lw	a5,0(a0)
    80004442:	4705                	li	a4,1
    80004444:	02e78a63          	beq	a5,a4,80004478 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004448:	470d                	li	a4,3
    8000444a:	02e78b63          	beq	a5,a4,80004480 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000444e:	4709                	li	a4,2
    80004450:	0ce79f63          	bne	a5,a4,8000452e <filewrite+0x10a>
    80004454:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004456:	0ac05a63          	blez	a2,8000450a <filewrite+0xe6>
    8000445a:	e4a6                	sd	s1,72(sp)
    8000445c:	fc4e                	sd	s3,56(sp)
    8000445e:	ec5e                	sd	s7,24(sp)
    80004460:	e862                	sd	s8,16(sp)
    80004462:	e466                	sd	s9,8(sp)
    int i = 0;
    80004464:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004466:	6b85                	lui	s7,0x1
    80004468:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000446c:	6785                	lui	a5,0x1
    8000446e:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004472:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004474:	4c05                	li	s8,1
    80004476:	a8ad                	j	800044f0 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004478:	6908                	ld	a0,16(a0)
    8000447a:	204000ef          	jal	8000467e <pipewrite>
    8000447e:	a04d                	j	80004520 <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004480:	02451783          	lh	a5,36(a0)
    80004484:	03079693          	slli	a3,a5,0x30
    80004488:	92c1                	srli	a3,a3,0x30
    8000448a:	4725                	li	a4,9
    8000448c:	0ad76f63          	bltu	a4,a3,8000454a <filewrite+0x126>
    80004490:	0792                	slli	a5,a5,0x4
    80004492:	0001c717          	auipc	a4,0x1c
    80004496:	95e70713          	addi	a4,a4,-1698 # 8001fdf0 <devsw>
    8000449a:	97ba                	add	a5,a5,a4
    8000449c:	679c                	ld	a5,8(a5)
    8000449e:	cbc5                	beqz	a5,8000454e <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    800044a0:	4505                	li	a0,1
    800044a2:	9782                	jalr	a5
    800044a4:	a8b5                	j	80004520 <filewrite+0xfc>
      if(n1 > max)
    800044a6:	2981                	sext.w	s3,s3
      begin_op();
    800044a8:	971ff0ef          	jal	80003e18 <begin_op>
      ilock(f->ip);
    800044ac:	01893503          	ld	a0,24(s2)
    800044b0:	f5dfe0ef          	jal	8000340c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800044b4:	874e                	mv	a4,s3
    800044b6:	02092683          	lw	a3,32(s2)
    800044ba:	016a0633          	add	a2,s4,s6
    800044be:	85e2                	mv	a1,s8
    800044c0:	01893503          	ld	a0,24(s2)
    800044c4:	bccff0ef          	jal	80003890 <writei>
    800044c8:	84aa                	mv	s1,a0
    800044ca:	00a05763          	blez	a0,800044d8 <filewrite+0xb4>
        f->off += r;
    800044ce:	02092783          	lw	a5,32(s2)
    800044d2:	9fa9                	addw	a5,a5,a0
    800044d4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800044d8:	01893503          	ld	a0,24(s2)
    800044dc:	fdffe0ef          	jal	800034ba <iunlock>
      end_op();
    800044e0:	9a9ff0ef          	jal	80003e88 <end_op>

      if(r != n1){
    800044e4:	02999563          	bne	s3,s1,8000450e <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    800044e8:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    800044ec:	015a5963          	bge	s4,s5,800044fe <filewrite+0xda>
      int n1 = n - i;
    800044f0:	414a87bb          	subw	a5,s5,s4
    800044f4:	89be                	mv	s3,a5
      if(n1 > max)
    800044f6:	fafbd8e3          	bge	s7,a5,800044a6 <filewrite+0x82>
    800044fa:	89e6                	mv	s3,s9
    800044fc:	b76d                	j	800044a6 <filewrite+0x82>
    800044fe:	64a6                	ld	s1,72(sp)
    80004500:	79e2                	ld	s3,56(sp)
    80004502:	6be2                	ld	s7,24(sp)
    80004504:	6c42                	ld	s8,16(sp)
    80004506:	6ca2                	ld	s9,8(sp)
    80004508:	a801                	j	80004518 <filewrite+0xf4>
    int i = 0;
    8000450a:	4a01                	li	s4,0
    8000450c:	a031                	j	80004518 <filewrite+0xf4>
    8000450e:	64a6                	ld	s1,72(sp)
    80004510:	79e2                	ld	s3,56(sp)
    80004512:	6be2                	ld	s7,24(sp)
    80004514:	6c42                	ld	s8,16(sp)
    80004516:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004518:	034a9d63          	bne	s5,s4,80004552 <filewrite+0x12e>
    8000451c:	8556                	mv	a0,s5
    8000451e:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004520:	60e6                	ld	ra,88(sp)
    80004522:	6446                	ld	s0,80(sp)
    80004524:	6906                	ld	s2,64(sp)
    80004526:	7aa2                	ld	s5,40(sp)
    80004528:	7b02                	ld	s6,32(sp)
    8000452a:	6125                	addi	sp,sp,96
    8000452c:	8082                	ret
    8000452e:	e4a6                	sd	s1,72(sp)
    80004530:	fc4e                	sd	s3,56(sp)
    80004532:	f852                	sd	s4,48(sp)
    80004534:	ec5e                	sd	s7,24(sp)
    80004536:	e862                	sd	s8,16(sp)
    80004538:	e466                	sd	s9,8(sp)
    panic("filewrite");
    8000453a:	00003517          	auipc	a0,0x3
    8000453e:	04e50513          	addi	a0,a0,78 # 80007588 <etext+0x588>
    80004542:	ae2fc0ef          	jal	80000824 <panic>
    return -1;
    80004546:	557d                	li	a0,-1
}
    80004548:	8082                	ret
      return -1;
    8000454a:	557d                	li	a0,-1
    8000454c:	bfd1                	j	80004520 <filewrite+0xfc>
    8000454e:	557d                	li	a0,-1
    80004550:	bfc1                	j	80004520 <filewrite+0xfc>
    ret = (i == n ? n : -1);
    80004552:	557d                	li	a0,-1
    80004554:	7a42                	ld	s4,48(sp)
    80004556:	b7e9                	j	80004520 <filewrite+0xfc>

0000000080004558 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004558:	7179                	addi	sp,sp,-48
    8000455a:	f406                	sd	ra,40(sp)
    8000455c:	f022                	sd	s0,32(sp)
    8000455e:	ec26                	sd	s1,24(sp)
    80004560:	e052                	sd	s4,0(sp)
    80004562:	1800                	addi	s0,sp,48
    80004564:	84aa                	mv	s1,a0
    80004566:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004568:	0005b023          	sd	zero,0(a1)
    8000456c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004570:	c29ff0ef          	jal	80004198 <filealloc>
    80004574:	e088                	sd	a0,0(s1)
    80004576:	c549                	beqz	a0,80004600 <pipealloc+0xa8>
    80004578:	c21ff0ef          	jal	80004198 <filealloc>
    8000457c:	00aa3023          	sd	a0,0(s4)
    80004580:	cd25                	beqz	a0,800045f8 <pipealloc+0xa0>
    80004582:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004584:	dc0fc0ef          	jal	80000b44 <kalloc>
    80004588:	892a                	mv	s2,a0
    8000458a:	c12d                	beqz	a0,800045ec <pipealloc+0x94>
    8000458c:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000458e:	4985                	li	s3,1
    80004590:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004594:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004598:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000459c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800045a0:	00003597          	auipc	a1,0x3
    800045a4:	ff858593          	addi	a1,a1,-8 # 80007598 <etext+0x598>
    800045a8:	df6fc0ef          	jal	80000b9e <initlock>
  (*f0)->type = FD_PIPE;
    800045ac:	609c                	ld	a5,0(s1)
    800045ae:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800045b2:	609c                	ld	a5,0(s1)
    800045b4:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800045b8:	609c                	ld	a5,0(s1)
    800045ba:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800045be:	609c                	ld	a5,0(s1)
    800045c0:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800045c4:	000a3783          	ld	a5,0(s4)
    800045c8:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800045cc:	000a3783          	ld	a5,0(s4)
    800045d0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800045d4:	000a3783          	ld	a5,0(s4)
    800045d8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800045dc:	000a3783          	ld	a5,0(s4)
    800045e0:	0127b823          	sd	s2,16(a5)
  return 0;
    800045e4:	4501                	li	a0,0
    800045e6:	6942                	ld	s2,16(sp)
    800045e8:	69a2                	ld	s3,8(sp)
    800045ea:	a01d                	j	80004610 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800045ec:	6088                	ld	a0,0(s1)
    800045ee:	c119                	beqz	a0,800045f4 <pipealloc+0x9c>
    800045f0:	6942                	ld	s2,16(sp)
    800045f2:	a029                	j	800045fc <pipealloc+0xa4>
    800045f4:	6942                	ld	s2,16(sp)
    800045f6:	a029                	j	80004600 <pipealloc+0xa8>
    800045f8:	6088                	ld	a0,0(s1)
    800045fa:	c10d                	beqz	a0,8000461c <pipealloc+0xc4>
    fileclose(*f0);
    800045fc:	c41ff0ef          	jal	8000423c <fileclose>
  if(*f1)
    80004600:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004604:	557d                	li	a0,-1
  if(*f1)
    80004606:	c789                	beqz	a5,80004610 <pipealloc+0xb8>
    fileclose(*f1);
    80004608:	853e                	mv	a0,a5
    8000460a:	c33ff0ef          	jal	8000423c <fileclose>
  return -1;
    8000460e:	557d                	li	a0,-1
}
    80004610:	70a2                	ld	ra,40(sp)
    80004612:	7402                	ld	s0,32(sp)
    80004614:	64e2                	ld	s1,24(sp)
    80004616:	6a02                	ld	s4,0(sp)
    80004618:	6145                	addi	sp,sp,48
    8000461a:	8082                	ret
  return -1;
    8000461c:	557d                	li	a0,-1
    8000461e:	bfcd                	j	80004610 <pipealloc+0xb8>

0000000080004620 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004620:	1101                	addi	sp,sp,-32
    80004622:	ec06                	sd	ra,24(sp)
    80004624:	e822                	sd	s0,16(sp)
    80004626:	e426                	sd	s1,8(sp)
    80004628:	e04a                	sd	s2,0(sp)
    8000462a:	1000                	addi	s0,sp,32
    8000462c:	84aa                	mv	s1,a0
    8000462e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004630:	df8fc0ef          	jal	80000c28 <acquire>
  if(writable){
    80004634:	02090763          	beqz	s2,80004662 <pipeclose+0x42>
    pi->writeopen = 0;
    80004638:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000463c:	21848513          	addi	a0,s1,536
    80004640:	967fd0ef          	jal	80001fa6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004644:	2204a783          	lw	a5,544(s1)
    80004648:	e781                	bnez	a5,80004650 <pipeclose+0x30>
    8000464a:	2244a783          	lw	a5,548(s1)
    8000464e:	c38d                	beqz	a5,80004670 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    80004650:	8526                	mv	a0,s1
    80004652:	e6afc0ef          	jal	80000cbc <release>
}
    80004656:	60e2                	ld	ra,24(sp)
    80004658:	6442                	ld	s0,16(sp)
    8000465a:	64a2                	ld	s1,8(sp)
    8000465c:	6902                	ld	s2,0(sp)
    8000465e:	6105                	addi	sp,sp,32
    80004660:	8082                	ret
    pi->readopen = 0;
    80004662:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004666:	21c48513          	addi	a0,s1,540
    8000466a:	93dfd0ef          	jal	80001fa6 <wakeup>
    8000466e:	bfd9                	j	80004644 <pipeclose+0x24>
    release(&pi->lock);
    80004670:	8526                	mv	a0,s1
    80004672:	e4afc0ef          	jal	80000cbc <release>
    kfree((char*)pi);
    80004676:	8526                	mv	a0,s1
    80004678:	be4fc0ef          	jal	80000a5c <kfree>
    8000467c:	bfe9                	j	80004656 <pipeclose+0x36>

000000008000467e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000467e:	7159                	addi	sp,sp,-112
    80004680:	f486                	sd	ra,104(sp)
    80004682:	f0a2                	sd	s0,96(sp)
    80004684:	eca6                	sd	s1,88(sp)
    80004686:	e8ca                	sd	s2,80(sp)
    80004688:	e4ce                	sd	s3,72(sp)
    8000468a:	e0d2                	sd	s4,64(sp)
    8000468c:	fc56                	sd	s5,56(sp)
    8000468e:	1880                	addi	s0,sp,112
    80004690:	84aa                	mv	s1,a0
    80004692:	8aae                	mv	s5,a1
    80004694:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004696:	a8cfd0ef          	jal	80001922 <myproc>
    8000469a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000469c:	8526                	mv	a0,s1
    8000469e:	d8afc0ef          	jal	80000c28 <acquire>
  while(i < n){
    800046a2:	0d405263          	blez	s4,80004766 <pipewrite+0xe8>
    800046a6:	f85a                	sd	s6,48(sp)
    800046a8:	f45e                	sd	s7,40(sp)
    800046aa:	f062                	sd	s8,32(sp)
    800046ac:	ec66                	sd	s9,24(sp)
    800046ae:	e86a                	sd	s10,16(sp)
  int i = 0;
    800046b0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800046b2:	f9f40c13          	addi	s8,s0,-97
    800046b6:	4b85                	li	s7,1
    800046b8:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800046ba:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800046be:	21c48c93          	addi	s9,s1,540
    800046c2:	a82d                	j	800046fc <pipewrite+0x7e>
      release(&pi->lock);
    800046c4:	8526                	mv	a0,s1
    800046c6:	df6fc0ef          	jal	80000cbc <release>
      return -1;
    800046ca:	597d                	li	s2,-1
    800046cc:	7b42                	ld	s6,48(sp)
    800046ce:	7ba2                	ld	s7,40(sp)
    800046d0:	7c02                	ld	s8,32(sp)
    800046d2:	6ce2                	ld	s9,24(sp)
    800046d4:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800046d6:	854a                	mv	a0,s2
    800046d8:	70a6                	ld	ra,104(sp)
    800046da:	7406                	ld	s0,96(sp)
    800046dc:	64e6                	ld	s1,88(sp)
    800046de:	6946                	ld	s2,80(sp)
    800046e0:	69a6                	ld	s3,72(sp)
    800046e2:	6a06                	ld	s4,64(sp)
    800046e4:	7ae2                	ld	s5,56(sp)
    800046e6:	6165                	addi	sp,sp,112
    800046e8:	8082                	ret
      wakeup(&pi->nread);
    800046ea:	856a                	mv	a0,s10
    800046ec:	8bbfd0ef          	jal	80001fa6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800046f0:	85a6                	mv	a1,s1
    800046f2:	8566                	mv	a0,s9
    800046f4:	867fd0ef          	jal	80001f5a <sleep>
  while(i < n){
    800046f8:	05495a63          	bge	s2,s4,8000474c <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    800046fc:	2204a783          	lw	a5,544(s1)
    80004700:	d3f1                	beqz	a5,800046c4 <pipewrite+0x46>
    80004702:	854e                	mv	a0,s3
    80004704:	a93fd0ef          	jal	80002196 <killed>
    80004708:	fd55                	bnez	a0,800046c4 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000470a:	2184a783          	lw	a5,536(s1)
    8000470e:	21c4a703          	lw	a4,540(s1)
    80004712:	2007879b          	addiw	a5,a5,512
    80004716:	fcf70ae3          	beq	a4,a5,800046ea <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000471a:	86de                	mv	a3,s7
    8000471c:	01590633          	add	a2,s2,s5
    80004720:	85e2                	mv	a1,s8
    80004722:	0589b503          	ld	a0,88(s3)
    80004726:	fedfc0ef          	jal	80001712 <copyin>
    8000472a:	05650063          	beq	a0,s6,8000476a <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000472e:	21c4a783          	lw	a5,540(s1)
    80004732:	0017871b          	addiw	a4,a5,1
    80004736:	20e4ae23          	sw	a4,540(s1)
    8000473a:	1ff7f793          	andi	a5,a5,511
    8000473e:	97a6                	add	a5,a5,s1
    80004740:	f9f44703          	lbu	a4,-97(s0)
    80004744:	00e78c23          	sb	a4,24(a5)
      i++;
    80004748:	2905                	addiw	s2,s2,1
    8000474a:	b77d                	j	800046f8 <pipewrite+0x7a>
    8000474c:	7b42                	ld	s6,48(sp)
    8000474e:	7ba2                	ld	s7,40(sp)
    80004750:	7c02                	ld	s8,32(sp)
    80004752:	6ce2                	ld	s9,24(sp)
    80004754:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004756:	21848513          	addi	a0,s1,536
    8000475a:	84dfd0ef          	jal	80001fa6 <wakeup>
  release(&pi->lock);
    8000475e:	8526                	mv	a0,s1
    80004760:	d5cfc0ef          	jal	80000cbc <release>
  return i;
    80004764:	bf8d                	j	800046d6 <pipewrite+0x58>
  int i = 0;
    80004766:	4901                	li	s2,0
    80004768:	b7fd                	j	80004756 <pipewrite+0xd8>
    8000476a:	7b42                	ld	s6,48(sp)
    8000476c:	7ba2                	ld	s7,40(sp)
    8000476e:	7c02                	ld	s8,32(sp)
    80004770:	6ce2                	ld	s9,24(sp)
    80004772:	6d42                	ld	s10,16(sp)
    80004774:	b7cd                	j	80004756 <pipewrite+0xd8>

0000000080004776 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004776:	711d                	addi	sp,sp,-96
    80004778:	ec86                	sd	ra,88(sp)
    8000477a:	e8a2                	sd	s0,80(sp)
    8000477c:	e4a6                	sd	s1,72(sp)
    8000477e:	e0ca                	sd	s2,64(sp)
    80004780:	fc4e                	sd	s3,56(sp)
    80004782:	f852                	sd	s4,48(sp)
    80004784:	f456                	sd	s5,40(sp)
    80004786:	1080                	addi	s0,sp,96
    80004788:	84aa                	mv	s1,a0
    8000478a:	892e                	mv	s2,a1
    8000478c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000478e:	994fd0ef          	jal	80001922 <myproc>
    80004792:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004794:	8526                	mv	a0,s1
    80004796:	c92fc0ef          	jal	80000c28 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000479a:	2184a703          	lw	a4,536(s1)
    8000479e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800047a2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047a6:	02f71763          	bne	a4,a5,800047d4 <piperead+0x5e>
    800047aa:	2244a783          	lw	a5,548(s1)
    800047ae:	cf85                	beqz	a5,800047e6 <piperead+0x70>
    if(killed(pr)){
    800047b0:	8552                	mv	a0,s4
    800047b2:	9e5fd0ef          	jal	80002196 <killed>
    800047b6:	e11d                	bnez	a0,800047dc <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800047b8:	85a6                	mv	a1,s1
    800047ba:	854e                	mv	a0,s3
    800047bc:	f9efd0ef          	jal	80001f5a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047c0:	2184a703          	lw	a4,536(s1)
    800047c4:	21c4a783          	lw	a5,540(s1)
    800047c8:	fef701e3          	beq	a4,a5,800047aa <piperead+0x34>
    800047cc:	f05a                	sd	s6,32(sp)
    800047ce:	ec5e                	sd	s7,24(sp)
    800047d0:	e862                	sd	s8,16(sp)
    800047d2:	a829                	j	800047ec <piperead+0x76>
    800047d4:	f05a                	sd	s6,32(sp)
    800047d6:	ec5e                	sd	s7,24(sp)
    800047d8:	e862                	sd	s8,16(sp)
    800047da:	a809                	j	800047ec <piperead+0x76>
      release(&pi->lock);
    800047dc:	8526                	mv	a0,s1
    800047de:	cdefc0ef          	jal	80000cbc <release>
      return -1;
    800047e2:	59fd                	li	s3,-1
    800047e4:	a0a5                	j	8000484c <piperead+0xd6>
    800047e6:	f05a                	sd	s6,32(sp)
    800047e8:	ec5e                	sd	s7,24(sp)
    800047ea:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800047ec:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800047ee:	faf40c13          	addi	s8,s0,-81
    800047f2:	4b85                	li	s7,1
    800047f4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800047f6:	05505163          	blez	s5,80004838 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    800047fa:	2184a783          	lw	a5,536(s1)
    800047fe:	21c4a703          	lw	a4,540(s1)
    80004802:	02f70b63          	beq	a4,a5,80004838 <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004806:	1ff7f793          	andi	a5,a5,511
    8000480a:	97a6                	add	a5,a5,s1
    8000480c:	0187c783          	lbu	a5,24(a5)
    80004810:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004814:	86de                	mv	a3,s7
    80004816:	8662                	mv	a2,s8
    80004818:	85ca                	mv	a1,s2
    8000481a:	058a3503          	ld	a0,88(s4)
    8000481e:	e37fc0ef          	jal	80001654 <copyout>
    80004822:	03650f63          	beq	a0,s6,80004860 <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004826:	2184a783          	lw	a5,536(s1)
    8000482a:	2785                	addiw	a5,a5,1
    8000482c:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004830:	2985                	addiw	s3,s3,1
    80004832:	0905                	addi	s2,s2,1
    80004834:	fd3a93e3          	bne	s5,s3,800047fa <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004838:	21c48513          	addi	a0,s1,540
    8000483c:	f6afd0ef          	jal	80001fa6 <wakeup>
  release(&pi->lock);
    80004840:	8526                	mv	a0,s1
    80004842:	c7afc0ef          	jal	80000cbc <release>
    80004846:	7b02                	ld	s6,32(sp)
    80004848:	6be2                	ld	s7,24(sp)
    8000484a:	6c42                	ld	s8,16(sp)
  return i;
}
    8000484c:	854e                	mv	a0,s3
    8000484e:	60e6                	ld	ra,88(sp)
    80004850:	6446                	ld	s0,80(sp)
    80004852:	64a6                	ld	s1,72(sp)
    80004854:	6906                	ld	s2,64(sp)
    80004856:	79e2                	ld	s3,56(sp)
    80004858:	7a42                	ld	s4,48(sp)
    8000485a:	7aa2                	ld	s5,40(sp)
    8000485c:	6125                	addi	sp,sp,96
    8000485e:	8082                	ret
      if(i == 0)
    80004860:	fc099ce3          	bnez	s3,80004838 <piperead+0xc2>
        i = -1;
    80004864:	89aa                	mv	s3,a0
    80004866:	bfc9                	j	80004838 <piperead+0xc2>

0000000080004868 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004868:	1141                	addi	sp,sp,-16
    8000486a:	e406                	sd	ra,8(sp)
    8000486c:	e022                	sd	s0,0(sp)
    8000486e:	0800                	addi	s0,sp,16
    80004870:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004872:	0035151b          	slliw	a0,a0,0x3
    80004876:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004878:	8b89                	andi	a5,a5,2
    8000487a:	c399                	beqz	a5,80004880 <flags2perm+0x18>
      perm |= PTE_W;
    8000487c:	00456513          	ori	a0,a0,4
    return perm;
}
    80004880:	60a2                	ld	ra,8(sp)
    80004882:	6402                	ld	s0,0(sp)
    80004884:	0141                	addi	sp,sp,16
    80004886:	8082                	ret

0000000080004888 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004888:	de010113          	addi	sp,sp,-544
    8000488c:	20113c23          	sd	ra,536(sp)
    80004890:	20813823          	sd	s0,528(sp)
    80004894:	20913423          	sd	s1,520(sp)
    80004898:	21213023          	sd	s2,512(sp)
    8000489c:	1400                	addi	s0,sp,544
    8000489e:	892a                	mv	s2,a0
    800048a0:	dea43823          	sd	a0,-528(s0)
    800048a4:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800048a8:	87afd0ef          	jal	80001922 <myproc>
    800048ac:	84aa                	mv	s1,a0

  begin_op();
    800048ae:	d6aff0ef          	jal	80003e18 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800048b2:	854a                	mv	a0,s2
    800048b4:	b86ff0ef          	jal	80003c3a <namei>
    800048b8:	cd21                	beqz	a0,80004910 <kexec+0x88>
    800048ba:	fbd2                	sd	s4,496(sp)
    800048bc:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800048be:	b4ffe0ef          	jal	8000340c <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800048c2:	04000713          	li	a4,64
    800048c6:	4681                	li	a3,0
    800048c8:	e5040613          	addi	a2,s0,-432
    800048cc:	4581                	li	a1,0
    800048ce:	8552                	mv	a0,s4
    800048d0:	ecffe0ef          	jal	8000379e <readi>
    800048d4:	04000793          	li	a5,64
    800048d8:	00f51a63          	bne	a0,a5,800048ec <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800048dc:	e5042703          	lw	a4,-432(s0)
    800048e0:	464c47b7          	lui	a5,0x464c4
    800048e4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800048e8:	02f70863          	beq	a4,a5,80004918 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800048ec:	8552                	mv	a0,s4
    800048ee:	d2bfe0ef          	jal	80003618 <iunlockput>
    end_op();
    800048f2:	d96ff0ef          	jal	80003e88 <end_op>
  }
  return -1;
    800048f6:	557d                	li	a0,-1
    800048f8:	7a5e                	ld	s4,496(sp)
}
    800048fa:	21813083          	ld	ra,536(sp)
    800048fe:	21013403          	ld	s0,528(sp)
    80004902:	20813483          	ld	s1,520(sp)
    80004906:	20013903          	ld	s2,512(sp)
    8000490a:	22010113          	addi	sp,sp,544
    8000490e:	8082                	ret
    end_op();
    80004910:	d78ff0ef          	jal	80003e88 <end_op>
    return -1;
    80004914:	557d                	li	a0,-1
    80004916:	b7d5                	j	800048fa <kexec+0x72>
    80004918:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000491a:	8526                	mv	a0,s1
    8000491c:	910fd0ef          	jal	80001a2c <proc_pagetable>
    80004920:	8b2a                	mv	s6,a0
    80004922:	26050f63          	beqz	a0,80004ba0 <kexec+0x318>
    80004926:	ffce                	sd	s3,504(sp)
    80004928:	f7d6                	sd	s5,488(sp)
    8000492a:	efde                	sd	s7,472(sp)
    8000492c:	ebe2                	sd	s8,464(sp)
    8000492e:	e7e6                	sd	s9,456(sp)
    80004930:	e3ea                	sd	s10,448(sp)
    80004932:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004934:	e8845783          	lhu	a5,-376(s0)
    80004938:	0e078963          	beqz	a5,80004a2a <kexec+0x1a2>
    8000493c:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004940:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004942:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004944:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004948:	6c85                	lui	s9,0x1
    8000494a:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000494e:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004952:	6a85                	lui	s5,0x1
    80004954:	a085                	j	800049b4 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004956:	00003517          	auipc	a0,0x3
    8000495a:	c4a50513          	addi	a0,a0,-950 # 800075a0 <etext+0x5a0>
    8000495e:	ec7fb0ef          	jal	80000824 <panic>
    if(sz - i < PGSIZE)
    80004962:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004964:	874a                	mv	a4,s2
    80004966:	009b86bb          	addw	a3,s7,s1
    8000496a:	4581                	li	a1,0
    8000496c:	8552                	mv	a0,s4
    8000496e:	e31fe0ef          	jal	8000379e <readi>
    80004972:	22a91b63          	bne	s2,a0,80004ba8 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    80004976:	009a84bb          	addw	s1,s5,s1
    8000497a:	0334f263          	bgeu	s1,s3,8000499e <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    8000497e:	02049593          	slli	a1,s1,0x20
    80004982:	9181                	srli	a1,a1,0x20
    80004984:	95e2                	add	a1,a1,s8
    80004986:	855a                	mv	a0,s6
    80004988:	e9efc0ef          	jal	80001026 <walkaddr>
    8000498c:	862a                	mv	a2,a0
    if(pa == 0)
    8000498e:	d561                	beqz	a0,80004956 <kexec+0xce>
    if(sz - i < PGSIZE)
    80004990:	409987bb          	subw	a5,s3,s1
    80004994:	893e                	mv	s2,a5
    80004996:	fcfcf6e3          	bgeu	s9,a5,80004962 <kexec+0xda>
    8000499a:	8956                	mv	s2,s5
    8000499c:	b7d9                	j	80004962 <kexec+0xda>
    sz = sz1;
    8000499e:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049a2:	2d05                	addiw	s10,s10,1
    800049a4:	e0843783          	ld	a5,-504(s0)
    800049a8:	0387869b          	addiw	a3,a5,56
    800049ac:	e8845783          	lhu	a5,-376(s0)
    800049b0:	06fd5e63          	bge	s10,a5,80004a2c <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800049b4:	e0d43423          	sd	a3,-504(s0)
    800049b8:	876e                	mv	a4,s11
    800049ba:	e1840613          	addi	a2,s0,-488
    800049be:	4581                	li	a1,0
    800049c0:	8552                	mv	a0,s4
    800049c2:	dddfe0ef          	jal	8000379e <readi>
    800049c6:	1db51f63          	bne	a0,s11,80004ba4 <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    800049ca:	e1842783          	lw	a5,-488(s0)
    800049ce:	4705                	li	a4,1
    800049d0:	fce799e3          	bne	a5,a4,800049a2 <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    800049d4:	e4043483          	ld	s1,-448(s0)
    800049d8:	e3843783          	ld	a5,-456(s0)
    800049dc:	1ef4e463          	bltu	s1,a5,80004bc4 <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800049e0:	e2843783          	ld	a5,-472(s0)
    800049e4:	94be                	add	s1,s1,a5
    800049e6:	1ef4e263          	bltu	s1,a5,80004bca <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    800049ea:	de843703          	ld	a4,-536(s0)
    800049ee:	8ff9                	and	a5,a5,a4
    800049f0:	1e079063          	bnez	a5,80004bd0 <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800049f4:	e1c42503          	lw	a0,-484(s0)
    800049f8:	e71ff0ef          	jal	80004868 <flags2perm>
    800049fc:	86aa                	mv	a3,a0
    800049fe:	8626                	mv	a2,s1
    80004a00:	85ca                	mv	a1,s2
    80004a02:	855a                	mv	a0,s6
    80004a04:	8f9fc0ef          	jal	800012fc <uvmalloc>
    80004a08:	dea43c23          	sd	a0,-520(s0)
    80004a0c:	1c050563          	beqz	a0,80004bd6 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a10:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004a14:	00098863          	beqz	s3,80004a24 <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a18:	e2843c03          	ld	s8,-472(s0)
    80004a1c:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004a20:	4481                	li	s1,0
    80004a22:	bfb1                	j	8000497e <kexec+0xf6>
    sz = sz1;
    80004a24:	df843903          	ld	s2,-520(s0)
    80004a28:	bfad                	j	800049a2 <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a2a:	4901                	li	s2,0
  iunlockput(ip);
    80004a2c:	8552                	mv	a0,s4
    80004a2e:	bebfe0ef          	jal	80003618 <iunlockput>
  end_op();
    80004a32:	c56ff0ef          	jal	80003e88 <end_op>
  p = myproc();
    80004a36:	eedfc0ef          	jal	80001922 <myproc>
    80004a3a:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004a3c:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80004a40:	6985                	lui	s3,0x1
    80004a42:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004a44:	99ca                	add	s3,s3,s2
    80004a46:	77fd                	lui	a5,0xfffff
    80004a48:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004a4c:	4691                	li	a3,4
    80004a4e:	6609                	lui	a2,0x2
    80004a50:	964e                	add	a2,a2,s3
    80004a52:	85ce                	mv	a1,s3
    80004a54:	855a                	mv	a0,s6
    80004a56:	8a7fc0ef          	jal	800012fc <uvmalloc>
    80004a5a:	8a2a                	mv	s4,a0
    80004a5c:	e105                	bnez	a0,80004a7c <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004a5e:	85ce                	mv	a1,s3
    80004a60:	855a                	mv	a0,s6
    80004a62:	84efd0ef          	jal	80001ab0 <proc_freepagetable>
  return -1;
    80004a66:	557d                	li	a0,-1
    80004a68:	79fe                	ld	s3,504(sp)
    80004a6a:	7a5e                	ld	s4,496(sp)
    80004a6c:	7abe                	ld	s5,488(sp)
    80004a6e:	7b1e                	ld	s6,480(sp)
    80004a70:	6bfe                	ld	s7,472(sp)
    80004a72:	6c5e                	ld	s8,464(sp)
    80004a74:	6cbe                	ld	s9,456(sp)
    80004a76:	6d1e                	ld	s10,448(sp)
    80004a78:	7dfa                	ld	s11,440(sp)
    80004a7a:	b541                	j	800048fa <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004a7c:	75f9                	lui	a1,0xffffe
    80004a7e:	95aa                	add	a1,a1,a0
    80004a80:	855a                	mv	a0,s6
    80004a82:	a4dfc0ef          	jal	800014ce <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004a86:	800a0b93          	addi	s7,s4,-2048
    80004a8a:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80004a8e:	e0043783          	ld	a5,-512(s0)
    80004a92:	6388                	ld	a0,0(a5)
  sp = sz;
    80004a94:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004a96:	4481                	li	s1,0
    ustack[argc] = sp;
    80004a98:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004a9c:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004aa0:	cd21                	beqz	a0,80004af8 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004aa2:	be0fc0ef          	jal	80000e82 <strlen>
    80004aa6:	0015079b          	addiw	a5,a0,1
    80004aaa:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004aae:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004ab2:	13796563          	bltu	s2,s7,80004bdc <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ab6:	e0043d83          	ld	s11,-512(s0)
    80004aba:	000db983          	ld	s3,0(s11)
    80004abe:	854e                	mv	a0,s3
    80004ac0:	bc2fc0ef          	jal	80000e82 <strlen>
    80004ac4:	0015069b          	addiw	a3,a0,1
    80004ac8:	864e                	mv	a2,s3
    80004aca:	85ca                	mv	a1,s2
    80004acc:	855a                	mv	a0,s6
    80004ace:	b87fc0ef          	jal	80001654 <copyout>
    80004ad2:	10054763          	bltz	a0,80004be0 <kexec+0x358>
    ustack[argc] = sp;
    80004ad6:	00349793          	slli	a5,s1,0x3
    80004ada:	97e6                	add	a5,a5,s9
    80004adc:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffde078>
  for(argc = 0; argv[argc]; argc++) {
    80004ae0:	0485                	addi	s1,s1,1
    80004ae2:	008d8793          	addi	a5,s11,8
    80004ae6:	e0f43023          	sd	a5,-512(s0)
    80004aea:	008db503          	ld	a0,8(s11)
    80004aee:	c509                	beqz	a0,80004af8 <kexec+0x270>
    if(argc >= MAXARG)
    80004af0:	fb8499e3          	bne	s1,s8,80004aa2 <kexec+0x21a>
  sz = sz1;
    80004af4:	89d2                	mv	s3,s4
    80004af6:	b7a5                	j	80004a5e <kexec+0x1d6>
  ustack[argc] = 0;
    80004af8:	00349793          	slli	a5,s1,0x3
    80004afc:	f9078793          	addi	a5,a5,-112
    80004b00:	97a2                	add	a5,a5,s0
    80004b02:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004b06:	00349693          	slli	a3,s1,0x3
    80004b0a:	06a1                	addi	a3,a3,8
    80004b0c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004b10:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004b14:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004b16:	f57964e3          	bltu	s2,s7,80004a5e <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004b1a:	e9040613          	addi	a2,s0,-368
    80004b1e:	85ca                	mv	a1,s2
    80004b20:	855a                	mv	a0,s6
    80004b22:	b33fc0ef          	jal	80001654 <copyout>
    80004b26:	f2054ce3          	bltz	a0,80004a5e <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004b2a:	060ab783          	ld	a5,96(s5) # 1060 <_entry-0x7fffefa0>
    80004b2e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004b32:	df043783          	ld	a5,-528(s0)
    80004b36:	0007c703          	lbu	a4,0(a5)
    80004b3a:	cf11                	beqz	a4,80004b56 <kexec+0x2ce>
    80004b3c:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004b3e:	02f00693          	li	a3,47
    80004b42:	a029                	j	80004b4c <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80004b44:	0785                	addi	a5,a5,1
    80004b46:	fff7c703          	lbu	a4,-1(a5)
    80004b4a:	c711                	beqz	a4,80004b56 <kexec+0x2ce>
    if(*s == '/')
    80004b4c:	fed71ce3          	bne	a4,a3,80004b44 <kexec+0x2bc>
      last = s+1;
    80004b50:	def43823          	sd	a5,-528(s0)
    80004b54:	bfc5                	j	80004b44 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004b56:	4641                	li	a2,16
    80004b58:	df043583          	ld	a1,-528(s0)
    80004b5c:	160a8513          	addi	a0,s5,352
    80004b60:	aecfc0ef          	jal	80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    80004b64:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80004b68:	056abc23          	sd	s6,88(s5)
  p->sz = sz;
    80004b6c:	054ab823          	sd	s4,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004b70:	060ab783          	ld	a5,96(s5)
    80004b74:	e6843703          	ld	a4,-408(s0)
    80004b78:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004b7a:	060ab783          	ld	a5,96(s5)
    80004b7e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004b82:	85ea                	mv	a1,s10
    80004b84:	f2dfc0ef          	jal	80001ab0 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004b88:	0004851b          	sext.w	a0,s1
    80004b8c:	79fe                	ld	s3,504(sp)
    80004b8e:	7a5e                	ld	s4,496(sp)
    80004b90:	7abe                	ld	s5,488(sp)
    80004b92:	7b1e                	ld	s6,480(sp)
    80004b94:	6bfe                	ld	s7,472(sp)
    80004b96:	6c5e                	ld	s8,464(sp)
    80004b98:	6cbe                	ld	s9,456(sp)
    80004b9a:	6d1e                	ld	s10,448(sp)
    80004b9c:	7dfa                	ld	s11,440(sp)
    80004b9e:	bbb1                	j	800048fa <kexec+0x72>
    80004ba0:	7b1e                	ld	s6,480(sp)
    80004ba2:	b3a9                	j	800048ec <kexec+0x64>
    80004ba4:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004ba8:	df843583          	ld	a1,-520(s0)
    80004bac:	855a                	mv	a0,s6
    80004bae:	f03fc0ef          	jal	80001ab0 <proc_freepagetable>
  if(ip){
    80004bb2:	79fe                	ld	s3,504(sp)
    80004bb4:	7abe                	ld	s5,488(sp)
    80004bb6:	7b1e                	ld	s6,480(sp)
    80004bb8:	6bfe                	ld	s7,472(sp)
    80004bba:	6c5e                	ld	s8,464(sp)
    80004bbc:	6cbe                	ld	s9,456(sp)
    80004bbe:	6d1e                	ld	s10,448(sp)
    80004bc0:	7dfa                	ld	s11,440(sp)
    80004bc2:	b32d                	j	800048ec <kexec+0x64>
    80004bc4:	df243c23          	sd	s2,-520(s0)
    80004bc8:	b7c5                	j	80004ba8 <kexec+0x320>
    80004bca:	df243c23          	sd	s2,-520(s0)
    80004bce:	bfe9                	j	80004ba8 <kexec+0x320>
    80004bd0:	df243c23          	sd	s2,-520(s0)
    80004bd4:	bfd1                	j	80004ba8 <kexec+0x320>
    80004bd6:	df243c23          	sd	s2,-520(s0)
    80004bda:	b7f9                	j	80004ba8 <kexec+0x320>
  sz = sz1;
    80004bdc:	89d2                	mv	s3,s4
    80004bde:	b541                	j	80004a5e <kexec+0x1d6>
    80004be0:	89d2                	mv	s3,s4
    80004be2:	bdb5                	j	80004a5e <kexec+0x1d6>

0000000080004be4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004be4:	7179                	addi	sp,sp,-48
    80004be6:	f406                	sd	ra,40(sp)
    80004be8:	f022                	sd	s0,32(sp)
    80004bea:	ec26                	sd	s1,24(sp)
    80004bec:	e84a                	sd	s2,16(sp)
    80004bee:	1800                	addi	s0,sp,48
    80004bf0:	892e                	mv	s2,a1
    80004bf2:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004bf4:	fdc40593          	addi	a1,s0,-36
    80004bf8:	c6ffd0ef          	jal	80002866 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004bfc:	fdc42703          	lw	a4,-36(s0)
    80004c00:	47bd                	li	a5,15
    80004c02:	02e7ea63          	bltu	a5,a4,80004c36 <argfd+0x52>
    80004c06:	d1dfc0ef          	jal	80001922 <myproc>
    80004c0a:	fdc42703          	lw	a4,-36(s0)
    80004c0e:	00371793          	slli	a5,a4,0x3
    80004c12:	0d078793          	addi	a5,a5,208
    80004c16:	953e                	add	a0,a0,a5
    80004c18:	651c                	ld	a5,8(a0)
    80004c1a:	c385                	beqz	a5,80004c3a <argfd+0x56>
    return -1;
  if(pfd)
    80004c1c:	00090463          	beqz	s2,80004c24 <argfd+0x40>
    *pfd = fd;
    80004c20:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004c24:	4501                	li	a0,0
  if(pf)
    80004c26:	c091                	beqz	s1,80004c2a <argfd+0x46>
    *pf = f;
    80004c28:	e09c                	sd	a5,0(s1)
}
    80004c2a:	70a2                	ld	ra,40(sp)
    80004c2c:	7402                	ld	s0,32(sp)
    80004c2e:	64e2                	ld	s1,24(sp)
    80004c30:	6942                	ld	s2,16(sp)
    80004c32:	6145                	addi	sp,sp,48
    80004c34:	8082                	ret
    return -1;
    80004c36:	557d                	li	a0,-1
    80004c38:	bfcd                	j	80004c2a <argfd+0x46>
    80004c3a:	557d                	li	a0,-1
    80004c3c:	b7fd                	j	80004c2a <argfd+0x46>

0000000080004c3e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004c3e:	1101                	addi	sp,sp,-32
    80004c40:	ec06                	sd	ra,24(sp)
    80004c42:	e822                	sd	s0,16(sp)
    80004c44:	e426                	sd	s1,8(sp)
    80004c46:	1000                	addi	s0,sp,32
    80004c48:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004c4a:	cd9fc0ef          	jal	80001922 <myproc>
    80004c4e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004c50:	0d850793          	addi	a5,a0,216
    80004c54:	4501                	li	a0,0
    80004c56:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004c58:	6398                	ld	a4,0(a5)
    80004c5a:	cb19                	beqz	a4,80004c70 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004c5c:	2505                	addiw	a0,a0,1
    80004c5e:	07a1                	addi	a5,a5,8
    80004c60:	fed51ce3          	bne	a0,a3,80004c58 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004c64:	557d                	li	a0,-1
}
    80004c66:	60e2                	ld	ra,24(sp)
    80004c68:	6442                	ld	s0,16(sp)
    80004c6a:	64a2                	ld	s1,8(sp)
    80004c6c:	6105                	addi	sp,sp,32
    80004c6e:	8082                	ret
      p->ofile[fd] = f;
    80004c70:	00351793          	slli	a5,a0,0x3
    80004c74:	0d078793          	addi	a5,a5,208
    80004c78:	963e                	add	a2,a2,a5
    80004c7a:	e604                	sd	s1,8(a2)
      return fd;
    80004c7c:	b7ed                	j	80004c66 <fdalloc+0x28>

0000000080004c7e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004c7e:	715d                	addi	sp,sp,-80
    80004c80:	e486                	sd	ra,72(sp)
    80004c82:	e0a2                	sd	s0,64(sp)
    80004c84:	fc26                	sd	s1,56(sp)
    80004c86:	f84a                	sd	s2,48(sp)
    80004c88:	f44e                	sd	s3,40(sp)
    80004c8a:	f052                	sd	s4,32(sp)
    80004c8c:	ec56                	sd	s5,24(sp)
    80004c8e:	e85a                	sd	s6,16(sp)
    80004c90:	0880                	addi	s0,sp,80
    80004c92:	892e                	mv	s2,a1
    80004c94:	8a2e                	mv	s4,a1
    80004c96:	8ab2                	mv	s5,a2
    80004c98:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004c9a:	fb040593          	addi	a1,s0,-80
    80004c9e:	fb7fe0ef          	jal	80003c54 <nameiparent>
    80004ca2:	84aa                	mv	s1,a0
    80004ca4:	10050763          	beqz	a0,80004db2 <create+0x134>
    return 0;

  ilock(dp);
    80004ca8:	f64fe0ef          	jal	8000340c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004cac:	4601                	li	a2,0
    80004cae:	fb040593          	addi	a1,s0,-80
    80004cb2:	8526                	mv	a0,s1
    80004cb4:	cf3fe0ef          	jal	800039a6 <dirlookup>
    80004cb8:	89aa                	mv	s3,a0
    80004cba:	c131                	beqz	a0,80004cfe <create+0x80>
    iunlockput(dp);
    80004cbc:	8526                	mv	a0,s1
    80004cbe:	95bfe0ef          	jal	80003618 <iunlockput>
    ilock(ip);
    80004cc2:	854e                	mv	a0,s3
    80004cc4:	f48fe0ef          	jal	8000340c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004cc8:	4789                	li	a5,2
    80004cca:	02f91563          	bne	s2,a5,80004cf4 <create+0x76>
    80004cce:	0449d783          	lhu	a5,68(s3)
    80004cd2:	37f9                	addiw	a5,a5,-2
    80004cd4:	17c2                	slli	a5,a5,0x30
    80004cd6:	93c1                	srli	a5,a5,0x30
    80004cd8:	4705                	li	a4,1
    80004cda:	00f76d63          	bltu	a4,a5,80004cf4 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004cde:	854e                	mv	a0,s3
    80004ce0:	60a6                	ld	ra,72(sp)
    80004ce2:	6406                	ld	s0,64(sp)
    80004ce4:	74e2                	ld	s1,56(sp)
    80004ce6:	7942                	ld	s2,48(sp)
    80004ce8:	79a2                	ld	s3,40(sp)
    80004cea:	7a02                	ld	s4,32(sp)
    80004cec:	6ae2                	ld	s5,24(sp)
    80004cee:	6b42                	ld	s6,16(sp)
    80004cf0:	6161                	addi	sp,sp,80
    80004cf2:	8082                	ret
    iunlockput(ip);
    80004cf4:	854e                	mv	a0,s3
    80004cf6:	923fe0ef          	jal	80003618 <iunlockput>
    return 0;
    80004cfa:	4981                	li	s3,0
    80004cfc:	b7cd                	j	80004cde <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004cfe:	85ca                	mv	a1,s2
    80004d00:	4088                	lw	a0,0(s1)
    80004d02:	d9afe0ef          	jal	8000329c <ialloc>
    80004d06:	892a                	mv	s2,a0
    80004d08:	cd15                	beqz	a0,80004d44 <create+0xc6>
  ilock(ip);
    80004d0a:	f02fe0ef          	jal	8000340c <ilock>
  ip->major = major;
    80004d0e:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80004d12:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80004d16:	4785                	li	a5,1
    80004d18:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004d1c:	854a                	mv	a0,s2
    80004d1e:	e3afe0ef          	jal	80003358 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004d22:	4705                	li	a4,1
    80004d24:	02ea0463          	beq	s4,a4,80004d4c <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004d28:	00492603          	lw	a2,4(s2)
    80004d2c:	fb040593          	addi	a1,s0,-80
    80004d30:	8526                	mv	a0,s1
    80004d32:	e5ffe0ef          	jal	80003b90 <dirlink>
    80004d36:	06054263          	bltz	a0,80004d9a <create+0x11c>
  iunlockput(dp);
    80004d3a:	8526                	mv	a0,s1
    80004d3c:	8ddfe0ef          	jal	80003618 <iunlockput>
  return ip;
    80004d40:	89ca                	mv	s3,s2
    80004d42:	bf71                	j	80004cde <create+0x60>
    iunlockput(dp);
    80004d44:	8526                	mv	a0,s1
    80004d46:	8d3fe0ef          	jal	80003618 <iunlockput>
    return 0;
    80004d4a:	bf51                	j	80004cde <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004d4c:	00492603          	lw	a2,4(s2)
    80004d50:	00003597          	auipc	a1,0x3
    80004d54:	87058593          	addi	a1,a1,-1936 # 800075c0 <etext+0x5c0>
    80004d58:	854a                	mv	a0,s2
    80004d5a:	e37fe0ef          	jal	80003b90 <dirlink>
    80004d5e:	02054e63          	bltz	a0,80004d9a <create+0x11c>
    80004d62:	40d0                	lw	a2,4(s1)
    80004d64:	00003597          	auipc	a1,0x3
    80004d68:	86458593          	addi	a1,a1,-1948 # 800075c8 <etext+0x5c8>
    80004d6c:	854a                	mv	a0,s2
    80004d6e:	e23fe0ef          	jal	80003b90 <dirlink>
    80004d72:	02054463          	bltz	a0,80004d9a <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004d76:	00492603          	lw	a2,4(s2)
    80004d7a:	fb040593          	addi	a1,s0,-80
    80004d7e:	8526                	mv	a0,s1
    80004d80:	e11fe0ef          	jal	80003b90 <dirlink>
    80004d84:	00054b63          	bltz	a0,80004d9a <create+0x11c>
    dp->nlink++;  // for ".."
    80004d88:	04a4d783          	lhu	a5,74(s1)
    80004d8c:	2785                	addiw	a5,a5,1
    80004d8e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004d92:	8526                	mv	a0,s1
    80004d94:	dc4fe0ef          	jal	80003358 <iupdate>
    80004d98:	b74d                	j	80004d3a <create+0xbc>
  ip->nlink = 0;
    80004d9a:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80004d9e:	854a                	mv	a0,s2
    80004da0:	db8fe0ef          	jal	80003358 <iupdate>
  iunlockput(ip);
    80004da4:	854a                	mv	a0,s2
    80004da6:	873fe0ef          	jal	80003618 <iunlockput>
  iunlockput(dp);
    80004daa:	8526                	mv	a0,s1
    80004dac:	86dfe0ef          	jal	80003618 <iunlockput>
  return 0;
    80004db0:	b73d                	j	80004cde <create+0x60>
    return 0;
    80004db2:	89aa                	mv	s3,a0
    80004db4:	b72d                	j	80004cde <create+0x60>

0000000080004db6 <sys_dup>:
{
    80004db6:	7179                	addi	sp,sp,-48
    80004db8:	f406                	sd	ra,40(sp)
    80004dba:	f022                	sd	s0,32(sp)
    80004dbc:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004dbe:	fd840613          	addi	a2,s0,-40
    80004dc2:	4581                	li	a1,0
    80004dc4:	4501                	li	a0,0
    80004dc6:	e1fff0ef          	jal	80004be4 <argfd>
    return -1;
    80004dca:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004dcc:	02054363          	bltz	a0,80004df2 <sys_dup+0x3c>
    80004dd0:	ec26                	sd	s1,24(sp)
    80004dd2:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004dd4:	fd843483          	ld	s1,-40(s0)
    80004dd8:	8526                	mv	a0,s1
    80004dda:	e65ff0ef          	jal	80004c3e <fdalloc>
    80004dde:	892a                	mv	s2,a0
    return -1;
    80004de0:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004de2:	00054d63          	bltz	a0,80004dfc <sys_dup+0x46>
  filedup(f);
    80004de6:	8526                	mv	a0,s1
    80004de8:	c0eff0ef          	jal	800041f6 <filedup>
  return fd;
    80004dec:	87ca                	mv	a5,s2
    80004dee:	64e2                	ld	s1,24(sp)
    80004df0:	6942                	ld	s2,16(sp)
}
    80004df2:	853e                	mv	a0,a5
    80004df4:	70a2                	ld	ra,40(sp)
    80004df6:	7402                	ld	s0,32(sp)
    80004df8:	6145                	addi	sp,sp,48
    80004dfa:	8082                	ret
    80004dfc:	64e2                	ld	s1,24(sp)
    80004dfe:	6942                	ld	s2,16(sp)
    80004e00:	bfcd                	j	80004df2 <sys_dup+0x3c>

0000000080004e02 <sys_read>:
{
    80004e02:	7179                	addi	sp,sp,-48
    80004e04:	f406                	sd	ra,40(sp)
    80004e06:	f022                	sd	s0,32(sp)
    80004e08:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e0a:	fd840593          	addi	a1,s0,-40
    80004e0e:	4505                	li	a0,1
    80004e10:	a73fd0ef          	jal	80002882 <argaddr>
  argint(2, &n);
    80004e14:	fe440593          	addi	a1,s0,-28
    80004e18:	4509                	li	a0,2
    80004e1a:	a4dfd0ef          	jal	80002866 <argint>
  if(argfd(0, 0, &f) < 0)
    80004e1e:	fe840613          	addi	a2,s0,-24
    80004e22:	4581                	li	a1,0
    80004e24:	4501                	li	a0,0
    80004e26:	dbfff0ef          	jal	80004be4 <argfd>
    80004e2a:	87aa                	mv	a5,a0
    return -1;
    80004e2c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e2e:	0007ca63          	bltz	a5,80004e42 <sys_read+0x40>
  return fileread(f, p, n);
    80004e32:	fe442603          	lw	a2,-28(s0)
    80004e36:	fd843583          	ld	a1,-40(s0)
    80004e3a:	fe843503          	ld	a0,-24(s0)
    80004e3e:	d22ff0ef          	jal	80004360 <fileread>
}
    80004e42:	70a2                	ld	ra,40(sp)
    80004e44:	7402                	ld	s0,32(sp)
    80004e46:	6145                	addi	sp,sp,48
    80004e48:	8082                	ret

0000000080004e4a <sys_write>:
{
    80004e4a:	7179                	addi	sp,sp,-48
    80004e4c:	f406                	sd	ra,40(sp)
    80004e4e:	f022                	sd	s0,32(sp)
    80004e50:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e52:	fd840593          	addi	a1,s0,-40
    80004e56:	4505                	li	a0,1
    80004e58:	a2bfd0ef          	jal	80002882 <argaddr>
  argint(2, &n);
    80004e5c:	fe440593          	addi	a1,s0,-28
    80004e60:	4509                	li	a0,2
    80004e62:	a05fd0ef          	jal	80002866 <argint>
  if(argfd(0, 0, &f) < 0)
    80004e66:	fe840613          	addi	a2,s0,-24
    80004e6a:	4581                	li	a1,0
    80004e6c:	4501                	li	a0,0
    80004e6e:	d77ff0ef          	jal	80004be4 <argfd>
    80004e72:	87aa                	mv	a5,a0
    return -1;
    80004e74:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e76:	0007ca63          	bltz	a5,80004e8a <sys_write+0x40>
  return filewrite(f, p, n);
    80004e7a:	fe442603          	lw	a2,-28(s0)
    80004e7e:	fd843583          	ld	a1,-40(s0)
    80004e82:	fe843503          	ld	a0,-24(s0)
    80004e86:	d9eff0ef          	jal	80004424 <filewrite>
}
    80004e8a:	70a2                	ld	ra,40(sp)
    80004e8c:	7402                	ld	s0,32(sp)
    80004e8e:	6145                	addi	sp,sp,48
    80004e90:	8082                	ret

0000000080004e92 <sys_close>:
{
    80004e92:	1101                	addi	sp,sp,-32
    80004e94:	ec06                	sd	ra,24(sp)
    80004e96:	e822                	sd	s0,16(sp)
    80004e98:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004e9a:	fe040613          	addi	a2,s0,-32
    80004e9e:	fec40593          	addi	a1,s0,-20
    80004ea2:	4501                	li	a0,0
    80004ea4:	d41ff0ef          	jal	80004be4 <argfd>
    return -1;
    80004ea8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004eaa:	02054163          	bltz	a0,80004ecc <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004eae:	a75fc0ef          	jal	80001922 <myproc>
    80004eb2:	fec42783          	lw	a5,-20(s0)
    80004eb6:	078e                	slli	a5,a5,0x3
    80004eb8:	0d078793          	addi	a5,a5,208
    80004ebc:	953e                	add	a0,a0,a5
    80004ebe:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80004ec2:	fe043503          	ld	a0,-32(s0)
    80004ec6:	b76ff0ef          	jal	8000423c <fileclose>
  return 0;
    80004eca:	4781                	li	a5,0
}
    80004ecc:	853e                	mv	a0,a5
    80004ece:	60e2                	ld	ra,24(sp)
    80004ed0:	6442                	ld	s0,16(sp)
    80004ed2:	6105                	addi	sp,sp,32
    80004ed4:	8082                	ret

0000000080004ed6 <sys_fstat>:
{
    80004ed6:	1101                	addi	sp,sp,-32
    80004ed8:	ec06                	sd	ra,24(sp)
    80004eda:	e822                	sd	s0,16(sp)
    80004edc:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004ede:	fe040593          	addi	a1,s0,-32
    80004ee2:	4505                	li	a0,1
    80004ee4:	99ffd0ef          	jal	80002882 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004ee8:	fe840613          	addi	a2,s0,-24
    80004eec:	4581                	li	a1,0
    80004eee:	4501                	li	a0,0
    80004ef0:	cf5ff0ef          	jal	80004be4 <argfd>
    80004ef4:	87aa                	mv	a5,a0
    return -1;
    80004ef6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ef8:	0007c863          	bltz	a5,80004f08 <sys_fstat+0x32>
  return filestat(f, st);
    80004efc:	fe043583          	ld	a1,-32(s0)
    80004f00:	fe843503          	ld	a0,-24(s0)
    80004f04:	bfaff0ef          	jal	800042fe <filestat>
}
    80004f08:	60e2                	ld	ra,24(sp)
    80004f0a:	6442                	ld	s0,16(sp)
    80004f0c:	6105                	addi	sp,sp,32
    80004f0e:	8082                	ret

0000000080004f10 <sys_link>:
{
    80004f10:	7169                	addi	sp,sp,-304
    80004f12:	f606                	sd	ra,296(sp)
    80004f14:	f222                	sd	s0,288(sp)
    80004f16:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f18:	08000613          	li	a2,128
    80004f1c:	ed040593          	addi	a1,s0,-304
    80004f20:	4501                	li	a0,0
    80004f22:	97dfd0ef          	jal	8000289e <argstr>
    return -1;
    80004f26:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f28:	0c054e63          	bltz	a0,80005004 <sys_link+0xf4>
    80004f2c:	08000613          	li	a2,128
    80004f30:	f5040593          	addi	a1,s0,-176
    80004f34:	4505                	li	a0,1
    80004f36:	969fd0ef          	jal	8000289e <argstr>
    return -1;
    80004f3a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f3c:	0c054463          	bltz	a0,80005004 <sys_link+0xf4>
    80004f40:	ee26                	sd	s1,280(sp)
  begin_op();
    80004f42:	ed7fe0ef          	jal	80003e18 <begin_op>
  if((ip = namei(old)) == 0){
    80004f46:	ed040513          	addi	a0,s0,-304
    80004f4a:	cf1fe0ef          	jal	80003c3a <namei>
    80004f4e:	84aa                	mv	s1,a0
    80004f50:	c53d                	beqz	a0,80004fbe <sys_link+0xae>
  ilock(ip);
    80004f52:	cbafe0ef          	jal	8000340c <ilock>
  if(ip->type == T_DIR){
    80004f56:	04449703          	lh	a4,68(s1)
    80004f5a:	4785                	li	a5,1
    80004f5c:	06f70663          	beq	a4,a5,80004fc8 <sys_link+0xb8>
    80004f60:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004f62:	04a4d783          	lhu	a5,74(s1)
    80004f66:	2785                	addiw	a5,a5,1
    80004f68:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f6c:	8526                	mv	a0,s1
    80004f6e:	beafe0ef          	jal	80003358 <iupdate>
  iunlock(ip);
    80004f72:	8526                	mv	a0,s1
    80004f74:	d46fe0ef          	jal	800034ba <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004f78:	fd040593          	addi	a1,s0,-48
    80004f7c:	f5040513          	addi	a0,s0,-176
    80004f80:	cd5fe0ef          	jal	80003c54 <nameiparent>
    80004f84:	892a                	mv	s2,a0
    80004f86:	cd21                	beqz	a0,80004fde <sys_link+0xce>
  ilock(dp);
    80004f88:	c84fe0ef          	jal	8000340c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004f8c:	854a                	mv	a0,s2
    80004f8e:	00092703          	lw	a4,0(s2)
    80004f92:	409c                	lw	a5,0(s1)
    80004f94:	04f71263          	bne	a4,a5,80004fd8 <sys_link+0xc8>
    80004f98:	40d0                	lw	a2,4(s1)
    80004f9a:	fd040593          	addi	a1,s0,-48
    80004f9e:	bf3fe0ef          	jal	80003b90 <dirlink>
    80004fa2:	02054b63          	bltz	a0,80004fd8 <sys_link+0xc8>
  iunlockput(dp);
    80004fa6:	854a                	mv	a0,s2
    80004fa8:	e70fe0ef          	jal	80003618 <iunlockput>
  iput(ip);
    80004fac:	8526                	mv	a0,s1
    80004fae:	de0fe0ef          	jal	8000358e <iput>
  end_op();
    80004fb2:	ed7fe0ef          	jal	80003e88 <end_op>
  return 0;
    80004fb6:	4781                	li	a5,0
    80004fb8:	64f2                	ld	s1,280(sp)
    80004fba:	6952                	ld	s2,272(sp)
    80004fbc:	a0a1                	j	80005004 <sys_link+0xf4>
    end_op();
    80004fbe:	ecbfe0ef          	jal	80003e88 <end_op>
    return -1;
    80004fc2:	57fd                	li	a5,-1
    80004fc4:	64f2                	ld	s1,280(sp)
    80004fc6:	a83d                	j	80005004 <sys_link+0xf4>
    iunlockput(ip);
    80004fc8:	8526                	mv	a0,s1
    80004fca:	e4efe0ef          	jal	80003618 <iunlockput>
    end_op();
    80004fce:	ebbfe0ef          	jal	80003e88 <end_op>
    return -1;
    80004fd2:	57fd                	li	a5,-1
    80004fd4:	64f2                	ld	s1,280(sp)
    80004fd6:	a03d                	j	80005004 <sys_link+0xf4>
    iunlockput(dp);
    80004fd8:	854a                	mv	a0,s2
    80004fda:	e3efe0ef          	jal	80003618 <iunlockput>
  ilock(ip);
    80004fde:	8526                	mv	a0,s1
    80004fe0:	c2cfe0ef          	jal	8000340c <ilock>
  ip->nlink--;
    80004fe4:	04a4d783          	lhu	a5,74(s1)
    80004fe8:	37fd                	addiw	a5,a5,-1
    80004fea:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004fee:	8526                	mv	a0,s1
    80004ff0:	b68fe0ef          	jal	80003358 <iupdate>
  iunlockput(ip);
    80004ff4:	8526                	mv	a0,s1
    80004ff6:	e22fe0ef          	jal	80003618 <iunlockput>
  end_op();
    80004ffa:	e8ffe0ef          	jal	80003e88 <end_op>
  return -1;
    80004ffe:	57fd                	li	a5,-1
    80005000:	64f2                	ld	s1,280(sp)
    80005002:	6952                	ld	s2,272(sp)
}
    80005004:	853e                	mv	a0,a5
    80005006:	70b2                	ld	ra,296(sp)
    80005008:	7412                	ld	s0,288(sp)
    8000500a:	6155                	addi	sp,sp,304
    8000500c:	8082                	ret

000000008000500e <sys_unlink>:
{
    8000500e:	7151                	addi	sp,sp,-240
    80005010:	f586                	sd	ra,232(sp)
    80005012:	f1a2                	sd	s0,224(sp)
    80005014:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005016:	08000613          	li	a2,128
    8000501a:	f3040593          	addi	a1,s0,-208
    8000501e:	4501                	li	a0,0
    80005020:	87ffd0ef          	jal	8000289e <argstr>
    80005024:	14054d63          	bltz	a0,8000517e <sys_unlink+0x170>
    80005028:	eda6                	sd	s1,216(sp)
  begin_op();
    8000502a:	deffe0ef          	jal	80003e18 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000502e:	fb040593          	addi	a1,s0,-80
    80005032:	f3040513          	addi	a0,s0,-208
    80005036:	c1ffe0ef          	jal	80003c54 <nameiparent>
    8000503a:	84aa                	mv	s1,a0
    8000503c:	c955                	beqz	a0,800050f0 <sys_unlink+0xe2>
  ilock(dp);
    8000503e:	bcefe0ef          	jal	8000340c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005042:	00002597          	auipc	a1,0x2
    80005046:	57e58593          	addi	a1,a1,1406 # 800075c0 <etext+0x5c0>
    8000504a:	fb040513          	addi	a0,s0,-80
    8000504e:	943fe0ef          	jal	80003990 <namecmp>
    80005052:	10050b63          	beqz	a0,80005168 <sys_unlink+0x15a>
    80005056:	00002597          	auipc	a1,0x2
    8000505a:	57258593          	addi	a1,a1,1394 # 800075c8 <etext+0x5c8>
    8000505e:	fb040513          	addi	a0,s0,-80
    80005062:	92ffe0ef          	jal	80003990 <namecmp>
    80005066:	10050163          	beqz	a0,80005168 <sys_unlink+0x15a>
    8000506a:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000506c:	f2c40613          	addi	a2,s0,-212
    80005070:	fb040593          	addi	a1,s0,-80
    80005074:	8526                	mv	a0,s1
    80005076:	931fe0ef          	jal	800039a6 <dirlookup>
    8000507a:	892a                	mv	s2,a0
    8000507c:	0e050563          	beqz	a0,80005166 <sys_unlink+0x158>
    80005080:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005082:	b8afe0ef          	jal	8000340c <ilock>
  if(ip->nlink < 1)
    80005086:	04a91783          	lh	a5,74(s2)
    8000508a:	06f05863          	blez	a5,800050fa <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000508e:	04491703          	lh	a4,68(s2)
    80005092:	4785                	li	a5,1
    80005094:	06f70963          	beq	a4,a5,80005106 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005098:	fc040993          	addi	s3,s0,-64
    8000509c:	4641                	li	a2,16
    8000509e:	4581                	li	a1,0
    800050a0:	854e                	mv	a0,s3
    800050a2:	c57fb0ef          	jal	80000cf8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800050a6:	4741                	li	a4,16
    800050a8:	f2c42683          	lw	a3,-212(s0)
    800050ac:	864e                	mv	a2,s3
    800050ae:	4581                	li	a1,0
    800050b0:	8526                	mv	a0,s1
    800050b2:	fdefe0ef          	jal	80003890 <writei>
    800050b6:	47c1                	li	a5,16
    800050b8:	08f51863          	bne	a0,a5,80005148 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    800050bc:	04491703          	lh	a4,68(s2)
    800050c0:	4785                	li	a5,1
    800050c2:	08f70963          	beq	a4,a5,80005154 <sys_unlink+0x146>
  iunlockput(dp);
    800050c6:	8526                	mv	a0,s1
    800050c8:	d50fe0ef          	jal	80003618 <iunlockput>
  ip->nlink--;
    800050cc:	04a95783          	lhu	a5,74(s2)
    800050d0:	37fd                	addiw	a5,a5,-1
    800050d2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800050d6:	854a                	mv	a0,s2
    800050d8:	a80fe0ef          	jal	80003358 <iupdate>
  iunlockput(ip);
    800050dc:	854a                	mv	a0,s2
    800050de:	d3afe0ef          	jal	80003618 <iunlockput>
  end_op();
    800050e2:	da7fe0ef          	jal	80003e88 <end_op>
  return 0;
    800050e6:	4501                	li	a0,0
    800050e8:	64ee                	ld	s1,216(sp)
    800050ea:	694e                	ld	s2,208(sp)
    800050ec:	69ae                	ld	s3,200(sp)
    800050ee:	a061                	j	80005176 <sys_unlink+0x168>
    end_op();
    800050f0:	d99fe0ef          	jal	80003e88 <end_op>
    return -1;
    800050f4:	557d                	li	a0,-1
    800050f6:	64ee                	ld	s1,216(sp)
    800050f8:	a8bd                	j	80005176 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800050fa:	00002517          	auipc	a0,0x2
    800050fe:	4d650513          	addi	a0,a0,1238 # 800075d0 <etext+0x5d0>
    80005102:	f22fb0ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005106:	04c92703          	lw	a4,76(s2)
    8000510a:	02000793          	li	a5,32
    8000510e:	f8e7f5e3          	bgeu	a5,a4,80005098 <sys_unlink+0x8a>
    80005112:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005114:	4741                	li	a4,16
    80005116:	86ce                	mv	a3,s3
    80005118:	f1840613          	addi	a2,s0,-232
    8000511c:	4581                	li	a1,0
    8000511e:	854a                	mv	a0,s2
    80005120:	e7efe0ef          	jal	8000379e <readi>
    80005124:	47c1                	li	a5,16
    80005126:	00f51b63          	bne	a0,a5,8000513c <sys_unlink+0x12e>
    if(de.inum != 0)
    8000512a:	f1845783          	lhu	a5,-232(s0)
    8000512e:	ebb1                	bnez	a5,80005182 <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005130:	29c1                	addiw	s3,s3,16
    80005132:	04c92783          	lw	a5,76(s2)
    80005136:	fcf9efe3          	bltu	s3,a5,80005114 <sys_unlink+0x106>
    8000513a:	bfb9                	j	80005098 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    8000513c:	00002517          	auipc	a0,0x2
    80005140:	4ac50513          	addi	a0,a0,1196 # 800075e8 <etext+0x5e8>
    80005144:	ee0fb0ef          	jal	80000824 <panic>
    panic("unlink: writei");
    80005148:	00002517          	auipc	a0,0x2
    8000514c:	4b850513          	addi	a0,a0,1208 # 80007600 <etext+0x600>
    80005150:	ed4fb0ef          	jal	80000824 <panic>
    dp->nlink--;
    80005154:	04a4d783          	lhu	a5,74(s1)
    80005158:	37fd                	addiw	a5,a5,-1
    8000515a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000515e:	8526                	mv	a0,s1
    80005160:	9f8fe0ef          	jal	80003358 <iupdate>
    80005164:	b78d                	j	800050c6 <sys_unlink+0xb8>
    80005166:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005168:	8526                	mv	a0,s1
    8000516a:	caefe0ef          	jal	80003618 <iunlockput>
  end_op();
    8000516e:	d1bfe0ef          	jal	80003e88 <end_op>
  return -1;
    80005172:	557d                	li	a0,-1
    80005174:	64ee                	ld	s1,216(sp)
}
    80005176:	70ae                	ld	ra,232(sp)
    80005178:	740e                	ld	s0,224(sp)
    8000517a:	616d                	addi	sp,sp,240
    8000517c:	8082                	ret
    return -1;
    8000517e:	557d                	li	a0,-1
    80005180:	bfdd                	j	80005176 <sys_unlink+0x168>
    iunlockput(ip);
    80005182:	854a                	mv	a0,s2
    80005184:	c94fe0ef          	jal	80003618 <iunlockput>
    goto bad;
    80005188:	694e                	ld	s2,208(sp)
    8000518a:	69ae                	ld	s3,200(sp)
    8000518c:	bff1                	j	80005168 <sys_unlink+0x15a>

000000008000518e <sys_open>:

uint64
sys_open(void)
{
    8000518e:	7131                	addi	sp,sp,-192
    80005190:	fd06                	sd	ra,184(sp)
    80005192:	f922                	sd	s0,176(sp)
    80005194:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005196:	f4c40593          	addi	a1,s0,-180
    8000519a:	4505                	li	a0,1
    8000519c:	ecafd0ef          	jal	80002866 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800051a0:	08000613          	li	a2,128
    800051a4:	f5040593          	addi	a1,s0,-176
    800051a8:	4501                	li	a0,0
    800051aa:	ef4fd0ef          	jal	8000289e <argstr>
    800051ae:	87aa                	mv	a5,a0
    return -1;
    800051b0:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800051b2:	0a07c363          	bltz	a5,80005258 <sys_open+0xca>
    800051b6:	f526                	sd	s1,168(sp)

  begin_op();
    800051b8:	c61fe0ef          	jal	80003e18 <begin_op>

  if(omode & O_CREATE){
    800051bc:	f4c42783          	lw	a5,-180(s0)
    800051c0:	2007f793          	andi	a5,a5,512
    800051c4:	c3dd                	beqz	a5,8000526a <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    800051c6:	4681                	li	a3,0
    800051c8:	4601                	li	a2,0
    800051ca:	4589                	li	a1,2
    800051cc:	f5040513          	addi	a0,s0,-176
    800051d0:	aafff0ef          	jal	80004c7e <create>
    800051d4:	84aa                	mv	s1,a0
    if(ip == 0){
    800051d6:	c549                	beqz	a0,80005260 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800051d8:	04449703          	lh	a4,68(s1)
    800051dc:	478d                	li	a5,3
    800051de:	00f71763          	bne	a4,a5,800051ec <sys_open+0x5e>
    800051e2:	0464d703          	lhu	a4,70(s1)
    800051e6:	47a5                	li	a5,9
    800051e8:	0ae7ee63          	bltu	a5,a4,800052a4 <sys_open+0x116>
    800051ec:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800051ee:	fabfe0ef          	jal	80004198 <filealloc>
    800051f2:	892a                	mv	s2,a0
    800051f4:	c561                	beqz	a0,800052bc <sys_open+0x12e>
    800051f6:	ed4e                	sd	s3,152(sp)
    800051f8:	a47ff0ef          	jal	80004c3e <fdalloc>
    800051fc:	89aa                	mv	s3,a0
    800051fe:	0a054b63          	bltz	a0,800052b4 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005202:	04449703          	lh	a4,68(s1)
    80005206:	478d                	li	a5,3
    80005208:	0cf70363          	beq	a4,a5,800052ce <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000520c:	4789                	li	a5,2
    8000520e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005212:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005216:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000521a:	f4c42783          	lw	a5,-180(s0)
    8000521e:	0017f713          	andi	a4,a5,1
    80005222:	00174713          	xori	a4,a4,1
    80005226:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000522a:	0037f713          	andi	a4,a5,3
    8000522e:	00e03733          	snez	a4,a4
    80005232:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005236:	4007f793          	andi	a5,a5,1024
    8000523a:	c791                	beqz	a5,80005246 <sys_open+0xb8>
    8000523c:	04449703          	lh	a4,68(s1)
    80005240:	4789                	li	a5,2
    80005242:	08f70d63          	beq	a4,a5,800052dc <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80005246:	8526                	mv	a0,s1
    80005248:	a72fe0ef          	jal	800034ba <iunlock>
  end_op();
    8000524c:	c3dfe0ef          	jal	80003e88 <end_op>

  return fd;
    80005250:	854e                	mv	a0,s3
    80005252:	74aa                	ld	s1,168(sp)
    80005254:	790a                	ld	s2,160(sp)
    80005256:	69ea                	ld	s3,152(sp)
}
    80005258:	70ea                	ld	ra,184(sp)
    8000525a:	744a                	ld	s0,176(sp)
    8000525c:	6129                	addi	sp,sp,192
    8000525e:	8082                	ret
      end_op();
    80005260:	c29fe0ef          	jal	80003e88 <end_op>
      return -1;
    80005264:	557d                	li	a0,-1
    80005266:	74aa                	ld	s1,168(sp)
    80005268:	bfc5                	j	80005258 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    8000526a:	f5040513          	addi	a0,s0,-176
    8000526e:	9cdfe0ef          	jal	80003c3a <namei>
    80005272:	84aa                	mv	s1,a0
    80005274:	c11d                	beqz	a0,8000529a <sys_open+0x10c>
    ilock(ip);
    80005276:	996fe0ef          	jal	8000340c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000527a:	04449703          	lh	a4,68(s1)
    8000527e:	4785                	li	a5,1
    80005280:	f4f71ce3          	bne	a4,a5,800051d8 <sys_open+0x4a>
    80005284:	f4c42783          	lw	a5,-180(s0)
    80005288:	d3b5                	beqz	a5,800051ec <sys_open+0x5e>
      iunlockput(ip);
    8000528a:	8526                	mv	a0,s1
    8000528c:	b8cfe0ef          	jal	80003618 <iunlockput>
      end_op();
    80005290:	bf9fe0ef          	jal	80003e88 <end_op>
      return -1;
    80005294:	557d                	li	a0,-1
    80005296:	74aa                	ld	s1,168(sp)
    80005298:	b7c1                	j	80005258 <sys_open+0xca>
      end_op();
    8000529a:	beffe0ef          	jal	80003e88 <end_op>
      return -1;
    8000529e:	557d                	li	a0,-1
    800052a0:	74aa                	ld	s1,168(sp)
    800052a2:	bf5d                	j	80005258 <sys_open+0xca>
    iunlockput(ip);
    800052a4:	8526                	mv	a0,s1
    800052a6:	b72fe0ef          	jal	80003618 <iunlockput>
    end_op();
    800052aa:	bdffe0ef          	jal	80003e88 <end_op>
    return -1;
    800052ae:	557d                	li	a0,-1
    800052b0:	74aa                	ld	s1,168(sp)
    800052b2:	b75d                	j	80005258 <sys_open+0xca>
      fileclose(f);
    800052b4:	854a                	mv	a0,s2
    800052b6:	f87fe0ef          	jal	8000423c <fileclose>
    800052ba:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800052bc:	8526                	mv	a0,s1
    800052be:	b5afe0ef          	jal	80003618 <iunlockput>
    end_op();
    800052c2:	bc7fe0ef          	jal	80003e88 <end_op>
    return -1;
    800052c6:	557d                	li	a0,-1
    800052c8:	74aa                	ld	s1,168(sp)
    800052ca:	790a                	ld	s2,160(sp)
    800052cc:	b771                	j	80005258 <sys_open+0xca>
    f->type = FD_DEVICE;
    800052ce:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    800052d2:	04649783          	lh	a5,70(s1)
    800052d6:	02f91223          	sh	a5,36(s2)
    800052da:	bf35                	j	80005216 <sys_open+0x88>
    itrunc(ip);
    800052dc:	8526                	mv	a0,s1
    800052de:	a1cfe0ef          	jal	800034fa <itrunc>
    800052e2:	b795                	j	80005246 <sys_open+0xb8>

00000000800052e4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800052e4:	7175                	addi	sp,sp,-144
    800052e6:	e506                	sd	ra,136(sp)
    800052e8:	e122                	sd	s0,128(sp)
    800052ea:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800052ec:	b2dfe0ef          	jal	80003e18 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800052f0:	08000613          	li	a2,128
    800052f4:	f7040593          	addi	a1,s0,-144
    800052f8:	4501                	li	a0,0
    800052fa:	da4fd0ef          	jal	8000289e <argstr>
    800052fe:	02054363          	bltz	a0,80005324 <sys_mkdir+0x40>
    80005302:	4681                	li	a3,0
    80005304:	4601                	li	a2,0
    80005306:	4585                	li	a1,1
    80005308:	f7040513          	addi	a0,s0,-144
    8000530c:	973ff0ef          	jal	80004c7e <create>
    80005310:	c911                	beqz	a0,80005324 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005312:	b06fe0ef          	jal	80003618 <iunlockput>
  end_op();
    80005316:	b73fe0ef          	jal	80003e88 <end_op>
  return 0;
    8000531a:	4501                	li	a0,0
}
    8000531c:	60aa                	ld	ra,136(sp)
    8000531e:	640a                	ld	s0,128(sp)
    80005320:	6149                	addi	sp,sp,144
    80005322:	8082                	ret
    end_op();
    80005324:	b65fe0ef          	jal	80003e88 <end_op>
    return -1;
    80005328:	557d                	li	a0,-1
    8000532a:	bfcd                	j	8000531c <sys_mkdir+0x38>

000000008000532c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000532c:	7135                	addi	sp,sp,-160
    8000532e:	ed06                	sd	ra,152(sp)
    80005330:	e922                	sd	s0,144(sp)
    80005332:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005334:	ae5fe0ef          	jal	80003e18 <begin_op>
  argint(1, &major);
    80005338:	f6c40593          	addi	a1,s0,-148
    8000533c:	4505                	li	a0,1
    8000533e:	d28fd0ef          	jal	80002866 <argint>
  argint(2, &minor);
    80005342:	f6840593          	addi	a1,s0,-152
    80005346:	4509                	li	a0,2
    80005348:	d1efd0ef          	jal	80002866 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000534c:	08000613          	li	a2,128
    80005350:	f7040593          	addi	a1,s0,-144
    80005354:	4501                	li	a0,0
    80005356:	d48fd0ef          	jal	8000289e <argstr>
    8000535a:	02054563          	bltz	a0,80005384 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000535e:	f6841683          	lh	a3,-152(s0)
    80005362:	f6c41603          	lh	a2,-148(s0)
    80005366:	458d                	li	a1,3
    80005368:	f7040513          	addi	a0,s0,-144
    8000536c:	913ff0ef          	jal	80004c7e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005370:	c911                	beqz	a0,80005384 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005372:	aa6fe0ef          	jal	80003618 <iunlockput>
  end_op();
    80005376:	b13fe0ef          	jal	80003e88 <end_op>
  return 0;
    8000537a:	4501                	li	a0,0
}
    8000537c:	60ea                	ld	ra,152(sp)
    8000537e:	644a                	ld	s0,144(sp)
    80005380:	610d                	addi	sp,sp,160
    80005382:	8082                	ret
    end_op();
    80005384:	b05fe0ef          	jal	80003e88 <end_op>
    return -1;
    80005388:	557d                	li	a0,-1
    8000538a:	bfcd                	j	8000537c <sys_mknod+0x50>

000000008000538c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000538c:	7135                	addi	sp,sp,-160
    8000538e:	ed06                	sd	ra,152(sp)
    80005390:	e922                	sd	s0,144(sp)
    80005392:	e14a                	sd	s2,128(sp)
    80005394:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005396:	d8cfc0ef          	jal	80001922 <myproc>
    8000539a:	892a                	mv	s2,a0
  
  begin_op();
    8000539c:	a7dfe0ef          	jal	80003e18 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800053a0:	08000613          	li	a2,128
    800053a4:	f6040593          	addi	a1,s0,-160
    800053a8:	4501                	li	a0,0
    800053aa:	cf4fd0ef          	jal	8000289e <argstr>
    800053ae:	04054363          	bltz	a0,800053f4 <sys_chdir+0x68>
    800053b2:	e526                	sd	s1,136(sp)
    800053b4:	f6040513          	addi	a0,s0,-160
    800053b8:	883fe0ef          	jal	80003c3a <namei>
    800053bc:	84aa                	mv	s1,a0
    800053be:	c915                	beqz	a0,800053f2 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800053c0:	84cfe0ef          	jal	8000340c <ilock>
  if(ip->type != T_DIR){
    800053c4:	04449703          	lh	a4,68(s1)
    800053c8:	4785                	li	a5,1
    800053ca:	02f71963          	bne	a4,a5,800053fc <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800053ce:	8526                	mv	a0,s1
    800053d0:	8eafe0ef          	jal	800034ba <iunlock>
  iput(p->cwd);
    800053d4:	15893503          	ld	a0,344(s2)
    800053d8:	9b6fe0ef          	jal	8000358e <iput>
  end_op();
    800053dc:	aadfe0ef          	jal	80003e88 <end_op>
  p->cwd = ip;
    800053e0:	14993c23          	sd	s1,344(s2)
  return 0;
    800053e4:	4501                	li	a0,0
    800053e6:	64aa                	ld	s1,136(sp)
}
    800053e8:	60ea                	ld	ra,152(sp)
    800053ea:	644a                	ld	s0,144(sp)
    800053ec:	690a                	ld	s2,128(sp)
    800053ee:	610d                	addi	sp,sp,160
    800053f0:	8082                	ret
    800053f2:	64aa                	ld	s1,136(sp)
    end_op();
    800053f4:	a95fe0ef          	jal	80003e88 <end_op>
    return -1;
    800053f8:	557d                	li	a0,-1
    800053fa:	b7fd                	j	800053e8 <sys_chdir+0x5c>
    iunlockput(ip);
    800053fc:	8526                	mv	a0,s1
    800053fe:	a1afe0ef          	jal	80003618 <iunlockput>
    end_op();
    80005402:	a87fe0ef          	jal	80003e88 <end_op>
    return -1;
    80005406:	557d                	li	a0,-1
    80005408:	64aa                	ld	s1,136(sp)
    8000540a:	bff9                	j	800053e8 <sys_chdir+0x5c>

000000008000540c <sys_exec>:

uint64
sys_exec(void)
{
    8000540c:	7105                	addi	sp,sp,-480
    8000540e:	ef86                	sd	ra,472(sp)
    80005410:	eba2                	sd	s0,464(sp)
    80005412:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005414:	e2840593          	addi	a1,s0,-472
    80005418:	4505                	li	a0,1
    8000541a:	c68fd0ef          	jal	80002882 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000541e:	08000613          	li	a2,128
    80005422:	f3040593          	addi	a1,s0,-208
    80005426:	4501                	li	a0,0
    80005428:	c76fd0ef          	jal	8000289e <argstr>
    8000542c:	87aa                	mv	a5,a0
    return -1;
    8000542e:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005430:	0e07c063          	bltz	a5,80005510 <sys_exec+0x104>
    80005434:	e7a6                	sd	s1,456(sp)
    80005436:	e3ca                	sd	s2,448(sp)
    80005438:	ff4e                	sd	s3,440(sp)
    8000543a:	fb52                	sd	s4,432(sp)
    8000543c:	f756                	sd	s5,424(sp)
    8000543e:	f35a                	sd	s6,416(sp)
    80005440:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005442:	e3040a13          	addi	s4,s0,-464
    80005446:	10000613          	li	a2,256
    8000544a:	4581                	li	a1,0
    8000544c:	8552                	mv	a0,s4
    8000544e:	8abfb0ef          	jal	80000cf8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005452:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005454:	89d2                	mv	s3,s4
    80005456:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005458:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000545c:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    8000545e:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005462:	00391513          	slli	a0,s2,0x3
    80005466:	85d6                	mv	a1,s5
    80005468:	e2843783          	ld	a5,-472(s0)
    8000546c:	953e                	add	a0,a0,a5
    8000546e:	b6efd0ef          	jal	800027dc <fetchaddr>
    80005472:	02054663          	bltz	a0,8000549e <sys_exec+0x92>
    if(uarg == 0){
    80005476:	e2043783          	ld	a5,-480(s0)
    8000547a:	c7a1                	beqz	a5,800054c2 <sys_exec+0xb6>
    argv[i] = kalloc();
    8000547c:	ec8fb0ef          	jal	80000b44 <kalloc>
    80005480:	85aa                	mv	a1,a0
    80005482:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005486:	cd01                	beqz	a0,8000549e <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005488:	865a                	mv	a2,s6
    8000548a:	e2043503          	ld	a0,-480(s0)
    8000548e:	b98fd0ef          	jal	80002826 <fetchstr>
    80005492:	00054663          	bltz	a0,8000549e <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005496:	0905                	addi	s2,s2,1
    80005498:	09a1                	addi	s3,s3,8
    8000549a:	fd7914e3          	bne	s2,s7,80005462 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000549e:	100a0a13          	addi	s4,s4,256
    800054a2:	6088                	ld	a0,0(s1)
    800054a4:	cd31                	beqz	a0,80005500 <sys_exec+0xf4>
    kfree(argv[i]);
    800054a6:	db6fb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054aa:	04a1                	addi	s1,s1,8
    800054ac:	ff449be3          	bne	s1,s4,800054a2 <sys_exec+0x96>
  return -1;
    800054b0:	557d                	li	a0,-1
    800054b2:	64be                	ld	s1,456(sp)
    800054b4:	691e                	ld	s2,448(sp)
    800054b6:	79fa                	ld	s3,440(sp)
    800054b8:	7a5a                	ld	s4,432(sp)
    800054ba:	7aba                	ld	s5,424(sp)
    800054bc:	7b1a                	ld	s6,416(sp)
    800054be:	6bfa                	ld	s7,408(sp)
    800054c0:	a881                	j	80005510 <sys_exec+0x104>
      argv[i] = 0;
    800054c2:	0009079b          	sext.w	a5,s2
    800054c6:	e3040593          	addi	a1,s0,-464
    800054ca:	078e                	slli	a5,a5,0x3
    800054cc:	97ae                	add	a5,a5,a1
    800054ce:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    800054d2:	f3040513          	addi	a0,s0,-208
    800054d6:	bb2ff0ef          	jal	80004888 <kexec>
    800054da:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054dc:	100a0a13          	addi	s4,s4,256
    800054e0:	6088                	ld	a0,0(s1)
    800054e2:	c511                	beqz	a0,800054ee <sys_exec+0xe2>
    kfree(argv[i]);
    800054e4:	d78fb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054e8:	04a1                	addi	s1,s1,8
    800054ea:	ff449be3          	bne	s1,s4,800054e0 <sys_exec+0xd4>
  return ret;
    800054ee:	854a                	mv	a0,s2
    800054f0:	64be                	ld	s1,456(sp)
    800054f2:	691e                	ld	s2,448(sp)
    800054f4:	79fa                	ld	s3,440(sp)
    800054f6:	7a5a                	ld	s4,432(sp)
    800054f8:	7aba                	ld	s5,424(sp)
    800054fa:	7b1a                	ld	s6,416(sp)
    800054fc:	6bfa                	ld	s7,408(sp)
    800054fe:	a809                	j	80005510 <sys_exec+0x104>
  return -1;
    80005500:	557d                	li	a0,-1
    80005502:	64be                	ld	s1,456(sp)
    80005504:	691e                	ld	s2,448(sp)
    80005506:	79fa                	ld	s3,440(sp)
    80005508:	7a5a                	ld	s4,432(sp)
    8000550a:	7aba                	ld	s5,424(sp)
    8000550c:	7b1a                	ld	s6,416(sp)
    8000550e:	6bfa                	ld	s7,408(sp)
}
    80005510:	60fe                	ld	ra,472(sp)
    80005512:	645e                	ld	s0,464(sp)
    80005514:	613d                	addi	sp,sp,480
    80005516:	8082                	ret

0000000080005518 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005518:	7139                	addi	sp,sp,-64
    8000551a:	fc06                	sd	ra,56(sp)
    8000551c:	f822                	sd	s0,48(sp)
    8000551e:	f426                	sd	s1,40(sp)
    80005520:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005522:	c00fc0ef          	jal	80001922 <myproc>
    80005526:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005528:	fd840593          	addi	a1,s0,-40
    8000552c:	4501                	li	a0,0
    8000552e:	b54fd0ef          	jal	80002882 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005532:	fc840593          	addi	a1,s0,-56
    80005536:	fd040513          	addi	a0,s0,-48
    8000553a:	81eff0ef          	jal	80004558 <pipealloc>
    return -1;
    8000553e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005540:	0a054763          	bltz	a0,800055ee <sys_pipe+0xd6>
  fd0 = -1;
    80005544:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005548:	fd043503          	ld	a0,-48(s0)
    8000554c:	ef2ff0ef          	jal	80004c3e <fdalloc>
    80005550:	fca42223          	sw	a0,-60(s0)
    80005554:	08054463          	bltz	a0,800055dc <sys_pipe+0xc4>
    80005558:	fc843503          	ld	a0,-56(s0)
    8000555c:	ee2ff0ef          	jal	80004c3e <fdalloc>
    80005560:	fca42023          	sw	a0,-64(s0)
    80005564:	06054263          	bltz	a0,800055c8 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005568:	4691                	li	a3,4
    8000556a:	fc440613          	addi	a2,s0,-60
    8000556e:	fd843583          	ld	a1,-40(s0)
    80005572:	6ca8                	ld	a0,88(s1)
    80005574:	8e0fc0ef          	jal	80001654 <copyout>
    80005578:	00054e63          	bltz	a0,80005594 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000557c:	4691                	li	a3,4
    8000557e:	fc040613          	addi	a2,s0,-64
    80005582:	fd843583          	ld	a1,-40(s0)
    80005586:	95b6                	add	a1,a1,a3
    80005588:	6ca8                	ld	a0,88(s1)
    8000558a:	8cafc0ef          	jal	80001654 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000558e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005590:	04055f63          	bgez	a0,800055ee <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    80005594:	fc442783          	lw	a5,-60(s0)
    80005598:	078e                	slli	a5,a5,0x3
    8000559a:	0d078793          	addi	a5,a5,208
    8000559e:	97a6                	add	a5,a5,s1
    800055a0:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    800055a4:	fc042783          	lw	a5,-64(s0)
    800055a8:	078e                	slli	a5,a5,0x3
    800055aa:	0d078793          	addi	a5,a5,208
    800055ae:	97a6                	add	a5,a5,s1
    800055b0:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    800055b4:	fd043503          	ld	a0,-48(s0)
    800055b8:	c85fe0ef          	jal	8000423c <fileclose>
    fileclose(wf);
    800055bc:	fc843503          	ld	a0,-56(s0)
    800055c0:	c7dfe0ef          	jal	8000423c <fileclose>
    return -1;
    800055c4:	57fd                	li	a5,-1
    800055c6:	a025                	j	800055ee <sys_pipe+0xd6>
    if(fd0 >= 0)
    800055c8:	fc442783          	lw	a5,-60(s0)
    800055cc:	0007c863          	bltz	a5,800055dc <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    800055d0:	078e                	slli	a5,a5,0x3
    800055d2:	0d078793          	addi	a5,a5,208
    800055d6:	97a6                	add	a5,a5,s1
    800055d8:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    800055dc:	fd043503          	ld	a0,-48(s0)
    800055e0:	c5dfe0ef          	jal	8000423c <fileclose>
    fileclose(wf);
    800055e4:	fc843503          	ld	a0,-56(s0)
    800055e8:	c55fe0ef          	jal	8000423c <fileclose>
    return -1;
    800055ec:	57fd                	li	a5,-1
}
    800055ee:	853e                	mv	a0,a5
    800055f0:	70e2                	ld	ra,56(sp)
    800055f2:	7442                	ld	s0,48(sp)
    800055f4:	74a2                	ld	s1,40(sp)
    800055f6:	6121                	addi	sp,sp,64
    800055f8:	8082                	ret
    800055fa:	0000                	unimp
    800055fc:	0000                	unimp
	...

0000000080005600 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005600:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005602:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005604:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005606:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005608:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000560a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000560c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000560e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005610:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005612:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005614:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005616:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005618:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000561a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000561c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000561e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005620:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005622:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005624:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005626:	8c4fd0ef          	jal	800026ea <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000562a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000562c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000562e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005630:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005632:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005634:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005636:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005638:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000563a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000563c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000563e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005640:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005642:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005644:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005646:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005648:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000564a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000564c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000564e:	10200073          	sret
    80005652:	00000013          	nop
    80005656:	00000013          	nop
    8000565a:	00000013          	nop

000000008000565e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000565e:	1141                	addi	sp,sp,-16
    80005660:	e406                	sd	ra,8(sp)
    80005662:	e022                	sd	s0,0(sp)
    80005664:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005666:	0c000737          	lui	a4,0xc000
    8000566a:	4785                	li	a5,1
    8000566c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000566e:	c35c                	sw	a5,4(a4)
}
    80005670:	60a2                	ld	ra,8(sp)
    80005672:	6402                	ld	s0,0(sp)
    80005674:	0141                	addi	sp,sp,16
    80005676:	8082                	ret

0000000080005678 <plicinithart>:

void
plicinithart(void)
{
    80005678:	1141                	addi	sp,sp,-16
    8000567a:	e406                	sd	ra,8(sp)
    8000567c:	e022                	sd	s0,0(sp)
    8000567e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005680:	a6efc0ef          	jal	800018ee <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005684:	0085171b          	slliw	a4,a0,0x8
    80005688:	0c0027b7          	lui	a5,0xc002
    8000568c:	97ba                	add	a5,a5,a4
    8000568e:	40200713          	li	a4,1026
    80005692:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005696:	00d5151b          	slliw	a0,a0,0xd
    8000569a:	0c2017b7          	lui	a5,0xc201
    8000569e:	97aa                	add	a5,a5,a0
    800056a0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800056a4:	60a2                	ld	ra,8(sp)
    800056a6:	6402                	ld	s0,0(sp)
    800056a8:	0141                	addi	sp,sp,16
    800056aa:	8082                	ret

00000000800056ac <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800056ac:	1141                	addi	sp,sp,-16
    800056ae:	e406                	sd	ra,8(sp)
    800056b0:	e022                	sd	s0,0(sp)
    800056b2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800056b4:	a3afc0ef          	jal	800018ee <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800056b8:	00d5151b          	slliw	a0,a0,0xd
    800056bc:	0c2017b7          	lui	a5,0xc201
    800056c0:	97aa                	add	a5,a5,a0
  return irq;
}
    800056c2:	43c8                	lw	a0,4(a5)
    800056c4:	60a2                	ld	ra,8(sp)
    800056c6:	6402                	ld	s0,0(sp)
    800056c8:	0141                	addi	sp,sp,16
    800056ca:	8082                	ret

00000000800056cc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800056cc:	1101                	addi	sp,sp,-32
    800056ce:	ec06                	sd	ra,24(sp)
    800056d0:	e822                	sd	s0,16(sp)
    800056d2:	e426                	sd	s1,8(sp)
    800056d4:	1000                	addi	s0,sp,32
    800056d6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800056d8:	a16fc0ef          	jal	800018ee <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800056dc:	00d5179b          	slliw	a5,a0,0xd
    800056e0:	0c201737          	lui	a4,0xc201
    800056e4:	97ba                	add	a5,a5,a4
    800056e6:	c3c4                	sw	s1,4(a5)
}
    800056e8:	60e2                	ld	ra,24(sp)
    800056ea:	6442                	ld	s0,16(sp)
    800056ec:	64a2                	ld	s1,8(sp)
    800056ee:	6105                	addi	sp,sp,32
    800056f0:	8082                	ret

00000000800056f2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800056f2:	1141                	addi	sp,sp,-16
    800056f4:	e406                	sd	ra,8(sp)
    800056f6:	e022                	sd	s0,0(sp)
    800056f8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800056fa:	479d                	li	a5,7
    800056fc:	04a7ca63          	blt	a5,a0,80005750 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005700:	0001b797          	auipc	a5,0x1b
    80005704:	74878793          	addi	a5,a5,1864 # 80020e48 <disk>
    80005708:	97aa                	add	a5,a5,a0
    8000570a:	0187c783          	lbu	a5,24(a5)
    8000570e:	e7b9                	bnez	a5,8000575c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005710:	00451693          	slli	a3,a0,0x4
    80005714:	0001b797          	auipc	a5,0x1b
    80005718:	73478793          	addi	a5,a5,1844 # 80020e48 <disk>
    8000571c:	6398                	ld	a4,0(a5)
    8000571e:	9736                	add	a4,a4,a3
    80005720:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005724:	6398                	ld	a4,0(a5)
    80005726:	9736                	add	a4,a4,a3
    80005728:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000572c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005730:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005734:	97aa                	add	a5,a5,a0
    80005736:	4705                	li	a4,1
    80005738:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000573c:	0001b517          	auipc	a0,0x1b
    80005740:	72450513          	addi	a0,a0,1828 # 80020e60 <disk+0x18>
    80005744:	863fc0ef          	jal	80001fa6 <wakeup>
}
    80005748:	60a2                	ld	ra,8(sp)
    8000574a:	6402                	ld	s0,0(sp)
    8000574c:	0141                	addi	sp,sp,16
    8000574e:	8082                	ret
    panic("free_desc 1");
    80005750:	00002517          	auipc	a0,0x2
    80005754:	ec050513          	addi	a0,a0,-320 # 80007610 <etext+0x610>
    80005758:	8ccfb0ef          	jal	80000824 <panic>
    panic("free_desc 2");
    8000575c:	00002517          	auipc	a0,0x2
    80005760:	ec450513          	addi	a0,a0,-316 # 80007620 <etext+0x620>
    80005764:	8c0fb0ef          	jal	80000824 <panic>

0000000080005768 <virtio_disk_init>:
{
    80005768:	1101                	addi	sp,sp,-32
    8000576a:	ec06                	sd	ra,24(sp)
    8000576c:	e822                	sd	s0,16(sp)
    8000576e:	e426                	sd	s1,8(sp)
    80005770:	e04a                	sd	s2,0(sp)
    80005772:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005774:	00002597          	auipc	a1,0x2
    80005778:	ebc58593          	addi	a1,a1,-324 # 80007630 <etext+0x630>
    8000577c:	0001b517          	auipc	a0,0x1b
    80005780:	7f450513          	addi	a0,a0,2036 # 80020f70 <disk+0x128>
    80005784:	c1afb0ef          	jal	80000b9e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005788:	100017b7          	lui	a5,0x10001
    8000578c:	4398                	lw	a4,0(a5)
    8000578e:	2701                	sext.w	a4,a4
    80005790:	747277b7          	lui	a5,0x74727
    80005794:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005798:	14f71863          	bne	a4,a5,800058e8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000579c:	100017b7          	lui	a5,0x10001
    800057a0:	43dc                	lw	a5,4(a5)
    800057a2:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800057a4:	4709                	li	a4,2
    800057a6:	14e79163          	bne	a5,a4,800058e8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057aa:	100017b7          	lui	a5,0x10001
    800057ae:	479c                	lw	a5,8(a5)
    800057b0:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800057b2:	12e79b63          	bne	a5,a4,800058e8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800057b6:	100017b7          	lui	a5,0x10001
    800057ba:	47d8                	lw	a4,12(a5)
    800057bc:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057be:	554d47b7          	lui	a5,0x554d4
    800057c2:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800057c6:	12f71163          	bne	a4,a5,800058e8 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    800057ca:	100017b7          	lui	a5,0x10001
    800057ce:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800057d2:	4705                	li	a4,1
    800057d4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057d6:	470d                	li	a4,3
    800057d8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800057da:	10001737          	lui	a4,0x10001
    800057de:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800057e0:	c7ffe6b7          	lui	a3,0xc7ffe
    800057e4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd7d7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800057e8:	8f75                	and	a4,a4,a3
    800057ea:	100016b7          	lui	a3,0x10001
    800057ee:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057f0:	472d                	li	a4,11
    800057f2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057f4:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800057f8:	439c                	lw	a5,0(a5)
    800057fa:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800057fe:	8ba1                	andi	a5,a5,8
    80005800:	0e078a63          	beqz	a5,800058f4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005804:	100017b7          	lui	a5,0x10001
    80005808:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000580c:	43fc                	lw	a5,68(a5)
    8000580e:	2781                	sext.w	a5,a5
    80005810:	0e079863          	bnez	a5,80005900 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005814:	100017b7          	lui	a5,0x10001
    80005818:	5bdc                	lw	a5,52(a5)
    8000581a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000581c:	0e078863          	beqz	a5,8000590c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005820:	471d                	li	a4,7
    80005822:	0ef77b63          	bgeu	a4,a5,80005918 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005826:	b1efb0ef          	jal	80000b44 <kalloc>
    8000582a:	0001b497          	auipc	s1,0x1b
    8000582e:	61e48493          	addi	s1,s1,1566 # 80020e48 <disk>
    80005832:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005834:	b10fb0ef          	jal	80000b44 <kalloc>
    80005838:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000583a:	b0afb0ef          	jal	80000b44 <kalloc>
    8000583e:	87aa                	mv	a5,a0
    80005840:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005842:	6088                	ld	a0,0(s1)
    80005844:	0e050063          	beqz	a0,80005924 <virtio_disk_init+0x1bc>
    80005848:	0001b717          	auipc	a4,0x1b
    8000584c:	60873703          	ld	a4,1544(a4) # 80020e50 <disk+0x8>
    80005850:	cb71                	beqz	a4,80005924 <virtio_disk_init+0x1bc>
    80005852:	cbe9                	beqz	a5,80005924 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005854:	6605                	lui	a2,0x1
    80005856:	4581                	li	a1,0
    80005858:	ca0fb0ef          	jal	80000cf8 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000585c:	0001b497          	auipc	s1,0x1b
    80005860:	5ec48493          	addi	s1,s1,1516 # 80020e48 <disk>
    80005864:	6605                	lui	a2,0x1
    80005866:	4581                	li	a1,0
    80005868:	6488                	ld	a0,8(s1)
    8000586a:	c8efb0ef          	jal	80000cf8 <memset>
  memset(disk.used, 0, PGSIZE);
    8000586e:	6605                	lui	a2,0x1
    80005870:	4581                	li	a1,0
    80005872:	6888                	ld	a0,16(s1)
    80005874:	c84fb0ef          	jal	80000cf8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005878:	100017b7          	lui	a5,0x10001
    8000587c:	4721                	li	a4,8
    8000587e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005880:	4098                	lw	a4,0(s1)
    80005882:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005886:	40d8                	lw	a4,4(s1)
    80005888:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000588c:	649c                	ld	a5,8(s1)
    8000588e:	0007869b          	sext.w	a3,a5
    80005892:	10001737          	lui	a4,0x10001
    80005896:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000589a:	9781                	srai	a5,a5,0x20
    8000589c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800058a0:	689c                	ld	a5,16(s1)
    800058a2:	0007869b          	sext.w	a3,a5
    800058a6:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800058aa:	9781                	srai	a5,a5,0x20
    800058ac:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800058b0:	4785                	li	a5,1
    800058b2:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800058b4:	00f48c23          	sb	a5,24(s1)
    800058b8:	00f48ca3          	sb	a5,25(s1)
    800058bc:	00f48d23          	sb	a5,26(s1)
    800058c0:	00f48da3          	sb	a5,27(s1)
    800058c4:	00f48e23          	sb	a5,28(s1)
    800058c8:	00f48ea3          	sb	a5,29(s1)
    800058cc:	00f48f23          	sb	a5,30(s1)
    800058d0:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800058d4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800058d8:	07272823          	sw	s2,112(a4)
}
    800058dc:	60e2                	ld	ra,24(sp)
    800058de:	6442                	ld	s0,16(sp)
    800058e0:	64a2                	ld	s1,8(sp)
    800058e2:	6902                	ld	s2,0(sp)
    800058e4:	6105                	addi	sp,sp,32
    800058e6:	8082                	ret
    panic("could not find virtio disk");
    800058e8:	00002517          	auipc	a0,0x2
    800058ec:	d5850513          	addi	a0,a0,-680 # 80007640 <etext+0x640>
    800058f0:	f35fa0ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    800058f4:	00002517          	auipc	a0,0x2
    800058f8:	d6c50513          	addi	a0,a0,-660 # 80007660 <etext+0x660>
    800058fc:	f29fa0ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    80005900:	00002517          	auipc	a0,0x2
    80005904:	d8050513          	addi	a0,a0,-640 # 80007680 <etext+0x680>
    80005908:	f1dfa0ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    8000590c:	00002517          	auipc	a0,0x2
    80005910:	d9450513          	addi	a0,a0,-620 # 800076a0 <etext+0x6a0>
    80005914:	f11fa0ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    80005918:	00002517          	auipc	a0,0x2
    8000591c:	da850513          	addi	a0,a0,-600 # 800076c0 <etext+0x6c0>
    80005920:	f05fa0ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    80005924:	00002517          	auipc	a0,0x2
    80005928:	dbc50513          	addi	a0,a0,-580 # 800076e0 <etext+0x6e0>
    8000592c:	ef9fa0ef          	jal	80000824 <panic>

0000000080005930 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005930:	711d                	addi	sp,sp,-96
    80005932:	ec86                	sd	ra,88(sp)
    80005934:	e8a2                	sd	s0,80(sp)
    80005936:	e4a6                	sd	s1,72(sp)
    80005938:	e0ca                	sd	s2,64(sp)
    8000593a:	fc4e                	sd	s3,56(sp)
    8000593c:	f852                	sd	s4,48(sp)
    8000593e:	f456                	sd	s5,40(sp)
    80005940:	f05a                	sd	s6,32(sp)
    80005942:	ec5e                	sd	s7,24(sp)
    80005944:	e862                	sd	s8,16(sp)
    80005946:	1080                	addi	s0,sp,96
    80005948:	89aa                	mv	s3,a0
    8000594a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000594c:	00c52b83          	lw	s7,12(a0)
    80005950:	001b9b9b          	slliw	s7,s7,0x1
    80005954:	1b82                	slli	s7,s7,0x20
    80005956:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    8000595a:	0001b517          	auipc	a0,0x1b
    8000595e:	61650513          	addi	a0,a0,1558 # 80020f70 <disk+0x128>
    80005962:	ac6fb0ef          	jal	80000c28 <acquire>
  for(int i = 0; i < NUM; i++){
    80005966:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005968:	0001ba97          	auipc	s5,0x1b
    8000596c:	4e0a8a93          	addi	s5,s5,1248 # 80020e48 <disk>
  for(int i = 0; i < 3; i++){
    80005970:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005972:	5c7d                	li	s8,-1
    80005974:	a095                	j	800059d8 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005976:	00fa8733          	add	a4,s5,a5
    8000597a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000597e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005980:	0207c563          	bltz	a5,800059aa <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005984:	2905                	addiw	s2,s2,1
    80005986:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005988:	05490c63          	beq	s2,s4,800059e0 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    8000598c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000598e:	0001b717          	auipc	a4,0x1b
    80005992:	4ba70713          	addi	a4,a4,1210 # 80020e48 <disk>
    80005996:	4781                	li	a5,0
    if(disk.free[i]){
    80005998:	01874683          	lbu	a3,24(a4)
    8000599c:	fee9                	bnez	a3,80005976 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    8000599e:	2785                	addiw	a5,a5,1
    800059a0:	0705                	addi	a4,a4,1
    800059a2:	fe979be3          	bne	a5,s1,80005998 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    800059a6:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    800059aa:	01205d63          	blez	s2,800059c4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    800059ae:	fa042503          	lw	a0,-96(s0)
    800059b2:	d41ff0ef          	jal	800056f2 <free_desc>
      for(int j = 0; j < i; j++)
    800059b6:	4785                	li	a5,1
    800059b8:	0127d663          	bge	a5,s2,800059c4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    800059bc:	fa442503          	lw	a0,-92(s0)
    800059c0:	d33ff0ef          	jal	800056f2 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800059c4:	0001b597          	auipc	a1,0x1b
    800059c8:	5ac58593          	addi	a1,a1,1452 # 80020f70 <disk+0x128>
    800059cc:	0001b517          	auipc	a0,0x1b
    800059d0:	49450513          	addi	a0,a0,1172 # 80020e60 <disk+0x18>
    800059d4:	d86fc0ef          	jal	80001f5a <sleep>
  for(int i = 0; i < 3; i++){
    800059d8:	fa040613          	addi	a2,s0,-96
    800059dc:	4901                	li	s2,0
    800059de:	b77d                	j	8000598c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800059e0:	fa042503          	lw	a0,-96(s0)
    800059e4:	00451693          	slli	a3,a0,0x4

  if(write)
    800059e8:	0001b797          	auipc	a5,0x1b
    800059ec:	46078793          	addi	a5,a5,1120 # 80020e48 <disk>
    800059f0:	00451713          	slli	a4,a0,0x4
    800059f4:	0a070713          	addi	a4,a4,160
    800059f8:	973e                	add	a4,a4,a5
    800059fa:	01603633          	snez	a2,s6
    800059fe:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005a00:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005a04:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005a08:	6398                	ld	a4,0(a5)
    80005a0a:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a0c:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005a10:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005a12:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005a14:	6390                	ld	a2,0(a5)
    80005a16:	00d60833          	add	a6,a2,a3
    80005a1a:	4741                	li	a4,16
    80005a1c:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005a20:	4585                	li	a1,1
    80005a22:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005a26:	fa442703          	lw	a4,-92(s0)
    80005a2a:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005a2e:	0712                	slli	a4,a4,0x4
    80005a30:	963a                	add	a2,a2,a4
    80005a32:	05898813          	addi	a6,s3,88
    80005a36:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005a3a:	0007b883          	ld	a7,0(a5)
    80005a3e:	9746                	add	a4,a4,a7
    80005a40:	40000613          	li	a2,1024
    80005a44:	c710                	sw	a2,8(a4)
  if(write)
    80005a46:	001b3613          	seqz	a2,s6
    80005a4a:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005a4e:	8e4d                	or	a2,a2,a1
    80005a50:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005a54:	fa842603          	lw	a2,-88(s0)
    80005a58:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005a5c:	00451813          	slli	a6,a0,0x4
    80005a60:	02080813          	addi	a6,a6,32
    80005a64:	983e                	add	a6,a6,a5
    80005a66:	577d                	li	a4,-1
    80005a68:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005a6c:	0612                	slli	a2,a2,0x4
    80005a6e:	98b2                	add	a7,a7,a2
    80005a70:	03068713          	addi	a4,a3,48
    80005a74:	973e                	add	a4,a4,a5
    80005a76:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005a7a:	6398                	ld	a4,0(a5)
    80005a7c:	9732                	add	a4,a4,a2
    80005a7e:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005a80:	4689                	li	a3,2
    80005a82:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005a86:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005a8a:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005a8e:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005a92:	6794                	ld	a3,8(a5)
    80005a94:	0026d703          	lhu	a4,2(a3)
    80005a98:	8b1d                	andi	a4,a4,7
    80005a9a:	0706                	slli	a4,a4,0x1
    80005a9c:	96ba                	add	a3,a3,a4
    80005a9e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005aa2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005aa6:	6798                	ld	a4,8(a5)
    80005aa8:	00275783          	lhu	a5,2(a4)
    80005aac:	2785                	addiw	a5,a5,1
    80005aae:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005ab2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005ab6:	100017b7          	lui	a5,0x10001
    80005aba:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005abe:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005ac2:	0001b917          	auipc	s2,0x1b
    80005ac6:	4ae90913          	addi	s2,s2,1198 # 80020f70 <disk+0x128>
  while(b->disk == 1) {
    80005aca:	84ae                	mv	s1,a1
    80005acc:	00b79a63          	bne	a5,a1,80005ae0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005ad0:	85ca                	mv	a1,s2
    80005ad2:	854e                	mv	a0,s3
    80005ad4:	c86fc0ef          	jal	80001f5a <sleep>
  while(b->disk == 1) {
    80005ad8:	0049a783          	lw	a5,4(s3)
    80005adc:	fe978ae3          	beq	a5,s1,80005ad0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005ae0:	fa042903          	lw	s2,-96(s0)
    80005ae4:	00491713          	slli	a4,s2,0x4
    80005ae8:	02070713          	addi	a4,a4,32
    80005aec:	0001b797          	auipc	a5,0x1b
    80005af0:	35c78793          	addi	a5,a5,860 # 80020e48 <disk>
    80005af4:	97ba                	add	a5,a5,a4
    80005af6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005afa:	0001b997          	auipc	s3,0x1b
    80005afe:	34e98993          	addi	s3,s3,846 # 80020e48 <disk>
    80005b02:	00491713          	slli	a4,s2,0x4
    80005b06:	0009b783          	ld	a5,0(s3)
    80005b0a:	97ba                	add	a5,a5,a4
    80005b0c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005b10:	854a                	mv	a0,s2
    80005b12:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005b16:	bddff0ef          	jal	800056f2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005b1a:	8885                	andi	s1,s1,1
    80005b1c:	f0fd                	bnez	s1,80005b02 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005b1e:	0001b517          	auipc	a0,0x1b
    80005b22:	45250513          	addi	a0,a0,1106 # 80020f70 <disk+0x128>
    80005b26:	996fb0ef          	jal	80000cbc <release>
}
    80005b2a:	60e6                	ld	ra,88(sp)
    80005b2c:	6446                	ld	s0,80(sp)
    80005b2e:	64a6                	ld	s1,72(sp)
    80005b30:	6906                	ld	s2,64(sp)
    80005b32:	79e2                	ld	s3,56(sp)
    80005b34:	7a42                	ld	s4,48(sp)
    80005b36:	7aa2                	ld	s5,40(sp)
    80005b38:	7b02                	ld	s6,32(sp)
    80005b3a:	6be2                	ld	s7,24(sp)
    80005b3c:	6c42                	ld	s8,16(sp)
    80005b3e:	6125                	addi	sp,sp,96
    80005b40:	8082                	ret

0000000080005b42 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005b42:	1101                	addi	sp,sp,-32
    80005b44:	ec06                	sd	ra,24(sp)
    80005b46:	e822                	sd	s0,16(sp)
    80005b48:	e426                	sd	s1,8(sp)
    80005b4a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005b4c:	0001b497          	auipc	s1,0x1b
    80005b50:	2fc48493          	addi	s1,s1,764 # 80020e48 <disk>
    80005b54:	0001b517          	auipc	a0,0x1b
    80005b58:	41c50513          	addi	a0,a0,1052 # 80020f70 <disk+0x128>
    80005b5c:	8ccfb0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005b60:	100017b7          	lui	a5,0x10001
    80005b64:	53bc                	lw	a5,96(a5)
    80005b66:	8b8d                	andi	a5,a5,3
    80005b68:	10001737          	lui	a4,0x10001
    80005b6c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005b6e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005b72:	689c                	ld	a5,16(s1)
    80005b74:	0204d703          	lhu	a4,32(s1)
    80005b78:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005b7c:	04f70863          	beq	a4,a5,80005bcc <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005b80:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005b84:	6898                	ld	a4,16(s1)
    80005b86:	0204d783          	lhu	a5,32(s1)
    80005b8a:	8b9d                	andi	a5,a5,7
    80005b8c:	078e                	slli	a5,a5,0x3
    80005b8e:	97ba                	add	a5,a5,a4
    80005b90:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005b92:	00479713          	slli	a4,a5,0x4
    80005b96:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005b9a:	9726                	add	a4,a4,s1
    80005b9c:	01074703          	lbu	a4,16(a4)
    80005ba0:	e329                	bnez	a4,80005be2 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005ba2:	0792                	slli	a5,a5,0x4
    80005ba4:	02078793          	addi	a5,a5,32
    80005ba8:	97a6                	add	a5,a5,s1
    80005baa:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005bac:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005bb0:	bf6fc0ef          	jal	80001fa6 <wakeup>

    disk.used_idx += 1;
    80005bb4:	0204d783          	lhu	a5,32(s1)
    80005bb8:	2785                	addiw	a5,a5,1
    80005bba:	17c2                	slli	a5,a5,0x30
    80005bbc:	93c1                	srli	a5,a5,0x30
    80005bbe:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005bc2:	6898                	ld	a4,16(s1)
    80005bc4:	00275703          	lhu	a4,2(a4)
    80005bc8:	faf71ce3          	bne	a4,a5,80005b80 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005bcc:	0001b517          	auipc	a0,0x1b
    80005bd0:	3a450513          	addi	a0,a0,932 # 80020f70 <disk+0x128>
    80005bd4:	8e8fb0ef          	jal	80000cbc <release>
}
    80005bd8:	60e2                	ld	ra,24(sp)
    80005bda:	6442                	ld	s0,16(sp)
    80005bdc:	64a2                	ld	s1,8(sp)
    80005bde:	6105                	addi	sp,sp,32
    80005be0:	8082                	ret
      panic("virtio_disk_intr status");
    80005be2:	00002517          	auipc	a0,0x2
    80005be6:	b1650513          	addi	a0,a0,-1258 # 800076f8 <etext+0x6f8>
    80005bea:	c3bfa0ef          	jal	80000824 <panic>
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
