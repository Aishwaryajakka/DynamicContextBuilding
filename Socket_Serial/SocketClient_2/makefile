CC=gcc
DBFLAG = -g -Wall -save-temps
EXE = socket_client.out
THREAD_LIB = -lpthread
JSON_LIB = -ljson

exe:
	$(CC) $(DBFLAG) *.c -o $(EXE) $(THREAD_LIB) $(JSON_LIB)

clean:
	rm -f *.out *.i *.o *.s



