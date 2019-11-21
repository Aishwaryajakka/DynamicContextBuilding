#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <pthread.h>
#include <errno.h>
#include <sys/msg.h>
#include <termios.h>
#include <fcntl.h>


#define SHM_KEY 1122
#define SEM_KEY 3344
#define MQ_KEY  4455
#define SUCCESS 0
#define FAILURE -1
#define UART_PORT "/dev/ttyUSB0"
#define SCALE  1
#define OFFSET 1


typedef unsigned int uint;
typedef signed int sint;
typedef short unsigned int suint;
typedef short signed int ssint;
typedef unsigned char uchar;


sint SHMID;
sint SEMID;
sint MessageQueue_ID;

sint SHM_Init(void);
sint SEM_Init(void);
sint MQ_Init(void);
void* TH1(void *arg1);
void* TH2(void *arg2);
pthread_t TH1_ID;
pthread_t TH2_ID;


static union semun{
                      sint val;
                      struct semid_ds *buf;
                      suint *array;
                  }Seminit;

typedef struct
             {
                   float TS_data;
                   suint IRS_data;
                   suint SS_data;
             }Sensordata_t;
Sensordata_t Sensordata;
Sensordata_t *Sensordata_SHM_Addr = (Sensordata_t *)NULL;



typedef enum
           {
               S1,S2,S3
           }States_t;
States_t State;

char ReceivedDataFromServer[500];
static struct sembuf sem_opr;

typedef struct
             {
                  uchar LED1_light;
                  uchar LED2_lock;
                  uchar LED3_fan;
                  uchar LED4_alarm;
             }control_data_t;
typedef struct
             {
                  long int       msg_type;
                  control_data_t control_data; 
             }controldata_t;
controldata_t controldata;


static sint UART_Init(void);
sint UART_fd;
struct termios TerminalSettings;
void ConvertToRealValue(void);
void StoreToSHM(void);


char data[] = {'x','y','z','u','v'};

sint main()
 {   
     SHM_Init();SEM_Init();
     while(3)
     {
           switch(State)
           {
                case S1:
                     if( MQ_Init() == SUCCESS )
                     {
                           State=S2;
                     }
                break;      
                case S2:
                     while(3)
                     {
                        if( UART_Init() == SUCCESS )
                        {  
                             write( UART_fd , &data ,5 );
                            if( pthread_create(&TH1_ID,NULL,TH1,NULL) < 0 )
                              {
                                   perror("TH1 creation failed:UARTPROCESS");
                              }
                            if( pthread_create( &TH2_ID , NULL , TH2 , NULL ) < 0 )
                              {
                                   perror("TH2 creation failed:UARTPROCESS");
                              }
                            printf("UART Process entrted in operational state....\n");    /****TB6****/
                            State=S3;
                            break;
                         }
                         sleep(2);
                      }  
                break;
                case S3:
                while(2);
                break;
           }  
     }
     return 0;
 }




sint SHM_Init(void)
 {
     SHMID = shmget( (key_t)SHM_KEY , sizeof(Sensordata) , 0666|IPC_CREAT|IPC_EXCL );
     if(SHMID < 0)
       {
          if(errno == EEXIST)
            {
               SHMID = shmget( (key_t)SHM_KEY , sizeof(Sensordata) , 0666 );
            }
          else
            {
               perror("SHM Init failed:UARTPROCESS");
               return FAILURE;
            }
       }
   
     Sensordata_SHM_Addr = (Sensordata_t *)shmat( SHMID , NULL ,0);
  
     if( Sensordata_SHM_Addr == (Sensordata_t *)-1 )
       {
          perror("SHM Attach failed:UARTPROCESS"); 
          return FAILURE;
       }
     return SUCCESS;
 }



sint SEM_Init(void)
 {
   SEMID = semget( (key_t)SEM_KEY , 1 , IPC_CREAT|IPC_EXCL|0666 );
   if( SEMID < 0 )
     {
       if(errno == EEXIST)
        {
            SEMID = semget( (key_t)SEM_KEY , 1 , 0666 );
        }
       else
        {
            perror("Sem creation failed:UARTPROCESS");
            return FAILURE;
        }
     }
   else     /******Set a initial value for the semaphore with specified key***********/
     {
       Seminit.val = 1;
       if( semctl( SEMID , 0 , SETVAL , Seminit ) < 0 )
         {
             perror("Sem init failed:UARTPROCESS");
             return FAILURE;
         }
     }
   return SUCCESS;
 }


sint MQ_Init(void)
 {
      if( ( MessageQueue_ID = msgget( (key_t)MQ_KEY , 0666|IPC_CREAT ) ) < 0 )
      {
           perror("Message queue creation failed:UARTPROCESS");
           return FAILURE;
      }
     return SUCCESS;
 }



static sint UART_Init(void)
 {
    if(( UART_fd = open( UART_PORT, O_RDWR | O_NOCTTY   ) ) < 0 )
    {
          perror("Unable to open UARt port:UART_Init:UARTPROCESS");  close(UART_fd);return FAILURE;   
    }
    tcgetattr( UART_fd , &TerminalSettings );
    cfsetospeed( &TerminalSettings, B9600 );
       cfsetispeed( &TerminalSettings, B9600 );
    TerminalSettings.c_cflag |=  (CLOCAL | CREAD);    /**ignore modem controls**/
       TerminalSettings.c_cflag &=  ~CSIZE;
       TerminalSettings.c_cflag |=  CS8;                /**8-bit characters**/
       TerminalSettings.c_cflag &=  ~PARENB;            /**no parity bit**/
       TerminalSettings.c_cflag &=  ~CSTOPB;            /**only need 1 stop bit**/
       TerminalSettings.c_cflag &=  ~CRTSCTS;           /**no hardware flowcontrol**/

       /* setup for non-canonical mode */
       TerminalSettings.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON);
       TerminalSettings.c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
       TerminalSettings.c_oflag &= ~OPOST;

       /* fetch bytes as they become available */
       TerminalSettings.c_cc[VMIN]  = 5;
       TerminalSettings.c_cc[VTIME] = 1;

       fcntl( UART_fd, F_SETFL, FNDELAY);
    /******************
//    newts.c_cflag = B115200 | CS8 | CLOCAL | CREAD;
  //  newts.c_iflag = IGNPAR;
 //   newts.c_oflag = 0;
  //  newts.c_lflag = 0
    **********************/
  //  tcflush( UART_fd , TCIFLUSH );
    if( tcsetattr( UART_fd , TCSANOW, &TerminalSettings ) < 0 )
    {
           perror("Unable to set UART attribute:UART_Init:UARTPROCESS"); close(UART_fd); return FAILURE;
    }
    return SUCCESS;
 }





typedef enum
           {
              NO,
              YES
           }Datareceivedfromuart_t;
static Datareceivedfromuart_t ReadFromUART(void);

typedef struct
             {
                  uchar RcvdPID;
                  suint TempValue;
                  uchar SmokeData;
                  uchar IRData;
             }ReceivedUartFormat_t;
union UART 
         {
              ReceivedUartFormat_t ReceivedUartFormat;
              uchar ReceivedUARTBuffer[5];
         }ReceivedUARTData;


/**********Will read data from UART and store to SHM***********/
void* TH1(void *arg1)
 {
     pthread_setcancelstate( PTHREAD_CANCEL_ENABLE , NULL );
     pthread_setcanceltype( PTHREAD_CANCEL_ASYNCHRONOUS , NULL );
      
     while(3)
          {
               if( ReadFromUART() == YES )       
               {
                    ConvertToRealValue();
                    StoreToSHM();
               }                        
          }
       return ((void *)SUCCESS);  
 }


unsigned char i=0;
/*****Data coming from UART********
55/TempValue(H)-TempValue(L)/SmokeData(1byte)/IRData(1byte)
**********************************/
static Datareceivedfromuart_t ReadFromUART(void)
 {
 //    unsigned char i=0;
     unsigned char a;
     if( read( UART_fd , &a, 1 ) > 0 )   
     {
           ReceivedUARTData.ReceivedUARTBuffer[i] = a;
           i++;
           if(i>4)
           {
           i = 0;        
         printf("1st : %x\n",ReceivedUARTData.ReceivedUARTBuffer[0]);
         printf("1st : %x\n",ReceivedUARTData.ReceivedUARTBuffer[1]);
         printf("1st : %x\n",ReceivedUARTData.ReceivedUARTBuffer[2]);
         printf("1st : %x\n",ReceivedUARTData.ReceivedUARTBuffer[3]);
         printf("1st : %x\n",ReceivedUARTData.ReceivedUARTBuffer[4]);
         printf("aaa\n"); 
         return ((Datareceivedfromuart_t)1);      
          }     
     }
  //   printf("bbb..\n");
     return ((Datareceivedfromuart_t)0);
 }


void ConvertToRealValue(void)
 {
     // Sensordata.TS_data  =  (( SCALE * ( ReceivedUARTData.ReceivedUartFormat.TempValue ) ) + OFFSET );
//      Sensordata.TS_data  =  (( 500*( ReceivedUARTData.ReceivedUartFormat.TempValue ) )/1024.0);   
//      Sensordata.SS_data  =  ReceivedUARTData.ReceivedUartFormat.SmokeData;
  //    printf("Smoke data in UART : %u\n",Sensordata.SS_data );
   //   Sensordata.IRS_data =  ReceivedUARTData.ReceivedUartFormat.IRData;
    //  printf("IRS data in UART : %u\n",Sensordata.IRS_data );

       Sensordata.TS_data  =  (( 500*( ReceivedUARTData.ReceivedUartFormat.TempValue ) )/1024.0);
       Sensordata.SS_data  =  ReceivedUARTData.ReceivedUARTBuffer[3];
       printf("Smoke data in UART : %u\n",Sensordata.SS_data );
       Sensordata.IRS_data =  ReceivedUARTData.ReceivedUARTBuffer[4];
       printf("IRS data in UART : %u\n",Sensordata.IRS_data );
 }



void StoreToSHM(void)
 {
    printf("e123\n");
    sem_opr.sem_num =  0; 
    sem_opr.sem_op  = -1;
    sem_opr.sem_flg = SEM_UNDO;
    if( semop( SEMID , &sem_opr ,1 ) < 0 )
      {
            perror("Sem locking failed:StoreToSHM:UARTPROCESS");
      }
    // Sensordata.TS_data = Sensordata_SHM_Addr->TS_data ;     
    Sensordata_SHM_Addr->TS_data =  Sensordata.TS_data;
    
    Sensordata_SHM_Addr->SS_data =  Sensordata.SS_data;
    printf("Smoke data stored in SHM : %u\n",Sensordata_SHM_Addr->SS_data);
    Sensordata_SHM_Addr->IRS_data =  Sensordata.IRS_data;                
    printf("IR data stored in SHM : %u\n",Sensordata_SHM_Addr->IRS_data);           
   // memcpy(Sensordata_SHM_Addr,);   
    sem_opr.sem_num =  0;
    sem_opr.sem_op  =  1;                                           
    sem_opr.sem_flg = SEM_UNDO;
    if( semop( SEMID , &sem_opr , 1 ) < 0 )
      {
             perror("Sem release failed:StoreToSHM:UARTPROCESS");
      }
 }





suint count = 0;
typedef enum
           {
              NOT_RECEIVED,RECEIVED
           }control_data_received_t;
static control_data_received_t control_data_received = NOT_RECEIVED;
void convert_to_uart_format(void);       
void SendToAudrino(void);
static uchar BufferToBeSentToAudrino[5];
/******Will receive conytrol data from client process and send to Audrino*******/
void* TH2(void *arg2)
 {
    pthread_setcancelstate( PTHREAD_CANCEL_ENABLE, NULL);
    pthread_setcanceltype( PTHREAD_CANCEL_ASYNCHRONOUS, NULL);
 
    while(4)
    {
          if( count >= 2 ) count = 0;
          switch( count )
          {
               case 0:
                    if( msgrcv( MessageQueue_ID , (void *)&controldata , sizeof(controldata.control_data) , 0 ,0 ) < 0 )
                    {
                         perror("Unable to receive control data through MSGQ from Socket client Process:TH2:UARTPROCESS");
                    }
                    else
                    {
                       control_data_received = RECEIVED;
                       printf("Control data received in UART process....\n");
                       printf("light : %u\n", controldata.control_data.LED1_light ); 
 printf("lock : %u\n", controldata.control_data.LED2_lock ); 
 printf("fan : %u\n", controldata.control_data.LED3_fan ); 
 printf("alarm : %u\n", controldata.control_data.LED4_alarm ); 







                    }
               break;
               case 1:
                    /*******************
                    AB/LED1_light/LED2_lock/LED3_fan/LED4_alarm/                    
                    ********************/
                    if( control_data_received == RECEIVED ) 
                    {
                        convert_to_uart_format();
                        SendToAudrino(); 
                        control_data_received = NOT_RECEIVED;       
                    }
               break;
          }
          count++;
    }
    return ( (void *)SUCCESS );
 }




void convert_to_uart_format(void)
 {
    BufferToBeSentToAudrino[0] = 0xAB;
    BufferToBeSentToAudrino[1] = controldata.control_data.LED1_light;
    BufferToBeSentToAudrino[2] = controldata.control_data.LED2_lock;
    BufferToBeSentToAudrino[3] = controldata.control_data.LED3_fan;
    BufferToBeSentToAudrino[4] = controldata.control_data.LED4_alarm;

 }




void SendToAudrino(void)
 {
     if( write( UART_fd , BufferToBeSentToAudrino , 5 ) < 0 )
     {
          perror("Unable to send data to audrino:SendToAudrino:UARTPROCESS");
     }
     else
     {
          printf("Successfully sent data to audrino...\n");
     }
 }

