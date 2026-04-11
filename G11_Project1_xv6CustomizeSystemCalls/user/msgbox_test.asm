
user/_msgbox_test:     file format elf64-littleriscv


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
  int len;

  printf("=== IPC Message Box Test ===\n\n");
   8:	00001517          	auipc	a0,0x1
   c:	a7850513          	addi	a0,a0,-1416 # a80 <malloc+0xfe>
  10:	0bf000ef          	jal	8ce <printf>

  // Parent creates its mailbox
  if(msgbox_create("parent") < 0){
  14:	00001517          	auipc	a0,0x1
  18:	a9450513          	addi	a0,a0,-1388 # aa8 <malloc+0x126>
  1c:	502000ef          	jal	51e <msgbox_create>
  20:	0c054263          	bltz	a0,e4 <main+0xe4>
    printf("FAIL: parent could not create mailbox\n");
    exit(1);
  }
  printf("[parent] created mailbox 'parent'\n");
  24:	00001517          	auipc	a0,0x1
  28:	ab450513          	addi	a0,a0,-1356 # ad8 <malloc+0x156>
  2c:	0a3000ef          	jal	8ce <printf>

  int pid = fork();
  30:	446000ef          	jal	476 <fork>
  if(pid < 0){
  34:	0c054163          	bltz	a0,f6 <main+0xf6>
    printf("FAIL: fork failed\n");
    exit(1);
  }

  if(pid == 0){
  38:	10051363          	bnez	a0,13e <main+0x13e>
    // ---- CHILD ----
    // Create child's own mailbox
    if(msgbox_create("child") < 0){
  3c:	00001517          	auipc	a0,0x1
  40:	adc50513          	addi	a0,a0,-1316 # b18 <malloc+0x196>
  44:	4da000ef          	jal	51e <msgbox_create>
  48:	0c054063          	bltz	a0,108 <main+0x108>
      printf("FAIL: child could not create mailbox\n");
      exit(1);
    }
    printf("[child]  created mailbox 'child'\n");
  4c:	00001517          	auipc	a0,0x1
  50:	afc50513          	addi	a0,a0,-1284 # b48 <malloc+0x1c6>
  54:	07b000ef          	jal	8ce <printf>

    // Send a message to parent
    char *msg1 = "hello from child";
    if(msgbox_send("parent", msg1, strlen(msg1) + 1) < 0){
  58:	00001517          	auipc	a0,0x1
  5c:	b1850513          	addi	a0,a0,-1256 # b70 <malloc+0x1ee>
  60:	1e2000ef          	jal	242 <strlen>
  64:	0015061b          	addiw	a2,a0,1
  68:	00001597          	auipc	a1,0x1
  6c:	b0858593          	addi	a1,a1,-1272 # b70 <malloc+0x1ee>
  70:	00001517          	auipc	a0,0x1
  74:	a3850513          	addi	a0,a0,-1480 # aa8 <malloc+0x126>
  78:	4ae000ef          	jal	526 <msgbox_send>
  7c:	08054f63          	bltz	a0,11a <main+0x11a>
      printf("FAIL: child could not send to parent\n");
      exit(1);
    }
    printf("[child]  sent: \"%s\"\n", msg1);
  80:	00001597          	auipc	a1,0x1
  84:	af058593          	addi	a1,a1,-1296 # b70 <malloc+0x1ee>
  88:	00001517          	auipc	a0,0x1
  8c:	b2850513          	addi	a0,a0,-1240 # bb0 <malloc+0x22e>
  90:	03f000ef          	jal	8ce <printf>

    // Small delay so parent prints its receive first
    pause(5);
  94:	4515                	li	a0,5
  96:	478000ef          	jal	50e <pause>

    // Receive reply from parent
    len = msgbox_recv(buf, sizeof(buf));
  9a:	04000593          	li	a1,64
  9e:	fb040513          	addi	a0,s0,-80
  a2:	48c000ef          	jal	52e <msgbox_recv>
  a6:	862a                	mv	a2,a0
    if(len < 0){
  a8:	08054263          	bltz	a0,12c <main+0x12c>
      printf("FAIL: child could not receive\n");
      exit(1);
    }
    printf("[child]  received: \"%s\" (%d bytes)\n", buf, len);
  ac:	fb040593          	addi	a1,s0,-80
  b0:	00001517          	auipc	a0,0x1
  b4:	b3850513          	addi	a0,a0,-1224 # be8 <malloc+0x266>
  b8:	017000ef          	jal	8ce <printf>

    // Check count (should be 0 after receiving)
    int cnt = msgbox_count();
  bc:	482000ef          	jal	53e <msgbox_count>
  c0:	85aa                	mv	a1,a0
    printf("[child]  pending messages: %d\n", cnt);
  c2:	00001517          	auipc	a0,0x1
  c6:	b4e50513          	addi	a0,a0,-1202 # c10 <malloc+0x28e>
  ca:	005000ef          	jal	8ce <printf>

    // Cleanup
    msgbox_destroy();
  ce:	468000ef          	jal	536 <msgbox_destroy>
    printf("[child]  destroyed mailbox\n");
  d2:	00001517          	auipc	a0,0x1
  d6:	b5e50513          	addi	a0,a0,-1186 # c30 <malloc+0x2ae>
  da:	7f4000ef          	jal	8ce <printf>
    exit(0);
  de:	4501                	li	a0,0
  e0:	39e000ef          	jal	47e <exit>
    printf("FAIL: parent could not create mailbox\n");
  e4:	00001517          	auipc	a0,0x1
  e8:	9cc50513          	addi	a0,a0,-1588 # ab0 <malloc+0x12e>
  ec:	7e2000ef          	jal	8ce <printf>
    exit(1);
  f0:	4505                	li	a0,1
  f2:	38c000ef          	jal	47e <exit>
    printf("FAIL: fork failed\n");
  f6:	00001517          	auipc	a0,0x1
  fa:	a0a50513          	addi	a0,a0,-1526 # b00 <malloc+0x17e>
  fe:	7d0000ef          	jal	8ce <printf>
    exit(1);
 102:	4505                	li	a0,1
 104:	37a000ef          	jal	47e <exit>
      printf("FAIL: child could not create mailbox\n");
 108:	00001517          	auipc	a0,0x1
 10c:	a1850513          	addi	a0,a0,-1512 # b20 <malloc+0x19e>
 110:	7be000ef          	jal	8ce <printf>
      exit(1);
 114:	4505                	li	a0,1
 116:	368000ef          	jal	47e <exit>
      printf("FAIL: child could not send to parent\n");
 11a:	00001517          	auipc	a0,0x1
 11e:	a6e50513          	addi	a0,a0,-1426 # b88 <malloc+0x206>
 122:	7ac000ef          	jal	8ce <printf>
      exit(1);
 126:	4505                	li	a0,1
 128:	356000ef          	jal	47e <exit>
      printf("FAIL: child could not receive\n");
 12c:	00001517          	auipc	a0,0x1
 130:	a9c50513          	addi	a0,a0,-1380 # bc8 <malloc+0x246>
 134:	79a000ef          	jal	8ce <printf>
      exit(1);
 138:	4505                	li	a0,1
 13a:	344000ef          	jal	47e <exit>

  } else {
    // ---- PARENT ----

    // Receive message from child
    len = msgbox_recv(buf, sizeof(buf));
 13e:	04000593          	li	a1,64
 142:	fb040513          	addi	a0,s0,-80
 146:	3e8000ef          	jal	52e <msgbox_recv>
 14a:	862a                	mv	a2,a0
    if(len < 0){
 14c:	06054d63          	bltz	a0,1c6 <main+0x1c6>
      printf("FAIL: parent could not receive\n");
      exit(1);
    }
    printf("[parent] received: \"%s\" (%d bytes)\n", buf, len);
 150:	fb040593          	addi	a1,s0,-80
 154:	00001517          	auipc	a0,0x1
 158:	b1c50513          	addi	a0,a0,-1252 # c70 <malloc+0x2ee>
 15c:	772000ef          	jal	8ce <printf>

    // Send reply to child
    char *msg2 = "hello from parent";
    if(msgbox_send("child", msg2, strlen(msg2) + 1) < 0){
 160:	00001517          	auipc	a0,0x1
 164:	b3850513          	addi	a0,a0,-1224 # c98 <malloc+0x316>
 168:	0da000ef          	jal	242 <strlen>
 16c:	0015061b          	addiw	a2,a0,1
 170:	00001597          	auipc	a1,0x1
 174:	b2858593          	addi	a1,a1,-1240 # c98 <malloc+0x316>
 178:	00001517          	auipc	a0,0x1
 17c:	9a050513          	addi	a0,a0,-1632 # b18 <malloc+0x196>
 180:	3a6000ef          	jal	526 <msgbox_send>
 184:	04054a63          	bltz	a0,1d8 <main+0x1d8>
      printf("FAIL: parent could not send to child\n");
      exit(1);
    }
    printf("[parent] sent: \"%s\"\n", msg2);
 188:	00001597          	auipc	a1,0x1
 18c:	b1058593          	addi	a1,a1,-1264 # c98 <malloc+0x316>
 190:	00001517          	auipc	a0,0x1
 194:	b4850513          	addi	a0,a0,-1208 # cd8 <malloc+0x356>
 198:	736000ef          	jal	8ce <printf>

    // Wait for child to finish
    int status;
    wait(&status);
 19c:	fac40513          	addi	a0,s0,-84
 1a0:	2e6000ef          	jal	486 <wait>

    // Cleanup
    msgbox_destroy();
 1a4:	392000ef          	jal	536 <msgbox_destroy>
    printf("[parent] destroyed mailbox\n");
 1a8:	00001517          	auipc	a0,0x1
 1ac:	b4850513          	addi	a0,a0,-1208 # cf0 <malloc+0x36e>
 1b0:	71e000ef          	jal	8ce <printf>

    printf("\n=== All tests passed! ===\n");
 1b4:	00001517          	auipc	a0,0x1
 1b8:	b5c50513          	addi	a0,a0,-1188 # d10 <malloc+0x38e>
 1bc:	712000ef          	jal	8ce <printf>
  }

  exit(0);
 1c0:	4501                	li	a0,0
 1c2:	2bc000ef          	jal	47e <exit>
      printf("FAIL: parent could not receive\n");
 1c6:	00001517          	auipc	a0,0x1
 1ca:	a8a50513          	addi	a0,a0,-1398 # c50 <malloc+0x2ce>
 1ce:	700000ef          	jal	8ce <printf>
      exit(1);
 1d2:	4505                	li	a0,1
 1d4:	2aa000ef          	jal	47e <exit>
      printf("FAIL: parent could not send to child\n");
 1d8:	00001517          	auipc	a0,0x1
 1dc:	ad850513          	addi	a0,a0,-1320 # cb0 <malloc+0x32e>
 1e0:	6ee000ef          	jal	8ce <printf>
      exit(1);
 1e4:	4505                	li	a0,1
 1e6:	298000ef          	jal	47e <exit>

00000000000001ea <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e406                	sd	ra,8(sp)
 1ee:	e022                	sd	s0,0(sp)
 1f0:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1f2:	e0fff0ef          	jal	0 <main>
  exit(r);
 1f6:	288000ef          	jal	47e <exit>

00000000000001fa <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e422                	sd	s0,8(sp)
 1fe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 200:	87aa                	mv	a5,a0
 202:	0585                	addi	a1,a1,1
 204:	0785                	addi	a5,a5,1
 206:	fff5c703          	lbu	a4,-1(a1)
 20a:	fee78fa3          	sb	a4,-1(a5)
 20e:	fb75                	bnez	a4,202 <strcpy+0x8>
    ;
  return os;
}
 210:	6422                	ld	s0,8(sp)
 212:	0141                	addi	sp,sp,16
 214:	8082                	ret

0000000000000216 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 21c:	00054783          	lbu	a5,0(a0)
 220:	cb91                	beqz	a5,234 <strcmp+0x1e>
 222:	0005c703          	lbu	a4,0(a1)
 226:	00f71763          	bne	a4,a5,234 <strcmp+0x1e>
    p++, q++;
 22a:	0505                	addi	a0,a0,1
 22c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 22e:	00054783          	lbu	a5,0(a0)
 232:	fbe5                	bnez	a5,222 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 234:	0005c503          	lbu	a0,0(a1)
}
 238:	40a7853b          	subw	a0,a5,a0
 23c:	6422                	ld	s0,8(sp)
 23e:	0141                	addi	sp,sp,16
 240:	8082                	ret

0000000000000242 <strlen>:

uint
strlen(const char *s)
{
 242:	1141                	addi	sp,sp,-16
 244:	e422                	sd	s0,8(sp)
 246:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 248:	00054783          	lbu	a5,0(a0)
 24c:	cf91                	beqz	a5,268 <strlen+0x26>
 24e:	0505                	addi	a0,a0,1
 250:	87aa                	mv	a5,a0
 252:	86be                	mv	a3,a5
 254:	0785                	addi	a5,a5,1
 256:	fff7c703          	lbu	a4,-1(a5)
 25a:	ff65                	bnez	a4,252 <strlen+0x10>
 25c:	40a6853b          	subw	a0,a3,a0
 260:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 262:	6422                	ld	s0,8(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret
  for(n = 0; s[n]; n++)
 268:	4501                	li	a0,0
 26a:	bfe5                	j	262 <strlen+0x20>

000000000000026c <memset>:

void*
memset(void *dst, int c, uint n)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e422                	sd	s0,8(sp)
 270:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 272:	ca19                	beqz	a2,288 <memset+0x1c>
 274:	87aa                	mv	a5,a0
 276:	1602                	slli	a2,a2,0x20
 278:	9201                	srli	a2,a2,0x20
 27a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 27e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 282:	0785                	addi	a5,a5,1
 284:	fee79de3          	bne	a5,a4,27e <memset+0x12>
  }
  return dst;
}
 288:	6422                	ld	s0,8(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret

000000000000028e <strchr>:

char*
strchr(const char *s, char c)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e422                	sd	s0,8(sp)
 292:	0800                	addi	s0,sp,16
  for(; *s; s++)
 294:	00054783          	lbu	a5,0(a0)
 298:	cb99                	beqz	a5,2ae <strchr+0x20>
    if(*s == c)
 29a:	00f58763          	beq	a1,a5,2a8 <strchr+0x1a>
  for(; *s; s++)
 29e:	0505                	addi	a0,a0,1
 2a0:	00054783          	lbu	a5,0(a0)
 2a4:	fbfd                	bnez	a5,29a <strchr+0xc>
      return (char*)s;
  return 0;
 2a6:	4501                	li	a0,0
}
 2a8:	6422                	ld	s0,8(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret
  return 0;
 2ae:	4501                	li	a0,0
 2b0:	bfe5                	j	2a8 <strchr+0x1a>

00000000000002b2 <gets>:

char*
gets(char *buf, int max)
{
 2b2:	711d                	addi	sp,sp,-96
 2b4:	ec86                	sd	ra,88(sp)
 2b6:	e8a2                	sd	s0,80(sp)
 2b8:	e4a6                	sd	s1,72(sp)
 2ba:	e0ca                	sd	s2,64(sp)
 2bc:	fc4e                	sd	s3,56(sp)
 2be:	f852                	sd	s4,48(sp)
 2c0:	f456                	sd	s5,40(sp)
 2c2:	f05a                	sd	s6,32(sp)
 2c4:	ec5e                	sd	s7,24(sp)
 2c6:	1080                	addi	s0,sp,96
 2c8:	8baa                	mv	s7,a0
 2ca:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2cc:	892a                	mv	s2,a0
 2ce:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2d0:	4aa9                	li	s5,10
 2d2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2d4:	89a6                	mv	s3,s1
 2d6:	2485                	addiw	s1,s1,1
 2d8:	0344d663          	bge	s1,s4,304 <gets+0x52>
    cc = read(0, &c, 1);
 2dc:	4605                	li	a2,1
 2de:	faf40593          	addi	a1,s0,-81
 2e2:	4501                	li	a0,0
 2e4:	1b2000ef          	jal	496 <read>
    if(cc < 1)
 2e8:	00a05e63          	blez	a0,304 <gets+0x52>
    buf[i++] = c;
 2ec:	faf44783          	lbu	a5,-81(s0)
 2f0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2f4:	01578763          	beq	a5,s5,302 <gets+0x50>
 2f8:	0905                	addi	s2,s2,1
 2fa:	fd679de3          	bne	a5,s6,2d4 <gets+0x22>
    buf[i++] = c;
 2fe:	89a6                	mv	s3,s1
 300:	a011                	j	304 <gets+0x52>
 302:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 304:	99de                	add	s3,s3,s7
 306:	00098023          	sb	zero,0(s3)
  return buf;
}
 30a:	855e                	mv	a0,s7
 30c:	60e6                	ld	ra,88(sp)
 30e:	6446                	ld	s0,80(sp)
 310:	64a6                	ld	s1,72(sp)
 312:	6906                	ld	s2,64(sp)
 314:	79e2                	ld	s3,56(sp)
 316:	7a42                	ld	s4,48(sp)
 318:	7aa2                	ld	s5,40(sp)
 31a:	7b02                	ld	s6,32(sp)
 31c:	6be2                	ld	s7,24(sp)
 31e:	6125                	addi	sp,sp,96
 320:	8082                	ret

0000000000000322 <stat>:

int
stat(const char *n, struct stat *st)
{
 322:	1101                	addi	sp,sp,-32
 324:	ec06                	sd	ra,24(sp)
 326:	e822                	sd	s0,16(sp)
 328:	e04a                	sd	s2,0(sp)
 32a:	1000                	addi	s0,sp,32
 32c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 32e:	4581                	li	a1,0
 330:	18e000ef          	jal	4be <open>
  if(fd < 0)
 334:	02054263          	bltz	a0,358 <stat+0x36>
 338:	e426                	sd	s1,8(sp)
 33a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 33c:	85ca                	mv	a1,s2
 33e:	198000ef          	jal	4d6 <fstat>
 342:	892a                	mv	s2,a0
  close(fd);
 344:	8526                	mv	a0,s1
 346:	160000ef          	jal	4a6 <close>
  return r;
 34a:	64a2                	ld	s1,8(sp)
}
 34c:	854a                	mv	a0,s2
 34e:	60e2                	ld	ra,24(sp)
 350:	6442                	ld	s0,16(sp)
 352:	6902                	ld	s2,0(sp)
 354:	6105                	addi	sp,sp,32
 356:	8082                	ret
    return -1;
 358:	597d                	li	s2,-1
 35a:	bfcd                	j	34c <stat+0x2a>

000000000000035c <atoi>:

int
atoi(const char *s)
{
 35c:	1141                	addi	sp,sp,-16
 35e:	e422                	sd	s0,8(sp)
 360:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 362:	00054683          	lbu	a3,0(a0)
 366:	fd06879b          	addiw	a5,a3,-48
 36a:	0ff7f793          	zext.b	a5,a5
 36e:	4625                	li	a2,9
 370:	02f66863          	bltu	a2,a5,3a0 <atoi+0x44>
 374:	872a                	mv	a4,a0
  n = 0;
 376:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 378:	0705                	addi	a4,a4,1
 37a:	0025179b          	slliw	a5,a0,0x2
 37e:	9fa9                	addw	a5,a5,a0
 380:	0017979b          	slliw	a5,a5,0x1
 384:	9fb5                	addw	a5,a5,a3
 386:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 38a:	00074683          	lbu	a3,0(a4)
 38e:	fd06879b          	addiw	a5,a3,-48
 392:	0ff7f793          	zext.b	a5,a5
 396:	fef671e3          	bgeu	a2,a5,378 <atoi+0x1c>
  return n;
}
 39a:	6422                	ld	s0,8(sp)
 39c:	0141                	addi	sp,sp,16
 39e:	8082                	ret
  n = 0;
 3a0:	4501                	li	a0,0
 3a2:	bfe5                	j	39a <atoi+0x3e>

00000000000003a4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3a4:	1141                	addi	sp,sp,-16
 3a6:	e422                	sd	s0,8(sp)
 3a8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3aa:	02b57463          	bgeu	a0,a1,3d2 <memmove+0x2e>
    while(n-- > 0)
 3ae:	00c05f63          	blez	a2,3cc <memmove+0x28>
 3b2:	1602                	slli	a2,a2,0x20
 3b4:	9201                	srli	a2,a2,0x20
 3b6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3ba:	872a                	mv	a4,a0
      *dst++ = *src++;
 3bc:	0585                	addi	a1,a1,1
 3be:	0705                	addi	a4,a4,1
 3c0:	fff5c683          	lbu	a3,-1(a1)
 3c4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3c8:	fef71ae3          	bne	a4,a5,3bc <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3cc:	6422                	ld	s0,8(sp)
 3ce:	0141                	addi	sp,sp,16
 3d0:	8082                	ret
    dst += n;
 3d2:	00c50733          	add	a4,a0,a2
    src += n;
 3d6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3d8:	fec05ae3          	blez	a2,3cc <memmove+0x28>
 3dc:	fff6079b          	addiw	a5,a2,-1
 3e0:	1782                	slli	a5,a5,0x20
 3e2:	9381                	srli	a5,a5,0x20
 3e4:	fff7c793          	not	a5,a5
 3e8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3ea:	15fd                	addi	a1,a1,-1
 3ec:	177d                	addi	a4,a4,-1
 3ee:	0005c683          	lbu	a3,0(a1)
 3f2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3f6:	fee79ae3          	bne	a5,a4,3ea <memmove+0x46>
 3fa:	bfc9                	j	3cc <memmove+0x28>

00000000000003fc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3fc:	1141                	addi	sp,sp,-16
 3fe:	e422                	sd	s0,8(sp)
 400:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 402:	ca05                	beqz	a2,432 <memcmp+0x36>
 404:	fff6069b          	addiw	a3,a2,-1
 408:	1682                	slli	a3,a3,0x20
 40a:	9281                	srli	a3,a3,0x20
 40c:	0685                	addi	a3,a3,1
 40e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 410:	00054783          	lbu	a5,0(a0)
 414:	0005c703          	lbu	a4,0(a1)
 418:	00e79863          	bne	a5,a4,428 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 41c:	0505                	addi	a0,a0,1
    p2++;
 41e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 420:	fed518e3          	bne	a0,a3,410 <memcmp+0x14>
  }
  return 0;
 424:	4501                	li	a0,0
 426:	a019                	j	42c <memcmp+0x30>
      return *p1 - *p2;
 428:	40e7853b          	subw	a0,a5,a4
}
 42c:	6422                	ld	s0,8(sp)
 42e:	0141                	addi	sp,sp,16
 430:	8082                	ret
  return 0;
 432:	4501                	li	a0,0
 434:	bfe5                	j	42c <memcmp+0x30>

0000000000000436 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 436:	1141                	addi	sp,sp,-16
 438:	e406                	sd	ra,8(sp)
 43a:	e022                	sd	s0,0(sp)
 43c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 43e:	f67ff0ef          	jal	3a4 <memmove>
}
 442:	60a2                	ld	ra,8(sp)
 444:	6402                	ld	s0,0(sp)
 446:	0141                	addi	sp,sp,16
 448:	8082                	ret

000000000000044a <sbrk>:

char *
sbrk(int n) {
 44a:	1141                	addi	sp,sp,-16
 44c:	e406                	sd	ra,8(sp)
 44e:	e022                	sd	s0,0(sp)
 450:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 452:	4585                	li	a1,1
 454:	0b2000ef          	jal	506 <sys_sbrk>
}
 458:	60a2                	ld	ra,8(sp)
 45a:	6402                	ld	s0,0(sp)
 45c:	0141                	addi	sp,sp,16
 45e:	8082                	ret

0000000000000460 <sbrklazy>:

char *
sbrklazy(int n) {
 460:	1141                	addi	sp,sp,-16
 462:	e406                	sd	ra,8(sp)
 464:	e022                	sd	s0,0(sp)
 466:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 468:	4589                	li	a1,2
 46a:	09c000ef          	jal	506 <sys_sbrk>
}
 46e:	60a2                	ld	ra,8(sp)
 470:	6402                	ld	s0,0(sp)
 472:	0141                	addi	sp,sp,16
 474:	8082                	ret

0000000000000476 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 476:	4885                	li	a7,1
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <exit>:
.global exit
exit:
 li a7, SYS_exit
 47e:	4889                	li	a7,2
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <wait>:
.global wait
wait:
 li a7, SYS_wait
 486:	488d                	li	a7,3
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 48e:	4891                	li	a7,4
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <read>:
.global read
read:
 li a7, SYS_read
 496:	4895                	li	a7,5
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <write>:
.global write
write:
 li a7, SYS_write
 49e:	48c1                	li	a7,16
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <close>:
.global close
close:
 li a7, SYS_close
 4a6:	48d5                	li	a7,21
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <kill>:
.global kill
kill:
 li a7, SYS_kill
 4ae:	4899                	li	a7,6
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4b6:	489d                	li	a7,7
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <open>:
.global open
open:
 li a7, SYS_open
 4be:	48bd                	li	a7,15
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4c6:	48c5                	li	a7,17
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4ce:	48c9                	li	a7,18
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4d6:	48a1                	li	a7,8
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <link>:
.global link
link:
 li a7, SYS_link
 4de:	48cd                	li	a7,19
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4e6:	48d1                	li	a7,20
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4ee:	48a5                	li	a7,9
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4f6:	48a9                	li	a7,10
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4fe:	48ad                	li	a7,11
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 506:	48b1                	li	a7,12
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <pause>:
.global pause
pause:
 li a7, SYS_pause
 50e:	48b5                	li	a7,13
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 516:	48b9                	li	a7,14
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <msgbox_create>:
.global msgbox_create
msgbox_create:
 li a7, SYS_msgbox_create
 51e:	48d9                	li	a7,22
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <msgbox_send>:
.global msgbox_send
msgbox_send:
 li a7, SYS_msgbox_send
 526:	48dd                	li	a7,23
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <msgbox_recv>:
.global msgbox_recv
msgbox_recv:
 li a7, SYS_msgbox_recv
 52e:	48e1                	li	a7,24
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <msgbox_destroy>:
.global msgbox_destroy
msgbox_destroy:
 li a7, SYS_msgbox_destroy
 536:	48e5                	li	a7,25
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <msgbox_count>:
.global msgbox_count
msgbox_count:
 li a7, SYS_msgbox_count
 53e:	48e9                	li	a7,26
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 546:	1101                	addi	sp,sp,-32
 548:	ec06                	sd	ra,24(sp)
 54a:	e822                	sd	s0,16(sp)
 54c:	1000                	addi	s0,sp,32
 54e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 552:	4605                	li	a2,1
 554:	fef40593          	addi	a1,s0,-17
 558:	f47ff0ef          	jal	49e <write>
}
 55c:	60e2                	ld	ra,24(sp)
 55e:	6442                	ld	s0,16(sp)
 560:	6105                	addi	sp,sp,32
 562:	8082                	ret

0000000000000564 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 564:	715d                	addi	sp,sp,-80
 566:	e486                	sd	ra,72(sp)
 568:	e0a2                	sd	s0,64(sp)
 56a:	f84a                	sd	s2,48(sp)
 56c:	0880                	addi	s0,sp,80
 56e:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 570:	c299                	beqz	a3,576 <printint+0x12>
 572:	0805c363          	bltz	a1,5f8 <printint+0x94>
  neg = 0;
 576:	4881                	li	a7,0
 578:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 57c:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 57e:	00000517          	auipc	a0,0x0
 582:	7ba50513          	addi	a0,a0,1978 # d38 <digits>
 586:	883e                	mv	a6,a5
 588:	2785                	addiw	a5,a5,1
 58a:	02c5f733          	remu	a4,a1,a2
 58e:	972a                	add	a4,a4,a0
 590:	00074703          	lbu	a4,0(a4)
 594:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 598:	872e                	mv	a4,a1
 59a:	02c5d5b3          	divu	a1,a1,a2
 59e:	0685                	addi	a3,a3,1
 5a0:	fec773e3          	bgeu	a4,a2,586 <printint+0x22>
  if(neg)
 5a4:	00088b63          	beqz	a7,5ba <printint+0x56>
    buf[i++] = '-';
 5a8:	fd078793          	addi	a5,a5,-48
 5ac:	97a2                	add	a5,a5,s0
 5ae:	02d00713          	li	a4,45
 5b2:	fee78423          	sb	a4,-24(a5)
 5b6:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 5ba:	02f05a63          	blez	a5,5ee <printint+0x8a>
 5be:	fc26                	sd	s1,56(sp)
 5c0:	f44e                	sd	s3,40(sp)
 5c2:	fb840713          	addi	a4,s0,-72
 5c6:	00f704b3          	add	s1,a4,a5
 5ca:	fff70993          	addi	s3,a4,-1
 5ce:	99be                	add	s3,s3,a5
 5d0:	37fd                	addiw	a5,a5,-1
 5d2:	1782                	slli	a5,a5,0x20
 5d4:	9381                	srli	a5,a5,0x20
 5d6:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 5da:	fff4c583          	lbu	a1,-1(s1)
 5de:	854a                	mv	a0,s2
 5e0:	f67ff0ef          	jal	546 <putc>
  while(--i >= 0)
 5e4:	14fd                	addi	s1,s1,-1
 5e6:	ff349ae3          	bne	s1,s3,5da <printint+0x76>
 5ea:	74e2                	ld	s1,56(sp)
 5ec:	79a2                	ld	s3,40(sp)
}
 5ee:	60a6                	ld	ra,72(sp)
 5f0:	6406                	ld	s0,64(sp)
 5f2:	7942                	ld	s2,48(sp)
 5f4:	6161                	addi	sp,sp,80
 5f6:	8082                	ret
    x = -xx;
 5f8:	40b005b3          	neg	a1,a1
    neg = 1;
 5fc:	4885                	li	a7,1
    x = -xx;
 5fe:	bfad                	j	578 <printint+0x14>

0000000000000600 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 600:	711d                	addi	sp,sp,-96
 602:	ec86                	sd	ra,88(sp)
 604:	e8a2                	sd	s0,80(sp)
 606:	e0ca                	sd	s2,64(sp)
 608:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 60a:	0005c903          	lbu	s2,0(a1)
 60e:	28090663          	beqz	s2,89a <vprintf+0x29a>
 612:	e4a6                	sd	s1,72(sp)
 614:	fc4e                	sd	s3,56(sp)
 616:	f852                	sd	s4,48(sp)
 618:	f456                	sd	s5,40(sp)
 61a:	f05a                	sd	s6,32(sp)
 61c:	ec5e                	sd	s7,24(sp)
 61e:	e862                	sd	s8,16(sp)
 620:	e466                	sd	s9,8(sp)
 622:	8b2a                	mv	s6,a0
 624:	8a2e                	mv	s4,a1
 626:	8bb2                	mv	s7,a2
  state = 0;
 628:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 62a:	4481                	li	s1,0
 62c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 62e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 632:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 636:	06c00c93          	li	s9,108
 63a:	a005                	j	65a <vprintf+0x5a>
        putc(fd, c0);
 63c:	85ca                	mv	a1,s2
 63e:	855a                	mv	a0,s6
 640:	f07ff0ef          	jal	546 <putc>
 644:	a019                	j	64a <vprintf+0x4a>
    } else if(state == '%'){
 646:	03598263          	beq	s3,s5,66a <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 64a:	2485                	addiw	s1,s1,1
 64c:	8726                	mv	a4,s1
 64e:	009a07b3          	add	a5,s4,s1
 652:	0007c903          	lbu	s2,0(a5)
 656:	22090a63          	beqz	s2,88a <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 65a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 65e:	fe0994e3          	bnez	s3,646 <vprintf+0x46>
      if(c0 == '%'){
 662:	fd579de3          	bne	a5,s5,63c <vprintf+0x3c>
        state = '%';
 666:	89be                	mv	s3,a5
 668:	b7cd                	j	64a <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 66a:	00ea06b3          	add	a3,s4,a4
 66e:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 672:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 674:	c681                	beqz	a3,67c <vprintf+0x7c>
 676:	9752                	add	a4,a4,s4
 678:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 67c:	05878363          	beq	a5,s8,6c2 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 680:	05978d63          	beq	a5,s9,6da <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 684:	07500713          	li	a4,117
 688:	0ee78763          	beq	a5,a4,776 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 68c:	07800713          	li	a4,120
 690:	12e78963          	beq	a5,a4,7c2 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 694:	07000713          	li	a4,112
 698:	14e78e63          	beq	a5,a4,7f4 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 69c:	06300713          	li	a4,99
 6a0:	18e78e63          	beq	a5,a4,83c <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 6a4:	07300713          	li	a4,115
 6a8:	1ae78463          	beq	a5,a4,850 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 6ac:	02500713          	li	a4,37
 6b0:	04e79563          	bne	a5,a4,6fa <vprintf+0xfa>
        putc(fd, '%');
 6b4:	02500593          	li	a1,37
 6b8:	855a                	mv	a0,s6
 6ba:	e8dff0ef          	jal	546 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 6be:	4981                	li	s3,0
 6c0:	b769                	j	64a <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 6c2:	008b8913          	addi	s2,s7,8
 6c6:	4685                	li	a3,1
 6c8:	4629                	li	a2,10
 6ca:	000ba583          	lw	a1,0(s7)
 6ce:	855a                	mv	a0,s6
 6d0:	e95ff0ef          	jal	564 <printint>
 6d4:	8bca                	mv	s7,s2
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	bf8d                	j	64a <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 6da:	06400793          	li	a5,100
 6de:	02f68963          	beq	a3,a5,710 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6e2:	06c00793          	li	a5,108
 6e6:	04f68263          	beq	a3,a5,72a <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 6ea:	07500793          	li	a5,117
 6ee:	0af68063          	beq	a3,a5,78e <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 6f2:	07800793          	li	a5,120
 6f6:	0ef68263          	beq	a3,a5,7da <vprintf+0x1da>
        putc(fd, '%');
 6fa:	02500593          	li	a1,37
 6fe:	855a                	mv	a0,s6
 700:	e47ff0ef          	jal	546 <putc>
        putc(fd, c0);
 704:	85ca                	mv	a1,s2
 706:	855a                	mv	a0,s6
 708:	e3fff0ef          	jal	546 <putc>
      state = 0;
 70c:	4981                	li	s3,0
 70e:	bf35                	j	64a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 710:	008b8913          	addi	s2,s7,8
 714:	4685                	li	a3,1
 716:	4629                	li	a2,10
 718:	000bb583          	ld	a1,0(s7)
 71c:	855a                	mv	a0,s6
 71e:	e47ff0ef          	jal	564 <printint>
        i += 1;
 722:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 724:	8bca                	mv	s7,s2
      state = 0;
 726:	4981                	li	s3,0
        i += 1;
 728:	b70d                	j	64a <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 72a:	06400793          	li	a5,100
 72e:	02f60763          	beq	a2,a5,75c <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 732:	07500793          	li	a5,117
 736:	06f60963          	beq	a2,a5,7a8 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 73a:	07800793          	li	a5,120
 73e:	faf61ee3          	bne	a2,a5,6fa <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 742:	008b8913          	addi	s2,s7,8
 746:	4681                	li	a3,0
 748:	4641                	li	a2,16
 74a:	000bb583          	ld	a1,0(s7)
 74e:	855a                	mv	a0,s6
 750:	e15ff0ef          	jal	564 <printint>
        i += 2;
 754:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 756:	8bca                	mv	s7,s2
      state = 0;
 758:	4981                	li	s3,0
        i += 2;
 75a:	bdc5                	j	64a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 75c:	008b8913          	addi	s2,s7,8
 760:	4685                	li	a3,1
 762:	4629                	li	a2,10
 764:	000bb583          	ld	a1,0(s7)
 768:	855a                	mv	a0,s6
 76a:	dfbff0ef          	jal	564 <printint>
        i += 2;
 76e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 770:	8bca                	mv	s7,s2
      state = 0;
 772:	4981                	li	s3,0
        i += 2;
 774:	bdd9                	j	64a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 776:	008b8913          	addi	s2,s7,8
 77a:	4681                	li	a3,0
 77c:	4629                	li	a2,10
 77e:	000be583          	lwu	a1,0(s7)
 782:	855a                	mv	a0,s6
 784:	de1ff0ef          	jal	564 <printint>
 788:	8bca                	mv	s7,s2
      state = 0;
 78a:	4981                	li	s3,0
 78c:	bd7d                	j	64a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 78e:	008b8913          	addi	s2,s7,8
 792:	4681                	li	a3,0
 794:	4629                	li	a2,10
 796:	000bb583          	ld	a1,0(s7)
 79a:	855a                	mv	a0,s6
 79c:	dc9ff0ef          	jal	564 <printint>
        i += 1;
 7a0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7a2:	8bca                	mv	s7,s2
      state = 0;
 7a4:	4981                	li	s3,0
        i += 1;
 7a6:	b555                	j	64a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7a8:	008b8913          	addi	s2,s7,8
 7ac:	4681                	li	a3,0
 7ae:	4629                	li	a2,10
 7b0:	000bb583          	ld	a1,0(s7)
 7b4:	855a                	mv	a0,s6
 7b6:	dafff0ef          	jal	564 <printint>
        i += 2;
 7ba:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7bc:	8bca                	mv	s7,s2
      state = 0;
 7be:	4981                	li	s3,0
        i += 2;
 7c0:	b569                	j	64a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 7c2:	008b8913          	addi	s2,s7,8
 7c6:	4681                	li	a3,0
 7c8:	4641                	li	a2,16
 7ca:	000be583          	lwu	a1,0(s7)
 7ce:	855a                	mv	a0,s6
 7d0:	d95ff0ef          	jal	564 <printint>
 7d4:	8bca                	mv	s7,s2
      state = 0;
 7d6:	4981                	li	s3,0
 7d8:	bd8d                	j	64a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7da:	008b8913          	addi	s2,s7,8
 7de:	4681                	li	a3,0
 7e0:	4641                	li	a2,16
 7e2:	000bb583          	ld	a1,0(s7)
 7e6:	855a                	mv	a0,s6
 7e8:	d7dff0ef          	jal	564 <printint>
        i += 1;
 7ec:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7ee:	8bca                	mv	s7,s2
      state = 0;
 7f0:	4981                	li	s3,0
        i += 1;
 7f2:	bda1                	j	64a <vprintf+0x4a>
 7f4:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 7f6:	008b8d13          	addi	s10,s7,8
 7fa:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7fe:	03000593          	li	a1,48
 802:	855a                	mv	a0,s6
 804:	d43ff0ef          	jal	546 <putc>
  putc(fd, 'x');
 808:	07800593          	li	a1,120
 80c:	855a                	mv	a0,s6
 80e:	d39ff0ef          	jal	546 <putc>
 812:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 814:	00000b97          	auipc	s7,0x0
 818:	524b8b93          	addi	s7,s7,1316 # d38 <digits>
 81c:	03c9d793          	srli	a5,s3,0x3c
 820:	97de                	add	a5,a5,s7
 822:	0007c583          	lbu	a1,0(a5)
 826:	855a                	mv	a0,s6
 828:	d1fff0ef          	jal	546 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 82c:	0992                	slli	s3,s3,0x4
 82e:	397d                	addiw	s2,s2,-1
 830:	fe0916e3          	bnez	s2,81c <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 834:	8bea                	mv	s7,s10
      state = 0;
 836:	4981                	li	s3,0
 838:	6d02                	ld	s10,0(sp)
 83a:	bd01                	j	64a <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 83c:	008b8913          	addi	s2,s7,8
 840:	000bc583          	lbu	a1,0(s7)
 844:	855a                	mv	a0,s6
 846:	d01ff0ef          	jal	546 <putc>
 84a:	8bca                	mv	s7,s2
      state = 0;
 84c:	4981                	li	s3,0
 84e:	bbf5                	j	64a <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 850:	008b8993          	addi	s3,s7,8
 854:	000bb903          	ld	s2,0(s7)
 858:	00090f63          	beqz	s2,876 <vprintf+0x276>
        for(; *s; s++)
 85c:	00094583          	lbu	a1,0(s2)
 860:	c195                	beqz	a1,884 <vprintf+0x284>
          putc(fd, *s);
 862:	855a                	mv	a0,s6
 864:	ce3ff0ef          	jal	546 <putc>
        for(; *s; s++)
 868:	0905                	addi	s2,s2,1
 86a:	00094583          	lbu	a1,0(s2)
 86e:	f9f5                	bnez	a1,862 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 870:	8bce                	mv	s7,s3
      state = 0;
 872:	4981                	li	s3,0
 874:	bbd9                	j	64a <vprintf+0x4a>
          s = "(null)";
 876:	00000917          	auipc	s2,0x0
 87a:	4ba90913          	addi	s2,s2,1210 # d30 <malloc+0x3ae>
        for(; *s; s++)
 87e:	02800593          	li	a1,40
 882:	b7c5                	j	862 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 884:	8bce                	mv	s7,s3
      state = 0;
 886:	4981                	li	s3,0
 888:	b3c9                	j	64a <vprintf+0x4a>
 88a:	64a6                	ld	s1,72(sp)
 88c:	79e2                	ld	s3,56(sp)
 88e:	7a42                	ld	s4,48(sp)
 890:	7aa2                	ld	s5,40(sp)
 892:	7b02                	ld	s6,32(sp)
 894:	6be2                	ld	s7,24(sp)
 896:	6c42                	ld	s8,16(sp)
 898:	6ca2                	ld	s9,8(sp)
    }
  }
}
 89a:	60e6                	ld	ra,88(sp)
 89c:	6446                	ld	s0,80(sp)
 89e:	6906                	ld	s2,64(sp)
 8a0:	6125                	addi	sp,sp,96
 8a2:	8082                	ret

00000000000008a4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8a4:	715d                	addi	sp,sp,-80
 8a6:	ec06                	sd	ra,24(sp)
 8a8:	e822                	sd	s0,16(sp)
 8aa:	1000                	addi	s0,sp,32
 8ac:	e010                	sd	a2,0(s0)
 8ae:	e414                	sd	a3,8(s0)
 8b0:	e818                	sd	a4,16(s0)
 8b2:	ec1c                	sd	a5,24(s0)
 8b4:	03043023          	sd	a6,32(s0)
 8b8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8bc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8c0:	8622                	mv	a2,s0
 8c2:	d3fff0ef          	jal	600 <vprintf>
}
 8c6:	60e2                	ld	ra,24(sp)
 8c8:	6442                	ld	s0,16(sp)
 8ca:	6161                	addi	sp,sp,80
 8cc:	8082                	ret

00000000000008ce <printf>:

void
printf(const char *fmt, ...)
{
 8ce:	711d                	addi	sp,sp,-96
 8d0:	ec06                	sd	ra,24(sp)
 8d2:	e822                	sd	s0,16(sp)
 8d4:	1000                	addi	s0,sp,32
 8d6:	e40c                	sd	a1,8(s0)
 8d8:	e810                	sd	a2,16(s0)
 8da:	ec14                	sd	a3,24(s0)
 8dc:	f018                	sd	a4,32(s0)
 8de:	f41c                	sd	a5,40(s0)
 8e0:	03043823          	sd	a6,48(s0)
 8e4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8e8:	00840613          	addi	a2,s0,8
 8ec:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8f0:	85aa                	mv	a1,a0
 8f2:	4505                	li	a0,1
 8f4:	d0dff0ef          	jal	600 <vprintf>
}
 8f8:	60e2                	ld	ra,24(sp)
 8fa:	6442                	ld	s0,16(sp)
 8fc:	6125                	addi	sp,sp,96
 8fe:	8082                	ret

0000000000000900 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 900:	1141                	addi	sp,sp,-16
 902:	e422                	sd	s0,8(sp)
 904:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 906:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 90a:	00001797          	auipc	a5,0x1
 90e:	6f67b783          	ld	a5,1782(a5) # 2000 <freep>
 912:	a02d                	j	93c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 914:	4618                	lw	a4,8(a2)
 916:	9f2d                	addw	a4,a4,a1
 918:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 91c:	6398                	ld	a4,0(a5)
 91e:	6310                	ld	a2,0(a4)
 920:	a83d                	j	95e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 922:	ff852703          	lw	a4,-8(a0)
 926:	9f31                	addw	a4,a4,a2
 928:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 92a:	ff053683          	ld	a3,-16(a0)
 92e:	a091                	j	972 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 930:	6398                	ld	a4,0(a5)
 932:	00e7e463          	bltu	a5,a4,93a <free+0x3a>
 936:	00e6ea63          	bltu	a3,a4,94a <free+0x4a>
{
 93a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 93c:	fed7fae3          	bgeu	a5,a3,930 <free+0x30>
 940:	6398                	ld	a4,0(a5)
 942:	00e6e463          	bltu	a3,a4,94a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 946:	fee7eae3          	bltu	a5,a4,93a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 94a:	ff852583          	lw	a1,-8(a0)
 94e:	6390                	ld	a2,0(a5)
 950:	02059813          	slli	a6,a1,0x20
 954:	01c85713          	srli	a4,a6,0x1c
 958:	9736                	add	a4,a4,a3
 95a:	fae60de3          	beq	a2,a4,914 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 95e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 962:	4790                	lw	a2,8(a5)
 964:	02061593          	slli	a1,a2,0x20
 968:	01c5d713          	srli	a4,a1,0x1c
 96c:	973e                	add	a4,a4,a5
 96e:	fae68ae3          	beq	a3,a4,922 <free+0x22>
    p->s.ptr = bp->s.ptr;
 972:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 974:	00001717          	auipc	a4,0x1
 978:	68f73623          	sd	a5,1676(a4) # 2000 <freep>
}
 97c:	6422                	ld	s0,8(sp)
 97e:	0141                	addi	sp,sp,16
 980:	8082                	ret

0000000000000982 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 982:	7139                	addi	sp,sp,-64
 984:	fc06                	sd	ra,56(sp)
 986:	f822                	sd	s0,48(sp)
 988:	f426                	sd	s1,40(sp)
 98a:	ec4e                	sd	s3,24(sp)
 98c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 98e:	02051493          	slli	s1,a0,0x20
 992:	9081                	srli	s1,s1,0x20
 994:	04bd                	addi	s1,s1,15
 996:	8091                	srli	s1,s1,0x4
 998:	0014899b          	addiw	s3,s1,1
 99c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 99e:	00001517          	auipc	a0,0x1
 9a2:	66253503          	ld	a0,1634(a0) # 2000 <freep>
 9a6:	c915                	beqz	a0,9da <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9aa:	4798                	lw	a4,8(a5)
 9ac:	08977a63          	bgeu	a4,s1,a40 <malloc+0xbe>
 9b0:	f04a                	sd	s2,32(sp)
 9b2:	e852                	sd	s4,16(sp)
 9b4:	e456                	sd	s5,8(sp)
 9b6:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9b8:	8a4e                	mv	s4,s3
 9ba:	0009871b          	sext.w	a4,s3
 9be:	6685                	lui	a3,0x1
 9c0:	00d77363          	bgeu	a4,a3,9c6 <malloc+0x44>
 9c4:	6a05                	lui	s4,0x1
 9c6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9ca:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9ce:	00001917          	auipc	s2,0x1
 9d2:	63290913          	addi	s2,s2,1586 # 2000 <freep>
  if(p == SBRK_ERROR)
 9d6:	5afd                	li	s5,-1
 9d8:	a081                	j	a18 <malloc+0x96>
 9da:	f04a                	sd	s2,32(sp)
 9dc:	e852                	sd	s4,16(sp)
 9de:	e456                	sd	s5,8(sp)
 9e0:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9e2:	00001797          	auipc	a5,0x1
 9e6:	62e78793          	addi	a5,a5,1582 # 2010 <base>
 9ea:	00001717          	auipc	a4,0x1
 9ee:	60f73b23          	sd	a5,1558(a4) # 2000 <freep>
 9f2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9f4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9f8:	b7c1                	j	9b8 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 9fa:	6398                	ld	a4,0(a5)
 9fc:	e118                	sd	a4,0(a0)
 9fe:	a8a9                	j	a58 <malloc+0xd6>
  hp->s.size = nu;
 a00:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a04:	0541                	addi	a0,a0,16
 a06:	efbff0ef          	jal	900 <free>
  return freep;
 a0a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a0e:	c12d                	beqz	a0,a70 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a10:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a12:	4798                	lw	a4,8(a5)
 a14:	02977263          	bgeu	a4,s1,a38 <malloc+0xb6>
    if(p == freep)
 a18:	00093703          	ld	a4,0(s2)
 a1c:	853e                	mv	a0,a5
 a1e:	fef719e3          	bne	a4,a5,a10 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a22:	8552                	mv	a0,s4
 a24:	a27ff0ef          	jal	44a <sbrk>
  if(p == SBRK_ERROR)
 a28:	fd551ce3          	bne	a0,s5,a00 <malloc+0x7e>
        return 0;
 a2c:	4501                	li	a0,0
 a2e:	7902                	ld	s2,32(sp)
 a30:	6a42                	ld	s4,16(sp)
 a32:	6aa2                	ld	s5,8(sp)
 a34:	6b02                	ld	s6,0(sp)
 a36:	a03d                	j	a64 <malloc+0xe2>
 a38:	7902                	ld	s2,32(sp)
 a3a:	6a42                	ld	s4,16(sp)
 a3c:	6aa2                	ld	s5,8(sp)
 a3e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a40:	fae48de3          	beq	s1,a4,9fa <malloc+0x78>
        p->s.size -= nunits;
 a44:	4137073b          	subw	a4,a4,s3
 a48:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a4a:	02071693          	slli	a3,a4,0x20
 a4e:	01c6d713          	srli	a4,a3,0x1c
 a52:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a54:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a58:	00001717          	auipc	a4,0x1
 a5c:	5aa73423          	sd	a0,1448(a4) # 2000 <freep>
      return (void*)(p + 1);
 a60:	01078513          	addi	a0,a5,16
  }
}
 a64:	70e2                	ld	ra,56(sp)
 a66:	7442                	ld	s0,48(sp)
 a68:	74a2                	ld	s1,40(sp)
 a6a:	69e2                	ld	s3,24(sp)
 a6c:	6121                	addi	sp,sp,64
 a6e:	8082                	ret
 a70:	7902                	ld	s2,32(sp)
 a72:	6a42                	ld	s4,16(sp)
 a74:	6aa2                	ld	s5,8(sp)
 a76:	6b02                	ld	s6,0(sp)
 a78:	b7f5                	j	a64 <malloc+0xe2>
