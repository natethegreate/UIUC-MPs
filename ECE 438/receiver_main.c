/*
 * File:   receiver_main.c
 * Author:
 *
 * Created on
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <pthread.h>


#define MAXBUFLEN 1472
#define WINDOWSIZE 545      //40 MB * 20/1000 / 1472 bytes. 545 packets per window
#define BUFSIZE 20000         //change me
#define PACKETSIZE 1472
#define HEADERSIZE 9		//size of seq number header
#define SEQHEAD 9

struct sockaddr_in si_me, si_other;
int s, slen;

// char nextPackets[10000][1472];
// char * nextPackets[10000];

void diep(char *s) {
    perror(s);
    exit(1);
}

char encode(int a){
char digits[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9' };
return digits[a];
}


void reliablyReceive(unsigned short int myUDPport, char* destinationFile) {
	char * nextPackets[BUFSIZE];
	// memset(nextPackets, 0, sizeof(nextPackets));	//initialize to null ptrs
	for(int x=0; x< BUFSIZE; x++) {
		nextPackets[x] = (char *) malloc(MAXBUFLEN);
	}
    slen = sizeof (si_other);
    FILE *fp;
    fp = fopen(destinationFile, "wb");  //switch to "wb" for grading

    // if ((rv = getaddrinfo(NULL, hostUDPport, &hints, &servinfo)) != 0) {
    //  fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
    //  return 1;
    // }

    if ((s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1)
        diep("socket");

    memset((char *) &si_me, 0, sizeof (si_me));
    si_me.sin_family = AF_INET;
    si_me.sin_port = htons(myUDPport);
    si_me.sin_addr.s_addr = htonl(INADDR_ANY);
    // printf("Now binding\n");
    if (bind(s, (struct sockaddr*) &si_me, sizeof (si_me)) == -1)
        diep("bind");
    // printf("made it past bind\n");

    /* Now receive data and send acknowledgements */
    int numbytes;
    char buf[MAXBUFLEN];    //buffer for holding received packet
    int endPacket=-1;		//note last packet;
    int endSize = 0;
    //handle receiving in while loop
    //open new file and write to it
    //keep track of ACK, order or packets,
    struct sockaddr_storage their_addr;
    socklen_t len;
    int currAck = 0;        //in order ack that we expect
    // int sentAck = 0;
    char ackmsg[10];          //the ack that will be sent back. Verify size!!!
    ackmsg[9] = '\0';
    int currSeq;            //received packet's sequence number
    int windowIdx = 0;      //index of current in big window array
    int windowLen = 0;		//index of end of packet big array
    int tempSeq, tempSeq1 =-1 , tempSeq2 = -1, tempSeq3=0;            //temp sequence number when getting packets from wait array
    char tempNum[SEQHEAD];        //holds initial buf value for sequence number, always length 4 bytes
    char * seqPtr;          //Pointer for getting the initial buf value
    int fsize = 0;			//filesize
    int minimal = 99999;
    int position = 0;

    // int hundredth=0, tenth=0, single=0;	//stevens code
    int digits[SEQHEAD];

    // printf("before loop\n");
    len = sizeof(their_addr);
    while(1) {
        //obtain some packet
        // if(currAck)
        memset(buf, '\0', sizeof(buf));	//clear buf
        if ((numbytes = recvfrom(s, buf, MAXBUFLEN-1 , 0,
             (struct sockaddr *)&their_addr, &len)) == -1) {
            perror("recvfrom");
            exit(1);
        }
        	// char databuf[numbytes-SEQHEAD];
        	// memset(databuf, '\0', numbytes-SEQHEAD+1);

        // printf("going to place in terminator");
        // buf[numbytes] = '\0';	//verify if necessary
        printf("numbytes is %d\n", numbytes);
        //get sequence number from buf, should be first 9 bytes
        memset(tempNum,'\0',10);
        tempNum[0] = buf[0];
        tempNum[1] = buf[1];
        tempNum[2] = buf[2];
        tempNum[3] = buf[3];
        tempNum[4] = buf[4];
        tempNum[5] = buf[5];
        tempNum[6] = buf[6];
        tempNum[7] = buf[7];
        tempNum[8] = buf[8];
        currSeq = atoi(tempNum);
        seqPtr= buf + 9;   //now pointing at actual data

        // printf("Got packet %d when tempNum is %s, expecting %d\n ", currSeq, tempNum, currAck);
        if(numbytes != 1471 && numbytes > 10) {
        	endPacket = currSeq;		//this is the last packet AAHHH
        	endSize = numbytes;
        }
        // if(currAck)
        //check if we got the right packet
        if(currSeq == currAck) {
        	char databuf[numbytes-SEQHEAD+1];
        	memset(databuf, '\0', numbytes-SEQHEAD+1);
            //send ACK in order. fill ackmsg, then sendto
            // printf("got correct packet!\n");
            //check if EOT
            // printf("before EOT check, seq %d, currAck is %d\n", currSeq, currAck);
        	if(*seqPtr == '\0' && numbytes==10){
        		printf("EOT found at packet %d\n", currSeq);
        		goto DONE;
        		break;
        	}
            //put into file, but dont include the sequence number
            // printf("got numbytes = %d, buffer = %s\n", numbytes, seqPtr);
            // printf("got numbytes = %d\n", numbytes);
            memcpy(&databuf, seqPtr, numbytes-SEQHEAD);
            // fputs(databuf, fp);
           	// printf("sizeof=%d, numbytes is %d\n", sizeof(databuf), numbytes);

            fwrite(databuf, numbytes - SEQHEAD, sizeof(char), fp);
            fsize += numbytes-HEADERSIZE;
            currAck++;

            //Create, send ACK
            for (int i = 8; i >=0; i--) {
              digits[i]= currSeq%10;
              currSeq = currSeq/10;
              ackmsg[i]=encode(digits[i]);
            }
            // sprintf(ackmsg, "%d", currAck);    //size is 3 chars + int
            // printf("sending ack%s \n", ackmsg);
            if ((numbytes = sendto(s, ackmsg, strlen(ackmsg), 0, (struct sockaddr *)&their_addr, len)) == -1) {
                perror("talker: sendto");
                exit(1);
            }
            //now determine waiting packet stuff
            //but only if there is packets in wait queue
            // currAck++;
            LOOP:
            //while were here, put in the rest of the waiting packets.
            while(windowIdx != windowLen) {
            	// printf("Starting queue loop at idx %d, len %d. wanting %d\n", windowIdx, windowLen, currAck);
                //unpack a packet from nextPackets. set tempSeq!
                memset(tempNum,'\0',10);
	            // seqPtr = nextPackets[windowIdx];
	        	tempNum[0] = nextPackets[windowIdx][0];
	        	tempNum[1] = nextPackets[windowIdx][1];
	        	tempNum[2] = nextPackets[windowIdx][2];
	        	tempNum[3] = nextPackets[windowIdx][3];
	        	tempNum[4] = nextPackets[windowIdx][4];
	        	tempNum[5] = nextPackets[windowIdx][5];
	        	tempNum[6] = nextPackets[windowIdx][6];
	        	tempNum[7] = nextPackets[windowIdx][7];
	        	tempNum[8] = nextPackets[windowIdx][8];	//grab tempseqnumber from stored packet
	            tempSeq = atoi(tempNum);

                // printf("have pkt %d, minimal = %d at pos %d \n", tempSeq, minimal, position);

                if(tempSeq < currAck) {
                	// printf("incrementing windowIdx\n");
	            	windowIdx++;
               		// printf("tempSeq<currAck, all future packets should be >= currAck");
	            }

                if(minimal == currAck) {
                	//initialize temp vars here
                	tempSeq1 = -1;
                	tempSeq2 = -1;
                	// printf("minimal matched, getting packet from position\n");
                	//place minimal into file
                	seqPtr = nextPackets[position] + 9;   //now pointing at actual data

	                //check EOT
	                if(*seqPtr == '\0' && numbytes==10){
	        			        printf("EOT found at packet %d\n", tempSeq);
	        			        goto DONE;
	        			        break;	//is this a strong enough break
	        		     }
	        		//insert into file
	        		if(tempSeq == endPacket) {
		                memset(databuf, '\0', endSize - SEQHEAD +1);
		                // printf("sizeof=%d, calc is %d, numbytes is %d\n", sizeof(databuf), numbytes-SEQHEAD+1, numbytes);
		                memcpy(&databuf, seqPtr, endSize - SEQHEAD);
		                fwrite(databuf, endSize - SEQHEAD, sizeof(char), fp);
	        			fsize += endSize - SEQHEAD+1;
	        		}
	        		else {
		                memset(databuf, '\0', 1463);
		                // printf("sizeof=%d, calc is %d, numbytes is %d\n", sizeof(databuf), numbytes-SEQHEAD+1, numbytes);
		                memcpy(&databuf, seqPtr, 1462);
		                fwrite(databuf, 1462, sizeof(char), fp);
		                fsize += 1463;
	            	}
	                
	                //success in putting packet in. move onto next.
	                currAck++;

	                //extract potential seq numbers
	                if(nextPackets[position+1] != NULL) {
					    tempNum[0] = nextPackets[position+1][0];
					    tempNum[1] = nextPackets[position+1][1];
					    tempNum[2] = nextPackets[position+1][2];
					    tempNum[3] = nextPackets[position+1][3];
					    tempNum[4] = nextPackets[position+1][4];
					    tempNum[5] = nextPackets[position+1][5];
					    tempNum[6] = nextPackets[position+1][6];
					    tempNum[7] = nextPackets[position+1][7];
					    tempNum[8] = nextPackets[position+1][8];	//destroys tempnum
					    tempSeq1 = atoi(tempNum);
					    printf("tempSeq1 for pos+1 is %d \n", tempSeq1);
					}
					if(nextPackets[windowIdx] != NULL) {
					    tempNum[0] = nextPackets[windowIdx][0];
					    tempNum[1] = nextPackets[windowIdx][1];
					    tempNum[2] = nextPackets[windowIdx][2];
					    tempNum[3] = nextPackets[windowIdx][3];
					    tempNum[4] = nextPackets[windowIdx][4];
					    tempNum[5] = nextPackets[windowIdx][5];
					    tempNum[6] = nextPackets[windowIdx][6];
					    tempNum[7] = nextPackets[windowIdx][7];
					    tempNum[8] = nextPackets[windowIdx][8];	//destroys tempnum
					    tempSeq2 = atoi(tempNum);
					    // printf("tempSeq2 for queue head is %d \n", tempSeq2);
					}

	                // printf("checking for other min\n");
	                if(tempSeq1 == currAck) {
	                	// printf("found at position+1\n");
                    if(position==windowIdx){
                      windowIdx++;
                    }
	                	minimal++;
	                	position++;
	                	continue;
	                }
	                else if(tempSeq2 == currAck) {
	                	// printf("found at head\n");
	                	minimal++;
	                	position = windowIdx;
	                	continue;
	                }
	                else {
	                	// printf("worst case, full queue check\n");
                    	minimal = 99999;
	                	for(int x=windowIdx; x<windowLen; x++) {
	                		memset(tempNum,'\0',10);
				            // seqPtr = nextPackets[x];		//might be unneeded
				        	tempNum[0] = nextPackets[x][0];
				        	tempNum[1] = nextPackets[x][1];
				        	tempNum[2] = nextPackets[x][2];
				        	tempNum[3] = nextPackets[x][3];
				        	tempNum[4] = nextPackets[x][4];
				        	tempNum[5] = nextPackets[x][5];
				        	tempNum[6] = nextPackets[x][6];
				        	tempNum[7] = nextPackets[x][7];
				        	tempNum[8] = nextPackets[x][8];	//destroys tempnum
				            tempSeq3 = atoi(tempNum);
				            // printf("in worst case, at idx %d\n",x);
	                		if(tempSeq3 < minimal && tempSeq3 >= currAck) {
	                			if(tempSeq3==currAck) {
                          			minimal = tempSeq3;
  	                				position = x;
                          			goto LOOP;
	                			}
	                			// printf("found new min at %d, wanted %d\n", tempSeq3, currAck);
	                			minimal = tempSeq3;
	                			position = x;
	                		}
	                	}
                    if(minimal==99999){
                      // printf("Looks like all clear, minimal is %d, currAck is %d\n",minimal, currAck);
                      if(windowIdx<windowLen-1){//IF we are not all clear,
                        // printf("Nope! Not all clear, windowIdx is %d, windowLen is %d\n",windowIdx, windowLen);
                        // diep("minimal<currAck");
                        // minimal = tempSeq2;
                        // position = windowIdx;

                      }
                                              windowIdx = 0;
                        windowLen = 0;	//end this madness
                    }
	                }
	                //leave queue loop
                }
                else
                	break;
             //    else if(tempSeq < currAck) {
             //    	printf("incrementing windowIdx\n");
	            // 	windowIdx++;
	            // }
            }

            // if(windowIdx == windowLen) {    //if the array is emptied, reset window variables
            //     windowLen = 0;
            //     windowIdx = 0;
            // }
            //another EOT check to breaj main loop
            if(*seqPtr == '\0' && numbytes==10){
        		printf("EOT found at packet %d DONE\n", currSeq);
        		goto DONE;
        		break;
        	}
        }

        else if(currSeq > currAck) { //got a next packet
          char databuf[numbytes-SEQHEAD+1];
        	memset(databuf, '\0', numbytes-SEQHEAD+1);
            //send this future ACK which should be from Seq
            // printf("got future packet %d. min is %d at pos %d\n", currSeq, minimal, position);
            // printf("next in queue is: %s \n", nextPackets[windowIdx]);
            if(currSeq <= minimal) {		//MAYBE undo this
            	// printf("updating min in future loop");
            	minimal = currSeq;
            	position = windowLen;
            }

            //store packet into nextPackets
            // *nextPackets[windowLen] = *buf;   //put entire buf into array spot. verify array sizes
            memcpy(nextPackets[windowLen], buf, 1472);
            // printf("Placed packet %d into window at %d, size is %d\n", currSeq, windowLen, numbytes);
            windowLen++;                    //increase this only when adding a packet to array

            //Create, send ACK
            for (int i = 8; i >=0; i--) {
              digits[i]= currSeq%10;
              currSeq = currSeq/10;
              ackmsg[i]=encode(digits[i]);
            }
            // sprintf(ackmsg, "%d", currSeq);    //size is 3 chars + int
            // printf("sending ack%s \n", ackmsg);
            if ((numbytes = sendto(s, ackmsg, strlen(ackmsg), 0, (struct sockaddr *)&their_addr, len)) == -1) {
                perror("talker: sendto");
                exit(1);
            }
            /*if(minimal < currAck) {
            	printf("min is behind in future loop\n");
            	if(nextPackets[position+1] != NULL) {
					    tempNum[0] = nextPackets[position+1][0];
					    tempNum[1] = nextPackets[position+1][1];
					    tempNum[2] = nextPackets[position+1][2];
					    tempNum[3] = nextPackets[position+1][3];
					    tempNum[4] = nextPackets[position+1][4];
					    tempNum[5] = nextPackets[position+1][5];
					    tempNum[6] = nextPackets[position+1][6];
					    tempNum[7] = nextPackets[position+1][7];
					    tempNum[8] = nextPackets[position+1][8];	//destroys tempnum
					    tempSeq1 = atoi(tempNum);
					    // printf("tempSeq1 for pos+1 is %d \n", tempSeq1);
					}
					if(nextPackets[windowIdx] != NULL) {
					    tempNum[0] = nextPackets[windowIdx][0];
					    tempNum[1] = nextPackets[windowIdx][1];
					    tempNum[2] = nextPackets[windowIdx][2];
					    tempNum[3] = nextPackets[windowIdx][3];
					    tempNum[4] = nextPackets[windowIdx][4];
					    tempNum[5] = nextPackets[windowIdx][5];
					    tempNum[6] = nextPackets[windowIdx][6];
					    tempNum[7] = nextPackets[windowIdx][7];
					    tempNum[8] = nextPackets[windowIdx][8];	//destroys tempnum
					    tempSeq2 = atoi(tempNum);
					    // printf("tempSeq2 for queue head is %d \n", tempSeq2);
					}
	                if(tempSeq1 == currAck) {
	                	printf("found at position+1\n");
	                	minimal = tempSeq1;
	                	position++;
	                	// windowIdx++;
	                	continue;
	                }
	                else if(tempSeq2 == currAck) {
	                	printf("found at head\n");
	                	minimal = tempSeq2;
	                	position = windowIdx;
	                	continue;
	                }
	                else {
	                	printf("future worst case, full queue check\n");
	                	for(int x=windowIdx; x<windowLen; x++) {
	                		memset(tempNum,'\0',10);
				            // seqPtr = nextPackets[x];		//might be unneeded
				        	tempNum[0] = nextPackets[x][0];
				        	tempNum[1] = nextPackets[x][1];
				        	tempNum[2] = nextPackets[x][2];
				        	tempNum[3] = nextPackets[x][3];
				        	tempNum[4] = nextPackets[x][4];
				        	tempNum[5] = nextPackets[x][5];
				        	tempNum[6] = nextPackets[x][6];
				        	tempNum[7] = nextPackets[x][7];
				        	tempNum[8] = nextPackets[x][8];	//destroys tempnum
				            tempSeq3 = atoi(tempNum);
				            // printf("in worst case, at idx %d\n",x);
	                		if(tempSeq3 == currAck) {
	                			printf("found new min at %d, wanted %d\n", tempSeq3, currAck);
	                			minimal = tempSeq3;
	                			position = x;
	                		}

	                	}

	                }
            }*/
            if(minimal< currAck){
            	// printf("minimal is %d, currAck is %d while we are in future packet %d\n",minimal, currAck, currSeq);
            	// diep("minimal<currAck");
            	windowIdx = 0;
            	windowLen = 0;	//reset then
        	}
            if (minimal == currAck) {
            	//rare case but can cause crash due to ideal packet loss bug
            	// printf("adding packet in rare future ideal case\n");
            	seqPtr = nextPackets[position] + 9;   //now pointing at actual data
	            //check EOT
	            if(*seqPtr == '\0' && numbytes==10){
	        		printf("EOT found at packet %d\n", tempSeq);
	        		goto DONE;
	        		break;	//is this a strong enough break
	        	}
	        	//insert into file
	        	// if()
	            memset(databuf, '\0', 1463);
	            memcpy(&databuf, seqPtr, 1462);
	            // printf("sizeof=%d, epic numbytes is %d\n", sizeof(databuf), numbytes);
	            fwrite(databuf, 1462, sizeof(char), fp);
	            fsize += 1462;
	            //success in putting packet in. move onto next.
	            currAck++;
	            // printf("new min in rare case\n");
            	if(nextPackets[position+1] != NULL) {
					    tempNum[0] = nextPackets[position+1][0];
					    tempNum[1] = nextPackets[position+1][1];
					    tempNum[2] = nextPackets[position+1][2];
					    tempNum[3] = nextPackets[position+1][3];
					    tempNum[4] = nextPackets[position+1][4];
					    tempNum[5] = nextPackets[position+1][5];
					    tempNum[6] = nextPackets[position+1][6];
					    tempNum[7] = nextPackets[position+1][7];
					    tempNum[8] = nextPackets[position+1][8];	//destroys tempnum
					    tempSeq1 = atoi(tempNum);
					    // printf("tempSeq1 for pos+1 is %d \n", tempSeq1);
					}
					if(nextPackets[windowIdx] != NULL) {
					    tempNum[0] = nextPackets[windowIdx][0];
					    tempNum[1] = nextPackets[windowIdx][1];
					    tempNum[2] = nextPackets[windowIdx][2];
					    tempNum[3] = nextPackets[windowIdx][3];
					    tempNum[4] = nextPackets[windowIdx][4];
					    tempNum[5] = nextPackets[windowIdx][5];
					    tempNum[6] = nextPackets[windowIdx][6];
					    tempNum[7] = nextPackets[windowIdx][7];
					    tempNum[8] = nextPackets[windowIdx][8];	//destroys tempnum
					    tempSeq2 = atoi(tempNum);
					    // printf("tempSeq2 for queue head is %d \n", tempSeq2);
					}
	                if(tempSeq1 == currAck) {
	                	// printf("found at position+1\n");
	                	minimal = tempSeq1;
	                	position++;
	                	// windowIdx++;
	                	continue;
	                }
	                else if(tempSeq2 == currAck) {
	                	printf("found at head\n");
	                	minimal = tempSeq2;
	                	position = windowIdx;
	                	continue;
	                }
	               	else {
	                	// printf(" rare worst case, full check\n");
	                	for(int x=windowIdx; x<windowLen; x++) {
	                		memset(tempNum,'\0',10);
				            // seqPtr = nextPackets[x];		//might be unneeded
				        	tempNum[0] = nextPackets[x][0];
				        	tempNum[1] = nextPackets[x][1];
				        	tempNum[2] = nextPackets[x][2];
				        	tempNum[3] = nextPackets[x][3];
				        	tempNum[4] = nextPackets[x][4];
				        	tempNum[5] = nextPackets[x][5];
				        	tempNum[6] = nextPackets[x][6];
				        	tempNum[7] = nextPackets[x][7];
				        	tempNum[8] = nextPackets[x][8];	//destroys tempnum
				            tempSeq3 = atoi(tempNum);
				            // printf("in worst case, at idx %d\n",x);
	                		if(tempSeq3 < minimal && tempSeq3 >= currAck) {
	                			// printf("rare found new min at %d, wanted %d\n", tempSeq3, currAck);
	                			minimal = tempSeq3;
	                			position = x;
	                		}

	                	}

	                }

            }
            
        }
        else {  //behind packet, discard
            //send ack anyway?
            // printf("got old packet %d, old like raisin\n", currSeq);
            //Create, send ACK
            // int digits[9];
            for (int i = 8; i >=0; i--) {
              digits[i]= currSeq%10;
              currSeq = currSeq/10;
              ackmsg[i]=encode(digits[i]);
            }
            // sprintf(ackmsg, "%d", currAck);    //size is 3 chars + int
            // printf("sending ack%s \n", ackmsg);
            if ((numbytes = sendto(s, ackmsg, strlen(ackmsg), 0, (struct sockaddr *)&their_addr, len)) == -1) {
                perror("talker: sendto");
                exit(1);
            }
        }
        // if(minimal < currAck)

    }
   	DONE:
    close(s);
    // truncate(fp, fsize);		//truncate last byte
    fseeko(fp,-1,SEEK_END);
    off_t pos;
    pos = ftello(fp);
    ftruncate(fileno(fp), pos);
    fsize--;
    printf("%s received. size is %d \n", destinationFile, fsize);
    fclose(fp);
    for(int x=0; x< 20000; x++) {
		free(nextPackets[x]);
	}
    return;
}

/*
 *
 */
int main(int argc, char** argv) {

    unsigned short int udpPort;

    // if (argc != 3) {
    //     fprintf(stderr, "usage: %s UDP_port filename_to_write\n\n", argv[0]);
    //     exit(1);
    // }
    printf("%d", argc);
    if(argc==4) {
         udpPort = (unsigned short int) atoi(argv[2]);

        reliablyReceive(udpPort, argv[3]);
    }
    else {
        if(argc==3) {
            udpPort = (unsigned short int) atoi(argv[1]);

            reliablyReceive(udpPort, argv[2]);
        }
    }
}
