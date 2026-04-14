
user/_demo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <strtonum>:
}

// ── Convert string to integer ────────────────────────────────
static int
strtonum(char *s)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
   6:	86aa                	mv	a3,a0
  int n = 0;
  int neg = 0;
  if(*s == '-'){ neg = 1; s++; }
   8:	00054703          	lbu	a4,0(a0)
   c:	02d00793          	li	a5,45
  int neg = 0;
  10:	4581                	li	a1,0
  if(*s == '-'){ neg = 1; s++; }
  12:	04f70563          	beq	a4,a5,5c <strtonum+0x5c>
  while(*s >= '0' && *s <= '9'){
  16:	0006c703          	lbu	a4,0(a3)
  1a:	fd07079b          	addiw	a5,a4,-48
  1e:	0ff7f793          	zext.b	a5,a5
  22:	4825                	li	a6,9
  24:	4501                	li	a0,0
  26:	4625                	li	a2,9
  28:	02f86463          	bltu	a6,a5,50 <strtonum+0x50>
    n = n * 10 + (*s - '0');
  2c:	0025179b          	slliw	a5,a0,0x2
  30:	9fa9                	addw	a5,a5,a0
  32:	0017979b          	slliw	a5,a5,0x1
  36:	fd07071b          	addiw	a4,a4,-48
  3a:	00f7053b          	addw	a0,a4,a5
    s++;
  3e:	0685                	addi	a3,a3,1
  while(*s >= '0' && *s <= '9'){
  40:	0006c703          	lbu	a4,0(a3)
  44:	fd07079b          	addiw	a5,a4,-48
  48:	0ff7f793          	zext.b	a5,a5
  4c:	fef670e3          	bgeu	a2,a5,2c <strtonum+0x2c>
  }
  return neg ? -n : n;
  50:	c199                	beqz	a1,56 <strtonum+0x56>
  52:	40a0053b          	negw	a0,a0
}
  56:	6422                	ld	s0,8(sp)
  58:	0141                	addi	sp,sp,16
  5a:	8082                	ret
  if(*s == '-'){ neg = 1; s++; }
  5c:	00150693          	addi	a3,a0,1
  60:	4585                	li	a1,1
  62:	bf55                	j	16 <strtonum+0x16>

0000000000000064 <readline>:
{
  64:	715d                	addi	sp,sp,-80
  66:	e486                	sd	ra,72(sp)
  68:	e0a2                	sd	s0,64(sp)
  6a:	fc26                	sd	s1,56(sp)
  6c:	e85a                	sd	s6,16(sp)
  6e:	0880                	addi	s0,sp,80
  70:	8b2a                	mv	s6,a0
  while(i < max - 1){
  72:	4785                	li	a5,1
  74:	04b7d663          	bge	a5,a1,c0 <readline+0x5c>
  78:	f84a                	sd	s2,48(sp)
  7a:	f44e                	sd	s3,40(sp)
  7c:	f052                	sd	s4,32(sp)
  7e:	ec56                	sd	s5,24(sp)
  80:	892a                	mv	s2,a0
  82:	fff5899b          	addiw	s3,a1,-1
  int i = 0;
  86:	4481                	li	s1,0
    if(c == '\n' || c == '\r') break;
  88:	4a29                	li	s4,10
  8a:	4ab5                	li	s5,13
    int n = read(0, &c, 1);  // read one character from stdin
  8c:	4605                	li	a2,1
  8e:	fbf40593          	addi	a1,s0,-65
  92:	4501                	li	a0,0
  94:	550000ef          	jal	5e4 <read>
    if(n <= 0) break;
  98:	02a05663          	blez	a0,c4 <readline+0x60>
    if(c == '\n' || c == '\r') break;
  9c:	fbf44783          	lbu	a5,-65(s0)
  a0:	05478063          	beq	a5,s4,e0 <readline+0x7c>
  a4:	05578363          	beq	a5,s5,ea <readline+0x86>
    buf[i++] = c;
  a8:	2485                	addiw	s1,s1,1
  aa:	00f90023          	sb	a5,0(s2)
  while(i < max - 1){
  ae:	0905                	addi	s2,s2,1
  b0:	fd349ee3          	bne	s1,s3,8c <readline+0x28>
  b4:	84ce                	mv	s1,s3
  b6:	7942                	ld	s2,48(sp)
  b8:	79a2                	ld	s3,40(sp)
  ba:	7a02                	ld	s4,32(sp)
  bc:	6ae2                	ld	s5,24(sp)
  be:	a039                	j	cc <readline+0x68>
  int i = 0;
  c0:	4481                	li	s1,0
  c2:	a029                	j	cc <readline+0x68>
  c4:	7942                	ld	s2,48(sp)
  c6:	79a2                	ld	s3,40(sp)
  c8:	7a02                	ld	s4,32(sp)
  ca:	6ae2                	ld	s5,24(sp)
  buf[i] = '\0';
  cc:	9b26                	add	s6,s6,s1
  ce:	000b0023          	sb	zero,0(s6)
}
  d2:	8526                	mv	a0,s1
  d4:	60a6                	ld	ra,72(sp)
  d6:	6406                	ld	s0,64(sp)
  d8:	74e2                	ld	s1,56(sp)
  da:	6b42                	ld	s6,16(sp)
  dc:	6161                	addi	sp,sp,80
  de:	8082                	ret
  e0:	7942                	ld	s2,48(sp)
  e2:	79a2                	ld	s3,40(sp)
  e4:	7a02                	ld	s4,32(sp)
  e6:	6ae2                	ld	s5,24(sp)
  e8:	b7d5                	j	cc <readline+0x68>
  ea:	7942                	ld	s2,48(sp)
  ec:	79a2                	ld	s3,40(sp)
  ee:	7a02                	ld	s4,32(sp)
  f0:	6ae2                	ld	s5,24(sp)
  f2:	bfe9                	j	cc <readline+0x68>

00000000000000f4 <printint>:
{
  f4:	1101                	addi	sp,sp,-32
  f6:	ec06                	sd	ra,24(sp)
  f8:	e822                	sd	s0,16(sp)
  fa:	1000                	addi	s0,sp,32
  buf[i] = '\0';
  fc:	fe0407a3          	sb	zero,-17(s0)
  if(n == 0){ buf[--i] = '0'; }
 100:	e519                	bnez	a0,10e <printint+0x1a>
 102:	03000793          	li	a5,48
 106:	fef40723          	sb	a5,-18(s0)
 10a:	45b9                	li	a1,14
 10c:	a805                	j	13c <printint+0x48>
  while(n > 0){ buf[--i] = '0' + (n % 10); n /= 10; }
 10e:	04a05363          	blez	a0,154 <printint+0x60>
 112:	fe040813          	addi	a6,s0,-32
 116:	87c2                	mv	a5,a6
 118:	46a9                	li	a3,10
 11a:	4625                	li	a2,9
 11c:	02d5673b          	remw	a4,a0,a3
 120:	0307071b          	addiw	a4,a4,48
 124:	00e78723          	sb	a4,14(a5)
 128:	872a                	mv	a4,a0
 12a:	02d5453b          	divw	a0,a0,a3
 12e:	85be                	mv	a1,a5
 130:	17fd                	addi	a5,a5,-1
 132:	fee645e3          	blt	a2,a4,11c <printint+0x28>
 136:	410585bb          	subw	a1,a1,a6
 13a:	25b9                	addiw	a1,a1,14
  write(1, buf+i, 15-i);
 13c:	463d                	li	a2,15
 13e:	9e0d                	subw	a2,a2,a1
 140:	fe040793          	addi	a5,s0,-32
 144:	95be                	add	a1,a1,a5
 146:	4505                	li	a0,1
 148:	4a4000ef          	jal	5ec <write>
}
 14c:	60e2                	ld	ra,24(sp)
 14e:	6442                	ld	s0,16(sp)
 150:	6105                	addi	sp,sp,32
 152:	8082                	ret
  while(n > 0){ buf[--i] = '0' + (n % 10); n /= 10; }
 154:	45bd                	li	a1,15
 156:	b7dd                	j	13c <printint+0x48>

0000000000000158 <printstr>:
{
 158:	1101                	addi	sp,sp,-32
 15a:	ec06                	sd	ra,24(sp)
 15c:	e822                	sd	s0,16(sp)
 15e:	e426                	sd	s1,8(sp)
 160:	1000                	addi	s0,sp,32
 162:	84aa                	mv	s1,a0
  write(1, s, strlen(s));
 164:	22c000ef          	jal	390 <strlen>
 168:	0005061b          	sext.w	a2,a0
 16c:	85a6                	mv	a1,s1
 16e:	4505                	li	a0,1
 170:	47c000ef          	jal	5ec <write>
}
 174:	60e2                	ld	ra,24(sp)
 176:	6442                	ld	s0,16(sp)
 178:	64a2                	ld	s1,8(sp)
 17a:	6105                	addi	sp,sp,32
 17c:	8082                	ret

000000000000017e <main>:
  printstr("Enter choice: ");
}

int
main(void)
{
 17e:	7159                	addi	sp,sp,-112
 180:	f486                	sd	ra,104(sp)
 182:	f0a2                	sd	s0,96(sp)
 184:	eca6                	sd	s1,88(sp)
 186:	e8ca                	sd	s2,80(sp)
 188:	e4ce                	sd	s3,72(sp)
 18a:	e0d2                	sd	s4,64(sp)
 18c:	fc56                	sd	s5,56(sp)
 18e:	f85a                	sd	s6,48(sp)
 190:	1880                	addi	s0,sp,112
  char buf[32];
  int choice;

  printstr("\n");
 192:	00001517          	auipc	a0,0x1
 196:	a4e50513          	addi	a0,a0,-1458 # be0 <malloc+0x100>
 19a:	fbfff0ef          	jal	158 <printstr>
  printstr("  1. getprocinfo  - Get PID and Priority\n");
 19e:	00001a97          	auipc	s5,0x1
 1a2:	a4aa8a93          	addi	s5,s5,-1462 # be8 <malloc+0x108>
  printstr("  2. setpriority  - Set Priority\n");
 1a6:	00001a17          	auipc	s4,0x1
 1aa:	a72a0a13          	addi	s4,s4,-1422 # c18 <malloc+0x138>
  printstr("  3. Exit\n");
 1ae:	00001997          	auipc	s3,0x1
 1b2:	a9298993          	addi	s3,s3,-1390 # c40 <malloc+0x160>
  printstr("Enter choice: ");
 1b6:	00001917          	auipc	s2,0x1
 1ba:	a9a90913          	addi	s2,s2,-1382 # c50 <malloc+0x170>
    print_menu();
    readline(buf, sizeof(buf));
    choice = strtonum(buf);

    // ── OPTION 1: getprocinfo ──────────────────────────────
    if(choice == 1){
 1be:	4485                	li	s1,1
 1c0:	a095                	j	224 <main+0xa6>
      printstr("\n--- getprocinfo ---\n");
 1c2:	00001517          	auipc	a0,0x1
 1c6:	a9e50513          	addi	a0,a0,-1378 # c60 <malloc+0x180>
 1ca:	f8fff0ef          	jal	158 <printstr>

      int my_pid = 0, my_prio = 0;
 1ce:	f8042c23          	sw	zero,-104(s0)
 1d2:	f8042e23          	sw	zero,-100(s0)

      if(getprocinfo(&my_pid, &my_prio) == 0){
 1d6:	f9c40593          	addi	a1,s0,-100
 1da:	f9840513          	addi	a0,s0,-104
 1de:	48e000ef          	jal	66c <getprocinfo>
 1e2:	e551                	bnez	a0,26e <main+0xf0>
        printstr("  Current PID      = ");
 1e4:	00001517          	auipc	a0,0x1
 1e8:	a9450513          	addi	a0,a0,-1388 # c78 <malloc+0x198>
 1ec:	f6dff0ef          	jal	158 <printstr>
        printint(my_pid);
 1f0:	f9842503          	lw	a0,-104(s0)
 1f4:	f01ff0ef          	jal	f4 <printint>
        printstr("\n");
 1f8:	00001517          	auipc	a0,0x1
 1fc:	9e850513          	addi	a0,a0,-1560 # be0 <malloc+0x100>
 200:	f59ff0ef          	jal	158 <printstr>
        printstr("  Current Priority = ");
 204:	00001517          	auipc	a0,0x1
 208:	a8c50513          	addi	a0,a0,-1396 # c90 <malloc+0x1b0>
 20c:	f4dff0ef          	jal	158 <printstr>
        printint(my_prio);
 210:	f9c42503          	lw	a0,-100(s0)
 214:	ee1ff0ef          	jal	f4 <printint>
        printstr("\n");
 218:	00001517          	auipc	a0,0x1
 21c:	9c850513          	addi	a0,a0,-1592 # be0 <malloc+0x100>
 220:	f39ff0ef          	jal	158 <printstr>
  printstr("  1. getprocinfo  - Get PID and Priority\n");
 224:	8556                	mv	a0,s5
 226:	f33ff0ef          	jal	158 <printstr>
  printstr("  2. setpriority  - Set Priority\n");
 22a:	8552                	mv	a0,s4
 22c:	f2dff0ef          	jal	158 <printstr>
  printstr("  3. Exit\n");
 230:	854e                	mv	a0,s3
 232:	f27ff0ef          	jal	158 <printstr>
  printstr("Enter choice: ");
 236:	854a                	mv	a0,s2
 238:	f21ff0ef          	jal	158 <printstr>
    readline(buf, sizeof(buf));
 23c:	02000593          	li	a1,32
 240:	fa040513          	addi	a0,s0,-96
 244:	e21ff0ef          	jal	64 <readline>
    choice = strtonum(buf);
 248:	fa040513          	addi	a0,s0,-96
 24c:	db5ff0ef          	jal	0 <strtonum>
    if(choice == 1){
 250:	f69509e3          	beq	a0,s1,1c2 <main+0x44>
      } else {
        printstr("  ERROR: getprocinfo failed\n");
      }

    // ── OPTION 2: setpriority ──────────────────────────────
    } else if(choice == 2){
 254:	4789                	li	a5,2
 256:	02f50363          	beq	a0,a5,27c <main+0xfe>
        printint(prio);
        printstr(" is invalid. Must be between 0 and 19.\n");
      }

    // ── OPTION 3: Exit ────────────────────────────────────
    } else if(choice == 3){
 25a:	478d                	li	a5,3
 25c:	0cf50563          	beq	a0,a5,326 <main+0x1a8>
      printstr("\n  Exiting demo. Goodbye!\n\n");
      exit(0);

    // ── Invalid choice ────────────────────────────────────
    } else {
      printstr("\n  Invalid choice. Please enter 1, 2 or 3.\n");
 260:	00001517          	auipc	a0,0x1
 264:	b5050513          	addi	a0,a0,-1200 # db0 <malloc+0x2d0>
 268:	ef1ff0ef          	jal	158 <printstr>
 26c:	bf65                	j	224 <main+0xa6>
        printstr("  ERROR: getprocinfo failed\n");
 26e:	00001517          	auipc	a0,0x1
 272:	a3a50513          	addi	a0,a0,-1478 # ca8 <malloc+0x1c8>
 276:	ee3ff0ef          	jal	158 <printstr>
 27a:	b76d                	j	224 <main+0xa6>
      printstr("\n--- setpriority ---\n");
 27c:	00001517          	auipc	a0,0x1
 280:	a4c50513          	addi	a0,a0,-1460 # cc8 <malloc+0x1e8>
 284:	ed5ff0ef          	jal	158 <printstr>
      printstr("  Enter priority (0 = lowest, 19 = highest): ");
 288:	00001517          	auipc	a0,0x1
 28c:	a5850513          	addi	a0,a0,-1448 # ce0 <malloc+0x200>
 290:	ec9ff0ef          	jal	158 <printstr>
      readline(buf, sizeof(buf));
 294:	02000593          	li	a1,32
 298:	fa040513          	addi	a0,s0,-96
 29c:	dc9ff0ef          	jal	64 <readline>
      int prio = strtonum(buf);
 2a0:	fa040513          	addi	a0,s0,-96
 2a4:	d5dff0ef          	jal	0 <strtonum>
 2a8:	8b2a                	mv	s6,a0
      printstr("  Trying to set priority to ");
 2aa:	00001517          	auipc	a0,0x1
 2ae:	a6650513          	addi	a0,a0,-1434 # d10 <malloc+0x230>
 2b2:	ea7ff0ef          	jal	158 <printstr>
      printint(prio);
 2b6:	855a                	mv	a0,s6
 2b8:	e3dff0ef          	jal	f4 <printint>
      printstr("...\n");
 2bc:	00001517          	auipc	a0,0x1
 2c0:	a7450513          	addi	a0,a0,-1420 # d30 <malloc+0x250>
 2c4:	e95ff0ef          	jal	158 <printstr>
      if(setpriority(prio) == 0){
 2c8:	855a                	mv	a0,s6
 2ca:	3aa000ef          	jal	674 <setpriority>
 2ce:	ed05                	bnez	a0,306 <main+0x188>
        int my_pid = 0, my_prio = 0;
 2d0:	f8042c23          	sw	zero,-104(s0)
 2d4:	f8042e23          	sw	zero,-100(s0)
        getprocinfo(&my_pid, &my_prio);
 2d8:	f9c40593          	addi	a1,s0,-100
 2dc:	f9840513          	addi	a0,s0,-104
 2e0:	38c000ef          	jal	66c <getprocinfo>
        printstr("  Success! Priority is now = ");
 2e4:	00001517          	auipc	a0,0x1
 2e8:	a5450513          	addi	a0,a0,-1452 # d38 <malloc+0x258>
 2ec:	e6dff0ef          	jal	158 <printstr>
        printint(my_prio);
 2f0:	f9c42503          	lw	a0,-100(s0)
 2f4:	e01ff0ef          	jal	f4 <printint>
        printstr("\n");
 2f8:	00001517          	auipc	a0,0x1
 2fc:	8e850513          	addi	a0,a0,-1816 # be0 <malloc+0x100>
 300:	e59ff0ef          	jal	158 <printstr>
 304:	b705                	j	224 <main+0xa6>
        printstr("  ERROR: ");
 306:	00001517          	auipc	a0,0x1
 30a:	a5250513          	addi	a0,a0,-1454 # d58 <malloc+0x278>
 30e:	e4bff0ef          	jal	158 <printstr>
        printint(prio);
 312:	855a                	mv	a0,s6
 314:	de1ff0ef          	jal	f4 <printint>
        printstr(" is invalid. Must be between 0 and 19.\n");
 318:	00001517          	auipc	a0,0x1
 31c:	a5050513          	addi	a0,a0,-1456 # d68 <malloc+0x288>
 320:	e39ff0ef          	jal	158 <printstr>
 324:	b701                	j	224 <main+0xa6>
      printstr("\n  Exiting demo. Goodbye!\n\n");
 326:	00001517          	auipc	a0,0x1
 32a:	a6a50513          	addi	a0,a0,-1430 # d90 <malloc+0x2b0>
 32e:	e2bff0ef          	jal	158 <printstr>
      exit(0);
 332:	4501                	li	a0,0
 334:	298000ef          	jal	5cc <exit>

0000000000000338 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 338:	1141                	addi	sp,sp,-16
 33a:	e406                	sd	ra,8(sp)
 33c:	e022                	sd	s0,0(sp)
 33e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 340:	e3fff0ef          	jal	17e <main>
  exit(r);
 344:	288000ef          	jal	5cc <exit>

0000000000000348 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 348:	1141                	addi	sp,sp,-16
 34a:	e422                	sd	s0,8(sp)
 34c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 34e:	87aa                	mv	a5,a0
 350:	0585                	addi	a1,a1,1
 352:	0785                	addi	a5,a5,1
 354:	fff5c703          	lbu	a4,-1(a1)
 358:	fee78fa3          	sb	a4,-1(a5)
 35c:	fb75                	bnez	a4,350 <strcpy+0x8>
    ;
  return os;
}
 35e:	6422                	ld	s0,8(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret

0000000000000364 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 364:	1141                	addi	sp,sp,-16
 366:	e422                	sd	s0,8(sp)
 368:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 36a:	00054783          	lbu	a5,0(a0)
 36e:	cb91                	beqz	a5,382 <strcmp+0x1e>
 370:	0005c703          	lbu	a4,0(a1)
 374:	00f71763          	bne	a4,a5,382 <strcmp+0x1e>
    p++, q++;
 378:	0505                	addi	a0,a0,1
 37a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 37c:	00054783          	lbu	a5,0(a0)
 380:	fbe5                	bnez	a5,370 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 382:	0005c503          	lbu	a0,0(a1)
}
 386:	40a7853b          	subw	a0,a5,a0
 38a:	6422                	ld	s0,8(sp)
 38c:	0141                	addi	sp,sp,16
 38e:	8082                	ret

0000000000000390 <strlen>:

uint
strlen(const char *s)
{
 390:	1141                	addi	sp,sp,-16
 392:	e422                	sd	s0,8(sp)
 394:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 396:	00054783          	lbu	a5,0(a0)
 39a:	cf91                	beqz	a5,3b6 <strlen+0x26>
 39c:	0505                	addi	a0,a0,1
 39e:	87aa                	mv	a5,a0
 3a0:	86be                	mv	a3,a5
 3a2:	0785                	addi	a5,a5,1
 3a4:	fff7c703          	lbu	a4,-1(a5)
 3a8:	ff65                	bnez	a4,3a0 <strlen+0x10>
 3aa:	40a6853b          	subw	a0,a3,a0
 3ae:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 3b0:	6422                	ld	s0,8(sp)
 3b2:	0141                	addi	sp,sp,16
 3b4:	8082                	ret
  for(n = 0; s[n]; n++)
 3b6:	4501                	li	a0,0
 3b8:	bfe5                	j	3b0 <strlen+0x20>

00000000000003ba <memset>:

void*
memset(void *dst, int c, uint n)
{
 3ba:	1141                	addi	sp,sp,-16
 3bc:	e422                	sd	s0,8(sp)
 3be:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3c0:	ca19                	beqz	a2,3d6 <memset+0x1c>
 3c2:	87aa                	mv	a5,a0
 3c4:	1602                	slli	a2,a2,0x20
 3c6:	9201                	srli	a2,a2,0x20
 3c8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 3cc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3d0:	0785                	addi	a5,a5,1
 3d2:	fee79de3          	bne	a5,a4,3cc <memset+0x12>
  }
  return dst;
}
 3d6:	6422                	ld	s0,8(sp)
 3d8:	0141                	addi	sp,sp,16
 3da:	8082                	ret

00000000000003dc <strchr>:

char*
strchr(const char *s, char c)
{
 3dc:	1141                	addi	sp,sp,-16
 3de:	e422                	sd	s0,8(sp)
 3e0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3e2:	00054783          	lbu	a5,0(a0)
 3e6:	cb99                	beqz	a5,3fc <strchr+0x20>
    if(*s == c)
 3e8:	00f58763          	beq	a1,a5,3f6 <strchr+0x1a>
  for(; *s; s++)
 3ec:	0505                	addi	a0,a0,1
 3ee:	00054783          	lbu	a5,0(a0)
 3f2:	fbfd                	bnez	a5,3e8 <strchr+0xc>
      return (char*)s;
  return 0;
 3f4:	4501                	li	a0,0
}
 3f6:	6422                	ld	s0,8(sp)
 3f8:	0141                	addi	sp,sp,16
 3fa:	8082                	ret
  return 0;
 3fc:	4501                	li	a0,0
 3fe:	bfe5                	j	3f6 <strchr+0x1a>

0000000000000400 <gets>:

char*
gets(char *buf, int max)
{
 400:	711d                	addi	sp,sp,-96
 402:	ec86                	sd	ra,88(sp)
 404:	e8a2                	sd	s0,80(sp)
 406:	e4a6                	sd	s1,72(sp)
 408:	e0ca                	sd	s2,64(sp)
 40a:	fc4e                	sd	s3,56(sp)
 40c:	f852                	sd	s4,48(sp)
 40e:	f456                	sd	s5,40(sp)
 410:	f05a                	sd	s6,32(sp)
 412:	ec5e                	sd	s7,24(sp)
 414:	1080                	addi	s0,sp,96
 416:	8baa                	mv	s7,a0
 418:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 41a:	892a                	mv	s2,a0
 41c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 41e:	4aa9                	li	s5,10
 420:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 422:	89a6                	mv	s3,s1
 424:	2485                	addiw	s1,s1,1
 426:	0344d663          	bge	s1,s4,452 <gets+0x52>
    cc = read(0, &c, 1);
 42a:	4605                	li	a2,1
 42c:	faf40593          	addi	a1,s0,-81
 430:	4501                	li	a0,0
 432:	1b2000ef          	jal	5e4 <read>
    if(cc < 1)
 436:	00a05e63          	blez	a0,452 <gets+0x52>
    buf[i++] = c;
 43a:	faf44783          	lbu	a5,-81(s0)
 43e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 442:	01578763          	beq	a5,s5,450 <gets+0x50>
 446:	0905                	addi	s2,s2,1
 448:	fd679de3          	bne	a5,s6,422 <gets+0x22>
    buf[i++] = c;
 44c:	89a6                	mv	s3,s1
 44e:	a011                	j	452 <gets+0x52>
 450:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 452:	99de                	add	s3,s3,s7
 454:	00098023          	sb	zero,0(s3)
  return buf;
}
 458:	855e                	mv	a0,s7
 45a:	60e6                	ld	ra,88(sp)
 45c:	6446                	ld	s0,80(sp)
 45e:	64a6                	ld	s1,72(sp)
 460:	6906                	ld	s2,64(sp)
 462:	79e2                	ld	s3,56(sp)
 464:	7a42                	ld	s4,48(sp)
 466:	7aa2                	ld	s5,40(sp)
 468:	7b02                	ld	s6,32(sp)
 46a:	6be2                	ld	s7,24(sp)
 46c:	6125                	addi	sp,sp,96
 46e:	8082                	ret

0000000000000470 <stat>:

int
stat(const char *n, struct stat *st)
{
 470:	1101                	addi	sp,sp,-32
 472:	ec06                	sd	ra,24(sp)
 474:	e822                	sd	s0,16(sp)
 476:	e04a                	sd	s2,0(sp)
 478:	1000                	addi	s0,sp,32
 47a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 47c:	4581                	li	a1,0
 47e:	18e000ef          	jal	60c <open>
  if(fd < 0)
 482:	02054263          	bltz	a0,4a6 <stat+0x36>
 486:	e426                	sd	s1,8(sp)
 488:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 48a:	85ca                	mv	a1,s2
 48c:	198000ef          	jal	624 <fstat>
 490:	892a                	mv	s2,a0
  close(fd);
 492:	8526                	mv	a0,s1
 494:	160000ef          	jal	5f4 <close>
  return r;
 498:	64a2                	ld	s1,8(sp)
}
 49a:	854a                	mv	a0,s2
 49c:	60e2                	ld	ra,24(sp)
 49e:	6442                	ld	s0,16(sp)
 4a0:	6902                	ld	s2,0(sp)
 4a2:	6105                	addi	sp,sp,32
 4a4:	8082                	ret
    return -1;
 4a6:	597d                	li	s2,-1
 4a8:	bfcd                	j	49a <stat+0x2a>

00000000000004aa <atoi>:

int
atoi(const char *s)
{
 4aa:	1141                	addi	sp,sp,-16
 4ac:	e422                	sd	s0,8(sp)
 4ae:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4b0:	00054683          	lbu	a3,0(a0)
 4b4:	fd06879b          	addiw	a5,a3,-48
 4b8:	0ff7f793          	zext.b	a5,a5
 4bc:	4625                	li	a2,9
 4be:	02f66863          	bltu	a2,a5,4ee <atoi+0x44>
 4c2:	872a                	mv	a4,a0
  n = 0;
 4c4:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 4c6:	0705                	addi	a4,a4,1
 4c8:	0025179b          	slliw	a5,a0,0x2
 4cc:	9fa9                	addw	a5,a5,a0
 4ce:	0017979b          	slliw	a5,a5,0x1
 4d2:	9fb5                	addw	a5,a5,a3
 4d4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4d8:	00074683          	lbu	a3,0(a4)
 4dc:	fd06879b          	addiw	a5,a3,-48
 4e0:	0ff7f793          	zext.b	a5,a5
 4e4:	fef671e3          	bgeu	a2,a5,4c6 <atoi+0x1c>
  return n;
}
 4e8:	6422                	ld	s0,8(sp)
 4ea:	0141                	addi	sp,sp,16
 4ec:	8082                	ret
  n = 0;
 4ee:	4501                	li	a0,0
 4f0:	bfe5                	j	4e8 <atoi+0x3e>

00000000000004f2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4f2:	1141                	addi	sp,sp,-16
 4f4:	e422                	sd	s0,8(sp)
 4f6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4f8:	02b57463          	bgeu	a0,a1,520 <memmove+0x2e>
    while(n-- > 0)
 4fc:	00c05f63          	blez	a2,51a <memmove+0x28>
 500:	1602                	slli	a2,a2,0x20
 502:	9201                	srli	a2,a2,0x20
 504:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 508:	872a                	mv	a4,a0
      *dst++ = *src++;
 50a:	0585                	addi	a1,a1,1
 50c:	0705                	addi	a4,a4,1
 50e:	fff5c683          	lbu	a3,-1(a1)
 512:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 516:	fef71ae3          	bne	a4,a5,50a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 51a:	6422                	ld	s0,8(sp)
 51c:	0141                	addi	sp,sp,16
 51e:	8082                	ret
    dst += n;
 520:	00c50733          	add	a4,a0,a2
    src += n;
 524:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 526:	fec05ae3          	blez	a2,51a <memmove+0x28>
 52a:	fff6079b          	addiw	a5,a2,-1
 52e:	1782                	slli	a5,a5,0x20
 530:	9381                	srli	a5,a5,0x20
 532:	fff7c793          	not	a5,a5
 536:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 538:	15fd                	addi	a1,a1,-1
 53a:	177d                	addi	a4,a4,-1
 53c:	0005c683          	lbu	a3,0(a1)
 540:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 544:	fee79ae3          	bne	a5,a4,538 <memmove+0x46>
 548:	bfc9                	j	51a <memmove+0x28>

000000000000054a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 54a:	1141                	addi	sp,sp,-16
 54c:	e422                	sd	s0,8(sp)
 54e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 550:	ca05                	beqz	a2,580 <memcmp+0x36>
 552:	fff6069b          	addiw	a3,a2,-1
 556:	1682                	slli	a3,a3,0x20
 558:	9281                	srli	a3,a3,0x20
 55a:	0685                	addi	a3,a3,1
 55c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 55e:	00054783          	lbu	a5,0(a0)
 562:	0005c703          	lbu	a4,0(a1)
 566:	00e79863          	bne	a5,a4,576 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 56a:	0505                	addi	a0,a0,1
    p2++;
 56c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 56e:	fed518e3          	bne	a0,a3,55e <memcmp+0x14>
  }
  return 0;
 572:	4501                	li	a0,0
 574:	a019                	j	57a <memcmp+0x30>
      return *p1 - *p2;
 576:	40e7853b          	subw	a0,a5,a4
}
 57a:	6422                	ld	s0,8(sp)
 57c:	0141                	addi	sp,sp,16
 57e:	8082                	ret
  return 0;
 580:	4501                	li	a0,0
 582:	bfe5                	j	57a <memcmp+0x30>

0000000000000584 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 584:	1141                	addi	sp,sp,-16
 586:	e406                	sd	ra,8(sp)
 588:	e022                	sd	s0,0(sp)
 58a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 58c:	f67ff0ef          	jal	4f2 <memmove>
}
 590:	60a2                	ld	ra,8(sp)
 592:	6402                	ld	s0,0(sp)
 594:	0141                	addi	sp,sp,16
 596:	8082                	ret

0000000000000598 <sbrk>:

char *
sbrk(int n) {
 598:	1141                	addi	sp,sp,-16
 59a:	e406                	sd	ra,8(sp)
 59c:	e022                	sd	s0,0(sp)
 59e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 5a0:	4585                	li	a1,1
 5a2:	0b2000ef          	jal	654 <sys_sbrk>
}
 5a6:	60a2                	ld	ra,8(sp)
 5a8:	6402                	ld	s0,0(sp)
 5aa:	0141                	addi	sp,sp,16
 5ac:	8082                	ret

00000000000005ae <sbrklazy>:

char *
sbrklazy(int n) {
 5ae:	1141                	addi	sp,sp,-16
 5b0:	e406                	sd	ra,8(sp)
 5b2:	e022                	sd	s0,0(sp)
 5b4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 5b6:	4589                	li	a1,2
 5b8:	09c000ef          	jal	654 <sys_sbrk>
}
 5bc:	60a2                	ld	ra,8(sp)
 5be:	6402                	ld	s0,0(sp)
 5c0:	0141                	addi	sp,sp,16
 5c2:	8082                	ret

00000000000005c4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5c4:	4885                	li	a7,1
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <exit>:
.global exit
exit:
 li a7, SYS_exit
 5cc:	4889                	li	a7,2
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5d4:	488d                	li	a7,3
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5dc:	4891                	li	a7,4
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <read>:
.global read
read:
 li a7, SYS_read
 5e4:	4895                	li	a7,5
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <write>:
.global write
write:
 li a7, SYS_write
 5ec:	48c1                	li	a7,16
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <close>:
.global close
close:
 li a7, SYS_close
 5f4:	48d5                	li	a7,21
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <kill>:
.global kill
kill:
 li a7, SYS_kill
 5fc:	4899                	li	a7,6
 ecall
 5fe:	00000073          	ecall
 ret
 602:	8082                	ret

0000000000000604 <exec>:
.global exec
exec:
 li a7, SYS_exec
 604:	489d                	li	a7,7
 ecall
 606:	00000073          	ecall
 ret
 60a:	8082                	ret

000000000000060c <open>:
.global open
open:
 li a7, SYS_open
 60c:	48bd                	li	a7,15
 ecall
 60e:	00000073          	ecall
 ret
 612:	8082                	ret

0000000000000614 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 614:	48c5                	li	a7,17
 ecall
 616:	00000073          	ecall
 ret
 61a:	8082                	ret

000000000000061c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 61c:	48c9                	li	a7,18
 ecall
 61e:	00000073          	ecall
 ret
 622:	8082                	ret

0000000000000624 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 624:	48a1                	li	a7,8
 ecall
 626:	00000073          	ecall
 ret
 62a:	8082                	ret

000000000000062c <link>:
.global link
link:
 li a7, SYS_link
 62c:	48cd                	li	a7,19
 ecall
 62e:	00000073          	ecall
 ret
 632:	8082                	ret

0000000000000634 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 634:	48d1                	li	a7,20
 ecall
 636:	00000073          	ecall
 ret
 63a:	8082                	ret

000000000000063c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 63c:	48a5                	li	a7,9
 ecall
 63e:	00000073          	ecall
 ret
 642:	8082                	ret

0000000000000644 <dup>:
.global dup
dup:
 li a7, SYS_dup
 644:	48a9                	li	a7,10
 ecall
 646:	00000073          	ecall
 ret
 64a:	8082                	ret

000000000000064c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 64c:	48ad                	li	a7,11
 ecall
 64e:	00000073          	ecall
 ret
 652:	8082                	ret

0000000000000654 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 654:	48b1                	li	a7,12
 ecall
 656:	00000073          	ecall
 ret
 65a:	8082                	ret

000000000000065c <pause>:
.global pause
pause:
 li a7, SYS_pause
 65c:	48b5                	li	a7,13
 ecall
 65e:	00000073          	ecall
 ret
 662:	8082                	ret

0000000000000664 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 664:	48b9                	li	a7,14
 ecall
 666:	00000073          	ecall
 ret
 66a:	8082                	ret

000000000000066c <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 66c:	48d9                	li	a7,22
 ecall
 66e:	00000073          	ecall
 ret
 672:	8082                	ret

0000000000000674 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 674:	48dd                	li	a7,23
 ecall
 676:	00000073          	ecall
 ret
 67a:	8082                	ret

000000000000067c <thread_create>:
.global thread_create
thread_create:
 li a7, SYS_thread_create
 67c:	48e1                	li	a7,24
 ecall
 67e:	00000073          	ecall
 ret
 682:	8082                	ret

0000000000000684 <thread_join>:
.global thread_join
thread_join:
 li a7, SYS_thread_join
 684:	48e5                	li	a7,25
 ecall
 686:	00000073          	ecall
 ret
 68a:	8082                	ret

000000000000068c <shmcreate>:
.global shmcreate
shmcreate:
 li a7, SYS_shmcreate
 68c:	48e9                	li	a7,26
 ecall
 68e:	00000073          	ecall
 ret
 692:	8082                	ret

0000000000000694 <shmat>:
.global shmat
shmat:
 li a7, SYS_shmat
 694:	48ed                	li	a7,27
 ecall
 696:	00000073          	ecall
 ret
 69a:	8082                	ret

000000000000069c <shmdt>:
.global shmdt
shmdt:
 li a7, SYS_shmdt
 69c:	48f1                	li	a7,28
 ecall
 69e:	00000073          	ecall
 ret
 6a2:	8082                	ret

00000000000006a4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 6a4:	1101                	addi	sp,sp,-32
 6a6:	ec06                	sd	ra,24(sp)
 6a8:	e822                	sd	s0,16(sp)
 6aa:	1000                	addi	s0,sp,32
 6ac:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 6b0:	4605                	li	a2,1
 6b2:	fef40593          	addi	a1,s0,-17
 6b6:	f37ff0ef          	jal	5ec <write>
}
 6ba:	60e2                	ld	ra,24(sp)
 6bc:	6442                	ld	s0,16(sp)
 6be:	6105                	addi	sp,sp,32
 6c0:	8082                	ret

00000000000006c2 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 6c2:	715d                	addi	sp,sp,-80
 6c4:	e486                	sd	ra,72(sp)
 6c6:	e0a2                	sd	s0,64(sp)
 6c8:	f84a                	sd	s2,48(sp)
 6ca:	0880                	addi	s0,sp,80
 6cc:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 6ce:	c299                	beqz	a3,6d4 <printint+0x12>
 6d0:	0805c363          	bltz	a1,756 <printint+0x94>
  neg = 0;
 6d4:	4881                	li	a7,0
 6d6:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 6da:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 6dc:	00000517          	auipc	a0,0x0
 6e0:	70c50513          	addi	a0,a0,1804 # de8 <digits>
 6e4:	883e                	mv	a6,a5
 6e6:	2785                	addiw	a5,a5,1
 6e8:	02c5f733          	remu	a4,a1,a2
 6ec:	972a                	add	a4,a4,a0
 6ee:	00074703          	lbu	a4,0(a4)
 6f2:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 6f6:	872e                	mv	a4,a1
 6f8:	02c5d5b3          	divu	a1,a1,a2
 6fc:	0685                	addi	a3,a3,1
 6fe:	fec773e3          	bgeu	a4,a2,6e4 <printint+0x22>
  if(neg)
 702:	00088b63          	beqz	a7,718 <printint+0x56>
    buf[i++] = '-';
 706:	fd078793          	addi	a5,a5,-48
 70a:	97a2                	add	a5,a5,s0
 70c:	02d00713          	li	a4,45
 710:	fee78423          	sb	a4,-24(a5)
 714:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 718:	02f05a63          	blez	a5,74c <printint+0x8a>
 71c:	fc26                	sd	s1,56(sp)
 71e:	f44e                	sd	s3,40(sp)
 720:	fb840713          	addi	a4,s0,-72
 724:	00f704b3          	add	s1,a4,a5
 728:	fff70993          	addi	s3,a4,-1
 72c:	99be                	add	s3,s3,a5
 72e:	37fd                	addiw	a5,a5,-1
 730:	1782                	slli	a5,a5,0x20
 732:	9381                	srli	a5,a5,0x20
 734:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 738:	fff4c583          	lbu	a1,-1(s1)
 73c:	854a                	mv	a0,s2
 73e:	f67ff0ef          	jal	6a4 <putc>
  while(--i >= 0)
 742:	14fd                	addi	s1,s1,-1
 744:	ff349ae3          	bne	s1,s3,738 <printint+0x76>
 748:	74e2                	ld	s1,56(sp)
 74a:	79a2                	ld	s3,40(sp)
}
 74c:	60a6                	ld	ra,72(sp)
 74e:	6406                	ld	s0,64(sp)
 750:	7942                	ld	s2,48(sp)
 752:	6161                	addi	sp,sp,80
 754:	8082                	ret
    x = -xx;
 756:	40b005b3          	neg	a1,a1
    neg = 1;
 75a:	4885                	li	a7,1
    x = -xx;
 75c:	bfad                	j	6d6 <printint+0x14>

000000000000075e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 75e:	711d                	addi	sp,sp,-96
 760:	ec86                	sd	ra,88(sp)
 762:	e8a2                	sd	s0,80(sp)
 764:	e0ca                	sd	s2,64(sp)
 766:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 768:	0005c903          	lbu	s2,0(a1)
 76c:	28090663          	beqz	s2,9f8 <vprintf+0x29a>
 770:	e4a6                	sd	s1,72(sp)
 772:	fc4e                	sd	s3,56(sp)
 774:	f852                	sd	s4,48(sp)
 776:	f456                	sd	s5,40(sp)
 778:	f05a                	sd	s6,32(sp)
 77a:	ec5e                	sd	s7,24(sp)
 77c:	e862                	sd	s8,16(sp)
 77e:	e466                	sd	s9,8(sp)
 780:	8b2a                	mv	s6,a0
 782:	8a2e                	mv	s4,a1
 784:	8bb2                	mv	s7,a2
  state = 0;
 786:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 788:	4481                	li	s1,0
 78a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 78c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 790:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 794:	06c00c93          	li	s9,108
 798:	a005                	j	7b8 <vprintf+0x5a>
        putc(fd, c0);
 79a:	85ca                	mv	a1,s2
 79c:	855a                	mv	a0,s6
 79e:	f07ff0ef          	jal	6a4 <putc>
 7a2:	a019                	j	7a8 <vprintf+0x4a>
    } else if(state == '%'){
 7a4:	03598263          	beq	s3,s5,7c8 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 7a8:	2485                	addiw	s1,s1,1
 7aa:	8726                	mv	a4,s1
 7ac:	009a07b3          	add	a5,s4,s1
 7b0:	0007c903          	lbu	s2,0(a5)
 7b4:	22090a63          	beqz	s2,9e8 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 7b8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 7bc:	fe0994e3          	bnez	s3,7a4 <vprintf+0x46>
      if(c0 == '%'){
 7c0:	fd579de3          	bne	a5,s5,79a <vprintf+0x3c>
        state = '%';
 7c4:	89be                	mv	s3,a5
 7c6:	b7cd                	j	7a8 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 7c8:	00ea06b3          	add	a3,s4,a4
 7cc:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 7d0:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 7d2:	c681                	beqz	a3,7da <vprintf+0x7c>
 7d4:	9752                	add	a4,a4,s4
 7d6:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 7da:	05878363          	beq	a5,s8,820 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 7de:	05978d63          	beq	a5,s9,838 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 7e2:	07500713          	li	a4,117
 7e6:	0ee78763          	beq	a5,a4,8d4 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 7ea:	07800713          	li	a4,120
 7ee:	12e78963          	beq	a5,a4,920 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 7f2:	07000713          	li	a4,112
 7f6:	14e78e63          	beq	a5,a4,952 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 7fa:	06300713          	li	a4,99
 7fe:	18e78e63          	beq	a5,a4,99a <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 802:	07300713          	li	a4,115
 806:	1ae78463          	beq	a5,a4,9ae <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 80a:	02500713          	li	a4,37
 80e:	04e79563          	bne	a5,a4,858 <vprintf+0xfa>
        putc(fd, '%');
 812:	02500593          	li	a1,37
 816:	855a                	mv	a0,s6
 818:	e8dff0ef          	jal	6a4 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 81c:	4981                	li	s3,0
 81e:	b769                	j	7a8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 820:	008b8913          	addi	s2,s7,8
 824:	4685                	li	a3,1
 826:	4629                	li	a2,10
 828:	000ba583          	lw	a1,0(s7)
 82c:	855a                	mv	a0,s6
 82e:	e95ff0ef          	jal	6c2 <printint>
 832:	8bca                	mv	s7,s2
      state = 0;
 834:	4981                	li	s3,0
 836:	bf8d                	j	7a8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 838:	06400793          	li	a5,100
 83c:	02f68963          	beq	a3,a5,86e <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 840:	06c00793          	li	a5,108
 844:	04f68263          	beq	a3,a5,888 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 848:	07500793          	li	a5,117
 84c:	0af68063          	beq	a3,a5,8ec <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 850:	07800793          	li	a5,120
 854:	0ef68263          	beq	a3,a5,938 <vprintf+0x1da>
        putc(fd, '%');
 858:	02500593          	li	a1,37
 85c:	855a                	mv	a0,s6
 85e:	e47ff0ef          	jal	6a4 <putc>
        putc(fd, c0);
 862:	85ca                	mv	a1,s2
 864:	855a                	mv	a0,s6
 866:	e3fff0ef          	jal	6a4 <putc>
      state = 0;
 86a:	4981                	li	s3,0
 86c:	bf35                	j	7a8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 86e:	008b8913          	addi	s2,s7,8
 872:	4685                	li	a3,1
 874:	4629                	li	a2,10
 876:	000bb583          	ld	a1,0(s7)
 87a:	855a                	mv	a0,s6
 87c:	e47ff0ef          	jal	6c2 <printint>
        i += 1;
 880:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 882:	8bca                	mv	s7,s2
      state = 0;
 884:	4981                	li	s3,0
        i += 1;
 886:	b70d                	j	7a8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 888:	06400793          	li	a5,100
 88c:	02f60763          	beq	a2,a5,8ba <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 890:	07500793          	li	a5,117
 894:	06f60963          	beq	a2,a5,906 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 898:	07800793          	li	a5,120
 89c:	faf61ee3          	bne	a2,a5,858 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 8a0:	008b8913          	addi	s2,s7,8
 8a4:	4681                	li	a3,0
 8a6:	4641                	li	a2,16
 8a8:	000bb583          	ld	a1,0(s7)
 8ac:	855a                	mv	a0,s6
 8ae:	e15ff0ef          	jal	6c2 <printint>
        i += 2;
 8b2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 8b4:	8bca                	mv	s7,s2
      state = 0;
 8b6:	4981                	li	s3,0
        i += 2;
 8b8:	bdc5                	j	7a8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 8ba:	008b8913          	addi	s2,s7,8
 8be:	4685                	li	a3,1
 8c0:	4629                	li	a2,10
 8c2:	000bb583          	ld	a1,0(s7)
 8c6:	855a                	mv	a0,s6
 8c8:	dfbff0ef          	jal	6c2 <printint>
        i += 2;
 8cc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 8ce:	8bca                	mv	s7,s2
      state = 0;
 8d0:	4981                	li	s3,0
        i += 2;
 8d2:	bdd9                	j	7a8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 8d4:	008b8913          	addi	s2,s7,8
 8d8:	4681                	li	a3,0
 8da:	4629                	li	a2,10
 8dc:	000be583          	lwu	a1,0(s7)
 8e0:	855a                	mv	a0,s6
 8e2:	de1ff0ef          	jal	6c2 <printint>
 8e6:	8bca                	mv	s7,s2
      state = 0;
 8e8:	4981                	li	s3,0
 8ea:	bd7d                	j	7a8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8ec:	008b8913          	addi	s2,s7,8
 8f0:	4681                	li	a3,0
 8f2:	4629                	li	a2,10
 8f4:	000bb583          	ld	a1,0(s7)
 8f8:	855a                	mv	a0,s6
 8fa:	dc9ff0ef          	jal	6c2 <printint>
        i += 1;
 8fe:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 900:	8bca                	mv	s7,s2
      state = 0;
 902:	4981                	li	s3,0
        i += 1;
 904:	b555                	j	7a8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 906:	008b8913          	addi	s2,s7,8
 90a:	4681                	li	a3,0
 90c:	4629                	li	a2,10
 90e:	000bb583          	ld	a1,0(s7)
 912:	855a                	mv	a0,s6
 914:	dafff0ef          	jal	6c2 <printint>
        i += 2;
 918:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 91a:	8bca                	mv	s7,s2
      state = 0;
 91c:	4981                	li	s3,0
        i += 2;
 91e:	b569                	j	7a8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 920:	008b8913          	addi	s2,s7,8
 924:	4681                	li	a3,0
 926:	4641                	li	a2,16
 928:	000be583          	lwu	a1,0(s7)
 92c:	855a                	mv	a0,s6
 92e:	d95ff0ef          	jal	6c2 <printint>
 932:	8bca                	mv	s7,s2
      state = 0;
 934:	4981                	li	s3,0
 936:	bd8d                	j	7a8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 938:	008b8913          	addi	s2,s7,8
 93c:	4681                	li	a3,0
 93e:	4641                	li	a2,16
 940:	000bb583          	ld	a1,0(s7)
 944:	855a                	mv	a0,s6
 946:	d7dff0ef          	jal	6c2 <printint>
        i += 1;
 94a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 94c:	8bca                	mv	s7,s2
      state = 0;
 94e:	4981                	li	s3,0
        i += 1;
 950:	bda1                	j	7a8 <vprintf+0x4a>
 952:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 954:	008b8d13          	addi	s10,s7,8
 958:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 95c:	03000593          	li	a1,48
 960:	855a                	mv	a0,s6
 962:	d43ff0ef          	jal	6a4 <putc>
  putc(fd, 'x');
 966:	07800593          	li	a1,120
 96a:	855a                	mv	a0,s6
 96c:	d39ff0ef          	jal	6a4 <putc>
 970:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 972:	00000b97          	auipc	s7,0x0
 976:	476b8b93          	addi	s7,s7,1142 # de8 <digits>
 97a:	03c9d793          	srli	a5,s3,0x3c
 97e:	97de                	add	a5,a5,s7
 980:	0007c583          	lbu	a1,0(a5)
 984:	855a                	mv	a0,s6
 986:	d1fff0ef          	jal	6a4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 98a:	0992                	slli	s3,s3,0x4
 98c:	397d                	addiw	s2,s2,-1
 98e:	fe0916e3          	bnez	s2,97a <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 992:	8bea                	mv	s7,s10
      state = 0;
 994:	4981                	li	s3,0
 996:	6d02                	ld	s10,0(sp)
 998:	bd01                	j	7a8 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 99a:	008b8913          	addi	s2,s7,8
 99e:	000bc583          	lbu	a1,0(s7)
 9a2:	855a                	mv	a0,s6
 9a4:	d01ff0ef          	jal	6a4 <putc>
 9a8:	8bca                	mv	s7,s2
      state = 0;
 9aa:	4981                	li	s3,0
 9ac:	bbf5                	j	7a8 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 9ae:	008b8993          	addi	s3,s7,8
 9b2:	000bb903          	ld	s2,0(s7)
 9b6:	00090f63          	beqz	s2,9d4 <vprintf+0x276>
        for(; *s; s++)
 9ba:	00094583          	lbu	a1,0(s2)
 9be:	c195                	beqz	a1,9e2 <vprintf+0x284>
          putc(fd, *s);
 9c0:	855a                	mv	a0,s6
 9c2:	ce3ff0ef          	jal	6a4 <putc>
        for(; *s; s++)
 9c6:	0905                	addi	s2,s2,1
 9c8:	00094583          	lbu	a1,0(s2)
 9cc:	f9f5                	bnez	a1,9c0 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 9ce:	8bce                	mv	s7,s3
      state = 0;
 9d0:	4981                	li	s3,0
 9d2:	bbd9                	j	7a8 <vprintf+0x4a>
          s = "(null)";
 9d4:	00000917          	auipc	s2,0x0
 9d8:	40c90913          	addi	s2,s2,1036 # de0 <malloc+0x300>
        for(; *s; s++)
 9dc:	02800593          	li	a1,40
 9e0:	b7c5                	j	9c0 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 9e2:	8bce                	mv	s7,s3
      state = 0;
 9e4:	4981                	li	s3,0
 9e6:	b3c9                	j	7a8 <vprintf+0x4a>
 9e8:	64a6                	ld	s1,72(sp)
 9ea:	79e2                	ld	s3,56(sp)
 9ec:	7a42                	ld	s4,48(sp)
 9ee:	7aa2                	ld	s5,40(sp)
 9f0:	7b02                	ld	s6,32(sp)
 9f2:	6be2                	ld	s7,24(sp)
 9f4:	6c42                	ld	s8,16(sp)
 9f6:	6ca2                	ld	s9,8(sp)
    }
  }
}
 9f8:	60e6                	ld	ra,88(sp)
 9fa:	6446                	ld	s0,80(sp)
 9fc:	6906                	ld	s2,64(sp)
 9fe:	6125                	addi	sp,sp,96
 a00:	8082                	ret

0000000000000a02 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a02:	715d                	addi	sp,sp,-80
 a04:	ec06                	sd	ra,24(sp)
 a06:	e822                	sd	s0,16(sp)
 a08:	1000                	addi	s0,sp,32
 a0a:	e010                	sd	a2,0(s0)
 a0c:	e414                	sd	a3,8(s0)
 a0e:	e818                	sd	a4,16(s0)
 a10:	ec1c                	sd	a5,24(s0)
 a12:	03043023          	sd	a6,32(s0)
 a16:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a1a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a1e:	8622                	mv	a2,s0
 a20:	d3fff0ef          	jal	75e <vprintf>
}
 a24:	60e2                	ld	ra,24(sp)
 a26:	6442                	ld	s0,16(sp)
 a28:	6161                	addi	sp,sp,80
 a2a:	8082                	ret

0000000000000a2c <printf>:

void
printf(const char *fmt, ...)
{
 a2c:	711d                	addi	sp,sp,-96
 a2e:	ec06                	sd	ra,24(sp)
 a30:	e822                	sd	s0,16(sp)
 a32:	1000                	addi	s0,sp,32
 a34:	e40c                	sd	a1,8(s0)
 a36:	e810                	sd	a2,16(s0)
 a38:	ec14                	sd	a3,24(s0)
 a3a:	f018                	sd	a4,32(s0)
 a3c:	f41c                	sd	a5,40(s0)
 a3e:	03043823          	sd	a6,48(s0)
 a42:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a46:	00840613          	addi	a2,s0,8
 a4a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a4e:	85aa                	mv	a1,a0
 a50:	4505                	li	a0,1
 a52:	d0dff0ef          	jal	75e <vprintf>
}
 a56:	60e2                	ld	ra,24(sp)
 a58:	6442                	ld	s0,16(sp)
 a5a:	6125                	addi	sp,sp,96
 a5c:	8082                	ret

0000000000000a5e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a5e:	1141                	addi	sp,sp,-16
 a60:	e422                	sd	s0,8(sp)
 a62:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a64:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a68:	00001797          	auipc	a5,0x1
 a6c:	5987b783          	ld	a5,1432(a5) # 2000 <freep>
 a70:	a02d                	j	a9a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a72:	4618                	lw	a4,8(a2)
 a74:	9f2d                	addw	a4,a4,a1
 a76:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a7a:	6398                	ld	a4,0(a5)
 a7c:	6310                	ld	a2,0(a4)
 a7e:	a83d                	j	abc <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a80:	ff852703          	lw	a4,-8(a0)
 a84:	9f31                	addw	a4,a4,a2
 a86:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a88:	ff053683          	ld	a3,-16(a0)
 a8c:	a091                	j	ad0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a8e:	6398                	ld	a4,0(a5)
 a90:	00e7e463          	bltu	a5,a4,a98 <free+0x3a>
 a94:	00e6ea63          	bltu	a3,a4,aa8 <free+0x4a>
{
 a98:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a9a:	fed7fae3          	bgeu	a5,a3,a8e <free+0x30>
 a9e:	6398                	ld	a4,0(a5)
 aa0:	00e6e463          	bltu	a3,a4,aa8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 aa4:	fee7eae3          	bltu	a5,a4,a98 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 aa8:	ff852583          	lw	a1,-8(a0)
 aac:	6390                	ld	a2,0(a5)
 aae:	02059813          	slli	a6,a1,0x20
 ab2:	01c85713          	srli	a4,a6,0x1c
 ab6:	9736                	add	a4,a4,a3
 ab8:	fae60de3          	beq	a2,a4,a72 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 abc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 ac0:	4790                	lw	a2,8(a5)
 ac2:	02061593          	slli	a1,a2,0x20
 ac6:	01c5d713          	srli	a4,a1,0x1c
 aca:	973e                	add	a4,a4,a5
 acc:	fae68ae3          	beq	a3,a4,a80 <free+0x22>
    p->s.ptr = bp->s.ptr;
 ad0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 ad2:	00001717          	auipc	a4,0x1
 ad6:	52f73723          	sd	a5,1326(a4) # 2000 <freep>
}
 ada:	6422                	ld	s0,8(sp)
 adc:	0141                	addi	sp,sp,16
 ade:	8082                	ret

0000000000000ae0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 ae0:	7139                	addi	sp,sp,-64
 ae2:	fc06                	sd	ra,56(sp)
 ae4:	f822                	sd	s0,48(sp)
 ae6:	f426                	sd	s1,40(sp)
 ae8:	ec4e                	sd	s3,24(sp)
 aea:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 aec:	02051493          	slli	s1,a0,0x20
 af0:	9081                	srli	s1,s1,0x20
 af2:	04bd                	addi	s1,s1,15
 af4:	8091                	srli	s1,s1,0x4
 af6:	0014899b          	addiw	s3,s1,1
 afa:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 afc:	00001517          	auipc	a0,0x1
 b00:	50453503          	ld	a0,1284(a0) # 2000 <freep>
 b04:	c915                	beqz	a0,b38 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b06:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b08:	4798                	lw	a4,8(a5)
 b0a:	08977a63          	bgeu	a4,s1,b9e <malloc+0xbe>
 b0e:	f04a                	sd	s2,32(sp)
 b10:	e852                	sd	s4,16(sp)
 b12:	e456                	sd	s5,8(sp)
 b14:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 b16:	8a4e                	mv	s4,s3
 b18:	0009871b          	sext.w	a4,s3
 b1c:	6685                	lui	a3,0x1
 b1e:	00d77363          	bgeu	a4,a3,b24 <malloc+0x44>
 b22:	6a05                	lui	s4,0x1
 b24:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b28:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b2c:	00001917          	auipc	s2,0x1
 b30:	4d490913          	addi	s2,s2,1236 # 2000 <freep>
  if(p == SBRK_ERROR)
 b34:	5afd                	li	s5,-1
 b36:	a081                	j	b76 <malloc+0x96>
 b38:	f04a                	sd	s2,32(sp)
 b3a:	e852                	sd	s4,16(sp)
 b3c:	e456                	sd	s5,8(sp)
 b3e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 b40:	00001797          	auipc	a5,0x1
 b44:	4d078793          	addi	a5,a5,1232 # 2010 <base>
 b48:	00001717          	auipc	a4,0x1
 b4c:	4af73c23          	sd	a5,1208(a4) # 2000 <freep>
 b50:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b52:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b56:	b7c1                	j	b16 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 b58:	6398                	ld	a4,0(a5)
 b5a:	e118                	sd	a4,0(a0)
 b5c:	a8a9                	j	bb6 <malloc+0xd6>
  hp->s.size = nu;
 b5e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b62:	0541                	addi	a0,a0,16
 b64:	efbff0ef          	jal	a5e <free>
  return freep;
 b68:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b6c:	c12d                	beqz	a0,bce <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b6e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b70:	4798                	lw	a4,8(a5)
 b72:	02977263          	bgeu	a4,s1,b96 <malloc+0xb6>
    if(p == freep)
 b76:	00093703          	ld	a4,0(s2)
 b7a:	853e                	mv	a0,a5
 b7c:	fef719e3          	bne	a4,a5,b6e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 b80:	8552                	mv	a0,s4
 b82:	a17ff0ef          	jal	598 <sbrk>
  if(p == SBRK_ERROR)
 b86:	fd551ce3          	bne	a0,s5,b5e <malloc+0x7e>
        return 0;
 b8a:	4501                	li	a0,0
 b8c:	7902                	ld	s2,32(sp)
 b8e:	6a42                	ld	s4,16(sp)
 b90:	6aa2                	ld	s5,8(sp)
 b92:	6b02                	ld	s6,0(sp)
 b94:	a03d                	j	bc2 <malloc+0xe2>
 b96:	7902                	ld	s2,32(sp)
 b98:	6a42                	ld	s4,16(sp)
 b9a:	6aa2                	ld	s5,8(sp)
 b9c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 b9e:	fae48de3          	beq	s1,a4,b58 <malloc+0x78>
        p->s.size -= nunits;
 ba2:	4137073b          	subw	a4,a4,s3
 ba6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ba8:	02071693          	slli	a3,a4,0x20
 bac:	01c6d713          	srli	a4,a3,0x1c
 bb0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 bb2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 bb6:	00001717          	auipc	a4,0x1
 bba:	44a73523          	sd	a0,1098(a4) # 2000 <freep>
      return (void*)(p + 1);
 bbe:	01078513          	addi	a0,a5,16
  }
}
 bc2:	70e2                	ld	ra,56(sp)
 bc4:	7442                	ld	s0,48(sp)
 bc6:	74a2                	ld	s1,40(sp)
 bc8:	69e2                	ld	s3,24(sp)
 bca:	6121                	addi	sp,sp,64
 bcc:	8082                	ret
 bce:	7902                	ld	s2,32(sp)
 bd0:	6a42                	ld	s4,16(sp)
 bd2:	6aa2                	ld	s5,8(sp)
 bd4:	6b02                	ld	s6,0(sp)
 bd6:	b7f5                	j	bc2 <malloc+0xe2>
