#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <pthread.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include <sys/msg.h>
#include <json-c/json.h>


#define SHM_KEY 1122
#define SEM_KEY 3344
#define MQ_KEY  4455
#define SUCCESS 0
#define FAILURE -1
#define SERVERIP "172.20.10.2"   
#define PORTNUMBER 8080


typedef unsigned int uint;
typedef signed int sint;
typedef short unsigned int suint;
typedef short signed int ssint;
typedef unsigned char uchar;


sint SHMID;
sint SEMID;
sint socfd;
sint MessageQueue_ID;
static struct sockaddr_in client_sock_addr;


sint SHM_Init(void);
sint SEM_Init(void);
sint MQ_Init(void);
sint TriggerConnection( const char *IP, suint portnumber );
sint ReadFromServer(void);
void ConnectionManager(void);
int Packet_Processing(void);
void SendToServer( const char *JSON_data,suint Sizeofdata);
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


typedef enum
           {
               connected,
               notconnected
           }serverstatus_t;
volatile serverstatus_t serverstatus;


typedef enum
           {
                Available,
                NotAvailable
           }DatafromServerAvailableStat_t;
DatafromServerAvailableStat_t DatafromServerAvailableStat = NotAvailable;



typedef enum
           {
                 TEMP_S,
                 SMK_S,
                 IR_S,
                 DEV_ID_REQUEST,
                 action,
                 NO_PACKET 
           }PacketIDReceived_t;
PacketIDReceived_t PacketIDReceived = NO_PACKET;


char ReceivedDataFromServer[500];
static struct sembuf sem_opr;
json_object *jobj_received_data = NULL;
json_object *jobj_sent_data = NULL;
json_object *jstring = NULL;




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




typedef enum
           {
                 HOLD,SEND
           }SendToServerStatus_t;
volatile SendToServerStatus_t SendToServerStatus = HOLD;




typedef enum
           {
                Controldata_hold,Controldata_send
           }sendcontroldatastatus_t;
volatile sendcontroldatastatus_t sendcontroldatastat = Controldata_hold;



char Server_IP[16];
char PortNumber[5];
sint Port;


sint main( int argc , char *argv[] )
 {
     if( argc == 1 )
     {
          printf("Enter Server IP and port address through CL....\n");
          exit(0);
     }
     else
     {
          strcpy( Server_IP , argv[1] );
          strcpy( PortNumber , argv[2] );
          printf("Server IP : %s\n", Server_IP );
          printf("Port NUmber : %d\n", atoi(PortNumber) );
     }
     sleep(5);   
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
                    if( TriggerConnection( SERVERIP,PORTNUMBER ) == SUCCESS )
                     {
                            serverstatus = connected;
                        
                            if( pthread_create(&TH1_ID,NULL,TH1,NULL) < 0 )
                              {
                                   perror("TH1 creation failed:SC");
                              }
                            if( pthread_create( &TH2_ID , NULL , TH2 , NULL ) < 0 )
                              {
                                   perror("TH2 creation failed:SC");
                              }
                            State=S3;
                            printf("Socket Client Process entered in operational state.......\n");  /****TB6***/
                      }  
                break;
                case S3:
                     ConnectionManager();
                break;
           }  
     }
     return 0;
 }






sint TriggerConnection(const char *IP, suint portnumber)
 {
    sint client_sock_addr_length,ConnectResponse;
    socfd = socket(AF_INET,SOCK_STREAM,0);
  
    if(socfd<0)  
      {
         perror("SOCKET_CREATION_FAILED:SC");
         return FAILURE;
      }
    printf("clientSocket created with fd : %d\nerrno: %d\n",socfd,errno);

    client_sock_addr.sin_family      = AF_INET;
    client_sock_addr.sin_port        = htons(portnumber);
    client_sock_addr.sin_addr.s_addr = inet_addr(IP); 

    client_sock_addr_length = sizeof(client_sock_addr);
   
    printf("Trying to Establish connection with Server........\n");
    ConnectResponse = connect(socfd , (struct sockaddr *)&client_sock_addr , client_sock_addr_length );
    if(ConnectResponse<0)
      {
        perror("FAILED TO CONNECT TO SERVER:SC");
        close(socfd);
        return FAILURE;
      }
    else
      {
         printf("Successfully connected to the server with response : success : %d\n",ConnectResponse);   /***TB6***/
      } 
   return SUCCESS;
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
               perror("SHM Init failed:SC");
               return FAILURE;
            }
       }
   
     Sensordata_SHM_Addr = (Sensordata_t *)shmat( SHMID , NULL ,0);
  
     if( Sensordata_SHM_Addr == (Sensordata_t *)-1 )
       {
          perror("SHM Attach failed:SC"); 
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
            perror("Sem creation failed:SC");
            return FAILURE;
        }
     }
   else     /******Set a initial value for the semaphore with specified key***********/
     {
       Seminit.val = 1;
       if( semctl( SEMID , 0 , SETVAL , Seminit ) < 0 )
         {
             perror("Sem init failed:SC");
             return FAILURE;
         }
     }
   return SUCCESS;
 }







sint MQ_Init(void)
 {
      if( ( MessageQueue_ID = msgget( (key_t)MQ_KEY , 0666|IPC_CREAT ) ) < 0 )
      {
           perror("Message queue creation failed:SC");
           return FAILURE;
      }
     return SUCCESS;
 }






void ConnectionManager(void)
 {
     if( serverstatus == notconnected )
       {
            printf("Server Disconnected...Trying to reconnect.....\n");   /****TB6****/
            pthread_cancel(TH1_ID);
            pthread_cancel(TH2_ID);
            close(socfd);
            State = S2;
       } 
 }






sint ReadFromServer(void)
 {
     signed int read_ret;
     read_ret = read( socfd, ReceivedDataFromServer , 500 );
     if( read_ret < 0 )
     {
           printf("Server is disconnected and read returned:fail: %d\n",read_ret);         /***TB6***/
           perror("Read from Server failed:SC");
           return FAILURE;
     }
     else if( read_ret == 0 )                    /*read() will return 0 if the server will be disconnected*/
     {
           printf("Server is disconnected and read returned:fail: %d\n",read_ret);   /***TB6****/
           serverstatus = notconnected;
           return FAILURE;
     }
     else
     {
          printf("Total Characters read from server is : %d\n",read_ret);          /******TB6******/  
          printf("Data received from server is : %s\n",ReceivedDataFromServer);   /******TB6******/
          DatafromServerAvailableStat = Available;
     } 
     return SUCCESS;
 }




void GetTempData(void);
void GetIRData(void);
void GetSDData(void);
void ConvertTempToJSON(void);
void ConvertIRToJSON(void);
void ConvertSDToJSON(void);
void ConvertDEVID_ToJSON(void);

char *test = "{\"PID\":\"DEV_ID_RESP\",\"DEVICE_ID\":\"TESTDEVICE2303\"}";
void* TH1(void *arg1)
 {
     pthread_setcancelstate( PTHREAD_CANCEL_ENABLE , NULL );
     pthread_setcanceltype( PTHREAD_CANCEL_ASYNCHRONOUS , NULL );
      
     while(3)
          {
               ReadFromServer();
               if( DatafromServerAvailableStat == Available )
                 {
                        jobj_received_data = json_tokener_parse( ReceivedDataFromServer );
            
	                if( jobj_received_data != NULL )
	                {
	                      Packet_Processing();
            	              DatafromServerAvailableStat = NotAvailable;
                        }                          
                        memset( ReceivedDataFromServer,'\0',sizeof(ReceivedDataFromServer));
                 }
               
               switch( PacketIDReceived ) 
               {
                     case TEMP_S:                  /*******{"PID":"TEMP_S"}**********/
                          GetTempData();
                          ConvertTempToJSON();
                          SendToServerStatus = SEND;
                     break; 
                     case IR_S:                    /*******{"PID":"IR_S"}**********/
                          GetIRData();
                          ConvertIRToJSON();
                          SendToServerStatus = SEND;
                     break; 
                     case SMK_S:                   /*******{"PID":"SMK_S"}**********/
                          GetSDData();
                          ConvertSDToJSON();
                          SendToServerStatus = SEND;
                     break;
                     case DEV_ID_REQUEST:          /*******{"PID":"DEV_ID_REQUEST"}**********/
                          ConvertDEVID_ToJSON();
                        //  write( socfd ,test,strlen(test));
                          SendToServerStatus = SEND; 
                     break;
                     case action:                  /***{"action":{"light":"ON/OFF","lock":"ON/OFF","fan":"ON/OFF","alarm":"ON/OFF"}}**********/ 
                          sendcontroldatastat = Controldata_send;
                     case NO_PACKET:
                     break;
               }
               PacketIDReceived = NO_PACKET;
               if( SendToServerStatus == SEND )
               {
                     SendToServer( (char *)json_object_to_json_string(jobj_sent_data) , strlen( json_object_to_json_string( jobj_sent_data ) ) );
              //       printf("str : %s\n",json_object_to_json_string( jobj_sent_data ));
                     jobj_sent_data = NULL;
                     SendToServerStatus = HOLD;
               } 
          }
       return ((void *)SUCCESS);  
 }



void SendToServer( const char *JSON_data , suint Sizeofdata )
 {
      if( write( socfd , JSON_data , Sizeofdata ) < 0 )
      {
           perror("Sending data to server failed:SendToServer:SC");
      }
 }



/******Will control outputs*******/
void* TH2(void *arg2)
 {
    pthread_setcancelstate( PTHREAD_CANCEL_ENABLE, NULL);
    pthread_setcanceltype( PTHREAD_CANCEL_ASYNCHRONOUS, NULL);
    controldata.msg_type = 1; 
    while(4)
    {
           if( sendcontroldatastat == Controldata_send )
           {
                  if( msgsnd( MessageQueue_ID , (void *)&controldata , sizeof(controldata.control_data) , 0 ) < 0 )
                  {
                         perror("unable to send control data:SC");
                  }
                  sendcontroldatastat = Controldata_hold;
           }
    }
    return ( (void *)SUCCESS );
 }





json_object *jobj_received_data_sub_string = NULL;
static void Process_sub_control_packet(void);
int Packet_Processing(void)
 {
     char *value;
     json_object_object_foreach( jobj_received_data, key, val )
     {
          if( strcmp( key,"PID" ) == 0)
          {
                 value = (char *)json_object_get_string( val );
                 printf("Value in Request string : %s\n", value);    /*****TB6******/
                 if( strcmp( value ,"TEMP_S") == 0 )
                 {
                      PacketIDReceived = TEMP_S;
                 }
                 else if(strcmp( value ,"SMK_S" ) == 0)
                 {
                      PacketIDReceived = SMK_S;
                 }
                 else if(strcmp( value ,"IR_S") == 0)
                 {
                      PacketIDReceived = IR_S;
                 }
                 else if(strcmp( value ,"DEV_ID_REQUEST") == 0)
                 {
                      PacketIDReceived = DEV_ID_REQUEST;
                 }  
                 return;
          }
          if( strcmp( key,"action" ) == 0 )
          {
                 PacketIDReceived = action;
                 value = (char *)json_object_get_string( val );
                 printf("Value in Control string : %s\n",value);         /***TB6***/
                 jobj_received_data_sub_string = json_tokener_parse(value);  
                 if( jobj_received_data_sub_string != NULL )
                 {
                      Process_sub_control_packet();   
                      return;
                 }              
          }
     }
 }




static void Process_sub_control_packet(void)
 {
    json_object_object_foreach( jobj_received_data_sub_string , key, val )
    {
          if( strcmp( key , "light" ) == 0 )
          {
              if( strcmp( "ON", (char *)json_object_get_string( val ) ) == 0 ) 
              {
                  controldata.control_data.LED1_light = 0x01; 
              }
              else
              {
                  controldata.control_data.LED1_light = 0x00;
              } 
          }
          if( strcmp( key , "lock" ) == 0 )
          {
              if( strcmp( "ON", (char *)json_object_get_string( val ) ) == 0 )
              {
                  controldata.control_data.LED2_lock = 0x01; 
              }
              else
              {
                  controldata.control_data.LED2_lock = 0x00;
              }
          }
          if( strcmp( key , "fan" ) == 0 )
          {
              if( strcmp( "ON", (char *)json_object_get_string( val ) ) == 0 )
              {
                  controldata.control_data.LED3_fan = 0x01;
              }
              else
              {
                  controldata.control_data.LED3_fan = 0x00;
              }              
          }
          if( strcmp( key , "alarm" ) == 0 )
          {
              if( strcmp( "ON", (char *)json_object_get_string( val ) ) == 0 )
              {
                  controldata.control_data.LED4_alarm = 0x01;
              }
              else
              {
                  controldata.control_data.LED4_alarm = 0x00;
              }
          }
        }
          printf("action data...\n");
          printf( "LED1_light : %u\n",controldata.control_data.LED1_light);
          printf( "LED2_lock : %u\n",controldata.control_data.LED2_lock);
          printf( "LED3_fan : %u\n",controldata.control_data.LED3_fan);
          printf( "LED4_alarm : %u\n",controldata.control_data.LED4_alarm);    
 }



void GetTempData(void)
 {
    sem_opr.sem_num =  0; 
    sem_opr.sem_op  = -1;
    sem_opr.sem_flg = SEM_UNDO;
    if( semop( SEMID , &sem_opr ,1 ) < 0 )
      {
            perror("Sem locking failed:SC");
      }
    Sensordata.TS_data = Sensordata_SHM_Addr->TS_data ;                                  

    sem_opr.sem_num =  0;
    sem_opr.sem_op  =  1;                                           
    sem_opr.sem_flg = SEM_UNDO;
    if( semop( SEMID , &sem_opr ,1 ) < 0 )
      {
          perror("sem release failed:SC");
      }
 }





void GetIRData(void)
 {
    sem_opr.sem_num =  0;
    sem_opr.sem_op  = -1;
    sem_opr.sem_flg = SEM_UNDO;
    if( semop( SEMID , &sem_opr ,1 ) < 0 )
       {
            perror("Sem locking failed:SC");
       }
    Sensordata.IRS_data = Sensordata_SHM_Addr->IRS_data ;
    printf("IRD in socket client : %u\n",Sensordata.IRS_data);
    sem_opr.sem_num =  0;
    sem_opr.sem_op  =  1;
    sem_opr.sem_flg = SEM_UNDO;
    if( semop( SEMID , &sem_opr ,1 ) < 0 )
       {
          perror("sem release failed:SC");
       }
 }





void GetSDData(void)
 {
    sem_opr.sem_num =  0;
    sem_opr.sem_op  = -1;
    sem_opr.sem_flg = SEM_UNDO;
    if( semop( SEMID , &sem_opr ,1 ) < 0 )
    {
          perror("Sem locking failed:SC");
    }

    Sensordata.SS_data = Sensordata_SHM_Addr->SS_data ;
    printf("Smoke data in socket client : %u\n",Sensordata.SS_data);
    sem_opr.sem_num =  0;
    sem_opr.sem_op  =  1;
    sem_opr.sem_flg = SEM_UNDO;
    if( semop( SEMID , &sem_opr ,1 ) < 0 )
    {
          perror("sem release failed:SC");
    }
 }






void ConvertTempToJSON(void)
 {
     json_object *jdoub;
     jobj_sent_data = json_object_new_object();
     jdoub = json_object_new_double( Sensordata.TS_data );   
     json_object_object_add( jobj_sent_data , "VALUE_TEMP_S" , jdoub );
 }







void ConvertIRToJSON(void)
 {
     json_object *jstring;     
     jobj_sent_data = json_object_new_object();
     if( Sensordata.IRS_data == 1 )   /*****Present*****/
     {
        jstring = json_object_new_string("PRESENT");
     }
     else if( Sensordata.IRS_data == 0 )  /*******Not Present********/
     {
        jstring = json_object_new_string("NOT_PRESENT");
     }
     json_object_object_add( jobj_sent_data , "VALUE_IR_S" , jstring );
 }






void ConvertSDToJSON(void)
 {
     json_object *jstring;
     jobj_sent_data = json_object_new_object();
     if( Sensordata.SS_data == 1 )   /******Detected******/
     {
        jstring = json_object_new_string("DETECTED");
     }
     else if( Sensordata.SS_data == 0 )  /****Not Detected********/
     {
        jstring = json_object_new_string("NOT_DETECTED");
     }
     json_object_object_add( jobj_sent_data , "VALUE_SMK_S" , jstring );
 }





void ConvertDEVID_ToJSON(void)
 {
     json_object *jstring; 
     jobj_sent_data = json_object_new_object();

     jstring = json_object_new_string("DEV_ID_RESP");
     json_object_object_add( jobj_sent_data,"PID",jstring );

     jstring = json_object_new_string("TESTDEVICE2303");
     json_object_object_add( jobj_sent_data,"DEVICE_ID",jstring );
 }


