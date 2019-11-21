	.file	"client.c"
	.text
.Ltext0:
	.comm	SHMID,4,4
	.comm	SEMID,4,4
	.comm	socfd,4,4
	.comm	MessageQueue_ID,4,4
	.local	client_sock_addr
	.comm	client_sock_addr,16,16
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
	.comm	serverstatus,4,4
	.globl	DatafromServerAvailableStat
	.data
	.align 4
	.type	DatafromServerAvailableStat, @object
	.size	DatafromServerAvailableStat, 4
DatafromServerAvailableStat:
	.long	1
	.globl	PacketIDReceived
	.align 4
	.type	PacketIDReceived, @object
	.size	PacketIDReceived, 4
PacketIDReceived:
	.long	5
	.comm	ReceivedDataFromServer,500,32
	.local	sem_opr
	.comm	sem_opr,6,2
	.globl	jobj_received_data
	.bss
	.align 8
	.type	jobj_received_data, @object
	.size	jobj_received_data, 8
jobj_received_data:
	.zero	8
	.globl	jobj_sent_data
	.align 8
	.type	jobj_sent_data, @object
	.size	jobj_sent_data, 8
jobj_sent_data:
	.zero	8
	.globl	jstring
	.align 8
	.type	jstring, @object
	.size	jstring, 8
jstring:
	.zero	8
	.comm	controldata,16,16
	.globl	SendToServerStatus
	.align 4
	.type	SendToServerStatus, @object
	.size	SendToServerStatus, 4
SendToServerStatus:
	.zero	4
	.globl	sendcontroldatastat
	.align 4
	.type	sendcontroldatastat, @object
	.size	sendcontroldatastat, 4
sendcontroldatastat:
	.zero	4
	.comm	Server_IP,16,16
	.comm	PortNumber,5,1
	.comm	Port,4,4
	.section	.rodata
	.align 8
.LC0:
	.string	"Enter Server IP and port address through CL...."
.LC1:
	.string	"Server IP : %s\n"
.LC2:
	.string	"Port NUmber : %d\n"
.LC3:
	.string	"192.168.0.104"
.LC4:
	.string	"TH1 creation failed:SC"
.LC5:
	.string	"TH2 creation failed:SC"
	.align 8
.LC6:
	.string	"Socket Client Process entered in operational state......."
	.text
	.globl	main
	.type	main, @function
main:
.LFB2:
	.file 1 "client.c"
	.loc 1 154 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movl	%edi, -4(%rbp)
	movq	%rsi, -16(%rbp)
	.loc 1 155 0
	cmpl	$1, -4(%rbp)
	jne	.L2
	.loc 1 157 0
	movl	$.LC0, %edi
	call	puts
	.loc 1 158 0
	movl	$0, %edi
	call	exit
.L2:
	.loc 1 162 0
	movq	-16(%rbp), %rax
	addq	$8, %rax
	movq	(%rax), %rax
	movq	%rax, %rsi
	movl	$Server_IP, %edi
	call	strcpy
	.loc 1 163 0
	movq	-16(%rbp), %rax
	addq	$16, %rax
	movq	(%rax), %rax
	movq	%rax, %rsi
	movl	$PortNumber, %edi
	call	strcpy
	.loc 1 164 0
	movl	$Server_IP, %esi
	movl	$.LC1, %edi
	movl	$0, %eax
	call	printf
	.loc 1 165 0
	movl	$PortNumber, %edi
	call	atoi
	movl	%eax, %esi
	movl	$.LC2, %edi
	movl	$0, %eax
	call	printf
	.loc 1 167 0
	movl	$5, %edi
	call	sleep
	.loc 1 168 0
	call	SHM_Init
	call	SEM_Init
.L11:
	.loc 1 171 0
	movl	State(%rip), %eax
	cmpl	$1, %eax
	je	.L4
	cmpl	$1, %eax
	jb	.L5
	cmpl	$2, %eax
	je	.L6
	jmp	.L3
.L5:
	.loc 1 174 0
	call	MQ_Init
	testl	%eax, %eax
	jne	.L12
	.loc 1 176 0
	movl	$1, State(%rip)
	.loc 1 178 0
	jmp	.L12
.L4:
	.loc 1 180 0
	movl	$8080, %esi
	movl	$.LC3, %edi
	call	TriggerConnection
	testl	%eax, %eax
	jne	.L13
	.loc 1 182 0
	movl	$0, serverstatus(%rip)
	.loc 1 184 0
	movl	$0, %ecx
	movl	$TH1, %edx
	movl	$0, %esi
	movl	$TH1_ID, %edi
	call	pthread_create
	testl	%eax, %eax
	jns	.L9
	.loc 1 186 0
	movl	$.LC4, %edi
	call	perror
.L9:
	.loc 1 188 0
	movl	$0, %ecx
	movl	$TH2, %edx
	movl	$0, %esi
	movl	$TH2_ID, %edi
	call	pthread_create
	testl	%eax, %eax
	jns	.L10
	.loc 1 190 0
	movl	$.LC5, %edi
	call	perror
.L10:
	.loc 1 192 0
	movl	$2, State(%rip)
	.loc 1 193 0
	movl	$.LC6, %edi
	call	puts
	.loc 1 195 0
	jmp	.L13
.L6:
	.loc 1 197 0
	call	ConnectionManager
	.loc 1 198 0
	jmp	.L3
.L12:
	.loc 1 178 0
	nop
	jmp	.L11
.L13:
	.loc 1 195 0
	nop
.L3:
	.loc 1 200 0 discriminator 1
	jmp	.L11
	.cfi_endproc
.LFE2:
	.size	main, .-main
	.section	.rodata
.LC7:
	.string	"SOCKET_CREATION_FAILED:SC"
	.align 8
.LC8:
	.string	"clientSocket created with fd : %d\nerrno: %d\n"
	.align 8
.LC9:
	.string	"Trying to Establish connection with Server........"
	.align 8
.LC10:
	.string	"FAILED TO CONNECT TO SERVER:SC"
	.align 8
.LC11:
	.string	"Successfully connected to the server with response : success : %d\n"
	.text
	.globl	TriggerConnection
	.type	TriggerConnection, @function
TriggerConnection:
.LFB3:
	.loc 1 210 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movl	%esi, %eax
	movw	%ax, -28(%rbp)
	.loc 1 212 0
	movl	$0, %edx
	movl	$1, %esi
	movl	$2, %edi
	call	socket
	movl	%eax, socfd(%rip)
	.loc 1 214 0
	movl	socfd(%rip), %eax
	testl	%eax, %eax
	jns	.L15
	.loc 1 216 0
	movl	$.LC7, %edi
	call	perror
	.loc 1 217 0
	movl	$-1, %eax
	jmp	.L16
.L15:
	.loc 1 219 0
	call	__errno_location
	.loc 1 219 0
	movl	(%rax), %edx
	movl	socfd(%rip), %eax
	movl	%eax, %esi
	movl	$.LC8, %edi
	movl	$0, %eax
	call	printf
	.loc 1 221 0
	movw	$2, client_sock_addr(%rip)
	.loc 1 222 0
	movzwl	-28(%rbp), %eax
	movl	%eax, %edi
	call	htons
	movw	%ax, client_sock_addr+2(%rip)
	.loc 1 223 0
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	inet_addr
	movl	%eax, client_sock_addr+4(%rip)
	.loc 1 225 0
	movl	$16, -8(%rbp)
	.loc 1 227 0
	movl	$.LC9, %edi
	call	puts
	.loc 1 228 0
	movl	-8(%rbp), %edx
	movl	socfd(%rip), %eax
	movl	$client_sock_addr, %esi
	movl	%eax, %edi
	call	connect
	movl	%eax, -4(%rbp)
	.loc 1 229 0
	cmpl	$0, -4(%rbp)
	jns	.L17
	.loc 1 231 0
	movl	$.LC10, %edi
	call	perror
	.loc 1 232 0
	movl	socfd(%rip), %eax
	movl	%eax, %edi
	call	close
	.loc 1 233 0
	movl	$-1, %eax
	jmp	.L16
.L17:
	.loc 1 237 0
	movl	-4(%rbp), %eax
	movl	%eax, %esi
	movl	$.LC11, %edi
	movl	$0, %eax
	call	printf
	.loc 1 239 0
	movl	$0, %eax
.L16:
	.loc 1 240 0
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	TriggerConnection, .-TriggerConnection
	.section	.rodata
.LC12:
	.string	"SHM Init failed:SC"
.LC13:
	.string	"SHM Attach failed:SC"
	.text
	.globl	SHM_Init
	.type	SHM_Init, @function
SHM_Init:
.LFB4:
	.loc 1 248 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 249 0
	movl	$1974, %edx
	movl	$8, %esi
	movl	$1122, %edi
	call	shmget
	movl	%eax, SHMID(%rip)
	.loc 1 250 0
	movl	SHMID(%rip), %eax
	testl	%eax, %eax
	jns	.L19
	.loc 1 252 0
	call	__errno_location
	movl	(%rax), %eax
	.loc 1 252 0
	cmpl	$17, %eax
	jne	.L20
	.loc 1 254 0
	movl	$438, %edx
	movl	$8, %esi
	movl	$1122, %edi
	call	shmget
	movl	%eax, SHMID(%rip)
	jmp	.L19
.L20:
	.loc 1 258 0
	movl	$.LC12, %edi
	call	perror
	.loc 1 259 0
	movl	$-1, %eax
	jmp	.L21
.L19:
	.loc 1 263 0
	movl	SHMID(%rip), %eax
	movl	$0, %edx
	movl	$0, %esi
	movl	%eax, %edi
	call	shmat
	movq	%rax, Sensordata_SHM_Addr(%rip)
	.loc 1 265 0
	movq	Sensordata_SHM_Addr(%rip), %rax
	cmpq	$-1, %rax
	jne	.L22
	.loc 1 267 0
	movl	$.LC13, %edi
	call	perror
	.loc 1 268 0
	movl	$-1, %eax
	jmp	.L21
.L22:
	.loc 1 270 0
	movl	$0, %eax
.L21:
	.loc 1 271 0
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4:
	.size	SHM_Init, .-SHM_Init
	.section	.rodata
.LC14:
	.string	"Sem creation failed:SC"
.LC15:
	.string	"Sem init failed:SC"
	.text
	.globl	SEM_Init
	.type	SEM_Init, @function
SEM_Init:
.LFB5:
	.loc 1 282 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 283 0
	movl	$1974, %edx
	movl	$1, %esi
	movl	$3344, %edi
	call	semget
	movl	%eax, SEMID(%rip)
	.loc 1 284 0
	movl	SEMID(%rip), %eax
	testl	%eax, %eax
	jns	.L24
	.loc 1 286 0
	call	__errno_location
	movl	(%rax), %eax
	.loc 1 286 0
	cmpl	$17, %eax
	jne	.L25
	.loc 1 288 0
	movl	$438, %edx
	movl	$1, %esi
	movl	$3344, %edi
	call	semget
	movl	%eax, SEMID(%rip)
	jmp	.L26
.L25:
	.loc 1 292 0
	movl	$.LC14, %edi
	call	perror
	.loc 1 293 0
	movl	$-1, %eax
	jmp	.L27
.L24:
	.loc 1 298 0
	movl	$1, Seminit(%rip)
	.loc 1 299 0
	movl	SEMID(%rip), %eax
	movq	Seminit(%rip), %rcx
	movl	$16, %edx
	movl	$0, %esi
	movl	%eax, %edi
	movl	$0, %eax
	call	semctl
	testl	%eax, %eax
	jns	.L26
	.loc 1 301 0
	movl	$.LC15, %edi
	call	perror
	.loc 1 302 0
	movl	$-1, %eax
	jmp	.L27
.L26:
	.loc 1 305 0
	movl	$0, %eax
.L27:
	.loc 1 306 0
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	SEM_Init, .-SEM_Init
	.section	.rodata
	.align 8
.LC16:
	.string	"Message queue creation failed:SC"
	.text
	.globl	MQ_Init
	.type	MQ_Init, @function
MQ_Init:
.LFB6:
	.loc 1 315 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 316 0
	movl	$950, %esi
	movl	$4455, %edi
	call	msgget
	movl	%eax, MessageQueue_ID(%rip)
	movl	MessageQueue_ID(%rip), %eax
	testl	%eax, %eax
	jns	.L29
	.loc 1 318 0
	movl	$.LC16, %edi
	call	perror
	.loc 1 319 0
	movl	$-1, %eax
	jmp	.L30
.L29:
	.loc 1 321 0
	movl	$0, %eax
.L30:
	.loc 1 322 0
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	MQ_Init, .-MQ_Init
	.section	.rodata
	.align 8
.LC17:
	.string	"Server Disconnected...Trying to reconnect....."
	.text
	.globl	ConnectionManager
	.type	ConnectionManager, @function
ConnectionManager:
.LFB7:
	.loc 1 330 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 331 0
	movl	serverstatus(%rip), %eax
	cmpl	$1, %eax
	jne	.L33
	.loc 1 333 0
	movl	$.LC17, %edi
	call	puts
	.loc 1 334 0
	movq	TH1_ID(%rip), %rax
	movq	%rax, %rdi
	call	pthread_cancel
	.loc 1 335 0
	movq	TH2_ID(%rip), %rax
	movq	%rax, %rdi
	call	pthread_cancel
	.loc 1 336 0
	movl	socfd(%rip), %eax
	movl	%eax, %edi
	call	close
	.loc 1 337 0
	movl	$1, State(%rip)
.L33:
	.loc 1 339 0
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	ConnectionManager, .-ConnectionManager
	.section	.rodata
	.align 8
.LC18:
	.string	"Server is disconnected and read returned:fail: %d\n"
.LC19:
	.string	"Read from Server failed:SC"
	.align 8
.LC20:
	.string	"Total Characters read from server is : %d\n"
	.align 8
.LC21:
	.string	"Data received from server is : %s\n"
	.text
	.globl	ReadFromServer
	.type	ReadFromServer, @function
ReadFromServer:
.LFB8:
	.loc 1 347 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	.loc 1 349 0
	movl	socfd(%rip), %eax
	movl	$500, %edx
	movl	$ReceivedDataFromServer, %esi
	movl	%eax, %edi
	call	read
	movl	%eax, -4(%rbp)
	.loc 1 350 0
	cmpl	$0, -4(%rbp)
	jns	.L35
	.loc 1 352 0
	movl	-4(%rbp), %eax
	movl	%eax, %esi
	movl	$.LC18, %edi
	movl	$0, %eax
	call	printf
	.loc 1 353 0
	movl	$.LC19, %edi
	call	perror
	.loc 1 354 0
	movl	$-1, %eax
	jmp	.L36
.L35:
	.loc 1 356 0
	cmpl	$0, -4(%rbp)
	jne	.L37
	.loc 1 358 0
	movl	-4(%rbp), %eax
	movl	%eax, %esi
	movl	$.LC18, %edi
	movl	$0, %eax
	call	printf
	.loc 1 359 0
	movl	$1, serverstatus(%rip)
	.loc 1 360 0
	movl	$-1, %eax
	jmp	.L36
.L37:
	.loc 1 364 0
	movl	-4(%rbp), %eax
	movl	%eax, %esi
	movl	$.LC20, %edi
	movl	$0, %eax
	call	printf
	.loc 1 365 0
	movl	$ReceivedDataFromServer, %esi
	movl	$.LC21, %edi
	movl	$0, %eax
	call	printf
	.loc 1 366 0
	movl	$0, DatafromServerAvailableStat(%rip)
	.loc 1 368 0
	movl	$0, %eax
.L36:
	.loc 1 369 0
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	ReadFromServer, .-ReadFromServer
	.globl	test
	.section	.rodata
	.align 8
.LC22:
	.string	"{\"PID\":\"DEV_ID_RESP\",\"DEVICE_ID\":\"TESTDEVICE2303\"}"
	.data
	.align 8
	.type	test, @object
	.size	test, 8
test:
	.quad	.LC22
	.text
	.globl	TH1
	.type	TH1, @function
TH1:
.LFB9:
	.loc 1 384 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$24, %rsp
	.cfi_offset 3, -24
	movq	%rdi, -24(%rbp)
	.loc 1 385 0
	movl	$0, %esi
	movl	$0, %edi
	call	pthread_setcancelstate
	.loc 1 386 0
	movl	$0, %esi
	movl	$1, %edi
	call	pthread_setcanceltype
.L50:
	.loc 1 390 0
	call	ReadFromServer
	.loc 1 391 0
	movl	DatafromServerAvailableStat(%rip), %eax
	testl	%eax, %eax
	jne	.L39
	.loc 1 393 0
	movl	$ReceivedDataFromServer, %edi
	call	json_tokener_parse
	movq	%rax, jobj_received_data(%rip)
	.loc 1 395 0
	movq	jobj_received_data(%rip), %rax
	testq	%rax, %rax
	je	.L40
	.loc 1 397 0
	call	Packet_Processing
	.loc 1 398 0
	movl	$1, DatafromServerAvailableStat(%rip)
.L40:
	.loc 1 400 0
	movl	$500, %edx
	movl	$0, %esi
	movl	$ReceivedDataFromServer, %edi
	call	memset
.L39:
	.loc 1 403 0
	movl	PacketIDReceived(%rip), %eax
	cmpl	$5, %eax
	ja	.L41
	movl	%eax, %eax
	movq	.L43(,%rax,8), %rax
	jmp	*%rax
	.section	.rodata
	.align 8
	.align 4
.L43:
	.quad	.L42
	.quad	.L44
	.quad	.L45
	.quad	.L46
	.quad	.L47
	.quad	.L51
	.text
.L42:
	.loc 1 406 0
	call	GetTempData
	.loc 1 407 0
	call	ConvertTempToJSON
	.loc 1 408 0
	movl	$1, SendToServerStatus(%rip)
	.loc 1 409 0
	jmp	.L41
.L45:
	.loc 1 411 0
	call	GetIRData
	.loc 1 412 0
	call	ConvertIRToJSON
	.loc 1 413 0
	movl	$1, SendToServerStatus(%rip)
	.loc 1 414 0
	jmp	.L41
.L44:
	.loc 1 416 0
	call	GetSDData
	.loc 1 417 0
	call	ConvertSDToJSON
	.loc 1 418 0
	movl	$1, SendToServerStatus(%rip)
	.loc 1 419 0
	jmp	.L41
.L46:
	.loc 1 421 0
	call	ConvertDEVID_ToJSON
	.loc 1 423 0
	movl	$1, SendToServerStatus(%rip)
	.loc 1 424 0
	jmp	.L41
.L47:
	.loc 1 426 0
	movl	$1, sendcontroldatastat(%rip)
.L51:
	.loc 1 428 0
	nop
.L41:
	.loc 1 430 0
	movl	$5, PacketIDReceived(%rip)
	.loc 1 431 0
	movl	SendToServerStatus(%rip), %eax
	cmpl	$1, %eax
	jne	.L50
	.loc 1 433 0
	movq	jobj_sent_data(%rip), %rax
	movq	%rax, %rdi
	call	json_object_to_json_string
	movq	%rax, %rdi
	call	strlen
	movzwl	%ax, %ebx
	movq	jobj_sent_data(%rip), %rax
	movq	%rax, %rdi
	call	json_object_to_json_string
	movl	%ebx, %esi
	movq	%rax, %rdi
	call	SendToServer
	.loc 1 435 0
	movq	$0, jobj_sent_data(%rip)
	.loc 1 436 0
	movl	$0, SendToServerStatus(%rip)
	.loc 1 438 0
	jmp	.L50
	.cfi_endproc
.LFE9:
	.size	TH1, .-TH1
	.section	.rodata
	.align 8
.LC23:
	.string	"Sending data to server failed:SendToServer:SC"
	.text
	.globl	SendToServer
	.type	SendToServer, @function
SendToServer:
.LFB10:
	.loc 1 445 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movl	%esi, %eax
	movw	%ax, -12(%rbp)
	.loc 1 446 0
	movzwl	-12(%rbp), %edx
	movl	socfd(%rip), %eax
	movq	-8(%rbp), %rcx
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	write
	testq	%rax, %rax
	jns	.L54
	.loc 1 448 0
	movl	$.LC23, %edi
	call	perror
.L54:
	.loc 1 450 0
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE10:
	.size	SendToServer, .-SendToServer
	.section	.rodata
	.align 8
.LC24:
	.string	"unable to send control data:SC"
	.text
	.globl	TH2
	.type	TH2, @function
TH2:
.LFB11:
	.loc 1 456 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	.loc 1 457 0
	movl	$0, %esi
	movl	$0, %edi
	call	pthread_setcancelstate
	.loc 1 458 0
	movl	$0, %esi
	movl	$1, %edi
	call	pthread_setcanceltype
	.loc 1 459 0
	movq	$1, controldata(%rip)
.L58:
	.loc 1 462 0
	movl	sendcontroldatastat(%rip), %eax
	cmpl	$1, %eax
	jne	.L58
	.loc 1 464 0
	movl	MessageQueue_ID(%rip), %eax
	movl	$0, %ecx
	movl	$4, %edx
	movl	$controldata, %esi
	movl	%eax, %edi
	call	msgsnd
	testl	%eax, %eax
	jns	.L57
	.loc 1 466 0
	movl	$.LC24, %edi
	call	perror
.L57:
	.loc 1 468 0
	movl	$0, sendcontroldatastat(%rip)
	.loc 1 470 0
	jmp	.L58
	.cfi_endproc
.LFE11:
	.size	TH2, .-TH2
	.globl	jobj_received_data_sub_string
	.bss
	.align 8
	.type	jobj_received_data_sub_string, @object
	.size	jobj_received_data_sub_string, 8
jobj_received_data_sub_string:
	.zero	8
	.section	.rodata
.LC25:
	.string	"PID"
.LC26:
	.string	"Value in Request string : %s\n"
.LC27:
	.string	"TEMP_S"
.LC28:
	.string	"SMK_S"
.LC29:
	.string	"IR_S"
.LC30:
	.string	"DEV_ID_REQUEST"
.LC31:
	.string	"action"
.LC32:
	.string	"Value in Control string : %s\n"
	.text
	.globl	Packet_Processing
	.type	Packet_Processing, @function
Packet_Processing:
.LFB12:
	.loc 1 481 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
.LBB2:
	.loc 1 483 0
	movq	jobj_received_data(%rip), %rax
	movq	%rax, %rdi
	call	json_object_get_object
	movq	40(%rax), %rax
	movq	%rax, -24(%rbp)
	.loc 1 483 0
	movq	$0, -16(%rbp)
	.loc 1 483 0
	jmp	.L60
.L69:
	.loc 1 485 0
	movq	-40(%rbp), %rax
	movl	$.LC25, %esi
	movq	%rax, %rdi
	call	strcmp
	testl	%eax, %eax
	jne	.L61
	.loc 1 487 0
	movq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	json_object_get_string
	movq	%rax, -8(%rbp)
	.loc 1 488 0
	movq	-8(%rbp), %rax
	movq	%rax, %rsi
	movl	$.LC26, %edi
	movl	$0, %eax
	call	printf
	.loc 1 489 0
	movq	-8(%rbp), %rax
	movl	$.LC27, %esi
	movq	%rax, %rdi
	call	strcmp
	testl	%eax, %eax
	jne	.L62
	.loc 1 491 0
	movl	$0, PacketIDReceived(%rip)
	.loc 1 505 0
	jmp	.L70
.L62:
	.loc 1 493 0
	movq	-8(%rbp), %rax
	movl	$.LC28, %esi
	movq	%rax, %rdi
	call	strcmp
	testl	%eax, %eax
	jne	.L64
	.loc 1 495 0
	movl	$1, PacketIDReceived(%rip)
	.loc 1 505 0
	jmp	.L70
.L64:
	.loc 1 497 0
	movq	-8(%rbp), %rax
	movl	$.LC29, %esi
	movq	%rax, %rdi
	call	strcmp
	testl	%eax, %eax
	jne	.L65
	.loc 1 499 0
	movl	$2, PacketIDReceived(%rip)
	.loc 1 505 0
	jmp	.L70
.L65:
	.loc 1 501 0
	movq	-8(%rbp), %rax
	movl	$.LC30, %esi
	movq	%rax, %rdi
	call	strcmp
	testl	%eax, %eax
	jne	.L70
	.loc 1 503 0
	movl	$3, PacketIDReceived(%rip)
	.loc 1 505 0
	jmp	.L70
.L61:
	.loc 1 507 0
	movq	-40(%rbp), %rax
	movl	$.LC31, %esi
	movq	%rax, %rdi
	call	strcmp
	testl	%eax, %eax
	jne	.L67
	.loc 1 509 0
	movl	$4, PacketIDReceived(%rip)
	.loc 1 510 0
	movq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	json_object_get_string
	movq	%rax, -8(%rbp)
	.loc 1 511 0
	movq	-8(%rbp), %rax
	movq	%rax, %rsi
	movl	$.LC32, %edi
	movl	$0, %eax
	call	printf
	.loc 1 512 0
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	json_tokener_parse
	movq	%rax, jobj_received_data_sub_string(%rip)
	.loc 1 513 0
	movq	jobj_received_data_sub_string(%rip), %rax
	testq	%rax, %rax
	je	.L67
	.loc 1 515 0
	call	Process_sub_control_packet
	.loc 1 516 0
	jmp	.L66
.L67:
	.loc 1 483 0 discriminator 2
	movq	-16(%rbp), %rax
	movq	%rax, -24(%rbp)
.L60:
.LBB3:
	.loc 1 483 0 discriminator 1
	cmpq	$0, -24(%rbp)
	je	.L68
	.loc 1 483 0 discriminator 3
	movq	-24(%rbp), %rax
	movq	(%rax), %rax
	movq	%rax, -40(%rbp)
	.loc 1 483 0 discriminator 3
	movq	-24(%rbp), %rax
	movq	8(%rax), %rax
	movq	%rax, -32(%rbp)
	movq	-24(%rbp), %rax
	movq	16(%rax), %rax
	movq	%rax, -16(%rbp)
.L68:
	.loc 1 483 0 is_stmt 0 discriminator 5
	movq	-24(%rbp), %rax
.LBE3:
	.loc 1 483 0 is_stmt 1 discriminator 5
	testq	%rax, %rax
	jne	.L69
	jmp	.L66
.L70:
	.loc 1 505 0
	nop
.L66:
.LBE2:
	.loc 1 520 0 discriminator 1
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE12:
	.size	Packet_Processing, .-Packet_Processing
	.section	.rodata
.LC33:
	.string	"light"
.LC34:
	.string	"ON"
.LC35:
	.string	"lock"
.LC36:
	.string	"fan"
.LC37:
	.string	"alarm"
.LC38:
	.string	"action data..."
.LC39:
	.string	"LED1_light : %u\n"
.LC40:
	.string	"LED2_lock : %u\n"
.LC41:
	.string	"LED3_fan : %u\n"
.LC42:
	.string	"LED4_alarm : %u\n"
	.text
	.type	Process_sub_control_packet, @function
Process_sub_control_packet:
.LFB13:
	.loc 1 526 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
.LBB4:
	.loc 1 527 0
	movq	jobj_received_data_sub_string(%rip), %rax
	movq	%rax, %rdi
	call	json_object_get_object
	movq	40(%rax), %rax
	movq	%rax, -16(%rbp)
	.loc 1 527 0
	movq	$0, -8(%rbp)
	.loc 1 527 0
	jmp	.L72
.L82:
	.loc 1 529 0
	movq	-32(%rbp), %rax
	movl	$.LC33, %esi
	movq	%rax, %rdi
	call	strcmp
	testl	%eax, %eax
	jne	.L73
	.loc 1 531 0
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	json_object_get_string
	movq	%rax, %rsi
	movl	$.LC34, %edi
	call	strcmp
	testl	%eax, %eax
	jne	.L74
	.loc 1 533 0
	movb	$1, controldata+8(%rip)
	jmp	.L73
.L74:
	.loc 1 537 0
	movb	$0, controldata+8(%rip)
.L73:
	.loc 1 540 0
	movq	-32(%rbp), %rax
	movl	$.LC35, %esi
	movq	%rax, %rdi
	call	strcmp
	testl	%eax, %eax
	jne	.L75
	.loc 1 542 0
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	json_object_get_string
	movq	%rax, %rsi
	movl	$.LC34, %edi
	call	strcmp
	testl	%eax, %eax
	jne	.L76
	.loc 1 544 0
	movb	$1, controldata+9(%rip)
	jmp	.L75
.L76:
	.loc 1 548 0
	movb	$0, controldata+9(%rip)
.L75:
	.loc 1 551 0
	movq	-32(%rbp), %rax
	movl	$.LC36, %esi
	movq	%rax, %rdi
	call	strcmp
	testl	%eax, %eax
	jne	.L77
	.loc 1 553 0
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	json_object_get_string
	movq	%rax, %rsi
	movl	$.LC34, %edi
	call	strcmp
	testl	%eax, %eax
	jne	.L78
	.loc 1 555 0
	movb	$1, controldata+10(%rip)
	jmp	.L77
.L78:
	.loc 1 559 0
	movb	$0, controldata+10(%rip)
.L77:
	.loc 1 562 0
	movq	-32(%rbp), %rax
	movl	$.LC37, %esi
	movq	%rax, %rdi
	call	strcmp
	testl	%eax, %eax
	jne	.L79
	.loc 1 564 0
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	json_object_get_string
	movq	%rax, %rsi
	movl	$.LC34, %edi
	call	strcmp
	testl	%eax, %eax
	jne	.L80
	.loc 1 566 0
	movb	$1, controldata+11(%rip)
	jmp	.L79
.L80:
	.loc 1 570 0
	movb	$0, controldata+11(%rip)
.L79:
	.loc 1 527 0 discriminator 2
	movq	-8(%rbp), %rax
	movq	%rax, -16(%rbp)
.L72:
.LBB5:
	.loc 1 527 0 discriminator 1
	cmpq	$0, -16(%rbp)
	je	.L81
	.loc 1 527 0 discriminator 3
	movq	-16(%rbp), %rax
	movq	(%rax), %rax
	movq	%rax, -32(%rbp)
	.loc 1 527 0 discriminator 3
	movq	-16(%rbp), %rax
	movq	8(%rax), %rax
	movq	%rax, -24(%rbp)
	movq	-16(%rbp), %rax
	movq	16(%rax), %rax
	movq	%rax, -8(%rbp)
.L81:
	.loc 1 527 0 is_stmt 0 discriminator 5
	movq	-16(%rbp), %rax
.LBE5:
	.loc 1 527 0 is_stmt 1 discriminator 5
	testq	%rax, %rax
	jne	.L82
.LBE4:
	.loc 1 574 0
	movl	$.LC38, %edi
	call	puts
	.loc 1 575 0
	movzbl	controldata+8(%rip), %eax
	movzbl	%al, %eax
	movl	%eax, %esi
	movl	$.LC39, %edi
	movl	$0, %eax
	call	printf
	.loc 1 576 0
	movzbl	controldata+9(%rip), %eax
	movzbl	%al, %eax
	movl	%eax, %esi
	movl	$.LC40, %edi
	movl	$0, %eax
	call	printf
	.loc 1 577 0
	movzbl	controldata+10(%rip), %eax
	movzbl	%al, %eax
	movl	%eax, %esi
	movl	$.LC41, %edi
	movl	$0, %eax
	call	printf
	.loc 1 578 0
	movzbl	controldata+11(%rip), %eax
	movzbl	%al, %eax
	movl	%eax, %esi
	movl	$.LC42, %edi
	movl	$0, %eax
	call	printf
	.loc 1 579 0
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE13:
	.size	Process_sub_control_packet, .-Process_sub_control_packet
	.section	.rodata
.LC43:
	.string	"Sem locking failed:SC"
.LC44:
	.string	"sem release failed:SC"
	.text
	.globl	GetTempData
	.type	GetTempData, @function
GetTempData:
.LFB14:
	.loc 1 584 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 585 0
	movw	$0, sem_opr(%rip)
	.loc 1 586 0
	movw	$-1, sem_opr+2(%rip)
	.loc 1 587 0
	movw	$4096, sem_opr+4(%rip)
	.loc 1 588 0
	movl	SEMID(%rip), %eax
	movl	$1, %edx
	movl	$sem_opr, %esi
	movl	%eax, %edi
	call	semop
	testl	%eax, %eax
	jns	.L84
	.loc 1 590 0
	movl	$.LC43, %edi
	call	perror
.L84:
	.loc 1 592 0
	movq	Sensordata_SHM_Addr(%rip), %rax
	movss	(%rax), %xmm0
	movss	%xmm0, Sensordata(%rip)
	.loc 1 594 0
	movw	$0, sem_opr(%rip)
	.loc 1 595 0
	movw	$1, sem_opr+2(%rip)
	.loc 1 596 0
	movw	$4096, sem_opr+4(%rip)
	.loc 1 597 0
	movl	SEMID(%rip), %eax
	movl	$1, %edx
	movl	$sem_opr, %esi
	movl	%eax, %edi
	call	semop
	testl	%eax, %eax
	jns	.L86
	.loc 1 599 0
	movl	$.LC44, %edi
	call	perror
.L86:
	.loc 1 601 0
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE14:
	.size	GetTempData, .-GetTempData
	.section	.rodata
.LC45:
	.string	"IRD in socket client : %u\n"
	.text
	.globl	GetIRData
	.type	GetIRData, @function
GetIRData:
.LFB15:
	.loc 1 608 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 609 0
	movw	$0, sem_opr(%rip)
	.loc 1 610 0
	movw	$-1, sem_opr+2(%rip)
	.loc 1 611 0
	movw	$4096, sem_opr+4(%rip)
	.loc 1 612 0
	movl	SEMID(%rip), %eax
	movl	$1, %edx
	movl	$sem_opr, %esi
	movl	%eax, %edi
	call	semop
	testl	%eax, %eax
	jns	.L88
	.loc 1 614 0
	movl	$.LC43, %edi
	call	perror
.L88:
	.loc 1 616 0
	movq	Sensordata_SHM_Addr(%rip), %rax
	movzwl	4(%rax), %eax
	movw	%ax, Sensordata+4(%rip)
	.loc 1 617 0
	movzwl	Sensordata+4(%rip), %eax
	movzwl	%ax, %eax
	movl	%eax, %esi
	movl	$.LC45, %edi
	movl	$0, %eax
	call	printf
	.loc 1 618 0
	movw	$0, sem_opr(%rip)
	.loc 1 619 0
	movw	$1, sem_opr+2(%rip)
	.loc 1 620 0
	movw	$4096, sem_opr+4(%rip)
	.loc 1 621 0
	movl	SEMID(%rip), %eax
	movl	$1, %edx
	movl	$sem_opr, %esi
	movl	%eax, %edi
	call	semop
	testl	%eax, %eax
	jns	.L90
	.loc 1 623 0
	movl	$.LC44, %edi
	call	perror
.L90:
	.loc 1 625 0
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE15:
	.size	GetIRData, .-GetIRData
	.section	.rodata
	.align 8
.LC46:
	.string	"Smoke data in socket client : %u\n"
	.text
	.globl	GetSDData
	.type	GetSDData, @function
GetSDData:
.LFB16:
	.loc 1 632 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 633 0
	movw	$0, sem_opr(%rip)
	.loc 1 634 0
	movw	$-1, sem_opr+2(%rip)
	.loc 1 635 0
	movw	$4096, sem_opr+4(%rip)
	.loc 1 636 0
	movl	SEMID(%rip), %eax
	movl	$1, %edx
	movl	$sem_opr, %esi
	movl	%eax, %edi
	call	semop
	testl	%eax, %eax
	jns	.L92
	.loc 1 638 0
	movl	$.LC43, %edi
	call	perror
.L92:
	.loc 1 641 0
	movq	Sensordata_SHM_Addr(%rip), %rax
	movzwl	6(%rax), %eax
	movw	%ax, Sensordata+6(%rip)
	.loc 1 642 0
	movzwl	Sensordata+6(%rip), %eax
	movzwl	%ax, %eax
	movl	%eax, %esi
	movl	$.LC46, %edi
	movl	$0, %eax
	call	printf
	.loc 1 643 0
	movw	$0, sem_opr(%rip)
	.loc 1 644 0
	movw	$1, sem_opr+2(%rip)
	.loc 1 645 0
	movw	$4096, sem_opr+4(%rip)
	.loc 1 646 0
	movl	SEMID(%rip), %eax
	movl	$1, %edx
	movl	$sem_opr, %esi
	movl	%eax, %edi
	call	semop
	testl	%eax, %eax
	jns	.L94
	.loc 1 648 0
	movl	$.LC44, %edi
	call	perror
.L94:
	.loc 1 650 0
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE16:
	.size	GetSDData, .-GetSDData
	.section	.rodata
.LC47:
	.string	"VALUE_TEMP_S"
	.text
	.globl	ConvertTempToJSON
	.type	ConvertTempToJSON, @function
ConvertTempToJSON:
.LFB17:
	.loc 1 658 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	.loc 1 660 0
	call	json_object_new_object
	movq	%rax, jobj_sent_data(%rip)
	.loc 1 661 0
	movss	Sensordata(%rip), %xmm0
	cvtss2sd	%xmm0, %xmm0
	call	json_object_new_double
	movq	%rax, -8(%rbp)
	.loc 1 662 0
	movq	jobj_sent_data(%rip), %rax
	movq	-8(%rbp), %rdx
	movl	$.LC47, %esi
	movq	%rax, %rdi
	call	json_object_object_add
	.loc 1 663 0
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE17:
	.size	ConvertTempToJSON, .-ConvertTempToJSON
	.section	.rodata
.LC48:
	.string	"PRESENT"
.LC49:
	.string	"NOT_PRESENT"
.LC50:
	.string	"VALUE_IR_S"
	.text
	.globl	ConvertIRToJSON
	.type	ConvertIRToJSON, @function
ConvertIRToJSON:
.LFB18:
	.loc 1 672 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	.loc 1 674 0
	call	json_object_new_object
	movq	%rax, jobj_sent_data(%rip)
	.loc 1 675 0
	movzwl	Sensordata+4(%rip), %eax
	cmpw	$1, %ax
	jne	.L97
	.loc 1 677 0
	movl	$.LC48, %edi
	call	json_object_new_string
	movq	%rax, -8(%rbp)
	jmp	.L98
.L97:
	.loc 1 679 0
	movzwl	Sensordata+4(%rip), %eax
	testw	%ax, %ax
	jne	.L98
	.loc 1 681 0
	movl	$.LC49, %edi
	call	json_object_new_string
	movq	%rax, -8(%rbp)
.L98:
	.loc 1 683 0
	movq	jobj_sent_data(%rip), %rax
	movq	-8(%rbp), %rdx
	movl	$.LC50, %esi
	movq	%rax, %rdi
	call	json_object_object_add
	.loc 1 684 0
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE18:
	.size	ConvertIRToJSON, .-ConvertIRToJSON
	.section	.rodata
.LC51:
	.string	"DETECTED"
.LC52:
	.string	"NOT_DETECTED"
.LC53:
	.string	"VALUE_SMK_S"
	.text
	.globl	ConvertSDToJSON
	.type	ConvertSDToJSON, @function
ConvertSDToJSON:
.LFB19:
	.loc 1 692 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	.loc 1 694 0
	call	json_object_new_object
	movq	%rax, jobj_sent_data(%rip)
	.loc 1 695 0
	movzwl	Sensordata+6(%rip), %eax
	cmpw	$1, %ax
	jne	.L100
	.loc 1 697 0
	movl	$.LC51, %edi
	call	json_object_new_string
	movq	%rax, -8(%rbp)
	jmp	.L101
.L100:
	.loc 1 699 0
	movzwl	Sensordata+6(%rip), %eax
	testw	%ax, %ax
	jne	.L101
	.loc 1 701 0
	movl	$.LC52, %edi
	call	json_object_new_string
	movq	%rax, -8(%rbp)
.L101:
	.loc 1 703 0
	movq	jobj_sent_data(%rip), %rax
	movq	-8(%rbp), %rdx
	movl	$.LC53, %esi
	movq	%rax, %rdi
	call	json_object_object_add
	.loc 1 704 0
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE19:
	.size	ConvertSDToJSON, .-ConvertSDToJSON
	.section	.rodata
.LC54:
	.string	"DEV_ID_RESP"
.LC55:
	.string	"TESTDEVICE2303"
.LC56:
	.string	"DEVICE_ID"
	.text
	.globl	ConvertDEVID_ToJSON
	.type	ConvertDEVID_ToJSON, @function
ConvertDEVID_ToJSON:
.LFB20:
	.loc 1 711 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	.loc 1 713 0
	call	json_object_new_object
	movq	%rax, jobj_sent_data(%rip)
	.loc 1 715 0
	movl	$.LC54, %edi
	call	json_object_new_string
	movq	%rax, -8(%rbp)
	.loc 1 716 0
	movq	jobj_sent_data(%rip), %rax
	movq	-8(%rbp), %rdx
	movl	$.LC25, %esi
	movq	%rax, %rdi
	call	json_object_object_add
	.loc 1 718 0
	movl	$.LC55, %edi
	call	json_object_new_string
	movq	%rax, -8(%rbp)
	.loc 1 719 0
	movq	jobj_sent_data(%rip), %rax
	movq	-8(%rbp), %rdx
	movl	$.LC56, %esi
	movq	%rax, %rdi
	call	json_object_object_add
	.loc 1 720 0
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE20:
	.size	ConvertDEVID_ToJSON, .-ConvertDEVID_ToJSON
.Letext0:
	.file 2 "/usr/include/x86_64-linux-gnu/bits/types.h"
	.file 3 "/usr/include/x86_64-linux-gnu/bits/ipc.h"
	.file 4 "/usr/include/x86_64-linux-gnu/sys/ipc.h"
	.file 5 "/usr/include/x86_64-linux-gnu/bits/pthreadtypes.h"
	.file 6 "/usr/include/x86_64-linux-gnu/bits/sem.h"
	.file 7 "/usr/include/x86_64-linux-gnu/sys/sem.h"
	.file 8 "/usr/include/pthread.h"
	.file 9 "/usr/include/x86_64-linux-gnu/bits/sockaddr.h"
	.file 10 "/usr/include/x86_64-linux-gnu/bits/socket.h"
	.file 11 "/usr/include/stdint.h"
	.file 12 "/usr/include/netinet/in.h"
	.file 13 "/usr/include/json-c/linkhash.h"
	.file 14 "/usr/include/json-c/json_object.h"
	.file 15 "/usr/include/x86_64-linux-gnu/bits/socket_type.h"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0xc17
	.value	0x4
	.long	.Ldebug_abbrev0
	.byte	0x8
	.uleb128 0x1
	.long	.LASF166
	.byte	0xc
	.long	.LASF167
	.long	.LASF168
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
	.uleb128 0x6
	.byte	0x8
	.long	0xab
	.uleb128 0x2
	.byte	0x1
	.byte	0x6
	.long	.LASF13
	.uleb128 0x6
	.byte	0x8
	.long	0xb8
	.uleb128 0x7
	.long	0xab
	.uleb128 0x8
	.long	.LASF27
	.byte	0x30
	.byte	0x3
	.byte	0x2a
	.long	0x14e
	.uleb128 0x9
	.long	.LASF14
	.byte	0x3
	.byte	0x2c
	.long	0x8d
	.byte	0
	.uleb128 0xa
	.string	"uid"
	.byte	0x3
	.byte	0x2d
	.long	0x65
	.byte	0x4
	.uleb128 0xa
	.string	"gid"
	.byte	0x3
	.byte	0x2e
	.long	0x70
	.byte	0x8
	.uleb128 0x9
	.long	.LASF15
	.byte	0x3
	.byte	0x2f
	.long	0x65
	.byte	0xc
	.uleb128 0x9
	.long	.LASF16
	.byte	0x3
	.byte	0x30
	.long	0x70
	.byte	0x10
	.uleb128 0x9
	.long	.LASF17
	.byte	0x3
	.byte	0x31
	.long	0x3b
	.byte	0x14
	.uleb128 0x9
	.long	.LASF18
	.byte	0x3
	.byte	0x32
	.long	0x3b
	.byte	0x16
	.uleb128 0x9
	.long	.LASF19
	.byte	0x3
	.byte	0x33
	.long	0x3b
	.byte	0x18
	.uleb128 0x9
	.long	.LASF20
	.byte	0x3
	.byte	0x34
	.long	0x3b
	.byte	0x1a
	.uleb128 0x9
	.long	.LASF21
	.byte	0x3
	.byte	0x35
	.long	0x9a
	.byte	0x20
	.uleb128 0x9
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
	.uleb128 0x8
	.long	.LASF28
	.byte	0x68
	.byte	0x6
	.byte	0x26
	.long	0x1df
	.uleb128 0x9
	.long	.LASF29
	.byte	0x6
	.byte	0x28
	.long	0xbd
	.byte	0
	.uleb128 0x9
	.long	.LASF30
	.byte	0x6
	.byte	0x29
	.long	0x82
	.byte	0x30
	.uleb128 0x9
	.long	.LASF21
	.byte	0x6
	.byte	0x2a
	.long	0x9a
	.byte	0x38
	.uleb128 0x9
	.long	.LASF31
	.byte	0x6
	.byte	0x2b
	.long	0x82
	.byte	0x40
	.uleb128 0x9
	.long	.LASF22
	.byte	0x6
	.byte	0x2c
	.long	0x9a
	.byte	0x48
	.uleb128 0x9
	.long	.LASF32
	.byte	0x6
	.byte	0x2d
	.long	0x9a
	.byte	0x50
	.uleb128 0x9
	.long	.LASF33
	.byte	0x6
	.byte	0x2e
	.long	0x9a
	.byte	0x58
	.uleb128 0x9
	.long	.LASF34
	.byte	0x6
	.byte	0x2f
	.long	0x9a
	.byte	0x60
	.byte	0
	.uleb128 0x8
	.long	.LASF35
	.byte	0x6
	.byte	0x7
	.byte	0x29
	.long	0x210
	.uleb128 0x9
	.long	.LASF36
	.byte	0x7
	.byte	0x2b
	.long	0x3b
	.byte	0
	.uleb128 0x9
	.long	.LASF37
	.byte	0x7
	.byte	0x2c
	.long	0x50
	.byte	0x2
	.uleb128 0x9
	.long	.LASF38
	.byte	0x7
	.byte	0x2d
	.long	0x50
	.byte	0x4
	.byte	0
	.uleb128 0xb
	.byte	0x4
	.long	0x42
	.byte	0x8
	.byte	0xc8
	.long	0x229
	.uleb128 0xc
	.long	.LASF39
	.byte	0
	.uleb128 0xc
	.long	.LASF40
	.byte	0x1
	.byte	0
	.uleb128 0xb
	.byte	0x4
	.long	0x42
	.byte	0x8
	.byte	0xcf
	.long	0x242
	.uleb128 0xc
	.long	.LASF41
	.byte	0
	.uleb128 0xc
	.long	.LASF42
	.byte	0x1
	.byte	0
	.uleb128 0xd
	.long	.LASF169
	.byte	0x4
	.long	0x42
	.byte	0xf
	.byte	0x18
	.long	0x28d
	.uleb128 0xc
	.long	.LASF43
	.byte	0x1
	.uleb128 0xc
	.long	.LASF44
	.byte	0x2
	.uleb128 0xc
	.long	.LASF45
	.byte	0x3
	.uleb128 0xc
	.long	.LASF46
	.byte	0x4
	.uleb128 0xc
	.long	.LASF47
	.byte	0x5
	.uleb128 0xc
	.long	.LASF48
	.byte	0x6
	.uleb128 0xc
	.long	.LASF49
	.byte	0xa
	.uleb128 0xe
	.long	.LASF50
	.long	0x80000
	.uleb128 0xf
	.long	.LASF51
	.value	0x800
	.byte	0
	.uleb128 0x4
	.long	.LASF52
	.byte	0x9
	.byte	0x1c
	.long	0x3b
	.uleb128 0x8
	.long	.LASF53
	.byte	0x10
	.byte	0xa
	.byte	0x99
	.long	0x2bd
	.uleb128 0x9
	.long	.LASF54
	.byte	0xa
	.byte	0x9b
	.long	0x28d
	.byte	0
	.uleb128 0x9
	.long	.LASF55
	.byte	0xa
	.byte	0x9c
	.long	0x2bd
	.byte	0x2
	.byte	0
	.uleb128 0x10
	.long	0xab
	.long	0x2cd
	.uleb128 0x11
	.long	0x7b
	.byte	0xd
	.byte	0
	.uleb128 0x4
	.long	.LASF56
	.byte	0xb
	.byte	0x31
	.long	0x3b
	.uleb128 0x4
	.long	.LASF57
	.byte	0xb
	.byte	0x33
	.long	0x42
	.uleb128 0x4
	.long	.LASF58
	.byte	0xc
	.byte	0x1e
	.long	0x2d8
	.uleb128 0x8
	.long	.LASF59
	.byte	0x4
	.byte	0xc
	.byte	0x1f
	.long	0x307
	.uleb128 0x9
	.long	.LASF60
	.byte	0xc
	.byte	0x21
	.long	0x2e3
	.byte	0
	.byte	0
	.uleb128 0x4
	.long	.LASF61
	.byte	0xc
	.byte	0x77
	.long	0x2cd
	.uleb128 0x8
	.long	.LASF62
	.byte	0x10
	.byte	0xc
	.byte	0xef
	.long	0x34f
	.uleb128 0x9
	.long	.LASF63
	.byte	0xc
	.byte	0xf1
	.long	0x28d
	.byte	0
	.uleb128 0x9
	.long	.LASF64
	.byte	0xc
	.byte	0xf2
	.long	0x307
	.byte	0x2
	.uleb128 0x9
	.long	.LASF65
	.byte	0xc
	.byte	0xf3
	.long	0x2ee
	.byte	0x4
	.uleb128 0x9
	.long	.LASF66
	.byte	0xc
	.byte	0xf6
	.long	0x34f
	.byte	0x8
	.byte	0
	.uleb128 0x10
	.long	0x34
	.long	0x35f
	.uleb128 0x11
	.long	0x7b
	.byte	0x7
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x365
	.uleb128 0x12
	.uleb128 0x13
	.long	.LASF70
	.uleb128 0x6
	.byte	0x8
	.long	0x366
	.uleb128 0x8
	.long	.LASF67
	.byte	0x20
	.byte	0xd
	.byte	0x3e
	.long	0x3aa
	.uleb128 0xa
	.string	"k"
	.byte	0xd
	.byte	0x42
	.long	0x98
	.byte	0
	.uleb128 0xa
	.string	"v"
	.byte	0xd
	.byte	0x46
	.long	0x35f
	.byte	0x8
	.uleb128 0x9
	.long	.LASF68
	.byte	0xd
	.byte	0x4a
	.long	0x3aa
	.byte	0x10
	.uleb128 0x9
	.long	.LASF69
	.byte	0xd
	.byte	0x4e
	.long	0x3aa
	.byte	0x18
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x371
	.uleb128 0x4
	.long	.LASF70
	.byte	0xe
	.byte	0x51
	.long	0x366
	.uleb128 0x2
	.byte	0x10
	.byte	0x4
	.long	.LASF71
	.uleb128 0x4
	.long	.LASF72
	.byte	0x1
	.byte	0x19
	.long	0x57
	.uleb128 0x4
	.long	.LASF73
	.byte	0x1
	.byte	0x1a
	.long	0x3b
	.uleb128 0x4
	.long	.LASF74
	.byte	0x1
	.byte	0x1c
	.long	0x34
	.uleb128 0x14
	.long	.LASF170
	.byte	0x8
	.byte	0x1
	.byte	0x34
	.long	0x411
	.uleb128 0x15
	.string	"val"
	.byte	0x1
	.byte	0x35
	.long	0x3c2
	.uleb128 0x15
	.string	"buf"
	.byte	0x1
	.byte	0x36
	.long	0x411
	.uleb128 0x16
	.long	.LASF75
	.byte	0x1
	.byte	0x37
	.long	0x417
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x172
	.uleb128 0x6
	.byte	0x8
	.long	0x3cd
	.uleb128 0x17
	.byte	0x8
	.byte	0x1
	.byte	0x3a
	.long	0x44a
	.uleb128 0x9
	.long	.LASF76
	.byte	0x1
	.byte	0x3c
	.long	0x44a
	.byte	0
	.uleb128 0x9
	.long	.LASF77
	.byte	0x1
	.byte	0x3d
	.long	0x3cd
	.byte	0x4
	.uleb128 0x9
	.long	.LASF78
	.byte	0x1
	.byte	0x3e
	.long	0x3cd
	.byte	0x6
	.byte	0
	.uleb128 0x2
	.byte	0x4
	.byte	0x4
	.long	.LASF79
	.uleb128 0x4
	.long	.LASF80
	.byte	0x1
	.byte	0x3f
	.long	0x41d
	.uleb128 0xb
	.byte	0x4
	.long	0x42
	.byte	0x1
	.byte	0x46
	.long	0x478
	.uleb128 0x18
	.string	"S1"
	.byte	0
	.uleb128 0x18
	.string	"S2"
	.byte	0x1
	.uleb128 0x18
	.string	"S3"
	.byte	0x2
	.byte	0
	.uleb128 0x4
	.long	.LASF81
	.byte	0x1
	.byte	0x48
	.long	0x45c
	.uleb128 0xb
	.byte	0x4
	.long	0x42
	.byte	0x1
	.byte	0x4d
	.long	0x49c
	.uleb128 0xc
	.long	.LASF82
	.byte	0
	.uleb128 0xc
	.long	.LASF83
	.byte	0x1
	.byte	0
	.uleb128 0x4
	.long	.LASF84
	.byte	0x1
	.byte	0x50
	.long	0x483
	.uleb128 0xb
	.byte	0x4
	.long	0x42
	.byte	0x1
	.byte	0x55
	.long	0x4c0
	.uleb128 0xc
	.long	.LASF85
	.byte	0
	.uleb128 0xc
	.long	.LASF86
	.byte	0x1
	.byte	0
	.uleb128 0x4
	.long	.LASF87
	.byte	0x1
	.byte	0x58
	.long	0x4a7
	.uleb128 0xb
	.byte	0x4
	.long	0x42
	.byte	0x1
	.byte	0x5e
	.long	0x4fc
	.uleb128 0xc
	.long	.LASF88
	.byte	0
	.uleb128 0xc
	.long	.LASF89
	.byte	0x1
	.uleb128 0xc
	.long	.LASF90
	.byte	0x2
	.uleb128 0xc
	.long	.LASF91
	.byte	0x3
	.uleb128 0xc
	.long	.LASF92
	.byte	0x4
	.uleb128 0xc
	.long	.LASF93
	.byte	0x5
	.byte	0
	.uleb128 0x4
	.long	.LASF94
	.byte	0x1
	.byte	0x65
	.long	0x4cb
	.uleb128 0x17
	.byte	0x4
	.byte	0x1
	.byte	0x72
	.long	0x540
	.uleb128 0x9
	.long	.LASF95
	.byte	0x1
	.byte	0x74
	.long	0x3d8
	.byte	0
	.uleb128 0x9
	.long	.LASF96
	.byte	0x1
	.byte	0x75
	.long	0x3d8
	.byte	0x1
	.uleb128 0x9
	.long	.LASF97
	.byte	0x1
	.byte	0x76
	.long	0x3d8
	.byte	0x2
	.uleb128 0x9
	.long	.LASF98
	.byte	0x1
	.byte	0x77
	.long	0x3d8
	.byte	0x3
	.byte	0
	.uleb128 0x4
	.long	.LASF99
	.byte	0x1
	.byte	0x78
	.long	0x507
	.uleb128 0x17
	.byte	0x10
	.byte	0x1
	.byte	0x79
	.long	0x56c
	.uleb128 0x9
	.long	.LASF100
	.byte	0x1
	.byte	0x7b
	.long	0x5e
	.byte	0
	.uleb128 0x9
	.long	.LASF101
	.byte	0x1
	.byte	0x7c
	.long	0x540
	.byte	0x8
	.byte	0
	.uleb128 0x4
	.long	.LASF102
	.byte	0x1
	.byte	0x7d
	.long	0x54b
	.uleb128 0xb
	.byte	0x4
	.long	0x42
	.byte	0x1
	.byte	0x84
	.long	0x590
	.uleb128 0xc
	.long	.LASF103
	.byte	0
	.uleb128 0xc
	.long	.LASF104
	.byte	0x1
	.byte	0
	.uleb128 0x4
	.long	.LASF105
	.byte	0x1
	.byte	0x86
	.long	0x577
	.uleb128 0xb
	.byte	0x4
	.long	0x42
	.byte	0x1
	.byte	0x8d
	.long	0x5b4
	.uleb128 0xc
	.long	.LASF106
	.byte	0
	.uleb128 0xc
	.long	.LASF107
	.byte	0x1
	.byte	0
	.uleb128 0x4
	.long	.LASF108
	.byte	0x1
	.byte	0x8f
	.long	0x59b
	.uleb128 0x19
	.long	.LASF111
	.byte	0x1
	.byte	0x99
	.long	0x3c2
	.quad	.LFB2
	.quad	.LFE2-.LFB2
	.uleb128 0x1
	.byte	0x9c
	.long	0x5fd
	.uleb128 0x1a
	.long	.LASF109
	.byte	0x1
	.byte	0x99
	.long	0x57
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.uleb128 0x1a
	.long	.LASF110
	.byte	0x1
	.byte	0x99
	.long	0x5fd
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0xa5
	.uleb128 0x19
	.long	.LASF112
	.byte	0x1
	.byte	0xd1
	.long	0x3c2
	.quad	.LFB3
	.quad	.LFE3-.LFB3
	.uleb128 0x1
	.byte	0x9c
	.long	0x65c
	.uleb128 0x1b
	.string	"IP"
	.byte	0x1
	.byte	0xd1
	.long	0xb2
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x1a
	.long	.LASF113
	.byte	0x1
	.byte	0xd1
	.long	0x3cd
	.uleb128 0x2
	.byte	0x91
	.sleb128 -44
	.uleb128 0x1c
	.long	.LASF114
	.byte	0x1
	.byte	0xd3
	.long	0x3c2
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x1c
	.long	.LASF115
	.byte	0x1
	.byte	0xd3
	.long	0x3c2
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.byte	0
	.uleb128 0x1d
	.long	.LASF116
	.byte	0x1
	.byte	0xf7
	.long	0x3c2
	.quad	.LFB4
	.quad	.LFE4-.LFB4
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x1e
	.long	.LASF117
	.byte	0x1
	.value	0x119
	.long	0x3c2
	.quad	.LFB5
	.quad	.LFE5-.LFB5
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x1e
	.long	.LASF118
	.byte	0x1
	.value	0x13a
	.long	0x3c2
	.quad	.LFB6
	.quad	.LFE6-.LFB6
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x1f
	.long	.LASF129
	.byte	0x1
	.value	0x149
	.quad	.LFB7
	.quad	.LFE7-.LFB7
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x20
	.long	.LASF119
	.byte	0x1
	.value	0x15a
	.long	0x3c2
	.quad	.LFB8
	.quad	.LFE8-.LFB8
	.uleb128 0x1
	.byte	0x9c
	.long	0x701
	.uleb128 0x21
	.long	.LASF120
	.byte	0x1
	.value	0x15c
	.long	0x57
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.byte	0
	.uleb128 0x22
	.string	"TH1"
	.byte	0x1
	.value	0x17f
	.long	0x98
	.quad	.LFB9
	.quad	.LFE9-.LFB9
	.uleb128 0x1
	.byte	0x9c
	.long	0x733
	.uleb128 0x23
	.long	.LASF121
	.byte	0x1
	.value	0x17f
	.long	0x98
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.byte	0
	.uleb128 0x24
	.long	.LASF133
	.byte	0x1
	.value	0x1bc
	.quad	.LFB10
	.quad	.LFE10-.LFB10
	.uleb128 0x1
	.byte	0x9c
	.long	0x770
	.uleb128 0x23
	.long	.LASF122
	.byte	0x1
	.value	0x1bc
	.long	0xb2
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x23
	.long	.LASF123
	.byte	0x1
	.value	0x1bc
	.long	0x3cd
	.uleb128 0x2
	.byte	0x91
	.sleb128 -28
	.byte	0
	.uleb128 0x22
	.string	"TH2"
	.byte	0x1
	.value	0x1c7
	.long	0x98
	.quad	.LFB11
	.quad	.LFE11-.LFB11
	.uleb128 0x1
	.byte	0x9c
	.long	0x7a2
	.uleb128 0x23
	.long	.LASF124
	.byte	0x1
	.value	0x1c7
	.long	0x98
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.uleb128 0x20
	.long	.LASF125
	.byte	0x1
	.value	0x1e0
	.long	0x57
	.quad	.LFB12
	.quad	.LFE12-.LFB12
	.uleb128 0x1
	.byte	0x9c
	.long	0x822
	.uleb128 0x21
	.long	.LASF126
	.byte	0x1
	.value	0x1e2
	.long	0xa5
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x25
	.string	"key"
	.byte	0x1
	.value	0x1e3
	.long	0xa5
	.uleb128 0x2
	.byte	0x91
	.sleb128 -56
	.uleb128 0x25
	.string	"val"
	.byte	0x1
	.value	0x1e3
	.long	0x36b
	.uleb128 0x2
	.byte	0x91
	.sleb128 -48
	.uleb128 0x26
	.quad	.LBB2
	.quad	.LBE2-.LBB2
	.uleb128 0x21
	.long	.LASF127
	.byte	0x1
	.value	0x1e3
	.long	0x3aa
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x21
	.long	.LASF128
	.byte	0x1
	.value	0x1e3
	.long	0x3aa
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.byte	0
	.byte	0
	.uleb128 0x27
	.long	.LASF171
	.byte	0x1
	.value	0x20d
	.quad	.LFB13
	.quad	.LFE13-.LFB13
	.uleb128 0x1
	.byte	0x9c
	.long	0x88f
	.uleb128 0x25
	.string	"key"
	.byte	0x1
	.value	0x20f
	.long	0xa5
	.uleb128 0x2
	.byte	0x91
	.sleb128 -48
	.uleb128 0x25
	.string	"val"
	.byte	0x1
	.value	0x20f
	.long	0x36b
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x26
	.quad	.LBB4
	.quad	.LBE4-.LBB4
	.uleb128 0x21
	.long	.LASF127
	.byte	0x1
	.value	0x20f
	.long	0x3aa
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.uleb128 0x21
	.long	.LASF128
	.byte	0x1
	.value	0x20f
	.long	0x3aa
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.byte	0
	.uleb128 0x1f
	.long	.LASF130
	.byte	0x1
	.value	0x247
	.quad	.LFB14
	.quad	.LFE14-.LFB14
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x1f
	.long	.LASF131
	.byte	0x1
	.value	0x25f
	.quad	.LFB15
	.quad	.LFE15-.LFB15
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x1f
	.long	.LASF132
	.byte	0x1
	.value	0x277
	.quad	.LFB16
	.quad	.LFE16-.LFB16
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x24
	.long	.LASF134
	.byte	0x1
	.value	0x291
	.quad	.LFB17
	.quad	.LFE17-.LFB17
	.uleb128 0x1
	.byte	0x9c
	.long	0x90b
	.uleb128 0x21
	.long	.LASF135
	.byte	0x1
	.value	0x293
	.long	0x90b
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x3b0
	.uleb128 0x24
	.long	.LASF136
	.byte	0x1
	.value	0x29f
	.quad	.LFB18
	.quad	.LFE18-.LFB18
	.uleb128 0x1
	.byte	0x9c
	.long	0x93f
	.uleb128 0x21
	.long	.LASF137
	.byte	0x1
	.value	0x2a1
	.long	0x90b
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.uleb128 0x24
	.long	.LASF138
	.byte	0x1
	.value	0x2b3
	.quad	.LFB19
	.quad	.LFE19-.LFB19
	.uleb128 0x1
	.byte	0x9c
	.long	0x96d
	.uleb128 0x21
	.long	.LASF137
	.byte	0x1
	.value	0x2b5
	.long	0x90b
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.uleb128 0x24
	.long	.LASF139
	.byte	0x1
	.value	0x2c6
	.quad	.LFB20
	.quad	.LFE20-.LFB20
	.uleb128 0x1
	.byte	0x9c
	.long	0x99b
	.uleb128 0x21
	.long	.LASF137
	.byte	0x1
	.value	0x2c8
	.long	0x90b
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.uleb128 0x1c
	.long	.LASF140
	.byte	0x1
	.byte	0x23
	.long	0x312
	.uleb128 0x9
	.byte	0x3
	.quad	client_sock_addr
	.uleb128 0x1c
	.long	.LASF141
	.byte	0x1
	.byte	0x38
	.long	0x3e3
	.uleb128 0x9
	.byte	0x3
	.quad	Seminit
	.uleb128 0x1c
	.long	.LASF142
	.byte	0x1
	.byte	0x6a
	.long	0x1df
	.uleb128 0x9
	.byte	0x3
	.quad	sem_opr
	.uleb128 0x28
	.long	.LASF143
	.byte	0x1
	.byte	0x1f
	.long	0x3c2
	.uleb128 0x9
	.byte	0x3
	.quad	SHMID
	.uleb128 0x28
	.long	.LASF144
	.byte	0x1
	.byte	0x20
	.long	0x3c2
	.uleb128 0x9
	.byte	0x3
	.quad	SEMID
	.uleb128 0x28
	.long	.LASF145
	.byte	0x1
	.byte	0x21
	.long	0x3c2
	.uleb128 0x9
	.byte	0x3
	.quad	socfd
	.uleb128 0x28
	.long	.LASF146
	.byte	0x1
	.byte	0x22
	.long	0x3c2
	.uleb128 0x9
	.byte	0x3
	.quad	MessageQueue_ID
	.uleb128 0x28
	.long	.LASF147
	.byte	0x1
	.byte	0x30
	.long	0x159
	.uleb128 0x9
	.byte	0x3
	.quad	TH1_ID
	.uleb128 0x28
	.long	.LASF148
	.byte	0x1
	.byte	0x31
	.long	0x159
	.uleb128 0x9
	.byte	0x3
	.quad	TH2_ID
	.uleb128 0x28
	.long	.LASF149
	.byte	0x1
	.byte	0x40
	.long	0x451
	.uleb128 0x9
	.byte	0x3
	.quad	Sensordata
	.uleb128 0x28
	.long	.LASF150
	.byte	0x1
	.byte	0x41
	.long	0xa82
	.uleb128 0x9
	.byte	0x3
	.quad	Sensordata_SHM_Addr
	.uleb128 0x6
	.byte	0x8
	.long	0x451
	.uleb128 0x28
	.long	.LASF151
	.byte	0x1
	.byte	0x49
	.long	0x478
	.uleb128 0x9
	.byte	0x3
	.quad	State
	.uleb128 0x28
	.long	.LASF152
	.byte	0x1
	.byte	0x51
	.long	0xab2
	.uleb128 0x9
	.byte	0x3
	.quad	serverstatus
	.uleb128 0x29
	.long	0x49c
	.uleb128 0x28
	.long	.LASF153
	.byte	0x1
	.byte	0x59
	.long	0x4c0
	.uleb128 0x9
	.byte	0x3
	.quad	DatafromServerAvailableStat
	.uleb128 0x28
	.long	.LASF154
	.byte	0x1
	.byte	0x66
	.long	0x4fc
	.uleb128 0x9
	.byte	0x3
	.quad	PacketIDReceived
	.uleb128 0x10
	.long	0xab
	.long	0xaf2
	.uleb128 0x2a
	.long	0x7b
	.value	0x1f3
	.byte	0
	.uleb128 0x28
	.long	.LASF155
	.byte	0x1
	.byte	0x69
	.long	0xae1
	.uleb128 0x9
	.byte	0x3
	.quad	ReceivedDataFromServer
	.uleb128 0x28
	.long	.LASF156
	.byte	0x1
	.byte	0x6b
	.long	0x90b
	.uleb128 0x9
	.byte	0x3
	.quad	jobj_received_data
	.uleb128 0x28
	.long	.LASF157
	.byte	0x1
	.byte	0x6c
	.long	0x90b
	.uleb128 0x9
	.byte	0x3
	.quad	jobj_sent_data
	.uleb128 0x28
	.long	.LASF137
	.byte	0x1
	.byte	0x6d
	.long	0x90b
	.uleb128 0x9
	.byte	0x3
	.quad	jstring
	.uleb128 0x28
	.long	.LASF158
	.byte	0x1
	.byte	0x7e
	.long	0x56c
	.uleb128 0x9
	.byte	0x3
	.quad	controldata
	.uleb128 0x28
	.long	.LASF159
	.byte	0x1
	.byte	0x87
	.long	0xb70
	.uleb128 0x9
	.byte	0x3
	.quad	SendToServerStatus
	.uleb128 0x29
	.long	0x590
	.uleb128 0x28
	.long	.LASF160
	.byte	0x1
	.byte	0x90
	.long	0xb8a
	.uleb128 0x9
	.byte	0x3
	.quad	sendcontroldatastat
	.uleb128 0x29
	.long	0x5b4
	.uleb128 0x10
	.long	0xab
	.long	0xb9f
	.uleb128 0x11
	.long	0x7b
	.byte	0xf
	.byte	0
	.uleb128 0x28
	.long	.LASF161
	.byte	0x1
	.byte	0x94
	.long	0xb8f
	.uleb128 0x9
	.byte	0x3
	.quad	Server_IP
	.uleb128 0x10
	.long	0xab
	.long	0xbc4
	.uleb128 0x11
	.long	0x7b
	.byte	0x4
	.byte	0
	.uleb128 0x28
	.long	.LASF162
	.byte	0x1
	.byte	0x95
	.long	0xbb4
	.uleb128 0x9
	.byte	0x3
	.quad	PortNumber
	.uleb128 0x28
	.long	.LASF163
	.byte	0x1
	.byte	0x96
	.long	0x3c2
	.uleb128 0x9
	.byte	0x3
	.quad	Port
	.uleb128 0x2b
	.long	.LASF164
	.byte	0x1
	.value	0x17e
	.long	0xa5
	.uleb128 0x9
	.byte	0x3
	.quad	test
	.uleb128 0x2b
	.long	.LASF165
	.byte	0x1
	.value	0x1de
	.long	0x90b
	.uleb128 0x9
	.byte	0x3
	.quad	jobj_received_data_sub_string
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
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x7
	.uleb128 0x26
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x8
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
	.uleb128 0x9
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
	.uleb128 0xa
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
	.uleb128 0xb
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
	.uleb128 0xc
	.uleb128 0x28
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1c
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xd
	.uleb128 0x4
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
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
	.uleb128 0xe
	.uleb128 0x28
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1c
	.uleb128 0x6
	.byte	0
	.byte	0
	.uleb128 0xf
	.uleb128 0x28
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1c
	.uleb128 0x5
	.byte	0
	.byte	0
	.uleb128 0x10
	.uleb128 0x1
	.byte	0x1
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x11
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x12
	.uleb128 0x26
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x13
	.uleb128 0x13
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3c
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x14
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
	.uleb128 0x15
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
	.uleb128 0x16
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
	.uleb128 0x17
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
	.uleb128 0x18
	.uleb128 0x28
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x1c
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x19
	.uleb128 0x2e
	.byte	0x1
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
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1a
	.uleb128 0x5
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
	.uleb128 0x1b
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
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
	.uleb128 0x1c
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
	.uleb128 0x1d
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
	.uleb128 0x1e
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
	.uleb128 0x1f
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
	.uleb128 0x20
	.uleb128 0x2e
	.byte	0x1
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
	.uleb128 0x21
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
	.uleb128 0x22
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
	.uleb128 0x23
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
	.uleb128 0x24
	.uleb128 0x2e
	.byte	0x1
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
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x25
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
	.uleb128 0x26
	.uleb128 0xb
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.byte	0
	.byte	0
	.uleb128 0x27
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
	.uleb128 0x28
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
	.uleb128 0x29
	.uleb128 0x35
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x2a
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0x5
	.byte	0
	.byte	0
	.uleb128 0x2b
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
.LASF80:
	.string	"Sensordata_t"
.LASF31:
	.string	"sem_ctime"
.LASF84:
	.string	"serverstatus_t"
.LASF105:
	.string	"SendToServerStatus_t"
.LASF119:
	.string	"ReadFromServer"
.LASF160:
	.string	"sendcontroldatastat"
.LASF142:
	.string	"sem_opr"
.LASF69:
	.string	"prev"
.LASF168:
	.string	"/home/akv/aj1/drive-download-20170523T182400Z-001/SocketClient_2"
.LASF28:
	.string	"semid_ds"
.LASF51:
	.string	"SOCK_NONBLOCK"
.LASF25:
	.string	"long long unsigned int"
.LASF58:
	.string	"in_addr_t"
.LASF150:
	.string	"Sensordata_SHM_Addr"
.LASF81:
	.string	"States_t"
.LASF164:
	.string	"test"
.LASF68:
	.string	"next"
.LASF37:
	.string	"sem_op"
.LASF49:
	.string	"SOCK_PACKET"
.LASF70:
	.string	"json_object"
.LASF38:
	.string	"sem_flg"
.LASF132:
	.string	"GetSDData"
.LASF141:
	.string	"Seminit"
.LASF26:
	.string	"long long int"
.LASF4:
	.string	"signed char"
.LASF76:
	.string	"TS_data"
.LASF11:
	.string	"__key_t"
.LASF94:
	.string	"PacketIDReceived_t"
.LASF117:
	.string	"SEM_Init"
.LASF98:
	.string	"LED4_alarm"
.LASF6:
	.string	"long int"
.LASF107:
	.string	"Controldata_send"
.LASF82:
	.string	"connected"
.LASF29:
	.string	"sem_perm"
.LASF118:
	.string	"MQ_Init"
.LASF96:
	.string	"LED2_lock"
.LASF43:
	.string	"SOCK_STREAM"
.LASF56:
	.string	"uint16_t"
.LASF89:
	.string	"SMK_S"
.LASF104:
	.string	"SEND"
.LASF75:
	.string	"array"
.LASF129:
	.string	"ConnectionManager"
.LASF90:
	.string	"IR_S"
.LASF88:
	.string	"TEMP_S"
.LASF92:
	.string	"action"
.LASF97:
	.string	"LED3_fan"
.LASF166:
	.string	"GNU C11 5.4.0 20160609 -mtune=generic -march=x86-64 -g -fstack-protector-strong"
.LASF66:
	.string	"sin_zero"
.LASF95:
	.string	"LED1_light"
.LASF126:
	.string	"value"
.LASF46:
	.string	"SOCK_RDM"
.LASF34:
	.string	"__glibc_reserved4"
.LASF3:
	.string	"unsigned int"
.LASF23:
	.string	"key_t"
.LASF114:
	.string	"client_sock_addr_length"
.LASF133:
	.string	"SendToServer"
.LASF106:
	.string	"Controldata_hold"
.LASF0:
	.string	"long unsigned int"
.LASF35:
	.string	"sembuf"
.LASF112:
	.string	"TriggerConnection"
.LASF113:
	.string	"portnumber"
.LASF124:
	.string	"arg2"
.LASF2:
	.string	"short unsigned int"
.LASF65:
	.string	"sin_addr"
.LASF103:
	.string	"HOLD"
.LASF149:
	.string	"Sensordata"
.LASF44:
	.string	"SOCK_DGRAM"
.LASF60:
	.string	"s_addr"
.LASF47:
	.string	"SOCK_SEQPACKET"
.LASF134:
	.string	"ConvertTempToJSON"
.LASF127:
	.string	"entrykey"
.LASF19:
	.string	"__seq"
.LASF162:
	.string	"PortNumber"
.LASF15:
	.string	"cuid"
.LASF153:
	.string	"DatafromServerAvailableStat"
.LASF5:
	.string	"short int"
.LASF137:
	.string	"jstring"
.LASF91:
	.string	"DEV_ID_REQUEST"
.LASF39:
	.string	"PTHREAD_CANCEL_ENABLE"
.LASF27:
	.string	"ipc_perm"
.LASF87:
	.string	"DatafromServerAvailableStat_t"
.LASF63:
	.string	"sin_family"
.LASF148:
	.string	"TH2_ID"
.LASF99:
	.string	"control_data_t"
.LASF143:
	.string	"SHMID"
.LASF9:
	.string	"sizetype"
.LASF131:
	.string	"GetIRData"
.LASF159:
	.string	"SendToServerStatus"
.LASF139:
	.string	"ConvertDEVID_ToJSON"
.LASF40:
	.string	"PTHREAD_CANCEL_DISABLE"
.LASF161:
	.string	"Server_IP"
.LASF12:
	.string	"__syscall_ulong_t"
.LASF100:
	.string	"msg_type"
.LASF30:
	.string	"sem_otime"
.LASF167:
	.string	"client.c"
.LASF115:
	.string	"ConnectResponse"
.LASF42:
	.string	"PTHREAD_CANCEL_ASYNCHRONOUS"
.LASF74:
	.string	"uchar"
.LASF48:
	.string	"SOCK_DCCP"
.LASF135:
	.string	"jdoub"
.LASF79:
	.string	"float"
.LASF154:
	.string	"PacketIDReceived"
.LASF171:
	.string	"Process_sub_control_packet"
.LASF54:
	.string	"sa_family"
.LASF147:
	.string	"TH1_ID"
.LASF169:
	.string	"__socket_type"
.LASF157:
	.string	"jobj_sent_data"
.LASF152:
	.string	"serverstatus"
.LASF24:
	.string	"pthread_t"
.LASF78:
	.string	"SS_data"
.LASF1:
	.string	"unsigned char"
.LASF165:
	.string	"jobj_received_data_sub_string"
.LASF158:
	.string	"controldata"
.LASF145:
	.string	"socfd"
.LASF122:
	.string	"JSON_data"
.LASF77:
	.string	"IRS_data"
.LASF116:
	.string	"SHM_Init"
.LASF136:
	.string	"ConvertIRToJSON"
.LASF57:
	.string	"uint32_t"
.LASF71:
	.string	"long double"
.LASF108:
	.string	"sendcontroldatastatus_t"
.LASF13:
	.string	"char"
.LASF17:
	.string	"mode"
.LASF140:
	.string	"client_sock_addr"
.LASF151:
	.string	"State"
.LASF53:
	.string	"sockaddr"
.LASF41:
	.string	"PTHREAD_CANCEL_DEFERRED"
.LASF128:
	.string	"entry_nextkey"
.LASF138:
	.string	"ConvertSDToJSON"
.LASF32:
	.string	"sem_nsems"
.LASF64:
	.string	"sin_port"
.LASF7:
	.string	"__uid_t"
.LASF120:
	.string	"read_ret"
.LASF170:
	.string	"semun"
.LASF163:
	.string	"Port"
.LASF130:
	.string	"GetTempData"
.LASF144:
	.string	"SEMID"
.LASF121:
	.string	"arg1"
.LASF72:
	.string	"sint"
.LASF93:
	.string	"NO_PACKET"
.LASF18:
	.string	"__pad1"
.LASF20:
	.string	"__pad2"
.LASF125:
	.string	"Packet_Processing"
.LASF85:
	.string	"Available"
.LASF101:
	.string	"control_data"
.LASF10:
	.string	"__time_t"
.LASF52:
	.string	"sa_family_t"
.LASF21:
	.string	"__glibc_reserved1"
.LASF22:
	.string	"__glibc_reserved2"
.LASF33:
	.string	"__glibc_reserved3"
.LASF110:
	.string	"argv"
.LASF83:
	.string	"notconnected"
.LASF50:
	.string	"SOCK_CLOEXEC"
.LASF73:
	.string	"suint"
.LASF102:
	.string	"controldata_t"
.LASF14:
	.string	"__key"
.LASF36:
	.string	"sem_num"
.LASF62:
	.string	"sockaddr_in"
.LASF156:
	.string	"jobj_received_data"
.LASF123:
	.string	"Sizeofdata"
.LASF146:
	.string	"MessageQueue_ID"
.LASF155:
	.string	"ReceivedDataFromServer"
.LASF109:
	.string	"argc"
.LASF55:
	.string	"sa_data"
.LASF45:
	.string	"SOCK_RAW"
.LASF67:
	.string	"lh_entry"
.LASF16:
	.string	"cgid"
.LASF111:
	.string	"main"
.LASF61:
	.string	"in_port_t"
.LASF86:
	.string	"NotAvailable"
.LASF59:
	.string	"in_addr"
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
