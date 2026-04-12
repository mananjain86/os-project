
user/_demo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <printint>:
#include "kernel/stat.h"
#include "user/user.h"

static void
printint(int n)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  char buf[16];
  int i = 15;
  buf[i] = '\0';
   8:	fe0407a3          	sb	zero,-17(s0)
  if(n == 0){ buf[--i] = '0'; }
   c:	e519                	bnez	a0,1a <printint+0x1a>
   e:	03000793          	li	a5,48
  12:	fef40723          	sb	a5,-18(s0)
  16:	45b9                	li	a1,14
  18:	a0a1                	j	60 <printint+0x60>
  while(n > 0){ buf[--i] = '0' + (n % 10); n /= 10; }
  1a:	04a05f63          	blez	a0,78 <printint+0x78>
  1e:	fee40693          	addi	a3,s0,-18
  22:	66666637          	lui	a2,0x66666
  26:	66760613          	addi	a2,a2,1639 # 66666667 <base+0x66665657>
  2a:	4825                	li	a6,9
  2c:	02c50733          	mul	a4,a0,a2
  30:	9709                	srai	a4,a4,0x22
  32:	41f5579b          	sraiw	a5,a0,0x1f
  36:	9f1d                	subw	a4,a4,a5
  38:	0027179b          	slliw	a5,a4,0x2
  3c:	9fb9                	addw	a5,a5,a4
  3e:	0017979b          	slliw	a5,a5,0x1
  42:	40f507bb          	subw	a5,a0,a5
  46:	0307879b          	addiw	a5,a5,48
  4a:	00f68023          	sb	a5,0(a3)
  4e:	87aa                	mv	a5,a0
  50:	853a                	mv	a0,a4
  52:	85b6                	mv	a1,a3
  54:	16fd                	addi	a3,a3,-1
  56:	fcf84be3          	blt	a6,a5,2c <printint+0x2c>
  5a:	fe040793          	addi	a5,s0,-32
  5e:	9d9d                	subw	a1,a1,a5
  write(1, buf+i, 15-i);
  60:	463d                	li	a2,15
  62:	9e0d                	subw	a2,a2,a1
  64:	fe040793          	addi	a5,s0,-32
  68:	95be                	add	a1,a1,a5
  6a:	4505                	li	a0,1
  6c:	460000ef          	jal	4cc <write>
}
  70:	60e2                	ld	ra,24(sp)
  72:	6442                	ld	s0,16(sp)
  74:	6105                	addi	sp,sp,32
  76:	8082                	ret
  while(n > 0){ buf[--i] = '0' + (n % 10); n /= 10; }
  78:	45bd                	li	a1,15
  7a:	b7dd                	j	60 <printint+0x60>

000000000000007c <printstr>:

static void
printstr(const char *s)
{
  7c:	1101                	addi	sp,sp,-32
  7e:	ec06                	sd	ra,24(sp)
  80:	e822                	sd	s0,16(sp)
  82:	e426                	sd	s1,8(sp)
  84:	1000                	addi	s0,sp,32
  86:	84aa                	mv	s1,a0
  write(1, s, strlen(s));
  88:	1ce000ef          	jal	256 <strlen>
  8c:	862a                	mv	a2,a0
  8e:	85a6                	mv	a1,s1
  90:	4505                	li	a0,1
  92:	43a000ef          	jal	4cc <write>
}
  96:	60e2                	ld	ra,24(sp)
  98:	6442                	ld	s0,16(sp)
  9a:	64a2                	ld	s1,8(sp)
  9c:	6105                	addi	sp,sp,32
  9e:	8082                	ret

00000000000000a0 <main>:

int
main(void)
{
  a0:	1101                	addi	sp,sp,-32
  a2:	ec06                	sd	ra,24(sp)
  a4:	e822                	sd	s0,16(sp)
  a6:	1000                	addi	s0,sp,32
  printstr("\n");
  a8:	00001517          	auipc	a0,0x1
  ac:	a0850513          	addi	a0,a0,-1528 # ab0 <malloc+0xf6>
  b0:	fcdff0ef          	jal	7c <printstr>
  printstr("========================================\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	a0450513          	addi	a0,a0,-1532 # ab8 <malloc+0xfe>
  bc:	fc1ff0ef          	jal	7c <printstr>
  printstr("  Process Creation System Calls Demo\n");
  c0:	00001517          	auipc	a0,0x1
  c4:	a2850513          	addi	a0,a0,-1496 # ae8 <malloc+0x12e>
  c8:	fb5ff0ef          	jal	7c <printstr>
  printstr("  getprocinfo + setpriority (xv6-riscv)\n");
  cc:	00001517          	auipc	a0,0x1
  d0:	a4450513          	addi	a0,a0,-1468 # b10 <malloc+0x156>
  d4:	fa9ff0ef          	jal	7c <printstr>
  printstr("========================================\n\n");
  d8:	00001517          	auipc	a0,0x1
  dc:	a6850513          	addi	a0,a0,-1432 # b40 <malloc+0x186>
  e0:	f9dff0ef          	jal	7c <printstr>

  // ── TEST 1: getprocinfo ──
  printstr("--- Test 1: getprocinfo ---\n");
  e4:	00001517          	auipc	a0,0x1
  e8:	a8c50513          	addi	a0,a0,-1396 # b70 <malloc+0x1b6>
  ec:	f91ff0ef          	jal	7c <printstr>
  int my_pid = 0, my_prio = 0;
  f0:	fe042623          	sw	zero,-20(s0)
  f4:	fe042423          	sw	zero,-24(s0)

  if(getprocinfo(&my_pid, &my_prio) == 0){
  f8:	fe840593          	addi	a1,s0,-24
  fc:	fec40513          	addi	a0,s0,-20
 100:	44c000ef          	jal	54c <getprocinfo>
 104:	0c051463          	bnez	a0,1cc <main+0x12c>
    printstr("  PID      = ");
 108:	00001517          	auipc	a0,0x1
 10c:	a8850513          	addi	a0,a0,-1400 # b90 <malloc+0x1d6>
 110:	f6dff0ef          	jal	7c <printstr>
    printint(my_pid);
 114:	fec42503          	lw	a0,-20(s0)
 118:	ee9ff0ef          	jal	0 <printint>
    printstr("\n");
 11c:	00001517          	auipc	a0,0x1
 120:	99450513          	addi	a0,a0,-1644 # ab0 <malloc+0xf6>
 124:	f59ff0ef          	jal	7c <printstr>
    printstr("  Priority = ");
 128:	00001517          	auipc	a0,0x1
 12c:	a7850513          	addi	a0,a0,-1416 # ba0 <malloc+0x1e6>
 130:	f4dff0ef          	jal	7c <printstr>
    printint(my_prio);
 134:	fe842503          	lw	a0,-24(s0)
 138:	ec9ff0ef          	jal	0 <printint>
    printstr("  (default is 0)\n");
 13c:	00001517          	auipc	a0,0x1
 140:	a7450513          	addi	a0,a0,-1420 # bb0 <malloc+0x1f6>
 144:	f39ff0ef          	jal	7c <printstr>
  } else {
    printstr("  ERROR: getprocinfo failed\n");
  }

  // ── TEST 2: setpriority ──
  printstr("\n--- Test 2: setpriority ---\n");
 148:	00001517          	auipc	a0,0x1
 14c:	aa050513          	addi	a0,a0,-1376 # be8 <malloc+0x22e>
 150:	f2dff0ef          	jal	7c <printstr>

  if(setpriority(15) == 0){
 154:	453d                	li	a0,15
 156:	3fe000ef          	jal	554 <setpriority>
 15a:	e141                	bnez	a0,1da <main+0x13a>
    getprocinfo(&my_pid, &my_prio);
 15c:	fe840593          	addi	a1,s0,-24
 160:	fec40513          	addi	a0,s0,-20
 164:	3e8000ef          	jal	54c <getprocinfo>
    printstr("  Set priority to 15\n");
 168:	00001517          	auipc	a0,0x1
 16c:	aa050513          	addi	a0,a0,-1376 # c08 <malloc+0x24e>
 170:	f0dff0ef          	jal	7c <printstr>
    printstr("  Verified priority = ");
 174:	00001517          	auipc	a0,0x1
 178:	aac50513          	addi	a0,a0,-1364 # c20 <malloc+0x266>
 17c:	f01ff0ef          	jal	7c <printstr>
    printint(my_prio);
 180:	fe842503          	lw	a0,-24(s0)
 184:	e7dff0ef          	jal	0 <printint>
    printstr("  (expected 15)\n");
 188:	00001517          	auipc	a0,0x1
 18c:	ab050513          	addi	a0,a0,-1360 # c38 <malloc+0x27e>
 190:	eedff0ef          	jal	7c <printstr>
  } else {
    printstr("  ERROR: setpriority failed\n");
  }

  if(setpriority(99) == -1)
 194:	06300513          	li	a0,99
 198:	3bc000ef          	jal	554 <setpriority>
 19c:	57fd                	li	a5,-1
 19e:	04f50563          	beq	a0,a5,1e8 <main+0x148>
    printstr("  setpriority(99) correctly rejected\n");

  printstr("\n========================================\n");
 1a2:	00001517          	auipc	a0,0x1
 1a6:	af650513          	addi	a0,a0,-1290 # c98 <malloc+0x2de>
 1aa:	ed3ff0ef          	jal	7c <printstr>
  printstr("  Process Creation calls working!\n");
 1ae:	00001517          	auipc	a0,0x1
 1b2:	b1a50513          	addi	a0,a0,-1254 # cc8 <malloc+0x30e>
 1b6:	ec7ff0ef          	jal	7c <printstr>
  printstr("========================================\n\n");
 1ba:	00001517          	auipc	a0,0x1
 1be:	98650513          	addi	a0,a0,-1658 # b40 <malloc+0x186>
 1c2:	ebbff0ef          	jal	7c <printstr>

  exit(0);
 1c6:	4501                	li	a0,0
 1c8:	2e4000ef          	jal	4ac <exit>
    printstr("  ERROR: getprocinfo failed\n");
 1cc:	00001517          	auipc	a0,0x1
 1d0:	9fc50513          	addi	a0,a0,-1540 # bc8 <malloc+0x20e>
 1d4:	ea9ff0ef          	jal	7c <printstr>
 1d8:	bf85                	j	148 <main+0xa8>
    printstr("  ERROR: setpriority failed\n");
 1da:	00001517          	auipc	a0,0x1
 1de:	a7650513          	addi	a0,a0,-1418 # c50 <malloc+0x296>
 1e2:	e9bff0ef          	jal	7c <printstr>
 1e6:	b77d                	j	194 <main+0xf4>
    printstr("  setpriority(99) correctly rejected\n");
 1e8:	00001517          	auipc	a0,0x1
 1ec:	a8850513          	addi	a0,a0,-1400 # c70 <malloc+0x2b6>
 1f0:	e8dff0ef          	jal	7c <printstr>
 1f4:	b77d                	j	1a2 <main+0x102>

00000000000001f6 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1f6:	1141                	addi	sp,sp,-16
 1f8:	e406                	sd	ra,8(sp)
 1fa:	e022                	sd	s0,0(sp)
 1fc:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1fe:	ea3ff0ef          	jal	a0 <main>
  exit(r);
 202:	2aa000ef          	jal	4ac <exit>

0000000000000206 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 206:	1141                	addi	sp,sp,-16
 208:	e406                	sd	ra,8(sp)
 20a:	e022                	sd	s0,0(sp)
 20c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 20e:	87aa                	mv	a5,a0
 210:	0585                	addi	a1,a1,1
 212:	0785                	addi	a5,a5,1
 214:	fff5c703          	lbu	a4,-1(a1)
 218:	fee78fa3          	sb	a4,-1(a5)
 21c:	fb75                	bnez	a4,210 <strcpy+0xa>
    ;
  return os;
}
 21e:	60a2                	ld	ra,8(sp)
 220:	6402                	ld	s0,0(sp)
 222:	0141                	addi	sp,sp,16
 224:	8082                	ret

0000000000000226 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 226:	1141                	addi	sp,sp,-16
 228:	e406                	sd	ra,8(sp)
 22a:	e022                	sd	s0,0(sp)
 22c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 22e:	00054783          	lbu	a5,0(a0)
 232:	cb91                	beqz	a5,246 <strcmp+0x20>
 234:	0005c703          	lbu	a4,0(a1)
 238:	00f71763          	bne	a4,a5,246 <strcmp+0x20>
    p++, q++;
 23c:	0505                	addi	a0,a0,1
 23e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 240:	00054783          	lbu	a5,0(a0)
 244:	fbe5                	bnez	a5,234 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 246:	0005c503          	lbu	a0,0(a1)
}
 24a:	40a7853b          	subw	a0,a5,a0
 24e:	60a2                	ld	ra,8(sp)
 250:	6402                	ld	s0,0(sp)
 252:	0141                	addi	sp,sp,16
 254:	8082                	ret

0000000000000256 <strlen>:

uint
strlen(const char *s)
{
 256:	1141                	addi	sp,sp,-16
 258:	e406                	sd	ra,8(sp)
 25a:	e022                	sd	s0,0(sp)
 25c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 25e:	00054783          	lbu	a5,0(a0)
 262:	cf91                	beqz	a5,27e <strlen+0x28>
 264:	00150793          	addi	a5,a0,1
 268:	86be                	mv	a3,a5
 26a:	0785                	addi	a5,a5,1
 26c:	fff7c703          	lbu	a4,-1(a5)
 270:	ff65                	bnez	a4,268 <strlen+0x12>
 272:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 276:	60a2                	ld	ra,8(sp)
 278:	6402                	ld	s0,0(sp)
 27a:	0141                	addi	sp,sp,16
 27c:	8082                	ret
  for(n = 0; s[n]; n++)
 27e:	4501                	li	a0,0
 280:	bfdd                	j	276 <strlen+0x20>

0000000000000282 <memset>:

void*
memset(void *dst, int c, uint n)
{
 282:	1141                	addi	sp,sp,-16
 284:	e406                	sd	ra,8(sp)
 286:	e022                	sd	s0,0(sp)
 288:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 28a:	ca19                	beqz	a2,2a0 <memset+0x1e>
 28c:	87aa                	mv	a5,a0
 28e:	1602                	slli	a2,a2,0x20
 290:	9201                	srli	a2,a2,0x20
 292:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 296:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 29a:	0785                	addi	a5,a5,1
 29c:	fee79de3          	bne	a5,a4,296 <memset+0x14>
  }
  return dst;
}
 2a0:	60a2                	ld	ra,8(sp)
 2a2:	6402                	ld	s0,0(sp)
 2a4:	0141                	addi	sp,sp,16
 2a6:	8082                	ret

00000000000002a8 <strchr>:

char*
strchr(const char *s, char c)
{
 2a8:	1141                	addi	sp,sp,-16
 2aa:	e406                	sd	ra,8(sp)
 2ac:	e022                	sd	s0,0(sp)
 2ae:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2b0:	00054783          	lbu	a5,0(a0)
 2b4:	cf81                	beqz	a5,2cc <strchr+0x24>
    if(*s == c)
 2b6:	00f58763          	beq	a1,a5,2c4 <strchr+0x1c>
  for(; *s; s++)
 2ba:	0505                	addi	a0,a0,1
 2bc:	00054783          	lbu	a5,0(a0)
 2c0:	fbfd                	bnez	a5,2b6 <strchr+0xe>
      return (char*)s;
  return 0;
 2c2:	4501                	li	a0,0
}
 2c4:	60a2                	ld	ra,8(sp)
 2c6:	6402                	ld	s0,0(sp)
 2c8:	0141                	addi	sp,sp,16
 2ca:	8082                	ret
  return 0;
 2cc:	4501                	li	a0,0
 2ce:	bfdd                	j	2c4 <strchr+0x1c>

00000000000002d0 <gets>:

char*
gets(char *buf, int max)
{
 2d0:	711d                	addi	sp,sp,-96
 2d2:	ec86                	sd	ra,88(sp)
 2d4:	e8a2                	sd	s0,80(sp)
 2d6:	e4a6                	sd	s1,72(sp)
 2d8:	e0ca                	sd	s2,64(sp)
 2da:	fc4e                	sd	s3,56(sp)
 2dc:	f852                	sd	s4,48(sp)
 2de:	f456                	sd	s5,40(sp)
 2e0:	f05a                	sd	s6,32(sp)
 2e2:	ec5e                	sd	s7,24(sp)
 2e4:	e862                	sd	s8,16(sp)
 2e6:	1080                	addi	s0,sp,96
 2e8:	8baa                	mv	s7,a0
 2ea:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ec:	892a                	mv	s2,a0
 2ee:	4481                	li	s1,0
    cc = read(0, &c, 1);
 2f0:	faf40b13          	addi	s6,s0,-81
 2f4:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 2f6:	8c26                	mv	s8,s1
 2f8:	0014899b          	addiw	s3,s1,1
 2fc:	84ce                	mv	s1,s3
 2fe:	0349d463          	bge	s3,s4,326 <gets+0x56>
    cc = read(0, &c, 1);
 302:	8656                	mv	a2,s5
 304:	85da                	mv	a1,s6
 306:	4501                	li	a0,0
 308:	1bc000ef          	jal	4c4 <read>
    if(cc < 1)
 30c:	00a05d63          	blez	a0,326 <gets+0x56>
      break;
    buf[i++] = c;
 310:	faf44783          	lbu	a5,-81(s0)
 314:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 318:	0905                	addi	s2,s2,1
 31a:	ff678713          	addi	a4,a5,-10
 31e:	c319                	beqz	a4,324 <gets+0x54>
 320:	17cd                	addi	a5,a5,-13
 322:	fbf1                	bnez	a5,2f6 <gets+0x26>
    buf[i++] = c;
 324:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 326:	9c5e                	add	s8,s8,s7
 328:	000c0023          	sb	zero,0(s8)
  return buf;
}
 32c:	855e                	mv	a0,s7
 32e:	60e6                	ld	ra,88(sp)
 330:	6446                	ld	s0,80(sp)
 332:	64a6                	ld	s1,72(sp)
 334:	6906                	ld	s2,64(sp)
 336:	79e2                	ld	s3,56(sp)
 338:	7a42                	ld	s4,48(sp)
 33a:	7aa2                	ld	s5,40(sp)
 33c:	7b02                	ld	s6,32(sp)
 33e:	6be2                	ld	s7,24(sp)
 340:	6c42                	ld	s8,16(sp)
 342:	6125                	addi	sp,sp,96
 344:	8082                	ret

0000000000000346 <stat>:

int
stat(const char *n, struct stat *st)
{
 346:	1101                	addi	sp,sp,-32
 348:	ec06                	sd	ra,24(sp)
 34a:	e822                	sd	s0,16(sp)
 34c:	e04a                	sd	s2,0(sp)
 34e:	1000                	addi	s0,sp,32
 350:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 352:	4581                	li	a1,0
 354:	198000ef          	jal	4ec <open>
  if(fd < 0)
 358:	02054263          	bltz	a0,37c <stat+0x36>
 35c:	e426                	sd	s1,8(sp)
 35e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 360:	85ca                	mv	a1,s2
 362:	1a2000ef          	jal	504 <fstat>
 366:	892a                	mv	s2,a0
  close(fd);
 368:	8526                	mv	a0,s1
 36a:	16a000ef          	jal	4d4 <close>
  return r;
 36e:	64a2                	ld	s1,8(sp)
}
 370:	854a                	mv	a0,s2
 372:	60e2                	ld	ra,24(sp)
 374:	6442                	ld	s0,16(sp)
 376:	6902                	ld	s2,0(sp)
 378:	6105                	addi	sp,sp,32
 37a:	8082                	ret
    return -1;
 37c:	57fd                	li	a5,-1
 37e:	893e                	mv	s2,a5
 380:	bfc5                	j	370 <stat+0x2a>

0000000000000382 <atoi>:

int
atoi(const char *s)
{
 382:	1141                	addi	sp,sp,-16
 384:	e406                	sd	ra,8(sp)
 386:	e022                	sd	s0,0(sp)
 388:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 38a:	00054683          	lbu	a3,0(a0)
 38e:	fd06879b          	addiw	a5,a3,-48
 392:	0ff7f793          	zext.b	a5,a5
 396:	4625                	li	a2,9
 398:	02f66963          	bltu	a2,a5,3ca <atoi+0x48>
 39c:	872a                	mv	a4,a0
  n = 0;
 39e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3a0:	0705                	addi	a4,a4,1
 3a2:	0025179b          	slliw	a5,a0,0x2
 3a6:	9fa9                	addw	a5,a5,a0
 3a8:	0017979b          	slliw	a5,a5,0x1
 3ac:	9fb5                	addw	a5,a5,a3
 3ae:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3b2:	00074683          	lbu	a3,0(a4)
 3b6:	fd06879b          	addiw	a5,a3,-48
 3ba:	0ff7f793          	zext.b	a5,a5
 3be:	fef671e3          	bgeu	a2,a5,3a0 <atoi+0x1e>
  return n;
}
 3c2:	60a2                	ld	ra,8(sp)
 3c4:	6402                	ld	s0,0(sp)
 3c6:	0141                	addi	sp,sp,16
 3c8:	8082                	ret
  n = 0;
 3ca:	4501                	li	a0,0
 3cc:	bfdd                	j	3c2 <atoi+0x40>

00000000000003ce <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3ce:	1141                	addi	sp,sp,-16
 3d0:	e406                	sd	ra,8(sp)
 3d2:	e022                	sd	s0,0(sp)
 3d4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3d6:	02b57563          	bgeu	a0,a1,400 <memmove+0x32>
    while(n-- > 0)
 3da:	00c05f63          	blez	a2,3f8 <memmove+0x2a>
 3de:	1602                	slli	a2,a2,0x20
 3e0:	9201                	srli	a2,a2,0x20
 3e2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3e6:	872a                	mv	a4,a0
      *dst++ = *src++;
 3e8:	0585                	addi	a1,a1,1
 3ea:	0705                	addi	a4,a4,1
 3ec:	fff5c683          	lbu	a3,-1(a1)
 3f0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3f4:	fee79ae3          	bne	a5,a4,3e8 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3f8:	60a2                	ld	ra,8(sp)
 3fa:	6402                	ld	s0,0(sp)
 3fc:	0141                	addi	sp,sp,16
 3fe:	8082                	ret
    while(n-- > 0)
 400:	fec05ce3          	blez	a2,3f8 <memmove+0x2a>
    dst += n;
 404:	00c50733          	add	a4,a0,a2
    src += n;
 408:	95b2                	add	a1,a1,a2
 40a:	fff6079b          	addiw	a5,a2,-1
 40e:	1782                	slli	a5,a5,0x20
 410:	9381                	srli	a5,a5,0x20
 412:	fff7c793          	not	a5,a5
 416:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 418:	15fd                	addi	a1,a1,-1
 41a:	177d                	addi	a4,a4,-1
 41c:	0005c683          	lbu	a3,0(a1)
 420:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 424:	fef71ae3          	bne	a4,a5,418 <memmove+0x4a>
 428:	bfc1                	j	3f8 <memmove+0x2a>

000000000000042a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 42a:	1141                	addi	sp,sp,-16
 42c:	e406                	sd	ra,8(sp)
 42e:	e022                	sd	s0,0(sp)
 430:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 432:	c61d                	beqz	a2,460 <memcmp+0x36>
 434:	1602                	slli	a2,a2,0x20
 436:	9201                	srli	a2,a2,0x20
 438:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 43c:	00054783          	lbu	a5,0(a0)
 440:	0005c703          	lbu	a4,0(a1)
 444:	00e79863          	bne	a5,a4,454 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 448:	0505                	addi	a0,a0,1
    p2++;
 44a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 44c:	fed518e3          	bne	a0,a3,43c <memcmp+0x12>
  }
  return 0;
 450:	4501                	li	a0,0
 452:	a019                	j	458 <memcmp+0x2e>
      return *p1 - *p2;
 454:	40e7853b          	subw	a0,a5,a4
}
 458:	60a2                	ld	ra,8(sp)
 45a:	6402                	ld	s0,0(sp)
 45c:	0141                	addi	sp,sp,16
 45e:	8082                	ret
  return 0;
 460:	4501                	li	a0,0
 462:	bfdd                	j	458 <memcmp+0x2e>

0000000000000464 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 464:	1141                	addi	sp,sp,-16
 466:	e406                	sd	ra,8(sp)
 468:	e022                	sd	s0,0(sp)
 46a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 46c:	f63ff0ef          	jal	3ce <memmove>
}
 470:	60a2                	ld	ra,8(sp)
 472:	6402                	ld	s0,0(sp)
 474:	0141                	addi	sp,sp,16
 476:	8082                	ret

0000000000000478 <sbrk>:

char *
sbrk(int n) {
 478:	1141                	addi	sp,sp,-16
 47a:	e406                	sd	ra,8(sp)
 47c:	e022                	sd	s0,0(sp)
 47e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 480:	4585                	li	a1,1
 482:	0b2000ef          	jal	534 <sys_sbrk>
}
 486:	60a2                	ld	ra,8(sp)
 488:	6402                	ld	s0,0(sp)
 48a:	0141                	addi	sp,sp,16
 48c:	8082                	ret

000000000000048e <sbrklazy>:

char *
sbrklazy(int n) {
 48e:	1141                	addi	sp,sp,-16
 490:	e406                	sd	ra,8(sp)
 492:	e022                	sd	s0,0(sp)
 494:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 496:	4589                	li	a1,2
 498:	09c000ef          	jal	534 <sys_sbrk>
}
 49c:	60a2                	ld	ra,8(sp)
 49e:	6402                	ld	s0,0(sp)
 4a0:	0141                	addi	sp,sp,16
 4a2:	8082                	ret

00000000000004a4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4a4:	4885                	li	a7,1
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <exit>:
.global exit
exit:
 li a7, SYS_exit
 4ac:	4889                	li	a7,2
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4b4:	488d                	li	a7,3
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4bc:	4891                	li	a7,4
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <read>:
.global read
read:
 li a7, SYS_read
 4c4:	4895                	li	a7,5
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <write>:
.global write
write:
 li a7, SYS_write
 4cc:	48c1                	li	a7,16
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <close>:
.global close
close:
 li a7, SYS_close
 4d4:	48d5                	li	a7,21
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <kill>:
.global kill
kill:
 li a7, SYS_kill
 4dc:	4899                	li	a7,6
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4e4:	489d                	li	a7,7
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <open>:
.global open
open:
 li a7, SYS_open
 4ec:	48bd                	li	a7,15
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4f4:	48c5                	li	a7,17
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4fc:	48c9                	li	a7,18
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 504:	48a1                	li	a7,8
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <link>:
.global link
link:
 li a7, SYS_link
 50c:	48cd                	li	a7,19
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 514:	48d1                	li	a7,20
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 51c:	48a5                	li	a7,9
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <dup>:
.global dup
dup:
 li a7, SYS_dup
 524:	48a9                	li	a7,10
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 52c:	48ad                	li	a7,11
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 534:	48b1                	li	a7,12
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <pause>:
.global pause
pause:
 li a7, SYS_pause
 53c:	48b5                	li	a7,13
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 544:	48b9                	li	a7,14
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 54c:	48d9                	li	a7,22
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 554:	48dd                	li	a7,23
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 55c:	1101                	addi	sp,sp,-32
 55e:	ec06                	sd	ra,24(sp)
 560:	e822                	sd	s0,16(sp)
 562:	1000                	addi	s0,sp,32
 564:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 568:	4605                	li	a2,1
 56a:	fef40593          	addi	a1,s0,-17
 56e:	f5fff0ef          	jal	4cc <write>
}
 572:	60e2                	ld	ra,24(sp)
 574:	6442                	ld	s0,16(sp)
 576:	6105                	addi	sp,sp,32
 578:	8082                	ret

000000000000057a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 57a:	715d                	addi	sp,sp,-80
 57c:	e486                	sd	ra,72(sp)
 57e:	e0a2                	sd	s0,64(sp)
 580:	f84a                	sd	s2,48(sp)
 582:	f44e                	sd	s3,40(sp)
 584:	0880                	addi	s0,sp,80
 586:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 588:	c6d1                	beqz	a3,614 <printint+0x9a>
 58a:	0805d563          	bgez	a1,614 <printint+0x9a>
    neg = 1;
    x = -xx;
 58e:	40b005b3          	neg	a1,a1
    neg = 1;
 592:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 594:	fb840993          	addi	s3,s0,-72
  neg = 0;
 598:	86ce                	mv	a3,s3
  i = 0;
 59a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 59c:	00000817          	auipc	a6,0x0
 5a0:	75c80813          	addi	a6,a6,1884 # cf8 <digits>
 5a4:	88ba                	mv	a7,a4
 5a6:	0017051b          	addiw	a0,a4,1
 5aa:	872a                	mv	a4,a0
 5ac:	02c5f7b3          	remu	a5,a1,a2
 5b0:	97c2                	add	a5,a5,a6
 5b2:	0007c783          	lbu	a5,0(a5)
 5b6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5ba:	87ae                	mv	a5,a1
 5bc:	02c5d5b3          	divu	a1,a1,a2
 5c0:	0685                	addi	a3,a3,1
 5c2:	fec7f1e3          	bgeu	a5,a2,5a4 <printint+0x2a>
  if(neg)
 5c6:	00030c63          	beqz	t1,5de <printint+0x64>
    buf[i++] = '-';
 5ca:	fd050793          	addi	a5,a0,-48
 5ce:	00878533          	add	a0,a5,s0
 5d2:	02d00793          	li	a5,45
 5d6:	fef50423          	sb	a5,-24(a0)
 5da:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 5de:	02e05563          	blez	a4,608 <printint+0x8e>
 5e2:	fc26                	sd	s1,56(sp)
 5e4:	377d                	addiw	a4,a4,-1
 5e6:	00e984b3          	add	s1,s3,a4
 5ea:	19fd                	addi	s3,s3,-1
 5ec:	99ba                	add	s3,s3,a4
 5ee:	1702                	slli	a4,a4,0x20
 5f0:	9301                	srli	a4,a4,0x20
 5f2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5f6:	0004c583          	lbu	a1,0(s1)
 5fa:	854a                	mv	a0,s2
 5fc:	f61ff0ef          	jal	55c <putc>
  while(--i >= 0)
 600:	14fd                	addi	s1,s1,-1
 602:	ff349ae3          	bne	s1,s3,5f6 <printint+0x7c>
 606:	74e2                	ld	s1,56(sp)
}
 608:	60a6                	ld	ra,72(sp)
 60a:	6406                	ld	s0,64(sp)
 60c:	7942                	ld	s2,48(sp)
 60e:	79a2                	ld	s3,40(sp)
 610:	6161                	addi	sp,sp,80
 612:	8082                	ret
  neg = 0;
 614:	4301                	li	t1,0
 616:	bfbd                	j	594 <printint+0x1a>

0000000000000618 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 618:	711d                	addi	sp,sp,-96
 61a:	ec86                	sd	ra,88(sp)
 61c:	e8a2                	sd	s0,80(sp)
 61e:	e4a6                	sd	s1,72(sp)
 620:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 622:	0005c483          	lbu	s1,0(a1)
 626:	22048363          	beqz	s1,84c <vprintf+0x234>
 62a:	e0ca                	sd	s2,64(sp)
 62c:	fc4e                	sd	s3,56(sp)
 62e:	f852                	sd	s4,48(sp)
 630:	f456                	sd	s5,40(sp)
 632:	f05a                	sd	s6,32(sp)
 634:	ec5e                	sd	s7,24(sp)
 636:	e862                	sd	s8,16(sp)
 638:	8b2a                	mv	s6,a0
 63a:	8a2e                	mv	s4,a1
 63c:	8bb2                	mv	s7,a2
  state = 0;
 63e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 640:	4901                	li	s2,0
 642:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 644:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 648:	06400c13          	li	s8,100
 64c:	a00d                	j	66e <vprintf+0x56>
        putc(fd, c0);
 64e:	85a6                	mv	a1,s1
 650:	855a                	mv	a0,s6
 652:	f0bff0ef          	jal	55c <putc>
 656:	a019                	j	65c <vprintf+0x44>
    } else if(state == '%'){
 658:	03598363          	beq	s3,s5,67e <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 65c:	0019079b          	addiw	a5,s2,1
 660:	893e                	mv	s2,a5
 662:	873e                	mv	a4,a5
 664:	97d2                	add	a5,a5,s4
 666:	0007c483          	lbu	s1,0(a5)
 66a:	1c048a63          	beqz	s1,83e <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 66e:	0004879b          	sext.w	a5,s1
    if(state == 0){
 672:	fe0993e3          	bnez	s3,658 <vprintf+0x40>
      if(c0 == '%'){
 676:	fd579ce3          	bne	a5,s5,64e <vprintf+0x36>
        state = '%';
 67a:	89be                	mv	s3,a5
 67c:	b7c5                	j	65c <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 67e:	00ea06b3          	add	a3,s4,a4
 682:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 686:	1c060863          	beqz	a2,856 <vprintf+0x23e>
      if(c0 == 'd'){
 68a:	03878763          	beq	a5,s8,6b8 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 68e:	f9478693          	addi	a3,a5,-108
 692:	0016b693          	seqz	a3,a3
 696:	f9c60593          	addi	a1,a2,-100
 69a:	e99d                	bnez	a1,6d0 <vprintf+0xb8>
 69c:	ca95                	beqz	a3,6d0 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 69e:	008b8493          	addi	s1,s7,8
 6a2:	4685                	li	a3,1
 6a4:	4629                	li	a2,10
 6a6:	000bb583          	ld	a1,0(s7)
 6aa:	855a                	mv	a0,s6
 6ac:	ecfff0ef          	jal	57a <printint>
        i += 1;
 6b0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6b2:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	b75d                	j	65c <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 6b8:	008b8493          	addi	s1,s7,8
 6bc:	4685                	li	a3,1
 6be:	4629                	li	a2,10
 6c0:	000ba583          	lw	a1,0(s7)
 6c4:	855a                	mv	a0,s6
 6c6:	eb5ff0ef          	jal	57a <printint>
 6ca:	8ba6                	mv	s7,s1
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	b779                	j	65c <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 6d0:	9752                	add	a4,a4,s4
 6d2:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6d6:	f9460713          	addi	a4,a2,-108
 6da:	00173713          	seqz	a4,a4
 6de:	8f75                	and	a4,a4,a3
 6e0:	f9c58513          	addi	a0,a1,-100
 6e4:	18051363          	bnez	a0,86a <vprintf+0x252>
 6e8:	18070163          	beqz	a4,86a <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ec:	008b8493          	addi	s1,s7,8
 6f0:	4685                	li	a3,1
 6f2:	4629                	li	a2,10
 6f4:	000bb583          	ld	a1,0(s7)
 6f8:	855a                	mv	a0,s6
 6fa:	e81ff0ef          	jal	57a <printint>
        i += 2;
 6fe:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 700:	8ba6                	mv	s7,s1
      state = 0;
 702:	4981                	li	s3,0
        i += 2;
 704:	bfa1                	j	65c <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 706:	008b8493          	addi	s1,s7,8
 70a:	4681                	li	a3,0
 70c:	4629                	li	a2,10
 70e:	000be583          	lwu	a1,0(s7)
 712:	855a                	mv	a0,s6
 714:	e67ff0ef          	jal	57a <printint>
 718:	8ba6                	mv	s7,s1
      state = 0;
 71a:	4981                	li	s3,0
 71c:	b781                	j	65c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 71e:	008b8493          	addi	s1,s7,8
 722:	4681                	li	a3,0
 724:	4629                	li	a2,10
 726:	000bb583          	ld	a1,0(s7)
 72a:	855a                	mv	a0,s6
 72c:	e4fff0ef          	jal	57a <printint>
        i += 1;
 730:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 732:	8ba6                	mv	s7,s1
      state = 0;
 734:	4981                	li	s3,0
 736:	b71d                	j	65c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 738:	008b8493          	addi	s1,s7,8
 73c:	4681                	li	a3,0
 73e:	4629                	li	a2,10
 740:	000bb583          	ld	a1,0(s7)
 744:	855a                	mv	a0,s6
 746:	e35ff0ef          	jal	57a <printint>
        i += 2;
 74a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 74c:	8ba6                	mv	s7,s1
      state = 0;
 74e:	4981                	li	s3,0
        i += 2;
 750:	b731                	j	65c <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 752:	008b8493          	addi	s1,s7,8
 756:	4681                	li	a3,0
 758:	4641                	li	a2,16
 75a:	000be583          	lwu	a1,0(s7)
 75e:	855a                	mv	a0,s6
 760:	e1bff0ef          	jal	57a <printint>
 764:	8ba6                	mv	s7,s1
      state = 0;
 766:	4981                	li	s3,0
 768:	bdd5                	j	65c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 76a:	008b8493          	addi	s1,s7,8
 76e:	4681                	li	a3,0
 770:	4641                	li	a2,16
 772:	000bb583          	ld	a1,0(s7)
 776:	855a                	mv	a0,s6
 778:	e03ff0ef          	jal	57a <printint>
        i += 1;
 77c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 77e:	8ba6                	mv	s7,s1
      state = 0;
 780:	4981                	li	s3,0
 782:	bde9                	j	65c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 784:	008b8493          	addi	s1,s7,8
 788:	4681                	li	a3,0
 78a:	4641                	li	a2,16
 78c:	000bb583          	ld	a1,0(s7)
 790:	855a                	mv	a0,s6
 792:	de9ff0ef          	jal	57a <printint>
        i += 2;
 796:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 798:	8ba6                	mv	s7,s1
      state = 0;
 79a:	4981                	li	s3,0
        i += 2;
 79c:	b5c1                	j	65c <vprintf+0x44>
 79e:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 7a0:	008b8793          	addi	a5,s7,8
 7a4:	8cbe                	mv	s9,a5
 7a6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7aa:	03000593          	li	a1,48
 7ae:	855a                	mv	a0,s6
 7b0:	dadff0ef          	jal	55c <putc>
  putc(fd, 'x');
 7b4:	07800593          	li	a1,120
 7b8:	855a                	mv	a0,s6
 7ba:	da3ff0ef          	jal	55c <putc>
 7be:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7c0:	00000b97          	auipc	s7,0x0
 7c4:	538b8b93          	addi	s7,s7,1336 # cf8 <digits>
 7c8:	03c9d793          	srli	a5,s3,0x3c
 7cc:	97de                	add	a5,a5,s7
 7ce:	0007c583          	lbu	a1,0(a5)
 7d2:	855a                	mv	a0,s6
 7d4:	d89ff0ef          	jal	55c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7d8:	0992                	slli	s3,s3,0x4
 7da:	34fd                	addiw	s1,s1,-1
 7dc:	f4f5                	bnez	s1,7c8 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 7de:	8be6                	mv	s7,s9
      state = 0;
 7e0:	4981                	li	s3,0
 7e2:	6ca2                	ld	s9,8(sp)
 7e4:	bda5                	j	65c <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 7e6:	008b8493          	addi	s1,s7,8
 7ea:	000bc583          	lbu	a1,0(s7)
 7ee:	855a                	mv	a0,s6
 7f0:	d6dff0ef          	jal	55c <putc>
 7f4:	8ba6                	mv	s7,s1
      state = 0;
 7f6:	4981                	li	s3,0
 7f8:	b595                	j	65c <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 7fa:	008b8993          	addi	s3,s7,8
 7fe:	000bb483          	ld	s1,0(s7)
 802:	cc91                	beqz	s1,81e <vprintf+0x206>
        for(; *s; s++)
 804:	0004c583          	lbu	a1,0(s1)
 808:	c985                	beqz	a1,838 <vprintf+0x220>
          putc(fd, *s);
 80a:	855a                	mv	a0,s6
 80c:	d51ff0ef          	jal	55c <putc>
        for(; *s; s++)
 810:	0485                	addi	s1,s1,1
 812:	0004c583          	lbu	a1,0(s1)
 816:	f9f5                	bnez	a1,80a <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 818:	8bce                	mv	s7,s3
      state = 0;
 81a:	4981                	li	s3,0
 81c:	b581                	j	65c <vprintf+0x44>
          s = "(null)";
 81e:	00000497          	auipc	s1,0x0
 822:	4d248493          	addi	s1,s1,1234 # cf0 <malloc+0x336>
        for(; *s; s++)
 826:	02800593          	li	a1,40
 82a:	b7c5                	j	80a <vprintf+0x1f2>
        putc(fd, '%');
 82c:	85be                	mv	a1,a5
 82e:	855a                	mv	a0,s6
 830:	d2dff0ef          	jal	55c <putc>
      state = 0;
 834:	4981                	li	s3,0
 836:	b51d                	j	65c <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 838:	8bce                	mv	s7,s3
      state = 0;
 83a:	4981                	li	s3,0
 83c:	b505                	j	65c <vprintf+0x44>
 83e:	6906                	ld	s2,64(sp)
 840:	79e2                	ld	s3,56(sp)
 842:	7a42                	ld	s4,48(sp)
 844:	7aa2                	ld	s5,40(sp)
 846:	7b02                	ld	s6,32(sp)
 848:	6be2                	ld	s7,24(sp)
 84a:	6c42                	ld	s8,16(sp)
    }
  }
}
 84c:	60e6                	ld	ra,88(sp)
 84e:	6446                	ld	s0,80(sp)
 850:	64a6                	ld	s1,72(sp)
 852:	6125                	addi	sp,sp,96
 854:	8082                	ret
      if(c0 == 'd'){
 856:	06400713          	li	a4,100
 85a:	e4e78fe3          	beq	a5,a4,6b8 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 85e:	f9478693          	addi	a3,a5,-108
 862:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 866:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 868:	4701                	li	a4,0
      } else if(c0 == 'u'){
 86a:	07500513          	li	a0,117
 86e:	e8a78ce3          	beq	a5,a0,706 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 872:	f8b60513          	addi	a0,a2,-117
 876:	e119                	bnez	a0,87c <vprintf+0x264>
 878:	ea0693e3          	bnez	a3,71e <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 87c:	f8b58513          	addi	a0,a1,-117
 880:	e119                	bnez	a0,886 <vprintf+0x26e>
 882:	ea071be3          	bnez	a4,738 <vprintf+0x120>
      } else if(c0 == 'x'){
 886:	07800513          	li	a0,120
 88a:	eca784e3          	beq	a5,a0,752 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 88e:	f8860613          	addi	a2,a2,-120
 892:	e219                	bnez	a2,898 <vprintf+0x280>
 894:	ec069be3          	bnez	a3,76a <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 898:	f8858593          	addi	a1,a1,-120
 89c:	e199                	bnez	a1,8a2 <vprintf+0x28a>
 89e:	ee0713e3          	bnez	a4,784 <vprintf+0x16c>
      } else if(c0 == 'p'){
 8a2:	07000713          	li	a4,112
 8a6:	eee78ce3          	beq	a5,a4,79e <vprintf+0x186>
      } else if(c0 == 'c'){
 8aa:	06300713          	li	a4,99
 8ae:	f2e78ce3          	beq	a5,a4,7e6 <vprintf+0x1ce>
      } else if(c0 == 's'){
 8b2:	07300713          	li	a4,115
 8b6:	f4e782e3          	beq	a5,a4,7fa <vprintf+0x1e2>
      } else if(c0 == '%'){
 8ba:	02500713          	li	a4,37
 8be:	f6e787e3          	beq	a5,a4,82c <vprintf+0x214>
        putc(fd, '%');
 8c2:	02500593          	li	a1,37
 8c6:	855a                	mv	a0,s6
 8c8:	c95ff0ef          	jal	55c <putc>
        putc(fd, c0);
 8cc:	85a6                	mv	a1,s1
 8ce:	855a                	mv	a0,s6
 8d0:	c8dff0ef          	jal	55c <putc>
      state = 0;
 8d4:	4981                	li	s3,0
 8d6:	b359                	j	65c <vprintf+0x44>

00000000000008d8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8d8:	715d                	addi	sp,sp,-80
 8da:	ec06                	sd	ra,24(sp)
 8dc:	e822                	sd	s0,16(sp)
 8de:	1000                	addi	s0,sp,32
 8e0:	e010                	sd	a2,0(s0)
 8e2:	e414                	sd	a3,8(s0)
 8e4:	e818                	sd	a4,16(s0)
 8e6:	ec1c                	sd	a5,24(s0)
 8e8:	03043023          	sd	a6,32(s0)
 8ec:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8f0:	8622                	mv	a2,s0
 8f2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8f6:	d23ff0ef          	jal	618 <vprintf>
}
 8fa:	60e2                	ld	ra,24(sp)
 8fc:	6442                	ld	s0,16(sp)
 8fe:	6161                	addi	sp,sp,80
 900:	8082                	ret

0000000000000902 <printf>:

void
printf(const char *fmt, ...)
{
 902:	711d                	addi	sp,sp,-96
 904:	ec06                	sd	ra,24(sp)
 906:	e822                	sd	s0,16(sp)
 908:	1000                	addi	s0,sp,32
 90a:	e40c                	sd	a1,8(s0)
 90c:	e810                	sd	a2,16(s0)
 90e:	ec14                	sd	a3,24(s0)
 910:	f018                	sd	a4,32(s0)
 912:	f41c                	sd	a5,40(s0)
 914:	03043823          	sd	a6,48(s0)
 918:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 91c:	00840613          	addi	a2,s0,8
 920:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 924:	85aa                	mv	a1,a0
 926:	4505                	li	a0,1
 928:	cf1ff0ef          	jal	618 <vprintf>
}
 92c:	60e2                	ld	ra,24(sp)
 92e:	6442                	ld	s0,16(sp)
 930:	6125                	addi	sp,sp,96
 932:	8082                	ret

0000000000000934 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 934:	1141                	addi	sp,sp,-16
 936:	e406                	sd	ra,8(sp)
 938:	e022                	sd	s0,0(sp)
 93a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 93c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 940:	00000797          	auipc	a5,0x0
 944:	6c07b783          	ld	a5,1728(a5) # 1000 <freep>
 948:	a039                	j	956 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 94a:	6398                	ld	a4,0(a5)
 94c:	00e7e463          	bltu	a5,a4,954 <free+0x20>
 950:	00e6ea63          	bltu	a3,a4,964 <free+0x30>
{
 954:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 956:	fed7fae3          	bgeu	a5,a3,94a <free+0x16>
 95a:	6398                	ld	a4,0(a5)
 95c:	00e6e463          	bltu	a3,a4,964 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 960:	fee7eae3          	bltu	a5,a4,954 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 964:	ff852583          	lw	a1,-8(a0)
 968:	6390                	ld	a2,0(a5)
 96a:	02059813          	slli	a6,a1,0x20
 96e:	01c85713          	srli	a4,a6,0x1c
 972:	9736                	add	a4,a4,a3
 974:	02e60563          	beq	a2,a4,99e <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 978:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 97c:	4790                	lw	a2,8(a5)
 97e:	02061593          	slli	a1,a2,0x20
 982:	01c5d713          	srli	a4,a1,0x1c
 986:	973e                	add	a4,a4,a5
 988:	02e68263          	beq	a3,a4,9ac <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 98c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 98e:	00000717          	auipc	a4,0x0
 992:	66f73923          	sd	a5,1650(a4) # 1000 <freep>
}
 996:	60a2                	ld	ra,8(sp)
 998:	6402                	ld	s0,0(sp)
 99a:	0141                	addi	sp,sp,16
 99c:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 99e:	4618                	lw	a4,8(a2)
 9a0:	9f2d                	addw	a4,a4,a1
 9a2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9a6:	6398                	ld	a4,0(a5)
 9a8:	6310                	ld	a2,0(a4)
 9aa:	b7f9                	j	978 <free+0x44>
    p->s.size += bp->s.size;
 9ac:	ff852703          	lw	a4,-8(a0)
 9b0:	9f31                	addw	a4,a4,a2
 9b2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9b4:	ff053683          	ld	a3,-16(a0)
 9b8:	bfd1                	j	98c <free+0x58>

00000000000009ba <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9ba:	7139                	addi	sp,sp,-64
 9bc:	fc06                	sd	ra,56(sp)
 9be:	f822                	sd	s0,48(sp)
 9c0:	f04a                	sd	s2,32(sp)
 9c2:	ec4e                	sd	s3,24(sp)
 9c4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9c6:	02051993          	slli	s3,a0,0x20
 9ca:	0209d993          	srli	s3,s3,0x20
 9ce:	09bd                	addi	s3,s3,15
 9d0:	0049d993          	srli	s3,s3,0x4
 9d4:	2985                	addiw	s3,s3,1
 9d6:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 9d8:	00000517          	auipc	a0,0x0
 9dc:	62853503          	ld	a0,1576(a0) # 1000 <freep>
 9e0:	c905                	beqz	a0,a10 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9e4:	4798                	lw	a4,8(a5)
 9e6:	09377663          	bgeu	a4,s3,a72 <malloc+0xb8>
 9ea:	f426                	sd	s1,40(sp)
 9ec:	e852                	sd	s4,16(sp)
 9ee:	e456                	sd	s5,8(sp)
 9f0:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9f2:	8a4e                	mv	s4,s3
 9f4:	6705                	lui	a4,0x1
 9f6:	00e9f363          	bgeu	s3,a4,9fc <malloc+0x42>
 9fa:	6a05                	lui	s4,0x1
 9fc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a00:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a04:	00000497          	auipc	s1,0x0
 a08:	5fc48493          	addi	s1,s1,1532 # 1000 <freep>
  if(p == SBRK_ERROR)
 a0c:	5afd                	li	s5,-1
 a0e:	a83d                	j	a4c <malloc+0x92>
 a10:	f426                	sd	s1,40(sp)
 a12:	e852                	sd	s4,16(sp)
 a14:	e456                	sd	s5,8(sp)
 a16:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a18:	00000797          	auipc	a5,0x0
 a1c:	5f878793          	addi	a5,a5,1528 # 1010 <base>
 a20:	00000717          	auipc	a4,0x0
 a24:	5ef73023          	sd	a5,1504(a4) # 1000 <freep>
 a28:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a2a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a2e:	b7d1                	j	9f2 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a30:	6398                	ld	a4,0(a5)
 a32:	e118                	sd	a4,0(a0)
 a34:	a899                	j	a8a <malloc+0xd0>
  hp->s.size = nu;
 a36:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a3a:	0541                	addi	a0,a0,16
 a3c:	ef9ff0ef          	jal	934 <free>
  return freep;
 a40:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 a42:	c125                	beqz	a0,aa2 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a44:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a46:	4798                	lw	a4,8(a5)
 a48:	03277163          	bgeu	a4,s2,a6a <malloc+0xb0>
    if(p == freep)
 a4c:	6098                	ld	a4,0(s1)
 a4e:	853e                	mv	a0,a5
 a50:	fef71ae3          	bne	a4,a5,a44 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 a54:	8552                	mv	a0,s4
 a56:	a23ff0ef          	jal	478 <sbrk>
  if(p == SBRK_ERROR)
 a5a:	fd551ee3          	bne	a0,s5,a36 <malloc+0x7c>
        return 0;
 a5e:	4501                	li	a0,0
 a60:	74a2                	ld	s1,40(sp)
 a62:	6a42                	ld	s4,16(sp)
 a64:	6aa2                	ld	s5,8(sp)
 a66:	6b02                	ld	s6,0(sp)
 a68:	a03d                	j	a96 <malloc+0xdc>
 a6a:	74a2                	ld	s1,40(sp)
 a6c:	6a42                	ld	s4,16(sp)
 a6e:	6aa2                	ld	s5,8(sp)
 a70:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a72:	fae90fe3          	beq	s2,a4,a30 <malloc+0x76>
        p->s.size -= nunits;
 a76:	4137073b          	subw	a4,a4,s3
 a7a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a7c:	02071693          	slli	a3,a4,0x20
 a80:	01c6d713          	srli	a4,a3,0x1c
 a84:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a86:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a8a:	00000717          	auipc	a4,0x0
 a8e:	56a73b23          	sd	a0,1398(a4) # 1000 <freep>
      return (void*)(p + 1);
 a92:	01078513          	addi	a0,a5,16
  }
}
 a96:	70e2                	ld	ra,56(sp)
 a98:	7442                	ld	s0,48(sp)
 a9a:	7902                	ld	s2,32(sp)
 a9c:	69e2                	ld	s3,24(sp)
 a9e:	6121                	addi	sp,sp,64
 aa0:	8082                	ret
 aa2:	74a2                	ld	s1,40(sp)
 aa4:	6a42                	ld	s4,16(sp)
 aa6:	6aa2                	ld	s5,8(sp)
 aa8:	6b02                	ld	s6,0(sp)
 aaa:	b7f5                	j	a96 <malloc+0xdc>
