
user/_demo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <strtonum>:
}

// ── Convert string to integer ────────────────────────────────
static int
strtonum(char *s)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
   8:	86aa                	mv	a3,a0
  int n = 0;
  int neg = 0;
  if(*s == '-'){ neg = 1; s++; }
   a:	00054703          	lbu	a4,0(a0)
   e:	02d00793          	li	a5,45
  int neg = 0;
  12:	4581                	li	a1,0
  if(*s == '-'){ neg = 1; s++; }
  14:	04f70663          	beq	a4,a5,60 <strtonum+0x60>
  while(*s >= '0' && *s <= '9'){
  18:	0006c703          	lbu	a4,0(a3)
  1c:	fd07079b          	addiw	a5,a4,-48
  20:	0ff7f793          	zext.b	a5,a5
  24:	4825                	li	a6,9
  26:	4501                	li	a0,0
  28:	8642                	mv	a2,a6
  2a:	02f86463          	bltu	a6,a5,52 <strtonum+0x52>
    n = n * 10 + (*s - '0');
  2e:	0025179b          	slliw	a5,a0,0x2
  32:	9fa9                	addw	a5,a5,a0
  34:	0017979b          	slliw	a5,a5,0x1
  38:	fd07071b          	addiw	a4,a4,-48
  3c:	00f7053b          	addw	a0,a4,a5
    s++;
  40:	0685                	addi	a3,a3,1
  while(*s >= '0' && *s <= '9'){
  42:	0006c703          	lbu	a4,0(a3)
  46:	fd07079b          	addiw	a5,a4,-48
  4a:	0ff7f793          	zext.b	a5,a5
  4e:	fef670e3          	bgeu	a2,a5,2e <strtonum+0x2e>
  }
  return neg ? -n : n;
  52:	c199                	beqz	a1,58 <strtonum+0x58>
  54:	40a0053b          	negw	a0,a0
}
  58:	60a2                	ld	ra,8(sp)
  5a:	6402                	ld	s0,0(sp)
  5c:	0141                	addi	sp,sp,16
  5e:	8082                	ret
  if(*s == '-'){ neg = 1; s++; }
  60:	00150693          	addi	a3,a0,1
  64:	4585                	li	a1,1
  66:	bf4d                	j	18 <strtonum+0x18>

0000000000000068 <readline>:
{
  68:	711d                	addi	sp,sp,-96
  6a:	ec86                	sd	ra,88(sp)
  6c:	e8a2                	sd	s0,80(sp)
  6e:	e4a6                	sd	s1,72(sp)
  70:	f05a                	sd	s6,32(sp)
  72:	1080                	addi	s0,sp,96
  74:	8b2a                	mv	s6,a0
  while(i < max - 1){
  76:	4785                	li	a5,1
  78:	04b7dc63          	bge	a5,a1,d0 <readline+0x68>
  7c:	e0ca                	sd	s2,64(sp)
  7e:	fc4e                	sd	s3,56(sp)
  80:	f852                	sd	s4,48(sp)
  82:	f456                	sd	s5,40(sp)
  84:	ec5e                	sd	s7,24(sp)
  86:	892a                	mv	s2,a0
  88:	fff5879b          	addiw	a5,a1,-1
  8c:	8bbe                	mv	s7,a5
  8e:	8abe                	mv	s5,a5
  int i = 0;
  90:	4481                	li	s1,0
    int n = read(0, &c, 1);  // read one character from stdin
  92:	faf40a13          	addi	s4,s0,-81
  96:	4985                	li	s3,1
  98:	864e                	mv	a2,s3
  9a:	85d2                	mv	a1,s4
  9c:	4501                	li	a0,0
  9e:	596000ef          	jal	634 <read>
    if(n <= 0) break;
  a2:	02a05963          	blez	a0,d4 <readline+0x6c>
    if(c == '\n' || c == '\r') break;
  a6:	faf44783          	lbu	a5,-81(s0)
  aa:	ff678713          	addi	a4,a5,-10
  ae:	c339                	beqz	a4,f4 <readline+0x8c>
  b0:	ff378713          	addi	a4,a5,-13
  b4:	c731                	beqz	a4,100 <readline+0x98>
    buf[i++] = c;
  b6:	2485                	addiw	s1,s1,1
  b8:	00f90023          	sb	a5,0(s2)
  while(i < max - 1){
  bc:	0905                	addi	s2,s2,1
  be:	fd549de3          	bne	s1,s5,98 <readline+0x30>
  c2:	84de                	mv	s1,s7
  c4:	6906                	ld	s2,64(sp)
  c6:	79e2                	ld	s3,56(sp)
  c8:	7a42                	ld	s4,48(sp)
  ca:	7aa2                	ld	s5,40(sp)
  cc:	6be2                	ld	s7,24(sp)
  ce:	a801                	j	de <readline+0x76>
  int i = 0;
  d0:	4481                	li	s1,0
  d2:	a031                	j	de <readline+0x76>
  d4:	6906                	ld	s2,64(sp)
  d6:	79e2                	ld	s3,56(sp)
  d8:	7a42                	ld	s4,48(sp)
  da:	7aa2                	ld	s5,40(sp)
  dc:	6be2                	ld	s7,24(sp)
  buf[i] = '\0';
  de:	009b07b3          	add	a5,s6,s1
  e2:	00078023          	sb	zero,0(a5)
}
  e6:	8526                	mv	a0,s1
  e8:	60e6                	ld	ra,88(sp)
  ea:	6446                	ld	s0,80(sp)
  ec:	64a6                	ld	s1,72(sp)
  ee:	7b02                	ld	s6,32(sp)
  f0:	6125                	addi	sp,sp,96
  f2:	8082                	ret
  f4:	6906                	ld	s2,64(sp)
  f6:	79e2                	ld	s3,56(sp)
  f8:	7a42                	ld	s4,48(sp)
  fa:	7aa2                	ld	s5,40(sp)
  fc:	6be2                	ld	s7,24(sp)
  fe:	b7c5                	j	de <readline+0x76>
 100:	6906                	ld	s2,64(sp)
 102:	79e2                	ld	s3,56(sp)
 104:	7a42                	ld	s4,48(sp)
 106:	7aa2                	ld	s5,40(sp)
 108:	6be2                	ld	s7,24(sp)
 10a:	bfd1                	j	de <readline+0x76>

000000000000010c <printint>:
{
 10c:	1101                	addi	sp,sp,-32
 10e:	ec06                	sd	ra,24(sp)
 110:	e822                	sd	s0,16(sp)
 112:	1000                	addi	s0,sp,32
  buf[i] = '\0';
 114:	fe0407a3          	sb	zero,-17(s0)
  if(n == 0){ buf[--i] = '0'; }
 118:	e519                	bnez	a0,126 <printint+0x1a>
 11a:	03000793          	li	a5,48
 11e:	fef40723          	sb	a5,-18(s0)
 122:	45b9                	li	a1,14
 124:	a0a1                	j	16c <printint+0x60>
  while(n > 0){ buf[--i] = '0' + (n % 10); n /= 10; }
 126:	04a05f63          	blez	a0,184 <printint+0x78>
 12a:	fee40693          	addi	a3,s0,-18
 12e:	66666637          	lui	a2,0x66666
 132:	66760613          	addi	a2,a2,1639 # 66666667 <base+0x66665657>
 136:	4825                	li	a6,9
 138:	02c50733          	mul	a4,a0,a2
 13c:	9709                	srai	a4,a4,0x22
 13e:	41f5579b          	sraiw	a5,a0,0x1f
 142:	9f1d                	subw	a4,a4,a5
 144:	0027179b          	slliw	a5,a4,0x2
 148:	9fb9                	addw	a5,a5,a4
 14a:	0017979b          	slliw	a5,a5,0x1
 14e:	40f507bb          	subw	a5,a0,a5
 152:	0307879b          	addiw	a5,a5,48
 156:	00f68023          	sb	a5,0(a3)
 15a:	87aa                	mv	a5,a0
 15c:	853a                	mv	a0,a4
 15e:	85b6                	mv	a1,a3
 160:	16fd                	addi	a3,a3,-1
 162:	fcf84be3          	blt	a6,a5,138 <printint+0x2c>
 166:	fe040793          	addi	a5,s0,-32
 16a:	9d9d                	subw	a1,a1,a5
  write(1, buf+i, 15-i);
 16c:	463d                	li	a2,15
 16e:	9e0d                	subw	a2,a2,a1
 170:	fe040793          	addi	a5,s0,-32
 174:	95be                	add	a1,a1,a5
 176:	4505                	li	a0,1
 178:	4c4000ef          	jal	63c <write>
}
 17c:	60e2                	ld	ra,24(sp)
 17e:	6442                	ld	s0,16(sp)
 180:	6105                	addi	sp,sp,32
 182:	8082                	ret
  while(n > 0){ buf[--i] = '0' + (n % 10); n /= 10; }
 184:	45bd                	li	a1,15
 186:	b7dd                	j	16c <printint+0x60>

0000000000000188 <printstr>:
{
 188:	1101                	addi	sp,sp,-32
 18a:	ec06                	sd	ra,24(sp)
 18c:	e822                	sd	s0,16(sp)
 18e:	e426                	sd	s1,8(sp)
 190:	1000                	addi	s0,sp,32
 192:	84aa                	mv	s1,a0
  write(1, s, strlen(s));
 194:	232000ef          	jal	3c6 <strlen>
 198:	862a                	mv	a2,a0
 19a:	85a6                	mv	a1,s1
 19c:	4505                	li	a0,1
 19e:	49e000ef          	jal	63c <write>
}
 1a2:	60e2                	ld	ra,24(sp)
 1a4:	6442                	ld	s0,16(sp)
 1a6:	64a2                	ld	s1,8(sp)
 1a8:	6105                	addi	sp,sp,32
 1aa:	8082                	ret

00000000000001ac <main>:
  printstr("Enter choice: ");
}

int
main(void)
{
 1ac:	7119                	addi	sp,sp,-128
 1ae:	fc86                	sd	ra,120(sp)
 1b0:	f8a2                	sd	s0,112(sp)
 1b2:	f4a6                	sd	s1,104(sp)
 1b4:	f0ca                	sd	s2,96(sp)
 1b6:	ecce                	sd	s3,88(sp)
 1b8:	e8d2                	sd	s4,80(sp)
 1ba:	e4d6                	sd	s5,72(sp)
 1bc:	e0da                	sd	s6,64(sp)
 1be:	fc5e                	sd	s7,56(sp)
 1c0:	f862                	sd	s8,48(sp)
 1c2:	0100                	addi	s0,sp,128
  char buf[32];
  int choice;

  printstr("\n");
 1c4:	00001517          	auipc	a0,0x1
 1c8:	a6c50513          	addi	a0,a0,-1428 # c30 <malloc+0xf6>
 1cc:	fbdff0ef          	jal	188 <printstr>
  printstr("  1. getprocinfo  - Get PID and Priority\n");
 1d0:	00001b97          	auipc	s7,0x1
 1d4:	a68b8b93          	addi	s7,s7,-1432 # c38 <malloc+0xfe>
  printstr("  2. setpriority  - Set Priority\n");
 1d8:	00001b17          	auipc	s6,0x1
 1dc:	a90b0b13          	addi	s6,s6,-1392 # c68 <malloc+0x12e>
  printstr("  3. Exit\n");
 1e0:	00001a97          	auipc	s5,0x1
 1e4:	ab0a8a93          	addi	s5,s5,-1360 # c90 <malloc+0x156>
  printstr("Enter choice: ");
 1e8:	00001a17          	auipc	s4,0x1
 1ec:	ab8a0a13          	addi	s4,s4,-1352 # ca0 <malloc+0x166>

  while(1){

    // Show menu and get choice
    print_menu();
    readline(buf, sizeof(buf));
 1f0:	f9040493          	addi	s1,s0,-112
 1f4:	02000913          	li	s2,32
    choice = strtonum(buf);

    // ── OPTION 1: getprocinfo ──────────────────────────────
    if(choice == 1){
 1f8:	4985                	li	s3,1
 1fa:	a095                	j	25e <main+0xb2>
      printstr("\n--- getprocinfo ---\n");
 1fc:	00001517          	auipc	a0,0x1
 200:	ab450513          	addi	a0,a0,-1356 # cb0 <malloc+0x176>
 204:	f85ff0ef          	jal	188 <printstr>

      int my_pid = 0, my_prio = 0;
 208:	f8042423          	sw	zero,-120(s0)
 20c:	f8042623          	sw	zero,-116(s0)

      if(getprocinfo(&my_pid, &my_prio) == 0){
 210:	f8c40593          	addi	a1,s0,-116
 214:	f8840513          	addi	a0,s0,-120
 218:	4a4000ef          	jal	6bc <getprocinfo>
 21c:	e159                	bnez	a0,2a2 <main+0xf6>
        printstr("  Current PID      = ");
 21e:	00001517          	auipc	a0,0x1
 222:	aaa50513          	addi	a0,a0,-1366 # cc8 <malloc+0x18e>
 226:	f63ff0ef          	jal	188 <printstr>
        printint(my_pid);
 22a:	f8842503          	lw	a0,-120(s0)
 22e:	edfff0ef          	jal	10c <printint>
        printstr("\n");
 232:	00001517          	auipc	a0,0x1
 236:	9fe50513          	addi	a0,a0,-1538 # c30 <malloc+0xf6>
 23a:	f4fff0ef          	jal	188 <printstr>
        printstr("  Current Priority = ");
 23e:	00001517          	auipc	a0,0x1
 242:	aa250513          	addi	a0,a0,-1374 # ce0 <malloc+0x1a6>
 246:	f43ff0ef          	jal	188 <printstr>
        printint(my_prio);
 24a:	f8c42503          	lw	a0,-116(s0)
 24e:	ebfff0ef          	jal	10c <printint>
        printstr("\n");
 252:	00001517          	auipc	a0,0x1
 256:	9de50513          	addi	a0,a0,-1570 # c30 <malloc+0xf6>
 25a:	f2fff0ef          	jal	188 <printstr>
  printstr("  1. getprocinfo  - Get PID and Priority\n");
 25e:	855e                	mv	a0,s7
 260:	f29ff0ef          	jal	188 <printstr>
  printstr("  2. setpriority  - Set Priority\n");
 264:	855a                	mv	a0,s6
 266:	f23ff0ef          	jal	188 <printstr>
  printstr("  3. Exit\n");
 26a:	8556                	mv	a0,s5
 26c:	f1dff0ef          	jal	188 <printstr>
  printstr("Enter choice: ");
 270:	8552                	mv	a0,s4
 272:	f17ff0ef          	jal	188 <printstr>
    readline(buf, sizeof(buf));
 276:	85ca                	mv	a1,s2
 278:	8526                	mv	a0,s1
 27a:	defff0ef          	jal	68 <readline>
    choice = strtonum(buf);
 27e:	8526                	mv	a0,s1
 280:	d81ff0ef          	jal	0 <strtonum>
    if(choice == 1){
 284:	f7350ce3          	beq	a0,s3,1fc <main+0x50>
      } else {
        printstr("  ERROR: getprocinfo failed\n");
      }

    // ── OPTION 2: setpriority ──────────────────────────────
    } else if(choice == 2){
 288:	4789                	li	a5,2
 28a:	02f50363          	beq	a0,a5,2b0 <main+0x104>
        printint(prio);
        printstr(" is invalid. Must be between 0 and 19.\n");
      }

    // ── OPTION 3: Exit ────────────────────────────────────
    } else if(choice == 3){
 28e:	478d                	li	a5,3
 290:	0cf50263          	beq	a0,a5,354 <main+0x1a8>
      printstr("\n  Exiting demo. Goodbye!\n\n");
      exit(0);

    // ── Invalid choice ────────────────────────────────────
    } else {
      printstr("\n  Invalid choice. Please enter 1, 2 or 3.\n");
 294:	00001517          	auipc	a0,0x1
 298:	b6c50513          	addi	a0,a0,-1172 # e00 <malloc+0x2c6>
 29c:	eedff0ef          	jal	188 <printstr>
 2a0:	bf7d                	j	25e <main+0xb2>
        printstr("  ERROR: getprocinfo failed\n");
 2a2:	00001517          	auipc	a0,0x1
 2a6:	a5650513          	addi	a0,a0,-1450 # cf8 <malloc+0x1be>
 2aa:	edfff0ef          	jal	188 <printstr>
 2ae:	bf45                	j	25e <main+0xb2>
      printstr("\n--- setpriority ---\n");
 2b0:	00001517          	auipc	a0,0x1
 2b4:	a6850513          	addi	a0,a0,-1432 # d18 <malloc+0x1de>
 2b8:	ed1ff0ef          	jal	188 <printstr>
      printstr("  Enter priority (0 = lowest, 19 = highest): ");
 2bc:	00001517          	auipc	a0,0x1
 2c0:	a7450513          	addi	a0,a0,-1420 # d30 <malloc+0x1f6>
 2c4:	ec5ff0ef          	jal	188 <printstr>
      readline(buf, sizeof(buf));
 2c8:	85ca                	mv	a1,s2
 2ca:	8526                	mv	a0,s1
 2cc:	d9dff0ef          	jal	68 <readline>
      int prio = strtonum(buf);
 2d0:	8526                	mv	a0,s1
 2d2:	d2fff0ef          	jal	0 <strtonum>
 2d6:	8c2a                	mv	s8,a0
      printstr("  Trying to set priority to ");
 2d8:	00001517          	auipc	a0,0x1
 2dc:	a8850513          	addi	a0,a0,-1400 # d60 <malloc+0x226>
 2e0:	ea9ff0ef          	jal	188 <printstr>
      printint(prio);
 2e4:	8562                	mv	a0,s8
 2e6:	e27ff0ef          	jal	10c <printint>
      printstr("...\n");
 2ea:	00001517          	auipc	a0,0x1
 2ee:	a9650513          	addi	a0,a0,-1386 # d80 <malloc+0x246>
 2f2:	e97ff0ef          	jal	188 <printstr>
      if(setpriority(prio) == 0){
 2f6:	8562                	mv	a0,s8
 2f8:	3cc000ef          	jal	6c4 <setpriority>
 2fc:	ed05                	bnez	a0,334 <main+0x188>
        int my_pid = 0, my_prio = 0;
 2fe:	f8042423          	sw	zero,-120(s0)
 302:	f8042623          	sw	zero,-116(s0)
        getprocinfo(&my_pid, &my_prio);
 306:	f8c40593          	addi	a1,s0,-116
 30a:	f8840513          	addi	a0,s0,-120
 30e:	3ae000ef          	jal	6bc <getprocinfo>
        printstr("  Success! Priority is now = ");
 312:	00001517          	auipc	a0,0x1
 316:	a7650513          	addi	a0,a0,-1418 # d88 <malloc+0x24e>
 31a:	e6fff0ef          	jal	188 <printstr>
        printint(my_prio);
 31e:	f8c42503          	lw	a0,-116(s0)
 322:	debff0ef          	jal	10c <printint>
        printstr("\n");
 326:	00001517          	auipc	a0,0x1
 32a:	90a50513          	addi	a0,a0,-1782 # c30 <malloc+0xf6>
 32e:	e5bff0ef          	jal	188 <printstr>
 332:	b735                	j	25e <main+0xb2>
        printstr("  ERROR: ");
 334:	00001517          	auipc	a0,0x1
 338:	a7450513          	addi	a0,a0,-1420 # da8 <malloc+0x26e>
 33c:	e4dff0ef          	jal	188 <printstr>
        printint(prio);
 340:	8562                	mv	a0,s8
 342:	dcbff0ef          	jal	10c <printint>
        printstr(" is invalid. Must be between 0 and 19.\n");
 346:	00001517          	auipc	a0,0x1
 34a:	a7250513          	addi	a0,a0,-1422 # db8 <malloc+0x27e>
 34e:	e3bff0ef          	jal	188 <printstr>
 352:	b731                	j	25e <main+0xb2>
      printstr("\n  Exiting demo. Goodbye!\n\n");
 354:	00001517          	auipc	a0,0x1
 358:	a8c50513          	addi	a0,a0,-1396 # de0 <malloc+0x2a6>
 35c:	e2dff0ef          	jal	188 <printstr>
      exit(0);
 360:	4501                	li	a0,0
 362:	2ba000ef          	jal	61c <exit>

0000000000000366 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 366:	1141                	addi	sp,sp,-16
 368:	e406                	sd	ra,8(sp)
 36a:	e022                	sd	s0,0(sp)
 36c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 36e:	e3fff0ef          	jal	1ac <main>
  exit(r);
 372:	2aa000ef          	jal	61c <exit>

0000000000000376 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 376:	1141                	addi	sp,sp,-16
 378:	e406                	sd	ra,8(sp)
 37a:	e022                	sd	s0,0(sp)
 37c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 37e:	87aa                	mv	a5,a0
 380:	0585                	addi	a1,a1,1
 382:	0785                	addi	a5,a5,1
 384:	fff5c703          	lbu	a4,-1(a1)
 388:	fee78fa3          	sb	a4,-1(a5)
 38c:	fb75                	bnez	a4,380 <strcpy+0xa>
    ;
  return os;
}
 38e:	60a2                	ld	ra,8(sp)
 390:	6402                	ld	s0,0(sp)
 392:	0141                	addi	sp,sp,16
 394:	8082                	ret

0000000000000396 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 396:	1141                	addi	sp,sp,-16
 398:	e406                	sd	ra,8(sp)
 39a:	e022                	sd	s0,0(sp)
 39c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 39e:	00054783          	lbu	a5,0(a0)
 3a2:	cb91                	beqz	a5,3b6 <strcmp+0x20>
 3a4:	0005c703          	lbu	a4,0(a1)
 3a8:	00f71763          	bne	a4,a5,3b6 <strcmp+0x20>
    p++, q++;
 3ac:	0505                	addi	a0,a0,1
 3ae:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 3b0:	00054783          	lbu	a5,0(a0)
 3b4:	fbe5                	bnez	a5,3a4 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 3b6:	0005c503          	lbu	a0,0(a1)
}
 3ba:	40a7853b          	subw	a0,a5,a0
 3be:	60a2                	ld	ra,8(sp)
 3c0:	6402                	ld	s0,0(sp)
 3c2:	0141                	addi	sp,sp,16
 3c4:	8082                	ret

00000000000003c6 <strlen>:

uint
strlen(const char *s)
{
 3c6:	1141                	addi	sp,sp,-16
 3c8:	e406                	sd	ra,8(sp)
 3ca:	e022                	sd	s0,0(sp)
 3cc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 3ce:	00054783          	lbu	a5,0(a0)
 3d2:	cf91                	beqz	a5,3ee <strlen+0x28>
 3d4:	00150793          	addi	a5,a0,1
 3d8:	86be                	mv	a3,a5
 3da:	0785                	addi	a5,a5,1
 3dc:	fff7c703          	lbu	a4,-1(a5)
 3e0:	ff65                	bnez	a4,3d8 <strlen+0x12>
 3e2:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 3e6:	60a2                	ld	ra,8(sp)
 3e8:	6402                	ld	s0,0(sp)
 3ea:	0141                	addi	sp,sp,16
 3ec:	8082                	ret
  for(n = 0; s[n]; n++)
 3ee:	4501                	li	a0,0
 3f0:	bfdd                	j	3e6 <strlen+0x20>

00000000000003f2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3f2:	1141                	addi	sp,sp,-16
 3f4:	e406                	sd	ra,8(sp)
 3f6:	e022                	sd	s0,0(sp)
 3f8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3fa:	ca19                	beqz	a2,410 <memset+0x1e>
 3fc:	87aa                	mv	a5,a0
 3fe:	1602                	slli	a2,a2,0x20
 400:	9201                	srli	a2,a2,0x20
 402:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 406:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 40a:	0785                	addi	a5,a5,1
 40c:	fee79de3          	bne	a5,a4,406 <memset+0x14>
  }
  return dst;
}
 410:	60a2                	ld	ra,8(sp)
 412:	6402                	ld	s0,0(sp)
 414:	0141                	addi	sp,sp,16
 416:	8082                	ret

0000000000000418 <strchr>:

char*
strchr(const char *s, char c)
{
 418:	1141                	addi	sp,sp,-16
 41a:	e406                	sd	ra,8(sp)
 41c:	e022                	sd	s0,0(sp)
 41e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 420:	00054783          	lbu	a5,0(a0)
 424:	cf81                	beqz	a5,43c <strchr+0x24>
    if(*s == c)
 426:	00f58763          	beq	a1,a5,434 <strchr+0x1c>
  for(; *s; s++)
 42a:	0505                	addi	a0,a0,1
 42c:	00054783          	lbu	a5,0(a0)
 430:	fbfd                	bnez	a5,426 <strchr+0xe>
      return (char*)s;
  return 0;
 432:	4501                	li	a0,0
}
 434:	60a2                	ld	ra,8(sp)
 436:	6402                	ld	s0,0(sp)
 438:	0141                	addi	sp,sp,16
 43a:	8082                	ret
  return 0;
 43c:	4501                	li	a0,0
 43e:	bfdd                	j	434 <strchr+0x1c>

0000000000000440 <gets>:

char*
gets(char *buf, int max)
{
 440:	711d                	addi	sp,sp,-96
 442:	ec86                	sd	ra,88(sp)
 444:	e8a2                	sd	s0,80(sp)
 446:	e4a6                	sd	s1,72(sp)
 448:	e0ca                	sd	s2,64(sp)
 44a:	fc4e                	sd	s3,56(sp)
 44c:	f852                	sd	s4,48(sp)
 44e:	f456                	sd	s5,40(sp)
 450:	f05a                	sd	s6,32(sp)
 452:	ec5e                	sd	s7,24(sp)
 454:	e862                	sd	s8,16(sp)
 456:	1080                	addi	s0,sp,96
 458:	8baa                	mv	s7,a0
 45a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 45c:	892a                	mv	s2,a0
 45e:	4481                	li	s1,0
    cc = read(0, &c, 1);
 460:	faf40b13          	addi	s6,s0,-81
 464:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 466:	8c26                	mv	s8,s1
 468:	0014899b          	addiw	s3,s1,1
 46c:	84ce                	mv	s1,s3
 46e:	0349d463          	bge	s3,s4,496 <gets+0x56>
    cc = read(0, &c, 1);
 472:	8656                	mv	a2,s5
 474:	85da                	mv	a1,s6
 476:	4501                	li	a0,0
 478:	1bc000ef          	jal	634 <read>
    if(cc < 1)
 47c:	00a05d63          	blez	a0,496 <gets+0x56>
      break;
    buf[i++] = c;
 480:	faf44783          	lbu	a5,-81(s0)
 484:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 488:	0905                	addi	s2,s2,1
 48a:	ff678713          	addi	a4,a5,-10
 48e:	c319                	beqz	a4,494 <gets+0x54>
 490:	17cd                	addi	a5,a5,-13
 492:	fbf1                	bnez	a5,466 <gets+0x26>
    buf[i++] = c;
 494:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 496:	9c5e                	add	s8,s8,s7
 498:	000c0023          	sb	zero,0(s8)
  return buf;
}
 49c:	855e                	mv	a0,s7
 49e:	60e6                	ld	ra,88(sp)
 4a0:	6446                	ld	s0,80(sp)
 4a2:	64a6                	ld	s1,72(sp)
 4a4:	6906                	ld	s2,64(sp)
 4a6:	79e2                	ld	s3,56(sp)
 4a8:	7a42                	ld	s4,48(sp)
 4aa:	7aa2                	ld	s5,40(sp)
 4ac:	7b02                	ld	s6,32(sp)
 4ae:	6be2                	ld	s7,24(sp)
 4b0:	6c42                	ld	s8,16(sp)
 4b2:	6125                	addi	sp,sp,96
 4b4:	8082                	ret

00000000000004b6 <stat>:

int
stat(const char *n, struct stat *st)
{
 4b6:	1101                	addi	sp,sp,-32
 4b8:	ec06                	sd	ra,24(sp)
 4ba:	e822                	sd	s0,16(sp)
 4bc:	e04a                	sd	s2,0(sp)
 4be:	1000                	addi	s0,sp,32
 4c0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4c2:	4581                	li	a1,0
 4c4:	198000ef          	jal	65c <open>
  if(fd < 0)
 4c8:	02054263          	bltz	a0,4ec <stat+0x36>
 4cc:	e426                	sd	s1,8(sp)
 4ce:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 4d0:	85ca                	mv	a1,s2
 4d2:	1a2000ef          	jal	674 <fstat>
 4d6:	892a                	mv	s2,a0
  close(fd);
 4d8:	8526                	mv	a0,s1
 4da:	16a000ef          	jal	644 <close>
  return r;
 4de:	64a2                	ld	s1,8(sp)
}
 4e0:	854a                	mv	a0,s2
 4e2:	60e2                	ld	ra,24(sp)
 4e4:	6442                	ld	s0,16(sp)
 4e6:	6902                	ld	s2,0(sp)
 4e8:	6105                	addi	sp,sp,32
 4ea:	8082                	ret
    return -1;
 4ec:	57fd                	li	a5,-1
 4ee:	893e                	mv	s2,a5
 4f0:	bfc5                	j	4e0 <stat+0x2a>

00000000000004f2 <atoi>:

int
atoi(const char *s)
{
 4f2:	1141                	addi	sp,sp,-16
 4f4:	e406                	sd	ra,8(sp)
 4f6:	e022                	sd	s0,0(sp)
 4f8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4fa:	00054683          	lbu	a3,0(a0)
 4fe:	fd06879b          	addiw	a5,a3,-48
 502:	0ff7f793          	zext.b	a5,a5
 506:	4625                	li	a2,9
 508:	02f66963          	bltu	a2,a5,53a <atoi+0x48>
 50c:	872a                	mv	a4,a0
  n = 0;
 50e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 510:	0705                	addi	a4,a4,1
 512:	0025179b          	slliw	a5,a0,0x2
 516:	9fa9                	addw	a5,a5,a0
 518:	0017979b          	slliw	a5,a5,0x1
 51c:	9fb5                	addw	a5,a5,a3
 51e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 522:	00074683          	lbu	a3,0(a4)
 526:	fd06879b          	addiw	a5,a3,-48
 52a:	0ff7f793          	zext.b	a5,a5
 52e:	fef671e3          	bgeu	a2,a5,510 <atoi+0x1e>
  return n;
}
 532:	60a2                	ld	ra,8(sp)
 534:	6402                	ld	s0,0(sp)
 536:	0141                	addi	sp,sp,16
 538:	8082                	ret
  n = 0;
 53a:	4501                	li	a0,0
 53c:	bfdd                	j	532 <atoi+0x40>

000000000000053e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 53e:	1141                	addi	sp,sp,-16
 540:	e406                	sd	ra,8(sp)
 542:	e022                	sd	s0,0(sp)
 544:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 546:	02b57563          	bgeu	a0,a1,570 <memmove+0x32>
    while(n-- > 0)
 54a:	00c05f63          	blez	a2,568 <memmove+0x2a>
 54e:	1602                	slli	a2,a2,0x20
 550:	9201                	srli	a2,a2,0x20
 552:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 556:	872a                	mv	a4,a0
      *dst++ = *src++;
 558:	0585                	addi	a1,a1,1
 55a:	0705                	addi	a4,a4,1
 55c:	fff5c683          	lbu	a3,-1(a1)
 560:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 564:	fee79ae3          	bne	a5,a4,558 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 568:	60a2                	ld	ra,8(sp)
 56a:	6402                	ld	s0,0(sp)
 56c:	0141                	addi	sp,sp,16
 56e:	8082                	ret
    while(n-- > 0)
 570:	fec05ce3          	blez	a2,568 <memmove+0x2a>
    dst += n;
 574:	00c50733          	add	a4,a0,a2
    src += n;
 578:	95b2                	add	a1,a1,a2
 57a:	fff6079b          	addiw	a5,a2,-1
 57e:	1782                	slli	a5,a5,0x20
 580:	9381                	srli	a5,a5,0x20
 582:	fff7c793          	not	a5,a5
 586:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 588:	15fd                	addi	a1,a1,-1
 58a:	177d                	addi	a4,a4,-1
 58c:	0005c683          	lbu	a3,0(a1)
 590:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 594:	fef71ae3          	bne	a4,a5,588 <memmove+0x4a>
 598:	bfc1                	j	568 <memmove+0x2a>

000000000000059a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 59a:	1141                	addi	sp,sp,-16
 59c:	e406                	sd	ra,8(sp)
 59e:	e022                	sd	s0,0(sp)
 5a0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 5a2:	c61d                	beqz	a2,5d0 <memcmp+0x36>
 5a4:	1602                	slli	a2,a2,0x20
 5a6:	9201                	srli	a2,a2,0x20
 5a8:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 5ac:	00054783          	lbu	a5,0(a0)
 5b0:	0005c703          	lbu	a4,0(a1)
 5b4:	00e79863          	bne	a5,a4,5c4 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 5b8:	0505                	addi	a0,a0,1
    p2++;
 5ba:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 5bc:	fed518e3          	bne	a0,a3,5ac <memcmp+0x12>
  }
  return 0;
 5c0:	4501                	li	a0,0
 5c2:	a019                	j	5c8 <memcmp+0x2e>
      return *p1 - *p2;
 5c4:	40e7853b          	subw	a0,a5,a4
}
 5c8:	60a2                	ld	ra,8(sp)
 5ca:	6402                	ld	s0,0(sp)
 5cc:	0141                	addi	sp,sp,16
 5ce:	8082                	ret
  return 0;
 5d0:	4501                	li	a0,0
 5d2:	bfdd                	j	5c8 <memcmp+0x2e>

00000000000005d4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 5d4:	1141                	addi	sp,sp,-16
 5d6:	e406                	sd	ra,8(sp)
 5d8:	e022                	sd	s0,0(sp)
 5da:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 5dc:	f63ff0ef          	jal	53e <memmove>
}
 5e0:	60a2                	ld	ra,8(sp)
 5e2:	6402                	ld	s0,0(sp)
 5e4:	0141                	addi	sp,sp,16
 5e6:	8082                	ret

00000000000005e8 <sbrk>:

char *
sbrk(int n) {
 5e8:	1141                	addi	sp,sp,-16
 5ea:	e406                	sd	ra,8(sp)
 5ec:	e022                	sd	s0,0(sp)
 5ee:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 5f0:	4585                	li	a1,1
 5f2:	0b2000ef          	jal	6a4 <sys_sbrk>
}
 5f6:	60a2                	ld	ra,8(sp)
 5f8:	6402                	ld	s0,0(sp)
 5fa:	0141                	addi	sp,sp,16
 5fc:	8082                	ret

00000000000005fe <sbrklazy>:

char *
sbrklazy(int n) {
 5fe:	1141                	addi	sp,sp,-16
 600:	e406                	sd	ra,8(sp)
 602:	e022                	sd	s0,0(sp)
 604:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 606:	4589                	li	a1,2
 608:	09c000ef          	jal	6a4 <sys_sbrk>
}
 60c:	60a2                	ld	ra,8(sp)
 60e:	6402                	ld	s0,0(sp)
 610:	0141                	addi	sp,sp,16
 612:	8082                	ret

0000000000000614 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 614:	4885                	li	a7,1
 ecall
 616:	00000073          	ecall
 ret
 61a:	8082                	ret

000000000000061c <exit>:
.global exit
exit:
 li a7, SYS_exit
 61c:	4889                	li	a7,2
 ecall
 61e:	00000073          	ecall
 ret
 622:	8082                	ret

0000000000000624 <wait>:
.global wait
wait:
 li a7, SYS_wait
 624:	488d                	li	a7,3
 ecall
 626:	00000073          	ecall
 ret
 62a:	8082                	ret

000000000000062c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 62c:	4891                	li	a7,4
 ecall
 62e:	00000073          	ecall
 ret
 632:	8082                	ret

0000000000000634 <read>:
.global read
read:
 li a7, SYS_read
 634:	4895                	li	a7,5
 ecall
 636:	00000073          	ecall
 ret
 63a:	8082                	ret

000000000000063c <write>:
.global write
write:
 li a7, SYS_write
 63c:	48c1                	li	a7,16
 ecall
 63e:	00000073          	ecall
 ret
 642:	8082                	ret

0000000000000644 <close>:
.global close
close:
 li a7, SYS_close
 644:	48d5                	li	a7,21
 ecall
 646:	00000073          	ecall
 ret
 64a:	8082                	ret

000000000000064c <kill>:
.global kill
kill:
 li a7, SYS_kill
 64c:	4899                	li	a7,6
 ecall
 64e:	00000073          	ecall
 ret
 652:	8082                	ret

0000000000000654 <exec>:
.global exec
exec:
 li a7, SYS_exec
 654:	489d                	li	a7,7
 ecall
 656:	00000073          	ecall
 ret
 65a:	8082                	ret

000000000000065c <open>:
.global open
open:
 li a7, SYS_open
 65c:	48bd                	li	a7,15
 ecall
 65e:	00000073          	ecall
 ret
 662:	8082                	ret

0000000000000664 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 664:	48c5                	li	a7,17
 ecall
 666:	00000073          	ecall
 ret
 66a:	8082                	ret

000000000000066c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 66c:	48c9                	li	a7,18
 ecall
 66e:	00000073          	ecall
 ret
 672:	8082                	ret

0000000000000674 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 674:	48a1                	li	a7,8
 ecall
 676:	00000073          	ecall
 ret
 67a:	8082                	ret

000000000000067c <link>:
.global link
link:
 li a7, SYS_link
 67c:	48cd                	li	a7,19
 ecall
 67e:	00000073          	ecall
 ret
 682:	8082                	ret

0000000000000684 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 684:	48d1                	li	a7,20
 ecall
 686:	00000073          	ecall
 ret
 68a:	8082                	ret

000000000000068c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 68c:	48a5                	li	a7,9
 ecall
 68e:	00000073          	ecall
 ret
 692:	8082                	ret

0000000000000694 <dup>:
.global dup
dup:
 li a7, SYS_dup
 694:	48a9                	li	a7,10
 ecall
 696:	00000073          	ecall
 ret
 69a:	8082                	ret

000000000000069c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 69c:	48ad                	li	a7,11
 ecall
 69e:	00000073          	ecall
 ret
 6a2:	8082                	ret

00000000000006a4 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 6a4:	48b1                	li	a7,12
 ecall
 6a6:	00000073          	ecall
 ret
 6aa:	8082                	ret

00000000000006ac <pause>:
.global pause
pause:
 li a7, SYS_pause
 6ac:	48b5                	li	a7,13
 ecall
 6ae:	00000073          	ecall
 ret
 6b2:	8082                	ret

00000000000006b4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 6b4:	48b9                	li	a7,14
 ecall
 6b6:	00000073          	ecall
 ret
 6ba:	8082                	ret

00000000000006bc <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 6bc:	48d9                	li	a7,22
 ecall
 6be:	00000073          	ecall
 ret
 6c2:	8082                	ret

00000000000006c4 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 6c4:	48dd                	li	a7,23
 ecall
 6c6:	00000073          	ecall
 ret
 6ca:	8082                	ret

00000000000006cc <thread_create>:
.global thread_create
thread_create:
 li a7, SYS_thread_create
 6cc:	48e1                	li	a7,24
 ecall
 6ce:	00000073          	ecall
 ret
 6d2:	8082                	ret

00000000000006d4 <thread_join>:
.global thread_join
thread_join:
 li a7, SYS_thread_join
 6d4:	48e5                	li	a7,25
 ecall
 6d6:	00000073          	ecall
 ret
 6da:	8082                	ret

00000000000006dc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 6dc:	1101                	addi	sp,sp,-32
 6de:	ec06                	sd	ra,24(sp)
 6e0:	e822                	sd	s0,16(sp)
 6e2:	1000                	addi	s0,sp,32
 6e4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 6e8:	4605                	li	a2,1
 6ea:	fef40593          	addi	a1,s0,-17
 6ee:	f4fff0ef          	jal	63c <write>
}
 6f2:	60e2                	ld	ra,24(sp)
 6f4:	6442                	ld	s0,16(sp)
 6f6:	6105                	addi	sp,sp,32
 6f8:	8082                	ret

00000000000006fa <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 6fa:	715d                	addi	sp,sp,-80
 6fc:	e486                	sd	ra,72(sp)
 6fe:	e0a2                	sd	s0,64(sp)
 700:	f84a                	sd	s2,48(sp)
 702:	f44e                	sd	s3,40(sp)
 704:	0880                	addi	s0,sp,80
 706:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 708:	c6d1                	beqz	a3,794 <printint+0x9a>
 70a:	0805d563          	bgez	a1,794 <printint+0x9a>
    neg = 1;
    x = -xx;
 70e:	40b005b3          	neg	a1,a1
    neg = 1;
 712:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 714:	fb840993          	addi	s3,s0,-72
  neg = 0;
 718:	86ce                	mv	a3,s3
  i = 0;
 71a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 71c:	00000817          	auipc	a6,0x0
 720:	71c80813          	addi	a6,a6,1820 # e38 <digits>
 724:	88ba                	mv	a7,a4
 726:	0017051b          	addiw	a0,a4,1
 72a:	872a                	mv	a4,a0
 72c:	02c5f7b3          	remu	a5,a1,a2
 730:	97c2                	add	a5,a5,a6
 732:	0007c783          	lbu	a5,0(a5)
 736:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 73a:	87ae                	mv	a5,a1
 73c:	02c5d5b3          	divu	a1,a1,a2
 740:	0685                	addi	a3,a3,1
 742:	fec7f1e3          	bgeu	a5,a2,724 <printint+0x2a>
  if(neg)
 746:	00030c63          	beqz	t1,75e <printint+0x64>
    buf[i++] = '-';
 74a:	fd050793          	addi	a5,a0,-48
 74e:	00878533          	add	a0,a5,s0
 752:	02d00793          	li	a5,45
 756:	fef50423          	sb	a5,-24(a0)
 75a:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 75e:	02e05563          	blez	a4,788 <printint+0x8e>
 762:	fc26                	sd	s1,56(sp)
 764:	377d                	addiw	a4,a4,-1
 766:	00e984b3          	add	s1,s3,a4
 76a:	19fd                	addi	s3,s3,-1
 76c:	99ba                	add	s3,s3,a4
 76e:	1702                	slli	a4,a4,0x20
 770:	9301                	srli	a4,a4,0x20
 772:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 776:	0004c583          	lbu	a1,0(s1)
 77a:	854a                	mv	a0,s2
 77c:	f61ff0ef          	jal	6dc <putc>
  while(--i >= 0)
 780:	14fd                	addi	s1,s1,-1
 782:	ff349ae3          	bne	s1,s3,776 <printint+0x7c>
 786:	74e2                	ld	s1,56(sp)
}
 788:	60a6                	ld	ra,72(sp)
 78a:	6406                	ld	s0,64(sp)
 78c:	7942                	ld	s2,48(sp)
 78e:	79a2                	ld	s3,40(sp)
 790:	6161                	addi	sp,sp,80
 792:	8082                	ret
  neg = 0;
 794:	4301                	li	t1,0
 796:	bfbd                	j	714 <printint+0x1a>

0000000000000798 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 798:	711d                	addi	sp,sp,-96
 79a:	ec86                	sd	ra,88(sp)
 79c:	e8a2                	sd	s0,80(sp)
 79e:	e4a6                	sd	s1,72(sp)
 7a0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 7a2:	0005c483          	lbu	s1,0(a1)
 7a6:	22048363          	beqz	s1,9cc <vprintf+0x234>
 7aa:	e0ca                	sd	s2,64(sp)
 7ac:	fc4e                	sd	s3,56(sp)
 7ae:	f852                	sd	s4,48(sp)
 7b0:	f456                	sd	s5,40(sp)
 7b2:	f05a                	sd	s6,32(sp)
 7b4:	ec5e                	sd	s7,24(sp)
 7b6:	e862                	sd	s8,16(sp)
 7b8:	8b2a                	mv	s6,a0
 7ba:	8a2e                	mv	s4,a1
 7bc:	8bb2                	mv	s7,a2
  state = 0;
 7be:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 7c0:	4901                	li	s2,0
 7c2:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 7c4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 7c8:	06400c13          	li	s8,100
 7cc:	a00d                	j	7ee <vprintf+0x56>
        putc(fd, c0);
 7ce:	85a6                	mv	a1,s1
 7d0:	855a                	mv	a0,s6
 7d2:	f0bff0ef          	jal	6dc <putc>
 7d6:	a019                	j	7dc <vprintf+0x44>
    } else if(state == '%'){
 7d8:	03598363          	beq	s3,s5,7fe <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 7dc:	0019079b          	addiw	a5,s2,1
 7e0:	893e                	mv	s2,a5
 7e2:	873e                	mv	a4,a5
 7e4:	97d2                	add	a5,a5,s4
 7e6:	0007c483          	lbu	s1,0(a5)
 7ea:	1c048a63          	beqz	s1,9be <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 7ee:	0004879b          	sext.w	a5,s1
    if(state == 0){
 7f2:	fe0993e3          	bnez	s3,7d8 <vprintf+0x40>
      if(c0 == '%'){
 7f6:	fd579ce3          	bne	a5,s5,7ce <vprintf+0x36>
        state = '%';
 7fa:	89be                	mv	s3,a5
 7fc:	b7c5                	j	7dc <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 7fe:	00ea06b3          	add	a3,s4,a4
 802:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 806:	1c060863          	beqz	a2,9d6 <vprintf+0x23e>
      if(c0 == 'd'){
 80a:	03878763          	beq	a5,s8,838 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 80e:	f9478693          	addi	a3,a5,-108
 812:	0016b693          	seqz	a3,a3
 816:	f9c60593          	addi	a1,a2,-100
 81a:	e99d                	bnez	a1,850 <vprintf+0xb8>
 81c:	ca95                	beqz	a3,850 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 81e:	008b8493          	addi	s1,s7,8
 822:	4685                	li	a3,1
 824:	4629                	li	a2,10
 826:	000bb583          	ld	a1,0(s7)
 82a:	855a                	mv	a0,s6
 82c:	ecfff0ef          	jal	6fa <printint>
        i += 1;
 830:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 832:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 834:	4981                	li	s3,0
 836:	b75d                	j	7dc <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 838:	008b8493          	addi	s1,s7,8
 83c:	4685                	li	a3,1
 83e:	4629                	li	a2,10
 840:	000ba583          	lw	a1,0(s7)
 844:	855a                	mv	a0,s6
 846:	eb5ff0ef          	jal	6fa <printint>
 84a:	8ba6                	mv	s7,s1
      state = 0;
 84c:	4981                	li	s3,0
 84e:	b779                	j	7dc <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 850:	9752                	add	a4,a4,s4
 852:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 856:	f9460713          	addi	a4,a2,-108
 85a:	00173713          	seqz	a4,a4
 85e:	8f75                	and	a4,a4,a3
 860:	f9c58513          	addi	a0,a1,-100
 864:	18051363          	bnez	a0,9ea <vprintf+0x252>
 868:	18070163          	beqz	a4,9ea <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 86c:	008b8493          	addi	s1,s7,8
 870:	4685                	li	a3,1
 872:	4629                	li	a2,10
 874:	000bb583          	ld	a1,0(s7)
 878:	855a                	mv	a0,s6
 87a:	e81ff0ef          	jal	6fa <printint>
        i += 2;
 87e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 880:	8ba6                	mv	s7,s1
      state = 0;
 882:	4981                	li	s3,0
        i += 2;
 884:	bfa1                	j	7dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 886:	008b8493          	addi	s1,s7,8
 88a:	4681                	li	a3,0
 88c:	4629                	li	a2,10
 88e:	000be583          	lwu	a1,0(s7)
 892:	855a                	mv	a0,s6
 894:	e67ff0ef          	jal	6fa <printint>
 898:	8ba6                	mv	s7,s1
      state = 0;
 89a:	4981                	li	s3,0
 89c:	b781                	j	7dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 89e:	008b8493          	addi	s1,s7,8
 8a2:	4681                	li	a3,0
 8a4:	4629                	li	a2,10
 8a6:	000bb583          	ld	a1,0(s7)
 8aa:	855a                	mv	a0,s6
 8ac:	e4fff0ef          	jal	6fa <printint>
        i += 1;
 8b0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 8b2:	8ba6                	mv	s7,s1
      state = 0;
 8b4:	4981                	li	s3,0
 8b6:	b71d                	j	7dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8b8:	008b8493          	addi	s1,s7,8
 8bc:	4681                	li	a3,0
 8be:	4629                	li	a2,10
 8c0:	000bb583          	ld	a1,0(s7)
 8c4:	855a                	mv	a0,s6
 8c6:	e35ff0ef          	jal	6fa <printint>
        i += 2;
 8ca:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 8cc:	8ba6                	mv	s7,s1
      state = 0;
 8ce:	4981                	li	s3,0
        i += 2;
 8d0:	b731                	j	7dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 8d2:	008b8493          	addi	s1,s7,8
 8d6:	4681                	li	a3,0
 8d8:	4641                	li	a2,16
 8da:	000be583          	lwu	a1,0(s7)
 8de:	855a                	mv	a0,s6
 8e0:	e1bff0ef          	jal	6fa <printint>
 8e4:	8ba6                	mv	s7,s1
      state = 0;
 8e6:	4981                	li	s3,0
 8e8:	bdd5                	j	7dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 8ea:	008b8493          	addi	s1,s7,8
 8ee:	4681                	li	a3,0
 8f0:	4641                	li	a2,16
 8f2:	000bb583          	ld	a1,0(s7)
 8f6:	855a                	mv	a0,s6
 8f8:	e03ff0ef          	jal	6fa <printint>
        i += 1;
 8fc:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 8fe:	8ba6                	mv	s7,s1
      state = 0;
 900:	4981                	li	s3,0
 902:	bde9                	j	7dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 904:	008b8493          	addi	s1,s7,8
 908:	4681                	li	a3,0
 90a:	4641                	li	a2,16
 90c:	000bb583          	ld	a1,0(s7)
 910:	855a                	mv	a0,s6
 912:	de9ff0ef          	jal	6fa <printint>
        i += 2;
 916:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 918:	8ba6                	mv	s7,s1
      state = 0;
 91a:	4981                	li	s3,0
        i += 2;
 91c:	b5c1                	j	7dc <vprintf+0x44>
 91e:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 920:	008b8793          	addi	a5,s7,8
 924:	8cbe                	mv	s9,a5
 926:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 92a:	03000593          	li	a1,48
 92e:	855a                	mv	a0,s6
 930:	dadff0ef          	jal	6dc <putc>
  putc(fd, 'x');
 934:	07800593          	li	a1,120
 938:	855a                	mv	a0,s6
 93a:	da3ff0ef          	jal	6dc <putc>
 93e:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 940:	00000b97          	auipc	s7,0x0
 944:	4f8b8b93          	addi	s7,s7,1272 # e38 <digits>
 948:	03c9d793          	srli	a5,s3,0x3c
 94c:	97de                	add	a5,a5,s7
 94e:	0007c583          	lbu	a1,0(a5)
 952:	855a                	mv	a0,s6
 954:	d89ff0ef          	jal	6dc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 958:	0992                	slli	s3,s3,0x4
 95a:	34fd                	addiw	s1,s1,-1
 95c:	f4f5                	bnez	s1,948 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 95e:	8be6                	mv	s7,s9
      state = 0;
 960:	4981                	li	s3,0
 962:	6ca2                	ld	s9,8(sp)
 964:	bda5                	j	7dc <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 966:	008b8493          	addi	s1,s7,8
 96a:	000bc583          	lbu	a1,0(s7)
 96e:	855a                	mv	a0,s6
 970:	d6dff0ef          	jal	6dc <putc>
 974:	8ba6                	mv	s7,s1
      state = 0;
 976:	4981                	li	s3,0
 978:	b595                	j	7dc <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 97a:	008b8993          	addi	s3,s7,8
 97e:	000bb483          	ld	s1,0(s7)
 982:	cc91                	beqz	s1,99e <vprintf+0x206>
        for(; *s; s++)
 984:	0004c583          	lbu	a1,0(s1)
 988:	c985                	beqz	a1,9b8 <vprintf+0x220>
          putc(fd, *s);
 98a:	855a                	mv	a0,s6
 98c:	d51ff0ef          	jal	6dc <putc>
        for(; *s; s++)
 990:	0485                	addi	s1,s1,1
 992:	0004c583          	lbu	a1,0(s1)
 996:	f9f5                	bnez	a1,98a <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 998:	8bce                	mv	s7,s3
      state = 0;
 99a:	4981                	li	s3,0
 99c:	b581                	j	7dc <vprintf+0x44>
          s = "(null)";
 99e:	00000497          	auipc	s1,0x0
 9a2:	49248493          	addi	s1,s1,1170 # e30 <malloc+0x2f6>
        for(; *s; s++)
 9a6:	02800593          	li	a1,40
 9aa:	b7c5                	j	98a <vprintf+0x1f2>
        putc(fd, '%');
 9ac:	85be                	mv	a1,a5
 9ae:	855a                	mv	a0,s6
 9b0:	d2dff0ef          	jal	6dc <putc>
      state = 0;
 9b4:	4981                	li	s3,0
 9b6:	b51d                	j	7dc <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 9b8:	8bce                	mv	s7,s3
      state = 0;
 9ba:	4981                	li	s3,0
 9bc:	b505                	j	7dc <vprintf+0x44>
 9be:	6906                	ld	s2,64(sp)
 9c0:	79e2                	ld	s3,56(sp)
 9c2:	7a42                	ld	s4,48(sp)
 9c4:	7aa2                	ld	s5,40(sp)
 9c6:	7b02                	ld	s6,32(sp)
 9c8:	6be2                	ld	s7,24(sp)
 9ca:	6c42                	ld	s8,16(sp)
    }
  }
}
 9cc:	60e6                	ld	ra,88(sp)
 9ce:	6446                	ld	s0,80(sp)
 9d0:	64a6                	ld	s1,72(sp)
 9d2:	6125                	addi	sp,sp,96
 9d4:	8082                	ret
      if(c0 == 'd'){
 9d6:	06400713          	li	a4,100
 9da:	e4e78fe3          	beq	a5,a4,838 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 9de:	f9478693          	addi	a3,a5,-108
 9e2:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 9e6:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 9e8:	4701                	li	a4,0
      } else if(c0 == 'u'){
 9ea:	07500513          	li	a0,117
 9ee:	e8a78ce3          	beq	a5,a0,886 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 9f2:	f8b60513          	addi	a0,a2,-117
 9f6:	e119                	bnez	a0,9fc <vprintf+0x264>
 9f8:	ea0693e3          	bnez	a3,89e <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 9fc:	f8b58513          	addi	a0,a1,-117
 a00:	e119                	bnez	a0,a06 <vprintf+0x26e>
 a02:	ea071be3          	bnez	a4,8b8 <vprintf+0x120>
      } else if(c0 == 'x'){
 a06:	07800513          	li	a0,120
 a0a:	eca784e3          	beq	a5,a0,8d2 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 a0e:	f8860613          	addi	a2,a2,-120
 a12:	e219                	bnez	a2,a18 <vprintf+0x280>
 a14:	ec069be3          	bnez	a3,8ea <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 a18:	f8858593          	addi	a1,a1,-120
 a1c:	e199                	bnez	a1,a22 <vprintf+0x28a>
 a1e:	ee0713e3          	bnez	a4,904 <vprintf+0x16c>
      } else if(c0 == 'p'){
 a22:	07000713          	li	a4,112
 a26:	eee78ce3          	beq	a5,a4,91e <vprintf+0x186>
      } else if(c0 == 'c'){
 a2a:	06300713          	li	a4,99
 a2e:	f2e78ce3          	beq	a5,a4,966 <vprintf+0x1ce>
      } else if(c0 == 's'){
 a32:	07300713          	li	a4,115
 a36:	f4e782e3          	beq	a5,a4,97a <vprintf+0x1e2>
      } else if(c0 == '%'){
 a3a:	02500713          	li	a4,37
 a3e:	f6e787e3          	beq	a5,a4,9ac <vprintf+0x214>
        putc(fd, '%');
 a42:	02500593          	li	a1,37
 a46:	855a                	mv	a0,s6
 a48:	c95ff0ef          	jal	6dc <putc>
        putc(fd, c0);
 a4c:	85a6                	mv	a1,s1
 a4e:	855a                	mv	a0,s6
 a50:	c8dff0ef          	jal	6dc <putc>
      state = 0;
 a54:	4981                	li	s3,0
 a56:	b359                	j	7dc <vprintf+0x44>

0000000000000a58 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a58:	715d                	addi	sp,sp,-80
 a5a:	ec06                	sd	ra,24(sp)
 a5c:	e822                	sd	s0,16(sp)
 a5e:	1000                	addi	s0,sp,32
 a60:	e010                	sd	a2,0(s0)
 a62:	e414                	sd	a3,8(s0)
 a64:	e818                	sd	a4,16(s0)
 a66:	ec1c                	sd	a5,24(s0)
 a68:	03043023          	sd	a6,32(s0)
 a6c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a70:	8622                	mv	a2,s0
 a72:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a76:	d23ff0ef          	jal	798 <vprintf>
}
 a7a:	60e2                	ld	ra,24(sp)
 a7c:	6442                	ld	s0,16(sp)
 a7e:	6161                	addi	sp,sp,80
 a80:	8082                	ret

0000000000000a82 <printf>:

void
printf(const char *fmt, ...)
{
 a82:	711d                	addi	sp,sp,-96
 a84:	ec06                	sd	ra,24(sp)
 a86:	e822                	sd	s0,16(sp)
 a88:	1000                	addi	s0,sp,32
 a8a:	e40c                	sd	a1,8(s0)
 a8c:	e810                	sd	a2,16(s0)
 a8e:	ec14                	sd	a3,24(s0)
 a90:	f018                	sd	a4,32(s0)
 a92:	f41c                	sd	a5,40(s0)
 a94:	03043823          	sd	a6,48(s0)
 a98:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a9c:	00840613          	addi	a2,s0,8
 aa0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 aa4:	85aa                	mv	a1,a0
 aa6:	4505                	li	a0,1
 aa8:	cf1ff0ef          	jal	798 <vprintf>
}
 aac:	60e2                	ld	ra,24(sp)
 aae:	6442                	ld	s0,16(sp)
 ab0:	6125                	addi	sp,sp,96
 ab2:	8082                	ret

0000000000000ab4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ab4:	1141                	addi	sp,sp,-16
 ab6:	e406                	sd	ra,8(sp)
 ab8:	e022                	sd	s0,0(sp)
 aba:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 abc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ac0:	00000797          	auipc	a5,0x0
 ac4:	5407b783          	ld	a5,1344(a5) # 1000 <freep>
 ac8:	a039                	j	ad6 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 aca:	6398                	ld	a4,0(a5)
 acc:	00e7e463          	bltu	a5,a4,ad4 <free+0x20>
 ad0:	00e6ea63          	bltu	a3,a4,ae4 <free+0x30>
{
 ad4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ad6:	fed7fae3          	bgeu	a5,a3,aca <free+0x16>
 ada:	6398                	ld	a4,0(a5)
 adc:	00e6e463          	bltu	a3,a4,ae4 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ae0:	fee7eae3          	bltu	a5,a4,ad4 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 ae4:	ff852583          	lw	a1,-8(a0)
 ae8:	6390                	ld	a2,0(a5)
 aea:	02059813          	slli	a6,a1,0x20
 aee:	01c85713          	srli	a4,a6,0x1c
 af2:	9736                	add	a4,a4,a3
 af4:	02e60563          	beq	a2,a4,b1e <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 af8:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 afc:	4790                	lw	a2,8(a5)
 afe:	02061593          	slli	a1,a2,0x20
 b02:	01c5d713          	srli	a4,a1,0x1c
 b06:	973e                	add	a4,a4,a5
 b08:	02e68263          	beq	a3,a4,b2c <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 b0c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 b0e:	00000717          	auipc	a4,0x0
 b12:	4ef73923          	sd	a5,1266(a4) # 1000 <freep>
}
 b16:	60a2                	ld	ra,8(sp)
 b18:	6402                	ld	s0,0(sp)
 b1a:	0141                	addi	sp,sp,16
 b1c:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 b1e:	4618                	lw	a4,8(a2)
 b20:	9f2d                	addw	a4,a4,a1
 b22:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b26:	6398                	ld	a4,0(a5)
 b28:	6310                	ld	a2,0(a4)
 b2a:	b7f9                	j	af8 <free+0x44>
    p->s.size += bp->s.size;
 b2c:	ff852703          	lw	a4,-8(a0)
 b30:	9f31                	addw	a4,a4,a2
 b32:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 b34:	ff053683          	ld	a3,-16(a0)
 b38:	bfd1                	j	b0c <free+0x58>

0000000000000b3a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b3a:	7139                	addi	sp,sp,-64
 b3c:	fc06                	sd	ra,56(sp)
 b3e:	f822                	sd	s0,48(sp)
 b40:	f04a                	sd	s2,32(sp)
 b42:	ec4e                	sd	s3,24(sp)
 b44:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b46:	02051993          	slli	s3,a0,0x20
 b4a:	0209d993          	srli	s3,s3,0x20
 b4e:	09bd                	addi	s3,s3,15
 b50:	0049d993          	srli	s3,s3,0x4
 b54:	2985                	addiw	s3,s3,1
 b56:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 b58:	00000517          	auipc	a0,0x0
 b5c:	4a853503          	ld	a0,1192(a0) # 1000 <freep>
 b60:	c905                	beqz	a0,b90 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b62:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b64:	4798                	lw	a4,8(a5)
 b66:	09377663          	bgeu	a4,s3,bf2 <malloc+0xb8>
 b6a:	f426                	sd	s1,40(sp)
 b6c:	e852                	sd	s4,16(sp)
 b6e:	e456                	sd	s5,8(sp)
 b70:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 b72:	8a4e                	mv	s4,s3
 b74:	6705                	lui	a4,0x1
 b76:	00e9f363          	bgeu	s3,a4,b7c <malloc+0x42>
 b7a:	6a05                	lui	s4,0x1
 b7c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b80:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b84:	00000497          	auipc	s1,0x0
 b88:	47c48493          	addi	s1,s1,1148 # 1000 <freep>
  if(p == SBRK_ERROR)
 b8c:	5afd                	li	s5,-1
 b8e:	a83d                	j	bcc <malloc+0x92>
 b90:	f426                	sd	s1,40(sp)
 b92:	e852                	sd	s4,16(sp)
 b94:	e456                	sd	s5,8(sp)
 b96:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 b98:	00000797          	auipc	a5,0x0
 b9c:	47878793          	addi	a5,a5,1144 # 1010 <base>
 ba0:	00000717          	auipc	a4,0x0
 ba4:	46f73023          	sd	a5,1120(a4) # 1000 <freep>
 ba8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 baa:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 bae:	b7d1                	j	b72 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 bb0:	6398                	ld	a4,0(a5)
 bb2:	e118                	sd	a4,0(a0)
 bb4:	a899                	j	c0a <malloc+0xd0>
  hp->s.size = nu;
 bb6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 bba:	0541                	addi	a0,a0,16
 bbc:	ef9ff0ef          	jal	ab4 <free>
  return freep;
 bc0:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 bc2:	c125                	beqz	a0,c22 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bc4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bc6:	4798                	lw	a4,8(a5)
 bc8:	03277163          	bgeu	a4,s2,bea <malloc+0xb0>
    if(p == freep)
 bcc:	6098                	ld	a4,0(s1)
 bce:	853e                	mv	a0,a5
 bd0:	fef71ae3          	bne	a4,a5,bc4 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 bd4:	8552                	mv	a0,s4
 bd6:	a13ff0ef          	jal	5e8 <sbrk>
  if(p == SBRK_ERROR)
 bda:	fd551ee3          	bne	a0,s5,bb6 <malloc+0x7c>
        return 0;
 bde:	4501                	li	a0,0
 be0:	74a2                	ld	s1,40(sp)
 be2:	6a42                	ld	s4,16(sp)
 be4:	6aa2                	ld	s5,8(sp)
 be6:	6b02                	ld	s6,0(sp)
 be8:	a03d                	j	c16 <malloc+0xdc>
 bea:	74a2                	ld	s1,40(sp)
 bec:	6a42                	ld	s4,16(sp)
 bee:	6aa2                	ld	s5,8(sp)
 bf0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 bf2:	fae90fe3          	beq	s2,a4,bb0 <malloc+0x76>
        p->s.size -= nunits;
 bf6:	4137073b          	subw	a4,a4,s3
 bfa:	c798                	sw	a4,8(a5)
        p += p->s.size;
 bfc:	02071693          	slli	a3,a4,0x20
 c00:	01c6d713          	srli	a4,a3,0x1c
 c04:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c06:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c0a:	00000717          	auipc	a4,0x0
 c0e:	3ea73b23          	sd	a0,1014(a4) # 1000 <freep>
      return (void*)(p + 1);
 c12:	01078513          	addi	a0,a5,16
  }
}
 c16:	70e2                	ld	ra,56(sp)
 c18:	7442                	ld	s0,48(sp)
 c1a:	7902                	ld	s2,32(sp)
 c1c:	69e2                	ld	s3,24(sp)
 c1e:	6121                	addi	sp,sp,64
 c20:	8082                	ret
 c22:	74a2                	ld	s1,40(sp)
 c24:	6a42                	ld	s4,16(sp)
 c26:	6aa2                	ld	s5,8(sp)
 c28:	6b02                	ld	s6,0(sp)
 c2a:	b7f5                	j	c16 <malloc+0xdc>
