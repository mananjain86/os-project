
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	45813103          	ld	sp,1112(sp) # 8000a458 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000016:	04a000ef          	jal	80000060 <start>

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
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffda03f>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	dbc78793          	addi	a5,a5,-580 # 80000e3c <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7119                	addi	sp,sp,-128
    800000d2:	fc86                	sd	ra,120(sp)
    800000d4:	f8a2                	sd	s0,112(sp)
    800000d6:	f4a6                	sd	s1,104(sp)
    800000d8:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000da:	06c05a63          	blez	a2,8000014e <consolewrite+0x7e>
    800000de:	f0ca                	sd	s2,96(sp)
    800000e0:	ecce                	sd	s3,88(sp)
    800000e2:	e8d2                	sd	s4,80(sp)
    800000e4:	e4d6                	sd	s5,72(sp)
    800000e6:	e0da                	sd	s6,64(sp)
    800000e8:	fc5e                	sd	s7,56(sp)
    800000ea:	f862                	sd	s8,48(sp)
    800000ec:	f466                	sd	s9,40(sp)
    800000ee:	8aaa                	mv	s5,a0
    800000f0:	8b2e                	mv	s6,a1
    800000f2:	8a32                	mv	s4,a2
  int i = 0;
    800000f4:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f6:	02000c13          	li	s8,32
    800000fa:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fe:	5bfd                	li	s7,-1
    80000100:	a035                	j	8000012c <consolewrite+0x5c>
    if(nn > n - i)
    80000102:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000106:	86ce                	mv	a3,s3
    80000108:	01648633          	add	a2,s1,s6
    8000010c:	85d6                	mv	a1,s5
    8000010e:	f8040513          	addi	a0,s0,-128
    80000112:	1a0020ef          	jal	800022b2 <either_copyin>
    80000116:	03750e63          	beq	a0,s7,80000152 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011a:	85ce                	mv	a1,s3
    8000011c:	f8040513          	addi	a0,s0,-128
    80000120:	778000ef          	jal	80000898 <uartwrite>
    i += nn;
    80000124:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80000128:	0144da63          	bge	s1,s4,8000013c <consolewrite+0x6c>
    if(nn > n - i)
    8000012c:	409a093b          	subw	s2,s4,s1
    80000130:	0009079b          	sext.w	a5,s2
    80000134:	fcfc57e3          	bge	s8,a5,80000102 <consolewrite+0x32>
    80000138:	8966                	mv	s2,s9
    8000013a:	b7e1                	j	80000102 <consolewrite+0x32>
    8000013c:	7906                	ld	s2,96(sp)
    8000013e:	69e6                	ld	s3,88(sp)
    80000140:	6a46                	ld	s4,80(sp)
    80000142:	6aa6                	ld	s5,72(sp)
    80000144:	6b06                	ld	s6,64(sp)
    80000146:	7be2                	ld	s7,56(sp)
    80000148:	7c42                	ld	s8,48(sp)
    8000014a:	7ca2                	ld	s9,40(sp)
    8000014c:	a819                	j	80000162 <consolewrite+0x92>
  int i = 0;
    8000014e:	4481                	li	s1,0
    80000150:	a809                	j	80000162 <consolewrite+0x92>
    80000152:	7906                	ld	s2,96(sp)
    80000154:	69e6                	ld	s3,88(sp)
    80000156:	6a46                	ld	s4,80(sp)
    80000158:	6aa6                	ld	s5,72(sp)
    8000015a:	6b06                	ld	s6,64(sp)
    8000015c:	7be2                	ld	s7,56(sp)
    8000015e:	7c42                	ld	s8,48(sp)
    80000160:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000162:	8526                	mv	a0,s1
    80000164:	70e6                	ld	ra,120(sp)
    80000166:	7446                	ld	s0,112(sp)
    80000168:	74a6                	ld	s1,104(sp)
    8000016a:	6109                	addi	sp,sp,128
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	00012517          	auipc	a0,0x12
    80000190:	31450513          	addi	a0,a0,788 # 800124a0 <cons>
    80000194:	23b000ef          	jal	80000bce <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	00012497          	auipc	s1,0x12
    8000019c:	30848493          	addi	s1,s1,776 # 800124a0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	00012917          	auipc	s2,0x12
    800001a4:	39890913          	addi	s2,s2,920 # 80012538 <cons+0x98>
  while(n > 0){
    800001a8:	0b305d63          	blez	s3,80000262 <consoleread+0xf4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	0af71263          	bne	a4,a5,80000258 <consoleread+0xea>
      if(killed(myproc())){
    800001b8:	71a010ef          	jal	800018d2 <myproc>
    800001bc:	789010ef          	jal	80002144 <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	547010ef          	jal	80001f0c <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef703e3          	beq	a4,a5,800001b8 <consoleread+0x4a>
    800001d6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d8:	00012717          	auipc	a4,0x12
    800001dc:	2c870713          	addi	a4,a4,712 # 800124a0 <cons>
    800001e0:	0017869b          	addiw	a3,a5,1
    800001e4:	08d72c23          	sw	a3,152(a4)
    800001e8:	07f7f693          	andi	a3,a5,127
    800001ec:	9736                	add	a4,a4,a3
    800001ee:	01874703          	lbu	a4,24(a4)
    800001f2:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001f6:	4691                	li	a3,4
    800001f8:	04db8663          	beq	s7,a3,80000244 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001fc:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000200:	4685                	li	a3,1
    80000202:	faf40613          	addi	a2,s0,-81
    80000206:	85d2                	mv	a1,s4
    80000208:	8556                	mv	a0,s5
    8000020a:	05e020ef          	jal	80002268 <either_copyout>
    8000020e:	57fd                	li	a5,-1
    80000210:	04f50863          	beq	a0,a5,80000260 <consoleread+0xf2>
      break;

    dst++;
    80000214:	0a05                	addi	s4,s4,1
    --n;
    80000216:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000218:	47a9                	li	a5,10
    8000021a:	04fb8d63          	beq	s7,a5,80000274 <consoleread+0x106>
    8000021e:	6be2                	ld	s7,24(sp)
    80000220:	b761                	j	800001a8 <consoleread+0x3a>
        release(&cons.lock);
    80000222:	00012517          	auipc	a0,0x12
    80000226:	27e50513          	addi	a0,a0,638 # 800124a0 <cons>
    8000022a:	23d000ef          	jal	80000c66 <release>
        return -1;
    8000022e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000230:	60e6                	ld	ra,88(sp)
    80000232:	6446                	ld	s0,80(sp)
    80000234:	64a6                	ld	s1,72(sp)
    80000236:	6906                	ld	s2,64(sp)
    80000238:	79e2                	ld	s3,56(sp)
    8000023a:	7a42                	ld	s4,48(sp)
    8000023c:	7aa2                	ld	s5,40(sp)
    8000023e:	7b02                	ld	s6,32(sp)
    80000240:	6125                	addi	sp,sp,96
    80000242:	8082                	ret
      if(n < target){
    80000244:	0009871b          	sext.w	a4,s3
    80000248:	01677a63          	bgeu	a4,s6,8000025c <consoleread+0xee>
        cons.r--;
    8000024c:	00012717          	auipc	a4,0x12
    80000250:	2ef72623          	sw	a5,748(a4) # 80012538 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	00012517          	auipc	a0,0x12
    80000266:	23e50513          	addi	a0,a0,574 # 800124a0 <cons>
    8000026a:	1fd000ef          	jal	80000c66 <release>
  return target - n;
    8000026e:	413b053b          	subw	a0,s6,s3
    80000272:	bf7d                	j	80000230 <consoleread+0xc2>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	b7f5                	j	80000262 <consoleread+0xf4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50863          	beq	a0,a5,80000294 <consputc+0x1c>
    uartputc_sync(c);
    80000288:	6a4000ef          	jal	8000092c <uartputc_sync>
}
    8000028c:	60a2                	ld	ra,8(sp)
    8000028e:	6402                	ld	s0,0(sp)
    80000290:	0141                	addi	sp,sp,16
    80000292:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000294:	4521                	li	a0,8
    80000296:	696000ef          	jal	8000092c <uartputc_sync>
    8000029a:	02000513          	li	a0,32
    8000029e:	68e000ef          	jal	8000092c <uartputc_sync>
    800002a2:	4521                	li	a0,8
    800002a4:	688000ef          	jal	8000092c <uartputc_sync>
    800002a8:	b7d5                	j	8000028c <consputc+0x14>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	1000                	addi	s0,sp,32
    800002b4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b6:	00012517          	auipc	a0,0x12
    800002ba:	1ea50513          	addi	a0,a0,490 # 800124a0 <cons>
    800002be:	111000ef          	jal	80000bce <acquire>

  switch(c){
    800002c2:	47d5                	li	a5,21
    800002c4:	08f48f63          	beq	s1,a5,80000362 <consoleintr+0xb8>
    800002c8:	0297c563          	blt	a5,s1,800002f2 <consoleintr+0x48>
    800002cc:	47a1                	li	a5,8
    800002ce:	0ef48463          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    800002d2:	47c1                	li	a5,16
    800002d4:	10f49563          	bne	s1,a5,800003de <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002d8:	024020ef          	jal	800022fc <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002dc:	00012517          	auipc	a0,0x12
    800002e0:	1c450513          	addi	a0,a0,452 # 800124a0 <cons>
    800002e4:	183000ef          	jal	80000c66 <release>
}
    800002e8:	60e2                	ld	ra,24(sp)
    800002ea:	6442                	ld	s0,16(sp)
    800002ec:	64a2                	ld	s1,8(sp)
    800002ee:	6105                	addi	sp,sp,32
    800002f0:	8082                	ret
  switch(c){
    800002f2:	07f00793          	li	a5,127
    800002f6:	0cf48063          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fa:	00012717          	auipc	a4,0x12
    800002fe:	1a670713          	addi	a4,a4,422 # 800124a0 <cons>
    80000302:	0a072783          	lw	a5,160(a4)
    80000306:	09872703          	lw	a4,152(a4)
    8000030a:	9f99                	subw	a5,a5,a4
    8000030c:	07f00713          	li	a4,127
    80000310:	fcf766e3          	bltu	a4,a5,800002dc <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000314:	47b5                	li	a5,13
    80000316:	0cf48763          	beq	s1,a5,800003e4 <consoleintr+0x13a>
      consputc(c);
    8000031a:	8526                	mv	a0,s1
    8000031c:	f5dff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000320:	00012797          	auipc	a5,0x12
    80000324:	18078793          	addi	a5,a5,384 # 800124a0 <cons>
    80000328:	0a07a683          	lw	a3,160(a5)
    8000032c:	0016871b          	addiw	a4,a3,1
    80000330:	0007061b          	sext.w	a2,a4
    80000334:	0ae7a023          	sw	a4,160(a5)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	97b6                	add	a5,a5,a3
    8000033e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	47a9                	li	a5,10
    80000344:	0cf48563          	beq	s1,a5,8000040e <consoleintr+0x164>
    80000348:	4791                	li	a5,4
    8000034a:	0cf48263          	beq	s1,a5,8000040e <consoleintr+0x164>
    8000034e:	00012797          	auipc	a5,0x12
    80000352:	1ea7a783          	lw	a5,490(a5) # 80012538 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	00012717          	auipc	a4,0x12
    80000368:	13c70713          	addi	a4,a4,316 # 800124a0 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	00012497          	auipc	s1,0x12
    80000378:	12c48493          	addi	s1,s1,300 # 800124a0 <cons>
    while(cons.e != cons.w &&
    8000037c:	4929                	li	s2,10
    8000037e:	02f70863          	beq	a4,a5,800003ae <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000382:	37fd                	addiw	a5,a5,-1
    80000384:	07f7f713          	andi	a4,a5,127
    80000388:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000038a:	01874703          	lbu	a4,24(a4)
    8000038e:	03270263          	beq	a4,s2,800003b2 <consoleintr+0x108>
      cons.e--;
    80000392:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000396:	10000513          	li	a0,256
    8000039a:	edfff0ef          	jal	80000278 <consputc>
    while(cons.e != cons.w &&
    8000039e:	0a04a783          	lw	a5,160(s1)
    800003a2:	09c4a703          	lw	a4,156(s1)
    800003a6:	fcf71ee3          	bne	a4,a5,80000382 <consoleintr+0xd8>
    800003aa:	6902                	ld	s2,0(sp)
    800003ac:	bf05                	j	800002dc <consoleintr+0x32>
    800003ae:	6902                	ld	s2,0(sp)
    800003b0:	b735                	j	800002dc <consoleintr+0x32>
    800003b2:	6902                	ld	s2,0(sp)
    800003b4:	b725                	j	800002dc <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b6:	00012717          	auipc	a4,0x12
    800003ba:	0ea70713          	addi	a4,a4,234 # 800124a0 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	00012717          	auipc	a4,0x12
    800003d0:	16f72a23          	sw	a5,372(a4) # 80012540 <cons+0xa0>
      consputc(BACKSPACE);
    800003d4:	10000513          	li	a0,256
    800003d8:	ea1ff0ef          	jal	80000278 <consputc>
    800003dc:	b701                	j	800002dc <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003de:	ee048fe3          	beqz	s1,800002dc <consoleintr+0x32>
    800003e2:	bf21                	j	800002fa <consoleintr+0x50>
      consputc(c);
    800003e4:	4529                	li	a0,10
    800003e6:	e93ff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003ea:	00012797          	auipc	a5,0x12
    800003ee:	0b678793          	addi	a5,a5,182 # 800124a0 <cons>
    800003f2:	0a07a703          	lw	a4,160(a5)
    800003f6:	0017069b          	addiw	a3,a4,1
    800003fa:	0006861b          	sext.w	a2,a3
    800003fe:	0ad7a023          	sw	a3,160(a5)
    80000402:	07f77713          	andi	a4,a4,127
    80000406:	97ba                	add	a5,a5,a4
    80000408:	4729                	li	a4,10
    8000040a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040e:	00012797          	auipc	a5,0x12
    80000412:	12c7a723          	sw	a2,302(a5) # 8001253c <cons+0x9c>
        wakeup(&cons.r);
    80000416:	00012517          	auipc	a0,0x12
    8000041a:	12250513          	addi	a0,a0,290 # 80012538 <cons+0x98>
    8000041e:	33b010ef          	jal	80001f58 <wakeup>
    80000422:	bd6d                	j	800002dc <consoleintr+0x32>

0000000080000424 <consoleinit>:

void
consoleinit(void)
{
    80000424:	1141                	addi	sp,sp,-16
    80000426:	e406                	sd	ra,8(sp)
    80000428:	e022                	sd	s0,0(sp)
    8000042a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000042c:	00007597          	auipc	a1,0x7
    80000430:	bd458593          	addi	a1,a1,-1068 # 80007000 <etext>
    80000434:	00012517          	auipc	a0,0x12
    80000438:	06c50513          	addi	a0,a0,108 # 800124a0 <cons>
    8000043c:	712000ef          	jal	80000b4e <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	00023797          	auipc	a5,0x23
    80000448:	1e478793          	addi	a5,a5,484 # 80023628 <devsw>
    8000044c:	00000717          	auipc	a4,0x0
    80000450:	d2270713          	addi	a4,a4,-734 # 8000016e <consoleread>
    80000454:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000456:	00000717          	auipc	a4,0x0
    8000045a:	c7a70713          	addi	a4,a4,-902 # 800000d0 <consolewrite>
    8000045e:	ef98                	sd	a4,24(a5)
}
    80000460:	60a2                	ld	ra,8(sp)
    80000462:	6402                	ld	s0,0(sp)
    80000464:	0141                	addi	sp,sp,16
    80000466:	8082                	ret

0000000080000468 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000468:	7139                	addi	sp,sp,-64
    8000046a:	fc06                	sd	ra,56(sp)
    8000046c:	f822                	sd	s0,48(sp)
    8000046e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000470:	c219                	beqz	a2,80000476 <printint+0xe>
    80000472:	08054063          	bltz	a0,800004f2 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000476:	4881                	li	a7,0
    80000478:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000047c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00007617          	auipc	a2,0x7
    80000482:	2b260613          	addi	a2,a2,690 # 80007730 <digits>
    80000486:	883e                	mv	a6,a5
    80000488:	2785                	addiw	a5,a5,1
    8000048a:	02b57733          	remu	a4,a0,a1
    8000048e:	9732                	add	a4,a4,a2
    80000490:	00074703          	lbu	a4,0(a4)
    80000494:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000498:	872a                	mv	a4,a0
    8000049a:	02b55533          	divu	a0,a0,a1
    8000049e:	0685                	addi	a3,a3,1
    800004a0:	feb773e3          	bgeu	a4,a1,80000486 <printint+0x1e>

  if(sign)
    800004a4:	00088a63          	beqz	a7,800004b8 <printint+0x50>
    buf[i++] = '-';
    800004a8:	1781                	addi	a5,a5,-32
    800004aa:	97a2                	add	a5,a5,s0
    800004ac:	02d00713          	li	a4,45
    800004b0:	fee78423          	sb	a4,-24(a5)
    800004b4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800004b8:	02f05963          	blez	a5,800004ea <printint+0x82>
    800004bc:	f426                	sd	s1,40(sp)
    800004be:	f04a                	sd	s2,32(sp)
    800004c0:	fc840713          	addi	a4,s0,-56
    800004c4:	00f704b3          	add	s1,a4,a5
    800004c8:	fff70913          	addi	s2,a4,-1
    800004cc:	993e                	add	s2,s2,a5
    800004ce:	37fd                	addiw	a5,a5,-1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004d8:	fff4c503          	lbu	a0,-1(s1)
    800004dc:	d9dff0ef          	jal	80000278 <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x70>
    800004e6:	74a2                	ld	s1,40(sp)
    800004e8:	7902                	ld	s2,32(sp)
}
    800004ea:	70e2                	ld	ra,56(sp)
    800004ec:	7442                	ld	s0,48(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4885                	li	a7,1
    x = -xx;
    800004f8:	b741                	j	80000478 <printint+0x10>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	e8d2                	sd	s4,80(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	8a2a                	mv	s4,a0
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
    80000518:	0000a797          	auipc	a5,0xa
    8000051c:	f5c7a783          	lw	a5,-164(a5) # 8000a474 <panicking>
    80000520:	c3a1                	beqz	a5,80000560 <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	000a4503          	lbu	a0,0(s4)
    8000052e:	28050763          	beqz	a0,800007bc <printf+0x2c2>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	f0ca                	sd	s2,96(sp)
    80000536:	ecce                	sd	s3,88(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	f862                	sd	s8,48(sp)
    8000053e:	f466                	sd	s9,40(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4981                	li	s3,0
    if(cx != '%'){
    80000546:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000054a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000054e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000552:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000556:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000055a:	07000d93          	li	s11,112
    8000055e:	a01d                	j	80000584 <printf+0x8a>
    acquire(&pr.lock);
    80000560:	00012517          	auipc	a0,0x12
    80000564:	fe850513          	addi	a0,a0,-24 # 80012548 <pr>
    80000568:	666000ef          	jal	80000bce <acquire>
    8000056c:	bf5d                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056e:	d0bff0ef          	jal	80000278 <consputc>
      continue;
    80000572:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000574:	0014899b          	addiw	s3,s1,1
    80000578:	013a07b3          	add	a5,s4,s3
    8000057c:	0007c503          	lbu	a0,0(a5)
    80000580:	20050b63          	beqz	a0,80000796 <printf+0x29c>
    if(cx != '%'){
    80000584:	ff5515e3          	bne	a0,s5,8000056e <printf+0x74>
    i++;
    80000588:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000058c:	009a07b3          	add	a5,s4,s1
    80000590:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000594:	20090b63          	beqz	s2,800007aa <printf+0x2b0>
    80000598:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000059c:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059e:	c789                	beqz	a5,800005a8 <printf+0xae>
    800005a0:	009a0733          	add	a4,s4,s1
    800005a4:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800005a8:	03690963          	beq	s2,s6,800005da <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    800005ac:	05890363          	beq	s2,s8,800005f2 <printf+0xf8>
    } else if(c0 == 'u'){
    800005b0:	0d990663          	beq	s2,s9,8000067c <printf+0x182>
    } else if(c0 == 'x'){
    800005b4:	11a90d63          	beq	s2,s10,800006ce <printf+0x1d4>
    } else if(c0 == 'p'){
    800005b8:	15b90663          	beq	s2,s11,80000704 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800005bc:	06300793          	li	a5,99
    800005c0:	18f90563          	beq	s2,a5,8000074a <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800005c4:	07300793          	li	a5,115
    800005c8:	18f90b63          	beq	s2,a5,8000075e <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005cc:	03591b63          	bne	s2,s5,80000602 <printf+0x108>
      consputc('%');
    800005d0:	02500513          	li	a0,37
    800005d4:	ca5ff0ef          	jal	80000278 <consputc>
    800005d8:	bf71                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005da:	f8843783          	ld	a5,-120(s0)
    800005de:	00878713          	addi	a4,a5,8
    800005e2:	f8e43423          	sd	a4,-120(s0)
    800005e6:	4605                	li	a2,1
    800005e8:	45a9                	li	a1,10
    800005ea:	4388                	lw	a0,0(a5)
    800005ec:	e7dff0ef          	jal	80000468 <printint>
    800005f0:	b751                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    800005f2:	01678f63          	beq	a5,s6,80000610 <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005f6:	03878b63          	beq	a5,s8,8000062c <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    800005fa:	09978e63          	beq	a5,s9,80000696 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    800005fe:	0fa78563          	beq	a5,s10,800006e8 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000602:	8556                	mv	a0,s5
    80000604:	c75ff0ef          	jal	80000278 <consputc>
      consputc(c0);
    80000608:	854a                	mv	a0,s2
    8000060a:	c6fff0ef          	jal	80000278 <consputc>
    8000060e:	b79d                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000610:	f8843783          	ld	a5,-120(s0)
    80000614:	00878713          	addi	a4,a5,8
    80000618:	f8e43423          	sd	a4,-120(s0)
    8000061c:	4605                	li	a2,1
    8000061e:	45a9                	li	a1,10
    80000620:	6388                	ld	a0,0(a5)
    80000622:	e47ff0ef          	jal	80000468 <printint>
      i += 1;
    80000626:	0029849b          	addiw	s1,s3,2
    8000062a:	b7a9                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000062c:	06400793          	li	a5,100
    80000630:	02f68863          	beq	a3,a5,80000660 <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000634:	07500793          	li	a5,117
    80000638:	06f68d63          	beq	a3,a5,800006b2 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000063c:	07800793          	li	a5,120
    80000640:	fcf691e3          	bne	a3,a5,80000602 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4601                	li	a2,0
    80000652:	45c1                	li	a1,16
    80000654:	6388                	ld	a0,0(a5)
    80000656:	e13ff0ef          	jal	80000468 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bf19                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4605                	li	a2,1
    8000066e:	45a9                	li	a1,10
    80000670:	6388                	ld	a0,0(a5)
    80000672:	df7ff0ef          	jal	80000468 <printint>
      i += 2;
    80000676:	0039849b          	addiw	s1,s3,3
    8000067a:	bded                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4601                	li	a2,0
    8000068a:	45a9                	li	a1,10
    8000068c:	0007e503          	lwu	a0,0(a5)
    80000690:	dd9ff0ef          	jal	80000468 <printint>
    80000694:	b5c5                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	4601                	li	a2,0
    800006a4:	45a9                	li	a1,10
    800006a6:	6388                	ld	a0,0(a5)
    800006a8:	dc1ff0ef          	jal	80000468 <printint>
      i += 1;
    800006ac:	0029849b          	addiw	s1,s3,2
    800006b0:	b5d1                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4601                	li	a2,0
    800006c0:	45a9                	li	a1,10
    800006c2:	6388                	ld	a0,0(a5)
    800006c4:	da5ff0ef          	jal	80000468 <printint>
      i += 2;
    800006c8:	0039849b          	addiw	s1,s3,3
    800006cc:	b565                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	4601                	li	a2,0
    800006dc:	45c1                	li	a1,16
    800006de:	0007e503          	lwu	a0,0(a5)
    800006e2:	d87ff0ef          	jal	80000468 <printint>
    800006e6:	b579                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	4601                	li	a2,0
    800006f6:	45c1                	li	a1,16
    800006f8:	6388                	ld	a0,0(a5)
    800006fa:	d6fff0ef          	jal	80000468 <printint>
      i += 1;
    800006fe:	0029849b          	addiw	s1,s3,2
    80000702:	bd8d                	j	80000574 <printf+0x7a>
    80000704:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000706:	f8843783          	ld	a5,-120(s0)
    8000070a:	00878713          	addi	a4,a5,8
    8000070e:	f8e43423          	sd	a4,-120(s0)
    80000712:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000716:	03000513          	li	a0,48
    8000071a:	b5fff0ef          	jal	80000278 <consputc>
  consputc('x');
    8000071e:	07800513          	li	a0,120
    80000722:	b57ff0ef          	jal	80000278 <consputc>
    80000726:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000728:	00007b97          	auipc	s7,0x7
    8000072c:	008b8b93          	addi	s7,s7,8 # 80007730 <digits>
    80000730:	03c9d793          	srli	a5,s3,0x3c
    80000734:	97de                	add	a5,a5,s7
    80000736:	0007c503          	lbu	a0,0(a5)
    8000073a:	b3fff0ef          	jal	80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000073e:	0992                	slli	s3,s3,0x4
    80000740:	397d                	addiw	s2,s2,-1
    80000742:	fe0917e3          	bnez	s2,80000730 <printf+0x236>
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	b535                	j	80000574 <printf+0x7a>
      consputc(va_arg(ap, uint));
    8000074a:	f8843783          	ld	a5,-120(s0)
    8000074e:	00878713          	addi	a4,a5,8
    80000752:	f8e43423          	sd	a4,-120(s0)
    80000756:	4388                	lw	a0,0(a5)
    80000758:	b21ff0ef          	jal	80000278 <consputc>
    8000075c:	bd21                	j	80000574 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000075e:	f8843783          	ld	a5,-120(s0)
    80000762:	00878713          	addi	a4,a5,8
    80000766:	f8e43423          	sd	a4,-120(s0)
    8000076a:	0007b903          	ld	s2,0(a5)
    8000076e:	00090d63          	beqz	s2,80000788 <printf+0x28e>
      for(; *s; s++)
    80000772:	00094503          	lbu	a0,0(s2)
    80000776:	de050fe3          	beqz	a0,80000574 <printf+0x7a>
        consputc(*s);
    8000077a:	affff0ef          	jal	80000278 <consputc>
      for(; *s; s++)
    8000077e:	0905                	addi	s2,s2,1
    80000780:	00094503          	lbu	a0,0(s2)
    80000784:	f97d                	bnez	a0,8000077a <printf+0x280>
    80000786:	b3fd                	j	80000574 <printf+0x7a>
        s = "(null)";
    80000788:	00007917          	auipc	s2,0x7
    8000078c:	88090913          	addi	s2,s2,-1920 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000790:	02800513          	li	a0,40
    80000794:	b7dd                	j	8000077a <printf+0x280>
    80000796:	74a6                	ld	s1,104(sp)
    80000798:	7906                	ld	s2,96(sp)
    8000079a:	69e6                	ld	s3,88(sp)
    8000079c:	6aa6                	ld	s5,72(sp)
    8000079e:	6b06                	ld	s6,64(sp)
    800007a0:	7c42                	ld	s8,48(sp)
    800007a2:	7ca2                	ld	s9,40(sp)
    800007a4:	7d02                	ld	s10,32(sp)
    800007a6:	6de2                	ld	s11,24(sp)
    800007a8:	a811                	j	800007bc <printf+0x2c2>
    800007aa:	74a6                	ld	s1,104(sp)
    800007ac:	7906                	ld	s2,96(sp)
    800007ae:	69e6                	ld	s3,88(sp)
    800007b0:	6aa6                	ld	s5,72(sp)
    800007b2:	6b06                	ld	s6,64(sp)
    800007b4:	7c42                	ld	s8,48(sp)
    800007b6:	7ca2                	ld	s9,40(sp)
    800007b8:	7d02                	ld	s10,32(sp)
    800007ba:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    800007bc:	0000a797          	auipc	a5,0xa
    800007c0:	cb87a783          	lw	a5,-840(a5) # 8000a474 <panicking>
    800007c4:	c799                	beqz	a5,800007d2 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007c6:	4501                	li	a0,0
    800007c8:	70e6                	ld	ra,120(sp)
    800007ca:	7446                	ld	s0,112(sp)
    800007cc:	6a46                	ld	s4,80(sp)
    800007ce:	6129                	addi	sp,sp,192
    800007d0:	8082                	ret
    release(&pr.lock);
    800007d2:	00012517          	auipc	a0,0x12
    800007d6:	d7650513          	addi	a0,a0,-650 # 80012548 <pr>
    800007da:	48c000ef          	jal	80000c66 <release>
  return 0;
    800007de:	b7e5                	j	800007c6 <printf+0x2cc>

00000000800007e0 <panic>:

void
panic(char *s)
{
    800007e0:	1101                	addi	sp,sp,-32
    800007e2:	ec06                	sd	ra,24(sp)
    800007e4:	e822                	sd	s0,16(sp)
    800007e6:	e426                	sd	s1,8(sp)
    800007e8:	e04a                	sd	s2,0(sp)
    800007ea:	1000                	addi	s0,sp,32
    800007ec:	84aa                	mv	s1,a0
  panicking = 1;
    800007ee:	4905                	li	s2,1
    800007f0:	0000a797          	auipc	a5,0xa
    800007f4:	c927a223          	sw	s2,-892(a5) # 8000a474 <panicking>
  printf("panic: ");
    800007f8:	00007517          	auipc	a0,0x7
    800007fc:	82050513          	addi	a0,a0,-2016 # 80007018 <etext+0x18>
    80000800:	cfbff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000804:	85a6                	mv	a1,s1
    80000806:	00007517          	auipc	a0,0x7
    8000080a:	81a50513          	addi	a0,a0,-2022 # 80007020 <etext+0x20>
    8000080e:	cedff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000812:	0000a797          	auipc	a5,0xa
    80000816:	c527af23          	sw	s2,-930(a5) # 8000a470 <panicked>
  for(;;)
    8000081a:	a001                	j	8000081a <panic+0x3a>

000000008000081c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000081c:	1141                	addi	sp,sp,-16
    8000081e:	e406                	sd	ra,8(sp)
    80000820:	e022                	sd	s0,0(sp)
    80000822:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000824:	00007597          	auipc	a1,0x7
    80000828:	80458593          	addi	a1,a1,-2044 # 80007028 <etext+0x28>
    8000082c:	00012517          	auipc	a0,0x12
    80000830:	d1c50513          	addi	a0,a0,-740 # 80012548 <pr>
    80000834:	31a000ef          	jal	80000b4e <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000840:	1141                	addi	sp,sp,-16
    80000842:	e406                	sd	ra,8(sp)
    80000844:	e022                	sd	s0,0(sp)
    80000846:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000848:	100007b7          	lui	a5,0x10000
    8000084c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000850:	10000737          	lui	a4,0x10000
    80000854:	f8000693          	li	a3,-128
    80000858:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000085c:	468d                	li	a3,3
    8000085e:	10000637          	lui	a2,0x10000
    80000862:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000866:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000086a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	461d                	li	a2,7
    80000874:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000878:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    8000087c:	00006597          	auipc	a1,0x6
    80000880:	7b458593          	addi	a1,a1,1972 # 80007030 <etext+0x30>
    80000884:	00012517          	auipc	a0,0x12
    80000888:	cdc50513          	addi	a0,a0,-804 # 80012560 <tx_lock>
    8000088c:	2c2000ef          	jal	80000b4e <initlock>
}
    80000890:	60a2                	ld	ra,8(sp)
    80000892:	6402                	ld	s0,0(sp)
    80000894:	0141                	addi	sp,sp,16
    80000896:	8082                	ret

0000000080000898 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000898:	715d                	addi	sp,sp,-80
    8000089a:	e486                	sd	ra,72(sp)
    8000089c:	e0a2                	sd	s0,64(sp)
    8000089e:	fc26                	sd	s1,56(sp)
    800008a0:	ec56                	sd	s5,24(sp)
    800008a2:	0880                	addi	s0,sp,80
    800008a4:	8aaa                	mv	s5,a0
    800008a6:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008a8:	00012517          	auipc	a0,0x12
    800008ac:	cb850513          	addi	a0,a0,-840 # 80012560 <tx_lock>
    800008b0:	31e000ef          	jal	80000bce <acquire>

  int i = 0;
  while(i < n){ 
    800008b4:	06905063          	blez	s1,80000914 <uartwrite+0x7c>
    800008b8:	f84a                	sd	s2,48(sp)
    800008ba:	f44e                	sd	s3,40(sp)
    800008bc:	f052                	sd	s4,32(sp)
    800008be:	e85a                	sd	s6,16(sp)
    800008c0:	e45e                	sd	s7,8(sp)
    800008c2:	8a56                	mv	s4,s5
    800008c4:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800008c6:	0000a497          	auipc	s1,0xa
    800008ca:	bb648493          	addi	s1,s1,-1098 # 8000a47c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	00012997          	auipc	s3,0x12
    800008d2:	c9298993          	addi	s3,s3,-878 # 80012560 <tx_lock>
    800008d6:	0000a917          	auipc	s2,0xa
    800008da:	ba290913          	addi	s2,s2,-1118 # 8000a478 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    800008de:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    800008e2:	4b05                	li	s6,1
    800008e4:	a005                	j	80000904 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    800008e6:	85ce                	mv	a1,s3
    800008e8:	854a                	mv	a0,s2
    800008ea:	622010ef          	jal	80001f0c <sleep>
    while(tx_busy != 0){
    800008ee:	409c                	lw	a5,0(s1)
    800008f0:	fbfd                	bnez	a5,800008e6 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    800008f2:	000a4783          	lbu	a5,0(s4)
    800008f6:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008fa:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008fe:	0a05                	addi	s4,s4,1
    80000900:	015a0563          	beq	s4,s5,8000090a <uartwrite+0x72>
    while(tx_busy != 0){
    80000904:	409c                	lw	a5,0(s1)
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x4e>
    80000908:	b7ed                	j	800008f2 <uartwrite+0x5a>
    8000090a:	7942                	ld	s2,48(sp)
    8000090c:	79a2                	ld	s3,40(sp)
    8000090e:	7a02                	ld	s4,32(sp)
    80000910:	6b42                	ld	s6,16(sp)
    80000912:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000914:	00012517          	auipc	a0,0x12
    80000918:	c4c50513          	addi	a0,a0,-948 # 80012560 <tx_lock>
    8000091c:	34a000ef          	jal	80000c66 <release>
}
    80000920:	60a6                	ld	ra,72(sp)
    80000922:	6406                	ld	s0,64(sp)
    80000924:	74e2                	ld	s1,56(sp)
    80000926:	6ae2                	ld	s5,24(sp)
    80000928:	6161                	addi	sp,sp,80
    8000092a:	8082                	ret

000000008000092c <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092c:	1101                	addi	sp,sp,-32
    8000092e:	ec06                	sd	ra,24(sp)
    80000930:	e822                	sd	s0,16(sp)
    80000932:	e426                	sd	s1,8(sp)
    80000934:	1000                	addi	s0,sp,32
    80000936:	84aa                	mv	s1,a0
  if(panicking == 0)
    80000938:	0000a797          	auipc	a5,0xa
    8000093c:	b3c7a783          	lw	a5,-1220(a5) # 8000a474 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	0000a797          	auipc	a5,0xa
    80000946:	b2e7a783          	lw	a5,-1234(a5) # 8000a470 <panicked>
    8000094a:	ef85                	bnez	a5,80000982 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094c:	10000737          	lui	a4,0x10000
    80000950:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000952:	00074783          	lbu	a5,0(a4)
    80000956:	0207f793          	andi	a5,a5,32
    8000095a:	dfe5                	beqz	a5,80000952 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095c:	0ff4f513          	zext.b	a0,s1
    80000960:	100007b7          	lui	a5,0x10000
    80000964:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000968:	0000a797          	auipc	a5,0xa
    8000096c:	b0c7a783          	lw	a5,-1268(a5) # 8000a474 <panicking>
    80000970:	cb91                	beqz	a5,80000984 <uartputc_sync+0x58>
    pop_off();
}
    80000972:	60e2                	ld	ra,24(sp)
    80000974:	6442                	ld	s0,16(sp)
    80000976:	64a2                	ld	s1,8(sp)
    80000978:	6105                	addi	sp,sp,32
    8000097a:	8082                	ret
    push_off();
    8000097c:	212000ef          	jal	80000b8e <push_off>
    80000980:	b7c9                	j	80000942 <uartputc_sync+0x16>
    for(;;)
    80000982:	a001                	j	80000982 <uartputc_sync+0x56>
    pop_off();
    80000984:	28e000ef          	jal	80000c12 <pop_off>
}
    80000988:	b7ed                	j	80000972 <uartputc_sync+0x46>

000000008000098a <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000098a:	1141                	addi	sp,sp,-16
    8000098c:	e422                	sd	s0,8(sp)
    8000098e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000990:	100007b7          	lui	a5,0x10000
    80000994:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80000996:	0007c783          	lbu	a5,0(a5)
    8000099a:	8b85                	andi	a5,a5,1
    8000099c:	cb81                	beqz	a5,800009ac <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    8000099e:	100007b7          	lui	a5,0x10000
    800009a2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a6:	6422                	ld	s0,8(sp)
    800009a8:	0141                	addi	sp,sp,16
    800009aa:	8082                	ret
    return -1;
    800009ac:	557d                	li	a0,-1
    800009ae:	bfe5                	j	800009a6 <uartgetc+0x1c>

00000000800009b0 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009b0:	1101                	addi	sp,sp,-32
    800009b2:	ec06                	sd	ra,24(sp)
    800009b4:	e822                	sd	s0,16(sp)
    800009b6:	e426                	sd	s1,8(sp)
    800009b8:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009ba:	100007b7          	lui	a5,0x10000
    800009be:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    800009c0:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    800009c4:	00012517          	auipc	a0,0x12
    800009c8:	b9c50513          	addi	a0,a0,-1124 # 80012560 <tx_lock>
    800009cc:	202000ef          	jal	80000bce <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    800009d0:	100007b7          	lui	a5,0x10000
    800009d4:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009d6:	0007c783          	lbu	a5,0(a5)
    800009da:	0207f793          	andi	a5,a5,32
    800009de:	eb89                	bnez	a5,800009f0 <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800009e0:	00012517          	auipc	a0,0x12
    800009e4:	b8050513          	addi	a0,a0,-1152 # 80012560 <tx_lock>
    800009e8:	27e000ef          	jal	80000c66 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	0000a797          	auipc	a5,0xa
    800009f4:	a807a623          	sw	zero,-1396(a5) # 8000a47c <tx_busy>
    wakeup(&tx_chan);
    800009f8:	0000a517          	auipc	a0,0xa
    800009fc:	a8050513          	addi	a0,a0,-1408 # 8000a478 <tx_chan>
    80000a00:	558010ef          	jal	80001f58 <wakeup>
    80000a04:	bff1                	j	800009e0 <uartintr+0x30>
      break;
    consoleintr(c);
    80000a06:	8a5ff0ef          	jal	800002aa <consoleintr>
    int c = uartgetc();
    80000a0a:	f81ff0ef          	jal	8000098a <uartgetc>
    if(c == -1)
    80000a0e:	fe951ce3          	bne	a0,s1,80000a06 <uartintr+0x56>
  }
}
    80000a12:	60e2                	ld	ra,24(sp)
    80000a14:	6442                	ld	s0,16(sp)
    80000a16:	64a2                	ld	s1,8(sp)
    80000a18:	6105                	addi	sp,sp,32
    80000a1a:	8082                	ret

0000000080000a1c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a1c:	1101                	addi	sp,sp,-32
    80000a1e:	ec06                	sd	ra,24(sp)
    80000a20:	e822                	sd	s0,16(sp)
    80000a22:	e426                	sd	s1,8(sp)
    80000a24:	e04a                	sd	s2,0(sp)
    80000a26:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a28:	03451793          	slli	a5,a0,0x34
    80000a2c:	e7a9                	bnez	a5,80000a76 <kfree+0x5a>
    80000a2e:	84aa                	mv	s1,a0
    80000a30:	00024797          	auipc	a5,0x24
    80000a34:	d9078793          	addi	a5,a5,-624 # 800247c0 <end>
    80000a38:	02f56f63          	bltu	a0,a5,80000a76 <kfree+0x5a>
    80000a3c:	47c5                	li	a5,17
    80000a3e:	07ee                	slli	a5,a5,0x1b
    80000a40:	02f57b63          	bgeu	a0,a5,80000a76 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a44:	6605                	lui	a2,0x1
    80000a46:	4585                	li	a1,1
    80000a48:	25a000ef          	jal	80000ca2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a4c:	00012917          	auipc	s2,0x12
    80000a50:	b2c90913          	addi	s2,s2,-1236 # 80012578 <kmem>
    80000a54:	854a                	mv	a0,s2
    80000a56:	178000ef          	jal	80000bce <acquire>
  r->next = kmem.freelist;
    80000a5a:	01893783          	ld	a5,24(s2)
    80000a5e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a60:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a64:	854a                	mv	a0,s2
    80000a66:	200000ef          	jal	80000c66 <release>
}
    80000a6a:	60e2                	ld	ra,24(sp)
    80000a6c:	6442                	ld	s0,16(sp)
    80000a6e:	64a2                	ld	s1,8(sp)
    80000a70:	6902                	ld	s2,0(sp)
    80000a72:	6105                	addi	sp,sp,32
    80000a74:	8082                	ret
    panic("kfree");
    80000a76:	00006517          	auipc	a0,0x6
    80000a7a:	5c250513          	addi	a0,a0,1474 # 80007038 <etext+0x38>
    80000a7e:	d63ff0ef          	jal	800007e0 <panic>

0000000080000a82 <freerange>:
{
    80000a82:	7179                	addi	sp,sp,-48
    80000a84:	f406                	sd	ra,40(sp)
    80000a86:	f022                	sd	s0,32(sp)
    80000a88:	ec26                	sd	s1,24(sp)
    80000a8a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a8c:	6785                	lui	a5,0x1
    80000a8e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a92:	00e504b3          	add	s1,a0,a4
    80000a96:	777d                	lui	a4,0xfffff
    80000a98:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a9a:	94be                	add	s1,s1,a5
    80000a9c:	0295e263          	bltu	a1,s1,80000ac0 <freerange+0x3e>
    80000aa0:	e84a                	sd	s2,16(sp)
    80000aa2:	e44e                	sd	s3,8(sp)
    80000aa4:	e052                	sd	s4,0(sp)
    80000aa6:	892e                	mv	s2,a1
    kfree(p);
    80000aa8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aaa:	6985                	lui	s3,0x1
    kfree(p);
    80000aac:	01448533          	add	a0,s1,s4
    80000ab0:	f6dff0ef          	jal	80000a1c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab4:	94ce                	add	s1,s1,s3
    80000ab6:	fe997be3          	bgeu	s2,s1,80000aac <freerange+0x2a>
    80000aba:	6942                	ld	s2,16(sp)
    80000abc:	69a2                	ld	s3,8(sp)
    80000abe:	6a02                	ld	s4,0(sp)
}
    80000ac0:	70a2                	ld	ra,40(sp)
    80000ac2:	7402                	ld	s0,32(sp)
    80000ac4:	64e2                	ld	s1,24(sp)
    80000ac6:	6145                	addi	sp,sp,48
    80000ac8:	8082                	ret

0000000080000aca <kinit>:
{
    80000aca:	1141                	addi	sp,sp,-16
    80000acc:	e406                	sd	ra,8(sp)
    80000ace:	e022                	sd	s0,0(sp)
    80000ad0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ad2:	00006597          	auipc	a1,0x6
    80000ad6:	56e58593          	addi	a1,a1,1390 # 80007040 <etext+0x40>
    80000ada:	00012517          	auipc	a0,0x12
    80000ade:	a9e50513          	addi	a0,a0,-1378 # 80012578 <kmem>
    80000ae2:	06c000ef          	jal	80000b4e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ae6:	45c5                	li	a1,17
    80000ae8:	05ee                	slli	a1,a1,0x1b
    80000aea:	00024517          	auipc	a0,0x24
    80000aee:	cd650513          	addi	a0,a0,-810 # 800247c0 <end>
    80000af2:	f91ff0ef          	jal	80000a82 <freerange>
}
    80000af6:	60a2                	ld	ra,8(sp)
    80000af8:	6402                	ld	s0,0(sp)
    80000afa:	0141                	addi	sp,sp,16
    80000afc:	8082                	ret

0000000080000afe <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000afe:	1101                	addi	sp,sp,-32
    80000b00:	ec06                	sd	ra,24(sp)
    80000b02:	e822                	sd	s0,16(sp)
    80000b04:	e426                	sd	s1,8(sp)
    80000b06:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b08:	00012497          	auipc	s1,0x12
    80000b0c:	a7048493          	addi	s1,s1,-1424 # 80012578 <kmem>
    80000b10:	8526                	mv	a0,s1
    80000b12:	0bc000ef          	jal	80000bce <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c485                	beqz	s1,80000b40 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	00012517          	auipc	a0,0x12
    80000b20:	a5c50513          	addi	a0,a0,-1444 # 80012578 <kmem>
    80000b24:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b26:	140000ef          	jal	80000c66 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b2a:	6605                	lui	a2,0x1
    80000b2c:	4595                	li	a1,5
    80000b2e:	8526                	mv	a0,s1
    80000b30:	172000ef          	jal	80000ca2 <memset>
  return (void*)r;
}
    80000b34:	8526                	mv	a0,s1
    80000b36:	60e2                	ld	ra,24(sp)
    80000b38:	6442                	ld	s0,16(sp)
    80000b3a:	64a2                	ld	s1,8(sp)
    80000b3c:	6105                	addi	sp,sp,32
    80000b3e:	8082                	ret
  release(&kmem.lock);
    80000b40:	00012517          	auipc	a0,0x12
    80000b44:	a3850513          	addi	a0,a0,-1480 # 80012578 <kmem>
    80000b48:	11e000ef          	jal	80000c66 <release>
  if(r)
    80000b4c:	b7e5                	j	80000b34 <kalloc+0x36>

0000000080000b4e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b4e:	1141                	addi	sp,sp,-16
    80000b50:	e422                	sd	s0,8(sp)
    80000b52:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b54:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b56:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b5a:	00053823          	sd	zero,16(a0)
}
    80000b5e:	6422                	ld	s0,8(sp)
    80000b60:	0141                	addi	sp,sp,16
    80000b62:	8082                	ret

0000000080000b64 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b64:	411c                	lw	a5,0(a0)
    80000b66:	e399                	bnez	a5,80000b6c <holding+0x8>
    80000b68:	4501                	li	a0,0
  return r;
}
    80000b6a:	8082                	ret
{
    80000b6c:	1101                	addi	sp,sp,-32
    80000b6e:	ec06                	sd	ra,24(sp)
    80000b70:	e822                	sd	s0,16(sp)
    80000b72:	e426                	sd	s1,8(sp)
    80000b74:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b76:	6904                	ld	s1,16(a0)
    80000b78:	53f000ef          	jal	800018b6 <mycpu>
    80000b7c:	40a48533          	sub	a0,s1,a0
    80000b80:	00153513          	seqz	a0,a0
}
    80000b84:	60e2                	ld	ra,24(sp)
    80000b86:	6442                	ld	s0,16(sp)
    80000b88:	64a2                	ld	s1,8(sp)
    80000b8a:	6105                	addi	sp,sp,32
    80000b8c:	8082                	ret

0000000080000b8e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8e:	1101                	addi	sp,sp,-32
    80000b90:	ec06                	sd	ra,24(sp)
    80000b92:	e822                	sd	s0,16(sp)
    80000b94:	e426                	sd	s1,8(sp)
    80000b96:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b98:	100024f3          	csrr	s1,sstatus
    80000b9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000ba0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ba2:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000ba6:	511000ef          	jal	800018b6 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cb99                	beqz	a5,80000bc2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	509000ef          	jal	800018b6 <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	4f5000ef          	jal	800018b6 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc6:	8085                	srli	s1,s1,0x1
    80000bc8:	8885                	andi	s1,s1,1
    80000bca:	dd64                	sw	s1,124(a0)
    80000bcc:	b7cd                	j	80000bae <push_off+0x20>

0000000080000bce <acquire>:
{
    80000bce:	1101                	addi	sp,sp,-32
    80000bd0:	ec06                	sd	ra,24(sp)
    80000bd2:	e822                	sd	s0,16(sp)
    80000bd4:	e426                	sd	s1,8(sp)
    80000bd6:	1000                	addi	s0,sp,32
    80000bd8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bda:	fb5ff0ef          	jal	80000b8e <push_off>
  if(holding(lk))
    80000bde:	8526                	mv	a0,s1
    80000be0:	f85ff0ef          	jal	80000b64 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	4705                	li	a4,1
  if(holding(lk))
    80000be6:	e105                	bnez	a0,80000c06 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be8:	87ba                	mv	a5,a4
    80000bea:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bee:	2781                	sext.w	a5,a5
    80000bf0:	ffe5                	bnez	a5,80000be8 <acquire+0x1a>
  __sync_synchronize();
    80000bf2:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000bf6:	4c1000ef          	jal	800018b6 <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00006517          	auipc	a0,0x6
    80000c0a:	44250513          	addi	a0,a0,1090 # 80007048 <etext+0x48>
    80000c0e:	bd3ff0ef          	jal	800007e0 <panic>

0000000080000c12 <pop_off>:

void
pop_off(void)
{
    80000c12:	1141                	addi	sp,sp,-16
    80000c14:	e406                	sd	ra,8(sp)
    80000c16:	e022                	sd	s0,0(sp)
    80000c18:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1a:	49d000ef          	jal	800018b6 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c1e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c22:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c24:	e78d                	bnez	a5,80000c4e <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c26:	5d3c                	lw	a5,120(a0)
    80000c28:	02f05963          	blez	a5,80000c5a <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c2c:	37fd                	addiw	a5,a5,-1
    80000c2e:	0007871b          	sext.w	a4,a5
    80000c32:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c34:	eb09                	bnez	a4,80000c46 <pop_off+0x34>
    80000c36:	5d7c                	lw	a5,124(a0)
    80000c38:	c799                	beqz	a5,80000c46 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c3e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c42:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c46:	60a2                	ld	ra,8(sp)
    80000c48:	6402                	ld	s0,0(sp)
    80000c4a:	0141                	addi	sp,sp,16
    80000c4c:	8082                	ret
    panic("pop_off - interruptible");
    80000c4e:	00006517          	auipc	a0,0x6
    80000c52:	40250513          	addi	a0,a0,1026 # 80007050 <etext+0x50>
    80000c56:	b8bff0ef          	jal	800007e0 <panic>
    panic("pop_off");
    80000c5a:	00006517          	auipc	a0,0x6
    80000c5e:	40e50513          	addi	a0,a0,1038 # 80007068 <etext+0x68>
    80000c62:	b7fff0ef          	jal	800007e0 <panic>

0000000080000c66 <release>:
{
    80000c66:	1101                	addi	sp,sp,-32
    80000c68:	ec06                	sd	ra,24(sp)
    80000c6a:	e822                	sd	s0,16(sp)
    80000c6c:	e426                	sd	s1,8(sp)
    80000c6e:	1000                	addi	s0,sp,32
    80000c70:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c72:	ef3ff0ef          	jal	80000b64 <holding>
    80000c76:	c105                	beqz	a0,80000c96 <release+0x30>
  lk->cpu = 0;
    80000c78:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c7c:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000c80:	0310000f          	fence	rw,w
    80000c84:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000c88:	f8bff0ef          	jal	80000c12 <pop_off>
}
    80000c8c:	60e2                	ld	ra,24(sp)
    80000c8e:	6442                	ld	s0,16(sp)
    80000c90:	64a2                	ld	s1,8(sp)
    80000c92:	6105                	addi	sp,sp,32
    80000c94:	8082                	ret
    panic("release");
    80000c96:	00006517          	auipc	a0,0x6
    80000c9a:	3da50513          	addi	a0,a0,986 # 80007070 <etext+0x70>
    80000c9e:	b43ff0ef          	jal	800007e0 <panic>

0000000080000ca2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ca2:	1141                	addi	sp,sp,-16
    80000ca4:	e422                	sd	s0,8(sp)
    80000ca6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ca8:	ca19                	beqz	a2,80000cbe <memset+0x1c>
    80000caa:	87aa                	mv	a5,a0
    80000cac:	1602                	slli	a2,a2,0x20
    80000cae:	9201                	srli	a2,a2,0x20
    80000cb0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cb4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cb8:	0785                	addi	a5,a5,1
    80000cba:	fee79de3          	bne	a5,a4,80000cb4 <memset+0x12>
  }
  return dst;
}
    80000cbe:	6422                	ld	s0,8(sp)
    80000cc0:	0141                	addi	sp,sp,16
    80000cc2:	8082                	ret

0000000080000cc4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cc4:	1141                	addi	sp,sp,-16
    80000cc6:	e422                	sd	s0,8(sp)
    80000cc8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cca:	ca05                	beqz	a2,80000cfa <memcmp+0x36>
    80000ccc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cd0:	1682                	slli	a3,a3,0x20
    80000cd2:	9281                	srli	a3,a3,0x20
    80000cd4:	0685                	addi	a3,a3,1
    80000cd6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cd8:	00054783          	lbu	a5,0(a0)
    80000cdc:	0005c703          	lbu	a4,0(a1)
    80000ce0:	00e79863          	bne	a5,a4,80000cf0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ce4:	0505                	addi	a0,a0,1
    80000ce6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ce8:	fed518e3          	bne	a0,a3,80000cd8 <memcmp+0x14>
  }

  return 0;
    80000cec:	4501                	li	a0,0
    80000cee:	a019                	j	80000cf4 <memcmp+0x30>
      return *s1 - *s2;
    80000cf0:	40e7853b          	subw	a0,a5,a4
}
    80000cf4:	6422                	ld	s0,8(sp)
    80000cf6:	0141                	addi	sp,sp,16
    80000cf8:	8082                	ret
  return 0;
    80000cfa:	4501                	li	a0,0
    80000cfc:	bfe5                	j	80000cf4 <memcmp+0x30>

0000000080000cfe <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000cfe:	1141                	addi	sp,sp,-16
    80000d00:	e422                	sd	s0,8(sp)
    80000d02:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d04:	c205                	beqz	a2,80000d24 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d06:	02a5e263          	bltu	a1,a0,80000d2a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d0a:	1602                	slli	a2,a2,0x20
    80000d0c:	9201                	srli	a2,a2,0x20
    80000d0e:	00c587b3          	add	a5,a1,a2
{
    80000d12:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d14:	0585                	addi	a1,a1,1
    80000d16:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffda841>
    80000d18:	fff5c683          	lbu	a3,-1(a1)
    80000d1c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d20:	feb79ae3          	bne	a5,a1,80000d14 <memmove+0x16>

  return dst;
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  if(s < d && s + n > d){
    80000d2a:	02061693          	slli	a3,a2,0x20
    80000d2e:	9281                	srli	a3,a3,0x20
    80000d30:	00d58733          	add	a4,a1,a3
    80000d34:	fce57be3          	bgeu	a0,a4,80000d0a <memmove+0xc>
    d += n;
    80000d38:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d3a:	fff6079b          	addiw	a5,a2,-1
    80000d3e:	1782                	slli	a5,a5,0x20
    80000d40:	9381                	srli	a5,a5,0x20
    80000d42:	fff7c793          	not	a5,a5
    80000d46:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d48:	177d                	addi	a4,a4,-1
    80000d4a:	16fd                	addi	a3,a3,-1
    80000d4c:	00074603          	lbu	a2,0(a4)
    80000d50:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d54:	fef71ae3          	bne	a4,a5,80000d48 <memmove+0x4a>
    80000d58:	b7f1                	j	80000d24 <memmove+0x26>

0000000080000d5a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d5a:	1141                	addi	sp,sp,-16
    80000d5c:	e406                	sd	ra,8(sp)
    80000d5e:	e022                	sd	s0,0(sp)
    80000d60:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d62:	f9dff0ef          	jal	80000cfe <memmove>
}
    80000d66:	60a2                	ld	ra,8(sp)
    80000d68:	6402                	ld	s0,0(sp)
    80000d6a:	0141                	addi	sp,sp,16
    80000d6c:	8082                	ret

0000000080000d6e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d6e:	1141                	addi	sp,sp,-16
    80000d70:	e422                	sd	s0,8(sp)
    80000d72:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d74:	ce11                	beqz	a2,80000d90 <strncmp+0x22>
    80000d76:	00054783          	lbu	a5,0(a0)
    80000d7a:	cf89                	beqz	a5,80000d94 <strncmp+0x26>
    80000d7c:	0005c703          	lbu	a4,0(a1)
    80000d80:	00f71a63          	bne	a4,a5,80000d94 <strncmp+0x26>
    n--, p++, q++;
    80000d84:	367d                	addiw	a2,a2,-1
    80000d86:	0505                	addi	a0,a0,1
    80000d88:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d8a:	f675                	bnez	a2,80000d76 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	a801                	j	80000d9e <strncmp+0x30>
    80000d90:	4501                	li	a0,0
    80000d92:	a031                	j	80000d9e <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000d94:	00054503          	lbu	a0,0(a0)
    80000d98:	0005c783          	lbu	a5,0(a1)
    80000d9c:	9d1d                	subw	a0,a0,a5
}
    80000d9e:	6422                	ld	s0,8(sp)
    80000da0:	0141                	addi	sp,sp,16
    80000da2:	8082                	ret

0000000080000da4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000da4:	1141                	addi	sp,sp,-16
    80000da6:	e422                	sd	s0,8(sp)
    80000da8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000daa:	87aa                	mv	a5,a0
    80000dac:	86b2                	mv	a3,a2
    80000dae:	367d                	addiw	a2,a2,-1
    80000db0:	02d05563          	blez	a3,80000dda <strncpy+0x36>
    80000db4:	0785                	addi	a5,a5,1
    80000db6:	0005c703          	lbu	a4,0(a1)
    80000dba:	fee78fa3          	sb	a4,-1(a5)
    80000dbe:	0585                	addi	a1,a1,1
    80000dc0:	f775                	bnez	a4,80000dac <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dc2:	873e                	mv	a4,a5
    80000dc4:	9fb5                	addw	a5,a5,a3
    80000dc6:	37fd                	addiw	a5,a5,-1
    80000dc8:	00c05963          	blez	a2,80000dda <strncpy+0x36>
    *s++ = 0;
    80000dcc:	0705                	addi	a4,a4,1
    80000dce:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000dd2:	40e786bb          	subw	a3,a5,a4
    80000dd6:	fed04be3          	bgtz	a3,80000dcc <strncpy+0x28>
  return os;
}
    80000dda:	6422                	ld	s0,8(sp)
    80000ddc:	0141                	addi	sp,sp,16
    80000dde:	8082                	ret

0000000080000de0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e422                	sd	s0,8(sp)
    80000de4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000de6:	02c05363          	blez	a2,80000e0c <safestrcpy+0x2c>
    80000dea:	fff6069b          	addiw	a3,a2,-1
    80000dee:	1682                	slli	a3,a3,0x20
    80000df0:	9281                	srli	a3,a3,0x20
    80000df2:	96ae                	add	a3,a3,a1
    80000df4:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000df6:	00d58963          	beq	a1,a3,80000e08 <safestrcpy+0x28>
    80000dfa:	0585                	addi	a1,a1,1
    80000dfc:	0785                	addi	a5,a5,1
    80000dfe:	fff5c703          	lbu	a4,-1(a1)
    80000e02:	fee78fa3          	sb	a4,-1(a5)
    80000e06:	fb65                	bnez	a4,80000df6 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e08:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e0c:	6422                	ld	s0,8(sp)
    80000e0e:	0141                	addi	sp,sp,16
    80000e10:	8082                	ret

0000000080000e12 <strlen>:

int
strlen(const char *s)
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e422                	sd	s0,8(sp)
    80000e16:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e18:	00054783          	lbu	a5,0(a0)
    80000e1c:	cf91                	beqz	a5,80000e38 <strlen+0x26>
    80000e1e:	0505                	addi	a0,a0,1
    80000e20:	87aa                	mv	a5,a0
    80000e22:	86be                	mv	a3,a5
    80000e24:	0785                	addi	a5,a5,1
    80000e26:	fff7c703          	lbu	a4,-1(a5)
    80000e2a:	ff65                	bnez	a4,80000e22 <strlen+0x10>
    80000e2c:	40a6853b          	subw	a0,a3,a0
    80000e30:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e38:	4501                	li	a0,0
    80000e3a:	bfe5                	j	80000e32 <strlen+0x20>

0000000080000e3c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e3c:	1141                	addi	sp,sp,-16
    80000e3e:	e406                	sd	ra,8(sp)
    80000e40:	e022                	sd	s0,0(sp)
    80000e42:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e44:	263000ef          	jal	800018a6 <cpuid>
    shminit();       // shared memory initialization
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e48:	00009717          	auipc	a4,0x9
    80000e4c:	63870713          	addi	a4,a4,1592 # 8000a480 <started>
  if(cpuid() == 0){
    80000e50:	c51d                	beqz	a0,80000e7e <main+0x42>
    while(started == 0)
    80000e52:	431c                	lw	a5,0(a4)
    80000e54:	2781                	sext.w	a5,a5
    80000e56:	dff5                	beqz	a5,80000e52 <main+0x16>
      ;
    __sync_synchronize();
    80000e58:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000e5c:	24b000ef          	jal	800018a6 <cpuid>
    80000e60:	85aa                	mv	a1,a0
    80000e62:	00006517          	auipc	a0,0x6
    80000e66:	23650513          	addi	a0,a0,566 # 80007098 <etext+0x98>
    80000e6a:	e90ff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000e6e:	084000ef          	jal	80000ef2 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e72:	5bc010ef          	jal	8000242e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e76:	373040ef          	jal	800059e8 <plicinithart>
  }

  scheduler();        
    80000e7a:	6fb000ef          	jal	80001d74 <scheduler>
    consoleinit();
    80000e7e:	da6ff0ef          	jal	80000424 <consoleinit>
    printfinit();
    80000e82:	99bff0ef          	jal	8000081c <printfinit>
    printf("\n");
    80000e86:	00006517          	auipc	a0,0x6
    80000e8a:	1f250513          	addi	a0,a0,498 # 80007078 <etext+0x78>
    80000e8e:	e6cff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000e92:	00006517          	auipc	a0,0x6
    80000e96:	1ee50513          	addi	a0,a0,494 # 80007080 <etext+0x80>
    80000e9a:	e60ff0ef          	jal	800004fa <printf>
    printf("\n");
    80000e9e:	00006517          	auipc	a0,0x6
    80000ea2:	1da50513          	addi	a0,a0,474 # 80007078 <etext+0x78>
    80000ea6:	e54ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000eaa:	c21ff0ef          	jal	80000aca <kinit>
    kvminit();       // create kernel page table
    80000eae:	2ce000ef          	jal	8000117c <kvminit>
    kvminithart();   // turn on paging
    80000eb2:	040000ef          	jal	80000ef2 <kvminithart>
    procinit();      // process table
    80000eb6:	13b000ef          	jal	800017f0 <procinit>
    trapinit();      // trap vectors
    80000eba:	550010ef          	jal	8000240a <trapinit>
    trapinithart();  // install kernel trap vector
    80000ebe:	570010ef          	jal	8000242e <trapinithart>
    plicinit();      // set up interrupt controller
    80000ec2:	30d040ef          	jal	800059ce <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ec6:	323040ef          	jal	800059e8 <plicinithart>
    binit();         // buffer cache
    80000eca:	1de020ef          	jal	800030a8 <binit>
    iinit();         // inode table
    80000ece:	764020ef          	jal	80003632 <iinit>
    fileinit();      // file table
    80000ed2:	656030ef          	jal	80004528 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ed6:	403040ef          	jal	80005ad8 <virtio_disk_init>
    shminit();       // shared memory initialization
    80000eda:	5cd010ef          	jal	80002ca6 <shminit>
    userinit();      // first user process
    80000ede:	4eb000ef          	jal	80001bc8 <userinit>
    __sync_synchronize();
    80000ee2:	0330000f          	fence	rw,rw
    started = 1;
    80000ee6:	4785                	li	a5,1
    80000ee8:	00009717          	auipc	a4,0x9
    80000eec:	58f72c23          	sw	a5,1432(a4) # 8000a480 <started>
    80000ef0:	b769                	j	80000e7a <main+0x3e>

0000000080000ef2 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000ef2:	1141                	addi	sp,sp,-16
    80000ef4:	e422                	sd	s0,8(sp)
    80000ef6:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ef8:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000efc:	00009797          	auipc	a5,0x9
    80000f00:	58c7b783          	ld	a5,1420(a5) # 8000a488 <kernel_pagetable>
    80000f04:	83b1                	srli	a5,a5,0xc
    80000f06:	577d                	li	a4,-1
    80000f08:	177e                	slli	a4,a4,0x3f
    80000f0a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f0c:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f10:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f14:	6422                	ld	s0,8(sp)
    80000f16:	0141                	addi	sp,sp,16
    80000f18:	8082                	ret

0000000080000f1a <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f1a:	7139                	addi	sp,sp,-64
    80000f1c:	fc06                	sd	ra,56(sp)
    80000f1e:	f822                	sd	s0,48(sp)
    80000f20:	f426                	sd	s1,40(sp)
    80000f22:	f04a                	sd	s2,32(sp)
    80000f24:	ec4e                	sd	s3,24(sp)
    80000f26:	e852                	sd	s4,16(sp)
    80000f28:	e456                	sd	s5,8(sp)
    80000f2a:	e05a                	sd	s6,0(sp)
    80000f2c:	0080                	addi	s0,sp,64
    80000f2e:	84aa                	mv	s1,a0
    80000f30:	89ae                	mv	s3,a1
    80000f32:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f34:	57fd                	li	a5,-1
    80000f36:	83e9                	srli	a5,a5,0x1a
    80000f38:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f3a:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f3c:	02b7fc63          	bgeu	a5,a1,80000f74 <walk+0x5a>
    panic("walk");
    80000f40:	00006517          	auipc	a0,0x6
    80000f44:	17050513          	addi	a0,a0,368 # 800070b0 <etext+0xb0>
    80000f48:	899ff0ef          	jal	800007e0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f4c:	060a8263          	beqz	s5,80000fb0 <walk+0x96>
    80000f50:	bafff0ef          	jal	80000afe <kalloc>
    80000f54:	84aa                	mv	s1,a0
    80000f56:	c139                	beqz	a0,80000f9c <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f58:	6605                	lui	a2,0x1
    80000f5a:	4581                	li	a1,0
    80000f5c:	d47ff0ef          	jal	80000ca2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f60:	00c4d793          	srli	a5,s1,0xc
    80000f64:	07aa                	slli	a5,a5,0xa
    80000f66:	0017e793          	ori	a5,a5,1
    80000f6a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f6e:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffda837>
    80000f70:	036a0063          	beq	s4,s6,80000f90 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f74:	0149d933          	srl	s2,s3,s4
    80000f78:	1ff97913          	andi	s2,s2,511
    80000f7c:	090e                	slli	s2,s2,0x3
    80000f7e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f80:	00093483          	ld	s1,0(s2)
    80000f84:	0014f793          	andi	a5,s1,1
    80000f88:	d3f1                	beqz	a5,80000f4c <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f8a:	80a9                	srli	s1,s1,0xa
    80000f8c:	04b2                	slli	s1,s1,0xc
    80000f8e:	b7c5                	j	80000f6e <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f90:	00c9d513          	srli	a0,s3,0xc
    80000f94:	1ff57513          	andi	a0,a0,511
    80000f98:	050e                	slli	a0,a0,0x3
    80000f9a:	9526                	add	a0,a0,s1
}
    80000f9c:	70e2                	ld	ra,56(sp)
    80000f9e:	7442                	ld	s0,48(sp)
    80000fa0:	74a2                	ld	s1,40(sp)
    80000fa2:	7902                	ld	s2,32(sp)
    80000fa4:	69e2                	ld	s3,24(sp)
    80000fa6:	6a42                	ld	s4,16(sp)
    80000fa8:	6aa2                	ld	s5,8(sp)
    80000faa:	6b02                	ld	s6,0(sp)
    80000fac:	6121                	addi	sp,sp,64
    80000fae:	8082                	ret
        return 0;
    80000fb0:	4501                	li	a0,0
    80000fb2:	b7ed                	j	80000f9c <walk+0x82>

0000000080000fb4 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fb4:	57fd                	li	a5,-1
    80000fb6:	83e9                	srli	a5,a5,0x1a
    80000fb8:	00b7f463          	bgeu	a5,a1,80000fc0 <walkaddr+0xc>
    return 0;
    80000fbc:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fbe:	8082                	ret
{
    80000fc0:	1141                	addi	sp,sp,-16
    80000fc2:	e406                	sd	ra,8(sp)
    80000fc4:	e022                	sd	s0,0(sp)
    80000fc6:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fc8:	4601                	li	a2,0
    80000fca:	f51ff0ef          	jal	80000f1a <walk>
  if(pte == 0)
    80000fce:	c105                	beqz	a0,80000fee <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000fd0:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000fd2:	0117f693          	andi	a3,a5,17
    80000fd6:	4745                	li	a4,17
    return 0;
    80000fd8:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000fda:	00e68663          	beq	a3,a4,80000fe6 <walkaddr+0x32>
}
    80000fde:	60a2                	ld	ra,8(sp)
    80000fe0:	6402                	ld	s0,0(sp)
    80000fe2:	0141                	addi	sp,sp,16
    80000fe4:	8082                	ret
  pa = PTE2PA(*pte);
    80000fe6:	83a9                	srli	a5,a5,0xa
    80000fe8:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000fec:	bfcd                	j	80000fde <walkaddr+0x2a>
    return 0;
    80000fee:	4501                	li	a0,0
    80000ff0:	b7fd                	j	80000fde <walkaddr+0x2a>

0000000080000ff2 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000ff2:	715d                	addi	sp,sp,-80
    80000ff4:	e486                	sd	ra,72(sp)
    80000ff6:	e0a2                	sd	s0,64(sp)
    80000ff8:	fc26                	sd	s1,56(sp)
    80000ffa:	f84a                	sd	s2,48(sp)
    80000ffc:	f44e                	sd	s3,40(sp)
    80000ffe:	f052                	sd	s4,32(sp)
    80001000:	ec56                	sd	s5,24(sp)
    80001002:	e85a                	sd	s6,16(sp)
    80001004:	e45e                	sd	s7,8(sp)
    80001006:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001008:	03459793          	slli	a5,a1,0x34
    8000100c:	e7a9                	bnez	a5,80001056 <mappages+0x64>
    8000100e:	8aaa                	mv	s5,a0
    80001010:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001012:	03461793          	slli	a5,a2,0x34
    80001016:	e7b1                	bnez	a5,80001062 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80001018:	ca39                	beqz	a2,8000106e <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000101a:	77fd                	lui	a5,0xfffff
    8000101c:	963e                	add	a2,a2,a5
    8000101e:	00b609b3          	add	s3,a2,a1
  a = va;
    80001022:	892e                	mv	s2,a1
    80001024:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001028:	6b85                	lui	s7,0x1
    8000102a:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    8000102e:	4605                	li	a2,1
    80001030:	85ca                	mv	a1,s2
    80001032:	8556                	mv	a0,s5
    80001034:	ee7ff0ef          	jal	80000f1a <walk>
    80001038:	c539                	beqz	a0,80001086 <mappages+0x94>
    if(*pte & PTE_V)
    8000103a:	611c                	ld	a5,0(a0)
    8000103c:	8b85                	andi	a5,a5,1
    8000103e:	ef95                	bnez	a5,8000107a <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001040:	80b1                	srli	s1,s1,0xc
    80001042:	04aa                	slli	s1,s1,0xa
    80001044:	0164e4b3          	or	s1,s1,s6
    80001048:	0014e493          	ori	s1,s1,1
    8000104c:	e104                	sd	s1,0(a0)
    if(a == last)
    8000104e:	05390863          	beq	s2,s3,8000109e <mappages+0xac>
    a += PGSIZE;
    80001052:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001054:	bfd9                	j	8000102a <mappages+0x38>
    panic("mappages: va not aligned");
    80001056:	00006517          	auipc	a0,0x6
    8000105a:	06250513          	addi	a0,a0,98 # 800070b8 <etext+0xb8>
    8000105e:	f82ff0ef          	jal	800007e0 <panic>
    panic("mappages: size not aligned");
    80001062:	00006517          	auipc	a0,0x6
    80001066:	07650513          	addi	a0,a0,118 # 800070d8 <etext+0xd8>
    8000106a:	f76ff0ef          	jal	800007e0 <panic>
    panic("mappages: size");
    8000106e:	00006517          	auipc	a0,0x6
    80001072:	08a50513          	addi	a0,a0,138 # 800070f8 <etext+0xf8>
    80001076:	f6aff0ef          	jal	800007e0 <panic>
      panic("mappages: remap");
    8000107a:	00006517          	auipc	a0,0x6
    8000107e:	08e50513          	addi	a0,a0,142 # 80007108 <etext+0x108>
    80001082:	f5eff0ef          	jal	800007e0 <panic>
      return -1;
    80001086:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001088:	60a6                	ld	ra,72(sp)
    8000108a:	6406                	ld	s0,64(sp)
    8000108c:	74e2                	ld	s1,56(sp)
    8000108e:	7942                	ld	s2,48(sp)
    80001090:	79a2                	ld	s3,40(sp)
    80001092:	7a02                	ld	s4,32(sp)
    80001094:	6ae2                	ld	s5,24(sp)
    80001096:	6b42                	ld	s6,16(sp)
    80001098:	6ba2                	ld	s7,8(sp)
    8000109a:	6161                	addi	sp,sp,80
    8000109c:	8082                	ret
  return 0;
    8000109e:	4501                	li	a0,0
    800010a0:	b7e5                	j	80001088 <mappages+0x96>

00000000800010a2 <kvmmap>:
{
    800010a2:	1141                	addi	sp,sp,-16
    800010a4:	e406                	sd	ra,8(sp)
    800010a6:	e022                	sd	s0,0(sp)
    800010a8:	0800                	addi	s0,sp,16
    800010aa:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010ac:	86b2                	mv	a3,a2
    800010ae:	863e                	mv	a2,a5
    800010b0:	f43ff0ef          	jal	80000ff2 <mappages>
    800010b4:	e509                	bnez	a0,800010be <kvmmap+0x1c>
}
    800010b6:	60a2                	ld	ra,8(sp)
    800010b8:	6402                	ld	s0,0(sp)
    800010ba:	0141                	addi	sp,sp,16
    800010bc:	8082                	ret
    panic("kvmmap");
    800010be:	00006517          	auipc	a0,0x6
    800010c2:	05a50513          	addi	a0,a0,90 # 80007118 <etext+0x118>
    800010c6:	f1aff0ef          	jal	800007e0 <panic>

00000000800010ca <kvmmake>:
{
    800010ca:	1101                	addi	sp,sp,-32
    800010cc:	ec06                	sd	ra,24(sp)
    800010ce:	e822                	sd	s0,16(sp)
    800010d0:	e426                	sd	s1,8(sp)
    800010d2:	e04a                	sd	s2,0(sp)
    800010d4:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010d6:	a29ff0ef          	jal	80000afe <kalloc>
    800010da:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010dc:	6605                	lui	a2,0x1
    800010de:	4581                	li	a1,0
    800010e0:	bc3ff0ef          	jal	80000ca2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800010e4:	4719                	li	a4,6
    800010e6:	6685                	lui	a3,0x1
    800010e8:	10000637          	lui	a2,0x10000
    800010ec:	100005b7          	lui	a1,0x10000
    800010f0:	8526                	mv	a0,s1
    800010f2:	fb1ff0ef          	jal	800010a2 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010f6:	4719                	li	a4,6
    800010f8:	6685                	lui	a3,0x1
    800010fa:	10001637          	lui	a2,0x10001
    800010fe:	100015b7          	lui	a1,0x10001
    80001102:	8526                	mv	a0,s1
    80001104:	f9fff0ef          	jal	800010a2 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001108:	4719                	li	a4,6
    8000110a:	040006b7          	lui	a3,0x4000
    8000110e:	0c000637          	lui	a2,0xc000
    80001112:	0c0005b7          	lui	a1,0xc000
    80001116:	8526                	mv	a0,s1
    80001118:	f8bff0ef          	jal	800010a2 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000111c:	00006917          	auipc	s2,0x6
    80001120:	ee490913          	addi	s2,s2,-284 # 80007000 <etext>
    80001124:	4729                	li	a4,10
    80001126:	80006697          	auipc	a3,0x80006
    8000112a:	eda68693          	addi	a3,a3,-294 # 7000 <_entry-0x7fff9000>
    8000112e:	4605                	li	a2,1
    80001130:	067e                	slli	a2,a2,0x1f
    80001132:	85b2                	mv	a1,a2
    80001134:	8526                	mv	a0,s1
    80001136:	f6dff0ef          	jal	800010a2 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000113a:	46c5                	li	a3,17
    8000113c:	06ee                	slli	a3,a3,0x1b
    8000113e:	4719                	li	a4,6
    80001140:	412686b3          	sub	a3,a3,s2
    80001144:	864a                	mv	a2,s2
    80001146:	85ca                	mv	a1,s2
    80001148:	8526                	mv	a0,s1
    8000114a:	f59ff0ef          	jal	800010a2 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000114e:	4729                	li	a4,10
    80001150:	6685                	lui	a3,0x1
    80001152:	00005617          	auipc	a2,0x5
    80001156:	eae60613          	addi	a2,a2,-338 # 80006000 <_trampoline>
    8000115a:	040005b7          	lui	a1,0x4000
    8000115e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001160:	05b2                	slli	a1,a1,0xc
    80001162:	8526                	mv	a0,s1
    80001164:	f3fff0ef          	jal	800010a2 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001168:	8526                	mv	a0,s1
    8000116a:	5ee000ef          	jal	80001758 <proc_mapstacks>
}
    8000116e:	8526                	mv	a0,s1
    80001170:	60e2                	ld	ra,24(sp)
    80001172:	6442                	ld	s0,16(sp)
    80001174:	64a2                	ld	s1,8(sp)
    80001176:	6902                	ld	s2,0(sp)
    80001178:	6105                	addi	sp,sp,32
    8000117a:	8082                	ret

000000008000117c <kvminit>:
{
    8000117c:	1141                	addi	sp,sp,-16
    8000117e:	e406                	sd	ra,8(sp)
    80001180:	e022                	sd	s0,0(sp)
    80001182:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001184:	f47ff0ef          	jal	800010ca <kvmmake>
    80001188:	00009797          	auipc	a5,0x9
    8000118c:	30a7b023          	sd	a0,768(a5) # 8000a488 <kernel_pagetable>
}
    80001190:	60a2                	ld	ra,8(sp)
    80001192:	6402                	ld	s0,0(sp)
    80001194:	0141                	addi	sp,sp,16
    80001196:	8082                	ret

0000000080001198 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001198:	1101                	addi	sp,sp,-32
    8000119a:	ec06                	sd	ra,24(sp)
    8000119c:	e822                	sd	s0,16(sp)
    8000119e:	e426                	sd	s1,8(sp)
    800011a0:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800011a2:	95dff0ef          	jal	80000afe <kalloc>
    800011a6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800011a8:	c509                	beqz	a0,800011b2 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800011aa:	6605                	lui	a2,0x1
    800011ac:	4581                	li	a1,0
    800011ae:	af5ff0ef          	jal	80000ca2 <memset>
  return pagetable;
}
    800011b2:	8526                	mv	a0,s1
    800011b4:	60e2                	ld	ra,24(sp)
    800011b6:	6442                	ld	s0,16(sp)
    800011b8:	64a2                	ld	s1,8(sp)
    800011ba:	6105                	addi	sp,sp,32
    800011bc:	8082                	ret

00000000800011be <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011be:	7139                	addi	sp,sp,-64
    800011c0:	fc06                	sd	ra,56(sp)
    800011c2:	f822                	sd	s0,48(sp)
    800011c4:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c6:	03459793          	slli	a5,a1,0x34
    800011ca:	e38d                	bnez	a5,800011ec <uvmunmap+0x2e>
    800011cc:	f04a                	sd	s2,32(sp)
    800011ce:	ec4e                	sd	s3,24(sp)
    800011d0:	e852                	sd	s4,16(sp)
    800011d2:	e456                	sd	s5,8(sp)
    800011d4:	e05a                	sd	s6,0(sp)
    800011d6:	8a2a                	mv	s4,a0
    800011d8:	892e                	mv	s2,a1
    800011da:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011dc:	0632                	slli	a2,a2,0xc
    800011de:	00b609b3          	add	s3,a2,a1
    800011e2:	6b05                	lui	s6,0x1
    800011e4:	0535f963          	bgeu	a1,s3,80001236 <uvmunmap+0x78>
    800011e8:	f426                	sd	s1,40(sp)
    800011ea:	a015                	j	8000120e <uvmunmap+0x50>
    800011ec:	f426                	sd	s1,40(sp)
    800011ee:	f04a                	sd	s2,32(sp)
    800011f0:	ec4e                	sd	s3,24(sp)
    800011f2:	e852                	sd	s4,16(sp)
    800011f4:	e456                	sd	s5,8(sp)
    800011f6:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800011f8:	00006517          	auipc	a0,0x6
    800011fc:	f2850513          	addi	a0,a0,-216 # 80007120 <etext+0x120>
    80001200:	de0ff0ef          	jal	800007e0 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001204:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001208:	995a                	add	s2,s2,s6
    8000120a:	03397563          	bgeu	s2,s3,80001234 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    8000120e:	4601                	li	a2,0
    80001210:	85ca                	mv	a1,s2
    80001212:	8552                	mv	a0,s4
    80001214:	d07ff0ef          	jal	80000f1a <walk>
    80001218:	84aa                	mv	s1,a0
    8000121a:	d57d                	beqz	a0,80001208 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    8000121c:	611c                	ld	a5,0(a0)
    8000121e:	0017f713          	andi	a4,a5,1
    80001222:	d37d                	beqz	a4,80001208 <uvmunmap+0x4a>
    if(do_free){
    80001224:	fe0a80e3          	beqz	s5,80001204 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001228:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    8000122a:	00c79513          	slli	a0,a5,0xc
    8000122e:	feeff0ef          	jal	80000a1c <kfree>
    80001232:	bfc9                	j	80001204 <uvmunmap+0x46>
    80001234:	74a2                	ld	s1,40(sp)
    80001236:	7902                	ld	s2,32(sp)
    80001238:	69e2                	ld	s3,24(sp)
    8000123a:	6a42                	ld	s4,16(sp)
    8000123c:	6aa2                	ld	s5,8(sp)
    8000123e:	6b02                	ld	s6,0(sp)
  }
}
    80001240:	70e2                	ld	ra,56(sp)
    80001242:	7442                	ld	s0,48(sp)
    80001244:	6121                	addi	sp,sp,64
    80001246:	8082                	ret

0000000080001248 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001248:	1101                	addi	sp,sp,-32
    8000124a:	ec06                	sd	ra,24(sp)
    8000124c:	e822                	sd	s0,16(sp)
    8000124e:	e426                	sd	s1,8(sp)
    80001250:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001252:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001254:	00b67d63          	bgeu	a2,a1,8000126e <uvmdealloc+0x26>
    80001258:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000125a:	6785                	lui	a5,0x1
    8000125c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000125e:	00f60733          	add	a4,a2,a5
    80001262:	76fd                	lui	a3,0xfffff
    80001264:	8f75                	and	a4,a4,a3
    80001266:	97ae                	add	a5,a5,a1
    80001268:	8ff5                	and	a5,a5,a3
    8000126a:	00f76863          	bltu	a4,a5,8000127a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000126e:	8526                	mv	a0,s1
    80001270:	60e2                	ld	ra,24(sp)
    80001272:	6442                	ld	s0,16(sp)
    80001274:	64a2                	ld	s1,8(sp)
    80001276:	6105                	addi	sp,sp,32
    80001278:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000127a:	8f99                	sub	a5,a5,a4
    8000127c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000127e:	4685                	li	a3,1
    80001280:	0007861b          	sext.w	a2,a5
    80001284:	85ba                	mv	a1,a4
    80001286:	f39ff0ef          	jal	800011be <uvmunmap>
    8000128a:	b7d5                	j	8000126e <uvmdealloc+0x26>

000000008000128c <uvmalloc>:
  if(newsz < oldsz)
    8000128c:	08b66f63          	bltu	a2,a1,8000132a <uvmalloc+0x9e>
{
    80001290:	7139                	addi	sp,sp,-64
    80001292:	fc06                	sd	ra,56(sp)
    80001294:	f822                	sd	s0,48(sp)
    80001296:	ec4e                	sd	s3,24(sp)
    80001298:	e852                	sd	s4,16(sp)
    8000129a:	e456                	sd	s5,8(sp)
    8000129c:	0080                	addi	s0,sp,64
    8000129e:	8aaa                	mv	s5,a0
    800012a0:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800012a2:	6785                	lui	a5,0x1
    800012a4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012a6:	95be                	add	a1,a1,a5
    800012a8:	77fd                	lui	a5,0xfffff
    800012aa:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012ae:	08c9f063          	bgeu	s3,a2,8000132e <uvmalloc+0xa2>
    800012b2:	f426                	sd	s1,40(sp)
    800012b4:	f04a                	sd	s2,32(sp)
    800012b6:	e05a                	sd	s6,0(sp)
    800012b8:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012ba:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800012be:	841ff0ef          	jal	80000afe <kalloc>
    800012c2:	84aa                	mv	s1,a0
    if(mem == 0){
    800012c4:	c515                	beqz	a0,800012f0 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800012c6:	6605                	lui	a2,0x1
    800012c8:	4581                	li	a1,0
    800012ca:	9d9ff0ef          	jal	80000ca2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012ce:	875a                	mv	a4,s6
    800012d0:	86a6                	mv	a3,s1
    800012d2:	6605                	lui	a2,0x1
    800012d4:	85ca                	mv	a1,s2
    800012d6:	8556                	mv	a0,s5
    800012d8:	d1bff0ef          	jal	80000ff2 <mappages>
    800012dc:	e915                	bnez	a0,80001310 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012de:	6785                	lui	a5,0x1
    800012e0:	993e                	add	s2,s2,a5
    800012e2:	fd496ee3          	bltu	s2,s4,800012be <uvmalloc+0x32>
  return newsz;
    800012e6:	8552                	mv	a0,s4
    800012e8:	74a2                	ld	s1,40(sp)
    800012ea:	7902                	ld	s2,32(sp)
    800012ec:	6b02                	ld	s6,0(sp)
    800012ee:	a811                	j	80001302 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800012f0:	864e                	mv	a2,s3
    800012f2:	85ca                	mv	a1,s2
    800012f4:	8556                	mv	a0,s5
    800012f6:	f53ff0ef          	jal	80001248 <uvmdealloc>
      return 0;
    800012fa:	4501                	li	a0,0
    800012fc:	74a2                	ld	s1,40(sp)
    800012fe:	7902                	ld	s2,32(sp)
    80001300:	6b02                	ld	s6,0(sp)
}
    80001302:	70e2                	ld	ra,56(sp)
    80001304:	7442                	ld	s0,48(sp)
    80001306:	69e2                	ld	s3,24(sp)
    80001308:	6a42                	ld	s4,16(sp)
    8000130a:	6aa2                	ld	s5,8(sp)
    8000130c:	6121                	addi	sp,sp,64
    8000130e:	8082                	ret
      kfree(mem);
    80001310:	8526                	mv	a0,s1
    80001312:	f0aff0ef          	jal	80000a1c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001316:	864e                	mv	a2,s3
    80001318:	85ca                	mv	a1,s2
    8000131a:	8556                	mv	a0,s5
    8000131c:	f2dff0ef          	jal	80001248 <uvmdealloc>
      return 0;
    80001320:	4501                	li	a0,0
    80001322:	74a2                	ld	s1,40(sp)
    80001324:	7902                	ld	s2,32(sp)
    80001326:	6b02                	ld	s6,0(sp)
    80001328:	bfe9                	j	80001302 <uvmalloc+0x76>
    return oldsz;
    8000132a:	852e                	mv	a0,a1
}
    8000132c:	8082                	ret
  return newsz;
    8000132e:	8532                	mv	a0,a2
    80001330:	bfc9                	j	80001302 <uvmalloc+0x76>

0000000080001332 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001332:	7179                	addi	sp,sp,-48
    80001334:	f406                	sd	ra,40(sp)
    80001336:	f022                	sd	s0,32(sp)
    80001338:	ec26                	sd	s1,24(sp)
    8000133a:	e84a                	sd	s2,16(sp)
    8000133c:	e44e                	sd	s3,8(sp)
    8000133e:	e052                	sd	s4,0(sp)
    80001340:	1800                	addi	s0,sp,48
    80001342:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001344:	84aa                	mv	s1,a0
    80001346:	6905                	lui	s2,0x1
    80001348:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000134a:	4985                	li	s3,1
    8000134c:	a819                	j	80001362 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000134e:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001350:	00c79513          	slli	a0,a5,0xc
    80001354:	fdfff0ef          	jal	80001332 <freewalk>
      pagetable[i] = 0;
    80001358:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000135c:	04a1                	addi	s1,s1,8
    8000135e:	01248f63          	beq	s1,s2,8000137c <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001362:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001364:	00f7f713          	andi	a4,a5,15
    80001368:	ff3703e3          	beq	a4,s3,8000134e <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000136c:	8b85                	andi	a5,a5,1
    8000136e:	d7fd                	beqz	a5,8000135c <freewalk+0x2a>
      panic("freewalk: leaf");
    80001370:	00006517          	auipc	a0,0x6
    80001374:	dc850513          	addi	a0,a0,-568 # 80007138 <etext+0x138>
    80001378:	c68ff0ef          	jal	800007e0 <panic>
    }
  }
  kfree((void*)pagetable);
    8000137c:	8552                	mv	a0,s4
    8000137e:	e9eff0ef          	jal	80000a1c <kfree>
}
    80001382:	70a2                	ld	ra,40(sp)
    80001384:	7402                	ld	s0,32(sp)
    80001386:	64e2                	ld	s1,24(sp)
    80001388:	6942                	ld	s2,16(sp)
    8000138a:	69a2                	ld	s3,8(sp)
    8000138c:	6a02                	ld	s4,0(sp)
    8000138e:	6145                	addi	sp,sp,48
    80001390:	8082                	ret

0000000080001392 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001392:	1101                	addi	sp,sp,-32
    80001394:	ec06                	sd	ra,24(sp)
    80001396:	e822                	sd	s0,16(sp)
    80001398:	e426                	sd	s1,8(sp)
    8000139a:	1000                	addi	s0,sp,32
    8000139c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000139e:	e989                	bnez	a1,800013b0 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800013a0:	8526                	mv	a0,s1
    800013a2:	f91ff0ef          	jal	80001332 <freewalk>
}
    800013a6:	60e2                	ld	ra,24(sp)
    800013a8:	6442                	ld	s0,16(sp)
    800013aa:	64a2                	ld	s1,8(sp)
    800013ac:	6105                	addi	sp,sp,32
    800013ae:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800013b0:	6785                	lui	a5,0x1
    800013b2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013b4:	95be                	add	a1,a1,a5
    800013b6:	4685                	li	a3,1
    800013b8:	00c5d613          	srli	a2,a1,0xc
    800013bc:	4581                	li	a1,0
    800013be:	e01ff0ef          	jal	800011be <uvmunmap>
    800013c2:	bff9                	j	800013a0 <uvmfree+0xe>

00000000800013c4 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800013c4:	ce49                	beqz	a2,8000145e <uvmcopy+0x9a>
{
    800013c6:	715d                	addi	sp,sp,-80
    800013c8:	e486                	sd	ra,72(sp)
    800013ca:	e0a2                	sd	s0,64(sp)
    800013cc:	fc26                	sd	s1,56(sp)
    800013ce:	f84a                	sd	s2,48(sp)
    800013d0:	f44e                	sd	s3,40(sp)
    800013d2:	f052                	sd	s4,32(sp)
    800013d4:	ec56                	sd	s5,24(sp)
    800013d6:	e85a                	sd	s6,16(sp)
    800013d8:	e45e                	sd	s7,8(sp)
    800013da:	0880                	addi	s0,sp,80
    800013dc:	8aaa                	mv	s5,a0
    800013de:	8b2e                	mv	s6,a1
    800013e0:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800013e2:	4481                	li	s1,0
    800013e4:	a029                	j	800013ee <uvmcopy+0x2a>
    800013e6:	6785                	lui	a5,0x1
    800013e8:	94be                	add	s1,s1,a5
    800013ea:	0544fe63          	bgeu	s1,s4,80001446 <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    800013ee:	4601                	li	a2,0
    800013f0:	85a6                	mv	a1,s1
    800013f2:	8556                	mv	a0,s5
    800013f4:	b27ff0ef          	jal	80000f1a <walk>
    800013f8:	d57d                	beqz	a0,800013e6 <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    800013fa:	6118                	ld	a4,0(a0)
    800013fc:	00177793          	andi	a5,a4,1
    80001400:	d3fd                	beqz	a5,800013e6 <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    80001402:	00a75593          	srli	a1,a4,0xa
    80001406:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000140a:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    8000140e:	ef0ff0ef          	jal	80000afe <kalloc>
    80001412:	89aa                	mv	s3,a0
    80001414:	c105                	beqz	a0,80001434 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001416:	6605                	lui	a2,0x1
    80001418:	85de                	mv	a1,s7
    8000141a:	8e5ff0ef          	jal	80000cfe <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000141e:	874a                	mv	a4,s2
    80001420:	86ce                	mv	a3,s3
    80001422:	6605                	lui	a2,0x1
    80001424:	85a6                	mv	a1,s1
    80001426:	855a                	mv	a0,s6
    80001428:	bcbff0ef          	jal	80000ff2 <mappages>
    8000142c:	dd4d                	beqz	a0,800013e6 <uvmcopy+0x22>
      kfree(mem);
    8000142e:	854e                	mv	a0,s3
    80001430:	decff0ef          	jal	80000a1c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001434:	4685                	li	a3,1
    80001436:	00c4d613          	srli	a2,s1,0xc
    8000143a:	4581                	li	a1,0
    8000143c:	855a                	mv	a0,s6
    8000143e:	d81ff0ef          	jal	800011be <uvmunmap>
  return -1;
    80001442:	557d                	li	a0,-1
    80001444:	a011                	j	80001448 <uvmcopy+0x84>
  return 0;
    80001446:	4501                	li	a0,0
}
    80001448:	60a6                	ld	ra,72(sp)
    8000144a:	6406                	ld	s0,64(sp)
    8000144c:	74e2                	ld	s1,56(sp)
    8000144e:	7942                	ld	s2,48(sp)
    80001450:	79a2                	ld	s3,40(sp)
    80001452:	7a02                	ld	s4,32(sp)
    80001454:	6ae2                	ld	s5,24(sp)
    80001456:	6b42                	ld	s6,16(sp)
    80001458:	6ba2                	ld	s7,8(sp)
    8000145a:	6161                	addi	sp,sp,80
    8000145c:	8082                	ret
  return 0;
    8000145e:	4501                	li	a0,0
}
    80001460:	8082                	ret

0000000080001462 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001462:	1141                	addi	sp,sp,-16
    80001464:	e406                	sd	ra,8(sp)
    80001466:	e022                	sd	s0,0(sp)
    80001468:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000146a:	4601                	li	a2,0
    8000146c:	aafff0ef          	jal	80000f1a <walk>
  if(pte == 0)
    80001470:	c901                	beqz	a0,80001480 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001472:	611c                	ld	a5,0(a0)
    80001474:	9bbd                	andi	a5,a5,-17
    80001476:	e11c                	sd	a5,0(a0)
}
    80001478:	60a2                	ld	ra,8(sp)
    8000147a:	6402                	ld	s0,0(sp)
    8000147c:	0141                	addi	sp,sp,16
    8000147e:	8082                	ret
    panic("uvmclear");
    80001480:	00006517          	auipc	a0,0x6
    80001484:	cc850513          	addi	a0,a0,-824 # 80007148 <etext+0x148>
    80001488:	b58ff0ef          	jal	800007e0 <panic>

000000008000148c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000148c:	c6dd                	beqz	a3,8000153a <copyinstr+0xae>
{
    8000148e:	715d                	addi	sp,sp,-80
    80001490:	e486                	sd	ra,72(sp)
    80001492:	e0a2                	sd	s0,64(sp)
    80001494:	fc26                	sd	s1,56(sp)
    80001496:	f84a                	sd	s2,48(sp)
    80001498:	f44e                	sd	s3,40(sp)
    8000149a:	f052                	sd	s4,32(sp)
    8000149c:	ec56                	sd	s5,24(sp)
    8000149e:	e85a                	sd	s6,16(sp)
    800014a0:	e45e                	sd	s7,8(sp)
    800014a2:	0880                	addi	s0,sp,80
    800014a4:	8a2a                	mv	s4,a0
    800014a6:	8b2e                	mv	s6,a1
    800014a8:	8bb2                	mv	s7,a2
    800014aa:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800014ac:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014ae:	6985                	lui	s3,0x1
    800014b0:	a825                	j	800014e8 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800014b2:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800014b6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800014b8:	37fd                	addiw	a5,a5,-1
    800014ba:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800014be:	60a6                	ld	ra,72(sp)
    800014c0:	6406                	ld	s0,64(sp)
    800014c2:	74e2                	ld	s1,56(sp)
    800014c4:	7942                	ld	s2,48(sp)
    800014c6:	79a2                	ld	s3,40(sp)
    800014c8:	7a02                	ld	s4,32(sp)
    800014ca:	6ae2                	ld	s5,24(sp)
    800014cc:	6b42                	ld	s6,16(sp)
    800014ce:	6ba2                	ld	s7,8(sp)
    800014d0:	6161                	addi	sp,sp,80
    800014d2:	8082                	ret
    800014d4:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800014d8:	9742                	add	a4,a4,a6
      --max;
    800014da:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    800014de:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    800014e2:	04e58463          	beq	a1,a4,8000152a <copyinstr+0x9e>
{
    800014e6:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    800014e8:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800014ec:	85a6                	mv	a1,s1
    800014ee:	8552                	mv	a0,s4
    800014f0:	ac5ff0ef          	jal	80000fb4 <walkaddr>
    if(pa0 == 0)
    800014f4:	cd0d                	beqz	a0,8000152e <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800014f6:	417486b3          	sub	a3,s1,s7
    800014fa:	96ce                	add	a3,a3,s3
    if(n > max)
    800014fc:	00d97363          	bgeu	s2,a3,80001502 <copyinstr+0x76>
    80001500:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001502:	955e                	add	a0,a0,s7
    80001504:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001506:	c695                	beqz	a3,80001532 <copyinstr+0xa6>
    80001508:	87da                	mv	a5,s6
    8000150a:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000150c:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001510:	96da                	add	a3,a3,s6
    80001512:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001514:	00f60733          	add	a4,a2,a5
    80001518:	00074703          	lbu	a4,0(a4)
    8000151c:	db59                	beqz	a4,800014b2 <copyinstr+0x26>
        *dst = *p;
    8000151e:	00e78023          	sb	a4,0(a5)
      dst++;
    80001522:	0785                	addi	a5,a5,1
    while(n > 0){
    80001524:	fed797e3          	bne	a5,a3,80001512 <copyinstr+0x86>
    80001528:	b775                	j	800014d4 <copyinstr+0x48>
    8000152a:	4781                	li	a5,0
    8000152c:	b771                	j	800014b8 <copyinstr+0x2c>
      return -1;
    8000152e:	557d                	li	a0,-1
    80001530:	b779                	j	800014be <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001532:	6b85                	lui	s7,0x1
    80001534:	9ba6                	add	s7,s7,s1
    80001536:	87da                	mv	a5,s6
    80001538:	b77d                	j	800014e6 <copyinstr+0x5a>
  int got_null = 0;
    8000153a:	4781                	li	a5,0
  if(got_null){
    8000153c:	37fd                	addiw	a5,a5,-1
    8000153e:	0007851b          	sext.w	a0,a5
}
    80001542:	8082                	ret

0000000080001544 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    80001544:	1141                	addi	sp,sp,-16
    80001546:	e406                	sd	ra,8(sp)
    80001548:	e022                	sd	s0,0(sp)
    8000154a:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    8000154c:	4601                	li	a2,0
    8000154e:	9cdff0ef          	jal	80000f1a <walk>
  if (pte == 0) {
    80001552:	c519                	beqz	a0,80001560 <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    80001554:	6108                	ld	a0,0(a0)
    80001556:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001558:	60a2                	ld	ra,8(sp)
    8000155a:	6402                	ld	s0,0(sp)
    8000155c:	0141                	addi	sp,sp,16
    8000155e:	8082                	ret
    return 0;
    80001560:	4501                	li	a0,0
    80001562:	bfdd                	j	80001558 <ismapped+0x14>

0000000080001564 <vmfault>:
{
    80001564:	7179                	addi	sp,sp,-48
    80001566:	f406                	sd	ra,40(sp)
    80001568:	f022                	sd	s0,32(sp)
    8000156a:	ec26                	sd	s1,24(sp)
    8000156c:	e44e                	sd	s3,8(sp)
    8000156e:	1800                	addi	s0,sp,48
    80001570:	89aa                	mv	s3,a0
    80001572:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80001574:	35e000ef          	jal	800018d2 <myproc>
  if (va >= p->sz)
    80001578:	693c                	ld	a5,80(a0)
    8000157a:	00f4ea63          	bltu	s1,a5,8000158e <vmfault+0x2a>
    return 0;
    8000157e:	4981                	li	s3,0
}
    80001580:	854e                	mv	a0,s3
    80001582:	70a2                	ld	ra,40(sp)
    80001584:	7402                	ld	s0,32(sp)
    80001586:	64e2                	ld	s1,24(sp)
    80001588:	69a2                	ld	s3,8(sp)
    8000158a:	6145                	addi	sp,sp,48
    8000158c:	8082                	ret
    8000158e:	e84a                	sd	s2,16(sp)
    80001590:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80001592:	77fd                	lui	a5,0xfffff
    80001594:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80001596:	85a6                	mv	a1,s1
    80001598:	854e                	mv	a0,s3
    8000159a:	fabff0ef          	jal	80001544 <ismapped>
    return 0;
    8000159e:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    800015a0:	c119                	beqz	a0,800015a6 <vmfault+0x42>
    800015a2:	6942                	ld	s2,16(sp)
    800015a4:	bff1                	j	80001580 <vmfault+0x1c>
    800015a6:	e052                	sd	s4,0(sp)
  mem = (uint64) kalloc();
    800015a8:	d56ff0ef          	jal	80000afe <kalloc>
    800015ac:	8a2a                	mv	s4,a0
  if(mem == 0)
    800015ae:	c90d                	beqz	a0,800015e0 <vmfault+0x7c>
  mem = (uint64) kalloc();
    800015b0:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    800015b2:	6605                	lui	a2,0x1
    800015b4:	4581                	li	a1,0
    800015b6:	eecff0ef          	jal	80000ca2 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    800015ba:	4759                	li	a4,22
    800015bc:	86d2                	mv	a3,s4
    800015be:	6605                	lui	a2,0x1
    800015c0:	85a6                	mv	a1,s1
    800015c2:	05893503          	ld	a0,88(s2)
    800015c6:	a2dff0ef          	jal	80000ff2 <mappages>
    800015ca:	e501                	bnez	a0,800015d2 <vmfault+0x6e>
    800015cc:	6942                	ld	s2,16(sp)
    800015ce:	6a02                	ld	s4,0(sp)
    800015d0:	bf45                	j	80001580 <vmfault+0x1c>
    kfree((void *)mem);
    800015d2:	8552                	mv	a0,s4
    800015d4:	c48ff0ef          	jal	80000a1c <kfree>
    return 0;
    800015d8:	4981                	li	s3,0
    800015da:	6942                	ld	s2,16(sp)
    800015dc:	6a02                	ld	s4,0(sp)
    800015de:	b74d                	j	80001580 <vmfault+0x1c>
    800015e0:	6942                	ld	s2,16(sp)
    800015e2:	6a02                	ld	s4,0(sp)
    800015e4:	bf71                	j	80001580 <vmfault+0x1c>

00000000800015e6 <copyout>:
  while(len > 0){
    800015e6:	c2cd                	beqz	a3,80001688 <copyout+0xa2>
{
    800015e8:	711d                	addi	sp,sp,-96
    800015ea:	ec86                	sd	ra,88(sp)
    800015ec:	e8a2                	sd	s0,80(sp)
    800015ee:	e4a6                	sd	s1,72(sp)
    800015f0:	f852                	sd	s4,48(sp)
    800015f2:	f05a                	sd	s6,32(sp)
    800015f4:	ec5e                	sd	s7,24(sp)
    800015f6:	e862                	sd	s8,16(sp)
    800015f8:	1080                	addi	s0,sp,96
    800015fa:	8c2a                	mv	s8,a0
    800015fc:	8b2e                	mv	s6,a1
    800015fe:	8bb2                	mv	s7,a2
    80001600:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    80001602:	74fd                	lui	s1,0xfffff
    80001604:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001606:	57fd                	li	a5,-1
    80001608:	83e9                	srli	a5,a5,0x1a
    8000160a:	0897e163          	bltu	a5,s1,8000168c <copyout+0xa6>
    8000160e:	e0ca                	sd	s2,64(sp)
    80001610:	fc4e                	sd	s3,56(sp)
    80001612:	f456                	sd	s5,40(sp)
    80001614:	e466                	sd	s9,8(sp)
    80001616:	e06a                	sd	s10,0(sp)
    80001618:	6d05                	lui	s10,0x1
    8000161a:	8cbe                	mv	s9,a5
    8000161c:	a015                	j	80001640 <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000161e:	409b0533          	sub	a0,s6,s1
    80001622:	0009861b          	sext.w	a2,s3
    80001626:	85de                	mv	a1,s7
    80001628:	954a                	add	a0,a0,s2
    8000162a:	ed4ff0ef          	jal	80000cfe <memmove>
    len -= n;
    8000162e:	413a0a33          	sub	s4,s4,s3
    src += n;
    80001632:	9bce                	add	s7,s7,s3
  while(len > 0){
    80001634:	040a0363          	beqz	s4,8000167a <copyout+0x94>
    if(va0 >= MAXVA)
    80001638:	055cec63          	bltu	s9,s5,80001690 <copyout+0xaa>
    8000163c:	84d6                	mv	s1,s5
    8000163e:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    80001640:	85a6                	mv	a1,s1
    80001642:	8562                	mv	a0,s8
    80001644:	971ff0ef          	jal	80000fb4 <walkaddr>
    80001648:	892a                	mv	s2,a0
    if(pa0 == 0) {
    8000164a:	e901                	bnez	a0,8000165a <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    8000164c:	4601                	li	a2,0
    8000164e:	85a6                	mv	a1,s1
    80001650:	8562                	mv	a0,s8
    80001652:	f13ff0ef          	jal	80001564 <vmfault>
    80001656:	892a                	mv	s2,a0
    80001658:	c139                	beqz	a0,8000169e <copyout+0xb8>
    pte = walk(pagetable, va0, 0);
    8000165a:	4601                	li	a2,0
    8000165c:	85a6                	mv	a1,s1
    8000165e:	8562                	mv	a0,s8
    80001660:	8bbff0ef          	jal	80000f1a <walk>
    if((*pte & PTE_W) == 0)
    80001664:	611c                	ld	a5,0(a0)
    80001666:	8b91                	andi	a5,a5,4
    80001668:	c3b1                	beqz	a5,800016ac <copyout+0xc6>
    n = PGSIZE - (dstva - va0);
    8000166a:	01a48ab3          	add	s5,s1,s10
    8000166e:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    80001672:	fb3a76e3          	bgeu	s4,s3,8000161e <copyout+0x38>
    80001676:	89d2                	mv	s3,s4
    80001678:	b75d                	j	8000161e <copyout+0x38>
  return 0;
    8000167a:	4501                	li	a0,0
    8000167c:	6906                	ld	s2,64(sp)
    8000167e:	79e2                	ld	s3,56(sp)
    80001680:	7aa2                	ld	s5,40(sp)
    80001682:	6ca2                	ld	s9,8(sp)
    80001684:	6d02                	ld	s10,0(sp)
    80001686:	a80d                	j	800016b8 <copyout+0xd2>
    80001688:	4501                	li	a0,0
}
    8000168a:	8082                	ret
      return -1;
    8000168c:	557d                	li	a0,-1
    8000168e:	a02d                	j	800016b8 <copyout+0xd2>
    80001690:	557d                	li	a0,-1
    80001692:	6906                	ld	s2,64(sp)
    80001694:	79e2                	ld	s3,56(sp)
    80001696:	7aa2                	ld	s5,40(sp)
    80001698:	6ca2                	ld	s9,8(sp)
    8000169a:	6d02                	ld	s10,0(sp)
    8000169c:	a831                	j	800016b8 <copyout+0xd2>
        return -1;
    8000169e:	557d                	li	a0,-1
    800016a0:	6906                	ld	s2,64(sp)
    800016a2:	79e2                	ld	s3,56(sp)
    800016a4:	7aa2                	ld	s5,40(sp)
    800016a6:	6ca2                	ld	s9,8(sp)
    800016a8:	6d02                	ld	s10,0(sp)
    800016aa:	a039                	j	800016b8 <copyout+0xd2>
      return -1;
    800016ac:	557d                	li	a0,-1
    800016ae:	6906                	ld	s2,64(sp)
    800016b0:	79e2                	ld	s3,56(sp)
    800016b2:	7aa2                	ld	s5,40(sp)
    800016b4:	6ca2                	ld	s9,8(sp)
    800016b6:	6d02                	ld	s10,0(sp)
}
    800016b8:	60e6                	ld	ra,88(sp)
    800016ba:	6446                	ld	s0,80(sp)
    800016bc:	64a6                	ld	s1,72(sp)
    800016be:	7a42                	ld	s4,48(sp)
    800016c0:	7b02                	ld	s6,32(sp)
    800016c2:	6be2                	ld	s7,24(sp)
    800016c4:	6c42                	ld	s8,16(sp)
    800016c6:	6125                	addi	sp,sp,96
    800016c8:	8082                	ret

00000000800016ca <copyin>:
  while(len > 0){
    800016ca:	c6c9                	beqz	a3,80001754 <copyin+0x8a>
{
    800016cc:	715d                	addi	sp,sp,-80
    800016ce:	e486                	sd	ra,72(sp)
    800016d0:	e0a2                	sd	s0,64(sp)
    800016d2:	fc26                	sd	s1,56(sp)
    800016d4:	f84a                	sd	s2,48(sp)
    800016d6:	f44e                	sd	s3,40(sp)
    800016d8:	f052                	sd	s4,32(sp)
    800016da:	ec56                	sd	s5,24(sp)
    800016dc:	e85a                	sd	s6,16(sp)
    800016de:	e45e                	sd	s7,8(sp)
    800016e0:	e062                	sd	s8,0(sp)
    800016e2:	0880                	addi	s0,sp,80
    800016e4:	8baa                	mv	s7,a0
    800016e6:	8aae                	mv	s5,a1
    800016e8:	8932                	mv	s2,a2
    800016ea:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800016ec:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800016ee:	6b05                	lui	s6,0x1
    800016f0:	a035                	j	8000171c <copyin+0x52>
    800016f2:	412984b3          	sub	s1,s3,s2
    800016f6:	94da                	add	s1,s1,s6
    if(n > len)
    800016f8:	009a7363          	bgeu	s4,s1,800016fe <copyin+0x34>
    800016fc:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016fe:	413905b3          	sub	a1,s2,s3
    80001702:	0004861b          	sext.w	a2,s1
    80001706:	95aa                	add	a1,a1,a0
    80001708:	8556                	mv	a0,s5
    8000170a:	df4ff0ef          	jal	80000cfe <memmove>
    len -= n;
    8000170e:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001712:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001714:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001718:	020a0163          	beqz	s4,8000173a <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    8000171c:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001720:	85ce                	mv	a1,s3
    80001722:	855e                	mv	a0,s7
    80001724:	891ff0ef          	jal	80000fb4 <walkaddr>
    if(pa0 == 0) {
    80001728:	f569                	bnez	a0,800016f2 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    8000172a:	4601                	li	a2,0
    8000172c:	85ce                	mv	a1,s3
    8000172e:	855e                	mv	a0,s7
    80001730:	e35ff0ef          	jal	80001564 <vmfault>
    80001734:	fd5d                	bnez	a0,800016f2 <copyin+0x28>
        return -1;
    80001736:	557d                	li	a0,-1
    80001738:	a011                	j	8000173c <copyin+0x72>
  return 0;
    8000173a:	4501                	li	a0,0
}
    8000173c:	60a6                	ld	ra,72(sp)
    8000173e:	6406                	ld	s0,64(sp)
    80001740:	74e2                	ld	s1,56(sp)
    80001742:	7942                	ld	s2,48(sp)
    80001744:	79a2                	ld	s3,40(sp)
    80001746:	7a02                	ld	s4,32(sp)
    80001748:	6ae2                	ld	s5,24(sp)
    8000174a:	6b42                	ld	s6,16(sp)
    8000174c:	6ba2                	ld	s7,8(sp)
    8000174e:	6c02                	ld	s8,0(sp)
    80001750:	6161                	addi	sp,sp,80
    80001752:	8082                	ret
  return 0;
    80001754:	4501                	li	a0,0
}
    80001756:	8082                	ret

0000000080001758 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001758:	7139                	addi	sp,sp,-64
    8000175a:	fc06                	sd	ra,56(sp)
    8000175c:	f822                	sd	s0,48(sp)
    8000175e:	f426                	sd	s1,40(sp)
    80001760:	f04a                	sd	s2,32(sp)
    80001762:	ec4e                	sd	s3,24(sp)
    80001764:	e852                	sd	s4,16(sp)
    80001766:	e456                	sd	s5,8(sp)
    80001768:	e05a                	sd	s6,0(sp)
    8000176a:	0080                	addi	s0,sp,64
    8000176c:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000176e:	00011497          	auipc	s1,0x11
    80001772:	25a48493          	addi	s1,s1,602 # 800129c8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001776:	8b26                	mv	s6,s1
    80001778:	00a36937          	lui	s2,0xa36
    8000177c:	77d90913          	addi	s2,s2,1917 # a3677d <_entry-0x7f5c9883>
    80001780:	0932                	slli	s2,s2,0xc
    80001782:	46d90913          	addi	s2,s2,1133
    80001786:	0936                	slli	s2,s2,0xd
    80001788:	df590913          	addi	s2,s2,-523
    8000178c:	093a                	slli	s2,s2,0xe
    8000178e:	6cf90913          	addi	s2,s2,1743
    80001792:	040009b7          	lui	s3,0x4000
    80001796:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001798:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000179a:	00017a97          	auipc	s5,0x17
    8000179e:	02ea8a93          	addi	s5,s5,46 # 800187c8 <tickslock>
    char *pa = kalloc();
    800017a2:	b5cff0ef          	jal	80000afe <kalloc>
    800017a6:	862a                	mv	a2,a0
    if(pa == 0)
    800017a8:	cd15                	beqz	a0,800017e4 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017aa:	416485b3          	sub	a1,s1,s6
    800017ae:	858d                	srai	a1,a1,0x3
    800017b0:	032585b3          	mul	a1,a1,s2
    800017b4:	2585                	addiw	a1,a1,1
    800017b6:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017ba:	4719                	li	a4,6
    800017bc:	6685                	lui	a3,0x1
    800017be:	40b985b3          	sub	a1,s3,a1
    800017c2:	8552                	mv	a0,s4
    800017c4:	8dfff0ef          	jal	800010a2 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017c8:	17848493          	addi	s1,s1,376
    800017cc:	fd549be3          	bne	s1,s5,800017a2 <proc_mapstacks+0x4a>
  }
}
    800017d0:	70e2                	ld	ra,56(sp)
    800017d2:	7442                	ld	s0,48(sp)
    800017d4:	74a2                	ld	s1,40(sp)
    800017d6:	7902                	ld	s2,32(sp)
    800017d8:	69e2                	ld	s3,24(sp)
    800017da:	6a42                	ld	s4,16(sp)
    800017dc:	6aa2                	ld	s5,8(sp)
    800017de:	6b02                	ld	s6,0(sp)
    800017e0:	6121                	addi	sp,sp,64
    800017e2:	8082                	ret
      panic("kalloc");
    800017e4:	00006517          	auipc	a0,0x6
    800017e8:	97450513          	addi	a0,a0,-1676 # 80007158 <etext+0x158>
    800017ec:	ff5fe0ef          	jal	800007e0 <panic>

00000000800017f0 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017f0:	7139                	addi	sp,sp,-64
    800017f2:	fc06                	sd	ra,56(sp)
    800017f4:	f822                	sd	s0,48(sp)
    800017f6:	f426                	sd	s1,40(sp)
    800017f8:	f04a                	sd	s2,32(sp)
    800017fa:	ec4e                	sd	s3,24(sp)
    800017fc:	e852                	sd	s4,16(sp)
    800017fe:	e456                	sd	s5,8(sp)
    80001800:	e05a                	sd	s6,0(sp)
    80001802:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001804:	00006597          	auipc	a1,0x6
    80001808:	95c58593          	addi	a1,a1,-1700 # 80007160 <etext+0x160>
    8000180c:	00011517          	auipc	a0,0x11
    80001810:	d8c50513          	addi	a0,a0,-628 # 80012598 <pid_lock>
    80001814:	b3aff0ef          	jal	80000b4e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001818:	00006597          	auipc	a1,0x6
    8000181c:	95058593          	addi	a1,a1,-1712 # 80007168 <etext+0x168>
    80001820:	00011517          	auipc	a0,0x11
    80001824:	d9050513          	addi	a0,a0,-624 # 800125b0 <wait_lock>
    80001828:	b26ff0ef          	jal	80000b4e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000182c:	00011497          	auipc	s1,0x11
    80001830:	19c48493          	addi	s1,s1,412 # 800129c8 <proc>
      initlock(&p->lock, "proc");
    80001834:	00006b17          	auipc	s6,0x6
    80001838:	944b0b13          	addi	s6,s6,-1724 # 80007178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000183c:	8aa6                	mv	s5,s1
    8000183e:	00a36937          	lui	s2,0xa36
    80001842:	77d90913          	addi	s2,s2,1917 # a3677d <_entry-0x7f5c9883>
    80001846:	0932                	slli	s2,s2,0xc
    80001848:	46d90913          	addi	s2,s2,1133
    8000184c:	0936                	slli	s2,s2,0xd
    8000184e:	df590913          	addi	s2,s2,-523
    80001852:	093a                	slli	s2,s2,0xe
    80001854:	6cf90913          	addi	s2,s2,1743
    80001858:	040009b7          	lui	s3,0x4000
    8000185c:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000185e:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001860:	00017a17          	auipc	s4,0x17
    80001864:	f68a0a13          	addi	s4,s4,-152 # 800187c8 <tickslock>
      initlock(&p->lock, "proc");
    80001868:	85da                	mv	a1,s6
    8000186a:	8526                	mv	a0,s1
    8000186c:	ae2ff0ef          	jal	80000b4e <initlock>
      p->state = UNUSED;
    80001870:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001874:	415487b3          	sub	a5,s1,s5
    80001878:	878d                	srai	a5,a5,0x3
    8000187a:	032787b3          	mul	a5,a5,s2
    8000187e:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffda841>
    80001880:	00d7979b          	slliw	a5,a5,0xd
    80001884:	40f987b3          	sub	a5,s3,a5
    80001888:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000188a:	17848493          	addi	s1,s1,376
    8000188e:	fd449de3          	bne	s1,s4,80001868 <procinit+0x78>
  }
}
    80001892:	70e2                	ld	ra,56(sp)
    80001894:	7442                	ld	s0,48(sp)
    80001896:	74a2                	ld	s1,40(sp)
    80001898:	7902                	ld	s2,32(sp)
    8000189a:	69e2                	ld	s3,24(sp)
    8000189c:	6a42                	ld	s4,16(sp)
    8000189e:	6aa2                	ld	s5,8(sp)
    800018a0:	6b02                	ld	s6,0(sp)
    800018a2:	6121                	addi	sp,sp,64
    800018a4:	8082                	ret

00000000800018a6 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018a6:	1141                	addi	sp,sp,-16
    800018a8:	e422                	sd	s0,8(sp)
    800018aa:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018ac:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018ae:	2501                	sext.w	a0,a0
    800018b0:	6422                	ld	s0,8(sp)
    800018b2:	0141                	addi	sp,sp,16
    800018b4:	8082                	ret

00000000800018b6 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018b6:	1141                	addi	sp,sp,-16
    800018b8:	e422                	sd	s0,8(sp)
    800018ba:	0800                	addi	s0,sp,16
    800018bc:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018be:	2781                	sext.w	a5,a5
    800018c0:	079e                	slli	a5,a5,0x7
  return c;
}
    800018c2:	00011517          	auipc	a0,0x11
    800018c6:	d0650513          	addi	a0,a0,-762 # 800125c8 <cpus>
    800018ca:	953e                	add	a0,a0,a5
    800018cc:	6422                	ld	s0,8(sp)
    800018ce:	0141                	addi	sp,sp,16
    800018d0:	8082                	ret

00000000800018d2 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018d2:	1101                	addi	sp,sp,-32
    800018d4:	ec06                	sd	ra,24(sp)
    800018d6:	e822                	sd	s0,16(sp)
    800018d8:	e426                	sd	s1,8(sp)
    800018da:	1000                	addi	s0,sp,32
  push_off();
    800018dc:	ab2ff0ef          	jal	80000b8e <push_off>
    800018e0:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018e2:	2781                	sext.w	a5,a5
    800018e4:	079e                	slli	a5,a5,0x7
    800018e6:	00011717          	auipc	a4,0x11
    800018ea:	cb270713          	addi	a4,a4,-846 # 80012598 <pid_lock>
    800018ee:	97ba                	add	a5,a5,a4
    800018f0:	7b84                	ld	s1,48(a5)
  pop_off();
    800018f2:	b20ff0ef          	jal	80000c12 <pop_off>
  return p;
}
    800018f6:	8526                	mv	a0,s1
    800018f8:	60e2                	ld	ra,24(sp)
    800018fa:	6442                	ld	s0,16(sp)
    800018fc:	64a2                	ld	s1,8(sp)
    800018fe:	6105                	addi	sp,sp,32
    80001900:	8082                	ret

0000000080001902 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001902:	7179                	addi	sp,sp,-48
    80001904:	f406                	sd	ra,40(sp)
    80001906:	f022                	sd	s0,32(sp)
    80001908:	ec26                	sd	s1,24(sp)
    8000190a:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    8000190c:	fc7ff0ef          	jal	800018d2 <myproc>
    80001910:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001912:	b54ff0ef          	jal	80000c66 <release>

  if (first) {
    80001916:	00009797          	auipc	a5,0x9
    8000191a:	b2a7a783          	lw	a5,-1238(a5) # 8000a440 <first.1>
    8000191e:	cf8d                	beqz	a5,80001958 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001920:	4505                	li	a0,1
    80001922:	1cc020ef          	jal	80003aee <fsinit>

    first = 0;
    80001926:	00009797          	auipc	a5,0x9
    8000192a:	b007ad23          	sw	zero,-1254(a5) # 8000a440 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    8000192e:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001932:	00006517          	auipc	a0,0x6
    80001936:	84e50513          	addi	a0,a0,-1970 # 80007180 <etext+0x180>
    8000193a:	fca43823          	sd	a0,-48(s0)
    8000193e:	fc043c23          	sd	zero,-40(s0)
    80001942:	fd040593          	addi	a1,s0,-48
    80001946:	2b2030ef          	jal	80004bf8 <kexec>
    8000194a:	70bc                	ld	a5,96(s1)
    8000194c:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    8000194e:	70bc                	ld	a5,96(s1)
    80001950:	7bb8                	ld	a4,112(a5)
    80001952:	57fd                	li	a5,-1
    80001954:	02f70d63          	beq	a4,a5,8000198e <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001958:	2ef000ef          	jal	80002446 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000195c:	6ca8                	ld	a0,88(s1)
    8000195e:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001960:	04000737          	lui	a4,0x4000
    80001964:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001966:	0732                	slli	a4,a4,0xc
    80001968:	00004797          	auipc	a5,0x4
    8000196c:	73478793          	addi	a5,a5,1844 # 8000609c <userret>
    80001970:	00004697          	auipc	a3,0x4
    80001974:	69068693          	addi	a3,a3,1680 # 80006000 <_trampoline>
    80001978:	8f95                	sub	a5,a5,a3
    8000197a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000197c:	577d                	li	a4,-1
    8000197e:	177e                	slli	a4,a4,0x3f
    80001980:	8d59                	or	a0,a0,a4
    80001982:	9782                	jalr	a5
}
    80001984:	70a2                	ld	ra,40(sp)
    80001986:	7402                	ld	s0,32(sp)
    80001988:	64e2                	ld	s1,24(sp)
    8000198a:	6145                	addi	sp,sp,48
    8000198c:	8082                	ret
      panic("exec");
    8000198e:	00005517          	auipc	a0,0x5
    80001992:	7fa50513          	addi	a0,a0,2042 # 80007188 <etext+0x188>
    80001996:	e4bfe0ef          	jal	800007e0 <panic>

000000008000199a <allocpid>:
{
    8000199a:	1101                	addi	sp,sp,-32
    8000199c:	ec06                	sd	ra,24(sp)
    8000199e:	e822                	sd	s0,16(sp)
    800019a0:	e426                	sd	s1,8(sp)
    800019a2:	e04a                	sd	s2,0(sp)
    800019a4:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019a6:	00011917          	auipc	s2,0x11
    800019aa:	bf290913          	addi	s2,s2,-1038 # 80012598 <pid_lock>
    800019ae:	854a                	mv	a0,s2
    800019b0:	a1eff0ef          	jal	80000bce <acquire>
  pid = nextpid;
    800019b4:	00009797          	auipc	a5,0x9
    800019b8:	a9078793          	addi	a5,a5,-1392 # 8000a444 <nextpid>
    800019bc:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019be:	0014871b          	addiw	a4,s1,1
    800019c2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019c4:	854a                	mv	a0,s2
    800019c6:	aa0ff0ef          	jal	80000c66 <release>
}
    800019ca:	8526                	mv	a0,s1
    800019cc:	60e2                	ld	ra,24(sp)
    800019ce:	6442                	ld	s0,16(sp)
    800019d0:	64a2                	ld	s1,8(sp)
    800019d2:	6902                	ld	s2,0(sp)
    800019d4:	6105                	addi	sp,sp,32
    800019d6:	8082                	ret

00000000800019d8 <proc_pagetable>:
{
    800019d8:	1101                	addi	sp,sp,-32
    800019da:	ec06                	sd	ra,24(sp)
    800019dc:	e822                	sd	s0,16(sp)
    800019de:	e426                	sd	s1,8(sp)
    800019e0:	e04a                	sd	s2,0(sp)
    800019e2:	1000                	addi	s0,sp,32
    800019e4:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019e6:	fb2ff0ef          	jal	80001198 <uvmcreate>
    800019ea:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800019ec:	cd05                	beqz	a0,80001a24 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800019ee:	4729                	li	a4,10
    800019f0:	00004697          	auipc	a3,0x4
    800019f4:	61068693          	addi	a3,a3,1552 # 80006000 <_trampoline>
    800019f8:	6605                	lui	a2,0x1
    800019fa:	040005b7          	lui	a1,0x4000
    800019fe:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a00:	05b2                	slli	a1,a1,0xc
    80001a02:	df0ff0ef          	jal	80000ff2 <mappages>
    80001a06:	02054663          	bltz	a0,80001a32 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a0a:	4719                	li	a4,6
    80001a0c:	06093683          	ld	a3,96(s2)
    80001a10:	6605                	lui	a2,0x1
    80001a12:	020005b7          	lui	a1,0x2000
    80001a16:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a18:	05b6                	slli	a1,a1,0xd
    80001a1a:	8526                	mv	a0,s1
    80001a1c:	dd6ff0ef          	jal	80000ff2 <mappages>
    80001a20:	00054f63          	bltz	a0,80001a3e <proc_pagetable+0x66>
}
    80001a24:	8526                	mv	a0,s1
    80001a26:	60e2                	ld	ra,24(sp)
    80001a28:	6442                	ld	s0,16(sp)
    80001a2a:	64a2                	ld	s1,8(sp)
    80001a2c:	6902                	ld	s2,0(sp)
    80001a2e:	6105                	addi	sp,sp,32
    80001a30:	8082                	ret
    uvmfree(pagetable, 0);
    80001a32:	4581                	li	a1,0
    80001a34:	8526                	mv	a0,s1
    80001a36:	95dff0ef          	jal	80001392 <uvmfree>
    return 0;
    80001a3a:	4481                	li	s1,0
    80001a3c:	b7e5                	j	80001a24 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a3e:	4681                	li	a3,0
    80001a40:	4605                	li	a2,1
    80001a42:	040005b7          	lui	a1,0x4000
    80001a46:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a48:	05b2                	slli	a1,a1,0xc
    80001a4a:	8526                	mv	a0,s1
    80001a4c:	f72ff0ef          	jal	800011be <uvmunmap>
    uvmfree(pagetable, 0);
    80001a50:	4581                	li	a1,0
    80001a52:	8526                	mv	a0,s1
    80001a54:	93fff0ef          	jal	80001392 <uvmfree>
    return 0;
    80001a58:	4481                	li	s1,0
    80001a5a:	b7e9                	j	80001a24 <proc_pagetable+0x4c>

0000000080001a5c <proc_freepagetable>:
{
    80001a5c:	1101                	addi	sp,sp,-32
    80001a5e:	ec06                	sd	ra,24(sp)
    80001a60:	e822                	sd	s0,16(sp)
    80001a62:	e426                	sd	s1,8(sp)
    80001a64:	e04a                	sd	s2,0(sp)
    80001a66:	1000                	addi	s0,sp,32
    80001a68:	84aa                	mv	s1,a0
    80001a6a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a6c:	4681                	li	a3,0
    80001a6e:	4605                	li	a2,1
    80001a70:	040005b7          	lui	a1,0x4000
    80001a74:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a76:	05b2                	slli	a1,a1,0xc
    80001a78:	f46ff0ef          	jal	800011be <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a7c:	4681                	li	a3,0
    80001a7e:	4605                	li	a2,1
    80001a80:	020005b7          	lui	a1,0x2000
    80001a84:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a86:	05b6                	slli	a1,a1,0xd
    80001a88:	8526                	mv	a0,s1
    80001a8a:	f34ff0ef          	jal	800011be <uvmunmap>
  uvmfree(pagetable, sz);
    80001a8e:	85ca                	mv	a1,s2
    80001a90:	8526                	mv	a0,s1
    80001a92:	901ff0ef          	jal	80001392 <uvmfree>
}
    80001a96:	60e2                	ld	ra,24(sp)
    80001a98:	6442                	ld	s0,16(sp)
    80001a9a:	64a2                	ld	s1,8(sp)
    80001a9c:	6902                	ld	s2,0(sp)
    80001a9e:	6105                	addi	sp,sp,32
    80001aa0:	8082                	ret

0000000080001aa2 <freeproc>:
{
    80001aa2:	1101                	addi	sp,sp,-32
    80001aa4:	ec06                	sd	ra,24(sp)
    80001aa6:	e822                	sd	s0,16(sp)
    80001aa8:	e426                	sd	s1,8(sp)
    80001aaa:	1000                	addi	s0,sp,32
    80001aac:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001aae:	7128                	ld	a0,96(a0)
    80001ab0:	c119                	beqz	a0,80001ab6 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001ab2:	f6bfe0ef          	jal	80000a1c <kfree>
  p->trapframe = 0;
    80001ab6:	0604b023          	sd	zero,96(s1)
  if(p->pagetable) {
    80001aba:	6ca8                	ld	a0,88(s1)
    80001abc:	c901                	beqz	a0,80001acc <freeproc+0x2a>
    shm_release(p->pagetable, p->sz);
    80001abe:	68ac                	ld	a1,80(s1)
    80001ac0:	51a010ef          	jal	80002fda <shm_release>
    proc_freepagetable(p->pagetable, p->sz);
    80001ac4:	68ac                	ld	a1,80(s1)
    80001ac6:	6ca8                	ld	a0,88(s1)
    80001ac8:	f95ff0ef          	jal	80001a5c <proc_freepagetable>
  p->pagetable = 0;
    80001acc:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001ad0:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001ad4:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001ad8:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001adc:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001ae0:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ae4:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ae8:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001aec:	0004ac23          	sw	zero,24(s1)
}
    80001af0:	60e2                	ld	ra,24(sp)
    80001af2:	6442                	ld	s0,16(sp)
    80001af4:	64a2                	ld	s1,8(sp)
    80001af6:	6105                	addi	sp,sp,32
    80001af8:	8082                	ret

0000000080001afa <allocproc>:
{
    80001afa:	1101                	addi	sp,sp,-32
    80001afc:	ec06                	sd	ra,24(sp)
    80001afe:	e822                	sd	s0,16(sp)
    80001b00:	e426                	sd	s1,8(sp)
    80001b02:	e04a                	sd	s2,0(sp)
    80001b04:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b06:	00011497          	auipc	s1,0x11
    80001b0a:	ec248493          	addi	s1,s1,-318 # 800129c8 <proc>
    80001b0e:	00017917          	auipc	s2,0x17
    80001b12:	cba90913          	addi	s2,s2,-838 # 800187c8 <tickslock>
    acquire(&p->lock);
    80001b16:	8526                	mv	a0,s1
    80001b18:	8b6ff0ef          	jal	80000bce <acquire>
    if(p->state == UNUSED) {
    80001b1c:	4c9c                	lw	a5,24(s1)
    80001b1e:	cb91                	beqz	a5,80001b32 <allocproc+0x38>
      release(&p->lock);
    80001b20:	8526                	mv	a0,s1
    80001b22:	944ff0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b26:	17848493          	addi	s1,s1,376
    80001b2a:	ff2496e3          	bne	s1,s2,80001b16 <allocproc+0x1c>
  return 0;
    80001b2e:	4481                	li	s1,0
    80001b30:	a089                	j	80001b72 <allocproc+0x78>
  p->pid = allocpid();
    80001b32:	e69ff0ef          	jal	8000199a <allocpid>
    80001b36:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b38:	4785                	li	a5,1
    80001b3a:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b3c:	fc3fe0ef          	jal	80000afe <kalloc>
    80001b40:	892a                	mv	s2,a0
    80001b42:	f0a8                	sd	a0,96(s1)
    80001b44:	cd15                	beqz	a0,80001b80 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b46:	8526                	mv	a0,s1
    80001b48:	e91ff0ef          	jal	800019d8 <proc_pagetable>
    80001b4c:	892a                	mv	s2,a0
    80001b4e:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001b50:	c121                	beqz	a0,80001b90 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b52:	07000613          	li	a2,112
    80001b56:	4581                	li	a1,0
    80001b58:	06848513          	addi	a0,s1,104
    80001b5c:	946ff0ef          	jal	80000ca2 <memset>
  p->context.ra = (uint64)forkret;
    80001b60:	00000797          	auipc	a5,0x0
    80001b64:	da278793          	addi	a5,a5,-606 # 80001902 <forkret>
    80001b68:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b6a:	64bc                	ld	a5,72(s1)
    80001b6c:	6705                	lui	a4,0x1
    80001b6e:	97ba                	add	a5,a5,a4
    80001b70:	f8bc                	sd	a5,112(s1)
}
    80001b72:	8526                	mv	a0,s1
    80001b74:	60e2                	ld	ra,24(sp)
    80001b76:	6442                	ld	s0,16(sp)
    80001b78:	64a2                	ld	s1,8(sp)
    80001b7a:	6902                	ld	s2,0(sp)
    80001b7c:	6105                	addi	sp,sp,32
    80001b7e:	8082                	ret
    freeproc(p);
    80001b80:	8526                	mv	a0,s1
    80001b82:	f21ff0ef          	jal	80001aa2 <freeproc>
    release(&p->lock);
    80001b86:	8526                	mv	a0,s1
    80001b88:	8deff0ef          	jal	80000c66 <release>
    return 0;
    80001b8c:	84ca                	mv	s1,s2
    80001b8e:	b7d5                	j	80001b72 <allocproc+0x78>
    freeproc(p);
    80001b90:	8526                	mv	a0,s1
    80001b92:	f11ff0ef          	jal	80001aa2 <freeproc>
    release(&p->lock);
    80001b96:	8526                	mv	a0,s1
    80001b98:	8ceff0ef          	jal	80000c66 <release>
    return 0;
    80001b9c:	84ca                	mv	s1,s2
    80001b9e:	bfd1                	j	80001b72 <allocproc+0x78>

0000000080001ba0 <kallocproc>:
{
    80001ba0:	1141                	addi	sp,sp,-16
    80001ba2:	e406                	sd	ra,8(sp)
    80001ba4:	e022                	sd	s0,0(sp)
    80001ba6:	0800                	addi	s0,sp,16
  return allocproc();
    80001ba8:	f53ff0ef          	jal	80001afa <allocproc>
}
    80001bac:	60a2                	ld	ra,8(sp)
    80001bae:	6402                	ld	s0,0(sp)
    80001bb0:	0141                	addi	sp,sp,16
    80001bb2:	8082                	ret

0000000080001bb4 <kfreeproc>:
{
    80001bb4:	1141                	addi	sp,sp,-16
    80001bb6:	e406                	sd	ra,8(sp)
    80001bb8:	e022                	sd	s0,0(sp)
    80001bba:	0800                	addi	s0,sp,16
  freeproc(p);
    80001bbc:	ee7ff0ef          	jal	80001aa2 <freeproc>
}
    80001bc0:	60a2                	ld	ra,8(sp)
    80001bc2:	6402                	ld	s0,0(sp)
    80001bc4:	0141                	addi	sp,sp,16
    80001bc6:	8082                	ret

0000000080001bc8 <userinit>:
{
    80001bc8:	1101                	addi	sp,sp,-32
    80001bca:	ec06                	sd	ra,24(sp)
    80001bcc:	e822                	sd	s0,16(sp)
    80001bce:	e426                	sd	s1,8(sp)
    80001bd0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001bd2:	f29ff0ef          	jal	80001afa <allocproc>
    80001bd6:	84aa                	mv	s1,a0
  initproc = p;
    80001bd8:	00009797          	auipc	a5,0x9
    80001bdc:	8aa7bc23          	sd	a0,-1864(a5) # 8000a490 <initproc>
  p->cwd = namei("/");
    80001be0:	00005517          	auipc	a0,0x5
    80001be4:	5b050513          	addi	a0,a0,1456 # 80007190 <etext+0x190>
    80001be8:	428020ef          	jal	80004010 <namei>
    80001bec:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001bf0:	478d                	li	a5,3
    80001bf2:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bf4:	8526                	mv	a0,s1
    80001bf6:	870ff0ef          	jal	80000c66 <release>
}
    80001bfa:	60e2                	ld	ra,24(sp)
    80001bfc:	6442                	ld	s0,16(sp)
    80001bfe:	64a2                	ld	s1,8(sp)
    80001c00:	6105                	addi	sp,sp,32
    80001c02:	8082                	ret

0000000080001c04 <growproc>:
{
    80001c04:	1101                	addi	sp,sp,-32
    80001c06:	ec06                	sd	ra,24(sp)
    80001c08:	e822                	sd	s0,16(sp)
    80001c0a:	e426                	sd	s1,8(sp)
    80001c0c:	e04a                	sd	s2,0(sp)
    80001c0e:	1000                	addi	s0,sp,32
    80001c10:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c12:	cc1ff0ef          	jal	800018d2 <myproc>
    80001c16:	892a                	mv	s2,a0
  sz = p->sz;
    80001c18:	692c                	ld	a1,80(a0)
  if(n > 0){
    80001c1a:	02905963          	blez	s1,80001c4c <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001c1e:	00b48633          	add	a2,s1,a1
    80001c22:	020007b7          	lui	a5,0x2000
    80001c26:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c28:	07b6                	slli	a5,a5,0xd
    80001c2a:	02c7ea63          	bltu	a5,a2,80001c5e <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c2e:	4691                	li	a3,4
    80001c30:	6d28                	ld	a0,88(a0)
    80001c32:	e5aff0ef          	jal	8000128c <uvmalloc>
    80001c36:	85aa                	mv	a1,a0
    80001c38:	c50d                	beqz	a0,80001c62 <growproc+0x5e>
  p->sz = sz;
    80001c3a:	04b93823          	sd	a1,80(s2)
  return 0;
    80001c3e:	4501                	li	a0,0
}
    80001c40:	60e2                	ld	ra,24(sp)
    80001c42:	6442                	ld	s0,16(sp)
    80001c44:	64a2                	ld	s1,8(sp)
    80001c46:	6902                	ld	s2,0(sp)
    80001c48:	6105                	addi	sp,sp,32
    80001c4a:	8082                	ret
  } else if(n < 0){
    80001c4c:	fe04d7e3          	bgez	s1,80001c3a <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c50:	00b48633          	add	a2,s1,a1
    80001c54:	6d28                	ld	a0,88(a0)
    80001c56:	df2ff0ef          	jal	80001248 <uvmdealloc>
    80001c5a:	85aa                	mv	a1,a0
    80001c5c:	bff9                	j	80001c3a <growproc+0x36>
      return -1;
    80001c5e:	557d                	li	a0,-1
    80001c60:	b7c5                	j	80001c40 <growproc+0x3c>
      return -1;
    80001c62:	557d                	li	a0,-1
    80001c64:	bff1                	j	80001c40 <growproc+0x3c>

0000000080001c66 <kfork>:
{
    80001c66:	7139                	addi	sp,sp,-64
    80001c68:	fc06                	sd	ra,56(sp)
    80001c6a:	f822                	sd	s0,48(sp)
    80001c6c:	f04a                	sd	s2,32(sp)
    80001c6e:	e456                	sd	s5,8(sp)
    80001c70:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c72:	c61ff0ef          	jal	800018d2 <myproc>
    80001c76:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c78:	e83ff0ef          	jal	80001afa <allocproc>
    80001c7c:	0e050a63          	beqz	a0,80001d70 <kfork+0x10a>
    80001c80:	e852                	sd	s4,16(sp)
    80001c82:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c84:	050ab603          	ld	a2,80(s5)
    80001c88:	6d2c                	ld	a1,88(a0)
    80001c8a:	058ab503          	ld	a0,88(s5)
    80001c8e:	f36ff0ef          	jal	800013c4 <uvmcopy>
    80001c92:	04054a63          	bltz	a0,80001ce6 <kfork+0x80>
    80001c96:	f426                	sd	s1,40(sp)
    80001c98:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c9a:	050ab783          	ld	a5,80(s5)
    80001c9e:	04fa3823          	sd	a5,80(s4)
  *(np->trapframe) = *(p->trapframe);
    80001ca2:	060ab683          	ld	a3,96(s5)
    80001ca6:	87b6                	mv	a5,a3
    80001ca8:	060a3703          	ld	a4,96(s4)
    80001cac:	12068693          	addi	a3,a3,288
    80001cb0:	0007b803          	ld	a6,0(a5)
    80001cb4:	6788                	ld	a0,8(a5)
    80001cb6:	6b8c                	ld	a1,16(a5)
    80001cb8:	6f90                	ld	a2,24(a5)
    80001cba:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001cbe:	e708                	sd	a0,8(a4)
    80001cc0:	eb0c                	sd	a1,16(a4)
    80001cc2:	ef10                	sd	a2,24(a4)
    80001cc4:	02078793          	addi	a5,a5,32
    80001cc8:	02070713          	addi	a4,a4,32
    80001ccc:	fed792e3          	bne	a5,a3,80001cb0 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001cd0:	060a3783          	ld	a5,96(s4)
    80001cd4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001cd8:	0d8a8493          	addi	s1,s5,216
    80001cdc:	0d8a0913          	addi	s2,s4,216
    80001ce0:	158a8993          	addi	s3,s5,344
    80001ce4:	a831                	j	80001d00 <kfork+0x9a>
    freeproc(np);
    80001ce6:	8552                	mv	a0,s4
    80001ce8:	dbbff0ef          	jal	80001aa2 <freeproc>
    release(&np->lock);
    80001cec:	8552                	mv	a0,s4
    80001cee:	f79fe0ef          	jal	80000c66 <release>
    return -1;
    80001cf2:	597d                	li	s2,-1
    80001cf4:	6a42                	ld	s4,16(sp)
    80001cf6:	a0b5                	j	80001d62 <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001cf8:	04a1                	addi	s1,s1,8
    80001cfa:	0921                	addi	s2,s2,8
    80001cfc:	01348963          	beq	s1,s3,80001d0e <kfork+0xa8>
    if(p->ofile[i])
    80001d00:	6088                	ld	a0,0(s1)
    80001d02:	d97d                	beqz	a0,80001cf8 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d04:	0a7020ef          	jal	800045aa <filedup>
    80001d08:	00a93023          	sd	a0,0(s2)
    80001d0c:	b7f5                	j	80001cf8 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001d0e:	158ab503          	ld	a0,344(s5)
    80001d12:	2b3010ef          	jal	800037c4 <idup>
    80001d16:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d1a:	4641                	li	a2,16
    80001d1c:	160a8593          	addi	a1,s5,352
    80001d20:	160a0513          	addi	a0,s4,352
    80001d24:	8bcff0ef          	jal	80000de0 <safestrcpy>
  pid = np->pid;
    80001d28:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001d2c:	8552                	mv	a0,s4
    80001d2e:	f39fe0ef          	jal	80000c66 <release>
  acquire(&wait_lock);
    80001d32:	00011497          	auipc	s1,0x11
    80001d36:	87e48493          	addi	s1,s1,-1922 # 800125b0 <wait_lock>
    80001d3a:	8526                	mv	a0,s1
    80001d3c:	e93fe0ef          	jal	80000bce <acquire>
  np->parent = p;
    80001d40:	055a3023          	sd	s5,64(s4)
  release(&wait_lock);
    80001d44:	8526                	mv	a0,s1
    80001d46:	f21fe0ef          	jal	80000c66 <release>
  acquire(&np->lock);
    80001d4a:	8552                	mv	a0,s4
    80001d4c:	e83fe0ef          	jal	80000bce <acquire>
  np->state = RUNNABLE;
    80001d50:	478d                	li	a5,3
    80001d52:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d56:	8552                	mv	a0,s4
    80001d58:	f0ffe0ef          	jal	80000c66 <release>
  return pid;
    80001d5c:	74a2                	ld	s1,40(sp)
    80001d5e:	69e2                	ld	s3,24(sp)
    80001d60:	6a42                	ld	s4,16(sp)
}
    80001d62:	854a                	mv	a0,s2
    80001d64:	70e2                	ld	ra,56(sp)
    80001d66:	7442                	ld	s0,48(sp)
    80001d68:	7902                	ld	s2,32(sp)
    80001d6a:	6aa2                	ld	s5,8(sp)
    80001d6c:	6121                	addi	sp,sp,64
    80001d6e:	8082                	ret
    return -1;
    80001d70:	597d                	li	s2,-1
    80001d72:	bfc5                	j	80001d62 <kfork+0xfc>

0000000080001d74 <scheduler>:
{
    80001d74:	715d                	addi	sp,sp,-80
    80001d76:	e486                	sd	ra,72(sp)
    80001d78:	e0a2                	sd	s0,64(sp)
    80001d7a:	fc26                	sd	s1,56(sp)
    80001d7c:	f84a                	sd	s2,48(sp)
    80001d7e:	f44e                	sd	s3,40(sp)
    80001d80:	f052                	sd	s4,32(sp)
    80001d82:	ec56                	sd	s5,24(sp)
    80001d84:	e85a                	sd	s6,16(sp)
    80001d86:	e45e                	sd	s7,8(sp)
    80001d88:	e062                	sd	s8,0(sp)
    80001d8a:	0880                	addi	s0,sp,80
    80001d8c:	8792                	mv	a5,tp
  int id = r_tp();
    80001d8e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d90:	00779b13          	slli	s6,a5,0x7
    80001d94:	00011717          	auipc	a4,0x11
    80001d98:	80470713          	addi	a4,a4,-2044 # 80012598 <pid_lock>
    80001d9c:	975a                	add	a4,a4,s6
    80001d9e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001da2:	00011717          	auipc	a4,0x11
    80001da6:	82e70713          	addi	a4,a4,-2002 # 800125d0 <cpus+0x8>
    80001daa:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001dac:	4c11                	li	s8,4
        c->proc = p;
    80001dae:	079e                	slli	a5,a5,0x7
    80001db0:	00010a17          	auipc	s4,0x10
    80001db4:	7e8a0a13          	addi	s4,s4,2024 # 80012598 <pid_lock>
    80001db8:	9a3e                	add	s4,s4,a5
        found = 1;
    80001dba:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dbc:	00017997          	auipc	s3,0x17
    80001dc0:	a0c98993          	addi	s3,s3,-1524 # 800187c8 <tickslock>
    80001dc4:	a83d                	j	80001e02 <scheduler+0x8e>
      release(&p->lock);
    80001dc6:	8526                	mv	a0,s1
    80001dc8:	e9ffe0ef          	jal	80000c66 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dcc:	17848493          	addi	s1,s1,376
    80001dd0:	03348563          	beq	s1,s3,80001dfa <scheduler+0x86>
      acquire(&p->lock);
    80001dd4:	8526                	mv	a0,s1
    80001dd6:	df9fe0ef          	jal	80000bce <acquire>
      if(p->state == RUNNABLE) {
    80001dda:	4c9c                	lw	a5,24(s1)
    80001ddc:	ff2795e3          	bne	a5,s2,80001dc6 <scheduler+0x52>
        p->state = RUNNING;
    80001de0:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001de4:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001de8:	06848593          	addi	a1,s1,104
    80001dec:	855a                	mv	a0,s6
    80001dee:	5b2000ef          	jal	800023a0 <swtch>
        c->proc = 0;
    80001df2:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001df6:	8ade                	mv	s5,s7
    80001df8:	b7f9                	j	80001dc6 <scheduler+0x52>
    if(found == 0) {
    80001dfa:	000a9463          	bnez	s5,80001e02 <scheduler+0x8e>
      asm volatile("wfi");
    80001dfe:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e02:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e06:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e0a:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e0e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001e12:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e14:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001e18:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e1a:	00011497          	auipc	s1,0x11
    80001e1e:	bae48493          	addi	s1,s1,-1106 # 800129c8 <proc>
      if(p->state == RUNNABLE) {
    80001e22:	490d                	li	s2,3
    80001e24:	bf45                	j	80001dd4 <scheduler+0x60>

0000000080001e26 <sched>:
{
    80001e26:	7179                	addi	sp,sp,-48
    80001e28:	f406                	sd	ra,40(sp)
    80001e2a:	f022                	sd	s0,32(sp)
    80001e2c:	ec26                	sd	s1,24(sp)
    80001e2e:	e84a                	sd	s2,16(sp)
    80001e30:	e44e                	sd	s3,8(sp)
    80001e32:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e34:	a9fff0ef          	jal	800018d2 <myproc>
    80001e38:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e3a:	d2bfe0ef          	jal	80000b64 <holding>
    80001e3e:	c92d                	beqz	a0,80001eb0 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e40:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e42:	2781                	sext.w	a5,a5
    80001e44:	079e                	slli	a5,a5,0x7
    80001e46:	00010717          	auipc	a4,0x10
    80001e4a:	75270713          	addi	a4,a4,1874 # 80012598 <pid_lock>
    80001e4e:	97ba                	add	a5,a5,a4
    80001e50:	0a87a703          	lw	a4,168(a5)
    80001e54:	4785                	li	a5,1
    80001e56:	06f71363          	bne	a4,a5,80001ebc <sched+0x96>
  if(p->state == RUNNING)
    80001e5a:	4c98                	lw	a4,24(s1)
    80001e5c:	4791                	li	a5,4
    80001e5e:	06f70563          	beq	a4,a5,80001ec8 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e62:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e66:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e68:	e7b5                	bnez	a5,80001ed4 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e6a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e6c:	00010917          	auipc	s2,0x10
    80001e70:	72c90913          	addi	s2,s2,1836 # 80012598 <pid_lock>
    80001e74:	2781                	sext.w	a5,a5
    80001e76:	079e                	slli	a5,a5,0x7
    80001e78:	97ca                	add	a5,a5,s2
    80001e7a:	0ac7a983          	lw	s3,172(a5)
    80001e7e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e80:	2781                	sext.w	a5,a5
    80001e82:	079e                	slli	a5,a5,0x7
    80001e84:	00010597          	auipc	a1,0x10
    80001e88:	74c58593          	addi	a1,a1,1868 # 800125d0 <cpus+0x8>
    80001e8c:	95be                	add	a1,a1,a5
    80001e8e:	06848513          	addi	a0,s1,104
    80001e92:	50e000ef          	jal	800023a0 <swtch>
    80001e96:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e98:	2781                	sext.w	a5,a5
    80001e9a:	079e                	slli	a5,a5,0x7
    80001e9c:	993e                	add	s2,s2,a5
    80001e9e:	0b392623          	sw	s3,172(s2)
}
    80001ea2:	70a2                	ld	ra,40(sp)
    80001ea4:	7402                	ld	s0,32(sp)
    80001ea6:	64e2                	ld	s1,24(sp)
    80001ea8:	6942                	ld	s2,16(sp)
    80001eaa:	69a2                	ld	s3,8(sp)
    80001eac:	6145                	addi	sp,sp,48
    80001eae:	8082                	ret
    panic("sched p->lock");
    80001eb0:	00005517          	auipc	a0,0x5
    80001eb4:	2e850513          	addi	a0,a0,744 # 80007198 <etext+0x198>
    80001eb8:	929fe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    80001ebc:	00005517          	auipc	a0,0x5
    80001ec0:	2ec50513          	addi	a0,a0,748 # 800071a8 <etext+0x1a8>
    80001ec4:	91dfe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    80001ec8:	00005517          	auipc	a0,0x5
    80001ecc:	2f050513          	addi	a0,a0,752 # 800071b8 <etext+0x1b8>
    80001ed0:	911fe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    80001ed4:	00005517          	auipc	a0,0x5
    80001ed8:	2f450513          	addi	a0,a0,756 # 800071c8 <etext+0x1c8>
    80001edc:	905fe0ef          	jal	800007e0 <panic>

0000000080001ee0 <yield>:
{
    80001ee0:	1101                	addi	sp,sp,-32
    80001ee2:	ec06                	sd	ra,24(sp)
    80001ee4:	e822                	sd	s0,16(sp)
    80001ee6:	e426                	sd	s1,8(sp)
    80001ee8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001eea:	9e9ff0ef          	jal	800018d2 <myproc>
    80001eee:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001ef0:	cdffe0ef          	jal	80000bce <acquire>
  p->state = RUNNABLE;
    80001ef4:	478d                	li	a5,3
    80001ef6:	cc9c                	sw	a5,24(s1)
  sched();
    80001ef8:	f2fff0ef          	jal	80001e26 <sched>
  release(&p->lock);
    80001efc:	8526                	mv	a0,s1
    80001efe:	d69fe0ef          	jal	80000c66 <release>
}
    80001f02:	60e2                	ld	ra,24(sp)
    80001f04:	6442                	ld	s0,16(sp)
    80001f06:	64a2                	ld	s1,8(sp)
    80001f08:	6105                	addi	sp,sp,32
    80001f0a:	8082                	ret

0000000080001f0c <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001f0c:	7179                	addi	sp,sp,-48
    80001f0e:	f406                	sd	ra,40(sp)
    80001f10:	f022                	sd	s0,32(sp)
    80001f12:	ec26                	sd	s1,24(sp)
    80001f14:	e84a                	sd	s2,16(sp)
    80001f16:	e44e                	sd	s3,8(sp)
    80001f18:	1800                	addi	s0,sp,48
    80001f1a:	89aa                	mv	s3,a0
    80001f1c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f1e:	9b5ff0ef          	jal	800018d2 <myproc>
    80001f22:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001f24:	cabfe0ef          	jal	80000bce <acquire>
  release(lk);
    80001f28:	854a                	mv	a0,s2
    80001f2a:	d3dfe0ef          	jal	80000c66 <release>

  // Go to sleep.
  p->chan = chan;
    80001f2e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f32:	4789                	li	a5,2
    80001f34:	cc9c                	sw	a5,24(s1)

  sched();
    80001f36:	ef1ff0ef          	jal	80001e26 <sched>

  // Tidy up.
  p->chan = 0;
    80001f3a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f3e:	8526                	mv	a0,s1
    80001f40:	d27fe0ef          	jal	80000c66 <release>
  acquire(lk);
    80001f44:	854a                	mv	a0,s2
    80001f46:	c89fe0ef          	jal	80000bce <acquire>
}
    80001f4a:	70a2                	ld	ra,40(sp)
    80001f4c:	7402                	ld	s0,32(sp)
    80001f4e:	64e2                	ld	s1,24(sp)
    80001f50:	6942                	ld	s2,16(sp)
    80001f52:	69a2                	ld	s3,8(sp)
    80001f54:	6145                	addi	sp,sp,48
    80001f56:	8082                	ret

0000000080001f58 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001f58:	7139                	addi	sp,sp,-64
    80001f5a:	fc06                	sd	ra,56(sp)
    80001f5c:	f822                	sd	s0,48(sp)
    80001f5e:	f426                	sd	s1,40(sp)
    80001f60:	f04a                	sd	s2,32(sp)
    80001f62:	ec4e                	sd	s3,24(sp)
    80001f64:	e852                	sd	s4,16(sp)
    80001f66:	e456                	sd	s5,8(sp)
    80001f68:	0080                	addi	s0,sp,64
    80001f6a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f6c:	00011497          	auipc	s1,0x11
    80001f70:	a5c48493          	addi	s1,s1,-1444 # 800129c8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f74:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f76:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f78:	00017917          	auipc	s2,0x17
    80001f7c:	85090913          	addi	s2,s2,-1968 # 800187c8 <tickslock>
    80001f80:	a801                	j	80001f90 <wakeup+0x38>
      }
      release(&p->lock);
    80001f82:	8526                	mv	a0,s1
    80001f84:	ce3fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f88:	17848493          	addi	s1,s1,376
    80001f8c:	03248263          	beq	s1,s2,80001fb0 <wakeup+0x58>
    if(p != myproc()){
    80001f90:	943ff0ef          	jal	800018d2 <myproc>
    80001f94:	fea48ae3          	beq	s1,a0,80001f88 <wakeup+0x30>
      acquire(&p->lock);
    80001f98:	8526                	mv	a0,s1
    80001f9a:	c35fe0ef          	jal	80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f9e:	4c9c                	lw	a5,24(s1)
    80001fa0:	ff3791e3          	bne	a5,s3,80001f82 <wakeup+0x2a>
    80001fa4:	709c                	ld	a5,32(s1)
    80001fa6:	fd479ee3          	bne	a5,s4,80001f82 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001faa:	0154ac23          	sw	s5,24(s1)
    80001fae:	bfd1                	j	80001f82 <wakeup+0x2a>
    }
  }
}
    80001fb0:	70e2                	ld	ra,56(sp)
    80001fb2:	7442                	ld	s0,48(sp)
    80001fb4:	74a2                	ld	s1,40(sp)
    80001fb6:	7902                	ld	s2,32(sp)
    80001fb8:	69e2                	ld	s3,24(sp)
    80001fba:	6a42                	ld	s4,16(sp)
    80001fbc:	6aa2                	ld	s5,8(sp)
    80001fbe:	6121                	addi	sp,sp,64
    80001fc0:	8082                	ret

0000000080001fc2 <reparent>:
{
    80001fc2:	7179                	addi	sp,sp,-48
    80001fc4:	f406                	sd	ra,40(sp)
    80001fc6:	f022                	sd	s0,32(sp)
    80001fc8:	ec26                	sd	s1,24(sp)
    80001fca:	e84a                	sd	s2,16(sp)
    80001fcc:	e44e                	sd	s3,8(sp)
    80001fce:	e052                	sd	s4,0(sp)
    80001fd0:	1800                	addi	s0,sp,48
    80001fd2:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fd4:	00011497          	auipc	s1,0x11
    80001fd8:	9f448493          	addi	s1,s1,-1548 # 800129c8 <proc>
      pp->parent = initproc;
    80001fdc:	00008a17          	auipc	s4,0x8
    80001fe0:	4b4a0a13          	addi	s4,s4,1204 # 8000a490 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fe4:	00016997          	auipc	s3,0x16
    80001fe8:	7e498993          	addi	s3,s3,2020 # 800187c8 <tickslock>
    80001fec:	a029                	j	80001ff6 <reparent+0x34>
    80001fee:	17848493          	addi	s1,s1,376
    80001ff2:	01348b63          	beq	s1,s3,80002008 <reparent+0x46>
    if(pp->parent == p){
    80001ff6:	60bc                	ld	a5,64(s1)
    80001ff8:	ff279be3          	bne	a5,s2,80001fee <reparent+0x2c>
      pp->parent = initproc;
    80001ffc:	000a3503          	ld	a0,0(s4)
    80002000:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    80002002:	f57ff0ef          	jal	80001f58 <wakeup>
    80002006:	b7e5                	j	80001fee <reparent+0x2c>
}
    80002008:	70a2                	ld	ra,40(sp)
    8000200a:	7402                	ld	s0,32(sp)
    8000200c:	64e2                	ld	s1,24(sp)
    8000200e:	6942                	ld	s2,16(sp)
    80002010:	69a2                	ld	s3,8(sp)
    80002012:	6a02                	ld	s4,0(sp)
    80002014:	6145                	addi	sp,sp,48
    80002016:	8082                	ret

0000000080002018 <kexit>:
{
    80002018:	7179                	addi	sp,sp,-48
    8000201a:	f406                	sd	ra,40(sp)
    8000201c:	f022                	sd	s0,32(sp)
    8000201e:	ec26                	sd	s1,24(sp)
    80002020:	e84a                	sd	s2,16(sp)
    80002022:	e44e                	sd	s3,8(sp)
    80002024:	e052                	sd	s4,0(sp)
    80002026:	1800                	addi	s0,sp,48
    80002028:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000202a:	8a9ff0ef          	jal	800018d2 <myproc>
    8000202e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002030:	00008797          	auipc	a5,0x8
    80002034:	4607b783          	ld	a5,1120(a5) # 8000a490 <initproc>
    80002038:	0d850493          	addi	s1,a0,216
    8000203c:	15850913          	addi	s2,a0,344
    80002040:	00a79f63          	bne	a5,a0,8000205e <kexit+0x46>
    panic("init exiting");
    80002044:	00005517          	auipc	a0,0x5
    80002048:	19c50513          	addi	a0,a0,412 # 800071e0 <etext+0x1e0>
    8000204c:	f94fe0ef          	jal	800007e0 <panic>
      fileclose(f);
    80002050:	5a0020ef          	jal	800045f0 <fileclose>
      p->ofile[fd] = 0;
    80002054:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002058:	04a1                	addi	s1,s1,8
    8000205a:	01248563          	beq	s1,s2,80002064 <kexit+0x4c>
    if(p->ofile[fd]){
    8000205e:	6088                	ld	a0,0(s1)
    80002060:	f965                	bnez	a0,80002050 <kexit+0x38>
    80002062:	bfdd                	j	80002058 <kexit+0x40>
  begin_op();
    80002064:	180020ef          	jal	800041e4 <begin_op>
  iput(p->cwd);
    80002068:	1589b503          	ld	a0,344(s3)
    8000206c:	111010ef          	jal	8000397c <iput>
  end_op();
    80002070:	1de020ef          	jal	8000424e <end_op>
  p->cwd = 0;
    80002074:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    80002078:	00010497          	auipc	s1,0x10
    8000207c:	53848493          	addi	s1,s1,1336 # 800125b0 <wait_lock>
    80002080:	8526                	mv	a0,s1
    80002082:	b4dfe0ef          	jal	80000bce <acquire>
  reparent(p);
    80002086:	854e                	mv	a0,s3
    80002088:	f3bff0ef          	jal	80001fc2 <reparent>
  wakeup(p->parent);
    8000208c:	0409b503          	ld	a0,64(s3)
    80002090:	ec9ff0ef          	jal	80001f58 <wakeup>
  acquire(&p->lock);
    80002094:	854e                	mv	a0,s3
    80002096:	b39fe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    8000209a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000209e:	4795                	li	a5,5
    800020a0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800020a4:	8526                	mv	a0,s1
    800020a6:	bc1fe0ef          	jal	80000c66 <release>
  sched();
    800020aa:	d7dff0ef          	jal	80001e26 <sched>
  panic("zombie exit");
    800020ae:	00005517          	auipc	a0,0x5
    800020b2:	14250513          	addi	a0,a0,322 # 800071f0 <etext+0x1f0>
    800020b6:	f2afe0ef          	jal	800007e0 <panic>

00000000800020ba <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800020ba:	7179                	addi	sp,sp,-48
    800020bc:	f406                	sd	ra,40(sp)
    800020be:	f022                	sd	s0,32(sp)
    800020c0:	ec26                	sd	s1,24(sp)
    800020c2:	e84a                	sd	s2,16(sp)
    800020c4:	e44e                	sd	s3,8(sp)
    800020c6:	1800                	addi	s0,sp,48
    800020c8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800020ca:	00011497          	auipc	s1,0x11
    800020ce:	8fe48493          	addi	s1,s1,-1794 # 800129c8 <proc>
    800020d2:	00016997          	auipc	s3,0x16
    800020d6:	6f698993          	addi	s3,s3,1782 # 800187c8 <tickslock>
    acquire(&p->lock);
    800020da:	8526                	mv	a0,s1
    800020dc:	af3fe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    800020e0:	589c                	lw	a5,48(s1)
    800020e2:	01278b63          	beq	a5,s2,800020f8 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020e6:	8526                	mv	a0,s1
    800020e8:	b7ffe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020ec:	17848493          	addi	s1,s1,376
    800020f0:	ff3495e3          	bne	s1,s3,800020da <kkill+0x20>
  }
  return -1;
    800020f4:	557d                	li	a0,-1
    800020f6:	a819                	j	8000210c <kkill+0x52>
      p->killed = 1;
    800020f8:	4785                	li	a5,1
    800020fa:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020fc:	4c98                	lw	a4,24(s1)
    800020fe:	4789                	li	a5,2
    80002100:	00f70d63          	beq	a4,a5,8000211a <kkill+0x60>
      release(&p->lock);
    80002104:	8526                	mv	a0,s1
    80002106:	b61fe0ef          	jal	80000c66 <release>
      return 0;
    8000210a:	4501                	li	a0,0
}
    8000210c:	70a2                	ld	ra,40(sp)
    8000210e:	7402                	ld	s0,32(sp)
    80002110:	64e2                	ld	s1,24(sp)
    80002112:	6942                	ld	s2,16(sp)
    80002114:	69a2                	ld	s3,8(sp)
    80002116:	6145                	addi	sp,sp,48
    80002118:	8082                	ret
        p->state = RUNNABLE;
    8000211a:	478d                	li	a5,3
    8000211c:	cc9c                	sw	a5,24(s1)
    8000211e:	b7dd                	j	80002104 <kkill+0x4a>

0000000080002120 <setkilled>:

void
setkilled(struct proc *p)
{
    80002120:	1101                	addi	sp,sp,-32
    80002122:	ec06                	sd	ra,24(sp)
    80002124:	e822                	sd	s0,16(sp)
    80002126:	e426                	sd	s1,8(sp)
    80002128:	1000                	addi	s0,sp,32
    8000212a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000212c:	aa3fe0ef          	jal	80000bce <acquire>
  p->killed = 1;
    80002130:	4785                	li	a5,1
    80002132:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002134:	8526                	mv	a0,s1
    80002136:	b31fe0ef          	jal	80000c66 <release>
}
    8000213a:	60e2                	ld	ra,24(sp)
    8000213c:	6442                	ld	s0,16(sp)
    8000213e:	64a2                	ld	s1,8(sp)
    80002140:	6105                	addi	sp,sp,32
    80002142:	8082                	ret

0000000080002144 <killed>:

int
killed(struct proc *p)
{
    80002144:	1101                	addi	sp,sp,-32
    80002146:	ec06                	sd	ra,24(sp)
    80002148:	e822                	sd	s0,16(sp)
    8000214a:	e426                	sd	s1,8(sp)
    8000214c:	e04a                	sd	s2,0(sp)
    8000214e:	1000                	addi	s0,sp,32
    80002150:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002152:	a7dfe0ef          	jal	80000bce <acquire>
  k = p->killed;
    80002156:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000215a:	8526                	mv	a0,s1
    8000215c:	b0bfe0ef          	jal	80000c66 <release>
  return k;
}
    80002160:	854a                	mv	a0,s2
    80002162:	60e2                	ld	ra,24(sp)
    80002164:	6442                	ld	s0,16(sp)
    80002166:	64a2                	ld	s1,8(sp)
    80002168:	6902                	ld	s2,0(sp)
    8000216a:	6105                	addi	sp,sp,32
    8000216c:	8082                	ret

000000008000216e <kwait>:
{
    8000216e:	715d                	addi	sp,sp,-80
    80002170:	e486                	sd	ra,72(sp)
    80002172:	e0a2                	sd	s0,64(sp)
    80002174:	fc26                	sd	s1,56(sp)
    80002176:	f84a                	sd	s2,48(sp)
    80002178:	f44e                	sd	s3,40(sp)
    8000217a:	f052                	sd	s4,32(sp)
    8000217c:	ec56                	sd	s5,24(sp)
    8000217e:	e85a                	sd	s6,16(sp)
    80002180:	e45e                	sd	s7,8(sp)
    80002182:	e062                	sd	s8,0(sp)
    80002184:	0880                	addi	s0,sp,80
    80002186:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002188:	f4aff0ef          	jal	800018d2 <myproc>
    8000218c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000218e:	00010517          	auipc	a0,0x10
    80002192:	42250513          	addi	a0,a0,1058 # 800125b0 <wait_lock>
    80002196:	a39fe0ef          	jal	80000bce <acquire>
    havekids = 0;
    8000219a:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000219c:	4a15                	li	s4,5
        havekids = 1;
    8000219e:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021a0:	00016997          	auipc	s3,0x16
    800021a4:	62898993          	addi	s3,s3,1576 # 800187c8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021a8:	00010c17          	auipc	s8,0x10
    800021ac:	408c0c13          	addi	s8,s8,1032 # 800125b0 <wait_lock>
    800021b0:	a871                	j	8000224c <kwait+0xde>
          pid = pp->pid;
    800021b2:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800021b6:	000b0c63          	beqz	s6,800021ce <kwait+0x60>
    800021ba:	4691                	li	a3,4
    800021bc:	02c48613          	addi	a2,s1,44
    800021c0:	85da                	mv	a1,s6
    800021c2:	05893503          	ld	a0,88(s2)
    800021c6:	c20ff0ef          	jal	800015e6 <copyout>
    800021ca:	02054b63          	bltz	a0,80002200 <kwait+0x92>
          freeproc(pp);
    800021ce:	8526                	mv	a0,s1
    800021d0:	8d3ff0ef          	jal	80001aa2 <freeproc>
          release(&pp->lock);
    800021d4:	8526                	mv	a0,s1
    800021d6:	a91fe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    800021da:	00010517          	auipc	a0,0x10
    800021de:	3d650513          	addi	a0,a0,982 # 800125b0 <wait_lock>
    800021e2:	a85fe0ef          	jal	80000c66 <release>
}
    800021e6:	854e                	mv	a0,s3
    800021e8:	60a6                	ld	ra,72(sp)
    800021ea:	6406                	ld	s0,64(sp)
    800021ec:	74e2                	ld	s1,56(sp)
    800021ee:	7942                	ld	s2,48(sp)
    800021f0:	79a2                	ld	s3,40(sp)
    800021f2:	7a02                	ld	s4,32(sp)
    800021f4:	6ae2                	ld	s5,24(sp)
    800021f6:	6b42                	ld	s6,16(sp)
    800021f8:	6ba2                	ld	s7,8(sp)
    800021fa:	6c02                	ld	s8,0(sp)
    800021fc:	6161                	addi	sp,sp,80
    800021fe:	8082                	ret
            release(&pp->lock);
    80002200:	8526                	mv	a0,s1
    80002202:	a65fe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    80002206:	00010517          	auipc	a0,0x10
    8000220a:	3aa50513          	addi	a0,a0,938 # 800125b0 <wait_lock>
    8000220e:	a59fe0ef          	jal	80000c66 <release>
            return -1;
    80002212:	59fd                	li	s3,-1
    80002214:	bfc9                	j	800021e6 <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002216:	17848493          	addi	s1,s1,376
    8000221a:	03348063          	beq	s1,s3,8000223a <kwait+0xcc>
      if(pp->parent == p){
    8000221e:	60bc                	ld	a5,64(s1)
    80002220:	ff279be3          	bne	a5,s2,80002216 <kwait+0xa8>
        acquire(&pp->lock);
    80002224:	8526                	mv	a0,s1
    80002226:	9a9fe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    8000222a:	4c9c                	lw	a5,24(s1)
    8000222c:	f94783e3          	beq	a5,s4,800021b2 <kwait+0x44>
        release(&pp->lock);
    80002230:	8526                	mv	a0,s1
    80002232:	a35fe0ef          	jal	80000c66 <release>
        havekids = 1;
    80002236:	8756                	mv	a4,s5
    80002238:	bff9                	j	80002216 <kwait+0xa8>
    if(!havekids || killed(p)){
    8000223a:	cf19                	beqz	a4,80002258 <kwait+0xea>
    8000223c:	854a                	mv	a0,s2
    8000223e:	f07ff0ef          	jal	80002144 <killed>
    80002242:	e919                	bnez	a0,80002258 <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002244:	85e2                	mv	a1,s8
    80002246:	854a                	mv	a0,s2
    80002248:	cc5ff0ef          	jal	80001f0c <sleep>
    havekids = 0;
    8000224c:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000224e:	00010497          	auipc	s1,0x10
    80002252:	77a48493          	addi	s1,s1,1914 # 800129c8 <proc>
    80002256:	b7e1                	j	8000221e <kwait+0xb0>
      release(&wait_lock);
    80002258:	00010517          	auipc	a0,0x10
    8000225c:	35850513          	addi	a0,a0,856 # 800125b0 <wait_lock>
    80002260:	a07fe0ef          	jal	80000c66 <release>
      return -1;
    80002264:	59fd                	li	s3,-1
    80002266:	b741                	j	800021e6 <kwait+0x78>

0000000080002268 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002268:	7179                	addi	sp,sp,-48
    8000226a:	f406                	sd	ra,40(sp)
    8000226c:	f022                	sd	s0,32(sp)
    8000226e:	ec26                	sd	s1,24(sp)
    80002270:	e84a                	sd	s2,16(sp)
    80002272:	e44e                	sd	s3,8(sp)
    80002274:	e052                	sd	s4,0(sp)
    80002276:	1800                	addi	s0,sp,48
    80002278:	84aa                	mv	s1,a0
    8000227a:	892e                	mv	s2,a1
    8000227c:	89b2                	mv	s3,a2
    8000227e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002280:	e52ff0ef          	jal	800018d2 <myproc>
  if(user_dst){
    80002284:	cc99                	beqz	s1,800022a2 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002286:	86d2                	mv	a3,s4
    80002288:	864e                	mv	a2,s3
    8000228a:	85ca                	mv	a1,s2
    8000228c:	6d28                	ld	a0,88(a0)
    8000228e:	b58ff0ef          	jal	800015e6 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002292:	70a2                	ld	ra,40(sp)
    80002294:	7402                	ld	s0,32(sp)
    80002296:	64e2                	ld	s1,24(sp)
    80002298:	6942                	ld	s2,16(sp)
    8000229a:	69a2                	ld	s3,8(sp)
    8000229c:	6a02                	ld	s4,0(sp)
    8000229e:	6145                	addi	sp,sp,48
    800022a0:	8082                	ret
    memmove((char *)dst, src, len);
    800022a2:	000a061b          	sext.w	a2,s4
    800022a6:	85ce                	mv	a1,s3
    800022a8:	854a                	mv	a0,s2
    800022aa:	a55fe0ef          	jal	80000cfe <memmove>
    return 0;
    800022ae:	8526                	mv	a0,s1
    800022b0:	b7cd                	j	80002292 <either_copyout+0x2a>

00000000800022b2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800022b2:	7179                	addi	sp,sp,-48
    800022b4:	f406                	sd	ra,40(sp)
    800022b6:	f022                	sd	s0,32(sp)
    800022b8:	ec26                	sd	s1,24(sp)
    800022ba:	e84a                	sd	s2,16(sp)
    800022bc:	e44e                	sd	s3,8(sp)
    800022be:	e052                	sd	s4,0(sp)
    800022c0:	1800                	addi	s0,sp,48
    800022c2:	892a                	mv	s2,a0
    800022c4:	84ae                	mv	s1,a1
    800022c6:	89b2                	mv	s3,a2
    800022c8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022ca:	e08ff0ef          	jal	800018d2 <myproc>
  if(user_src){
    800022ce:	cc99                	beqz	s1,800022ec <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800022d0:	86d2                	mv	a3,s4
    800022d2:	864e                	mv	a2,s3
    800022d4:	85ca                	mv	a1,s2
    800022d6:	6d28                	ld	a0,88(a0)
    800022d8:	bf2ff0ef          	jal	800016ca <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022dc:	70a2                	ld	ra,40(sp)
    800022de:	7402                	ld	s0,32(sp)
    800022e0:	64e2                	ld	s1,24(sp)
    800022e2:	6942                	ld	s2,16(sp)
    800022e4:	69a2                	ld	s3,8(sp)
    800022e6:	6a02                	ld	s4,0(sp)
    800022e8:	6145                	addi	sp,sp,48
    800022ea:	8082                	ret
    memmove(dst, (char*)src, len);
    800022ec:	000a061b          	sext.w	a2,s4
    800022f0:	85ce                	mv	a1,s3
    800022f2:	854a                	mv	a0,s2
    800022f4:	a0bfe0ef          	jal	80000cfe <memmove>
    return 0;
    800022f8:	8526                	mv	a0,s1
    800022fa:	b7cd                	j	800022dc <either_copyin+0x2a>

00000000800022fc <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022fc:	715d                	addi	sp,sp,-80
    800022fe:	e486                	sd	ra,72(sp)
    80002300:	e0a2                	sd	s0,64(sp)
    80002302:	fc26                	sd	s1,56(sp)
    80002304:	f84a                	sd	s2,48(sp)
    80002306:	f44e                	sd	s3,40(sp)
    80002308:	f052                	sd	s4,32(sp)
    8000230a:	ec56                	sd	s5,24(sp)
    8000230c:	e85a                	sd	s6,16(sp)
    8000230e:	e45e                	sd	s7,8(sp)
    80002310:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002312:	00005517          	auipc	a0,0x5
    80002316:	d6650513          	addi	a0,a0,-666 # 80007078 <etext+0x78>
    8000231a:	9e0fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000231e:	00011497          	auipc	s1,0x11
    80002322:	80a48493          	addi	s1,s1,-2038 # 80012b28 <proc+0x160>
    80002326:	00016917          	auipc	s2,0x16
    8000232a:	60290913          	addi	s2,s2,1538 # 80018928 <shm_table+0x130>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000232e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002330:	00005997          	auipc	s3,0x5
    80002334:	ed098993          	addi	s3,s3,-304 # 80007200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    80002338:	00005a97          	auipc	s5,0x5
    8000233c:	ed0a8a93          	addi	s5,s5,-304 # 80007208 <etext+0x208>
    printf("\n");
    80002340:	00005a17          	auipc	s4,0x5
    80002344:	d38a0a13          	addi	s4,s4,-712 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002348:	00005b97          	auipc	s7,0x5
    8000234c:	400b8b93          	addi	s7,s7,1024 # 80007748 <states.0>
    80002350:	a829                	j	8000236a <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002352:	ed06a583          	lw	a1,-304(a3)
    80002356:	8556                	mv	a0,s5
    80002358:	9a2fe0ef          	jal	800004fa <printf>
    printf("\n");
    8000235c:	8552                	mv	a0,s4
    8000235e:	99cfe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002362:	17848493          	addi	s1,s1,376
    80002366:	03248263          	beq	s1,s2,8000238a <procdump+0x8e>
    if(p->state == UNUSED)
    8000236a:	86a6                	mv	a3,s1
    8000236c:	eb84a783          	lw	a5,-328(s1)
    80002370:	dbed                	beqz	a5,80002362 <procdump+0x66>
      state = "???";
    80002372:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002374:	fcfb6fe3          	bltu	s6,a5,80002352 <procdump+0x56>
    80002378:	02079713          	slli	a4,a5,0x20
    8000237c:	01d75793          	srli	a5,a4,0x1d
    80002380:	97de                	add	a5,a5,s7
    80002382:	6390                	ld	a2,0(a5)
    80002384:	f679                	bnez	a2,80002352 <procdump+0x56>
      state = "???";
    80002386:	864e                	mv	a2,s3
    80002388:	b7e9                	j	80002352 <procdump+0x56>
  }
}
    8000238a:	60a6                	ld	ra,72(sp)
    8000238c:	6406                	ld	s0,64(sp)
    8000238e:	74e2                	ld	s1,56(sp)
    80002390:	7942                	ld	s2,48(sp)
    80002392:	79a2                	ld	s3,40(sp)
    80002394:	7a02                	ld	s4,32(sp)
    80002396:	6ae2                	ld	s5,24(sp)
    80002398:	6b42                	ld	s6,16(sp)
    8000239a:	6ba2                	ld	s7,8(sp)
    8000239c:	6161                	addi	sp,sp,80
    8000239e:	8082                	ret

00000000800023a0 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800023a0:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800023a4:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800023a8:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800023aa:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800023ac:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800023b0:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800023b4:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800023b8:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800023bc:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800023c0:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800023c4:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800023c8:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800023cc:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800023d0:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800023d4:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800023d8:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800023dc:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800023de:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800023e0:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800023e4:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800023e8:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800023ec:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800023f0:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800023f4:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800023f8:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800023fc:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002400:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002404:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002408:	8082                	ret

000000008000240a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000240a:	1141                	addi	sp,sp,-16
    8000240c:	e406                	sd	ra,8(sp)
    8000240e:	e022                	sd	s0,0(sp)
    80002410:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002412:	00005597          	auipc	a1,0x5
    80002416:	e3658593          	addi	a1,a1,-458 # 80007248 <etext+0x248>
    8000241a:	00016517          	auipc	a0,0x16
    8000241e:	3ae50513          	addi	a0,a0,942 # 800187c8 <tickslock>
    80002422:	f2cfe0ef          	jal	80000b4e <initlock>
}
    80002426:	60a2                	ld	ra,8(sp)
    80002428:	6402                	ld	s0,0(sp)
    8000242a:	0141                	addi	sp,sp,16
    8000242c:	8082                	ret

000000008000242e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000242e:	1141                	addi	sp,sp,-16
    80002430:	e422                	sd	s0,8(sp)
    80002432:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002434:	00003797          	auipc	a5,0x3
    80002438:	53c78793          	addi	a5,a5,1340 # 80005970 <kernelvec>
    8000243c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002440:	6422                	ld	s0,8(sp)
    80002442:	0141                	addi	sp,sp,16
    80002444:	8082                	ret

0000000080002446 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002446:	1141                	addi	sp,sp,-16
    80002448:	e406                	sd	ra,8(sp)
    8000244a:	e022                	sd	s0,0(sp)
    8000244c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000244e:	c84ff0ef          	jal	800018d2 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002452:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002456:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002458:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000245c:	04000737          	lui	a4,0x4000
    80002460:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002462:	0732                	slli	a4,a4,0xc
    80002464:	00004797          	auipc	a5,0x4
    80002468:	b9c78793          	addi	a5,a5,-1124 # 80006000 <_trampoline>
    8000246c:	00004697          	auipc	a3,0x4
    80002470:	b9468693          	addi	a3,a3,-1132 # 80006000 <_trampoline>
    80002474:	8f95                	sub	a5,a5,a3
    80002476:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002478:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000247c:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000247e:	18002773          	csrr	a4,satp
    80002482:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002484:	7138                	ld	a4,96(a0)
    80002486:	653c                	ld	a5,72(a0)
    80002488:	6685                	lui	a3,0x1
    8000248a:	97b6                	add	a5,a5,a3
    8000248c:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000248e:	713c                	ld	a5,96(a0)
    80002490:	00000717          	auipc	a4,0x0
    80002494:	0f870713          	addi	a4,a4,248 # 80002588 <usertrap>
    80002498:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000249a:	713c                	ld	a5,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000249c:	8712                	mv	a4,tp
    8000249e:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024a0:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800024a4:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800024a8:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024ac:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800024b0:	713c                	ld	a5,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800024b2:	6f9c                	ld	a5,24(a5)
    800024b4:	14179073          	csrw	sepc,a5
}
    800024b8:	60a2                	ld	ra,8(sp)
    800024ba:	6402                	ld	s0,0(sp)
    800024bc:	0141                	addi	sp,sp,16
    800024be:	8082                	ret

00000000800024c0 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800024c0:	1101                	addi	sp,sp,-32
    800024c2:	ec06                	sd	ra,24(sp)
    800024c4:	e822                	sd	s0,16(sp)
    800024c6:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800024c8:	bdeff0ef          	jal	800018a6 <cpuid>
    800024cc:	cd11                	beqz	a0,800024e8 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800024ce:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800024d2:	000f4737          	lui	a4,0xf4
    800024d6:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800024da:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800024dc:	14d79073          	csrw	stimecmp,a5
}
    800024e0:	60e2                	ld	ra,24(sp)
    800024e2:	6442                	ld	s0,16(sp)
    800024e4:	6105                	addi	sp,sp,32
    800024e6:	8082                	ret
    800024e8:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024ea:	00016497          	auipc	s1,0x16
    800024ee:	2de48493          	addi	s1,s1,734 # 800187c8 <tickslock>
    800024f2:	8526                	mv	a0,s1
    800024f4:	edafe0ef          	jal	80000bce <acquire>
    ticks++;
    800024f8:	00008517          	auipc	a0,0x8
    800024fc:	fa050513          	addi	a0,a0,-96 # 8000a498 <ticks>
    80002500:	411c                	lw	a5,0(a0)
    80002502:	2785                	addiw	a5,a5,1
    80002504:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002506:	a53ff0ef          	jal	80001f58 <wakeup>
    release(&tickslock);
    8000250a:	8526                	mv	a0,s1
    8000250c:	f5afe0ef          	jal	80000c66 <release>
    80002510:	64a2                	ld	s1,8(sp)
    80002512:	bf75                	j	800024ce <clockintr+0xe>

0000000080002514 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002514:	1101                	addi	sp,sp,-32
    80002516:	ec06                	sd	ra,24(sp)
    80002518:	e822                	sd	s0,16(sp)
    8000251a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000251c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002520:	57fd                	li	a5,-1
    80002522:	17fe                	slli	a5,a5,0x3f
    80002524:	07a5                	addi	a5,a5,9
    80002526:	00f70c63          	beq	a4,a5,8000253e <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000252a:	57fd                	li	a5,-1
    8000252c:	17fe                	slli	a5,a5,0x3f
    8000252e:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002530:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002532:	04f70763          	beq	a4,a5,80002580 <devintr+0x6c>
  }
}
    80002536:	60e2                	ld	ra,24(sp)
    80002538:	6442                	ld	s0,16(sp)
    8000253a:	6105                	addi	sp,sp,32
    8000253c:	8082                	ret
    8000253e:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002540:	4dc030ef          	jal	80005a1c <plic_claim>
    80002544:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002546:	47a9                	li	a5,10
    80002548:	00f50963          	beq	a0,a5,8000255a <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    8000254c:	4785                	li	a5,1
    8000254e:	00f50963          	beq	a0,a5,80002560 <devintr+0x4c>
    return 1;
    80002552:	4505                	li	a0,1
    } else if(irq){
    80002554:	e889                	bnez	s1,80002566 <devintr+0x52>
    80002556:	64a2                	ld	s1,8(sp)
    80002558:	bff9                	j	80002536 <devintr+0x22>
      uartintr();
    8000255a:	c56fe0ef          	jal	800009b0 <uartintr>
    if(irq)
    8000255e:	a819                	j	80002574 <devintr+0x60>
      virtio_disk_intr();
    80002560:	183030ef          	jal	80005ee2 <virtio_disk_intr>
    if(irq)
    80002564:	a801                	j	80002574 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002566:	85a6                	mv	a1,s1
    80002568:	00005517          	auipc	a0,0x5
    8000256c:	ce850513          	addi	a0,a0,-792 # 80007250 <etext+0x250>
    80002570:	f8bfd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002574:	8526                	mv	a0,s1
    80002576:	4c6030ef          	jal	80005a3c <plic_complete>
    return 1;
    8000257a:	4505                	li	a0,1
    8000257c:	64a2                	ld	s1,8(sp)
    8000257e:	bf65                	j	80002536 <devintr+0x22>
    clockintr();
    80002580:	f41ff0ef          	jal	800024c0 <clockintr>
    return 2;
    80002584:	4509                	li	a0,2
    80002586:	bf45                	j	80002536 <devintr+0x22>

0000000080002588 <usertrap>:
{
    80002588:	1101                	addi	sp,sp,-32
    8000258a:	ec06                	sd	ra,24(sp)
    8000258c:	e822                	sd	s0,16(sp)
    8000258e:	e426                	sd	s1,8(sp)
    80002590:	e04a                	sd	s2,0(sp)
    80002592:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002594:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002598:	1007f793          	andi	a5,a5,256
    8000259c:	eba5                	bnez	a5,8000260c <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000259e:	00003797          	auipc	a5,0x3
    800025a2:	3d278793          	addi	a5,a5,978 # 80005970 <kernelvec>
    800025a6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800025aa:	b28ff0ef          	jal	800018d2 <myproc>
    800025ae:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800025b0:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025b2:	14102773          	csrr	a4,sepc
    800025b6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025b8:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800025bc:	47a1                	li	a5,8
    800025be:	04f70d63          	beq	a4,a5,80002618 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    800025c2:	f53ff0ef          	jal	80002514 <devintr>
    800025c6:	892a                	mv	s2,a0
    800025c8:	e945                	bnez	a0,80002678 <usertrap+0xf0>
    800025ca:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800025ce:	47bd                	li	a5,15
    800025d0:	08f70863          	beq	a4,a5,80002660 <usertrap+0xd8>
    800025d4:	14202773          	csrr	a4,scause
    800025d8:	47b5                	li	a5,13
    800025da:	08f70363          	beq	a4,a5,80002660 <usertrap+0xd8>
    800025de:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800025e2:	5890                	lw	a2,48(s1)
    800025e4:	00005517          	auipc	a0,0x5
    800025e8:	cac50513          	addi	a0,a0,-852 # 80007290 <etext+0x290>
    800025ec:	f0ffd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025f0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025f4:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800025f8:	00005517          	auipc	a0,0x5
    800025fc:	cc850513          	addi	a0,a0,-824 # 800072c0 <etext+0x2c0>
    80002600:	efbfd0ef          	jal	800004fa <printf>
    setkilled(p);
    80002604:	8526                	mv	a0,s1
    80002606:	b1bff0ef          	jal	80002120 <setkilled>
    8000260a:	a035                	j	80002636 <usertrap+0xae>
    panic("usertrap: not from user mode");
    8000260c:	00005517          	auipc	a0,0x5
    80002610:	c6450513          	addi	a0,a0,-924 # 80007270 <etext+0x270>
    80002614:	9ccfe0ef          	jal	800007e0 <panic>
    if(killed(p))
    80002618:	b2dff0ef          	jal	80002144 <killed>
    8000261c:	ed15                	bnez	a0,80002658 <usertrap+0xd0>
    p->trapframe->epc += 4;
    8000261e:	70b8                	ld	a4,96(s1)
    80002620:	6f1c                	ld	a5,24(a4)
    80002622:	0791                	addi	a5,a5,4
    80002624:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002626:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000262a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000262e:	10079073          	csrw	sstatus,a5
    syscall();
    80002632:	246000ef          	jal	80002878 <syscall>
  if(killed(p))
    80002636:	8526                	mv	a0,s1
    80002638:	b0dff0ef          	jal	80002144 <killed>
    8000263c:	e139                	bnez	a0,80002682 <usertrap+0xfa>
  prepare_return();
    8000263e:	e09ff0ef          	jal	80002446 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002642:	6ca8                	ld	a0,88(s1)
    80002644:	8131                	srli	a0,a0,0xc
    80002646:	57fd                	li	a5,-1
    80002648:	17fe                	slli	a5,a5,0x3f
    8000264a:	8d5d                	or	a0,a0,a5
}
    8000264c:	60e2                	ld	ra,24(sp)
    8000264e:	6442                	ld	s0,16(sp)
    80002650:	64a2                	ld	s1,8(sp)
    80002652:	6902                	ld	s2,0(sp)
    80002654:	6105                	addi	sp,sp,32
    80002656:	8082                	ret
      kexit(-1);
    80002658:	557d                	li	a0,-1
    8000265a:	9bfff0ef          	jal	80002018 <kexit>
    8000265e:	b7c1                	j	8000261e <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002660:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002664:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002668:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    8000266a:	00163613          	seqz	a2,a2
    8000266e:	6ca8                	ld	a0,88(s1)
    80002670:	ef5fe0ef          	jal	80001564 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002674:	f169                	bnez	a0,80002636 <usertrap+0xae>
    80002676:	b7a5                	j	800025de <usertrap+0x56>
  if(killed(p))
    80002678:	8526                	mv	a0,s1
    8000267a:	acbff0ef          	jal	80002144 <killed>
    8000267e:	c511                	beqz	a0,8000268a <usertrap+0x102>
    80002680:	a011                	j	80002684 <usertrap+0xfc>
    80002682:	4901                	li	s2,0
    kexit(-1);
    80002684:	557d                	li	a0,-1
    80002686:	993ff0ef          	jal	80002018 <kexit>
  if(which_dev == 2)
    8000268a:	4789                	li	a5,2
    8000268c:	faf919e3          	bne	s2,a5,8000263e <usertrap+0xb6>
    yield();
    80002690:	851ff0ef          	jal	80001ee0 <yield>
    80002694:	b76d                	j	8000263e <usertrap+0xb6>

0000000080002696 <kerneltrap>:
{
    80002696:	7179                	addi	sp,sp,-48
    80002698:	f406                	sd	ra,40(sp)
    8000269a:	f022                	sd	s0,32(sp)
    8000269c:	ec26                	sd	s1,24(sp)
    8000269e:	e84a                	sd	s2,16(sp)
    800026a0:	e44e                	sd	s3,8(sp)
    800026a2:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026a4:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026a8:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026ac:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800026b0:	1004f793          	andi	a5,s1,256
    800026b4:	c795                	beqz	a5,800026e0 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026b6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800026ba:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800026bc:	eb85                	bnez	a5,800026ec <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800026be:	e57ff0ef          	jal	80002514 <devintr>
    800026c2:	c91d                	beqz	a0,800026f8 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800026c4:	4789                	li	a5,2
    800026c6:	04f50a63          	beq	a0,a5,8000271a <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026ca:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026ce:	10049073          	csrw	sstatus,s1
}
    800026d2:	70a2                	ld	ra,40(sp)
    800026d4:	7402                	ld	s0,32(sp)
    800026d6:	64e2                	ld	s1,24(sp)
    800026d8:	6942                	ld	s2,16(sp)
    800026da:	69a2                	ld	s3,8(sp)
    800026dc:	6145                	addi	sp,sp,48
    800026de:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026e0:	00005517          	auipc	a0,0x5
    800026e4:	c0850513          	addi	a0,a0,-1016 # 800072e8 <etext+0x2e8>
    800026e8:	8f8fe0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    800026ec:	00005517          	auipc	a0,0x5
    800026f0:	c2450513          	addi	a0,a0,-988 # 80007310 <etext+0x310>
    800026f4:	8ecfe0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026f8:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026fc:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002700:	85ce                	mv	a1,s3
    80002702:	00005517          	auipc	a0,0x5
    80002706:	c2e50513          	addi	a0,a0,-978 # 80007330 <etext+0x330>
    8000270a:	df1fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    8000270e:	00005517          	auipc	a0,0x5
    80002712:	c4a50513          	addi	a0,a0,-950 # 80007358 <etext+0x358>
    80002716:	8cafe0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000271a:	9b8ff0ef          	jal	800018d2 <myproc>
    8000271e:	d555                	beqz	a0,800026ca <kerneltrap+0x34>
    yield();
    80002720:	fc0ff0ef          	jal	80001ee0 <yield>
    80002724:	b75d                	j	800026ca <kerneltrap+0x34>

0000000080002726 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002726:	1101                	addi	sp,sp,-32
    80002728:	ec06                	sd	ra,24(sp)
    8000272a:	e822                	sd	s0,16(sp)
    8000272c:	e426                	sd	s1,8(sp)
    8000272e:	1000                	addi	s0,sp,32
    80002730:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002732:	9a0ff0ef          	jal	800018d2 <myproc>
  switch (n) {
    80002736:	4795                	li	a5,5
    80002738:	0497e163          	bltu	a5,s1,8000277a <argraw+0x54>
    8000273c:	048a                	slli	s1,s1,0x2
    8000273e:	00005717          	auipc	a4,0x5
    80002742:	03a70713          	addi	a4,a4,58 # 80007778 <states.0+0x30>
    80002746:	94ba                	add	s1,s1,a4
    80002748:	409c                	lw	a5,0(s1)
    8000274a:	97ba                	add	a5,a5,a4
    8000274c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000274e:	713c                	ld	a5,96(a0)
    80002750:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002752:	60e2                	ld	ra,24(sp)
    80002754:	6442                	ld	s0,16(sp)
    80002756:	64a2                	ld	s1,8(sp)
    80002758:	6105                	addi	sp,sp,32
    8000275a:	8082                	ret
    return p->trapframe->a1;
    8000275c:	713c                	ld	a5,96(a0)
    8000275e:	7fa8                	ld	a0,120(a5)
    80002760:	bfcd                	j	80002752 <argraw+0x2c>
    return p->trapframe->a2;
    80002762:	713c                	ld	a5,96(a0)
    80002764:	63c8                	ld	a0,128(a5)
    80002766:	b7f5                	j	80002752 <argraw+0x2c>
    return p->trapframe->a3;
    80002768:	713c                	ld	a5,96(a0)
    8000276a:	67c8                	ld	a0,136(a5)
    8000276c:	b7dd                	j	80002752 <argraw+0x2c>
    return p->trapframe->a4;
    8000276e:	713c                	ld	a5,96(a0)
    80002770:	6bc8                	ld	a0,144(a5)
    80002772:	b7c5                	j	80002752 <argraw+0x2c>
    return p->trapframe->a5;
    80002774:	713c                	ld	a5,96(a0)
    80002776:	6fc8                	ld	a0,152(a5)
    80002778:	bfe9                	j	80002752 <argraw+0x2c>
  panic("argraw");
    8000277a:	00005517          	auipc	a0,0x5
    8000277e:	bee50513          	addi	a0,a0,-1042 # 80007368 <etext+0x368>
    80002782:	85efe0ef          	jal	800007e0 <panic>

0000000080002786 <fetchaddr>:
{
    80002786:	1101                	addi	sp,sp,-32
    80002788:	ec06                	sd	ra,24(sp)
    8000278a:	e822                	sd	s0,16(sp)
    8000278c:	e426                	sd	s1,8(sp)
    8000278e:	e04a                	sd	s2,0(sp)
    80002790:	1000                	addi	s0,sp,32
    80002792:	84aa                	mv	s1,a0
    80002794:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002796:	93cff0ef          	jal	800018d2 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000279a:	693c                	ld	a5,80(a0)
    8000279c:	02f4f663          	bgeu	s1,a5,800027c8 <fetchaddr+0x42>
    800027a0:	00848713          	addi	a4,s1,8
    800027a4:	02e7e463          	bltu	a5,a4,800027cc <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800027a8:	46a1                	li	a3,8
    800027aa:	8626                	mv	a2,s1
    800027ac:	85ca                	mv	a1,s2
    800027ae:	6d28                	ld	a0,88(a0)
    800027b0:	f1bfe0ef          	jal	800016ca <copyin>
    800027b4:	00a03533          	snez	a0,a0
    800027b8:	40a00533          	neg	a0,a0
}
    800027bc:	60e2                	ld	ra,24(sp)
    800027be:	6442                	ld	s0,16(sp)
    800027c0:	64a2                	ld	s1,8(sp)
    800027c2:	6902                	ld	s2,0(sp)
    800027c4:	6105                	addi	sp,sp,32
    800027c6:	8082                	ret
    return -1;
    800027c8:	557d                	li	a0,-1
    800027ca:	bfcd                	j	800027bc <fetchaddr+0x36>
    800027cc:	557d                	li	a0,-1
    800027ce:	b7fd                	j	800027bc <fetchaddr+0x36>

00000000800027d0 <fetchstr>:
{
    800027d0:	7179                	addi	sp,sp,-48
    800027d2:	f406                	sd	ra,40(sp)
    800027d4:	f022                	sd	s0,32(sp)
    800027d6:	ec26                	sd	s1,24(sp)
    800027d8:	e84a                	sd	s2,16(sp)
    800027da:	e44e                	sd	s3,8(sp)
    800027dc:	1800                	addi	s0,sp,48
    800027de:	892a                	mv	s2,a0
    800027e0:	84ae                	mv	s1,a1
    800027e2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800027e4:	8eeff0ef          	jal	800018d2 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800027e8:	86ce                	mv	a3,s3
    800027ea:	864a                	mv	a2,s2
    800027ec:	85a6                	mv	a1,s1
    800027ee:	6d28                	ld	a0,88(a0)
    800027f0:	c9dfe0ef          	jal	8000148c <copyinstr>
    800027f4:	00054c63          	bltz	a0,8000280c <fetchstr+0x3c>
  return strlen(buf);
    800027f8:	8526                	mv	a0,s1
    800027fa:	e18fe0ef          	jal	80000e12 <strlen>
}
    800027fe:	70a2                	ld	ra,40(sp)
    80002800:	7402                	ld	s0,32(sp)
    80002802:	64e2                	ld	s1,24(sp)
    80002804:	6942                	ld	s2,16(sp)
    80002806:	69a2                	ld	s3,8(sp)
    80002808:	6145                	addi	sp,sp,48
    8000280a:	8082                	ret
    return -1;
    8000280c:	557d                	li	a0,-1
    8000280e:	bfc5                	j	800027fe <fetchstr+0x2e>

0000000080002810 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002810:	1101                	addi	sp,sp,-32
    80002812:	ec06                	sd	ra,24(sp)
    80002814:	e822                	sd	s0,16(sp)
    80002816:	e426                	sd	s1,8(sp)
    80002818:	1000                	addi	s0,sp,32
    8000281a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000281c:	f0bff0ef          	jal	80002726 <argraw>
    80002820:	c088                	sw	a0,0(s1)
}
    80002822:	60e2                	ld	ra,24(sp)
    80002824:	6442                	ld	s0,16(sp)
    80002826:	64a2                	ld	s1,8(sp)
    80002828:	6105                	addi	sp,sp,32
    8000282a:	8082                	ret

000000008000282c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000282c:	1101                	addi	sp,sp,-32
    8000282e:	ec06                	sd	ra,24(sp)
    80002830:	e822                	sd	s0,16(sp)
    80002832:	e426                	sd	s1,8(sp)
    80002834:	1000                	addi	s0,sp,32
    80002836:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002838:	eefff0ef          	jal	80002726 <argraw>
    8000283c:	e088                	sd	a0,0(s1)
}
    8000283e:	60e2                	ld	ra,24(sp)
    80002840:	6442                	ld	s0,16(sp)
    80002842:	64a2                	ld	s1,8(sp)
    80002844:	6105                	addi	sp,sp,32
    80002846:	8082                	ret

0000000080002848 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002848:	7179                	addi	sp,sp,-48
    8000284a:	f406                	sd	ra,40(sp)
    8000284c:	f022                	sd	s0,32(sp)
    8000284e:	ec26                	sd	s1,24(sp)
    80002850:	e84a                	sd	s2,16(sp)
    80002852:	1800                	addi	s0,sp,48
    80002854:	84ae                	mv	s1,a1
    80002856:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002858:	fd840593          	addi	a1,s0,-40
    8000285c:	fd1ff0ef          	jal	8000282c <argaddr>
  return fetchstr(addr, buf, max);
    80002860:	864a                	mv	a2,s2
    80002862:	85a6                	mv	a1,s1
    80002864:	fd843503          	ld	a0,-40(s0)
    80002868:	f69ff0ef          	jal	800027d0 <fetchstr>
}
    8000286c:	70a2                	ld	ra,40(sp)
    8000286e:	7402                	ld	s0,32(sp)
    80002870:	64e2                	ld	s1,24(sp)
    80002872:	6942                	ld	s2,16(sp)
    80002874:	6145                	addi	sp,sp,48
    80002876:	8082                	ret

0000000080002878 <syscall>:
[SYS_shmdt]    sys_shmdt,
};

void
syscall(void)
{
    80002878:	1101                	addi	sp,sp,-32
    8000287a:	ec06                	sd	ra,24(sp)
    8000287c:	e822                	sd	s0,16(sp)
    8000287e:	e426                	sd	s1,8(sp)
    80002880:	e04a                	sd	s2,0(sp)
    80002882:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002884:	84eff0ef          	jal	800018d2 <myproc>
    80002888:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000288a:	06053903          	ld	s2,96(a0)
    8000288e:	0a893783          	ld	a5,168(s2)
    80002892:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002896:	37fd                	addiw	a5,a5,-1
    80002898:	476d                	li	a4,27
    8000289a:	00f76f63          	bltu	a4,a5,800028b8 <syscall+0x40>
    8000289e:	00369713          	slli	a4,a3,0x3
    800028a2:	00005797          	auipc	a5,0x5
    800028a6:	eee78793          	addi	a5,a5,-274 # 80007790 <syscalls>
    800028aa:	97ba                	add	a5,a5,a4
    800028ac:	639c                	ld	a5,0(a5)
    800028ae:	c789                	beqz	a5,800028b8 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800028b0:	9782                	jalr	a5
    800028b2:	06a93823          	sd	a0,112(s2)
    800028b6:	a829                	j	800028d0 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800028b8:	16048613          	addi	a2,s1,352
    800028bc:	588c                	lw	a1,48(s1)
    800028be:	00005517          	auipc	a0,0x5
    800028c2:	ab250513          	addi	a0,a0,-1358 # 80007370 <etext+0x370>
    800028c6:	c35fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800028ca:	70bc                	ld	a5,96(s1)
    800028cc:	577d                	li	a4,-1
    800028ce:	fbb8                	sd	a4,112(a5)
  }
}
    800028d0:	60e2                	ld	ra,24(sp)
    800028d2:	6442                	ld	s0,16(sp)
    800028d4:	64a2                	ld	s1,8(sp)
    800028d6:	6902                	ld	s2,0(sp)
    800028d8:	6105                	addi	sp,sp,32
    800028da:	8082                	ret

00000000800028dc <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800028dc:	1101                	addi	sp,sp,-32
    800028de:	ec06                	sd	ra,24(sp)
    800028e0:	e822                	sd	s0,16(sp)
    800028e2:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800028e4:	fec40593          	addi	a1,s0,-20
    800028e8:	4501                	li	a0,0
    800028ea:	f27ff0ef          	jal	80002810 <argint>
  kexit(n);
    800028ee:	fec42503          	lw	a0,-20(s0)
    800028f2:	f26ff0ef          	jal	80002018 <kexit>
  return 0;  // not reached
}
    800028f6:	4501                	li	a0,0
    800028f8:	60e2                	ld	ra,24(sp)
    800028fa:	6442                	ld	s0,16(sp)
    800028fc:	6105                	addi	sp,sp,32
    800028fe:	8082                	ret

0000000080002900 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002900:	1141                	addi	sp,sp,-16
    80002902:	e406                	sd	ra,8(sp)
    80002904:	e022                	sd	s0,0(sp)
    80002906:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002908:	fcbfe0ef          	jal	800018d2 <myproc>
}
    8000290c:	5908                	lw	a0,48(a0)
    8000290e:	60a2                	ld	ra,8(sp)
    80002910:	6402                	ld	s0,0(sp)
    80002912:	0141                	addi	sp,sp,16
    80002914:	8082                	ret

0000000080002916 <sys_fork>:

uint64
sys_fork(void)
{
    80002916:	1141                	addi	sp,sp,-16
    80002918:	e406                	sd	ra,8(sp)
    8000291a:	e022                	sd	s0,0(sp)
    8000291c:	0800                	addi	s0,sp,16
  return kfork();
    8000291e:	b48ff0ef          	jal	80001c66 <kfork>
}
    80002922:	60a2                	ld	ra,8(sp)
    80002924:	6402                	ld	s0,0(sp)
    80002926:	0141                	addi	sp,sp,16
    80002928:	8082                	ret

000000008000292a <sys_wait>:

uint64
sys_wait(void)
{
    8000292a:	1101                	addi	sp,sp,-32
    8000292c:	ec06                	sd	ra,24(sp)
    8000292e:	e822                	sd	s0,16(sp)
    80002930:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002932:	fe840593          	addi	a1,s0,-24
    80002936:	4501                	li	a0,0
    80002938:	ef5ff0ef          	jal	8000282c <argaddr>
  return kwait(p);
    8000293c:	fe843503          	ld	a0,-24(s0)
    80002940:	82fff0ef          	jal	8000216e <kwait>
}
    80002944:	60e2                	ld	ra,24(sp)
    80002946:	6442                	ld	s0,16(sp)
    80002948:	6105                	addi	sp,sp,32
    8000294a:	8082                	ret

000000008000294c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000294c:	7179                	addi	sp,sp,-48
    8000294e:	f406                	sd	ra,40(sp)
    80002950:	f022                	sd	s0,32(sp)
    80002952:	ec26                	sd	s1,24(sp)
    80002954:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002956:	fd840593          	addi	a1,s0,-40
    8000295a:	4501                	li	a0,0
    8000295c:	eb5ff0ef          	jal	80002810 <argint>
  argint(1, &t);
    80002960:	fdc40593          	addi	a1,s0,-36
    80002964:	4505                	li	a0,1
    80002966:	eabff0ef          	jal	80002810 <argint>
  addr = myproc()->sz;
    8000296a:	f69fe0ef          	jal	800018d2 <myproc>
    8000296e:	6924                	ld	s1,80(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002970:	fdc42703          	lw	a4,-36(s0)
    80002974:	4785                	li	a5,1
    80002976:	02f70763          	beq	a4,a5,800029a4 <sys_sbrk+0x58>
    8000297a:	fd842783          	lw	a5,-40(s0)
    8000297e:	0207c363          	bltz	a5,800029a4 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002982:	97a6                	add	a5,a5,s1
    80002984:	0297ee63          	bltu	a5,s1,800029c0 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002988:	02000737          	lui	a4,0x2000
    8000298c:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    8000298e:	0736                	slli	a4,a4,0xd
    80002990:	02f76a63          	bltu	a4,a5,800029c4 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002994:	f3ffe0ef          	jal	800018d2 <myproc>
    80002998:	fd842703          	lw	a4,-40(s0)
    8000299c:	693c                	ld	a5,80(a0)
    8000299e:	97ba                	add	a5,a5,a4
    800029a0:	e93c                	sd	a5,80(a0)
    800029a2:	a039                	j	800029b0 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    800029a4:	fd842503          	lw	a0,-40(s0)
    800029a8:	a5cff0ef          	jal	80001c04 <growproc>
    800029ac:	00054863          	bltz	a0,800029bc <sys_sbrk+0x70>
  }
  return addr;
}
    800029b0:	8526                	mv	a0,s1
    800029b2:	70a2                	ld	ra,40(sp)
    800029b4:	7402                	ld	s0,32(sp)
    800029b6:	64e2                	ld	s1,24(sp)
    800029b8:	6145                	addi	sp,sp,48
    800029ba:	8082                	ret
      return -1;
    800029bc:	54fd                	li	s1,-1
    800029be:	bfcd                	j	800029b0 <sys_sbrk+0x64>
      return -1;
    800029c0:	54fd                	li	s1,-1
    800029c2:	b7fd                	j	800029b0 <sys_sbrk+0x64>
      return -1;
    800029c4:	54fd                	li	s1,-1
    800029c6:	b7ed                	j	800029b0 <sys_sbrk+0x64>

00000000800029c8 <sys_pause>:

uint64
sys_pause(void)
{
    800029c8:	7139                	addi	sp,sp,-64
    800029ca:	fc06                	sd	ra,56(sp)
    800029cc:	f822                	sd	s0,48(sp)
    800029ce:	f04a                	sd	s2,32(sp)
    800029d0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800029d2:	fcc40593          	addi	a1,s0,-52
    800029d6:	4501                	li	a0,0
    800029d8:	e39ff0ef          	jal	80002810 <argint>
  if(n < 0)
    800029dc:	fcc42783          	lw	a5,-52(s0)
    800029e0:	0607c763          	bltz	a5,80002a4e <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    800029e4:	00016517          	auipc	a0,0x16
    800029e8:	de450513          	addi	a0,a0,-540 # 800187c8 <tickslock>
    800029ec:	9e2fe0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    800029f0:	00008917          	auipc	s2,0x8
    800029f4:	aa892903          	lw	s2,-1368(s2) # 8000a498 <ticks>
  while(ticks - ticks0 < n){
    800029f8:	fcc42783          	lw	a5,-52(s0)
    800029fc:	cf8d                	beqz	a5,80002a36 <sys_pause+0x6e>
    800029fe:	f426                	sd	s1,40(sp)
    80002a00:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a02:	00016997          	auipc	s3,0x16
    80002a06:	dc698993          	addi	s3,s3,-570 # 800187c8 <tickslock>
    80002a0a:	00008497          	auipc	s1,0x8
    80002a0e:	a8e48493          	addi	s1,s1,-1394 # 8000a498 <ticks>
    if(killed(myproc())){
    80002a12:	ec1fe0ef          	jal	800018d2 <myproc>
    80002a16:	f2eff0ef          	jal	80002144 <killed>
    80002a1a:	ed0d                	bnez	a0,80002a54 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002a1c:	85ce                	mv	a1,s3
    80002a1e:	8526                	mv	a0,s1
    80002a20:	cecff0ef          	jal	80001f0c <sleep>
  while(ticks - ticks0 < n){
    80002a24:	409c                	lw	a5,0(s1)
    80002a26:	412787bb          	subw	a5,a5,s2
    80002a2a:	fcc42703          	lw	a4,-52(s0)
    80002a2e:	fee7e2e3          	bltu	a5,a4,80002a12 <sys_pause+0x4a>
    80002a32:	74a2                	ld	s1,40(sp)
    80002a34:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a36:	00016517          	auipc	a0,0x16
    80002a3a:	d9250513          	addi	a0,a0,-622 # 800187c8 <tickslock>
    80002a3e:	a28fe0ef          	jal	80000c66 <release>
  return 0;
    80002a42:	4501                	li	a0,0
}
    80002a44:	70e2                	ld	ra,56(sp)
    80002a46:	7442                	ld	s0,48(sp)
    80002a48:	7902                	ld	s2,32(sp)
    80002a4a:	6121                	addi	sp,sp,64
    80002a4c:	8082                	ret
    n = 0;
    80002a4e:	fc042623          	sw	zero,-52(s0)
    80002a52:	bf49                	j	800029e4 <sys_pause+0x1c>
      release(&tickslock);
    80002a54:	00016517          	auipc	a0,0x16
    80002a58:	d7450513          	addi	a0,a0,-652 # 800187c8 <tickslock>
    80002a5c:	a0afe0ef          	jal	80000c66 <release>
      return -1;
    80002a60:	557d                	li	a0,-1
    80002a62:	74a2                	ld	s1,40(sp)
    80002a64:	69e2                	ld	s3,24(sp)
    80002a66:	bff9                	j	80002a44 <sys_pause+0x7c>

0000000080002a68 <sys_kill>:

uint64
sys_kill(void)
{
    80002a68:	1101                	addi	sp,sp,-32
    80002a6a:	ec06                	sd	ra,24(sp)
    80002a6c:	e822                	sd	s0,16(sp)
    80002a6e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a70:	fec40593          	addi	a1,s0,-20
    80002a74:	4501                	li	a0,0
    80002a76:	d9bff0ef          	jal	80002810 <argint>
  return kkill(pid);
    80002a7a:	fec42503          	lw	a0,-20(s0)
    80002a7e:	e3cff0ef          	jal	800020ba <kkill>
}
    80002a82:	60e2                	ld	ra,24(sp)
    80002a84:	6442                	ld	s0,16(sp)
    80002a86:	6105                	addi	sp,sp,32
    80002a88:	8082                	ret

0000000080002a8a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a8a:	1101                	addi	sp,sp,-32
    80002a8c:	ec06                	sd	ra,24(sp)
    80002a8e:	e822                	sd	s0,16(sp)
    80002a90:	e426                	sd	s1,8(sp)
    80002a92:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a94:	00016517          	auipc	a0,0x16
    80002a98:	d3450513          	addi	a0,a0,-716 # 800187c8 <tickslock>
    80002a9c:	932fe0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80002aa0:	00008497          	auipc	s1,0x8
    80002aa4:	9f84a483          	lw	s1,-1544(s1) # 8000a498 <ticks>
  release(&tickslock);
    80002aa8:	00016517          	auipc	a0,0x16
    80002aac:	d2050513          	addi	a0,a0,-736 # 800187c8 <tickslock>
    80002ab0:	9b6fe0ef          	jal	80000c66 <release>
  return xticks;
}
    80002ab4:	02049513          	slli	a0,s1,0x20
    80002ab8:	9101                	srli	a0,a0,0x20
    80002aba:	60e2                	ld	ra,24(sp)
    80002abc:	6442                	ld	s0,16(sp)
    80002abe:	64a2                	ld	s1,8(sp)
    80002ac0:	6105                	addi	sp,sp,32
    80002ac2:	8082                	ret

0000000080002ac4 <sys_getprocinfo>:

uint64
sys_getprocinfo(void)
{
    80002ac4:	1101                	addi	sp,sp,-32
    80002ac6:	ec06                	sd	ra,24(sp)
    80002ac8:	e822                	sd	s0,16(sp)
    80002aca:	e426                	sd	s1,8(sp)
    80002acc:	e04a                	sd	s2,0(sp)
    80002ace:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002ad0:	e03fe0ef          	jal	800018d2 <myproc>
    80002ad4:	84aa                	mv	s1,a0
  uint64 pid_addr  = p->trapframe->a0;
    80002ad6:	713c                	ld	a5,96(a0)
  uint64 prio_addr = p->trapframe->a1;
    80002ad8:	0787b903          	ld	s2,120(a5)

  if(copyout(p->pagetable, pid_addr,
    80002adc:	4691                	li	a3,4
    80002ade:	03050613          	addi	a2,a0,48
    80002ae2:	7bac                	ld	a1,112(a5)
    80002ae4:	6d28                	ld	a0,88(a0)
    80002ae6:	b01fe0ef          	jal	800015e6 <copyout>
    80002aea:	87aa                	mv	a5,a0
             (char*)&p->pid, sizeof(p->pid)) < 0)
    return -1;
    80002aec:	557d                	li	a0,-1
  if(copyout(p->pagetable, pid_addr,
    80002aee:	0007ca63          	bltz	a5,80002b02 <sys_getprocinfo+0x3e>
  if(copyout(p->pagetable, prio_addr,
    80002af2:	4691                	li	a3,4
    80002af4:	17048613          	addi	a2,s1,368
    80002af8:	85ca                	mv	a1,s2
    80002afa:	6ca8                	ld	a0,88(s1)
    80002afc:	aebfe0ef          	jal	800015e6 <copyout>
    80002b00:	957d                	srai	a0,a0,0x3f
             (char*)&p->priority, sizeof(p->priority)) < 0)
    return -1;
  return 0;
}
    80002b02:	60e2                	ld	ra,24(sp)
    80002b04:	6442                	ld	s0,16(sp)
    80002b06:	64a2                	ld	s1,8(sp)
    80002b08:	6902                	ld	s2,0(sp)
    80002b0a:	6105                	addi	sp,sp,32
    80002b0c:	8082                	ret

0000000080002b0e <sys_setpriority>:

uint64
sys_setpriority(void)
{
    80002b0e:	1141                	addi	sp,sp,-16
    80002b10:	e406                	sd	ra,8(sp)
    80002b12:	e022                	sd	s0,0(sp)
    80002b14:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b16:	dbdfe0ef          	jal	800018d2 <myproc>
    80002b1a:	87aa                	mv	a5,a0
  int prio = (int)p->trapframe->a0;
    80002b1c:	7138                	ld	a4,96(a0)
    80002b1e:	5b38                	lw	a4,112(a4)
  if(prio < 0 || prio > 19)
    80002b20:	46cd                	li	a3,19
    return -1;
    80002b22:	557d                	li	a0,-1
  if(prio < 0 || prio > 19)
    80002b24:	00e6e563          	bltu	a3,a4,80002b2e <sys_setpriority+0x20>
  p->priority = prio;
    80002b28:	16e7a823          	sw	a4,368(a5)
  return 0;
    80002b2c:	4501                	li	a0,0
}
    80002b2e:	60a2                	ld	ra,8(sp)
    80002b30:	6402                	ld	s0,0(sp)
    80002b32:	0141                	addi	sp,sp,16
    80002b34:	8082                	ret

0000000080002b36 <sys_thread_create>:
#include "spinlock.h" 
#include "proc.h"

extern struct proc proc[NPROC];

uint64 sys_thread_create(void){
    80002b36:	7139                	addi	sp,sp,-64
    80002b38:	fc06                	sd	ra,56(sp)
    80002b3a:	f822                	sd	s0,48(sp)
    80002b3c:	f426                	sd	s1,40(sp)
    80002b3e:	f04a                	sd	s2,32(sp)
    80002b40:	e456                	sd	s5,8(sp)
    80002b42:	0080                	addi	s0,sp,64
    struct proc *parent = myproc();
    80002b44:	d8ffe0ef          	jal	800018d2 <myproc>
    80002b48:	8aaa                	mv	s5,a0

    uint64 fn = parent->trapframe->a0;
    80002b4a:	713c                	ld	a5,96(a0)
    80002b4c:	0707b903          	ld	s2,112(a5)
    uint64 arg = parent->trapframe->a1;
    80002b50:	7fa4                	ld	s1,120(a5)

    struct proc *np;

    if((np = kallocproc()) ==0){
    80002b52:	84eff0ef          	jal	80001ba0 <kallocproc>
    80002b56:	cd45                	beqz	a0,80002c0e <sys_thread_create+0xd8>
    80002b58:	ec4e                	sd	s3,24(sp)
    80002b5a:	e852                	sd	s4,16(sp)
    80002b5c:	89aa                	mv	s3,a0
        return -1;
    }

    np->pagetable = parent->pagetable;
    80002b5e:	058ab783          	ld	a5,88(s5)
    80002b62:	ed3c                	sd	a5,88(a0)
    np->sz = parent->sz;
    80002b64:	050ab783          	ld	a5,80(s5)
    80002b68:	e93c                	sd	a5,80(a0)

    np->is_thread = 1;
    80002b6a:	4785                	li	a5,1
    80002b6c:	d95c                	sw	a5,52(a0)
    np->thread_parent = parent->pid;
    80002b6e:	030aa783          	lw	a5,48(s5)
    80002b72:	dd1c                	sw	a5,56(a0)

    *(np->trapframe) = *(parent->trapframe);
    80002b74:	060ab683          	ld	a3,96(s5)
    80002b78:	87b6                	mv	a5,a3
    80002b7a:	7138                	ld	a4,96(a0)
    80002b7c:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    80002b80:	0007b803          	ld	a6,0(a5)
    80002b84:	6788                	ld	a0,8(a5)
    80002b86:	6b8c                	ld	a1,16(a5)
    80002b88:	6f90                	ld	a2,24(a5)
    80002b8a:	01073023          	sd	a6,0(a4)
    80002b8e:	e708                	sd	a0,8(a4)
    80002b90:	eb0c                	sd	a1,16(a4)
    80002b92:	ef10                	sd	a2,24(a4)
    80002b94:	02078793          	addi	a5,a5,32
    80002b98:	02070713          	addi	a4,a4,32
    80002b9c:	fed792e3          	bne	a5,a3,80002b80 <sys_thread_create+0x4a>
    np->trapframe->epc = fn;   // thread entry point (RISC-V: epc not eip)
    80002ba0:	0609b783          	ld	a5,96(s3)
    80002ba4:	0127bc23          	sd	s2,24(a5)
    np->trapframe->a0  = arg;  // argument passed in register a0
    80002ba8:	0609b783          	ld	a5,96(s3)
    80002bac:	fba4                	sd	s1,112(a5)

    // Inherit open files and working directory from parent
    for (int i = 0; i < NOFILE; i++)
    80002bae:	0d8a8493          	addi	s1,s5,216
    80002bb2:	0d898913          	addi	s2,s3,216
    80002bb6:	158a8a13          	addi	s4,s5,344
    80002bba:	a029                	j	80002bc4 <sys_thread_create+0x8e>
    80002bbc:	04a1                	addi	s1,s1,8
    80002bbe:	0921                	addi	s2,s2,8
    80002bc0:	01448963          	beq	s1,s4,80002bd2 <sys_thread_create+0x9c>
        if (parent->ofile[i])
    80002bc4:	6088                	ld	a0,0(s1)
    80002bc6:	d97d                	beqz	a0,80002bbc <sys_thread_create+0x86>
            np->ofile[i] = filedup(parent->ofile[i]);
    80002bc8:	1e3010ef          	jal	800045aa <filedup>
    80002bcc:	00a93023          	sd	a0,0(s2)
    80002bd0:	b7f5                	j	80002bbc <sys_thread_create+0x86>
    np->cwd = idup(parent->cwd);
    80002bd2:	158ab503          	ld	a0,344(s5)
    80002bd6:	3ef000ef          	jal	800037c4 <idup>
    80002bda:	14a9bc23          	sd	a0,344(s3)

    safestrcpy(np->name, parent->name, sizeof(parent->name));
    80002bde:	4641                	li	a2,16
    80002be0:	160a8593          	addi	a1,s5,352
    80002be4:	16098513          	addi	a0,s3,352
    80002be8:	9f8fe0ef          	jal	80000de0 <safestrcpy>

    // kallocproc() returns with np->lock held.
    np->state = RUNNABLE;
    80002bec:	478d                	li	a5,3
    80002bee:	00f9ac23          	sw	a5,24(s3)
    release(&np->lock);
    80002bf2:	854e                	mv	a0,s3
    80002bf4:	872fe0ef          	jal	80000c66 <release>

    return np->pid;  // return tid to caller
    80002bf8:	0309a503          	lw	a0,48(s3)
    80002bfc:	69e2                	ld	s3,24(sp)
    80002bfe:	6a42                	ld	s4,16(sp)
}
    80002c00:	70e2                	ld	ra,56(sp)
    80002c02:	7442                	ld	s0,48(sp)
    80002c04:	74a2                	ld	s1,40(sp)
    80002c06:	7902                	ld	s2,32(sp)
    80002c08:	6aa2                	ld	s5,8(sp)
    80002c0a:	6121                	addi	sp,sp,64
    80002c0c:	8082                	ret
        return -1;
    80002c0e:	557d                	li	a0,-1
    80002c10:	bfc5                	j	80002c00 <sys_thread_create+0xca>

0000000080002c12 <sys_thread_join>:

uint64
sys_thread_join(void)
{
    80002c12:	715d                	addi	sp,sp,-80
    80002c14:	e486                	sd	ra,72(sp)
    80002c16:	e0a2                	sd	s0,64(sp)
    80002c18:	fc26                	sd	s1,56(sp)
    80002c1a:	f84a                	sd	s2,48(sp)
    80002c1c:	f44e                	sd	s3,40(sp)
    80002c1e:	f052                	sd	s4,32(sp)
    80002c20:	ec56                	sd	s5,24(sp)
    80002c22:	e85a                	sd	s6,16(sp)
    80002c24:	e45e                	sd	s7,8(sp)
    80002c26:	0880                	addi	s0,sp,80
  struct proc *p = myproc();
    80002c28:	cabfe0ef          	jal	800018d2 <myproc>

  // Read tid from trapframe register a0
  int tid = (int)p->trapframe->a0;
    80002c2c:	713c                	ld	a5,96(a0)
    80002c2e:	0707a903          	lw	s2,112(a5)
  // Search the process table for the thread
  struct proc *target;
  int found;

  for (;;) {
    found = 0;
    80002c32:	4b81                	li	s7,0
      acquire(&target->lock);

      if (target->pid == tid && target->is_thread) {
        found = 1;

        if (target->state == ZOMBIE) {
    80002c34:	4a95                	li	s5,5
        found = 1;
    80002c36:	4b05                	li	s6,1
    for (target = proc; target < &proc[NPROC]; target++) {
    80002c38:	00016997          	auipc	s3,0x16
    80002c3c:	b9098993          	addi	s3,s3,-1136 # 800187c8 <tickslock>
    found = 0;
    80002c40:	8a5e                	mv	s4,s7
    for (target = proc; target < &proc[NPROC]; target++) {
    80002c42:	00010497          	auipc	s1,0x10
    80002c46:	d8648493          	addi	s1,s1,-634 # 800129c8 <proc>
    80002c4a:	a815                	j	80002c7e <sys_thread_join+0x6c>
          // Thread finished — reap it
          kfreeproc(target);         // frees kstack, trapframe, etc.
    80002c4c:	8526                	mv	a0,s1
    80002c4e:	f67fe0ef          	jal	80001bb4 <kfreeproc>
          release(&target->lock);
    80002c52:	8526                	mv	a0,s1
    80002c54:	812fe0ef          	jal	80000c66 <release>
          return 0;
    80002c58:	4501                	li	a0,0
      return -1;  // no thread with that TID exists

    // Thread exists but hasn't exited yet — yield and retry
    yield();
  }
    80002c5a:	60a6                	ld	ra,72(sp)
    80002c5c:	6406                	ld	s0,64(sp)
    80002c5e:	74e2                	ld	s1,56(sp)
    80002c60:	7942                	ld	s2,48(sp)
    80002c62:	79a2                	ld	s3,40(sp)
    80002c64:	7a02                	ld	s4,32(sp)
    80002c66:	6ae2                	ld	s5,24(sp)
    80002c68:	6b42                	ld	s6,16(sp)
    80002c6a:	6ba2                	ld	s7,8(sp)
    80002c6c:	6161                	addi	sp,sp,80
    80002c6e:	8082                	ret
      release(&target->lock);
    80002c70:	8526                	mv	a0,s1
    80002c72:	ff5fd0ef          	jal	80000c66 <release>
    for (target = proc; target < &proc[NPROC]; target++) {
    80002c76:	17848493          	addi	s1,s1,376
    80002c7a:	01348f63          	beq	s1,s3,80002c98 <sys_thread_join+0x86>
      acquire(&target->lock);
    80002c7e:	8526                	mv	a0,s1
    80002c80:	f4ffd0ef          	jal	80000bce <acquire>
      if (target->pid == tid && target->is_thread) {
    80002c84:	589c                	lw	a5,48(s1)
    80002c86:	ff2795e3          	bne	a5,s2,80002c70 <sys_thread_join+0x5e>
    80002c8a:	58dc                	lw	a5,52(s1)
    80002c8c:	d3f5                	beqz	a5,80002c70 <sys_thread_join+0x5e>
        if (target->state == ZOMBIE) {
    80002c8e:	4c9c                	lw	a5,24(s1)
    80002c90:	fb578ee3          	beq	a5,s5,80002c4c <sys_thread_join+0x3a>
        found = 1;
    80002c94:	8a5a                	mv	s4,s6
    80002c96:	bfe9                	j	80002c70 <sys_thread_join+0x5e>
    if (!found)
    80002c98:	000a0563          	beqz	s4,80002ca2 <sys_thread_join+0x90>
    yield();
    80002c9c:	a44ff0ef          	jal	80001ee0 <yield>
    found = 0;
    80002ca0:	b745                	j	80002c40 <sys_thread_join+0x2e>
      return -1;  // no thread with that TID exists
    80002ca2:	557d                	li	a0,-1
    80002ca4:	bf5d                	j	80002c5a <sys_thread_join+0x48>

0000000080002ca6 <shminit>:
#include "shm.h"

struct spinlock shm_lock;         // Protects the table itself
struct shm_table_entry shm_table[SHM_MAX];

void shminit(void) {
    80002ca6:	7179                	addi	sp,sp,-48
    80002ca8:	f406                	sd	ra,40(sp)
    80002caa:	f022                	sd	s0,32(sp)
    80002cac:	ec26                	sd	s1,24(sp)
    80002cae:	e84a                	sd	s2,16(sp)
    80002cb0:	e44e                	sd	s3,8(sp)
    80002cb2:	1800                	addi	s0,sp,48
  initlock(&shm_lock, "shm_table");
    80002cb4:	00004597          	auipc	a1,0x4
    80002cb8:	6dc58593          	addi	a1,a1,1756 # 80007390 <etext+0x390>
    80002cbc:	00016517          	auipc	a0,0x16
    80002cc0:	b2450513          	addi	a0,a0,-1244 # 800187e0 <shm_lock>
    80002cc4:	e8bfd0ef          	jal	80000b4e <initlock>

  for (int i = 0; i < SHM_MAX; i++) {
    80002cc8:	00016497          	auipc	s1,0x16
    80002ccc:	b4848493          	addi	s1,s1,-1208 # 80018810 <shm_table+0x18>
    80002cd0:	00016997          	auipc	s3,0x16
    80002cd4:	74098993          	addi	s3,s3,1856 # 80019410 <bcache+0x18>
    initlock(&shm_table[i].lock, "shm_entry");
    80002cd8:	00004917          	auipc	s2,0x4
    80002cdc:	6c890913          	addi	s2,s2,1736 # 800073a0 <etext+0x3a0>
    80002ce0:	85ca                	mv	a1,s2
    80002ce2:	8526                	mv	a0,s1
    80002ce4:	e6bfd0ef          	jal	80000b4e <initlock>
    shm_table[i].key = 0;
    80002ce8:	fe04a423          	sw	zero,-24(s1)
    shm_table[i].pa = 0;
    80002cec:	fe04b823          	sd	zero,-16(s1)
    shm_table[i].ref_count = 0;
    80002cf0:	fe04ac23          	sw	zero,-8(s1)
  for (int i = 0; i < SHM_MAX; i++) {
    80002cf4:	03048493          	addi	s1,s1,48
    80002cf8:	ff3494e3          	bne	s1,s3,80002ce0 <shminit+0x3a>
  }
}
    80002cfc:	70a2                	ld	ra,40(sp)
    80002cfe:	7402                	ld	s0,32(sp)
    80002d00:	64e2                	ld	s1,24(sp)
    80002d02:	6942                	ld	s2,16(sp)
    80002d04:	69a2                	ld	s3,8(sp)
    80002d06:	6145                	addi	sp,sp,48
    80002d08:	8082                	ret

0000000080002d0a <sys_shmcreate>:

uint64 sys_shmcreate(void) {
    80002d0a:	7179                	addi	sp,sp,-48
    80002d0c:	f406                	sd	ra,40(sp)
    80002d0e:	f022                	sd	s0,32(sp)
    80002d10:	ec26                	sd	s1,24(sp)
    80002d12:	1800                	addi	s0,sp,48
  int key;
  argint(0, &key);
    80002d14:	fdc40593          	addi	a1,s0,-36
    80002d18:	4501                	li	a0,0
    80002d1a:	af7ff0ef          	jal	80002810 <argint>

  acquire(&shm_lock);
    80002d1e:	00016517          	auipc	a0,0x16
    80002d22:	ac250513          	addi	a0,a0,-1342 # 800187e0 <shm_lock>
    80002d26:	ea9fd0ef          	jal	80000bce <acquire>

  // Check if segment already exists
  for (int i = 0; i < SHM_MAX; i++) {
    if (shm_table[i].key == key && shm_table[i].pa != 0) {
    80002d2a:	fdc42683          	lw	a3,-36(s0)
    80002d2e:	00016797          	auipc	a5,0x16
    80002d32:	aca78793          	addi	a5,a5,-1334 # 800187f8 <shm_table>
  for (int i = 0; i < SHM_MAX; i++) {
    80002d36:	4481                	li	s1,0
    80002d38:	04000613          	li	a2,64
    80002d3c:	a031                	j	80002d48 <sys_shmcreate+0x3e>
    80002d3e:	2485                	addiw	s1,s1,1
    80002d40:	03078793          	addi	a5,a5,48
    80002d44:	02c48363          	beq	s1,a2,80002d6a <sys_shmcreate+0x60>
    if (shm_table[i].key == key && shm_table[i].pa != 0) {
    80002d48:	4398                	lw	a4,0(a5)
    80002d4a:	fed71ae3          	bne	a4,a3,80002d3e <sys_shmcreate+0x34>
    80002d4e:	6798                	ld	a4,8(a5)
    80002d50:	d77d                	beqz	a4,80002d3e <sys_shmcreate+0x34>
      release(&shm_lock);
    80002d52:	00016517          	auipc	a0,0x16
    80002d56:	a8e50513          	addi	a0,a0,-1394 # 800187e0 <shm_lock>
    80002d5a:	f0dfd0ef          	jal	80000c66 <release>
      return i; // Return shmid
    80002d5e:	8526                	mv	a0,s1
    }
  }

  release(&shm_lock);
  return -1; // Table full
}
    80002d60:	70a2                	ld	ra,40(sp)
    80002d62:	7402                	ld	s0,32(sp)
    80002d64:	64e2                	ld	s1,24(sp)
    80002d66:	6145                	addi	sp,sp,48
    80002d68:	8082                	ret
    80002d6a:	00016797          	auipc	a5,0x16
    80002d6e:	a9678793          	addi	a5,a5,-1386 # 80018800 <shm_table+0x8>
  for (int i = 0; i < SHM_MAX; i++) {
    80002d72:	4481                	li	s1,0
    80002d74:	04000693          	li	a3,64
    if (shm_table[i].pa == 0) {
    80002d78:	6398                	ld	a4,0(a5)
    80002d7a:	cf11                	beqz	a4,80002d96 <sys_shmcreate+0x8c>
  for (int i = 0; i < SHM_MAX; i++) {
    80002d7c:	2485                	addiw	s1,s1,1
    80002d7e:	03078793          	addi	a5,a5,48
    80002d82:	fed49be3          	bne	s1,a3,80002d78 <sys_shmcreate+0x6e>
  release(&shm_lock);
    80002d86:	00016517          	auipc	a0,0x16
    80002d8a:	a5a50513          	addi	a0,a0,-1446 # 800187e0 <shm_lock>
    80002d8e:	ed9fd0ef          	jal	80000c66 <release>
  return -1; // Table full
    80002d92:	557d                	li	a0,-1
    80002d94:	b7f1                	j	80002d60 <sys_shmcreate+0x56>
    80002d96:	e84a                	sd	s2,16(sp)
      uint64 pa = (uint64)kalloc();
    80002d98:	d67fd0ef          	jal	80000afe <kalloc>
    80002d9c:	892a                	mv	s2,a0
      if (pa == 0) {
    80002d9e:	cd15                	beqz	a0,80002dda <sys_shmcreate+0xd0>
      memset((void*)pa, 0, PGSIZE);
    80002da0:	6605                	lui	a2,0x1
    80002da2:	4581                	li	a1,0
    80002da4:	efffd0ef          	jal	80000ca2 <memset>
      shm_table[i].key = key;
    80002da8:	00149713          	slli	a4,s1,0x1
    80002dac:	9726                	add	a4,a4,s1
    80002dae:	0712                	slli	a4,a4,0x4
    80002db0:	00016797          	auipc	a5,0x16
    80002db4:	a4878793          	addi	a5,a5,-1464 # 800187f8 <shm_table>
    80002db8:	97ba                	add	a5,a5,a4
    80002dba:	fdc42703          	lw	a4,-36(s0)
    80002dbe:	c398                	sw	a4,0(a5)
      shm_table[i].pa = pa;
    80002dc0:	0127b423          	sd	s2,8(a5)
      shm_table[i].ref_count = 0; // It will be incremented on shmat
    80002dc4:	0007a823          	sw	zero,16(a5)
      release(&shm_lock);
    80002dc8:	00016517          	auipc	a0,0x16
    80002dcc:	a1850513          	addi	a0,a0,-1512 # 800187e0 <shm_lock>
    80002dd0:	e97fd0ef          	jal	80000c66 <release>
      return i; // Return shmid
    80002dd4:	8526                	mv	a0,s1
    80002dd6:	6942                	ld	s2,16(sp)
    80002dd8:	b761                	j	80002d60 <sys_shmcreate+0x56>
        release(&shm_lock);
    80002dda:	00016517          	auipc	a0,0x16
    80002dde:	a0650513          	addi	a0,a0,-1530 # 800187e0 <shm_lock>
    80002de2:	e85fd0ef          	jal	80000c66 <release>
        return -1; // Out of memory
    80002de6:	557d                	li	a0,-1
    80002de8:	6942                	ld	s2,16(sp)
    80002dea:	bf9d                	j	80002d60 <sys_shmcreate+0x56>

0000000080002dec <sys_shmat>:

uint64 sys_shmat(void) {
    80002dec:	7179                	addi	sp,sp,-48
    80002dee:	f406                	sd	ra,40(sp)
    80002df0:	f022                	sd	s0,32(sp)
    80002df2:	ec26                	sd	s1,24(sp)
    80002df4:	1800                	addi	s0,sp,48
  int shmid;
  argint(0, &shmid);
    80002df6:	fdc40593          	addi	a1,s0,-36
    80002dfa:	4501                	li	a0,0
    80002dfc:	a15ff0ef          	jal	80002810 <argint>

  if (shmid < 0 || shmid >= SHM_MAX) return -1;
    80002e00:	fdc42703          	lw	a4,-36(s0)
    80002e04:	03f00793          	li	a5,63
    80002e08:	54fd                	li	s1,-1
    80002e0a:	08e7ed63          	bltu	a5,a4,80002ea4 <sys_shmat+0xb8>

  acquire(&shm_lock);
    80002e0e:	00016517          	auipc	a0,0x16
    80002e12:	9d250513          	addi	a0,a0,-1582 # 800187e0 <shm_lock>
    80002e16:	db9fd0ef          	jal	80000bce <acquire>
  if (shm_table[shmid].pa == 0) {
    80002e1a:	fdc42703          	lw	a4,-36(s0)
    80002e1e:	00171793          	slli	a5,a4,0x1
    80002e22:	97ba                	add	a5,a5,a4
    80002e24:	0792                	slli	a5,a5,0x4
    80002e26:	00016717          	auipc	a4,0x16
    80002e2a:	9d270713          	addi	a4,a4,-1582 # 800187f8 <shm_table>
    80002e2e:	97ba                	add	a5,a5,a4
    80002e30:	679c                	ld	a5,8(a5)
    80002e32:	cfbd                	beqz	a5,80002eb0 <sys_shmat+0xc4>
    80002e34:	e84a                	sd	s2,16(sp)
    release(&shm_lock);
    return -1;
  }

  struct proc *p = myproc();
    80002e36:	a9dfe0ef          	jal	800018d2 <myproc>
    80002e3a:	892a                	mv	s2,a0
  uint64 va = PGROUNDUP(p->sz);
    80002e3c:	6924                	ld	s1,80(a0)
    80002e3e:	6785                	lui	a5,0x1
    80002e40:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80002e42:	94be                	add	s1,s1,a5
    80002e44:	77fd                	lui	a5,0xfffff
    80002e46:	8cfd                	and	s1,s1,a5

  // Map the shared physical page to the process's page table
  if (mappages(p->pagetable, va, PGSIZE, shm_table[shmid].pa, PTE_W | PTE_R | PTE_U) < 0) {
    80002e48:	fdc42703          	lw	a4,-36(s0)
    80002e4c:	00171793          	slli	a5,a4,0x1
    80002e50:	97ba                	add	a5,a5,a4
    80002e52:	0792                	slli	a5,a5,0x4
    80002e54:	00016717          	auipc	a4,0x16
    80002e58:	9a470713          	addi	a4,a4,-1628 # 800187f8 <shm_table>
    80002e5c:	97ba                	add	a5,a5,a4
    80002e5e:	4759                	li	a4,22
    80002e60:	6794                	ld	a3,8(a5)
    80002e62:	6605                	lui	a2,0x1
    80002e64:	85a6                	mv	a1,s1
    80002e66:	6d28                	ld	a0,88(a0)
    80002e68:	98afe0ef          	jal	80000ff2 <mappages>
    80002e6c:	04054963          	bltz	a0,80002ebe <sys_shmat+0xd2>
    release(&shm_lock);
    return -1;
  }

  shm_table[shmid].ref_count++;
    80002e70:	fdc42603          	lw	a2,-36(s0)
    80002e74:	00016697          	auipc	a3,0x16
    80002e78:	98468693          	addi	a3,a3,-1660 # 800187f8 <shm_table>
    80002e7c:	00161793          	slli	a5,a2,0x1
    80002e80:	00c78733          	add	a4,a5,a2
    80002e84:	0712                	slli	a4,a4,0x4
    80002e86:	9736                	add	a4,a4,a3
    80002e88:	4b1c                	lw	a5,16(a4)
    80002e8a:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffda841>
    80002e8c:	cb1c                	sw	a5,16(a4)
  p->sz = va + PGSIZE; // Increase process size to include the shared page
    80002e8e:	6785                	lui	a5,0x1
    80002e90:	97a6                	add	a5,a5,s1
    80002e92:	04f93823          	sd	a5,80(s2)
  release(&shm_lock);
    80002e96:	00016517          	auipc	a0,0x16
    80002e9a:	94a50513          	addi	a0,a0,-1718 # 800187e0 <shm_lock>
    80002e9e:	dc9fd0ef          	jal	80000c66 <release>
    80002ea2:	6942                	ld	s2,16(sp)

  return va; // Return the virtual address where it is attached
}
    80002ea4:	8526                	mv	a0,s1
    80002ea6:	70a2                	ld	ra,40(sp)
    80002ea8:	7402                	ld	s0,32(sp)
    80002eaa:	64e2                	ld	s1,24(sp)
    80002eac:	6145                	addi	sp,sp,48
    80002eae:	8082                	ret
    release(&shm_lock);
    80002eb0:	00016517          	auipc	a0,0x16
    80002eb4:	93050513          	addi	a0,a0,-1744 # 800187e0 <shm_lock>
    80002eb8:	daffd0ef          	jal	80000c66 <release>
    return -1;
    80002ebc:	b7e5                	j	80002ea4 <sys_shmat+0xb8>
    release(&shm_lock);
    80002ebe:	00016517          	auipc	a0,0x16
    80002ec2:	92250513          	addi	a0,a0,-1758 # 800187e0 <shm_lock>
    80002ec6:	da1fd0ef          	jal	80000c66 <release>
    return -1;
    80002eca:	54fd                	li	s1,-1
    80002ecc:	6942                	ld	s2,16(sp)
    80002ece:	bfd9                	j	80002ea4 <sys_shmat+0xb8>

0000000080002ed0 <sys_shmdt>:

uint64 sys_shmdt(void) {
    80002ed0:	7139                	addi	sp,sp,-64
    80002ed2:	fc06                	sd	ra,56(sp)
    80002ed4:	f822                	sd	s0,48(sp)
    80002ed6:	0080                	addi	s0,sp,64
  int shmid;
  argint(0, &shmid);
    80002ed8:	fcc40593          	addi	a1,s0,-52
    80002edc:	4501                	li	a0,0
    80002ede:	933ff0ef          	jal	80002810 <argint>

  if (shmid < 0 || shmid >= SHM_MAX) return -1;
    80002ee2:	fcc42703          	lw	a4,-52(s0)
    80002ee6:	03f00793          	li	a5,63
    80002eea:	557d                	li	a0,-1
    80002eec:	0ce7ef63          	bltu	a5,a4,80002fca <sys_shmdt+0xfa>

  acquire(&shm_lock);
    80002ef0:	00016517          	auipc	a0,0x16
    80002ef4:	8f050513          	addi	a0,a0,-1808 # 800187e0 <shm_lock>
    80002ef8:	cd7fd0ef          	jal	80000bce <acquire>
  if (shm_table[shmid].pa == 0) {
    80002efc:	fcc42703          	lw	a4,-52(s0)
    80002f00:	00171793          	slli	a5,a4,0x1
    80002f04:	97ba                	add	a5,a5,a4
    80002f06:	0792                	slli	a5,a5,0x4
    80002f08:	00016717          	auipc	a4,0x16
    80002f0c:	8f070713          	addi	a4,a4,-1808 # 800187f8 <shm_table>
    80002f10:	97ba                	add	a5,a5,a4
    80002f12:	679c                	ld	a5,8(a5)
    80002f14:	c38d                	beqz	a5,80002f36 <sys_shmdt+0x66>
    80002f16:	f04a                	sd	s2,32(sp)
    release(&shm_lock);
    return -1;
  }

  struct proc *p = myproc();
    80002f18:	9bbfe0ef          	jal	800018d2 <myproc>
    80002f1c:	892a                	mv	s2,a0
  uint64 va = 0;
  // Search for the virtual address where the shared page is mapped
  for (uint64 a = 0; a < p->sz; a += PGSIZE) {
    80002f1e:	693c                	ld	a5,80(a0)
    80002f20:	cfc9                	beqz	a5,80002fba <sys_shmdt+0xea>
    80002f22:	f426                	sd	s1,40(sp)
    80002f24:	ec4e                	sd	s3,24(sp)
    80002f26:	e852                	sd	s4,16(sp)
    80002f28:	4481                	li	s1,0
    pte_t *pte = walk(p->pagetable, a, 0);
    if (pte != 0 && (*pte & PTE_V)) {
      if (PTE2PA(*pte) == shm_table[shmid].pa) {
    80002f2a:	00016a17          	auipc	s4,0x16
    80002f2e:	8cea0a13          	addi	s4,s4,-1842 # 800187f8 <shm_table>
  for (uint64 a = 0; a < p->sz; a += PGSIZE) {
    80002f32:	6985                	lui	s3,0x1
    80002f34:	a831                	j	80002f50 <sys_shmdt+0x80>
    release(&shm_lock);
    80002f36:	00016517          	auipc	a0,0x16
    80002f3a:	8aa50513          	addi	a0,a0,-1878 # 800187e0 <shm_lock>
    80002f3e:	d29fd0ef          	jal	80000c66 <release>
    return -1;
    80002f42:	557d                	li	a0,-1
    80002f44:	a059                	j	80002fca <sys_shmdt+0xfa>
  for (uint64 a = 0; a < p->sz; a += PGSIZE) {
    80002f46:	94ce                	add	s1,s1,s3
    80002f48:	05093783          	ld	a5,80(s2)
    80002f4c:	06f4f463          	bgeu	s1,a5,80002fb4 <sys_shmdt+0xe4>
    pte_t *pte = walk(p->pagetable, a, 0);
    80002f50:	4601                	li	a2,0
    80002f52:	85a6                	mv	a1,s1
    80002f54:	05893503          	ld	a0,88(s2)
    80002f58:	fc3fd0ef          	jal	80000f1a <walk>
    if (pte != 0 && (*pte & PTE_V)) {
    80002f5c:	d56d                	beqz	a0,80002f46 <sys_shmdt+0x76>
    80002f5e:	611c                	ld	a5,0(a0)
    80002f60:	0017f713          	andi	a4,a5,1
    80002f64:	d36d                	beqz	a4,80002f46 <sys_shmdt+0x76>
      if (PTE2PA(*pte) == shm_table[shmid].pa) {
    80002f66:	83a9                	srli	a5,a5,0xa
    80002f68:	07b2                	slli	a5,a5,0xc
    80002f6a:	fcc42683          	lw	a3,-52(s0)
    80002f6e:	00169713          	slli	a4,a3,0x1
    80002f72:	9736                	add	a4,a4,a3
    80002f74:	0712                	slli	a4,a4,0x4
    80002f76:	9752                	add	a4,a4,s4
    80002f78:	6718                	ld	a4,8(a4)
    80002f7a:	fce796e3          	bne	a5,a4,80002f46 <sys_shmdt+0x76>
        break;
      }
    }
  }

  if (va != 0) {
    80002f7e:	c8b1                	beqz	s1,80002fd2 <sys_shmdt+0x102>
    uvmunmap(p->pagetable, va, 1, 0); // Unmap without freeing the underlying physical memory
    80002f80:	4681                	li	a3,0
    80002f82:	4605                	li	a2,1
    80002f84:	85a6                	mv	a1,s1
    80002f86:	05893503          	ld	a0,88(s2)
    80002f8a:	a34fe0ef          	jal	800011be <uvmunmap>
    shm_table[shmid].ref_count--;
    80002f8e:	fcc42603          	lw	a2,-52(s0)
    80002f92:	00016697          	auipc	a3,0x16
    80002f96:	86668693          	addi	a3,a3,-1946 # 800187f8 <shm_table>
    80002f9a:	00161793          	slli	a5,a2,0x1
    80002f9e:	00c78733          	add	a4,a5,a2
    80002fa2:	0712                	slli	a4,a4,0x4
    80002fa4:	9736                	add	a4,a4,a3
    80002fa6:	4b1c                	lw	a5,16(a4)
    80002fa8:	37fd                	addiw	a5,a5,-1 # fff <_entry-0x7ffff001>
    80002faa:	cb1c                	sw	a5,16(a4)
    80002fac:	74a2                	ld	s1,40(sp)
    80002fae:	69e2                	ld	s3,24(sp)
    80002fb0:	6a42                	ld	s4,16(sp)
    80002fb2:	a021                	j	80002fba <sys_shmdt+0xea>
    80002fb4:	74a2                	ld	s1,40(sp)
    80002fb6:	69e2                	ld	s3,24(sp)
    80002fb8:	6a42                	ld	s4,16(sp)
  }

  release(&shm_lock);
    80002fba:	00016517          	auipc	a0,0x16
    80002fbe:	82650513          	addi	a0,a0,-2010 # 800187e0 <shm_lock>
    80002fc2:	ca5fd0ef          	jal	80000c66 <release>
  return 0;
    80002fc6:	4501                	li	a0,0
    80002fc8:	7902                	ld	s2,32(sp)
}
    80002fca:	70e2                	ld	ra,56(sp)
    80002fcc:	7442                	ld	s0,48(sp)
    80002fce:	6121                	addi	sp,sp,64
    80002fd0:	8082                	ret
    80002fd2:	74a2                	ld	s1,40(sp)
    80002fd4:	69e2                	ld	s3,24(sp)
    80002fd6:	6a42                	ld	s4,16(sp)
    80002fd8:	b7cd                	j	80002fba <sys_shmdt+0xea>

0000000080002fda <shm_release>:

// Called when a process is freed to ensure shared memory is detached.
void shm_release(pagetable_t pagetable, uint64 sz) {
    80002fda:	715d                	addi	sp,sp,-80
    80002fdc:	e486                	sd	ra,72(sp)
    80002fde:	e0a2                	sd	s0,64(sp)
    80002fe0:	fc26                	sd	s1,56(sp)
    80002fe2:	f84a                	sd	s2,48(sp)
    80002fe4:	f44e                	sd	s3,40(sp)
    80002fe6:	f052                	sd	s4,32(sp)
    80002fe8:	ec56                	sd	s5,24(sp)
    80002fea:	e85a                	sd	s6,16(sp)
    80002fec:	e45e                	sd	s7,8(sp)
    80002fee:	0880                	addi	s0,sp,80
    80002ff0:	8a2a                	mv	s4,a0
    80002ff2:	89ae                	mv	s3,a1
  acquire(&shm_lock);
    80002ff4:	00015517          	auipc	a0,0x15
    80002ff8:	7ec50513          	addi	a0,a0,2028 # 800187e0 <shm_lock>
    80002ffc:	bd3fd0ef          	jal	80000bce <acquire>
  for(int i = 0; i < SHM_MAX; i++) {
    80003000:	00015917          	auipc	s2,0x15
    80003004:	7f890913          	addi	s2,s2,2040 # 800187f8 <shm_table>
    80003008:	00016b97          	auipc	s7,0x16
    8000300c:	3f0b8b93          	addi	s7,s7,1008 # 800193f8 <bcache>
    if(shm_table[i].pa != 0) {
      for (uint64 a = 0; a < sz; a += PGSIZE) {
    80003010:	6a85                	lui	s5,0x1
    80003012:	a095                	j	80003076 <shm_release+0x9c>
        pte_t *pte = walk(pagetable, a, 0);
        if (pte != 0 && (*pte & PTE_V) && PTE2PA(*pte) == shm_table[i].pa) {
          uvmunmap(pagetable, a, 1, 0); // Unmap without freeing underlying pa
          shm_table[i].ref_count--;
          if (shm_table[i].ref_count <= 0) {
            kfree((void*)shm_table[i].pa);
    80003014:	008b3503          	ld	a0,8(s6)
    80003018:	a05fd0ef          	jal	80000a1c <kfree>
            shm_table[i].pa = 0;
    8000301c:	000b3423          	sd	zero,8(s6)
            shm_table[i].key = 0;
    80003020:	000b2023          	sw	zero,0(s6)
            shm_table[i].ref_count = 0;
    80003024:	000b2823          	sw	zero,16(s6)
    80003028:	a099                	j	8000306e <shm_release+0x94>
      for (uint64 a = 0; a < sz; a += PGSIZE) {
    8000302a:	94d6                	add	s1,s1,s5
    8000302c:	0534f163          	bgeu	s1,s3,8000306e <shm_release+0x94>
        pte_t *pte = walk(pagetable, a, 0);
    80003030:	4601                	li	a2,0
    80003032:	85a6                	mv	a1,s1
    80003034:	8552                	mv	a0,s4
    80003036:	ee5fd0ef          	jal	80000f1a <walk>
        if (pte != 0 && (*pte & PTE_V) && PTE2PA(*pte) == shm_table[i].pa) {
    8000303a:	d965                	beqz	a0,8000302a <shm_release+0x50>
    8000303c:	611c                	ld	a5,0(a0)
    8000303e:	0017f713          	andi	a4,a5,1
    80003042:	d765                	beqz	a4,8000302a <shm_release+0x50>
    80003044:	83a9                	srli	a5,a5,0xa
    80003046:	07b2                	slli	a5,a5,0xc
    80003048:	008b3703          	ld	a4,8(s6)
    8000304c:	fce79fe3          	bne	a5,a4,8000302a <shm_release+0x50>
          uvmunmap(pagetable, a, 1, 0); // Unmap without freeing underlying pa
    80003050:	4681                	li	a3,0
    80003052:	4605                	li	a2,1
    80003054:	85a6                	mv	a1,s1
    80003056:	8552                	mv	a0,s4
    80003058:	966fe0ef          	jal	800011be <uvmunmap>
          shm_table[i].ref_count--;
    8000305c:	010b2783          	lw	a5,16(s6)
    80003060:	37fd                	addiw	a5,a5,-1
    80003062:	0007871b          	sext.w	a4,a5
    80003066:	00fb2823          	sw	a5,16(s6)
          if (shm_table[i].ref_count <= 0) {
    8000306a:	fae055e3          	blez	a4,80003014 <shm_release+0x3a>
  for(int i = 0; i < SHM_MAX; i++) {
    8000306e:	03090913          	addi	s2,s2,48
    80003072:	01790a63          	beq	s2,s7,80003086 <shm_release+0xac>
    if(shm_table[i].pa != 0) {
    80003076:	8b4a                	mv	s6,s2
    80003078:	00893783          	ld	a5,8(s2)
    8000307c:	dbed                	beqz	a5,8000306e <shm_release+0x94>
      for (uint64 a = 0; a < sz; a += PGSIZE) {
    8000307e:	fe0988e3          	beqz	s3,8000306e <shm_release+0x94>
    80003082:	4481                	li	s1,0
    80003084:	b775                	j	80003030 <shm_release+0x56>
          break;
        }
      }
    }
  }
  release(&shm_lock);
    80003086:	00015517          	auipc	a0,0x15
    8000308a:	75a50513          	addi	a0,a0,1882 # 800187e0 <shm_lock>
    8000308e:	bd9fd0ef          	jal	80000c66 <release>
}
    80003092:	60a6                	ld	ra,72(sp)
    80003094:	6406                	ld	s0,64(sp)
    80003096:	74e2                	ld	s1,56(sp)
    80003098:	7942                	ld	s2,48(sp)
    8000309a:	79a2                	ld	s3,40(sp)
    8000309c:	7a02                	ld	s4,32(sp)
    8000309e:	6ae2                	ld	s5,24(sp)
    800030a0:	6b42                	ld	s6,16(sp)
    800030a2:	6ba2                	ld	s7,8(sp)
    800030a4:	6161                	addi	sp,sp,80
    800030a6:	8082                	ret

00000000800030a8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800030a8:	7179                	addi	sp,sp,-48
    800030aa:	f406                	sd	ra,40(sp)
    800030ac:	f022                	sd	s0,32(sp)
    800030ae:	ec26                	sd	s1,24(sp)
    800030b0:	e84a                	sd	s2,16(sp)
    800030b2:	e44e                	sd	s3,8(sp)
    800030b4:	e052                	sd	s4,0(sp)
    800030b6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800030b8:	00004597          	auipc	a1,0x4
    800030bc:	2f858593          	addi	a1,a1,760 # 800073b0 <etext+0x3b0>
    800030c0:	00016517          	auipc	a0,0x16
    800030c4:	33850513          	addi	a0,a0,824 # 800193f8 <bcache>
    800030c8:	a87fd0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800030cc:	0001e797          	auipc	a5,0x1e
    800030d0:	32c78793          	addi	a5,a5,812 # 800213f8 <bcache+0x8000>
    800030d4:	0001e717          	auipc	a4,0x1e
    800030d8:	58c70713          	addi	a4,a4,1420 # 80021660 <bcache+0x8268>
    800030dc:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030e0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030e4:	00016497          	auipc	s1,0x16
    800030e8:	32c48493          	addi	s1,s1,812 # 80019410 <bcache+0x18>
    b->next = bcache.head.next;
    800030ec:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030ee:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030f0:	00004a17          	auipc	s4,0x4
    800030f4:	2c8a0a13          	addi	s4,s4,712 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    800030f8:	2b893783          	ld	a5,696(s2)
    800030fc:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030fe:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003102:	85d2                	mv	a1,s4
    80003104:	01048513          	addi	a0,s1,16
    80003108:	322010ef          	jal	8000442a <initsleeplock>
    bcache.head.next->prev = b;
    8000310c:	2b893783          	ld	a5,696(s2)
    80003110:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003112:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003116:	45848493          	addi	s1,s1,1112
    8000311a:	fd349fe3          	bne	s1,s3,800030f8 <binit+0x50>
  }
}
    8000311e:	70a2                	ld	ra,40(sp)
    80003120:	7402                	ld	s0,32(sp)
    80003122:	64e2                	ld	s1,24(sp)
    80003124:	6942                	ld	s2,16(sp)
    80003126:	69a2                	ld	s3,8(sp)
    80003128:	6a02                	ld	s4,0(sp)
    8000312a:	6145                	addi	sp,sp,48
    8000312c:	8082                	ret

000000008000312e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000312e:	7179                	addi	sp,sp,-48
    80003130:	f406                	sd	ra,40(sp)
    80003132:	f022                	sd	s0,32(sp)
    80003134:	ec26                	sd	s1,24(sp)
    80003136:	e84a                	sd	s2,16(sp)
    80003138:	e44e                	sd	s3,8(sp)
    8000313a:	1800                	addi	s0,sp,48
    8000313c:	892a                	mv	s2,a0
    8000313e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003140:	00016517          	auipc	a0,0x16
    80003144:	2b850513          	addi	a0,a0,696 # 800193f8 <bcache>
    80003148:	a87fd0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000314c:	0001e497          	auipc	s1,0x1e
    80003150:	5644b483          	ld	s1,1380(s1) # 800216b0 <bcache+0x82b8>
    80003154:	0001e797          	auipc	a5,0x1e
    80003158:	50c78793          	addi	a5,a5,1292 # 80021660 <bcache+0x8268>
    8000315c:	02f48b63          	beq	s1,a5,80003192 <bread+0x64>
    80003160:	873e                	mv	a4,a5
    80003162:	a021                	j	8000316a <bread+0x3c>
    80003164:	68a4                	ld	s1,80(s1)
    80003166:	02e48663          	beq	s1,a4,80003192 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    8000316a:	449c                	lw	a5,8(s1)
    8000316c:	ff279ce3          	bne	a5,s2,80003164 <bread+0x36>
    80003170:	44dc                	lw	a5,12(s1)
    80003172:	ff3799e3          	bne	a5,s3,80003164 <bread+0x36>
      b->refcnt++;
    80003176:	40bc                	lw	a5,64(s1)
    80003178:	2785                	addiw	a5,a5,1
    8000317a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000317c:	00016517          	auipc	a0,0x16
    80003180:	27c50513          	addi	a0,a0,636 # 800193f8 <bcache>
    80003184:	ae3fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80003188:	01048513          	addi	a0,s1,16
    8000318c:	2d4010ef          	jal	80004460 <acquiresleep>
      return b;
    80003190:	a889                	j	800031e2 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003192:	0001e497          	auipc	s1,0x1e
    80003196:	5164b483          	ld	s1,1302(s1) # 800216a8 <bcache+0x82b0>
    8000319a:	0001e797          	auipc	a5,0x1e
    8000319e:	4c678793          	addi	a5,a5,1222 # 80021660 <bcache+0x8268>
    800031a2:	00f48863          	beq	s1,a5,800031b2 <bread+0x84>
    800031a6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800031a8:	40bc                	lw	a5,64(s1)
    800031aa:	cb91                	beqz	a5,800031be <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031ac:	64a4                	ld	s1,72(s1)
    800031ae:	fee49de3          	bne	s1,a4,800031a8 <bread+0x7a>
  panic("bget: no buffers");
    800031b2:	00004517          	auipc	a0,0x4
    800031b6:	20e50513          	addi	a0,a0,526 # 800073c0 <etext+0x3c0>
    800031ba:	e26fd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    800031be:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800031c2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800031c6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031ca:	4785                	li	a5,1
    800031cc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031ce:	00016517          	auipc	a0,0x16
    800031d2:	22a50513          	addi	a0,a0,554 # 800193f8 <bcache>
    800031d6:	a91fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    800031da:	01048513          	addi	a0,s1,16
    800031de:	282010ef          	jal	80004460 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031e2:	409c                	lw	a5,0(s1)
    800031e4:	cb89                	beqz	a5,800031f6 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031e6:	8526                	mv	a0,s1
    800031e8:	70a2                	ld	ra,40(sp)
    800031ea:	7402                	ld	s0,32(sp)
    800031ec:	64e2                	ld	s1,24(sp)
    800031ee:	6942                	ld	s2,16(sp)
    800031f0:	69a2                	ld	s3,8(sp)
    800031f2:	6145                	addi	sp,sp,48
    800031f4:	8082                	ret
    virtio_disk_rw(b, 0);
    800031f6:	4581                	li	a1,0
    800031f8:	8526                	mv	a0,s1
    800031fa:	2d7020ef          	jal	80005cd0 <virtio_disk_rw>
    b->valid = 1;
    800031fe:	4785                	li	a5,1
    80003200:	c09c                	sw	a5,0(s1)
  return b;
    80003202:	b7d5                	j	800031e6 <bread+0xb8>

0000000080003204 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003204:	1101                	addi	sp,sp,-32
    80003206:	ec06                	sd	ra,24(sp)
    80003208:	e822                	sd	s0,16(sp)
    8000320a:	e426                	sd	s1,8(sp)
    8000320c:	1000                	addi	s0,sp,32
    8000320e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003210:	0541                	addi	a0,a0,16
    80003212:	2cc010ef          	jal	800044de <holdingsleep>
    80003216:	c911                	beqz	a0,8000322a <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003218:	4585                	li	a1,1
    8000321a:	8526                	mv	a0,s1
    8000321c:	2b5020ef          	jal	80005cd0 <virtio_disk_rw>
}
    80003220:	60e2                	ld	ra,24(sp)
    80003222:	6442                	ld	s0,16(sp)
    80003224:	64a2                	ld	s1,8(sp)
    80003226:	6105                	addi	sp,sp,32
    80003228:	8082                	ret
    panic("bwrite");
    8000322a:	00004517          	auipc	a0,0x4
    8000322e:	1ae50513          	addi	a0,a0,430 # 800073d8 <etext+0x3d8>
    80003232:	daefd0ef          	jal	800007e0 <panic>

0000000080003236 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003236:	1101                	addi	sp,sp,-32
    80003238:	ec06                	sd	ra,24(sp)
    8000323a:	e822                	sd	s0,16(sp)
    8000323c:	e426                	sd	s1,8(sp)
    8000323e:	e04a                	sd	s2,0(sp)
    80003240:	1000                	addi	s0,sp,32
    80003242:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003244:	01050913          	addi	s2,a0,16
    80003248:	854a                	mv	a0,s2
    8000324a:	294010ef          	jal	800044de <holdingsleep>
    8000324e:	c135                	beqz	a0,800032b2 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80003250:	854a                	mv	a0,s2
    80003252:	254010ef          	jal	800044a6 <releasesleep>

  acquire(&bcache.lock);
    80003256:	00016517          	auipc	a0,0x16
    8000325a:	1a250513          	addi	a0,a0,418 # 800193f8 <bcache>
    8000325e:	971fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80003262:	40bc                	lw	a5,64(s1)
    80003264:	37fd                	addiw	a5,a5,-1
    80003266:	0007871b          	sext.w	a4,a5
    8000326a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000326c:	e71d                	bnez	a4,8000329a <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000326e:	68b8                	ld	a4,80(s1)
    80003270:	64bc                	ld	a5,72(s1)
    80003272:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003274:	68b8                	ld	a4,80(s1)
    80003276:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003278:	0001e797          	auipc	a5,0x1e
    8000327c:	18078793          	addi	a5,a5,384 # 800213f8 <bcache+0x8000>
    80003280:	2b87b703          	ld	a4,696(a5)
    80003284:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003286:	0001e717          	auipc	a4,0x1e
    8000328a:	3da70713          	addi	a4,a4,986 # 80021660 <bcache+0x8268>
    8000328e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003290:	2b87b703          	ld	a4,696(a5)
    80003294:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003296:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000329a:	00016517          	auipc	a0,0x16
    8000329e:	15e50513          	addi	a0,a0,350 # 800193f8 <bcache>
    800032a2:	9c5fd0ef          	jal	80000c66 <release>
}
    800032a6:	60e2                	ld	ra,24(sp)
    800032a8:	6442                	ld	s0,16(sp)
    800032aa:	64a2                	ld	s1,8(sp)
    800032ac:	6902                	ld	s2,0(sp)
    800032ae:	6105                	addi	sp,sp,32
    800032b0:	8082                	ret
    panic("brelse");
    800032b2:	00004517          	auipc	a0,0x4
    800032b6:	12e50513          	addi	a0,a0,302 # 800073e0 <etext+0x3e0>
    800032ba:	d26fd0ef          	jal	800007e0 <panic>

00000000800032be <bpin>:

void
bpin(struct buf *b) {
    800032be:	1101                	addi	sp,sp,-32
    800032c0:	ec06                	sd	ra,24(sp)
    800032c2:	e822                	sd	s0,16(sp)
    800032c4:	e426                	sd	s1,8(sp)
    800032c6:	1000                	addi	s0,sp,32
    800032c8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032ca:	00016517          	auipc	a0,0x16
    800032ce:	12e50513          	addi	a0,a0,302 # 800193f8 <bcache>
    800032d2:	8fdfd0ef          	jal	80000bce <acquire>
  b->refcnt++;
    800032d6:	40bc                	lw	a5,64(s1)
    800032d8:	2785                	addiw	a5,a5,1
    800032da:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032dc:	00016517          	auipc	a0,0x16
    800032e0:	11c50513          	addi	a0,a0,284 # 800193f8 <bcache>
    800032e4:	983fd0ef          	jal	80000c66 <release>
}
    800032e8:	60e2                	ld	ra,24(sp)
    800032ea:	6442                	ld	s0,16(sp)
    800032ec:	64a2                	ld	s1,8(sp)
    800032ee:	6105                	addi	sp,sp,32
    800032f0:	8082                	ret

00000000800032f2 <bunpin>:

void
bunpin(struct buf *b) {
    800032f2:	1101                	addi	sp,sp,-32
    800032f4:	ec06                	sd	ra,24(sp)
    800032f6:	e822                	sd	s0,16(sp)
    800032f8:	e426                	sd	s1,8(sp)
    800032fa:	1000                	addi	s0,sp,32
    800032fc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032fe:	00016517          	auipc	a0,0x16
    80003302:	0fa50513          	addi	a0,a0,250 # 800193f8 <bcache>
    80003306:	8c9fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    8000330a:	40bc                	lw	a5,64(s1)
    8000330c:	37fd                	addiw	a5,a5,-1
    8000330e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003310:	00016517          	auipc	a0,0x16
    80003314:	0e850513          	addi	a0,a0,232 # 800193f8 <bcache>
    80003318:	94ffd0ef          	jal	80000c66 <release>
}
    8000331c:	60e2                	ld	ra,24(sp)
    8000331e:	6442                	ld	s0,16(sp)
    80003320:	64a2                	ld	s1,8(sp)
    80003322:	6105                	addi	sp,sp,32
    80003324:	8082                	ret

0000000080003326 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003326:	1101                	addi	sp,sp,-32
    80003328:	ec06                	sd	ra,24(sp)
    8000332a:	e822                	sd	s0,16(sp)
    8000332c:	e426                	sd	s1,8(sp)
    8000332e:	e04a                	sd	s2,0(sp)
    80003330:	1000                	addi	s0,sp,32
    80003332:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003334:	00d5d59b          	srliw	a1,a1,0xd
    80003338:	0001e797          	auipc	a5,0x1e
    8000333c:	79c7a783          	lw	a5,1948(a5) # 80021ad4 <sb+0x1c>
    80003340:	9dbd                	addw	a1,a1,a5
    80003342:	dedff0ef          	jal	8000312e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003346:	0074f713          	andi	a4,s1,7
    8000334a:	4785                	li	a5,1
    8000334c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003350:	14ce                	slli	s1,s1,0x33
    80003352:	90d9                	srli	s1,s1,0x36
    80003354:	00950733          	add	a4,a0,s1
    80003358:	05874703          	lbu	a4,88(a4)
    8000335c:	00e7f6b3          	and	a3,a5,a4
    80003360:	c29d                	beqz	a3,80003386 <bfree+0x60>
    80003362:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003364:	94aa                	add	s1,s1,a0
    80003366:	fff7c793          	not	a5,a5
    8000336a:	8f7d                	and	a4,a4,a5
    8000336c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003370:	7f9000ef          	jal	80004368 <log_write>
  brelse(bp);
    80003374:	854a                	mv	a0,s2
    80003376:	ec1ff0ef          	jal	80003236 <brelse>
}
    8000337a:	60e2                	ld	ra,24(sp)
    8000337c:	6442                	ld	s0,16(sp)
    8000337e:	64a2                	ld	s1,8(sp)
    80003380:	6902                	ld	s2,0(sp)
    80003382:	6105                	addi	sp,sp,32
    80003384:	8082                	ret
    panic("freeing free block");
    80003386:	00004517          	auipc	a0,0x4
    8000338a:	06250513          	addi	a0,a0,98 # 800073e8 <etext+0x3e8>
    8000338e:	c52fd0ef          	jal	800007e0 <panic>

0000000080003392 <balloc>:
{
    80003392:	711d                	addi	sp,sp,-96
    80003394:	ec86                	sd	ra,88(sp)
    80003396:	e8a2                	sd	s0,80(sp)
    80003398:	e4a6                	sd	s1,72(sp)
    8000339a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000339c:	0001e797          	auipc	a5,0x1e
    800033a0:	7207a783          	lw	a5,1824(a5) # 80021abc <sb+0x4>
    800033a4:	0e078f63          	beqz	a5,800034a2 <balloc+0x110>
    800033a8:	e0ca                	sd	s2,64(sp)
    800033aa:	fc4e                	sd	s3,56(sp)
    800033ac:	f852                	sd	s4,48(sp)
    800033ae:	f456                	sd	s5,40(sp)
    800033b0:	f05a                	sd	s6,32(sp)
    800033b2:	ec5e                	sd	s7,24(sp)
    800033b4:	e862                	sd	s8,16(sp)
    800033b6:	e466                	sd	s9,8(sp)
    800033b8:	8baa                	mv	s7,a0
    800033ba:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033bc:	0001eb17          	auipc	s6,0x1e
    800033c0:	6fcb0b13          	addi	s6,s6,1788 # 80021ab8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033c4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800033c6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033c8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800033ca:	6c89                	lui	s9,0x2
    800033cc:	a0b5                	j	80003438 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    800033ce:	97ca                	add	a5,a5,s2
    800033d0:	8e55                	or	a2,a2,a3
    800033d2:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800033d6:	854a                	mv	a0,s2
    800033d8:	791000ef          	jal	80004368 <log_write>
        brelse(bp);
    800033dc:	854a                	mv	a0,s2
    800033de:	e59ff0ef          	jal	80003236 <brelse>
  bp = bread(dev, bno);
    800033e2:	85a6                	mv	a1,s1
    800033e4:	855e                	mv	a0,s7
    800033e6:	d49ff0ef          	jal	8000312e <bread>
    800033ea:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800033ec:	40000613          	li	a2,1024
    800033f0:	4581                	li	a1,0
    800033f2:	05850513          	addi	a0,a0,88
    800033f6:	8adfd0ef          	jal	80000ca2 <memset>
  log_write(bp);
    800033fa:	854a                	mv	a0,s2
    800033fc:	76d000ef          	jal	80004368 <log_write>
  brelse(bp);
    80003400:	854a                	mv	a0,s2
    80003402:	e35ff0ef          	jal	80003236 <brelse>
}
    80003406:	6906                	ld	s2,64(sp)
    80003408:	79e2                	ld	s3,56(sp)
    8000340a:	7a42                	ld	s4,48(sp)
    8000340c:	7aa2                	ld	s5,40(sp)
    8000340e:	7b02                	ld	s6,32(sp)
    80003410:	6be2                	ld	s7,24(sp)
    80003412:	6c42                	ld	s8,16(sp)
    80003414:	6ca2                	ld	s9,8(sp)
}
    80003416:	8526                	mv	a0,s1
    80003418:	60e6                	ld	ra,88(sp)
    8000341a:	6446                	ld	s0,80(sp)
    8000341c:	64a6                	ld	s1,72(sp)
    8000341e:	6125                	addi	sp,sp,96
    80003420:	8082                	ret
    brelse(bp);
    80003422:	854a                	mv	a0,s2
    80003424:	e13ff0ef          	jal	80003236 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003428:	015c87bb          	addw	a5,s9,s5
    8000342c:	00078a9b          	sext.w	s5,a5
    80003430:	004b2703          	lw	a4,4(s6)
    80003434:	04eaff63          	bgeu	s5,a4,80003492 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003438:	41fad79b          	sraiw	a5,s5,0x1f
    8000343c:	0137d79b          	srliw	a5,a5,0x13
    80003440:	015787bb          	addw	a5,a5,s5
    80003444:	40d7d79b          	sraiw	a5,a5,0xd
    80003448:	01cb2583          	lw	a1,28(s6)
    8000344c:	9dbd                	addw	a1,a1,a5
    8000344e:	855e                	mv	a0,s7
    80003450:	cdfff0ef          	jal	8000312e <bread>
    80003454:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003456:	004b2503          	lw	a0,4(s6)
    8000345a:	000a849b          	sext.w	s1,s5
    8000345e:	8762                	mv	a4,s8
    80003460:	fca4f1e3          	bgeu	s1,a0,80003422 <balloc+0x90>
      m = 1 << (bi % 8);
    80003464:	00777693          	andi	a3,a4,7
    80003468:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000346c:	41f7579b          	sraiw	a5,a4,0x1f
    80003470:	01d7d79b          	srliw	a5,a5,0x1d
    80003474:	9fb9                	addw	a5,a5,a4
    80003476:	4037d79b          	sraiw	a5,a5,0x3
    8000347a:	00f90633          	add	a2,s2,a5
    8000347e:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003482:	00c6f5b3          	and	a1,a3,a2
    80003486:	d5a1                	beqz	a1,800033ce <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003488:	2705                	addiw	a4,a4,1
    8000348a:	2485                	addiw	s1,s1,1
    8000348c:	fd471ae3          	bne	a4,s4,80003460 <balloc+0xce>
    80003490:	bf49                	j	80003422 <balloc+0x90>
    80003492:	6906                	ld	s2,64(sp)
    80003494:	79e2                	ld	s3,56(sp)
    80003496:	7a42                	ld	s4,48(sp)
    80003498:	7aa2                	ld	s5,40(sp)
    8000349a:	7b02                	ld	s6,32(sp)
    8000349c:	6be2                	ld	s7,24(sp)
    8000349e:	6c42                	ld	s8,16(sp)
    800034a0:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800034a2:	00004517          	auipc	a0,0x4
    800034a6:	f5e50513          	addi	a0,a0,-162 # 80007400 <etext+0x400>
    800034aa:	850fd0ef          	jal	800004fa <printf>
  return 0;
    800034ae:	4481                	li	s1,0
    800034b0:	b79d                	j	80003416 <balloc+0x84>

00000000800034b2 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800034b2:	7179                	addi	sp,sp,-48
    800034b4:	f406                	sd	ra,40(sp)
    800034b6:	f022                	sd	s0,32(sp)
    800034b8:	ec26                	sd	s1,24(sp)
    800034ba:	e84a                	sd	s2,16(sp)
    800034bc:	e44e                	sd	s3,8(sp)
    800034be:	1800                	addi	s0,sp,48
    800034c0:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800034c2:	47ad                	li	a5,11
    800034c4:	02b7e663          	bltu	a5,a1,800034f0 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    800034c8:	02059793          	slli	a5,a1,0x20
    800034cc:	01e7d593          	srli	a1,a5,0x1e
    800034d0:	00b504b3          	add	s1,a0,a1
    800034d4:	0504a903          	lw	s2,80(s1)
    800034d8:	06091a63          	bnez	s2,8000354c <bmap+0x9a>
      addr = balloc(ip->dev);
    800034dc:	4108                	lw	a0,0(a0)
    800034de:	eb5ff0ef          	jal	80003392 <balloc>
    800034e2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800034e6:	06090363          	beqz	s2,8000354c <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    800034ea:	0524a823          	sw	s2,80(s1)
    800034ee:	a8b9                	j	8000354c <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800034f0:	ff45849b          	addiw	s1,a1,-12
    800034f4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800034f8:	0ff00793          	li	a5,255
    800034fc:	06e7ee63          	bltu	a5,a4,80003578 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003500:	08052903          	lw	s2,128(a0)
    80003504:	00091d63          	bnez	s2,8000351e <bmap+0x6c>
      addr = balloc(ip->dev);
    80003508:	4108                	lw	a0,0(a0)
    8000350a:	e89ff0ef          	jal	80003392 <balloc>
    8000350e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003512:	02090d63          	beqz	s2,8000354c <bmap+0x9a>
    80003516:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003518:	0929a023          	sw	s2,128(s3) # 1080 <_entry-0x7fffef80>
    8000351c:	a011                	j	80003520 <bmap+0x6e>
    8000351e:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003520:	85ca                	mv	a1,s2
    80003522:	0009a503          	lw	a0,0(s3)
    80003526:	c09ff0ef          	jal	8000312e <bread>
    8000352a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000352c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003530:	02049713          	slli	a4,s1,0x20
    80003534:	01e75593          	srli	a1,a4,0x1e
    80003538:	00b784b3          	add	s1,a5,a1
    8000353c:	0004a903          	lw	s2,0(s1)
    80003540:	00090e63          	beqz	s2,8000355c <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003544:	8552                	mv	a0,s4
    80003546:	cf1ff0ef          	jal	80003236 <brelse>
    return addr;
    8000354a:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000354c:	854a                	mv	a0,s2
    8000354e:	70a2                	ld	ra,40(sp)
    80003550:	7402                	ld	s0,32(sp)
    80003552:	64e2                	ld	s1,24(sp)
    80003554:	6942                	ld	s2,16(sp)
    80003556:	69a2                	ld	s3,8(sp)
    80003558:	6145                	addi	sp,sp,48
    8000355a:	8082                	ret
      addr = balloc(ip->dev);
    8000355c:	0009a503          	lw	a0,0(s3)
    80003560:	e33ff0ef          	jal	80003392 <balloc>
    80003564:	0005091b          	sext.w	s2,a0
      if(addr){
    80003568:	fc090ee3          	beqz	s2,80003544 <bmap+0x92>
        a[bn] = addr;
    8000356c:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003570:	8552                	mv	a0,s4
    80003572:	5f7000ef          	jal	80004368 <log_write>
    80003576:	b7f9                	j	80003544 <bmap+0x92>
    80003578:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000357a:	00004517          	auipc	a0,0x4
    8000357e:	e9e50513          	addi	a0,a0,-354 # 80007418 <etext+0x418>
    80003582:	a5efd0ef          	jal	800007e0 <panic>

0000000080003586 <iget>:
{
    80003586:	7179                	addi	sp,sp,-48
    80003588:	f406                	sd	ra,40(sp)
    8000358a:	f022                	sd	s0,32(sp)
    8000358c:	ec26                	sd	s1,24(sp)
    8000358e:	e84a                	sd	s2,16(sp)
    80003590:	e44e                	sd	s3,8(sp)
    80003592:	e052                	sd	s4,0(sp)
    80003594:	1800                	addi	s0,sp,48
    80003596:	89aa                	mv	s3,a0
    80003598:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000359a:	0001e517          	auipc	a0,0x1e
    8000359e:	53e50513          	addi	a0,a0,1342 # 80021ad8 <itable>
    800035a2:	e2cfd0ef          	jal	80000bce <acquire>
  empty = 0;
    800035a6:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035a8:	0001e497          	auipc	s1,0x1e
    800035ac:	54848493          	addi	s1,s1,1352 # 80021af0 <itable+0x18>
    800035b0:	00020697          	auipc	a3,0x20
    800035b4:	fd068693          	addi	a3,a3,-48 # 80023580 <log>
    800035b8:	a039                	j	800035c6 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035ba:	02090963          	beqz	s2,800035ec <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035be:	08848493          	addi	s1,s1,136
    800035c2:	02d48863          	beq	s1,a3,800035f2 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800035c6:	449c                	lw	a5,8(s1)
    800035c8:	fef059e3          	blez	a5,800035ba <iget+0x34>
    800035cc:	4098                	lw	a4,0(s1)
    800035ce:	ff3716e3          	bne	a4,s3,800035ba <iget+0x34>
    800035d2:	40d8                	lw	a4,4(s1)
    800035d4:	ff4713e3          	bne	a4,s4,800035ba <iget+0x34>
      ip->ref++;
    800035d8:	2785                	addiw	a5,a5,1
    800035da:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800035dc:	0001e517          	auipc	a0,0x1e
    800035e0:	4fc50513          	addi	a0,a0,1276 # 80021ad8 <itable>
    800035e4:	e82fd0ef          	jal	80000c66 <release>
      return ip;
    800035e8:	8926                	mv	s2,s1
    800035ea:	a02d                	j	80003614 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035ec:	fbe9                	bnez	a5,800035be <iget+0x38>
      empty = ip;
    800035ee:	8926                	mv	s2,s1
    800035f0:	b7f9                	j	800035be <iget+0x38>
  if(empty == 0)
    800035f2:	02090a63          	beqz	s2,80003626 <iget+0xa0>
  ip->dev = dev;
    800035f6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035fa:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035fe:	4785                	li	a5,1
    80003600:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003604:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003608:	0001e517          	auipc	a0,0x1e
    8000360c:	4d050513          	addi	a0,a0,1232 # 80021ad8 <itable>
    80003610:	e56fd0ef          	jal	80000c66 <release>
}
    80003614:	854a                	mv	a0,s2
    80003616:	70a2                	ld	ra,40(sp)
    80003618:	7402                	ld	s0,32(sp)
    8000361a:	64e2                	ld	s1,24(sp)
    8000361c:	6942                	ld	s2,16(sp)
    8000361e:	69a2                	ld	s3,8(sp)
    80003620:	6a02                	ld	s4,0(sp)
    80003622:	6145                	addi	sp,sp,48
    80003624:	8082                	ret
    panic("iget: no inodes");
    80003626:	00004517          	auipc	a0,0x4
    8000362a:	e0a50513          	addi	a0,a0,-502 # 80007430 <etext+0x430>
    8000362e:	9b2fd0ef          	jal	800007e0 <panic>

0000000080003632 <iinit>:
{
    80003632:	7179                	addi	sp,sp,-48
    80003634:	f406                	sd	ra,40(sp)
    80003636:	f022                	sd	s0,32(sp)
    80003638:	ec26                	sd	s1,24(sp)
    8000363a:	e84a                	sd	s2,16(sp)
    8000363c:	e44e                	sd	s3,8(sp)
    8000363e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003640:	00004597          	auipc	a1,0x4
    80003644:	e0058593          	addi	a1,a1,-512 # 80007440 <etext+0x440>
    80003648:	0001e517          	auipc	a0,0x1e
    8000364c:	49050513          	addi	a0,a0,1168 # 80021ad8 <itable>
    80003650:	cfefd0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003654:	0001e497          	auipc	s1,0x1e
    80003658:	4ac48493          	addi	s1,s1,1196 # 80021b00 <itable+0x28>
    8000365c:	00020997          	auipc	s3,0x20
    80003660:	f3498993          	addi	s3,s3,-204 # 80023590 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003664:	00004917          	auipc	s2,0x4
    80003668:	de490913          	addi	s2,s2,-540 # 80007448 <etext+0x448>
    8000366c:	85ca                	mv	a1,s2
    8000366e:	8526                	mv	a0,s1
    80003670:	5bb000ef          	jal	8000442a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003674:	08848493          	addi	s1,s1,136
    80003678:	ff349ae3          	bne	s1,s3,8000366c <iinit+0x3a>
}
    8000367c:	70a2                	ld	ra,40(sp)
    8000367e:	7402                	ld	s0,32(sp)
    80003680:	64e2                	ld	s1,24(sp)
    80003682:	6942                	ld	s2,16(sp)
    80003684:	69a2                	ld	s3,8(sp)
    80003686:	6145                	addi	sp,sp,48
    80003688:	8082                	ret

000000008000368a <ialloc>:
{
    8000368a:	7139                	addi	sp,sp,-64
    8000368c:	fc06                	sd	ra,56(sp)
    8000368e:	f822                	sd	s0,48(sp)
    80003690:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003692:	0001e717          	auipc	a4,0x1e
    80003696:	43272703          	lw	a4,1074(a4) # 80021ac4 <sb+0xc>
    8000369a:	4785                	li	a5,1
    8000369c:	06e7f063          	bgeu	a5,a4,800036fc <ialloc+0x72>
    800036a0:	f426                	sd	s1,40(sp)
    800036a2:	f04a                	sd	s2,32(sp)
    800036a4:	ec4e                	sd	s3,24(sp)
    800036a6:	e852                	sd	s4,16(sp)
    800036a8:	e456                	sd	s5,8(sp)
    800036aa:	e05a                	sd	s6,0(sp)
    800036ac:	8aaa                	mv	s5,a0
    800036ae:	8b2e                	mv	s6,a1
    800036b0:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800036b2:	0001ea17          	auipc	s4,0x1e
    800036b6:	406a0a13          	addi	s4,s4,1030 # 80021ab8 <sb>
    800036ba:	00495593          	srli	a1,s2,0x4
    800036be:	018a2783          	lw	a5,24(s4)
    800036c2:	9dbd                	addw	a1,a1,a5
    800036c4:	8556                	mv	a0,s5
    800036c6:	a69ff0ef          	jal	8000312e <bread>
    800036ca:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800036cc:	05850993          	addi	s3,a0,88
    800036d0:	00f97793          	andi	a5,s2,15
    800036d4:	079a                	slli	a5,a5,0x6
    800036d6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800036d8:	00099783          	lh	a5,0(s3)
    800036dc:	cb9d                	beqz	a5,80003712 <ialloc+0x88>
    brelse(bp);
    800036de:	b59ff0ef          	jal	80003236 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800036e2:	0905                	addi	s2,s2,1
    800036e4:	00ca2703          	lw	a4,12(s4)
    800036e8:	0009079b          	sext.w	a5,s2
    800036ec:	fce7e7e3          	bltu	a5,a4,800036ba <ialloc+0x30>
    800036f0:	74a2                	ld	s1,40(sp)
    800036f2:	7902                	ld	s2,32(sp)
    800036f4:	69e2                	ld	s3,24(sp)
    800036f6:	6a42                	ld	s4,16(sp)
    800036f8:	6aa2                	ld	s5,8(sp)
    800036fa:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800036fc:	00004517          	auipc	a0,0x4
    80003700:	d5450513          	addi	a0,a0,-684 # 80007450 <etext+0x450>
    80003704:	df7fc0ef          	jal	800004fa <printf>
  return 0;
    80003708:	4501                	li	a0,0
}
    8000370a:	70e2                	ld	ra,56(sp)
    8000370c:	7442                	ld	s0,48(sp)
    8000370e:	6121                	addi	sp,sp,64
    80003710:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003712:	04000613          	li	a2,64
    80003716:	4581                	li	a1,0
    80003718:	854e                	mv	a0,s3
    8000371a:	d88fd0ef          	jal	80000ca2 <memset>
      dip->type = type;
    8000371e:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003722:	8526                	mv	a0,s1
    80003724:	445000ef          	jal	80004368 <log_write>
      brelse(bp);
    80003728:	8526                	mv	a0,s1
    8000372a:	b0dff0ef          	jal	80003236 <brelse>
      return iget(dev, inum);
    8000372e:	0009059b          	sext.w	a1,s2
    80003732:	8556                	mv	a0,s5
    80003734:	e53ff0ef          	jal	80003586 <iget>
    80003738:	74a2                	ld	s1,40(sp)
    8000373a:	7902                	ld	s2,32(sp)
    8000373c:	69e2                	ld	s3,24(sp)
    8000373e:	6a42                	ld	s4,16(sp)
    80003740:	6aa2                	ld	s5,8(sp)
    80003742:	6b02                	ld	s6,0(sp)
    80003744:	b7d9                	j	8000370a <ialloc+0x80>

0000000080003746 <iupdate>:
{
    80003746:	1101                	addi	sp,sp,-32
    80003748:	ec06                	sd	ra,24(sp)
    8000374a:	e822                	sd	s0,16(sp)
    8000374c:	e426                	sd	s1,8(sp)
    8000374e:	e04a                	sd	s2,0(sp)
    80003750:	1000                	addi	s0,sp,32
    80003752:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003754:	415c                	lw	a5,4(a0)
    80003756:	0047d79b          	srliw	a5,a5,0x4
    8000375a:	0001e597          	auipc	a1,0x1e
    8000375e:	3765a583          	lw	a1,886(a1) # 80021ad0 <sb+0x18>
    80003762:	9dbd                	addw	a1,a1,a5
    80003764:	4108                	lw	a0,0(a0)
    80003766:	9c9ff0ef          	jal	8000312e <bread>
    8000376a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000376c:	05850793          	addi	a5,a0,88
    80003770:	40d8                	lw	a4,4(s1)
    80003772:	8b3d                	andi	a4,a4,15
    80003774:	071a                	slli	a4,a4,0x6
    80003776:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003778:	04449703          	lh	a4,68(s1)
    8000377c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003780:	04649703          	lh	a4,70(s1)
    80003784:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003788:	04849703          	lh	a4,72(s1)
    8000378c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003790:	04a49703          	lh	a4,74(s1)
    80003794:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003798:	44f8                	lw	a4,76(s1)
    8000379a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000379c:	03400613          	li	a2,52
    800037a0:	05048593          	addi	a1,s1,80
    800037a4:	00c78513          	addi	a0,a5,12
    800037a8:	d56fd0ef          	jal	80000cfe <memmove>
  log_write(bp);
    800037ac:	854a                	mv	a0,s2
    800037ae:	3bb000ef          	jal	80004368 <log_write>
  brelse(bp);
    800037b2:	854a                	mv	a0,s2
    800037b4:	a83ff0ef          	jal	80003236 <brelse>
}
    800037b8:	60e2                	ld	ra,24(sp)
    800037ba:	6442                	ld	s0,16(sp)
    800037bc:	64a2                	ld	s1,8(sp)
    800037be:	6902                	ld	s2,0(sp)
    800037c0:	6105                	addi	sp,sp,32
    800037c2:	8082                	ret

00000000800037c4 <idup>:
{
    800037c4:	1101                	addi	sp,sp,-32
    800037c6:	ec06                	sd	ra,24(sp)
    800037c8:	e822                	sd	s0,16(sp)
    800037ca:	e426                	sd	s1,8(sp)
    800037cc:	1000                	addi	s0,sp,32
    800037ce:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800037d0:	0001e517          	auipc	a0,0x1e
    800037d4:	30850513          	addi	a0,a0,776 # 80021ad8 <itable>
    800037d8:	bf6fd0ef          	jal	80000bce <acquire>
  ip->ref++;
    800037dc:	449c                	lw	a5,8(s1)
    800037de:	2785                	addiw	a5,a5,1
    800037e0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800037e2:	0001e517          	auipc	a0,0x1e
    800037e6:	2f650513          	addi	a0,a0,758 # 80021ad8 <itable>
    800037ea:	c7cfd0ef          	jal	80000c66 <release>
}
    800037ee:	8526                	mv	a0,s1
    800037f0:	60e2                	ld	ra,24(sp)
    800037f2:	6442                	ld	s0,16(sp)
    800037f4:	64a2                	ld	s1,8(sp)
    800037f6:	6105                	addi	sp,sp,32
    800037f8:	8082                	ret

00000000800037fa <ilock>:
{
    800037fa:	1101                	addi	sp,sp,-32
    800037fc:	ec06                	sd	ra,24(sp)
    800037fe:	e822                	sd	s0,16(sp)
    80003800:	e426                	sd	s1,8(sp)
    80003802:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003804:	cd19                	beqz	a0,80003822 <ilock+0x28>
    80003806:	84aa                	mv	s1,a0
    80003808:	451c                	lw	a5,8(a0)
    8000380a:	00f05c63          	blez	a5,80003822 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000380e:	0541                	addi	a0,a0,16
    80003810:	451000ef          	jal	80004460 <acquiresleep>
  if(ip->valid == 0){
    80003814:	40bc                	lw	a5,64(s1)
    80003816:	cf89                	beqz	a5,80003830 <ilock+0x36>
}
    80003818:	60e2                	ld	ra,24(sp)
    8000381a:	6442                	ld	s0,16(sp)
    8000381c:	64a2                	ld	s1,8(sp)
    8000381e:	6105                	addi	sp,sp,32
    80003820:	8082                	ret
    80003822:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003824:	00004517          	auipc	a0,0x4
    80003828:	c4450513          	addi	a0,a0,-956 # 80007468 <etext+0x468>
    8000382c:	fb5fc0ef          	jal	800007e0 <panic>
    80003830:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003832:	40dc                	lw	a5,4(s1)
    80003834:	0047d79b          	srliw	a5,a5,0x4
    80003838:	0001e597          	auipc	a1,0x1e
    8000383c:	2985a583          	lw	a1,664(a1) # 80021ad0 <sb+0x18>
    80003840:	9dbd                	addw	a1,a1,a5
    80003842:	4088                	lw	a0,0(s1)
    80003844:	8ebff0ef          	jal	8000312e <bread>
    80003848:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000384a:	05850593          	addi	a1,a0,88
    8000384e:	40dc                	lw	a5,4(s1)
    80003850:	8bbd                	andi	a5,a5,15
    80003852:	079a                	slli	a5,a5,0x6
    80003854:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003856:	00059783          	lh	a5,0(a1)
    8000385a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000385e:	00259783          	lh	a5,2(a1)
    80003862:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003866:	00459783          	lh	a5,4(a1)
    8000386a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000386e:	00659783          	lh	a5,6(a1)
    80003872:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003876:	459c                	lw	a5,8(a1)
    80003878:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000387a:	03400613          	li	a2,52
    8000387e:	05b1                	addi	a1,a1,12
    80003880:	05048513          	addi	a0,s1,80
    80003884:	c7afd0ef          	jal	80000cfe <memmove>
    brelse(bp);
    80003888:	854a                	mv	a0,s2
    8000388a:	9adff0ef          	jal	80003236 <brelse>
    ip->valid = 1;
    8000388e:	4785                	li	a5,1
    80003890:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003892:	04449783          	lh	a5,68(s1)
    80003896:	c399                	beqz	a5,8000389c <ilock+0xa2>
    80003898:	6902                	ld	s2,0(sp)
    8000389a:	bfbd                	j	80003818 <ilock+0x1e>
      panic("ilock: no type");
    8000389c:	00004517          	auipc	a0,0x4
    800038a0:	bd450513          	addi	a0,a0,-1068 # 80007470 <etext+0x470>
    800038a4:	f3dfc0ef          	jal	800007e0 <panic>

00000000800038a8 <iunlock>:
{
    800038a8:	1101                	addi	sp,sp,-32
    800038aa:	ec06                	sd	ra,24(sp)
    800038ac:	e822                	sd	s0,16(sp)
    800038ae:	e426                	sd	s1,8(sp)
    800038b0:	e04a                	sd	s2,0(sp)
    800038b2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800038b4:	c505                	beqz	a0,800038dc <iunlock+0x34>
    800038b6:	84aa                	mv	s1,a0
    800038b8:	01050913          	addi	s2,a0,16
    800038bc:	854a                	mv	a0,s2
    800038be:	421000ef          	jal	800044de <holdingsleep>
    800038c2:	cd09                	beqz	a0,800038dc <iunlock+0x34>
    800038c4:	449c                	lw	a5,8(s1)
    800038c6:	00f05b63          	blez	a5,800038dc <iunlock+0x34>
  releasesleep(&ip->lock);
    800038ca:	854a                	mv	a0,s2
    800038cc:	3db000ef          	jal	800044a6 <releasesleep>
}
    800038d0:	60e2                	ld	ra,24(sp)
    800038d2:	6442                	ld	s0,16(sp)
    800038d4:	64a2                	ld	s1,8(sp)
    800038d6:	6902                	ld	s2,0(sp)
    800038d8:	6105                	addi	sp,sp,32
    800038da:	8082                	ret
    panic("iunlock");
    800038dc:	00004517          	auipc	a0,0x4
    800038e0:	ba450513          	addi	a0,a0,-1116 # 80007480 <etext+0x480>
    800038e4:	efdfc0ef          	jal	800007e0 <panic>

00000000800038e8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800038e8:	7179                	addi	sp,sp,-48
    800038ea:	f406                	sd	ra,40(sp)
    800038ec:	f022                	sd	s0,32(sp)
    800038ee:	ec26                	sd	s1,24(sp)
    800038f0:	e84a                	sd	s2,16(sp)
    800038f2:	e44e                	sd	s3,8(sp)
    800038f4:	1800                	addi	s0,sp,48
    800038f6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800038f8:	05050493          	addi	s1,a0,80
    800038fc:	08050913          	addi	s2,a0,128
    80003900:	a021                	j	80003908 <itrunc+0x20>
    80003902:	0491                	addi	s1,s1,4
    80003904:	01248b63          	beq	s1,s2,8000391a <itrunc+0x32>
    if(ip->addrs[i]){
    80003908:	408c                	lw	a1,0(s1)
    8000390a:	dde5                	beqz	a1,80003902 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000390c:	0009a503          	lw	a0,0(s3)
    80003910:	a17ff0ef          	jal	80003326 <bfree>
      ip->addrs[i] = 0;
    80003914:	0004a023          	sw	zero,0(s1)
    80003918:	b7ed                	j	80003902 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000391a:	0809a583          	lw	a1,128(s3)
    8000391e:	ed89                	bnez	a1,80003938 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003920:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003924:	854e                	mv	a0,s3
    80003926:	e21ff0ef          	jal	80003746 <iupdate>
}
    8000392a:	70a2                	ld	ra,40(sp)
    8000392c:	7402                	ld	s0,32(sp)
    8000392e:	64e2                	ld	s1,24(sp)
    80003930:	6942                	ld	s2,16(sp)
    80003932:	69a2                	ld	s3,8(sp)
    80003934:	6145                	addi	sp,sp,48
    80003936:	8082                	ret
    80003938:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000393a:	0009a503          	lw	a0,0(s3)
    8000393e:	ff0ff0ef          	jal	8000312e <bread>
    80003942:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003944:	05850493          	addi	s1,a0,88
    80003948:	45850913          	addi	s2,a0,1112
    8000394c:	a021                	j	80003954 <itrunc+0x6c>
    8000394e:	0491                	addi	s1,s1,4
    80003950:	01248963          	beq	s1,s2,80003962 <itrunc+0x7a>
      if(a[j])
    80003954:	408c                	lw	a1,0(s1)
    80003956:	dde5                	beqz	a1,8000394e <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003958:	0009a503          	lw	a0,0(s3)
    8000395c:	9cbff0ef          	jal	80003326 <bfree>
    80003960:	b7fd                	j	8000394e <itrunc+0x66>
    brelse(bp);
    80003962:	8552                	mv	a0,s4
    80003964:	8d3ff0ef          	jal	80003236 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003968:	0809a583          	lw	a1,128(s3)
    8000396c:	0009a503          	lw	a0,0(s3)
    80003970:	9b7ff0ef          	jal	80003326 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003974:	0809a023          	sw	zero,128(s3)
    80003978:	6a02                	ld	s4,0(sp)
    8000397a:	b75d                	j	80003920 <itrunc+0x38>

000000008000397c <iput>:
{
    8000397c:	1101                	addi	sp,sp,-32
    8000397e:	ec06                	sd	ra,24(sp)
    80003980:	e822                	sd	s0,16(sp)
    80003982:	e426                	sd	s1,8(sp)
    80003984:	1000                	addi	s0,sp,32
    80003986:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003988:	0001e517          	auipc	a0,0x1e
    8000398c:	15050513          	addi	a0,a0,336 # 80021ad8 <itable>
    80003990:	a3efd0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003994:	4498                	lw	a4,8(s1)
    80003996:	4785                	li	a5,1
    80003998:	02f70063          	beq	a4,a5,800039b8 <iput+0x3c>
  ip->ref--;
    8000399c:	449c                	lw	a5,8(s1)
    8000399e:	37fd                	addiw	a5,a5,-1
    800039a0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039a2:	0001e517          	auipc	a0,0x1e
    800039a6:	13650513          	addi	a0,a0,310 # 80021ad8 <itable>
    800039aa:	abcfd0ef          	jal	80000c66 <release>
}
    800039ae:	60e2                	ld	ra,24(sp)
    800039b0:	6442                	ld	s0,16(sp)
    800039b2:	64a2                	ld	s1,8(sp)
    800039b4:	6105                	addi	sp,sp,32
    800039b6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039b8:	40bc                	lw	a5,64(s1)
    800039ba:	d3ed                	beqz	a5,8000399c <iput+0x20>
    800039bc:	04a49783          	lh	a5,74(s1)
    800039c0:	fff1                	bnez	a5,8000399c <iput+0x20>
    800039c2:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800039c4:	01048913          	addi	s2,s1,16
    800039c8:	854a                	mv	a0,s2
    800039ca:	297000ef          	jal	80004460 <acquiresleep>
    release(&itable.lock);
    800039ce:	0001e517          	auipc	a0,0x1e
    800039d2:	10a50513          	addi	a0,a0,266 # 80021ad8 <itable>
    800039d6:	a90fd0ef          	jal	80000c66 <release>
    itrunc(ip);
    800039da:	8526                	mv	a0,s1
    800039dc:	f0dff0ef          	jal	800038e8 <itrunc>
    ip->type = 0;
    800039e0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800039e4:	8526                	mv	a0,s1
    800039e6:	d61ff0ef          	jal	80003746 <iupdate>
    ip->valid = 0;
    800039ea:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039ee:	854a                	mv	a0,s2
    800039f0:	2b7000ef          	jal	800044a6 <releasesleep>
    acquire(&itable.lock);
    800039f4:	0001e517          	auipc	a0,0x1e
    800039f8:	0e450513          	addi	a0,a0,228 # 80021ad8 <itable>
    800039fc:	9d2fd0ef          	jal	80000bce <acquire>
    80003a00:	6902                	ld	s2,0(sp)
    80003a02:	bf69                	j	8000399c <iput+0x20>

0000000080003a04 <iunlockput>:
{
    80003a04:	1101                	addi	sp,sp,-32
    80003a06:	ec06                	sd	ra,24(sp)
    80003a08:	e822                	sd	s0,16(sp)
    80003a0a:	e426                	sd	s1,8(sp)
    80003a0c:	1000                	addi	s0,sp,32
    80003a0e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a10:	e99ff0ef          	jal	800038a8 <iunlock>
  iput(ip);
    80003a14:	8526                	mv	a0,s1
    80003a16:	f67ff0ef          	jal	8000397c <iput>
}
    80003a1a:	60e2                	ld	ra,24(sp)
    80003a1c:	6442                	ld	s0,16(sp)
    80003a1e:	64a2                	ld	s1,8(sp)
    80003a20:	6105                	addi	sp,sp,32
    80003a22:	8082                	ret

0000000080003a24 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003a24:	0001e717          	auipc	a4,0x1e
    80003a28:	0a072703          	lw	a4,160(a4) # 80021ac4 <sb+0xc>
    80003a2c:	4785                	li	a5,1
    80003a2e:	0ae7ff63          	bgeu	a5,a4,80003aec <ireclaim+0xc8>
{
    80003a32:	7139                	addi	sp,sp,-64
    80003a34:	fc06                	sd	ra,56(sp)
    80003a36:	f822                	sd	s0,48(sp)
    80003a38:	f426                	sd	s1,40(sp)
    80003a3a:	f04a                	sd	s2,32(sp)
    80003a3c:	ec4e                	sd	s3,24(sp)
    80003a3e:	e852                	sd	s4,16(sp)
    80003a40:	e456                	sd	s5,8(sp)
    80003a42:	e05a                	sd	s6,0(sp)
    80003a44:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003a46:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003a48:	00050a1b          	sext.w	s4,a0
    80003a4c:	0001ea97          	auipc	s5,0x1e
    80003a50:	06ca8a93          	addi	s5,s5,108 # 80021ab8 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003a54:	00004b17          	auipc	s6,0x4
    80003a58:	a34b0b13          	addi	s6,s6,-1484 # 80007488 <etext+0x488>
    80003a5c:	a099                	j	80003aa2 <ireclaim+0x7e>
    80003a5e:	85ce                	mv	a1,s3
    80003a60:	855a                	mv	a0,s6
    80003a62:	a99fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003a66:	85ce                	mv	a1,s3
    80003a68:	8552                	mv	a0,s4
    80003a6a:	b1dff0ef          	jal	80003586 <iget>
    80003a6e:	89aa                	mv	s3,a0
    brelse(bp);
    80003a70:	854a                	mv	a0,s2
    80003a72:	fc4ff0ef          	jal	80003236 <brelse>
    if (ip) {
    80003a76:	00098f63          	beqz	s3,80003a94 <ireclaim+0x70>
      begin_op();
    80003a7a:	76a000ef          	jal	800041e4 <begin_op>
      ilock(ip);
    80003a7e:	854e                	mv	a0,s3
    80003a80:	d7bff0ef          	jal	800037fa <ilock>
      iunlock(ip);
    80003a84:	854e                	mv	a0,s3
    80003a86:	e23ff0ef          	jal	800038a8 <iunlock>
      iput(ip);
    80003a8a:	854e                	mv	a0,s3
    80003a8c:	ef1ff0ef          	jal	8000397c <iput>
      end_op();
    80003a90:	7be000ef          	jal	8000424e <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003a94:	0485                	addi	s1,s1,1
    80003a96:	00caa703          	lw	a4,12(s5)
    80003a9a:	0004879b          	sext.w	a5,s1
    80003a9e:	02e7fd63          	bgeu	a5,a4,80003ad8 <ireclaim+0xb4>
    80003aa2:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003aa6:	0044d593          	srli	a1,s1,0x4
    80003aaa:	018aa783          	lw	a5,24(s5)
    80003aae:	9dbd                	addw	a1,a1,a5
    80003ab0:	8552                	mv	a0,s4
    80003ab2:	e7cff0ef          	jal	8000312e <bread>
    80003ab6:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003ab8:	05850793          	addi	a5,a0,88
    80003abc:	00f9f713          	andi	a4,s3,15
    80003ac0:	071a                	slli	a4,a4,0x6
    80003ac2:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003ac4:	00079703          	lh	a4,0(a5)
    80003ac8:	c701                	beqz	a4,80003ad0 <ireclaim+0xac>
    80003aca:	00679783          	lh	a5,6(a5)
    80003ace:	dbc1                	beqz	a5,80003a5e <ireclaim+0x3a>
    brelse(bp);
    80003ad0:	854a                	mv	a0,s2
    80003ad2:	f64ff0ef          	jal	80003236 <brelse>
    if (ip) {
    80003ad6:	bf7d                	j	80003a94 <ireclaim+0x70>
}
    80003ad8:	70e2                	ld	ra,56(sp)
    80003ada:	7442                	ld	s0,48(sp)
    80003adc:	74a2                	ld	s1,40(sp)
    80003ade:	7902                	ld	s2,32(sp)
    80003ae0:	69e2                	ld	s3,24(sp)
    80003ae2:	6a42                	ld	s4,16(sp)
    80003ae4:	6aa2                	ld	s5,8(sp)
    80003ae6:	6b02                	ld	s6,0(sp)
    80003ae8:	6121                	addi	sp,sp,64
    80003aea:	8082                	ret
    80003aec:	8082                	ret

0000000080003aee <fsinit>:
fsinit(int dev) {
    80003aee:	7179                	addi	sp,sp,-48
    80003af0:	f406                	sd	ra,40(sp)
    80003af2:	f022                	sd	s0,32(sp)
    80003af4:	ec26                	sd	s1,24(sp)
    80003af6:	e84a                	sd	s2,16(sp)
    80003af8:	e44e                	sd	s3,8(sp)
    80003afa:	1800                	addi	s0,sp,48
    80003afc:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003afe:	4585                	li	a1,1
    80003b00:	e2eff0ef          	jal	8000312e <bread>
    80003b04:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b06:	0001e997          	auipc	s3,0x1e
    80003b0a:	fb298993          	addi	s3,s3,-78 # 80021ab8 <sb>
    80003b0e:	02000613          	li	a2,32
    80003b12:	05850593          	addi	a1,a0,88
    80003b16:	854e                	mv	a0,s3
    80003b18:	9e6fd0ef          	jal	80000cfe <memmove>
  brelse(bp);
    80003b1c:	854a                	mv	a0,s2
    80003b1e:	f18ff0ef          	jal	80003236 <brelse>
  if(sb.magic != FSMAGIC)
    80003b22:	0009a703          	lw	a4,0(s3)
    80003b26:	102037b7          	lui	a5,0x10203
    80003b2a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b2e:	02f71363          	bne	a4,a5,80003b54 <fsinit+0x66>
  initlog(dev, &sb);
    80003b32:	0001e597          	auipc	a1,0x1e
    80003b36:	f8658593          	addi	a1,a1,-122 # 80021ab8 <sb>
    80003b3a:	8526                	mv	a0,s1
    80003b3c:	62a000ef          	jal	80004166 <initlog>
  ireclaim(dev);
    80003b40:	8526                	mv	a0,s1
    80003b42:	ee3ff0ef          	jal	80003a24 <ireclaim>
}
    80003b46:	70a2                	ld	ra,40(sp)
    80003b48:	7402                	ld	s0,32(sp)
    80003b4a:	64e2                	ld	s1,24(sp)
    80003b4c:	6942                	ld	s2,16(sp)
    80003b4e:	69a2                	ld	s3,8(sp)
    80003b50:	6145                	addi	sp,sp,48
    80003b52:	8082                	ret
    panic("invalid file system");
    80003b54:	00004517          	auipc	a0,0x4
    80003b58:	95450513          	addi	a0,a0,-1708 # 800074a8 <etext+0x4a8>
    80003b5c:	c85fc0ef          	jal	800007e0 <panic>

0000000080003b60 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b60:	1141                	addi	sp,sp,-16
    80003b62:	e422                	sd	s0,8(sp)
    80003b64:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b66:	411c                	lw	a5,0(a0)
    80003b68:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b6a:	415c                	lw	a5,4(a0)
    80003b6c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b6e:	04451783          	lh	a5,68(a0)
    80003b72:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b76:	04a51783          	lh	a5,74(a0)
    80003b7a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b7e:	04c56783          	lwu	a5,76(a0)
    80003b82:	e99c                	sd	a5,16(a1)
}
    80003b84:	6422                	ld	s0,8(sp)
    80003b86:	0141                	addi	sp,sp,16
    80003b88:	8082                	ret

0000000080003b8a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b8a:	457c                	lw	a5,76(a0)
    80003b8c:	0ed7eb63          	bltu	a5,a3,80003c82 <readi+0xf8>
{
    80003b90:	7159                	addi	sp,sp,-112
    80003b92:	f486                	sd	ra,104(sp)
    80003b94:	f0a2                	sd	s0,96(sp)
    80003b96:	eca6                	sd	s1,88(sp)
    80003b98:	e0d2                	sd	s4,64(sp)
    80003b9a:	fc56                	sd	s5,56(sp)
    80003b9c:	f85a                	sd	s6,48(sp)
    80003b9e:	f45e                	sd	s7,40(sp)
    80003ba0:	1880                	addi	s0,sp,112
    80003ba2:	8b2a                	mv	s6,a0
    80003ba4:	8bae                	mv	s7,a1
    80003ba6:	8a32                	mv	s4,a2
    80003ba8:	84b6                	mv	s1,a3
    80003baa:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003bac:	9f35                	addw	a4,a4,a3
    return 0;
    80003bae:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003bb0:	0cd76063          	bltu	a4,a3,80003c70 <readi+0xe6>
    80003bb4:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003bb6:	00e7f463          	bgeu	a5,a4,80003bbe <readi+0x34>
    n = ip->size - off;
    80003bba:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bbe:	080a8f63          	beqz	s5,80003c5c <readi+0xd2>
    80003bc2:	e8ca                	sd	s2,80(sp)
    80003bc4:	f062                	sd	s8,32(sp)
    80003bc6:	ec66                	sd	s9,24(sp)
    80003bc8:	e86a                	sd	s10,16(sp)
    80003bca:	e46e                	sd	s11,8(sp)
    80003bcc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bce:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003bd2:	5c7d                	li	s8,-1
    80003bd4:	a80d                	j	80003c06 <readi+0x7c>
    80003bd6:	020d1d93          	slli	s11,s10,0x20
    80003bda:	020ddd93          	srli	s11,s11,0x20
    80003bde:	05890613          	addi	a2,s2,88
    80003be2:	86ee                	mv	a3,s11
    80003be4:	963a                	add	a2,a2,a4
    80003be6:	85d2                	mv	a1,s4
    80003be8:	855e                	mv	a0,s7
    80003bea:	e7efe0ef          	jal	80002268 <either_copyout>
    80003bee:	05850763          	beq	a0,s8,80003c3c <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003bf2:	854a                	mv	a0,s2
    80003bf4:	e42ff0ef          	jal	80003236 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bf8:	013d09bb          	addw	s3,s10,s3
    80003bfc:	009d04bb          	addw	s1,s10,s1
    80003c00:	9a6e                	add	s4,s4,s11
    80003c02:	0559f763          	bgeu	s3,s5,80003c50 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003c06:	00a4d59b          	srliw	a1,s1,0xa
    80003c0a:	855a                	mv	a0,s6
    80003c0c:	8a7ff0ef          	jal	800034b2 <bmap>
    80003c10:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c14:	c5b1                	beqz	a1,80003c60 <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003c16:	000b2503          	lw	a0,0(s6)
    80003c1a:	d14ff0ef          	jal	8000312e <bread>
    80003c1e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c20:	3ff4f713          	andi	a4,s1,1023
    80003c24:	40ec87bb          	subw	a5,s9,a4
    80003c28:	413a86bb          	subw	a3,s5,s3
    80003c2c:	8d3e                	mv	s10,a5
    80003c2e:	2781                	sext.w	a5,a5
    80003c30:	0006861b          	sext.w	a2,a3
    80003c34:	faf671e3          	bgeu	a2,a5,80003bd6 <readi+0x4c>
    80003c38:	8d36                	mv	s10,a3
    80003c3a:	bf71                	j	80003bd6 <readi+0x4c>
      brelse(bp);
    80003c3c:	854a                	mv	a0,s2
    80003c3e:	df8ff0ef          	jal	80003236 <brelse>
      tot = -1;
    80003c42:	59fd                	li	s3,-1
      break;
    80003c44:	6946                	ld	s2,80(sp)
    80003c46:	7c02                	ld	s8,32(sp)
    80003c48:	6ce2                	ld	s9,24(sp)
    80003c4a:	6d42                	ld	s10,16(sp)
    80003c4c:	6da2                	ld	s11,8(sp)
    80003c4e:	a831                	j	80003c6a <readi+0xe0>
    80003c50:	6946                	ld	s2,80(sp)
    80003c52:	7c02                	ld	s8,32(sp)
    80003c54:	6ce2                	ld	s9,24(sp)
    80003c56:	6d42                	ld	s10,16(sp)
    80003c58:	6da2                	ld	s11,8(sp)
    80003c5a:	a801                	j	80003c6a <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c5c:	89d6                	mv	s3,s5
    80003c5e:	a031                	j	80003c6a <readi+0xe0>
    80003c60:	6946                	ld	s2,80(sp)
    80003c62:	7c02                	ld	s8,32(sp)
    80003c64:	6ce2                	ld	s9,24(sp)
    80003c66:	6d42                	ld	s10,16(sp)
    80003c68:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003c6a:	0009851b          	sext.w	a0,s3
    80003c6e:	69a6                	ld	s3,72(sp)
}
    80003c70:	70a6                	ld	ra,104(sp)
    80003c72:	7406                	ld	s0,96(sp)
    80003c74:	64e6                	ld	s1,88(sp)
    80003c76:	6a06                	ld	s4,64(sp)
    80003c78:	7ae2                	ld	s5,56(sp)
    80003c7a:	7b42                	ld	s6,48(sp)
    80003c7c:	7ba2                	ld	s7,40(sp)
    80003c7e:	6165                	addi	sp,sp,112
    80003c80:	8082                	ret
    return 0;
    80003c82:	4501                	li	a0,0
}
    80003c84:	8082                	ret

0000000080003c86 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c86:	457c                	lw	a5,76(a0)
    80003c88:	10d7e063          	bltu	a5,a3,80003d88 <writei+0x102>
{
    80003c8c:	7159                	addi	sp,sp,-112
    80003c8e:	f486                	sd	ra,104(sp)
    80003c90:	f0a2                	sd	s0,96(sp)
    80003c92:	e8ca                	sd	s2,80(sp)
    80003c94:	e0d2                	sd	s4,64(sp)
    80003c96:	fc56                	sd	s5,56(sp)
    80003c98:	f85a                	sd	s6,48(sp)
    80003c9a:	f45e                	sd	s7,40(sp)
    80003c9c:	1880                	addi	s0,sp,112
    80003c9e:	8aaa                	mv	s5,a0
    80003ca0:	8bae                	mv	s7,a1
    80003ca2:	8a32                	mv	s4,a2
    80003ca4:	8936                	mv	s2,a3
    80003ca6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ca8:	00e687bb          	addw	a5,a3,a4
    80003cac:	0ed7e063          	bltu	a5,a3,80003d8c <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003cb0:	00043737          	lui	a4,0x43
    80003cb4:	0cf76e63          	bltu	a4,a5,80003d90 <writei+0x10a>
    80003cb8:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cba:	0a0b0f63          	beqz	s6,80003d78 <writei+0xf2>
    80003cbe:	eca6                	sd	s1,88(sp)
    80003cc0:	f062                	sd	s8,32(sp)
    80003cc2:	ec66                	sd	s9,24(sp)
    80003cc4:	e86a                	sd	s10,16(sp)
    80003cc6:	e46e                	sd	s11,8(sp)
    80003cc8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cca:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003cce:	5c7d                	li	s8,-1
    80003cd0:	a825                	j	80003d08 <writei+0x82>
    80003cd2:	020d1d93          	slli	s11,s10,0x20
    80003cd6:	020ddd93          	srli	s11,s11,0x20
    80003cda:	05848513          	addi	a0,s1,88
    80003cde:	86ee                	mv	a3,s11
    80003ce0:	8652                	mv	a2,s4
    80003ce2:	85de                	mv	a1,s7
    80003ce4:	953a                	add	a0,a0,a4
    80003ce6:	dccfe0ef          	jal	800022b2 <either_copyin>
    80003cea:	05850a63          	beq	a0,s8,80003d3e <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003cee:	8526                	mv	a0,s1
    80003cf0:	678000ef          	jal	80004368 <log_write>
    brelse(bp);
    80003cf4:	8526                	mv	a0,s1
    80003cf6:	d40ff0ef          	jal	80003236 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cfa:	013d09bb          	addw	s3,s10,s3
    80003cfe:	012d093b          	addw	s2,s10,s2
    80003d02:	9a6e                	add	s4,s4,s11
    80003d04:	0569f063          	bgeu	s3,s6,80003d44 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003d08:	00a9559b          	srliw	a1,s2,0xa
    80003d0c:	8556                	mv	a0,s5
    80003d0e:	fa4ff0ef          	jal	800034b2 <bmap>
    80003d12:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d16:	c59d                	beqz	a1,80003d44 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003d18:	000aa503          	lw	a0,0(s5)
    80003d1c:	c12ff0ef          	jal	8000312e <bread>
    80003d20:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d22:	3ff97713          	andi	a4,s2,1023
    80003d26:	40ec87bb          	subw	a5,s9,a4
    80003d2a:	413b06bb          	subw	a3,s6,s3
    80003d2e:	8d3e                	mv	s10,a5
    80003d30:	2781                	sext.w	a5,a5
    80003d32:	0006861b          	sext.w	a2,a3
    80003d36:	f8f67ee3          	bgeu	a2,a5,80003cd2 <writei+0x4c>
    80003d3a:	8d36                	mv	s10,a3
    80003d3c:	bf59                	j	80003cd2 <writei+0x4c>
      brelse(bp);
    80003d3e:	8526                	mv	a0,s1
    80003d40:	cf6ff0ef          	jal	80003236 <brelse>
  }

  if(off > ip->size)
    80003d44:	04caa783          	lw	a5,76(s5)
    80003d48:	0327fa63          	bgeu	a5,s2,80003d7c <writei+0xf6>
    ip->size = off;
    80003d4c:	052aa623          	sw	s2,76(s5)
    80003d50:	64e6                	ld	s1,88(sp)
    80003d52:	7c02                	ld	s8,32(sp)
    80003d54:	6ce2                	ld	s9,24(sp)
    80003d56:	6d42                	ld	s10,16(sp)
    80003d58:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d5a:	8556                	mv	a0,s5
    80003d5c:	9ebff0ef          	jal	80003746 <iupdate>

  return tot;
    80003d60:	0009851b          	sext.w	a0,s3
    80003d64:	69a6                	ld	s3,72(sp)
}
    80003d66:	70a6                	ld	ra,104(sp)
    80003d68:	7406                	ld	s0,96(sp)
    80003d6a:	6946                	ld	s2,80(sp)
    80003d6c:	6a06                	ld	s4,64(sp)
    80003d6e:	7ae2                	ld	s5,56(sp)
    80003d70:	7b42                	ld	s6,48(sp)
    80003d72:	7ba2                	ld	s7,40(sp)
    80003d74:	6165                	addi	sp,sp,112
    80003d76:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d78:	89da                	mv	s3,s6
    80003d7a:	b7c5                	j	80003d5a <writei+0xd4>
    80003d7c:	64e6                	ld	s1,88(sp)
    80003d7e:	7c02                	ld	s8,32(sp)
    80003d80:	6ce2                	ld	s9,24(sp)
    80003d82:	6d42                	ld	s10,16(sp)
    80003d84:	6da2                	ld	s11,8(sp)
    80003d86:	bfd1                	j	80003d5a <writei+0xd4>
    return -1;
    80003d88:	557d                	li	a0,-1
}
    80003d8a:	8082                	ret
    return -1;
    80003d8c:	557d                	li	a0,-1
    80003d8e:	bfe1                	j	80003d66 <writei+0xe0>
    return -1;
    80003d90:	557d                	li	a0,-1
    80003d92:	bfd1                	j	80003d66 <writei+0xe0>

0000000080003d94 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d94:	1141                	addi	sp,sp,-16
    80003d96:	e406                	sd	ra,8(sp)
    80003d98:	e022                	sd	s0,0(sp)
    80003d9a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d9c:	4639                	li	a2,14
    80003d9e:	fd1fc0ef          	jal	80000d6e <strncmp>
}
    80003da2:	60a2                	ld	ra,8(sp)
    80003da4:	6402                	ld	s0,0(sp)
    80003da6:	0141                	addi	sp,sp,16
    80003da8:	8082                	ret

0000000080003daa <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003daa:	7139                	addi	sp,sp,-64
    80003dac:	fc06                	sd	ra,56(sp)
    80003dae:	f822                	sd	s0,48(sp)
    80003db0:	f426                	sd	s1,40(sp)
    80003db2:	f04a                	sd	s2,32(sp)
    80003db4:	ec4e                	sd	s3,24(sp)
    80003db6:	e852                	sd	s4,16(sp)
    80003db8:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003dba:	04451703          	lh	a4,68(a0)
    80003dbe:	4785                	li	a5,1
    80003dc0:	00f71a63          	bne	a4,a5,80003dd4 <dirlookup+0x2a>
    80003dc4:	892a                	mv	s2,a0
    80003dc6:	89ae                	mv	s3,a1
    80003dc8:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dca:	457c                	lw	a5,76(a0)
    80003dcc:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003dce:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dd0:	e39d                	bnez	a5,80003df6 <dirlookup+0x4c>
    80003dd2:	a095                	j	80003e36 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003dd4:	00003517          	auipc	a0,0x3
    80003dd8:	6ec50513          	addi	a0,a0,1772 # 800074c0 <etext+0x4c0>
    80003ddc:	a05fc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    80003de0:	00003517          	auipc	a0,0x3
    80003de4:	6f850513          	addi	a0,a0,1784 # 800074d8 <etext+0x4d8>
    80003de8:	9f9fc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dec:	24c1                	addiw	s1,s1,16
    80003dee:	04c92783          	lw	a5,76(s2)
    80003df2:	04f4f163          	bgeu	s1,a5,80003e34 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003df6:	4741                	li	a4,16
    80003df8:	86a6                	mv	a3,s1
    80003dfa:	fc040613          	addi	a2,s0,-64
    80003dfe:	4581                	li	a1,0
    80003e00:	854a                	mv	a0,s2
    80003e02:	d89ff0ef          	jal	80003b8a <readi>
    80003e06:	47c1                	li	a5,16
    80003e08:	fcf51ce3          	bne	a0,a5,80003de0 <dirlookup+0x36>
    if(de.inum == 0)
    80003e0c:	fc045783          	lhu	a5,-64(s0)
    80003e10:	dff1                	beqz	a5,80003dec <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003e12:	fc240593          	addi	a1,s0,-62
    80003e16:	854e                	mv	a0,s3
    80003e18:	f7dff0ef          	jal	80003d94 <namecmp>
    80003e1c:	f961                	bnez	a0,80003dec <dirlookup+0x42>
      if(poff)
    80003e1e:	000a0463          	beqz	s4,80003e26 <dirlookup+0x7c>
        *poff = off;
    80003e22:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e26:	fc045583          	lhu	a1,-64(s0)
    80003e2a:	00092503          	lw	a0,0(s2)
    80003e2e:	f58ff0ef          	jal	80003586 <iget>
    80003e32:	a011                	j	80003e36 <dirlookup+0x8c>
  return 0;
    80003e34:	4501                	li	a0,0
}
    80003e36:	70e2                	ld	ra,56(sp)
    80003e38:	7442                	ld	s0,48(sp)
    80003e3a:	74a2                	ld	s1,40(sp)
    80003e3c:	7902                	ld	s2,32(sp)
    80003e3e:	69e2                	ld	s3,24(sp)
    80003e40:	6a42                	ld	s4,16(sp)
    80003e42:	6121                	addi	sp,sp,64
    80003e44:	8082                	ret

0000000080003e46 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e46:	711d                	addi	sp,sp,-96
    80003e48:	ec86                	sd	ra,88(sp)
    80003e4a:	e8a2                	sd	s0,80(sp)
    80003e4c:	e4a6                	sd	s1,72(sp)
    80003e4e:	e0ca                	sd	s2,64(sp)
    80003e50:	fc4e                	sd	s3,56(sp)
    80003e52:	f852                	sd	s4,48(sp)
    80003e54:	f456                	sd	s5,40(sp)
    80003e56:	f05a                	sd	s6,32(sp)
    80003e58:	ec5e                	sd	s7,24(sp)
    80003e5a:	e862                	sd	s8,16(sp)
    80003e5c:	e466                	sd	s9,8(sp)
    80003e5e:	1080                	addi	s0,sp,96
    80003e60:	84aa                	mv	s1,a0
    80003e62:	8b2e                	mv	s6,a1
    80003e64:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e66:	00054703          	lbu	a4,0(a0)
    80003e6a:	02f00793          	li	a5,47
    80003e6e:	00f70e63          	beq	a4,a5,80003e8a <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e72:	a61fd0ef          	jal	800018d2 <myproc>
    80003e76:	15853503          	ld	a0,344(a0)
    80003e7a:	94bff0ef          	jal	800037c4 <idup>
    80003e7e:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003e80:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003e84:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e86:	4b85                	li	s7,1
    80003e88:	a871                	j	80003f24 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003e8a:	4585                	li	a1,1
    80003e8c:	4505                	li	a0,1
    80003e8e:	ef8ff0ef          	jal	80003586 <iget>
    80003e92:	8a2a                	mv	s4,a0
    80003e94:	b7f5                	j	80003e80 <namex+0x3a>
      iunlockput(ip);
    80003e96:	8552                	mv	a0,s4
    80003e98:	b6dff0ef          	jal	80003a04 <iunlockput>
      return 0;
    80003e9c:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e9e:	8552                	mv	a0,s4
    80003ea0:	60e6                	ld	ra,88(sp)
    80003ea2:	6446                	ld	s0,80(sp)
    80003ea4:	64a6                	ld	s1,72(sp)
    80003ea6:	6906                	ld	s2,64(sp)
    80003ea8:	79e2                	ld	s3,56(sp)
    80003eaa:	7a42                	ld	s4,48(sp)
    80003eac:	7aa2                	ld	s5,40(sp)
    80003eae:	7b02                	ld	s6,32(sp)
    80003eb0:	6be2                	ld	s7,24(sp)
    80003eb2:	6c42                	ld	s8,16(sp)
    80003eb4:	6ca2                	ld	s9,8(sp)
    80003eb6:	6125                	addi	sp,sp,96
    80003eb8:	8082                	ret
      iunlock(ip);
    80003eba:	8552                	mv	a0,s4
    80003ebc:	9edff0ef          	jal	800038a8 <iunlock>
      return ip;
    80003ec0:	bff9                	j	80003e9e <namex+0x58>
      iunlockput(ip);
    80003ec2:	8552                	mv	a0,s4
    80003ec4:	b41ff0ef          	jal	80003a04 <iunlockput>
      return 0;
    80003ec8:	8a4e                	mv	s4,s3
    80003eca:	bfd1                	j	80003e9e <namex+0x58>
  len = path - s;
    80003ecc:	40998633          	sub	a2,s3,s1
    80003ed0:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003ed4:	099c5063          	bge	s8,s9,80003f54 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003ed8:	4639                	li	a2,14
    80003eda:	85a6                	mv	a1,s1
    80003edc:	8556                	mv	a0,s5
    80003ede:	e21fc0ef          	jal	80000cfe <memmove>
    80003ee2:	84ce                	mv	s1,s3
  while(*path == '/')
    80003ee4:	0004c783          	lbu	a5,0(s1)
    80003ee8:	01279763          	bne	a5,s2,80003ef6 <namex+0xb0>
    path++;
    80003eec:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003eee:	0004c783          	lbu	a5,0(s1)
    80003ef2:	ff278de3          	beq	a5,s2,80003eec <namex+0xa6>
    ilock(ip);
    80003ef6:	8552                	mv	a0,s4
    80003ef8:	903ff0ef          	jal	800037fa <ilock>
    if(ip->type != T_DIR){
    80003efc:	044a1783          	lh	a5,68(s4)
    80003f00:	f9779be3          	bne	a5,s7,80003e96 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003f04:	000b0563          	beqz	s6,80003f0e <namex+0xc8>
    80003f08:	0004c783          	lbu	a5,0(s1)
    80003f0c:	d7dd                	beqz	a5,80003eba <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f0e:	4601                	li	a2,0
    80003f10:	85d6                	mv	a1,s5
    80003f12:	8552                	mv	a0,s4
    80003f14:	e97ff0ef          	jal	80003daa <dirlookup>
    80003f18:	89aa                	mv	s3,a0
    80003f1a:	d545                	beqz	a0,80003ec2 <namex+0x7c>
    iunlockput(ip);
    80003f1c:	8552                	mv	a0,s4
    80003f1e:	ae7ff0ef          	jal	80003a04 <iunlockput>
    ip = next;
    80003f22:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003f24:	0004c783          	lbu	a5,0(s1)
    80003f28:	01279763          	bne	a5,s2,80003f36 <namex+0xf0>
    path++;
    80003f2c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f2e:	0004c783          	lbu	a5,0(s1)
    80003f32:	ff278de3          	beq	a5,s2,80003f2c <namex+0xe6>
  if(*path == 0)
    80003f36:	cb8d                	beqz	a5,80003f68 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003f38:	0004c783          	lbu	a5,0(s1)
    80003f3c:	89a6                	mv	s3,s1
  len = path - s;
    80003f3e:	4c81                	li	s9,0
    80003f40:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003f42:	01278963          	beq	a5,s2,80003f54 <namex+0x10e>
    80003f46:	d3d9                	beqz	a5,80003ecc <namex+0x86>
    path++;
    80003f48:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003f4a:	0009c783          	lbu	a5,0(s3)
    80003f4e:	ff279ce3          	bne	a5,s2,80003f46 <namex+0x100>
    80003f52:	bfad                	j	80003ecc <namex+0x86>
    memmove(name, s, len);
    80003f54:	2601                	sext.w	a2,a2
    80003f56:	85a6                	mv	a1,s1
    80003f58:	8556                	mv	a0,s5
    80003f5a:	da5fc0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    80003f5e:	9cd6                	add	s9,s9,s5
    80003f60:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003f64:	84ce                	mv	s1,s3
    80003f66:	bfbd                	j	80003ee4 <namex+0x9e>
  if(nameiparent){
    80003f68:	f20b0be3          	beqz	s6,80003e9e <namex+0x58>
    iput(ip);
    80003f6c:	8552                	mv	a0,s4
    80003f6e:	a0fff0ef          	jal	8000397c <iput>
    return 0;
    80003f72:	4a01                	li	s4,0
    80003f74:	b72d                	j	80003e9e <namex+0x58>

0000000080003f76 <dirlink>:
{
    80003f76:	7139                	addi	sp,sp,-64
    80003f78:	fc06                	sd	ra,56(sp)
    80003f7a:	f822                	sd	s0,48(sp)
    80003f7c:	f04a                	sd	s2,32(sp)
    80003f7e:	ec4e                	sd	s3,24(sp)
    80003f80:	e852                	sd	s4,16(sp)
    80003f82:	0080                	addi	s0,sp,64
    80003f84:	892a                	mv	s2,a0
    80003f86:	8a2e                	mv	s4,a1
    80003f88:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f8a:	4601                	li	a2,0
    80003f8c:	e1fff0ef          	jal	80003daa <dirlookup>
    80003f90:	e535                	bnez	a0,80003ffc <dirlink+0x86>
    80003f92:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f94:	04c92483          	lw	s1,76(s2)
    80003f98:	c48d                	beqz	s1,80003fc2 <dirlink+0x4c>
    80003f9a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f9c:	4741                	li	a4,16
    80003f9e:	86a6                	mv	a3,s1
    80003fa0:	fc040613          	addi	a2,s0,-64
    80003fa4:	4581                	li	a1,0
    80003fa6:	854a                	mv	a0,s2
    80003fa8:	be3ff0ef          	jal	80003b8a <readi>
    80003fac:	47c1                	li	a5,16
    80003fae:	04f51b63          	bne	a0,a5,80004004 <dirlink+0x8e>
    if(de.inum == 0)
    80003fb2:	fc045783          	lhu	a5,-64(s0)
    80003fb6:	c791                	beqz	a5,80003fc2 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fb8:	24c1                	addiw	s1,s1,16
    80003fba:	04c92783          	lw	a5,76(s2)
    80003fbe:	fcf4efe3          	bltu	s1,a5,80003f9c <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003fc2:	4639                	li	a2,14
    80003fc4:	85d2                	mv	a1,s4
    80003fc6:	fc240513          	addi	a0,s0,-62
    80003fca:	ddbfc0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    80003fce:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fd2:	4741                	li	a4,16
    80003fd4:	86a6                	mv	a3,s1
    80003fd6:	fc040613          	addi	a2,s0,-64
    80003fda:	4581                	li	a1,0
    80003fdc:	854a                	mv	a0,s2
    80003fde:	ca9ff0ef          	jal	80003c86 <writei>
    80003fe2:	1541                	addi	a0,a0,-16
    80003fe4:	00a03533          	snez	a0,a0
    80003fe8:	40a00533          	neg	a0,a0
    80003fec:	74a2                	ld	s1,40(sp)
}
    80003fee:	70e2                	ld	ra,56(sp)
    80003ff0:	7442                	ld	s0,48(sp)
    80003ff2:	7902                	ld	s2,32(sp)
    80003ff4:	69e2                	ld	s3,24(sp)
    80003ff6:	6a42                	ld	s4,16(sp)
    80003ff8:	6121                	addi	sp,sp,64
    80003ffa:	8082                	ret
    iput(ip);
    80003ffc:	981ff0ef          	jal	8000397c <iput>
    return -1;
    80004000:	557d                	li	a0,-1
    80004002:	b7f5                	j	80003fee <dirlink+0x78>
      panic("dirlink read");
    80004004:	00003517          	auipc	a0,0x3
    80004008:	4e450513          	addi	a0,a0,1252 # 800074e8 <etext+0x4e8>
    8000400c:	fd4fc0ef          	jal	800007e0 <panic>

0000000080004010 <namei>:

struct inode*
namei(char *path)
{
    80004010:	1101                	addi	sp,sp,-32
    80004012:	ec06                	sd	ra,24(sp)
    80004014:	e822                	sd	s0,16(sp)
    80004016:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004018:	fe040613          	addi	a2,s0,-32
    8000401c:	4581                	li	a1,0
    8000401e:	e29ff0ef          	jal	80003e46 <namex>
}
    80004022:	60e2                	ld	ra,24(sp)
    80004024:	6442                	ld	s0,16(sp)
    80004026:	6105                	addi	sp,sp,32
    80004028:	8082                	ret

000000008000402a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000402a:	1141                	addi	sp,sp,-16
    8000402c:	e406                	sd	ra,8(sp)
    8000402e:	e022                	sd	s0,0(sp)
    80004030:	0800                	addi	s0,sp,16
    80004032:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004034:	4585                	li	a1,1
    80004036:	e11ff0ef          	jal	80003e46 <namex>
}
    8000403a:	60a2                	ld	ra,8(sp)
    8000403c:	6402                	ld	s0,0(sp)
    8000403e:	0141                	addi	sp,sp,16
    80004040:	8082                	ret

0000000080004042 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004042:	1101                	addi	sp,sp,-32
    80004044:	ec06                	sd	ra,24(sp)
    80004046:	e822                	sd	s0,16(sp)
    80004048:	e426                	sd	s1,8(sp)
    8000404a:	e04a                	sd	s2,0(sp)
    8000404c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000404e:	0001f917          	auipc	s2,0x1f
    80004052:	53290913          	addi	s2,s2,1330 # 80023580 <log>
    80004056:	01892583          	lw	a1,24(s2)
    8000405a:	02492503          	lw	a0,36(s2)
    8000405e:	8d0ff0ef          	jal	8000312e <bread>
    80004062:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004064:	02892603          	lw	a2,40(s2)
    80004068:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000406a:	00c05f63          	blez	a2,80004088 <write_head+0x46>
    8000406e:	0001f717          	auipc	a4,0x1f
    80004072:	53e70713          	addi	a4,a4,1342 # 800235ac <log+0x2c>
    80004076:	87aa                	mv	a5,a0
    80004078:	060a                	slli	a2,a2,0x2
    8000407a:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    8000407c:	4314                	lw	a3,0(a4)
    8000407e:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004080:	0711                	addi	a4,a4,4
    80004082:	0791                	addi	a5,a5,4
    80004084:	fec79ce3          	bne	a5,a2,8000407c <write_head+0x3a>
  }
  bwrite(buf);
    80004088:	8526                	mv	a0,s1
    8000408a:	97aff0ef          	jal	80003204 <bwrite>
  brelse(buf);
    8000408e:	8526                	mv	a0,s1
    80004090:	9a6ff0ef          	jal	80003236 <brelse>
}
    80004094:	60e2                	ld	ra,24(sp)
    80004096:	6442                	ld	s0,16(sp)
    80004098:	64a2                	ld	s1,8(sp)
    8000409a:	6902                	ld	s2,0(sp)
    8000409c:	6105                	addi	sp,sp,32
    8000409e:	8082                	ret

00000000800040a0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040a0:	0001f797          	auipc	a5,0x1f
    800040a4:	5087a783          	lw	a5,1288(a5) # 800235a8 <log+0x28>
    800040a8:	0af05e63          	blez	a5,80004164 <install_trans+0xc4>
{
    800040ac:	715d                	addi	sp,sp,-80
    800040ae:	e486                	sd	ra,72(sp)
    800040b0:	e0a2                	sd	s0,64(sp)
    800040b2:	fc26                	sd	s1,56(sp)
    800040b4:	f84a                	sd	s2,48(sp)
    800040b6:	f44e                	sd	s3,40(sp)
    800040b8:	f052                	sd	s4,32(sp)
    800040ba:	ec56                	sd	s5,24(sp)
    800040bc:	e85a                	sd	s6,16(sp)
    800040be:	e45e                	sd	s7,8(sp)
    800040c0:	0880                	addi	s0,sp,80
    800040c2:	8b2a                	mv	s6,a0
    800040c4:	0001fa97          	auipc	s5,0x1f
    800040c8:	4e8a8a93          	addi	s5,s5,1256 # 800235ac <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040cc:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800040ce:	00003b97          	auipc	s7,0x3
    800040d2:	42ab8b93          	addi	s7,s7,1066 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800040d6:	0001fa17          	auipc	s4,0x1f
    800040da:	4aaa0a13          	addi	s4,s4,1194 # 80023580 <log>
    800040de:	a025                	j	80004106 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800040e0:	000aa603          	lw	a2,0(s5)
    800040e4:	85ce                	mv	a1,s3
    800040e6:	855e                	mv	a0,s7
    800040e8:	c12fc0ef          	jal	800004fa <printf>
    800040ec:	a839                	j	8000410a <install_trans+0x6a>
    brelse(lbuf);
    800040ee:	854a                	mv	a0,s2
    800040f0:	946ff0ef          	jal	80003236 <brelse>
    brelse(dbuf);
    800040f4:	8526                	mv	a0,s1
    800040f6:	940ff0ef          	jal	80003236 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040fa:	2985                	addiw	s3,s3,1
    800040fc:	0a91                	addi	s5,s5,4
    800040fe:	028a2783          	lw	a5,40(s4)
    80004102:	04f9d663          	bge	s3,a5,8000414e <install_trans+0xae>
    if(recovering) {
    80004106:	fc0b1de3          	bnez	s6,800040e0 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000410a:	018a2583          	lw	a1,24(s4)
    8000410e:	013585bb          	addw	a1,a1,s3
    80004112:	2585                	addiw	a1,a1,1
    80004114:	024a2503          	lw	a0,36(s4)
    80004118:	816ff0ef          	jal	8000312e <bread>
    8000411c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000411e:	000aa583          	lw	a1,0(s5)
    80004122:	024a2503          	lw	a0,36(s4)
    80004126:	808ff0ef          	jal	8000312e <bread>
    8000412a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000412c:	40000613          	li	a2,1024
    80004130:	05890593          	addi	a1,s2,88
    80004134:	05850513          	addi	a0,a0,88
    80004138:	bc7fc0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    8000413c:	8526                	mv	a0,s1
    8000413e:	8c6ff0ef          	jal	80003204 <bwrite>
    if(recovering == 0)
    80004142:	fa0b16e3          	bnez	s6,800040ee <install_trans+0x4e>
      bunpin(dbuf);
    80004146:	8526                	mv	a0,s1
    80004148:	9aaff0ef          	jal	800032f2 <bunpin>
    8000414c:	b74d                	j	800040ee <install_trans+0x4e>
}
    8000414e:	60a6                	ld	ra,72(sp)
    80004150:	6406                	ld	s0,64(sp)
    80004152:	74e2                	ld	s1,56(sp)
    80004154:	7942                	ld	s2,48(sp)
    80004156:	79a2                	ld	s3,40(sp)
    80004158:	7a02                	ld	s4,32(sp)
    8000415a:	6ae2                	ld	s5,24(sp)
    8000415c:	6b42                	ld	s6,16(sp)
    8000415e:	6ba2                	ld	s7,8(sp)
    80004160:	6161                	addi	sp,sp,80
    80004162:	8082                	ret
    80004164:	8082                	ret

0000000080004166 <initlog>:
{
    80004166:	7179                	addi	sp,sp,-48
    80004168:	f406                	sd	ra,40(sp)
    8000416a:	f022                	sd	s0,32(sp)
    8000416c:	ec26                	sd	s1,24(sp)
    8000416e:	e84a                	sd	s2,16(sp)
    80004170:	e44e                	sd	s3,8(sp)
    80004172:	1800                	addi	s0,sp,48
    80004174:	892a                	mv	s2,a0
    80004176:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004178:	0001f497          	auipc	s1,0x1f
    8000417c:	40848493          	addi	s1,s1,1032 # 80023580 <log>
    80004180:	00003597          	auipc	a1,0x3
    80004184:	39858593          	addi	a1,a1,920 # 80007518 <etext+0x518>
    80004188:	8526                	mv	a0,s1
    8000418a:	9c5fc0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    8000418e:	0149a583          	lw	a1,20(s3)
    80004192:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80004194:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004198:	854a                	mv	a0,s2
    8000419a:	f95fe0ef          	jal	8000312e <bread>
  log.lh.n = lh->n;
    8000419e:	4d30                	lw	a2,88(a0)
    800041a0:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    800041a2:	00c05f63          	blez	a2,800041c0 <initlog+0x5a>
    800041a6:	87aa                	mv	a5,a0
    800041a8:	0001f717          	auipc	a4,0x1f
    800041ac:	40470713          	addi	a4,a4,1028 # 800235ac <log+0x2c>
    800041b0:	060a                	slli	a2,a2,0x2
    800041b2:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800041b4:	4ff4                	lw	a3,92(a5)
    800041b6:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800041b8:	0791                	addi	a5,a5,4
    800041ba:	0711                	addi	a4,a4,4
    800041bc:	fec79ce3          	bne	a5,a2,800041b4 <initlog+0x4e>
  brelse(buf);
    800041c0:	876ff0ef          	jal	80003236 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800041c4:	4505                	li	a0,1
    800041c6:	edbff0ef          	jal	800040a0 <install_trans>
  log.lh.n = 0;
    800041ca:	0001f797          	auipc	a5,0x1f
    800041ce:	3c07af23          	sw	zero,990(a5) # 800235a8 <log+0x28>
  write_head(); // clear the log
    800041d2:	e71ff0ef          	jal	80004042 <write_head>
}
    800041d6:	70a2                	ld	ra,40(sp)
    800041d8:	7402                	ld	s0,32(sp)
    800041da:	64e2                	ld	s1,24(sp)
    800041dc:	6942                	ld	s2,16(sp)
    800041de:	69a2                	ld	s3,8(sp)
    800041e0:	6145                	addi	sp,sp,48
    800041e2:	8082                	ret

00000000800041e4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800041e4:	1101                	addi	sp,sp,-32
    800041e6:	ec06                	sd	ra,24(sp)
    800041e8:	e822                	sd	s0,16(sp)
    800041ea:	e426                	sd	s1,8(sp)
    800041ec:	e04a                	sd	s2,0(sp)
    800041ee:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800041f0:	0001f517          	auipc	a0,0x1f
    800041f4:	39050513          	addi	a0,a0,912 # 80023580 <log>
    800041f8:	9d7fc0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    800041fc:	0001f497          	auipc	s1,0x1f
    80004200:	38448493          	addi	s1,s1,900 # 80023580 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004204:	4979                	li	s2,30
    80004206:	a029                	j	80004210 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80004208:	85a6                	mv	a1,s1
    8000420a:	8526                	mv	a0,s1
    8000420c:	d01fd0ef          	jal	80001f0c <sleep>
    if(log.committing){
    80004210:	509c                	lw	a5,32(s1)
    80004212:	fbfd                	bnez	a5,80004208 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004214:	4cd8                	lw	a4,28(s1)
    80004216:	2705                	addiw	a4,a4,1
    80004218:	0027179b          	slliw	a5,a4,0x2
    8000421c:	9fb9                	addw	a5,a5,a4
    8000421e:	0017979b          	slliw	a5,a5,0x1
    80004222:	5494                	lw	a3,40(s1)
    80004224:	9fb5                	addw	a5,a5,a3
    80004226:	00f95763          	bge	s2,a5,80004234 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000422a:	85a6                	mv	a1,s1
    8000422c:	8526                	mv	a0,s1
    8000422e:	cdffd0ef          	jal	80001f0c <sleep>
    80004232:	bff9                	j	80004210 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80004234:	0001f517          	auipc	a0,0x1f
    80004238:	34c50513          	addi	a0,a0,844 # 80023580 <log>
    8000423c:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    8000423e:	a29fc0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80004242:	60e2                	ld	ra,24(sp)
    80004244:	6442                	ld	s0,16(sp)
    80004246:	64a2                	ld	s1,8(sp)
    80004248:	6902                	ld	s2,0(sp)
    8000424a:	6105                	addi	sp,sp,32
    8000424c:	8082                	ret

000000008000424e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000424e:	7139                	addi	sp,sp,-64
    80004250:	fc06                	sd	ra,56(sp)
    80004252:	f822                	sd	s0,48(sp)
    80004254:	f426                	sd	s1,40(sp)
    80004256:	f04a                	sd	s2,32(sp)
    80004258:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000425a:	0001f497          	auipc	s1,0x1f
    8000425e:	32648493          	addi	s1,s1,806 # 80023580 <log>
    80004262:	8526                	mv	a0,s1
    80004264:	96bfc0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80004268:	4cdc                	lw	a5,28(s1)
    8000426a:	37fd                	addiw	a5,a5,-1
    8000426c:	0007891b          	sext.w	s2,a5
    80004270:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80004272:	509c                	lw	a5,32(s1)
    80004274:	ef9d                	bnez	a5,800042b2 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80004276:	04091763          	bnez	s2,800042c4 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    8000427a:	0001f497          	auipc	s1,0x1f
    8000427e:	30648493          	addi	s1,s1,774 # 80023580 <log>
    80004282:	4785                	li	a5,1
    80004284:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004286:	8526                	mv	a0,s1
    80004288:	9dffc0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000428c:	549c                	lw	a5,40(s1)
    8000428e:	04f04b63          	bgtz	a5,800042e4 <end_op+0x96>
    acquire(&log.lock);
    80004292:	0001f497          	auipc	s1,0x1f
    80004296:	2ee48493          	addi	s1,s1,750 # 80023580 <log>
    8000429a:	8526                	mv	a0,s1
    8000429c:	933fc0ef          	jal	80000bce <acquire>
    log.committing = 0;
    800042a0:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    800042a4:	8526                	mv	a0,s1
    800042a6:	cb3fd0ef          	jal	80001f58 <wakeup>
    release(&log.lock);
    800042aa:	8526                	mv	a0,s1
    800042ac:	9bbfc0ef          	jal	80000c66 <release>
}
    800042b0:	a025                	j	800042d8 <end_op+0x8a>
    800042b2:	ec4e                	sd	s3,24(sp)
    800042b4:	e852                	sd	s4,16(sp)
    800042b6:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800042b8:	00003517          	auipc	a0,0x3
    800042bc:	26850513          	addi	a0,a0,616 # 80007520 <etext+0x520>
    800042c0:	d20fc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    800042c4:	0001f497          	auipc	s1,0x1f
    800042c8:	2bc48493          	addi	s1,s1,700 # 80023580 <log>
    800042cc:	8526                	mv	a0,s1
    800042ce:	c8bfd0ef          	jal	80001f58 <wakeup>
  release(&log.lock);
    800042d2:	8526                	mv	a0,s1
    800042d4:	993fc0ef          	jal	80000c66 <release>
}
    800042d8:	70e2                	ld	ra,56(sp)
    800042da:	7442                	ld	s0,48(sp)
    800042dc:	74a2                	ld	s1,40(sp)
    800042de:	7902                	ld	s2,32(sp)
    800042e0:	6121                	addi	sp,sp,64
    800042e2:	8082                	ret
    800042e4:	ec4e                	sd	s3,24(sp)
    800042e6:	e852                	sd	s4,16(sp)
    800042e8:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800042ea:	0001fa97          	auipc	s5,0x1f
    800042ee:	2c2a8a93          	addi	s5,s5,706 # 800235ac <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800042f2:	0001fa17          	auipc	s4,0x1f
    800042f6:	28ea0a13          	addi	s4,s4,654 # 80023580 <log>
    800042fa:	018a2583          	lw	a1,24(s4)
    800042fe:	012585bb          	addw	a1,a1,s2
    80004302:	2585                	addiw	a1,a1,1
    80004304:	024a2503          	lw	a0,36(s4)
    80004308:	e27fe0ef          	jal	8000312e <bread>
    8000430c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000430e:	000aa583          	lw	a1,0(s5)
    80004312:	024a2503          	lw	a0,36(s4)
    80004316:	e19fe0ef          	jal	8000312e <bread>
    8000431a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000431c:	40000613          	li	a2,1024
    80004320:	05850593          	addi	a1,a0,88
    80004324:	05848513          	addi	a0,s1,88
    80004328:	9d7fc0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    8000432c:	8526                	mv	a0,s1
    8000432e:	ed7fe0ef          	jal	80003204 <bwrite>
    brelse(from);
    80004332:	854e                	mv	a0,s3
    80004334:	f03fe0ef          	jal	80003236 <brelse>
    brelse(to);
    80004338:	8526                	mv	a0,s1
    8000433a:	efdfe0ef          	jal	80003236 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000433e:	2905                	addiw	s2,s2,1
    80004340:	0a91                	addi	s5,s5,4
    80004342:	028a2783          	lw	a5,40(s4)
    80004346:	faf94ae3          	blt	s2,a5,800042fa <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000434a:	cf9ff0ef          	jal	80004042 <write_head>
    install_trans(0); // Now install writes to home locations
    8000434e:	4501                	li	a0,0
    80004350:	d51ff0ef          	jal	800040a0 <install_trans>
    log.lh.n = 0;
    80004354:	0001f797          	auipc	a5,0x1f
    80004358:	2407aa23          	sw	zero,596(a5) # 800235a8 <log+0x28>
    write_head();    // Erase the transaction from the log
    8000435c:	ce7ff0ef          	jal	80004042 <write_head>
    80004360:	69e2                	ld	s3,24(sp)
    80004362:	6a42                	ld	s4,16(sp)
    80004364:	6aa2                	ld	s5,8(sp)
    80004366:	b735                	j	80004292 <end_op+0x44>

0000000080004368 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004368:	1101                	addi	sp,sp,-32
    8000436a:	ec06                	sd	ra,24(sp)
    8000436c:	e822                	sd	s0,16(sp)
    8000436e:	e426                	sd	s1,8(sp)
    80004370:	e04a                	sd	s2,0(sp)
    80004372:	1000                	addi	s0,sp,32
    80004374:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004376:	0001f917          	auipc	s2,0x1f
    8000437a:	20a90913          	addi	s2,s2,522 # 80023580 <log>
    8000437e:	854a                	mv	a0,s2
    80004380:	84ffc0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004384:	02892603          	lw	a2,40(s2)
    80004388:	47f5                	li	a5,29
    8000438a:	04c7cc63          	blt	a5,a2,800043e2 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000438e:	0001f797          	auipc	a5,0x1f
    80004392:	20e7a783          	lw	a5,526(a5) # 8002359c <log+0x1c>
    80004396:	04f05c63          	blez	a5,800043ee <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000439a:	4781                	li	a5,0
    8000439c:	04c05f63          	blez	a2,800043fa <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043a0:	44cc                	lw	a1,12(s1)
    800043a2:	0001f717          	auipc	a4,0x1f
    800043a6:	20a70713          	addi	a4,a4,522 # 800235ac <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    800043aa:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043ac:	4314                	lw	a3,0(a4)
    800043ae:	04b68663          	beq	a3,a1,800043fa <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    800043b2:	2785                	addiw	a5,a5,1
    800043b4:	0711                	addi	a4,a4,4
    800043b6:	fef61be3          	bne	a2,a5,800043ac <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    800043ba:	0621                	addi	a2,a2,8
    800043bc:	060a                	slli	a2,a2,0x2
    800043be:	0001f797          	auipc	a5,0x1f
    800043c2:	1c278793          	addi	a5,a5,450 # 80023580 <log>
    800043c6:	97b2                	add	a5,a5,a2
    800043c8:	44d8                	lw	a4,12(s1)
    800043ca:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800043cc:	8526                	mv	a0,s1
    800043ce:	ef1fe0ef          	jal	800032be <bpin>
    log.lh.n++;
    800043d2:	0001f717          	auipc	a4,0x1f
    800043d6:	1ae70713          	addi	a4,a4,430 # 80023580 <log>
    800043da:	571c                	lw	a5,40(a4)
    800043dc:	2785                	addiw	a5,a5,1
    800043de:	d71c                	sw	a5,40(a4)
    800043e0:	a80d                	j	80004412 <log_write+0xaa>
    panic("too big a transaction");
    800043e2:	00003517          	auipc	a0,0x3
    800043e6:	14e50513          	addi	a0,a0,334 # 80007530 <etext+0x530>
    800043ea:	bf6fc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    800043ee:	00003517          	auipc	a0,0x3
    800043f2:	15a50513          	addi	a0,a0,346 # 80007548 <etext+0x548>
    800043f6:	beafc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    800043fa:	00878693          	addi	a3,a5,8
    800043fe:	068a                	slli	a3,a3,0x2
    80004400:	0001f717          	auipc	a4,0x1f
    80004404:	18070713          	addi	a4,a4,384 # 80023580 <log>
    80004408:	9736                	add	a4,a4,a3
    8000440a:	44d4                	lw	a3,12(s1)
    8000440c:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000440e:	faf60fe3          	beq	a2,a5,800043cc <log_write+0x64>
  }
  release(&log.lock);
    80004412:	0001f517          	auipc	a0,0x1f
    80004416:	16e50513          	addi	a0,a0,366 # 80023580 <log>
    8000441a:	84dfc0ef          	jal	80000c66 <release>
}
    8000441e:	60e2                	ld	ra,24(sp)
    80004420:	6442                	ld	s0,16(sp)
    80004422:	64a2                	ld	s1,8(sp)
    80004424:	6902                	ld	s2,0(sp)
    80004426:	6105                	addi	sp,sp,32
    80004428:	8082                	ret

000000008000442a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000442a:	1101                	addi	sp,sp,-32
    8000442c:	ec06                	sd	ra,24(sp)
    8000442e:	e822                	sd	s0,16(sp)
    80004430:	e426                	sd	s1,8(sp)
    80004432:	e04a                	sd	s2,0(sp)
    80004434:	1000                	addi	s0,sp,32
    80004436:	84aa                	mv	s1,a0
    80004438:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000443a:	00003597          	auipc	a1,0x3
    8000443e:	12e58593          	addi	a1,a1,302 # 80007568 <etext+0x568>
    80004442:	0521                	addi	a0,a0,8
    80004444:	f0afc0ef          	jal	80000b4e <initlock>
  lk->name = name;
    80004448:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000444c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004450:	0204a423          	sw	zero,40(s1)
}
    80004454:	60e2                	ld	ra,24(sp)
    80004456:	6442                	ld	s0,16(sp)
    80004458:	64a2                	ld	s1,8(sp)
    8000445a:	6902                	ld	s2,0(sp)
    8000445c:	6105                	addi	sp,sp,32
    8000445e:	8082                	ret

0000000080004460 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004460:	1101                	addi	sp,sp,-32
    80004462:	ec06                	sd	ra,24(sp)
    80004464:	e822                	sd	s0,16(sp)
    80004466:	e426                	sd	s1,8(sp)
    80004468:	e04a                	sd	s2,0(sp)
    8000446a:	1000                	addi	s0,sp,32
    8000446c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000446e:	00850913          	addi	s2,a0,8
    80004472:	854a                	mv	a0,s2
    80004474:	f5afc0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    80004478:	409c                	lw	a5,0(s1)
    8000447a:	c799                	beqz	a5,80004488 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    8000447c:	85ca                	mv	a1,s2
    8000447e:	8526                	mv	a0,s1
    80004480:	a8dfd0ef          	jal	80001f0c <sleep>
  while (lk->locked) {
    80004484:	409c                	lw	a5,0(s1)
    80004486:	fbfd                	bnez	a5,8000447c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004488:	4785                	li	a5,1
    8000448a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000448c:	c46fd0ef          	jal	800018d2 <myproc>
    80004490:	591c                	lw	a5,48(a0)
    80004492:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004494:	854a                	mv	a0,s2
    80004496:	fd0fc0ef          	jal	80000c66 <release>
}
    8000449a:	60e2                	ld	ra,24(sp)
    8000449c:	6442                	ld	s0,16(sp)
    8000449e:	64a2                	ld	s1,8(sp)
    800044a0:	6902                	ld	s2,0(sp)
    800044a2:	6105                	addi	sp,sp,32
    800044a4:	8082                	ret

00000000800044a6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800044a6:	1101                	addi	sp,sp,-32
    800044a8:	ec06                	sd	ra,24(sp)
    800044aa:	e822                	sd	s0,16(sp)
    800044ac:	e426                	sd	s1,8(sp)
    800044ae:	e04a                	sd	s2,0(sp)
    800044b0:	1000                	addi	s0,sp,32
    800044b2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044b4:	00850913          	addi	s2,a0,8
    800044b8:	854a                	mv	a0,s2
    800044ba:	f14fc0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    800044be:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044c2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800044c6:	8526                	mv	a0,s1
    800044c8:	a91fd0ef          	jal	80001f58 <wakeup>
  release(&lk->lk);
    800044cc:	854a                	mv	a0,s2
    800044ce:	f98fc0ef          	jal	80000c66 <release>
}
    800044d2:	60e2                	ld	ra,24(sp)
    800044d4:	6442                	ld	s0,16(sp)
    800044d6:	64a2                	ld	s1,8(sp)
    800044d8:	6902                	ld	s2,0(sp)
    800044da:	6105                	addi	sp,sp,32
    800044dc:	8082                	ret

00000000800044de <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044de:	7179                	addi	sp,sp,-48
    800044e0:	f406                	sd	ra,40(sp)
    800044e2:	f022                	sd	s0,32(sp)
    800044e4:	ec26                	sd	s1,24(sp)
    800044e6:	e84a                	sd	s2,16(sp)
    800044e8:	1800                	addi	s0,sp,48
    800044ea:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044ec:	00850913          	addi	s2,a0,8
    800044f0:	854a                	mv	a0,s2
    800044f2:	edcfc0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800044f6:	409c                	lw	a5,0(s1)
    800044f8:	ef81                	bnez	a5,80004510 <holdingsleep+0x32>
    800044fa:	4481                	li	s1,0
  release(&lk->lk);
    800044fc:	854a                	mv	a0,s2
    800044fe:	f68fc0ef          	jal	80000c66 <release>
  return r;
}
    80004502:	8526                	mv	a0,s1
    80004504:	70a2                	ld	ra,40(sp)
    80004506:	7402                	ld	s0,32(sp)
    80004508:	64e2                	ld	s1,24(sp)
    8000450a:	6942                	ld	s2,16(sp)
    8000450c:	6145                	addi	sp,sp,48
    8000450e:	8082                	ret
    80004510:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004512:	0284a983          	lw	s3,40(s1)
    80004516:	bbcfd0ef          	jal	800018d2 <myproc>
    8000451a:	5904                	lw	s1,48(a0)
    8000451c:	413484b3          	sub	s1,s1,s3
    80004520:	0014b493          	seqz	s1,s1
    80004524:	69a2                	ld	s3,8(sp)
    80004526:	bfd9                	j	800044fc <holdingsleep+0x1e>

0000000080004528 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004528:	1141                	addi	sp,sp,-16
    8000452a:	e406                	sd	ra,8(sp)
    8000452c:	e022                	sd	s0,0(sp)
    8000452e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004530:	00003597          	auipc	a1,0x3
    80004534:	04858593          	addi	a1,a1,72 # 80007578 <etext+0x578>
    80004538:	0001f517          	auipc	a0,0x1f
    8000453c:	19050513          	addi	a0,a0,400 # 800236c8 <ftable>
    80004540:	e0efc0ef          	jal	80000b4e <initlock>
}
    80004544:	60a2                	ld	ra,8(sp)
    80004546:	6402                	ld	s0,0(sp)
    80004548:	0141                	addi	sp,sp,16
    8000454a:	8082                	ret

000000008000454c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000454c:	1101                	addi	sp,sp,-32
    8000454e:	ec06                	sd	ra,24(sp)
    80004550:	e822                	sd	s0,16(sp)
    80004552:	e426                	sd	s1,8(sp)
    80004554:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004556:	0001f517          	auipc	a0,0x1f
    8000455a:	17250513          	addi	a0,a0,370 # 800236c8 <ftable>
    8000455e:	e70fc0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004562:	0001f497          	auipc	s1,0x1f
    80004566:	17e48493          	addi	s1,s1,382 # 800236e0 <ftable+0x18>
    8000456a:	00020717          	auipc	a4,0x20
    8000456e:	11670713          	addi	a4,a4,278 # 80024680 <disk>
    if(f->ref == 0){
    80004572:	40dc                	lw	a5,4(s1)
    80004574:	cf89                	beqz	a5,8000458e <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004576:	02848493          	addi	s1,s1,40
    8000457a:	fee49ce3          	bne	s1,a4,80004572 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000457e:	0001f517          	auipc	a0,0x1f
    80004582:	14a50513          	addi	a0,a0,330 # 800236c8 <ftable>
    80004586:	ee0fc0ef          	jal	80000c66 <release>
  return 0;
    8000458a:	4481                	li	s1,0
    8000458c:	a809                	j	8000459e <filealloc+0x52>
      f->ref = 1;
    8000458e:	4785                	li	a5,1
    80004590:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004592:	0001f517          	auipc	a0,0x1f
    80004596:	13650513          	addi	a0,a0,310 # 800236c8 <ftable>
    8000459a:	eccfc0ef          	jal	80000c66 <release>
}
    8000459e:	8526                	mv	a0,s1
    800045a0:	60e2                	ld	ra,24(sp)
    800045a2:	6442                	ld	s0,16(sp)
    800045a4:	64a2                	ld	s1,8(sp)
    800045a6:	6105                	addi	sp,sp,32
    800045a8:	8082                	ret

00000000800045aa <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800045aa:	1101                	addi	sp,sp,-32
    800045ac:	ec06                	sd	ra,24(sp)
    800045ae:	e822                	sd	s0,16(sp)
    800045b0:	e426                	sd	s1,8(sp)
    800045b2:	1000                	addi	s0,sp,32
    800045b4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800045b6:	0001f517          	auipc	a0,0x1f
    800045ba:	11250513          	addi	a0,a0,274 # 800236c8 <ftable>
    800045be:	e10fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    800045c2:	40dc                	lw	a5,4(s1)
    800045c4:	02f05063          	blez	a5,800045e4 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800045c8:	2785                	addiw	a5,a5,1
    800045ca:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045cc:	0001f517          	auipc	a0,0x1f
    800045d0:	0fc50513          	addi	a0,a0,252 # 800236c8 <ftable>
    800045d4:	e92fc0ef          	jal	80000c66 <release>
  return f;
}
    800045d8:	8526                	mv	a0,s1
    800045da:	60e2                	ld	ra,24(sp)
    800045dc:	6442                	ld	s0,16(sp)
    800045de:	64a2                	ld	s1,8(sp)
    800045e0:	6105                	addi	sp,sp,32
    800045e2:	8082                	ret
    panic("filedup");
    800045e4:	00003517          	auipc	a0,0x3
    800045e8:	f9c50513          	addi	a0,a0,-100 # 80007580 <etext+0x580>
    800045ec:	9f4fc0ef          	jal	800007e0 <panic>

00000000800045f0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800045f0:	7139                	addi	sp,sp,-64
    800045f2:	fc06                	sd	ra,56(sp)
    800045f4:	f822                	sd	s0,48(sp)
    800045f6:	f426                	sd	s1,40(sp)
    800045f8:	0080                	addi	s0,sp,64
    800045fa:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800045fc:	0001f517          	auipc	a0,0x1f
    80004600:	0cc50513          	addi	a0,a0,204 # 800236c8 <ftable>
    80004604:	dcafc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80004608:	40dc                	lw	a5,4(s1)
    8000460a:	04f05a63          	blez	a5,8000465e <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    8000460e:	37fd                	addiw	a5,a5,-1
    80004610:	0007871b          	sext.w	a4,a5
    80004614:	c0dc                	sw	a5,4(s1)
    80004616:	04e04e63          	bgtz	a4,80004672 <fileclose+0x82>
    8000461a:	f04a                	sd	s2,32(sp)
    8000461c:	ec4e                	sd	s3,24(sp)
    8000461e:	e852                	sd	s4,16(sp)
    80004620:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004622:	0004a903          	lw	s2,0(s1)
    80004626:	0094ca83          	lbu	s5,9(s1)
    8000462a:	0104ba03          	ld	s4,16(s1)
    8000462e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004632:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004636:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000463a:	0001f517          	auipc	a0,0x1f
    8000463e:	08e50513          	addi	a0,a0,142 # 800236c8 <ftable>
    80004642:	e24fc0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    80004646:	4785                	li	a5,1
    80004648:	04f90063          	beq	s2,a5,80004688 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000464c:	3979                	addiw	s2,s2,-2
    8000464e:	4785                	li	a5,1
    80004650:	0527f563          	bgeu	a5,s2,8000469a <fileclose+0xaa>
    80004654:	7902                	ld	s2,32(sp)
    80004656:	69e2                	ld	s3,24(sp)
    80004658:	6a42                	ld	s4,16(sp)
    8000465a:	6aa2                	ld	s5,8(sp)
    8000465c:	a00d                	j	8000467e <fileclose+0x8e>
    8000465e:	f04a                	sd	s2,32(sp)
    80004660:	ec4e                	sd	s3,24(sp)
    80004662:	e852                	sd	s4,16(sp)
    80004664:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004666:	00003517          	auipc	a0,0x3
    8000466a:	f2250513          	addi	a0,a0,-222 # 80007588 <etext+0x588>
    8000466e:	972fc0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    80004672:	0001f517          	auipc	a0,0x1f
    80004676:	05650513          	addi	a0,a0,86 # 800236c8 <ftable>
    8000467a:	decfc0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000467e:	70e2                	ld	ra,56(sp)
    80004680:	7442                	ld	s0,48(sp)
    80004682:	74a2                	ld	s1,40(sp)
    80004684:	6121                	addi	sp,sp,64
    80004686:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004688:	85d6                	mv	a1,s5
    8000468a:	8552                	mv	a0,s4
    8000468c:	336000ef          	jal	800049c2 <pipeclose>
    80004690:	7902                	ld	s2,32(sp)
    80004692:	69e2                	ld	s3,24(sp)
    80004694:	6a42                	ld	s4,16(sp)
    80004696:	6aa2                	ld	s5,8(sp)
    80004698:	b7dd                	j	8000467e <fileclose+0x8e>
    begin_op();
    8000469a:	b4bff0ef          	jal	800041e4 <begin_op>
    iput(ff.ip);
    8000469e:	854e                	mv	a0,s3
    800046a0:	adcff0ef          	jal	8000397c <iput>
    end_op();
    800046a4:	babff0ef          	jal	8000424e <end_op>
    800046a8:	7902                	ld	s2,32(sp)
    800046aa:	69e2                	ld	s3,24(sp)
    800046ac:	6a42                	ld	s4,16(sp)
    800046ae:	6aa2                	ld	s5,8(sp)
    800046b0:	b7f9                	j	8000467e <fileclose+0x8e>

00000000800046b2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800046b2:	715d                	addi	sp,sp,-80
    800046b4:	e486                	sd	ra,72(sp)
    800046b6:	e0a2                	sd	s0,64(sp)
    800046b8:	fc26                	sd	s1,56(sp)
    800046ba:	f44e                	sd	s3,40(sp)
    800046bc:	0880                	addi	s0,sp,80
    800046be:	84aa                	mv	s1,a0
    800046c0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800046c2:	a10fd0ef          	jal	800018d2 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800046c6:	409c                	lw	a5,0(s1)
    800046c8:	37f9                	addiw	a5,a5,-2
    800046ca:	4705                	li	a4,1
    800046cc:	04f76063          	bltu	a4,a5,8000470c <filestat+0x5a>
    800046d0:	f84a                	sd	s2,48(sp)
    800046d2:	892a                	mv	s2,a0
    ilock(f->ip);
    800046d4:	6c88                	ld	a0,24(s1)
    800046d6:	924ff0ef          	jal	800037fa <ilock>
    stati(f->ip, &st);
    800046da:	fb840593          	addi	a1,s0,-72
    800046de:	6c88                	ld	a0,24(s1)
    800046e0:	c80ff0ef          	jal	80003b60 <stati>
    iunlock(f->ip);
    800046e4:	6c88                	ld	a0,24(s1)
    800046e6:	9c2ff0ef          	jal	800038a8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800046ea:	46e1                	li	a3,24
    800046ec:	fb840613          	addi	a2,s0,-72
    800046f0:	85ce                	mv	a1,s3
    800046f2:	05893503          	ld	a0,88(s2)
    800046f6:	ef1fc0ef          	jal	800015e6 <copyout>
    800046fa:	41f5551b          	sraiw	a0,a0,0x1f
    800046fe:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004700:	60a6                	ld	ra,72(sp)
    80004702:	6406                	ld	s0,64(sp)
    80004704:	74e2                	ld	s1,56(sp)
    80004706:	79a2                	ld	s3,40(sp)
    80004708:	6161                	addi	sp,sp,80
    8000470a:	8082                	ret
  return -1;
    8000470c:	557d                	li	a0,-1
    8000470e:	bfcd                	j	80004700 <filestat+0x4e>

0000000080004710 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004710:	7179                	addi	sp,sp,-48
    80004712:	f406                	sd	ra,40(sp)
    80004714:	f022                	sd	s0,32(sp)
    80004716:	e84a                	sd	s2,16(sp)
    80004718:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000471a:	00854783          	lbu	a5,8(a0)
    8000471e:	cfd1                	beqz	a5,800047ba <fileread+0xaa>
    80004720:	ec26                	sd	s1,24(sp)
    80004722:	e44e                	sd	s3,8(sp)
    80004724:	84aa                	mv	s1,a0
    80004726:	89ae                	mv	s3,a1
    80004728:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000472a:	411c                	lw	a5,0(a0)
    8000472c:	4705                	li	a4,1
    8000472e:	04e78363          	beq	a5,a4,80004774 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004732:	470d                	li	a4,3
    80004734:	04e78763          	beq	a5,a4,80004782 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004738:	4709                	li	a4,2
    8000473a:	06e79a63          	bne	a5,a4,800047ae <fileread+0x9e>
    ilock(f->ip);
    8000473e:	6d08                	ld	a0,24(a0)
    80004740:	8baff0ef          	jal	800037fa <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004744:	874a                	mv	a4,s2
    80004746:	5094                	lw	a3,32(s1)
    80004748:	864e                	mv	a2,s3
    8000474a:	4585                	li	a1,1
    8000474c:	6c88                	ld	a0,24(s1)
    8000474e:	c3cff0ef          	jal	80003b8a <readi>
    80004752:	892a                	mv	s2,a0
    80004754:	00a05563          	blez	a0,8000475e <fileread+0x4e>
      f->off += r;
    80004758:	509c                	lw	a5,32(s1)
    8000475a:	9fa9                	addw	a5,a5,a0
    8000475c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000475e:	6c88                	ld	a0,24(s1)
    80004760:	948ff0ef          	jal	800038a8 <iunlock>
    80004764:	64e2                	ld	s1,24(sp)
    80004766:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004768:	854a                	mv	a0,s2
    8000476a:	70a2                	ld	ra,40(sp)
    8000476c:	7402                	ld	s0,32(sp)
    8000476e:	6942                	ld	s2,16(sp)
    80004770:	6145                	addi	sp,sp,48
    80004772:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004774:	6908                	ld	a0,16(a0)
    80004776:	388000ef          	jal	80004afe <piperead>
    8000477a:	892a                	mv	s2,a0
    8000477c:	64e2                	ld	s1,24(sp)
    8000477e:	69a2                	ld	s3,8(sp)
    80004780:	b7e5                	j	80004768 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004782:	02451783          	lh	a5,36(a0)
    80004786:	03079693          	slli	a3,a5,0x30
    8000478a:	92c1                	srli	a3,a3,0x30
    8000478c:	4725                	li	a4,9
    8000478e:	02d76863          	bltu	a4,a3,800047be <fileread+0xae>
    80004792:	0792                	slli	a5,a5,0x4
    80004794:	0001f717          	auipc	a4,0x1f
    80004798:	e9470713          	addi	a4,a4,-364 # 80023628 <devsw>
    8000479c:	97ba                	add	a5,a5,a4
    8000479e:	639c                	ld	a5,0(a5)
    800047a0:	c39d                	beqz	a5,800047c6 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800047a2:	4505                	li	a0,1
    800047a4:	9782                	jalr	a5
    800047a6:	892a                	mv	s2,a0
    800047a8:	64e2                	ld	s1,24(sp)
    800047aa:	69a2                	ld	s3,8(sp)
    800047ac:	bf75                	j	80004768 <fileread+0x58>
    panic("fileread");
    800047ae:	00003517          	auipc	a0,0x3
    800047b2:	dea50513          	addi	a0,a0,-534 # 80007598 <etext+0x598>
    800047b6:	82afc0ef          	jal	800007e0 <panic>
    return -1;
    800047ba:	597d                	li	s2,-1
    800047bc:	b775                	j	80004768 <fileread+0x58>
      return -1;
    800047be:	597d                	li	s2,-1
    800047c0:	64e2                	ld	s1,24(sp)
    800047c2:	69a2                	ld	s3,8(sp)
    800047c4:	b755                	j	80004768 <fileread+0x58>
    800047c6:	597d                	li	s2,-1
    800047c8:	64e2                	ld	s1,24(sp)
    800047ca:	69a2                	ld	s3,8(sp)
    800047cc:	bf71                	j	80004768 <fileread+0x58>

00000000800047ce <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800047ce:	00954783          	lbu	a5,9(a0)
    800047d2:	10078b63          	beqz	a5,800048e8 <filewrite+0x11a>
{
    800047d6:	715d                	addi	sp,sp,-80
    800047d8:	e486                	sd	ra,72(sp)
    800047da:	e0a2                	sd	s0,64(sp)
    800047dc:	f84a                	sd	s2,48(sp)
    800047de:	f052                	sd	s4,32(sp)
    800047e0:	e85a                	sd	s6,16(sp)
    800047e2:	0880                	addi	s0,sp,80
    800047e4:	892a                	mv	s2,a0
    800047e6:	8b2e                	mv	s6,a1
    800047e8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800047ea:	411c                	lw	a5,0(a0)
    800047ec:	4705                	li	a4,1
    800047ee:	02e78763          	beq	a5,a4,8000481c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047f2:	470d                	li	a4,3
    800047f4:	02e78863          	beq	a5,a4,80004824 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800047f8:	4709                	li	a4,2
    800047fa:	0ce79c63          	bne	a5,a4,800048d2 <filewrite+0x104>
    800047fe:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004800:	0ac05863          	blez	a2,800048b0 <filewrite+0xe2>
    80004804:	fc26                	sd	s1,56(sp)
    80004806:	ec56                	sd	s5,24(sp)
    80004808:	e45e                	sd	s7,8(sp)
    8000480a:	e062                	sd	s8,0(sp)
    int i = 0;
    8000480c:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000480e:	6b85                	lui	s7,0x1
    80004810:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004814:	6c05                	lui	s8,0x1
    80004816:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000481a:	a8b5                	j	80004896 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    8000481c:	6908                	ld	a0,16(a0)
    8000481e:	1fc000ef          	jal	80004a1a <pipewrite>
    80004822:	a04d                	j	800048c4 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004824:	02451783          	lh	a5,36(a0)
    80004828:	03079693          	slli	a3,a5,0x30
    8000482c:	92c1                	srli	a3,a3,0x30
    8000482e:	4725                	li	a4,9
    80004830:	0ad76e63          	bltu	a4,a3,800048ec <filewrite+0x11e>
    80004834:	0792                	slli	a5,a5,0x4
    80004836:	0001f717          	auipc	a4,0x1f
    8000483a:	df270713          	addi	a4,a4,-526 # 80023628 <devsw>
    8000483e:	97ba                	add	a5,a5,a4
    80004840:	679c                	ld	a5,8(a5)
    80004842:	c7dd                	beqz	a5,800048f0 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004844:	4505                	li	a0,1
    80004846:	9782                	jalr	a5
    80004848:	a8b5                	j	800048c4 <filewrite+0xf6>
      if(n1 > max)
    8000484a:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    8000484e:	997ff0ef          	jal	800041e4 <begin_op>
      ilock(f->ip);
    80004852:	01893503          	ld	a0,24(s2)
    80004856:	fa5fe0ef          	jal	800037fa <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000485a:	8756                	mv	a4,s5
    8000485c:	02092683          	lw	a3,32(s2)
    80004860:	01698633          	add	a2,s3,s6
    80004864:	4585                	li	a1,1
    80004866:	01893503          	ld	a0,24(s2)
    8000486a:	c1cff0ef          	jal	80003c86 <writei>
    8000486e:	84aa                	mv	s1,a0
    80004870:	00a05763          	blez	a0,8000487e <filewrite+0xb0>
        f->off += r;
    80004874:	02092783          	lw	a5,32(s2)
    80004878:	9fa9                	addw	a5,a5,a0
    8000487a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000487e:	01893503          	ld	a0,24(s2)
    80004882:	826ff0ef          	jal	800038a8 <iunlock>
      end_op();
    80004886:	9c9ff0ef          	jal	8000424e <end_op>

      if(r != n1){
    8000488a:	029a9563          	bne	s5,s1,800048b4 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    8000488e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004892:	0149da63          	bge	s3,s4,800048a6 <filewrite+0xd8>
      int n1 = n - i;
    80004896:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000489a:	0004879b          	sext.w	a5,s1
    8000489e:	fafbd6e3          	bge	s7,a5,8000484a <filewrite+0x7c>
    800048a2:	84e2                	mv	s1,s8
    800048a4:	b75d                	j	8000484a <filewrite+0x7c>
    800048a6:	74e2                	ld	s1,56(sp)
    800048a8:	6ae2                	ld	s5,24(sp)
    800048aa:	6ba2                	ld	s7,8(sp)
    800048ac:	6c02                	ld	s8,0(sp)
    800048ae:	a039                	j	800048bc <filewrite+0xee>
    int i = 0;
    800048b0:	4981                	li	s3,0
    800048b2:	a029                	j	800048bc <filewrite+0xee>
    800048b4:	74e2                	ld	s1,56(sp)
    800048b6:	6ae2                	ld	s5,24(sp)
    800048b8:	6ba2                	ld	s7,8(sp)
    800048ba:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800048bc:	033a1c63          	bne	s4,s3,800048f4 <filewrite+0x126>
    800048c0:	8552                	mv	a0,s4
    800048c2:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800048c4:	60a6                	ld	ra,72(sp)
    800048c6:	6406                	ld	s0,64(sp)
    800048c8:	7942                	ld	s2,48(sp)
    800048ca:	7a02                	ld	s4,32(sp)
    800048cc:	6b42                	ld	s6,16(sp)
    800048ce:	6161                	addi	sp,sp,80
    800048d0:	8082                	ret
    800048d2:	fc26                	sd	s1,56(sp)
    800048d4:	f44e                	sd	s3,40(sp)
    800048d6:	ec56                	sd	s5,24(sp)
    800048d8:	e45e                	sd	s7,8(sp)
    800048da:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800048dc:	00003517          	auipc	a0,0x3
    800048e0:	ccc50513          	addi	a0,a0,-820 # 800075a8 <etext+0x5a8>
    800048e4:	efdfb0ef          	jal	800007e0 <panic>
    return -1;
    800048e8:	557d                	li	a0,-1
}
    800048ea:	8082                	ret
      return -1;
    800048ec:	557d                	li	a0,-1
    800048ee:	bfd9                	j	800048c4 <filewrite+0xf6>
    800048f0:	557d                	li	a0,-1
    800048f2:	bfc9                	j	800048c4 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800048f4:	557d                	li	a0,-1
    800048f6:	79a2                	ld	s3,40(sp)
    800048f8:	b7f1                	j	800048c4 <filewrite+0xf6>

00000000800048fa <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800048fa:	7179                	addi	sp,sp,-48
    800048fc:	f406                	sd	ra,40(sp)
    800048fe:	f022                	sd	s0,32(sp)
    80004900:	ec26                	sd	s1,24(sp)
    80004902:	e052                	sd	s4,0(sp)
    80004904:	1800                	addi	s0,sp,48
    80004906:	84aa                	mv	s1,a0
    80004908:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000490a:	0005b023          	sd	zero,0(a1)
    8000490e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004912:	c3bff0ef          	jal	8000454c <filealloc>
    80004916:	e088                	sd	a0,0(s1)
    80004918:	c549                	beqz	a0,800049a2 <pipealloc+0xa8>
    8000491a:	c33ff0ef          	jal	8000454c <filealloc>
    8000491e:	00aa3023          	sd	a0,0(s4)
    80004922:	cd25                	beqz	a0,8000499a <pipealloc+0xa0>
    80004924:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004926:	9d8fc0ef          	jal	80000afe <kalloc>
    8000492a:	892a                	mv	s2,a0
    8000492c:	c12d                	beqz	a0,8000498e <pipealloc+0x94>
    8000492e:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004930:	4985                	li	s3,1
    80004932:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004936:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000493a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000493e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004942:	00003597          	auipc	a1,0x3
    80004946:	c7658593          	addi	a1,a1,-906 # 800075b8 <etext+0x5b8>
    8000494a:	a04fc0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    8000494e:	609c                	ld	a5,0(s1)
    80004950:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004954:	609c                	ld	a5,0(s1)
    80004956:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000495a:	609c                	ld	a5,0(s1)
    8000495c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004960:	609c                	ld	a5,0(s1)
    80004962:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004966:	000a3783          	ld	a5,0(s4)
    8000496a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000496e:	000a3783          	ld	a5,0(s4)
    80004972:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004976:	000a3783          	ld	a5,0(s4)
    8000497a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000497e:	000a3783          	ld	a5,0(s4)
    80004982:	0127b823          	sd	s2,16(a5)
  return 0;
    80004986:	4501                	li	a0,0
    80004988:	6942                	ld	s2,16(sp)
    8000498a:	69a2                	ld	s3,8(sp)
    8000498c:	a01d                	j	800049b2 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000498e:	6088                	ld	a0,0(s1)
    80004990:	c119                	beqz	a0,80004996 <pipealloc+0x9c>
    80004992:	6942                	ld	s2,16(sp)
    80004994:	a029                	j	8000499e <pipealloc+0xa4>
    80004996:	6942                	ld	s2,16(sp)
    80004998:	a029                	j	800049a2 <pipealloc+0xa8>
    8000499a:	6088                	ld	a0,0(s1)
    8000499c:	c10d                	beqz	a0,800049be <pipealloc+0xc4>
    fileclose(*f0);
    8000499e:	c53ff0ef          	jal	800045f0 <fileclose>
  if(*f1)
    800049a2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800049a6:	557d                	li	a0,-1
  if(*f1)
    800049a8:	c789                	beqz	a5,800049b2 <pipealloc+0xb8>
    fileclose(*f1);
    800049aa:	853e                	mv	a0,a5
    800049ac:	c45ff0ef          	jal	800045f0 <fileclose>
  return -1;
    800049b0:	557d                	li	a0,-1
}
    800049b2:	70a2                	ld	ra,40(sp)
    800049b4:	7402                	ld	s0,32(sp)
    800049b6:	64e2                	ld	s1,24(sp)
    800049b8:	6a02                	ld	s4,0(sp)
    800049ba:	6145                	addi	sp,sp,48
    800049bc:	8082                	ret
  return -1;
    800049be:	557d                	li	a0,-1
    800049c0:	bfcd                	j	800049b2 <pipealloc+0xb8>

00000000800049c2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800049c2:	1101                	addi	sp,sp,-32
    800049c4:	ec06                	sd	ra,24(sp)
    800049c6:	e822                	sd	s0,16(sp)
    800049c8:	e426                	sd	s1,8(sp)
    800049ca:	e04a                	sd	s2,0(sp)
    800049cc:	1000                	addi	s0,sp,32
    800049ce:	84aa                	mv	s1,a0
    800049d0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800049d2:	9fcfc0ef          	jal	80000bce <acquire>
  if(writable){
    800049d6:	02090763          	beqz	s2,80004a04 <pipeclose+0x42>
    pi->writeopen = 0;
    800049da:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800049de:	21848513          	addi	a0,s1,536
    800049e2:	d76fd0ef          	jal	80001f58 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800049e6:	2204b783          	ld	a5,544(s1)
    800049ea:	e785                	bnez	a5,80004a12 <pipeclose+0x50>
    release(&pi->lock);
    800049ec:	8526                	mv	a0,s1
    800049ee:	a78fc0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    800049f2:	8526                	mv	a0,s1
    800049f4:	828fc0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    800049f8:	60e2                	ld	ra,24(sp)
    800049fa:	6442                	ld	s0,16(sp)
    800049fc:	64a2                	ld	s1,8(sp)
    800049fe:	6902                	ld	s2,0(sp)
    80004a00:	6105                	addi	sp,sp,32
    80004a02:	8082                	ret
    pi->readopen = 0;
    80004a04:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a08:	21c48513          	addi	a0,s1,540
    80004a0c:	d4cfd0ef          	jal	80001f58 <wakeup>
    80004a10:	bfd9                	j	800049e6 <pipeclose+0x24>
    release(&pi->lock);
    80004a12:	8526                	mv	a0,s1
    80004a14:	a52fc0ef          	jal	80000c66 <release>
}
    80004a18:	b7c5                	j	800049f8 <pipeclose+0x36>

0000000080004a1a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a1a:	711d                	addi	sp,sp,-96
    80004a1c:	ec86                	sd	ra,88(sp)
    80004a1e:	e8a2                	sd	s0,80(sp)
    80004a20:	e4a6                	sd	s1,72(sp)
    80004a22:	e0ca                	sd	s2,64(sp)
    80004a24:	fc4e                	sd	s3,56(sp)
    80004a26:	f852                	sd	s4,48(sp)
    80004a28:	f456                	sd	s5,40(sp)
    80004a2a:	1080                	addi	s0,sp,96
    80004a2c:	84aa                	mv	s1,a0
    80004a2e:	8aae                	mv	s5,a1
    80004a30:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a32:	ea1fc0ef          	jal	800018d2 <myproc>
    80004a36:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a38:	8526                	mv	a0,s1
    80004a3a:	994fc0ef          	jal	80000bce <acquire>
  while(i < n){
    80004a3e:	0b405a63          	blez	s4,80004af2 <pipewrite+0xd8>
    80004a42:	f05a                	sd	s6,32(sp)
    80004a44:	ec5e                	sd	s7,24(sp)
    80004a46:	e862                	sd	s8,16(sp)
  int i = 0;
    80004a48:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a4a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a4c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a50:	21c48b93          	addi	s7,s1,540
    80004a54:	a81d                	j	80004a8a <pipewrite+0x70>
      release(&pi->lock);
    80004a56:	8526                	mv	a0,s1
    80004a58:	a0efc0ef          	jal	80000c66 <release>
      return -1;
    80004a5c:	597d                	li	s2,-1
    80004a5e:	7b02                	ld	s6,32(sp)
    80004a60:	6be2                	ld	s7,24(sp)
    80004a62:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a64:	854a                	mv	a0,s2
    80004a66:	60e6                	ld	ra,88(sp)
    80004a68:	6446                	ld	s0,80(sp)
    80004a6a:	64a6                	ld	s1,72(sp)
    80004a6c:	6906                	ld	s2,64(sp)
    80004a6e:	79e2                	ld	s3,56(sp)
    80004a70:	7a42                	ld	s4,48(sp)
    80004a72:	7aa2                	ld	s5,40(sp)
    80004a74:	6125                	addi	sp,sp,96
    80004a76:	8082                	ret
      wakeup(&pi->nread);
    80004a78:	8562                	mv	a0,s8
    80004a7a:	cdefd0ef          	jal	80001f58 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a7e:	85a6                	mv	a1,s1
    80004a80:	855e                	mv	a0,s7
    80004a82:	c8afd0ef          	jal	80001f0c <sleep>
  while(i < n){
    80004a86:	05495b63          	bge	s2,s4,80004adc <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80004a8a:	2204a783          	lw	a5,544(s1)
    80004a8e:	d7e1                	beqz	a5,80004a56 <pipewrite+0x3c>
    80004a90:	854e                	mv	a0,s3
    80004a92:	eb2fd0ef          	jal	80002144 <killed>
    80004a96:	f161                	bnez	a0,80004a56 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a98:	2184a783          	lw	a5,536(s1)
    80004a9c:	21c4a703          	lw	a4,540(s1)
    80004aa0:	2007879b          	addiw	a5,a5,512
    80004aa4:	fcf70ae3          	beq	a4,a5,80004a78 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004aa8:	4685                	li	a3,1
    80004aaa:	01590633          	add	a2,s2,s5
    80004aae:	faf40593          	addi	a1,s0,-81
    80004ab2:	0589b503          	ld	a0,88(s3)
    80004ab6:	c15fc0ef          	jal	800016ca <copyin>
    80004aba:	03650e63          	beq	a0,s6,80004af6 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004abe:	21c4a783          	lw	a5,540(s1)
    80004ac2:	0017871b          	addiw	a4,a5,1
    80004ac6:	20e4ae23          	sw	a4,540(s1)
    80004aca:	1ff7f793          	andi	a5,a5,511
    80004ace:	97a6                	add	a5,a5,s1
    80004ad0:	faf44703          	lbu	a4,-81(s0)
    80004ad4:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ad8:	2905                	addiw	s2,s2,1
    80004ada:	b775                	j	80004a86 <pipewrite+0x6c>
    80004adc:	7b02                	ld	s6,32(sp)
    80004ade:	6be2                	ld	s7,24(sp)
    80004ae0:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004ae2:	21848513          	addi	a0,s1,536
    80004ae6:	c72fd0ef          	jal	80001f58 <wakeup>
  release(&pi->lock);
    80004aea:	8526                	mv	a0,s1
    80004aec:	97afc0ef          	jal	80000c66 <release>
  return i;
    80004af0:	bf95                	j	80004a64 <pipewrite+0x4a>
  int i = 0;
    80004af2:	4901                	li	s2,0
    80004af4:	b7fd                	j	80004ae2 <pipewrite+0xc8>
    80004af6:	7b02                	ld	s6,32(sp)
    80004af8:	6be2                	ld	s7,24(sp)
    80004afa:	6c42                	ld	s8,16(sp)
    80004afc:	b7dd                	j	80004ae2 <pipewrite+0xc8>

0000000080004afe <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004afe:	715d                	addi	sp,sp,-80
    80004b00:	e486                	sd	ra,72(sp)
    80004b02:	e0a2                	sd	s0,64(sp)
    80004b04:	fc26                	sd	s1,56(sp)
    80004b06:	f84a                	sd	s2,48(sp)
    80004b08:	f44e                	sd	s3,40(sp)
    80004b0a:	f052                	sd	s4,32(sp)
    80004b0c:	ec56                	sd	s5,24(sp)
    80004b0e:	0880                	addi	s0,sp,80
    80004b10:	84aa                	mv	s1,a0
    80004b12:	892e                	mv	s2,a1
    80004b14:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b16:	dbdfc0ef          	jal	800018d2 <myproc>
    80004b1a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b1c:	8526                	mv	a0,s1
    80004b1e:	8b0fc0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b22:	2184a703          	lw	a4,536(s1)
    80004b26:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b2a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b2e:	02f71563          	bne	a4,a5,80004b58 <piperead+0x5a>
    80004b32:	2244a783          	lw	a5,548(s1)
    80004b36:	cb85                	beqz	a5,80004b66 <piperead+0x68>
    if(killed(pr)){
    80004b38:	8552                	mv	a0,s4
    80004b3a:	e0afd0ef          	jal	80002144 <killed>
    80004b3e:	ed19                	bnez	a0,80004b5c <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b40:	85a6                	mv	a1,s1
    80004b42:	854e                	mv	a0,s3
    80004b44:	bc8fd0ef          	jal	80001f0c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b48:	2184a703          	lw	a4,536(s1)
    80004b4c:	21c4a783          	lw	a5,540(s1)
    80004b50:	fef701e3          	beq	a4,a5,80004b32 <piperead+0x34>
    80004b54:	e85a                	sd	s6,16(sp)
    80004b56:	a809                	j	80004b68 <piperead+0x6a>
    80004b58:	e85a                	sd	s6,16(sp)
    80004b5a:	a039                	j	80004b68 <piperead+0x6a>
      release(&pi->lock);
    80004b5c:	8526                	mv	a0,s1
    80004b5e:	908fc0ef          	jal	80000c66 <release>
      return -1;
    80004b62:	59fd                	li	s3,-1
    80004b64:	a8b9                	j	80004bc2 <piperead+0xc4>
    80004b66:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b68:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004b6a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b6c:	05505363          	blez	s5,80004bb2 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004b70:	2184a783          	lw	a5,536(s1)
    80004b74:	21c4a703          	lw	a4,540(s1)
    80004b78:	02f70d63          	beq	a4,a5,80004bb2 <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    80004b7c:	1ff7f793          	andi	a5,a5,511
    80004b80:	97a6                	add	a5,a5,s1
    80004b82:	0187c783          	lbu	a5,24(a5)
    80004b86:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004b8a:	4685                	li	a3,1
    80004b8c:	fbf40613          	addi	a2,s0,-65
    80004b90:	85ca                	mv	a1,s2
    80004b92:	058a3503          	ld	a0,88(s4)
    80004b96:	a51fc0ef          	jal	800015e6 <copyout>
    80004b9a:	03650e63          	beq	a0,s6,80004bd6 <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004b9e:	2184a783          	lw	a5,536(s1)
    80004ba2:	2785                	addiw	a5,a5,1
    80004ba4:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ba8:	2985                	addiw	s3,s3,1
    80004baa:	0905                	addi	s2,s2,1
    80004bac:	fd3a92e3          	bne	s5,s3,80004b70 <piperead+0x72>
    80004bb0:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004bb2:	21c48513          	addi	a0,s1,540
    80004bb6:	ba2fd0ef          	jal	80001f58 <wakeup>
  release(&pi->lock);
    80004bba:	8526                	mv	a0,s1
    80004bbc:	8aafc0ef          	jal	80000c66 <release>
    80004bc0:	6b42                	ld	s6,16(sp)
  return i;
}
    80004bc2:	854e                	mv	a0,s3
    80004bc4:	60a6                	ld	ra,72(sp)
    80004bc6:	6406                	ld	s0,64(sp)
    80004bc8:	74e2                	ld	s1,56(sp)
    80004bca:	7942                	ld	s2,48(sp)
    80004bcc:	79a2                	ld	s3,40(sp)
    80004bce:	7a02                	ld	s4,32(sp)
    80004bd0:	6ae2                	ld	s5,24(sp)
    80004bd2:	6161                	addi	sp,sp,80
    80004bd4:	8082                	ret
      if(i == 0)
    80004bd6:	fc099ee3          	bnez	s3,80004bb2 <piperead+0xb4>
        i = -1;
    80004bda:	89aa                	mv	s3,a0
    80004bdc:	bfd9                	j	80004bb2 <piperead+0xb4>

0000000080004bde <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004bde:	1141                	addi	sp,sp,-16
    80004be0:	e422                	sd	s0,8(sp)
    80004be2:	0800                	addi	s0,sp,16
    80004be4:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004be6:	8905                	andi	a0,a0,1
    80004be8:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004bea:	8b89                	andi	a5,a5,2
    80004bec:	c399                	beqz	a5,80004bf2 <flags2perm+0x14>
      perm |= PTE_W;
    80004bee:	00456513          	ori	a0,a0,4
    return perm;
}
    80004bf2:	6422                	ld	s0,8(sp)
    80004bf4:	0141                	addi	sp,sp,16
    80004bf6:	8082                	ret

0000000080004bf8 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004bf8:	df010113          	addi	sp,sp,-528
    80004bfc:	20113423          	sd	ra,520(sp)
    80004c00:	20813023          	sd	s0,512(sp)
    80004c04:	ffa6                	sd	s1,504(sp)
    80004c06:	fbca                	sd	s2,496(sp)
    80004c08:	0c00                	addi	s0,sp,528
    80004c0a:	892a                	mv	s2,a0
    80004c0c:	dea43c23          	sd	a0,-520(s0)
    80004c10:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c14:	cbffc0ef          	jal	800018d2 <myproc>
    80004c18:	84aa                	mv	s1,a0

  begin_op();
    80004c1a:	dcaff0ef          	jal	800041e4 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004c1e:	854a                	mv	a0,s2
    80004c20:	bf0ff0ef          	jal	80004010 <namei>
    80004c24:	c931                	beqz	a0,80004c78 <kexec+0x80>
    80004c26:	f3d2                	sd	s4,480(sp)
    80004c28:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c2a:	bd1fe0ef          	jal	800037fa <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c2e:	04000713          	li	a4,64
    80004c32:	4681                	li	a3,0
    80004c34:	e5040613          	addi	a2,s0,-432
    80004c38:	4581                	li	a1,0
    80004c3a:	8552                	mv	a0,s4
    80004c3c:	f4ffe0ef          	jal	80003b8a <readi>
    80004c40:	04000793          	li	a5,64
    80004c44:	00f51a63          	bne	a0,a5,80004c58 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004c48:	e5042703          	lw	a4,-432(s0)
    80004c4c:	464c47b7          	lui	a5,0x464c4
    80004c50:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c54:	02f70663          	beq	a4,a5,80004c80 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c58:	8552                	mv	a0,s4
    80004c5a:	dabfe0ef          	jal	80003a04 <iunlockput>
    end_op();
    80004c5e:	df0ff0ef          	jal	8000424e <end_op>
  }
  return -1;
    80004c62:	557d                	li	a0,-1
    80004c64:	7a1e                	ld	s4,480(sp)
}
    80004c66:	20813083          	ld	ra,520(sp)
    80004c6a:	20013403          	ld	s0,512(sp)
    80004c6e:	74fe                	ld	s1,504(sp)
    80004c70:	795e                	ld	s2,496(sp)
    80004c72:	21010113          	addi	sp,sp,528
    80004c76:	8082                	ret
    end_op();
    80004c78:	dd6ff0ef          	jal	8000424e <end_op>
    return -1;
    80004c7c:	557d                	li	a0,-1
    80004c7e:	b7e5                	j	80004c66 <kexec+0x6e>
    80004c80:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004c82:	8526                	mv	a0,s1
    80004c84:	d55fc0ef          	jal	800019d8 <proc_pagetable>
    80004c88:	8b2a                	mv	s6,a0
    80004c8a:	2c050b63          	beqz	a0,80004f60 <kexec+0x368>
    80004c8e:	f7ce                	sd	s3,488(sp)
    80004c90:	efd6                	sd	s5,472(sp)
    80004c92:	e7de                	sd	s7,456(sp)
    80004c94:	e3e2                	sd	s8,448(sp)
    80004c96:	ff66                	sd	s9,440(sp)
    80004c98:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c9a:	e7042d03          	lw	s10,-400(s0)
    80004c9e:	e8845783          	lhu	a5,-376(s0)
    80004ca2:	12078963          	beqz	a5,80004dd4 <kexec+0x1dc>
    80004ca6:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ca8:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004caa:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004cac:	6c85                	lui	s9,0x1
    80004cae:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004cb2:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004cb6:	6a85                	lui	s5,0x1
    80004cb8:	a085                	j	80004d18 <kexec+0x120>
      panic("loadseg: address should exist");
    80004cba:	00003517          	auipc	a0,0x3
    80004cbe:	90650513          	addi	a0,a0,-1786 # 800075c0 <etext+0x5c0>
    80004cc2:	b1ffb0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    80004cc6:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004cc8:	8726                	mv	a4,s1
    80004cca:	012c06bb          	addw	a3,s8,s2
    80004cce:	4581                	li	a1,0
    80004cd0:	8552                	mv	a0,s4
    80004cd2:	eb9fe0ef          	jal	80003b8a <readi>
    80004cd6:	2501                	sext.w	a0,a0
    80004cd8:	24a49a63          	bne	s1,a0,80004f2c <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004cdc:	012a893b          	addw	s2,s5,s2
    80004ce0:	03397363          	bgeu	s2,s3,80004d06 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004ce4:	02091593          	slli	a1,s2,0x20
    80004ce8:	9181                	srli	a1,a1,0x20
    80004cea:	95de                	add	a1,a1,s7
    80004cec:	855a                	mv	a0,s6
    80004cee:	ac6fc0ef          	jal	80000fb4 <walkaddr>
    80004cf2:	862a                	mv	a2,a0
    if(pa == 0)
    80004cf4:	d179                	beqz	a0,80004cba <kexec+0xc2>
    if(sz - i < PGSIZE)
    80004cf6:	412984bb          	subw	s1,s3,s2
    80004cfa:	0004879b          	sext.w	a5,s1
    80004cfe:	fcfcf4e3          	bgeu	s9,a5,80004cc6 <kexec+0xce>
    80004d02:	84d6                	mv	s1,s5
    80004d04:	b7c9                	j	80004cc6 <kexec+0xce>
    sz = sz1;
    80004d06:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d0a:	2d85                	addiw	s11,s11,1
    80004d0c:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004d10:	e8845783          	lhu	a5,-376(s0)
    80004d14:	08fdd063          	bge	s11,a5,80004d94 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004d18:	2d01                	sext.w	s10,s10
    80004d1a:	03800713          	li	a4,56
    80004d1e:	86ea                	mv	a3,s10
    80004d20:	e1840613          	addi	a2,s0,-488
    80004d24:	4581                	li	a1,0
    80004d26:	8552                	mv	a0,s4
    80004d28:	e63fe0ef          	jal	80003b8a <readi>
    80004d2c:	03800793          	li	a5,56
    80004d30:	1cf51663          	bne	a0,a5,80004efc <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004d34:	e1842783          	lw	a5,-488(s0)
    80004d38:	4705                	li	a4,1
    80004d3a:	fce798e3          	bne	a5,a4,80004d0a <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80004d3e:	e4043483          	ld	s1,-448(s0)
    80004d42:	e3843783          	ld	a5,-456(s0)
    80004d46:	1af4ef63          	bltu	s1,a5,80004f04 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004d4a:	e2843783          	ld	a5,-472(s0)
    80004d4e:	94be                	add	s1,s1,a5
    80004d50:	1af4ee63          	bltu	s1,a5,80004f0c <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004d54:	df043703          	ld	a4,-528(s0)
    80004d58:	8ff9                	and	a5,a5,a4
    80004d5a:	1a079d63          	bnez	a5,80004f14 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004d5e:	e1c42503          	lw	a0,-484(s0)
    80004d62:	e7dff0ef          	jal	80004bde <flags2perm>
    80004d66:	86aa                	mv	a3,a0
    80004d68:	8626                	mv	a2,s1
    80004d6a:	85ca                	mv	a1,s2
    80004d6c:	855a                	mv	a0,s6
    80004d6e:	d1efc0ef          	jal	8000128c <uvmalloc>
    80004d72:	e0a43423          	sd	a0,-504(s0)
    80004d76:	1a050363          	beqz	a0,80004f1c <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004d7a:	e2843b83          	ld	s7,-472(s0)
    80004d7e:	e2042c03          	lw	s8,-480(s0)
    80004d82:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004d86:	00098463          	beqz	s3,80004d8e <kexec+0x196>
    80004d8a:	4901                	li	s2,0
    80004d8c:	bfa1                	j	80004ce4 <kexec+0xec>
    sz = sz1;
    80004d8e:	e0843903          	ld	s2,-504(s0)
    80004d92:	bfa5                	j	80004d0a <kexec+0x112>
    80004d94:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004d96:	8552                	mv	a0,s4
    80004d98:	c6dfe0ef          	jal	80003a04 <iunlockput>
  end_op();
    80004d9c:	cb2ff0ef          	jal	8000424e <end_op>
  p = myproc();
    80004da0:	b33fc0ef          	jal	800018d2 <myproc>
    80004da4:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004da6:	05053c83          	ld	s9,80(a0)
  sz = PGROUNDUP(sz);
    80004daa:	6985                	lui	s3,0x1
    80004dac:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004dae:	99ca                	add	s3,s3,s2
    80004db0:	77fd                	lui	a5,0xfffff
    80004db2:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004db6:	4691                	li	a3,4
    80004db8:	6609                	lui	a2,0x2
    80004dba:	964e                	add	a2,a2,s3
    80004dbc:	85ce                	mv	a1,s3
    80004dbe:	855a                	mv	a0,s6
    80004dc0:	cccfc0ef          	jal	8000128c <uvmalloc>
    80004dc4:	892a                	mv	s2,a0
    80004dc6:	e0a43423          	sd	a0,-504(s0)
    80004dca:	e519                	bnez	a0,80004dd8 <kexec+0x1e0>
  if(pagetable)
    80004dcc:	e1343423          	sd	s3,-504(s0)
    80004dd0:	4a01                	li	s4,0
    80004dd2:	aab1                	j	80004f2e <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004dd4:	4901                	li	s2,0
    80004dd6:	b7c1                	j	80004d96 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004dd8:	75f9                	lui	a1,0xffffe
    80004dda:	95aa                	add	a1,a1,a0
    80004ddc:	855a                	mv	a0,s6
    80004dde:	e84fc0ef          	jal	80001462 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004de2:	7bfd                	lui	s7,0xfffff
    80004de4:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004de6:	e0043783          	ld	a5,-512(s0)
    80004dea:	6388                	ld	a0,0(a5)
    80004dec:	cd39                	beqz	a0,80004e4a <kexec+0x252>
    80004dee:	e9040993          	addi	s3,s0,-368
    80004df2:	f9040c13          	addi	s8,s0,-112
    80004df6:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004df8:	81afc0ef          	jal	80000e12 <strlen>
    80004dfc:	0015079b          	addiw	a5,a0,1
    80004e00:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e04:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004e08:	11796e63          	bltu	s2,s7,80004f24 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004e0c:	e0043d03          	ld	s10,-512(s0)
    80004e10:	000d3a03          	ld	s4,0(s10)
    80004e14:	8552                	mv	a0,s4
    80004e16:	ffdfb0ef          	jal	80000e12 <strlen>
    80004e1a:	0015069b          	addiw	a3,a0,1
    80004e1e:	8652                	mv	a2,s4
    80004e20:	85ca                	mv	a1,s2
    80004e22:	855a                	mv	a0,s6
    80004e24:	fc2fc0ef          	jal	800015e6 <copyout>
    80004e28:	10054063          	bltz	a0,80004f28 <kexec+0x330>
    ustack[argc] = sp;
    80004e2c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004e30:	0485                	addi	s1,s1,1
    80004e32:	008d0793          	addi	a5,s10,8
    80004e36:	e0f43023          	sd	a5,-512(s0)
    80004e3a:	008d3503          	ld	a0,8(s10)
    80004e3e:	c909                	beqz	a0,80004e50 <kexec+0x258>
    if(argc >= MAXARG)
    80004e40:	09a1                	addi	s3,s3,8
    80004e42:	fb899be3          	bne	s3,s8,80004df8 <kexec+0x200>
  ip = 0;
    80004e46:	4a01                	li	s4,0
    80004e48:	a0dd                	j	80004f2e <kexec+0x336>
  sp = sz;
    80004e4a:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004e4e:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e50:	00349793          	slli	a5,s1,0x3
    80004e54:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffda7d0>
    80004e58:	97a2                	add	a5,a5,s0
    80004e5a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004e5e:	00148693          	addi	a3,s1,1
    80004e62:	068e                	slli	a3,a3,0x3
    80004e64:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e68:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004e6c:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004e70:	f5796ee3          	bltu	s2,s7,80004dcc <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e74:	e9040613          	addi	a2,s0,-368
    80004e78:	85ca                	mv	a1,s2
    80004e7a:	855a                	mv	a0,s6
    80004e7c:	f6afc0ef          	jal	800015e6 <copyout>
    80004e80:	0e054263          	bltz	a0,80004f64 <kexec+0x36c>
  p->trapframe->a1 = sp;
    80004e84:	060ab783          	ld	a5,96(s5) # 1060 <_entry-0x7fffefa0>
    80004e88:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e8c:	df843783          	ld	a5,-520(s0)
    80004e90:	0007c703          	lbu	a4,0(a5)
    80004e94:	cf11                	beqz	a4,80004eb0 <kexec+0x2b8>
    80004e96:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e98:	02f00693          	li	a3,47
    80004e9c:	a039                	j	80004eaa <kexec+0x2b2>
      last = s+1;
    80004e9e:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004ea2:	0785                	addi	a5,a5,1
    80004ea4:	fff7c703          	lbu	a4,-1(a5)
    80004ea8:	c701                	beqz	a4,80004eb0 <kexec+0x2b8>
    if(*s == '/')
    80004eaa:	fed71ce3          	bne	a4,a3,80004ea2 <kexec+0x2aa>
    80004eae:	bfc5                	j	80004e9e <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004eb0:	4641                	li	a2,16
    80004eb2:	df843583          	ld	a1,-520(s0)
    80004eb6:	160a8513          	addi	a0,s5,352
    80004eba:	f27fb0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    80004ebe:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80004ec2:	056abc23          	sd	s6,88(s5)
  p->sz = sz;
    80004ec6:	e0843783          	ld	a5,-504(s0)
    80004eca:	04fab823          	sd	a5,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004ece:	060ab783          	ld	a5,96(s5)
    80004ed2:	e6843703          	ld	a4,-408(s0)
    80004ed6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004ed8:	060ab783          	ld	a5,96(s5)
    80004edc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004ee0:	85e6                	mv	a1,s9
    80004ee2:	b7bfc0ef          	jal	80001a5c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ee6:	0004851b          	sext.w	a0,s1
    80004eea:	79be                	ld	s3,488(sp)
    80004eec:	7a1e                	ld	s4,480(sp)
    80004eee:	6afe                	ld	s5,472(sp)
    80004ef0:	6b5e                	ld	s6,464(sp)
    80004ef2:	6bbe                	ld	s7,456(sp)
    80004ef4:	6c1e                	ld	s8,448(sp)
    80004ef6:	7cfa                	ld	s9,440(sp)
    80004ef8:	7d5a                	ld	s10,432(sp)
    80004efa:	b3b5                	j	80004c66 <kexec+0x6e>
    80004efc:	e1243423          	sd	s2,-504(s0)
    80004f00:	7dba                	ld	s11,424(sp)
    80004f02:	a035                	j	80004f2e <kexec+0x336>
    80004f04:	e1243423          	sd	s2,-504(s0)
    80004f08:	7dba                	ld	s11,424(sp)
    80004f0a:	a015                	j	80004f2e <kexec+0x336>
    80004f0c:	e1243423          	sd	s2,-504(s0)
    80004f10:	7dba                	ld	s11,424(sp)
    80004f12:	a831                	j	80004f2e <kexec+0x336>
    80004f14:	e1243423          	sd	s2,-504(s0)
    80004f18:	7dba                	ld	s11,424(sp)
    80004f1a:	a811                	j	80004f2e <kexec+0x336>
    80004f1c:	e1243423          	sd	s2,-504(s0)
    80004f20:	7dba                	ld	s11,424(sp)
    80004f22:	a031                	j	80004f2e <kexec+0x336>
  ip = 0;
    80004f24:	4a01                	li	s4,0
    80004f26:	a021                	j	80004f2e <kexec+0x336>
    80004f28:	4a01                	li	s4,0
  if(pagetable)
    80004f2a:	a011                	j	80004f2e <kexec+0x336>
    80004f2c:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004f2e:	e0843583          	ld	a1,-504(s0)
    80004f32:	855a                	mv	a0,s6
    80004f34:	b29fc0ef          	jal	80001a5c <proc_freepagetable>
  return -1;
    80004f38:	557d                	li	a0,-1
  if(ip){
    80004f3a:	000a1b63          	bnez	s4,80004f50 <kexec+0x358>
    80004f3e:	79be                	ld	s3,488(sp)
    80004f40:	7a1e                	ld	s4,480(sp)
    80004f42:	6afe                	ld	s5,472(sp)
    80004f44:	6b5e                	ld	s6,464(sp)
    80004f46:	6bbe                	ld	s7,456(sp)
    80004f48:	6c1e                	ld	s8,448(sp)
    80004f4a:	7cfa                	ld	s9,440(sp)
    80004f4c:	7d5a                	ld	s10,432(sp)
    80004f4e:	bb21                	j	80004c66 <kexec+0x6e>
    80004f50:	79be                	ld	s3,488(sp)
    80004f52:	6afe                	ld	s5,472(sp)
    80004f54:	6b5e                	ld	s6,464(sp)
    80004f56:	6bbe                	ld	s7,456(sp)
    80004f58:	6c1e                	ld	s8,448(sp)
    80004f5a:	7cfa                	ld	s9,440(sp)
    80004f5c:	7d5a                	ld	s10,432(sp)
    80004f5e:	b9ed                	j	80004c58 <kexec+0x60>
    80004f60:	6b5e                	ld	s6,464(sp)
    80004f62:	b9dd                	j	80004c58 <kexec+0x60>
  sz = sz1;
    80004f64:	e0843983          	ld	s3,-504(s0)
    80004f68:	b595                	j	80004dcc <kexec+0x1d4>

0000000080004f6a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f6a:	7179                	addi	sp,sp,-48
    80004f6c:	f406                	sd	ra,40(sp)
    80004f6e:	f022                	sd	s0,32(sp)
    80004f70:	ec26                	sd	s1,24(sp)
    80004f72:	e84a                	sd	s2,16(sp)
    80004f74:	1800                	addi	s0,sp,48
    80004f76:	892e                	mv	s2,a1
    80004f78:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004f7a:	fdc40593          	addi	a1,s0,-36
    80004f7e:	893fd0ef          	jal	80002810 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f82:	fdc42703          	lw	a4,-36(s0)
    80004f86:	47bd                	li	a5,15
    80004f88:	02e7e963          	bltu	a5,a4,80004fba <argfd+0x50>
    80004f8c:	947fc0ef          	jal	800018d2 <myproc>
    80004f90:	fdc42703          	lw	a4,-36(s0)
    80004f94:	01a70793          	addi	a5,a4,26
    80004f98:	078e                	slli	a5,a5,0x3
    80004f9a:	953e                	add	a0,a0,a5
    80004f9c:	651c                	ld	a5,8(a0)
    80004f9e:	c385                	beqz	a5,80004fbe <argfd+0x54>
    return -1;
  if(pfd)
    80004fa0:	00090463          	beqz	s2,80004fa8 <argfd+0x3e>
    *pfd = fd;
    80004fa4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004fa8:	4501                	li	a0,0
  if(pf)
    80004faa:	c091                	beqz	s1,80004fae <argfd+0x44>
    *pf = f;
    80004fac:	e09c                	sd	a5,0(s1)
}
    80004fae:	70a2                	ld	ra,40(sp)
    80004fb0:	7402                	ld	s0,32(sp)
    80004fb2:	64e2                	ld	s1,24(sp)
    80004fb4:	6942                	ld	s2,16(sp)
    80004fb6:	6145                	addi	sp,sp,48
    80004fb8:	8082                	ret
    return -1;
    80004fba:	557d                	li	a0,-1
    80004fbc:	bfcd                	j	80004fae <argfd+0x44>
    80004fbe:	557d                	li	a0,-1
    80004fc0:	b7fd                	j	80004fae <argfd+0x44>

0000000080004fc2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004fc2:	1101                	addi	sp,sp,-32
    80004fc4:	ec06                	sd	ra,24(sp)
    80004fc6:	e822                	sd	s0,16(sp)
    80004fc8:	e426                	sd	s1,8(sp)
    80004fca:	1000                	addi	s0,sp,32
    80004fcc:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004fce:	905fc0ef          	jal	800018d2 <myproc>
    80004fd2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004fd4:	0d850793          	addi	a5,a0,216
    80004fd8:	4501                	li	a0,0
    80004fda:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004fdc:	6398                	ld	a4,0(a5)
    80004fde:	cb19                	beqz	a4,80004ff4 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004fe0:	2505                	addiw	a0,a0,1
    80004fe2:	07a1                	addi	a5,a5,8
    80004fe4:	fed51ce3          	bne	a0,a3,80004fdc <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004fe8:	557d                	li	a0,-1
}
    80004fea:	60e2                	ld	ra,24(sp)
    80004fec:	6442                	ld	s0,16(sp)
    80004fee:	64a2                	ld	s1,8(sp)
    80004ff0:	6105                	addi	sp,sp,32
    80004ff2:	8082                	ret
      p->ofile[fd] = f;
    80004ff4:	01a50793          	addi	a5,a0,26
    80004ff8:	078e                	slli	a5,a5,0x3
    80004ffa:	963e                	add	a2,a2,a5
    80004ffc:	e604                	sd	s1,8(a2)
      return fd;
    80004ffe:	b7f5                	j	80004fea <fdalloc+0x28>

0000000080005000 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005000:	715d                	addi	sp,sp,-80
    80005002:	e486                	sd	ra,72(sp)
    80005004:	e0a2                	sd	s0,64(sp)
    80005006:	fc26                	sd	s1,56(sp)
    80005008:	f84a                	sd	s2,48(sp)
    8000500a:	f44e                	sd	s3,40(sp)
    8000500c:	ec56                	sd	s5,24(sp)
    8000500e:	e85a                	sd	s6,16(sp)
    80005010:	0880                	addi	s0,sp,80
    80005012:	8b2e                	mv	s6,a1
    80005014:	89b2                	mv	s3,a2
    80005016:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005018:	fb040593          	addi	a1,s0,-80
    8000501c:	80eff0ef          	jal	8000402a <nameiparent>
    80005020:	84aa                	mv	s1,a0
    80005022:	10050a63          	beqz	a0,80005136 <create+0x136>
    return 0;

  ilock(dp);
    80005026:	fd4fe0ef          	jal	800037fa <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000502a:	4601                	li	a2,0
    8000502c:	fb040593          	addi	a1,s0,-80
    80005030:	8526                	mv	a0,s1
    80005032:	d79fe0ef          	jal	80003daa <dirlookup>
    80005036:	8aaa                	mv	s5,a0
    80005038:	c129                	beqz	a0,8000507a <create+0x7a>
    iunlockput(dp);
    8000503a:	8526                	mv	a0,s1
    8000503c:	9c9fe0ef          	jal	80003a04 <iunlockput>
    ilock(ip);
    80005040:	8556                	mv	a0,s5
    80005042:	fb8fe0ef          	jal	800037fa <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005046:	4789                	li	a5,2
    80005048:	02fb1463          	bne	s6,a5,80005070 <create+0x70>
    8000504c:	044ad783          	lhu	a5,68(s5)
    80005050:	37f9                	addiw	a5,a5,-2
    80005052:	17c2                	slli	a5,a5,0x30
    80005054:	93c1                	srli	a5,a5,0x30
    80005056:	4705                	li	a4,1
    80005058:	00f76c63          	bltu	a4,a5,80005070 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000505c:	8556                	mv	a0,s5
    8000505e:	60a6                	ld	ra,72(sp)
    80005060:	6406                	ld	s0,64(sp)
    80005062:	74e2                	ld	s1,56(sp)
    80005064:	7942                	ld	s2,48(sp)
    80005066:	79a2                	ld	s3,40(sp)
    80005068:	6ae2                	ld	s5,24(sp)
    8000506a:	6b42                	ld	s6,16(sp)
    8000506c:	6161                	addi	sp,sp,80
    8000506e:	8082                	ret
    iunlockput(ip);
    80005070:	8556                	mv	a0,s5
    80005072:	993fe0ef          	jal	80003a04 <iunlockput>
    return 0;
    80005076:	4a81                	li	s5,0
    80005078:	b7d5                	j	8000505c <create+0x5c>
    8000507a:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    8000507c:	85da                	mv	a1,s6
    8000507e:	4088                	lw	a0,0(s1)
    80005080:	e0afe0ef          	jal	8000368a <ialloc>
    80005084:	8a2a                	mv	s4,a0
    80005086:	cd15                	beqz	a0,800050c2 <create+0xc2>
  ilock(ip);
    80005088:	f72fe0ef          	jal	800037fa <ilock>
  ip->major = major;
    8000508c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005090:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005094:	4905                	li	s2,1
    80005096:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000509a:	8552                	mv	a0,s4
    8000509c:	eaafe0ef          	jal	80003746 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800050a0:	032b0763          	beq	s6,s2,800050ce <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    800050a4:	004a2603          	lw	a2,4(s4)
    800050a8:	fb040593          	addi	a1,s0,-80
    800050ac:	8526                	mv	a0,s1
    800050ae:	ec9fe0ef          	jal	80003f76 <dirlink>
    800050b2:	06054563          	bltz	a0,8000511c <create+0x11c>
  iunlockput(dp);
    800050b6:	8526                	mv	a0,s1
    800050b8:	94dfe0ef          	jal	80003a04 <iunlockput>
  return ip;
    800050bc:	8ad2                	mv	s5,s4
    800050be:	7a02                	ld	s4,32(sp)
    800050c0:	bf71                	j	8000505c <create+0x5c>
    iunlockput(dp);
    800050c2:	8526                	mv	a0,s1
    800050c4:	941fe0ef          	jal	80003a04 <iunlockput>
    return 0;
    800050c8:	8ad2                	mv	s5,s4
    800050ca:	7a02                	ld	s4,32(sp)
    800050cc:	bf41                	j	8000505c <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800050ce:	004a2603          	lw	a2,4(s4)
    800050d2:	00002597          	auipc	a1,0x2
    800050d6:	50e58593          	addi	a1,a1,1294 # 800075e0 <etext+0x5e0>
    800050da:	8552                	mv	a0,s4
    800050dc:	e9bfe0ef          	jal	80003f76 <dirlink>
    800050e0:	02054e63          	bltz	a0,8000511c <create+0x11c>
    800050e4:	40d0                	lw	a2,4(s1)
    800050e6:	00002597          	auipc	a1,0x2
    800050ea:	50258593          	addi	a1,a1,1282 # 800075e8 <etext+0x5e8>
    800050ee:	8552                	mv	a0,s4
    800050f0:	e87fe0ef          	jal	80003f76 <dirlink>
    800050f4:	02054463          	bltz	a0,8000511c <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    800050f8:	004a2603          	lw	a2,4(s4)
    800050fc:	fb040593          	addi	a1,s0,-80
    80005100:	8526                	mv	a0,s1
    80005102:	e75fe0ef          	jal	80003f76 <dirlink>
    80005106:	00054b63          	bltz	a0,8000511c <create+0x11c>
    dp->nlink++;  // for ".."
    8000510a:	04a4d783          	lhu	a5,74(s1)
    8000510e:	2785                	addiw	a5,a5,1
    80005110:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005114:	8526                	mv	a0,s1
    80005116:	e30fe0ef          	jal	80003746 <iupdate>
    8000511a:	bf71                	j	800050b6 <create+0xb6>
  ip->nlink = 0;
    8000511c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005120:	8552                	mv	a0,s4
    80005122:	e24fe0ef          	jal	80003746 <iupdate>
  iunlockput(ip);
    80005126:	8552                	mv	a0,s4
    80005128:	8ddfe0ef          	jal	80003a04 <iunlockput>
  iunlockput(dp);
    8000512c:	8526                	mv	a0,s1
    8000512e:	8d7fe0ef          	jal	80003a04 <iunlockput>
  return 0;
    80005132:	7a02                	ld	s4,32(sp)
    80005134:	b725                	j	8000505c <create+0x5c>
    return 0;
    80005136:	8aaa                	mv	s5,a0
    80005138:	b715                	j	8000505c <create+0x5c>

000000008000513a <sys_dup>:
{
    8000513a:	7179                	addi	sp,sp,-48
    8000513c:	f406                	sd	ra,40(sp)
    8000513e:	f022                	sd	s0,32(sp)
    80005140:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005142:	fd840613          	addi	a2,s0,-40
    80005146:	4581                	li	a1,0
    80005148:	4501                	li	a0,0
    8000514a:	e21ff0ef          	jal	80004f6a <argfd>
    return -1;
    8000514e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005150:	02054363          	bltz	a0,80005176 <sys_dup+0x3c>
    80005154:	ec26                	sd	s1,24(sp)
    80005156:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005158:	fd843903          	ld	s2,-40(s0)
    8000515c:	854a                	mv	a0,s2
    8000515e:	e65ff0ef          	jal	80004fc2 <fdalloc>
    80005162:	84aa                	mv	s1,a0
    return -1;
    80005164:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005166:	00054d63          	bltz	a0,80005180 <sys_dup+0x46>
  filedup(f);
    8000516a:	854a                	mv	a0,s2
    8000516c:	c3eff0ef          	jal	800045aa <filedup>
  return fd;
    80005170:	87a6                	mv	a5,s1
    80005172:	64e2                	ld	s1,24(sp)
    80005174:	6942                	ld	s2,16(sp)
}
    80005176:	853e                	mv	a0,a5
    80005178:	70a2                	ld	ra,40(sp)
    8000517a:	7402                	ld	s0,32(sp)
    8000517c:	6145                	addi	sp,sp,48
    8000517e:	8082                	ret
    80005180:	64e2                	ld	s1,24(sp)
    80005182:	6942                	ld	s2,16(sp)
    80005184:	bfcd                	j	80005176 <sys_dup+0x3c>

0000000080005186 <sys_read>:
{
    80005186:	7179                	addi	sp,sp,-48
    80005188:	f406                	sd	ra,40(sp)
    8000518a:	f022                	sd	s0,32(sp)
    8000518c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000518e:	fd840593          	addi	a1,s0,-40
    80005192:	4505                	li	a0,1
    80005194:	e98fd0ef          	jal	8000282c <argaddr>
  argint(2, &n);
    80005198:	fe440593          	addi	a1,s0,-28
    8000519c:	4509                	li	a0,2
    8000519e:	e72fd0ef          	jal	80002810 <argint>
  if(argfd(0, 0, &f) < 0)
    800051a2:	fe840613          	addi	a2,s0,-24
    800051a6:	4581                	li	a1,0
    800051a8:	4501                	li	a0,0
    800051aa:	dc1ff0ef          	jal	80004f6a <argfd>
    800051ae:	87aa                	mv	a5,a0
    return -1;
    800051b0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800051b2:	0007ca63          	bltz	a5,800051c6 <sys_read+0x40>
  return fileread(f, p, n);
    800051b6:	fe442603          	lw	a2,-28(s0)
    800051ba:	fd843583          	ld	a1,-40(s0)
    800051be:	fe843503          	ld	a0,-24(s0)
    800051c2:	d4eff0ef          	jal	80004710 <fileread>
}
    800051c6:	70a2                	ld	ra,40(sp)
    800051c8:	7402                	ld	s0,32(sp)
    800051ca:	6145                	addi	sp,sp,48
    800051cc:	8082                	ret

00000000800051ce <sys_write>:
{
    800051ce:	7179                	addi	sp,sp,-48
    800051d0:	f406                	sd	ra,40(sp)
    800051d2:	f022                	sd	s0,32(sp)
    800051d4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051d6:	fd840593          	addi	a1,s0,-40
    800051da:	4505                	li	a0,1
    800051dc:	e50fd0ef          	jal	8000282c <argaddr>
  argint(2, &n);
    800051e0:	fe440593          	addi	a1,s0,-28
    800051e4:	4509                	li	a0,2
    800051e6:	e2afd0ef          	jal	80002810 <argint>
  if(argfd(0, 0, &f) < 0)
    800051ea:	fe840613          	addi	a2,s0,-24
    800051ee:	4581                	li	a1,0
    800051f0:	4501                	li	a0,0
    800051f2:	d79ff0ef          	jal	80004f6a <argfd>
    800051f6:	87aa                	mv	a5,a0
    return -1;
    800051f8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800051fa:	0007ca63          	bltz	a5,8000520e <sys_write+0x40>
  return filewrite(f, p, n);
    800051fe:	fe442603          	lw	a2,-28(s0)
    80005202:	fd843583          	ld	a1,-40(s0)
    80005206:	fe843503          	ld	a0,-24(s0)
    8000520a:	dc4ff0ef          	jal	800047ce <filewrite>
}
    8000520e:	70a2                	ld	ra,40(sp)
    80005210:	7402                	ld	s0,32(sp)
    80005212:	6145                	addi	sp,sp,48
    80005214:	8082                	ret

0000000080005216 <sys_close>:
{
    80005216:	1101                	addi	sp,sp,-32
    80005218:	ec06                	sd	ra,24(sp)
    8000521a:	e822                	sd	s0,16(sp)
    8000521c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000521e:	fe040613          	addi	a2,s0,-32
    80005222:	fec40593          	addi	a1,s0,-20
    80005226:	4501                	li	a0,0
    80005228:	d43ff0ef          	jal	80004f6a <argfd>
    return -1;
    8000522c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000522e:	02054063          	bltz	a0,8000524e <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80005232:	ea0fc0ef          	jal	800018d2 <myproc>
    80005236:	fec42783          	lw	a5,-20(s0)
    8000523a:	07e9                	addi	a5,a5,26
    8000523c:	078e                	slli	a5,a5,0x3
    8000523e:	953e                	add	a0,a0,a5
    80005240:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80005244:	fe043503          	ld	a0,-32(s0)
    80005248:	ba8ff0ef          	jal	800045f0 <fileclose>
  return 0;
    8000524c:	4781                	li	a5,0
}
    8000524e:	853e                	mv	a0,a5
    80005250:	60e2                	ld	ra,24(sp)
    80005252:	6442                	ld	s0,16(sp)
    80005254:	6105                	addi	sp,sp,32
    80005256:	8082                	ret

0000000080005258 <sys_fstat>:
{
    80005258:	1101                	addi	sp,sp,-32
    8000525a:	ec06                	sd	ra,24(sp)
    8000525c:	e822                	sd	s0,16(sp)
    8000525e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005260:	fe040593          	addi	a1,s0,-32
    80005264:	4505                	li	a0,1
    80005266:	dc6fd0ef          	jal	8000282c <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000526a:	fe840613          	addi	a2,s0,-24
    8000526e:	4581                	li	a1,0
    80005270:	4501                	li	a0,0
    80005272:	cf9ff0ef          	jal	80004f6a <argfd>
    80005276:	87aa                	mv	a5,a0
    return -1;
    80005278:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000527a:	0007c863          	bltz	a5,8000528a <sys_fstat+0x32>
  return filestat(f, st);
    8000527e:	fe043583          	ld	a1,-32(s0)
    80005282:	fe843503          	ld	a0,-24(s0)
    80005286:	c2cff0ef          	jal	800046b2 <filestat>
}
    8000528a:	60e2                	ld	ra,24(sp)
    8000528c:	6442                	ld	s0,16(sp)
    8000528e:	6105                	addi	sp,sp,32
    80005290:	8082                	ret

0000000080005292 <sys_link>:
{
    80005292:	7169                	addi	sp,sp,-304
    80005294:	f606                	sd	ra,296(sp)
    80005296:	f222                	sd	s0,288(sp)
    80005298:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000529a:	08000613          	li	a2,128
    8000529e:	ed040593          	addi	a1,s0,-304
    800052a2:	4501                	li	a0,0
    800052a4:	da4fd0ef          	jal	80002848 <argstr>
    return -1;
    800052a8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052aa:	0c054e63          	bltz	a0,80005386 <sys_link+0xf4>
    800052ae:	08000613          	li	a2,128
    800052b2:	f5040593          	addi	a1,s0,-176
    800052b6:	4505                	li	a0,1
    800052b8:	d90fd0ef          	jal	80002848 <argstr>
    return -1;
    800052bc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052be:	0c054463          	bltz	a0,80005386 <sys_link+0xf4>
    800052c2:	ee26                	sd	s1,280(sp)
  begin_op();
    800052c4:	f21fe0ef          	jal	800041e4 <begin_op>
  if((ip = namei(old)) == 0){
    800052c8:	ed040513          	addi	a0,s0,-304
    800052cc:	d45fe0ef          	jal	80004010 <namei>
    800052d0:	84aa                	mv	s1,a0
    800052d2:	c53d                	beqz	a0,80005340 <sys_link+0xae>
  ilock(ip);
    800052d4:	d26fe0ef          	jal	800037fa <ilock>
  if(ip->type == T_DIR){
    800052d8:	04449703          	lh	a4,68(s1)
    800052dc:	4785                	li	a5,1
    800052de:	06f70663          	beq	a4,a5,8000534a <sys_link+0xb8>
    800052e2:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800052e4:	04a4d783          	lhu	a5,74(s1)
    800052e8:	2785                	addiw	a5,a5,1
    800052ea:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800052ee:	8526                	mv	a0,s1
    800052f0:	c56fe0ef          	jal	80003746 <iupdate>
  iunlock(ip);
    800052f4:	8526                	mv	a0,s1
    800052f6:	db2fe0ef          	jal	800038a8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800052fa:	fd040593          	addi	a1,s0,-48
    800052fe:	f5040513          	addi	a0,s0,-176
    80005302:	d29fe0ef          	jal	8000402a <nameiparent>
    80005306:	892a                	mv	s2,a0
    80005308:	cd21                	beqz	a0,80005360 <sys_link+0xce>
  ilock(dp);
    8000530a:	cf0fe0ef          	jal	800037fa <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000530e:	00092703          	lw	a4,0(s2)
    80005312:	409c                	lw	a5,0(s1)
    80005314:	04f71363          	bne	a4,a5,8000535a <sys_link+0xc8>
    80005318:	40d0                	lw	a2,4(s1)
    8000531a:	fd040593          	addi	a1,s0,-48
    8000531e:	854a                	mv	a0,s2
    80005320:	c57fe0ef          	jal	80003f76 <dirlink>
    80005324:	02054b63          	bltz	a0,8000535a <sys_link+0xc8>
  iunlockput(dp);
    80005328:	854a                	mv	a0,s2
    8000532a:	edafe0ef          	jal	80003a04 <iunlockput>
  iput(ip);
    8000532e:	8526                	mv	a0,s1
    80005330:	e4cfe0ef          	jal	8000397c <iput>
  end_op();
    80005334:	f1bfe0ef          	jal	8000424e <end_op>
  return 0;
    80005338:	4781                	li	a5,0
    8000533a:	64f2                	ld	s1,280(sp)
    8000533c:	6952                	ld	s2,272(sp)
    8000533e:	a0a1                	j	80005386 <sys_link+0xf4>
    end_op();
    80005340:	f0ffe0ef          	jal	8000424e <end_op>
    return -1;
    80005344:	57fd                	li	a5,-1
    80005346:	64f2                	ld	s1,280(sp)
    80005348:	a83d                	j	80005386 <sys_link+0xf4>
    iunlockput(ip);
    8000534a:	8526                	mv	a0,s1
    8000534c:	eb8fe0ef          	jal	80003a04 <iunlockput>
    end_op();
    80005350:	efffe0ef          	jal	8000424e <end_op>
    return -1;
    80005354:	57fd                	li	a5,-1
    80005356:	64f2                	ld	s1,280(sp)
    80005358:	a03d                	j	80005386 <sys_link+0xf4>
    iunlockput(dp);
    8000535a:	854a                	mv	a0,s2
    8000535c:	ea8fe0ef          	jal	80003a04 <iunlockput>
  ilock(ip);
    80005360:	8526                	mv	a0,s1
    80005362:	c98fe0ef          	jal	800037fa <ilock>
  ip->nlink--;
    80005366:	04a4d783          	lhu	a5,74(s1)
    8000536a:	37fd                	addiw	a5,a5,-1
    8000536c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005370:	8526                	mv	a0,s1
    80005372:	bd4fe0ef          	jal	80003746 <iupdate>
  iunlockput(ip);
    80005376:	8526                	mv	a0,s1
    80005378:	e8cfe0ef          	jal	80003a04 <iunlockput>
  end_op();
    8000537c:	ed3fe0ef          	jal	8000424e <end_op>
  return -1;
    80005380:	57fd                	li	a5,-1
    80005382:	64f2                	ld	s1,280(sp)
    80005384:	6952                	ld	s2,272(sp)
}
    80005386:	853e                	mv	a0,a5
    80005388:	70b2                	ld	ra,296(sp)
    8000538a:	7412                	ld	s0,288(sp)
    8000538c:	6155                	addi	sp,sp,304
    8000538e:	8082                	ret

0000000080005390 <sys_unlink>:
{
    80005390:	7151                	addi	sp,sp,-240
    80005392:	f586                	sd	ra,232(sp)
    80005394:	f1a2                	sd	s0,224(sp)
    80005396:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005398:	08000613          	li	a2,128
    8000539c:	f3040593          	addi	a1,s0,-208
    800053a0:	4501                	li	a0,0
    800053a2:	ca6fd0ef          	jal	80002848 <argstr>
    800053a6:	16054063          	bltz	a0,80005506 <sys_unlink+0x176>
    800053aa:	eda6                	sd	s1,216(sp)
  begin_op();
    800053ac:	e39fe0ef          	jal	800041e4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800053b0:	fb040593          	addi	a1,s0,-80
    800053b4:	f3040513          	addi	a0,s0,-208
    800053b8:	c73fe0ef          	jal	8000402a <nameiparent>
    800053bc:	84aa                	mv	s1,a0
    800053be:	c945                	beqz	a0,8000546e <sys_unlink+0xde>
  ilock(dp);
    800053c0:	c3afe0ef          	jal	800037fa <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800053c4:	00002597          	auipc	a1,0x2
    800053c8:	21c58593          	addi	a1,a1,540 # 800075e0 <etext+0x5e0>
    800053cc:	fb040513          	addi	a0,s0,-80
    800053d0:	9c5fe0ef          	jal	80003d94 <namecmp>
    800053d4:	10050e63          	beqz	a0,800054f0 <sys_unlink+0x160>
    800053d8:	00002597          	auipc	a1,0x2
    800053dc:	21058593          	addi	a1,a1,528 # 800075e8 <etext+0x5e8>
    800053e0:	fb040513          	addi	a0,s0,-80
    800053e4:	9b1fe0ef          	jal	80003d94 <namecmp>
    800053e8:	10050463          	beqz	a0,800054f0 <sys_unlink+0x160>
    800053ec:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800053ee:	f2c40613          	addi	a2,s0,-212
    800053f2:	fb040593          	addi	a1,s0,-80
    800053f6:	8526                	mv	a0,s1
    800053f8:	9b3fe0ef          	jal	80003daa <dirlookup>
    800053fc:	892a                	mv	s2,a0
    800053fe:	0e050863          	beqz	a0,800054ee <sys_unlink+0x15e>
  ilock(ip);
    80005402:	bf8fe0ef          	jal	800037fa <ilock>
  if(ip->nlink < 1)
    80005406:	04a91783          	lh	a5,74(s2)
    8000540a:	06f05763          	blez	a5,80005478 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000540e:	04491703          	lh	a4,68(s2)
    80005412:	4785                	li	a5,1
    80005414:	06f70963          	beq	a4,a5,80005486 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005418:	4641                	li	a2,16
    8000541a:	4581                	li	a1,0
    8000541c:	fc040513          	addi	a0,s0,-64
    80005420:	883fb0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005424:	4741                	li	a4,16
    80005426:	f2c42683          	lw	a3,-212(s0)
    8000542a:	fc040613          	addi	a2,s0,-64
    8000542e:	4581                	li	a1,0
    80005430:	8526                	mv	a0,s1
    80005432:	855fe0ef          	jal	80003c86 <writei>
    80005436:	47c1                	li	a5,16
    80005438:	08f51b63          	bne	a0,a5,800054ce <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    8000543c:	04491703          	lh	a4,68(s2)
    80005440:	4785                	li	a5,1
    80005442:	08f70d63          	beq	a4,a5,800054dc <sys_unlink+0x14c>
  iunlockput(dp);
    80005446:	8526                	mv	a0,s1
    80005448:	dbcfe0ef          	jal	80003a04 <iunlockput>
  ip->nlink--;
    8000544c:	04a95783          	lhu	a5,74(s2)
    80005450:	37fd                	addiw	a5,a5,-1
    80005452:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005456:	854a                	mv	a0,s2
    80005458:	aeefe0ef          	jal	80003746 <iupdate>
  iunlockput(ip);
    8000545c:	854a                	mv	a0,s2
    8000545e:	da6fe0ef          	jal	80003a04 <iunlockput>
  end_op();
    80005462:	dedfe0ef          	jal	8000424e <end_op>
  return 0;
    80005466:	4501                	li	a0,0
    80005468:	64ee                	ld	s1,216(sp)
    8000546a:	694e                	ld	s2,208(sp)
    8000546c:	a849                	j	800054fe <sys_unlink+0x16e>
    end_op();
    8000546e:	de1fe0ef          	jal	8000424e <end_op>
    return -1;
    80005472:	557d                	li	a0,-1
    80005474:	64ee                	ld	s1,216(sp)
    80005476:	a061                	j	800054fe <sys_unlink+0x16e>
    80005478:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    8000547a:	00002517          	auipc	a0,0x2
    8000547e:	17650513          	addi	a0,a0,374 # 800075f0 <etext+0x5f0>
    80005482:	b5efb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005486:	04c92703          	lw	a4,76(s2)
    8000548a:	02000793          	li	a5,32
    8000548e:	f8e7f5e3          	bgeu	a5,a4,80005418 <sys_unlink+0x88>
    80005492:	e5ce                	sd	s3,200(sp)
    80005494:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005498:	4741                	li	a4,16
    8000549a:	86ce                	mv	a3,s3
    8000549c:	f1840613          	addi	a2,s0,-232
    800054a0:	4581                	li	a1,0
    800054a2:	854a                	mv	a0,s2
    800054a4:	ee6fe0ef          	jal	80003b8a <readi>
    800054a8:	47c1                	li	a5,16
    800054aa:	00f51c63          	bne	a0,a5,800054c2 <sys_unlink+0x132>
    if(de.inum != 0)
    800054ae:	f1845783          	lhu	a5,-232(s0)
    800054b2:	efa1                	bnez	a5,8000550a <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800054b4:	29c1                	addiw	s3,s3,16
    800054b6:	04c92783          	lw	a5,76(s2)
    800054ba:	fcf9efe3          	bltu	s3,a5,80005498 <sys_unlink+0x108>
    800054be:	69ae                	ld	s3,200(sp)
    800054c0:	bfa1                	j	80005418 <sys_unlink+0x88>
      panic("isdirempty: readi");
    800054c2:	00002517          	auipc	a0,0x2
    800054c6:	14650513          	addi	a0,a0,326 # 80007608 <etext+0x608>
    800054ca:	b16fb0ef          	jal	800007e0 <panic>
    800054ce:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800054d0:	00002517          	auipc	a0,0x2
    800054d4:	15050513          	addi	a0,a0,336 # 80007620 <etext+0x620>
    800054d8:	b08fb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    800054dc:	04a4d783          	lhu	a5,74(s1)
    800054e0:	37fd                	addiw	a5,a5,-1
    800054e2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800054e6:	8526                	mv	a0,s1
    800054e8:	a5efe0ef          	jal	80003746 <iupdate>
    800054ec:	bfa9                	j	80005446 <sys_unlink+0xb6>
    800054ee:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800054f0:	8526                	mv	a0,s1
    800054f2:	d12fe0ef          	jal	80003a04 <iunlockput>
  end_op();
    800054f6:	d59fe0ef          	jal	8000424e <end_op>
  return -1;
    800054fa:	557d                	li	a0,-1
    800054fc:	64ee                	ld	s1,216(sp)
}
    800054fe:	70ae                	ld	ra,232(sp)
    80005500:	740e                	ld	s0,224(sp)
    80005502:	616d                	addi	sp,sp,240
    80005504:	8082                	ret
    return -1;
    80005506:	557d                	li	a0,-1
    80005508:	bfdd                	j	800054fe <sys_unlink+0x16e>
    iunlockput(ip);
    8000550a:	854a                	mv	a0,s2
    8000550c:	cf8fe0ef          	jal	80003a04 <iunlockput>
    goto bad;
    80005510:	694e                	ld	s2,208(sp)
    80005512:	69ae                	ld	s3,200(sp)
    80005514:	bff1                	j	800054f0 <sys_unlink+0x160>

0000000080005516 <sys_open>:

uint64
sys_open(void)
{
    80005516:	7131                	addi	sp,sp,-192
    80005518:	fd06                	sd	ra,184(sp)
    8000551a:	f922                	sd	s0,176(sp)
    8000551c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000551e:	f4c40593          	addi	a1,s0,-180
    80005522:	4505                	li	a0,1
    80005524:	aecfd0ef          	jal	80002810 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005528:	08000613          	li	a2,128
    8000552c:	f5040593          	addi	a1,s0,-176
    80005530:	4501                	li	a0,0
    80005532:	b16fd0ef          	jal	80002848 <argstr>
    80005536:	87aa                	mv	a5,a0
    return -1;
    80005538:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000553a:	0a07c263          	bltz	a5,800055de <sys_open+0xc8>
    8000553e:	f526                	sd	s1,168(sp)

  begin_op();
    80005540:	ca5fe0ef          	jal	800041e4 <begin_op>

  if(omode & O_CREATE){
    80005544:	f4c42783          	lw	a5,-180(s0)
    80005548:	2007f793          	andi	a5,a5,512
    8000554c:	c3d5                	beqz	a5,800055f0 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000554e:	4681                	li	a3,0
    80005550:	4601                	li	a2,0
    80005552:	4589                	li	a1,2
    80005554:	f5040513          	addi	a0,s0,-176
    80005558:	aa9ff0ef          	jal	80005000 <create>
    8000555c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000555e:	c541                	beqz	a0,800055e6 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005560:	04449703          	lh	a4,68(s1)
    80005564:	478d                	li	a5,3
    80005566:	00f71763          	bne	a4,a5,80005574 <sys_open+0x5e>
    8000556a:	0464d703          	lhu	a4,70(s1)
    8000556e:	47a5                	li	a5,9
    80005570:	0ae7ed63          	bltu	a5,a4,8000562a <sys_open+0x114>
    80005574:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005576:	fd7fe0ef          	jal	8000454c <filealloc>
    8000557a:	892a                	mv	s2,a0
    8000557c:	c179                	beqz	a0,80005642 <sys_open+0x12c>
    8000557e:	ed4e                	sd	s3,152(sp)
    80005580:	a43ff0ef          	jal	80004fc2 <fdalloc>
    80005584:	89aa                	mv	s3,a0
    80005586:	0a054a63          	bltz	a0,8000563a <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000558a:	04449703          	lh	a4,68(s1)
    8000558e:	478d                	li	a5,3
    80005590:	0cf70263          	beq	a4,a5,80005654 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005594:	4789                	li	a5,2
    80005596:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000559a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000559e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800055a2:	f4c42783          	lw	a5,-180(s0)
    800055a6:	0017c713          	xori	a4,a5,1
    800055aa:	8b05                	andi	a4,a4,1
    800055ac:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800055b0:	0037f713          	andi	a4,a5,3
    800055b4:	00e03733          	snez	a4,a4
    800055b8:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800055bc:	4007f793          	andi	a5,a5,1024
    800055c0:	c791                	beqz	a5,800055cc <sys_open+0xb6>
    800055c2:	04449703          	lh	a4,68(s1)
    800055c6:	4789                	li	a5,2
    800055c8:	08f70d63          	beq	a4,a5,80005662 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    800055cc:	8526                	mv	a0,s1
    800055ce:	adafe0ef          	jal	800038a8 <iunlock>
  end_op();
    800055d2:	c7dfe0ef          	jal	8000424e <end_op>

  return fd;
    800055d6:	854e                	mv	a0,s3
    800055d8:	74aa                	ld	s1,168(sp)
    800055da:	790a                	ld	s2,160(sp)
    800055dc:	69ea                	ld	s3,152(sp)
}
    800055de:	70ea                	ld	ra,184(sp)
    800055e0:	744a                	ld	s0,176(sp)
    800055e2:	6129                	addi	sp,sp,192
    800055e4:	8082                	ret
      end_op();
    800055e6:	c69fe0ef          	jal	8000424e <end_op>
      return -1;
    800055ea:	557d                	li	a0,-1
    800055ec:	74aa                	ld	s1,168(sp)
    800055ee:	bfc5                	j	800055de <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800055f0:	f5040513          	addi	a0,s0,-176
    800055f4:	a1dfe0ef          	jal	80004010 <namei>
    800055f8:	84aa                	mv	s1,a0
    800055fa:	c11d                	beqz	a0,80005620 <sys_open+0x10a>
    ilock(ip);
    800055fc:	9fefe0ef          	jal	800037fa <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005600:	04449703          	lh	a4,68(s1)
    80005604:	4785                	li	a5,1
    80005606:	f4f71de3          	bne	a4,a5,80005560 <sys_open+0x4a>
    8000560a:	f4c42783          	lw	a5,-180(s0)
    8000560e:	d3bd                	beqz	a5,80005574 <sys_open+0x5e>
      iunlockput(ip);
    80005610:	8526                	mv	a0,s1
    80005612:	bf2fe0ef          	jal	80003a04 <iunlockput>
      end_op();
    80005616:	c39fe0ef          	jal	8000424e <end_op>
      return -1;
    8000561a:	557d                	li	a0,-1
    8000561c:	74aa                	ld	s1,168(sp)
    8000561e:	b7c1                	j	800055de <sys_open+0xc8>
      end_op();
    80005620:	c2ffe0ef          	jal	8000424e <end_op>
      return -1;
    80005624:	557d                	li	a0,-1
    80005626:	74aa                	ld	s1,168(sp)
    80005628:	bf5d                	j	800055de <sys_open+0xc8>
    iunlockput(ip);
    8000562a:	8526                	mv	a0,s1
    8000562c:	bd8fe0ef          	jal	80003a04 <iunlockput>
    end_op();
    80005630:	c1ffe0ef          	jal	8000424e <end_op>
    return -1;
    80005634:	557d                	li	a0,-1
    80005636:	74aa                	ld	s1,168(sp)
    80005638:	b75d                	j	800055de <sys_open+0xc8>
      fileclose(f);
    8000563a:	854a                	mv	a0,s2
    8000563c:	fb5fe0ef          	jal	800045f0 <fileclose>
    80005640:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005642:	8526                	mv	a0,s1
    80005644:	bc0fe0ef          	jal	80003a04 <iunlockput>
    end_op();
    80005648:	c07fe0ef          	jal	8000424e <end_op>
    return -1;
    8000564c:	557d                	li	a0,-1
    8000564e:	74aa                	ld	s1,168(sp)
    80005650:	790a                	ld	s2,160(sp)
    80005652:	b771                	j	800055de <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005654:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005658:	04649783          	lh	a5,70(s1)
    8000565c:	02f91223          	sh	a5,36(s2)
    80005660:	bf3d                	j	8000559e <sys_open+0x88>
    itrunc(ip);
    80005662:	8526                	mv	a0,s1
    80005664:	a84fe0ef          	jal	800038e8 <itrunc>
    80005668:	b795                	j	800055cc <sys_open+0xb6>

000000008000566a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000566a:	7175                	addi	sp,sp,-144
    8000566c:	e506                	sd	ra,136(sp)
    8000566e:	e122                	sd	s0,128(sp)
    80005670:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005672:	b73fe0ef          	jal	800041e4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005676:	08000613          	li	a2,128
    8000567a:	f7040593          	addi	a1,s0,-144
    8000567e:	4501                	li	a0,0
    80005680:	9c8fd0ef          	jal	80002848 <argstr>
    80005684:	02054363          	bltz	a0,800056aa <sys_mkdir+0x40>
    80005688:	4681                	li	a3,0
    8000568a:	4601                	li	a2,0
    8000568c:	4585                	li	a1,1
    8000568e:	f7040513          	addi	a0,s0,-144
    80005692:	96fff0ef          	jal	80005000 <create>
    80005696:	c911                	beqz	a0,800056aa <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005698:	b6cfe0ef          	jal	80003a04 <iunlockput>
  end_op();
    8000569c:	bb3fe0ef          	jal	8000424e <end_op>
  return 0;
    800056a0:	4501                	li	a0,0
}
    800056a2:	60aa                	ld	ra,136(sp)
    800056a4:	640a                	ld	s0,128(sp)
    800056a6:	6149                	addi	sp,sp,144
    800056a8:	8082                	ret
    end_op();
    800056aa:	ba5fe0ef          	jal	8000424e <end_op>
    return -1;
    800056ae:	557d                	li	a0,-1
    800056b0:	bfcd                	j	800056a2 <sys_mkdir+0x38>

00000000800056b2 <sys_mknod>:

uint64
sys_mknod(void)
{
    800056b2:	7135                	addi	sp,sp,-160
    800056b4:	ed06                	sd	ra,152(sp)
    800056b6:	e922                	sd	s0,144(sp)
    800056b8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800056ba:	b2bfe0ef          	jal	800041e4 <begin_op>
  argint(1, &major);
    800056be:	f6c40593          	addi	a1,s0,-148
    800056c2:	4505                	li	a0,1
    800056c4:	94cfd0ef          	jal	80002810 <argint>
  argint(2, &minor);
    800056c8:	f6840593          	addi	a1,s0,-152
    800056cc:	4509                	li	a0,2
    800056ce:	942fd0ef          	jal	80002810 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800056d2:	08000613          	li	a2,128
    800056d6:	f7040593          	addi	a1,s0,-144
    800056da:	4501                	li	a0,0
    800056dc:	96cfd0ef          	jal	80002848 <argstr>
    800056e0:	02054563          	bltz	a0,8000570a <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800056e4:	f6841683          	lh	a3,-152(s0)
    800056e8:	f6c41603          	lh	a2,-148(s0)
    800056ec:	458d                	li	a1,3
    800056ee:	f7040513          	addi	a0,s0,-144
    800056f2:	90fff0ef          	jal	80005000 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800056f6:	c911                	beqz	a0,8000570a <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800056f8:	b0cfe0ef          	jal	80003a04 <iunlockput>
  end_op();
    800056fc:	b53fe0ef          	jal	8000424e <end_op>
  return 0;
    80005700:	4501                	li	a0,0
}
    80005702:	60ea                	ld	ra,152(sp)
    80005704:	644a                	ld	s0,144(sp)
    80005706:	610d                	addi	sp,sp,160
    80005708:	8082                	ret
    end_op();
    8000570a:	b45fe0ef          	jal	8000424e <end_op>
    return -1;
    8000570e:	557d                	li	a0,-1
    80005710:	bfcd                	j	80005702 <sys_mknod+0x50>

0000000080005712 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005712:	7135                	addi	sp,sp,-160
    80005714:	ed06                	sd	ra,152(sp)
    80005716:	e922                	sd	s0,144(sp)
    80005718:	e14a                	sd	s2,128(sp)
    8000571a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000571c:	9b6fc0ef          	jal	800018d2 <myproc>
    80005720:	892a                	mv	s2,a0
  
  begin_op();
    80005722:	ac3fe0ef          	jal	800041e4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005726:	08000613          	li	a2,128
    8000572a:	f6040593          	addi	a1,s0,-160
    8000572e:	4501                	li	a0,0
    80005730:	918fd0ef          	jal	80002848 <argstr>
    80005734:	04054363          	bltz	a0,8000577a <sys_chdir+0x68>
    80005738:	e526                	sd	s1,136(sp)
    8000573a:	f6040513          	addi	a0,s0,-160
    8000573e:	8d3fe0ef          	jal	80004010 <namei>
    80005742:	84aa                	mv	s1,a0
    80005744:	c915                	beqz	a0,80005778 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005746:	8b4fe0ef          	jal	800037fa <ilock>
  if(ip->type != T_DIR){
    8000574a:	04449703          	lh	a4,68(s1)
    8000574e:	4785                	li	a5,1
    80005750:	02f71963          	bne	a4,a5,80005782 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005754:	8526                	mv	a0,s1
    80005756:	952fe0ef          	jal	800038a8 <iunlock>
  iput(p->cwd);
    8000575a:	15893503          	ld	a0,344(s2)
    8000575e:	a1efe0ef          	jal	8000397c <iput>
  end_op();
    80005762:	aedfe0ef          	jal	8000424e <end_op>
  p->cwd = ip;
    80005766:	14993c23          	sd	s1,344(s2)
  return 0;
    8000576a:	4501                	li	a0,0
    8000576c:	64aa                	ld	s1,136(sp)
}
    8000576e:	60ea                	ld	ra,152(sp)
    80005770:	644a                	ld	s0,144(sp)
    80005772:	690a                	ld	s2,128(sp)
    80005774:	610d                	addi	sp,sp,160
    80005776:	8082                	ret
    80005778:	64aa                	ld	s1,136(sp)
    end_op();
    8000577a:	ad5fe0ef          	jal	8000424e <end_op>
    return -1;
    8000577e:	557d                	li	a0,-1
    80005780:	b7fd                	j	8000576e <sys_chdir+0x5c>
    iunlockput(ip);
    80005782:	8526                	mv	a0,s1
    80005784:	a80fe0ef          	jal	80003a04 <iunlockput>
    end_op();
    80005788:	ac7fe0ef          	jal	8000424e <end_op>
    return -1;
    8000578c:	557d                	li	a0,-1
    8000578e:	64aa                	ld	s1,136(sp)
    80005790:	bff9                	j	8000576e <sys_chdir+0x5c>

0000000080005792 <sys_exec>:

uint64
sys_exec(void)
{
    80005792:	7121                	addi	sp,sp,-448
    80005794:	ff06                	sd	ra,440(sp)
    80005796:	fb22                	sd	s0,432(sp)
    80005798:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000579a:	e4840593          	addi	a1,s0,-440
    8000579e:	4505                	li	a0,1
    800057a0:	88cfd0ef          	jal	8000282c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800057a4:	08000613          	li	a2,128
    800057a8:	f5040593          	addi	a1,s0,-176
    800057ac:	4501                	li	a0,0
    800057ae:	89afd0ef          	jal	80002848 <argstr>
    800057b2:	87aa                	mv	a5,a0
    return -1;
    800057b4:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800057b6:	0c07c463          	bltz	a5,8000587e <sys_exec+0xec>
    800057ba:	f726                	sd	s1,424(sp)
    800057bc:	f34a                	sd	s2,416(sp)
    800057be:	ef4e                	sd	s3,408(sp)
    800057c0:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800057c2:	10000613          	li	a2,256
    800057c6:	4581                	li	a1,0
    800057c8:	e5040513          	addi	a0,s0,-432
    800057cc:	cd6fb0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800057d0:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800057d4:	89a6                	mv	s3,s1
    800057d6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800057d8:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800057dc:	00391513          	slli	a0,s2,0x3
    800057e0:	e4040593          	addi	a1,s0,-448
    800057e4:	e4843783          	ld	a5,-440(s0)
    800057e8:	953e                	add	a0,a0,a5
    800057ea:	f9dfc0ef          	jal	80002786 <fetchaddr>
    800057ee:	02054663          	bltz	a0,8000581a <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800057f2:	e4043783          	ld	a5,-448(s0)
    800057f6:	c3a9                	beqz	a5,80005838 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800057f8:	b06fb0ef          	jal	80000afe <kalloc>
    800057fc:	85aa                	mv	a1,a0
    800057fe:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005802:	cd01                	beqz	a0,8000581a <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005804:	6605                	lui	a2,0x1
    80005806:	e4043503          	ld	a0,-448(s0)
    8000580a:	fc7fc0ef          	jal	800027d0 <fetchstr>
    8000580e:	00054663          	bltz	a0,8000581a <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005812:	0905                	addi	s2,s2,1
    80005814:	09a1                	addi	s3,s3,8
    80005816:	fd4913e3          	bne	s2,s4,800057dc <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000581a:	f5040913          	addi	s2,s0,-176
    8000581e:	6088                	ld	a0,0(s1)
    80005820:	c931                	beqz	a0,80005874 <sys_exec+0xe2>
    kfree(argv[i]);
    80005822:	9fafb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005826:	04a1                	addi	s1,s1,8
    80005828:	ff249be3          	bne	s1,s2,8000581e <sys_exec+0x8c>
  return -1;
    8000582c:	557d                	li	a0,-1
    8000582e:	74ba                	ld	s1,424(sp)
    80005830:	791a                	ld	s2,416(sp)
    80005832:	69fa                	ld	s3,408(sp)
    80005834:	6a5a                	ld	s4,400(sp)
    80005836:	a0a1                	j	8000587e <sys_exec+0xec>
      argv[i] = 0;
    80005838:	0009079b          	sext.w	a5,s2
    8000583c:	078e                	slli	a5,a5,0x3
    8000583e:	fd078793          	addi	a5,a5,-48
    80005842:	97a2                	add	a5,a5,s0
    80005844:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80005848:	e5040593          	addi	a1,s0,-432
    8000584c:	f5040513          	addi	a0,s0,-176
    80005850:	ba8ff0ef          	jal	80004bf8 <kexec>
    80005854:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005856:	f5040993          	addi	s3,s0,-176
    8000585a:	6088                	ld	a0,0(s1)
    8000585c:	c511                	beqz	a0,80005868 <sys_exec+0xd6>
    kfree(argv[i]);
    8000585e:	9befb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005862:	04a1                	addi	s1,s1,8
    80005864:	ff349be3          	bne	s1,s3,8000585a <sys_exec+0xc8>
  return ret;
    80005868:	854a                	mv	a0,s2
    8000586a:	74ba                	ld	s1,424(sp)
    8000586c:	791a                	ld	s2,416(sp)
    8000586e:	69fa                	ld	s3,408(sp)
    80005870:	6a5a                	ld	s4,400(sp)
    80005872:	a031                	j	8000587e <sys_exec+0xec>
  return -1;
    80005874:	557d                	li	a0,-1
    80005876:	74ba                	ld	s1,424(sp)
    80005878:	791a                	ld	s2,416(sp)
    8000587a:	69fa                	ld	s3,408(sp)
    8000587c:	6a5a                	ld	s4,400(sp)
}
    8000587e:	70fa                	ld	ra,440(sp)
    80005880:	745a                	ld	s0,432(sp)
    80005882:	6139                	addi	sp,sp,448
    80005884:	8082                	ret

0000000080005886 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005886:	7139                	addi	sp,sp,-64
    80005888:	fc06                	sd	ra,56(sp)
    8000588a:	f822                	sd	s0,48(sp)
    8000588c:	f426                	sd	s1,40(sp)
    8000588e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005890:	842fc0ef          	jal	800018d2 <myproc>
    80005894:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005896:	fd840593          	addi	a1,s0,-40
    8000589a:	4501                	li	a0,0
    8000589c:	f91fc0ef          	jal	8000282c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800058a0:	fc840593          	addi	a1,s0,-56
    800058a4:	fd040513          	addi	a0,s0,-48
    800058a8:	852ff0ef          	jal	800048fa <pipealloc>
    return -1;
    800058ac:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800058ae:	0a054463          	bltz	a0,80005956 <sys_pipe+0xd0>
  fd0 = -1;
    800058b2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800058b6:	fd043503          	ld	a0,-48(s0)
    800058ba:	f08ff0ef          	jal	80004fc2 <fdalloc>
    800058be:	fca42223          	sw	a0,-60(s0)
    800058c2:	08054163          	bltz	a0,80005944 <sys_pipe+0xbe>
    800058c6:	fc843503          	ld	a0,-56(s0)
    800058ca:	ef8ff0ef          	jal	80004fc2 <fdalloc>
    800058ce:	fca42023          	sw	a0,-64(s0)
    800058d2:	06054063          	bltz	a0,80005932 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800058d6:	4691                	li	a3,4
    800058d8:	fc440613          	addi	a2,s0,-60
    800058dc:	fd843583          	ld	a1,-40(s0)
    800058e0:	6ca8                	ld	a0,88(s1)
    800058e2:	d05fb0ef          	jal	800015e6 <copyout>
    800058e6:	00054e63          	bltz	a0,80005902 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800058ea:	4691                	li	a3,4
    800058ec:	fc040613          	addi	a2,s0,-64
    800058f0:	fd843583          	ld	a1,-40(s0)
    800058f4:	0591                	addi	a1,a1,4
    800058f6:	6ca8                	ld	a0,88(s1)
    800058f8:	ceffb0ef          	jal	800015e6 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800058fc:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800058fe:	04055c63          	bgez	a0,80005956 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005902:	fc442783          	lw	a5,-60(s0)
    80005906:	07e9                	addi	a5,a5,26
    80005908:	078e                	slli	a5,a5,0x3
    8000590a:	97a6                	add	a5,a5,s1
    8000590c:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005910:	fc042783          	lw	a5,-64(s0)
    80005914:	07e9                	addi	a5,a5,26
    80005916:	078e                	slli	a5,a5,0x3
    80005918:	94be                	add	s1,s1,a5
    8000591a:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    8000591e:	fd043503          	ld	a0,-48(s0)
    80005922:	ccffe0ef          	jal	800045f0 <fileclose>
    fileclose(wf);
    80005926:	fc843503          	ld	a0,-56(s0)
    8000592a:	cc7fe0ef          	jal	800045f0 <fileclose>
    return -1;
    8000592e:	57fd                	li	a5,-1
    80005930:	a01d                	j	80005956 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005932:	fc442783          	lw	a5,-60(s0)
    80005936:	0007c763          	bltz	a5,80005944 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000593a:	07e9                	addi	a5,a5,26
    8000593c:	078e                	slli	a5,a5,0x3
    8000593e:	97a6                	add	a5,a5,s1
    80005940:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80005944:	fd043503          	ld	a0,-48(s0)
    80005948:	ca9fe0ef          	jal	800045f0 <fileclose>
    fileclose(wf);
    8000594c:	fc843503          	ld	a0,-56(s0)
    80005950:	ca1fe0ef          	jal	800045f0 <fileclose>
    return -1;
    80005954:	57fd                	li	a5,-1
}
    80005956:	853e                	mv	a0,a5
    80005958:	70e2                	ld	ra,56(sp)
    8000595a:	7442                	ld	s0,48(sp)
    8000595c:	74a2                	ld	s1,40(sp)
    8000595e:	6121                	addi	sp,sp,64
    80005960:	8082                	ret
	...

0000000080005970 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005970:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005972:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005974:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005976:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005978:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000597a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000597c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000597e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005980:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005982:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005984:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005986:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005988:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000598a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000598c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000598e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005990:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005992:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005994:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005996:	d01fc0ef          	jal	80002696 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000599a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000599c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000599e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800059a0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800059a2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800059a4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800059a6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800059a8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800059aa:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800059ac:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800059ae:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800059b0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800059b2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800059b4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800059b6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800059b8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800059ba:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800059bc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800059be:	10200073          	sret
	...

00000000800059ce <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800059ce:	1141                	addi	sp,sp,-16
    800059d0:	e422                	sd	s0,8(sp)
    800059d2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800059d4:	0c0007b7          	lui	a5,0xc000
    800059d8:	4705                	li	a4,1
    800059da:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800059dc:	0c0007b7          	lui	a5,0xc000
    800059e0:	c3d8                	sw	a4,4(a5)
}
    800059e2:	6422                	ld	s0,8(sp)
    800059e4:	0141                	addi	sp,sp,16
    800059e6:	8082                	ret

00000000800059e8 <plicinithart>:

void
plicinithart(void)
{
    800059e8:	1141                	addi	sp,sp,-16
    800059ea:	e406                	sd	ra,8(sp)
    800059ec:	e022                	sd	s0,0(sp)
    800059ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800059f0:	eb7fb0ef          	jal	800018a6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800059f4:	0085171b          	slliw	a4,a0,0x8
    800059f8:	0c0027b7          	lui	a5,0xc002
    800059fc:	97ba                	add	a5,a5,a4
    800059fe:	40200713          	li	a4,1026
    80005a02:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005a06:	00d5151b          	slliw	a0,a0,0xd
    80005a0a:	0c2017b7          	lui	a5,0xc201
    80005a0e:	97aa                	add	a5,a5,a0
    80005a10:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005a14:	60a2                	ld	ra,8(sp)
    80005a16:	6402                	ld	s0,0(sp)
    80005a18:	0141                	addi	sp,sp,16
    80005a1a:	8082                	ret

0000000080005a1c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005a1c:	1141                	addi	sp,sp,-16
    80005a1e:	e406                	sd	ra,8(sp)
    80005a20:	e022                	sd	s0,0(sp)
    80005a22:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005a24:	e83fb0ef          	jal	800018a6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005a28:	00d5151b          	slliw	a0,a0,0xd
    80005a2c:	0c2017b7          	lui	a5,0xc201
    80005a30:	97aa                	add	a5,a5,a0
  return irq;
}
    80005a32:	43c8                	lw	a0,4(a5)
    80005a34:	60a2                	ld	ra,8(sp)
    80005a36:	6402                	ld	s0,0(sp)
    80005a38:	0141                	addi	sp,sp,16
    80005a3a:	8082                	ret

0000000080005a3c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005a3c:	1101                	addi	sp,sp,-32
    80005a3e:	ec06                	sd	ra,24(sp)
    80005a40:	e822                	sd	s0,16(sp)
    80005a42:	e426                	sd	s1,8(sp)
    80005a44:	1000                	addi	s0,sp,32
    80005a46:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005a48:	e5ffb0ef          	jal	800018a6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005a4c:	00d5151b          	slliw	a0,a0,0xd
    80005a50:	0c2017b7          	lui	a5,0xc201
    80005a54:	97aa                	add	a5,a5,a0
    80005a56:	c3c4                	sw	s1,4(a5)
}
    80005a58:	60e2                	ld	ra,24(sp)
    80005a5a:	6442                	ld	s0,16(sp)
    80005a5c:	64a2                	ld	s1,8(sp)
    80005a5e:	6105                	addi	sp,sp,32
    80005a60:	8082                	ret

0000000080005a62 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005a62:	1141                	addi	sp,sp,-16
    80005a64:	e406                	sd	ra,8(sp)
    80005a66:	e022                	sd	s0,0(sp)
    80005a68:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005a6a:	479d                	li	a5,7
    80005a6c:	04a7ca63          	blt	a5,a0,80005ac0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005a70:	0001f797          	auipc	a5,0x1f
    80005a74:	c1078793          	addi	a5,a5,-1008 # 80024680 <disk>
    80005a78:	97aa                	add	a5,a5,a0
    80005a7a:	0187c783          	lbu	a5,24(a5)
    80005a7e:	e7b9                	bnez	a5,80005acc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005a80:	00451693          	slli	a3,a0,0x4
    80005a84:	0001f797          	auipc	a5,0x1f
    80005a88:	bfc78793          	addi	a5,a5,-1028 # 80024680 <disk>
    80005a8c:	6398                	ld	a4,0(a5)
    80005a8e:	9736                	add	a4,a4,a3
    80005a90:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005a94:	6398                	ld	a4,0(a5)
    80005a96:	9736                	add	a4,a4,a3
    80005a98:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005a9c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005aa0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005aa4:	97aa                	add	a5,a5,a0
    80005aa6:	4705                	li	a4,1
    80005aa8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005aac:	0001f517          	auipc	a0,0x1f
    80005ab0:	bec50513          	addi	a0,a0,-1044 # 80024698 <disk+0x18>
    80005ab4:	ca4fc0ef          	jal	80001f58 <wakeup>
}
    80005ab8:	60a2                	ld	ra,8(sp)
    80005aba:	6402                	ld	s0,0(sp)
    80005abc:	0141                	addi	sp,sp,16
    80005abe:	8082                	ret
    panic("free_desc 1");
    80005ac0:	00002517          	auipc	a0,0x2
    80005ac4:	b7050513          	addi	a0,a0,-1168 # 80007630 <etext+0x630>
    80005ac8:	d19fa0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    80005acc:	00002517          	auipc	a0,0x2
    80005ad0:	b7450513          	addi	a0,a0,-1164 # 80007640 <etext+0x640>
    80005ad4:	d0dfa0ef          	jal	800007e0 <panic>

0000000080005ad8 <virtio_disk_init>:
{
    80005ad8:	1101                	addi	sp,sp,-32
    80005ada:	ec06                	sd	ra,24(sp)
    80005adc:	e822                	sd	s0,16(sp)
    80005ade:	e426                	sd	s1,8(sp)
    80005ae0:	e04a                	sd	s2,0(sp)
    80005ae2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ae4:	00002597          	auipc	a1,0x2
    80005ae8:	b6c58593          	addi	a1,a1,-1172 # 80007650 <etext+0x650>
    80005aec:	0001f517          	auipc	a0,0x1f
    80005af0:	cbc50513          	addi	a0,a0,-836 # 800247a8 <disk+0x128>
    80005af4:	85afb0ef          	jal	80000b4e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005af8:	100017b7          	lui	a5,0x10001
    80005afc:	4398                	lw	a4,0(a5)
    80005afe:	2701                	sext.w	a4,a4
    80005b00:	747277b7          	lui	a5,0x74727
    80005b04:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005b08:	18f71063          	bne	a4,a5,80005c88 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005b0c:	100017b7          	lui	a5,0x10001
    80005b10:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005b12:	439c                	lw	a5,0(a5)
    80005b14:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005b16:	4709                	li	a4,2
    80005b18:	16e79863          	bne	a5,a4,80005c88 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b1c:	100017b7          	lui	a5,0x10001
    80005b20:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005b22:	439c                	lw	a5,0(a5)
    80005b24:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005b26:	16e79163          	bne	a5,a4,80005c88 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005b2a:	100017b7          	lui	a5,0x10001
    80005b2e:	47d8                	lw	a4,12(a5)
    80005b30:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b32:	554d47b7          	lui	a5,0x554d4
    80005b36:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005b3a:	14f71763          	bne	a4,a5,80005c88 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b3e:	100017b7          	lui	a5,0x10001
    80005b42:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b46:	4705                	li	a4,1
    80005b48:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b4a:	470d                	li	a4,3
    80005b4c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005b4e:	10001737          	lui	a4,0x10001
    80005b52:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005b54:	c7ffe737          	lui	a4,0xc7ffe
    80005b58:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd9f9f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005b5c:	8ef9                	and	a3,a3,a4
    80005b5e:	10001737          	lui	a4,0x10001
    80005b62:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b64:	472d                	li	a4,11
    80005b66:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b68:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005b6c:	439c                	lw	a5,0(a5)
    80005b6e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005b72:	8ba1                	andi	a5,a5,8
    80005b74:	12078063          	beqz	a5,80005c94 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005b78:	100017b7          	lui	a5,0x10001
    80005b7c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005b80:	100017b7          	lui	a5,0x10001
    80005b84:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005b88:	439c                	lw	a5,0(a5)
    80005b8a:	2781                	sext.w	a5,a5
    80005b8c:	10079a63          	bnez	a5,80005ca0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005b90:	100017b7          	lui	a5,0x10001
    80005b94:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005b98:	439c                	lw	a5,0(a5)
    80005b9a:	2781                	sext.w	a5,a5
  if(max == 0)
    80005b9c:	10078863          	beqz	a5,80005cac <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005ba0:	471d                	li	a4,7
    80005ba2:	10f77b63          	bgeu	a4,a5,80005cb8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005ba6:	f59fa0ef          	jal	80000afe <kalloc>
    80005baa:	0001f497          	auipc	s1,0x1f
    80005bae:	ad648493          	addi	s1,s1,-1322 # 80024680 <disk>
    80005bb2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005bb4:	f4bfa0ef          	jal	80000afe <kalloc>
    80005bb8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005bba:	f45fa0ef          	jal	80000afe <kalloc>
    80005bbe:	87aa                	mv	a5,a0
    80005bc0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005bc2:	6088                	ld	a0,0(s1)
    80005bc4:	10050063          	beqz	a0,80005cc4 <virtio_disk_init+0x1ec>
    80005bc8:	0001f717          	auipc	a4,0x1f
    80005bcc:	ac073703          	ld	a4,-1344(a4) # 80024688 <disk+0x8>
    80005bd0:	0e070a63          	beqz	a4,80005cc4 <virtio_disk_init+0x1ec>
    80005bd4:	0e078863          	beqz	a5,80005cc4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005bd8:	6605                	lui	a2,0x1
    80005bda:	4581                	li	a1,0
    80005bdc:	8c6fb0ef          	jal	80000ca2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005be0:	0001f497          	auipc	s1,0x1f
    80005be4:	aa048493          	addi	s1,s1,-1376 # 80024680 <disk>
    80005be8:	6605                	lui	a2,0x1
    80005bea:	4581                	li	a1,0
    80005bec:	6488                	ld	a0,8(s1)
    80005bee:	8b4fb0ef          	jal	80000ca2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005bf2:	6605                	lui	a2,0x1
    80005bf4:	4581                	li	a1,0
    80005bf6:	6888                	ld	a0,16(s1)
    80005bf8:	8aafb0ef          	jal	80000ca2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005bfc:	100017b7          	lui	a5,0x10001
    80005c00:	4721                	li	a4,8
    80005c02:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005c04:	4098                	lw	a4,0(s1)
    80005c06:	100017b7          	lui	a5,0x10001
    80005c0a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005c0e:	40d8                	lw	a4,4(s1)
    80005c10:	100017b7          	lui	a5,0x10001
    80005c14:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005c18:	649c                	ld	a5,8(s1)
    80005c1a:	0007869b          	sext.w	a3,a5
    80005c1e:	10001737          	lui	a4,0x10001
    80005c22:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005c26:	9781                	srai	a5,a5,0x20
    80005c28:	10001737          	lui	a4,0x10001
    80005c2c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005c30:	689c                	ld	a5,16(s1)
    80005c32:	0007869b          	sext.w	a3,a5
    80005c36:	10001737          	lui	a4,0x10001
    80005c3a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005c3e:	9781                	srai	a5,a5,0x20
    80005c40:	10001737          	lui	a4,0x10001
    80005c44:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005c48:	10001737          	lui	a4,0x10001
    80005c4c:	4785                	li	a5,1
    80005c4e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005c50:	00f48c23          	sb	a5,24(s1)
    80005c54:	00f48ca3          	sb	a5,25(s1)
    80005c58:	00f48d23          	sb	a5,26(s1)
    80005c5c:	00f48da3          	sb	a5,27(s1)
    80005c60:	00f48e23          	sb	a5,28(s1)
    80005c64:	00f48ea3          	sb	a5,29(s1)
    80005c68:	00f48f23          	sb	a5,30(s1)
    80005c6c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005c70:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c74:	100017b7          	lui	a5,0x10001
    80005c78:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80005c7c:	60e2                	ld	ra,24(sp)
    80005c7e:	6442                	ld	s0,16(sp)
    80005c80:	64a2                	ld	s1,8(sp)
    80005c82:	6902                	ld	s2,0(sp)
    80005c84:	6105                	addi	sp,sp,32
    80005c86:	8082                	ret
    panic("could not find virtio disk");
    80005c88:	00002517          	auipc	a0,0x2
    80005c8c:	9d850513          	addi	a0,a0,-1576 # 80007660 <etext+0x660>
    80005c90:	b51fa0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005c94:	00002517          	auipc	a0,0x2
    80005c98:	9ec50513          	addi	a0,a0,-1556 # 80007680 <etext+0x680>
    80005c9c:	b45fa0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    80005ca0:	00002517          	auipc	a0,0x2
    80005ca4:	a0050513          	addi	a0,a0,-1536 # 800076a0 <etext+0x6a0>
    80005ca8:	b39fa0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    80005cac:	00002517          	auipc	a0,0x2
    80005cb0:	a1450513          	addi	a0,a0,-1516 # 800076c0 <etext+0x6c0>
    80005cb4:	b2dfa0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    80005cb8:	00002517          	auipc	a0,0x2
    80005cbc:	a2850513          	addi	a0,a0,-1496 # 800076e0 <etext+0x6e0>
    80005cc0:	b21fa0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    80005cc4:	00002517          	auipc	a0,0x2
    80005cc8:	a3c50513          	addi	a0,a0,-1476 # 80007700 <etext+0x700>
    80005ccc:	b15fa0ef          	jal	800007e0 <panic>

0000000080005cd0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005cd0:	7159                	addi	sp,sp,-112
    80005cd2:	f486                	sd	ra,104(sp)
    80005cd4:	f0a2                	sd	s0,96(sp)
    80005cd6:	eca6                	sd	s1,88(sp)
    80005cd8:	e8ca                	sd	s2,80(sp)
    80005cda:	e4ce                	sd	s3,72(sp)
    80005cdc:	e0d2                	sd	s4,64(sp)
    80005cde:	fc56                	sd	s5,56(sp)
    80005ce0:	f85a                	sd	s6,48(sp)
    80005ce2:	f45e                	sd	s7,40(sp)
    80005ce4:	f062                	sd	s8,32(sp)
    80005ce6:	ec66                	sd	s9,24(sp)
    80005ce8:	1880                	addi	s0,sp,112
    80005cea:	8a2a                	mv	s4,a0
    80005cec:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005cee:	00c52c83          	lw	s9,12(a0)
    80005cf2:	001c9c9b          	slliw	s9,s9,0x1
    80005cf6:	1c82                	slli	s9,s9,0x20
    80005cf8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005cfc:	0001f517          	auipc	a0,0x1f
    80005d00:	aac50513          	addi	a0,a0,-1364 # 800247a8 <disk+0x128>
    80005d04:	ecbfa0ef          	jal	80000bce <acquire>
  for(int i = 0; i < 3; i++){
    80005d08:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005d0a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005d0c:	0001fb17          	auipc	s6,0x1f
    80005d10:	974b0b13          	addi	s6,s6,-1676 # 80024680 <disk>
  for(int i = 0; i < 3; i++){
    80005d14:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005d16:	0001fc17          	auipc	s8,0x1f
    80005d1a:	a92c0c13          	addi	s8,s8,-1390 # 800247a8 <disk+0x128>
    80005d1e:	a8b9                	j	80005d7c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005d20:	00fb0733          	add	a4,s6,a5
    80005d24:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005d28:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005d2a:	0207c563          	bltz	a5,80005d54 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80005d2e:	2905                	addiw	s2,s2,1
    80005d30:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005d32:	05590963          	beq	s2,s5,80005d84 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005d36:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005d38:	0001f717          	auipc	a4,0x1f
    80005d3c:	94870713          	addi	a4,a4,-1720 # 80024680 <disk>
    80005d40:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005d42:	01874683          	lbu	a3,24(a4)
    80005d46:	fee9                	bnez	a3,80005d20 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005d48:	2785                	addiw	a5,a5,1
    80005d4a:	0705                	addi	a4,a4,1
    80005d4c:	fe979be3          	bne	a5,s1,80005d42 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005d50:	57fd                	li	a5,-1
    80005d52:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005d54:	01205d63          	blez	s2,80005d6e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005d58:	f9042503          	lw	a0,-112(s0)
    80005d5c:	d07ff0ef          	jal	80005a62 <free_desc>
      for(int j = 0; j < i; j++)
    80005d60:	4785                	li	a5,1
    80005d62:	0127d663          	bge	a5,s2,80005d6e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005d66:	f9442503          	lw	a0,-108(s0)
    80005d6a:	cf9ff0ef          	jal	80005a62 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005d6e:	85e2                	mv	a1,s8
    80005d70:	0001f517          	auipc	a0,0x1f
    80005d74:	92850513          	addi	a0,a0,-1752 # 80024698 <disk+0x18>
    80005d78:	994fc0ef          	jal	80001f0c <sleep>
  for(int i = 0; i < 3; i++){
    80005d7c:	f9040613          	addi	a2,s0,-112
    80005d80:	894e                	mv	s2,s3
    80005d82:	bf55                	j	80005d36 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005d84:	f9042503          	lw	a0,-112(s0)
    80005d88:	00451693          	slli	a3,a0,0x4

  if(write)
    80005d8c:	0001f797          	auipc	a5,0x1f
    80005d90:	8f478793          	addi	a5,a5,-1804 # 80024680 <disk>
    80005d94:	00a50713          	addi	a4,a0,10
    80005d98:	0712                	slli	a4,a4,0x4
    80005d9a:	973e                	add	a4,a4,a5
    80005d9c:	01703633          	snez	a2,s7
    80005da0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005da2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005da6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005daa:	6398                	ld	a4,0(a5)
    80005dac:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005dae:	0a868613          	addi	a2,a3,168
    80005db2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005db4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005db6:	6390                	ld	a2,0(a5)
    80005db8:	00d605b3          	add	a1,a2,a3
    80005dbc:	4741                	li	a4,16
    80005dbe:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005dc0:	4805                	li	a6,1
    80005dc2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005dc6:	f9442703          	lw	a4,-108(s0)
    80005dca:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005dce:	0712                	slli	a4,a4,0x4
    80005dd0:	963a                	add	a2,a2,a4
    80005dd2:	058a0593          	addi	a1,s4,88
    80005dd6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005dd8:	0007b883          	ld	a7,0(a5)
    80005ddc:	9746                	add	a4,a4,a7
    80005dde:	40000613          	li	a2,1024
    80005de2:	c710                	sw	a2,8(a4)
  if(write)
    80005de4:	001bb613          	seqz	a2,s7
    80005de8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005dec:	00166613          	ori	a2,a2,1
    80005df0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005df4:	f9842583          	lw	a1,-104(s0)
    80005df8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005dfc:	00250613          	addi	a2,a0,2
    80005e00:	0612                	slli	a2,a2,0x4
    80005e02:	963e                	add	a2,a2,a5
    80005e04:	577d                	li	a4,-1
    80005e06:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005e0a:	0592                	slli	a1,a1,0x4
    80005e0c:	98ae                	add	a7,a7,a1
    80005e0e:	03068713          	addi	a4,a3,48
    80005e12:	973e                	add	a4,a4,a5
    80005e14:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005e18:	6398                	ld	a4,0(a5)
    80005e1a:	972e                	add	a4,a4,a1
    80005e1c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005e20:	4689                	li	a3,2
    80005e22:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005e26:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005e2a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005e2e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005e32:	6794                	ld	a3,8(a5)
    80005e34:	0026d703          	lhu	a4,2(a3)
    80005e38:	8b1d                	andi	a4,a4,7
    80005e3a:	0706                	slli	a4,a4,0x1
    80005e3c:	96ba                	add	a3,a3,a4
    80005e3e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005e42:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005e46:	6798                	ld	a4,8(a5)
    80005e48:	00275783          	lhu	a5,2(a4)
    80005e4c:	2785                	addiw	a5,a5,1
    80005e4e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005e52:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005e56:	100017b7          	lui	a5,0x10001
    80005e5a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005e5e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005e62:	0001f917          	auipc	s2,0x1f
    80005e66:	94690913          	addi	s2,s2,-1722 # 800247a8 <disk+0x128>
  while(b->disk == 1) {
    80005e6a:	4485                	li	s1,1
    80005e6c:	01079a63          	bne	a5,a6,80005e80 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005e70:	85ca                	mv	a1,s2
    80005e72:	8552                	mv	a0,s4
    80005e74:	898fc0ef          	jal	80001f0c <sleep>
  while(b->disk == 1) {
    80005e78:	004a2783          	lw	a5,4(s4)
    80005e7c:	fe978ae3          	beq	a5,s1,80005e70 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005e80:	f9042903          	lw	s2,-112(s0)
    80005e84:	00290713          	addi	a4,s2,2
    80005e88:	0712                	slli	a4,a4,0x4
    80005e8a:	0001e797          	auipc	a5,0x1e
    80005e8e:	7f678793          	addi	a5,a5,2038 # 80024680 <disk>
    80005e92:	97ba                	add	a5,a5,a4
    80005e94:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005e98:	0001e997          	auipc	s3,0x1e
    80005e9c:	7e898993          	addi	s3,s3,2024 # 80024680 <disk>
    80005ea0:	00491713          	slli	a4,s2,0x4
    80005ea4:	0009b783          	ld	a5,0(s3)
    80005ea8:	97ba                	add	a5,a5,a4
    80005eaa:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005eae:	854a                	mv	a0,s2
    80005eb0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005eb4:	bafff0ef          	jal	80005a62 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005eb8:	8885                	andi	s1,s1,1
    80005eba:	f0fd                	bnez	s1,80005ea0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005ebc:	0001f517          	auipc	a0,0x1f
    80005ec0:	8ec50513          	addi	a0,a0,-1812 # 800247a8 <disk+0x128>
    80005ec4:	da3fa0ef          	jal	80000c66 <release>
}
    80005ec8:	70a6                	ld	ra,104(sp)
    80005eca:	7406                	ld	s0,96(sp)
    80005ecc:	64e6                	ld	s1,88(sp)
    80005ece:	6946                	ld	s2,80(sp)
    80005ed0:	69a6                	ld	s3,72(sp)
    80005ed2:	6a06                	ld	s4,64(sp)
    80005ed4:	7ae2                	ld	s5,56(sp)
    80005ed6:	7b42                	ld	s6,48(sp)
    80005ed8:	7ba2                	ld	s7,40(sp)
    80005eda:	7c02                	ld	s8,32(sp)
    80005edc:	6ce2                	ld	s9,24(sp)
    80005ede:	6165                	addi	sp,sp,112
    80005ee0:	8082                	ret

0000000080005ee2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005ee2:	1101                	addi	sp,sp,-32
    80005ee4:	ec06                	sd	ra,24(sp)
    80005ee6:	e822                	sd	s0,16(sp)
    80005ee8:	e426                	sd	s1,8(sp)
    80005eea:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005eec:	0001e497          	auipc	s1,0x1e
    80005ef0:	79448493          	addi	s1,s1,1940 # 80024680 <disk>
    80005ef4:	0001f517          	auipc	a0,0x1f
    80005ef8:	8b450513          	addi	a0,a0,-1868 # 800247a8 <disk+0x128>
    80005efc:	cd3fa0ef          	jal	80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005f00:	100017b7          	lui	a5,0x10001
    80005f04:	53b8                	lw	a4,96(a5)
    80005f06:	8b0d                	andi	a4,a4,3
    80005f08:	100017b7          	lui	a5,0x10001
    80005f0c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005f0e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005f12:	689c                	ld	a5,16(s1)
    80005f14:	0204d703          	lhu	a4,32(s1)
    80005f18:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005f1c:	04f70663          	beq	a4,a5,80005f68 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005f20:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005f24:	6898                	ld	a4,16(s1)
    80005f26:	0204d783          	lhu	a5,32(s1)
    80005f2a:	8b9d                	andi	a5,a5,7
    80005f2c:	078e                	slli	a5,a5,0x3
    80005f2e:	97ba                	add	a5,a5,a4
    80005f30:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005f32:	00278713          	addi	a4,a5,2
    80005f36:	0712                	slli	a4,a4,0x4
    80005f38:	9726                	add	a4,a4,s1
    80005f3a:	01074703          	lbu	a4,16(a4)
    80005f3e:	e321                	bnez	a4,80005f7e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005f40:	0789                	addi	a5,a5,2
    80005f42:	0792                	slli	a5,a5,0x4
    80005f44:	97a6                	add	a5,a5,s1
    80005f46:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005f48:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005f4c:	80cfc0ef          	jal	80001f58 <wakeup>

    disk.used_idx += 1;
    80005f50:	0204d783          	lhu	a5,32(s1)
    80005f54:	2785                	addiw	a5,a5,1
    80005f56:	17c2                	slli	a5,a5,0x30
    80005f58:	93c1                	srli	a5,a5,0x30
    80005f5a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005f5e:	6898                	ld	a4,16(s1)
    80005f60:	00275703          	lhu	a4,2(a4)
    80005f64:	faf71ee3          	bne	a4,a5,80005f20 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005f68:	0001f517          	auipc	a0,0x1f
    80005f6c:	84050513          	addi	a0,a0,-1984 # 800247a8 <disk+0x128>
    80005f70:	cf7fa0ef          	jal	80000c66 <release>
}
    80005f74:	60e2                	ld	ra,24(sp)
    80005f76:	6442                	ld	s0,16(sp)
    80005f78:	64a2                	ld	s1,8(sp)
    80005f7a:	6105                	addi	sp,sp,32
    80005f7c:	8082                	ret
      panic("virtio_disk_intr status");
    80005f7e:	00001517          	auipc	a0,0x1
    80005f82:	79a50513          	addi	a0,a0,1946 # 80007718 <etext+0x718>
    80005f86:	85bfa0ef          	jal	800007e0 <panic>
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
