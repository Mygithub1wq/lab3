
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 10 12 00       	mov    $0x121000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 10 12 c0       	mov    %eax,0xc0121000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 00 12 c0       	mov    $0xc0120000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));

static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba 30 41 12 c0       	mov    $0xc0124130,%edx
c0100041:	b8 00 30 12 c0       	mov    $0xc0123000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 30 12 c0 	movl   $0xc0123000,(%esp)
c010005d:	e8 3c 8a 00 00       	call   c0108a9e <memset>

    cons_init();                // init the console
c0100062:	e8 d7 14 00 00       	call   c010153e <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 40 8c 10 c0 	movl   $0xc0108c40,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 5c 8c 10 c0 	movl   $0xc0108c5c,(%esp)
c010007c:	e8 d6 02 00 00       	call   c0100357 <cprintf>

    print_kerninfo();
c0100081:	e8 05 08 00 00       	call   c010088b <print_kerninfo>

    grade_backtrace();
c0100086:	e8 95 00 00 00       	call   c0100120 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 f8 4b 00 00       	call   c0104c88 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 87 1e 00 00       	call   c0101f1c <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 ff 1f 00 00       	call   c0102099 <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 43 74 00 00       	call   c01074e2 <vmm_init>

    ide_init();                 // init ide devices
c010009f:	e8 cb 15 00 00       	call   c010166f <ide_init>
    swap_init();                // init swap
c01000a4:	e8 4c 5f 00 00       	call   c0105ff5 <swap_init>

    clock_init();               // init clock interrupt
c01000a9:	e8 46 0c 00 00       	call   c0100cf4 <clock_init>
    intr_enable();              // enable irq interrupt
c01000ae:	e8 d7 1d 00 00       	call   c0101e8a <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000b3:	eb fe                	jmp    c01000b3 <kern_init+0x7d>

c01000b5 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b5:	55                   	push   %ebp
c01000b6:	89 e5                	mov    %esp,%ebp
c01000b8:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000c2:	00 
c01000c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000ca:	00 
c01000cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000d2:	e8 3e 0b 00 00       	call   c0100c15 <mon_backtrace>
}
c01000d7:	c9                   	leave  
c01000d8:	c3                   	ret    

c01000d9 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000d9:	55                   	push   %ebp
c01000da:	89 e5                	mov    %esp,%ebp
c01000dc:	53                   	push   %ebx
c01000dd:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e0:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000e6:	8d 55 08             	lea    0x8(%ebp),%edx
c01000e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01000ec:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000f0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000f4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000f8:	89 04 24             	mov    %eax,(%esp)
c01000fb:	e8 b5 ff ff ff       	call   c01000b5 <grade_backtrace2>
}
c0100100:	83 c4 14             	add    $0x14,%esp
c0100103:	5b                   	pop    %ebx
c0100104:	5d                   	pop    %ebp
c0100105:	c3                   	ret    

c0100106 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100106:	55                   	push   %ebp
c0100107:	89 e5                	mov    %esp,%ebp
c0100109:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c010010c:	8b 45 10             	mov    0x10(%ebp),%eax
c010010f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100113:	8b 45 08             	mov    0x8(%ebp),%eax
c0100116:	89 04 24             	mov    %eax,(%esp)
c0100119:	e8 bb ff ff ff       	call   c01000d9 <grade_backtrace1>
}
c010011e:	c9                   	leave  
c010011f:	c3                   	ret    

c0100120 <grade_backtrace>:

void
grade_backtrace(void) {
c0100120:	55                   	push   %ebp
c0100121:	89 e5                	mov    %esp,%ebp
c0100123:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100126:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010012b:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100132:	ff 
c0100133:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100137:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010013e:	e8 c3 ff ff ff       	call   c0100106 <grade_backtrace0>
}
c0100143:	c9                   	leave  
c0100144:	c3                   	ret    

c0100145 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100145:	55                   	push   %ebp
c0100146:	89 e5                	mov    %esp,%ebp
c0100148:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010014b:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010014e:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100151:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100154:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100157:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010015b:	0f b7 c0             	movzwl %ax,%eax
c010015e:	83 e0 03             	and    $0x3,%eax
c0100161:	89 c2                	mov    %eax,%edx
c0100163:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c0100168:	89 54 24 08          	mov    %edx,0x8(%esp)
c010016c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100170:	c7 04 24 61 8c 10 c0 	movl   $0xc0108c61,(%esp)
c0100177:	e8 db 01 00 00       	call   c0100357 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010017c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100180:	0f b7 d0             	movzwl %ax,%edx
c0100183:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c0100188:	89 54 24 08          	mov    %edx,0x8(%esp)
c010018c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100190:	c7 04 24 6f 8c 10 c0 	movl   $0xc0108c6f,(%esp)
c0100197:	e8 bb 01 00 00       	call   c0100357 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010019c:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a0:	0f b7 d0             	movzwl %ax,%edx
c01001a3:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001a8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b0:	c7 04 24 7d 8c 10 c0 	movl   $0xc0108c7d,(%esp)
c01001b7:	e8 9b 01 00 00       	call   c0100357 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001bc:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c0:	0f b7 d0             	movzwl %ax,%edx
c01001c3:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001c8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d0:	c7 04 24 8b 8c 10 c0 	movl   $0xc0108c8b,(%esp)
c01001d7:	e8 7b 01 00 00       	call   c0100357 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001dc:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e0:	0f b7 d0             	movzwl %ax,%edx
c01001e3:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001e8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f0:	c7 04 24 99 8c 10 c0 	movl   $0xc0108c99,(%esp)
c01001f7:	e8 5b 01 00 00       	call   c0100357 <cprintf>
    round ++;
c01001fc:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c0100201:	83 c0 01             	add    $0x1,%eax
c0100204:	a3 00 30 12 c0       	mov    %eax,0xc0123000
}
c0100209:	c9                   	leave  
c010020a:	c3                   	ret    

c010020b <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c010020b:	55                   	push   %ebp
c010020c:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c010020e:	5d                   	pop    %ebp
c010020f:	c3                   	ret    

c0100210 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100210:	55                   	push   %ebp
c0100211:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100213:	5d                   	pop    %ebp
c0100214:	c3                   	ret    

c0100215 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100215:	55                   	push   %ebp
c0100216:	89 e5                	mov    %esp,%ebp
c0100218:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010021b:	e8 25 ff ff ff       	call   c0100145 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100220:	c7 04 24 a8 8c 10 c0 	movl   $0xc0108ca8,(%esp)
c0100227:	e8 2b 01 00 00       	call   c0100357 <cprintf>
    lab1_switch_to_user();
c010022c:	e8 da ff ff ff       	call   c010020b <lab1_switch_to_user>
    lab1_print_cur_status();
c0100231:	e8 0f ff ff ff       	call   c0100145 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100236:	c7 04 24 c8 8c 10 c0 	movl   $0xc0108cc8,(%esp)
c010023d:	e8 15 01 00 00       	call   c0100357 <cprintf>
    lab1_switch_to_kernel();
c0100242:	e8 c9 ff ff ff       	call   c0100210 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100247:	e8 f9 fe ff ff       	call   c0100145 <lab1_print_cur_status>
}
c010024c:	c9                   	leave  
c010024d:	c3                   	ret    

c010024e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010024e:	55                   	push   %ebp
c010024f:	89 e5                	mov    %esp,%ebp
c0100251:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100254:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100258:	74 13                	je     c010026d <readline+0x1f>
        cprintf("%s", prompt);
c010025a:	8b 45 08             	mov    0x8(%ebp),%eax
c010025d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100261:	c7 04 24 e7 8c 10 c0 	movl   $0xc0108ce7,(%esp)
c0100268:	e8 ea 00 00 00       	call   c0100357 <cprintf>
    }
    int i = 0, c;
c010026d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100274:	e8 66 01 00 00       	call   c01003df <getchar>
c0100279:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010027c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100280:	79 07                	jns    c0100289 <readline+0x3b>
            return NULL;
c0100282:	b8 00 00 00 00       	mov    $0x0,%eax
c0100287:	eb 79                	jmp    c0100302 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100289:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010028d:	7e 28                	jle    c01002b7 <readline+0x69>
c010028f:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100296:	7f 1f                	jg     c01002b7 <readline+0x69>
            cputchar(c);
c0100298:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010029b:	89 04 24             	mov    %eax,(%esp)
c010029e:	e8 da 00 00 00       	call   c010037d <cputchar>
            buf[i ++] = c;
c01002a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002a6:	8d 50 01             	lea    0x1(%eax),%edx
c01002a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002af:	88 90 20 30 12 c0    	mov    %dl,-0x3fedcfe0(%eax)
c01002b5:	eb 46                	jmp    c01002fd <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01002b7:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002bb:	75 17                	jne    c01002d4 <readline+0x86>
c01002bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002c1:	7e 11                	jle    c01002d4 <readline+0x86>
            cputchar(c);
c01002c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002c6:	89 04 24             	mov    %eax,(%esp)
c01002c9:	e8 af 00 00 00       	call   c010037d <cputchar>
            i --;
c01002ce:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002d2:	eb 29                	jmp    c01002fd <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01002d4:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002d8:	74 06                	je     c01002e0 <readline+0x92>
c01002da:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002de:	75 1d                	jne    c01002fd <readline+0xaf>
            cputchar(c);
c01002e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002e3:	89 04 24             	mov    %eax,(%esp)
c01002e6:	e8 92 00 00 00       	call   c010037d <cputchar>
            buf[i] = '\0';
c01002eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002ee:	05 20 30 12 c0       	add    $0xc0123020,%eax
c01002f3:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002f6:	b8 20 30 12 c0       	mov    $0xc0123020,%eax
c01002fb:	eb 05                	jmp    c0100302 <readline+0xb4>
        }
    }
c01002fd:	e9 72 ff ff ff       	jmp    c0100274 <readline+0x26>
}
c0100302:	c9                   	leave  
c0100303:	c3                   	ret    

c0100304 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100304:	55                   	push   %ebp
c0100305:	89 e5                	mov    %esp,%ebp
c0100307:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010030a:	8b 45 08             	mov    0x8(%ebp),%eax
c010030d:	89 04 24             	mov    %eax,(%esp)
c0100310:	e8 55 12 00 00       	call   c010156a <cons_putc>
    (*cnt) ++;
c0100315:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100318:	8b 00                	mov    (%eax),%eax
c010031a:	8d 50 01             	lea    0x1(%eax),%edx
c010031d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100320:	89 10                	mov    %edx,(%eax)
}
c0100322:	c9                   	leave  
c0100323:	c3                   	ret    

c0100324 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100324:	55                   	push   %ebp
c0100325:	89 e5                	mov    %esp,%ebp
c0100327:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010032a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100331:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100334:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100338:	8b 45 08             	mov    0x8(%ebp),%eax
c010033b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010033f:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100342:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100346:	c7 04 24 04 03 10 c0 	movl   $0xc0100304,(%esp)
c010034d:	e8 8d 7e 00 00       	call   c01081df <vprintfmt>
    return cnt;
c0100352:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100355:	c9                   	leave  
c0100356:	c3                   	ret    

c0100357 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100357:	55                   	push   %ebp
c0100358:	89 e5                	mov    %esp,%ebp
c010035a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010035d:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100360:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100363:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100366:	89 44 24 04          	mov    %eax,0x4(%esp)
c010036a:	8b 45 08             	mov    0x8(%ebp),%eax
c010036d:	89 04 24             	mov    %eax,(%esp)
c0100370:	e8 af ff ff ff       	call   c0100324 <vcprintf>
c0100375:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100378:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010037b:	c9                   	leave  
c010037c:	c3                   	ret    

c010037d <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010037d:	55                   	push   %ebp
c010037e:	89 e5                	mov    %esp,%ebp
c0100380:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100383:	8b 45 08             	mov    0x8(%ebp),%eax
c0100386:	89 04 24             	mov    %eax,(%esp)
c0100389:	e8 dc 11 00 00       	call   c010156a <cons_putc>
}
c010038e:	c9                   	leave  
c010038f:	c3                   	ret    

c0100390 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100390:	55                   	push   %ebp
c0100391:	89 e5                	mov    %esp,%ebp
c0100393:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100396:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c010039d:	eb 13                	jmp    c01003b2 <cputs+0x22>
        cputch(c, &cnt);
c010039f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003a3:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003a6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003aa:	89 04 24             	mov    %eax,(%esp)
c01003ad:	e8 52 ff ff ff       	call   c0100304 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01003b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01003b5:	8d 50 01             	lea    0x1(%eax),%edx
c01003b8:	89 55 08             	mov    %edx,0x8(%ebp)
c01003bb:	0f b6 00             	movzbl (%eax),%eax
c01003be:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003c1:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003c5:	75 d8                	jne    c010039f <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01003c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003ce:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003d5:	e8 2a ff ff ff       	call   c0100304 <cputch>
    return cnt;
c01003da:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003dd:	c9                   	leave  
c01003de:	c3                   	ret    

c01003df <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003df:	55                   	push   %ebp
c01003e0:	89 e5                	mov    %esp,%ebp
c01003e2:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003e5:	e8 bc 11 00 00       	call   c01015a6 <cons_getc>
c01003ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003f1:	74 f2                	je     c01003e5 <getchar+0x6>
        /* do nothing */;
    return c;
c01003f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003f6:	c9                   	leave  
c01003f7:	c3                   	ret    

c01003f8 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01003f8:	55                   	push   %ebp
c01003f9:	89 e5                	mov    %esp,%ebp
c01003fb:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01003fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100401:	8b 00                	mov    (%eax),%eax
c0100403:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100406:	8b 45 10             	mov    0x10(%ebp),%eax
c0100409:	8b 00                	mov    (%eax),%eax
c010040b:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010040e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100415:	e9 d2 00 00 00       	jmp    c01004ec <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c010041a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010041d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100420:	01 d0                	add    %edx,%eax
c0100422:	89 c2                	mov    %eax,%edx
c0100424:	c1 ea 1f             	shr    $0x1f,%edx
c0100427:	01 d0                	add    %edx,%eax
c0100429:	d1 f8                	sar    %eax
c010042b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010042e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100431:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100434:	eb 04                	jmp    c010043a <stab_binsearch+0x42>
            m --;
c0100436:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010043a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010043d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100440:	7c 1f                	jl     c0100461 <stab_binsearch+0x69>
c0100442:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100445:	89 d0                	mov    %edx,%eax
c0100447:	01 c0                	add    %eax,%eax
c0100449:	01 d0                	add    %edx,%eax
c010044b:	c1 e0 02             	shl    $0x2,%eax
c010044e:	89 c2                	mov    %eax,%edx
c0100450:	8b 45 08             	mov    0x8(%ebp),%eax
c0100453:	01 d0                	add    %edx,%eax
c0100455:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100459:	0f b6 c0             	movzbl %al,%eax
c010045c:	3b 45 14             	cmp    0x14(%ebp),%eax
c010045f:	75 d5                	jne    c0100436 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100461:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100464:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100467:	7d 0b                	jge    c0100474 <stab_binsearch+0x7c>
            l = true_m + 1;
c0100469:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010046c:	83 c0 01             	add    $0x1,%eax
c010046f:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100472:	eb 78                	jmp    c01004ec <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100474:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010047b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010047e:	89 d0                	mov    %edx,%eax
c0100480:	01 c0                	add    %eax,%eax
c0100482:	01 d0                	add    %edx,%eax
c0100484:	c1 e0 02             	shl    $0x2,%eax
c0100487:	89 c2                	mov    %eax,%edx
c0100489:	8b 45 08             	mov    0x8(%ebp),%eax
c010048c:	01 d0                	add    %edx,%eax
c010048e:	8b 40 08             	mov    0x8(%eax),%eax
c0100491:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100494:	73 13                	jae    c01004a9 <stab_binsearch+0xb1>
            *region_left = m;
c0100496:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100499:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010049c:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010049e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004a1:	83 c0 01             	add    $0x1,%eax
c01004a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004a7:	eb 43                	jmp    c01004ec <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c01004a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004ac:	89 d0                	mov    %edx,%eax
c01004ae:	01 c0                	add    %eax,%eax
c01004b0:	01 d0                	add    %edx,%eax
c01004b2:	c1 e0 02             	shl    $0x2,%eax
c01004b5:	89 c2                	mov    %eax,%edx
c01004b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01004ba:	01 d0                	add    %edx,%eax
c01004bc:	8b 40 08             	mov    0x8(%eax),%eax
c01004bf:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004c2:	76 16                	jbe    c01004da <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004c7:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004ca:	8b 45 10             	mov    0x10(%ebp),%eax
c01004cd:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d2:	83 e8 01             	sub    $0x1,%eax
c01004d5:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004d8:	eb 12                	jmp    c01004ec <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004da:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004e0:	89 10                	mov    %edx,(%eax)
            l = m;
c01004e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004e8:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01004ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004ef:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004f2:	0f 8e 22 ff ff ff    	jle    c010041a <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01004f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004fc:	75 0f                	jne    c010050d <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01004fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100501:	8b 00                	mov    (%eax),%eax
c0100503:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100506:	8b 45 10             	mov    0x10(%ebp),%eax
c0100509:	89 10                	mov    %edx,(%eax)
c010050b:	eb 3f                	jmp    c010054c <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c010050d:	8b 45 10             	mov    0x10(%ebp),%eax
c0100510:	8b 00                	mov    (%eax),%eax
c0100512:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100515:	eb 04                	jmp    c010051b <stab_binsearch+0x123>
c0100517:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c010051b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010051e:	8b 00                	mov    (%eax),%eax
c0100520:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100523:	7d 1f                	jge    c0100544 <stab_binsearch+0x14c>
c0100525:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100528:	89 d0                	mov    %edx,%eax
c010052a:	01 c0                	add    %eax,%eax
c010052c:	01 d0                	add    %edx,%eax
c010052e:	c1 e0 02             	shl    $0x2,%eax
c0100531:	89 c2                	mov    %eax,%edx
c0100533:	8b 45 08             	mov    0x8(%ebp),%eax
c0100536:	01 d0                	add    %edx,%eax
c0100538:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010053c:	0f b6 c0             	movzbl %al,%eax
c010053f:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100542:	75 d3                	jne    c0100517 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100544:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100547:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010054a:	89 10                	mov    %edx,(%eax)
    }
}
c010054c:	c9                   	leave  
c010054d:	c3                   	ret    

c010054e <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010054e:	55                   	push   %ebp
c010054f:	89 e5                	mov    %esp,%ebp
c0100551:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100554:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100557:	c7 00 ec 8c 10 c0    	movl   $0xc0108cec,(%eax)
    info->eip_line = 0;
c010055d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100560:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100567:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056a:	c7 40 08 ec 8c 10 c0 	movl   $0xc0108cec,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100571:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100574:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010057b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057e:	8b 55 08             	mov    0x8(%ebp),%edx
c0100581:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100584:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100587:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010058e:	c7 45 f4 3c ac 10 c0 	movl   $0xc010ac3c,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100595:	c7 45 f0 60 99 11 c0 	movl   $0xc0119960,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010059c:	c7 45 ec 61 99 11 c0 	movl   $0xc0119961,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01005a3:	c7 45 e8 f1 d1 11 c0 	movl   $0xc011d1f1,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01005aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005ad:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005b0:	76 0d                	jbe    c01005bf <debuginfo_eip+0x71>
c01005b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005b5:	83 e8 01             	sub    $0x1,%eax
c01005b8:	0f b6 00             	movzbl (%eax),%eax
c01005bb:	84 c0                	test   %al,%al
c01005bd:	74 0a                	je     c01005c9 <debuginfo_eip+0x7b>
        return -1;
c01005bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005c4:	e9 c0 02 00 00       	jmp    c0100889 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005d6:	29 c2                	sub    %eax,%edx
c01005d8:	89 d0                	mov    %edx,%eax
c01005da:	c1 f8 02             	sar    $0x2,%eax
c01005dd:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005e3:	83 e8 01             	sub    $0x1,%eax
c01005e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01005ec:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005f0:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005f7:	00 
c01005f8:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01005fb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01005ff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c0100602:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100606:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100609:	89 04 24             	mov    %eax,(%esp)
c010060c:	e8 e7 fd ff ff       	call   c01003f8 <stab_binsearch>
    if (lfile == 0)
c0100611:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100614:	85 c0                	test   %eax,%eax
c0100616:	75 0a                	jne    c0100622 <debuginfo_eip+0xd4>
        return -1;
c0100618:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010061d:	e9 67 02 00 00       	jmp    c0100889 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100622:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100625:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100628:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010062b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010062e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100631:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100635:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c010063c:	00 
c010063d:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100640:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100644:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100647:	89 44 24 04          	mov    %eax,0x4(%esp)
c010064b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010064e:	89 04 24             	mov    %eax,(%esp)
c0100651:	e8 a2 fd ff ff       	call   c01003f8 <stab_binsearch>

    if (lfun <= rfun) {
c0100656:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100659:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010065c:	39 c2                	cmp    %eax,%edx
c010065e:	7f 7c                	jg     c01006dc <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100660:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100663:	89 c2                	mov    %eax,%edx
c0100665:	89 d0                	mov    %edx,%eax
c0100667:	01 c0                	add    %eax,%eax
c0100669:	01 d0                	add    %edx,%eax
c010066b:	c1 e0 02             	shl    $0x2,%eax
c010066e:	89 c2                	mov    %eax,%edx
c0100670:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100673:	01 d0                	add    %edx,%eax
c0100675:	8b 10                	mov    (%eax),%edx
c0100677:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010067a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010067d:	29 c1                	sub    %eax,%ecx
c010067f:	89 c8                	mov    %ecx,%eax
c0100681:	39 c2                	cmp    %eax,%edx
c0100683:	73 22                	jae    c01006a7 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100685:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100688:	89 c2                	mov    %eax,%edx
c010068a:	89 d0                	mov    %edx,%eax
c010068c:	01 c0                	add    %eax,%eax
c010068e:	01 d0                	add    %edx,%eax
c0100690:	c1 e0 02             	shl    $0x2,%eax
c0100693:	89 c2                	mov    %eax,%edx
c0100695:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100698:	01 d0                	add    %edx,%eax
c010069a:	8b 10                	mov    (%eax),%edx
c010069c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010069f:	01 c2                	add    %eax,%edx
c01006a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006a4:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01006a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006aa:	89 c2                	mov    %eax,%edx
c01006ac:	89 d0                	mov    %edx,%eax
c01006ae:	01 c0                	add    %eax,%eax
c01006b0:	01 d0                	add    %edx,%eax
c01006b2:	c1 e0 02             	shl    $0x2,%eax
c01006b5:	89 c2                	mov    %eax,%edx
c01006b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006ba:	01 d0                	add    %edx,%eax
c01006bc:	8b 50 08             	mov    0x8(%eax),%edx
c01006bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006c2:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006c8:	8b 40 10             	mov    0x10(%eax),%eax
c01006cb:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006da:	eb 15                	jmp    c01006f1 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006df:	8b 55 08             	mov    0x8(%ebp),%edx
c01006e2:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006f4:	8b 40 08             	mov    0x8(%eax),%eax
c01006f7:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01006fe:	00 
c01006ff:	89 04 24             	mov    %eax,(%esp)
c0100702:	e8 0b 82 00 00       	call   c0108912 <strfind>
c0100707:	89 c2                	mov    %eax,%edx
c0100709:	8b 45 0c             	mov    0xc(%ebp),%eax
c010070c:	8b 40 08             	mov    0x8(%eax),%eax
c010070f:	29 c2                	sub    %eax,%edx
c0100711:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100714:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100717:	8b 45 08             	mov    0x8(%ebp),%eax
c010071a:	89 44 24 10          	mov    %eax,0x10(%esp)
c010071e:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100725:	00 
c0100726:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100729:	89 44 24 08          	mov    %eax,0x8(%esp)
c010072d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100730:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100734:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100737:	89 04 24             	mov    %eax,(%esp)
c010073a:	e8 b9 fc ff ff       	call   c01003f8 <stab_binsearch>
    if (lline <= rline) {
c010073f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100742:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100745:	39 c2                	cmp    %eax,%edx
c0100747:	7f 24                	jg     c010076d <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c0100749:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010074c:	89 c2                	mov    %eax,%edx
c010074e:	89 d0                	mov    %edx,%eax
c0100750:	01 c0                	add    %eax,%eax
c0100752:	01 d0                	add    %edx,%eax
c0100754:	c1 e0 02             	shl    $0x2,%eax
c0100757:	89 c2                	mov    %eax,%edx
c0100759:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075c:	01 d0                	add    %edx,%eax
c010075e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100762:	0f b7 d0             	movzwl %ax,%edx
c0100765:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100768:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010076b:	eb 13                	jmp    c0100780 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c010076d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100772:	e9 12 01 00 00       	jmp    c0100889 <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100777:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010077a:	83 e8 01             	sub    $0x1,%eax
c010077d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100780:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100783:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100786:	39 c2                	cmp    %eax,%edx
c0100788:	7c 56                	jl     c01007e0 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c010078a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010078d:	89 c2                	mov    %eax,%edx
c010078f:	89 d0                	mov    %edx,%eax
c0100791:	01 c0                	add    %eax,%eax
c0100793:	01 d0                	add    %edx,%eax
c0100795:	c1 e0 02             	shl    $0x2,%eax
c0100798:	89 c2                	mov    %eax,%edx
c010079a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010079d:	01 d0                	add    %edx,%eax
c010079f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007a3:	3c 84                	cmp    $0x84,%al
c01007a5:	74 39                	je     c01007e0 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01007a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007aa:	89 c2                	mov    %eax,%edx
c01007ac:	89 d0                	mov    %edx,%eax
c01007ae:	01 c0                	add    %eax,%eax
c01007b0:	01 d0                	add    %edx,%eax
c01007b2:	c1 e0 02             	shl    $0x2,%eax
c01007b5:	89 c2                	mov    %eax,%edx
c01007b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ba:	01 d0                	add    %edx,%eax
c01007bc:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007c0:	3c 64                	cmp    $0x64,%al
c01007c2:	75 b3                	jne    c0100777 <debuginfo_eip+0x229>
c01007c4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007c7:	89 c2                	mov    %eax,%edx
c01007c9:	89 d0                	mov    %edx,%eax
c01007cb:	01 c0                	add    %eax,%eax
c01007cd:	01 d0                	add    %edx,%eax
c01007cf:	c1 e0 02             	shl    $0x2,%eax
c01007d2:	89 c2                	mov    %eax,%edx
c01007d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007d7:	01 d0                	add    %edx,%eax
c01007d9:	8b 40 08             	mov    0x8(%eax),%eax
c01007dc:	85 c0                	test   %eax,%eax
c01007de:	74 97                	je     c0100777 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007e0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007e6:	39 c2                	cmp    %eax,%edx
c01007e8:	7c 46                	jl     c0100830 <debuginfo_eip+0x2e2>
c01007ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007ed:	89 c2                	mov    %eax,%edx
c01007ef:	89 d0                	mov    %edx,%eax
c01007f1:	01 c0                	add    %eax,%eax
c01007f3:	01 d0                	add    %edx,%eax
c01007f5:	c1 e0 02             	shl    $0x2,%eax
c01007f8:	89 c2                	mov    %eax,%edx
c01007fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007fd:	01 d0                	add    %edx,%eax
c01007ff:	8b 10                	mov    (%eax),%edx
c0100801:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100804:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100807:	29 c1                	sub    %eax,%ecx
c0100809:	89 c8                	mov    %ecx,%eax
c010080b:	39 c2                	cmp    %eax,%edx
c010080d:	73 21                	jae    c0100830 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c010080f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100812:	89 c2                	mov    %eax,%edx
c0100814:	89 d0                	mov    %edx,%eax
c0100816:	01 c0                	add    %eax,%eax
c0100818:	01 d0                	add    %edx,%eax
c010081a:	c1 e0 02             	shl    $0x2,%eax
c010081d:	89 c2                	mov    %eax,%edx
c010081f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100822:	01 d0                	add    %edx,%eax
c0100824:	8b 10                	mov    (%eax),%edx
c0100826:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100829:	01 c2                	add    %eax,%edx
c010082b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010082e:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100830:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100833:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100836:	39 c2                	cmp    %eax,%edx
c0100838:	7d 4a                	jge    c0100884 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c010083a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010083d:	83 c0 01             	add    $0x1,%eax
c0100840:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100843:	eb 18                	jmp    c010085d <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100845:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100848:	8b 40 14             	mov    0x14(%eax),%eax
c010084b:	8d 50 01             	lea    0x1(%eax),%edx
c010084e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100851:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100854:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100857:	83 c0 01             	add    $0x1,%eax
c010085a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010085d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100860:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100863:	39 c2                	cmp    %eax,%edx
c0100865:	7d 1d                	jge    c0100884 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100867:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010086a:	89 c2                	mov    %eax,%edx
c010086c:	89 d0                	mov    %edx,%eax
c010086e:	01 c0                	add    %eax,%eax
c0100870:	01 d0                	add    %edx,%eax
c0100872:	c1 e0 02             	shl    $0x2,%eax
c0100875:	89 c2                	mov    %eax,%edx
c0100877:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010087a:	01 d0                	add    %edx,%eax
c010087c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100880:	3c a0                	cmp    $0xa0,%al
c0100882:	74 c1                	je     c0100845 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100884:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100889:	c9                   	leave  
c010088a:	c3                   	ret    

c010088b <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010088b:	55                   	push   %ebp
c010088c:	89 e5                	mov    %esp,%ebp
c010088e:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100891:	c7 04 24 f6 8c 10 c0 	movl   $0xc0108cf6,(%esp)
c0100898:	e8 ba fa ff ff       	call   c0100357 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010089d:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01008a4:	c0 
c01008a5:	c7 04 24 0f 8d 10 c0 	movl   $0xc0108d0f,(%esp)
c01008ac:	e8 a6 fa ff ff       	call   c0100357 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008b1:	c7 44 24 04 27 8c 10 	movl   $0xc0108c27,0x4(%esp)
c01008b8:	c0 
c01008b9:	c7 04 24 27 8d 10 c0 	movl   $0xc0108d27,(%esp)
c01008c0:	e8 92 fa ff ff       	call   c0100357 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008c5:	c7 44 24 04 00 30 12 	movl   $0xc0123000,0x4(%esp)
c01008cc:	c0 
c01008cd:	c7 04 24 3f 8d 10 c0 	movl   $0xc0108d3f,(%esp)
c01008d4:	e8 7e fa ff ff       	call   c0100357 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008d9:	c7 44 24 04 30 41 12 	movl   $0xc0124130,0x4(%esp)
c01008e0:	c0 
c01008e1:	c7 04 24 57 8d 10 c0 	movl   $0xc0108d57,(%esp)
c01008e8:	e8 6a fa ff ff       	call   c0100357 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008ed:	b8 30 41 12 c0       	mov    $0xc0124130,%eax
c01008f2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008f8:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01008fd:	29 c2                	sub    %eax,%edx
c01008ff:	89 d0                	mov    %edx,%eax
c0100901:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100907:	85 c0                	test   %eax,%eax
c0100909:	0f 48 c2             	cmovs  %edx,%eax
c010090c:	c1 f8 0a             	sar    $0xa,%eax
c010090f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100913:	c7 04 24 70 8d 10 c0 	movl   $0xc0108d70,(%esp)
c010091a:	e8 38 fa ff ff       	call   c0100357 <cprintf>
}
c010091f:	c9                   	leave  
c0100920:	c3                   	ret    

c0100921 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100921:	55                   	push   %ebp
c0100922:	89 e5                	mov    %esp,%ebp
c0100924:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c010092a:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010092d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100931:	8b 45 08             	mov    0x8(%ebp),%eax
c0100934:	89 04 24             	mov    %eax,(%esp)
c0100937:	e8 12 fc ff ff       	call   c010054e <debuginfo_eip>
c010093c:	85 c0                	test   %eax,%eax
c010093e:	74 15                	je     c0100955 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100940:	8b 45 08             	mov    0x8(%ebp),%eax
c0100943:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100947:	c7 04 24 9a 8d 10 c0 	movl   $0xc0108d9a,(%esp)
c010094e:	e8 04 fa ff ff       	call   c0100357 <cprintf>
c0100953:	eb 6d                	jmp    c01009c2 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100955:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010095c:	eb 1c                	jmp    c010097a <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c010095e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100961:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100964:	01 d0                	add    %edx,%eax
c0100966:	0f b6 00             	movzbl (%eax),%eax
c0100969:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010096f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100972:	01 ca                	add    %ecx,%edx
c0100974:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100976:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010097a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010097d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100980:	7f dc                	jg     c010095e <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100982:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100988:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010098b:	01 d0                	add    %edx,%eax
c010098d:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100990:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100993:	8b 55 08             	mov    0x8(%ebp),%edx
c0100996:	89 d1                	mov    %edx,%ecx
c0100998:	29 c1                	sub    %eax,%ecx
c010099a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010099d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01009a0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01009a4:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01009aa:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01009ae:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009b2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009b6:	c7 04 24 b6 8d 10 c0 	movl   $0xc0108db6,(%esp)
c01009bd:	e8 95 f9 ff ff       	call   c0100357 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c01009c2:	c9                   	leave  
c01009c3:	c3                   	ret    

c01009c4 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009c4:	55                   	push   %ebp
c01009c5:	89 e5                	mov    %esp,%ebp
c01009c7:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009ca:	8b 45 04             	mov    0x4(%ebp),%eax
c01009cd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009d3:	c9                   	leave  
c01009d4:	c3                   	ret    

c01009d5 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009d5:	55                   	push   %ebp
c01009d6:	89 e5                	mov    %esp,%ebp
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
}
c01009d8:	5d                   	pop    %ebp
c01009d9:	c3                   	ret    

c01009da <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c01009da:	55                   	push   %ebp
c01009db:	89 e5                	mov    %esp,%ebp
c01009dd:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c01009e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c01009e7:	eb 0c                	jmp    c01009f5 <parse+0x1b>
            *buf ++ = '\0';
c01009e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01009ec:	8d 50 01             	lea    0x1(%eax),%edx
c01009ef:	89 55 08             	mov    %edx,0x8(%ebp)
c01009f2:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c01009f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01009f8:	0f b6 00             	movzbl (%eax),%eax
c01009fb:	84 c0                	test   %al,%al
c01009fd:	74 1d                	je     c0100a1c <parse+0x42>
c01009ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a02:	0f b6 00             	movzbl (%eax),%eax
c0100a05:	0f be c0             	movsbl %al,%eax
c0100a08:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a0c:	c7 04 24 48 8e 10 c0 	movl   $0xc0108e48,(%esp)
c0100a13:	e8 c7 7e 00 00       	call   c01088df <strchr>
c0100a18:	85 c0                	test   %eax,%eax
c0100a1a:	75 cd                	jne    c01009e9 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100a1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a1f:	0f b6 00             	movzbl (%eax),%eax
c0100a22:	84 c0                	test   %al,%al
c0100a24:	75 02                	jne    c0100a28 <parse+0x4e>
            break;
c0100a26:	eb 67                	jmp    c0100a8f <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100a28:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100a2c:	75 14                	jne    c0100a42 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100a2e:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100a35:	00 
c0100a36:	c7 04 24 4d 8e 10 c0 	movl   $0xc0108e4d,(%esp)
c0100a3d:	e8 15 f9 ff ff       	call   c0100357 <cprintf>
        }
        argv[argc ++] = buf;
c0100a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a45:	8d 50 01             	lea    0x1(%eax),%edx
c0100a48:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100a4b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a52:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a55:	01 c2                	add    %eax,%edx
c0100a57:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a5a:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100a5c:	eb 04                	jmp    c0100a62 <parse+0x88>
            buf ++;
c0100a5e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100a62:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a65:	0f b6 00             	movzbl (%eax),%eax
c0100a68:	84 c0                	test   %al,%al
c0100a6a:	74 1d                	je     c0100a89 <parse+0xaf>
c0100a6c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a6f:	0f b6 00             	movzbl (%eax),%eax
c0100a72:	0f be c0             	movsbl %al,%eax
c0100a75:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a79:	c7 04 24 48 8e 10 c0 	movl   $0xc0108e48,(%esp)
c0100a80:	e8 5a 7e 00 00       	call   c01088df <strchr>
c0100a85:	85 c0                	test   %eax,%eax
c0100a87:	74 d5                	je     c0100a5e <parse+0x84>
            buf ++;
        }
    }
c0100a89:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a8a:	e9 66 ff ff ff       	jmp    c01009f5 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100a92:	c9                   	leave  
c0100a93:	c3                   	ret    

c0100a94 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100a94:	55                   	push   %ebp
c0100a95:	89 e5                	mov    %esp,%ebp
c0100a97:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100a9a:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100aa1:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aa4:	89 04 24             	mov    %eax,(%esp)
c0100aa7:	e8 2e ff ff ff       	call   c01009da <parse>
c0100aac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100aaf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100ab3:	75 0a                	jne    c0100abf <runcmd+0x2b>
        return 0;
c0100ab5:	b8 00 00 00 00       	mov    $0x0,%eax
c0100aba:	e9 85 00 00 00       	jmp    c0100b44 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100abf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100ac6:	eb 5c                	jmp    c0100b24 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100ac8:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100acb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100ace:	89 d0                	mov    %edx,%eax
c0100ad0:	01 c0                	add    %eax,%eax
c0100ad2:	01 d0                	add    %edx,%eax
c0100ad4:	c1 e0 02             	shl    $0x2,%eax
c0100ad7:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100adc:	8b 00                	mov    (%eax),%eax
c0100ade:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100ae2:	89 04 24             	mov    %eax,(%esp)
c0100ae5:	e8 56 7d 00 00       	call   c0108840 <strcmp>
c0100aea:	85 c0                	test   %eax,%eax
c0100aec:	75 32                	jne    c0100b20 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100aee:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100af1:	89 d0                	mov    %edx,%eax
c0100af3:	01 c0                	add    %eax,%eax
c0100af5:	01 d0                	add    %edx,%eax
c0100af7:	c1 e0 02             	shl    $0x2,%eax
c0100afa:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100aff:	8b 40 08             	mov    0x8(%eax),%eax
c0100b02:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100b05:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100b08:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100b0b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100b0f:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100b12:	83 c2 04             	add    $0x4,%edx
c0100b15:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100b19:	89 0c 24             	mov    %ecx,(%esp)
c0100b1c:	ff d0                	call   *%eax
c0100b1e:	eb 24                	jmp    c0100b44 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b20:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b27:	83 f8 02             	cmp    $0x2,%eax
c0100b2a:	76 9c                	jbe    c0100ac8 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100b2c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b33:	c7 04 24 6b 8e 10 c0 	movl   $0xc0108e6b,(%esp)
c0100b3a:	e8 18 f8 ff ff       	call   c0100357 <cprintf>
    return 0;
c0100b3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100b44:	c9                   	leave  
c0100b45:	c3                   	ret    

c0100b46 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100b46:	55                   	push   %ebp
c0100b47:	89 e5                	mov    %esp,%ebp
c0100b49:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100b4c:	c7 04 24 84 8e 10 c0 	movl   $0xc0108e84,(%esp)
c0100b53:	e8 ff f7 ff ff       	call   c0100357 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100b58:	c7 04 24 ac 8e 10 c0 	movl   $0xc0108eac,(%esp)
c0100b5f:	e8 f3 f7 ff ff       	call   c0100357 <cprintf>

    if (tf != NULL) {
c0100b64:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100b68:	74 0b                	je     c0100b75 <kmonitor+0x2f>
        print_trapframe(tf);
c0100b6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b6d:	89 04 24             	mov    %eax,(%esp)
c0100b70:	e8 5d 16 00 00       	call   c01021d2 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100b75:	c7 04 24 d1 8e 10 c0 	movl   $0xc0108ed1,(%esp)
c0100b7c:	e8 cd f6 ff ff       	call   c010024e <readline>
c0100b81:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100b84:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b88:	74 18                	je     c0100ba2 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100b8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b8d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b94:	89 04 24             	mov    %eax,(%esp)
c0100b97:	e8 f8 fe ff ff       	call   c0100a94 <runcmd>
c0100b9c:	85 c0                	test   %eax,%eax
c0100b9e:	79 02                	jns    c0100ba2 <kmonitor+0x5c>
                break;
c0100ba0:	eb 02                	jmp    c0100ba4 <kmonitor+0x5e>
            }
        }
    }
c0100ba2:	eb d1                	jmp    c0100b75 <kmonitor+0x2f>
}
c0100ba4:	c9                   	leave  
c0100ba5:	c3                   	ret    

c0100ba6 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100ba6:	55                   	push   %ebp
c0100ba7:	89 e5                	mov    %esp,%ebp
c0100ba9:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100bb3:	eb 3f                	jmp    c0100bf4 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100bb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100bb8:	89 d0                	mov    %edx,%eax
c0100bba:	01 c0                	add    %eax,%eax
c0100bbc:	01 d0                	add    %edx,%eax
c0100bbe:	c1 e0 02             	shl    $0x2,%eax
c0100bc1:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100bc6:	8b 48 04             	mov    0x4(%eax),%ecx
c0100bc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100bcc:	89 d0                	mov    %edx,%eax
c0100bce:	01 c0                	add    %eax,%eax
c0100bd0:	01 d0                	add    %edx,%eax
c0100bd2:	c1 e0 02             	shl    $0x2,%eax
c0100bd5:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100bda:	8b 00                	mov    (%eax),%eax
c0100bdc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100be0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100be4:	c7 04 24 d5 8e 10 c0 	movl   $0xc0108ed5,(%esp)
c0100beb:	e8 67 f7 ff ff       	call   c0100357 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bf0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bf7:	83 f8 02             	cmp    $0x2,%eax
c0100bfa:	76 b9                	jbe    c0100bb5 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100bfc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c01:	c9                   	leave  
c0100c02:	c3                   	ret    

c0100c03 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100c03:	55                   	push   %ebp
c0100c04:	89 e5                	mov    %esp,%ebp
c0100c06:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100c09:	e8 7d fc ff ff       	call   c010088b <print_kerninfo>
    return 0;
c0100c0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c13:	c9                   	leave  
c0100c14:	c3                   	ret    

c0100c15 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100c15:	55                   	push   %ebp
c0100c16:	89 e5                	mov    %esp,%ebp
c0100c18:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100c1b:	e8 b5 fd ff ff       	call   c01009d5 <print_stackframe>
    return 0;
c0100c20:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c25:	c9                   	leave  
c0100c26:	c3                   	ret    

c0100c27 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100c27:	55                   	push   %ebp
c0100c28:	89 e5                	mov    %esp,%ebp
c0100c2a:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100c2d:	a1 20 34 12 c0       	mov    0xc0123420,%eax
c0100c32:	85 c0                	test   %eax,%eax
c0100c34:	74 02                	je     c0100c38 <__panic+0x11>
        goto panic_dead;
c0100c36:	eb 59                	jmp    c0100c91 <__panic+0x6a>
    }
    is_panic = 1;
c0100c38:	c7 05 20 34 12 c0 01 	movl   $0x1,0xc0123420
c0100c3f:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100c42:	8d 45 14             	lea    0x14(%ebp),%eax
c0100c45:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100c48:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100c4b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100c4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c52:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c56:	c7 04 24 de 8e 10 c0 	movl   $0xc0108ede,(%esp)
c0100c5d:	e8 f5 f6 ff ff       	call   c0100357 <cprintf>
    vcprintf(fmt, ap);
c0100c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c65:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c69:	8b 45 10             	mov    0x10(%ebp),%eax
c0100c6c:	89 04 24             	mov    %eax,(%esp)
c0100c6f:	e8 b0 f6 ff ff       	call   c0100324 <vcprintf>
    cprintf("\n");
c0100c74:	c7 04 24 fa 8e 10 c0 	movl   $0xc0108efa,(%esp)
c0100c7b:	e8 d7 f6 ff ff       	call   c0100357 <cprintf>
    
    cprintf("stack trackback:\n");
c0100c80:	c7 04 24 fc 8e 10 c0 	movl   $0xc0108efc,(%esp)
c0100c87:	e8 cb f6 ff ff       	call   c0100357 <cprintf>
    print_stackframe();
c0100c8c:	e8 44 fd ff ff       	call   c01009d5 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100c91:	e8 fa 11 00 00       	call   c0101e90 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100c96:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100c9d:	e8 a4 fe ff ff       	call   c0100b46 <kmonitor>
    }
c0100ca2:	eb f2                	jmp    c0100c96 <__panic+0x6f>

c0100ca4 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100ca4:	55                   	push   %ebp
c0100ca5:	89 e5                	mov    %esp,%ebp
c0100ca7:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100caa:	8d 45 14             	lea    0x14(%ebp),%eax
c0100cad:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100cb0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100cb3:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100cb7:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cba:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cbe:	c7 04 24 0e 8f 10 c0 	movl   $0xc0108f0e,(%esp)
c0100cc5:	e8 8d f6 ff ff       	call   c0100357 <cprintf>
    vcprintf(fmt, ap);
c0100cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ccd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cd1:	8b 45 10             	mov    0x10(%ebp),%eax
c0100cd4:	89 04 24             	mov    %eax,(%esp)
c0100cd7:	e8 48 f6 ff ff       	call   c0100324 <vcprintf>
    cprintf("\n");
c0100cdc:	c7 04 24 fa 8e 10 c0 	movl   $0xc0108efa,(%esp)
c0100ce3:	e8 6f f6 ff ff       	call   c0100357 <cprintf>
    va_end(ap);
}
c0100ce8:	c9                   	leave  
c0100ce9:	c3                   	ret    

c0100cea <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100cea:	55                   	push   %ebp
c0100ceb:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100ced:	a1 20 34 12 c0       	mov    0xc0123420,%eax
}
c0100cf2:	5d                   	pop    %ebp
c0100cf3:	c3                   	ret    

c0100cf4 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100cf4:	55                   	push   %ebp
c0100cf5:	89 e5                	mov    %esp,%ebp
c0100cf7:	83 ec 28             	sub    $0x28,%esp
c0100cfa:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100d00:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100d04:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100d08:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100d0c:	ee                   	out    %al,(%dx)
c0100d0d:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100d13:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100d17:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100d1b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100d1f:	ee                   	out    %al,(%dx)
c0100d20:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100d26:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100d2a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100d2e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100d32:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100d33:	c7 05 3c 40 12 c0 00 	movl   $0x0,0xc012403c
c0100d3a:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100d3d:	c7 04 24 2c 8f 10 c0 	movl   $0xc0108f2c,(%esp)
c0100d44:	e8 0e f6 ff ff       	call   c0100357 <cprintf>
    pic_enable(IRQ_TIMER);
c0100d49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d50:	e8 99 11 00 00       	call   c0101eee <pic_enable>
}
c0100d55:	c9                   	leave  
c0100d56:	c3                   	ret    

c0100d57 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100d57:	55                   	push   %ebp
c0100d58:	89 e5                	mov    %esp,%ebp
c0100d5a:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100d5d:	9c                   	pushf  
c0100d5e:	58                   	pop    %eax
c0100d5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100d65:	25 00 02 00 00       	and    $0x200,%eax
c0100d6a:	85 c0                	test   %eax,%eax
c0100d6c:	74 0c                	je     c0100d7a <__intr_save+0x23>
        intr_disable();
c0100d6e:	e8 1d 11 00 00       	call   c0101e90 <intr_disable>
        return 1;
c0100d73:	b8 01 00 00 00       	mov    $0x1,%eax
c0100d78:	eb 05                	jmp    c0100d7f <__intr_save+0x28>
    }
    return 0;
c0100d7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d7f:	c9                   	leave  
c0100d80:	c3                   	ret    

c0100d81 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100d81:	55                   	push   %ebp
c0100d82:	89 e5                	mov    %esp,%ebp
c0100d84:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100d87:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100d8b:	74 05                	je     c0100d92 <__intr_restore+0x11>
        intr_enable();
c0100d8d:	e8 f8 10 00 00       	call   c0101e8a <intr_enable>
    }
}
c0100d92:	c9                   	leave  
c0100d93:	c3                   	ret    

c0100d94 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100d94:	55                   	push   %ebp
c0100d95:	89 e5                	mov    %esp,%ebp
c0100d97:	83 ec 10             	sub    $0x10,%esp
c0100d9a:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100da0:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100da4:	89 c2                	mov    %eax,%edx
c0100da6:	ec                   	in     (%dx),%al
c0100da7:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100daa:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100db0:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100db4:	89 c2                	mov    %eax,%edx
c0100db6:	ec                   	in     (%dx),%al
c0100db7:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100dba:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100dc0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100dc4:	89 c2                	mov    %eax,%edx
c0100dc6:	ec                   	in     (%dx),%al
c0100dc7:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100dca:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100dd0:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100dd4:	89 c2                	mov    %eax,%edx
c0100dd6:	ec                   	in     (%dx),%al
c0100dd7:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100dda:	c9                   	leave  
c0100ddb:	c3                   	ret    

c0100ddc <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100ddc:	55                   	push   %ebp
c0100ddd:	89 e5                	mov    %esp,%ebp
c0100ddf:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100de2:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100de9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100dec:	0f b7 00             	movzwl (%eax),%eax
c0100def:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100df3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100df6:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100dfb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100dfe:	0f b7 00             	movzwl (%eax),%eax
c0100e01:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100e05:	74 12                	je     c0100e19 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100e07:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100e0e:	66 c7 05 46 34 12 c0 	movw   $0x3b4,0xc0123446
c0100e15:	b4 03 
c0100e17:	eb 13                	jmp    c0100e2c <cga_init+0x50>
    } else {
        *cp = was;
c0100e19:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e1c:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100e20:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100e23:	66 c7 05 46 34 12 c0 	movw   $0x3d4,0xc0123446
c0100e2a:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100e2c:	0f b7 05 46 34 12 c0 	movzwl 0xc0123446,%eax
c0100e33:	0f b7 c0             	movzwl %ax,%eax
c0100e36:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100e3a:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e3e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100e42:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100e46:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100e47:	0f b7 05 46 34 12 c0 	movzwl 0xc0123446,%eax
c0100e4e:	83 c0 01             	add    $0x1,%eax
c0100e51:	0f b7 c0             	movzwl %ax,%eax
c0100e54:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e58:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100e5c:	89 c2                	mov    %eax,%edx
c0100e5e:	ec                   	in     (%dx),%al
c0100e5f:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100e62:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100e66:	0f b6 c0             	movzbl %al,%eax
c0100e69:	c1 e0 08             	shl    $0x8,%eax
c0100e6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100e6f:	0f b7 05 46 34 12 c0 	movzwl 0xc0123446,%eax
c0100e76:	0f b7 c0             	movzwl %ax,%eax
c0100e79:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100e7d:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e81:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100e85:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100e89:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100e8a:	0f b7 05 46 34 12 c0 	movzwl 0xc0123446,%eax
c0100e91:	83 c0 01             	add    $0x1,%eax
c0100e94:	0f b7 c0             	movzwl %ax,%eax
c0100e97:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e9b:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100e9f:	89 c2                	mov    %eax,%edx
c0100ea1:	ec                   	in     (%dx),%al
c0100ea2:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100ea5:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100ea9:	0f b6 c0             	movzbl %al,%eax
c0100eac:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100eaf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb2:	a3 40 34 12 c0       	mov    %eax,0xc0123440
    crt_pos = pos;
c0100eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100eba:	66 a3 44 34 12 c0    	mov    %ax,0xc0123444
}
c0100ec0:	c9                   	leave  
c0100ec1:	c3                   	ret    

c0100ec2 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100ec2:	55                   	push   %ebp
c0100ec3:	89 e5                	mov    %esp,%ebp
c0100ec5:	83 ec 48             	sub    $0x48,%esp
c0100ec8:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100ece:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ed2:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100ed6:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100eda:	ee                   	out    %al,(%dx)
c0100edb:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100ee1:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100ee5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100ee9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100eed:	ee                   	out    %al,(%dx)
c0100eee:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100ef4:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100ef8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100efc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f00:	ee                   	out    %al,(%dx)
c0100f01:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100f07:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100f0b:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f0f:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f13:	ee                   	out    %al,(%dx)
c0100f14:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100f1a:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100f1e:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f22:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f26:	ee                   	out    %al,(%dx)
c0100f27:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100f2d:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100f31:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100f35:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100f39:	ee                   	out    %al,(%dx)
c0100f3a:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100f40:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0100f44:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100f48:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100f4c:	ee                   	out    %al,(%dx)
c0100f4d:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f53:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0100f57:	89 c2                	mov    %eax,%edx
c0100f59:	ec                   	in     (%dx),%al
c0100f5a:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0100f5d:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0100f61:	3c ff                	cmp    $0xff,%al
c0100f63:	0f 95 c0             	setne  %al
c0100f66:	0f b6 c0             	movzbl %al,%eax
c0100f69:	a3 48 34 12 c0       	mov    %eax,0xc0123448
c0100f6e:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f74:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c0100f78:	89 c2                	mov    %eax,%edx
c0100f7a:	ec                   	in     (%dx),%al
c0100f7b:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0100f7e:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c0100f84:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0100f88:	89 c2                	mov    %eax,%edx
c0100f8a:	ec                   	in     (%dx),%al
c0100f8b:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0100f8e:	a1 48 34 12 c0       	mov    0xc0123448,%eax
c0100f93:	85 c0                	test   %eax,%eax
c0100f95:	74 0c                	je     c0100fa3 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0100f97:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0100f9e:	e8 4b 0f 00 00       	call   c0101eee <pic_enable>
    }
}
c0100fa3:	c9                   	leave  
c0100fa4:	c3                   	ret    

c0100fa5 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0100fa5:	55                   	push   %ebp
c0100fa6:	89 e5                	mov    %esp,%ebp
c0100fa8:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0100fab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0100fb2:	eb 09                	jmp    c0100fbd <lpt_putc_sub+0x18>
        delay();
c0100fb4:	e8 db fd ff ff       	call   c0100d94 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0100fb9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0100fbd:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0100fc3:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100fc7:	89 c2                	mov    %eax,%edx
c0100fc9:	ec                   	in     (%dx),%al
c0100fca:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100fcd:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100fd1:	84 c0                	test   %al,%al
c0100fd3:	78 09                	js     c0100fde <lpt_putc_sub+0x39>
c0100fd5:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0100fdc:	7e d6                	jle    c0100fb4 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0100fde:	8b 45 08             	mov    0x8(%ebp),%eax
c0100fe1:	0f b6 c0             	movzbl %al,%eax
c0100fe4:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c0100fea:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fed:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100ff1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100ff5:	ee                   	out    %al,(%dx)
c0100ff6:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0100ffc:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0101000:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101004:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101008:	ee                   	out    %al,(%dx)
c0101009:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c010100f:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c0101013:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101017:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010101b:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c010101c:	c9                   	leave  
c010101d:	c3                   	ret    

c010101e <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c010101e:	55                   	push   %ebp
c010101f:	89 e5                	mov    %esp,%ebp
c0101021:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101024:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101028:	74 0d                	je     c0101037 <lpt_putc+0x19>
        lpt_putc_sub(c);
c010102a:	8b 45 08             	mov    0x8(%ebp),%eax
c010102d:	89 04 24             	mov    %eax,(%esp)
c0101030:	e8 70 ff ff ff       	call   c0100fa5 <lpt_putc_sub>
c0101035:	eb 24                	jmp    c010105b <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c0101037:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010103e:	e8 62 ff ff ff       	call   c0100fa5 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101043:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010104a:	e8 56 ff ff ff       	call   c0100fa5 <lpt_putc_sub>
        lpt_putc_sub('\b');
c010104f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101056:	e8 4a ff ff ff       	call   c0100fa5 <lpt_putc_sub>
    }
}
c010105b:	c9                   	leave  
c010105c:	c3                   	ret    

c010105d <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c010105d:	55                   	push   %ebp
c010105e:	89 e5                	mov    %esp,%ebp
c0101060:	53                   	push   %ebx
c0101061:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101064:	8b 45 08             	mov    0x8(%ebp),%eax
c0101067:	b0 00                	mov    $0x0,%al
c0101069:	85 c0                	test   %eax,%eax
c010106b:	75 07                	jne    c0101074 <cga_putc+0x17>
        c |= 0x0700;
c010106d:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101074:	8b 45 08             	mov    0x8(%ebp),%eax
c0101077:	0f b6 c0             	movzbl %al,%eax
c010107a:	83 f8 0a             	cmp    $0xa,%eax
c010107d:	74 4c                	je     c01010cb <cga_putc+0x6e>
c010107f:	83 f8 0d             	cmp    $0xd,%eax
c0101082:	74 57                	je     c01010db <cga_putc+0x7e>
c0101084:	83 f8 08             	cmp    $0x8,%eax
c0101087:	0f 85 88 00 00 00    	jne    c0101115 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c010108d:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c0101094:	66 85 c0             	test   %ax,%ax
c0101097:	74 30                	je     c01010c9 <cga_putc+0x6c>
            crt_pos --;
c0101099:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c01010a0:	83 e8 01             	sub    $0x1,%eax
c01010a3:	66 a3 44 34 12 c0    	mov    %ax,0xc0123444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01010a9:	a1 40 34 12 c0       	mov    0xc0123440,%eax
c01010ae:	0f b7 15 44 34 12 c0 	movzwl 0xc0123444,%edx
c01010b5:	0f b7 d2             	movzwl %dx,%edx
c01010b8:	01 d2                	add    %edx,%edx
c01010ba:	01 c2                	add    %eax,%edx
c01010bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01010bf:	b0 00                	mov    $0x0,%al
c01010c1:	83 c8 20             	or     $0x20,%eax
c01010c4:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01010c7:	eb 72                	jmp    c010113b <cga_putc+0xde>
c01010c9:	eb 70                	jmp    c010113b <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c01010cb:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c01010d2:	83 c0 50             	add    $0x50,%eax
c01010d5:	66 a3 44 34 12 c0    	mov    %ax,0xc0123444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01010db:	0f b7 1d 44 34 12 c0 	movzwl 0xc0123444,%ebx
c01010e2:	0f b7 0d 44 34 12 c0 	movzwl 0xc0123444,%ecx
c01010e9:	0f b7 c1             	movzwl %cx,%eax
c01010ec:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c01010f2:	c1 e8 10             	shr    $0x10,%eax
c01010f5:	89 c2                	mov    %eax,%edx
c01010f7:	66 c1 ea 06          	shr    $0x6,%dx
c01010fb:	89 d0                	mov    %edx,%eax
c01010fd:	c1 e0 02             	shl    $0x2,%eax
c0101100:	01 d0                	add    %edx,%eax
c0101102:	c1 e0 04             	shl    $0x4,%eax
c0101105:	29 c1                	sub    %eax,%ecx
c0101107:	89 ca                	mov    %ecx,%edx
c0101109:	89 d8                	mov    %ebx,%eax
c010110b:	29 d0                	sub    %edx,%eax
c010110d:	66 a3 44 34 12 c0    	mov    %ax,0xc0123444
        break;
c0101113:	eb 26                	jmp    c010113b <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101115:	8b 0d 40 34 12 c0    	mov    0xc0123440,%ecx
c010111b:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c0101122:	8d 50 01             	lea    0x1(%eax),%edx
c0101125:	66 89 15 44 34 12 c0 	mov    %dx,0xc0123444
c010112c:	0f b7 c0             	movzwl %ax,%eax
c010112f:	01 c0                	add    %eax,%eax
c0101131:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101134:	8b 45 08             	mov    0x8(%ebp),%eax
c0101137:	66 89 02             	mov    %ax,(%edx)
        break;
c010113a:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c010113b:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c0101142:	66 3d cf 07          	cmp    $0x7cf,%ax
c0101146:	76 5b                	jbe    c01011a3 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101148:	a1 40 34 12 c0       	mov    0xc0123440,%eax
c010114d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101153:	a1 40 34 12 c0       	mov    0xc0123440,%eax
c0101158:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010115f:	00 
c0101160:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101164:	89 04 24             	mov    %eax,(%esp)
c0101167:	e8 71 79 00 00       	call   c0108add <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010116c:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101173:	eb 15                	jmp    c010118a <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101175:	a1 40 34 12 c0       	mov    0xc0123440,%eax
c010117a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010117d:	01 d2                	add    %edx,%edx
c010117f:	01 d0                	add    %edx,%eax
c0101181:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101186:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010118a:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101191:	7e e2                	jle    c0101175 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101193:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c010119a:	83 e8 50             	sub    $0x50,%eax
c010119d:	66 a3 44 34 12 c0    	mov    %ax,0xc0123444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01011a3:	0f b7 05 46 34 12 c0 	movzwl 0xc0123446,%eax
c01011aa:	0f b7 c0             	movzwl %ax,%eax
c01011ad:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c01011b1:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c01011b5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01011b9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01011bd:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c01011be:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c01011c5:	66 c1 e8 08          	shr    $0x8,%ax
c01011c9:	0f b6 c0             	movzbl %al,%eax
c01011cc:	0f b7 15 46 34 12 c0 	movzwl 0xc0123446,%edx
c01011d3:	83 c2 01             	add    $0x1,%edx
c01011d6:	0f b7 d2             	movzwl %dx,%edx
c01011d9:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c01011dd:	88 45 ed             	mov    %al,-0x13(%ebp)
c01011e0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01011e4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01011e8:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c01011e9:	0f b7 05 46 34 12 c0 	movzwl 0xc0123446,%eax
c01011f0:	0f b7 c0             	movzwl %ax,%eax
c01011f3:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01011f7:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c01011fb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01011ff:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101203:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0101204:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c010120b:	0f b6 c0             	movzbl %al,%eax
c010120e:	0f b7 15 46 34 12 c0 	movzwl 0xc0123446,%edx
c0101215:	83 c2 01             	add    $0x1,%edx
c0101218:	0f b7 d2             	movzwl %dx,%edx
c010121b:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c010121f:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101222:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101226:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010122a:	ee                   	out    %al,(%dx)
}
c010122b:	83 c4 34             	add    $0x34,%esp
c010122e:	5b                   	pop    %ebx
c010122f:	5d                   	pop    %ebp
c0101230:	c3                   	ret    

c0101231 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101231:	55                   	push   %ebp
c0101232:	89 e5                	mov    %esp,%ebp
c0101234:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101237:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010123e:	eb 09                	jmp    c0101249 <serial_putc_sub+0x18>
        delay();
c0101240:	e8 4f fb ff ff       	call   c0100d94 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101245:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101249:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010124f:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101253:	89 c2                	mov    %eax,%edx
c0101255:	ec                   	in     (%dx),%al
c0101256:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101259:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010125d:	0f b6 c0             	movzbl %al,%eax
c0101260:	83 e0 20             	and    $0x20,%eax
c0101263:	85 c0                	test   %eax,%eax
c0101265:	75 09                	jne    c0101270 <serial_putc_sub+0x3f>
c0101267:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010126e:	7e d0                	jle    c0101240 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101270:	8b 45 08             	mov    0x8(%ebp),%eax
c0101273:	0f b6 c0             	movzbl %al,%eax
c0101276:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c010127c:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010127f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101283:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101287:	ee                   	out    %al,(%dx)
}
c0101288:	c9                   	leave  
c0101289:	c3                   	ret    

c010128a <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c010128a:	55                   	push   %ebp
c010128b:	89 e5                	mov    %esp,%ebp
c010128d:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101290:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101294:	74 0d                	je     c01012a3 <serial_putc+0x19>
        serial_putc_sub(c);
c0101296:	8b 45 08             	mov    0x8(%ebp),%eax
c0101299:	89 04 24             	mov    %eax,(%esp)
c010129c:	e8 90 ff ff ff       	call   c0101231 <serial_putc_sub>
c01012a1:	eb 24                	jmp    c01012c7 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c01012a3:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01012aa:	e8 82 ff ff ff       	call   c0101231 <serial_putc_sub>
        serial_putc_sub(' ');
c01012af:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01012b6:	e8 76 ff ff ff       	call   c0101231 <serial_putc_sub>
        serial_putc_sub('\b');
c01012bb:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01012c2:	e8 6a ff ff ff       	call   c0101231 <serial_putc_sub>
    }
}
c01012c7:	c9                   	leave  
c01012c8:	c3                   	ret    

c01012c9 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c01012c9:	55                   	push   %ebp
c01012ca:	89 e5                	mov    %esp,%ebp
c01012cc:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c01012cf:	eb 33                	jmp    c0101304 <cons_intr+0x3b>
        if (c != 0) {
c01012d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01012d5:	74 2d                	je     c0101304 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c01012d7:	a1 64 36 12 c0       	mov    0xc0123664,%eax
c01012dc:	8d 50 01             	lea    0x1(%eax),%edx
c01012df:	89 15 64 36 12 c0    	mov    %edx,0xc0123664
c01012e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01012e8:	88 90 60 34 12 c0    	mov    %dl,-0x3fedcba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01012ee:	a1 64 36 12 c0       	mov    0xc0123664,%eax
c01012f3:	3d 00 02 00 00       	cmp    $0x200,%eax
c01012f8:	75 0a                	jne    c0101304 <cons_intr+0x3b>
                cons.wpos = 0;
c01012fa:	c7 05 64 36 12 c0 00 	movl   $0x0,0xc0123664
c0101301:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c0101304:	8b 45 08             	mov    0x8(%ebp),%eax
c0101307:	ff d0                	call   *%eax
c0101309:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010130c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101310:	75 bf                	jne    c01012d1 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c0101312:	c9                   	leave  
c0101313:	c3                   	ret    

c0101314 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101314:	55                   	push   %ebp
c0101315:	89 e5                	mov    %esp,%ebp
c0101317:	83 ec 10             	sub    $0x10,%esp
c010131a:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101320:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101324:	89 c2                	mov    %eax,%edx
c0101326:	ec                   	in     (%dx),%al
c0101327:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010132a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c010132e:	0f b6 c0             	movzbl %al,%eax
c0101331:	83 e0 01             	and    $0x1,%eax
c0101334:	85 c0                	test   %eax,%eax
c0101336:	75 07                	jne    c010133f <serial_proc_data+0x2b>
        return -1;
c0101338:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010133d:	eb 2a                	jmp    c0101369 <serial_proc_data+0x55>
c010133f:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101345:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101349:	89 c2                	mov    %eax,%edx
c010134b:	ec                   	in     (%dx),%al
c010134c:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c010134f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101353:	0f b6 c0             	movzbl %al,%eax
c0101356:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101359:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c010135d:	75 07                	jne    c0101366 <serial_proc_data+0x52>
        c = '\b';
c010135f:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101366:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101369:	c9                   	leave  
c010136a:	c3                   	ret    

c010136b <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c010136b:	55                   	push   %ebp
c010136c:	89 e5                	mov    %esp,%ebp
c010136e:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101371:	a1 48 34 12 c0       	mov    0xc0123448,%eax
c0101376:	85 c0                	test   %eax,%eax
c0101378:	74 0c                	je     c0101386 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c010137a:	c7 04 24 14 13 10 c0 	movl   $0xc0101314,(%esp)
c0101381:	e8 43 ff ff ff       	call   c01012c9 <cons_intr>
    }
}
c0101386:	c9                   	leave  
c0101387:	c3                   	ret    

c0101388 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101388:	55                   	push   %ebp
c0101389:	89 e5                	mov    %esp,%ebp
c010138b:	83 ec 38             	sub    $0x38,%esp
c010138e:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101394:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101398:	89 c2                	mov    %eax,%edx
c010139a:	ec                   	in     (%dx),%al
c010139b:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c010139e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c01013a2:	0f b6 c0             	movzbl %al,%eax
c01013a5:	83 e0 01             	and    $0x1,%eax
c01013a8:	85 c0                	test   %eax,%eax
c01013aa:	75 0a                	jne    c01013b6 <kbd_proc_data+0x2e>
        return -1;
c01013ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013b1:	e9 59 01 00 00       	jmp    c010150f <kbd_proc_data+0x187>
c01013b6:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013bc:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01013c0:	89 c2                	mov    %eax,%edx
c01013c2:	ec                   	in     (%dx),%al
c01013c3:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c01013c6:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c01013ca:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c01013cd:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c01013d1:	75 17                	jne    c01013ea <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c01013d3:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c01013d8:	83 c8 40             	or     $0x40,%eax
c01013db:	a3 68 36 12 c0       	mov    %eax,0xc0123668
        return 0;
c01013e0:	b8 00 00 00 00       	mov    $0x0,%eax
c01013e5:	e9 25 01 00 00       	jmp    c010150f <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c01013ea:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01013ee:	84 c0                	test   %al,%al
c01013f0:	79 47                	jns    c0101439 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01013f2:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c01013f7:	83 e0 40             	and    $0x40,%eax
c01013fa:	85 c0                	test   %eax,%eax
c01013fc:	75 09                	jne    c0101407 <kbd_proc_data+0x7f>
c01013fe:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101402:	83 e0 7f             	and    $0x7f,%eax
c0101405:	eb 04                	jmp    c010140b <kbd_proc_data+0x83>
c0101407:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010140b:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c010140e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101412:	0f b6 80 40 00 12 c0 	movzbl -0x3fedffc0(%eax),%eax
c0101419:	83 c8 40             	or     $0x40,%eax
c010141c:	0f b6 c0             	movzbl %al,%eax
c010141f:	f7 d0                	not    %eax
c0101421:	89 c2                	mov    %eax,%edx
c0101423:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c0101428:	21 d0                	and    %edx,%eax
c010142a:	a3 68 36 12 c0       	mov    %eax,0xc0123668
        return 0;
c010142f:	b8 00 00 00 00       	mov    $0x0,%eax
c0101434:	e9 d6 00 00 00       	jmp    c010150f <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c0101439:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c010143e:	83 e0 40             	and    $0x40,%eax
c0101441:	85 c0                	test   %eax,%eax
c0101443:	74 11                	je     c0101456 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101445:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101449:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c010144e:	83 e0 bf             	and    $0xffffffbf,%eax
c0101451:	a3 68 36 12 c0       	mov    %eax,0xc0123668
    }

    shift |= shiftcode[data];
c0101456:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010145a:	0f b6 80 40 00 12 c0 	movzbl -0x3fedffc0(%eax),%eax
c0101461:	0f b6 d0             	movzbl %al,%edx
c0101464:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c0101469:	09 d0                	or     %edx,%eax
c010146b:	a3 68 36 12 c0       	mov    %eax,0xc0123668
    shift ^= togglecode[data];
c0101470:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101474:	0f b6 80 40 01 12 c0 	movzbl -0x3fedfec0(%eax),%eax
c010147b:	0f b6 d0             	movzbl %al,%edx
c010147e:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c0101483:	31 d0                	xor    %edx,%eax
c0101485:	a3 68 36 12 c0       	mov    %eax,0xc0123668

    c = charcode[shift & (CTL | SHIFT)][data];
c010148a:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c010148f:	83 e0 03             	and    $0x3,%eax
c0101492:	8b 14 85 40 05 12 c0 	mov    -0x3fedfac0(,%eax,4),%edx
c0101499:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010149d:	01 d0                	add    %edx,%eax
c010149f:	0f b6 00             	movzbl (%eax),%eax
c01014a2:	0f b6 c0             	movzbl %al,%eax
c01014a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01014a8:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c01014ad:	83 e0 08             	and    $0x8,%eax
c01014b0:	85 c0                	test   %eax,%eax
c01014b2:	74 22                	je     c01014d6 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c01014b4:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01014b8:	7e 0c                	jle    c01014c6 <kbd_proc_data+0x13e>
c01014ba:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c01014be:	7f 06                	jg     c01014c6 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c01014c0:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c01014c4:	eb 10                	jmp    c01014d6 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c01014c6:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c01014ca:	7e 0a                	jle    c01014d6 <kbd_proc_data+0x14e>
c01014cc:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c01014d0:	7f 04                	jg     c01014d6 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c01014d2:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c01014d6:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c01014db:	f7 d0                	not    %eax
c01014dd:	83 e0 06             	and    $0x6,%eax
c01014e0:	85 c0                	test   %eax,%eax
c01014e2:	75 28                	jne    c010150c <kbd_proc_data+0x184>
c01014e4:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01014eb:	75 1f                	jne    c010150c <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c01014ed:	c7 04 24 47 8f 10 c0 	movl   $0xc0108f47,(%esp)
c01014f4:	e8 5e ee ff ff       	call   c0100357 <cprintf>
c01014f9:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01014ff:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101503:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101507:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c010150b:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c010150c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010150f:	c9                   	leave  
c0101510:	c3                   	ret    

c0101511 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101511:	55                   	push   %ebp
c0101512:	89 e5                	mov    %esp,%ebp
c0101514:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101517:	c7 04 24 88 13 10 c0 	movl   $0xc0101388,(%esp)
c010151e:	e8 a6 fd ff ff       	call   c01012c9 <cons_intr>
}
c0101523:	c9                   	leave  
c0101524:	c3                   	ret    

c0101525 <kbd_init>:

static void
kbd_init(void) {
c0101525:	55                   	push   %ebp
c0101526:	89 e5                	mov    %esp,%ebp
c0101528:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c010152b:	e8 e1 ff ff ff       	call   c0101511 <kbd_intr>
    pic_enable(IRQ_KBD);
c0101530:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101537:	e8 b2 09 00 00       	call   c0101eee <pic_enable>
}
c010153c:	c9                   	leave  
c010153d:	c3                   	ret    

c010153e <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c010153e:	55                   	push   %ebp
c010153f:	89 e5                	mov    %esp,%ebp
c0101541:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101544:	e8 93 f8 ff ff       	call   c0100ddc <cga_init>
    serial_init();
c0101549:	e8 74 f9 ff ff       	call   c0100ec2 <serial_init>
    kbd_init();
c010154e:	e8 d2 ff ff ff       	call   c0101525 <kbd_init>
    if (!serial_exists) {
c0101553:	a1 48 34 12 c0       	mov    0xc0123448,%eax
c0101558:	85 c0                	test   %eax,%eax
c010155a:	75 0c                	jne    c0101568 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c010155c:	c7 04 24 53 8f 10 c0 	movl   $0xc0108f53,(%esp)
c0101563:	e8 ef ed ff ff       	call   c0100357 <cprintf>
    }
}
c0101568:	c9                   	leave  
c0101569:	c3                   	ret    

c010156a <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c010156a:	55                   	push   %ebp
c010156b:	89 e5                	mov    %esp,%ebp
c010156d:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101570:	e8 e2 f7 ff ff       	call   c0100d57 <__intr_save>
c0101575:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101578:	8b 45 08             	mov    0x8(%ebp),%eax
c010157b:	89 04 24             	mov    %eax,(%esp)
c010157e:	e8 9b fa ff ff       	call   c010101e <lpt_putc>
        cga_putc(c);
c0101583:	8b 45 08             	mov    0x8(%ebp),%eax
c0101586:	89 04 24             	mov    %eax,(%esp)
c0101589:	e8 cf fa ff ff       	call   c010105d <cga_putc>
        serial_putc(c);
c010158e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101591:	89 04 24             	mov    %eax,(%esp)
c0101594:	e8 f1 fc ff ff       	call   c010128a <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101599:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010159c:	89 04 24             	mov    %eax,(%esp)
c010159f:	e8 dd f7 ff ff       	call   c0100d81 <__intr_restore>
}
c01015a4:	c9                   	leave  
c01015a5:	c3                   	ret    

c01015a6 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c01015a6:	55                   	push   %ebp
c01015a7:	89 e5                	mov    %esp,%ebp
c01015a9:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c01015ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c01015b3:	e8 9f f7 ff ff       	call   c0100d57 <__intr_save>
c01015b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c01015bb:	e8 ab fd ff ff       	call   c010136b <serial_intr>
        kbd_intr();
c01015c0:	e8 4c ff ff ff       	call   c0101511 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c01015c5:	8b 15 60 36 12 c0    	mov    0xc0123660,%edx
c01015cb:	a1 64 36 12 c0       	mov    0xc0123664,%eax
c01015d0:	39 c2                	cmp    %eax,%edx
c01015d2:	74 31                	je     c0101605 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c01015d4:	a1 60 36 12 c0       	mov    0xc0123660,%eax
c01015d9:	8d 50 01             	lea    0x1(%eax),%edx
c01015dc:	89 15 60 36 12 c0    	mov    %edx,0xc0123660
c01015e2:	0f b6 80 60 34 12 c0 	movzbl -0x3fedcba0(%eax),%eax
c01015e9:	0f b6 c0             	movzbl %al,%eax
c01015ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01015ef:	a1 60 36 12 c0       	mov    0xc0123660,%eax
c01015f4:	3d 00 02 00 00       	cmp    $0x200,%eax
c01015f9:	75 0a                	jne    c0101605 <cons_getc+0x5f>
                cons.rpos = 0;
c01015fb:	c7 05 60 36 12 c0 00 	movl   $0x0,0xc0123660
c0101602:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101605:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101608:	89 04 24             	mov    %eax,(%esp)
c010160b:	e8 71 f7 ff ff       	call   c0100d81 <__intr_restore>
    return c;
c0101610:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101613:	c9                   	leave  
c0101614:	c3                   	ret    

c0101615 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0101615:	55                   	push   %ebp
c0101616:	89 e5                	mov    %esp,%ebp
c0101618:	83 ec 14             	sub    $0x14,%esp
c010161b:	8b 45 08             	mov    0x8(%ebp),%eax
c010161e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0101622:	90                   	nop
c0101623:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101627:	83 c0 07             	add    $0x7,%eax
c010162a:	0f b7 c0             	movzwl %ax,%eax
c010162d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101631:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101635:	89 c2                	mov    %eax,%edx
c0101637:	ec                   	in     (%dx),%al
c0101638:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010163b:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010163f:	0f b6 c0             	movzbl %al,%eax
c0101642:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0101645:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101648:	25 80 00 00 00       	and    $0x80,%eax
c010164d:	85 c0                	test   %eax,%eax
c010164f:	75 d2                	jne    c0101623 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0101651:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0101655:	74 11                	je     c0101668 <ide_wait_ready+0x53>
c0101657:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010165a:	83 e0 21             	and    $0x21,%eax
c010165d:	85 c0                	test   %eax,%eax
c010165f:	74 07                	je     c0101668 <ide_wait_ready+0x53>
        return -1;
c0101661:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101666:	eb 05                	jmp    c010166d <ide_wait_ready+0x58>
    }
    return 0;
c0101668:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010166d:	c9                   	leave  
c010166e:	c3                   	ret    

c010166f <ide_init>:

void
ide_init(void) {
c010166f:	55                   	push   %ebp
c0101670:	89 e5                	mov    %esp,%ebp
c0101672:	57                   	push   %edi
c0101673:	53                   	push   %ebx
c0101674:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c010167a:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0101680:	e9 d6 02 00 00       	jmp    c010195b <ide_init+0x2ec>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0101685:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101689:	c1 e0 03             	shl    $0x3,%eax
c010168c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101693:	29 c2                	sub    %eax,%edx
c0101695:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c010169b:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c010169e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01016a2:	66 d1 e8             	shr    %ax
c01016a5:	0f b7 c0             	movzwl %ax,%eax
c01016a8:	0f b7 04 85 74 8f 10 	movzwl -0x3fef708c(,%eax,4),%eax
c01016af:	c0 
c01016b0:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c01016b4:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01016b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01016bf:	00 
c01016c0:	89 04 24             	mov    %eax,(%esp)
c01016c3:	e8 4d ff ff ff       	call   c0101615 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c01016c8:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01016cc:	83 e0 01             	and    $0x1,%eax
c01016cf:	c1 e0 04             	shl    $0x4,%eax
c01016d2:	83 c8 e0             	or     $0xffffffe0,%eax
c01016d5:	0f b6 c0             	movzbl %al,%eax
c01016d8:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01016dc:	83 c2 06             	add    $0x6,%edx
c01016df:	0f b7 d2             	movzwl %dx,%edx
c01016e2:	66 89 55 d2          	mov    %dx,-0x2e(%ebp)
c01016e6:	88 45 d1             	mov    %al,-0x2f(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016e9:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01016ed:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01016f1:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01016f2:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01016f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01016fd:	00 
c01016fe:	89 04 24             	mov    %eax,(%esp)
c0101701:	e8 0f ff ff ff       	call   c0101615 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0101706:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010170a:	83 c0 07             	add    $0x7,%eax
c010170d:	0f b7 c0             	movzwl %ax,%eax
c0101710:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0101714:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c0101718:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c010171c:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101720:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0101721:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101725:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010172c:	00 
c010172d:	89 04 24             	mov    %eax,(%esp)
c0101730:	e8 e0 fe ff ff       	call   c0101615 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0101735:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101739:	83 c0 07             	add    $0x7,%eax
c010173c:	0f b7 c0             	movzwl %ax,%eax
c010173f:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101743:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c0101747:	89 c2                	mov    %eax,%edx
c0101749:	ec                   	in     (%dx),%al
c010174a:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c010174d:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101751:	84 c0                	test   %al,%al
c0101753:	0f 84 f7 01 00 00    	je     c0101950 <ide_init+0x2e1>
c0101759:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010175d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101764:	00 
c0101765:	89 04 24             	mov    %eax,(%esp)
c0101768:	e8 a8 fe ff ff       	call   c0101615 <ide_wait_ready>
c010176d:	85 c0                	test   %eax,%eax
c010176f:	0f 85 db 01 00 00    	jne    c0101950 <ide_init+0x2e1>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0101775:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101779:	c1 e0 03             	shl    $0x3,%eax
c010177c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101783:	29 c2                	sub    %eax,%edx
c0101785:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c010178b:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c010178e:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101792:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0101795:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c010179b:	89 45 c0             	mov    %eax,-0x40(%ebp)
c010179e:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c01017a5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01017a8:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c01017ab:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01017ae:	89 cb                	mov    %ecx,%ebx
c01017b0:	89 df                	mov    %ebx,%edi
c01017b2:	89 c1                	mov    %eax,%ecx
c01017b4:	fc                   	cld    
c01017b5:	f2 6d                	repnz insl (%dx),%es:(%edi)
c01017b7:	89 c8                	mov    %ecx,%eax
c01017b9:	89 fb                	mov    %edi,%ebx
c01017bb:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c01017be:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c01017c1:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c01017c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c01017ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01017cd:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c01017d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c01017d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01017d9:	25 00 00 00 04       	and    $0x4000000,%eax
c01017de:	85 c0                	test   %eax,%eax
c01017e0:	74 0e                	je     c01017f0 <ide_init+0x181>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c01017e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01017e5:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c01017eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01017ee:	eb 09                	jmp    c01017f9 <ide_init+0x18a>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c01017f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01017f3:	8b 40 78             	mov    0x78(%eax),%eax
c01017f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c01017f9:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01017fd:	c1 e0 03             	shl    $0x3,%eax
c0101800:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101807:	29 c2                	sub    %eax,%edx
c0101809:	81 c2 80 36 12 c0    	add    $0xc0123680,%edx
c010180f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101812:	89 42 04             	mov    %eax,0x4(%edx)
        ide_devices[ideno].size = sectors;
c0101815:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101819:	c1 e0 03             	shl    $0x3,%eax
c010181c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101823:	29 c2                	sub    %eax,%edx
c0101825:	81 c2 80 36 12 c0    	add    $0xc0123680,%edx
c010182b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010182e:	89 42 08             	mov    %eax,0x8(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0101831:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101834:	83 c0 62             	add    $0x62,%eax
c0101837:	0f b7 00             	movzwl (%eax),%eax
c010183a:	0f b7 c0             	movzwl %ax,%eax
c010183d:	25 00 02 00 00       	and    $0x200,%eax
c0101842:	85 c0                	test   %eax,%eax
c0101844:	75 24                	jne    c010186a <ide_init+0x1fb>
c0101846:	c7 44 24 0c 7c 8f 10 	movl   $0xc0108f7c,0xc(%esp)
c010184d:	c0 
c010184e:	c7 44 24 08 bf 8f 10 	movl   $0xc0108fbf,0x8(%esp)
c0101855:	c0 
c0101856:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c010185d:	00 
c010185e:	c7 04 24 d4 8f 10 c0 	movl   $0xc0108fd4,(%esp)
c0101865:	e8 bd f3 ff ff       	call   c0100c27 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c010186a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010186e:	c1 e0 03             	shl    $0x3,%eax
c0101871:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101878:	29 c2                	sub    %eax,%edx
c010187a:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c0101880:	83 c0 0c             	add    $0xc,%eax
c0101883:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101886:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101889:	83 c0 36             	add    $0x36,%eax
c010188c:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c010188f:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0101896:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010189d:	eb 34                	jmp    c01018d3 <ide_init+0x264>
            model[i] = data[i + 1], model[i + 1] = data[i];
c010189f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01018a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01018a5:	01 c2                	add    %eax,%edx
c01018a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01018aa:	8d 48 01             	lea    0x1(%eax),%ecx
c01018ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01018b0:	01 c8                	add    %ecx,%eax
c01018b2:	0f b6 00             	movzbl (%eax),%eax
c01018b5:	88 02                	mov    %al,(%edx)
c01018b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01018ba:	8d 50 01             	lea    0x1(%eax),%edx
c01018bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01018c0:	01 c2                	add    %eax,%edx
c01018c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01018c5:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c01018c8:	01 c8                	add    %ecx,%eax
c01018ca:	0f b6 00             	movzbl (%eax),%eax
c01018cd:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c01018cf:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c01018d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01018d6:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c01018d9:	72 c4                	jb     c010189f <ide_init+0x230>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c01018db:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01018de:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01018e1:	01 d0                	add    %edx,%eax
c01018e3:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c01018e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01018e9:	8d 50 ff             	lea    -0x1(%eax),%edx
c01018ec:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01018ef:	85 c0                	test   %eax,%eax
c01018f1:	74 0f                	je     c0101902 <ide_init+0x293>
c01018f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01018f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01018f9:	01 d0                	add    %edx,%eax
c01018fb:	0f b6 00             	movzbl (%eax),%eax
c01018fe:	3c 20                	cmp    $0x20,%al
c0101900:	74 d9                	je     c01018db <ide_init+0x26c>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0101902:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101906:	c1 e0 03             	shl    $0x3,%eax
c0101909:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101910:	29 c2                	sub    %eax,%edx
c0101912:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c0101918:	8d 48 0c             	lea    0xc(%eax),%ecx
c010191b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010191f:	c1 e0 03             	shl    $0x3,%eax
c0101922:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101929:	29 c2                	sub    %eax,%edx
c010192b:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c0101931:	8b 50 08             	mov    0x8(%eax),%edx
c0101934:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101938:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010193c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101940:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101944:	c7 04 24 e6 8f 10 c0 	movl   $0xc0108fe6,(%esp)
c010194b:	e8 07 ea ff ff       	call   c0100357 <cprintf>

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101950:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101954:	83 c0 01             	add    $0x1,%eax
c0101957:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c010195b:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c0101960:	0f 86 1f fd ff ff    	jbe    c0101685 <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101966:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c010196d:	e8 7c 05 00 00       	call   c0101eee <pic_enable>
    pic_enable(IRQ_IDE2);
c0101972:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101979:	e8 70 05 00 00       	call   c0101eee <pic_enable>
}
c010197e:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101984:	5b                   	pop    %ebx
c0101985:	5f                   	pop    %edi
c0101986:	5d                   	pop    %ebp
c0101987:	c3                   	ret    

c0101988 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101988:	55                   	push   %ebp
c0101989:	89 e5                	mov    %esp,%ebp
c010198b:	83 ec 04             	sub    $0x4,%esp
c010198e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101991:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101995:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c010199a:	77 24                	ja     c01019c0 <ide_device_valid+0x38>
c010199c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c01019a0:	c1 e0 03             	shl    $0x3,%eax
c01019a3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01019aa:	29 c2                	sub    %eax,%edx
c01019ac:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c01019b2:	0f b6 00             	movzbl (%eax),%eax
c01019b5:	84 c0                	test   %al,%al
c01019b7:	74 07                	je     c01019c0 <ide_device_valid+0x38>
c01019b9:	b8 01 00 00 00       	mov    $0x1,%eax
c01019be:	eb 05                	jmp    c01019c5 <ide_device_valid+0x3d>
c01019c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01019c5:	c9                   	leave  
c01019c6:	c3                   	ret    

c01019c7 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c01019c7:	55                   	push   %ebp
c01019c8:	89 e5                	mov    %esp,%ebp
c01019ca:	83 ec 08             	sub    $0x8,%esp
c01019cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01019d0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c01019d4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c01019d8:	89 04 24             	mov    %eax,(%esp)
c01019db:	e8 a8 ff ff ff       	call   c0101988 <ide_device_valid>
c01019e0:	85 c0                	test   %eax,%eax
c01019e2:	74 1b                	je     c01019ff <ide_device_size+0x38>
        return ide_devices[ideno].size;
c01019e4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c01019e8:	c1 e0 03             	shl    $0x3,%eax
c01019eb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01019f2:	29 c2                	sub    %eax,%edx
c01019f4:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c01019fa:	8b 40 08             	mov    0x8(%eax),%eax
c01019fd:	eb 05                	jmp    c0101a04 <ide_device_size+0x3d>
    }
    return 0;
c01019ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101a04:	c9                   	leave  
c0101a05:	c3                   	ret    

c0101a06 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101a06:	55                   	push   %ebp
c0101a07:	89 e5                	mov    %esp,%ebp
c0101a09:	57                   	push   %edi
c0101a0a:	53                   	push   %ebx
c0101a0b:	83 ec 50             	sub    $0x50,%esp
c0101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a11:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101a15:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101a1c:	77 24                	ja     c0101a42 <ide_read_secs+0x3c>
c0101a1e:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101a23:	77 1d                	ja     c0101a42 <ide_read_secs+0x3c>
c0101a25:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101a29:	c1 e0 03             	shl    $0x3,%eax
c0101a2c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101a33:	29 c2                	sub    %eax,%edx
c0101a35:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c0101a3b:	0f b6 00             	movzbl (%eax),%eax
c0101a3e:	84 c0                	test   %al,%al
c0101a40:	75 24                	jne    c0101a66 <ide_read_secs+0x60>
c0101a42:	c7 44 24 0c 04 90 10 	movl   $0xc0109004,0xc(%esp)
c0101a49:	c0 
c0101a4a:	c7 44 24 08 bf 8f 10 	movl   $0xc0108fbf,0x8(%esp)
c0101a51:	c0 
c0101a52:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101a59:	00 
c0101a5a:	c7 04 24 d4 8f 10 c0 	movl   $0xc0108fd4,(%esp)
c0101a61:	e8 c1 f1 ff ff       	call   c0100c27 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101a66:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101a6d:	77 0f                	ja     c0101a7e <ide_read_secs+0x78>
c0101a6f:	8b 45 14             	mov    0x14(%ebp),%eax
c0101a72:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101a75:	01 d0                	add    %edx,%eax
c0101a77:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101a7c:	76 24                	jbe    c0101aa2 <ide_read_secs+0x9c>
c0101a7e:	c7 44 24 0c 2c 90 10 	movl   $0xc010902c,0xc(%esp)
c0101a85:	c0 
c0101a86:	c7 44 24 08 bf 8f 10 	movl   $0xc0108fbf,0x8(%esp)
c0101a8d:	c0 
c0101a8e:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101a95:	00 
c0101a96:	c7 04 24 d4 8f 10 c0 	movl   $0xc0108fd4,(%esp)
c0101a9d:	e8 85 f1 ff ff       	call   c0100c27 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101aa2:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101aa6:	66 d1 e8             	shr    %ax
c0101aa9:	0f b7 c0             	movzwl %ax,%eax
c0101aac:	0f b7 04 85 74 8f 10 	movzwl -0x3fef708c(,%eax,4),%eax
c0101ab3:	c0 
c0101ab4:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101ab8:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101abc:	66 d1 e8             	shr    %ax
c0101abf:	0f b7 c0             	movzwl %ax,%eax
c0101ac2:	0f b7 04 85 76 8f 10 	movzwl -0x3fef708a(,%eax,4),%eax
c0101ac9:	c0 
c0101aca:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101ace:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101ad2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101ad9:	00 
c0101ada:	89 04 24             	mov    %eax,(%esp)
c0101add:	e8 33 fb ff ff       	call   c0101615 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101ae2:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101ae6:	83 c0 02             	add    $0x2,%eax
c0101ae9:	0f b7 c0             	movzwl %ax,%eax
c0101aec:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101af0:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101af4:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101af8:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101afc:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101afd:	8b 45 14             	mov    0x14(%ebp),%eax
c0101b00:	0f b6 c0             	movzbl %al,%eax
c0101b03:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101b07:	83 c2 02             	add    $0x2,%edx
c0101b0a:	0f b7 d2             	movzwl %dx,%edx
c0101b0d:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101b11:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101b14:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101b18:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101b1c:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b20:	0f b6 c0             	movzbl %al,%eax
c0101b23:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101b27:	83 c2 03             	add    $0x3,%edx
c0101b2a:	0f b7 d2             	movzwl %dx,%edx
c0101b2d:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101b31:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101b34:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101b38:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101b3c:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b40:	c1 e8 08             	shr    $0x8,%eax
c0101b43:	0f b6 c0             	movzbl %al,%eax
c0101b46:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101b4a:	83 c2 04             	add    $0x4,%edx
c0101b4d:	0f b7 d2             	movzwl %dx,%edx
c0101b50:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101b54:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101b57:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101b5b:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101b5f:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101b60:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b63:	c1 e8 10             	shr    $0x10,%eax
c0101b66:	0f b6 c0             	movzbl %al,%eax
c0101b69:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101b6d:	83 c2 05             	add    $0x5,%edx
c0101b70:	0f b7 d2             	movzwl %dx,%edx
c0101b73:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101b77:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101b7a:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101b7e:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101b82:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101b83:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101b87:	83 e0 01             	and    $0x1,%eax
c0101b8a:	c1 e0 04             	shl    $0x4,%eax
c0101b8d:	89 c2                	mov    %eax,%edx
c0101b8f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b92:	c1 e8 18             	shr    $0x18,%eax
c0101b95:	83 e0 0f             	and    $0xf,%eax
c0101b98:	09 d0                	or     %edx,%eax
c0101b9a:	83 c8 e0             	or     $0xffffffe0,%eax
c0101b9d:	0f b6 c0             	movzbl %al,%eax
c0101ba0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ba4:	83 c2 06             	add    $0x6,%edx
c0101ba7:	0f b7 d2             	movzwl %dx,%edx
c0101baa:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101bae:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101bb1:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101bb5:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101bb9:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101bba:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101bbe:	83 c0 07             	add    $0x7,%eax
c0101bc1:	0f b7 c0             	movzwl %ax,%eax
c0101bc4:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101bc8:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c0101bcc:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101bd0:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101bd4:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101bd5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101bdc:	eb 5a                	jmp    c0101c38 <ide_read_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101bde:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101be2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101be9:	00 
c0101bea:	89 04 24             	mov    %eax,(%esp)
c0101bed:	e8 23 fa ff ff       	call   c0101615 <ide_wait_ready>
c0101bf2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101bf5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101bf9:	74 02                	je     c0101bfd <ide_read_secs+0x1f7>
            goto out;
c0101bfb:	eb 41                	jmp    c0101c3e <ide_read_secs+0x238>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101bfd:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101c01:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101c04:	8b 45 10             	mov    0x10(%ebp),%eax
c0101c07:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101c0a:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101c11:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101c14:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101c17:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101c1a:	89 cb                	mov    %ecx,%ebx
c0101c1c:	89 df                	mov    %ebx,%edi
c0101c1e:	89 c1                	mov    %eax,%ecx
c0101c20:	fc                   	cld    
c0101c21:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101c23:	89 c8                	mov    %ecx,%eax
c0101c25:	89 fb                	mov    %edi,%ebx
c0101c27:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101c2a:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101c2d:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101c31:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101c38:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101c3c:	75 a0                	jne    c0101bde <ide_read_secs+0x1d8>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0101c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101c41:	83 c4 50             	add    $0x50,%esp
c0101c44:	5b                   	pop    %ebx
c0101c45:	5f                   	pop    %edi
c0101c46:	5d                   	pop    %ebp
c0101c47:	c3                   	ret    

c0101c48 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101c48:	55                   	push   %ebp
c0101c49:	89 e5                	mov    %esp,%ebp
c0101c4b:	56                   	push   %esi
c0101c4c:	53                   	push   %ebx
c0101c4d:	83 ec 50             	sub    $0x50,%esp
c0101c50:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c53:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101c57:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101c5e:	77 24                	ja     c0101c84 <ide_write_secs+0x3c>
c0101c60:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101c65:	77 1d                	ja     c0101c84 <ide_write_secs+0x3c>
c0101c67:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c6b:	c1 e0 03             	shl    $0x3,%eax
c0101c6e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101c75:	29 c2                	sub    %eax,%edx
c0101c77:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c0101c7d:	0f b6 00             	movzbl (%eax),%eax
c0101c80:	84 c0                	test   %al,%al
c0101c82:	75 24                	jne    c0101ca8 <ide_write_secs+0x60>
c0101c84:	c7 44 24 0c 04 90 10 	movl   $0xc0109004,0xc(%esp)
c0101c8b:	c0 
c0101c8c:	c7 44 24 08 bf 8f 10 	movl   $0xc0108fbf,0x8(%esp)
c0101c93:	c0 
c0101c94:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101c9b:	00 
c0101c9c:	c7 04 24 d4 8f 10 c0 	movl   $0xc0108fd4,(%esp)
c0101ca3:	e8 7f ef ff ff       	call   c0100c27 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101ca8:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101caf:	77 0f                	ja     c0101cc0 <ide_write_secs+0x78>
c0101cb1:	8b 45 14             	mov    0x14(%ebp),%eax
c0101cb4:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101cb7:	01 d0                	add    %edx,%eax
c0101cb9:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101cbe:	76 24                	jbe    c0101ce4 <ide_write_secs+0x9c>
c0101cc0:	c7 44 24 0c 2c 90 10 	movl   $0xc010902c,0xc(%esp)
c0101cc7:	c0 
c0101cc8:	c7 44 24 08 bf 8f 10 	movl   $0xc0108fbf,0x8(%esp)
c0101ccf:	c0 
c0101cd0:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101cd7:	00 
c0101cd8:	c7 04 24 d4 8f 10 c0 	movl   $0xc0108fd4,(%esp)
c0101cdf:	e8 43 ef ff ff       	call   c0100c27 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101ce4:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101ce8:	66 d1 e8             	shr    %ax
c0101ceb:	0f b7 c0             	movzwl %ax,%eax
c0101cee:	0f b7 04 85 74 8f 10 	movzwl -0x3fef708c(,%eax,4),%eax
c0101cf5:	c0 
c0101cf6:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101cfa:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101cfe:	66 d1 e8             	shr    %ax
c0101d01:	0f b7 c0             	movzwl %ax,%eax
c0101d04:	0f b7 04 85 76 8f 10 	movzwl -0x3fef708a(,%eax,4),%eax
c0101d0b:	c0 
c0101d0c:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101d10:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d14:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101d1b:	00 
c0101d1c:	89 04 24             	mov    %eax,(%esp)
c0101d1f:	e8 f1 f8 ff ff       	call   c0101615 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101d24:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101d28:	83 c0 02             	add    $0x2,%eax
c0101d2b:	0f b7 c0             	movzwl %ax,%eax
c0101d2e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101d32:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101d36:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101d3a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101d3e:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101d3f:	8b 45 14             	mov    0x14(%ebp),%eax
c0101d42:	0f b6 c0             	movzbl %al,%eax
c0101d45:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d49:	83 c2 02             	add    $0x2,%edx
c0101d4c:	0f b7 d2             	movzwl %dx,%edx
c0101d4f:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101d53:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101d56:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101d5a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101d5e:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101d5f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d62:	0f b6 c0             	movzbl %al,%eax
c0101d65:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d69:	83 c2 03             	add    $0x3,%edx
c0101d6c:	0f b7 d2             	movzwl %dx,%edx
c0101d6f:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101d73:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101d76:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101d7a:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101d7e:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d82:	c1 e8 08             	shr    $0x8,%eax
c0101d85:	0f b6 c0             	movzbl %al,%eax
c0101d88:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d8c:	83 c2 04             	add    $0x4,%edx
c0101d8f:	0f b7 d2             	movzwl %dx,%edx
c0101d92:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101d96:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101d99:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101d9d:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101da1:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101da2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101da5:	c1 e8 10             	shr    $0x10,%eax
c0101da8:	0f b6 c0             	movzbl %al,%eax
c0101dab:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101daf:	83 c2 05             	add    $0x5,%edx
c0101db2:	0f b7 d2             	movzwl %dx,%edx
c0101db5:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101db9:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101dbc:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101dc0:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101dc4:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101dc5:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101dc9:	83 e0 01             	and    $0x1,%eax
c0101dcc:	c1 e0 04             	shl    $0x4,%eax
c0101dcf:	89 c2                	mov    %eax,%edx
c0101dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101dd4:	c1 e8 18             	shr    $0x18,%eax
c0101dd7:	83 e0 0f             	and    $0xf,%eax
c0101dda:	09 d0                	or     %edx,%eax
c0101ddc:	83 c8 e0             	or     $0xffffffe0,%eax
c0101ddf:	0f b6 c0             	movzbl %al,%eax
c0101de2:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101de6:	83 c2 06             	add    $0x6,%edx
c0101de9:	0f b7 d2             	movzwl %dx,%edx
c0101dec:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101df0:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101df3:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101df7:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101dfb:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101dfc:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101e00:	83 c0 07             	add    $0x7,%eax
c0101e03:	0f b7 c0             	movzwl %ax,%eax
c0101e06:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101e0a:	c6 45 d5 30          	movb   $0x30,-0x2b(%ebp)
c0101e0e:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101e12:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101e16:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101e17:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101e1e:	eb 5a                	jmp    c0101e7a <ide_write_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101e20:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101e24:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101e2b:	00 
c0101e2c:	89 04 24             	mov    %eax,(%esp)
c0101e2f:	e8 e1 f7 ff ff       	call   c0101615 <ide_wait_ready>
c0101e34:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101e37:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101e3b:	74 02                	je     c0101e3f <ide_write_secs+0x1f7>
            goto out;
c0101e3d:	eb 41                	jmp    c0101e80 <ide_write_secs+0x238>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0101e3f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101e43:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101e46:	8b 45 10             	mov    0x10(%ebp),%eax
c0101e49:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101e4c:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c0101e53:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101e56:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101e59:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101e5c:	89 cb                	mov    %ecx,%ebx
c0101e5e:	89 de                	mov    %ebx,%esi
c0101e60:	89 c1                	mov    %eax,%ecx
c0101e62:	fc                   	cld    
c0101e63:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0101e65:	89 c8                	mov    %ecx,%eax
c0101e67:	89 f3                	mov    %esi,%ebx
c0101e69:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101e6c:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101e6f:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101e73:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101e7a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101e7e:	75 a0                	jne    c0101e20 <ide_write_secs+0x1d8>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0101e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101e83:	83 c4 50             	add    $0x50,%esp
c0101e86:	5b                   	pop    %ebx
c0101e87:	5e                   	pop    %esi
c0101e88:	5d                   	pop    %ebp
c0101e89:	c3                   	ret    

c0101e8a <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101e8a:	55                   	push   %ebp
c0101e8b:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c0101e8d:	fb                   	sti    
    sti();
}
c0101e8e:	5d                   	pop    %ebp
c0101e8f:	c3                   	ret    

c0101e90 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101e90:	55                   	push   %ebp
c0101e91:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c0101e93:	fa                   	cli    
    cli();
}
c0101e94:	5d                   	pop    %ebp
c0101e95:	c3                   	ret    

c0101e96 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101e96:	55                   	push   %ebp
c0101e97:	89 e5                	mov    %esp,%ebp
c0101e99:	83 ec 14             	sub    $0x14,%esp
c0101e9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e9f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101ea3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101ea7:	66 a3 50 05 12 c0    	mov    %ax,0xc0120550
    if (did_init) {
c0101ead:	a1 60 37 12 c0       	mov    0xc0123760,%eax
c0101eb2:	85 c0                	test   %eax,%eax
c0101eb4:	74 36                	je     c0101eec <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0101eb6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101eba:	0f b6 c0             	movzbl %al,%eax
c0101ebd:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101ec3:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ec6:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101eca:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101ece:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101ecf:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101ed3:	66 c1 e8 08          	shr    $0x8,%ax
c0101ed7:	0f b6 c0             	movzbl %al,%eax
c0101eda:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101ee0:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101ee3:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101ee7:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101eeb:	ee                   	out    %al,(%dx)
    }
}
c0101eec:	c9                   	leave  
c0101eed:	c3                   	ret    

c0101eee <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101eee:	55                   	push   %ebp
c0101eef:	89 e5                	mov    %esp,%ebp
c0101ef1:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101ef4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ef7:	ba 01 00 00 00       	mov    $0x1,%edx
c0101efc:	89 c1                	mov    %eax,%ecx
c0101efe:	d3 e2                	shl    %cl,%edx
c0101f00:	89 d0                	mov    %edx,%eax
c0101f02:	f7 d0                	not    %eax
c0101f04:	89 c2                	mov    %eax,%edx
c0101f06:	0f b7 05 50 05 12 c0 	movzwl 0xc0120550,%eax
c0101f0d:	21 d0                	and    %edx,%eax
c0101f0f:	0f b7 c0             	movzwl %ax,%eax
c0101f12:	89 04 24             	mov    %eax,(%esp)
c0101f15:	e8 7c ff ff ff       	call   c0101e96 <pic_setmask>
}
c0101f1a:	c9                   	leave  
c0101f1b:	c3                   	ret    

c0101f1c <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101f1c:	55                   	push   %ebp
c0101f1d:	89 e5                	mov    %esp,%ebp
c0101f1f:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101f22:	c7 05 60 37 12 c0 01 	movl   $0x1,0xc0123760
c0101f29:	00 00 00 
c0101f2c:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101f32:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c0101f36:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101f3a:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101f3e:	ee                   	out    %al,(%dx)
c0101f3f:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101f45:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c0101f49:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101f4d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101f51:	ee                   	out    %al,(%dx)
c0101f52:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0101f58:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0101f5c:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101f60:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101f64:	ee                   	out    %al,(%dx)
c0101f65:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c0101f6b:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c0101f6f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101f73:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f77:	ee                   	out    %al,(%dx)
c0101f78:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c0101f7e:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c0101f82:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101f86:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101f8a:	ee                   	out    %al,(%dx)
c0101f8b:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c0101f91:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c0101f95:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101f99:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101f9d:	ee                   	out    %al,(%dx)
c0101f9e:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c0101fa4:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c0101fa8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101fac:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101fb0:	ee                   	out    %al,(%dx)
c0101fb1:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c0101fb7:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c0101fbb:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101fbf:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101fc3:	ee                   	out    %al,(%dx)
c0101fc4:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c0101fca:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c0101fce:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101fd2:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101fd6:	ee                   	out    %al,(%dx)
c0101fd7:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c0101fdd:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c0101fe1:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101fe5:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101fe9:	ee                   	out    %al,(%dx)
c0101fea:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c0101ff0:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c0101ff4:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101ff8:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101ffc:	ee                   	out    %al,(%dx)
c0101ffd:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0102003:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c0102007:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c010200b:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c010200f:	ee                   	out    %al,(%dx)
c0102010:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c0102016:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c010201a:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c010201e:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0102022:	ee                   	out    %al,(%dx)
c0102023:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c0102029:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c010202d:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0102031:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0102035:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0102036:	0f b7 05 50 05 12 c0 	movzwl 0xc0120550,%eax
c010203d:	66 83 f8 ff          	cmp    $0xffff,%ax
c0102041:	74 12                	je     c0102055 <pic_init+0x139>
        pic_setmask(irq_mask);
c0102043:	0f b7 05 50 05 12 c0 	movzwl 0xc0120550,%eax
c010204a:	0f b7 c0             	movzwl %ax,%eax
c010204d:	89 04 24             	mov    %eax,(%esp)
c0102050:	e8 41 fe ff ff       	call   c0101e96 <pic_setmask>
    }
}
c0102055:	c9                   	leave  
c0102056:	c3                   	ret    

c0102057 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0102057:	55                   	push   %ebp
c0102058:	89 e5                	mov    %esp,%ebp
c010205a:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c010205d:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102064:	00 
c0102065:	c7 04 24 80 90 10 c0 	movl   $0xc0109080,(%esp)
c010206c:	e8 e6 e2 ff ff       	call   c0100357 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c0102071:	c7 04 24 8a 90 10 c0 	movl   $0xc010908a,(%esp)
c0102078:	e8 da e2 ff ff       	call   c0100357 <cprintf>
    panic("EOT: kernel seems ok.");
c010207d:	c7 44 24 08 98 90 10 	movl   $0xc0109098,0x8(%esp)
c0102084:	c0 
c0102085:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c010208c:	00 
c010208d:	c7 04 24 ae 90 10 c0 	movl   $0xc01090ae,(%esp)
c0102094:	e8 8e eb ff ff       	call   c0100c27 <__panic>

c0102099 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102099:	55                   	push   %ebp
c010209a:	89 e5                	mov    %esp,%ebp
c010209c:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c010209f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01020a6:	e9 c3 00 00 00       	jmp    c010216e <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01020ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01020ae:	8b 04 85 e0 05 12 c0 	mov    -0x3fedfa20(,%eax,4),%eax
c01020b5:	89 c2                	mov    %eax,%edx
c01020b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01020ba:	66 89 14 c5 80 37 12 	mov    %dx,-0x3fedc880(,%eax,8)
c01020c1:	c0 
c01020c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01020c5:	66 c7 04 c5 82 37 12 	movw   $0x8,-0x3fedc87e(,%eax,8)
c01020cc:	c0 08 00 
c01020cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01020d2:	0f b6 14 c5 84 37 12 	movzbl -0x3fedc87c(,%eax,8),%edx
c01020d9:	c0 
c01020da:	83 e2 e0             	and    $0xffffffe0,%edx
c01020dd:	88 14 c5 84 37 12 c0 	mov    %dl,-0x3fedc87c(,%eax,8)
c01020e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01020e7:	0f b6 14 c5 84 37 12 	movzbl -0x3fedc87c(,%eax,8),%edx
c01020ee:	c0 
c01020ef:	83 e2 1f             	and    $0x1f,%edx
c01020f2:	88 14 c5 84 37 12 c0 	mov    %dl,-0x3fedc87c(,%eax,8)
c01020f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01020fc:	0f b6 14 c5 85 37 12 	movzbl -0x3fedc87b(,%eax,8),%edx
c0102103:	c0 
c0102104:	83 e2 f0             	and    $0xfffffff0,%edx
c0102107:	83 ca 0e             	or     $0xe,%edx
c010210a:	88 14 c5 85 37 12 c0 	mov    %dl,-0x3fedc87b(,%eax,8)
c0102111:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102114:	0f b6 14 c5 85 37 12 	movzbl -0x3fedc87b(,%eax,8),%edx
c010211b:	c0 
c010211c:	83 e2 ef             	and    $0xffffffef,%edx
c010211f:	88 14 c5 85 37 12 c0 	mov    %dl,-0x3fedc87b(,%eax,8)
c0102126:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102129:	0f b6 14 c5 85 37 12 	movzbl -0x3fedc87b(,%eax,8),%edx
c0102130:	c0 
c0102131:	83 e2 9f             	and    $0xffffff9f,%edx
c0102134:	88 14 c5 85 37 12 c0 	mov    %dl,-0x3fedc87b(,%eax,8)
c010213b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010213e:	0f b6 14 c5 85 37 12 	movzbl -0x3fedc87b(,%eax,8),%edx
c0102145:	c0 
c0102146:	83 ca 80             	or     $0xffffff80,%edx
c0102149:	88 14 c5 85 37 12 c0 	mov    %dl,-0x3fedc87b(,%eax,8)
c0102150:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102153:	8b 04 85 e0 05 12 c0 	mov    -0x3fedfa20(,%eax,4),%eax
c010215a:	c1 e8 10             	shr    $0x10,%eax
c010215d:	89 c2                	mov    %eax,%edx
c010215f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102162:	66 89 14 c5 86 37 12 	mov    %dx,-0x3fedc87a(,%eax,8)
c0102169:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c010216a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010216e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102171:	3d ff 00 00 00       	cmp    $0xff,%eax
c0102176:	0f 86 2f ff ff ff    	jbe    c01020ab <idt_init+0x12>
c010217c:	c7 45 f8 60 05 12 c0 	movl   $0xc0120560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0102183:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102186:	0f 01 18             	lidtl  (%eax)
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
c0102189:	c9                   	leave  
c010218a:	c3                   	ret    

c010218b <trapname>:

static const char *
trapname(int trapno) {
c010218b:	55                   	push   %ebp
c010218c:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c010218e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102191:	83 f8 13             	cmp    $0x13,%eax
c0102194:	77 0c                	ja     c01021a2 <trapname+0x17>
        return excnames[trapno];
c0102196:	8b 45 08             	mov    0x8(%ebp),%eax
c0102199:	8b 04 85 80 94 10 c0 	mov    -0x3fef6b80(,%eax,4),%eax
c01021a0:	eb 18                	jmp    c01021ba <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01021a2:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01021a6:	7e 0d                	jle    c01021b5 <trapname+0x2a>
c01021a8:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01021ac:	7f 07                	jg     c01021b5 <trapname+0x2a>
        return "Hardware Interrupt";
c01021ae:	b8 bf 90 10 c0       	mov    $0xc01090bf,%eax
c01021b3:	eb 05                	jmp    c01021ba <trapname+0x2f>
    }
    return "(unknown trap)";
c01021b5:	b8 d2 90 10 c0       	mov    $0xc01090d2,%eax
}
c01021ba:	5d                   	pop    %ebp
c01021bb:	c3                   	ret    

c01021bc <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01021bc:	55                   	push   %ebp
c01021bd:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01021bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01021c2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01021c6:	66 83 f8 08          	cmp    $0x8,%ax
c01021ca:	0f 94 c0             	sete   %al
c01021cd:	0f b6 c0             	movzbl %al,%eax
}
c01021d0:	5d                   	pop    %ebp
c01021d1:	c3                   	ret    

c01021d2 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01021d2:	55                   	push   %ebp
c01021d3:	89 e5                	mov    %esp,%ebp
c01021d5:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01021d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01021db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01021df:	c7 04 24 13 91 10 c0 	movl   $0xc0109113,(%esp)
c01021e6:	e8 6c e1 ff ff       	call   c0100357 <cprintf>
    print_regs(&tf->tf_regs);
c01021eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01021ee:	89 04 24             	mov    %eax,(%esp)
c01021f1:	e8 a1 01 00 00       	call   c0102397 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c01021f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01021f9:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c01021fd:	0f b7 c0             	movzwl %ax,%eax
c0102200:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102204:	c7 04 24 24 91 10 c0 	movl   $0xc0109124,(%esp)
c010220b:	e8 47 e1 ff ff       	call   c0100357 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0102210:	8b 45 08             	mov    0x8(%ebp),%eax
c0102213:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0102217:	0f b7 c0             	movzwl %ax,%eax
c010221a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010221e:	c7 04 24 37 91 10 c0 	movl   $0xc0109137,(%esp)
c0102225:	e8 2d e1 ff ff       	call   c0100357 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c010222a:	8b 45 08             	mov    0x8(%ebp),%eax
c010222d:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0102231:	0f b7 c0             	movzwl %ax,%eax
c0102234:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102238:	c7 04 24 4a 91 10 c0 	movl   $0xc010914a,(%esp)
c010223f:	e8 13 e1 ff ff       	call   c0100357 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0102244:	8b 45 08             	mov    0x8(%ebp),%eax
c0102247:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c010224b:	0f b7 c0             	movzwl %ax,%eax
c010224e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102252:	c7 04 24 5d 91 10 c0 	movl   $0xc010915d,(%esp)
c0102259:	e8 f9 e0 ff ff       	call   c0100357 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c010225e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102261:	8b 40 30             	mov    0x30(%eax),%eax
c0102264:	89 04 24             	mov    %eax,(%esp)
c0102267:	e8 1f ff ff ff       	call   c010218b <trapname>
c010226c:	8b 55 08             	mov    0x8(%ebp),%edx
c010226f:	8b 52 30             	mov    0x30(%edx),%edx
c0102272:	89 44 24 08          	mov    %eax,0x8(%esp)
c0102276:	89 54 24 04          	mov    %edx,0x4(%esp)
c010227a:	c7 04 24 70 91 10 c0 	movl   $0xc0109170,(%esp)
c0102281:	e8 d1 e0 ff ff       	call   c0100357 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0102286:	8b 45 08             	mov    0x8(%ebp),%eax
c0102289:	8b 40 34             	mov    0x34(%eax),%eax
c010228c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102290:	c7 04 24 82 91 10 c0 	movl   $0xc0109182,(%esp)
c0102297:	e8 bb e0 ff ff       	call   c0100357 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c010229c:	8b 45 08             	mov    0x8(%ebp),%eax
c010229f:	8b 40 38             	mov    0x38(%eax),%eax
c01022a2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022a6:	c7 04 24 91 91 10 c0 	movl   $0xc0109191,(%esp)
c01022ad:	e8 a5 e0 ff ff       	call   c0100357 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01022b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01022b5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01022b9:	0f b7 c0             	movzwl %ax,%eax
c01022bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022c0:	c7 04 24 a0 91 10 c0 	movl   $0xc01091a0,(%esp)
c01022c7:	e8 8b e0 ff ff       	call   c0100357 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01022cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01022cf:	8b 40 40             	mov    0x40(%eax),%eax
c01022d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022d6:	c7 04 24 b3 91 10 c0 	movl   $0xc01091b3,(%esp)
c01022dd:	e8 75 e0 ff ff       	call   c0100357 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01022e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01022e9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01022f0:	eb 3e                	jmp    c0102330 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c01022f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01022f5:	8b 50 40             	mov    0x40(%eax),%edx
c01022f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01022fb:	21 d0                	and    %edx,%eax
c01022fd:	85 c0                	test   %eax,%eax
c01022ff:	74 28                	je     c0102329 <print_trapframe+0x157>
c0102301:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102304:	8b 04 85 80 05 12 c0 	mov    -0x3fedfa80(,%eax,4),%eax
c010230b:	85 c0                	test   %eax,%eax
c010230d:	74 1a                	je     c0102329 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c010230f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102312:	8b 04 85 80 05 12 c0 	mov    -0x3fedfa80(,%eax,4),%eax
c0102319:	89 44 24 04          	mov    %eax,0x4(%esp)
c010231d:	c7 04 24 c2 91 10 c0 	movl   $0xc01091c2,(%esp)
c0102324:	e8 2e e0 ff ff       	call   c0100357 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102329:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010232d:	d1 65 f0             	shll   -0x10(%ebp)
c0102330:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102333:	83 f8 17             	cmp    $0x17,%eax
c0102336:	76 ba                	jbe    c01022f2 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102338:	8b 45 08             	mov    0x8(%ebp),%eax
c010233b:	8b 40 40             	mov    0x40(%eax),%eax
c010233e:	25 00 30 00 00       	and    $0x3000,%eax
c0102343:	c1 e8 0c             	shr    $0xc,%eax
c0102346:	89 44 24 04          	mov    %eax,0x4(%esp)
c010234a:	c7 04 24 c6 91 10 c0 	movl   $0xc01091c6,(%esp)
c0102351:	e8 01 e0 ff ff       	call   c0100357 <cprintf>

    if (!trap_in_kernel(tf)) {
c0102356:	8b 45 08             	mov    0x8(%ebp),%eax
c0102359:	89 04 24             	mov    %eax,(%esp)
c010235c:	e8 5b fe ff ff       	call   c01021bc <trap_in_kernel>
c0102361:	85 c0                	test   %eax,%eax
c0102363:	75 30                	jne    c0102395 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0102365:	8b 45 08             	mov    0x8(%ebp),%eax
c0102368:	8b 40 44             	mov    0x44(%eax),%eax
c010236b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010236f:	c7 04 24 cf 91 10 c0 	movl   $0xc01091cf,(%esp)
c0102376:	e8 dc df ff ff       	call   c0100357 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c010237b:	8b 45 08             	mov    0x8(%ebp),%eax
c010237e:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0102382:	0f b7 c0             	movzwl %ax,%eax
c0102385:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102389:	c7 04 24 de 91 10 c0 	movl   $0xc01091de,(%esp)
c0102390:	e8 c2 df ff ff       	call   c0100357 <cprintf>
    }
}
c0102395:	c9                   	leave  
c0102396:	c3                   	ret    

c0102397 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0102397:	55                   	push   %ebp
c0102398:	89 e5                	mov    %esp,%ebp
c010239a:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c010239d:	8b 45 08             	mov    0x8(%ebp),%eax
c01023a0:	8b 00                	mov    (%eax),%eax
c01023a2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023a6:	c7 04 24 f1 91 10 c0 	movl   $0xc01091f1,(%esp)
c01023ad:	e8 a5 df ff ff       	call   c0100357 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01023b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01023b5:	8b 40 04             	mov    0x4(%eax),%eax
c01023b8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023bc:	c7 04 24 00 92 10 c0 	movl   $0xc0109200,(%esp)
c01023c3:	e8 8f df ff ff       	call   c0100357 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01023c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01023cb:	8b 40 08             	mov    0x8(%eax),%eax
c01023ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023d2:	c7 04 24 0f 92 10 c0 	movl   $0xc010920f,(%esp)
c01023d9:	e8 79 df ff ff       	call   c0100357 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01023de:	8b 45 08             	mov    0x8(%ebp),%eax
c01023e1:	8b 40 0c             	mov    0xc(%eax),%eax
c01023e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023e8:	c7 04 24 1e 92 10 c0 	movl   $0xc010921e,(%esp)
c01023ef:	e8 63 df ff ff       	call   c0100357 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c01023f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01023f7:	8b 40 10             	mov    0x10(%eax),%eax
c01023fa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023fe:	c7 04 24 2d 92 10 c0 	movl   $0xc010922d,(%esp)
c0102405:	e8 4d df ff ff       	call   c0100357 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c010240a:	8b 45 08             	mov    0x8(%ebp),%eax
c010240d:	8b 40 14             	mov    0x14(%eax),%eax
c0102410:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102414:	c7 04 24 3c 92 10 c0 	movl   $0xc010923c,(%esp)
c010241b:	e8 37 df ff ff       	call   c0100357 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0102420:	8b 45 08             	mov    0x8(%ebp),%eax
c0102423:	8b 40 18             	mov    0x18(%eax),%eax
c0102426:	89 44 24 04          	mov    %eax,0x4(%esp)
c010242a:	c7 04 24 4b 92 10 c0 	movl   $0xc010924b,(%esp)
c0102431:	e8 21 df ff ff       	call   c0100357 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102436:	8b 45 08             	mov    0x8(%ebp),%eax
c0102439:	8b 40 1c             	mov    0x1c(%eax),%eax
c010243c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102440:	c7 04 24 5a 92 10 c0 	movl   $0xc010925a,(%esp)
c0102447:	e8 0b df ff ff       	call   c0100357 <cprintf>
}
c010244c:	c9                   	leave  
c010244d:	c3                   	ret    

c010244e <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c010244e:	55                   	push   %ebp
c010244f:	89 e5                	mov    %esp,%ebp
c0102451:	53                   	push   %ebx
c0102452:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102455:	8b 45 08             	mov    0x8(%ebp),%eax
c0102458:	8b 40 34             	mov    0x34(%eax),%eax
c010245b:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010245e:	85 c0                	test   %eax,%eax
c0102460:	74 07                	je     c0102469 <print_pgfault+0x1b>
c0102462:	b9 69 92 10 c0       	mov    $0xc0109269,%ecx
c0102467:	eb 05                	jmp    c010246e <print_pgfault+0x20>
c0102469:	b9 7a 92 10 c0       	mov    $0xc010927a,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c010246e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102471:	8b 40 34             	mov    0x34(%eax),%eax
c0102474:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102477:	85 c0                	test   %eax,%eax
c0102479:	74 07                	je     c0102482 <print_pgfault+0x34>
c010247b:	ba 57 00 00 00       	mov    $0x57,%edx
c0102480:	eb 05                	jmp    c0102487 <print_pgfault+0x39>
c0102482:	ba 52 00 00 00       	mov    $0x52,%edx
            (tf->tf_err & 4) ? 'U' : 'K',
c0102487:	8b 45 08             	mov    0x8(%ebp),%eax
c010248a:	8b 40 34             	mov    0x34(%eax),%eax
c010248d:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102490:	85 c0                	test   %eax,%eax
c0102492:	74 07                	je     c010249b <print_pgfault+0x4d>
c0102494:	b8 55 00 00 00       	mov    $0x55,%eax
c0102499:	eb 05                	jmp    c01024a0 <print_pgfault+0x52>
c010249b:	b8 4b 00 00 00       	mov    $0x4b,%eax
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01024a0:	0f 20 d3             	mov    %cr2,%ebx
c01024a3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
    return cr2;
c01024a6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
c01024a9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01024ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01024b1:	89 44 24 08          	mov    %eax,0x8(%esp)
c01024b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01024b9:	c7 04 24 88 92 10 c0 	movl   $0xc0109288,(%esp)
c01024c0:	e8 92 de ff ff       	call   c0100357 <cprintf>
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c01024c5:	83 c4 34             	add    $0x34,%esp
c01024c8:	5b                   	pop    %ebx
c01024c9:	5d                   	pop    %ebp
c01024ca:	c3                   	ret    

c01024cb <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01024cb:	55                   	push   %ebp
c01024cc:	89 e5                	mov    %esp,%ebp
c01024ce:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c01024d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01024d4:	89 04 24             	mov    %eax,(%esp)
c01024d7:	e8 72 ff ff ff       	call   c010244e <print_pgfault>
    if (check_mm_struct != NULL) {
c01024dc:	a1 2c 41 12 c0       	mov    0xc012412c,%eax
c01024e1:	85 c0                	test   %eax,%eax
c01024e3:	74 28                	je     c010250d <pgfault_handler+0x42>
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01024e5:	0f 20 d0             	mov    %cr2,%eax
c01024e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01024eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c01024ee:	89 c1                	mov    %eax,%ecx
c01024f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01024f3:	8b 50 34             	mov    0x34(%eax),%edx
c01024f6:	a1 2c 41 12 c0       	mov    0xc012412c,%eax
c01024fb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01024ff:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102503:	89 04 24             	mov    %eax,(%esp)
c0102506:	e8 44 57 00 00       	call   c0107c4f <do_pgfault>
c010250b:	eb 1c                	jmp    c0102529 <pgfault_handler+0x5e>
    }
    panic("unhandled page fault.\n");
c010250d:	c7 44 24 08 ab 92 10 	movl   $0xc01092ab,0x8(%esp)
c0102514:	c0 
c0102515:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
c010251c:	00 
c010251d:	c7 04 24 ae 90 10 c0 	movl   $0xc01090ae,(%esp)
c0102524:	e8 fe e6 ff ff       	call   c0100c27 <__panic>
}
c0102529:	c9                   	leave  
c010252a:	c3                   	ret    

c010252b <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c010252b:	55                   	push   %ebp
c010252c:	89 e5                	mov    %esp,%ebp
c010252e:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c0102531:	8b 45 08             	mov    0x8(%ebp),%eax
c0102534:	8b 40 30             	mov    0x30(%eax),%eax
c0102537:	83 f8 24             	cmp    $0x24,%eax
c010253a:	0f 84 c2 00 00 00    	je     c0102602 <trap_dispatch+0xd7>
c0102540:	83 f8 24             	cmp    $0x24,%eax
c0102543:	77 18                	ja     c010255d <trap_dispatch+0x32>
c0102545:	83 f8 20             	cmp    $0x20,%eax
c0102548:	74 7d                	je     c01025c7 <trap_dispatch+0x9c>
c010254a:	83 f8 21             	cmp    $0x21,%eax
c010254d:	0f 84 d5 00 00 00    	je     c0102628 <trap_dispatch+0xfd>
c0102553:	83 f8 0e             	cmp    $0xe,%eax
c0102556:	74 28                	je     c0102580 <trap_dispatch+0x55>
c0102558:	e9 0d 01 00 00       	jmp    c010266a <trap_dispatch+0x13f>
c010255d:	83 f8 2e             	cmp    $0x2e,%eax
c0102560:	0f 82 04 01 00 00    	jb     c010266a <trap_dispatch+0x13f>
c0102566:	83 f8 2f             	cmp    $0x2f,%eax
c0102569:	0f 86 33 01 00 00    	jbe    c01026a2 <trap_dispatch+0x177>
c010256f:	83 e8 78             	sub    $0x78,%eax
c0102572:	83 f8 01             	cmp    $0x1,%eax
c0102575:	0f 87 ef 00 00 00    	ja     c010266a <trap_dispatch+0x13f>
c010257b:	e9 ce 00 00 00       	jmp    c010264e <trap_dispatch+0x123>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c0102580:	8b 45 08             	mov    0x8(%ebp),%eax
c0102583:	89 04 24             	mov    %eax,(%esp)
c0102586:	e8 40 ff ff ff       	call   c01024cb <pgfault_handler>
c010258b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010258e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102592:	74 2e                	je     c01025c2 <trap_dispatch+0x97>
            print_trapframe(tf);
c0102594:	8b 45 08             	mov    0x8(%ebp),%eax
c0102597:	89 04 24             	mov    %eax,(%esp)
c010259a:	e8 33 fc ff ff       	call   c01021d2 <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c010259f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01025a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01025a6:	c7 44 24 08 c2 92 10 	movl   $0xc01092c2,0x8(%esp)
c01025ad:	c0 
c01025ae:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c01025b5:	00 
c01025b6:	c7 04 24 ae 90 10 c0 	movl   $0xc01090ae,(%esp)
c01025bd:	e8 65 e6 ff ff       	call   c0100c27 <__panic>
        }
        break;
c01025c2:	e9 dc 00 00 00       	jmp    c01026a3 <trap_dispatch+0x178>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c01025c7:	a1 3c 40 12 c0       	mov    0xc012403c,%eax
c01025cc:	83 c0 01             	add    $0x1,%eax
c01025cf:	a3 3c 40 12 c0       	mov    %eax,0xc012403c
        if (ticks % TICK_NUM == 0) {
c01025d4:	8b 0d 3c 40 12 c0    	mov    0xc012403c,%ecx
c01025da:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c01025df:	89 c8                	mov    %ecx,%eax
c01025e1:	f7 e2                	mul    %edx
c01025e3:	89 d0                	mov    %edx,%eax
c01025e5:	c1 e8 05             	shr    $0x5,%eax
c01025e8:	6b c0 64             	imul   $0x64,%eax,%eax
c01025eb:	29 c1                	sub    %eax,%ecx
c01025ed:	89 c8                	mov    %ecx,%eax
c01025ef:	85 c0                	test   %eax,%eax
c01025f1:	75 0a                	jne    c01025fd <trap_dispatch+0xd2>
            print_ticks();
c01025f3:	e8 5f fa ff ff       	call   c0102057 <print_ticks>
        }
        break;
c01025f8:	e9 a6 00 00 00       	jmp    c01026a3 <trap_dispatch+0x178>
c01025fd:	e9 a1 00 00 00       	jmp    c01026a3 <trap_dispatch+0x178>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0102602:	e8 9f ef ff ff       	call   c01015a6 <cons_getc>
c0102607:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c010260a:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c010260e:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102612:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102616:	89 44 24 04          	mov    %eax,0x4(%esp)
c010261a:	c7 04 24 dd 92 10 c0 	movl   $0xc01092dd,(%esp)
c0102621:	e8 31 dd ff ff       	call   c0100357 <cprintf>
        break;
c0102626:	eb 7b                	jmp    c01026a3 <trap_dispatch+0x178>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0102628:	e8 79 ef ff ff       	call   c01015a6 <cons_getc>
c010262d:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0102630:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102634:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102638:	89 54 24 08          	mov    %edx,0x8(%esp)
c010263c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102640:	c7 04 24 ef 92 10 c0 	movl   $0xc01092ef,(%esp)
c0102647:	e8 0b dd ff ff       	call   c0100357 <cprintf>
        break;
c010264c:	eb 55                	jmp    c01026a3 <trap_dispatch+0x178>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c010264e:	c7 44 24 08 fe 92 10 	movl   $0xc01092fe,0x8(%esp)
c0102655:	c0 
c0102656:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c010265d:	00 
c010265e:	c7 04 24 ae 90 10 c0 	movl   $0xc01090ae,(%esp)
c0102665:	e8 bd e5 ff ff       	call   c0100c27 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c010266a:	8b 45 08             	mov    0x8(%ebp),%eax
c010266d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102671:	0f b7 c0             	movzwl %ax,%eax
c0102674:	83 e0 03             	and    $0x3,%eax
c0102677:	85 c0                	test   %eax,%eax
c0102679:	75 28                	jne    c01026a3 <trap_dispatch+0x178>
            print_trapframe(tf);
c010267b:	8b 45 08             	mov    0x8(%ebp),%eax
c010267e:	89 04 24             	mov    %eax,(%esp)
c0102681:	e8 4c fb ff ff       	call   c01021d2 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0102686:	c7 44 24 08 0e 93 10 	movl   $0xc010930e,0x8(%esp)
c010268d:	c0 
c010268e:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0102695:	00 
c0102696:	c7 04 24 ae 90 10 c0 	movl   $0xc01090ae,(%esp)
c010269d:	e8 85 e5 ff ff       	call   c0100c27 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c01026a2:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c01026a3:	c9                   	leave  
c01026a4:	c3                   	ret    

c01026a5 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c01026a5:	55                   	push   %ebp
c01026a6:	89 e5                	mov    %esp,%ebp
c01026a8:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c01026ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01026ae:	89 04 24             	mov    %eax,(%esp)
c01026b1:	e8 75 fe ff ff       	call   c010252b <trap_dispatch>
}
c01026b6:	c9                   	leave  
c01026b7:	c3                   	ret    

c01026b8 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c01026b8:	1e                   	push   %ds
    pushl %es
c01026b9:	06                   	push   %es
    pushl %fs
c01026ba:	0f a0                	push   %fs
    pushl %gs
c01026bc:	0f a8                	push   %gs
    pushal
c01026be:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c01026bf:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c01026c4:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c01026c6:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c01026c8:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c01026c9:	e8 d7 ff ff ff       	call   c01026a5 <trap>

    # pop the pushed stack pointer
    popl %esp
c01026ce:	5c                   	pop    %esp

c01026cf <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c01026cf:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c01026d0:	0f a9                	pop    %gs
    popl %fs
c01026d2:	0f a1                	pop    %fs
    popl %es
c01026d4:	07                   	pop    %es
    popl %ds
c01026d5:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c01026d6:	83 c4 08             	add    $0x8,%esp
    iret
c01026d9:	cf                   	iret   

c01026da <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c01026da:	6a 00                	push   $0x0
  pushl $0
c01026dc:	6a 00                	push   $0x0
  jmp __alltraps
c01026de:	e9 d5 ff ff ff       	jmp    c01026b8 <__alltraps>

c01026e3 <vector1>:
.globl vector1
vector1:
  pushl $0
c01026e3:	6a 00                	push   $0x0
  pushl $1
c01026e5:	6a 01                	push   $0x1
  jmp __alltraps
c01026e7:	e9 cc ff ff ff       	jmp    c01026b8 <__alltraps>

c01026ec <vector2>:
.globl vector2
vector2:
  pushl $0
c01026ec:	6a 00                	push   $0x0
  pushl $2
c01026ee:	6a 02                	push   $0x2
  jmp __alltraps
c01026f0:	e9 c3 ff ff ff       	jmp    c01026b8 <__alltraps>

c01026f5 <vector3>:
.globl vector3
vector3:
  pushl $0
c01026f5:	6a 00                	push   $0x0
  pushl $3
c01026f7:	6a 03                	push   $0x3
  jmp __alltraps
c01026f9:	e9 ba ff ff ff       	jmp    c01026b8 <__alltraps>

c01026fe <vector4>:
.globl vector4
vector4:
  pushl $0
c01026fe:	6a 00                	push   $0x0
  pushl $4
c0102700:	6a 04                	push   $0x4
  jmp __alltraps
c0102702:	e9 b1 ff ff ff       	jmp    c01026b8 <__alltraps>

c0102707 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102707:	6a 00                	push   $0x0
  pushl $5
c0102709:	6a 05                	push   $0x5
  jmp __alltraps
c010270b:	e9 a8 ff ff ff       	jmp    c01026b8 <__alltraps>

c0102710 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102710:	6a 00                	push   $0x0
  pushl $6
c0102712:	6a 06                	push   $0x6
  jmp __alltraps
c0102714:	e9 9f ff ff ff       	jmp    c01026b8 <__alltraps>

c0102719 <vector7>:
.globl vector7
vector7:
  pushl $0
c0102719:	6a 00                	push   $0x0
  pushl $7
c010271b:	6a 07                	push   $0x7
  jmp __alltraps
c010271d:	e9 96 ff ff ff       	jmp    c01026b8 <__alltraps>

c0102722 <vector8>:
.globl vector8
vector8:
  pushl $8
c0102722:	6a 08                	push   $0x8
  jmp __alltraps
c0102724:	e9 8f ff ff ff       	jmp    c01026b8 <__alltraps>

c0102729 <vector9>:
.globl vector9
vector9:
  pushl $0
c0102729:	6a 00                	push   $0x0
  pushl $9
c010272b:	6a 09                	push   $0x9
  jmp __alltraps
c010272d:	e9 86 ff ff ff       	jmp    c01026b8 <__alltraps>

c0102732 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102732:	6a 0a                	push   $0xa
  jmp __alltraps
c0102734:	e9 7f ff ff ff       	jmp    c01026b8 <__alltraps>

c0102739 <vector11>:
.globl vector11
vector11:
  pushl $11
c0102739:	6a 0b                	push   $0xb
  jmp __alltraps
c010273b:	e9 78 ff ff ff       	jmp    c01026b8 <__alltraps>

c0102740 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102740:	6a 0c                	push   $0xc
  jmp __alltraps
c0102742:	e9 71 ff ff ff       	jmp    c01026b8 <__alltraps>

c0102747 <vector13>:
.globl vector13
vector13:
  pushl $13
c0102747:	6a 0d                	push   $0xd
  jmp __alltraps
c0102749:	e9 6a ff ff ff       	jmp    c01026b8 <__alltraps>

c010274e <vector14>:
.globl vector14
vector14:
  pushl $14
c010274e:	6a 0e                	push   $0xe
  jmp __alltraps
c0102750:	e9 63 ff ff ff       	jmp    c01026b8 <__alltraps>

c0102755 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102755:	6a 00                	push   $0x0
  pushl $15
c0102757:	6a 0f                	push   $0xf
  jmp __alltraps
c0102759:	e9 5a ff ff ff       	jmp    c01026b8 <__alltraps>

c010275e <vector16>:
.globl vector16
vector16:
  pushl $0
c010275e:	6a 00                	push   $0x0
  pushl $16
c0102760:	6a 10                	push   $0x10
  jmp __alltraps
c0102762:	e9 51 ff ff ff       	jmp    c01026b8 <__alltraps>

c0102767 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102767:	6a 11                	push   $0x11
  jmp __alltraps
c0102769:	e9 4a ff ff ff       	jmp    c01026b8 <__alltraps>

c010276e <vector18>:
.globl vector18
vector18:
  pushl $0
c010276e:	6a 00                	push   $0x0
  pushl $18
c0102770:	6a 12                	push   $0x12
  jmp __alltraps
c0102772:	e9 41 ff ff ff       	jmp    c01026b8 <__alltraps>

c0102777 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102777:	6a 00                	push   $0x0
  pushl $19
c0102779:	6a 13                	push   $0x13
  jmp __alltraps
c010277b:	e9 38 ff ff ff       	jmp    c01026b8 <__alltraps>

c0102780 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102780:	6a 00                	push   $0x0
  pushl $20
c0102782:	6a 14                	push   $0x14
  jmp __alltraps
c0102784:	e9 2f ff ff ff       	jmp    c01026b8 <__alltraps>

c0102789 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102789:	6a 00                	push   $0x0
  pushl $21
c010278b:	6a 15                	push   $0x15
  jmp __alltraps
c010278d:	e9 26 ff ff ff       	jmp    c01026b8 <__alltraps>

c0102792 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102792:	6a 00                	push   $0x0
  pushl $22
c0102794:	6a 16                	push   $0x16
  jmp __alltraps
c0102796:	e9 1d ff ff ff       	jmp    c01026b8 <__alltraps>

c010279b <vector23>:
.globl vector23
vector23:
  pushl $0
c010279b:	6a 00                	push   $0x0
  pushl $23
c010279d:	6a 17                	push   $0x17
  jmp __alltraps
c010279f:	e9 14 ff ff ff       	jmp    c01026b8 <__alltraps>

c01027a4 <vector24>:
.globl vector24
vector24:
  pushl $0
c01027a4:	6a 00                	push   $0x0
  pushl $24
c01027a6:	6a 18                	push   $0x18
  jmp __alltraps
c01027a8:	e9 0b ff ff ff       	jmp    c01026b8 <__alltraps>

c01027ad <vector25>:
.globl vector25
vector25:
  pushl $0
c01027ad:	6a 00                	push   $0x0
  pushl $25
c01027af:	6a 19                	push   $0x19
  jmp __alltraps
c01027b1:	e9 02 ff ff ff       	jmp    c01026b8 <__alltraps>

c01027b6 <vector26>:
.globl vector26
vector26:
  pushl $0
c01027b6:	6a 00                	push   $0x0
  pushl $26
c01027b8:	6a 1a                	push   $0x1a
  jmp __alltraps
c01027ba:	e9 f9 fe ff ff       	jmp    c01026b8 <__alltraps>

c01027bf <vector27>:
.globl vector27
vector27:
  pushl $0
c01027bf:	6a 00                	push   $0x0
  pushl $27
c01027c1:	6a 1b                	push   $0x1b
  jmp __alltraps
c01027c3:	e9 f0 fe ff ff       	jmp    c01026b8 <__alltraps>

c01027c8 <vector28>:
.globl vector28
vector28:
  pushl $0
c01027c8:	6a 00                	push   $0x0
  pushl $28
c01027ca:	6a 1c                	push   $0x1c
  jmp __alltraps
c01027cc:	e9 e7 fe ff ff       	jmp    c01026b8 <__alltraps>

c01027d1 <vector29>:
.globl vector29
vector29:
  pushl $0
c01027d1:	6a 00                	push   $0x0
  pushl $29
c01027d3:	6a 1d                	push   $0x1d
  jmp __alltraps
c01027d5:	e9 de fe ff ff       	jmp    c01026b8 <__alltraps>

c01027da <vector30>:
.globl vector30
vector30:
  pushl $0
c01027da:	6a 00                	push   $0x0
  pushl $30
c01027dc:	6a 1e                	push   $0x1e
  jmp __alltraps
c01027de:	e9 d5 fe ff ff       	jmp    c01026b8 <__alltraps>

c01027e3 <vector31>:
.globl vector31
vector31:
  pushl $0
c01027e3:	6a 00                	push   $0x0
  pushl $31
c01027e5:	6a 1f                	push   $0x1f
  jmp __alltraps
c01027e7:	e9 cc fe ff ff       	jmp    c01026b8 <__alltraps>

c01027ec <vector32>:
.globl vector32
vector32:
  pushl $0
c01027ec:	6a 00                	push   $0x0
  pushl $32
c01027ee:	6a 20                	push   $0x20
  jmp __alltraps
c01027f0:	e9 c3 fe ff ff       	jmp    c01026b8 <__alltraps>

c01027f5 <vector33>:
.globl vector33
vector33:
  pushl $0
c01027f5:	6a 00                	push   $0x0
  pushl $33
c01027f7:	6a 21                	push   $0x21
  jmp __alltraps
c01027f9:	e9 ba fe ff ff       	jmp    c01026b8 <__alltraps>

c01027fe <vector34>:
.globl vector34
vector34:
  pushl $0
c01027fe:	6a 00                	push   $0x0
  pushl $34
c0102800:	6a 22                	push   $0x22
  jmp __alltraps
c0102802:	e9 b1 fe ff ff       	jmp    c01026b8 <__alltraps>

c0102807 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102807:	6a 00                	push   $0x0
  pushl $35
c0102809:	6a 23                	push   $0x23
  jmp __alltraps
c010280b:	e9 a8 fe ff ff       	jmp    c01026b8 <__alltraps>

c0102810 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102810:	6a 00                	push   $0x0
  pushl $36
c0102812:	6a 24                	push   $0x24
  jmp __alltraps
c0102814:	e9 9f fe ff ff       	jmp    c01026b8 <__alltraps>

c0102819 <vector37>:
.globl vector37
vector37:
  pushl $0
c0102819:	6a 00                	push   $0x0
  pushl $37
c010281b:	6a 25                	push   $0x25
  jmp __alltraps
c010281d:	e9 96 fe ff ff       	jmp    c01026b8 <__alltraps>

c0102822 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102822:	6a 00                	push   $0x0
  pushl $38
c0102824:	6a 26                	push   $0x26
  jmp __alltraps
c0102826:	e9 8d fe ff ff       	jmp    c01026b8 <__alltraps>

c010282b <vector39>:
.globl vector39
vector39:
  pushl $0
c010282b:	6a 00                	push   $0x0
  pushl $39
c010282d:	6a 27                	push   $0x27
  jmp __alltraps
c010282f:	e9 84 fe ff ff       	jmp    c01026b8 <__alltraps>

c0102834 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102834:	6a 00                	push   $0x0
  pushl $40
c0102836:	6a 28                	push   $0x28
  jmp __alltraps
c0102838:	e9 7b fe ff ff       	jmp    c01026b8 <__alltraps>

c010283d <vector41>:
.globl vector41
vector41:
  pushl $0
c010283d:	6a 00                	push   $0x0
  pushl $41
c010283f:	6a 29                	push   $0x29
  jmp __alltraps
c0102841:	e9 72 fe ff ff       	jmp    c01026b8 <__alltraps>

c0102846 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102846:	6a 00                	push   $0x0
  pushl $42
c0102848:	6a 2a                	push   $0x2a
  jmp __alltraps
c010284a:	e9 69 fe ff ff       	jmp    c01026b8 <__alltraps>

c010284f <vector43>:
.globl vector43
vector43:
  pushl $0
c010284f:	6a 00                	push   $0x0
  pushl $43
c0102851:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102853:	e9 60 fe ff ff       	jmp    c01026b8 <__alltraps>

c0102858 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102858:	6a 00                	push   $0x0
  pushl $44
c010285a:	6a 2c                	push   $0x2c
  jmp __alltraps
c010285c:	e9 57 fe ff ff       	jmp    c01026b8 <__alltraps>

c0102861 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102861:	6a 00                	push   $0x0
  pushl $45
c0102863:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102865:	e9 4e fe ff ff       	jmp    c01026b8 <__alltraps>

c010286a <vector46>:
.globl vector46
vector46:
  pushl $0
c010286a:	6a 00                	push   $0x0
  pushl $46
c010286c:	6a 2e                	push   $0x2e
  jmp __alltraps
c010286e:	e9 45 fe ff ff       	jmp    c01026b8 <__alltraps>

c0102873 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102873:	6a 00                	push   $0x0
  pushl $47
c0102875:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102877:	e9 3c fe ff ff       	jmp    c01026b8 <__alltraps>

c010287c <vector48>:
.globl vector48
vector48:
  pushl $0
c010287c:	6a 00                	push   $0x0
  pushl $48
c010287e:	6a 30                	push   $0x30
  jmp __alltraps
c0102880:	e9 33 fe ff ff       	jmp    c01026b8 <__alltraps>

c0102885 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102885:	6a 00                	push   $0x0
  pushl $49
c0102887:	6a 31                	push   $0x31
  jmp __alltraps
c0102889:	e9 2a fe ff ff       	jmp    c01026b8 <__alltraps>

c010288e <vector50>:
.globl vector50
vector50:
  pushl $0
c010288e:	6a 00                	push   $0x0
  pushl $50
c0102890:	6a 32                	push   $0x32
  jmp __alltraps
c0102892:	e9 21 fe ff ff       	jmp    c01026b8 <__alltraps>

c0102897 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102897:	6a 00                	push   $0x0
  pushl $51
c0102899:	6a 33                	push   $0x33
  jmp __alltraps
c010289b:	e9 18 fe ff ff       	jmp    c01026b8 <__alltraps>

c01028a0 <vector52>:
.globl vector52
vector52:
  pushl $0
c01028a0:	6a 00                	push   $0x0
  pushl $52
c01028a2:	6a 34                	push   $0x34
  jmp __alltraps
c01028a4:	e9 0f fe ff ff       	jmp    c01026b8 <__alltraps>

c01028a9 <vector53>:
.globl vector53
vector53:
  pushl $0
c01028a9:	6a 00                	push   $0x0
  pushl $53
c01028ab:	6a 35                	push   $0x35
  jmp __alltraps
c01028ad:	e9 06 fe ff ff       	jmp    c01026b8 <__alltraps>

c01028b2 <vector54>:
.globl vector54
vector54:
  pushl $0
c01028b2:	6a 00                	push   $0x0
  pushl $54
c01028b4:	6a 36                	push   $0x36
  jmp __alltraps
c01028b6:	e9 fd fd ff ff       	jmp    c01026b8 <__alltraps>

c01028bb <vector55>:
.globl vector55
vector55:
  pushl $0
c01028bb:	6a 00                	push   $0x0
  pushl $55
c01028bd:	6a 37                	push   $0x37
  jmp __alltraps
c01028bf:	e9 f4 fd ff ff       	jmp    c01026b8 <__alltraps>

c01028c4 <vector56>:
.globl vector56
vector56:
  pushl $0
c01028c4:	6a 00                	push   $0x0
  pushl $56
c01028c6:	6a 38                	push   $0x38
  jmp __alltraps
c01028c8:	e9 eb fd ff ff       	jmp    c01026b8 <__alltraps>

c01028cd <vector57>:
.globl vector57
vector57:
  pushl $0
c01028cd:	6a 00                	push   $0x0
  pushl $57
c01028cf:	6a 39                	push   $0x39
  jmp __alltraps
c01028d1:	e9 e2 fd ff ff       	jmp    c01026b8 <__alltraps>

c01028d6 <vector58>:
.globl vector58
vector58:
  pushl $0
c01028d6:	6a 00                	push   $0x0
  pushl $58
c01028d8:	6a 3a                	push   $0x3a
  jmp __alltraps
c01028da:	e9 d9 fd ff ff       	jmp    c01026b8 <__alltraps>

c01028df <vector59>:
.globl vector59
vector59:
  pushl $0
c01028df:	6a 00                	push   $0x0
  pushl $59
c01028e1:	6a 3b                	push   $0x3b
  jmp __alltraps
c01028e3:	e9 d0 fd ff ff       	jmp    c01026b8 <__alltraps>

c01028e8 <vector60>:
.globl vector60
vector60:
  pushl $0
c01028e8:	6a 00                	push   $0x0
  pushl $60
c01028ea:	6a 3c                	push   $0x3c
  jmp __alltraps
c01028ec:	e9 c7 fd ff ff       	jmp    c01026b8 <__alltraps>

c01028f1 <vector61>:
.globl vector61
vector61:
  pushl $0
c01028f1:	6a 00                	push   $0x0
  pushl $61
c01028f3:	6a 3d                	push   $0x3d
  jmp __alltraps
c01028f5:	e9 be fd ff ff       	jmp    c01026b8 <__alltraps>

c01028fa <vector62>:
.globl vector62
vector62:
  pushl $0
c01028fa:	6a 00                	push   $0x0
  pushl $62
c01028fc:	6a 3e                	push   $0x3e
  jmp __alltraps
c01028fe:	e9 b5 fd ff ff       	jmp    c01026b8 <__alltraps>

c0102903 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102903:	6a 00                	push   $0x0
  pushl $63
c0102905:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102907:	e9 ac fd ff ff       	jmp    c01026b8 <__alltraps>

c010290c <vector64>:
.globl vector64
vector64:
  pushl $0
c010290c:	6a 00                	push   $0x0
  pushl $64
c010290e:	6a 40                	push   $0x40
  jmp __alltraps
c0102910:	e9 a3 fd ff ff       	jmp    c01026b8 <__alltraps>

c0102915 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102915:	6a 00                	push   $0x0
  pushl $65
c0102917:	6a 41                	push   $0x41
  jmp __alltraps
c0102919:	e9 9a fd ff ff       	jmp    c01026b8 <__alltraps>

c010291e <vector66>:
.globl vector66
vector66:
  pushl $0
c010291e:	6a 00                	push   $0x0
  pushl $66
c0102920:	6a 42                	push   $0x42
  jmp __alltraps
c0102922:	e9 91 fd ff ff       	jmp    c01026b8 <__alltraps>

c0102927 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102927:	6a 00                	push   $0x0
  pushl $67
c0102929:	6a 43                	push   $0x43
  jmp __alltraps
c010292b:	e9 88 fd ff ff       	jmp    c01026b8 <__alltraps>

c0102930 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102930:	6a 00                	push   $0x0
  pushl $68
c0102932:	6a 44                	push   $0x44
  jmp __alltraps
c0102934:	e9 7f fd ff ff       	jmp    c01026b8 <__alltraps>

c0102939 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102939:	6a 00                	push   $0x0
  pushl $69
c010293b:	6a 45                	push   $0x45
  jmp __alltraps
c010293d:	e9 76 fd ff ff       	jmp    c01026b8 <__alltraps>

c0102942 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102942:	6a 00                	push   $0x0
  pushl $70
c0102944:	6a 46                	push   $0x46
  jmp __alltraps
c0102946:	e9 6d fd ff ff       	jmp    c01026b8 <__alltraps>

c010294b <vector71>:
.globl vector71
vector71:
  pushl $0
c010294b:	6a 00                	push   $0x0
  pushl $71
c010294d:	6a 47                	push   $0x47
  jmp __alltraps
c010294f:	e9 64 fd ff ff       	jmp    c01026b8 <__alltraps>

c0102954 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102954:	6a 00                	push   $0x0
  pushl $72
c0102956:	6a 48                	push   $0x48
  jmp __alltraps
c0102958:	e9 5b fd ff ff       	jmp    c01026b8 <__alltraps>

c010295d <vector73>:
.globl vector73
vector73:
  pushl $0
c010295d:	6a 00                	push   $0x0
  pushl $73
c010295f:	6a 49                	push   $0x49
  jmp __alltraps
c0102961:	e9 52 fd ff ff       	jmp    c01026b8 <__alltraps>

c0102966 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102966:	6a 00                	push   $0x0
  pushl $74
c0102968:	6a 4a                	push   $0x4a
  jmp __alltraps
c010296a:	e9 49 fd ff ff       	jmp    c01026b8 <__alltraps>

c010296f <vector75>:
.globl vector75
vector75:
  pushl $0
c010296f:	6a 00                	push   $0x0
  pushl $75
c0102971:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102973:	e9 40 fd ff ff       	jmp    c01026b8 <__alltraps>

c0102978 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102978:	6a 00                	push   $0x0
  pushl $76
c010297a:	6a 4c                	push   $0x4c
  jmp __alltraps
c010297c:	e9 37 fd ff ff       	jmp    c01026b8 <__alltraps>

c0102981 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102981:	6a 00                	push   $0x0
  pushl $77
c0102983:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102985:	e9 2e fd ff ff       	jmp    c01026b8 <__alltraps>

c010298a <vector78>:
.globl vector78
vector78:
  pushl $0
c010298a:	6a 00                	push   $0x0
  pushl $78
c010298c:	6a 4e                	push   $0x4e
  jmp __alltraps
c010298e:	e9 25 fd ff ff       	jmp    c01026b8 <__alltraps>

c0102993 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102993:	6a 00                	push   $0x0
  pushl $79
c0102995:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102997:	e9 1c fd ff ff       	jmp    c01026b8 <__alltraps>

c010299c <vector80>:
.globl vector80
vector80:
  pushl $0
c010299c:	6a 00                	push   $0x0
  pushl $80
c010299e:	6a 50                	push   $0x50
  jmp __alltraps
c01029a0:	e9 13 fd ff ff       	jmp    c01026b8 <__alltraps>

c01029a5 <vector81>:
.globl vector81
vector81:
  pushl $0
c01029a5:	6a 00                	push   $0x0
  pushl $81
c01029a7:	6a 51                	push   $0x51
  jmp __alltraps
c01029a9:	e9 0a fd ff ff       	jmp    c01026b8 <__alltraps>

c01029ae <vector82>:
.globl vector82
vector82:
  pushl $0
c01029ae:	6a 00                	push   $0x0
  pushl $82
c01029b0:	6a 52                	push   $0x52
  jmp __alltraps
c01029b2:	e9 01 fd ff ff       	jmp    c01026b8 <__alltraps>

c01029b7 <vector83>:
.globl vector83
vector83:
  pushl $0
c01029b7:	6a 00                	push   $0x0
  pushl $83
c01029b9:	6a 53                	push   $0x53
  jmp __alltraps
c01029bb:	e9 f8 fc ff ff       	jmp    c01026b8 <__alltraps>

c01029c0 <vector84>:
.globl vector84
vector84:
  pushl $0
c01029c0:	6a 00                	push   $0x0
  pushl $84
c01029c2:	6a 54                	push   $0x54
  jmp __alltraps
c01029c4:	e9 ef fc ff ff       	jmp    c01026b8 <__alltraps>

c01029c9 <vector85>:
.globl vector85
vector85:
  pushl $0
c01029c9:	6a 00                	push   $0x0
  pushl $85
c01029cb:	6a 55                	push   $0x55
  jmp __alltraps
c01029cd:	e9 e6 fc ff ff       	jmp    c01026b8 <__alltraps>

c01029d2 <vector86>:
.globl vector86
vector86:
  pushl $0
c01029d2:	6a 00                	push   $0x0
  pushl $86
c01029d4:	6a 56                	push   $0x56
  jmp __alltraps
c01029d6:	e9 dd fc ff ff       	jmp    c01026b8 <__alltraps>

c01029db <vector87>:
.globl vector87
vector87:
  pushl $0
c01029db:	6a 00                	push   $0x0
  pushl $87
c01029dd:	6a 57                	push   $0x57
  jmp __alltraps
c01029df:	e9 d4 fc ff ff       	jmp    c01026b8 <__alltraps>

c01029e4 <vector88>:
.globl vector88
vector88:
  pushl $0
c01029e4:	6a 00                	push   $0x0
  pushl $88
c01029e6:	6a 58                	push   $0x58
  jmp __alltraps
c01029e8:	e9 cb fc ff ff       	jmp    c01026b8 <__alltraps>

c01029ed <vector89>:
.globl vector89
vector89:
  pushl $0
c01029ed:	6a 00                	push   $0x0
  pushl $89
c01029ef:	6a 59                	push   $0x59
  jmp __alltraps
c01029f1:	e9 c2 fc ff ff       	jmp    c01026b8 <__alltraps>

c01029f6 <vector90>:
.globl vector90
vector90:
  pushl $0
c01029f6:	6a 00                	push   $0x0
  pushl $90
c01029f8:	6a 5a                	push   $0x5a
  jmp __alltraps
c01029fa:	e9 b9 fc ff ff       	jmp    c01026b8 <__alltraps>

c01029ff <vector91>:
.globl vector91
vector91:
  pushl $0
c01029ff:	6a 00                	push   $0x0
  pushl $91
c0102a01:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102a03:	e9 b0 fc ff ff       	jmp    c01026b8 <__alltraps>

c0102a08 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102a08:	6a 00                	push   $0x0
  pushl $92
c0102a0a:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102a0c:	e9 a7 fc ff ff       	jmp    c01026b8 <__alltraps>

c0102a11 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102a11:	6a 00                	push   $0x0
  pushl $93
c0102a13:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102a15:	e9 9e fc ff ff       	jmp    c01026b8 <__alltraps>

c0102a1a <vector94>:
.globl vector94
vector94:
  pushl $0
c0102a1a:	6a 00                	push   $0x0
  pushl $94
c0102a1c:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102a1e:	e9 95 fc ff ff       	jmp    c01026b8 <__alltraps>

c0102a23 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102a23:	6a 00                	push   $0x0
  pushl $95
c0102a25:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102a27:	e9 8c fc ff ff       	jmp    c01026b8 <__alltraps>

c0102a2c <vector96>:
.globl vector96
vector96:
  pushl $0
c0102a2c:	6a 00                	push   $0x0
  pushl $96
c0102a2e:	6a 60                	push   $0x60
  jmp __alltraps
c0102a30:	e9 83 fc ff ff       	jmp    c01026b8 <__alltraps>

c0102a35 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102a35:	6a 00                	push   $0x0
  pushl $97
c0102a37:	6a 61                	push   $0x61
  jmp __alltraps
c0102a39:	e9 7a fc ff ff       	jmp    c01026b8 <__alltraps>

c0102a3e <vector98>:
.globl vector98
vector98:
  pushl $0
c0102a3e:	6a 00                	push   $0x0
  pushl $98
c0102a40:	6a 62                	push   $0x62
  jmp __alltraps
c0102a42:	e9 71 fc ff ff       	jmp    c01026b8 <__alltraps>

c0102a47 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102a47:	6a 00                	push   $0x0
  pushl $99
c0102a49:	6a 63                	push   $0x63
  jmp __alltraps
c0102a4b:	e9 68 fc ff ff       	jmp    c01026b8 <__alltraps>

c0102a50 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102a50:	6a 00                	push   $0x0
  pushl $100
c0102a52:	6a 64                	push   $0x64
  jmp __alltraps
c0102a54:	e9 5f fc ff ff       	jmp    c01026b8 <__alltraps>

c0102a59 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102a59:	6a 00                	push   $0x0
  pushl $101
c0102a5b:	6a 65                	push   $0x65
  jmp __alltraps
c0102a5d:	e9 56 fc ff ff       	jmp    c01026b8 <__alltraps>

c0102a62 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102a62:	6a 00                	push   $0x0
  pushl $102
c0102a64:	6a 66                	push   $0x66
  jmp __alltraps
c0102a66:	e9 4d fc ff ff       	jmp    c01026b8 <__alltraps>

c0102a6b <vector103>:
.globl vector103
vector103:
  pushl $0
c0102a6b:	6a 00                	push   $0x0
  pushl $103
c0102a6d:	6a 67                	push   $0x67
  jmp __alltraps
c0102a6f:	e9 44 fc ff ff       	jmp    c01026b8 <__alltraps>

c0102a74 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102a74:	6a 00                	push   $0x0
  pushl $104
c0102a76:	6a 68                	push   $0x68
  jmp __alltraps
c0102a78:	e9 3b fc ff ff       	jmp    c01026b8 <__alltraps>

c0102a7d <vector105>:
.globl vector105
vector105:
  pushl $0
c0102a7d:	6a 00                	push   $0x0
  pushl $105
c0102a7f:	6a 69                	push   $0x69
  jmp __alltraps
c0102a81:	e9 32 fc ff ff       	jmp    c01026b8 <__alltraps>

c0102a86 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102a86:	6a 00                	push   $0x0
  pushl $106
c0102a88:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102a8a:	e9 29 fc ff ff       	jmp    c01026b8 <__alltraps>

c0102a8f <vector107>:
.globl vector107
vector107:
  pushl $0
c0102a8f:	6a 00                	push   $0x0
  pushl $107
c0102a91:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102a93:	e9 20 fc ff ff       	jmp    c01026b8 <__alltraps>

c0102a98 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102a98:	6a 00                	push   $0x0
  pushl $108
c0102a9a:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102a9c:	e9 17 fc ff ff       	jmp    c01026b8 <__alltraps>

c0102aa1 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102aa1:	6a 00                	push   $0x0
  pushl $109
c0102aa3:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102aa5:	e9 0e fc ff ff       	jmp    c01026b8 <__alltraps>

c0102aaa <vector110>:
.globl vector110
vector110:
  pushl $0
c0102aaa:	6a 00                	push   $0x0
  pushl $110
c0102aac:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102aae:	e9 05 fc ff ff       	jmp    c01026b8 <__alltraps>

c0102ab3 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102ab3:	6a 00                	push   $0x0
  pushl $111
c0102ab5:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102ab7:	e9 fc fb ff ff       	jmp    c01026b8 <__alltraps>

c0102abc <vector112>:
.globl vector112
vector112:
  pushl $0
c0102abc:	6a 00                	push   $0x0
  pushl $112
c0102abe:	6a 70                	push   $0x70
  jmp __alltraps
c0102ac0:	e9 f3 fb ff ff       	jmp    c01026b8 <__alltraps>

c0102ac5 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102ac5:	6a 00                	push   $0x0
  pushl $113
c0102ac7:	6a 71                	push   $0x71
  jmp __alltraps
c0102ac9:	e9 ea fb ff ff       	jmp    c01026b8 <__alltraps>

c0102ace <vector114>:
.globl vector114
vector114:
  pushl $0
c0102ace:	6a 00                	push   $0x0
  pushl $114
c0102ad0:	6a 72                	push   $0x72
  jmp __alltraps
c0102ad2:	e9 e1 fb ff ff       	jmp    c01026b8 <__alltraps>

c0102ad7 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102ad7:	6a 00                	push   $0x0
  pushl $115
c0102ad9:	6a 73                	push   $0x73
  jmp __alltraps
c0102adb:	e9 d8 fb ff ff       	jmp    c01026b8 <__alltraps>

c0102ae0 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102ae0:	6a 00                	push   $0x0
  pushl $116
c0102ae2:	6a 74                	push   $0x74
  jmp __alltraps
c0102ae4:	e9 cf fb ff ff       	jmp    c01026b8 <__alltraps>

c0102ae9 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102ae9:	6a 00                	push   $0x0
  pushl $117
c0102aeb:	6a 75                	push   $0x75
  jmp __alltraps
c0102aed:	e9 c6 fb ff ff       	jmp    c01026b8 <__alltraps>

c0102af2 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102af2:	6a 00                	push   $0x0
  pushl $118
c0102af4:	6a 76                	push   $0x76
  jmp __alltraps
c0102af6:	e9 bd fb ff ff       	jmp    c01026b8 <__alltraps>

c0102afb <vector119>:
.globl vector119
vector119:
  pushl $0
c0102afb:	6a 00                	push   $0x0
  pushl $119
c0102afd:	6a 77                	push   $0x77
  jmp __alltraps
c0102aff:	e9 b4 fb ff ff       	jmp    c01026b8 <__alltraps>

c0102b04 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102b04:	6a 00                	push   $0x0
  pushl $120
c0102b06:	6a 78                	push   $0x78
  jmp __alltraps
c0102b08:	e9 ab fb ff ff       	jmp    c01026b8 <__alltraps>

c0102b0d <vector121>:
.globl vector121
vector121:
  pushl $0
c0102b0d:	6a 00                	push   $0x0
  pushl $121
c0102b0f:	6a 79                	push   $0x79
  jmp __alltraps
c0102b11:	e9 a2 fb ff ff       	jmp    c01026b8 <__alltraps>

c0102b16 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102b16:	6a 00                	push   $0x0
  pushl $122
c0102b18:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102b1a:	e9 99 fb ff ff       	jmp    c01026b8 <__alltraps>

c0102b1f <vector123>:
.globl vector123
vector123:
  pushl $0
c0102b1f:	6a 00                	push   $0x0
  pushl $123
c0102b21:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102b23:	e9 90 fb ff ff       	jmp    c01026b8 <__alltraps>

c0102b28 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102b28:	6a 00                	push   $0x0
  pushl $124
c0102b2a:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102b2c:	e9 87 fb ff ff       	jmp    c01026b8 <__alltraps>

c0102b31 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102b31:	6a 00                	push   $0x0
  pushl $125
c0102b33:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102b35:	e9 7e fb ff ff       	jmp    c01026b8 <__alltraps>

c0102b3a <vector126>:
.globl vector126
vector126:
  pushl $0
c0102b3a:	6a 00                	push   $0x0
  pushl $126
c0102b3c:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102b3e:	e9 75 fb ff ff       	jmp    c01026b8 <__alltraps>

c0102b43 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102b43:	6a 00                	push   $0x0
  pushl $127
c0102b45:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102b47:	e9 6c fb ff ff       	jmp    c01026b8 <__alltraps>

c0102b4c <vector128>:
.globl vector128
vector128:
  pushl $0
c0102b4c:	6a 00                	push   $0x0
  pushl $128
c0102b4e:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102b53:	e9 60 fb ff ff       	jmp    c01026b8 <__alltraps>

c0102b58 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102b58:	6a 00                	push   $0x0
  pushl $129
c0102b5a:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102b5f:	e9 54 fb ff ff       	jmp    c01026b8 <__alltraps>

c0102b64 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102b64:	6a 00                	push   $0x0
  pushl $130
c0102b66:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102b6b:	e9 48 fb ff ff       	jmp    c01026b8 <__alltraps>

c0102b70 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102b70:	6a 00                	push   $0x0
  pushl $131
c0102b72:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102b77:	e9 3c fb ff ff       	jmp    c01026b8 <__alltraps>

c0102b7c <vector132>:
.globl vector132
vector132:
  pushl $0
c0102b7c:	6a 00                	push   $0x0
  pushl $132
c0102b7e:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102b83:	e9 30 fb ff ff       	jmp    c01026b8 <__alltraps>

c0102b88 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102b88:	6a 00                	push   $0x0
  pushl $133
c0102b8a:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102b8f:	e9 24 fb ff ff       	jmp    c01026b8 <__alltraps>

c0102b94 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102b94:	6a 00                	push   $0x0
  pushl $134
c0102b96:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102b9b:	e9 18 fb ff ff       	jmp    c01026b8 <__alltraps>

c0102ba0 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102ba0:	6a 00                	push   $0x0
  pushl $135
c0102ba2:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102ba7:	e9 0c fb ff ff       	jmp    c01026b8 <__alltraps>

c0102bac <vector136>:
.globl vector136
vector136:
  pushl $0
c0102bac:	6a 00                	push   $0x0
  pushl $136
c0102bae:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102bb3:	e9 00 fb ff ff       	jmp    c01026b8 <__alltraps>

c0102bb8 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102bb8:	6a 00                	push   $0x0
  pushl $137
c0102bba:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102bbf:	e9 f4 fa ff ff       	jmp    c01026b8 <__alltraps>

c0102bc4 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102bc4:	6a 00                	push   $0x0
  pushl $138
c0102bc6:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102bcb:	e9 e8 fa ff ff       	jmp    c01026b8 <__alltraps>

c0102bd0 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102bd0:	6a 00                	push   $0x0
  pushl $139
c0102bd2:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102bd7:	e9 dc fa ff ff       	jmp    c01026b8 <__alltraps>

c0102bdc <vector140>:
.globl vector140
vector140:
  pushl $0
c0102bdc:	6a 00                	push   $0x0
  pushl $140
c0102bde:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102be3:	e9 d0 fa ff ff       	jmp    c01026b8 <__alltraps>

c0102be8 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102be8:	6a 00                	push   $0x0
  pushl $141
c0102bea:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102bef:	e9 c4 fa ff ff       	jmp    c01026b8 <__alltraps>

c0102bf4 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102bf4:	6a 00                	push   $0x0
  pushl $142
c0102bf6:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102bfb:	e9 b8 fa ff ff       	jmp    c01026b8 <__alltraps>

c0102c00 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102c00:	6a 00                	push   $0x0
  pushl $143
c0102c02:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102c07:	e9 ac fa ff ff       	jmp    c01026b8 <__alltraps>

c0102c0c <vector144>:
.globl vector144
vector144:
  pushl $0
c0102c0c:	6a 00                	push   $0x0
  pushl $144
c0102c0e:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102c13:	e9 a0 fa ff ff       	jmp    c01026b8 <__alltraps>

c0102c18 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102c18:	6a 00                	push   $0x0
  pushl $145
c0102c1a:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102c1f:	e9 94 fa ff ff       	jmp    c01026b8 <__alltraps>

c0102c24 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102c24:	6a 00                	push   $0x0
  pushl $146
c0102c26:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102c2b:	e9 88 fa ff ff       	jmp    c01026b8 <__alltraps>

c0102c30 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102c30:	6a 00                	push   $0x0
  pushl $147
c0102c32:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102c37:	e9 7c fa ff ff       	jmp    c01026b8 <__alltraps>

c0102c3c <vector148>:
.globl vector148
vector148:
  pushl $0
c0102c3c:	6a 00                	push   $0x0
  pushl $148
c0102c3e:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102c43:	e9 70 fa ff ff       	jmp    c01026b8 <__alltraps>

c0102c48 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102c48:	6a 00                	push   $0x0
  pushl $149
c0102c4a:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102c4f:	e9 64 fa ff ff       	jmp    c01026b8 <__alltraps>

c0102c54 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102c54:	6a 00                	push   $0x0
  pushl $150
c0102c56:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102c5b:	e9 58 fa ff ff       	jmp    c01026b8 <__alltraps>

c0102c60 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102c60:	6a 00                	push   $0x0
  pushl $151
c0102c62:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102c67:	e9 4c fa ff ff       	jmp    c01026b8 <__alltraps>

c0102c6c <vector152>:
.globl vector152
vector152:
  pushl $0
c0102c6c:	6a 00                	push   $0x0
  pushl $152
c0102c6e:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102c73:	e9 40 fa ff ff       	jmp    c01026b8 <__alltraps>

c0102c78 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102c78:	6a 00                	push   $0x0
  pushl $153
c0102c7a:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102c7f:	e9 34 fa ff ff       	jmp    c01026b8 <__alltraps>

c0102c84 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102c84:	6a 00                	push   $0x0
  pushl $154
c0102c86:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102c8b:	e9 28 fa ff ff       	jmp    c01026b8 <__alltraps>

c0102c90 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102c90:	6a 00                	push   $0x0
  pushl $155
c0102c92:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102c97:	e9 1c fa ff ff       	jmp    c01026b8 <__alltraps>

c0102c9c <vector156>:
.globl vector156
vector156:
  pushl $0
c0102c9c:	6a 00                	push   $0x0
  pushl $156
c0102c9e:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102ca3:	e9 10 fa ff ff       	jmp    c01026b8 <__alltraps>

c0102ca8 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102ca8:	6a 00                	push   $0x0
  pushl $157
c0102caa:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102caf:	e9 04 fa ff ff       	jmp    c01026b8 <__alltraps>

c0102cb4 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102cb4:	6a 00                	push   $0x0
  pushl $158
c0102cb6:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102cbb:	e9 f8 f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102cc0 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102cc0:	6a 00                	push   $0x0
  pushl $159
c0102cc2:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102cc7:	e9 ec f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102ccc <vector160>:
.globl vector160
vector160:
  pushl $0
c0102ccc:	6a 00                	push   $0x0
  pushl $160
c0102cce:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102cd3:	e9 e0 f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102cd8 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102cd8:	6a 00                	push   $0x0
  pushl $161
c0102cda:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102cdf:	e9 d4 f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102ce4 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102ce4:	6a 00                	push   $0x0
  pushl $162
c0102ce6:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102ceb:	e9 c8 f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102cf0 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102cf0:	6a 00                	push   $0x0
  pushl $163
c0102cf2:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102cf7:	e9 bc f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102cfc <vector164>:
.globl vector164
vector164:
  pushl $0
c0102cfc:	6a 00                	push   $0x0
  pushl $164
c0102cfe:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102d03:	e9 b0 f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102d08 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102d08:	6a 00                	push   $0x0
  pushl $165
c0102d0a:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102d0f:	e9 a4 f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102d14 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102d14:	6a 00                	push   $0x0
  pushl $166
c0102d16:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102d1b:	e9 98 f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102d20 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102d20:	6a 00                	push   $0x0
  pushl $167
c0102d22:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102d27:	e9 8c f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102d2c <vector168>:
.globl vector168
vector168:
  pushl $0
c0102d2c:	6a 00                	push   $0x0
  pushl $168
c0102d2e:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102d33:	e9 80 f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102d38 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102d38:	6a 00                	push   $0x0
  pushl $169
c0102d3a:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102d3f:	e9 74 f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102d44 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102d44:	6a 00                	push   $0x0
  pushl $170
c0102d46:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102d4b:	e9 68 f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102d50 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102d50:	6a 00                	push   $0x0
  pushl $171
c0102d52:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102d57:	e9 5c f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102d5c <vector172>:
.globl vector172
vector172:
  pushl $0
c0102d5c:	6a 00                	push   $0x0
  pushl $172
c0102d5e:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102d63:	e9 50 f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102d68 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102d68:	6a 00                	push   $0x0
  pushl $173
c0102d6a:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102d6f:	e9 44 f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102d74 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102d74:	6a 00                	push   $0x0
  pushl $174
c0102d76:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102d7b:	e9 38 f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102d80 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102d80:	6a 00                	push   $0x0
  pushl $175
c0102d82:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102d87:	e9 2c f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102d8c <vector176>:
.globl vector176
vector176:
  pushl $0
c0102d8c:	6a 00                	push   $0x0
  pushl $176
c0102d8e:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102d93:	e9 20 f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102d98 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102d98:	6a 00                	push   $0x0
  pushl $177
c0102d9a:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102d9f:	e9 14 f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102da4 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102da4:	6a 00                	push   $0x0
  pushl $178
c0102da6:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102dab:	e9 08 f9 ff ff       	jmp    c01026b8 <__alltraps>

c0102db0 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102db0:	6a 00                	push   $0x0
  pushl $179
c0102db2:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102db7:	e9 fc f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102dbc <vector180>:
.globl vector180
vector180:
  pushl $0
c0102dbc:	6a 00                	push   $0x0
  pushl $180
c0102dbe:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102dc3:	e9 f0 f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102dc8 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102dc8:	6a 00                	push   $0x0
  pushl $181
c0102dca:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102dcf:	e9 e4 f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102dd4 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102dd4:	6a 00                	push   $0x0
  pushl $182
c0102dd6:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102ddb:	e9 d8 f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102de0 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102de0:	6a 00                	push   $0x0
  pushl $183
c0102de2:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102de7:	e9 cc f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102dec <vector184>:
.globl vector184
vector184:
  pushl $0
c0102dec:	6a 00                	push   $0x0
  pushl $184
c0102dee:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102df3:	e9 c0 f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102df8 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102df8:	6a 00                	push   $0x0
  pushl $185
c0102dfa:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102dff:	e9 b4 f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102e04 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102e04:	6a 00                	push   $0x0
  pushl $186
c0102e06:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102e0b:	e9 a8 f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102e10 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102e10:	6a 00                	push   $0x0
  pushl $187
c0102e12:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102e17:	e9 9c f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102e1c <vector188>:
.globl vector188
vector188:
  pushl $0
c0102e1c:	6a 00                	push   $0x0
  pushl $188
c0102e1e:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102e23:	e9 90 f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102e28 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102e28:	6a 00                	push   $0x0
  pushl $189
c0102e2a:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102e2f:	e9 84 f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102e34 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102e34:	6a 00                	push   $0x0
  pushl $190
c0102e36:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102e3b:	e9 78 f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102e40 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102e40:	6a 00                	push   $0x0
  pushl $191
c0102e42:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102e47:	e9 6c f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102e4c <vector192>:
.globl vector192
vector192:
  pushl $0
c0102e4c:	6a 00                	push   $0x0
  pushl $192
c0102e4e:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102e53:	e9 60 f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102e58 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102e58:	6a 00                	push   $0x0
  pushl $193
c0102e5a:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102e5f:	e9 54 f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102e64 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102e64:	6a 00                	push   $0x0
  pushl $194
c0102e66:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102e6b:	e9 48 f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102e70 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102e70:	6a 00                	push   $0x0
  pushl $195
c0102e72:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102e77:	e9 3c f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102e7c <vector196>:
.globl vector196
vector196:
  pushl $0
c0102e7c:	6a 00                	push   $0x0
  pushl $196
c0102e7e:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102e83:	e9 30 f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102e88 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102e88:	6a 00                	push   $0x0
  pushl $197
c0102e8a:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102e8f:	e9 24 f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102e94 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102e94:	6a 00                	push   $0x0
  pushl $198
c0102e96:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102e9b:	e9 18 f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102ea0 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102ea0:	6a 00                	push   $0x0
  pushl $199
c0102ea2:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102ea7:	e9 0c f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102eac <vector200>:
.globl vector200
vector200:
  pushl $0
c0102eac:	6a 00                	push   $0x0
  pushl $200
c0102eae:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102eb3:	e9 00 f8 ff ff       	jmp    c01026b8 <__alltraps>

c0102eb8 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102eb8:	6a 00                	push   $0x0
  pushl $201
c0102eba:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102ebf:	e9 f4 f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102ec4 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102ec4:	6a 00                	push   $0x0
  pushl $202
c0102ec6:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102ecb:	e9 e8 f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102ed0 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102ed0:	6a 00                	push   $0x0
  pushl $203
c0102ed2:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102ed7:	e9 dc f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102edc <vector204>:
.globl vector204
vector204:
  pushl $0
c0102edc:	6a 00                	push   $0x0
  pushl $204
c0102ede:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102ee3:	e9 d0 f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102ee8 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102ee8:	6a 00                	push   $0x0
  pushl $205
c0102eea:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102eef:	e9 c4 f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102ef4 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102ef4:	6a 00                	push   $0x0
  pushl $206
c0102ef6:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102efb:	e9 b8 f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102f00 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102f00:	6a 00                	push   $0x0
  pushl $207
c0102f02:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102f07:	e9 ac f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102f0c <vector208>:
.globl vector208
vector208:
  pushl $0
c0102f0c:	6a 00                	push   $0x0
  pushl $208
c0102f0e:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102f13:	e9 a0 f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102f18 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102f18:	6a 00                	push   $0x0
  pushl $209
c0102f1a:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102f1f:	e9 94 f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102f24 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102f24:	6a 00                	push   $0x0
  pushl $210
c0102f26:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102f2b:	e9 88 f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102f30 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102f30:	6a 00                	push   $0x0
  pushl $211
c0102f32:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102f37:	e9 7c f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102f3c <vector212>:
.globl vector212
vector212:
  pushl $0
c0102f3c:	6a 00                	push   $0x0
  pushl $212
c0102f3e:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102f43:	e9 70 f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102f48 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102f48:	6a 00                	push   $0x0
  pushl $213
c0102f4a:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102f4f:	e9 64 f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102f54 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102f54:	6a 00                	push   $0x0
  pushl $214
c0102f56:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102f5b:	e9 58 f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102f60 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102f60:	6a 00                	push   $0x0
  pushl $215
c0102f62:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102f67:	e9 4c f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102f6c <vector216>:
.globl vector216
vector216:
  pushl $0
c0102f6c:	6a 00                	push   $0x0
  pushl $216
c0102f6e:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102f73:	e9 40 f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102f78 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102f78:	6a 00                	push   $0x0
  pushl $217
c0102f7a:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102f7f:	e9 34 f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102f84 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102f84:	6a 00                	push   $0x0
  pushl $218
c0102f86:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102f8b:	e9 28 f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102f90 <vector219>:
.globl vector219
vector219:
  pushl $0
c0102f90:	6a 00                	push   $0x0
  pushl $219
c0102f92:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102f97:	e9 1c f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102f9c <vector220>:
.globl vector220
vector220:
  pushl $0
c0102f9c:	6a 00                	push   $0x0
  pushl $220
c0102f9e:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102fa3:	e9 10 f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102fa8 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102fa8:	6a 00                	push   $0x0
  pushl $221
c0102faa:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102faf:	e9 04 f7 ff ff       	jmp    c01026b8 <__alltraps>

c0102fb4 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102fb4:	6a 00                	push   $0x0
  pushl $222
c0102fb6:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102fbb:	e9 f8 f6 ff ff       	jmp    c01026b8 <__alltraps>

c0102fc0 <vector223>:
.globl vector223
vector223:
  pushl $0
c0102fc0:	6a 00                	push   $0x0
  pushl $223
c0102fc2:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102fc7:	e9 ec f6 ff ff       	jmp    c01026b8 <__alltraps>

c0102fcc <vector224>:
.globl vector224
vector224:
  pushl $0
c0102fcc:	6a 00                	push   $0x0
  pushl $224
c0102fce:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102fd3:	e9 e0 f6 ff ff       	jmp    c01026b8 <__alltraps>

c0102fd8 <vector225>:
.globl vector225
vector225:
  pushl $0
c0102fd8:	6a 00                	push   $0x0
  pushl $225
c0102fda:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102fdf:	e9 d4 f6 ff ff       	jmp    c01026b8 <__alltraps>

c0102fe4 <vector226>:
.globl vector226
vector226:
  pushl $0
c0102fe4:	6a 00                	push   $0x0
  pushl $226
c0102fe6:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102feb:	e9 c8 f6 ff ff       	jmp    c01026b8 <__alltraps>

c0102ff0 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102ff0:	6a 00                	push   $0x0
  pushl $227
c0102ff2:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102ff7:	e9 bc f6 ff ff       	jmp    c01026b8 <__alltraps>

c0102ffc <vector228>:
.globl vector228
vector228:
  pushl $0
c0102ffc:	6a 00                	push   $0x0
  pushl $228
c0102ffe:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0103003:	e9 b0 f6 ff ff       	jmp    c01026b8 <__alltraps>

c0103008 <vector229>:
.globl vector229
vector229:
  pushl $0
c0103008:	6a 00                	push   $0x0
  pushl $229
c010300a:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c010300f:	e9 a4 f6 ff ff       	jmp    c01026b8 <__alltraps>

c0103014 <vector230>:
.globl vector230
vector230:
  pushl $0
c0103014:	6a 00                	push   $0x0
  pushl $230
c0103016:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c010301b:	e9 98 f6 ff ff       	jmp    c01026b8 <__alltraps>

c0103020 <vector231>:
.globl vector231
vector231:
  pushl $0
c0103020:	6a 00                	push   $0x0
  pushl $231
c0103022:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0103027:	e9 8c f6 ff ff       	jmp    c01026b8 <__alltraps>

c010302c <vector232>:
.globl vector232
vector232:
  pushl $0
c010302c:	6a 00                	push   $0x0
  pushl $232
c010302e:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0103033:	e9 80 f6 ff ff       	jmp    c01026b8 <__alltraps>

c0103038 <vector233>:
.globl vector233
vector233:
  pushl $0
c0103038:	6a 00                	push   $0x0
  pushl $233
c010303a:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c010303f:	e9 74 f6 ff ff       	jmp    c01026b8 <__alltraps>

c0103044 <vector234>:
.globl vector234
vector234:
  pushl $0
c0103044:	6a 00                	push   $0x0
  pushl $234
c0103046:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010304b:	e9 68 f6 ff ff       	jmp    c01026b8 <__alltraps>

c0103050 <vector235>:
.globl vector235
vector235:
  pushl $0
c0103050:	6a 00                	push   $0x0
  pushl $235
c0103052:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0103057:	e9 5c f6 ff ff       	jmp    c01026b8 <__alltraps>

c010305c <vector236>:
.globl vector236
vector236:
  pushl $0
c010305c:	6a 00                	push   $0x0
  pushl $236
c010305e:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0103063:	e9 50 f6 ff ff       	jmp    c01026b8 <__alltraps>

c0103068 <vector237>:
.globl vector237
vector237:
  pushl $0
c0103068:	6a 00                	push   $0x0
  pushl $237
c010306a:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010306f:	e9 44 f6 ff ff       	jmp    c01026b8 <__alltraps>

c0103074 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103074:	6a 00                	push   $0x0
  pushl $238
c0103076:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010307b:	e9 38 f6 ff ff       	jmp    c01026b8 <__alltraps>

c0103080 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103080:	6a 00                	push   $0x0
  pushl $239
c0103082:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0103087:	e9 2c f6 ff ff       	jmp    c01026b8 <__alltraps>

c010308c <vector240>:
.globl vector240
vector240:
  pushl $0
c010308c:	6a 00                	push   $0x0
  pushl $240
c010308e:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103093:	e9 20 f6 ff ff       	jmp    c01026b8 <__alltraps>

c0103098 <vector241>:
.globl vector241
vector241:
  pushl $0
c0103098:	6a 00                	push   $0x0
  pushl $241
c010309a:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010309f:	e9 14 f6 ff ff       	jmp    c01026b8 <__alltraps>

c01030a4 <vector242>:
.globl vector242
vector242:
  pushl $0
c01030a4:	6a 00                	push   $0x0
  pushl $242
c01030a6:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01030ab:	e9 08 f6 ff ff       	jmp    c01026b8 <__alltraps>

c01030b0 <vector243>:
.globl vector243
vector243:
  pushl $0
c01030b0:	6a 00                	push   $0x0
  pushl $243
c01030b2:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01030b7:	e9 fc f5 ff ff       	jmp    c01026b8 <__alltraps>

c01030bc <vector244>:
.globl vector244
vector244:
  pushl $0
c01030bc:	6a 00                	push   $0x0
  pushl $244
c01030be:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01030c3:	e9 f0 f5 ff ff       	jmp    c01026b8 <__alltraps>

c01030c8 <vector245>:
.globl vector245
vector245:
  pushl $0
c01030c8:	6a 00                	push   $0x0
  pushl $245
c01030ca:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01030cf:	e9 e4 f5 ff ff       	jmp    c01026b8 <__alltraps>

c01030d4 <vector246>:
.globl vector246
vector246:
  pushl $0
c01030d4:	6a 00                	push   $0x0
  pushl $246
c01030d6:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01030db:	e9 d8 f5 ff ff       	jmp    c01026b8 <__alltraps>

c01030e0 <vector247>:
.globl vector247
vector247:
  pushl $0
c01030e0:	6a 00                	push   $0x0
  pushl $247
c01030e2:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01030e7:	e9 cc f5 ff ff       	jmp    c01026b8 <__alltraps>

c01030ec <vector248>:
.globl vector248
vector248:
  pushl $0
c01030ec:	6a 00                	push   $0x0
  pushl $248
c01030ee:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01030f3:	e9 c0 f5 ff ff       	jmp    c01026b8 <__alltraps>

c01030f8 <vector249>:
.globl vector249
vector249:
  pushl $0
c01030f8:	6a 00                	push   $0x0
  pushl $249
c01030fa:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01030ff:	e9 b4 f5 ff ff       	jmp    c01026b8 <__alltraps>

c0103104 <vector250>:
.globl vector250
vector250:
  pushl $0
c0103104:	6a 00                	push   $0x0
  pushl $250
c0103106:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c010310b:	e9 a8 f5 ff ff       	jmp    c01026b8 <__alltraps>

c0103110 <vector251>:
.globl vector251
vector251:
  pushl $0
c0103110:	6a 00                	push   $0x0
  pushl $251
c0103112:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0103117:	e9 9c f5 ff ff       	jmp    c01026b8 <__alltraps>

c010311c <vector252>:
.globl vector252
vector252:
  pushl $0
c010311c:	6a 00                	push   $0x0
  pushl $252
c010311e:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0103123:	e9 90 f5 ff ff       	jmp    c01026b8 <__alltraps>

c0103128 <vector253>:
.globl vector253
vector253:
  pushl $0
c0103128:	6a 00                	push   $0x0
  pushl $253
c010312a:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c010312f:	e9 84 f5 ff ff       	jmp    c01026b8 <__alltraps>

c0103134 <vector254>:
.globl vector254
vector254:
  pushl $0
c0103134:	6a 00                	push   $0x0
  pushl $254
c0103136:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c010313b:	e9 78 f5 ff ff       	jmp    c01026b8 <__alltraps>

c0103140 <vector255>:
.globl vector255
vector255:
  pushl $0
c0103140:	6a 00                	push   $0x0
  pushl $255
c0103142:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0103147:	e9 6c f5 ff ff       	jmp    c01026b8 <__alltraps>

c010314c <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010314c:	55                   	push   %ebp
c010314d:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010314f:	8b 55 08             	mov    0x8(%ebp),%edx
c0103152:	a1 54 40 12 c0       	mov    0xc0124054,%eax
c0103157:	29 c2                	sub    %eax,%edx
c0103159:	89 d0                	mov    %edx,%eax
c010315b:	c1 f8 05             	sar    $0x5,%eax
}
c010315e:	5d                   	pop    %ebp
c010315f:	c3                   	ret    

c0103160 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103160:	55                   	push   %ebp
c0103161:	89 e5                	mov    %esp,%ebp
c0103163:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103166:	8b 45 08             	mov    0x8(%ebp),%eax
c0103169:	89 04 24             	mov    %eax,(%esp)
c010316c:	e8 db ff ff ff       	call   c010314c <page2ppn>
c0103171:	c1 e0 0c             	shl    $0xc,%eax
}
c0103174:	c9                   	leave  
c0103175:	c3                   	ret    

c0103176 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0103176:	55                   	push   %ebp
c0103177:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103179:	8b 45 08             	mov    0x8(%ebp),%eax
c010317c:	8b 00                	mov    (%eax),%eax
}
c010317e:	5d                   	pop    %ebp
c010317f:	c3                   	ret    

c0103180 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103180:	55                   	push   %ebp
c0103181:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103183:	8b 45 08             	mov    0x8(%ebp),%eax
c0103186:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103189:	89 10                	mov    %edx,(%eax)
}
c010318b:	5d                   	pop    %ebp
c010318c:	c3                   	ret    

c010318d <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c010318d:	55                   	push   %ebp
c010318e:	89 e5                	mov    %esp,%ebp
c0103190:	83 ec 10             	sub    $0x10,%esp
c0103193:	c7 45 fc 40 40 12 c0 	movl   $0xc0124040,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010319a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010319d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01031a0:	89 50 04             	mov    %edx,0x4(%eax)
c01031a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01031a6:	8b 50 04             	mov    0x4(%eax),%edx
c01031a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01031ac:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c01031ae:	c7 05 48 40 12 c0 00 	movl   $0x0,0xc0124048
c01031b5:	00 00 00 
}
c01031b8:	c9                   	leave  
c01031b9:	c3                   	ret    

c01031ba <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c01031ba:	55                   	push   %ebp
c01031bb:	89 e5                	mov    %esp,%ebp
c01031bd:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01031c0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01031c4:	75 24                	jne    c01031ea <default_init_memmap+0x30>
c01031c6:	c7 44 24 0c d0 94 10 	movl   $0xc01094d0,0xc(%esp)
c01031cd:	c0 
c01031ce:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c01031d5:	c0 
c01031d6:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01031dd:	00 
c01031de:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c01031e5:	e8 3d da ff ff       	call   c0100c27 <__panic>
    struct Page *p = base;
c01031ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01031ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01031f0:	eb 7d                	jmp    c010326f <default_init_memmap+0xb5>
        assert(PageReserved(p));
c01031f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031f5:	83 c0 04             	add    $0x4,%eax
c01031f8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01031ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103202:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103205:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103208:	0f a3 10             	bt     %edx,(%eax)
c010320b:	19 c0                	sbb    %eax,%eax
c010320d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0103210:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103214:	0f 95 c0             	setne  %al
c0103217:	0f b6 c0             	movzbl %al,%eax
c010321a:	85 c0                	test   %eax,%eax
c010321c:	75 24                	jne    c0103242 <default_init_memmap+0x88>
c010321e:	c7 44 24 0c 01 95 10 	movl   $0xc0109501,0xc(%esp)
c0103225:	c0 
c0103226:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c010322d:	c0 
c010322e:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0103235:	00 
c0103236:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c010323d:	e8 e5 d9 ff ff       	call   c0100c27 <__panic>
        p->flags = p->property = 0;
c0103242:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103245:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c010324c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010324f:	8b 50 08             	mov    0x8(%eax),%edx
c0103252:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103255:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0103258:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010325f:	00 
c0103260:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103263:	89 04 24             	mov    %eax,(%esp)
c0103266:	e8 15 ff ff ff       	call   c0103180 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c010326b:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c010326f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103272:	c1 e0 05             	shl    $0x5,%eax
c0103275:	89 c2                	mov    %eax,%edx
c0103277:	8b 45 08             	mov    0x8(%ebp),%eax
c010327a:	01 d0                	add    %edx,%eax
c010327c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010327f:	0f 85 6d ff ff ff    	jne    c01031f2 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0103285:	8b 45 08             	mov    0x8(%ebp),%eax
c0103288:	8b 55 0c             	mov    0xc(%ebp),%edx
c010328b:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010328e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103291:	83 c0 04             	add    $0x4,%eax
c0103294:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c010329b:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010329e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01032a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01032a4:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c01032a7:	8b 15 48 40 12 c0    	mov    0xc0124048,%edx
c01032ad:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032b0:	01 d0                	add    %edx,%eax
c01032b2:	a3 48 40 12 c0       	mov    %eax,0xc0124048
    list_add_before(&free_list, &(base->page_link));
c01032b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01032ba:	83 c0 0c             	add    $0xc,%eax
c01032bd:	c7 45 dc 40 40 12 c0 	movl   $0xc0124040,-0x24(%ebp)
c01032c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01032c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01032ca:	8b 00                	mov    (%eax),%eax
c01032cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01032cf:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01032d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01032d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01032d8:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01032db:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01032de:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01032e1:	89 10                	mov    %edx,(%eax)
c01032e3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01032e6:	8b 10                	mov    (%eax),%edx
c01032e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01032eb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01032ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01032f1:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01032f4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01032f7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01032fa:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01032fd:	89 10                	mov    %edx,(%eax)
}
c01032ff:	c9                   	leave  
c0103300:	c3                   	ret    

c0103301 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0103301:	55                   	push   %ebp
c0103302:	89 e5                	mov    %esp,%ebp
c0103304:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0103307:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010330b:	75 24                	jne    c0103331 <default_alloc_pages+0x30>
c010330d:	c7 44 24 0c d0 94 10 	movl   $0xc01094d0,0xc(%esp)
c0103314:	c0 
c0103315:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c010331c:	c0 
c010331d:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0103324:	00 
c0103325:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c010332c:	e8 f6 d8 ff ff       	call   c0100c27 <__panic>
    if (n > nr_free) {
c0103331:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c0103336:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103339:	73 0a                	jae    c0103345 <default_alloc_pages+0x44>
        return NULL;
c010333b:	b8 00 00 00 00       	mov    $0x0,%eax
c0103340:	e9 36 01 00 00       	jmp    c010347b <default_alloc_pages+0x17a>
    }
    struct Page *page = NULL;
c0103345:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c010334c:	c7 45 f0 40 40 12 c0 	movl   $0xc0124040,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c0103353:	eb 1c                	jmp    c0103371 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0103355:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103358:	83 e8 0c             	sub    $0xc,%eax
c010335b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c010335e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103361:	8b 40 08             	mov    0x8(%eax),%eax
c0103364:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103367:	72 08                	jb     c0103371 <default_alloc_pages+0x70>
            page = p;
c0103369:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010336c:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c010336f:	eb 18                	jmp    c0103389 <default_alloc_pages+0x88>
c0103371:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103374:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103377:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010337a:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c010337d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103380:	81 7d f0 40 40 12 c0 	cmpl   $0xc0124040,-0x10(%ebp)
c0103387:	75 cc                	jne    c0103355 <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c0103389:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010338d:	0f 84 e5 00 00 00    	je     c0103478 <default_alloc_pages+0x177>
        if (page->property > n) {
c0103393:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103396:	8b 40 08             	mov    0x8(%eax),%eax
c0103399:	3b 45 08             	cmp    0x8(%ebp),%eax
c010339c:	0f 86 85 00 00 00    	jbe    c0103427 <default_alloc_pages+0x126>
            struct Page *p = page + n;
c01033a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01033a5:	c1 e0 05             	shl    $0x5,%eax
c01033a8:	89 c2                	mov    %eax,%edx
c01033aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033ad:	01 d0                	add    %edx,%eax
c01033af:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c01033b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033b5:	8b 40 08             	mov    0x8(%eax),%eax
c01033b8:	2b 45 08             	sub    0x8(%ebp),%eax
c01033bb:	89 c2                	mov    %eax,%edx
c01033bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01033c0:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c01033c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01033c6:	83 c0 04             	add    $0x4,%eax
c01033c9:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01033d0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01033d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01033d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01033d9:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c01033dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01033df:	83 c0 0c             	add    $0xc,%eax
c01033e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01033e5:	83 c2 0c             	add    $0xc,%edx
c01033e8:	89 55 d8             	mov    %edx,-0x28(%ebp)
c01033eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01033ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01033f1:	8b 40 04             	mov    0x4(%eax),%eax
c01033f4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01033f7:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01033fa:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01033fd:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0103400:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103403:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103406:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103409:	89 10                	mov    %edx,(%eax)
c010340b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010340e:	8b 10                	mov    (%eax),%edx
c0103410:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103413:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103416:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103419:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010341c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010341f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103422:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103425:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
c0103427:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010342a:	83 c0 0c             	add    $0xc,%eax
c010342d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103430:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103433:	8b 40 04             	mov    0x4(%eax),%eax
c0103436:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0103439:	8b 12                	mov    (%edx),%edx
c010343b:	89 55 c0             	mov    %edx,-0x40(%ebp)
c010343e:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103441:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103444:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103447:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010344a:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010344d:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103450:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c0103452:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c0103457:	2b 45 08             	sub    0x8(%ebp),%eax
c010345a:	a3 48 40 12 c0       	mov    %eax,0xc0124048
        ClearPageProperty(page);
c010345f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103462:	83 c0 04             	add    $0x4,%eax
c0103465:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c010346c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010346f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103472:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103475:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0103478:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010347b:	c9                   	leave  
c010347c:	c3                   	ret    

c010347d <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c010347d:	55                   	push   %ebp
c010347e:	89 e5                	mov    %esp,%ebp
c0103480:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0103486:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010348a:	75 24                	jne    c01034b0 <default_free_pages+0x33>
c010348c:	c7 44 24 0c d0 94 10 	movl   $0xc01094d0,0xc(%esp)
c0103493:	c0 
c0103494:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c010349b:	c0 
c010349c:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c01034a3:	00 
c01034a4:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c01034ab:	e8 77 d7 ff ff       	call   c0100c27 <__panic>
    struct Page *p = base;
c01034b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01034b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01034b6:	e9 9d 00 00 00       	jmp    c0103558 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c01034bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034be:	83 c0 04             	add    $0x4,%eax
c01034c1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01034c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01034cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01034ce:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01034d1:	0f a3 10             	bt     %edx,(%eax)
c01034d4:	19 c0                	sbb    %eax,%eax
c01034d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c01034d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01034dd:	0f 95 c0             	setne  %al
c01034e0:	0f b6 c0             	movzbl %al,%eax
c01034e3:	85 c0                	test   %eax,%eax
c01034e5:	75 2c                	jne    c0103513 <default_free_pages+0x96>
c01034e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034ea:	83 c0 04             	add    $0x4,%eax
c01034ed:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01034f4:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01034f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01034fa:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01034fd:	0f a3 10             	bt     %edx,(%eax)
c0103500:	19 c0                	sbb    %eax,%eax
c0103502:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0103505:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0103509:	0f 95 c0             	setne  %al
c010350c:	0f b6 c0             	movzbl %al,%eax
c010350f:	85 c0                	test   %eax,%eax
c0103511:	74 24                	je     c0103537 <default_free_pages+0xba>
c0103513:	c7 44 24 0c 14 95 10 	movl   $0xc0109514,0xc(%esp)
c010351a:	c0 
c010351b:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103522:	c0 
c0103523:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
c010352a:	00 
c010352b:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103532:	e8 f0 d6 ff ff       	call   c0100c27 <__panic>
        p->flags = 0;
c0103537:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010353a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0103541:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103548:	00 
c0103549:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010354c:	89 04 24             	mov    %eax,(%esp)
c010354f:	e8 2c fc ff ff       	call   c0103180 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0103554:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103558:	8b 45 0c             	mov    0xc(%ebp),%eax
c010355b:	c1 e0 05             	shl    $0x5,%eax
c010355e:	89 c2                	mov    %eax,%edx
c0103560:	8b 45 08             	mov    0x8(%ebp),%eax
c0103563:	01 d0                	add    %edx,%eax
c0103565:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103568:	0f 85 4d ff ff ff    	jne    c01034bb <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c010356e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103571:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103574:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0103577:	8b 45 08             	mov    0x8(%ebp),%eax
c010357a:	83 c0 04             	add    $0x4,%eax
c010357d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0103584:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103587:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010358a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010358d:	0f ab 10             	bts    %edx,(%eax)
c0103590:	c7 45 cc 40 40 12 c0 	movl   $0xc0124040,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103597:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010359a:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c010359d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01035a0:	e9 fa 00 00 00       	jmp    c010369f <default_free_pages+0x222>
        p = le2page(le, page_link);
c01035a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01035a8:	83 e8 0c             	sub    $0xc,%eax
c01035ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01035ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01035b1:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01035b4:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01035b7:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01035ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c01035bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01035c0:	8b 40 08             	mov    0x8(%eax),%eax
c01035c3:	c1 e0 05             	shl    $0x5,%eax
c01035c6:	89 c2                	mov    %eax,%edx
c01035c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01035cb:	01 d0                	add    %edx,%eax
c01035cd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01035d0:	75 5a                	jne    c010362c <default_free_pages+0x1af>
            base->property += p->property;
c01035d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01035d5:	8b 50 08             	mov    0x8(%eax),%edx
c01035d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035db:	8b 40 08             	mov    0x8(%eax),%eax
c01035de:	01 c2                	add    %eax,%edx
c01035e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01035e3:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c01035e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035e9:	83 c0 04             	add    $0x4,%eax
c01035ec:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c01035f3:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01035f6:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01035f9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01035fc:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c01035ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103602:	83 c0 0c             	add    $0xc,%eax
c0103605:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103608:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010360b:	8b 40 04             	mov    0x4(%eax),%eax
c010360e:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103611:	8b 12                	mov    (%edx),%edx
c0103613:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0103616:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103619:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010361c:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010361f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103622:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103625:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103628:	89 10                	mov    %edx,(%eax)
c010362a:	eb 73                	jmp    c010369f <default_free_pages+0x222>
        }
        else if (p + p->property == base) {
c010362c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010362f:	8b 40 08             	mov    0x8(%eax),%eax
c0103632:	c1 e0 05             	shl    $0x5,%eax
c0103635:	89 c2                	mov    %eax,%edx
c0103637:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010363a:	01 d0                	add    %edx,%eax
c010363c:	3b 45 08             	cmp    0x8(%ebp),%eax
c010363f:	75 5e                	jne    c010369f <default_free_pages+0x222>
            p->property += base->property;
c0103641:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103644:	8b 50 08             	mov    0x8(%eax),%edx
c0103647:	8b 45 08             	mov    0x8(%ebp),%eax
c010364a:	8b 40 08             	mov    0x8(%eax),%eax
c010364d:	01 c2                	add    %eax,%edx
c010364f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103652:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0103655:	8b 45 08             	mov    0x8(%ebp),%eax
c0103658:	83 c0 04             	add    $0x4,%eax
c010365b:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0103662:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0103665:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103668:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010366b:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c010366e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103671:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0103674:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103677:	83 c0 0c             	add    $0xc,%eax
c010367a:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010367d:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103680:	8b 40 04             	mov    0x4(%eax),%eax
c0103683:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103686:	8b 12                	mov    (%edx),%edx
c0103688:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c010368b:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010368e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0103691:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0103694:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103697:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010369a:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010369d:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c010369f:	81 7d f0 40 40 12 c0 	cmpl   $0xc0124040,-0x10(%ebp)
c01036a6:	0f 85 f9 fe ff ff    	jne    c01035a5 <default_free_pages+0x128>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c01036ac:	8b 15 48 40 12 c0    	mov    0xc0124048,%edx
c01036b2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01036b5:	01 d0                	add    %edx,%eax
c01036b7:	a3 48 40 12 c0       	mov    %eax,0xc0124048
c01036bc:	c7 45 9c 40 40 12 c0 	movl   $0xc0124040,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01036c3:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01036c6:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c01036c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01036cc:	eb 68                	jmp    c0103736 <default_free_pages+0x2b9>
        p = le2page(le, page_link);
c01036ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01036d1:	83 e8 0c             	sub    $0xc,%eax
c01036d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c01036d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01036da:	8b 40 08             	mov    0x8(%eax),%eax
c01036dd:	c1 e0 05             	shl    $0x5,%eax
c01036e0:	89 c2                	mov    %eax,%edx
c01036e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01036e5:	01 d0                	add    %edx,%eax
c01036e7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01036ea:	77 3b                	ja     c0103727 <default_free_pages+0x2aa>
            assert(base + base->property != p);
c01036ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01036ef:	8b 40 08             	mov    0x8(%eax),%eax
c01036f2:	c1 e0 05             	shl    $0x5,%eax
c01036f5:	89 c2                	mov    %eax,%edx
c01036f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01036fa:	01 d0                	add    %edx,%eax
c01036fc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01036ff:	75 24                	jne    c0103725 <default_free_pages+0x2a8>
c0103701:	c7 44 24 0c 39 95 10 	movl   $0xc0109539,0xc(%esp)
c0103708:	c0 
c0103709:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103710:	c0 
c0103711:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0103718:	00 
c0103719:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103720:	e8 02 d5 ff ff       	call   c0100c27 <__panic>
            break;
c0103725:	eb 18                	jmp    c010373f <default_free_pages+0x2c2>
c0103727:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010372a:	89 45 98             	mov    %eax,-0x68(%ebp)
c010372d:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103730:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
c0103733:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
c0103736:	81 7d f0 40 40 12 c0 	cmpl   $0xc0124040,-0x10(%ebp)
c010373d:	75 8f                	jne    c01036ce <default_free_pages+0x251>
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
c010373f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103742:	8d 50 0c             	lea    0xc(%eax),%edx
c0103745:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103748:	89 45 94             	mov    %eax,-0x6c(%ebp)
c010374b:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010374e:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103751:	8b 00                	mov    (%eax),%eax
c0103753:	8b 55 90             	mov    -0x70(%ebp),%edx
c0103756:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0103759:	89 45 88             	mov    %eax,-0x78(%ebp)
c010375c:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010375f:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103762:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103765:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0103768:	89 10                	mov    %edx,(%eax)
c010376a:	8b 45 84             	mov    -0x7c(%ebp),%eax
c010376d:	8b 10                	mov    (%eax),%edx
c010376f:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103772:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103775:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103778:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010377b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010377e:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103781:	8b 55 88             	mov    -0x78(%ebp),%edx
c0103784:	89 10                	mov    %edx,(%eax)
}
c0103786:	c9                   	leave  
c0103787:	c3                   	ret    

c0103788 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0103788:	55                   	push   %ebp
c0103789:	89 e5                	mov    %esp,%ebp
    return nr_free;
c010378b:	a1 48 40 12 c0       	mov    0xc0124048,%eax
}
c0103790:	5d                   	pop    %ebp
c0103791:	c3                   	ret    

c0103792 <basic_check>:

static void
basic_check(void) {
c0103792:	55                   	push   %ebp
c0103793:	89 e5                	mov    %esp,%ebp
c0103795:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103798:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010379f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01037a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c01037ab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01037b2:	e8 d7 0e 00 00       	call   c010468e <alloc_pages>
c01037b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01037ba:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01037be:	75 24                	jne    c01037e4 <basic_check+0x52>
c01037c0:	c7 44 24 0c 54 95 10 	movl   $0xc0109554,0xc(%esp)
c01037c7:	c0 
c01037c8:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c01037cf:	c0 
c01037d0:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c01037d7:	00 
c01037d8:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c01037df:	e8 43 d4 ff ff       	call   c0100c27 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01037e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01037eb:	e8 9e 0e 00 00       	call   c010468e <alloc_pages>
c01037f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01037f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01037f7:	75 24                	jne    c010381d <basic_check+0x8b>
c01037f9:	c7 44 24 0c 70 95 10 	movl   $0xc0109570,0xc(%esp)
c0103800:	c0 
c0103801:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103808:	c0 
c0103809:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0103810:	00 
c0103811:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103818:	e8 0a d4 ff ff       	call   c0100c27 <__panic>
    assert((p2 = alloc_page()) != NULL);
c010381d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103824:	e8 65 0e 00 00       	call   c010468e <alloc_pages>
c0103829:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010382c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103830:	75 24                	jne    c0103856 <basic_check+0xc4>
c0103832:	c7 44 24 0c 8c 95 10 	movl   $0xc010958c,0xc(%esp)
c0103839:	c0 
c010383a:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103841:	c0 
c0103842:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0103849:	00 
c010384a:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103851:	e8 d1 d3 ff ff       	call   c0100c27 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103856:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103859:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010385c:	74 10                	je     c010386e <basic_check+0xdc>
c010385e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103861:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103864:	74 08                	je     c010386e <basic_check+0xdc>
c0103866:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103869:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010386c:	75 24                	jne    c0103892 <basic_check+0x100>
c010386e:	c7 44 24 0c a8 95 10 	movl   $0xc01095a8,0xc(%esp)
c0103875:	c0 
c0103876:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c010387d:	c0 
c010387e:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0103885:	00 
c0103886:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c010388d:	e8 95 d3 ff ff       	call   c0100c27 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103892:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103895:	89 04 24             	mov    %eax,(%esp)
c0103898:	e8 d9 f8 ff ff       	call   c0103176 <page_ref>
c010389d:	85 c0                	test   %eax,%eax
c010389f:	75 1e                	jne    c01038bf <basic_check+0x12d>
c01038a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038a4:	89 04 24             	mov    %eax,(%esp)
c01038a7:	e8 ca f8 ff ff       	call   c0103176 <page_ref>
c01038ac:	85 c0                	test   %eax,%eax
c01038ae:	75 0f                	jne    c01038bf <basic_check+0x12d>
c01038b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038b3:	89 04 24             	mov    %eax,(%esp)
c01038b6:	e8 bb f8 ff ff       	call   c0103176 <page_ref>
c01038bb:	85 c0                	test   %eax,%eax
c01038bd:	74 24                	je     c01038e3 <basic_check+0x151>
c01038bf:	c7 44 24 0c cc 95 10 	movl   $0xc01095cc,0xc(%esp)
c01038c6:	c0 
c01038c7:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c01038ce:	c0 
c01038cf:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c01038d6:	00 
c01038d7:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c01038de:	e8 44 d3 ff ff       	call   c0100c27 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c01038e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01038e6:	89 04 24             	mov    %eax,(%esp)
c01038e9:	e8 72 f8 ff ff       	call   c0103160 <page2pa>
c01038ee:	8b 15 a0 3f 12 c0    	mov    0xc0123fa0,%edx
c01038f4:	c1 e2 0c             	shl    $0xc,%edx
c01038f7:	39 d0                	cmp    %edx,%eax
c01038f9:	72 24                	jb     c010391f <basic_check+0x18d>
c01038fb:	c7 44 24 0c 08 96 10 	movl   $0xc0109608,0xc(%esp)
c0103902:	c0 
c0103903:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c010390a:	c0 
c010390b:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0103912:	00 
c0103913:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c010391a:	e8 08 d3 ff ff       	call   c0100c27 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c010391f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103922:	89 04 24             	mov    %eax,(%esp)
c0103925:	e8 36 f8 ff ff       	call   c0103160 <page2pa>
c010392a:	8b 15 a0 3f 12 c0    	mov    0xc0123fa0,%edx
c0103930:	c1 e2 0c             	shl    $0xc,%edx
c0103933:	39 d0                	cmp    %edx,%eax
c0103935:	72 24                	jb     c010395b <basic_check+0x1c9>
c0103937:	c7 44 24 0c 25 96 10 	movl   $0xc0109625,0xc(%esp)
c010393e:	c0 
c010393f:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103946:	c0 
c0103947:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c010394e:	00 
c010394f:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103956:	e8 cc d2 ff ff       	call   c0100c27 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c010395b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010395e:	89 04 24             	mov    %eax,(%esp)
c0103961:	e8 fa f7 ff ff       	call   c0103160 <page2pa>
c0103966:	8b 15 a0 3f 12 c0    	mov    0xc0123fa0,%edx
c010396c:	c1 e2 0c             	shl    $0xc,%edx
c010396f:	39 d0                	cmp    %edx,%eax
c0103971:	72 24                	jb     c0103997 <basic_check+0x205>
c0103973:	c7 44 24 0c 42 96 10 	movl   $0xc0109642,0xc(%esp)
c010397a:	c0 
c010397b:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103982:	c0 
c0103983:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c010398a:	00 
c010398b:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103992:	e8 90 d2 ff ff       	call   c0100c27 <__panic>

    list_entry_t free_list_store = free_list;
c0103997:	a1 40 40 12 c0       	mov    0xc0124040,%eax
c010399c:	8b 15 44 40 12 c0    	mov    0xc0124044,%edx
c01039a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01039a5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01039a8:	c7 45 e0 40 40 12 c0 	movl   $0xc0124040,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01039af:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01039b2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01039b5:	89 50 04             	mov    %edx,0x4(%eax)
c01039b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01039bb:	8b 50 04             	mov    0x4(%eax),%edx
c01039be:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01039c1:	89 10                	mov    %edx,(%eax)
c01039c3:	c7 45 dc 40 40 12 c0 	movl   $0xc0124040,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01039ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01039cd:	8b 40 04             	mov    0x4(%eax),%eax
c01039d0:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01039d3:	0f 94 c0             	sete   %al
c01039d6:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01039d9:	85 c0                	test   %eax,%eax
c01039db:	75 24                	jne    c0103a01 <basic_check+0x26f>
c01039dd:	c7 44 24 0c 5f 96 10 	movl   $0xc010965f,0xc(%esp)
c01039e4:	c0 
c01039e5:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c01039ec:	c0 
c01039ed:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c01039f4:	00 
c01039f5:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c01039fc:	e8 26 d2 ff ff       	call   c0100c27 <__panic>

    unsigned int nr_free_store = nr_free;
c0103a01:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c0103a06:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103a09:	c7 05 48 40 12 c0 00 	movl   $0x0,0xc0124048
c0103a10:	00 00 00 

    assert(alloc_page() == NULL);
c0103a13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a1a:	e8 6f 0c 00 00       	call   c010468e <alloc_pages>
c0103a1f:	85 c0                	test   %eax,%eax
c0103a21:	74 24                	je     c0103a47 <basic_check+0x2b5>
c0103a23:	c7 44 24 0c 76 96 10 	movl   $0xc0109676,0xc(%esp)
c0103a2a:	c0 
c0103a2b:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103a32:	c0 
c0103a33:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0103a3a:	00 
c0103a3b:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103a42:	e8 e0 d1 ff ff       	call   c0100c27 <__panic>

    free_page(p0);
c0103a47:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103a4e:	00 
c0103a4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a52:	89 04 24             	mov    %eax,(%esp)
c0103a55:	e8 9f 0c 00 00       	call   c01046f9 <free_pages>
    free_page(p1);
c0103a5a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103a61:	00 
c0103a62:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a65:	89 04 24             	mov    %eax,(%esp)
c0103a68:	e8 8c 0c 00 00       	call   c01046f9 <free_pages>
    free_page(p2);
c0103a6d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103a74:	00 
c0103a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a78:	89 04 24             	mov    %eax,(%esp)
c0103a7b:	e8 79 0c 00 00       	call   c01046f9 <free_pages>
    assert(nr_free == 3);
c0103a80:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c0103a85:	83 f8 03             	cmp    $0x3,%eax
c0103a88:	74 24                	je     c0103aae <basic_check+0x31c>
c0103a8a:	c7 44 24 0c 8b 96 10 	movl   $0xc010968b,0xc(%esp)
c0103a91:	c0 
c0103a92:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103a99:	c0 
c0103a9a:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0103aa1:	00 
c0103aa2:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103aa9:	e8 79 d1 ff ff       	call   c0100c27 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103aae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ab5:	e8 d4 0b 00 00       	call   c010468e <alloc_pages>
c0103aba:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103abd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103ac1:	75 24                	jne    c0103ae7 <basic_check+0x355>
c0103ac3:	c7 44 24 0c 54 95 10 	movl   $0xc0109554,0xc(%esp)
c0103aca:	c0 
c0103acb:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103ad2:	c0 
c0103ad3:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0103ada:	00 
c0103adb:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103ae2:	e8 40 d1 ff ff       	call   c0100c27 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103ae7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103aee:	e8 9b 0b 00 00       	call   c010468e <alloc_pages>
c0103af3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103af6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103afa:	75 24                	jne    c0103b20 <basic_check+0x38e>
c0103afc:	c7 44 24 0c 70 95 10 	movl   $0xc0109570,0xc(%esp)
c0103b03:	c0 
c0103b04:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103b0b:	c0 
c0103b0c:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0103b13:	00 
c0103b14:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103b1b:	e8 07 d1 ff ff       	call   c0100c27 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103b20:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103b27:	e8 62 0b 00 00       	call   c010468e <alloc_pages>
c0103b2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103b2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103b33:	75 24                	jne    c0103b59 <basic_check+0x3c7>
c0103b35:	c7 44 24 0c 8c 95 10 	movl   $0xc010958c,0xc(%esp)
c0103b3c:	c0 
c0103b3d:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103b44:	c0 
c0103b45:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c0103b4c:	00 
c0103b4d:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103b54:	e8 ce d0 ff ff       	call   c0100c27 <__panic>

    assert(alloc_page() == NULL);
c0103b59:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103b60:	e8 29 0b 00 00       	call   c010468e <alloc_pages>
c0103b65:	85 c0                	test   %eax,%eax
c0103b67:	74 24                	je     c0103b8d <basic_check+0x3fb>
c0103b69:	c7 44 24 0c 76 96 10 	movl   $0xc0109676,0xc(%esp)
c0103b70:	c0 
c0103b71:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103b78:	c0 
c0103b79:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0103b80:	00 
c0103b81:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103b88:	e8 9a d0 ff ff       	call   c0100c27 <__panic>

    free_page(p0);
c0103b8d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103b94:	00 
c0103b95:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b98:	89 04 24             	mov    %eax,(%esp)
c0103b9b:	e8 59 0b 00 00       	call   c01046f9 <free_pages>
c0103ba0:	c7 45 d8 40 40 12 c0 	movl   $0xc0124040,-0x28(%ebp)
c0103ba7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103baa:	8b 40 04             	mov    0x4(%eax),%eax
c0103bad:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103bb0:	0f 94 c0             	sete   %al
c0103bb3:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103bb6:	85 c0                	test   %eax,%eax
c0103bb8:	74 24                	je     c0103bde <basic_check+0x44c>
c0103bba:	c7 44 24 0c 98 96 10 	movl   $0xc0109698,0xc(%esp)
c0103bc1:	c0 
c0103bc2:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103bc9:	c0 
c0103bca:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0103bd1:	00 
c0103bd2:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103bd9:	e8 49 d0 ff ff       	call   c0100c27 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103bde:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103be5:	e8 a4 0a 00 00       	call   c010468e <alloc_pages>
c0103bea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103bed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103bf0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103bf3:	74 24                	je     c0103c19 <basic_check+0x487>
c0103bf5:	c7 44 24 0c b0 96 10 	movl   $0xc01096b0,0xc(%esp)
c0103bfc:	c0 
c0103bfd:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103c04:	c0 
c0103c05:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c0103c0c:	00 
c0103c0d:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103c14:	e8 0e d0 ff ff       	call   c0100c27 <__panic>
    assert(alloc_page() == NULL);
c0103c19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c20:	e8 69 0a 00 00       	call   c010468e <alloc_pages>
c0103c25:	85 c0                	test   %eax,%eax
c0103c27:	74 24                	je     c0103c4d <basic_check+0x4bb>
c0103c29:	c7 44 24 0c 76 96 10 	movl   $0xc0109676,0xc(%esp)
c0103c30:	c0 
c0103c31:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103c38:	c0 
c0103c39:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0103c40:	00 
c0103c41:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103c48:	e8 da cf ff ff       	call   c0100c27 <__panic>

    assert(nr_free == 0);
c0103c4d:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c0103c52:	85 c0                	test   %eax,%eax
c0103c54:	74 24                	je     c0103c7a <basic_check+0x4e8>
c0103c56:	c7 44 24 0c c9 96 10 	movl   $0xc01096c9,0xc(%esp)
c0103c5d:	c0 
c0103c5e:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103c65:	c0 
c0103c66:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0103c6d:	00 
c0103c6e:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103c75:	e8 ad cf ff ff       	call   c0100c27 <__panic>
    free_list = free_list_store;
c0103c7a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103c7d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103c80:	a3 40 40 12 c0       	mov    %eax,0xc0124040
c0103c85:	89 15 44 40 12 c0    	mov    %edx,0xc0124044
    nr_free = nr_free_store;
c0103c8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c8e:	a3 48 40 12 c0       	mov    %eax,0xc0124048

    free_page(p);
c0103c93:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103c9a:	00 
c0103c9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c9e:	89 04 24             	mov    %eax,(%esp)
c0103ca1:	e8 53 0a 00 00       	call   c01046f9 <free_pages>
    free_page(p1);
c0103ca6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103cad:	00 
c0103cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103cb1:	89 04 24             	mov    %eax,(%esp)
c0103cb4:	e8 40 0a 00 00       	call   c01046f9 <free_pages>
    free_page(p2);
c0103cb9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103cc0:	00 
c0103cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cc4:	89 04 24             	mov    %eax,(%esp)
c0103cc7:	e8 2d 0a 00 00       	call   c01046f9 <free_pages>
}
c0103ccc:	c9                   	leave  
c0103ccd:	c3                   	ret    

c0103cce <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0103cce:	55                   	push   %ebp
c0103ccf:	89 e5                	mov    %esp,%ebp
c0103cd1:	53                   	push   %ebx
c0103cd2:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c0103cd8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103cdf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0103ce6:	c7 45 ec 40 40 12 c0 	movl   $0xc0124040,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103ced:	eb 6b                	jmp    c0103d5a <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0103cef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103cf2:	83 e8 0c             	sub    $0xc,%eax
c0103cf5:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c0103cf8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103cfb:	83 c0 04             	add    $0x4,%eax
c0103cfe:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103d05:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103d08:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103d0b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103d0e:	0f a3 10             	bt     %edx,(%eax)
c0103d11:	19 c0                	sbb    %eax,%eax
c0103d13:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0103d16:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103d1a:	0f 95 c0             	setne  %al
c0103d1d:	0f b6 c0             	movzbl %al,%eax
c0103d20:	85 c0                	test   %eax,%eax
c0103d22:	75 24                	jne    c0103d48 <default_check+0x7a>
c0103d24:	c7 44 24 0c d6 96 10 	movl   $0xc01096d6,0xc(%esp)
c0103d2b:	c0 
c0103d2c:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103d33:	c0 
c0103d34:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0103d3b:	00 
c0103d3c:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103d43:	e8 df ce ff ff       	call   c0100c27 <__panic>
        count ++, total += p->property;
c0103d48:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103d4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103d4f:	8b 50 08             	mov    0x8(%eax),%edx
c0103d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d55:	01 d0                	add    %edx,%eax
c0103d57:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103d5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d5d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103d60:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103d63:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0103d66:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103d69:	81 7d ec 40 40 12 c0 	cmpl   $0xc0124040,-0x14(%ebp)
c0103d70:	0f 85 79 ff ff ff    	jne    c0103cef <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0103d76:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0103d79:	e8 ad 09 00 00       	call   c010472b <nr_free_pages>
c0103d7e:	39 c3                	cmp    %eax,%ebx
c0103d80:	74 24                	je     c0103da6 <default_check+0xd8>
c0103d82:	c7 44 24 0c e6 96 10 	movl   $0xc01096e6,0xc(%esp)
c0103d89:	c0 
c0103d8a:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103d91:	c0 
c0103d92:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c0103d99:	00 
c0103d9a:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103da1:	e8 81 ce ff ff       	call   c0100c27 <__panic>

    basic_check();
c0103da6:	e8 e7 f9 ff ff       	call   c0103792 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0103dab:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0103db2:	e8 d7 08 00 00       	call   c010468e <alloc_pages>
c0103db7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c0103dba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103dbe:	75 24                	jne    c0103de4 <default_check+0x116>
c0103dc0:	c7 44 24 0c ff 96 10 	movl   $0xc01096ff,0xc(%esp)
c0103dc7:	c0 
c0103dc8:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103dcf:	c0 
c0103dd0:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c0103dd7:	00 
c0103dd8:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103ddf:	e8 43 ce ff ff       	call   c0100c27 <__panic>
    assert(!PageProperty(p0));
c0103de4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103de7:	83 c0 04             	add    $0x4,%eax
c0103dea:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0103df1:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103df4:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103df7:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103dfa:	0f a3 10             	bt     %edx,(%eax)
c0103dfd:	19 c0                	sbb    %eax,%eax
c0103dff:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0103e02:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0103e06:	0f 95 c0             	setne  %al
c0103e09:	0f b6 c0             	movzbl %al,%eax
c0103e0c:	85 c0                	test   %eax,%eax
c0103e0e:	74 24                	je     c0103e34 <default_check+0x166>
c0103e10:	c7 44 24 0c 0a 97 10 	movl   $0xc010970a,0xc(%esp)
c0103e17:	c0 
c0103e18:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103e1f:	c0 
c0103e20:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0103e27:	00 
c0103e28:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103e2f:	e8 f3 cd ff ff       	call   c0100c27 <__panic>

    list_entry_t free_list_store = free_list;
c0103e34:	a1 40 40 12 c0       	mov    0xc0124040,%eax
c0103e39:	8b 15 44 40 12 c0    	mov    0xc0124044,%edx
c0103e3f:	89 45 80             	mov    %eax,-0x80(%ebp)
c0103e42:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0103e45:	c7 45 b4 40 40 12 c0 	movl   $0xc0124040,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103e4c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103e4f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103e52:	89 50 04             	mov    %edx,0x4(%eax)
c0103e55:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103e58:	8b 50 04             	mov    0x4(%eax),%edx
c0103e5b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103e5e:	89 10                	mov    %edx,(%eax)
c0103e60:	c7 45 b0 40 40 12 c0 	movl   $0xc0124040,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103e67:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103e6a:	8b 40 04             	mov    0x4(%eax),%eax
c0103e6d:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c0103e70:	0f 94 c0             	sete   %al
c0103e73:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103e76:	85 c0                	test   %eax,%eax
c0103e78:	75 24                	jne    c0103e9e <default_check+0x1d0>
c0103e7a:	c7 44 24 0c 5f 96 10 	movl   $0xc010965f,0xc(%esp)
c0103e81:	c0 
c0103e82:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103e89:	c0 
c0103e8a:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0103e91:	00 
c0103e92:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103e99:	e8 89 cd ff ff       	call   c0100c27 <__panic>
    assert(alloc_page() == NULL);
c0103e9e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ea5:	e8 e4 07 00 00       	call   c010468e <alloc_pages>
c0103eaa:	85 c0                	test   %eax,%eax
c0103eac:	74 24                	je     c0103ed2 <default_check+0x204>
c0103eae:	c7 44 24 0c 76 96 10 	movl   $0xc0109676,0xc(%esp)
c0103eb5:	c0 
c0103eb6:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103ebd:	c0 
c0103ebe:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c0103ec5:	00 
c0103ec6:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103ecd:	e8 55 cd ff ff       	call   c0100c27 <__panic>

    unsigned int nr_free_store = nr_free;
c0103ed2:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c0103ed7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0103eda:	c7 05 48 40 12 c0 00 	movl   $0x0,0xc0124048
c0103ee1:	00 00 00 

    free_pages(p0 + 2, 3);
c0103ee4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ee7:	83 c0 40             	add    $0x40,%eax
c0103eea:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0103ef1:	00 
c0103ef2:	89 04 24             	mov    %eax,(%esp)
c0103ef5:	e8 ff 07 00 00       	call   c01046f9 <free_pages>
    assert(alloc_pages(4) == NULL);
c0103efa:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0103f01:	e8 88 07 00 00       	call   c010468e <alloc_pages>
c0103f06:	85 c0                	test   %eax,%eax
c0103f08:	74 24                	je     c0103f2e <default_check+0x260>
c0103f0a:	c7 44 24 0c 1c 97 10 	movl   $0xc010971c,0xc(%esp)
c0103f11:	c0 
c0103f12:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103f19:	c0 
c0103f1a:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0103f21:	00 
c0103f22:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103f29:	e8 f9 cc ff ff       	call   c0100c27 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0103f2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f31:	83 c0 40             	add    $0x40,%eax
c0103f34:	83 c0 04             	add    $0x4,%eax
c0103f37:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0103f3e:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103f41:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103f44:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103f47:	0f a3 10             	bt     %edx,(%eax)
c0103f4a:	19 c0                	sbb    %eax,%eax
c0103f4c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0103f4f:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0103f53:	0f 95 c0             	setne  %al
c0103f56:	0f b6 c0             	movzbl %al,%eax
c0103f59:	85 c0                	test   %eax,%eax
c0103f5b:	74 0e                	je     c0103f6b <default_check+0x29d>
c0103f5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f60:	83 c0 40             	add    $0x40,%eax
c0103f63:	8b 40 08             	mov    0x8(%eax),%eax
c0103f66:	83 f8 03             	cmp    $0x3,%eax
c0103f69:	74 24                	je     c0103f8f <default_check+0x2c1>
c0103f6b:	c7 44 24 0c 34 97 10 	movl   $0xc0109734,0xc(%esp)
c0103f72:	c0 
c0103f73:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103f7a:	c0 
c0103f7b:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0103f82:	00 
c0103f83:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103f8a:	e8 98 cc ff ff       	call   c0100c27 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0103f8f:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0103f96:	e8 f3 06 00 00       	call   c010468e <alloc_pages>
c0103f9b:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103f9e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103fa2:	75 24                	jne    c0103fc8 <default_check+0x2fa>
c0103fa4:	c7 44 24 0c 60 97 10 	movl   $0xc0109760,0xc(%esp)
c0103fab:	c0 
c0103fac:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103fb3:	c0 
c0103fb4:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c0103fbb:	00 
c0103fbc:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103fc3:	e8 5f cc ff ff       	call   c0100c27 <__panic>
    assert(alloc_page() == NULL);
c0103fc8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103fcf:	e8 ba 06 00 00       	call   c010468e <alloc_pages>
c0103fd4:	85 c0                	test   %eax,%eax
c0103fd6:	74 24                	je     c0103ffc <default_check+0x32e>
c0103fd8:	c7 44 24 0c 76 96 10 	movl   $0xc0109676,0xc(%esp)
c0103fdf:	c0 
c0103fe0:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0103fe7:	c0 
c0103fe8:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c0103fef:	00 
c0103ff0:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0103ff7:	e8 2b cc ff ff       	call   c0100c27 <__panic>
    assert(p0 + 2 == p1);
c0103ffc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103fff:	83 c0 40             	add    $0x40,%eax
c0104002:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104005:	74 24                	je     c010402b <default_check+0x35d>
c0104007:	c7 44 24 0c 7e 97 10 	movl   $0xc010977e,0xc(%esp)
c010400e:	c0 
c010400f:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0104016:	c0 
c0104017:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c010401e:	00 
c010401f:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0104026:	e8 fc cb ff ff       	call   c0100c27 <__panic>

    p2 = p0 + 1;
c010402b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010402e:	83 c0 20             	add    $0x20,%eax
c0104031:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0104034:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010403b:	00 
c010403c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010403f:	89 04 24             	mov    %eax,(%esp)
c0104042:	e8 b2 06 00 00       	call   c01046f9 <free_pages>
    free_pages(p1, 3);
c0104047:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010404e:	00 
c010404f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104052:	89 04 24             	mov    %eax,(%esp)
c0104055:	e8 9f 06 00 00       	call   c01046f9 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010405a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010405d:	83 c0 04             	add    $0x4,%eax
c0104060:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0104067:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010406a:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010406d:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104070:	0f a3 10             	bt     %edx,(%eax)
c0104073:	19 c0                	sbb    %eax,%eax
c0104075:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0104078:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c010407c:	0f 95 c0             	setne  %al
c010407f:	0f b6 c0             	movzbl %al,%eax
c0104082:	85 c0                	test   %eax,%eax
c0104084:	74 0b                	je     c0104091 <default_check+0x3c3>
c0104086:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104089:	8b 40 08             	mov    0x8(%eax),%eax
c010408c:	83 f8 01             	cmp    $0x1,%eax
c010408f:	74 24                	je     c01040b5 <default_check+0x3e7>
c0104091:	c7 44 24 0c 8c 97 10 	movl   $0xc010978c,0xc(%esp)
c0104098:	c0 
c0104099:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c01040a0:	c0 
c01040a1:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c01040a8:	00 
c01040a9:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c01040b0:	e8 72 cb ff ff       	call   c0100c27 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01040b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01040b8:	83 c0 04             	add    $0x4,%eax
c01040bb:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c01040c2:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01040c5:	8b 45 90             	mov    -0x70(%ebp),%eax
c01040c8:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01040cb:	0f a3 10             	bt     %edx,(%eax)
c01040ce:	19 c0                	sbb    %eax,%eax
c01040d0:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01040d3:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01040d7:	0f 95 c0             	setne  %al
c01040da:	0f b6 c0             	movzbl %al,%eax
c01040dd:	85 c0                	test   %eax,%eax
c01040df:	74 0b                	je     c01040ec <default_check+0x41e>
c01040e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01040e4:	8b 40 08             	mov    0x8(%eax),%eax
c01040e7:	83 f8 03             	cmp    $0x3,%eax
c01040ea:	74 24                	je     c0104110 <default_check+0x442>
c01040ec:	c7 44 24 0c b4 97 10 	movl   $0xc01097b4,0xc(%esp)
c01040f3:	c0 
c01040f4:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c01040fb:	c0 
c01040fc:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c0104103:	00 
c0104104:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c010410b:	e8 17 cb ff ff       	call   c0100c27 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0104110:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104117:	e8 72 05 00 00       	call   c010468e <alloc_pages>
c010411c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010411f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104122:	83 e8 20             	sub    $0x20,%eax
c0104125:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0104128:	74 24                	je     c010414e <default_check+0x480>
c010412a:	c7 44 24 0c da 97 10 	movl   $0xc01097da,0xc(%esp)
c0104131:	c0 
c0104132:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0104139:	c0 
c010413a:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c0104141:	00 
c0104142:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0104149:	e8 d9 ca ff ff       	call   c0100c27 <__panic>
    free_page(p0);
c010414e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104155:	00 
c0104156:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104159:	89 04 24             	mov    %eax,(%esp)
c010415c:	e8 98 05 00 00       	call   c01046f9 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0104161:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0104168:	e8 21 05 00 00       	call   c010468e <alloc_pages>
c010416d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104170:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104173:	83 c0 20             	add    $0x20,%eax
c0104176:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0104179:	74 24                	je     c010419f <default_check+0x4d1>
c010417b:	c7 44 24 0c f8 97 10 	movl   $0xc01097f8,0xc(%esp)
c0104182:	c0 
c0104183:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c010418a:	c0 
c010418b:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0104192:	00 
c0104193:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c010419a:	e8 88 ca ff ff       	call   c0100c27 <__panic>

    free_pages(p0, 2);
c010419f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01041a6:	00 
c01041a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01041aa:	89 04 24             	mov    %eax,(%esp)
c01041ad:	e8 47 05 00 00       	call   c01046f9 <free_pages>
    free_page(p2);
c01041b2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01041b9:	00 
c01041ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01041bd:	89 04 24             	mov    %eax,(%esp)
c01041c0:	e8 34 05 00 00       	call   c01046f9 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01041c5:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01041cc:	e8 bd 04 00 00       	call   c010468e <alloc_pages>
c01041d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01041d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01041d8:	75 24                	jne    c01041fe <default_check+0x530>
c01041da:	c7 44 24 0c 18 98 10 	movl   $0xc0109818,0xc(%esp)
c01041e1:	c0 
c01041e2:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c01041e9:	c0 
c01041ea:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c01041f1:	00 
c01041f2:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c01041f9:	e8 29 ca ff ff       	call   c0100c27 <__panic>
    assert(alloc_page() == NULL);
c01041fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104205:	e8 84 04 00 00       	call   c010468e <alloc_pages>
c010420a:	85 c0                	test   %eax,%eax
c010420c:	74 24                	je     c0104232 <default_check+0x564>
c010420e:	c7 44 24 0c 76 96 10 	movl   $0xc0109676,0xc(%esp)
c0104215:	c0 
c0104216:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c010421d:	c0 
c010421e:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0104225:	00 
c0104226:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c010422d:	e8 f5 c9 ff ff       	call   c0100c27 <__panic>

    assert(nr_free == 0);
c0104232:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c0104237:	85 c0                	test   %eax,%eax
c0104239:	74 24                	je     c010425f <default_check+0x591>
c010423b:	c7 44 24 0c c9 96 10 	movl   $0xc01096c9,0xc(%esp)
c0104242:	c0 
c0104243:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c010424a:	c0 
c010424b:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c0104252:	00 
c0104253:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c010425a:	e8 c8 c9 ff ff       	call   c0100c27 <__panic>
    nr_free = nr_free_store;
c010425f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104262:	a3 48 40 12 c0       	mov    %eax,0xc0124048

    free_list = free_list_store;
c0104267:	8b 45 80             	mov    -0x80(%ebp),%eax
c010426a:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010426d:	a3 40 40 12 c0       	mov    %eax,0xc0124040
c0104272:	89 15 44 40 12 c0    	mov    %edx,0xc0124044
    free_pages(p0, 5);
c0104278:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c010427f:	00 
c0104280:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104283:	89 04 24             	mov    %eax,(%esp)
c0104286:	e8 6e 04 00 00       	call   c01046f9 <free_pages>

    le = &free_list;
c010428b:	c7 45 ec 40 40 12 c0 	movl   $0xc0124040,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104292:	eb 1d                	jmp    c01042b1 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c0104294:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104297:	83 e8 0c             	sub    $0xc,%eax
c010429a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c010429d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01042a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01042a4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01042a7:	8b 40 08             	mov    0x8(%eax),%eax
c01042aa:	29 c2                	sub    %eax,%edx
c01042ac:	89 d0                	mov    %edx,%eax
c01042ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01042b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01042b4:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01042b7:	8b 45 88             	mov    -0x78(%ebp),%eax
c01042ba:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01042bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01042c0:	81 7d ec 40 40 12 c0 	cmpl   $0xc0124040,-0x14(%ebp)
c01042c7:	75 cb                	jne    c0104294 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c01042c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01042cd:	74 24                	je     c01042f3 <default_check+0x625>
c01042cf:	c7 44 24 0c 36 98 10 	movl   $0xc0109836,0xc(%esp)
c01042d6:	c0 
c01042d7:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c01042de:	c0 
c01042df:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c01042e6:	00 
c01042e7:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c01042ee:	e8 34 c9 ff ff       	call   c0100c27 <__panic>
    assert(total == 0);
c01042f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01042f7:	74 24                	je     c010431d <default_check+0x64f>
c01042f9:	c7 44 24 0c 41 98 10 	movl   $0xc0109841,0xc(%esp)
c0104300:	c0 
c0104301:	c7 44 24 08 d6 94 10 	movl   $0xc01094d6,0x8(%esp)
c0104308:	c0 
c0104309:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
c0104310:	00 
c0104311:	c7 04 24 eb 94 10 c0 	movl   $0xc01094eb,(%esp)
c0104318:	e8 0a c9 ff ff       	call   c0100c27 <__panic>
}
c010431d:	81 c4 94 00 00 00    	add    $0x94,%esp
c0104323:	5b                   	pop    %ebx
c0104324:	5d                   	pop    %ebp
c0104325:	c3                   	ret    

c0104326 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104326:	55                   	push   %ebp
c0104327:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104329:	8b 55 08             	mov    0x8(%ebp),%edx
c010432c:	a1 54 40 12 c0       	mov    0xc0124054,%eax
c0104331:	29 c2                	sub    %eax,%edx
c0104333:	89 d0                	mov    %edx,%eax
c0104335:	c1 f8 05             	sar    $0x5,%eax
}
c0104338:	5d                   	pop    %ebp
c0104339:	c3                   	ret    

c010433a <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010433a:	55                   	push   %ebp
c010433b:	89 e5                	mov    %esp,%ebp
c010433d:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104340:	8b 45 08             	mov    0x8(%ebp),%eax
c0104343:	89 04 24             	mov    %eax,(%esp)
c0104346:	e8 db ff ff ff       	call   c0104326 <page2ppn>
c010434b:	c1 e0 0c             	shl    $0xc,%eax
}
c010434e:	c9                   	leave  
c010434f:	c3                   	ret    

c0104350 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0104350:	55                   	push   %ebp
c0104351:	89 e5                	mov    %esp,%ebp
c0104353:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104356:	8b 45 08             	mov    0x8(%ebp),%eax
c0104359:	c1 e8 0c             	shr    $0xc,%eax
c010435c:	89 c2                	mov    %eax,%edx
c010435e:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0104363:	39 c2                	cmp    %eax,%edx
c0104365:	72 1c                	jb     c0104383 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104367:	c7 44 24 08 7c 98 10 	movl   $0xc010987c,0x8(%esp)
c010436e:	c0 
c010436f:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0104376:	00 
c0104377:	c7 04 24 9b 98 10 c0 	movl   $0xc010989b,(%esp)
c010437e:	e8 a4 c8 ff ff       	call   c0100c27 <__panic>
    }
    return &pages[PPN(pa)];
c0104383:	a1 54 40 12 c0       	mov    0xc0124054,%eax
c0104388:	8b 55 08             	mov    0x8(%ebp),%edx
c010438b:	c1 ea 0c             	shr    $0xc,%edx
c010438e:	c1 e2 05             	shl    $0x5,%edx
c0104391:	01 d0                	add    %edx,%eax
}
c0104393:	c9                   	leave  
c0104394:	c3                   	ret    

c0104395 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0104395:	55                   	push   %ebp
c0104396:	89 e5                	mov    %esp,%ebp
c0104398:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010439b:	8b 45 08             	mov    0x8(%ebp),%eax
c010439e:	89 04 24             	mov    %eax,(%esp)
c01043a1:	e8 94 ff ff ff       	call   c010433a <page2pa>
c01043a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01043a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043ac:	c1 e8 0c             	shr    $0xc,%eax
c01043af:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01043b2:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c01043b7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01043ba:	72 23                	jb     c01043df <page2kva+0x4a>
c01043bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01043c3:	c7 44 24 08 ac 98 10 	movl   $0xc01098ac,0x8(%esp)
c01043ca:	c0 
c01043cb:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c01043d2:	00 
c01043d3:	c7 04 24 9b 98 10 c0 	movl   $0xc010989b,(%esp)
c01043da:	e8 48 c8 ff ff       	call   c0100c27 <__panic>
c01043df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043e2:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01043e7:	c9                   	leave  
c01043e8:	c3                   	ret    

c01043e9 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c01043e9:	55                   	push   %ebp
c01043ea:	89 e5                	mov    %esp,%ebp
c01043ec:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01043ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01043f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01043f5:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01043fc:	77 23                	ja     c0104421 <kva2page+0x38>
c01043fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104401:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104405:	c7 44 24 08 d0 98 10 	movl   $0xc01098d0,0x8(%esp)
c010440c:	c0 
c010440d:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0104414:	00 
c0104415:	c7 04 24 9b 98 10 c0 	movl   $0xc010989b,(%esp)
c010441c:	e8 06 c8 ff ff       	call   c0100c27 <__panic>
c0104421:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104424:	05 00 00 00 40       	add    $0x40000000,%eax
c0104429:	89 04 24             	mov    %eax,(%esp)
c010442c:	e8 1f ff ff ff       	call   c0104350 <pa2page>
}
c0104431:	c9                   	leave  
c0104432:	c3                   	ret    

c0104433 <pte2page>:

static inline struct Page *
pte2page(pte_t pte) {
c0104433:	55                   	push   %ebp
c0104434:	89 e5                	mov    %esp,%ebp
c0104436:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0104439:	8b 45 08             	mov    0x8(%ebp),%eax
c010443c:	83 e0 01             	and    $0x1,%eax
c010443f:	85 c0                	test   %eax,%eax
c0104441:	75 1c                	jne    c010445f <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0104443:	c7 44 24 08 f4 98 10 	movl   $0xc01098f4,0x8(%esp)
c010444a:	c0 
c010444b:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0104452:	00 
c0104453:	c7 04 24 9b 98 10 c0 	movl   $0xc010989b,(%esp)
c010445a:	e8 c8 c7 ff ff       	call   c0100c27 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c010445f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104462:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104467:	89 04 24             	mov    %eax,(%esp)
c010446a:	e8 e1 fe ff ff       	call   c0104350 <pa2page>
}
c010446f:	c9                   	leave  
c0104470:	c3                   	ret    

c0104471 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0104471:	55                   	push   %ebp
c0104472:	89 e5                	mov    %esp,%ebp
c0104474:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0104477:	8b 45 08             	mov    0x8(%ebp),%eax
c010447a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010447f:	89 04 24             	mov    %eax,(%esp)
c0104482:	e8 c9 fe ff ff       	call   c0104350 <pa2page>
}
c0104487:	c9                   	leave  
c0104488:	c3                   	ret    

c0104489 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0104489:	55                   	push   %ebp
c010448a:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010448c:	8b 45 08             	mov    0x8(%ebp),%eax
c010448f:	8b 00                	mov    (%eax),%eax
}
c0104491:	5d                   	pop    %ebp
c0104492:	c3                   	ret    

c0104493 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0104493:	55                   	push   %ebp
c0104494:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104496:	8b 45 08             	mov    0x8(%ebp),%eax
c0104499:	8b 55 0c             	mov    0xc(%ebp),%edx
c010449c:	89 10                	mov    %edx,(%eax)
}
c010449e:	5d                   	pop    %ebp
c010449f:	c3                   	ret    

c01044a0 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c01044a0:	55                   	push   %ebp
c01044a1:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c01044a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01044a6:	8b 00                	mov    (%eax),%eax
c01044a8:	8d 50 01             	lea    0x1(%eax),%edx
c01044ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01044ae:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01044b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01044b3:	8b 00                	mov    (%eax),%eax
}
c01044b5:	5d                   	pop    %ebp
c01044b6:	c3                   	ret    

c01044b7 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c01044b7:	55                   	push   %ebp
c01044b8:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c01044ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01044bd:	8b 00                	mov    (%eax),%eax
c01044bf:	8d 50 ff             	lea    -0x1(%eax),%edx
c01044c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01044c5:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01044c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01044ca:	8b 00                	mov    (%eax),%eax
}
c01044cc:	5d                   	pop    %ebp
c01044cd:	c3                   	ret    

c01044ce <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c01044ce:	55                   	push   %ebp
c01044cf:	89 e5                	mov    %esp,%ebp
c01044d1:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01044d4:	9c                   	pushf  
c01044d5:	58                   	pop    %eax
c01044d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01044d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01044dc:	25 00 02 00 00       	and    $0x200,%eax
c01044e1:	85 c0                	test   %eax,%eax
c01044e3:	74 0c                	je     c01044f1 <__intr_save+0x23>
        intr_disable();
c01044e5:	e8 a6 d9 ff ff       	call   c0101e90 <intr_disable>
        return 1;
c01044ea:	b8 01 00 00 00       	mov    $0x1,%eax
c01044ef:	eb 05                	jmp    c01044f6 <__intr_save+0x28>
    }
    return 0;
c01044f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01044f6:	c9                   	leave  
c01044f7:	c3                   	ret    

c01044f8 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01044f8:	55                   	push   %ebp
c01044f9:	89 e5                	mov    %esp,%ebp
c01044fb:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01044fe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104502:	74 05                	je     c0104509 <__intr_restore+0x11>
        intr_enable();
c0104504:	e8 81 d9 ff ff       	call   c0101e8a <intr_enable>
    }
}
c0104509:	c9                   	leave  
c010450a:	c3                   	ret    

c010450b <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c010450b:	55                   	push   %ebp
c010450c:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c010450e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104511:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0104514:	b8 23 00 00 00       	mov    $0x23,%eax
c0104519:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c010451b:	b8 23 00 00 00       	mov    $0x23,%eax
c0104520:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0104522:	b8 10 00 00 00       	mov    $0x10,%eax
c0104527:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0104529:	b8 10 00 00 00       	mov    $0x10,%eax
c010452e:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0104530:	b8 10 00 00 00       	mov    $0x10,%eax
c0104535:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0104537:	ea 3e 45 10 c0 08 00 	ljmp   $0x8,$0xc010453e
}
c010453e:	5d                   	pop    %ebp
c010453f:	c3                   	ret    

c0104540 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0104540:	55                   	push   %ebp
c0104541:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0104543:	8b 45 08             	mov    0x8(%ebp),%eax
c0104546:	a3 c4 3f 12 c0       	mov    %eax,0xc0123fc4
}
c010454b:	5d                   	pop    %ebp
c010454c:	c3                   	ret    

c010454d <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c010454d:	55                   	push   %ebp
c010454e:	89 e5                	mov    %esp,%ebp
c0104550:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0104553:	b8 00 00 12 c0       	mov    $0xc0120000,%eax
c0104558:	89 04 24             	mov    %eax,(%esp)
c010455b:	e8 e0 ff ff ff       	call   c0104540 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0104560:	66 c7 05 c8 3f 12 c0 	movw   $0x10,0xc0123fc8
c0104567:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0104569:	66 c7 05 28 0a 12 c0 	movw   $0x68,0xc0120a28
c0104570:	68 00 
c0104572:	b8 c0 3f 12 c0       	mov    $0xc0123fc0,%eax
c0104577:	66 a3 2a 0a 12 c0    	mov    %ax,0xc0120a2a
c010457d:	b8 c0 3f 12 c0       	mov    $0xc0123fc0,%eax
c0104582:	c1 e8 10             	shr    $0x10,%eax
c0104585:	a2 2c 0a 12 c0       	mov    %al,0xc0120a2c
c010458a:	0f b6 05 2d 0a 12 c0 	movzbl 0xc0120a2d,%eax
c0104591:	83 e0 f0             	and    $0xfffffff0,%eax
c0104594:	83 c8 09             	or     $0x9,%eax
c0104597:	a2 2d 0a 12 c0       	mov    %al,0xc0120a2d
c010459c:	0f b6 05 2d 0a 12 c0 	movzbl 0xc0120a2d,%eax
c01045a3:	83 e0 ef             	and    $0xffffffef,%eax
c01045a6:	a2 2d 0a 12 c0       	mov    %al,0xc0120a2d
c01045ab:	0f b6 05 2d 0a 12 c0 	movzbl 0xc0120a2d,%eax
c01045b2:	83 e0 9f             	and    $0xffffff9f,%eax
c01045b5:	a2 2d 0a 12 c0       	mov    %al,0xc0120a2d
c01045ba:	0f b6 05 2d 0a 12 c0 	movzbl 0xc0120a2d,%eax
c01045c1:	83 c8 80             	or     $0xffffff80,%eax
c01045c4:	a2 2d 0a 12 c0       	mov    %al,0xc0120a2d
c01045c9:	0f b6 05 2e 0a 12 c0 	movzbl 0xc0120a2e,%eax
c01045d0:	83 e0 f0             	and    $0xfffffff0,%eax
c01045d3:	a2 2e 0a 12 c0       	mov    %al,0xc0120a2e
c01045d8:	0f b6 05 2e 0a 12 c0 	movzbl 0xc0120a2e,%eax
c01045df:	83 e0 ef             	and    $0xffffffef,%eax
c01045e2:	a2 2e 0a 12 c0       	mov    %al,0xc0120a2e
c01045e7:	0f b6 05 2e 0a 12 c0 	movzbl 0xc0120a2e,%eax
c01045ee:	83 e0 df             	and    $0xffffffdf,%eax
c01045f1:	a2 2e 0a 12 c0       	mov    %al,0xc0120a2e
c01045f6:	0f b6 05 2e 0a 12 c0 	movzbl 0xc0120a2e,%eax
c01045fd:	83 c8 40             	or     $0x40,%eax
c0104600:	a2 2e 0a 12 c0       	mov    %al,0xc0120a2e
c0104605:	0f b6 05 2e 0a 12 c0 	movzbl 0xc0120a2e,%eax
c010460c:	83 e0 7f             	and    $0x7f,%eax
c010460f:	a2 2e 0a 12 c0       	mov    %al,0xc0120a2e
c0104614:	b8 c0 3f 12 c0       	mov    $0xc0123fc0,%eax
c0104619:	c1 e8 18             	shr    $0x18,%eax
c010461c:	a2 2f 0a 12 c0       	mov    %al,0xc0120a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0104621:	c7 04 24 30 0a 12 c0 	movl   $0xc0120a30,(%esp)
c0104628:	e8 de fe ff ff       	call   c010450b <lgdt>
c010462d:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0104633:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0104637:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c010463a:	c9                   	leave  
c010463b:	c3                   	ret    

c010463c <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c010463c:	55                   	push   %ebp
c010463d:	89 e5                	mov    %esp,%ebp
c010463f:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0104642:	c7 05 4c 40 12 c0 60 	movl   $0xc0109860,0xc012404c
c0104649:	98 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c010464c:	a1 4c 40 12 c0       	mov    0xc012404c,%eax
c0104651:	8b 00                	mov    (%eax),%eax
c0104653:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104657:	c7 04 24 20 99 10 c0 	movl   $0xc0109920,(%esp)
c010465e:	e8 f4 bc ff ff       	call   c0100357 <cprintf>
    pmm_manager->init();
c0104663:	a1 4c 40 12 c0       	mov    0xc012404c,%eax
c0104668:	8b 40 04             	mov    0x4(%eax),%eax
c010466b:	ff d0                	call   *%eax
}
c010466d:	c9                   	leave  
c010466e:	c3                   	ret    

c010466f <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c010466f:	55                   	push   %ebp
c0104670:	89 e5                	mov    %esp,%ebp
c0104672:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0104675:	a1 4c 40 12 c0       	mov    0xc012404c,%eax
c010467a:	8b 40 08             	mov    0x8(%eax),%eax
c010467d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104680:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104684:	8b 55 08             	mov    0x8(%ebp),%edx
c0104687:	89 14 24             	mov    %edx,(%esp)
c010468a:	ff d0                	call   *%eax
}
c010468c:	c9                   	leave  
c010468d:	c3                   	ret    

c010468e <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c010468e:	55                   	push   %ebp
c010468f:	89 e5                	mov    %esp,%ebp
c0104691:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0104694:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c010469b:	e8 2e fe ff ff       	call   c01044ce <__intr_save>
c01046a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c01046a3:	a1 4c 40 12 c0       	mov    0xc012404c,%eax
c01046a8:	8b 40 0c             	mov    0xc(%eax),%eax
c01046ab:	8b 55 08             	mov    0x8(%ebp),%edx
c01046ae:	89 14 24             	mov    %edx,(%esp)
c01046b1:	ff d0                	call   *%eax
c01046b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c01046b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046b9:	89 04 24             	mov    %eax,(%esp)
c01046bc:	e8 37 fe ff ff       	call   c01044f8 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c01046c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01046c5:	75 2d                	jne    c01046f4 <alloc_pages+0x66>
c01046c7:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c01046cb:	77 27                	ja     c01046f4 <alloc_pages+0x66>
c01046cd:	a1 2c 40 12 c0       	mov    0xc012402c,%eax
c01046d2:	85 c0                	test   %eax,%eax
c01046d4:	74 1e                	je     c01046f4 <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c01046d6:	8b 55 08             	mov    0x8(%ebp),%edx
c01046d9:	a1 2c 41 12 c0       	mov    0xc012412c,%eax
c01046de:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01046e5:	00 
c01046e6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01046ea:	89 04 24             	mov    %eax,(%esp)
c01046ed:	e8 0f 1a 00 00       	call   c0106101 <swap_out>
    }
c01046f2:	eb a7                	jmp    c010469b <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01046f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01046f7:	c9                   	leave  
c01046f8:	c3                   	ret    

c01046f9 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c01046f9:	55                   	push   %ebp
c01046fa:	89 e5                	mov    %esp,%ebp
c01046fc:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01046ff:	e8 ca fd ff ff       	call   c01044ce <__intr_save>
c0104704:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0104707:	a1 4c 40 12 c0       	mov    0xc012404c,%eax
c010470c:	8b 40 10             	mov    0x10(%eax),%eax
c010470f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104712:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104716:	8b 55 08             	mov    0x8(%ebp),%edx
c0104719:	89 14 24             	mov    %edx,(%esp)
c010471c:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c010471e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104721:	89 04 24             	mov    %eax,(%esp)
c0104724:	e8 cf fd ff ff       	call   c01044f8 <__intr_restore>
}
c0104729:	c9                   	leave  
c010472a:	c3                   	ret    

c010472b <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c010472b:	55                   	push   %ebp
c010472c:	89 e5                	mov    %esp,%ebp
c010472e:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0104731:	e8 98 fd ff ff       	call   c01044ce <__intr_save>
c0104736:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0104739:	a1 4c 40 12 c0       	mov    0xc012404c,%eax
c010473e:	8b 40 14             	mov    0x14(%eax),%eax
c0104741:	ff d0                	call   *%eax
c0104743:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0104746:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104749:	89 04 24             	mov    %eax,(%esp)
c010474c:	e8 a7 fd ff ff       	call   c01044f8 <__intr_restore>
    return ret;
c0104751:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0104754:	c9                   	leave  
c0104755:	c3                   	ret    

c0104756 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0104756:	55                   	push   %ebp
c0104757:	89 e5                	mov    %esp,%ebp
c0104759:	57                   	push   %edi
c010475a:	56                   	push   %esi
c010475b:	53                   	push   %ebx
c010475c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0104762:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0104769:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0104770:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0104777:	c7 04 24 37 99 10 c0 	movl   $0xc0109937,(%esp)
c010477e:	e8 d4 bb ff ff       	call   c0100357 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0104783:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010478a:	e9 15 01 00 00       	jmp    c01048a4 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c010478f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104792:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104795:	89 d0                	mov    %edx,%eax
c0104797:	c1 e0 02             	shl    $0x2,%eax
c010479a:	01 d0                	add    %edx,%eax
c010479c:	c1 e0 02             	shl    $0x2,%eax
c010479f:	01 c8                	add    %ecx,%eax
c01047a1:	8b 50 08             	mov    0x8(%eax),%edx
c01047a4:	8b 40 04             	mov    0x4(%eax),%eax
c01047a7:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01047aa:	89 55 bc             	mov    %edx,-0x44(%ebp)
c01047ad:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01047b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01047b3:	89 d0                	mov    %edx,%eax
c01047b5:	c1 e0 02             	shl    $0x2,%eax
c01047b8:	01 d0                	add    %edx,%eax
c01047ba:	c1 e0 02             	shl    $0x2,%eax
c01047bd:	01 c8                	add    %ecx,%eax
c01047bf:	8b 48 0c             	mov    0xc(%eax),%ecx
c01047c2:	8b 58 10             	mov    0x10(%eax),%ebx
c01047c5:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01047c8:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01047cb:	01 c8                	add    %ecx,%eax
c01047cd:	11 da                	adc    %ebx,%edx
c01047cf:	89 45 b0             	mov    %eax,-0x50(%ebp)
c01047d2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c01047d5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01047d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01047db:	89 d0                	mov    %edx,%eax
c01047dd:	c1 e0 02             	shl    $0x2,%eax
c01047e0:	01 d0                	add    %edx,%eax
c01047e2:	c1 e0 02             	shl    $0x2,%eax
c01047e5:	01 c8                	add    %ecx,%eax
c01047e7:	83 c0 14             	add    $0x14,%eax
c01047ea:	8b 00                	mov    (%eax),%eax
c01047ec:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c01047f2:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01047f5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01047f8:	83 c0 ff             	add    $0xffffffff,%eax
c01047fb:	83 d2 ff             	adc    $0xffffffff,%edx
c01047fe:	89 c6                	mov    %eax,%esi
c0104800:	89 d7                	mov    %edx,%edi
c0104802:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104805:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104808:	89 d0                	mov    %edx,%eax
c010480a:	c1 e0 02             	shl    $0x2,%eax
c010480d:	01 d0                	add    %edx,%eax
c010480f:	c1 e0 02             	shl    $0x2,%eax
c0104812:	01 c8                	add    %ecx,%eax
c0104814:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104817:	8b 58 10             	mov    0x10(%eax),%ebx
c010481a:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0104820:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0104824:	89 74 24 14          	mov    %esi,0x14(%esp)
c0104828:	89 7c 24 18          	mov    %edi,0x18(%esp)
c010482c:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010482f:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104832:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104836:	89 54 24 10          	mov    %edx,0x10(%esp)
c010483a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010483e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0104842:	c7 04 24 44 99 10 c0 	movl   $0xc0109944,(%esp)
c0104849:	e8 09 bb ff ff       	call   c0100357 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c010484e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104851:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104854:	89 d0                	mov    %edx,%eax
c0104856:	c1 e0 02             	shl    $0x2,%eax
c0104859:	01 d0                	add    %edx,%eax
c010485b:	c1 e0 02             	shl    $0x2,%eax
c010485e:	01 c8                	add    %ecx,%eax
c0104860:	83 c0 14             	add    $0x14,%eax
c0104863:	8b 00                	mov    (%eax),%eax
c0104865:	83 f8 01             	cmp    $0x1,%eax
c0104868:	75 36                	jne    c01048a0 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c010486a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010486d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104870:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0104873:	77 2b                	ja     c01048a0 <page_init+0x14a>
c0104875:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0104878:	72 05                	jb     c010487f <page_init+0x129>
c010487a:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c010487d:	73 21                	jae    c01048a0 <page_init+0x14a>
c010487f:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0104883:	77 1b                	ja     c01048a0 <page_init+0x14a>
c0104885:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0104889:	72 09                	jb     c0104894 <page_init+0x13e>
c010488b:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0104892:	77 0c                	ja     c01048a0 <page_init+0x14a>
                maxpa = end;
c0104894:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104897:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010489a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010489d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c01048a0:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01048a4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01048a7:	8b 00                	mov    (%eax),%eax
c01048a9:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01048ac:	0f 8f dd fe ff ff    	jg     c010478f <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c01048b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01048b6:	72 1d                	jb     c01048d5 <page_init+0x17f>
c01048b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01048bc:	77 09                	ja     c01048c7 <page_init+0x171>
c01048be:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c01048c5:	76 0e                	jbe    c01048d5 <page_init+0x17f>
        maxpa = KMEMSIZE;
c01048c7:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c01048ce:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c01048d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01048d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01048db:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01048df:	c1 ea 0c             	shr    $0xc,%edx
c01048e2:	a3 a0 3f 12 c0       	mov    %eax,0xc0123fa0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c01048e7:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c01048ee:	b8 30 41 12 c0       	mov    $0xc0124130,%eax
c01048f3:	8d 50 ff             	lea    -0x1(%eax),%edx
c01048f6:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01048f9:	01 d0                	add    %edx,%eax
c01048fb:	89 45 a8             	mov    %eax,-0x58(%ebp)
c01048fe:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104901:	ba 00 00 00 00       	mov    $0x0,%edx
c0104906:	f7 75 ac             	divl   -0x54(%ebp)
c0104909:	89 d0                	mov    %edx,%eax
c010490b:	8b 55 a8             	mov    -0x58(%ebp),%edx
c010490e:	29 c2                	sub    %eax,%edx
c0104910:	89 d0                	mov    %edx,%eax
c0104912:	a3 54 40 12 c0       	mov    %eax,0xc0124054

    for (i = 0; i < npage; i ++) {
c0104917:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010491e:	eb 27                	jmp    c0104947 <page_init+0x1f1>
        SetPageReserved(pages + i);
c0104920:	a1 54 40 12 c0       	mov    0xc0124054,%eax
c0104925:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104928:	c1 e2 05             	shl    $0x5,%edx
c010492b:	01 d0                	add    %edx,%eax
c010492d:	83 c0 04             	add    $0x4,%eax
c0104930:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0104937:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010493a:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010493d:	8b 55 90             	mov    -0x70(%ebp),%edx
c0104940:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0104943:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104947:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010494a:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c010494f:	39 c2                	cmp    %eax,%edx
c0104951:	72 cd                	jb     c0104920 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0104953:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0104958:	c1 e0 05             	shl    $0x5,%eax
c010495b:	89 c2                	mov    %eax,%edx
c010495d:	a1 54 40 12 c0       	mov    0xc0124054,%eax
c0104962:	01 d0                	add    %edx,%eax
c0104964:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0104967:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c010496e:	77 23                	ja     c0104993 <page_init+0x23d>
c0104970:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104973:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104977:	c7 44 24 08 d0 98 10 	movl   $0xc01098d0,0x8(%esp)
c010497e:	c0 
c010497f:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0104986:	00 
c0104987:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c010498e:	e8 94 c2 ff ff       	call   c0100c27 <__panic>
c0104993:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104996:	05 00 00 00 40       	add    $0x40000000,%eax
c010499b:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c010499e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01049a5:	e9 74 01 00 00       	jmp    c0104b1e <page_init+0x3c8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01049aa:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01049ad:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01049b0:	89 d0                	mov    %edx,%eax
c01049b2:	c1 e0 02             	shl    $0x2,%eax
c01049b5:	01 d0                	add    %edx,%eax
c01049b7:	c1 e0 02             	shl    $0x2,%eax
c01049ba:	01 c8                	add    %ecx,%eax
c01049bc:	8b 50 08             	mov    0x8(%eax),%edx
c01049bf:	8b 40 04             	mov    0x4(%eax),%eax
c01049c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01049c5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01049c8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01049cb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01049ce:	89 d0                	mov    %edx,%eax
c01049d0:	c1 e0 02             	shl    $0x2,%eax
c01049d3:	01 d0                	add    %edx,%eax
c01049d5:	c1 e0 02             	shl    $0x2,%eax
c01049d8:	01 c8                	add    %ecx,%eax
c01049da:	8b 48 0c             	mov    0xc(%eax),%ecx
c01049dd:	8b 58 10             	mov    0x10(%eax),%ebx
c01049e0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01049e3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01049e6:	01 c8                	add    %ecx,%eax
c01049e8:	11 da                	adc    %ebx,%edx
c01049ea:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01049ed:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01049f0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01049f3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01049f6:	89 d0                	mov    %edx,%eax
c01049f8:	c1 e0 02             	shl    $0x2,%eax
c01049fb:	01 d0                	add    %edx,%eax
c01049fd:	c1 e0 02             	shl    $0x2,%eax
c0104a00:	01 c8                	add    %ecx,%eax
c0104a02:	83 c0 14             	add    $0x14,%eax
c0104a05:	8b 00                	mov    (%eax),%eax
c0104a07:	83 f8 01             	cmp    $0x1,%eax
c0104a0a:	0f 85 0a 01 00 00    	jne    c0104b1a <page_init+0x3c4>
            if (begin < freemem) {
c0104a10:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104a13:	ba 00 00 00 00       	mov    $0x0,%edx
c0104a18:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104a1b:	72 17                	jb     c0104a34 <page_init+0x2de>
c0104a1d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104a20:	77 05                	ja     c0104a27 <page_init+0x2d1>
c0104a22:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0104a25:	76 0d                	jbe    c0104a34 <page_init+0x2de>
                begin = freemem;
c0104a27:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104a2a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104a2d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0104a34:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104a38:	72 1d                	jb     c0104a57 <page_init+0x301>
c0104a3a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104a3e:	77 09                	ja     c0104a49 <page_init+0x2f3>
c0104a40:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0104a47:	76 0e                	jbe    c0104a57 <page_init+0x301>
                end = KMEMSIZE;
c0104a49:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0104a50:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0104a57:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104a5a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104a5d:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104a60:	0f 87 b4 00 00 00    	ja     c0104b1a <page_init+0x3c4>
c0104a66:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104a69:	72 09                	jb     c0104a74 <page_init+0x31e>
c0104a6b:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104a6e:	0f 83 a6 00 00 00    	jae    c0104b1a <page_init+0x3c4>
                begin = ROUNDUP(begin, PGSIZE);
c0104a74:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0104a7b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104a7e:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104a81:	01 d0                	add    %edx,%eax
c0104a83:	83 e8 01             	sub    $0x1,%eax
c0104a86:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104a89:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104a8c:	ba 00 00 00 00       	mov    $0x0,%edx
c0104a91:	f7 75 9c             	divl   -0x64(%ebp)
c0104a94:	89 d0                	mov    %edx,%eax
c0104a96:	8b 55 98             	mov    -0x68(%ebp),%edx
c0104a99:	29 c2                	sub    %eax,%edx
c0104a9b:	89 d0                	mov    %edx,%eax
c0104a9d:	ba 00 00 00 00       	mov    $0x0,%edx
c0104aa2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104aa5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0104aa8:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104aab:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0104aae:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104ab1:	ba 00 00 00 00       	mov    $0x0,%edx
c0104ab6:	89 c7                	mov    %eax,%edi
c0104ab8:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0104abe:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0104ac1:	89 d0                	mov    %edx,%eax
c0104ac3:	83 e0 00             	and    $0x0,%eax
c0104ac6:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0104ac9:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104acc:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104acf:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104ad2:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0104ad5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104ad8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104adb:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104ade:	77 3a                	ja     c0104b1a <page_init+0x3c4>
c0104ae0:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104ae3:	72 05                	jb     c0104aea <page_init+0x394>
c0104ae5:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104ae8:	73 30                	jae    c0104b1a <page_init+0x3c4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0104aea:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0104aed:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c0104af0:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104af3:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104af6:	29 c8                	sub    %ecx,%eax
c0104af8:	19 da                	sbb    %ebx,%edx
c0104afa:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104afe:	c1 ea 0c             	shr    $0xc,%edx
c0104b01:	89 c3                	mov    %eax,%ebx
c0104b03:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104b06:	89 04 24             	mov    %eax,(%esp)
c0104b09:	e8 42 f8 ff ff       	call   c0104350 <pa2page>
c0104b0e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104b12:	89 04 24             	mov    %eax,(%esp)
c0104b15:	e8 55 fb ff ff       	call   c010466f <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c0104b1a:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104b1e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104b21:	8b 00                	mov    (%eax),%eax
c0104b23:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104b26:	0f 8f 7e fe ff ff    	jg     c01049aa <page_init+0x254>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0104b2c:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0104b32:	5b                   	pop    %ebx
c0104b33:	5e                   	pop    %esi
c0104b34:	5f                   	pop    %edi
c0104b35:	5d                   	pop    %ebp
c0104b36:	c3                   	ret    

c0104b37 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0104b37:	55                   	push   %ebp
c0104b38:	89 e5                	mov    %esp,%ebp
c0104b3a:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0104b3d:	8b 45 14             	mov    0x14(%ebp),%eax
c0104b40:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104b43:	31 d0                	xor    %edx,%eax
c0104b45:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104b4a:	85 c0                	test   %eax,%eax
c0104b4c:	74 24                	je     c0104b72 <boot_map_segment+0x3b>
c0104b4e:	c7 44 24 0c 82 99 10 	movl   $0xc0109982,0xc(%esp)
c0104b55:	c0 
c0104b56:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0104b5d:	c0 
c0104b5e:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0104b65:	00 
c0104b66:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0104b6d:	e8 b5 c0 ff ff       	call   c0100c27 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0104b72:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0104b79:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b7c:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104b81:	89 c2                	mov    %eax,%edx
c0104b83:	8b 45 10             	mov    0x10(%ebp),%eax
c0104b86:	01 c2                	add    %eax,%edx
c0104b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b8b:	01 d0                	add    %edx,%eax
c0104b8d:	83 e8 01             	sub    $0x1,%eax
c0104b90:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104b93:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b96:	ba 00 00 00 00       	mov    $0x0,%edx
c0104b9b:	f7 75 f0             	divl   -0x10(%ebp)
c0104b9e:	89 d0                	mov    %edx,%eax
c0104ba0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104ba3:	29 c2                	sub    %eax,%edx
c0104ba5:	89 d0                	mov    %edx,%eax
c0104ba7:	c1 e8 0c             	shr    $0xc,%eax
c0104baa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0104bad:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104bb0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104bb3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104bb6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104bbb:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0104bbe:	8b 45 14             	mov    0x14(%ebp),%eax
c0104bc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104bc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104bc7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104bcc:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104bcf:	eb 6b                	jmp    c0104c3c <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0104bd1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104bd8:	00 
c0104bd9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104be0:	8b 45 08             	mov    0x8(%ebp),%eax
c0104be3:	89 04 24             	mov    %eax,(%esp)
c0104be6:	e8 82 01 00 00       	call   c0104d6d <get_pte>
c0104beb:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0104bee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104bf2:	75 24                	jne    c0104c18 <boot_map_segment+0xe1>
c0104bf4:	c7 44 24 0c ae 99 10 	movl   $0xc01099ae,0xc(%esp)
c0104bfb:	c0 
c0104bfc:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0104c03:	c0 
c0104c04:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0104c0b:	00 
c0104c0c:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0104c13:	e8 0f c0 ff ff       	call   c0100c27 <__panic>
        *ptep = pa | PTE_P | perm;
c0104c18:	8b 45 18             	mov    0x18(%ebp),%eax
c0104c1b:	8b 55 14             	mov    0x14(%ebp),%edx
c0104c1e:	09 d0                	or     %edx,%eax
c0104c20:	83 c8 01             	or     $0x1,%eax
c0104c23:	89 c2                	mov    %eax,%edx
c0104c25:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104c28:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104c2a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104c2e:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0104c35:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0104c3c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104c40:	75 8f                	jne    c0104bd1 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0104c42:	c9                   	leave  
c0104c43:	c3                   	ret    

c0104c44 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0104c44:	55                   	push   %ebp
c0104c45:	89 e5                	mov    %esp,%ebp
c0104c47:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0104c4a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104c51:	e8 38 fa ff ff       	call   c010468e <alloc_pages>
c0104c56:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0104c59:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104c5d:	75 1c                	jne    c0104c7b <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0104c5f:	c7 44 24 08 bb 99 10 	movl   $0xc01099bb,0x8(%esp)
c0104c66:	c0 
c0104c67:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0104c6e:	00 
c0104c6f:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0104c76:	e8 ac bf ff ff       	call   c0100c27 <__panic>
    }
    return page2kva(p);
c0104c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c7e:	89 04 24             	mov    %eax,(%esp)
c0104c81:	e8 0f f7 ff ff       	call   c0104395 <page2kva>
}
c0104c86:	c9                   	leave  
c0104c87:	c3                   	ret    

c0104c88 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0104c88:	55                   	push   %ebp
c0104c89:	89 e5                	mov    %esp,%ebp
c0104c8b:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0104c8e:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0104c93:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c96:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104c9d:	77 23                	ja     c0104cc2 <pmm_init+0x3a>
c0104c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ca2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104ca6:	c7 44 24 08 d0 98 10 	movl   $0xc01098d0,0x8(%esp)
c0104cad:	c0 
c0104cae:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0104cb5:	00 
c0104cb6:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0104cbd:	e8 65 bf ff ff       	call   c0100c27 <__panic>
c0104cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cc5:	05 00 00 00 40       	add    $0x40000000,%eax
c0104cca:	a3 50 40 12 c0       	mov    %eax,0xc0124050
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0104ccf:	e8 68 f9 ff ff       	call   c010463c <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0104cd4:	e8 7d fa ff ff       	call   c0104756 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0104cd9:	e8 a6 04 00 00       	call   c0105184 <check_alloc_page>

    check_pgdir();
c0104cde:	e8 bf 04 00 00       	call   c01051a2 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0104ce3:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0104ce8:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0104cee:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0104cf3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104cf6:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0104cfd:	77 23                	ja     c0104d22 <pmm_init+0x9a>
c0104cff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d02:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104d06:	c7 44 24 08 d0 98 10 	movl   $0xc01098d0,0x8(%esp)
c0104d0d:	c0 
c0104d0e:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c0104d15:	00 
c0104d16:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0104d1d:	e8 05 bf ff ff       	call   c0100c27 <__panic>
c0104d22:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d25:	05 00 00 00 40       	add    $0x40000000,%eax
c0104d2a:	83 c8 03             	or     $0x3,%eax
c0104d2d:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0104d2f:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0104d34:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0104d3b:	00 
c0104d3c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104d43:	00 
c0104d44:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0104d4b:	38 
c0104d4c:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0104d53:	c0 
c0104d54:	89 04 24             	mov    %eax,(%esp)
c0104d57:	e8 db fd ff ff       	call   c0104b37 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0104d5c:	e8 ec f7 ff ff       	call   c010454d <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0104d61:	e8 d7 0a 00 00       	call   c010583d <check_boot_pgdir>

    print_pgdir();
c0104d66:	e8 5f 0f 00 00       	call   c0105cca <print_pgdir>

}
c0104d6b:	c9                   	leave  
c0104d6c:	c3                   	ret    

c0104d6d <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0104d6d:	55                   	push   %ebp
c0104d6e:	89 e5                	mov    %esp,%ebp
c0104d70:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c0104d73:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104d76:	c1 e8 16             	shr    $0x16,%eax
c0104d79:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104d80:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d83:	01 d0                	add    %edx,%eax
c0104d85:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c0104d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d8b:	8b 00                	mov    (%eax),%eax
c0104d8d:	83 e0 01             	and    $0x1,%eax
c0104d90:	85 c0                	test   %eax,%eax
c0104d92:	0f 85 af 00 00 00    	jne    c0104e47 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c0104d98:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104d9c:	74 15                	je     c0104db3 <get_pte+0x46>
c0104d9e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104da5:	e8 e4 f8 ff ff       	call   c010468e <alloc_pages>
c0104daa:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104dad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104db1:	75 0a                	jne    c0104dbd <get_pte+0x50>
            return NULL;
c0104db3:	b8 00 00 00 00       	mov    $0x0,%eax
c0104db8:	e9 e6 00 00 00       	jmp    c0104ea3 <get_pte+0x136>
        }
        set_page_ref(page, 1);
c0104dbd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104dc4:	00 
c0104dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104dc8:	89 04 24             	mov    %eax,(%esp)
c0104dcb:	e8 c3 f6 ff ff       	call   c0104493 <set_page_ref>
        uintptr_t pa = page2pa(page);
c0104dd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104dd3:	89 04 24             	mov    %eax,(%esp)
c0104dd6:	e8 5f f5 ff ff       	call   c010433a <page2pa>
c0104ddb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0104dde:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104de1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104de4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104de7:	c1 e8 0c             	shr    $0xc,%eax
c0104dea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104ded:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0104df2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0104df5:	72 23                	jb     c0104e1a <get_pte+0xad>
c0104df7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104dfa:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104dfe:	c7 44 24 08 ac 98 10 	movl   $0xc01098ac,0x8(%esp)
c0104e05:	c0 
c0104e06:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
c0104e0d:	00 
c0104e0e:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0104e15:	e8 0d be ff ff       	call   c0100c27 <__panic>
c0104e1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e1d:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104e22:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104e29:	00 
c0104e2a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104e31:	00 
c0104e32:	89 04 24             	mov    %eax,(%esp)
c0104e35:	e8 64 3c 00 00       	call   c0108a9e <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0104e3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e3d:	83 c8 07             	or     $0x7,%eax
c0104e40:	89 c2                	mov    %eax,%edx
c0104e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e45:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0104e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e4a:	8b 00                	mov    (%eax),%eax
c0104e4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e51:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104e54:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104e57:	c1 e8 0c             	shr    $0xc,%eax
c0104e5a:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104e5d:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0104e62:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104e65:	72 23                	jb     c0104e8a <get_pte+0x11d>
c0104e67:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104e6a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104e6e:	c7 44 24 08 ac 98 10 	movl   $0xc01098ac,0x8(%esp)
c0104e75:	c0 
c0104e76:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
c0104e7d:	00 
c0104e7e:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0104e85:	e8 9d bd ff ff       	call   c0100c27 <__panic>
c0104e8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104e8d:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104e92:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104e95:	c1 ea 0c             	shr    $0xc,%edx
c0104e98:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c0104e9e:	c1 e2 02             	shl    $0x2,%edx
c0104ea1:	01 d0                	add    %edx,%eax
}
c0104ea3:	c9                   	leave  
c0104ea4:	c3                   	ret    

c0104ea5 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0104ea5:	55                   	push   %ebp
c0104ea6:	89 e5                	mov    %esp,%ebp
c0104ea8:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104eab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104eb2:	00 
c0104eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104eb6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104eba:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ebd:	89 04 24             	mov    %eax,(%esp)
c0104ec0:	e8 a8 fe ff ff       	call   c0104d6d <get_pte>
c0104ec5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0104ec8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104ecc:	74 08                	je     c0104ed6 <get_page+0x31>
        *ptep_store = ptep;
c0104ece:	8b 45 10             	mov    0x10(%ebp),%eax
c0104ed1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104ed4:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0104ed6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104eda:	74 1b                	je     c0104ef7 <get_page+0x52>
c0104edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104edf:	8b 00                	mov    (%eax),%eax
c0104ee1:	83 e0 01             	and    $0x1,%eax
c0104ee4:	85 c0                	test   %eax,%eax
c0104ee6:	74 0f                	je     c0104ef7 <get_page+0x52>
        return pte2page(*ptep);
c0104ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104eeb:	8b 00                	mov    (%eax),%eax
c0104eed:	89 04 24             	mov    %eax,(%esp)
c0104ef0:	e8 3e f5 ff ff       	call   c0104433 <pte2page>
c0104ef5:	eb 05                	jmp    c0104efc <get_page+0x57>
    }
    return NULL;
c0104ef7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104efc:	c9                   	leave  
c0104efd:	c3                   	ret    

c0104efe <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0104efe:	55                   	push   %ebp
c0104eff:	89 e5                	mov    %esp,%ebp
c0104f01:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c0104f04:	8b 45 10             	mov    0x10(%ebp),%eax
c0104f07:	8b 00                	mov    (%eax),%eax
c0104f09:	83 e0 01             	and    $0x1,%eax
c0104f0c:	85 c0                	test   %eax,%eax
c0104f0e:	74 4d                	je     c0104f5d <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c0104f10:	8b 45 10             	mov    0x10(%ebp),%eax
c0104f13:	8b 00                	mov    (%eax),%eax
c0104f15:	89 04 24             	mov    %eax,(%esp)
c0104f18:	e8 16 f5 ff ff       	call   c0104433 <pte2page>
c0104f1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0104f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f23:	89 04 24             	mov    %eax,(%esp)
c0104f26:	e8 8c f5 ff ff       	call   c01044b7 <page_ref_dec>
c0104f2b:	85 c0                	test   %eax,%eax
c0104f2d:	75 13                	jne    c0104f42 <page_remove_pte+0x44>
            free_page(page);
c0104f2f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104f36:	00 
c0104f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f3a:	89 04 24             	mov    %eax,(%esp)
c0104f3d:	e8 b7 f7 ff ff       	call   c01046f9 <free_pages>
        }
        *ptep = 0;
c0104f42:	8b 45 10             	mov    0x10(%ebp),%eax
c0104f45:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0104f4b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104f52:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f55:	89 04 24             	mov    %eax,(%esp)
c0104f58:	e8 ff 00 00 00       	call   c010505c <tlb_invalidate>
    }
}
c0104f5d:	c9                   	leave  
c0104f5e:	c3                   	ret    

c0104f5f <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0104f5f:	55                   	push   %ebp
c0104f60:	89 e5                	mov    %esp,%ebp
c0104f62:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104f65:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104f6c:	00 
c0104f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f70:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104f74:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f77:	89 04 24             	mov    %eax,(%esp)
c0104f7a:	e8 ee fd ff ff       	call   c0104d6d <get_pte>
c0104f7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0104f82:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104f86:	74 19                	je     c0104fa1 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0104f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f8b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104f8f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f92:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104f96:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f99:	89 04 24             	mov    %eax,(%esp)
c0104f9c:	e8 5d ff ff ff       	call   c0104efe <page_remove_pte>
    }
}
c0104fa1:	c9                   	leave  
c0104fa2:	c3                   	ret    

c0104fa3 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0104fa3:	55                   	push   %ebp
c0104fa4:	89 e5                	mov    %esp,%ebp
c0104fa6:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0104fa9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104fb0:	00 
c0104fb1:	8b 45 10             	mov    0x10(%ebp),%eax
c0104fb4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104fb8:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fbb:	89 04 24             	mov    %eax,(%esp)
c0104fbe:	e8 aa fd ff ff       	call   c0104d6d <get_pte>
c0104fc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0104fc6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104fca:	75 0a                	jne    c0104fd6 <page_insert+0x33>
        return -E_NO_MEM;
c0104fcc:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0104fd1:	e9 84 00 00 00       	jmp    c010505a <page_insert+0xb7>
    }
    page_ref_inc(page);
c0104fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104fd9:	89 04 24             	mov    %eax,(%esp)
c0104fdc:	e8 bf f4 ff ff       	call   c01044a0 <page_ref_inc>
    if (*ptep & PTE_P) {
c0104fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fe4:	8b 00                	mov    (%eax),%eax
c0104fe6:	83 e0 01             	and    $0x1,%eax
c0104fe9:	85 c0                	test   %eax,%eax
c0104feb:	74 3e                	je     c010502b <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0104fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ff0:	8b 00                	mov    (%eax),%eax
c0104ff2:	89 04 24             	mov    %eax,(%esp)
c0104ff5:	e8 39 f4 ff ff       	call   c0104433 <pte2page>
c0104ffa:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0104ffd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105000:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105003:	75 0d                	jne    c0105012 <page_insert+0x6f>
            page_ref_dec(page);
c0105005:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105008:	89 04 24             	mov    %eax,(%esp)
c010500b:	e8 a7 f4 ff ff       	call   c01044b7 <page_ref_dec>
c0105010:	eb 19                	jmp    c010502b <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0105012:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105015:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105019:	8b 45 10             	mov    0x10(%ebp),%eax
c010501c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105020:	8b 45 08             	mov    0x8(%ebp),%eax
c0105023:	89 04 24             	mov    %eax,(%esp)
c0105026:	e8 d3 fe ff ff       	call   c0104efe <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c010502b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010502e:	89 04 24             	mov    %eax,(%esp)
c0105031:	e8 04 f3 ff ff       	call   c010433a <page2pa>
c0105036:	0b 45 14             	or     0x14(%ebp),%eax
c0105039:	83 c8 01             	or     $0x1,%eax
c010503c:	89 c2                	mov    %eax,%edx
c010503e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105041:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0105043:	8b 45 10             	mov    0x10(%ebp),%eax
c0105046:	89 44 24 04          	mov    %eax,0x4(%esp)
c010504a:	8b 45 08             	mov    0x8(%ebp),%eax
c010504d:	89 04 24             	mov    %eax,(%esp)
c0105050:	e8 07 00 00 00       	call   c010505c <tlb_invalidate>
    return 0;
c0105055:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010505a:	c9                   	leave  
c010505b:	c3                   	ret    

c010505c <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c010505c:	55                   	push   %ebp
c010505d:	89 e5                	mov    %esp,%ebp
c010505f:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0105062:	0f 20 d8             	mov    %cr3,%eax
c0105065:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0105068:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c010506b:	89 c2                	mov    %eax,%edx
c010506d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105070:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105073:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010507a:	77 23                	ja     c010509f <tlb_invalidate+0x43>
c010507c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010507f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105083:	c7 44 24 08 d0 98 10 	movl   $0xc01098d0,0x8(%esp)
c010508a:	c0 
c010508b:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c0105092:	00 
c0105093:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c010509a:	e8 88 bb ff ff       	call   c0100c27 <__panic>
c010509f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050a2:	05 00 00 00 40       	add    $0x40000000,%eax
c01050a7:	39 c2                	cmp    %eax,%edx
c01050a9:	75 0c                	jne    c01050b7 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c01050ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01050ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01050b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01050b4:	0f 01 38             	invlpg (%eax)
    }
}
c01050b7:	c9                   	leave  
c01050b8:	c3                   	ret    

c01050b9 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c01050b9:	55                   	push   %ebp
c01050ba:	89 e5                	mov    %esp,%ebp
c01050bc:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c01050bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01050c6:	e8 c3 f5 ff ff       	call   c010468e <alloc_pages>
c01050cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c01050ce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01050d2:	0f 84 a7 00 00 00    	je     c010517f <pgdir_alloc_page+0xc6>
        if (page_insert(pgdir, page, la, perm) != 0) {
c01050d8:	8b 45 10             	mov    0x10(%ebp),%eax
c01050db:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01050df:	8b 45 0c             	mov    0xc(%ebp),%eax
c01050e2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01050e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01050ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01050f0:	89 04 24             	mov    %eax,(%esp)
c01050f3:	e8 ab fe ff ff       	call   c0104fa3 <page_insert>
c01050f8:	85 c0                	test   %eax,%eax
c01050fa:	74 1a                	je     c0105116 <pgdir_alloc_page+0x5d>
            free_page(page);
c01050fc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105103:	00 
c0105104:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105107:	89 04 24             	mov    %eax,(%esp)
c010510a:	e8 ea f5 ff ff       	call   c01046f9 <free_pages>
            return NULL;
c010510f:	b8 00 00 00 00       	mov    $0x0,%eax
c0105114:	eb 6c                	jmp    c0105182 <pgdir_alloc_page+0xc9>
        }
        if (swap_init_ok){
c0105116:	a1 2c 40 12 c0       	mov    0xc012402c,%eax
c010511b:	85 c0                	test   %eax,%eax
c010511d:	74 60                	je     c010517f <pgdir_alloc_page+0xc6>
            swap_map_swappable(check_mm_struct, la, page, 0);
c010511f:	a1 2c 41 12 c0       	mov    0xc012412c,%eax
c0105124:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010512b:	00 
c010512c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010512f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105133:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105136:	89 54 24 04          	mov    %edx,0x4(%esp)
c010513a:	89 04 24             	mov    %eax,(%esp)
c010513d:	e8 73 0f 00 00       	call   c01060b5 <swap_map_swappable>
            page->pra_vaddr=la;
c0105142:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105145:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105148:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c010514b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010514e:	89 04 24             	mov    %eax,(%esp)
c0105151:	e8 33 f3 ff ff       	call   c0104489 <page_ref>
c0105156:	83 f8 01             	cmp    $0x1,%eax
c0105159:	74 24                	je     c010517f <pgdir_alloc_page+0xc6>
c010515b:	c7 44 24 0c d4 99 10 	movl   $0xc01099d4,0xc(%esp)
c0105162:	c0 
c0105163:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c010516a:	c0 
c010516b:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0105172:	00 
c0105173:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c010517a:	e8 a8 ba ff ff       	call   c0100c27 <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c010517f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105182:	c9                   	leave  
c0105183:	c3                   	ret    

c0105184 <check_alloc_page>:

static void
check_alloc_page(void) {
c0105184:	55                   	push   %ebp
c0105185:	89 e5                	mov    %esp,%ebp
c0105187:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c010518a:	a1 4c 40 12 c0       	mov    0xc012404c,%eax
c010518f:	8b 40 18             	mov    0x18(%eax),%eax
c0105192:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0105194:	c7 04 24 e8 99 10 c0 	movl   $0xc01099e8,(%esp)
c010519b:	e8 b7 b1 ff ff       	call   c0100357 <cprintf>
}
c01051a0:	c9                   	leave  
c01051a1:	c3                   	ret    

c01051a2 <check_pgdir>:

static void
check_pgdir(void) {
c01051a2:	55                   	push   %ebp
c01051a3:	89 e5                	mov    %esp,%ebp
c01051a5:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01051a8:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c01051ad:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01051b2:	76 24                	jbe    c01051d8 <check_pgdir+0x36>
c01051b4:	c7 44 24 0c 07 9a 10 	movl   $0xc0109a07,0xc(%esp)
c01051bb:	c0 
c01051bc:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c01051c3:	c0 
c01051c4:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
c01051cb:	00 
c01051cc:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c01051d3:	e8 4f ba ff ff       	call   c0100c27 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01051d8:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01051dd:	85 c0                	test   %eax,%eax
c01051df:	74 0e                	je     c01051ef <check_pgdir+0x4d>
c01051e1:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01051e6:	25 ff 0f 00 00       	and    $0xfff,%eax
c01051eb:	85 c0                	test   %eax,%eax
c01051ed:	74 24                	je     c0105213 <check_pgdir+0x71>
c01051ef:	c7 44 24 0c 24 9a 10 	movl   $0xc0109a24,0xc(%esp)
c01051f6:	c0 
c01051f7:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c01051fe:	c0 
c01051ff:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0105206:	00 
c0105207:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c010520e:	e8 14 ba ff ff       	call   c0100c27 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0105213:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105218:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010521f:	00 
c0105220:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105227:	00 
c0105228:	89 04 24             	mov    %eax,(%esp)
c010522b:	e8 75 fc ff ff       	call   c0104ea5 <get_page>
c0105230:	85 c0                	test   %eax,%eax
c0105232:	74 24                	je     c0105258 <check_pgdir+0xb6>
c0105234:	c7 44 24 0c 5c 9a 10 	movl   $0xc0109a5c,0xc(%esp)
c010523b:	c0 
c010523c:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105243:	c0 
c0105244:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c010524b:	00 
c010524c:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105253:	e8 cf b9 ff ff       	call   c0100c27 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0105258:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010525f:	e8 2a f4 ff ff       	call   c010468e <alloc_pages>
c0105264:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0105267:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c010526c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105273:	00 
c0105274:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010527b:	00 
c010527c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010527f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105283:	89 04 24             	mov    %eax,(%esp)
c0105286:	e8 18 fd ff ff       	call   c0104fa3 <page_insert>
c010528b:	85 c0                	test   %eax,%eax
c010528d:	74 24                	je     c01052b3 <check_pgdir+0x111>
c010528f:	c7 44 24 0c 84 9a 10 	movl   $0xc0109a84,0xc(%esp)
c0105296:	c0 
c0105297:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c010529e:	c0 
c010529f:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c01052a6:	00 
c01052a7:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c01052ae:	e8 74 b9 ff ff       	call   c0100c27 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01052b3:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01052b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01052bf:	00 
c01052c0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01052c7:	00 
c01052c8:	89 04 24             	mov    %eax,(%esp)
c01052cb:	e8 9d fa ff ff       	call   c0104d6d <get_pte>
c01052d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01052d3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01052d7:	75 24                	jne    c01052fd <check_pgdir+0x15b>
c01052d9:	c7 44 24 0c b0 9a 10 	movl   $0xc0109ab0,0xc(%esp)
c01052e0:	c0 
c01052e1:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c01052e8:	c0 
c01052e9:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c01052f0:	00 
c01052f1:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c01052f8:	e8 2a b9 ff ff       	call   c0100c27 <__panic>
    assert(pte2page(*ptep) == p1);
c01052fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105300:	8b 00                	mov    (%eax),%eax
c0105302:	89 04 24             	mov    %eax,(%esp)
c0105305:	e8 29 f1 ff ff       	call   c0104433 <pte2page>
c010530a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010530d:	74 24                	je     c0105333 <check_pgdir+0x191>
c010530f:	c7 44 24 0c dd 9a 10 	movl   $0xc0109add,0xc(%esp)
c0105316:	c0 
c0105317:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c010531e:	c0 
c010531f:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0105326:	00 
c0105327:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c010532e:	e8 f4 b8 ff ff       	call   c0100c27 <__panic>
    assert(page_ref(p1) == 1);
c0105333:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105336:	89 04 24             	mov    %eax,(%esp)
c0105339:	e8 4b f1 ff ff       	call   c0104489 <page_ref>
c010533e:	83 f8 01             	cmp    $0x1,%eax
c0105341:	74 24                	je     c0105367 <check_pgdir+0x1c5>
c0105343:	c7 44 24 0c f3 9a 10 	movl   $0xc0109af3,0xc(%esp)
c010534a:	c0 
c010534b:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105352:	c0 
c0105353:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c010535a:	00 
c010535b:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105362:	e8 c0 b8 ff ff       	call   c0100c27 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0105367:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c010536c:	8b 00                	mov    (%eax),%eax
c010536e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105373:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105376:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105379:	c1 e8 0c             	shr    $0xc,%eax
c010537c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010537f:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0105384:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105387:	72 23                	jb     c01053ac <check_pgdir+0x20a>
c0105389:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010538c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105390:	c7 44 24 08 ac 98 10 	movl   $0xc01098ac,0x8(%esp)
c0105397:	c0 
c0105398:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c010539f:	00 
c01053a0:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c01053a7:	e8 7b b8 ff ff       	call   c0100c27 <__panic>
c01053ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01053af:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01053b4:	83 c0 04             	add    $0x4,%eax
c01053b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01053ba:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01053bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01053c6:	00 
c01053c7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01053ce:	00 
c01053cf:	89 04 24             	mov    %eax,(%esp)
c01053d2:	e8 96 f9 ff ff       	call   c0104d6d <get_pte>
c01053d7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01053da:	74 24                	je     c0105400 <check_pgdir+0x25e>
c01053dc:	c7 44 24 0c 08 9b 10 	movl   $0xc0109b08,0xc(%esp)
c01053e3:	c0 
c01053e4:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c01053eb:	c0 
c01053ec:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c01053f3:	00 
c01053f4:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c01053fb:	e8 27 b8 ff ff       	call   c0100c27 <__panic>

    p2 = alloc_page();
c0105400:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105407:	e8 82 f2 ff ff       	call   c010468e <alloc_pages>
c010540c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c010540f:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105414:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c010541b:	00 
c010541c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105423:	00 
c0105424:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105427:	89 54 24 04          	mov    %edx,0x4(%esp)
c010542b:	89 04 24             	mov    %eax,(%esp)
c010542e:	e8 70 fb ff ff       	call   c0104fa3 <page_insert>
c0105433:	85 c0                	test   %eax,%eax
c0105435:	74 24                	je     c010545b <check_pgdir+0x2b9>
c0105437:	c7 44 24 0c 30 9b 10 	movl   $0xc0109b30,0xc(%esp)
c010543e:	c0 
c010543f:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105446:	c0 
c0105447:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c010544e:	00 
c010544f:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105456:	e8 cc b7 ff ff       	call   c0100c27 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010545b:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105460:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105467:	00 
c0105468:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010546f:	00 
c0105470:	89 04 24             	mov    %eax,(%esp)
c0105473:	e8 f5 f8 ff ff       	call   c0104d6d <get_pte>
c0105478:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010547b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010547f:	75 24                	jne    c01054a5 <check_pgdir+0x303>
c0105481:	c7 44 24 0c 68 9b 10 	movl   $0xc0109b68,0xc(%esp)
c0105488:	c0 
c0105489:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105490:	c0 
c0105491:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c0105498:	00 
c0105499:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c01054a0:	e8 82 b7 ff ff       	call   c0100c27 <__panic>
    assert(*ptep & PTE_U);
c01054a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054a8:	8b 00                	mov    (%eax),%eax
c01054aa:	83 e0 04             	and    $0x4,%eax
c01054ad:	85 c0                	test   %eax,%eax
c01054af:	75 24                	jne    c01054d5 <check_pgdir+0x333>
c01054b1:	c7 44 24 0c 98 9b 10 	movl   $0xc0109b98,0xc(%esp)
c01054b8:	c0 
c01054b9:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c01054c0:	c0 
c01054c1:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c01054c8:	00 
c01054c9:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c01054d0:	e8 52 b7 ff ff       	call   c0100c27 <__panic>
    assert(*ptep & PTE_W);
c01054d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054d8:	8b 00                	mov    (%eax),%eax
c01054da:	83 e0 02             	and    $0x2,%eax
c01054dd:	85 c0                	test   %eax,%eax
c01054df:	75 24                	jne    c0105505 <check_pgdir+0x363>
c01054e1:	c7 44 24 0c a6 9b 10 	movl   $0xc0109ba6,0xc(%esp)
c01054e8:	c0 
c01054e9:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c01054f0:	c0 
c01054f1:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c01054f8:	00 
c01054f9:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105500:	e8 22 b7 ff ff       	call   c0100c27 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0105505:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c010550a:	8b 00                	mov    (%eax),%eax
c010550c:	83 e0 04             	and    $0x4,%eax
c010550f:	85 c0                	test   %eax,%eax
c0105511:	75 24                	jne    c0105537 <check_pgdir+0x395>
c0105513:	c7 44 24 0c b4 9b 10 	movl   $0xc0109bb4,0xc(%esp)
c010551a:	c0 
c010551b:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105522:	c0 
c0105523:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c010552a:	00 
c010552b:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105532:	e8 f0 b6 ff ff       	call   c0100c27 <__panic>
    assert(page_ref(p2) == 1);
c0105537:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010553a:	89 04 24             	mov    %eax,(%esp)
c010553d:	e8 47 ef ff ff       	call   c0104489 <page_ref>
c0105542:	83 f8 01             	cmp    $0x1,%eax
c0105545:	74 24                	je     c010556b <check_pgdir+0x3c9>
c0105547:	c7 44 24 0c ca 9b 10 	movl   $0xc0109bca,0xc(%esp)
c010554e:	c0 
c010554f:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105556:	c0 
c0105557:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c010555e:	00 
c010555f:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105566:	e8 bc b6 ff ff       	call   c0100c27 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c010556b:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105570:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105577:	00 
c0105578:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010557f:	00 
c0105580:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105583:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105587:	89 04 24             	mov    %eax,(%esp)
c010558a:	e8 14 fa ff ff       	call   c0104fa3 <page_insert>
c010558f:	85 c0                	test   %eax,%eax
c0105591:	74 24                	je     c01055b7 <check_pgdir+0x415>
c0105593:	c7 44 24 0c dc 9b 10 	movl   $0xc0109bdc,0xc(%esp)
c010559a:	c0 
c010559b:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c01055a2:	c0 
c01055a3:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c01055aa:	00 
c01055ab:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c01055b2:	e8 70 b6 ff ff       	call   c0100c27 <__panic>
    assert(page_ref(p1) == 2);
c01055b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055ba:	89 04 24             	mov    %eax,(%esp)
c01055bd:	e8 c7 ee ff ff       	call   c0104489 <page_ref>
c01055c2:	83 f8 02             	cmp    $0x2,%eax
c01055c5:	74 24                	je     c01055eb <check_pgdir+0x449>
c01055c7:	c7 44 24 0c 08 9c 10 	movl   $0xc0109c08,0xc(%esp)
c01055ce:	c0 
c01055cf:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c01055d6:	c0 
c01055d7:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c01055de:	00 
c01055df:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c01055e6:	e8 3c b6 ff ff       	call   c0100c27 <__panic>
    assert(page_ref(p2) == 0);
c01055eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01055ee:	89 04 24             	mov    %eax,(%esp)
c01055f1:	e8 93 ee ff ff       	call   c0104489 <page_ref>
c01055f6:	85 c0                	test   %eax,%eax
c01055f8:	74 24                	je     c010561e <check_pgdir+0x47c>
c01055fa:	c7 44 24 0c 1a 9c 10 	movl   $0xc0109c1a,0xc(%esp)
c0105601:	c0 
c0105602:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105609:	c0 
c010560a:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0105611:	00 
c0105612:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105619:	e8 09 b6 ff ff       	call   c0100c27 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010561e:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105623:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010562a:	00 
c010562b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105632:	00 
c0105633:	89 04 24             	mov    %eax,(%esp)
c0105636:	e8 32 f7 ff ff       	call   c0104d6d <get_pte>
c010563b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010563e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105642:	75 24                	jne    c0105668 <check_pgdir+0x4c6>
c0105644:	c7 44 24 0c 68 9b 10 	movl   $0xc0109b68,0xc(%esp)
c010564b:	c0 
c010564c:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105653:	c0 
c0105654:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c010565b:	00 
c010565c:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105663:	e8 bf b5 ff ff       	call   c0100c27 <__panic>
    assert(pte2page(*ptep) == p1);
c0105668:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010566b:	8b 00                	mov    (%eax),%eax
c010566d:	89 04 24             	mov    %eax,(%esp)
c0105670:	e8 be ed ff ff       	call   c0104433 <pte2page>
c0105675:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105678:	74 24                	je     c010569e <check_pgdir+0x4fc>
c010567a:	c7 44 24 0c dd 9a 10 	movl   $0xc0109add,0xc(%esp)
c0105681:	c0 
c0105682:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105689:	c0 
c010568a:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c0105691:	00 
c0105692:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105699:	e8 89 b5 ff ff       	call   c0100c27 <__panic>
    assert((*ptep & PTE_U) == 0);
c010569e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056a1:	8b 00                	mov    (%eax),%eax
c01056a3:	83 e0 04             	and    $0x4,%eax
c01056a6:	85 c0                	test   %eax,%eax
c01056a8:	74 24                	je     c01056ce <check_pgdir+0x52c>
c01056aa:	c7 44 24 0c 2c 9c 10 	movl   $0xc0109c2c,0xc(%esp)
c01056b1:	c0 
c01056b2:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c01056b9:	c0 
c01056ba:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c01056c1:	00 
c01056c2:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c01056c9:	e8 59 b5 ff ff       	call   c0100c27 <__panic>

    page_remove(boot_pgdir, 0x0);
c01056ce:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01056d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01056da:	00 
c01056db:	89 04 24             	mov    %eax,(%esp)
c01056de:	e8 7c f8 ff ff       	call   c0104f5f <page_remove>
    assert(page_ref(p1) == 1);
c01056e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056e6:	89 04 24             	mov    %eax,(%esp)
c01056e9:	e8 9b ed ff ff       	call   c0104489 <page_ref>
c01056ee:	83 f8 01             	cmp    $0x1,%eax
c01056f1:	74 24                	je     c0105717 <check_pgdir+0x575>
c01056f3:	c7 44 24 0c f3 9a 10 	movl   $0xc0109af3,0xc(%esp)
c01056fa:	c0 
c01056fb:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105702:	c0 
c0105703:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
c010570a:	00 
c010570b:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105712:	e8 10 b5 ff ff       	call   c0100c27 <__panic>
    assert(page_ref(p2) == 0);
c0105717:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010571a:	89 04 24             	mov    %eax,(%esp)
c010571d:	e8 67 ed ff ff       	call   c0104489 <page_ref>
c0105722:	85 c0                	test   %eax,%eax
c0105724:	74 24                	je     c010574a <check_pgdir+0x5a8>
c0105726:	c7 44 24 0c 1a 9c 10 	movl   $0xc0109c1a,0xc(%esp)
c010572d:	c0 
c010572e:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105735:	c0 
c0105736:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c010573d:	00 
c010573e:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105745:	e8 dd b4 ff ff       	call   c0100c27 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c010574a:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c010574f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105756:	00 
c0105757:	89 04 24             	mov    %eax,(%esp)
c010575a:	e8 00 f8 ff ff       	call   c0104f5f <page_remove>
    assert(page_ref(p1) == 0);
c010575f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105762:	89 04 24             	mov    %eax,(%esp)
c0105765:	e8 1f ed ff ff       	call   c0104489 <page_ref>
c010576a:	85 c0                	test   %eax,%eax
c010576c:	74 24                	je     c0105792 <check_pgdir+0x5f0>
c010576e:	c7 44 24 0c 41 9c 10 	movl   $0xc0109c41,0xc(%esp)
c0105775:	c0 
c0105776:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c010577d:	c0 
c010577e:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c0105785:	00 
c0105786:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c010578d:	e8 95 b4 ff ff       	call   c0100c27 <__panic>
    assert(page_ref(p2) == 0);
c0105792:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105795:	89 04 24             	mov    %eax,(%esp)
c0105798:	e8 ec ec ff ff       	call   c0104489 <page_ref>
c010579d:	85 c0                	test   %eax,%eax
c010579f:	74 24                	je     c01057c5 <check_pgdir+0x623>
c01057a1:	c7 44 24 0c 1a 9c 10 	movl   $0xc0109c1a,0xc(%esp)
c01057a8:	c0 
c01057a9:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c01057b0:	c0 
c01057b1:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c01057b8:	00 
c01057b9:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c01057c0:	e8 62 b4 ff ff       	call   c0100c27 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c01057c5:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01057ca:	8b 00                	mov    (%eax),%eax
c01057cc:	89 04 24             	mov    %eax,(%esp)
c01057cf:	e8 9d ec ff ff       	call   c0104471 <pde2page>
c01057d4:	89 04 24             	mov    %eax,(%esp)
c01057d7:	e8 ad ec ff ff       	call   c0104489 <page_ref>
c01057dc:	83 f8 01             	cmp    $0x1,%eax
c01057df:	74 24                	je     c0105805 <check_pgdir+0x663>
c01057e1:	c7 44 24 0c 54 9c 10 	movl   $0xc0109c54,0xc(%esp)
c01057e8:	c0 
c01057e9:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c01057f0:	c0 
c01057f1:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
c01057f8:	00 
c01057f9:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105800:	e8 22 b4 ff ff       	call   c0100c27 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0105805:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c010580a:	8b 00                	mov    (%eax),%eax
c010580c:	89 04 24             	mov    %eax,(%esp)
c010580f:	e8 5d ec ff ff       	call   c0104471 <pde2page>
c0105814:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010581b:	00 
c010581c:	89 04 24             	mov    %eax,(%esp)
c010581f:	e8 d5 ee ff ff       	call   c01046f9 <free_pages>
    boot_pgdir[0] = 0;
c0105824:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105829:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c010582f:	c7 04 24 7b 9c 10 c0 	movl   $0xc0109c7b,(%esp)
c0105836:	e8 1c ab ff ff       	call   c0100357 <cprintf>
}
c010583b:	c9                   	leave  
c010583c:	c3                   	ret    

c010583d <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c010583d:	55                   	push   %ebp
c010583e:	89 e5                	mov    %esp,%ebp
c0105840:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0105843:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010584a:	e9 ca 00 00 00       	jmp    c0105919 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c010584f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105852:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105855:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105858:	c1 e8 0c             	shr    $0xc,%eax
c010585b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010585e:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0105863:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105866:	72 23                	jb     c010588b <check_boot_pgdir+0x4e>
c0105868:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010586b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010586f:	c7 44 24 08 ac 98 10 	movl   $0xc01098ac,0x8(%esp)
c0105876:	c0 
c0105877:	c7 44 24 04 3b 02 00 	movl   $0x23b,0x4(%esp)
c010587e:	00 
c010587f:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105886:	e8 9c b3 ff ff       	call   c0100c27 <__panic>
c010588b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010588e:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105893:	89 c2                	mov    %eax,%edx
c0105895:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c010589a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01058a1:	00 
c01058a2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01058a6:	89 04 24             	mov    %eax,(%esp)
c01058a9:	e8 bf f4 ff ff       	call   c0104d6d <get_pte>
c01058ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01058b1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01058b5:	75 24                	jne    c01058db <check_boot_pgdir+0x9e>
c01058b7:	c7 44 24 0c 98 9c 10 	movl   $0xc0109c98,0xc(%esp)
c01058be:	c0 
c01058bf:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c01058c6:	c0 
c01058c7:	c7 44 24 04 3b 02 00 	movl   $0x23b,0x4(%esp)
c01058ce:	00 
c01058cf:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c01058d6:	e8 4c b3 ff ff       	call   c0100c27 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c01058db:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01058de:	8b 00                	mov    (%eax),%eax
c01058e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01058e5:	89 c2                	mov    %eax,%edx
c01058e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058ea:	39 c2                	cmp    %eax,%edx
c01058ec:	74 24                	je     c0105912 <check_boot_pgdir+0xd5>
c01058ee:	c7 44 24 0c d5 9c 10 	movl   $0xc0109cd5,0xc(%esp)
c01058f5:	c0 
c01058f6:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c01058fd:	c0 
c01058fe:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
c0105905:	00 
c0105906:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c010590d:	e8 15 b3 ff ff       	call   c0100c27 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0105912:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0105919:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010591c:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0105921:	39 c2                	cmp    %eax,%edx
c0105923:	0f 82 26 ff ff ff    	jb     c010584f <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0105929:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c010592e:	05 ac 0f 00 00       	add    $0xfac,%eax
c0105933:	8b 00                	mov    (%eax),%eax
c0105935:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010593a:	89 c2                	mov    %eax,%edx
c010593c:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105941:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105944:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c010594b:	77 23                	ja     c0105970 <check_boot_pgdir+0x133>
c010594d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105950:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105954:	c7 44 24 08 d0 98 10 	movl   $0xc01098d0,0x8(%esp)
c010595b:	c0 
c010595c:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c0105963:	00 
c0105964:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c010596b:	e8 b7 b2 ff ff       	call   c0100c27 <__panic>
c0105970:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105973:	05 00 00 00 40       	add    $0x40000000,%eax
c0105978:	39 c2                	cmp    %eax,%edx
c010597a:	74 24                	je     c01059a0 <check_boot_pgdir+0x163>
c010597c:	c7 44 24 0c ec 9c 10 	movl   $0xc0109cec,0xc(%esp)
c0105983:	c0 
c0105984:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c010598b:	c0 
c010598c:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c0105993:	00 
c0105994:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c010599b:	e8 87 b2 ff ff       	call   c0100c27 <__panic>

    assert(boot_pgdir[0] == 0);
c01059a0:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01059a5:	8b 00                	mov    (%eax),%eax
c01059a7:	85 c0                	test   %eax,%eax
c01059a9:	74 24                	je     c01059cf <check_boot_pgdir+0x192>
c01059ab:	c7 44 24 0c 20 9d 10 	movl   $0xc0109d20,0xc(%esp)
c01059b2:	c0 
c01059b3:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c01059ba:	c0 
c01059bb:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c01059c2:	00 
c01059c3:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c01059ca:	e8 58 b2 ff ff       	call   c0100c27 <__panic>

    struct Page *p;
    p = alloc_page();
c01059cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01059d6:	e8 b3 ec ff ff       	call   c010468e <alloc_pages>
c01059db:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c01059de:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01059e3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01059ea:	00 
c01059eb:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c01059f2:	00 
c01059f3:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01059f6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01059fa:	89 04 24             	mov    %eax,(%esp)
c01059fd:	e8 a1 f5 ff ff       	call   c0104fa3 <page_insert>
c0105a02:	85 c0                	test   %eax,%eax
c0105a04:	74 24                	je     c0105a2a <check_boot_pgdir+0x1ed>
c0105a06:	c7 44 24 0c 34 9d 10 	movl   $0xc0109d34,0xc(%esp)
c0105a0d:	c0 
c0105a0e:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105a15:	c0 
c0105a16:	c7 44 24 04 45 02 00 	movl   $0x245,0x4(%esp)
c0105a1d:	00 
c0105a1e:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105a25:	e8 fd b1 ff ff       	call   c0100c27 <__panic>
    assert(page_ref(p) == 1);
c0105a2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105a2d:	89 04 24             	mov    %eax,(%esp)
c0105a30:	e8 54 ea ff ff       	call   c0104489 <page_ref>
c0105a35:	83 f8 01             	cmp    $0x1,%eax
c0105a38:	74 24                	je     c0105a5e <check_boot_pgdir+0x221>
c0105a3a:	c7 44 24 0c 62 9d 10 	movl   $0xc0109d62,0xc(%esp)
c0105a41:	c0 
c0105a42:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105a49:	c0 
c0105a4a:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
c0105a51:	00 
c0105a52:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105a59:	e8 c9 b1 ff ff       	call   c0100c27 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0105a5e:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105a63:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105a6a:	00 
c0105a6b:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0105a72:	00 
c0105a73:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105a76:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105a7a:	89 04 24             	mov    %eax,(%esp)
c0105a7d:	e8 21 f5 ff ff       	call   c0104fa3 <page_insert>
c0105a82:	85 c0                	test   %eax,%eax
c0105a84:	74 24                	je     c0105aaa <check_boot_pgdir+0x26d>
c0105a86:	c7 44 24 0c 74 9d 10 	movl   $0xc0109d74,0xc(%esp)
c0105a8d:	c0 
c0105a8e:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105a95:	c0 
c0105a96:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
c0105a9d:	00 
c0105a9e:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105aa5:	e8 7d b1 ff ff       	call   c0100c27 <__panic>
    assert(page_ref(p) == 2);
c0105aaa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105aad:	89 04 24             	mov    %eax,(%esp)
c0105ab0:	e8 d4 e9 ff ff       	call   c0104489 <page_ref>
c0105ab5:	83 f8 02             	cmp    $0x2,%eax
c0105ab8:	74 24                	je     c0105ade <check_boot_pgdir+0x2a1>
c0105aba:	c7 44 24 0c ab 9d 10 	movl   $0xc0109dab,0xc(%esp)
c0105ac1:	c0 
c0105ac2:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105ac9:	c0 
c0105aca:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c0105ad1:	00 
c0105ad2:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105ad9:	e8 49 b1 ff ff       	call   c0100c27 <__panic>

    const char *str = "ucore: Hello world!!";
c0105ade:	c7 45 dc bc 9d 10 c0 	movl   $0xc0109dbc,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0105ae5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105ae8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105aec:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105af3:	e8 cf 2c 00 00       	call   c01087c7 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0105af8:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0105aff:	00 
c0105b00:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105b07:	e8 34 2d 00 00       	call   c0108840 <strcmp>
c0105b0c:	85 c0                	test   %eax,%eax
c0105b0e:	74 24                	je     c0105b34 <check_boot_pgdir+0x2f7>
c0105b10:	c7 44 24 0c d4 9d 10 	movl   $0xc0109dd4,0xc(%esp)
c0105b17:	c0 
c0105b18:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105b1f:	c0 
c0105b20:	c7 44 24 04 4c 02 00 	movl   $0x24c,0x4(%esp)
c0105b27:	00 
c0105b28:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105b2f:	e8 f3 b0 ff ff       	call   c0100c27 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0105b34:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b37:	89 04 24             	mov    %eax,(%esp)
c0105b3a:	e8 56 e8 ff ff       	call   c0104395 <page2kva>
c0105b3f:	05 00 01 00 00       	add    $0x100,%eax
c0105b44:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0105b47:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105b4e:	e8 1c 2c 00 00       	call   c010876f <strlen>
c0105b53:	85 c0                	test   %eax,%eax
c0105b55:	74 24                	je     c0105b7b <check_boot_pgdir+0x33e>
c0105b57:	c7 44 24 0c 0c 9e 10 	movl   $0xc0109e0c,0xc(%esp)
c0105b5e:	c0 
c0105b5f:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105b66:	c0 
c0105b67:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
c0105b6e:	00 
c0105b6f:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105b76:	e8 ac b0 ff ff       	call   c0100c27 <__panic>

    free_page(p);
c0105b7b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105b82:	00 
c0105b83:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b86:	89 04 24             	mov    %eax,(%esp)
c0105b89:	e8 6b eb ff ff       	call   c01046f9 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0105b8e:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105b93:	8b 00                	mov    (%eax),%eax
c0105b95:	89 04 24             	mov    %eax,(%esp)
c0105b98:	e8 d4 e8 ff ff       	call   c0104471 <pde2page>
c0105b9d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105ba4:	00 
c0105ba5:	89 04 24             	mov    %eax,(%esp)
c0105ba8:	e8 4c eb ff ff       	call   c01046f9 <free_pages>
    boot_pgdir[0] = 0;
c0105bad:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105bb2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0105bb8:	c7 04 24 30 9e 10 c0 	movl   $0xc0109e30,(%esp)
c0105bbf:	e8 93 a7 ff ff       	call   c0100357 <cprintf>
}
c0105bc4:	c9                   	leave  
c0105bc5:	c3                   	ret    

c0105bc6 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105bc6:	55                   	push   %ebp
c0105bc7:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0105bc9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bcc:	83 e0 04             	and    $0x4,%eax
c0105bcf:	85 c0                	test   %eax,%eax
c0105bd1:	74 07                	je     c0105bda <perm2str+0x14>
c0105bd3:	b8 75 00 00 00       	mov    $0x75,%eax
c0105bd8:	eb 05                	jmp    c0105bdf <perm2str+0x19>
c0105bda:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0105bdf:	a2 28 40 12 c0       	mov    %al,0xc0124028
    str[1] = 'r';
c0105be4:	c6 05 29 40 12 c0 72 	movb   $0x72,0xc0124029
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0105beb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bee:	83 e0 02             	and    $0x2,%eax
c0105bf1:	85 c0                	test   %eax,%eax
c0105bf3:	74 07                	je     c0105bfc <perm2str+0x36>
c0105bf5:	b8 77 00 00 00       	mov    $0x77,%eax
c0105bfa:	eb 05                	jmp    c0105c01 <perm2str+0x3b>
c0105bfc:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0105c01:	a2 2a 40 12 c0       	mov    %al,0xc012402a
    str[3] = '\0';
c0105c06:	c6 05 2b 40 12 c0 00 	movb   $0x0,0xc012402b
    return str;
c0105c0d:	b8 28 40 12 c0       	mov    $0xc0124028,%eax
}
c0105c12:	5d                   	pop    %ebp
c0105c13:	c3                   	ret    

c0105c14 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0105c14:	55                   	push   %ebp
c0105c15:	89 e5                	mov    %esp,%ebp
c0105c17:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0105c1a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c1d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105c20:	72 0a                	jb     c0105c2c <get_pgtable_items+0x18>
        return 0;
c0105c22:	b8 00 00 00 00       	mov    $0x0,%eax
c0105c27:	e9 9c 00 00 00       	jmp    c0105cc8 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0105c2c:	eb 04                	jmp    c0105c32 <get_pgtable_items+0x1e>
        start ++;
c0105c2e:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0105c32:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c35:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105c38:	73 18                	jae    c0105c52 <get_pgtable_items+0x3e>
c0105c3a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c3d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105c44:	8b 45 14             	mov    0x14(%ebp),%eax
c0105c47:	01 d0                	add    %edx,%eax
c0105c49:	8b 00                	mov    (%eax),%eax
c0105c4b:	83 e0 01             	and    $0x1,%eax
c0105c4e:	85 c0                	test   %eax,%eax
c0105c50:	74 dc                	je     c0105c2e <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c0105c52:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c55:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105c58:	73 69                	jae    c0105cc3 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0105c5a:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0105c5e:	74 08                	je     c0105c68 <get_pgtable_items+0x54>
            *left_store = start;
c0105c60:	8b 45 18             	mov    0x18(%ebp),%eax
c0105c63:	8b 55 10             	mov    0x10(%ebp),%edx
c0105c66:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0105c68:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c6b:	8d 50 01             	lea    0x1(%eax),%edx
c0105c6e:	89 55 10             	mov    %edx,0x10(%ebp)
c0105c71:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105c78:	8b 45 14             	mov    0x14(%ebp),%eax
c0105c7b:	01 d0                	add    %edx,%eax
c0105c7d:	8b 00                	mov    (%eax),%eax
c0105c7f:	83 e0 07             	and    $0x7,%eax
c0105c82:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105c85:	eb 04                	jmp    c0105c8b <get_pgtable_items+0x77>
            start ++;
c0105c87:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105c8b:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c8e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105c91:	73 1d                	jae    c0105cb0 <get_pgtable_items+0x9c>
c0105c93:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c96:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105c9d:	8b 45 14             	mov    0x14(%ebp),%eax
c0105ca0:	01 d0                	add    %edx,%eax
c0105ca2:	8b 00                	mov    (%eax),%eax
c0105ca4:	83 e0 07             	and    $0x7,%eax
c0105ca7:	89 c2                	mov    %eax,%edx
c0105ca9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105cac:	39 c2                	cmp    %eax,%edx
c0105cae:	74 d7                	je     c0105c87 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c0105cb0:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105cb4:	74 08                	je     c0105cbe <get_pgtable_items+0xaa>
            *right_store = start;
c0105cb6:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105cb9:	8b 55 10             	mov    0x10(%ebp),%edx
c0105cbc:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0105cbe:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105cc1:	eb 05                	jmp    c0105cc8 <get_pgtable_items+0xb4>
    }
    return 0;
c0105cc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105cc8:	c9                   	leave  
c0105cc9:	c3                   	ret    

c0105cca <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0105cca:	55                   	push   %ebp
c0105ccb:	89 e5                	mov    %esp,%ebp
c0105ccd:	57                   	push   %edi
c0105cce:	56                   	push   %esi
c0105ccf:	53                   	push   %ebx
c0105cd0:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105cd3:	c7 04 24 50 9e 10 c0 	movl   $0xc0109e50,(%esp)
c0105cda:	e8 78 a6 ff ff       	call   c0100357 <cprintf>
    size_t left, right = 0, perm;
c0105cdf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105ce6:	e9 fa 00 00 00       	jmp    c0105de5 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105ceb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105cee:	89 04 24             	mov    %eax,(%esp)
c0105cf1:	e8 d0 fe ff ff       	call   c0105bc6 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0105cf6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105cf9:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105cfc:	29 d1                	sub    %edx,%ecx
c0105cfe:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105d00:	89 d6                	mov    %edx,%esi
c0105d02:	c1 e6 16             	shl    $0x16,%esi
c0105d05:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105d08:	89 d3                	mov    %edx,%ebx
c0105d0a:	c1 e3 16             	shl    $0x16,%ebx
c0105d0d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105d10:	89 d1                	mov    %edx,%ecx
c0105d12:	c1 e1 16             	shl    $0x16,%ecx
c0105d15:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0105d18:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105d1b:	29 d7                	sub    %edx,%edi
c0105d1d:	89 fa                	mov    %edi,%edx
c0105d1f:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105d23:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105d27:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105d2b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105d2f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105d33:	c7 04 24 81 9e 10 c0 	movl   $0xc0109e81,(%esp)
c0105d3a:	e8 18 a6 ff ff       	call   c0100357 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0105d3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d42:	c1 e0 0a             	shl    $0xa,%eax
c0105d45:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105d48:	eb 54                	jmp    c0105d9e <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105d4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105d4d:	89 04 24             	mov    %eax,(%esp)
c0105d50:	e8 71 fe ff ff       	call   c0105bc6 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0105d55:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0105d58:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105d5b:	29 d1                	sub    %edx,%ecx
c0105d5d:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105d5f:	89 d6                	mov    %edx,%esi
c0105d61:	c1 e6 0c             	shl    $0xc,%esi
c0105d64:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105d67:	89 d3                	mov    %edx,%ebx
c0105d69:	c1 e3 0c             	shl    $0xc,%ebx
c0105d6c:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105d6f:	c1 e2 0c             	shl    $0xc,%edx
c0105d72:	89 d1                	mov    %edx,%ecx
c0105d74:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0105d77:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105d7a:	29 d7                	sub    %edx,%edi
c0105d7c:	89 fa                	mov    %edi,%edx
c0105d7e:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105d82:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105d86:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105d8a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105d8e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105d92:	c7 04 24 a0 9e 10 c0 	movl   $0xc0109ea0,(%esp)
c0105d99:	e8 b9 a5 ff ff       	call   c0100357 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105d9e:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c0105da3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105da6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105da9:	89 ce                	mov    %ecx,%esi
c0105dab:	c1 e6 0a             	shl    $0xa,%esi
c0105dae:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0105db1:	89 cb                	mov    %ecx,%ebx
c0105db3:	c1 e3 0a             	shl    $0xa,%ebx
c0105db6:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c0105db9:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0105dbd:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c0105dc0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0105dc4:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105dc8:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105dcc:	89 74 24 04          	mov    %esi,0x4(%esp)
c0105dd0:	89 1c 24             	mov    %ebx,(%esp)
c0105dd3:	e8 3c fe ff ff       	call   c0105c14 <get_pgtable_items>
c0105dd8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105ddb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105ddf:	0f 85 65 ff ff ff    	jne    c0105d4a <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105de5:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0105dea:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105ded:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c0105df0:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0105df4:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0105df7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0105dfb:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105dff:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105e03:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0105e0a:	00 
c0105e0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0105e12:	e8 fd fd ff ff       	call   c0105c14 <get_pgtable_items>
c0105e17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105e1a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105e1e:	0f 85 c7 fe ff ff    	jne    c0105ceb <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0105e24:	c7 04 24 c4 9e 10 c0 	movl   $0xc0109ec4,(%esp)
c0105e2b:	e8 27 a5 ff ff       	call   c0100357 <cprintf>
}
c0105e30:	83 c4 4c             	add    $0x4c,%esp
c0105e33:	5b                   	pop    %ebx
c0105e34:	5e                   	pop    %esi
c0105e35:	5f                   	pop    %edi
c0105e36:	5d                   	pop    %ebp
c0105e37:	c3                   	ret    

c0105e38 <kmalloc>:

void *
kmalloc(size_t n) {
c0105e38:	55                   	push   %ebp
c0105e39:	89 e5                	mov    %esp,%ebp
c0105e3b:	83 ec 28             	sub    $0x28,%esp
    void * ptr=NULL;
c0105e3e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct Page *base=NULL;
c0105e45:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    assert(n > 0 && n < 1024*0124);
c0105e4c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105e50:	74 09                	je     c0105e5b <kmalloc+0x23>
c0105e52:	81 7d 08 ff 4f 01 00 	cmpl   $0x14fff,0x8(%ebp)
c0105e59:	76 24                	jbe    c0105e7f <kmalloc+0x47>
c0105e5b:	c7 44 24 0c f5 9e 10 	movl   $0xc0109ef5,0xc(%esp)
c0105e62:	c0 
c0105e63:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105e6a:	c0 
c0105e6b:	c7 44 24 04 9b 02 00 	movl   $0x29b,0x4(%esp)
c0105e72:	00 
c0105e73:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105e7a:	e8 a8 ad ff ff       	call   c0100c27 <__panic>
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0105e7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e82:	05 ff 0f 00 00       	add    $0xfff,%eax
c0105e87:	c1 e8 0c             	shr    $0xc,%eax
c0105e8a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    base = alloc_pages(num_pages);
c0105e8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e90:	89 04 24             	mov    %eax,(%esp)
c0105e93:	e8 f6 e7 ff ff       	call   c010468e <alloc_pages>
c0105e98:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(base != NULL);
c0105e9b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105e9f:	75 24                	jne    c0105ec5 <kmalloc+0x8d>
c0105ea1:	c7 44 24 0c 0c 9f 10 	movl   $0xc0109f0c,0xc(%esp)
c0105ea8:	c0 
c0105ea9:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105eb0:	c0 
c0105eb1:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
c0105eb8:	00 
c0105eb9:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105ec0:	e8 62 ad ff ff       	call   c0100c27 <__panic>
    ptr=page2kva(base);
c0105ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ec8:	89 04 24             	mov    %eax,(%esp)
c0105ecb:	e8 c5 e4 ff ff       	call   c0104395 <page2kva>
c0105ed0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ptr;
c0105ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105ed6:	c9                   	leave  
c0105ed7:	c3                   	ret    

c0105ed8 <kfree>:

void 
kfree(void *ptr, size_t n) {
c0105ed8:	55                   	push   %ebp
c0105ed9:	89 e5                	mov    %esp,%ebp
c0105edb:	83 ec 28             	sub    $0x28,%esp
    assert(n > 0 && n < 1024*0124);
c0105ede:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105ee2:	74 09                	je     c0105eed <kfree+0x15>
c0105ee4:	81 7d 0c ff 4f 01 00 	cmpl   $0x14fff,0xc(%ebp)
c0105eeb:	76 24                	jbe    c0105f11 <kfree+0x39>
c0105eed:	c7 44 24 0c f5 9e 10 	movl   $0xc0109ef5,0xc(%esp)
c0105ef4:	c0 
c0105ef5:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105efc:	c0 
c0105efd:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
c0105f04:	00 
c0105f05:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105f0c:	e8 16 ad ff ff       	call   c0100c27 <__panic>
    assert(ptr != NULL);
c0105f11:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105f15:	75 24                	jne    c0105f3b <kfree+0x63>
c0105f17:	c7 44 24 0c 19 9f 10 	movl   $0xc0109f19,0xc(%esp)
c0105f1e:	c0 
c0105f1f:	c7 44 24 08 99 99 10 	movl   $0xc0109999,0x8(%esp)
c0105f26:	c0 
c0105f27:	c7 44 24 04 a6 02 00 	movl   $0x2a6,0x4(%esp)
c0105f2e:	00 
c0105f2f:	c7 04 24 74 99 10 c0 	movl   $0xc0109974,(%esp)
c0105f36:	e8 ec ac ff ff       	call   c0100c27 <__panic>
    struct Page *base=NULL;
c0105f3b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0105f42:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f45:	05 ff 0f 00 00       	add    $0xfff,%eax
c0105f4a:	c1 e8 0c             	shr    $0xc,%eax
c0105f4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    base = kva2page(ptr);
c0105f50:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f53:	89 04 24             	mov    %eax,(%esp)
c0105f56:	e8 8e e4 ff ff       	call   c01043e9 <kva2page>
c0105f5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    free_pages(base, num_pages);
c0105f5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f61:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f68:	89 04 24             	mov    %eax,(%esp)
c0105f6b:	e8 89 e7 ff ff       	call   c01046f9 <free_pages>
}
c0105f70:	c9                   	leave  
c0105f71:	c3                   	ret    

c0105f72 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0105f72:	55                   	push   %ebp
c0105f73:	89 e5                	mov    %esp,%ebp
c0105f75:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0105f78:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f7b:	c1 e8 0c             	shr    $0xc,%eax
c0105f7e:	89 c2                	mov    %eax,%edx
c0105f80:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0105f85:	39 c2                	cmp    %eax,%edx
c0105f87:	72 1c                	jb     c0105fa5 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0105f89:	c7 44 24 08 28 9f 10 	movl   $0xc0109f28,0x8(%esp)
c0105f90:	c0 
c0105f91:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0105f98:	00 
c0105f99:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105fa0:	e8 82 ac ff ff       	call   c0100c27 <__panic>
    }
    return &pages[PPN(pa)];
c0105fa5:	a1 54 40 12 c0       	mov    0xc0124054,%eax
c0105faa:	8b 55 08             	mov    0x8(%ebp),%edx
c0105fad:	c1 ea 0c             	shr    $0xc,%edx
c0105fb0:	c1 e2 05             	shl    $0x5,%edx
c0105fb3:	01 d0                	add    %edx,%eax
}
c0105fb5:	c9                   	leave  
c0105fb6:	c3                   	ret    

c0105fb7 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0105fb7:	55                   	push   %ebp
c0105fb8:	89 e5                	mov    %esp,%ebp
c0105fba:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0105fbd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fc0:	83 e0 01             	and    $0x1,%eax
c0105fc3:	85 c0                	test   %eax,%eax
c0105fc5:	75 1c                	jne    c0105fe3 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0105fc7:	c7 44 24 08 58 9f 10 	movl   $0xc0109f58,0x8(%esp)
c0105fce:	c0 
c0105fcf:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0105fd6:	00 
c0105fd7:	c7 04 24 47 9f 10 c0 	movl   $0xc0109f47,(%esp)
c0105fde:	e8 44 ac ff ff       	call   c0100c27 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0105fe3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fe6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105feb:	89 04 24             	mov    %eax,(%esp)
c0105fee:	e8 7f ff ff ff       	call   c0105f72 <pa2page>
}
c0105ff3:	c9                   	leave  
c0105ff4:	c3                   	ret    

c0105ff5 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0105ff5:	55                   	push   %ebp
c0105ff6:	89 e5                	mov    %esp,%ebp
c0105ff8:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c0105ffb:	e8 ea 1e 00 00       	call   c0107eea <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0106000:	a1 fc 40 12 c0       	mov    0xc01240fc,%eax
c0106005:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c010600a:	76 0c                	jbe    c0106018 <swap_init+0x23>
c010600c:	a1 fc 40 12 c0       	mov    0xc01240fc,%eax
c0106011:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0106016:	76 25                	jbe    c010603d <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0106018:	a1 fc 40 12 c0       	mov    0xc01240fc,%eax
c010601d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106021:	c7 44 24 08 79 9f 10 	movl   $0xc0109f79,0x8(%esp)
c0106028:	c0 
c0106029:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
c0106030:	00 
c0106031:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c0106038:	e8 ea ab ff ff       	call   c0100c27 <__panic>
     }
     

     sm = &swap_manager_fifo;
c010603d:	c7 05 34 40 12 c0 40 	movl   $0xc0120a40,0xc0124034
c0106044:	0a 12 c0 
     int r = sm->init();
c0106047:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c010604c:	8b 40 04             	mov    0x4(%eax),%eax
c010604f:	ff d0                	call   *%eax
c0106051:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0106054:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106058:	75 26                	jne    c0106080 <swap_init+0x8b>
     {
          swap_init_ok = 1;
c010605a:	c7 05 2c 40 12 c0 01 	movl   $0x1,0xc012402c
c0106061:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0106064:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c0106069:	8b 00                	mov    (%eax),%eax
c010606b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010606f:	c7 04 24 a3 9f 10 c0 	movl   $0xc0109fa3,(%esp)
c0106076:	e8 dc a2 ff ff       	call   c0100357 <cprintf>
          check_swap();
c010607b:	e8 a4 04 00 00       	call   c0106524 <check_swap>
     }

     return r;
c0106080:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106083:	c9                   	leave  
c0106084:	c3                   	ret    

c0106085 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0106085:	55                   	push   %ebp
c0106086:	89 e5                	mov    %esp,%ebp
c0106088:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c010608b:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c0106090:	8b 40 08             	mov    0x8(%eax),%eax
c0106093:	8b 55 08             	mov    0x8(%ebp),%edx
c0106096:	89 14 24             	mov    %edx,(%esp)
c0106099:	ff d0                	call   *%eax
}
c010609b:	c9                   	leave  
c010609c:	c3                   	ret    

c010609d <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c010609d:	55                   	push   %ebp
c010609e:	89 e5                	mov    %esp,%ebp
c01060a0:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c01060a3:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c01060a8:	8b 40 0c             	mov    0xc(%eax),%eax
c01060ab:	8b 55 08             	mov    0x8(%ebp),%edx
c01060ae:	89 14 24             	mov    %edx,(%esp)
c01060b1:	ff d0                	call   *%eax
}
c01060b3:	c9                   	leave  
c01060b4:	c3                   	ret    

c01060b5 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01060b5:	55                   	push   %ebp
c01060b6:	89 e5                	mov    %esp,%ebp
c01060b8:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c01060bb:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c01060c0:	8b 40 10             	mov    0x10(%eax),%eax
c01060c3:	8b 55 14             	mov    0x14(%ebp),%edx
c01060c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01060ca:	8b 55 10             	mov    0x10(%ebp),%edx
c01060cd:	89 54 24 08          	mov    %edx,0x8(%esp)
c01060d1:	8b 55 0c             	mov    0xc(%ebp),%edx
c01060d4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01060d8:	8b 55 08             	mov    0x8(%ebp),%edx
c01060db:	89 14 24             	mov    %edx,(%esp)
c01060de:	ff d0                	call   *%eax
}
c01060e0:	c9                   	leave  
c01060e1:	c3                   	ret    

c01060e2 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01060e2:	55                   	push   %ebp
c01060e3:	89 e5                	mov    %esp,%ebp
c01060e5:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c01060e8:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c01060ed:	8b 40 14             	mov    0x14(%eax),%eax
c01060f0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01060f3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01060f7:	8b 55 08             	mov    0x8(%ebp),%edx
c01060fa:	89 14 24             	mov    %edx,(%esp)
c01060fd:	ff d0                	call   *%eax
}
c01060ff:	c9                   	leave  
c0106100:	c3                   	ret    

c0106101 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0106101:	55                   	push   %ebp
c0106102:	89 e5                	mov    %esp,%ebp
c0106104:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0106107:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010610e:	e9 5a 01 00 00       	jmp    c010626d <swap_out+0x16c>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0106113:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c0106118:	8b 40 18             	mov    0x18(%eax),%eax
c010611b:	8b 55 10             	mov    0x10(%ebp),%edx
c010611e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106122:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0106125:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106129:	8b 55 08             	mov    0x8(%ebp),%edx
c010612c:	89 14 24             	mov    %edx,(%esp)
c010612f:	ff d0                	call   *%eax
c0106131:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0106134:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106138:	74 18                	je     c0106152 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c010613a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010613d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106141:	c7 04 24 b8 9f 10 c0 	movl   $0xc0109fb8,(%esp)
c0106148:	e8 0a a2 ff ff       	call   c0100357 <cprintf>
c010614d:	e9 27 01 00 00       	jmp    c0106279 <swap_out+0x178>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0106152:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106155:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106158:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c010615b:	8b 45 08             	mov    0x8(%ebp),%eax
c010615e:	8b 40 0c             	mov    0xc(%eax),%eax
c0106161:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106168:	00 
c0106169:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010616c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106170:	89 04 24             	mov    %eax,(%esp)
c0106173:	e8 f5 eb ff ff       	call   c0104d6d <get_pte>
c0106178:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c010617b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010617e:	8b 00                	mov    (%eax),%eax
c0106180:	83 e0 01             	and    $0x1,%eax
c0106183:	85 c0                	test   %eax,%eax
c0106185:	75 24                	jne    c01061ab <swap_out+0xaa>
c0106187:	c7 44 24 0c e5 9f 10 	movl   $0xc0109fe5,0xc(%esp)
c010618e:	c0 
c010618f:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c0106196:	c0 
c0106197:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c010619e:	00 
c010619f:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c01061a6:	e8 7c aa ff ff       	call   c0100c27 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c01061ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01061ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01061b1:	8b 52 1c             	mov    0x1c(%edx),%edx
c01061b4:	c1 ea 0c             	shr    $0xc,%edx
c01061b7:	83 c2 01             	add    $0x1,%edx
c01061ba:	c1 e2 08             	shl    $0x8,%edx
c01061bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01061c1:	89 14 24             	mov    %edx,(%esp)
c01061c4:	e8 db 1d 00 00       	call   c0107fa4 <swapfs_write>
c01061c9:	85 c0                	test   %eax,%eax
c01061cb:	74 34                	je     c0106201 <swap_out+0x100>
                    cprintf("SWAP: failed to save\n");
c01061cd:	c7 04 24 0f a0 10 c0 	movl   $0xc010a00f,(%esp)
c01061d4:	e8 7e a1 ff ff       	call   c0100357 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c01061d9:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c01061de:	8b 40 10             	mov    0x10(%eax),%eax
c01061e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01061e4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01061eb:	00 
c01061ec:	89 54 24 08          	mov    %edx,0x8(%esp)
c01061f0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01061f3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01061f7:	8b 55 08             	mov    0x8(%ebp),%edx
c01061fa:	89 14 24             	mov    %edx,(%esp)
c01061fd:	ff d0                	call   *%eax
c01061ff:	eb 68                	jmp    c0106269 <swap_out+0x168>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0106201:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106204:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106207:	c1 e8 0c             	shr    $0xc,%eax
c010620a:	83 c0 01             	add    $0x1,%eax
c010620d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106211:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106214:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106218:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010621b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010621f:	c7 04 24 28 a0 10 c0 	movl   $0xc010a028,(%esp)
c0106226:	e8 2c a1 ff ff       	call   c0100357 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c010622b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010622e:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106231:	c1 e8 0c             	shr    $0xc,%eax
c0106234:	83 c0 01             	add    $0x1,%eax
c0106237:	c1 e0 08             	shl    $0x8,%eax
c010623a:	89 c2                	mov    %eax,%edx
c010623c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010623f:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0106241:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106244:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010624b:	00 
c010624c:	89 04 24             	mov    %eax,(%esp)
c010624f:	e8 a5 e4 ff ff       	call   c01046f9 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0106254:	8b 45 08             	mov    0x8(%ebp),%eax
c0106257:	8b 40 0c             	mov    0xc(%eax),%eax
c010625a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010625d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106261:	89 04 24             	mov    %eax,(%esp)
c0106264:	e8 f3 ed ff ff       	call   c010505c <tlb_invalidate>

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c0106269:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010626d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106270:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106273:	0f 85 9a fe ff ff    	jne    c0106113 <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c0106279:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010627c:	c9                   	leave  
c010627d:	c3                   	ret    

c010627e <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c010627e:	55                   	push   %ebp
c010627f:	89 e5                	mov    %esp,%ebp
c0106281:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0106284:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010628b:	e8 fe e3 ff ff       	call   c010468e <alloc_pages>
c0106290:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0106293:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106297:	75 24                	jne    c01062bd <swap_in+0x3f>
c0106299:	c7 44 24 0c 68 a0 10 	movl   $0xc010a068,0xc(%esp)
c01062a0:	c0 
c01062a1:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c01062a8:	c0 
c01062a9:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
c01062b0:	00 
c01062b1:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c01062b8:	e8 6a a9 ff ff       	call   c0100c27 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c01062bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01062c0:	8b 40 0c             	mov    0xc(%eax),%eax
c01062c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01062ca:	00 
c01062cb:	8b 55 0c             	mov    0xc(%ebp),%edx
c01062ce:	89 54 24 04          	mov    %edx,0x4(%esp)
c01062d2:	89 04 24             	mov    %eax,(%esp)
c01062d5:	e8 93 ea ff ff       	call   c0104d6d <get_pte>
c01062da:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c01062dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01062e0:	8b 00                	mov    (%eax),%eax
c01062e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01062e5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01062e9:	89 04 24             	mov    %eax,(%esp)
c01062ec:	e8 41 1c 00 00       	call   c0107f32 <swapfs_read>
c01062f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01062f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01062f8:	74 2a                	je     c0106324 <swap_in+0xa6>
     {
        assert(r!=0);
c01062fa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01062fe:	75 24                	jne    c0106324 <swap_in+0xa6>
c0106300:	c7 44 24 0c 75 a0 10 	movl   $0xc010a075,0xc(%esp)
c0106307:	c0 
c0106308:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c010630f:	c0 
c0106310:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c0106317:	00 
c0106318:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c010631f:	e8 03 a9 ff ff       	call   c0100c27 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0106324:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106327:	8b 00                	mov    (%eax),%eax
c0106329:	c1 e8 08             	shr    $0x8,%eax
c010632c:	89 c2                	mov    %eax,%edx
c010632e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106331:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106335:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106339:	c7 04 24 7c a0 10 c0 	movl   $0xc010a07c,(%esp)
c0106340:	e8 12 a0 ff ff       	call   c0100357 <cprintf>
     *ptr_result=result;
c0106345:	8b 45 10             	mov    0x10(%ebp),%eax
c0106348:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010634b:	89 10                	mov    %edx,(%eax)
     return 0;
c010634d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106352:	c9                   	leave  
c0106353:	c3                   	ret    

c0106354 <check_content_set>:



static inline void
check_content_set(void)
{
c0106354:	55                   	push   %ebp
c0106355:	89 e5                	mov    %esp,%ebp
c0106357:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c010635a:	b8 00 10 00 00       	mov    $0x1000,%eax
c010635f:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106362:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106367:	83 f8 01             	cmp    $0x1,%eax
c010636a:	74 24                	je     c0106390 <check_content_set+0x3c>
c010636c:	c7 44 24 0c ba a0 10 	movl   $0xc010a0ba,0xc(%esp)
c0106373:	c0 
c0106374:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c010637b:	c0 
c010637c:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c0106383:	00 
c0106384:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c010638b:	e8 97 a8 ff ff       	call   c0100c27 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0106390:	b8 10 10 00 00       	mov    $0x1010,%eax
c0106395:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106398:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c010639d:	83 f8 01             	cmp    $0x1,%eax
c01063a0:	74 24                	je     c01063c6 <check_content_set+0x72>
c01063a2:	c7 44 24 0c ba a0 10 	movl   $0xc010a0ba,0xc(%esp)
c01063a9:	c0 
c01063aa:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c01063b1:	c0 
c01063b2:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c01063b9:	00 
c01063ba:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c01063c1:	e8 61 a8 ff ff       	call   c0100c27 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c01063c6:	b8 00 20 00 00       	mov    $0x2000,%eax
c01063cb:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c01063ce:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c01063d3:	83 f8 02             	cmp    $0x2,%eax
c01063d6:	74 24                	je     c01063fc <check_content_set+0xa8>
c01063d8:	c7 44 24 0c c9 a0 10 	movl   $0xc010a0c9,0xc(%esp)
c01063df:	c0 
c01063e0:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c01063e7:	c0 
c01063e8:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c01063ef:	00 
c01063f0:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c01063f7:	e8 2b a8 ff ff       	call   c0100c27 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c01063fc:	b8 10 20 00 00       	mov    $0x2010,%eax
c0106401:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106404:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106409:	83 f8 02             	cmp    $0x2,%eax
c010640c:	74 24                	je     c0106432 <check_content_set+0xde>
c010640e:	c7 44 24 0c c9 a0 10 	movl   $0xc010a0c9,0xc(%esp)
c0106415:	c0 
c0106416:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c010641d:	c0 
c010641e:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0106425:	00 
c0106426:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c010642d:	e8 f5 a7 ff ff       	call   c0100c27 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0106432:	b8 00 30 00 00       	mov    $0x3000,%eax
c0106437:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c010643a:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c010643f:	83 f8 03             	cmp    $0x3,%eax
c0106442:	74 24                	je     c0106468 <check_content_set+0x114>
c0106444:	c7 44 24 0c d8 a0 10 	movl   $0xc010a0d8,0xc(%esp)
c010644b:	c0 
c010644c:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c0106453:	c0 
c0106454:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c010645b:	00 
c010645c:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c0106463:	e8 bf a7 ff ff       	call   c0100c27 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0106468:	b8 10 30 00 00       	mov    $0x3010,%eax
c010646d:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106470:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106475:	83 f8 03             	cmp    $0x3,%eax
c0106478:	74 24                	je     c010649e <check_content_set+0x14a>
c010647a:	c7 44 24 0c d8 a0 10 	movl   $0xc010a0d8,0xc(%esp)
c0106481:	c0 
c0106482:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c0106489:	c0 
c010648a:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0106491:	00 
c0106492:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c0106499:	e8 89 a7 ff ff       	call   c0100c27 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c010649e:	b8 00 40 00 00       	mov    $0x4000,%eax
c01064a3:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01064a6:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c01064ab:	83 f8 04             	cmp    $0x4,%eax
c01064ae:	74 24                	je     c01064d4 <check_content_set+0x180>
c01064b0:	c7 44 24 0c e7 a0 10 	movl   $0xc010a0e7,0xc(%esp)
c01064b7:	c0 
c01064b8:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c01064bf:	c0 
c01064c0:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c01064c7:	00 
c01064c8:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c01064cf:	e8 53 a7 ff ff       	call   c0100c27 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c01064d4:	b8 10 40 00 00       	mov    $0x4010,%eax
c01064d9:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01064dc:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c01064e1:	83 f8 04             	cmp    $0x4,%eax
c01064e4:	74 24                	je     c010650a <check_content_set+0x1b6>
c01064e6:	c7 44 24 0c e7 a0 10 	movl   $0xc010a0e7,0xc(%esp)
c01064ed:	c0 
c01064ee:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c01064f5:	c0 
c01064f6:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c01064fd:	00 
c01064fe:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c0106505:	e8 1d a7 ff ff       	call   c0100c27 <__panic>
}
c010650a:	c9                   	leave  
c010650b:	c3                   	ret    

c010650c <check_content_access>:

static inline int
check_content_access(void)
{
c010650c:	55                   	push   %ebp
c010650d:	89 e5                	mov    %esp,%ebp
c010650f:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0106512:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c0106517:	8b 40 1c             	mov    0x1c(%eax),%eax
c010651a:	ff d0                	call   *%eax
c010651c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c010651f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106522:	c9                   	leave  
c0106523:	c3                   	ret    

c0106524 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0106524:	55                   	push   %ebp
c0106525:	89 e5                	mov    %esp,%ebp
c0106527:	53                   	push   %ebx
c0106528:	83 ec 74             	sub    $0x74,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c010652b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106532:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0106539:	c7 45 e8 40 40 12 c0 	movl   $0xc0124040,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106540:	eb 6b                	jmp    c01065ad <check_swap+0x89>
        struct Page *p = le2page(le, page_link);
c0106542:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106545:	83 e8 0c             	sub    $0xc,%eax
c0106548:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c010654b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010654e:	83 c0 04             	add    $0x4,%eax
c0106551:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0106558:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010655b:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010655e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106561:	0f a3 10             	bt     %edx,(%eax)
c0106564:	19 c0                	sbb    %eax,%eax
c0106566:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0106569:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010656d:	0f 95 c0             	setne  %al
c0106570:	0f b6 c0             	movzbl %al,%eax
c0106573:	85 c0                	test   %eax,%eax
c0106575:	75 24                	jne    c010659b <check_swap+0x77>
c0106577:	c7 44 24 0c f6 a0 10 	movl   $0xc010a0f6,0xc(%esp)
c010657e:	c0 
c010657f:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c0106586:	c0 
c0106587:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c010658e:	00 
c010658f:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c0106596:	e8 8c a6 ff ff       	call   c0100c27 <__panic>
        count ++, total += p->property;
c010659b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010659f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01065a2:	8b 50 08             	mov    0x8(%eax),%edx
c01065a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065a8:	01 d0                	add    %edx,%eax
c01065aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01065ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01065b0:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01065b3:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01065b6:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c01065b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01065bc:	81 7d e8 40 40 12 c0 	cmpl   $0xc0124040,-0x18(%ebp)
c01065c3:	0f 85 79 ff ff ff    	jne    c0106542 <check_swap+0x1e>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c01065c9:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c01065cc:	e8 5a e1 ff ff       	call   c010472b <nr_free_pages>
c01065d1:	39 c3                	cmp    %eax,%ebx
c01065d3:	74 24                	je     c01065f9 <check_swap+0xd5>
c01065d5:	c7 44 24 0c 06 a1 10 	movl   $0xc010a106,0xc(%esp)
c01065dc:	c0 
c01065dd:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c01065e4:	c0 
c01065e5:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c01065ec:	00 
c01065ed:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c01065f4:	e8 2e a6 ff ff       	call   c0100c27 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c01065f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065fc:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106600:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106603:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106607:	c7 04 24 20 a1 10 c0 	movl   $0xc010a120,(%esp)
c010660e:	e8 44 9d ff ff       	call   c0100357 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0106613:	e8 13 0b 00 00       	call   c010712b <mm_create>
c0106618:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(mm != NULL);
c010661b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010661f:	75 24                	jne    c0106645 <check_swap+0x121>
c0106621:	c7 44 24 0c 46 a1 10 	movl   $0xc010a146,0xc(%esp)
c0106628:	c0 
c0106629:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c0106630:	c0 
c0106631:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c0106638:	00 
c0106639:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c0106640:	e8 e2 a5 ff ff       	call   c0100c27 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0106645:	a1 2c 41 12 c0       	mov    0xc012412c,%eax
c010664a:	85 c0                	test   %eax,%eax
c010664c:	74 24                	je     c0106672 <check_swap+0x14e>
c010664e:	c7 44 24 0c 51 a1 10 	movl   $0xc010a151,0xc(%esp)
c0106655:	c0 
c0106656:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c010665d:	c0 
c010665e:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c0106665:	00 
c0106666:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c010666d:	e8 b5 a5 ff ff       	call   c0100c27 <__panic>

     check_mm_struct = mm;
c0106672:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106675:	a3 2c 41 12 c0       	mov    %eax,0xc012412c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c010667a:	8b 15 e0 09 12 c0    	mov    0xc01209e0,%edx
c0106680:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106683:	89 50 0c             	mov    %edx,0xc(%eax)
c0106686:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106689:	8b 40 0c             	mov    0xc(%eax),%eax
c010668c:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(pgdir[0] == 0);
c010668f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106692:	8b 00                	mov    (%eax),%eax
c0106694:	85 c0                	test   %eax,%eax
c0106696:	74 24                	je     c01066bc <check_swap+0x198>
c0106698:	c7 44 24 0c 69 a1 10 	movl   $0xc010a169,0xc(%esp)
c010669f:	c0 
c01066a0:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c01066a7:	c0 
c01066a8:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c01066af:	00 
c01066b0:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c01066b7:	e8 6b a5 ff ff       	call   c0100c27 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c01066bc:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c01066c3:	00 
c01066c4:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c01066cb:	00 
c01066cc:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c01066d3:	e8 cb 0a 00 00       	call   c01071a3 <vma_create>
c01066d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(vma != NULL);
c01066db:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01066df:	75 24                	jne    c0106705 <check_swap+0x1e1>
c01066e1:	c7 44 24 0c 77 a1 10 	movl   $0xc010a177,0xc(%esp)
c01066e8:	c0 
c01066e9:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c01066f0:	c0 
c01066f1:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c01066f8:	00 
c01066f9:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c0106700:	e8 22 a5 ff ff       	call   c0100c27 <__panic>

     insert_vma_struct(mm, vma);
c0106705:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106708:	89 44 24 04          	mov    %eax,0x4(%esp)
c010670c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010670f:	89 04 24             	mov    %eax,(%esp)
c0106712:	e8 1c 0c 00 00       	call   c0107333 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0106717:	c7 04 24 84 a1 10 c0 	movl   $0xc010a184,(%esp)
c010671e:	e8 34 9c ff ff       	call   c0100357 <cprintf>
     pte_t *temp_ptep=NULL;
c0106723:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c010672a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010672d:	8b 40 0c             	mov    0xc(%eax),%eax
c0106730:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0106737:	00 
c0106738:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010673f:	00 
c0106740:	89 04 24             	mov    %eax,(%esp)
c0106743:	e8 25 e6 ff ff       	call   c0104d6d <get_pte>
c0106748:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(temp_ptep!= NULL);
c010674b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c010674f:	75 24                	jne    c0106775 <check_swap+0x251>
c0106751:	c7 44 24 0c b8 a1 10 	movl   $0xc010a1b8,0xc(%esp)
c0106758:	c0 
c0106759:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c0106760:	c0 
c0106761:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0106768:	00 
c0106769:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c0106770:	e8 b2 a4 ff ff       	call   c0100c27 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0106775:	c7 04 24 cc a1 10 c0 	movl   $0xc010a1cc,(%esp)
c010677c:	e8 d6 9b ff ff       	call   c0100357 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106781:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106788:	e9 a3 00 00 00       	jmp    c0106830 <check_swap+0x30c>
          check_rp[i] = alloc_page();
c010678d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106794:	e8 f5 de ff ff       	call   c010468e <alloc_pages>
c0106799:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010679c:	89 04 95 60 40 12 c0 	mov    %eax,-0x3fedbfa0(,%edx,4)
          assert(check_rp[i] != NULL );
c01067a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01067a6:	8b 04 85 60 40 12 c0 	mov    -0x3fedbfa0(,%eax,4),%eax
c01067ad:	85 c0                	test   %eax,%eax
c01067af:	75 24                	jne    c01067d5 <check_swap+0x2b1>
c01067b1:	c7 44 24 0c f0 a1 10 	movl   $0xc010a1f0,0xc(%esp)
c01067b8:	c0 
c01067b9:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c01067c0:	c0 
c01067c1:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c01067c8:	00 
c01067c9:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c01067d0:	e8 52 a4 ff ff       	call   c0100c27 <__panic>
          assert(!PageProperty(check_rp[i]));
c01067d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01067d8:	8b 04 85 60 40 12 c0 	mov    -0x3fedbfa0(,%eax,4),%eax
c01067df:	83 c0 04             	add    $0x4,%eax
c01067e2:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c01067e9:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01067ec:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01067ef:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01067f2:	0f a3 10             	bt     %edx,(%eax)
c01067f5:	19 c0                	sbb    %eax,%eax
c01067f7:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c01067fa:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c01067fe:	0f 95 c0             	setne  %al
c0106801:	0f b6 c0             	movzbl %al,%eax
c0106804:	85 c0                	test   %eax,%eax
c0106806:	74 24                	je     c010682c <check_swap+0x308>
c0106808:	c7 44 24 0c 04 a2 10 	movl   $0xc010a204,0xc(%esp)
c010680f:	c0 
c0106810:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c0106817:	c0 
c0106818:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c010681f:	00 
c0106820:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c0106827:	e8 fb a3 ff ff       	call   c0100c27 <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010682c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0106830:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106834:	0f 8e 53 ff ff ff    	jle    c010678d <check_swap+0x269>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c010683a:	a1 40 40 12 c0       	mov    0xc0124040,%eax
c010683f:	8b 15 44 40 12 c0    	mov    0xc0124044,%edx
c0106845:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106848:	89 55 9c             	mov    %edx,-0x64(%ebp)
c010684b:	c7 45 a8 40 40 12 c0 	movl   $0xc0124040,-0x58(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0106852:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106855:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0106858:	89 50 04             	mov    %edx,0x4(%eax)
c010685b:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010685e:	8b 50 04             	mov    0x4(%eax),%edx
c0106861:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106864:	89 10                	mov    %edx,(%eax)
c0106866:	c7 45 a4 40 40 12 c0 	movl   $0xc0124040,-0x5c(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c010686d:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106870:	8b 40 04             	mov    0x4(%eax),%eax
c0106873:	39 45 a4             	cmp    %eax,-0x5c(%ebp)
c0106876:	0f 94 c0             	sete   %al
c0106879:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c010687c:	85 c0                	test   %eax,%eax
c010687e:	75 24                	jne    c01068a4 <check_swap+0x380>
c0106880:	c7 44 24 0c 1f a2 10 	movl   $0xc010a21f,0xc(%esp)
c0106887:	c0 
c0106888:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c010688f:	c0 
c0106890:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0106897:	00 
c0106898:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c010689f:	e8 83 a3 ff ff       	call   c0100c27 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c01068a4:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c01068a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
     nr_free = 0;
c01068ac:	c7 05 48 40 12 c0 00 	movl   $0x0,0xc0124048
c01068b3:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01068b6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01068bd:	eb 1e                	jmp    c01068dd <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c01068bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01068c2:	8b 04 85 60 40 12 c0 	mov    -0x3fedbfa0(,%eax,4),%eax
c01068c9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01068d0:	00 
c01068d1:	89 04 24             	mov    %eax,(%esp)
c01068d4:	e8 20 de ff ff       	call   c01046f9 <free_pages>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01068d9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01068dd:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01068e1:	7e dc                	jle    c01068bf <check_swap+0x39b>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c01068e3:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c01068e8:	83 f8 04             	cmp    $0x4,%eax
c01068eb:	74 24                	je     c0106911 <check_swap+0x3ed>
c01068ed:	c7 44 24 0c 38 a2 10 	movl   $0xc010a238,0xc(%esp)
c01068f4:	c0 
c01068f5:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c01068fc:	c0 
c01068fd:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0106904:	00 
c0106905:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c010690c:	e8 16 a3 ff ff       	call   c0100c27 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0106911:	c7 04 24 5c a2 10 c0 	movl   $0xc010a25c,(%esp)
c0106918:	e8 3a 9a ff ff       	call   c0100357 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c010691d:	c7 05 38 40 12 c0 00 	movl   $0x0,0xc0124038
c0106924:	00 00 00 
     
     check_content_set();
c0106927:	e8 28 fa ff ff       	call   c0106354 <check_content_set>
     assert( nr_free == 0);         
c010692c:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c0106931:	85 c0                	test   %eax,%eax
c0106933:	74 24                	je     c0106959 <check_swap+0x435>
c0106935:	c7 44 24 0c 83 a2 10 	movl   $0xc010a283,0xc(%esp)
c010693c:	c0 
c010693d:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c0106944:	c0 
c0106945:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c010694c:	00 
c010694d:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c0106954:	e8 ce a2 ff ff       	call   c0100c27 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0106959:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106960:	eb 26                	jmp    c0106988 <check_swap+0x464>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0106962:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106965:	c7 04 85 80 40 12 c0 	movl   $0xffffffff,-0x3fedbf80(,%eax,4)
c010696c:	ff ff ff ff 
c0106970:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106973:	8b 14 85 80 40 12 c0 	mov    -0x3fedbf80(,%eax,4),%edx
c010697a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010697d:	89 14 85 c0 40 12 c0 	mov    %edx,-0x3fedbf40(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0106984:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0106988:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c010698c:	7e d4                	jle    c0106962 <check_swap+0x43e>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010698e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106995:	e9 eb 00 00 00       	jmp    c0106a85 <check_swap+0x561>
         check_ptep[i]=0;
c010699a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010699d:	c7 04 85 14 41 12 c0 	movl   $0x0,-0x3fedbeec(,%eax,4)
c01069a4:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c01069a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01069ab:	83 c0 01             	add    $0x1,%eax
c01069ae:	c1 e0 0c             	shl    $0xc,%eax
c01069b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01069b8:	00 
c01069b9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01069c0:	89 04 24             	mov    %eax,(%esp)
c01069c3:	e8 a5 e3 ff ff       	call   c0104d6d <get_pte>
c01069c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01069cb:	89 04 95 14 41 12 c0 	mov    %eax,-0x3fedbeec(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c01069d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01069d5:	8b 04 85 14 41 12 c0 	mov    -0x3fedbeec(,%eax,4),%eax
c01069dc:	85 c0                	test   %eax,%eax
c01069de:	75 24                	jne    c0106a04 <check_swap+0x4e0>
c01069e0:	c7 44 24 0c 90 a2 10 	movl   $0xc010a290,0xc(%esp)
c01069e7:	c0 
c01069e8:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c01069ef:	c0 
c01069f0:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c01069f7:	00 
c01069f8:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c01069ff:	e8 23 a2 ff ff       	call   c0100c27 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0106a04:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a07:	8b 04 85 14 41 12 c0 	mov    -0x3fedbeec(,%eax,4),%eax
c0106a0e:	8b 00                	mov    (%eax),%eax
c0106a10:	89 04 24             	mov    %eax,(%esp)
c0106a13:	e8 9f f5 ff ff       	call   c0105fb7 <pte2page>
c0106a18:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106a1b:	8b 14 95 60 40 12 c0 	mov    -0x3fedbfa0(,%edx,4),%edx
c0106a22:	39 d0                	cmp    %edx,%eax
c0106a24:	74 24                	je     c0106a4a <check_swap+0x526>
c0106a26:	c7 44 24 0c a8 a2 10 	movl   $0xc010a2a8,0xc(%esp)
c0106a2d:	c0 
c0106a2e:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c0106a35:	c0 
c0106a36:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0106a3d:	00 
c0106a3e:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c0106a45:	e8 dd a1 ff ff       	call   c0100c27 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0106a4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a4d:	8b 04 85 14 41 12 c0 	mov    -0x3fedbeec(,%eax,4),%eax
c0106a54:	8b 00                	mov    (%eax),%eax
c0106a56:	83 e0 01             	and    $0x1,%eax
c0106a59:	85 c0                	test   %eax,%eax
c0106a5b:	75 24                	jne    c0106a81 <check_swap+0x55d>
c0106a5d:	c7 44 24 0c d0 a2 10 	movl   $0xc010a2d0,0xc(%esp)
c0106a64:	c0 
c0106a65:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c0106a6c:	c0 
c0106a6d:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0106a74:	00 
c0106a75:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c0106a7c:	e8 a6 a1 ff ff       	call   c0100c27 <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106a81:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0106a85:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106a89:	0f 8e 0b ff ff ff    	jle    c010699a <check_swap+0x476>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c0106a8f:	c7 04 24 ec a2 10 c0 	movl   $0xc010a2ec,(%esp)
c0106a96:	e8 bc 98 ff ff       	call   c0100357 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0106a9b:	e8 6c fa ff ff       	call   c010650c <check_content_access>
c0106aa0:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(ret==0);
c0106aa3:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0106aa7:	74 24                	je     c0106acd <check_swap+0x5a9>
c0106aa9:	c7 44 24 0c 12 a3 10 	movl   $0xc010a312,0xc(%esp)
c0106ab0:	c0 
c0106ab1:	c7 44 24 08 fa 9f 10 	movl   $0xc0109ffa,0x8(%esp)
c0106ab8:	c0 
c0106ab9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0106ac0:	00 
c0106ac1:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c0106ac8:	e8 5a a1 ff ff       	call   c0100c27 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106acd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106ad4:	eb 1e                	jmp    c0106af4 <check_swap+0x5d0>
         free_pages(check_rp[i],1);
c0106ad6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ad9:	8b 04 85 60 40 12 c0 	mov    -0x3fedbfa0(,%eax,4),%eax
c0106ae0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106ae7:	00 
c0106ae8:	89 04 24             	mov    %eax,(%esp)
c0106aeb:	e8 09 dc ff ff       	call   c01046f9 <free_pages>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106af0:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0106af4:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106af8:	7e dc                	jle    c0106ad6 <check_swap+0x5b2>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0106afa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106afd:	89 04 24             	mov    %eax,(%esp)
c0106b00:	e8 5e 09 00 00       	call   c0107463 <mm_destroy>
         
     nr_free = nr_free_store;
c0106b05:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106b08:	a3 48 40 12 c0       	mov    %eax,0xc0124048
     free_list = free_list_store;
c0106b0d:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106b10:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0106b13:	a3 40 40 12 c0       	mov    %eax,0xc0124040
c0106b18:	89 15 44 40 12 c0    	mov    %edx,0xc0124044

     
     le = &free_list;
c0106b1e:	c7 45 e8 40 40 12 c0 	movl   $0xc0124040,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106b25:	eb 1d                	jmp    c0106b44 <check_swap+0x620>
         struct Page *p = le2page(le, page_link);
c0106b27:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106b2a:	83 e8 0c             	sub    $0xc,%eax
c0106b2d:	89 45 c8             	mov    %eax,-0x38(%ebp)
         count --, total -= p->property;
c0106b30:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0106b34:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106b37:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106b3a:	8b 40 08             	mov    0x8(%eax),%eax
c0106b3d:	29 c2                	sub    %eax,%edx
c0106b3f:	89 d0                	mov    %edx,%eax
c0106b41:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b44:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106b47:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0106b4a:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106b4d:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0106b50:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106b53:	81 7d e8 40 40 12 c0 	cmpl   $0xc0124040,-0x18(%ebp)
c0106b5a:	75 cb                	jne    c0106b27 <check_swap+0x603>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c0106b5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b5f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b66:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b6a:	c7 04 24 19 a3 10 c0 	movl   $0xc010a319,(%esp)
c0106b71:	e8 e1 97 ff ff       	call   c0100357 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0106b76:	c7 04 24 33 a3 10 c0 	movl   $0xc010a333,(%esp)
c0106b7d:	e8 d5 97 ff ff       	call   c0100357 <cprintf>
}
c0106b82:	83 c4 74             	add    $0x74,%esp
c0106b85:	5b                   	pop    %ebx
c0106b86:	5d                   	pop    %ebp
c0106b87:	c3                   	ret    

c0106b88 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0106b88:	55                   	push   %ebp
c0106b89:	89 e5                	mov    %esp,%ebp
c0106b8b:	83 ec 10             	sub    $0x10,%esp
c0106b8e:	c7 45 fc 24 41 12 c0 	movl   $0xc0124124,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0106b95:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106b98:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0106b9b:	89 50 04             	mov    %edx,0x4(%eax)
c0106b9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106ba1:	8b 50 04             	mov    0x4(%eax),%edx
c0106ba4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106ba7:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0106ba9:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bac:	c7 40 14 24 41 12 c0 	movl   $0xc0124124,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0106bb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106bb8:	c9                   	leave  
c0106bb9:	c3                   	ret    

c0106bba <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0106bba:	55                   	push   %ebp
c0106bbb:	89 e5                	mov    %esp,%ebp
c0106bbd:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0106bc0:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bc3:	8b 40 14             	mov    0x14(%eax),%eax
c0106bc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0106bc9:	8b 45 10             	mov    0x10(%ebp),%eax
c0106bcc:	83 c0 14             	add    $0x14,%eax
c0106bcf:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0106bd2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106bd6:	74 06                	je     c0106bde <_fifo_map_swappable+0x24>
c0106bd8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106bdc:	75 24                	jne    c0106c02 <_fifo_map_swappable+0x48>
c0106bde:	c7 44 24 0c 4c a3 10 	movl   $0xc010a34c,0xc(%esp)
c0106be5:	c0 
c0106be6:	c7 44 24 08 6a a3 10 	movl   $0xc010a36a,0x8(%esp)
c0106bed:	c0 
c0106bee:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0106bf5:	00 
c0106bf6:	c7 04 24 7f a3 10 c0 	movl   $0xc010a37f,(%esp)
c0106bfd:	e8 25 a0 ff ff       	call   c0100c27 <__panic>
c0106c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c05:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c0b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106c0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106c14:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106c17:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0106c1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106c1d:	8b 40 04             	mov    0x4(%eax),%eax
c0106c20:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106c23:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0106c26:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106c29:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0106c2c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0106c2f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106c32:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106c35:	89 10                	mov    %edx,(%eax)
c0106c37:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106c3a:	8b 10                	mov    (%eax),%edx
c0106c3c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106c3f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106c42:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106c45:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106c48:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106c4b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106c4e:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106c51:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c0106c53:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106c58:	c9                   	leave  
c0106c59:	c3                   	ret    

c0106c5a <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0106c5a:	55                   	push   %ebp
c0106c5b:	89 e5                	mov    %esp,%ebp
c0106c5d:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0106c60:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c63:	8b 40 14             	mov    0x14(%eax),%eax
c0106c66:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0106c69:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106c6d:	75 24                	jne    c0106c93 <_fifo_swap_out_victim+0x39>
c0106c6f:	c7 44 24 0c 93 a3 10 	movl   $0xc010a393,0xc(%esp)
c0106c76:	c0 
c0106c77:	c7 44 24 08 6a a3 10 	movl   $0xc010a36a,0x8(%esp)
c0106c7e:	c0 
c0106c7f:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0106c86:	00 
c0106c87:	c7 04 24 7f a3 10 c0 	movl   $0xc010a37f,(%esp)
c0106c8e:	e8 94 9f ff ff       	call   c0100c27 <__panic>
     assert(in_tick==0);
c0106c93:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106c97:	74 24                	je     c0106cbd <_fifo_swap_out_victim+0x63>
c0106c99:	c7 44 24 0c a0 a3 10 	movl   $0xc010a3a0,0xc(%esp)
c0106ca0:	c0 
c0106ca1:	c7 44 24 08 6a a3 10 	movl   $0xc010a36a,0x8(%esp)
c0106ca8:	c0 
c0106ca9:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c0106cb0:	00 
c0106cb1:	c7 04 24 7f a3 10 c0 	movl   $0xc010a37f,(%esp)
c0106cb8:	e8 6a 9f ff ff       	call   c0100c27 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     /* Select the tail */
     list_entry_t *le = head->prev;
c0106cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cc0:	8b 00                	mov    (%eax),%eax
c0106cc2:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c0106cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cc8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0106ccb:	75 24                	jne    c0106cf1 <_fifo_swap_out_victim+0x97>
c0106ccd:	c7 44 24 0c ab a3 10 	movl   $0xc010a3ab,0xc(%esp)
c0106cd4:	c0 
c0106cd5:	c7 44 24 08 6a a3 10 	movl   $0xc010a36a,0x8(%esp)
c0106cdc:	c0 
c0106cdd:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c0106ce4:	00 
c0106ce5:	c7 04 24 7f a3 10 c0 	movl   $0xc010a37f,(%esp)
c0106cec:	e8 36 9f ff ff       	call   c0100c27 <__panic>
     struct Page *p = le2page(le, pra_page_link);
c0106cf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106cf4:	83 e8 14             	sub    $0x14,%eax
c0106cf7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106cfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106cfd:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0106d00:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106d03:	8b 40 04             	mov    0x4(%eax),%eax
c0106d06:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106d09:	8b 12                	mov    (%edx),%edx
c0106d0b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0106d0e:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0106d11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106d14:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106d17:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106d1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106d1d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106d20:	89 10                	mov    %edx,(%eax)
     list_del(le);
     assert(p !=NULL);
c0106d22:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106d26:	75 24                	jne    c0106d4c <_fifo_swap_out_victim+0xf2>
c0106d28:	c7 44 24 0c b4 a3 10 	movl   $0xc010a3b4,0xc(%esp)
c0106d2f:	c0 
c0106d30:	c7 44 24 08 6a a3 10 	movl   $0xc010a36a,0x8(%esp)
c0106d37:	c0 
c0106d38:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
c0106d3f:	00 
c0106d40:	c7 04 24 7f a3 10 c0 	movl   $0xc010a37f,(%esp)
c0106d47:	e8 db 9e ff ff       	call   c0100c27 <__panic>
     *ptr_page = p;
c0106d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d4f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106d52:	89 10                	mov    %edx,(%eax)
     return 0;
c0106d54:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106d59:	c9                   	leave  
c0106d5a:	c3                   	ret    

c0106d5b <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0106d5b:	55                   	push   %ebp
c0106d5c:	89 e5                	mov    %esp,%ebp
c0106d5e:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0106d61:	c7 04 24 c0 a3 10 c0 	movl   $0xc010a3c0,(%esp)
c0106d68:	e8 ea 95 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0106d6d:	b8 00 30 00 00       	mov    $0x3000,%eax
c0106d72:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0106d75:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106d7a:	83 f8 04             	cmp    $0x4,%eax
c0106d7d:	74 24                	je     c0106da3 <_fifo_check_swap+0x48>
c0106d7f:	c7 44 24 0c e6 a3 10 	movl   $0xc010a3e6,0xc(%esp)
c0106d86:	c0 
c0106d87:	c7 44 24 08 6a a3 10 	movl   $0xc010a36a,0x8(%esp)
c0106d8e:	c0 
c0106d8f:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
c0106d96:	00 
c0106d97:	c7 04 24 7f a3 10 c0 	movl   $0xc010a37f,(%esp)
c0106d9e:	e8 84 9e ff ff       	call   c0100c27 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0106da3:	c7 04 24 f8 a3 10 c0 	movl   $0xc010a3f8,(%esp)
c0106daa:	e8 a8 95 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0106daf:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106db4:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0106db7:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106dbc:	83 f8 04             	cmp    $0x4,%eax
c0106dbf:	74 24                	je     c0106de5 <_fifo_check_swap+0x8a>
c0106dc1:	c7 44 24 0c e6 a3 10 	movl   $0xc010a3e6,0xc(%esp)
c0106dc8:	c0 
c0106dc9:	c7 44 24 08 6a a3 10 	movl   $0xc010a36a,0x8(%esp)
c0106dd0:	c0 
c0106dd1:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
c0106dd8:	00 
c0106dd9:	c7 04 24 7f a3 10 c0 	movl   $0xc010a37f,(%esp)
c0106de0:	e8 42 9e ff ff       	call   c0100c27 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0106de5:	c7 04 24 20 a4 10 c0 	movl   $0xc010a420,(%esp)
c0106dec:	e8 66 95 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0106df1:	b8 00 40 00 00       	mov    $0x4000,%eax
c0106df6:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0106df9:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106dfe:	83 f8 04             	cmp    $0x4,%eax
c0106e01:	74 24                	je     c0106e27 <_fifo_check_swap+0xcc>
c0106e03:	c7 44 24 0c e6 a3 10 	movl   $0xc010a3e6,0xc(%esp)
c0106e0a:	c0 
c0106e0b:	c7 44 24 08 6a a3 10 	movl   $0xc010a36a,0x8(%esp)
c0106e12:	c0 
c0106e13:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0106e1a:	00 
c0106e1b:	c7 04 24 7f a3 10 c0 	movl   $0xc010a37f,(%esp)
c0106e22:	e8 00 9e ff ff       	call   c0100c27 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0106e27:	c7 04 24 48 a4 10 c0 	movl   $0xc010a448,(%esp)
c0106e2e:	e8 24 95 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0106e33:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106e38:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0106e3b:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106e40:	83 f8 04             	cmp    $0x4,%eax
c0106e43:	74 24                	je     c0106e69 <_fifo_check_swap+0x10e>
c0106e45:	c7 44 24 0c e6 a3 10 	movl   $0xc010a3e6,0xc(%esp)
c0106e4c:	c0 
c0106e4d:	c7 44 24 08 6a a3 10 	movl   $0xc010a36a,0x8(%esp)
c0106e54:	c0 
c0106e55:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0106e5c:	00 
c0106e5d:	c7 04 24 7f a3 10 c0 	movl   $0xc010a37f,(%esp)
c0106e64:	e8 be 9d ff ff       	call   c0100c27 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0106e69:	c7 04 24 70 a4 10 c0 	movl   $0xc010a470,(%esp)
c0106e70:	e8 e2 94 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0106e75:	b8 00 50 00 00       	mov    $0x5000,%eax
c0106e7a:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0106e7d:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106e82:	83 f8 05             	cmp    $0x5,%eax
c0106e85:	74 24                	je     c0106eab <_fifo_check_swap+0x150>
c0106e87:	c7 44 24 0c 96 a4 10 	movl   $0xc010a496,0xc(%esp)
c0106e8e:	c0 
c0106e8f:	c7 44 24 08 6a a3 10 	movl   $0xc010a36a,0x8(%esp)
c0106e96:	c0 
c0106e97:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0106e9e:	00 
c0106e9f:	c7 04 24 7f a3 10 c0 	movl   $0xc010a37f,(%esp)
c0106ea6:	e8 7c 9d ff ff       	call   c0100c27 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0106eab:	c7 04 24 48 a4 10 c0 	movl   $0xc010a448,(%esp)
c0106eb2:	e8 a0 94 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0106eb7:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106ebc:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0106ebf:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106ec4:	83 f8 05             	cmp    $0x5,%eax
c0106ec7:	74 24                	je     c0106eed <_fifo_check_swap+0x192>
c0106ec9:	c7 44 24 0c 96 a4 10 	movl   $0xc010a496,0xc(%esp)
c0106ed0:	c0 
c0106ed1:	c7 44 24 08 6a a3 10 	movl   $0xc010a36a,0x8(%esp)
c0106ed8:	c0 
c0106ed9:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0106ee0:	00 
c0106ee1:	c7 04 24 7f a3 10 c0 	movl   $0xc010a37f,(%esp)
c0106ee8:	e8 3a 9d ff ff       	call   c0100c27 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0106eed:	c7 04 24 f8 a3 10 c0 	movl   $0xc010a3f8,(%esp)
c0106ef4:	e8 5e 94 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0106ef9:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106efe:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0106f01:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106f06:	83 f8 06             	cmp    $0x6,%eax
c0106f09:	74 24                	je     c0106f2f <_fifo_check_swap+0x1d4>
c0106f0b:	c7 44 24 0c a5 a4 10 	movl   $0xc010a4a5,0xc(%esp)
c0106f12:	c0 
c0106f13:	c7 44 24 08 6a a3 10 	movl   $0xc010a36a,0x8(%esp)
c0106f1a:	c0 
c0106f1b:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0106f22:	00 
c0106f23:	c7 04 24 7f a3 10 c0 	movl   $0xc010a37f,(%esp)
c0106f2a:	e8 f8 9c ff ff       	call   c0100c27 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0106f2f:	c7 04 24 48 a4 10 c0 	movl   $0xc010a448,(%esp)
c0106f36:	e8 1c 94 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0106f3b:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106f40:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0106f43:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106f48:	83 f8 07             	cmp    $0x7,%eax
c0106f4b:	74 24                	je     c0106f71 <_fifo_check_swap+0x216>
c0106f4d:	c7 44 24 0c b4 a4 10 	movl   $0xc010a4b4,0xc(%esp)
c0106f54:	c0 
c0106f55:	c7 44 24 08 6a a3 10 	movl   $0xc010a36a,0x8(%esp)
c0106f5c:	c0 
c0106f5d:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0106f64:	00 
c0106f65:	c7 04 24 7f a3 10 c0 	movl   $0xc010a37f,(%esp)
c0106f6c:	e8 b6 9c ff ff       	call   c0100c27 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0106f71:	c7 04 24 c0 a3 10 c0 	movl   $0xc010a3c0,(%esp)
c0106f78:	e8 da 93 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0106f7d:	b8 00 30 00 00       	mov    $0x3000,%eax
c0106f82:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0106f85:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106f8a:	83 f8 08             	cmp    $0x8,%eax
c0106f8d:	74 24                	je     c0106fb3 <_fifo_check_swap+0x258>
c0106f8f:	c7 44 24 0c c3 a4 10 	movl   $0xc010a4c3,0xc(%esp)
c0106f96:	c0 
c0106f97:	c7 44 24 08 6a a3 10 	movl   $0xc010a36a,0x8(%esp)
c0106f9e:	c0 
c0106f9f:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0106fa6:	00 
c0106fa7:	c7 04 24 7f a3 10 c0 	movl   $0xc010a37f,(%esp)
c0106fae:	e8 74 9c ff ff       	call   c0100c27 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0106fb3:	c7 04 24 20 a4 10 c0 	movl   $0xc010a420,(%esp)
c0106fba:	e8 98 93 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0106fbf:	b8 00 40 00 00       	mov    $0x4000,%eax
c0106fc4:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0106fc7:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106fcc:	83 f8 09             	cmp    $0x9,%eax
c0106fcf:	74 24                	je     c0106ff5 <_fifo_check_swap+0x29a>
c0106fd1:	c7 44 24 0c d2 a4 10 	movl   $0xc010a4d2,0xc(%esp)
c0106fd8:	c0 
c0106fd9:	c7 44 24 08 6a a3 10 	movl   $0xc010a36a,0x8(%esp)
c0106fe0:	c0 
c0106fe1:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0106fe8:	00 
c0106fe9:	c7 04 24 7f a3 10 c0 	movl   $0xc010a37f,(%esp)
c0106ff0:	e8 32 9c ff ff       	call   c0100c27 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0106ff5:	c7 04 24 70 a4 10 c0 	movl   $0xc010a470,(%esp)
c0106ffc:	e8 56 93 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107001:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107006:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c0107009:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c010700e:	83 f8 0a             	cmp    $0xa,%eax
c0107011:	74 24                	je     c0107037 <_fifo_check_swap+0x2dc>
c0107013:	c7 44 24 0c e1 a4 10 	movl   $0xc010a4e1,0xc(%esp)
c010701a:	c0 
c010701b:	c7 44 24 08 6a a3 10 	movl   $0xc010a36a,0x8(%esp)
c0107022:	c0 
c0107023:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c010702a:	00 
c010702b:	c7 04 24 7f a3 10 c0 	movl   $0xc010a37f,(%esp)
c0107032:	e8 f0 9b ff ff       	call   c0100c27 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107037:	c7 04 24 f8 a3 10 c0 	movl   $0xc010a3f8,(%esp)
c010703e:	e8 14 93 ff ff       	call   c0100357 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0107043:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107048:	0f b6 00             	movzbl (%eax),%eax
c010704b:	3c 0a                	cmp    $0xa,%al
c010704d:	74 24                	je     c0107073 <_fifo_check_swap+0x318>
c010704f:	c7 44 24 0c f4 a4 10 	movl   $0xc010a4f4,0xc(%esp)
c0107056:	c0 
c0107057:	c7 44 24 08 6a a3 10 	movl   $0xc010a36a,0x8(%esp)
c010705e:	c0 
c010705f:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
c0107066:	00 
c0107067:	c7 04 24 7f a3 10 c0 	movl   $0xc010a37f,(%esp)
c010706e:	e8 b4 9b ff ff       	call   c0100c27 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0107073:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107078:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c010707b:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0107080:	83 f8 0b             	cmp    $0xb,%eax
c0107083:	74 24                	je     c01070a9 <_fifo_check_swap+0x34e>
c0107085:	c7 44 24 0c 15 a5 10 	movl   $0xc010a515,0xc(%esp)
c010708c:	c0 
c010708d:	c7 44 24 08 6a a3 10 	movl   $0xc010a36a,0x8(%esp)
c0107094:	c0 
c0107095:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
c010709c:	00 
c010709d:	c7 04 24 7f a3 10 c0 	movl   $0xc010a37f,(%esp)
c01070a4:	e8 7e 9b ff ff       	call   c0100c27 <__panic>
    return 0;
c01070a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01070ae:	c9                   	leave  
c01070af:	c3                   	ret    

c01070b0 <_fifo_init>:


static int
_fifo_init(void)
{
c01070b0:	55                   	push   %ebp
c01070b1:	89 e5                	mov    %esp,%ebp
    return 0;
c01070b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01070b8:	5d                   	pop    %ebp
c01070b9:	c3                   	ret    

c01070ba <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01070ba:	55                   	push   %ebp
c01070bb:	89 e5                	mov    %esp,%ebp
    return 0;
c01070bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01070c2:	5d                   	pop    %ebp
c01070c3:	c3                   	ret    

c01070c4 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c01070c4:	55                   	push   %ebp
c01070c5:	89 e5                	mov    %esp,%ebp
c01070c7:	b8 00 00 00 00       	mov    $0x0,%eax
c01070cc:	5d                   	pop    %ebp
c01070cd:	c3                   	ret    

c01070ce <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c01070ce:	55                   	push   %ebp
c01070cf:	89 e5                	mov    %esp,%ebp
c01070d1:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01070d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01070d7:	c1 e8 0c             	shr    $0xc,%eax
c01070da:	89 c2                	mov    %eax,%edx
c01070dc:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c01070e1:	39 c2                	cmp    %eax,%edx
c01070e3:	72 1c                	jb     c0107101 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01070e5:	c7 44 24 08 38 a5 10 	movl   $0xc010a538,0x8(%esp)
c01070ec:	c0 
c01070ed:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c01070f4:	00 
c01070f5:	c7 04 24 57 a5 10 c0 	movl   $0xc010a557,(%esp)
c01070fc:	e8 26 9b ff ff       	call   c0100c27 <__panic>
    }
    return &pages[PPN(pa)];
c0107101:	a1 54 40 12 c0       	mov    0xc0124054,%eax
c0107106:	8b 55 08             	mov    0x8(%ebp),%edx
c0107109:	c1 ea 0c             	shr    $0xc,%edx
c010710c:	c1 e2 05             	shl    $0x5,%edx
c010710f:	01 d0                	add    %edx,%eax
}
c0107111:	c9                   	leave  
c0107112:	c3                   	ret    

c0107113 <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c0107113:	55                   	push   %ebp
c0107114:	89 e5                	mov    %esp,%ebp
c0107116:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0107119:	8b 45 08             	mov    0x8(%ebp),%eax
c010711c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107121:	89 04 24             	mov    %eax,(%esp)
c0107124:	e8 a5 ff ff ff       	call   c01070ce <pa2page>
}
c0107129:	c9                   	leave  
c010712a:	c3                   	ret    

c010712b <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c010712b:	55                   	push   %ebp
c010712c:	89 e5                	mov    %esp,%ebp
c010712e:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0107131:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0107138:	e8 fb ec ff ff       	call   c0105e38 <kmalloc>
c010713d:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0107140:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107144:	74 58                	je     c010719e <mm_create+0x73>
        list_init(&(mm->mmap_list));
c0107146:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107149:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010714c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010714f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107152:	89 50 04             	mov    %edx,0x4(%eax)
c0107155:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107158:	8b 50 04             	mov    0x4(%eax),%edx
c010715b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010715e:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c0107160:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107163:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c010716a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010716d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0107174:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107177:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c010717e:	a1 2c 40 12 c0       	mov    0xc012402c,%eax
c0107183:	85 c0                	test   %eax,%eax
c0107185:	74 0d                	je     c0107194 <mm_create+0x69>
c0107187:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010718a:	89 04 24             	mov    %eax,(%esp)
c010718d:	e8 f3 ee ff ff       	call   c0106085 <swap_init_mm>
c0107192:	eb 0a                	jmp    c010719e <mm_create+0x73>
        else mm->sm_priv = NULL;
c0107194:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107197:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c010719e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01071a1:	c9                   	leave  
c01071a2:	c3                   	ret    

c01071a3 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c01071a3:	55                   	push   %ebp
c01071a4:	89 e5                	mov    %esp,%ebp
c01071a6:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c01071a9:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c01071b0:	e8 83 ec ff ff       	call   c0105e38 <kmalloc>
c01071b5:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c01071b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01071bc:	74 1b                	je     c01071d9 <vma_create+0x36>
        vma->vm_start = vm_start;
c01071be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01071c1:	8b 55 08             	mov    0x8(%ebp),%edx
c01071c4:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c01071c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01071ca:	8b 55 0c             	mov    0xc(%ebp),%edx
c01071cd:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c01071d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01071d3:	8b 55 10             	mov    0x10(%ebp),%edx
c01071d6:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c01071d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01071dc:	c9                   	leave  
c01071dd:	c3                   	ret    

c01071de <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c01071de:	55                   	push   %ebp
c01071df:	89 e5                	mov    %esp,%ebp
c01071e1:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c01071e4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c01071eb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01071ef:	0f 84 95 00 00 00    	je     c010728a <find_vma+0xac>
        vma = mm->mmap_cache;
c01071f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01071f8:	8b 40 08             	mov    0x8(%eax),%eax
c01071fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c01071fe:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0107202:	74 16                	je     c010721a <find_vma+0x3c>
c0107204:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107207:	8b 40 04             	mov    0x4(%eax),%eax
c010720a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010720d:	77 0b                	ja     c010721a <find_vma+0x3c>
c010720f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107212:	8b 40 08             	mov    0x8(%eax),%eax
c0107215:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107218:	77 61                	ja     c010727b <find_vma+0x9d>
                bool found = 0;
c010721a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0107221:	8b 45 08             	mov    0x8(%ebp),%eax
c0107224:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107227:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010722a:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c010722d:	eb 28                	jmp    c0107257 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c010722f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107232:	83 e8 10             	sub    $0x10,%eax
c0107235:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0107238:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010723b:	8b 40 04             	mov    0x4(%eax),%eax
c010723e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107241:	77 14                	ja     c0107257 <find_vma+0x79>
c0107243:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107246:	8b 40 08             	mov    0x8(%eax),%eax
c0107249:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010724c:	76 09                	jbe    c0107257 <find_vma+0x79>
                        found = 1;
c010724e:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0107255:	eb 17                	jmp    c010726e <find_vma+0x90>
c0107257:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010725a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010725d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107260:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c0107263:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107266:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107269:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010726c:	75 c1                	jne    c010722f <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c010726e:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0107272:	75 07                	jne    c010727b <find_vma+0x9d>
                    vma = NULL;
c0107274:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c010727b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010727f:	74 09                	je     c010728a <find_vma+0xac>
            mm->mmap_cache = vma;
c0107281:	8b 45 08             	mov    0x8(%ebp),%eax
c0107284:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0107287:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c010728a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010728d:	c9                   	leave  
c010728e:	c3                   	ret    

c010728f <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c010728f:	55                   	push   %ebp
c0107290:	89 e5                	mov    %esp,%ebp
c0107292:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c0107295:	8b 45 08             	mov    0x8(%ebp),%eax
c0107298:	8b 50 04             	mov    0x4(%eax),%edx
c010729b:	8b 45 08             	mov    0x8(%ebp),%eax
c010729e:	8b 40 08             	mov    0x8(%eax),%eax
c01072a1:	39 c2                	cmp    %eax,%edx
c01072a3:	72 24                	jb     c01072c9 <check_vma_overlap+0x3a>
c01072a5:	c7 44 24 0c 65 a5 10 	movl   $0xc010a565,0xc(%esp)
c01072ac:	c0 
c01072ad:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c01072b4:	c0 
c01072b5:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c01072bc:	00 
c01072bd:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c01072c4:	e8 5e 99 ff ff       	call   c0100c27 <__panic>
    assert(prev->vm_end <= next->vm_start);
c01072c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01072cc:	8b 50 08             	mov    0x8(%eax),%edx
c01072cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01072d2:	8b 40 04             	mov    0x4(%eax),%eax
c01072d5:	39 c2                	cmp    %eax,%edx
c01072d7:	76 24                	jbe    c01072fd <check_vma_overlap+0x6e>
c01072d9:	c7 44 24 0c a8 a5 10 	movl   $0xc010a5a8,0xc(%esp)
c01072e0:	c0 
c01072e1:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c01072e8:	c0 
c01072e9:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c01072f0:	00 
c01072f1:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c01072f8:	e8 2a 99 ff ff       	call   c0100c27 <__panic>
    assert(next->vm_start < next->vm_end);
c01072fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107300:	8b 50 04             	mov    0x4(%eax),%edx
c0107303:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107306:	8b 40 08             	mov    0x8(%eax),%eax
c0107309:	39 c2                	cmp    %eax,%edx
c010730b:	72 24                	jb     c0107331 <check_vma_overlap+0xa2>
c010730d:	c7 44 24 0c c7 a5 10 	movl   $0xc010a5c7,0xc(%esp)
c0107314:	c0 
c0107315:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c010731c:	c0 
c010731d:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c0107324:	00 
c0107325:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c010732c:	e8 f6 98 ff ff       	call   c0100c27 <__panic>
}
c0107331:	c9                   	leave  
c0107332:	c3                   	ret    

c0107333 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0107333:	55                   	push   %ebp
c0107334:	89 e5                	mov    %esp,%ebp
c0107336:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0107339:	8b 45 0c             	mov    0xc(%ebp),%eax
c010733c:	8b 50 04             	mov    0x4(%eax),%edx
c010733f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107342:	8b 40 08             	mov    0x8(%eax),%eax
c0107345:	39 c2                	cmp    %eax,%edx
c0107347:	72 24                	jb     c010736d <insert_vma_struct+0x3a>
c0107349:	c7 44 24 0c e5 a5 10 	movl   $0xc010a5e5,0xc(%esp)
c0107350:	c0 
c0107351:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c0107358:	c0 
c0107359:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0107360:	00 
c0107361:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c0107368:	e8 ba 98 ff ff       	call   c0100c27 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c010736d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107370:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c0107373:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107376:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0107379:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010737c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c010737f:	eb 21                	jmp    c01073a2 <insert_vma_struct+0x6f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c0107381:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107384:	83 e8 10             	sub    $0x10,%eax
c0107387:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c010738a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010738d:	8b 50 04             	mov    0x4(%eax),%edx
c0107390:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107393:	8b 40 04             	mov    0x4(%eax),%eax
c0107396:	39 c2                	cmp    %eax,%edx
c0107398:	76 02                	jbe    c010739c <insert_vma_struct+0x69>
                break;
c010739a:	eb 1d                	jmp    c01073b9 <insert_vma_struct+0x86>
            }
            le_prev = le;
c010739c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010739f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01073a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01073a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01073a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01073ab:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c01073ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01073b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01073b4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01073b7:	75 c8                	jne    c0107381 <insert_vma_struct+0x4e>
c01073b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01073bc:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01073bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01073c2:	8b 40 04             	mov    0x4(%eax),%eax
                break;
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c01073c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c01073c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01073cb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01073ce:	74 15                	je     c01073e5 <insert_vma_struct+0xb2>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c01073d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01073d3:	8d 50 f0             	lea    -0x10(%eax),%edx
c01073d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01073d9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01073dd:	89 14 24             	mov    %edx,(%esp)
c01073e0:	e8 aa fe ff ff       	call   c010728f <check_vma_overlap>
    }
    if (le_next != list) {
c01073e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01073e8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01073eb:	74 15                	je     c0107402 <insert_vma_struct+0xcf>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c01073ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01073f0:	83 e8 10             	sub    $0x10,%eax
c01073f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01073f7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01073fa:	89 04 24             	mov    %eax,(%esp)
c01073fd:	e8 8d fe ff ff       	call   c010728f <check_vma_overlap>
    }

    vma->vm_mm = mm;
c0107402:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107405:	8b 55 08             	mov    0x8(%ebp),%edx
c0107408:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c010740a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010740d:	8d 50 10             	lea    0x10(%eax),%edx
c0107410:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107413:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0107416:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0107419:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010741c:	8b 40 04             	mov    0x4(%eax),%eax
c010741f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107422:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0107425:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107428:	89 55 cc             	mov    %edx,-0x34(%ebp)
c010742b:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010742e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107431:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107434:	89 10                	mov    %edx,(%eax)
c0107436:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107439:	8b 10                	mov    (%eax),%edx
c010743b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010743e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107441:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107444:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0107447:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010744a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010744d:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107450:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c0107452:	8b 45 08             	mov    0x8(%ebp),%eax
c0107455:	8b 40 10             	mov    0x10(%eax),%eax
c0107458:	8d 50 01             	lea    0x1(%eax),%edx
c010745b:	8b 45 08             	mov    0x8(%ebp),%eax
c010745e:	89 50 10             	mov    %edx,0x10(%eax)
}
c0107461:	c9                   	leave  
c0107462:	c3                   	ret    

c0107463 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0107463:	55                   	push   %ebp
c0107464:	89 e5                	mov    %esp,%ebp
c0107466:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c0107469:	8b 45 08             	mov    0x8(%ebp),%eax
c010746c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c010746f:	eb 3e                	jmp    c01074af <mm_destroy+0x4c>
c0107471:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107474:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0107477:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010747a:	8b 40 04             	mov    0x4(%eax),%eax
c010747d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107480:	8b 12                	mov    (%edx),%edx
c0107482:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0107485:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0107488:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010748b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010748e:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107491:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107494:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107497:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
c0107499:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010749c:	83 e8 10             	sub    $0x10,%eax
c010749f:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c01074a6:	00 
c01074a7:	89 04 24             	mov    %eax,(%esp)
c01074aa:	e8 29 ea ff ff       	call   c0105ed8 <kfree>
c01074af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01074b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01074b8:	8b 40 04             	mov    0x4(%eax),%eax
// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c01074bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01074be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01074c1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01074c4:	75 ab                	jne    c0107471 <mm_destroy+0xe>
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
c01074c6:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c01074cd:	00 
c01074ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01074d1:	89 04 24             	mov    %eax,(%esp)
c01074d4:	e8 ff e9 ff ff       	call   c0105ed8 <kfree>
    mm=NULL;
c01074d9:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c01074e0:	c9                   	leave  
c01074e1:	c3                   	ret    

c01074e2 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c01074e2:	55                   	push   %ebp
c01074e3:	89 e5                	mov    %esp,%ebp
c01074e5:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c01074e8:	e8 02 00 00 00       	call   c01074ef <check_vmm>
}
c01074ed:	c9                   	leave  
c01074ee:	c3                   	ret    

c01074ef <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c01074ef:	55                   	push   %ebp
c01074f0:	89 e5                	mov    %esp,%ebp
c01074f2:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01074f5:	e8 31 d2 ff ff       	call   c010472b <nr_free_pages>
c01074fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c01074fd:	e8 41 00 00 00       	call   c0107543 <check_vma_struct>
    check_pgfault();
c0107502:	e8 03 05 00 00       	call   c0107a0a <check_pgfault>

    assert(nr_free_pages_store == nr_free_pages());
c0107507:	e8 1f d2 ff ff       	call   c010472b <nr_free_pages>
c010750c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010750f:	74 24                	je     c0107535 <check_vmm+0x46>
c0107511:	c7 44 24 0c 04 a6 10 	movl   $0xc010a604,0xc(%esp)
c0107518:	c0 
c0107519:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c0107520:	c0 
c0107521:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
c0107528:	00 
c0107529:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c0107530:	e8 f2 96 ff ff       	call   c0100c27 <__panic>

    cprintf("check_vmm() succeeded.\n");
c0107535:	c7 04 24 2b a6 10 c0 	movl   $0xc010a62b,(%esp)
c010753c:	e8 16 8e ff ff       	call   c0100357 <cprintf>
}
c0107541:	c9                   	leave  
c0107542:	c3                   	ret    

c0107543 <check_vma_struct>:

static void
check_vma_struct(void) {
c0107543:	55                   	push   %ebp
c0107544:	89 e5                	mov    %esp,%ebp
c0107546:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107549:	e8 dd d1 ff ff       	call   c010472b <nr_free_pages>
c010754e:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0107551:	e8 d5 fb ff ff       	call   c010712b <mm_create>
c0107556:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0107559:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010755d:	75 24                	jne    c0107583 <check_vma_struct+0x40>
c010755f:	c7 44 24 0c 43 a6 10 	movl   $0xc010a643,0xc(%esp)
c0107566:	c0 
c0107567:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c010756e:	c0 
c010756f:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
c0107576:	00 
c0107577:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c010757e:	e8 a4 96 ff ff       	call   c0100c27 <__panic>

    int step1 = 10, step2 = step1 * 10;
c0107583:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c010758a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010758d:	89 d0                	mov    %edx,%eax
c010758f:	c1 e0 02             	shl    $0x2,%eax
c0107592:	01 d0                	add    %edx,%eax
c0107594:	01 c0                	add    %eax,%eax
c0107596:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0107599:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010759c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010759f:	eb 70                	jmp    c0107611 <check_vma_struct+0xce>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01075a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01075a4:	89 d0                	mov    %edx,%eax
c01075a6:	c1 e0 02             	shl    $0x2,%eax
c01075a9:	01 d0                	add    %edx,%eax
c01075ab:	83 c0 02             	add    $0x2,%eax
c01075ae:	89 c1                	mov    %eax,%ecx
c01075b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01075b3:	89 d0                	mov    %edx,%eax
c01075b5:	c1 e0 02             	shl    $0x2,%eax
c01075b8:	01 d0                	add    %edx,%eax
c01075ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01075c1:	00 
c01075c2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01075c6:	89 04 24             	mov    %eax,(%esp)
c01075c9:	e8 d5 fb ff ff       	call   c01071a3 <vma_create>
c01075ce:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c01075d1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01075d5:	75 24                	jne    c01075fb <check_vma_struct+0xb8>
c01075d7:	c7 44 24 0c 4e a6 10 	movl   $0xc010a64e,0xc(%esp)
c01075de:	c0 
c01075df:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c01075e6:	c0 
c01075e7:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c01075ee:	00 
c01075ef:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c01075f6:	e8 2c 96 ff ff       	call   c0100c27 <__panic>
        insert_vma_struct(mm, vma);
c01075fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01075fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107602:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107605:	89 04 24             	mov    %eax,(%esp)
c0107608:	e8 26 fd ff ff       	call   c0107333 <insert_vma_struct>
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c010760d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0107611:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107615:	7f 8a                	jg     c01075a1 <check_vma_struct+0x5e>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0107617:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010761a:	83 c0 01             	add    $0x1,%eax
c010761d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107620:	eb 70                	jmp    c0107692 <check_vma_struct+0x14f>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0107622:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107625:	89 d0                	mov    %edx,%eax
c0107627:	c1 e0 02             	shl    $0x2,%eax
c010762a:	01 d0                	add    %edx,%eax
c010762c:	83 c0 02             	add    $0x2,%eax
c010762f:	89 c1                	mov    %eax,%ecx
c0107631:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107634:	89 d0                	mov    %edx,%eax
c0107636:	c1 e0 02             	shl    $0x2,%eax
c0107639:	01 d0                	add    %edx,%eax
c010763b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107642:	00 
c0107643:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0107647:	89 04 24             	mov    %eax,(%esp)
c010764a:	e8 54 fb ff ff       	call   c01071a3 <vma_create>
c010764f:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c0107652:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0107656:	75 24                	jne    c010767c <check_vma_struct+0x139>
c0107658:	c7 44 24 0c 4e a6 10 	movl   $0xc010a64e,0xc(%esp)
c010765f:	c0 
c0107660:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c0107667:	c0 
c0107668:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c010766f:	00 
c0107670:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c0107677:	e8 ab 95 ff ff       	call   c0100c27 <__panic>
        insert_vma_struct(mm, vma);
c010767c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010767f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107683:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107686:	89 04 24             	mov    %eax,(%esp)
c0107689:	e8 a5 fc ff ff       	call   c0107333 <insert_vma_struct>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c010768e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107692:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107695:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107698:	7e 88                	jle    c0107622 <check_vma_struct+0xdf>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c010769a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010769d:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01076a0:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01076a3:	8b 40 04             	mov    0x4(%eax),%eax
c01076a6:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c01076a9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c01076b0:	e9 97 00 00 00       	jmp    c010774c <check_vma_struct+0x209>
        assert(le != &(mm->mmap_list));
c01076b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01076b8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01076bb:	75 24                	jne    c01076e1 <check_vma_struct+0x19e>
c01076bd:	c7 44 24 0c 5a a6 10 	movl   $0xc010a65a,0xc(%esp)
c01076c4:	c0 
c01076c5:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c01076cc:	c0 
c01076cd:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c01076d4:	00 
c01076d5:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c01076dc:	e8 46 95 ff ff       	call   c0100c27 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c01076e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01076e4:	83 e8 10             	sub    $0x10,%eax
c01076e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c01076ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01076ed:	8b 48 04             	mov    0x4(%eax),%ecx
c01076f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01076f3:	89 d0                	mov    %edx,%eax
c01076f5:	c1 e0 02             	shl    $0x2,%eax
c01076f8:	01 d0                	add    %edx,%eax
c01076fa:	39 c1                	cmp    %eax,%ecx
c01076fc:	75 17                	jne    c0107715 <check_vma_struct+0x1d2>
c01076fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107701:	8b 48 08             	mov    0x8(%eax),%ecx
c0107704:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107707:	89 d0                	mov    %edx,%eax
c0107709:	c1 e0 02             	shl    $0x2,%eax
c010770c:	01 d0                	add    %edx,%eax
c010770e:	83 c0 02             	add    $0x2,%eax
c0107711:	39 c1                	cmp    %eax,%ecx
c0107713:	74 24                	je     c0107739 <check_vma_struct+0x1f6>
c0107715:	c7 44 24 0c 74 a6 10 	movl   $0xc010a674,0xc(%esp)
c010771c:	c0 
c010771d:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c0107724:	c0 
c0107725:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c010772c:	00 
c010772d:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c0107734:	e8 ee 94 ff ff       	call   c0100c27 <__panic>
c0107739:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010773c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c010773f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107742:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0107745:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c0107748:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010774c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010774f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107752:	0f 8e 5d ff ff ff    	jle    c01076b5 <check_vma_struct+0x172>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0107758:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c010775f:	e9 cd 01 00 00       	jmp    c0107931 <check_vma_struct+0x3ee>
        struct vma_struct *vma1 = find_vma(mm, i);
c0107764:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107767:	89 44 24 04          	mov    %eax,0x4(%esp)
c010776b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010776e:	89 04 24             	mov    %eax,(%esp)
c0107771:	e8 68 fa ff ff       	call   c01071de <find_vma>
c0107776:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma1 != NULL);
c0107779:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010777d:	75 24                	jne    c01077a3 <check_vma_struct+0x260>
c010777f:	c7 44 24 0c a9 a6 10 	movl   $0xc010a6a9,0xc(%esp)
c0107786:	c0 
c0107787:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c010778e:	c0 
c010778f:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0107796:	00 
c0107797:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c010779e:	e8 84 94 ff ff       	call   c0100c27 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c01077a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077a6:	83 c0 01             	add    $0x1,%eax
c01077a9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01077ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01077b0:	89 04 24             	mov    %eax,(%esp)
c01077b3:	e8 26 fa ff ff       	call   c01071de <find_vma>
c01077b8:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma2 != NULL);
c01077bb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01077bf:	75 24                	jne    c01077e5 <check_vma_struct+0x2a2>
c01077c1:	c7 44 24 0c b6 a6 10 	movl   $0xc010a6b6,0xc(%esp)
c01077c8:	c0 
c01077c9:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c01077d0:	c0 
c01077d1:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c01077d8:	00 
c01077d9:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c01077e0:	e8 42 94 ff ff       	call   c0100c27 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c01077e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077e8:	83 c0 02             	add    $0x2,%eax
c01077eb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01077ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01077f2:	89 04 24             	mov    %eax,(%esp)
c01077f5:	e8 e4 f9 ff ff       	call   c01071de <find_vma>
c01077fa:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma3 == NULL);
c01077fd:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0107801:	74 24                	je     c0107827 <check_vma_struct+0x2e4>
c0107803:	c7 44 24 0c c3 a6 10 	movl   $0xc010a6c3,0xc(%esp)
c010780a:	c0 
c010780b:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c0107812:	c0 
c0107813:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c010781a:	00 
c010781b:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c0107822:	e8 00 94 ff ff       	call   c0100c27 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0107827:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010782a:	83 c0 03             	add    $0x3,%eax
c010782d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107831:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107834:	89 04 24             	mov    %eax,(%esp)
c0107837:	e8 a2 f9 ff ff       	call   c01071de <find_vma>
c010783c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma4 == NULL);
c010783f:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0107843:	74 24                	je     c0107869 <check_vma_struct+0x326>
c0107845:	c7 44 24 0c d0 a6 10 	movl   $0xc010a6d0,0xc(%esp)
c010784c:	c0 
c010784d:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c0107854:	c0 
c0107855:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c010785c:	00 
c010785d:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c0107864:	e8 be 93 ff ff       	call   c0100c27 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0107869:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010786c:	83 c0 04             	add    $0x4,%eax
c010786f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107873:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107876:	89 04 24             	mov    %eax,(%esp)
c0107879:	e8 60 f9 ff ff       	call   c01071de <find_vma>
c010787e:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma5 == NULL);
c0107881:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0107885:	74 24                	je     c01078ab <check_vma_struct+0x368>
c0107887:	c7 44 24 0c dd a6 10 	movl   $0xc010a6dd,0xc(%esp)
c010788e:	c0 
c010788f:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c0107896:	c0 
c0107897:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c010789e:	00 
c010789f:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c01078a6:	e8 7c 93 ff ff       	call   c0100c27 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c01078ab:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01078ae:	8b 50 04             	mov    0x4(%eax),%edx
c01078b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01078b4:	39 c2                	cmp    %eax,%edx
c01078b6:	75 10                	jne    c01078c8 <check_vma_struct+0x385>
c01078b8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01078bb:	8b 50 08             	mov    0x8(%eax),%edx
c01078be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01078c1:	83 c0 02             	add    $0x2,%eax
c01078c4:	39 c2                	cmp    %eax,%edx
c01078c6:	74 24                	je     c01078ec <check_vma_struct+0x3a9>
c01078c8:	c7 44 24 0c ec a6 10 	movl   $0xc010a6ec,0xc(%esp)
c01078cf:	c0 
c01078d0:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c01078d7:	c0 
c01078d8:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c01078df:	00 
c01078e0:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c01078e7:	e8 3b 93 ff ff       	call   c0100c27 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c01078ec:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01078ef:	8b 50 04             	mov    0x4(%eax),%edx
c01078f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01078f5:	39 c2                	cmp    %eax,%edx
c01078f7:	75 10                	jne    c0107909 <check_vma_struct+0x3c6>
c01078f9:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01078fc:	8b 50 08             	mov    0x8(%eax),%edx
c01078ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107902:	83 c0 02             	add    $0x2,%eax
c0107905:	39 c2                	cmp    %eax,%edx
c0107907:	74 24                	je     c010792d <check_vma_struct+0x3ea>
c0107909:	c7 44 24 0c 1c a7 10 	movl   $0xc010a71c,0xc(%esp)
c0107910:	c0 
c0107911:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c0107918:	c0 
c0107919:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0107920:	00 
c0107921:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c0107928:	e8 fa 92 ff ff       	call   c0100c27 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c010792d:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0107931:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107934:	89 d0                	mov    %edx,%eax
c0107936:	c1 e0 02             	shl    $0x2,%eax
c0107939:	01 d0                	add    %edx,%eax
c010793b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010793e:	0f 8d 20 fe ff ff    	jge    c0107764 <check_vma_struct+0x221>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0107944:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c010794b:	eb 70                	jmp    c01079bd <check_vma_struct+0x47a>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c010794d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107950:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107954:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107957:	89 04 24             	mov    %eax,(%esp)
c010795a:	e8 7f f8 ff ff       	call   c01071de <find_vma>
c010795f:	89 45 bc             	mov    %eax,-0x44(%ebp)
        if (vma_below_5 != NULL ) {
c0107962:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0107966:	74 27                	je     c010798f <check_vma_struct+0x44c>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0107968:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010796b:	8b 50 08             	mov    0x8(%eax),%edx
c010796e:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0107971:	8b 40 04             	mov    0x4(%eax),%eax
c0107974:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0107978:	89 44 24 08          	mov    %eax,0x8(%esp)
c010797c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010797f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107983:	c7 04 24 4c a7 10 c0 	movl   $0xc010a74c,(%esp)
c010798a:	e8 c8 89 ff ff       	call   c0100357 <cprintf>
        }
        assert(vma_below_5 == NULL);
c010798f:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0107993:	74 24                	je     c01079b9 <check_vma_struct+0x476>
c0107995:	c7 44 24 0c 71 a7 10 	movl   $0xc010a771,0xc(%esp)
c010799c:	c0 
c010799d:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c01079a4:	c0 
c01079a5:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c01079ac:	00 
c01079ad:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c01079b4:	e8 6e 92 ff ff       	call   c0100c27 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c01079b9:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01079bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01079c1:	79 8a                	jns    c010794d <check_vma_struct+0x40a>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c01079c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01079c6:	89 04 24             	mov    %eax,(%esp)
c01079c9:	e8 95 fa ff ff       	call   c0107463 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
c01079ce:	e8 58 cd ff ff       	call   c010472b <nr_free_pages>
c01079d3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01079d6:	74 24                	je     c01079fc <check_vma_struct+0x4b9>
c01079d8:	c7 44 24 0c 04 a6 10 	movl   $0xc010a604,0xc(%esp)
c01079df:	c0 
c01079e0:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c01079e7:	c0 
c01079e8:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c01079ef:	00 
c01079f0:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c01079f7:	e8 2b 92 ff ff       	call   c0100c27 <__panic>

    cprintf("check_vma_struct() succeeded!\n");
c01079fc:	c7 04 24 88 a7 10 c0 	movl   $0xc010a788,(%esp)
c0107a03:	e8 4f 89 ff ff       	call   c0100357 <cprintf>
}
c0107a08:	c9                   	leave  
c0107a09:	c3                   	ret    

c0107a0a <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0107a0a:	55                   	push   %ebp
c0107a0b:	89 e5                	mov    %esp,%ebp
c0107a0d:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107a10:	e8 16 cd ff ff       	call   c010472b <nr_free_pages>
c0107a15:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0107a18:	e8 0e f7 ff ff       	call   c010712b <mm_create>
c0107a1d:	a3 2c 41 12 c0       	mov    %eax,0xc012412c
    assert(check_mm_struct != NULL);
c0107a22:	a1 2c 41 12 c0       	mov    0xc012412c,%eax
c0107a27:	85 c0                	test   %eax,%eax
c0107a29:	75 24                	jne    c0107a4f <check_pgfault+0x45>
c0107a2b:	c7 44 24 0c a7 a7 10 	movl   $0xc010a7a7,0xc(%esp)
c0107a32:	c0 
c0107a33:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c0107a3a:	c0 
c0107a3b:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c0107a42:	00 
c0107a43:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c0107a4a:	e8 d8 91 ff ff       	call   c0100c27 <__panic>

    struct mm_struct *mm = check_mm_struct;
c0107a4f:	a1 2c 41 12 c0       	mov    0xc012412c,%eax
c0107a54:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0107a57:	8b 15 e0 09 12 c0    	mov    0xc01209e0,%edx
c0107a5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107a60:	89 50 0c             	mov    %edx,0xc(%eax)
c0107a63:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107a66:	8b 40 0c             	mov    0xc(%eax),%eax
c0107a69:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0107a6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107a6f:	8b 00                	mov    (%eax),%eax
c0107a71:	85 c0                	test   %eax,%eax
c0107a73:	74 24                	je     c0107a99 <check_pgfault+0x8f>
c0107a75:	c7 44 24 0c bf a7 10 	movl   $0xc010a7bf,0xc(%esp)
c0107a7c:	c0 
c0107a7d:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c0107a84:	c0 
c0107a85:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0107a8c:	00 
c0107a8d:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c0107a94:	e8 8e 91 ff ff       	call   c0100c27 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0107a99:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0107aa0:	00 
c0107aa1:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0107aa8:	00 
c0107aa9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0107ab0:	e8 ee f6 ff ff       	call   c01071a3 <vma_create>
c0107ab5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0107ab8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0107abc:	75 24                	jne    c0107ae2 <check_pgfault+0xd8>
c0107abe:	c7 44 24 0c 4e a6 10 	movl   $0xc010a64e,0xc(%esp)
c0107ac5:	c0 
c0107ac6:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c0107acd:	c0 
c0107ace:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0107ad5:	00 
c0107ad6:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c0107add:	e8 45 91 ff ff       	call   c0100c27 <__panic>

    insert_vma_struct(mm, vma);
c0107ae2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107ae9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107aec:	89 04 24             	mov    %eax,(%esp)
c0107aef:	e8 3f f8 ff ff       	call   c0107333 <insert_vma_struct>

    uintptr_t addr = 0x100;
c0107af4:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0107afb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107afe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107b02:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b05:	89 04 24             	mov    %eax,(%esp)
c0107b08:	e8 d1 f6 ff ff       	call   c01071de <find_vma>
c0107b0d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107b10:	74 24                	je     c0107b36 <check_pgfault+0x12c>
c0107b12:	c7 44 24 0c cd a7 10 	movl   $0xc010a7cd,0xc(%esp)
c0107b19:	c0 
c0107b1a:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c0107b21:	c0 
c0107b22:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0107b29:	00 
c0107b2a:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c0107b31:	e8 f1 90 ff ff       	call   c0100c27 <__panic>

    int i, sum = 0;
c0107b36:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0107b3d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107b44:	eb 17                	jmp    c0107b5d <check_pgfault+0x153>
        *(char *)(addr + i) = i;
c0107b46:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107b49:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107b4c:	01 d0                	add    %edx,%eax
c0107b4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107b51:	88 10                	mov    %dl,(%eax)
        sum += i;
c0107b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b56:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c0107b59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107b5d:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0107b61:	7e e3                	jle    c0107b46 <check_pgfault+0x13c>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0107b63:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107b6a:	eb 15                	jmp    c0107b81 <check_pgfault+0x177>
        sum -= *(char *)(addr + i);
c0107b6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107b6f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107b72:	01 d0                	add    %edx,%eax
c0107b74:	0f b6 00             	movzbl (%eax),%eax
c0107b77:	0f be c0             	movsbl %al,%eax
c0107b7a:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0107b7d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107b81:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0107b85:	7e e5                	jle    c0107b6c <check_pgfault+0x162>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c0107b87:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107b8b:	74 24                	je     c0107bb1 <check_pgfault+0x1a7>
c0107b8d:	c7 44 24 0c e7 a7 10 	movl   $0xc010a7e7,0xc(%esp)
c0107b94:	c0 
c0107b95:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c0107b9c:	c0 
c0107b9d:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0107ba4:	00 
c0107ba5:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c0107bac:	e8 76 90 ff ff       	call   c0100c27 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0107bb1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107bb4:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0107bb7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107bba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107bbf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107bc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107bc6:	89 04 24             	mov    %eax,(%esp)
c0107bc9:	e8 91 d3 ff ff       	call   c0104f5f <page_remove>
    free_page(pde2page(pgdir[0]));
c0107bce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107bd1:	8b 00                	mov    (%eax),%eax
c0107bd3:	89 04 24             	mov    %eax,(%esp)
c0107bd6:	e8 38 f5 ff ff       	call   c0107113 <pde2page>
c0107bdb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107be2:	00 
c0107be3:	89 04 24             	mov    %eax,(%esp)
c0107be6:	e8 0e cb ff ff       	call   c01046f9 <free_pages>
    pgdir[0] = 0;
c0107beb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107bee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0107bf4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107bf7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0107bfe:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c01:	89 04 24             	mov    %eax,(%esp)
c0107c04:	e8 5a f8 ff ff       	call   c0107463 <mm_destroy>
    check_mm_struct = NULL;
c0107c09:	c7 05 2c 41 12 c0 00 	movl   $0x0,0xc012412c
c0107c10:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0107c13:	e8 13 cb ff ff       	call   c010472b <nr_free_pages>
c0107c18:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107c1b:	74 24                	je     c0107c41 <check_pgfault+0x237>
c0107c1d:	c7 44 24 0c 04 a6 10 	movl   $0xc010a604,0xc(%esp)
c0107c24:	c0 
c0107c25:	c7 44 24 08 83 a5 10 	movl   $0xc010a583,0x8(%esp)
c0107c2c:	c0 
c0107c2d:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0107c34:	00 
c0107c35:	c7 04 24 98 a5 10 c0 	movl   $0xc010a598,(%esp)
c0107c3c:	e8 e6 8f ff ff       	call   c0100c27 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0107c41:	c7 04 24 f0 a7 10 c0 	movl   $0xc010a7f0,(%esp)
c0107c48:	e8 0a 87 ff ff       	call   c0100357 <cprintf>
}
c0107c4d:	c9                   	leave  
c0107c4e:	c3                   	ret    

c0107c4f <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0107c4f:	55                   	push   %ebp
c0107c50:	89 e5                	mov    %esp,%ebp
c0107c52:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0107c55:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0107c5c:	8b 45 10             	mov    0x10(%ebp),%eax
c0107c5f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107c63:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c66:	89 04 24             	mov    %eax,(%esp)
c0107c69:	e8 70 f5 ff ff       	call   c01071de <find_vma>
c0107c6e:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0107c71:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0107c76:	83 c0 01             	add    $0x1,%eax
c0107c79:	a3 38 40 12 c0       	mov    %eax,0xc0124038
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0107c7e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107c82:	74 0b                	je     c0107c8f <do_pgfault+0x40>
c0107c84:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107c87:	8b 40 04             	mov    0x4(%eax),%eax
c0107c8a:	3b 45 10             	cmp    0x10(%ebp),%eax
c0107c8d:	76 18                	jbe    c0107ca7 <do_pgfault+0x58>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0107c8f:	8b 45 10             	mov    0x10(%ebp),%eax
c0107c92:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107c96:	c7 04 24 0c a8 10 c0 	movl   $0xc010a80c,(%esp)
c0107c9d:	e8 b5 86 ff ff       	call   c0100357 <cprintf>
        goto failed;
c0107ca2:	e9 c0 01 00 00       	jmp    c0107e67 <do_pgfault+0x218>
    }
    //check the error_code
    switch (error_code & 3) {
c0107ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107caa:	83 e0 03             	and    $0x3,%eax
c0107cad:	85 c0                	test   %eax,%eax
c0107caf:	74 36                	je     c0107ce7 <do_pgfault+0x98>
c0107cb1:	83 f8 01             	cmp    $0x1,%eax
c0107cb4:	74 20                	je     c0107cd6 <do_pgfault+0x87>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0107cb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107cb9:	8b 40 0c             	mov    0xc(%eax),%eax
c0107cbc:	83 e0 02             	and    $0x2,%eax
c0107cbf:	85 c0                	test   %eax,%eax
c0107cc1:	75 11                	jne    c0107cd4 <do_pgfault+0x85>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0107cc3:	c7 04 24 3c a8 10 c0 	movl   $0xc010a83c,(%esp)
c0107cca:	e8 88 86 ff ff       	call   c0100357 <cprintf>
            goto failed;
c0107ccf:	e9 93 01 00 00       	jmp    c0107e67 <do_pgfault+0x218>
        }
        break;
c0107cd4:	eb 2f                	jmp    c0107d05 <do_pgfault+0xb6>
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0107cd6:	c7 04 24 9c a8 10 c0 	movl   $0xc010a89c,(%esp)
c0107cdd:	e8 75 86 ff ff       	call   c0100357 <cprintf>
        goto failed;
c0107ce2:	e9 80 01 00 00       	jmp    c0107e67 <do_pgfault+0x218>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0107ce7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107cea:	8b 40 0c             	mov    0xc(%eax),%eax
c0107ced:	83 e0 05             	and    $0x5,%eax
c0107cf0:	85 c0                	test   %eax,%eax
c0107cf2:	75 11                	jne    c0107d05 <do_pgfault+0xb6>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0107cf4:	c7 04 24 d4 a8 10 c0 	movl   $0xc010a8d4,(%esp)
c0107cfb:	e8 57 86 ff ff       	call   c0100357 <cprintf>
            goto failed;
c0107d00:	e9 62 01 00 00       	jmp    c0107e67 <do_pgfault+0x218>
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0107d05:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0107d0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107d0f:	8b 40 0c             	mov    0xc(%eax),%eax
c0107d12:	83 e0 02             	and    $0x2,%eax
c0107d15:	85 c0                	test   %eax,%eax
c0107d17:	74 04                	je     c0107d1d <do_pgfault+0xce>
        perm |= PTE_W;
c0107d19:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0107d1d:	8b 45 10             	mov    0x10(%ebp),%eax
c0107d20:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107d23:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d26:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107d2b:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0107d2e:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0107d35:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            goto failed;
        }
   }
#endif
    // 根据get_pte来获取pte如果不存在，则分配一个新的
    ptep = get_pte(mm->pgdir, addr, 1);
c0107d3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d3f:	8b 40 0c             	mov    0xc(%eax),%eax
c0107d42:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0107d49:	00 
c0107d4a:	8b 55 10             	mov    0x10(%ebp),%edx
c0107d4d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107d51:	89 04 24             	mov    %eax,(%esp)
c0107d54:	e8 14 d0 ff ff       	call   c0104d6d <get_pte>
c0107d59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (ptep == NULL) {
c0107d5c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107d60:	75 11                	jne    c0107d73 <do_pgfault+0x124>
        cprintf("get_pte in do_pgfault failed\n");
c0107d62:	c7 04 24 37 a9 10 c0 	movl   $0xc010a937,(%esp)
c0107d69:	e8 e9 85 ff ff       	call   c0100357 <cprintf>
        goto failed;
c0107d6e:	e9 f4 00 00 00       	jmp    c0107e67 <do_pgfault+0x218>
    }
    struct Page *p;
    // 如果对应的物理页不存在，分配一个新的页，且把物理地址和逻辑地址映射 
    if (*ptep == 0) {
c0107d73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107d76:	8b 00                	mov    (%eax),%eax
c0107d78:	85 c0                	test   %eax,%eax
c0107d7a:	75 3a                	jne    c0107db6 <do_pgfault+0x167>
        p = pgdir_alloc_page(mm->pgdir, addr, perm);
c0107d7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d7f:	8b 40 0c             	mov    0xc(%eax),%eax
c0107d82:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107d85:	89 54 24 08          	mov    %edx,0x8(%esp)
c0107d89:	8b 55 10             	mov    0x10(%ebp),%edx
c0107d8c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107d90:	89 04 24             	mov    %eax,(%esp)
c0107d93:	e8 21 d3 ff ff       	call   c01050b9 <pgdir_alloc_page>
c0107d98:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if (p == NULL) {
c0107d9b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0107d9f:	0f 85 bb 00 00 00    	jne    c0107e60 <do_pgfault+0x211>
            cprintf("alloc_page in do_pgfault failed\n");
c0107da5:	c7 04 24 58 a9 10 c0 	movl   $0xc010a958,(%esp)
c0107dac:	e8 a6 85 ff ff       	call   c0100357 <cprintf>
            goto failed;
c0107db1:	e9 b1 00 00 00       	jmp    c0107e67 <do_pgfault+0x218>
        }
    } else {
        // 如果不全为0，则可能被交换到了swap磁盘中
        if(swap_init_ok) {
c0107db6:	a1 2c 40 12 c0       	mov    0xc012402c,%eax
c0107dbb:	85 c0                	test   %eax,%eax
c0107dbd:	0f 84 86 00 00 00    	je     c0107e49 <do_pgfault+0x1fa>
            struct Page *page=NULL;
c0107dc3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
            int swapIn;
            // 从磁盘中换出
            swapIn = swap_in(mm, addr, &page);
c0107dca:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0107dcd:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107dd1:	8b 45 10             	mov    0x10(%ebp),%eax
c0107dd4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107dd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ddb:	89 04 24             	mov    %eax,(%esp)
c0107dde:	e8 9b e4 ff ff       	call   c010627e <swap_in>
c0107de3:	89 45 dc             	mov    %eax,-0x24(%ebp)
            if (swapIn != 0) {
c0107de6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107dea:	74 0e                	je     c0107dfa <do_pgfault+0x1ab>
                cprintf("swap_in in do_pgfault failed\n");
c0107dec:	c7 04 24 79 a9 10 c0 	movl   $0xc010a979,(%esp)
c0107df3:	e8 5f 85 ff ff       	call   c0100357 <cprintf>
c0107df8:	eb 6d                	jmp    c0107e67 <do_pgfault+0x218>
                goto failed;
            }

            // build the map of phy addr of an Page with the linear addr la
            page_insert(mm->pgdir, page, addr, perm);
c0107dfa:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107dfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e00:	8b 40 0c             	mov    0xc(%eax),%eax
c0107e03:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0107e06:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0107e0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0107e0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0107e11:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107e15:	89 04 24             	mov    %eax,(%esp)
c0107e18:	e8 86 d1 ff ff       	call   c0104fa3 <page_insert>
            // if (page_insert(mm->pgdir, page, addr, perm) != 0) {
            //     cprintf("page_insert in do_pgfault failed\n");
            //     goto failed;
            // }

            swap_map_swappable(mm, addr, page, 1);
c0107e1d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107e20:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0107e27:	00 
c0107e28:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107e2c:	8b 45 10             	mov    0x10(%ebp),%eax
c0107e2f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107e33:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e36:	89 04 24             	mov    %eax,(%esp)
c0107e39:	e8 77 e2 ff ff       	call   c01060b5 <swap_map_swappable>
            page->pra_vaddr = addr;
c0107e3e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107e41:	8b 55 10             	mov    0x10(%ebp),%edx
c0107e44:	89 50 1c             	mov    %edx,0x1c(%eax)
c0107e47:	eb 17                	jmp    c0107e60 <do_pgfault+0x211>
        } else {
            cprintf("no swap_init_ok, but ptep is %x, failed\n", *ptep);
c0107e49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107e4c:	8b 00                	mov    (%eax),%eax
c0107e4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107e52:	c7 04 24 98 a9 10 c0 	movl   $0xc010a998,(%esp)
c0107e59:	e8 f9 84 ff ff       	call   c0100357 <cprintf>
            goto failed;
c0107e5e:	eb 07                	jmp    c0107e67 <do_pgfault+0x218>
        }
    }
   ret = 0;
c0107e60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0107e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107e6a:	c9                   	leave  
c0107e6b:	c3                   	ret    

c0107e6c <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0107e6c:	55                   	push   %ebp
c0107e6d:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0107e6f:	8b 55 08             	mov    0x8(%ebp),%edx
c0107e72:	a1 54 40 12 c0       	mov    0xc0124054,%eax
c0107e77:	29 c2                	sub    %eax,%edx
c0107e79:	89 d0                	mov    %edx,%eax
c0107e7b:	c1 f8 05             	sar    $0x5,%eax
}
c0107e7e:	5d                   	pop    %ebp
c0107e7f:	c3                   	ret    

c0107e80 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0107e80:	55                   	push   %ebp
c0107e81:	89 e5                	mov    %esp,%ebp
c0107e83:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0107e86:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e89:	89 04 24             	mov    %eax,(%esp)
c0107e8c:	e8 db ff ff ff       	call   c0107e6c <page2ppn>
c0107e91:	c1 e0 0c             	shl    $0xc,%eax
}
c0107e94:	c9                   	leave  
c0107e95:	c3                   	ret    

c0107e96 <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c0107e96:	55                   	push   %ebp
c0107e97:	89 e5                	mov    %esp,%ebp
c0107e99:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0107e9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e9f:	89 04 24             	mov    %eax,(%esp)
c0107ea2:	e8 d9 ff ff ff       	call   c0107e80 <page2pa>
c0107ea7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ead:	c1 e8 0c             	shr    $0xc,%eax
c0107eb0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107eb3:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0107eb8:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107ebb:	72 23                	jb     c0107ee0 <page2kva+0x4a>
c0107ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ec0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107ec4:	c7 44 24 08 c4 a9 10 	movl   $0xc010a9c4,0x8(%esp)
c0107ecb:	c0 
c0107ecc:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0107ed3:	00 
c0107ed4:	c7 04 24 e7 a9 10 c0 	movl   $0xc010a9e7,(%esp)
c0107edb:	e8 47 8d ff ff       	call   c0100c27 <__panic>
c0107ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ee3:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0107ee8:	c9                   	leave  
c0107ee9:	c3                   	ret    

c0107eea <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0107eea:	55                   	push   %ebp
c0107eeb:	89 e5                	mov    %esp,%ebp
c0107eed:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0107ef0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107ef7:	e8 8c 9a ff ff       	call   c0101988 <ide_device_valid>
c0107efc:	85 c0                	test   %eax,%eax
c0107efe:	75 1c                	jne    c0107f1c <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c0107f00:	c7 44 24 08 f5 a9 10 	movl   $0xc010a9f5,0x8(%esp)
c0107f07:	c0 
c0107f08:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c0107f0f:	00 
c0107f10:	c7 04 24 0f aa 10 c0 	movl   $0xc010aa0f,(%esp)
c0107f17:	e8 0b 8d ff ff       	call   c0100c27 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0107f1c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107f23:	e8 9f 9a ff ff       	call   c01019c7 <ide_device_size>
c0107f28:	c1 e8 03             	shr    $0x3,%eax
c0107f2b:	a3 fc 40 12 c0       	mov    %eax,0xc01240fc
}
c0107f30:	c9                   	leave  
c0107f31:	c3                   	ret    

c0107f32 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c0107f32:	55                   	push   %ebp
c0107f33:	89 e5                	mov    %esp,%ebp
c0107f35:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0107f38:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107f3b:	89 04 24             	mov    %eax,(%esp)
c0107f3e:	e8 53 ff ff ff       	call   c0107e96 <page2kva>
c0107f43:	8b 55 08             	mov    0x8(%ebp),%edx
c0107f46:	c1 ea 08             	shr    $0x8,%edx
c0107f49:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0107f4c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107f50:	74 0b                	je     c0107f5d <swapfs_read+0x2b>
c0107f52:	8b 15 fc 40 12 c0    	mov    0xc01240fc,%edx
c0107f58:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0107f5b:	72 23                	jb     c0107f80 <swapfs_read+0x4e>
c0107f5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f60:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107f64:	c7 44 24 08 20 aa 10 	movl   $0xc010aa20,0x8(%esp)
c0107f6b:	c0 
c0107f6c:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0107f73:	00 
c0107f74:	c7 04 24 0f aa 10 c0 	movl   $0xc010aa0f,(%esp)
c0107f7b:	e8 a7 8c ff ff       	call   c0100c27 <__panic>
c0107f80:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107f83:	c1 e2 03             	shl    $0x3,%edx
c0107f86:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0107f8d:	00 
c0107f8e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107f92:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107f96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107f9d:	e8 64 9a ff ff       	call   c0101a06 <ide_read_secs>
}
c0107fa2:	c9                   	leave  
c0107fa3:	c3                   	ret    

c0107fa4 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0107fa4:	55                   	push   %ebp
c0107fa5:	89 e5                	mov    %esp,%ebp
c0107fa7:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0107faa:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107fad:	89 04 24             	mov    %eax,(%esp)
c0107fb0:	e8 e1 fe ff ff       	call   c0107e96 <page2kva>
c0107fb5:	8b 55 08             	mov    0x8(%ebp),%edx
c0107fb8:	c1 ea 08             	shr    $0x8,%edx
c0107fbb:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0107fbe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107fc2:	74 0b                	je     c0107fcf <swapfs_write+0x2b>
c0107fc4:	8b 15 fc 40 12 c0    	mov    0xc01240fc,%edx
c0107fca:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0107fcd:	72 23                	jb     c0107ff2 <swapfs_write+0x4e>
c0107fcf:	8b 45 08             	mov    0x8(%ebp),%eax
c0107fd2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107fd6:	c7 44 24 08 20 aa 10 	movl   $0xc010aa20,0x8(%esp)
c0107fdd:	c0 
c0107fde:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c0107fe5:	00 
c0107fe6:	c7 04 24 0f aa 10 c0 	movl   $0xc010aa0f,(%esp)
c0107fed:	e8 35 8c ff ff       	call   c0100c27 <__panic>
c0107ff2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ff5:	c1 e2 03             	shl    $0x3,%edx
c0107ff8:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0107fff:	00 
c0108000:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108004:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108008:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010800f:	e8 34 9c ff ff       	call   c0101c48 <ide_write_secs>
}
c0108014:	c9                   	leave  
c0108015:	c3                   	ret    

c0108016 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0108016:	55                   	push   %ebp
c0108017:	89 e5                	mov    %esp,%ebp
c0108019:	83 ec 58             	sub    $0x58,%esp
c010801c:	8b 45 10             	mov    0x10(%ebp),%eax
c010801f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0108022:	8b 45 14             	mov    0x14(%ebp),%eax
c0108025:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0108028:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010802b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010802e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108031:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0108034:	8b 45 18             	mov    0x18(%ebp),%eax
c0108037:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010803a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010803d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108040:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108043:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0108046:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108049:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010804c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108050:	74 1c                	je     c010806e <printnum+0x58>
c0108052:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108055:	ba 00 00 00 00       	mov    $0x0,%edx
c010805a:	f7 75 e4             	divl   -0x1c(%ebp)
c010805d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108060:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108063:	ba 00 00 00 00       	mov    $0x0,%edx
c0108068:	f7 75 e4             	divl   -0x1c(%ebp)
c010806b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010806e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108071:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108074:	f7 75 e4             	divl   -0x1c(%ebp)
c0108077:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010807a:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010807d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108080:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108083:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108086:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0108089:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010808c:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010808f:	8b 45 18             	mov    0x18(%ebp),%eax
c0108092:	ba 00 00 00 00       	mov    $0x0,%edx
c0108097:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010809a:	77 56                	ja     c01080f2 <printnum+0xdc>
c010809c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010809f:	72 05                	jb     c01080a6 <printnum+0x90>
c01080a1:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01080a4:	77 4c                	ja     c01080f2 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c01080a6:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01080a9:	8d 50 ff             	lea    -0x1(%eax),%edx
c01080ac:	8b 45 20             	mov    0x20(%ebp),%eax
c01080af:	89 44 24 18          	mov    %eax,0x18(%esp)
c01080b3:	89 54 24 14          	mov    %edx,0x14(%esp)
c01080b7:	8b 45 18             	mov    0x18(%ebp),%eax
c01080ba:	89 44 24 10          	mov    %eax,0x10(%esp)
c01080be:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01080c1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01080c4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01080c8:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01080cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01080cf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01080d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01080d6:	89 04 24             	mov    %eax,(%esp)
c01080d9:	e8 38 ff ff ff       	call   c0108016 <printnum>
c01080de:	eb 1c                	jmp    c01080fc <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c01080e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01080e3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01080e7:	8b 45 20             	mov    0x20(%ebp),%eax
c01080ea:	89 04 24             	mov    %eax,(%esp)
c01080ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01080f0:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c01080f2:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c01080f6:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01080fa:	7f e4                	jg     c01080e0 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c01080fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01080ff:	05 c0 aa 10 c0       	add    $0xc010aac0,%eax
c0108104:	0f b6 00             	movzbl (%eax),%eax
c0108107:	0f be c0             	movsbl %al,%eax
c010810a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010810d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108111:	89 04 24             	mov    %eax,(%esp)
c0108114:	8b 45 08             	mov    0x8(%ebp),%eax
c0108117:	ff d0                	call   *%eax
}
c0108119:	c9                   	leave  
c010811a:	c3                   	ret    

c010811b <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010811b:	55                   	push   %ebp
c010811c:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010811e:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0108122:	7e 14                	jle    c0108138 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0108124:	8b 45 08             	mov    0x8(%ebp),%eax
c0108127:	8b 00                	mov    (%eax),%eax
c0108129:	8d 48 08             	lea    0x8(%eax),%ecx
c010812c:	8b 55 08             	mov    0x8(%ebp),%edx
c010812f:	89 0a                	mov    %ecx,(%edx)
c0108131:	8b 50 04             	mov    0x4(%eax),%edx
c0108134:	8b 00                	mov    (%eax),%eax
c0108136:	eb 30                	jmp    c0108168 <getuint+0x4d>
    }
    else if (lflag) {
c0108138:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010813c:	74 16                	je     c0108154 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010813e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108141:	8b 00                	mov    (%eax),%eax
c0108143:	8d 48 04             	lea    0x4(%eax),%ecx
c0108146:	8b 55 08             	mov    0x8(%ebp),%edx
c0108149:	89 0a                	mov    %ecx,(%edx)
c010814b:	8b 00                	mov    (%eax),%eax
c010814d:	ba 00 00 00 00       	mov    $0x0,%edx
c0108152:	eb 14                	jmp    c0108168 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0108154:	8b 45 08             	mov    0x8(%ebp),%eax
c0108157:	8b 00                	mov    (%eax),%eax
c0108159:	8d 48 04             	lea    0x4(%eax),%ecx
c010815c:	8b 55 08             	mov    0x8(%ebp),%edx
c010815f:	89 0a                	mov    %ecx,(%edx)
c0108161:	8b 00                	mov    (%eax),%eax
c0108163:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0108168:	5d                   	pop    %ebp
c0108169:	c3                   	ret    

c010816a <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010816a:	55                   	push   %ebp
c010816b:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010816d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0108171:	7e 14                	jle    c0108187 <getint+0x1d>
        return va_arg(*ap, long long);
c0108173:	8b 45 08             	mov    0x8(%ebp),%eax
c0108176:	8b 00                	mov    (%eax),%eax
c0108178:	8d 48 08             	lea    0x8(%eax),%ecx
c010817b:	8b 55 08             	mov    0x8(%ebp),%edx
c010817e:	89 0a                	mov    %ecx,(%edx)
c0108180:	8b 50 04             	mov    0x4(%eax),%edx
c0108183:	8b 00                	mov    (%eax),%eax
c0108185:	eb 28                	jmp    c01081af <getint+0x45>
    }
    else if (lflag) {
c0108187:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010818b:	74 12                	je     c010819f <getint+0x35>
        return va_arg(*ap, long);
c010818d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108190:	8b 00                	mov    (%eax),%eax
c0108192:	8d 48 04             	lea    0x4(%eax),%ecx
c0108195:	8b 55 08             	mov    0x8(%ebp),%edx
c0108198:	89 0a                	mov    %ecx,(%edx)
c010819a:	8b 00                	mov    (%eax),%eax
c010819c:	99                   	cltd   
c010819d:	eb 10                	jmp    c01081af <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010819f:	8b 45 08             	mov    0x8(%ebp),%eax
c01081a2:	8b 00                	mov    (%eax),%eax
c01081a4:	8d 48 04             	lea    0x4(%eax),%ecx
c01081a7:	8b 55 08             	mov    0x8(%ebp),%edx
c01081aa:	89 0a                	mov    %ecx,(%edx)
c01081ac:	8b 00                	mov    (%eax),%eax
c01081ae:	99                   	cltd   
    }
}
c01081af:	5d                   	pop    %ebp
c01081b0:	c3                   	ret    

c01081b1 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01081b1:	55                   	push   %ebp
c01081b2:	89 e5                	mov    %esp,%ebp
c01081b4:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c01081b7:	8d 45 14             	lea    0x14(%ebp),%eax
c01081ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c01081bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01081c4:	8b 45 10             	mov    0x10(%ebp),%eax
c01081c7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01081cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01081d5:	89 04 24             	mov    %eax,(%esp)
c01081d8:	e8 02 00 00 00       	call   c01081df <vprintfmt>
    va_end(ap);
}
c01081dd:	c9                   	leave  
c01081de:	c3                   	ret    

c01081df <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c01081df:	55                   	push   %ebp
c01081e0:	89 e5                	mov    %esp,%ebp
c01081e2:	56                   	push   %esi
c01081e3:	53                   	push   %ebx
c01081e4:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01081e7:	eb 18                	jmp    c0108201 <vprintfmt+0x22>
            if (ch == '\0') {
c01081e9:	85 db                	test   %ebx,%ebx
c01081eb:	75 05                	jne    c01081f2 <vprintfmt+0x13>
                return;
c01081ed:	e9 d1 03 00 00       	jmp    c01085c3 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c01081f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081f9:	89 1c 24             	mov    %ebx,(%esp)
c01081fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01081ff:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108201:	8b 45 10             	mov    0x10(%ebp),%eax
c0108204:	8d 50 01             	lea    0x1(%eax),%edx
c0108207:	89 55 10             	mov    %edx,0x10(%ebp)
c010820a:	0f b6 00             	movzbl (%eax),%eax
c010820d:	0f b6 d8             	movzbl %al,%ebx
c0108210:	83 fb 25             	cmp    $0x25,%ebx
c0108213:	75 d4                	jne    c01081e9 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c0108215:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0108219:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0108220:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108223:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0108226:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010822d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108230:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0108233:	8b 45 10             	mov    0x10(%ebp),%eax
c0108236:	8d 50 01             	lea    0x1(%eax),%edx
c0108239:	89 55 10             	mov    %edx,0x10(%ebp)
c010823c:	0f b6 00             	movzbl (%eax),%eax
c010823f:	0f b6 d8             	movzbl %al,%ebx
c0108242:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0108245:	83 f8 55             	cmp    $0x55,%eax
c0108248:	0f 87 44 03 00 00    	ja     c0108592 <vprintfmt+0x3b3>
c010824e:	8b 04 85 e4 aa 10 c0 	mov    -0x3fef551c(,%eax,4),%eax
c0108255:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0108257:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010825b:	eb d6                	jmp    c0108233 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010825d:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0108261:	eb d0                	jmp    c0108233 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0108263:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010826a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010826d:	89 d0                	mov    %edx,%eax
c010826f:	c1 e0 02             	shl    $0x2,%eax
c0108272:	01 d0                	add    %edx,%eax
c0108274:	01 c0                	add    %eax,%eax
c0108276:	01 d8                	add    %ebx,%eax
c0108278:	83 e8 30             	sub    $0x30,%eax
c010827b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010827e:	8b 45 10             	mov    0x10(%ebp),%eax
c0108281:	0f b6 00             	movzbl (%eax),%eax
c0108284:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0108287:	83 fb 2f             	cmp    $0x2f,%ebx
c010828a:	7e 0b                	jle    c0108297 <vprintfmt+0xb8>
c010828c:	83 fb 39             	cmp    $0x39,%ebx
c010828f:	7f 06                	jg     c0108297 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0108291:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c0108295:	eb d3                	jmp    c010826a <vprintfmt+0x8b>
            goto process_precision;
c0108297:	eb 33                	jmp    c01082cc <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c0108299:	8b 45 14             	mov    0x14(%ebp),%eax
c010829c:	8d 50 04             	lea    0x4(%eax),%edx
c010829f:	89 55 14             	mov    %edx,0x14(%ebp)
c01082a2:	8b 00                	mov    (%eax),%eax
c01082a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01082a7:	eb 23                	jmp    c01082cc <vprintfmt+0xed>

        case '.':
            if (width < 0)
c01082a9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01082ad:	79 0c                	jns    c01082bb <vprintfmt+0xdc>
                width = 0;
c01082af:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c01082b6:	e9 78 ff ff ff       	jmp    c0108233 <vprintfmt+0x54>
c01082bb:	e9 73 ff ff ff       	jmp    c0108233 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c01082c0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c01082c7:	e9 67 ff ff ff       	jmp    c0108233 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c01082cc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01082d0:	79 12                	jns    c01082e4 <vprintfmt+0x105>
                width = precision, precision = -1;
c01082d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01082d5:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01082d8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c01082df:	e9 4f ff ff ff       	jmp    c0108233 <vprintfmt+0x54>
c01082e4:	e9 4a ff ff ff       	jmp    c0108233 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c01082e9:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c01082ed:	e9 41 ff ff ff       	jmp    c0108233 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c01082f2:	8b 45 14             	mov    0x14(%ebp),%eax
c01082f5:	8d 50 04             	lea    0x4(%eax),%edx
c01082f8:	89 55 14             	mov    %edx,0x14(%ebp)
c01082fb:	8b 00                	mov    (%eax),%eax
c01082fd:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108300:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108304:	89 04 24             	mov    %eax,(%esp)
c0108307:	8b 45 08             	mov    0x8(%ebp),%eax
c010830a:	ff d0                	call   *%eax
            break;
c010830c:	e9 ac 02 00 00       	jmp    c01085bd <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0108311:	8b 45 14             	mov    0x14(%ebp),%eax
c0108314:	8d 50 04             	lea    0x4(%eax),%edx
c0108317:	89 55 14             	mov    %edx,0x14(%ebp)
c010831a:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010831c:	85 db                	test   %ebx,%ebx
c010831e:	79 02                	jns    c0108322 <vprintfmt+0x143>
                err = -err;
c0108320:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0108322:	83 fb 06             	cmp    $0x6,%ebx
c0108325:	7f 0b                	jg     c0108332 <vprintfmt+0x153>
c0108327:	8b 34 9d a4 aa 10 c0 	mov    -0x3fef555c(,%ebx,4),%esi
c010832e:	85 f6                	test   %esi,%esi
c0108330:	75 23                	jne    c0108355 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c0108332:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0108336:	c7 44 24 08 d1 aa 10 	movl   $0xc010aad1,0x8(%esp)
c010833d:	c0 
c010833e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108341:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108345:	8b 45 08             	mov    0x8(%ebp),%eax
c0108348:	89 04 24             	mov    %eax,(%esp)
c010834b:	e8 61 fe ff ff       	call   c01081b1 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0108350:	e9 68 02 00 00       	jmp    c01085bd <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c0108355:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0108359:	c7 44 24 08 da aa 10 	movl   $0xc010aada,0x8(%esp)
c0108360:	c0 
c0108361:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108364:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108368:	8b 45 08             	mov    0x8(%ebp),%eax
c010836b:	89 04 24             	mov    %eax,(%esp)
c010836e:	e8 3e fe ff ff       	call   c01081b1 <printfmt>
            }
            break;
c0108373:	e9 45 02 00 00       	jmp    c01085bd <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0108378:	8b 45 14             	mov    0x14(%ebp),%eax
c010837b:	8d 50 04             	lea    0x4(%eax),%edx
c010837e:	89 55 14             	mov    %edx,0x14(%ebp)
c0108381:	8b 30                	mov    (%eax),%esi
c0108383:	85 f6                	test   %esi,%esi
c0108385:	75 05                	jne    c010838c <vprintfmt+0x1ad>
                p = "(null)";
c0108387:	be dd aa 10 c0       	mov    $0xc010aadd,%esi
            }
            if (width > 0 && padc != '-') {
c010838c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108390:	7e 3e                	jle    c01083d0 <vprintfmt+0x1f1>
c0108392:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0108396:	74 38                	je     c01083d0 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0108398:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c010839b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010839e:	89 44 24 04          	mov    %eax,0x4(%esp)
c01083a2:	89 34 24             	mov    %esi,(%esp)
c01083a5:	e8 ed 03 00 00       	call   c0108797 <strnlen>
c01083aa:	29 c3                	sub    %eax,%ebx
c01083ac:	89 d8                	mov    %ebx,%eax
c01083ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01083b1:	eb 17                	jmp    c01083ca <vprintfmt+0x1eb>
                    putch(padc, putdat);
c01083b3:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01083b7:	8b 55 0c             	mov    0xc(%ebp),%edx
c01083ba:	89 54 24 04          	mov    %edx,0x4(%esp)
c01083be:	89 04 24             	mov    %eax,(%esp)
c01083c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01083c4:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c01083c6:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01083ca:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01083ce:	7f e3                	jg     c01083b3 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01083d0:	eb 38                	jmp    c010840a <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c01083d2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01083d6:	74 1f                	je     c01083f7 <vprintfmt+0x218>
c01083d8:	83 fb 1f             	cmp    $0x1f,%ebx
c01083db:	7e 05                	jle    c01083e2 <vprintfmt+0x203>
c01083dd:	83 fb 7e             	cmp    $0x7e,%ebx
c01083e0:	7e 15                	jle    c01083f7 <vprintfmt+0x218>
                    putch('?', putdat);
c01083e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01083e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01083e9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c01083f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01083f3:	ff d0                	call   *%eax
c01083f5:	eb 0f                	jmp    c0108406 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c01083f7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01083fa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01083fe:	89 1c 24             	mov    %ebx,(%esp)
c0108401:	8b 45 08             	mov    0x8(%ebp),%eax
c0108404:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0108406:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010840a:	89 f0                	mov    %esi,%eax
c010840c:	8d 70 01             	lea    0x1(%eax),%esi
c010840f:	0f b6 00             	movzbl (%eax),%eax
c0108412:	0f be d8             	movsbl %al,%ebx
c0108415:	85 db                	test   %ebx,%ebx
c0108417:	74 10                	je     c0108429 <vprintfmt+0x24a>
c0108419:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010841d:	78 b3                	js     c01083d2 <vprintfmt+0x1f3>
c010841f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c0108423:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108427:	79 a9                	jns    c01083d2 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0108429:	eb 17                	jmp    c0108442 <vprintfmt+0x263>
                putch(' ', putdat);
c010842b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010842e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108432:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0108439:	8b 45 08             	mov    0x8(%ebp),%eax
c010843c:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010843e:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0108442:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108446:	7f e3                	jg     c010842b <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c0108448:	e9 70 01 00 00       	jmp    c01085bd <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010844d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108450:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108454:	8d 45 14             	lea    0x14(%ebp),%eax
c0108457:	89 04 24             	mov    %eax,(%esp)
c010845a:	e8 0b fd ff ff       	call   c010816a <getint>
c010845f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108462:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0108465:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108468:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010846b:	85 d2                	test   %edx,%edx
c010846d:	79 26                	jns    c0108495 <vprintfmt+0x2b6>
                putch('-', putdat);
c010846f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108472:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108476:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010847d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108480:	ff d0                	call   *%eax
                num = -(long long)num;
c0108482:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108485:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108488:	f7 d8                	neg    %eax
c010848a:	83 d2 00             	adc    $0x0,%edx
c010848d:	f7 da                	neg    %edx
c010848f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108492:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0108495:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010849c:	e9 a8 00 00 00       	jmp    c0108549 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01084a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01084a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084a8:	8d 45 14             	lea    0x14(%ebp),%eax
c01084ab:	89 04 24             	mov    %eax,(%esp)
c01084ae:	e8 68 fc ff ff       	call   c010811b <getuint>
c01084b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01084b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01084b9:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01084c0:	e9 84 00 00 00       	jmp    c0108549 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c01084c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01084c8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084cc:	8d 45 14             	lea    0x14(%ebp),%eax
c01084cf:	89 04 24             	mov    %eax,(%esp)
c01084d2:	e8 44 fc ff ff       	call   c010811b <getuint>
c01084d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01084da:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c01084dd:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c01084e4:	eb 63                	jmp    c0108549 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c01084e6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084ed:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c01084f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01084f7:	ff d0                	call   *%eax
            putch('x', putdat);
c01084f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084fc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108500:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0108507:	8b 45 08             	mov    0x8(%ebp),%eax
c010850a:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010850c:	8b 45 14             	mov    0x14(%ebp),%eax
c010850f:	8d 50 04             	lea    0x4(%eax),%edx
c0108512:	89 55 14             	mov    %edx,0x14(%ebp)
c0108515:	8b 00                	mov    (%eax),%eax
c0108517:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010851a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0108521:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0108528:	eb 1f                	jmp    c0108549 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010852a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010852d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108531:	8d 45 14             	lea    0x14(%ebp),%eax
c0108534:	89 04 24             	mov    %eax,(%esp)
c0108537:	e8 df fb ff ff       	call   c010811b <getuint>
c010853c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010853f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0108542:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0108549:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010854d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108550:	89 54 24 18          	mov    %edx,0x18(%esp)
c0108554:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108557:	89 54 24 14          	mov    %edx,0x14(%esp)
c010855b:	89 44 24 10          	mov    %eax,0x10(%esp)
c010855f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108562:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108565:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108569:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010856d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108570:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108574:	8b 45 08             	mov    0x8(%ebp),%eax
c0108577:	89 04 24             	mov    %eax,(%esp)
c010857a:	e8 97 fa ff ff       	call   c0108016 <printnum>
            break;
c010857f:	eb 3c                	jmp    c01085bd <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0108581:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108584:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108588:	89 1c 24             	mov    %ebx,(%esp)
c010858b:	8b 45 08             	mov    0x8(%ebp),%eax
c010858e:	ff d0                	call   *%eax
            break;
c0108590:	eb 2b                	jmp    c01085bd <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0108592:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108595:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108599:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c01085a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01085a3:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c01085a5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01085a9:	eb 04                	jmp    c01085af <vprintfmt+0x3d0>
c01085ab:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01085af:	8b 45 10             	mov    0x10(%ebp),%eax
c01085b2:	83 e8 01             	sub    $0x1,%eax
c01085b5:	0f b6 00             	movzbl (%eax),%eax
c01085b8:	3c 25                	cmp    $0x25,%al
c01085ba:	75 ef                	jne    c01085ab <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c01085bc:	90                   	nop
        }
    }
c01085bd:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01085be:	e9 3e fc ff ff       	jmp    c0108201 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c01085c3:	83 c4 40             	add    $0x40,%esp
c01085c6:	5b                   	pop    %ebx
c01085c7:	5e                   	pop    %esi
c01085c8:	5d                   	pop    %ebp
c01085c9:	c3                   	ret    

c01085ca <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c01085ca:	55                   	push   %ebp
c01085cb:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c01085cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01085d0:	8b 40 08             	mov    0x8(%eax),%eax
c01085d3:	8d 50 01             	lea    0x1(%eax),%edx
c01085d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01085d9:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c01085dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01085df:	8b 10                	mov    (%eax),%edx
c01085e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01085e4:	8b 40 04             	mov    0x4(%eax),%eax
c01085e7:	39 c2                	cmp    %eax,%edx
c01085e9:	73 12                	jae    c01085fd <sprintputch+0x33>
        *b->buf ++ = ch;
c01085eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01085ee:	8b 00                	mov    (%eax),%eax
c01085f0:	8d 48 01             	lea    0x1(%eax),%ecx
c01085f3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01085f6:	89 0a                	mov    %ecx,(%edx)
c01085f8:	8b 55 08             	mov    0x8(%ebp),%edx
c01085fb:	88 10                	mov    %dl,(%eax)
    }
}
c01085fd:	5d                   	pop    %ebp
c01085fe:	c3                   	ret    

c01085ff <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c01085ff:	55                   	push   %ebp
c0108600:	89 e5                	mov    %esp,%ebp
c0108602:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0108605:	8d 45 14             	lea    0x14(%ebp),%eax
c0108608:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010860b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010860e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108612:	8b 45 10             	mov    0x10(%ebp),%eax
c0108615:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108619:	8b 45 0c             	mov    0xc(%ebp),%eax
c010861c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108620:	8b 45 08             	mov    0x8(%ebp),%eax
c0108623:	89 04 24             	mov    %eax,(%esp)
c0108626:	e8 08 00 00 00       	call   c0108633 <vsnprintf>
c010862b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010862e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108631:	c9                   	leave  
c0108632:	c3                   	ret    

c0108633 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0108633:	55                   	push   %ebp
c0108634:	89 e5                	mov    %esp,%ebp
c0108636:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0108639:	8b 45 08             	mov    0x8(%ebp),%eax
c010863c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010863f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108642:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108645:	8b 45 08             	mov    0x8(%ebp),%eax
c0108648:	01 d0                	add    %edx,%eax
c010864a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010864d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0108654:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108658:	74 0a                	je     c0108664 <vsnprintf+0x31>
c010865a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010865d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108660:	39 c2                	cmp    %eax,%edx
c0108662:	76 07                	jbe    c010866b <vsnprintf+0x38>
        return -E_INVAL;
c0108664:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0108669:	eb 2a                	jmp    c0108695 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010866b:	8b 45 14             	mov    0x14(%ebp),%eax
c010866e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108672:	8b 45 10             	mov    0x10(%ebp),%eax
c0108675:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108679:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010867c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108680:	c7 04 24 ca 85 10 c0 	movl   $0xc01085ca,(%esp)
c0108687:	e8 53 fb ff ff       	call   c01081df <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010868c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010868f:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0108692:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108695:	c9                   	leave  
c0108696:	c3                   	ret    

c0108697 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c0108697:	55                   	push   %ebp
c0108698:	89 e5                	mov    %esp,%ebp
c010869a:	57                   	push   %edi
c010869b:	56                   	push   %esi
c010869c:	53                   	push   %ebx
c010869d:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c01086a0:	a1 60 0a 12 c0       	mov    0xc0120a60,%eax
c01086a5:	8b 15 64 0a 12 c0    	mov    0xc0120a64,%edx
c01086ab:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c01086b1:	6b f0 05             	imul   $0x5,%eax,%esi
c01086b4:	01 f7                	add    %esi,%edi
c01086b6:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
c01086bb:	f7 e6                	mul    %esi
c01086bd:	8d 34 17             	lea    (%edi,%edx,1),%esi
c01086c0:	89 f2                	mov    %esi,%edx
c01086c2:	83 c0 0b             	add    $0xb,%eax
c01086c5:	83 d2 00             	adc    $0x0,%edx
c01086c8:	89 c7                	mov    %eax,%edi
c01086ca:	83 e7 ff             	and    $0xffffffff,%edi
c01086cd:	89 f9                	mov    %edi,%ecx
c01086cf:	0f b7 da             	movzwl %dx,%ebx
c01086d2:	89 0d 60 0a 12 c0    	mov    %ecx,0xc0120a60
c01086d8:	89 1d 64 0a 12 c0    	mov    %ebx,0xc0120a64
    unsigned long long result = (next >> 12);
c01086de:	a1 60 0a 12 c0       	mov    0xc0120a60,%eax
c01086e3:	8b 15 64 0a 12 c0    	mov    0xc0120a64,%edx
c01086e9:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01086ed:	c1 ea 0c             	shr    $0xc,%edx
c01086f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01086f3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c01086f6:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c01086fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108700:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108703:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108706:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108709:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010870c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010870f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108713:	74 1c                	je     c0108731 <rand+0x9a>
c0108715:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108718:	ba 00 00 00 00       	mov    $0x0,%edx
c010871d:	f7 75 dc             	divl   -0x24(%ebp)
c0108720:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0108723:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108726:	ba 00 00 00 00       	mov    $0x0,%edx
c010872b:	f7 75 dc             	divl   -0x24(%ebp)
c010872e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108731:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108734:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108737:	f7 75 dc             	divl   -0x24(%ebp)
c010873a:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010873d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108740:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108743:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108746:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108749:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010874c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010874f:	83 c4 24             	add    $0x24,%esp
c0108752:	5b                   	pop    %ebx
c0108753:	5e                   	pop    %esi
c0108754:	5f                   	pop    %edi
c0108755:	5d                   	pop    %ebp
c0108756:	c3                   	ret    

c0108757 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c0108757:	55                   	push   %ebp
c0108758:	89 e5                	mov    %esp,%ebp
    next = seed;
c010875a:	8b 45 08             	mov    0x8(%ebp),%eax
c010875d:	ba 00 00 00 00       	mov    $0x0,%edx
c0108762:	a3 60 0a 12 c0       	mov    %eax,0xc0120a60
c0108767:	89 15 64 0a 12 c0    	mov    %edx,0xc0120a64
}
c010876d:	5d                   	pop    %ebp
c010876e:	c3                   	ret    

c010876f <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010876f:	55                   	push   %ebp
c0108770:	89 e5                	mov    %esp,%ebp
c0108772:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108775:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010877c:	eb 04                	jmp    c0108782 <strlen+0x13>
        cnt ++;
c010877e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0108782:	8b 45 08             	mov    0x8(%ebp),%eax
c0108785:	8d 50 01             	lea    0x1(%eax),%edx
c0108788:	89 55 08             	mov    %edx,0x8(%ebp)
c010878b:	0f b6 00             	movzbl (%eax),%eax
c010878e:	84 c0                	test   %al,%al
c0108790:	75 ec                	jne    c010877e <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0108792:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108795:	c9                   	leave  
c0108796:	c3                   	ret    

c0108797 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0108797:	55                   	push   %ebp
c0108798:	89 e5                	mov    %esp,%ebp
c010879a:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010879d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c01087a4:	eb 04                	jmp    c01087aa <strnlen+0x13>
        cnt ++;
c01087a6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c01087aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01087ad:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01087b0:	73 10                	jae    c01087c2 <strnlen+0x2b>
c01087b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01087b5:	8d 50 01             	lea    0x1(%eax),%edx
c01087b8:	89 55 08             	mov    %edx,0x8(%ebp)
c01087bb:	0f b6 00             	movzbl (%eax),%eax
c01087be:	84 c0                	test   %al,%al
c01087c0:	75 e4                	jne    c01087a6 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c01087c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01087c5:	c9                   	leave  
c01087c6:	c3                   	ret    

c01087c7 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c01087c7:	55                   	push   %ebp
c01087c8:	89 e5                	mov    %esp,%ebp
c01087ca:	57                   	push   %edi
c01087cb:	56                   	push   %esi
c01087cc:	83 ec 20             	sub    $0x20,%esp
c01087cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01087d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01087d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01087d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c01087db:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01087de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01087e1:	89 d1                	mov    %edx,%ecx
c01087e3:	89 c2                	mov    %eax,%edx
c01087e5:	89 ce                	mov    %ecx,%esi
c01087e7:	89 d7                	mov    %edx,%edi
c01087e9:	ac                   	lods   %ds:(%esi),%al
c01087ea:	aa                   	stos   %al,%es:(%edi)
c01087eb:	84 c0                	test   %al,%al
c01087ed:	75 fa                	jne    c01087e9 <strcpy+0x22>
c01087ef:	89 fa                	mov    %edi,%edx
c01087f1:	89 f1                	mov    %esi,%ecx
c01087f3:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01087f6:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01087f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c01087fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c01087ff:	83 c4 20             	add    $0x20,%esp
c0108802:	5e                   	pop    %esi
c0108803:	5f                   	pop    %edi
c0108804:	5d                   	pop    %ebp
c0108805:	c3                   	ret    

c0108806 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0108806:	55                   	push   %ebp
c0108807:	89 e5                	mov    %esp,%ebp
c0108809:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010880c:	8b 45 08             	mov    0x8(%ebp),%eax
c010880f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0108812:	eb 21                	jmp    c0108835 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0108814:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108817:	0f b6 10             	movzbl (%eax),%edx
c010881a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010881d:	88 10                	mov    %dl,(%eax)
c010881f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108822:	0f b6 00             	movzbl (%eax),%eax
c0108825:	84 c0                	test   %al,%al
c0108827:	74 04                	je     c010882d <strncpy+0x27>
            src ++;
c0108829:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c010882d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0108831:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0108835:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108839:	75 d9                	jne    c0108814 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c010883b:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010883e:	c9                   	leave  
c010883f:	c3                   	ret    

c0108840 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0108840:	55                   	push   %ebp
c0108841:	89 e5                	mov    %esp,%ebp
c0108843:	57                   	push   %edi
c0108844:	56                   	push   %esi
c0108845:	83 ec 20             	sub    $0x20,%esp
c0108848:	8b 45 08             	mov    0x8(%ebp),%eax
c010884b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010884e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108851:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0108854:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108857:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010885a:	89 d1                	mov    %edx,%ecx
c010885c:	89 c2                	mov    %eax,%edx
c010885e:	89 ce                	mov    %ecx,%esi
c0108860:	89 d7                	mov    %edx,%edi
c0108862:	ac                   	lods   %ds:(%esi),%al
c0108863:	ae                   	scas   %es:(%edi),%al
c0108864:	75 08                	jne    c010886e <strcmp+0x2e>
c0108866:	84 c0                	test   %al,%al
c0108868:	75 f8                	jne    c0108862 <strcmp+0x22>
c010886a:	31 c0                	xor    %eax,%eax
c010886c:	eb 04                	jmp    c0108872 <strcmp+0x32>
c010886e:	19 c0                	sbb    %eax,%eax
c0108870:	0c 01                	or     $0x1,%al
c0108872:	89 fa                	mov    %edi,%edx
c0108874:	89 f1                	mov    %esi,%ecx
c0108876:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108879:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010887c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c010887f:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0108882:	83 c4 20             	add    $0x20,%esp
c0108885:	5e                   	pop    %esi
c0108886:	5f                   	pop    %edi
c0108887:	5d                   	pop    %ebp
c0108888:	c3                   	ret    

c0108889 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0108889:	55                   	push   %ebp
c010888a:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010888c:	eb 0c                	jmp    c010889a <strncmp+0x11>
        n --, s1 ++, s2 ++;
c010888e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0108892:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0108896:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010889a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010889e:	74 1a                	je     c01088ba <strncmp+0x31>
c01088a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01088a3:	0f b6 00             	movzbl (%eax),%eax
c01088a6:	84 c0                	test   %al,%al
c01088a8:	74 10                	je     c01088ba <strncmp+0x31>
c01088aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01088ad:	0f b6 10             	movzbl (%eax),%edx
c01088b0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01088b3:	0f b6 00             	movzbl (%eax),%eax
c01088b6:	38 c2                	cmp    %al,%dl
c01088b8:	74 d4                	je     c010888e <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c01088ba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01088be:	74 18                	je     c01088d8 <strncmp+0x4f>
c01088c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01088c3:	0f b6 00             	movzbl (%eax),%eax
c01088c6:	0f b6 d0             	movzbl %al,%edx
c01088c9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01088cc:	0f b6 00             	movzbl (%eax),%eax
c01088cf:	0f b6 c0             	movzbl %al,%eax
c01088d2:	29 c2                	sub    %eax,%edx
c01088d4:	89 d0                	mov    %edx,%eax
c01088d6:	eb 05                	jmp    c01088dd <strncmp+0x54>
c01088d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01088dd:	5d                   	pop    %ebp
c01088de:	c3                   	ret    

c01088df <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c01088df:	55                   	push   %ebp
c01088e0:	89 e5                	mov    %esp,%ebp
c01088e2:	83 ec 04             	sub    $0x4,%esp
c01088e5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01088e8:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01088eb:	eb 14                	jmp    c0108901 <strchr+0x22>
        if (*s == c) {
c01088ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01088f0:	0f b6 00             	movzbl (%eax),%eax
c01088f3:	3a 45 fc             	cmp    -0x4(%ebp),%al
c01088f6:	75 05                	jne    c01088fd <strchr+0x1e>
            return (char *)s;
c01088f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01088fb:	eb 13                	jmp    c0108910 <strchr+0x31>
        }
        s ++;
c01088fd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0108901:	8b 45 08             	mov    0x8(%ebp),%eax
c0108904:	0f b6 00             	movzbl (%eax),%eax
c0108907:	84 c0                	test   %al,%al
c0108909:	75 e2                	jne    c01088ed <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c010890b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108910:	c9                   	leave  
c0108911:	c3                   	ret    

c0108912 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0108912:	55                   	push   %ebp
c0108913:	89 e5                	mov    %esp,%ebp
c0108915:	83 ec 04             	sub    $0x4,%esp
c0108918:	8b 45 0c             	mov    0xc(%ebp),%eax
c010891b:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010891e:	eb 11                	jmp    c0108931 <strfind+0x1f>
        if (*s == c) {
c0108920:	8b 45 08             	mov    0x8(%ebp),%eax
c0108923:	0f b6 00             	movzbl (%eax),%eax
c0108926:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0108929:	75 02                	jne    c010892d <strfind+0x1b>
            break;
c010892b:	eb 0e                	jmp    c010893b <strfind+0x29>
        }
        s ++;
c010892d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0108931:	8b 45 08             	mov    0x8(%ebp),%eax
c0108934:	0f b6 00             	movzbl (%eax),%eax
c0108937:	84 c0                	test   %al,%al
c0108939:	75 e5                	jne    c0108920 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c010893b:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010893e:	c9                   	leave  
c010893f:	c3                   	ret    

c0108940 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0108940:	55                   	push   %ebp
c0108941:	89 e5                	mov    %esp,%ebp
c0108943:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0108946:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010894d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0108954:	eb 04                	jmp    c010895a <strtol+0x1a>
        s ++;
c0108956:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010895a:	8b 45 08             	mov    0x8(%ebp),%eax
c010895d:	0f b6 00             	movzbl (%eax),%eax
c0108960:	3c 20                	cmp    $0x20,%al
c0108962:	74 f2                	je     c0108956 <strtol+0x16>
c0108964:	8b 45 08             	mov    0x8(%ebp),%eax
c0108967:	0f b6 00             	movzbl (%eax),%eax
c010896a:	3c 09                	cmp    $0x9,%al
c010896c:	74 e8                	je     c0108956 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c010896e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108971:	0f b6 00             	movzbl (%eax),%eax
c0108974:	3c 2b                	cmp    $0x2b,%al
c0108976:	75 06                	jne    c010897e <strtol+0x3e>
        s ++;
c0108978:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010897c:	eb 15                	jmp    c0108993 <strtol+0x53>
    }
    else if (*s == '-') {
c010897e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108981:	0f b6 00             	movzbl (%eax),%eax
c0108984:	3c 2d                	cmp    $0x2d,%al
c0108986:	75 0b                	jne    c0108993 <strtol+0x53>
        s ++, neg = 1;
c0108988:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010898c:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0108993:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108997:	74 06                	je     c010899f <strtol+0x5f>
c0108999:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010899d:	75 24                	jne    c01089c3 <strtol+0x83>
c010899f:	8b 45 08             	mov    0x8(%ebp),%eax
c01089a2:	0f b6 00             	movzbl (%eax),%eax
c01089a5:	3c 30                	cmp    $0x30,%al
c01089a7:	75 1a                	jne    c01089c3 <strtol+0x83>
c01089a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01089ac:	83 c0 01             	add    $0x1,%eax
c01089af:	0f b6 00             	movzbl (%eax),%eax
c01089b2:	3c 78                	cmp    $0x78,%al
c01089b4:	75 0d                	jne    c01089c3 <strtol+0x83>
        s += 2, base = 16;
c01089b6:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c01089ba:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c01089c1:	eb 2a                	jmp    c01089ed <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c01089c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01089c7:	75 17                	jne    c01089e0 <strtol+0xa0>
c01089c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01089cc:	0f b6 00             	movzbl (%eax),%eax
c01089cf:	3c 30                	cmp    $0x30,%al
c01089d1:	75 0d                	jne    c01089e0 <strtol+0xa0>
        s ++, base = 8;
c01089d3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01089d7:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c01089de:	eb 0d                	jmp    c01089ed <strtol+0xad>
    }
    else if (base == 0) {
c01089e0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01089e4:	75 07                	jne    c01089ed <strtol+0xad>
        base = 10;
c01089e6:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c01089ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01089f0:	0f b6 00             	movzbl (%eax),%eax
c01089f3:	3c 2f                	cmp    $0x2f,%al
c01089f5:	7e 1b                	jle    c0108a12 <strtol+0xd2>
c01089f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01089fa:	0f b6 00             	movzbl (%eax),%eax
c01089fd:	3c 39                	cmp    $0x39,%al
c01089ff:	7f 11                	jg     c0108a12 <strtol+0xd2>
            dig = *s - '0';
c0108a01:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a04:	0f b6 00             	movzbl (%eax),%eax
c0108a07:	0f be c0             	movsbl %al,%eax
c0108a0a:	83 e8 30             	sub    $0x30,%eax
c0108a0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108a10:	eb 48                	jmp    c0108a5a <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0108a12:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a15:	0f b6 00             	movzbl (%eax),%eax
c0108a18:	3c 60                	cmp    $0x60,%al
c0108a1a:	7e 1b                	jle    c0108a37 <strtol+0xf7>
c0108a1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a1f:	0f b6 00             	movzbl (%eax),%eax
c0108a22:	3c 7a                	cmp    $0x7a,%al
c0108a24:	7f 11                	jg     c0108a37 <strtol+0xf7>
            dig = *s - 'a' + 10;
c0108a26:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a29:	0f b6 00             	movzbl (%eax),%eax
c0108a2c:	0f be c0             	movsbl %al,%eax
c0108a2f:	83 e8 57             	sub    $0x57,%eax
c0108a32:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108a35:	eb 23                	jmp    c0108a5a <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0108a37:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a3a:	0f b6 00             	movzbl (%eax),%eax
c0108a3d:	3c 40                	cmp    $0x40,%al
c0108a3f:	7e 3d                	jle    c0108a7e <strtol+0x13e>
c0108a41:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a44:	0f b6 00             	movzbl (%eax),%eax
c0108a47:	3c 5a                	cmp    $0x5a,%al
c0108a49:	7f 33                	jg     c0108a7e <strtol+0x13e>
            dig = *s - 'A' + 10;
c0108a4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a4e:	0f b6 00             	movzbl (%eax),%eax
c0108a51:	0f be c0             	movsbl %al,%eax
c0108a54:	83 e8 37             	sub    $0x37,%eax
c0108a57:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0108a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a5d:	3b 45 10             	cmp    0x10(%ebp),%eax
c0108a60:	7c 02                	jl     c0108a64 <strtol+0x124>
            break;
c0108a62:	eb 1a                	jmp    c0108a7e <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c0108a64:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0108a68:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108a6b:	0f af 45 10          	imul   0x10(%ebp),%eax
c0108a6f:	89 c2                	mov    %eax,%edx
c0108a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a74:	01 d0                	add    %edx,%eax
c0108a76:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0108a79:	e9 6f ff ff ff       	jmp    c01089ed <strtol+0xad>

    if (endptr) {
c0108a7e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108a82:	74 08                	je     c0108a8c <strtol+0x14c>
        *endptr = (char *) s;
c0108a84:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a87:	8b 55 08             	mov    0x8(%ebp),%edx
c0108a8a:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0108a8c:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108a90:	74 07                	je     c0108a99 <strtol+0x159>
c0108a92:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108a95:	f7 d8                	neg    %eax
c0108a97:	eb 03                	jmp    c0108a9c <strtol+0x15c>
c0108a99:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0108a9c:	c9                   	leave  
c0108a9d:	c3                   	ret    

c0108a9e <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0108a9e:	55                   	push   %ebp
c0108a9f:	89 e5                	mov    %esp,%ebp
c0108aa1:	57                   	push   %edi
c0108aa2:	83 ec 24             	sub    $0x24,%esp
c0108aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108aa8:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0108aab:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0108aaf:	8b 55 08             	mov    0x8(%ebp),%edx
c0108ab2:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0108ab5:	88 45 f7             	mov    %al,-0x9(%ebp)
c0108ab8:	8b 45 10             	mov    0x10(%ebp),%eax
c0108abb:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0108abe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0108ac1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0108ac5:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0108ac8:	89 d7                	mov    %edx,%edi
c0108aca:	f3 aa                	rep stos %al,%es:(%edi)
c0108acc:	89 fa                	mov    %edi,%edx
c0108ace:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0108ad1:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0108ad4:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0108ad7:	83 c4 24             	add    $0x24,%esp
c0108ada:	5f                   	pop    %edi
c0108adb:	5d                   	pop    %ebp
c0108adc:	c3                   	ret    

c0108add <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0108add:	55                   	push   %ebp
c0108ade:	89 e5                	mov    %esp,%ebp
c0108ae0:	57                   	push   %edi
c0108ae1:	56                   	push   %esi
c0108ae2:	53                   	push   %ebx
c0108ae3:	83 ec 30             	sub    $0x30,%esp
c0108ae6:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ae9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108aec:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108aef:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108af2:	8b 45 10             	mov    0x10(%ebp),%eax
c0108af5:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0108af8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108afb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108afe:	73 42                	jae    c0108b42 <memmove+0x65>
c0108b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b03:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108b06:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108b09:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108b0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b0f:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0108b12:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108b15:	c1 e8 02             	shr    $0x2,%eax
c0108b18:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0108b1a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108b1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108b20:	89 d7                	mov    %edx,%edi
c0108b22:	89 c6                	mov    %eax,%esi
c0108b24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108b26:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0108b29:	83 e1 03             	and    $0x3,%ecx
c0108b2c:	74 02                	je     c0108b30 <memmove+0x53>
c0108b2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108b30:	89 f0                	mov    %esi,%eax
c0108b32:	89 fa                	mov    %edi,%edx
c0108b34:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0108b37:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108b3a:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0108b3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108b40:	eb 36                	jmp    c0108b78 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0108b42:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b45:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108b48:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108b4b:	01 c2                	add    %eax,%edx
c0108b4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b50:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0108b53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b56:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0108b59:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b5c:	89 c1                	mov    %eax,%ecx
c0108b5e:	89 d8                	mov    %ebx,%eax
c0108b60:	89 d6                	mov    %edx,%esi
c0108b62:	89 c7                	mov    %eax,%edi
c0108b64:	fd                   	std    
c0108b65:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108b67:	fc                   	cld    
c0108b68:	89 f8                	mov    %edi,%eax
c0108b6a:	89 f2                	mov    %esi,%edx
c0108b6c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0108b6f:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0108b72:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0108b75:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0108b78:	83 c4 30             	add    $0x30,%esp
c0108b7b:	5b                   	pop    %ebx
c0108b7c:	5e                   	pop    %esi
c0108b7d:	5f                   	pop    %edi
c0108b7e:	5d                   	pop    %ebp
c0108b7f:	c3                   	ret    

c0108b80 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0108b80:	55                   	push   %ebp
c0108b81:	89 e5                	mov    %esp,%ebp
c0108b83:	57                   	push   %edi
c0108b84:	56                   	push   %esi
c0108b85:	83 ec 20             	sub    $0x20,%esp
c0108b88:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b91:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108b94:	8b 45 10             	mov    0x10(%ebp),%eax
c0108b97:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0108b9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108b9d:	c1 e8 02             	shr    $0x2,%eax
c0108ba0:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0108ba2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ba8:	89 d7                	mov    %edx,%edi
c0108baa:	89 c6                	mov    %eax,%esi
c0108bac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108bae:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0108bb1:	83 e1 03             	and    $0x3,%ecx
c0108bb4:	74 02                	je     c0108bb8 <memcpy+0x38>
c0108bb6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108bb8:	89 f0                	mov    %esi,%eax
c0108bba:	89 fa                	mov    %edi,%edx
c0108bbc:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0108bbf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108bc2:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0108bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0108bc8:	83 c4 20             	add    $0x20,%esp
c0108bcb:	5e                   	pop    %esi
c0108bcc:	5f                   	pop    %edi
c0108bcd:	5d                   	pop    %ebp
c0108bce:	c3                   	ret    

c0108bcf <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0108bcf:	55                   	push   %ebp
c0108bd0:	89 e5                	mov    %esp,%ebp
c0108bd2:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0108bd5:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bd8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0108bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108bde:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0108be1:	eb 30                	jmp    c0108c13 <memcmp+0x44>
        if (*s1 != *s2) {
c0108be3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108be6:	0f b6 10             	movzbl (%eax),%edx
c0108be9:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108bec:	0f b6 00             	movzbl (%eax),%eax
c0108bef:	38 c2                	cmp    %al,%dl
c0108bf1:	74 18                	je     c0108c0b <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0108bf3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108bf6:	0f b6 00             	movzbl (%eax),%eax
c0108bf9:	0f b6 d0             	movzbl %al,%edx
c0108bfc:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108bff:	0f b6 00             	movzbl (%eax),%eax
c0108c02:	0f b6 c0             	movzbl %al,%eax
c0108c05:	29 c2                	sub    %eax,%edx
c0108c07:	89 d0                	mov    %edx,%eax
c0108c09:	eb 1a                	jmp    c0108c25 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0108c0b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0108c0f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0108c13:	8b 45 10             	mov    0x10(%ebp),%eax
c0108c16:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108c19:	89 55 10             	mov    %edx,0x10(%ebp)
c0108c1c:	85 c0                	test   %eax,%eax
c0108c1e:	75 c3                	jne    c0108be3 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0108c20:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108c25:	c9                   	leave  
c0108c26:	c3                   	ret    
