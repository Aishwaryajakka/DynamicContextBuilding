	.file	"serial.c"
	.text
.Ltext0:
	.comm	SHMID,4,4
	.comm	SEMID,4,4
	.comm	MessageQueue_ID,4,4
	.comm	TH1_ID,8,8
	.comm	TH2_ID,8,8
	.local	Seminit
	.comm	Seminit,8,8
	.comm	Sensordata,8,8
	.globl	Sensordata_SHM_Addr
	.bss
	.align 8
	.type	Sensordata_SHM_Addr, @object
	.size	Sensordata_SHM_Addr, 8
Sensordata_SHM_Addr:
	.zero	8
	.comm	State,4,4
	.comm	ReceivedDataFromServer,500,32
	.local	sem_opr
	.comm	sem_opr,6,2
	.comm	controldata,16,16
	.comm	UART_fd,4,4
	.comm	TerminalSettings,60,32
	.globl	data
	.data
	.type	data, @object
	.size	data, 5
data:
	.byte	120
	.byte	121
	.byte	122
	.byte	117
	.byte	118
	.section	.rodata
	.align 8
.LC0:
	.string	"TH1 creation failed:UARTPROCESS"
	.align 8
.LC1:
	.string	"TH2 creation failed:UARTPROCESS"
	.align 8
.LC2:
	.string	"UART Process entrted in operational state...."
	.text
	.globl	main
	.type	main, @function
main:
.LFB2:
	.file 1 "serial.c"
	.loc 1 94 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 95 0
	call	SHM_Init
	call	SEM_Init
.L11:
	.loc 1 98 0
	movl	State(%rip), %eax
	cmpl	$1, %eax
	je	.L3
	cmpl	$1, %eax
	jb	.L4
	cmpl	$2, %eax
	je	.L5
	jmp	.L2
.L4:
	.loc 1 101 0
	call	MQ_Init
	testl	%eax, %eax
	jne	.L12
	.loc 1 103 0
	movl	$1, State(%rip)
	.loc 1 105 0
	jmp	.L12
.L3:
	.loc 1 109 0
	call	UART_Init
	testl	%eax, %eax
	jne	.L7
	.loc 1 111 0
	movl	UART_fd(%rip), %eax
	movl	$5, %edx
	movl	$data, %esi
	movl	%eax, %edi
	call	write
	.loc 1 112 0
	movl	$0, %ecx
	movl	$TH1, %edx
	movl	$0, %esi
	movl	$TH1_ID, %edi
	call	pthread_create
	testl	%eax, %eax
	jns	.L8
	.loc 1 114 0
	movl	$.LC0, %edi
	call	perror
.L8:
	.loc 1 116 0
	movl	$0, %ecx
	movl	$TH2, %edx
	movl	$0, %esi
	movl	$TH2_ID, %edi
	call	pthread_create
	testl	%eax, %eax
	jns	.L9
	.loc 1 118 0
	movl	$.LC1, %edi
	call	perror
.L9:
	.loc 1 120 0
	movl	$.LC2, %edi
	call	puts
	.loc 1 121 0
	movl	$2, State(%rip)
	.loc 1 122 0
	nop
	.loc 1 126 0
	jmp	.L2
.L7:
	.loc 1 124 0
	movl	$2, %edi
	call	sleep
	.loc 1 125 0
	jmp	.L3
.L5:
	.loc 1 128 0 discriminator 3
	jmp	.L5
.L12:
	.loc 1 105 0
	nop
.L2:
	.loc 1 131 0 discriminator 1
	jmp	.L11
	.cfi_endproc
.LFE2:
	.size	main, .-main
	.section	.rodata
.LC3:
	.string	"SHM Init failed:UARTPROCESS"
.LC4:
	.string	"SHM Attach failed:UARTPROCESS"
	.text
	.globl	SHM_Init
	.type	SHM_Init, @function
SHM_Init:
.LFB3:
	.loc 1 139 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 140 0
	movl	$1974, %edx
	movl	$8, %esi
	movl	$1122, %edi
	call	shmget
	movl	%eax, SHMID(%rip)
	.loc 1 141 0
	movl	SHMID(%rip), %eax
	testl	%eax, %eax
	jns	.L14
	.loc 1 143 0
	call	__errno_location
	movl	(%rax), %eax
	.loc 1 143 0
	cmpl	$17, %eax
	jne	.L15
	.loc 1 145 0
	movl	$438, %edx
	movl	$8, %esi
	movl	$1122, %edi
	call	shmget
	movl	%eax, SHMID(%rip)
	jmp	.L14
.L15:
	.loc 1 149 0
	movl	$.LC3, %edi
	call	perror
	.loc 1 150 0
	movl	$-1, %eax
	jmp	.L16
.L14:
	.loc 1 154 0
	movl	SHMID(%rip), %eax
	movl	$0, %edx
	movl	$0, %esi
	movl	%eax, %edi
	call	shmat
	movq	%rax, Sensordata_SHM_Addr(%rip)
	.loc 1 156 0
	movq	Sensordata_SHM_Addr(%rip), %rax
	cmpq	$-1, %rax
	jne	.L17
	.loc 1 158 0
	movl	$.LC4, %edi
	call	perror
	.loc 1 159 0
	movl	$-1, %eax
	jmp	.L16
.L17:
	.loc 1 161 0
	movl	$0, %eax
.L16:
	.loc 1 162 0
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	SHM_Init, .-SHM_Init
	.section	.rodata
	.align 8
.LC5:
	.string	"Sem creation failed:UARTPROCESS"
.LC6:
	.string	"Sem init failed:UARTPROCESS"
	.text
	.globl	SEM_Init
	.type	SEM_Init, @function
SEM_Init:
.LFB4:
	.loc 1 167 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 168 0
	movl	$1974, %edx
	movl	$1, %esi
	movl	$3344, %edi
	call	semget
	movl	%eax, SEMID(%rip)
	.loc 1 169 0
	movl	SEMID(%rip), %eax
	testl	%eax, %eax
	jns	.L19
	.loc 1 171 0
	call	__errno_location
	movl	(%rax), %eax
	.loc 1 171 0
	cmpl	$17, %eax
	jne	.L20
	.loc 1 173 0
	movl	$438, %edx
	movl	$1, %esi
	movl	$3344, %edi
	call	semget
	movl	%eax, SEMID(%rip)
	jmp	.L21
.L20:
	.loc 1 177 0
	movl	$.LC5, %edi
	call	perror
	.loc 1 178 0
	movl	$-1, %eax
	jmp	.L22
.L19:
	.loc 1 183 0
	movl	$1, Seminit(%rip)
	.loc 1 184 0
	movl	SEMID(%rip), %eax
	movq	Seminit(%rip), %rcx
	movl	$16, %edx
	movl	$0, %esi
	movl	%eax, %edi
	movl	$0, %eax
	call	semctl
	testl	%eax, %eax
	jns	.L21
	.loc 1 186 0
	movl	$.LC6, %edi
	call	perror
	.loc 1 187 0
	movl	$-1, %eax
	jmp	.L22
.L21:
	.loc 1 190 0
	movl	$0, %eax
.L22:
	.loc 1 191 0
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4:
	.size	SEM_Init, .-SEM_Init
	.section	.rodata
	.align 8
.LC7:
	.string	"Message queue creation failed:UARTPROCESS"
	.text
	.globl	MQ_Init
	.type	MQ_Init, @function
MQ_Init:
.LFB5:
	.loc 1 195 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 196 0
	movl	$950, %esi
	movl	$4455, %edi
	call	msgget
	movl	%eax, MessageQueue_ID(%rip)
	movl	MessageQueue_ID(%rip), %eax
	testl	%eax, %eax
	jns	.L24
	.loc 1 198 0
	movl	$.LC7, %edi
	call	perror
	.loc 1 199 0
	movl	$-1, %eax
	jmp	.L25
.L24:
	.loc 1 201 0
	movl	$0, %eax
.L25:
	.loc 1 202 0
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	MQ_Init, .-MQ_Init
	.section	.rodata
.LC8:
	.string	"/dev/ttyUSB0"
	.align 8
.LC9:
	.string	"Unable to open UARt port:UART_Init:UARTPROCESS"
	.align 8
.LC10:
	.string	"Unable to set UART attribute:UART_Init:UARTPROCESS"
	.text
	.type	UART_Init, @function
UART_Init:
.LFB6:
	.loc 1 207 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 208 0
	movl	$258, %esi
	movl	$.LC8, %edi
	movl	$0, %eax
	call	open
	movl	%eax, UART_fd(%rip)
	movl	UART_fd(%rip), %eax
	testl	%eax, %eax
	jns	.L27
	.loc 1 210 0
	movl	$.LC9, %edi
	call	perror
	movl	UART_fd(%rip), %eax
	movl	%eax, %edi
	call	close
	movl	$-1, %eax
	jmp	.L28
.L27:
	.loc 1 212 0
	movl	UART_fd(%rip), %eax
	movl	$TerminalSettings, %esi
	movl	%eax, %edi
	call	tcgetattr
	.loc 1 213 0
	movl	$13, %esi
	movl	$TerminalSettings, %edi
	call	cfsetospeed
	.loc 1 214 0
	movl	$13, %esi
	movl	$TerminalSettings, %edi
	call	cfsetispeed
	.loc 1 215 0
	movl	TerminalSettings+8(%rip), %eax
	orl	$2176, %eax
	movl	%eax, TerminalSettings+8(%rip)
	.loc 1 216 0
	movl	TerminalSettings+8(%rip), %eax
	andl	$-49, %eax
	movl	%eax, TerminalSettings+8(%rip)
	.loc 1 217 0
	movl	TerminalSettings+8(%rip), %eax
	orl	$48, %eax
	movl	%eax, TerminalSettings+8(%rip)
	.loc 1 218 0
	movl	TerminalSettings+8(%rip), %eax
	andb	$254, %ah
	movl	%eax, TerminalSettings+8(%rip)
	.loc 1 219 0
	movl	TerminalSettings+8(%rip), %eax
	andl	$-65, %eax
	movl	%eax, TerminalSettings+8(%rip)
	.loc 1 220 0
	movl	TerminalSettings+8(%rip), %eax
	andl	$2147483647, %eax
	movl	%eax, TerminalSettings+8(%rip)
	.loc 1 223 0
	movl	TerminalSettings(%rip), %eax
	andl	$-1516, %eax
	movl	%eax, TerminalSettings(%rip)
	.loc 1 224 0
	movl	TerminalSettings+12(%rip), %eax
	andl	$-32844, %eax
	movl	%eax, TerminalSettings+12(%rip)
	.loc 1 225 0
	movl	TerminalSettings+4(%rip), %eax
	andl	$-2, %eax
	movl	%eax, TerminalSettings+4(%rip)
	.loc 1 228 0
	movb	$5, TerminalSettings+23(%rip)
	.loc 1 229 0
	movb	$1, TerminalSettings+22(%rip)
	.loc 1 231 0
	movl	UART_fd(%rip), %eax
	movl	$2048, %edx
	movl	$4, %esi
	movl	%eax, %edi
	movl	$0, %eax
	call	fcntl
	.loc 1 239 0
	movl	UART_fd(%rip), %eax
	movl	$TerminalSettings, %edx
	movl	$0, %esi
	movl	%eax, %edi
	call	tcsetattr
	testl	%eax, %eax
	jns	.L29
	.loc 1 241 0
	movl	$.LC10, %edi
	call	perror
	movl	UART_fd(%rip), %eax
	movl	%eax, %edi
	call	close
	movl	$-1, %eax
	jmp	.L28
.L29:
	.loc 1 243 0
	movl	$0, %eax
.L28:
	.loc 1 244 0
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	UART_Init, .-UART_Init
	.comm	ReceivedUARTData,6,2
	.globl	TH1
	.type	TH1, @function
TH1:
.LFB7:
	.loc 1 273 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	.loc 1 274 0
	movl	$0, %esi
	movl	$0, %edi
	call	pthread_setcancelstate
	.loc 1 275 0
	movl	$0, %esi
	movl	$1, %edi
	call	pthread_setcanceltype
.L32:
	.loc 1 279 0
	call	ReadFromUART
	cmpl	$1, %eax
	jne	.L32
	.loc 1 281 0
	call	ConvertToRealValue
	.loc 1 282 0
	call	StoreToSHM
	.loc 1 284 0
	jmp	.L32
	.cfi_endproc
.LFE7:
	.size	TH1, .-TH1
	.globl	i
	.bss
	.type	i, @object
	.size	i, 1
i:
	.zero	1
	.section	.rodata
.LC11:
	.string	"1st : %x\n"
.LC12:
	.string	"aaa"
	.text
	.type	ReadFromUART, @function
ReadFromUART:
.LFB8:
	.loc 1 294 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	.loc 1 294 0
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	.loc 1 297 0
	movl	UART_fd(%rip), %eax
	leaq	-9(%rbp), %rcx
	movl	$1, %edx
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	read
	testq	%rax, %rax
	jle	.L34
	.loc 1 299 0
	movzbl	i(%rip), %eax
	movzbl	%al, %eax
	movzbl	-9(%rbp), %edx
	cltq
	movb	%dl, ReceivedUARTData(%rax)
	.loc 1 300 0
	movzbl	i(%rip), %eax
	addl	$1, %eax
	movb	%al, i(%rip)
	.loc 1 301 0
	movzbl	i(%rip), %eax
	cmpb	$4, %al
	jbe	.L34
	.loc 1 303 0
	movb	$0, i(%rip)
	.loc 1 304 0
	movzbl	ReceivedUARTData(%rip), %eax
	movzbl	%al, %eax
	movl	%eax, %esi
	movl	$.LC11, %edi
	movl	$0, %eax
	call	printf
	.loc 1 305 0
	movzbl	ReceivedUARTData+1(%rip), %eax
	movzbl	%al, %eax
	movl	%eax, %esi
	movl	$.LC11, %edi
	movl	$0, %eax
	call	printf
	.loc 1 306 0
	movzbl	ReceivedUARTData+2(%rip), %eax
	movzbl	%al, %eax
	movl	%eax, %esi
	movl	$.LC11, %edi
	movl	$0, %eax
	call	printf
	.loc 1 307 0
	movzbl	ReceivedUARTData+3(%rip), %eax
	movzbl	%al, %eax
	movl	%eax, %esi
	movl	$.LC11, %edi
	movl	$0, %eax
	call	printf
	.loc 1 308 0
	movzbl	ReceivedUARTData+4(%rip), %eax
	movzbl	%al, %eax
	movl	%eax, %esi
	movl	$.LC11, %edi
	movl	$0, %eax
	call	printf
	.loc 1 309 0
	movl	$.LC12, %edi
	call	puts
	.loc 1 310 0
	movl	$1, %eax
	jmp	.L36
.L34:
	.loc 1 314 0
	movl	$0, %eax
.L36:
	.loc 1 315 0 discriminator 1
	movq	-8(%rbp), %rcx
	xorq	%fs:40, %rcx
	je	.L37
	.loc 1 315 0 is_stmt 0
	call	__stack_chk_fail
.L37:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	ReadFromUART, .-ReadFromUART
	.section	.rodata
.LC14:
	.string	"Smoke data in UART : %u\n"
.LC15:
	.string	"IRS data in UART : %u\n"
	.text
	.globl	ConvertToRealValue
	.type	ConvertToRealValue, @function
ConvertToRealValue:
.LFB9:
	.loc 1 319 0 is_stmt 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 327 0
	movzwl	ReceivedUARTData+2(%rip), %eax
	movzwl	%ax, %eax
	imull	$500, %eax, %eax
	pxor	%xmm0, %xmm0
	cvtsi2sd	%eax, %xmm0
	movsd	.LC13(%rip), %xmm1
	divsd	%xmm1, %xmm0
	cvtsd2ss	%xmm0, %xmm0
	movss	%xmm0, Sensordata(%rip)
	.loc 1 328 0
	movzbl	ReceivedUARTData+3(%rip), %eax
	movzbl	%al, %eax
	movw	%ax, Sensordata+6(%rip)
	.loc 1 329 0
	movzwl	Sensordata+6(%rip), %eax
	movzwl	%ax, %eax
	movl	%eax, %esi
	movl	$.LC14, %edi
	movl	$0, %eax
	call	printf
	.loc 1 330 0
	movzbl	ReceivedUARTData+4(%rip), %eax
	movzbl	%al, %eax
	movw	%ax, Sensordata+4(%rip)
	.loc 1 331 0
	movzwl	Sensordata+4(%rip), %eax
	movzwl	%ax, %eax
	movl	%eax, %esi
	movl	$.LC15, %edi
	movl	$0, %eax
	call	printf
	.loc 1 332 0
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	ConvertToRealValue, .-ConvertToRealValue
	.section	.rodata
.LC16:
	.string	"e123"
	.align 8
.LC17:
	.string	"Sem locking failed:StoreToSHM:UARTPROCESS"
	.align 8
.LC18:
	.string	"Smoke data stored in SHM : %u\n"
.LC19:
	.string	"IR data stored in SHM : %u\n"
	.align 8
.LC20:
	.string	"Sem release failed:StoreToSHM:UARTPROCESS"
	.text
	.globl	StoreToSHM
	.type	StoreToSHM, @function
StoreToSHM:
.LFB10:
	.loc 1 337 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 338 0
	movl	$.LC16, %edi
	call	puts
	.loc 1 339 0
	movw	$0, sem_opr(%rip)
	.loc 1 340 0
	movw	$-1, sem_opr+2(%rip)
	.loc 1 341 0
	movw	$4096, sem_opr+4(%rip)
	.loc 1 342 0
	movl	SEMID(%rip), %eax
	movl	$1, %edx
	movl	$sem_opr, %esi
	movl	%eax, %edi
	call	semop
	testl	%eax, %eax
	jns	.L40
	.loc 1 344 0
	movl	$.LC17, %edi
	call	perror
.L40:
	.loc 1 347 0
	movq	Sensordata_SHM_Addr(%rip), %rax
	movss	Sensordata(%rip), %xmm0
	movss	%xmm0, (%rax)
	.loc 1 349 0
	movq	Sensordata_SHM_Addr(%rip), %rax
	movzwl	Sensordata+6(%rip), %edx
	movw	%dx, 6(%rax)
	.loc 1 350 0
	movq	Sensordata_SHM_Addr(%rip), %rax
	movzwl	6(%rax), %eax
	movzwl	%ax, %eax
	movl	%eax, %esi
	movl	$.LC18, %edi
	movl	$0, %eax
	call	printf
	.loc 1 351 0
	movq	Sensordata_SHM_Addr(%rip), %rax
	movzwl	Sensordata+4(%rip), %edx
	movw	%dx, 4(%rax)
	.loc 1 352 0
	movq	Sensordata_SHM_Addr(%rip), %rax
	movzwl	4(%rax), %eax
	movzwl	%ax, %eax
	movl	%eax, %esi
	movl	$.LC19, %edi
	movl	$0, %eax
	call	printf
	.loc 1 354 0
	movw	$0, sem_opr(%rip)
	.loc 1 355 0
	movw	$1, sem_opr+2(%rip)
	.loc 1 356 0
	movw	$4096, sem_opr+4(%rip)
	.loc 1 357 0
	movl	SEMID(%rip), %eax
	movl	$1, %edx
	movl	$sem_opr, %esi
	movl	%eax, %edi
	call	semop
	testl	%eax, %eax
	jns	.L42
	.loc 1 359 0
	movl	$.LC20, %edi
	call	perror
.L42:
	.loc 1 361 0
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE10:
	.size	StoreToSHM, .-StoreToSHM
	.globl	count
	.bss
	.align 2
	.type	count, @object
	.size	count, 2
count:
	.zero	2
	.local	control_data_received
	.comm	control_data_received,4,4
	.local	BufferToBeSentToAudrino
	.comm	BufferToBeSentToAudrino,5,1
	.section	.rodata
	.align 8
.LC21:
	.string	"Unable to receive control data through MSGQ from Socket client Process:TH2:UARTPROCESS"
	.align 8
.LC22:
	.string	"Control data received in UART process...."
.LC23:
	.string	"light : %u\n"
.LC24:
	.string	"lock : %u\n"
.LC25:
	.string	"fan : %u\n"
.LC26:
	.string	"alarm : %u\n"
	.text
	.globl	TH2
	.type	TH2, @function
TH2:
.LFB11:
	.loc 1 378 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	.loc 1 379 0
	movl	$0, %esi
	movl	$0, %edi
	call	pthread_setcancelstate
	.loc 1 380 0
	movl	$0, %esi
	movl	$1, %edi
	call	pthread_setcanceltype
.L51:
	.loc 1 384 0
	movzwl	count(%rip), %eax
	cmpw	$1, %ax
	jbe	.L44
	.loc 1 384 0 is_stmt 0 discriminator 1
	movw	$0, count(%rip)
.L44:
	.loc 1 385 0 is_stmt 1
	movzwl	count(%rip), %eax
	movzwl	%ax, %eax
	testl	%eax, %eax
	je	.L46
	cmpl	$1, %eax
	je	.L47
	jmp	.L45
.L46:
	.loc 1 388 0
	movl	MessageQueue_ID(%rip), %eax
	movl	$0, %r8d
	movl	$0, %ecx
	movl	$4, %edx
	movl	$controldata, %esi
	movl	%eax, %edi
	call	msgrcv
	testq	%rax, %rax
	jns	.L48
	.loc 1 390 0
	movl	$.LC21, %edi
	call	perror
	.loc 1 408 0
	jmp	.L45
.L48:
	.loc 1 394 0
	movl	$1, control_data_received(%rip)
	.loc 1 395 0
	movl	$.LC22, %edi
	call	puts
	.loc 1 396 0
	movzbl	controldata+8(%rip), %eax
	movzbl	%al, %eax
	movl	%eax, %esi
	movl	$.LC23, %edi
	movl	$0, %eax
	call	printf
	.loc 1 397 0
	movzbl	controldata+9(%rip), %eax
	movzbl	%al, %eax
	movl	%eax, %esi
	movl	$.LC24, %edi
	movl	$0, %eax
	call	printf
	.loc 1 398 0
	movzbl	controldata+10(%rip), %eax
	movzbl	%al, %eax
	movl	%eax, %esi
	movl	$.LC25, %edi
	movl	$0, %eax
	call	printf
	.loc 1 399 0
	movzbl	controldata+11(%rip), %eax
	movzbl	%al, %eax
	movl	%eax, %esi
	movl	$.LC26, %edi
	movl	$0, %eax
	call	printf
	.loc 1 408 0
	jmp	.L45
.L47:
	.loc 1 413 0
	movl	control_data_received(%rip), %eax
	cmpl	$1, %eax
	jne	.L52
	.loc 1 415 0
	call	convert_to_uart_format
	.loc 1 416 0
	call	SendToAudrino
	.loc 1 417 0
	movl	$0, control_data_received(%rip)
.L52:
	.loc 1 419 0
	nop
.L45:
	.loc 1 421 0
	movzwl	count(%rip), %eax
	addl	$1, %eax
	movw	%ax, count(%rip)
	.loc 1 422 0
	jmp	.L51
	.cfi_endproc
.LFE11:
	.size	TH2, .-TH2
	.globl	convert_to_uart_format
	.type	convert_to_uart_format, @function
convert_to_uart_format:
.LFB12:
	.loc 1 430 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 431 0
	movb	$-85, BufferToBeSentToAudrino(%rip)
	.loc 1 432 0
	movzbl	controldata+8(%rip), %eax
	movb	%al, BufferToBeSentToAudrino+1(%rip)
	.loc 1 433 0
	movzbl	controldata+9(%rip), %eax
	movb	%al, BufferToBeSentToAudrino+2(%rip)
	.loc 1 434 0
	movzbl	controldata+10(%rip), %eax
	movb	%al, BufferToBeSentToAudrino+3(%rip)
	.loc 1 435 0
	movzbl	controldata+11(%rip), %eax
	movb	%al, BufferToBeSentToAudrino+4(%rip)
	.loc 1 437 0
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE12:
	.size	convert_to_uart_format, .-convert_to_uart_format
	.section	.rodata
	.align 8
.LC27:
	.string	"Unable to send data to audrino:SendToAudrino:UARTPROCESS"
	.align 8
.LC28:
	.string	"Successfully sent data to audrino..."
	.text
	.globl	SendToAudrino
	.type	SendToAudrino, @function
SendToAudrino:
.LFB13:
	.loc 1 443 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 444 0
	movl	UART_fd(%rip), %eax
	movl	$5, %edx
	movl	$BufferToBeSentToAudrino, %esi
	movl	%eax, %edi
	call	write
	testq	%rax, %rax
	jns	.L55
	.loc 1 446 0
	movl	$.LC27, %edi
	call	perror
	.loc 1 452 0
	jmp	.L57
.L55:
	.loc 1 450 0
	movl	$.LC28, %edi
	call	puts
.L57:
	.loc 1 452 0
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE13:
	.size	SendToAudrino, .-SendToAudrino
	.section	.rodata
	.align 8
.LC13:
	.long	0
	.long	1083179008
	.text
.Letext0:
	.file 2 "/usr/include/x86_64-linux-gnu/bits/types.h"
	.file 3 "/usr/include/x86_64-linux-gnu/bits/ipc.h"
	.file 4 "/usr/include/x86_64-linux-gnu/sys/ipc.h"
	.file 5 "/usr/include/x86_64-linux-gnu/bits/pthreadtypes.h"
	.file 6 "/usr/include/x86_64-linux-gnu/bits/sem.h"
	.file 7 "/usr/include/x86_64-linux-gnu/sys/sem.h"
	.file 8 "/usr/include/pthread.h"
	.file 9 "/usr/include/x86_64-linux-gnu/bits/termios.h"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0x821
	.value	0x4
	.long	.Ldebug_abbrev0
	.byte	0x8
	.uleb128 0x1
	.long	.LASF115
	.byte	0xc
	.long	.LASF116
	.long	.LASF117
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.long	.Ldebug_line0
	.uleb128 0x2
	.byte	0x8
	.byte	0x7
	.long	.LASF0
	.uleb128 0x2
	.byte	0x1
	.byte	0x8
	.long	.LASF1
	.uleb128 0x2
	.byte	0x2
	.byte	0x7
	.long	.LASF2
	.uleb128 0x2
	.byte	0x4
	.byte	0x7
	.long	.LASF3
	.uleb128 0x2
	.byte	0x1
	.byte	0x6
	.long	.LASF4
	.uleb128 0x2
	.byte	0x2
	.byte	0x5
	.long	.LASF5
	.uleb128 0x3
	.byte	0x4
	.byte	0x5
	.string	"int"
	.uleb128 0x2
	.byte	0x8
	.byte	0x5
	.long	.LASF6
	.uleb128 0x4
	.long	.LASF7
	.byte	0x2
	.byte	0x7d
	.long	0x42
	.uleb128 0x4
	.long	.LASF8
	.byte	0x2
	.byte	0x7e
	.long	0x42
	.uleb128 0x2
	.byte	0x8
	.byte	0x7
	.long	.LASF9
	.uleb128 0x4
	.long	.LASF10
	.byte	0x2
	.byte	0x8b
	.long	0x5e
	.uleb128 0x4
	.long	.LASF11
	.byte	0x2
	.byte	0x90
	.long	0x57
	.uleb128 0x5
	.byte	0x8
	.uleb128 0x4
	.long	.LASF12
	.byte	0x2
	.byte	0xb1
	.long	0x2d
	.uleb128 0x2
	.byte	0x1
	.byte	0x6
	.long	.LASF13
	.uleb128 0x6
	.long	.LASF27
	.byte	0x30
	.byte	0x3
	.byte	0x2a
	.long	0x13d
	.uleb128 0x7
	.long	.LASF14
	.byte	0x3
	.byte	0x2c
	.long	0x8d
	.byte	0
	.uleb128 0x8
	.string	"uid"
	.byte	0x3
	.byte	0x2d
	.long	0x65
	.byte	0x4
	.uleb128 0x8
	.string	"gid"
	.byte	0x3
	.byte	0x2e
	.long	0x70
	.byte	0x8
	.uleb128 0x7
	.long	.LASF15
	.byte	0x3
	.byte	0x2f
	.long	0x65
	.byte	0xc
	.uleb128 0x7
	.long	.LASF16
	.byte	0x3
	.byte	0x30
	.long	0x70
	.byte	0x10
	.uleb128 0x7
	.long	.LASF17
	.byte	0x3
	.byte	0x31
	.long	0x3b
	.byte	0x14
	.uleb128 0x7
	.long	.LASF18
	.byte	0x3
	.byte	0x32
	.long	0x3b
	.byte	0x16
	.uleb128 0x7
	.long	.LASF19
	.byte	0x3
	.byte	0x33
	.long	0x3b
	.byte	0x18
	.uleb128 0x7
	.long	.LASF20
	.byte	0x3
	.byte	0x34
	.long	0x3b
	.byte	0x1a
	.uleb128 0x7
	.long	.LASF21
	.byte	0x3
	.byte	0x35
	.long	0x9a
	.byte	0x20
	.uleb128 0x7
	.long	.LASF22
	.byte	0x3
	.byte	0x36
	.long	0x9a
	.byte	0x28
	.byte	0
	.uleb128 0x4
	.long	.LASF23
	.byte	0x4
	.byte	0x2f
	.long	0x8d
	.uleb128 0x4
	.long	.LASF24
	.byte	0x5
	.byte	0x3c
	.long	0x2d
	.uleb128 0x2
	.byte	0x8
	.byte	0x7
	.long	.LASF25
	.uleb128 0x2
	.byte	0x8
	.byte	0x5
	.long	.LASF26
	.uleb128 0x6
	.long	.LASF28
	.byte	0x68
	.byte	0x6
	.byte	0x26
	.long	0x1ce
	.uleb128 0x7
	.long	.LASF29
	.byte	0x6
	.byte	0x28
	.long	0xac
	.byte	0
	.uleb128 0x7
	.long	.LASF30
	.byte	0x6
	.byte	0x29
	.long	0x82
	.byte	0x30
	.uleb128 0x7
	.long	.LASF21
	.byte	0x6
	.byte	0x2a
	.long	0x9a
	.byte	0x38
	.uleb128 0x7
	.long	.LASF31
	.byte	0x6
	.byte	0x2b
	.long	0x82
	.byte	0x40
	.uleb128 0x7
	.long	.LASF22
	.byte	0x6
	.byte	0x2c
	.long	0x9a
	.byte	0x48
	.uleb128 0x7
	.long	.LASF32
	.byte	0x6
	.byte	0x2d
	.long	0x9a
	.byte	0x50
	.uleb128 0x7
	.long	.LASF33
	.byte	0x6
	.byte	0x2e
	.long	0x9a
	.byte	0x58
	.uleb128 0x7
	.long	.LASF34
	.byte	0x6
	.byte	0x2f
	.long	0x9a
	.byte	0x60
	.byte	0
	.uleb128 0x6
	.long	.LASF35
	.byte	0x6
	.byte	0x7
	.byte	0x29
	.long	0x1ff
	.uleb128 0x7
	.long	.LASF36
	.byte	0x7
	.byte	0x2b
	.long	0x3b
	.byte	0
	.uleb128 0x7
	.long	.LASF37
	.byte	0x7
	.byte	0x2c
	.long	0x50
	.byte	0x2
	.uleb128 0x7
	.long	.LASF38
	.byte	0x7
	.byte	0x2d
	.long	0x50
	.byte	0x4
	.byte	0
	.uleb128 0x9
	.byte	0x4
	.long	0x42
	.byte	0x8
	.byte	0xc8
	.long	0x218
	.uleb128 0xa
	.long	.LASF39
	.byte	0
	.uleb128 0xa
	.long	.LASF40
	.byte	0x1
	.byte	0
	.uleb128 0x9
	.byte	0x4
	.long	0x42
	.byte	0x8
	.byte	0xcf
	.long	0x231
	.uleb128 0xa
	.long	.LASF41
	.byte	0
	.uleb128 0xa
	.long	.LASF42
	.byte	0x1
	.byte	0
	.uleb128 0x4
	.long	.LASF43
	.byte	0x9
	.byte	0x17
	.long	0x34
	.uleb128 0x4
	.long	.LASF44
	.byte	0x9
	.byte	0x18
	.long	0x42
	.uleb128 0x4
	.long	.LASF45
	.byte	0x9
	.byte	0x19
	.long	0x42
	.uleb128 0x6
	.long	.LASF46
	.byte	0x3c
	.byte	0x9
	.byte	0x1c
	.long	0x2bf
	.uleb128 0x7
	.long	.LASF47
	.byte	0x9
	.byte	0x1e
	.long	0x247
	.byte	0
	.uleb128 0x7
	.long	.LASF48
	.byte	0x9
	.byte	0x1f
	.long	0x247
	.byte	0x4
	.uleb128 0x7
	.long	.LASF49
	.byte	0x9
	.byte	0x20
	.long	0x247
	.byte	0x8
	.uleb128 0x7
	.long	.LASF50
	.byte	0x9
	.byte	0x21
	.long	0x247
	.byte	0xc
	.uleb128 0x7
	.long	.LASF51
	.byte	0x9
	.byte	0x22
	.long	0x231
	.byte	0x10
	.uleb128 0x7
	.long	.LASF52
	.byte	0x9
	.byte	0x23
	.long	0x2bf
	.byte	0x11
	.uleb128 0x7
	.long	.LASF53
	.byte	0x9
	.byte	0x24
	.long	0x23c
	.byte	0x34
	.uleb128 0x7
	.long	.LASF54
	.byte	0x9
	.byte	0x25
	.long	0x23c
	.byte	0x38
	.byte	0
	.uleb128 0xb
	.long	0x231
	.long	0x2cf
	.uleb128 0xc
	.long	0x7b
	.byte	0x1f
	.byte	0
	.uleb128 0x4
	.long	.LASF55
	.byte	0x1
	.byte	0x18
	.long	0x57
	.uleb128 0x4
	.long	.LASF56
	.byte	0x1
	.byte	0x19
	.long	0x3b
	.uleb128 0x4
	.long	.LASF57
	.byte	0x1
	.byte	0x1b
	.long	0x34
	.uleb128 0xd
	.long	.LASF79
	.byte	0x8
	.byte	0x1
	.byte	0x2b
	.long	0x31e
	.uleb128 0xe
	.string	"val"
	.byte	0x1
	.byte	0x2c
	.long	0x2cf
	.uleb128 0xe
	.string	"buf"
	.byte	0x1
	.byte	0x2d
	.long	0x31e
	.uleb128 0xf
	.long	.LASF58
	.byte	0x1
	.byte	0x2e
	.long	0x324
	.byte	0
	.uleb128 0x10
	.byte	0x8
	.long	0x161
	.uleb128 0x10
	.byte	0x8
	.long	0x2da
	.uleb128 0x11
	.byte	0x8
	.byte	0x1
	.byte	0x31
	.long	0x357
	.uleb128 0x7
	.long	.LASF59
	.byte	0x1
	.byte	0x33
	.long	0x357
	.byte	0
	.uleb128 0x7
	.long	.LASF60
	.byte	0x1
	.byte	0x34
	.long	0x2da
	.byte	0x4
	.uleb128 0x7
	.long	.LASF61
	.byte	0x1
	.byte	0x35
	.long	0x2da
	.byte	0x6
	.byte	0
	.uleb128 0x2
	.byte	0x4
	.byte	0x4
	.long	.LASF62
	.uleb128 0x4
	.long	.LASF63
	.byte	0x1
	.byte	0x36
	.long	0x32a
	.uleb128 0x9
	.byte	0x4
	.long	0x42
	.byte	0x1
	.byte	0x3d
	.long	0x385
	.uleb128 0x12
	.string	"S1"
	.byte	0
	.uleb128 0x12
	.string	"S2"
	.byte	0x1
	.uleb128 0x12
	.string	"S3"
	.byte	0x2
	.byte	0
	.uleb128 0x4
	.long	.LASF64
	.byte	0x1
	.byte	0x3f
	.long	0x369
	.uleb128 0x11
	.byte	0x4
	.byte	0x1
	.byte	0x45
	.long	0x3c9
	.uleb128 0x7
	.long	.LASF65
	.byte	0x1
	.byte	0x47
	.long	0x2e5
	.byte	0
	.uleb128 0x7
	.long	.LASF66
	.byte	0x1
	.byte	0x48
	.long	0x2e5
	.byte	0x1
	.uleb128 0x7
	.long	.LASF67
	.byte	0x1
	.byte	0x49
	.long	0x2e5
	.byte	0x2
	.uleb128 0x7
	.long	.LASF68
	.byte	0x1
	.byte	0x4a
	.long	0x2e5
	.byte	0x3
	.byte	0
	.uleb128 0x4
	.long	.LASF69
	.byte	0x1
	.byte	0x4b
	.long	0x390
	.uleb128 0x11
	.byte	0x10
	.byte	0x1
	.byte	0x4c
	.long	0x3f5
	.uleb128 0x7
	.long	.LASF70
	.byte	0x1
	.byte	0x4e
	.long	0x5e
	.byte	0
	.uleb128 0x7
	.long	.LASF71
	.byte	0x1
	.byte	0x4f
	.long	0x3c9
	.byte	0x8
	.byte	0
	.uleb128 0x4
	.long	.LASF72
	.byte	0x1
	.byte	0x50
	.long	0x3d4
	.uleb128 0x9
	.byte	0x4
	.long	0x42
	.byte	0x1
	.byte	0xfb
	.long	0x418
	.uleb128 0x12
	.string	"NO"
	.byte	0
	.uleb128 0x12
	.string	"YES"
	.byte	0x1
	.byte	0
	.uleb128 0x4
	.long	.LASF73
	.byte	0x1
	.byte	0xfe
	.long	0x400
	.uleb128 0x13
	.byte	0x6
	.byte	0x1
	.value	0x101
	.long	0x461
	.uleb128 0x14
	.long	.LASF74
	.byte	0x1
	.value	0x103
	.long	0x2e5
	.byte	0
	.uleb128 0x14
	.long	.LASF75
	.byte	0x1
	.value	0x104
	.long	0x2da
	.byte	0x2
	.uleb128 0x14
	.long	.LASF76
	.byte	0x1
	.value	0x105
	.long	0x2e5
	.byte	0x4
	.uleb128 0x14
	.long	.LASF77
	.byte	0x1
	.value	0x106
	.long	0x2e5
	.byte	0x5
	.byte	0
	.uleb128 0x15
	.long	.LASF78
	.byte	0x1
	.value	0x107
	.long	0x423
	.uleb128 0x16
	.long	.LASF80
	.byte	0x6
	.byte	0x1
	.value	0x108
	.long	0x493
	.uleb128 0x17
	.long	.LASF81
	.byte	0x1
	.value	0x10a
	.long	0x461
	.uleb128 0x17
	.long	.LASF82
	.byte	0x1
	.value	0x10b
	.long	0x493
	.byte	0
	.uleb128 0xb
	.long	0x2e5
	.long	0x4a3
	.uleb128 0xc
	.long	0x7b
	.byte	0x4
	.byte	0
	.uleb128 0x18
	.byte	0x4
	.long	0x42
	.byte	0x1
	.value	0x171
	.long	0x4bd
	.uleb128 0xa
	.long	.LASF83
	.byte	0
	.uleb128 0xa
	.long	.LASF84
	.byte	0x1
	.byte	0
	.uleb128 0x15
	.long	.LASF85
	.byte	0x1
	.value	0x173
	.long	0x4a3
	.uleb128 0x19
	.long	.LASF89
	.byte	0x1
	.byte	0x5d
	.long	0x2cf
	.quad	.LFB2
	.quad	.LFE2-.LFB2
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x1a
	.long	.LASF86
	.byte	0x1
	.byte	0x8a
	.long	0x2cf
	.quad	.LFB3
	.quad	.LFE3-.LFB3
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x1a
	.long	.LASF87
	.byte	0x1
	.byte	0xa6
	.long	0x2cf
	.quad	.LFB4
	.quad	.LFE4-.LFB4
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x1a
	.long	.LASF88
	.byte	0x1
	.byte	0xc2
	.long	0x2cf
	.quad	.LFB5
	.quad	.LFE5-.LFB5
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x1b
	.long	.LASF118
	.byte	0x1
	.byte	0xce
	.long	0x2cf
	.quad	.LFB6
	.quad	.LFE6-.LFB6
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x1c
	.string	"TH1"
	.byte	0x1
	.value	0x110
	.long	0x98
	.quad	.LFB7
	.quad	.LFE7-.LFB7
	.uleb128 0x1
	.byte	0x9c
	.long	0x58c
	.uleb128 0x1d
	.long	.LASF92
	.byte	0x1
	.value	0x110
	.long	0x98
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.uleb128 0x1e
	.long	.LASF119
	.byte	0x1
	.value	0x125
	.long	0x418
	.quad	.LFB8
	.quad	.LFE8-.LFB8
	.uleb128 0x1
	.byte	0x9c
	.long	0x5bc
	.uleb128 0x1f
	.string	"a"
	.byte	0x1
	.value	0x128
	.long	0x34
	.uleb128 0x2
	.byte	0x91
	.sleb128 -25
	.byte	0
	.uleb128 0x20
	.long	.LASF90
	.byte	0x1
	.value	0x13e
	.quad	.LFB9
	.quad	.LFE9-.LFB9
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x20
	.long	.LASF91
	.byte	0x1
	.value	0x150
	.quad	.LFB10
	.quad	.LFE10-.LFB10
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x1c
	.string	"TH2"
	.byte	0x1
	.value	0x179
	.long	0x98
	.quad	.LFB11
	.quad	.LFE11-.LFB11
	.uleb128 0x1
	.byte	0x9c
	.long	0x622
	.uleb128 0x1d
	.long	.LASF93
	.byte	0x1
	.value	0x179
	.long	0x98
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.uleb128 0x21
	.long	.LASF94
	.byte	0x1
	.value	0x1ad
	.quad	.LFB12
	.quad	.LFE12-.LFB12
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x20
	.long	.LASF95
	.byte	0x1
	.value	0x1ba
	.quad	.LFB13
	.quad	.LFE13-.LFB13
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x22
	.long	.LASF96
	.byte	0x1
	.byte	0x2f
	.long	0x2f0
	.uleb128 0x9
	.byte	0x3
	.quad	Seminit
	.uleb128 0x22
	.long	.LASF97
	.byte	0x1
	.byte	0x43
	.long	0x1ce
	.uleb128 0x9
	.byte	0x3
	.quad	sem_opr
	.uleb128 0x23
	.long	.LASF98
	.byte	0x1
	.value	0x174
	.long	0x4bd
	.uleb128 0x9
	.byte	0x3
	.quad	control_data_received
	.uleb128 0x23
	.long	.LASF99
	.byte	0x1
	.value	0x177
	.long	0x493
	.uleb128 0x9
	.byte	0x3
	.quad	BufferToBeSentToAudrino
	.uleb128 0x24
	.long	.LASF100
	.byte	0x1
	.byte	0x1e
	.long	0x2cf
	.uleb128 0x9
	.byte	0x3
	.quad	SHMID
	.uleb128 0x24
	.long	.LASF101
	.byte	0x1
	.byte	0x1f
	.long	0x2cf
	.uleb128 0x9
	.byte	0x3
	.quad	SEMID
	.uleb128 0x24
	.long	.LASF102
	.byte	0x1
	.byte	0x20
	.long	0x2cf
	.uleb128 0x9
	.byte	0x3
	.quad	MessageQueue_ID
	.uleb128 0x24
	.long	.LASF103
	.byte	0x1
	.byte	0x27
	.long	0x148
	.uleb128 0x9
	.byte	0x3
	.quad	TH1_ID
	.uleb128 0x24
	.long	.LASF104
	.byte	0x1
	.byte	0x28
	.long	0x148
	.uleb128 0x9
	.byte	0x3
	.quad	TH2_ID
	.uleb128 0x24
	.long	.LASF105
	.byte	0x1
	.byte	0x37
	.long	0x35e
	.uleb128 0x9
	.byte	0x3
	.quad	Sensordata
	.uleb128 0x24
	.long	.LASF106
	.byte	0x1
	.byte	0x38
	.long	0x73f
	.uleb128 0x9
	.byte	0x3
	.quad	Sensordata_SHM_Addr
	.uleb128 0x10
	.byte	0x8
	.long	0x35e
	.uleb128 0x24
	.long	.LASF107
	.byte	0x1
	.byte	0x40
	.long	0x385
	.uleb128 0x9
	.byte	0x3
	.quad	State
	.uleb128 0xb
	.long	0xa5
	.long	0x76b
	.uleb128 0x25
	.long	0x7b
	.value	0x1f3
	.byte	0
	.uleb128 0x24
	.long	.LASF108
	.byte	0x1
	.byte	0x42
	.long	0x75a
	.uleb128 0x9
	.byte	0x3
	.quad	ReceivedDataFromServer
	.uleb128 0x24
	.long	.LASF109
	.byte	0x1
	.byte	0x51
	.long	0x3f5
	.uleb128 0x9
	.byte	0x3
	.quad	controldata
	.uleb128 0x24
	.long	.LASF110
	.byte	0x1
	.byte	0x55
	.long	0x2cf
	.uleb128 0x9
	.byte	0x3
	.quad	UART_fd
	.uleb128 0x24
	.long	.LASF111
	.byte	0x1
	.byte	0x56
	.long	0x252
	.uleb128 0x9
	.byte	0x3
	.quad	TerminalSettings
	.uleb128 0xb
	.long	0xa5
	.long	0x7cf
	.uleb128 0xc
	.long	0x7b
	.byte	0x4
	.byte	0
	.uleb128 0x24
	.long	.LASF112
	.byte	0x1
	.byte	0x5b
	.long	0x7bf
	.uleb128 0x9
	.byte	0x3
	.quad	data
	.uleb128 0x26
	.long	.LASF113
	.byte	0x1
	.value	0x10c
	.long	0x46d
	.uleb128 0x9
	.byte	0x3
	.quad	ReceivedUARTData
	.uleb128 0x27
	.string	"i"
	.byte	0x1
	.value	0x121
	.long	0x34
	.uleb128 0x9
	.byte	0x3
	.quad	i
	.uleb128 0x26
	.long	.LASF114
	.byte	0x1
	.value	0x16f
	.long	0x2da
	.uleb128 0x9
	.byte	0x3
	.quad	count
	.byte	0
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.uleb128 0x1
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0xe
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1b
	.uleb128 0xe
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x10
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x2
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.byte	0
	.byte	0
	.uleb128 0x3
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x8
	.byte	0
	.byte	0
	.uleb128 0x4
	.uleb128 0x16
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x5
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x6
	.uleb128 0x13
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x7
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x8
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x9
	.uleb128 0x4
	.byte	0x1
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xa
	.uleb128 0x28
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1c
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xb
	.uleb128 0x1
	.byte	0x1
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xc
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xd
	.uleb128 0x17
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xe
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xf
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x10
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x11
	.uleb128 0x13
	.byte	0x1
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x12
	.uleb128 0x28
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x1c
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x13
	.uleb128 0x13
	.byte	0x1
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x14
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x15
	.uleb128 0x16
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x16
	.uleb128 0x17
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x17
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x18
	.uleb128 0x4
	.byte	0x1
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x19
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2116
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x1a
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2116
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x1b
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2116
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x1c
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2116
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1d
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x1e
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2116
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1f
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x20
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2116
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x21
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2117
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x22
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x23
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x24
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x25
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0x5
	.byte	0
	.byte	0
	.uleb128 0x26
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x27
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_aranges,"",@progbits
	.long	0x2c
	.value	0x2
	.long	.Ldebug_info0
	.byte	0x8
	.byte	0
	.value	0
	.value	0
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.quad	0
	.quad	0
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	.debug_str,"MS",@progbits,1
.LASF8:
	.string	"__gid_t"
.LASF63:
	.string	"Sensordata_t"
.LASF31:
	.string	"sem_ctime"
.LASF51:
	.string	"c_line"
.LASF97:
	.string	"sem_opr"
.LASF90:
	.string	"ConvertToRealValue"
.LASF28:
	.string	"semid_ds"
.LASF110:
	.string	"UART_fd"
.LASF83:
	.string	"NOT_RECEIVED"
.LASF25:
	.string	"long long unsigned int"
.LASF106:
	.string	"Sensordata_SHM_Addr"
.LASF50:
	.string	"c_lflag"
.LASF53:
	.string	"c_ispeed"
.LASF37:
	.string	"sem_op"
.LASF38:
	.string	"sem_flg"
.LASF96:
	.string	"Seminit"
.LASF26:
	.string	"long long int"
.LASF4:
	.string	"signed char"
.LASF94:
	.string	"convert_to_uart_format"
.LASF59:
	.string	"TS_data"
.LASF11:
	.string	"__key_t"
.LASF74:
	.string	"RcvdPID"
.LASF119:
	.string	"ReadFromUART"
.LASF87:
	.string	"SEM_Init"
.LASF68:
	.string	"LED4_alarm"
.LASF81:
	.string	"ReceivedUartFormat"
.LASF6:
	.string	"long int"
.LASF117:
	.string	"/home/akv/aj1/drive-download-20170523T182400Z-001/SerialCommunication_1"
.LASF84:
	.string	"RECEIVED"
.LASF29:
	.string	"sem_perm"
.LASF48:
	.string	"c_oflag"
.LASF88:
	.string	"MQ_Init"
.LASF66:
	.string	"LED2_lock"
.LASF58:
	.string	"array"
.LASF2:
	.string	"short unsigned int"
.LASF114:
	.string	"count"
.LASF40:
	.string	"PTHREAD_CANCEL_DISABLE"
.LASF67:
	.string	"LED3_fan"
.LASF118:
	.string	"UART_Init"
.LASF115:
	.string	"GNU C11 5.4.0 20160609 -mtune=generic -march=x86-64 -g -fstack-protector-strong"
.LASF65:
	.string	"LED1_light"
.LASF80:
	.string	"UART"
.LASF3:
	.string	"unsigned int"
.LASF23:
	.string	"key_t"
.LASF0:
	.string	"long unsigned int"
.LASF35:
	.string	"sembuf"
.LASF41:
	.string	"PTHREAD_CANCEL_DEFERRED"
.LASF112:
	.string	"data"
.LASF98:
	.string	"control_data_received"
.LASF45:
	.string	"tcflag_t"
.LASF105:
	.string	"Sensordata"
.LASF43:
	.string	"cc_t"
.LASF19:
	.string	"__seq"
.LASF64:
	.string	"States_t"
.LASF15:
	.string	"cuid"
.LASF47:
	.string	"c_iflag"
.LASF5:
	.string	"short int"
.LASF54:
	.string	"c_ospeed"
.LASF39:
	.string	"PTHREAD_CANCEL_ENABLE"
.LASF27:
	.string	"ipc_perm"
.LASF73:
	.string	"Datareceivedfromuart_t"
.LASF104:
	.string	"TH2_ID"
.LASF69:
	.string	"control_data_t"
.LASF100:
	.string	"SHMID"
.LASF9:
	.string	"sizetype"
.LASF12:
	.string	"__syscall_ulong_t"
.LASF70:
	.string	"msg_type"
.LASF30:
	.string	"sem_otime"
.LASF42:
	.string	"PTHREAD_CANCEL_ASYNCHRONOUS"
.LASF57:
	.string	"uchar"
.LASF95:
	.string	"SendToAudrino"
.LASF62:
	.string	"float"
.LASF93:
	.string	"arg2"
.LASF103:
	.string	"TH1_ID"
.LASF52:
	.string	"c_cc"
.LASF24:
	.string	"pthread_t"
.LASF61:
	.string	"SS_data"
.LASF1:
	.string	"unsigned char"
.LASF91:
	.string	"StoreToSHM"
.LASF109:
	.string	"controldata"
.LASF49:
	.string	"c_cflag"
.LASF60:
	.string	"IRS_data"
.LASF86:
	.string	"SHM_Init"
.LASF76:
	.string	"SmokeData"
.LASF111:
	.string	"TerminalSettings"
.LASF13:
	.string	"char"
.LASF17:
	.string	"mode"
.LASF107:
	.string	"State"
.LASF32:
	.string	"sem_nsems"
.LASF7:
	.string	"__uid_t"
.LASF79:
	.string	"semun"
.LASF116:
	.string	"serial.c"
.LASF101:
	.string	"SEMID"
.LASF92:
	.string	"arg1"
.LASF55:
	.string	"sint"
.LASF18:
	.string	"__pad1"
.LASF20:
	.string	"__pad2"
.LASF71:
	.string	"control_data"
.LASF10:
	.string	"__time_t"
.LASF46:
	.string	"termios"
.LASF21:
	.string	"__glibc_reserved1"
.LASF22:
	.string	"__glibc_reserved2"
.LASF33:
	.string	"__glibc_reserved3"
.LASF34:
	.string	"__glibc_reserved4"
.LASF56:
	.string	"suint"
.LASF72:
	.string	"controldata_t"
.LASF14:
	.string	"__key"
.LASF36:
	.string	"sem_num"
.LASF78:
	.string	"ReceivedUartFormat_t"
.LASF82:
	.string	"ReceivedUARTBuffer"
.LASF113:
	.string	"ReceivedUARTData"
.LASF77:
	.string	"IRData"
.LASF102:
	.string	"MessageQueue_ID"
.LASF108:
	.string	"ReceivedDataFromServer"
.LASF75:
	.string	"TempValue"
.LASF99:
	.string	"BufferToBeSentToAudrino"
.LASF16:
	.string	"cgid"
.LASF89:
	.string	"main"
.LASF44:
	.string	"speed_t"
.LASF85:
	.string	"control_data_received_t"
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
