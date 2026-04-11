
user/_msgbox_demo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	711d                	addi	sp,sp,-96
   2:	ec86                	sd	ra,88(sp)
   4:	e8a2                	sd	s0,80(sp)
   6:	1080                	addi	s0,sp,96
  char buf[64];

  printf("=== IPC Demo ===\n");
   8:	00001517          	auipc	a0,0x1
   c:	93850513          	addi	a0,a0,-1736 # 940 <malloc+0xfc>
  10:	780000ef          	jal	790 <printf>

  msgbox_create("box1");
  14:	00001517          	auipc	a0,0x1
  18:	94450513          	addi	a0,a0,-1724 # 958 <malloc+0x114>
  1c:	3c4000ef          	jal	3e0 <msgbox_create>

  int pid = fork();
  20:	318000ef          	jal	338 <fork>
  if(pid == 0){
  24:	e90d                	bnez	a0,56 <main+0x56>
  26:	e4a6                	sd	s1,72(sp)
    // Child: send a message to parent's mailbox
    pause(2); // let parent be ready to receive
  28:	4509                	li	a0,2
  2a:	3a6000ef          	jal	3d0 <pause>
    msgbox_send("box1", "hi from child!", 15);
  2e:	463d                	li	a2,15
  30:	00001597          	auipc	a1,0x1
  34:	93058593          	addi	a1,a1,-1744 # 960 <malloc+0x11c>
  38:	00001517          	auipc	a0,0x1
  3c:	92050513          	addi	a0,a0,-1760 # 958 <malloc+0x114>
  40:	3a8000ef          	jal	3e8 <msgbox_send>
    printf("[child]  sent message\n");
  44:	00001517          	auipc	a0,0x1
  48:	92c50513          	addi	a0,a0,-1748 # 970 <malloc+0x12c>
  4c:	744000ef          	jal	790 <printf>
    exit(0);
  50:	4501                	li	a0,0
  52:	2ee000ef          	jal	340 <exit>
  56:	e4a6                	sd	s1,72(sp)
  }

  // Parent: receive the message (blocks until child sends)
  int len = msgbox_recv(buf, sizeof(buf));
  58:	04000593          	li	a1,64
  5c:	fa040513          	addi	a0,s0,-96
  60:	390000ef          	jal	3f0 <msgbox_recv>
  64:	84aa                	mv	s1,a0
  // Small delay so child's print finishes first
  pause(3);
  66:	450d                	li	a0,3
  68:	368000ef          	jal	3d0 <pause>
  printf("[parent] got: \"%s\" (%d bytes)\n", buf, len);
  6c:	8626                	mv	a2,s1
  6e:	fa040593          	addi	a1,s0,-96
  72:	00001517          	auipc	a0,0x1
  76:	91650513          	addi	a0,a0,-1770 # 988 <malloc+0x144>
  7a:	716000ef          	jal	790 <printf>
  printf("[parent] pending: %d\n", msgbox_count());
  7e:	382000ef          	jal	400 <msgbox_count>
  82:	85aa                	mv	a1,a0
  84:	00001517          	auipc	a0,0x1
  88:	92450513          	addi	a0,a0,-1756 # 9a8 <malloc+0x164>
  8c:	704000ef          	jal	790 <printf>

  wait(0);
  90:	4501                	li	a0,0
  92:	2b6000ef          	jal	348 <wait>
  msgbox_destroy();
  96:	362000ef          	jal	3f8 <msgbox_destroy>
  printf("=== Done ===\n");
  9a:	00001517          	auipc	a0,0x1
  9e:	92650513          	addi	a0,a0,-1754 # 9c0 <malloc+0x17c>
  a2:	6ee000ef          	jal	790 <printf>
  exit(0);
  a6:	4501                	li	a0,0
  a8:	298000ef          	jal	340 <exit>

00000000000000ac <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  ac:	1141                	addi	sp,sp,-16
  ae:	e406                	sd	ra,8(sp)
  b0:	e022                	sd	s0,0(sp)
  b2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  b4:	f4dff0ef          	jal	0 <main>
  exit(r);
  b8:	288000ef          	jal	340 <exit>

00000000000000bc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  bc:	1141                	addi	sp,sp,-16
  be:	e422                	sd	s0,8(sp)
  c0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  c2:	87aa                	mv	a5,a0
  c4:	0585                	addi	a1,a1,1
  c6:	0785                	addi	a5,a5,1
  c8:	fff5c703          	lbu	a4,-1(a1)
  cc:	fee78fa3          	sb	a4,-1(a5)
  d0:	fb75                	bnez	a4,c4 <strcpy+0x8>
    ;
  return os;
}
  d2:	6422                	ld	s0,8(sp)
  d4:	0141                	addi	sp,sp,16
  d6:	8082                	ret

00000000000000d8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e422                	sd	s0,8(sp)
  dc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  de:	00054783          	lbu	a5,0(a0)
  e2:	cb91                	beqz	a5,f6 <strcmp+0x1e>
  e4:	0005c703          	lbu	a4,0(a1)
  e8:	00f71763          	bne	a4,a5,f6 <strcmp+0x1e>
    p++, q++;
  ec:	0505                	addi	a0,a0,1
  ee:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  f0:	00054783          	lbu	a5,0(a0)
  f4:	fbe5                	bnez	a5,e4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  f6:	0005c503          	lbu	a0,0(a1)
}
  fa:	40a7853b          	subw	a0,a5,a0
  fe:	6422                	ld	s0,8(sp)
 100:	0141                	addi	sp,sp,16
 102:	8082                	ret

0000000000000104 <strlen>:

uint
strlen(const char *s)
{
 104:	1141                	addi	sp,sp,-16
 106:	e422                	sd	s0,8(sp)
 108:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 10a:	00054783          	lbu	a5,0(a0)
 10e:	cf91                	beqz	a5,12a <strlen+0x26>
 110:	0505                	addi	a0,a0,1
 112:	87aa                	mv	a5,a0
 114:	86be                	mv	a3,a5
 116:	0785                	addi	a5,a5,1
 118:	fff7c703          	lbu	a4,-1(a5)
 11c:	ff65                	bnez	a4,114 <strlen+0x10>
 11e:	40a6853b          	subw	a0,a3,a0
 122:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 124:	6422                	ld	s0,8(sp)
 126:	0141                	addi	sp,sp,16
 128:	8082                	ret
  for(n = 0; s[n]; n++)
 12a:	4501                	li	a0,0
 12c:	bfe5                	j	124 <strlen+0x20>

000000000000012e <memset>:

void*
memset(void *dst, int c, uint n)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e422                	sd	s0,8(sp)
 132:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 134:	ca19                	beqz	a2,14a <memset+0x1c>
 136:	87aa                	mv	a5,a0
 138:	1602                	slli	a2,a2,0x20
 13a:	9201                	srli	a2,a2,0x20
 13c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 140:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 144:	0785                	addi	a5,a5,1
 146:	fee79de3          	bne	a5,a4,140 <memset+0x12>
  }
  return dst;
}
 14a:	6422                	ld	s0,8(sp)
 14c:	0141                	addi	sp,sp,16
 14e:	8082                	ret

0000000000000150 <strchr>:

char*
strchr(const char *s, char c)
{
 150:	1141                	addi	sp,sp,-16
 152:	e422                	sd	s0,8(sp)
 154:	0800                	addi	s0,sp,16
  for(; *s; s++)
 156:	00054783          	lbu	a5,0(a0)
 15a:	cb99                	beqz	a5,170 <strchr+0x20>
    if(*s == c)
 15c:	00f58763          	beq	a1,a5,16a <strchr+0x1a>
  for(; *s; s++)
 160:	0505                	addi	a0,a0,1
 162:	00054783          	lbu	a5,0(a0)
 166:	fbfd                	bnez	a5,15c <strchr+0xc>
      return (char*)s;
  return 0;
 168:	4501                	li	a0,0
}
 16a:	6422                	ld	s0,8(sp)
 16c:	0141                	addi	sp,sp,16
 16e:	8082                	ret
  return 0;
 170:	4501                	li	a0,0
 172:	bfe5                	j	16a <strchr+0x1a>

0000000000000174 <gets>:

char*
gets(char *buf, int max)
{
 174:	711d                	addi	sp,sp,-96
 176:	ec86                	sd	ra,88(sp)
 178:	e8a2                	sd	s0,80(sp)
 17a:	e4a6                	sd	s1,72(sp)
 17c:	e0ca                	sd	s2,64(sp)
 17e:	fc4e                	sd	s3,56(sp)
 180:	f852                	sd	s4,48(sp)
 182:	f456                	sd	s5,40(sp)
 184:	f05a                	sd	s6,32(sp)
 186:	ec5e                	sd	s7,24(sp)
 188:	1080                	addi	s0,sp,96
 18a:	8baa                	mv	s7,a0
 18c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18e:	892a                	mv	s2,a0
 190:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 192:	4aa9                	li	s5,10
 194:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 196:	89a6                	mv	s3,s1
 198:	2485                	addiw	s1,s1,1
 19a:	0344d663          	bge	s1,s4,1c6 <gets+0x52>
    cc = read(0, &c, 1);
 19e:	4605                	li	a2,1
 1a0:	faf40593          	addi	a1,s0,-81
 1a4:	4501                	li	a0,0
 1a6:	1b2000ef          	jal	358 <read>
    if(cc < 1)
 1aa:	00a05e63          	blez	a0,1c6 <gets+0x52>
    buf[i++] = c;
 1ae:	faf44783          	lbu	a5,-81(s0)
 1b2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1b6:	01578763          	beq	a5,s5,1c4 <gets+0x50>
 1ba:	0905                	addi	s2,s2,1
 1bc:	fd679de3          	bne	a5,s6,196 <gets+0x22>
    buf[i++] = c;
 1c0:	89a6                	mv	s3,s1
 1c2:	a011                	j	1c6 <gets+0x52>
 1c4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1c6:	99de                	add	s3,s3,s7
 1c8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1cc:	855e                	mv	a0,s7
 1ce:	60e6                	ld	ra,88(sp)
 1d0:	6446                	ld	s0,80(sp)
 1d2:	64a6                	ld	s1,72(sp)
 1d4:	6906                	ld	s2,64(sp)
 1d6:	79e2                	ld	s3,56(sp)
 1d8:	7a42                	ld	s4,48(sp)
 1da:	7aa2                	ld	s5,40(sp)
 1dc:	7b02                	ld	s6,32(sp)
 1de:	6be2                	ld	s7,24(sp)
 1e0:	6125                	addi	sp,sp,96
 1e2:	8082                	ret

00000000000001e4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e4:	1101                	addi	sp,sp,-32
 1e6:	ec06                	sd	ra,24(sp)
 1e8:	e822                	sd	s0,16(sp)
 1ea:	e04a                	sd	s2,0(sp)
 1ec:	1000                	addi	s0,sp,32
 1ee:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f0:	4581                	li	a1,0
 1f2:	18e000ef          	jal	380 <open>
  if(fd < 0)
 1f6:	02054263          	bltz	a0,21a <stat+0x36>
 1fa:	e426                	sd	s1,8(sp)
 1fc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1fe:	85ca                	mv	a1,s2
 200:	198000ef          	jal	398 <fstat>
 204:	892a                	mv	s2,a0
  close(fd);
 206:	8526                	mv	a0,s1
 208:	160000ef          	jal	368 <close>
  return r;
 20c:	64a2                	ld	s1,8(sp)
}
 20e:	854a                	mv	a0,s2
 210:	60e2                	ld	ra,24(sp)
 212:	6442                	ld	s0,16(sp)
 214:	6902                	ld	s2,0(sp)
 216:	6105                	addi	sp,sp,32
 218:	8082                	ret
    return -1;
 21a:	597d                	li	s2,-1
 21c:	bfcd                	j	20e <stat+0x2a>

000000000000021e <atoi>:

int
atoi(const char *s)
{
 21e:	1141                	addi	sp,sp,-16
 220:	e422                	sd	s0,8(sp)
 222:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 224:	00054683          	lbu	a3,0(a0)
 228:	fd06879b          	addiw	a5,a3,-48
 22c:	0ff7f793          	zext.b	a5,a5
 230:	4625                	li	a2,9
 232:	02f66863          	bltu	a2,a5,262 <atoi+0x44>
 236:	872a                	mv	a4,a0
  n = 0;
 238:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 23a:	0705                	addi	a4,a4,1
 23c:	0025179b          	slliw	a5,a0,0x2
 240:	9fa9                	addw	a5,a5,a0
 242:	0017979b          	slliw	a5,a5,0x1
 246:	9fb5                	addw	a5,a5,a3
 248:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 24c:	00074683          	lbu	a3,0(a4)
 250:	fd06879b          	addiw	a5,a3,-48
 254:	0ff7f793          	zext.b	a5,a5
 258:	fef671e3          	bgeu	a2,a5,23a <atoi+0x1c>
  return n;
}
 25c:	6422                	ld	s0,8(sp)
 25e:	0141                	addi	sp,sp,16
 260:	8082                	ret
  n = 0;
 262:	4501                	li	a0,0
 264:	bfe5                	j	25c <atoi+0x3e>

0000000000000266 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 266:	1141                	addi	sp,sp,-16
 268:	e422                	sd	s0,8(sp)
 26a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 26c:	02b57463          	bgeu	a0,a1,294 <memmove+0x2e>
    while(n-- > 0)
 270:	00c05f63          	blez	a2,28e <memmove+0x28>
 274:	1602                	slli	a2,a2,0x20
 276:	9201                	srli	a2,a2,0x20
 278:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 27c:	872a                	mv	a4,a0
      *dst++ = *src++;
 27e:	0585                	addi	a1,a1,1
 280:	0705                	addi	a4,a4,1
 282:	fff5c683          	lbu	a3,-1(a1)
 286:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 28a:	fef71ae3          	bne	a4,a5,27e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret
    dst += n;
 294:	00c50733          	add	a4,a0,a2
    src += n;
 298:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 29a:	fec05ae3          	blez	a2,28e <memmove+0x28>
 29e:	fff6079b          	addiw	a5,a2,-1
 2a2:	1782                	slli	a5,a5,0x20
 2a4:	9381                	srli	a5,a5,0x20
 2a6:	fff7c793          	not	a5,a5
 2aa:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2ac:	15fd                	addi	a1,a1,-1
 2ae:	177d                	addi	a4,a4,-1
 2b0:	0005c683          	lbu	a3,0(a1)
 2b4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b8:	fee79ae3          	bne	a5,a4,2ac <memmove+0x46>
 2bc:	bfc9                	j	28e <memmove+0x28>

00000000000002be <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2be:	1141                	addi	sp,sp,-16
 2c0:	e422                	sd	s0,8(sp)
 2c2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2c4:	ca05                	beqz	a2,2f4 <memcmp+0x36>
 2c6:	fff6069b          	addiw	a3,a2,-1
 2ca:	1682                	slli	a3,a3,0x20
 2cc:	9281                	srli	a3,a3,0x20
 2ce:	0685                	addi	a3,a3,1
 2d0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2d2:	00054783          	lbu	a5,0(a0)
 2d6:	0005c703          	lbu	a4,0(a1)
 2da:	00e79863          	bne	a5,a4,2ea <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2de:	0505                	addi	a0,a0,1
    p2++;
 2e0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2e2:	fed518e3          	bne	a0,a3,2d2 <memcmp+0x14>
  }
  return 0;
 2e6:	4501                	li	a0,0
 2e8:	a019                	j	2ee <memcmp+0x30>
      return *p1 - *p2;
 2ea:	40e7853b          	subw	a0,a5,a4
}
 2ee:	6422                	ld	s0,8(sp)
 2f0:	0141                	addi	sp,sp,16
 2f2:	8082                	ret
  return 0;
 2f4:	4501                	li	a0,0
 2f6:	bfe5                	j	2ee <memcmp+0x30>

00000000000002f8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e406                	sd	ra,8(sp)
 2fc:	e022                	sd	s0,0(sp)
 2fe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 300:	f67ff0ef          	jal	266 <memmove>
}
 304:	60a2                	ld	ra,8(sp)
 306:	6402                	ld	s0,0(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret

000000000000030c <sbrk>:

char *
sbrk(int n) {
 30c:	1141                	addi	sp,sp,-16
 30e:	e406                	sd	ra,8(sp)
 310:	e022                	sd	s0,0(sp)
 312:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 314:	4585                	li	a1,1
 316:	0b2000ef          	jal	3c8 <sys_sbrk>
}
 31a:	60a2                	ld	ra,8(sp)
 31c:	6402                	ld	s0,0(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret

0000000000000322 <sbrklazy>:

char *
sbrklazy(int n) {
 322:	1141                	addi	sp,sp,-16
 324:	e406                	sd	ra,8(sp)
 326:	e022                	sd	s0,0(sp)
 328:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 32a:	4589                	li	a1,2
 32c:	09c000ef          	jal	3c8 <sys_sbrk>
}
 330:	60a2                	ld	ra,8(sp)
 332:	6402                	ld	s0,0(sp)
 334:	0141                	addi	sp,sp,16
 336:	8082                	ret

0000000000000338 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 338:	4885                	li	a7,1
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <exit>:
.global exit
exit:
 li a7, SYS_exit
 340:	4889                	li	a7,2
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <wait>:
.global wait
wait:
 li a7, SYS_wait
 348:	488d                	li	a7,3
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 350:	4891                	li	a7,4
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <read>:
.global read
read:
 li a7, SYS_read
 358:	4895                	li	a7,5
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <write>:
.global write
write:
 li a7, SYS_write
 360:	48c1                	li	a7,16
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <close>:
.global close
close:
 li a7, SYS_close
 368:	48d5                	li	a7,21
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <kill>:
.global kill
kill:
 li a7, SYS_kill
 370:	4899                	li	a7,6
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <exec>:
.global exec
exec:
 li a7, SYS_exec
 378:	489d                	li	a7,7
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <open>:
.global open
open:
 li a7, SYS_open
 380:	48bd                	li	a7,15
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 388:	48c5                	li	a7,17
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 390:	48c9                	li	a7,18
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 398:	48a1                	li	a7,8
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <link>:
.global link
link:
 li a7, SYS_link
 3a0:	48cd                	li	a7,19
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a8:	48d1                	li	a7,20
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3b0:	48a5                	li	a7,9
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b8:	48a9                	li	a7,10
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3c0:	48ad                	li	a7,11
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3c8:	48b1                	li	a7,12
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3d0:	48b5                	li	a7,13
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d8:	48b9                	li	a7,14
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <msgbox_create>:
.global msgbox_create
msgbox_create:
 li a7, SYS_msgbox_create
 3e0:	48d9                	li	a7,22
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <msgbox_send>:
.global msgbox_send
msgbox_send:
 li a7, SYS_msgbox_send
 3e8:	48dd                	li	a7,23
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <msgbox_recv>:
.global msgbox_recv
msgbox_recv:
 li a7, SYS_msgbox_recv
 3f0:	48e1                	li	a7,24
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <msgbox_destroy>:
.global msgbox_destroy
msgbox_destroy:
 li a7, SYS_msgbox_destroy
 3f8:	48e5                	li	a7,25
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <msgbox_count>:
.global msgbox_count
msgbox_count:
 li a7, SYS_msgbox_count
 400:	48e9                	li	a7,26
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 408:	1101                	addi	sp,sp,-32
 40a:	ec06                	sd	ra,24(sp)
 40c:	e822                	sd	s0,16(sp)
 40e:	1000                	addi	s0,sp,32
 410:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 414:	4605                	li	a2,1
 416:	fef40593          	addi	a1,s0,-17
 41a:	f47ff0ef          	jal	360 <write>
}
 41e:	60e2                	ld	ra,24(sp)
 420:	6442                	ld	s0,16(sp)
 422:	6105                	addi	sp,sp,32
 424:	8082                	ret

0000000000000426 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 426:	715d                	addi	sp,sp,-80
 428:	e486                	sd	ra,72(sp)
 42a:	e0a2                	sd	s0,64(sp)
 42c:	f84a                	sd	s2,48(sp)
 42e:	0880                	addi	s0,sp,80
 430:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 432:	c299                	beqz	a3,438 <printint+0x12>
 434:	0805c363          	bltz	a1,4ba <printint+0x94>
  neg = 0;
 438:	4881                	li	a7,0
 43a:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 43e:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 440:	00000517          	auipc	a0,0x0
 444:	59850513          	addi	a0,a0,1432 # 9d8 <digits>
 448:	883e                	mv	a6,a5
 44a:	2785                	addiw	a5,a5,1
 44c:	02c5f733          	remu	a4,a1,a2
 450:	972a                	add	a4,a4,a0
 452:	00074703          	lbu	a4,0(a4)
 456:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 45a:	872e                	mv	a4,a1
 45c:	02c5d5b3          	divu	a1,a1,a2
 460:	0685                	addi	a3,a3,1
 462:	fec773e3          	bgeu	a4,a2,448 <printint+0x22>
  if(neg)
 466:	00088b63          	beqz	a7,47c <printint+0x56>
    buf[i++] = '-';
 46a:	fd078793          	addi	a5,a5,-48
 46e:	97a2                	add	a5,a5,s0
 470:	02d00713          	li	a4,45
 474:	fee78423          	sb	a4,-24(a5)
 478:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 47c:	02f05a63          	blez	a5,4b0 <printint+0x8a>
 480:	fc26                	sd	s1,56(sp)
 482:	f44e                	sd	s3,40(sp)
 484:	fb840713          	addi	a4,s0,-72
 488:	00f704b3          	add	s1,a4,a5
 48c:	fff70993          	addi	s3,a4,-1
 490:	99be                	add	s3,s3,a5
 492:	37fd                	addiw	a5,a5,-1
 494:	1782                	slli	a5,a5,0x20
 496:	9381                	srli	a5,a5,0x20
 498:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 49c:	fff4c583          	lbu	a1,-1(s1)
 4a0:	854a                	mv	a0,s2
 4a2:	f67ff0ef          	jal	408 <putc>
  while(--i >= 0)
 4a6:	14fd                	addi	s1,s1,-1
 4a8:	ff349ae3          	bne	s1,s3,49c <printint+0x76>
 4ac:	74e2                	ld	s1,56(sp)
 4ae:	79a2                	ld	s3,40(sp)
}
 4b0:	60a6                	ld	ra,72(sp)
 4b2:	6406                	ld	s0,64(sp)
 4b4:	7942                	ld	s2,48(sp)
 4b6:	6161                	addi	sp,sp,80
 4b8:	8082                	ret
    x = -xx;
 4ba:	40b005b3          	neg	a1,a1
    neg = 1;
 4be:	4885                	li	a7,1
    x = -xx;
 4c0:	bfad                	j	43a <printint+0x14>

00000000000004c2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4c2:	711d                	addi	sp,sp,-96
 4c4:	ec86                	sd	ra,88(sp)
 4c6:	e8a2                	sd	s0,80(sp)
 4c8:	e0ca                	sd	s2,64(sp)
 4ca:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4cc:	0005c903          	lbu	s2,0(a1)
 4d0:	28090663          	beqz	s2,75c <vprintf+0x29a>
 4d4:	e4a6                	sd	s1,72(sp)
 4d6:	fc4e                	sd	s3,56(sp)
 4d8:	f852                	sd	s4,48(sp)
 4da:	f456                	sd	s5,40(sp)
 4dc:	f05a                	sd	s6,32(sp)
 4de:	ec5e                	sd	s7,24(sp)
 4e0:	e862                	sd	s8,16(sp)
 4e2:	e466                	sd	s9,8(sp)
 4e4:	8b2a                	mv	s6,a0
 4e6:	8a2e                	mv	s4,a1
 4e8:	8bb2                	mv	s7,a2
  state = 0;
 4ea:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4ec:	4481                	li	s1,0
 4ee:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4f0:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4f4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4f8:	06c00c93          	li	s9,108
 4fc:	a005                	j	51c <vprintf+0x5a>
        putc(fd, c0);
 4fe:	85ca                	mv	a1,s2
 500:	855a                	mv	a0,s6
 502:	f07ff0ef          	jal	408 <putc>
 506:	a019                	j	50c <vprintf+0x4a>
    } else if(state == '%'){
 508:	03598263          	beq	s3,s5,52c <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 50c:	2485                	addiw	s1,s1,1
 50e:	8726                	mv	a4,s1
 510:	009a07b3          	add	a5,s4,s1
 514:	0007c903          	lbu	s2,0(a5)
 518:	22090a63          	beqz	s2,74c <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 51c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 520:	fe0994e3          	bnez	s3,508 <vprintf+0x46>
      if(c0 == '%'){
 524:	fd579de3          	bne	a5,s5,4fe <vprintf+0x3c>
        state = '%';
 528:	89be                	mv	s3,a5
 52a:	b7cd                	j	50c <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 52c:	00ea06b3          	add	a3,s4,a4
 530:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 534:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 536:	c681                	beqz	a3,53e <vprintf+0x7c>
 538:	9752                	add	a4,a4,s4
 53a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 53e:	05878363          	beq	a5,s8,584 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 542:	05978d63          	beq	a5,s9,59c <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 546:	07500713          	li	a4,117
 54a:	0ee78763          	beq	a5,a4,638 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 54e:	07800713          	li	a4,120
 552:	12e78963          	beq	a5,a4,684 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 556:	07000713          	li	a4,112
 55a:	14e78e63          	beq	a5,a4,6b6 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 55e:	06300713          	li	a4,99
 562:	18e78e63          	beq	a5,a4,6fe <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 566:	07300713          	li	a4,115
 56a:	1ae78463          	beq	a5,a4,712 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 56e:	02500713          	li	a4,37
 572:	04e79563          	bne	a5,a4,5bc <vprintf+0xfa>
        putc(fd, '%');
 576:	02500593          	li	a1,37
 57a:	855a                	mv	a0,s6
 57c:	e8dff0ef          	jal	408 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 580:	4981                	li	s3,0
 582:	b769                	j	50c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 584:	008b8913          	addi	s2,s7,8
 588:	4685                	li	a3,1
 58a:	4629                	li	a2,10
 58c:	000ba583          	lw	a1,0(s7)
 590:	855a                	mv	a0,s6
 592:	e95ff0ef          	jal	426 <printint>
 596:	8bca                	mv	s7,s2
      state = 0;
 598:	4981                	li	s3,0
 59a:	bf8d                	j	50c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 59c:	06400793          	li	a5,100
 5a0:	02f68963          	beq	a3,a5,5d2 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5a4:	06c00793          	li	a5,108
 5a8:	04f68263          	beq	a3,a5,5ec <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5ac:	07500793          	li	a5,117
 5b0:	0af68063          	beq	a3,a5,650 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 5b4:	07800793          	li	a5,120
 5b8:	0ef68263          	beq	a3,a5,69c <vprintf+0x1da>
        putc(fd, '%');
 5bc:	02500593          	li	a1,37
 5c0:	855a                	mv	a0,s6
 5c2:	e47ff0ef          	jal	408 <putc>
        putc(fd, c0);
 5c6:	85ca                	mv	a1,s2
 5c8:	855a                	mv	a0,s6
 5ca:	e3fff0ef          	jal	408 <putc>
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	bf35                	j	50c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d2:	008b8913          	addi	s2,s7,8
 5d6:	4685                	li	a3,1
 5d8:	4629                	li	a2,10
 5da:	000bb583          	ld	a1,0(s7)
 5de:	855a                	mv	a0,s6
 5e0:	e47ff0ef          	jal	426 <printint>
        i += 1;
 5e4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e6:	8bca                	mv	s7,s2
      state = 0;
 5e8:	4981                	li	s3,0
        i += 1;
 5ea:	b70d                	j	50c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ec:	06400793          	li	a5,100
 5f0:	02f60763          	beq	a2,a5,61e <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5f4:	07500793          	li	a5,117
 5f8:	06f60963          	beq	a2,a5,66a <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5fc:	07800793          	li	a5,120
 600:	faf61ee3          	bne	a2,a5,5bc <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 604:	008b8913          	addi	s2,s7,8
 608:	4681                	li	a3,0
 60a:	4641                	li	a2,16
 60c:	000bb583          	ld	a1,0(s7)
 610:	855a                	mv	a0,s6
 612:	e15ff0ef          	jal	426 <printint>
        i += 2;
 616:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 618:	8bca                	mv	s7,s2
      state = 0;
 61a:	4981                	li	s3,0
        i += 2;
 61c:	bdc5                	j	50c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 61e:	008b8913          	addi	s2,s7,8
 622:	4685                	li	a3,1
 624:	4629                	li	a2,10
 626:	000bb583          	ld	a1,0(s7)
 62a:	855a                	mv	a0,s6
 62c:	dfbff0ef          	jal	426 <printint>
        i += 2;
 630:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 632:	8bca                	mv	s7,s2
      state = 0;
 634:	4981                	li	s3,0
        i += 2;
 636:	bdd9                	j	50c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 638:	008b8913          	addi	s2,s7,8
 63c:	4681                	li	a3,0
 63e:	4629                	li	a2,10
 640:	000be583          	lwu	a1,0(s7)
 644:	855a                	mv	a0,s6
 646:	de1ff0ef          	jal	426 <printint>
 64a:	8bca                	mv	s7,s2
      state = 0;
 64c:	4981                	li	s3,0
 64e:	bd7d                	j	50c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 650:	008b8913          	addi	s2,s7,8
 654:	4681                	li	a3,0
 656:	4629                	li	a2,10
 658:	000bb583          	ld	a1,0(s7)
 65c:	855a                	mv	a0,s6
 65e:	dc9ff0ef          	jal	426 <printint>
        i += 1;
 662:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 664:	8bca                	mv	s7,s2
      state = 0;
 666:	4981                	li	s3,0
        i += 1;
 668:	b555                	j	50c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 66a:	008b8913          	addi	s2,s7,8
 66e:	4681                	li	a3,0
 670:	4629                	li	a2,10
 672:	000bb583          	ld	a1,0(s7)
 676:	855a                	mv	a0,s6
 678:	dafff0ef          	jal	426 <printint>
        i += 2;
 67c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 67e:	8bca                	mv	s7,s2
      state = 0;
 680:	4981                	li	s3,0
        i += 2;
 682:	b569                	j	50c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 684:	008b8913          	addi	s2,s7,8
 688:	4681                	li	a3,0
 68a:	4641                	li	a2,16
 68c:	000be583          	lwu	a1,0(s7)
 690:	855a                	mv	a0,s6
 692:	d95ff0ef          	jal	426 <printint>
 696:	8bca                	mv	s7,s2
      state = 0;
 698:	4981                	li	s3,0
 69a:	bd8d                	j	50c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 69c:	008b8913          	addi	s2,s7,8
 6a0:	4681                	li	a3,0
 6a2:	4641                	li	a2,16
 6a4:	000bb583          	ld	a1,0(s7)
 6a8:	855a                	mv	a0,s6
 6aa:	d7dff0ef          	jal	426 <printint>
        i += 1;
 6ae:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b0:	8bca                	mv	s7,s2
      state = 0;
 6b2:	4981                	li	s3,0
        i += 1;
 6b4:	bda1                	j	50c <vprintf+0x4a>
 6b6:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6b8:	008b8d13          	addi	s10,s7,8
 6bc:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6c0:	03000593          	li	a1,48
 6c4:	855a                	mv	a0,s6
 6c6:	d43ff0ef          	jal	408 <putc>
  putc(fd, 'x');
 6ca:	07800593          	li	a1,120
 6ce:	855a                	mv	a0,s6
 6d0:	d39ff0ef          	jal	408 <putc>
 6d4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6d6:	00000b97          	auipc	s7,0x0
 6da:	302b8b93          	addi	s7,s7,770 # 9d8 <digits>
 6de:	03c9d793          	srli	a5,s3,0x3c
 6e2:	97de                	add	a5,a5,s7
 6e4:	0007c583          	lbu	a1,0(a5)
 6e8:	855a                	mv	a0,s6
 6ea:	d1fff0ef          	jal	408 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6ee:	0992                	slli	s3,s3,0x4
 6f0:	397d                	addiw	s2,s2,-1
 6f2:	fe0916e3          	bnez	s2,6de <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 6f6:	8bea                	mv	s7,s10
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	6d02                	ld	s10,0(sp)
 6fc:	bd01                	j	50c <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 6fe:	008b8913          	addi	s2,s7,8
 702:	000bc583          	lbu	a1,0(s7)
 706:	855a                	mv	a0,s6
 708:	d01ff0ef          	jal	408 <putc>
 70c:	8bca                	mv	s7,s2
      state = 0;
 70e:	4981                	li	s3,0
 710:	bbf5                	j	50c <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 712:	008b8993          	addi	s3,s7,8
 716:	000bb903          	ld	s2,0(s7)
 71a:	00090f63          	beqz	s2,738 <vprintf+0x276>
        for(; *s; s++)
 71e:	00094583          	lbu	a1,0(s2)
 722:	c195                	beqz	a1,746 <vprintf+0x284>
          putc(fd, *s);
 724:	855a                	mv	a0,s6
 726:	ce3ff0ef          	jal	408 <putc>
        for(; *s; s++)
 72a:	0905                	addi	s2,s2,1
 72c:	00094583          	lbu	a1,0(s2)
 730:	f9f5                	bnez	a1,724 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 732:	8bce                	mv	s7,s3
      state = 0;
 734:	4981                	li	s3,0
 736:	bbd9                	j	50c <vprintf+0x4a>
          s = "(null)";
 738:	00000917          	auipc	s2,0x0
 73c:	29890913          	addi	s2,s2,664 # 9d0 <malloc+0x18c>
        for(; *s; s++)
 740:	02800593          	li	a1,40
 744:	b7c5                	j	724 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 746:	8bce                	mv	s7,s3
      state = 0;
 748:	4981                	li	s3,0
 74a:	b3c9                	j	50c <vprintf+0x4a>
 74c:	64a6                	ld	s1,72(sp)
 74e:	79e2                	ld	s3,56(sp)
 750:	7a42                	ld	s4,48(sp)
 752:	7aa2                	ld	s5,40(sp)
 754:	7b02                	ld	s6,32(sp)
 756:	6be2                	ld	s7,24(sp)
 758:	6c42                	ld	s8,16(sp)
 75a:	6ca2                	ld	s9,8(sp)
    }
  }
}
 75c:	60e6                	ld	ra,88(sp)
 75e:	6446                	ld	s0,80(sp)
 760:	6906                	ld	s2,64(sp)
 762:	6125                	addi	sp,sp,96
 764:	8082                	ret

0000000000000766 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 766:	715d                	addi	sp,sp,-80
 768:	ec06                	sd	ra,24(sp)
 76a:	e822                	sd	s0,16(sp)
 76c:	1000                	addi	s0,sp,32
 76e:	e010                	sd	a2,0(s0)
 770:	e414                	sd	a3,8(s0)
 772:	e818                	sd	a4,16(s0)
 774:	ec1c                	sd	a5,24(s0)
 776:	03043023          	sd	a6,32(s0)
 77a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 77e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 782:	8622                	mv	a2,s0
 784:	d3fff0ef          	jal	4c2 <vprintf>
}
 788:	60e2                	ld	ra,24(sp)
 78a:	6442                	ld	s0,16(sp)
 78c:	6161                	addi	sp,sp,80
 78e:	8082                	ret

0000000000000790 <printf>:

void
printf(const char *fmt, ...)
{
 790:	711d                	addi	sp,sp,-96
 792:	ec06                	sd	ra,24(sp)
 794:	e822                	sd	s0,16(sp)
 796:	1000                	addi	s0,sp,32
 798:	e40c                	sd	a1,8(s0)
 79a:	e810                	sd	a2,16(s0)
 79c:	ec14                	sd	a3,24(s0)
 79e:	f018                	sd	a4,32(s0)
 7a0:	f41c                	sd	a5,40(s0)
 7a2:	03043823          	sd	a6,48(s0)
 7a6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7aa:	00840613          	addi	a2,s0,8
 7ae:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7b2:	85aa                	mv	a1,a0
 7b4:	4505                	li	a0,1
 7b6:	d0dff0ef          	jal	4c2 <vprintf>
}
 7ba:	60e2                	ld	ra,24(sp)
 7bc:	6442                	ld	s0,16(sp)
 7be:	6125                	addi	sp,sp,96
 7c0:	8082                	ret

00000000000007c2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c2:	1141                	addi	sp,sp,-16
 7c4:	e422                	sd	s0,8(sp)
 7c6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7c8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7cc:	00001797          	auipc	a5,0x1
 7d0:	8347b783          	ld	a5,-1996(a5) # 1000 <freep>
 7d4:	a02d                	j	7fe <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7d6:	4618                	lw	a4,8(a2)
 7d8:	9f2d                	addw	a4,a4,a1
 7da:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7de:	6398                	ld	a4,0(a5)
 7e0:	6310                	ld	a2,0(a4)
 7e2:	a83d                	j	820 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7e4:	ff852703          	lw	a4,-8(a0)
 7e8:	9f31                	addw	a4,a4,a2
 7ea:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7ec:	ff053683          	ld	a3,-16(a0)
 7f0:	a091                	j	834 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f2:	6398                	ld	a4,0(a5)
 7f4:	00e7e463          	bltu	a5,a4,7fc <free+0x3a>
 7f8:	00e6ea63          	bltu	a3,a4,80c <free+0x4a>
{
 7fc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fe:	fed7fae3          	bgeu	a5,a3,7f2 <free+0x30>
 802:	6398                	ld	a4,0(a5)
 804:	00e6e463          	bltu	a3,a4,80c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 808:	fee7eae3          	bltu	a5,a4,7fc <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 80c:	ff852583          	lw	a1,-8(a0)
 810:	6390                	ld	a2,0(a5)
 812:	02059813          	slli	a6,a1,0x20
 816:	01c85713          	srli	a4,a6,0x1c
 81a:	9736                	add	a4,a4,a3
 81c:	fae60de3          	beq	a2,a4,7d6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 820:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 824:	4790                	lw	a2,8(a5)
 826:	02061593          	slli	a1,a2,0x20
 82a:	01c5d713          	srli	a4,a1,0x1c
 82e:	973e                	add	a4,a4,a5
 830:	fae68ae3          	beq	a3,a4,7e4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 834:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 836:	00000717          	auipc	a4,0x0
 83a:	7cf73523          	sd	a5,1994(a4) # 1000 <freep>
}
 83e:	6422                	ld	s0,8(sp)
 840:	0141                	addi	sp,sp,16
 842:	8082                	ret

0000000000000844 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 844:	7139                	addi	sp,sp,-64
 846:	fc06                	sd	ra,56(sp)
 848:	f822                	sd	s0,48(sp)
 84a:	f426                	sd	s1,40(sp)
 84c:	ec4e                	sd	s3,24(sp)
 84e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 850:	02051493          	slli	s1,a0,0x20
 854:	9081                	srli	s1,s1,0x20
 856:	04bd                	addi	s1,s1,15
 858:	8091                	srli	s1,s1,0x4
 85a:	0014899b          	addiw	s3,s1,1
 85e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 860:	00000517          	auipc	a0,0x0
 864:	7a053503          	ld	a0,1952(a0) # 1000 <freep>
 868:	c915                	beqz	a0,89c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 86a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 86c:	4798                	lw	a4,8(a5)
 86e:	08977a63          	bgeu	a4,s1,902 <malloc+0xbe>
 872:	f04a                	sd	s2,32(sp)
 874:	e852                	sd	s4,16(sp)
 876:	e456                	sd	s5,8(sp)
 878:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 87a:	8a4e                	mv	s4,s3
 87c:	0009871b          	sext.w	a4,s3
 880:	6685                	lui	a3,0x1
 882:	00d77363          	bgeu	a4,a3,888 <malloc+0x44>
 886:	6a05                	lui	s4,0x1
 888:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 88c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 890:	00000917          	auipc	s2,0x0
 894:	77090913          	addi	s2,s2,1904 # 1000 <freep>
  if(p == SBRK_ERROR)
 898:	5afd                	li	s5,-1
 89a:	a081                	j	8da <malloc+0x96>
 89c:	f04a                	sd	s2,32(sp)
 89e:	e852                	sd	s4,16(sp)
 8a0:	e456                	sd	s5,8(sp)
 8a2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8a4:	00000797          	auipc	a5,0x0
 8a8:	76c78793          	addi	a5,a5,1900 # 1010 <base>
 8ac:	00000717          	auipc	a4,0x0
 8b0:	74f73a23          	sd	a5,1876(a4) # 1000 <freep>
 8b4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8b6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ba:	b7c1                	j	87a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8bc:	6398                	ld	a4,0(a5)
 8be:	e118                	sd	a4,0(a0)
 8c0:	a8a9                	j	91a <malloc+0xd6>
  hp->s.size = nu;
 8c2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8c6:	0541                	addi	a0,a0,16
 8c8:	efbff0ef          	jal	7c2 <free>
  return freep;
 8cc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8d0:	c12d                	beqz	a0,932 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d4:	4798                	lw	a4,8(a5)
 8d6:	02977263          	bgeu	a4,s1,8fa <malloc+0xb6>
    if(p == freep)
 8da:	00093703          	ld	a4,0(s2)
 8de:	853e                	mv	a0,a5
 8e0:	fef719e3          	bne	a4,a5,8d2 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8e4:	8552                	mv	a0,s4
 8e6:	a27ff0ef          	jal	30c <sbrk>
  if(p == SBRK_ERROR)
 8ea:	fd551ce3          	bne	a0,s5,8c2 <malloc+0x7e>
        return 0;
 8ee:	4501                	li	a0,0
 8f0:	7902                	ld	s2,32(sp)
 8f2:	6a42                	ld	s4,16(sp)
 8f4:	6aa2                	ld	s5,8(sp)
 8f6:	6b02                	ld	s6,0(sp)
 8f8:	a03d                	j	926 <malloc+0xe2>
 8fa:	7902                	ld	s2,32(sp)
 8fc:	6a42                	ld	s4,16(sp)
 8fe:	6aa2                	ld	s5,8(sp)
 900:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 902:	fae48de3          	beq	s1,a4,8bc <malloc+0x78>
        p->s.size -= nunits;
 906:	4137073b          	subw	a4,a4,s3
 90a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 90c:	02071693          	slli	a3,a4,0x20
 910:	01c6d713          	srli	a4,a3,0x1c
 914:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 916:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 91a:	00000717          	auipc	a4,0x0
 91e:	6ea73323          	sd	a0,1766(a4) # 1000 <freep>
      return (void*)(p + 1);
 922:	01078513          	addi	a0,a5,16
  }
}
 926:	70e2                	ld	ra,56(sp)
 928:	7442                	ld	s0,48(sp)
 92a:	74a2                	ld	s1,40(sp)
 92c:	69e2                	ld	s3,24(sp)
 92e:	6121                	addi	sp,sp,64
 930:	8082                	ret
 932:	7902                	ld	s2,32(sp)
 934:	6a42                	ld	s4,16(sp)
 936:	6aa2                	ld	s5,8(sp)
 938:	6b02                	ld	s6,0(sp)
 93a:	b7f5                	j	926 <malloc+0xe2>
