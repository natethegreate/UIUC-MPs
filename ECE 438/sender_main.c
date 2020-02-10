/*
 * File:   sender_main.c
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
#include <sys/stat.h>
#include <signal.h>
#include <sys/time.h>
struct sockaddr_in si_other;


#define MAXBUFLEN 1472
#define MAXWINDOWSIZE 545000
#define TIMEOUT 30000

typedef struct packet{
    char* databuf;  //buf that holds data, have custom sizes?
    int sequence;   //sequence number
    int len;
    // struct timeval timer;  //timer from when the message was sent
    int status;   //let's see if we need this, could be set to stages
} packet;

int s, slen;

char encode(int a){
char digits[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9' };
return digits[a];
}

void diep(char *s) {
    perror(s);
    exit(1);
}

void reliablyTransfer(char* hostname, unsigned short int hostUDPport, char* filename, unsigned long long int bytesToTransfer) {
    //Open the file
    FILE *fp;
   fp = fopen(filename, "rb");
    if (fp == NULL) {
       printf("Could not open file to send.");
       exit(1);
    }
    // FILE *fw;
   // fw = fopen("sanitycheck.wav", "wb");
   //  if (fw == NULL) {
   //     printf("Could not open file to send.");
   //     exit(1);
   //  }

    /* Determine how many bytes to transfer */

    slen = sizeof (si_other);
    // struct addrinfo *servinfo;

    if ((s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1)
        diep("socket");

    memset((char *) &si_other, 0, sizeof (si_other));
    si_other.sin_family = AF_INET;
    si_other.sin_port = htons(hostUDPport);
    if (inet_aton(hostname, &si_other.sin_addr) == 0) {
        fprintf(stderr, "inet_aton() failed\n");
        exit(1);
    }


      /* Send data and receive acknowledgements on s*/
      /* Student's Baby Code Below*/
      struct timeval read_timeout, begin, time_sent, time_recv, now, time_last;
      read_timeout.tv_sec = 0;
      read_timeout.tv_usec = 10;
      setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, &read_timeout, sizeof read_timeout);
    char message[MAXBUFLEN];
    char ack[MAXBUFLEN];
    int flag = 1, NextSeqNum = 0, sendcount = 0, numbytes=-1, NextACK=0, RetAck=0, sizeWindow=0, bufferlen=0;
    long long int remaining=bytesToTransfer;
    int j=0;
    double ws=10.0;
    int digits[9], copy_sequence;
    char ID[10];
    int done =0, read  =0;//done then stop adding more packet into window, TCP friendliness stupid read vs bufferlen check
    struct packet* window[MAXWINDOWSIZE];
    socklen_t len;
    struct sockaddr_storage their_addr;

    len = sizeof their_addr;
    for (size_t i = 0; i < ws; i++) {
      window[i]=(struct packet*) malloc(sizeof(packet));
      window[i]->databuf =NULL;
      window[i]->sequence = i;
      window[i]->len =0;
    }
    sizeWindow = ws;
    NextSeqNum = ws;
    //exponential increase
    gettimeofday(&time_last,NULL);
    while (1) {
      gettimeofday(&begin, NULL);
      if(window[0]==NULL){//we're done sending
        if(done==1&&NextACK==NextSeqNum)
        { DONE:
          // printf("looks like we are done, remaining =%d. \n", remaining);
          if(remaining>0){//stupid TCP friendliness
            // printf("TCP friendliness? read = %d, bufferlen =%d, remaining =%d. WE LOOPING1\n", read, bufferlen, remaining);
            while (remaining>0) {
              memset(message,'0',MAXBUFLEN);
              message[MAXBUFLEN]='\0';
              if ((numbytes = sendto(s, message, strlen(message), 0, (struct sockaddr *)&si_other, slen)) == -1) {
                perror("talker: sendto");
                exit(1);
              }
              remaining = remaining - MAXBUFLEN;
              goto RECV1;
            }
          }
          memset(message,'\0',MAXBUFLEN);
          for (size_t i = 0; i < 9; i++) {
            digits[i]=0;
          }
          copy_sequence = NextSeqNum;
          for (int i = 8; i >=0; i--) {
            digits[i]= copy_sequence%10;
            copy_sequence = copy_sequence/10;
            message[i]=encode(digits[i]);
          }
          if ((numbytes = sendto(s, message, 10, 0, (struct sockaddr *)&si_other, slen)) == -1) {
            perror("talker: sendto");
            exit(1);
          }
          if ((numbytes = sendto(s, message, 10, 0, (struct sockaddr *)&si_other, slen)) == -1) {
            perror("talker: sendto");
            exit(1);
          }
          if ((numbytes = sendto(s, message, 10, 0, (struct sockaddr *)&si_other, slen)) == -1) {
            perror("talker: sendto");
            exit(1);
          }
          if ((numbytes = sendto(s, message, 10, 0, (struct sockaddr *)&si_other, slen)) == -1) {
            perror("talker: sendto");
            exit(1);
          }
          break;
        }
        else if (done==1){
          j=0;
          while(window[j]!=NULL){//force sent everything
            if ((numbytes = sendto(s, window[j]->databuf, window[j]->len, 0, (struct sockaddr *)&si_other, slen)) == -1) {
                perror("talker: sendto");
                exit(1);
            }
            goto RECV1;
          }
          // printf("window[0]==NULL but NextACK!=NextSeqNum? NextACK=%d, NextSeqNum=%d", NextACK, NextSeqNum);
        }else{printf("window[0]==NULL but not done? ws=%f, sizeWindow=%d", ws, sizeWindow); }
      }
      //Second, if there's available size in the window
      if(sizeWindow<ws && done ==0){
        for (size_t i = sizeWindow; i < ws; i++) //Allocate
        {
          window[i] = (struct packet*) malloc(sizeof(packet));
          window[i]->databuf =NULL;
          window[i]->sequence = NextSeqNum;//next in line
          window[i]->len = 0;
          NextSeqNum++;
          sizeWindow++;
          // printf("NextSeqNum Increased to%d, sizeWindow = %d,ws =%f\n", NextSeqNum, sizeWindow,ws);
        }
      }else if(done ==1){
        if(ws>sizeWindow){ws =sizeWindow;}
      }
      //Third, now if there's data not sent in the window
      sendcount =0;
      for (size_t i = 0; i < ws && flag; i++) {
        //if not sent
        if(window[i]==NULL){
          printf("ERROR at window[%d], sizeWindow is%d, previous sequence as %d", i, sizeWindow, window[i-1]->sequence);
          diep("Window == NULL inside sizeWindow Error");
          break;
        }
        else if(window[i]->databuf==NULL){//packets waiting
          bufferlen = (remaining>MAXBUFLEN-10?MAXBUFLEN-10:remaining);
          remaining=remaining-bufferlen;
          char temp[bufferlen];
          if(bufferlen==0){// no more data in file
            STOP_READING1:
            done =1;//Finished getting file
            NextSeqNum = window[i]->sequence;
            // printf("NextSeqNum now set to %d\n", NextSeqNum);
            for (; i < ws; i++) {
              if(window[i]==NULL){
                // printf("ERROR at window[%d], sizeWindow is%d, sequence as %d", i, sizeWindow, window[i-1]->sequence);
                diep("Window == NULL inside sizeWindow Error");}//error handling
              else if(window[i]->databuf==NULL){
                free(window[i]);
                window[i]=NULL;
                sizeWindow=sizeWindow -1;
              }
              if(window[i+1]!=NULL){
                if(window[i+1]->databuf!=NULL){diep("sent/recved packet behind waiting packets");}
              }//error handling
            }//free all waiting packets
            goto RECV1;//break out of the sending loop
          }

          read = fread(&temp,1,bufferlen,fp);
          if(read!= bufferlen){//TCP friendliness
            if(read ==0){
              printf("TCP friendliness? read = %d, bufferlen =%d, remaining =%d\n", read, bufferlen, remaining);
              goto RECV1;
            }
            else{bufferlen =read; goto STOP_READING1;}
          }
          copy_sequence = window[i]->sequence;
          memset(message,'\0',MAXBUFLEN);
          for (size_t i = 0; i < 9; i++) {
            digits[i]=0;
          }
          for (int i = 8; i >=0; i--) {
            digits[i]= copy_sequence%10;
            copy_sequence = copy_sequence /10;
            message[i]=encode(digits[i]);
            ID[i] = message[i];
          }
          ID[9]='\0';
          window[i]->databuf = (char*) malloc((bufferlen+10)*sizeof(packet));
          char* actual= message+9;
          memcpy(actual,temp,bufferlen);
          actual[bufferlen]='\0';
          memcpy(window[i]->databuf,message,bufferlen+10);
          window[i]->len = bufferlen+10;
          // printf("sending message %s with length%d \n", ID, bufferlen+10);
          // fwrite(actual, bufferlen, sizeof(char),fw);
          // for (size_t i = 0; i < bufferlen; i++) {
          //   if(message[i+9]!=temp[i])printf("Here's where I'm wrong: %c,%c at i= %d\n", message[i+9], temp[i], i);
          // }
          // printf("Check end: %c,%c at i= %d\n", message[bufferlen+8], temp[bufferlen-1], i);
          // printf("Check end: %c,%c at i= %d\n", message[bufferlen+9], temp[bufferlen], i);
          if ((numbytes = sendto(s, message, bufferlen+10, 0, (struct sockaddr *)&si_other, slen)) == -1) {
              perror("talker: sendto");
              exit(1);
          }
          sendcount++;
          gettimeofday(&time_last, NULL);
        }
      }
      gettimeofday(&time_sent, NULL);
      // printf ("senttime is %d\n",(time_sent.tv_sec - begin.tv_sec) * 1000000 + (time_sent.tv_usec - begin.tv_usec));

      //TIMEOUT or FORCE SEND
      gettimeofday(&now,NULL);
      int timeout = (now.tv_sec - time_last.tv_sec) * 1000000 + (now.tv_usec - time_last.tv_usec);
      if(timeout>=TIMEOUT){//HARD RESET!
        // printf("\nYOYOYO!\ntimeout is %d\n", timeout);
        // FORCESENT:
        if(window[0]==NULL){
          // printf("but not DONE? NextACK = %d, NextSeqNum= %d", NextACK, NextSeqNum); 
          ws = 100; 
          continue;
        }//HARD RESET ws, try to get more window going
        for (size_t j = 0; j < sizeWindow; j++) {
          if(window[j]->len==0){continue;}
          strncpy(ID,window[j]->databuf,9);
          ID[9] = '\0';
          // printf("FORCE RESENDING!\nthe length is %d\n ID is%s\n", window[j]->len, ID);
          if ((numbytes = sendto(s, window[j]->databuf, window[j]->len, 0, (struct sockaddr *)&si_other, slen)) == -1) {
              perror("talker: sendto");
              exit(1);
          }
        }
        if(window[sizeWindow]!=NULL){
          printf("containing sequence %d, j =%d, sizeWindow =%d, NextSeqNum =%d, NextACK =%d",window[sizeWindow]->sequence, j, sizeWindow, NextSeqNum, NextACK);
        }
        gettimeofday(&time_last,NULL);
      }
      //If received ACK,
      RECV1:
      numbytes=0;
      memset(ack,'\0',MAXBUFLEN);
      if((numbytes=recvfrom(s, ack, MAXBUFLEN-1 , 0,(struct sockaddr *)&their_addr, &len))>0){//received something
        RetAck=atoi(ack);
        // printf("numbytes is %d, ack is %s, RetAck is %d\n",numbytes, ack, RetAck);
        if(NextACK<RetAck){//DROPPED PACKET!!
          // printf("NextACK<RetAck, NextACK: %d, RetAck:%d, DROPPED PACKET!!",NextACK, RetAck);
          int j =0;
          if(flag ==1 && ws>20){
            ws = ws/2; 
            // printf("\nws changed! ws=%f.\nDropped Packet and exit slow start!\n", ws);
        }
          while(window[j]->sequence >=NextACK && window[j]->sequence< RetAck){//Resend it
            if(flag==0&&(timeout<TIMEOUT)){break;}//if last ACK is also wrong, we are in huge crash state, focus on dealing with overflowing ACKs
            else{printf("timeout: %d\n", timeout);}
            strncpy(ID,window[j]->databuf,9);
            ID[9] = '\0';
            // printf("RESENDING!\nthe length is %d\n ID is%s\n", window[j]->len, ID);
            if ((numbytes = sendto(s, window[j]->databuf, window[j]->len, 0, (struct sockaddr *)&si_other, slen)) == -1) {
                perror("talker: sendto");
                exit(1);
            }
            j++;
            if(j==sizeWindow){break;}
          }
          for (size_t i = j; i < sizeWindow; i++) {
            //if found the packet corresponded to the received ACK
            if(window[i]->sequence ==RetAck){
              window[i]->len =0;
              break;
            }
          }
          flag =0;
          break; //INTO arithmetically
        }else if(NextACK==RetAck){// WE GOOD
          printf("NextACK==RetAck = %d, We GOOD,", RetAck);
          flag =1;
          if(window[0]->sequence !=RetAck){diep("window 0 not next ack!");}
          int i =0;
          int deleteCount = 0;
          window[0]->len=0;
          while(window[i]->len==0){ //Delete all the RECVed packets
              free(window[i]->databuf);
              free(window[i]);
              deleteCount++;
              i++;
              if(i==sizeWindow){
                while(i>=0){
                  window[i]=NULL;
                  i--;
                }
                // printf("got rid of all packets!"); 
                break;
              }
          }
          for (size_t i = deleteCount; i < sizeWindow; i++) {//move the stack
              window[i-deleteCount]=window[i];
              window[i]=NULL;
              // printf("Set window[%d] to NULL\n", i);
          }
          sizeWindow = sizeWindow-deleteCount;
          ws = ws+1;
          // printf("We deleted %d elements, changing sizeWindow to %d, change ws to %f\n",deleteCount,sizeWindow,ws);
          if(window[0]!=NULL){
            NextACK=window[0]->sequence;
          }
          else{
            NextACK=RetAck+deleteCount;
            // printf("NextACK: %d, NextSeqNum: %d",NextACK, NextSeqNum);
            if(done!=1){printf("done!=1 when empty?");}
          }
        }
        else{//got old packets, think about what to respond
        }
        gettimeofday(&time_last,NULL);
      }
      gettimeofday(&time_recv, NULL);
      int difftime = (time_recv.tv_sec - time_sent.tv_sec) * 1000000 + (time_recv.tv_usec - time_recv.tv_usec);
      // if(difftime>0)
      //   printf ("\n\nrecvtime is %d\n\n",difftime);
      // printf ("totaltime is %d\n",(time_recv.tv_sec - begin.tv_sec) * 1000000 + (time_recv.tv_usec - begin.tv_usec));
    }

    // arithmetically increase and mutiplicative decrease
    while (1) {
      gettimeofday(&begin, NULL);
      if(window[0]==NULL){//we're done sending
        if(done==1&&NextACK==NextSeqNum)
        {
          // printf("looks like we are done, remaining =%d\n", remaining);
          if(remaining>0){//stupid TCP friendliness
            // printf("TCP friendliness? read = %d, bufferlen =%d, remaining=%d. WE LOOPING2\n", read, bufferlen, remaining);
            while (remaining>0) {
              memset(message,'0',MAXBUFLEN);
              message[MAXBUFLEN]='\0';
              if ((numbytes = sendto(s, message, strlen(message), 0, (struct sockaddr *)&si_other, slen)) == -1) {
                perror("talker: sendto");
                exit(1);
              }
              remaining = remaining - MAXBUFLEN;
              goto RECV2;
            }
          }
          memset(message,'\0',MAXBUFLEN);
          for (size_t i = 0; i < 9; i++) {
            digits[i]=0;
          }
          copy_sequence = NextSeqNum;
          for (int i = 8; i >=0; i--) {
            digits[i]= copy_sequence%10;
            copy_sequence = copy_sequence/10;
            message[i]=encode(digits[i]);
          }
          if ((numbytes = sendto(s, message, 10, 0, (struct sockaddr *)&si_other, slen)) == -1) {
            perror("talker: sendto");
            exit(1);
          }
          if ((numbytes = sendto(s, message, 10, 0, (struct sockaddr *)&si_other, slen)) == -1) {
            perror("talker: sendto");
            exit(1);
          }
          if ((numbytes = sendto(s, message, 10, 0, (struct sockaddr *)&si_other, slen)) == -1) {
            perror("talker: sendto");
            exit(1);
          }
          if ((numbytes = sendto(s, message, 10, 0, (struct sockaddr *)&si_other, slen)) == -1) {
            perror("talker: sendto");
            exit(1);
          }
          break;
        }
        else if (done==1){
          j=0;
          while(window[j]!=NULL){//force sent everything
            if ((numbytes = sendto(s, window[j]->databuf, window[j]->len, 0, (struct sockaddr *)&si_other, slen)) == -1) {
                perror("talker: sendto");
                exit(1);
            }
            goto RECV2;
          }
          // printf("window[0]==NULL but NextACK!=NextSeqNum? NextACK=%d, NextSeqNum=%d", NextACK, NextSeqNum);
        }else{printf("window[0]==NULL but not done? ws=%f, sizeWindow=%d", ws, sizeWindow); }
      }
      //Second, if there's available size in the window
      if(sizeWindow<ws && done ==0){
        for (size_t i = sizeWindow; i < ws; i++) //Allocate
        {
          window[i] = (struct packet*) malloc(sizeof(packet));
          window[i]->databuf =NULL;
          window[i]->sequence = NextSeqNum;//next in line
          window[i]->len = 0;
          NextSeqNum++;
          sizeWindow++;
          // printf("NextSeqNum Increased to%d, sizeWindow = %d,ws =%f\n", NextSeqNum, sizeWindow,ws);
        }
      }else if(done ==1){
        if(ws>sizeWindow){ws =sizeWindow;}
      }
      //Third, now if there's data not sent in the window
      sendcount =0;
      for (size_t i = 0; i < ws && flag; i++) {
        //if not sent
        if(window[i]==NULL){
          printf("ERROR at window[%d], sizeWindow is%d, previous sequence as %d", i, sizeWindow, window[i-1]->sequence);
          diep("Window == NULL inside sizeWindow Error");
          break;
        }
        else if(window[i]->databuf==NULL){//packets waiting
          bufferlen = (remaining>MAXBUFLEN-10?MAXBUFLEN-10:remaining);
          remaining=remaining-bufferlen;
          char temp[bufferlen];
          if(bufferlen==0){// no more data in file
            STOP_READING2:
            done =1;//Finished getting file
            NextSeqNum = window[i]->sequence;
            // printf("NextSeqNum now set to %d\n", NextSeqNum);
            for (; i < ws; i++) {
              if(window[i]==NULL){
                printf("ERROR at window[%d], sizeWindow is%d, sequence as %d", i, sizeWindow, window[i-1]->sequence);
                diep("Window == NULL inside sizeWindow Error");}//error handling
              else if(window[i]->databuf==NULL){
                free(window[i]);
                window[i]=NULL;
                sizeWindow=sizeWindow -1;
              }
              if(window[i+1]!=NULL){
                if(window[i+1]->databuf!=NULL){diep("sent/recved packet behind waiting packets");}
              }//error handling
            }//free all waiting packets
            goto RECV2;//break out of the sending loop
          }

          read = fread(&temp,1,bufferlen,fp);
          if(read!= bufferlen){//TCP friendliness
            if(read ==0){
              // printf("TCP friendliness? read = %d, bufferlen =%d, remaining=%d\n", read, bufferlen, remaining);
              goto RECV2;
            }
            else{bufferlen =read; goto STOP_READING2;}
          }
          copy_sequence = window[i]->sequence;
          memset(message,'\0',MAXBUFLEN);
          for (size_t i = 0; i < 9; i++) {
            digits[i]=0;
          }
          for (int i = 8; i >=0; i--) {
            digits[i]= copy_sequence%10;
            copy_sequence = copy_sequence /10;
            message[i]=encode(digits[i]);
            ID[i] = message[i];
          }
          ID[9]='\0';
          window[i]->databuf = (char*) malloc((bufferlen+10)*sizeof(packet));
          char* actual= message+9;
          memcpy(actual,temp,bufferlen);
          actual[bufferlen]='\0';
          memcpy(window[i]->databuf,message,bufferlen+10);
          window[i]->len = bufferlen+10;
          // printf("sending message %s with length%d \n", ID, bufferlen+10);
          // fwrite(actual, bufferlen, sizeof(char),fw);
          // for (size_t i = 0; i < bufferlen; i++) {
          //   if(message[i+9]!=temp[i])printf("Here's where I'm wrong: %c,%c at i= %d\n", message[i+9], temp[i], i);
          // }
          // printf("Check end: %c,%c at i= %d\n", message[bufferlen+8], temp[bufferlen-1], i);
          // printf("Check end: %c,%c at i= %d\n", message[bufferlen+9], temp[bufferlen], i);
          if ((numbytes = sendto(s, message, bufferlen+10, 0, (struct sockaddr *)&si_other, slen)) == -1) {
              perror("talker: sendto");
              exit(1);
          }
          sendcount++;
          gettimeofday(&time_last, NULL);
        }
      }
      gettimeofday(&time_sent, NULL);
      // printf ("senttime is %d\n",(time_sent.tv_sec - begin.tv_sec) * 1000000 + (time_sent.tv_usec - begin.tv_usec));

      //TIMEOUT or FORCE SEND
      gettimeofday(&now,NULL);
      int timeout = (now.tv_sec - time_last.tv_sec) * 1000000 + (now.tv_usec - time_last.tv_usec);
      if(timeout>=TIMEOUT){//HARD RESET!
        // printf("\nYOYOYO!\ntimeout is %d\n", timeout);

        if(window[0]==NULL){
          // printf("but not DONE? NextACK = %d, NextSeqNum= %d", NextACK, NextSeqNum); 
          ws = 100; 
          continue;
        }//HARD RESET ws, try to get more window going
        for (size_t j = 0; j < sizeWindow; j++) {
          if(window[j]->len==0){continue;}
          strncpy(ID,window[j]->databuf,9);
          ID[9] = '\0';
          // printf("FORCE RESENDING!\nthe length is %d\n ID is%s\n", window[j]->len, ID);
          if ((numbytes = sendto(s, window[j]->databuf, window[j]->len, 0, (struct sockaddr *)&si_other, slen)) == -1) {
              perror("talker: sendto");
              exit(1);
          }
        }
        // if(window[sizeWindow]!=NULL){
          // printf("containing sequence %d, j =%d, sizeWindow =%d, NextSeqNum =%d, NextACK =%d",window[sizeWindow]->sequence, j, sizeWindow, NextSeqNum, NextACK);
        // }
        gettimeofday(&time_last,NULL);
      }
      //If received ACK,
      RECV2:
      numbytes=0;
      memset(ack,'\0',MAXBUFLEN);
      if((numbytes=recvfrom(s, ack, MAXBUFLEN-1 , 0,(struct sockaddr *)&their_addr, &len))>0){//received something
        RetAck=atoi(ack);
        // printf("numbytes is %d, ack is %s, RetAck is %d\n",numbytes, ack, RetAck);
        if(NextACK<RetAck){//DROPPED PACKET!!
          // printf("NextACK<RetAck, NextACK: %d, RetAck:%d, DROPPED PACKET!!",NextACK, RetAck);
          int j =0;
          if(flag ==1 && ws>20){
            ws = ws/2; 
            // printf("\nws changed! ws=%f.\nDropped Packet and in arithmetically\n", ws);
        }
          while(window[j]->sequence >=NextACK && window[j]->sequence< RetAck){//Resend it
            if(flag==0&&(timeout<TIMEOUT)){break;}//if last ACK is also wrong, we are in huge crash state, focus on dealing with overflowing ACKs
            else{printf("timeout: %d\n", timeout);}
            strncpy(ID,window[j]->databuf,9);
            ID[9] = '\0';
            // printf("RESENDING!\nthe length is %d\n ID is%s\n", window[j]->len, ID);
            if ((numbytes = sendto(s, window[j]->databuf, window[j]->len, 0, (struct sockaddr *)&si_other, slen)) == -1) {
                perror("talker: sendto");
                exit(1);
            }
            j++;
            if(j==sizeWindow){break;}
          }
          for (size_t i = j; i < sizeWindow; i++) {
            //if found the packet corresponded to the received ACK
            if(window[i]->sequence ==RetAck){
              window[i]->len =0;
              break;
            }
          }
          flag =0;
          // break; //INTO arithmetically
        }else if(NextACK==RetAck){// WE GOOD
          // printf("NextACK==RetAck = %d, We GOOD,", RetAck);
          flag =1;
          if(window[0]->sequence !=RetAck){diep("window 0 not next ack!");}
          int i =0;
          int deleteCount = 0;
          window[0]->len=0;
          while(window[i]->len==0){ //Delete all the RECVed packets
              free(window[i]->databuf);
              free(window[i]);
              deleteCount++;
              i++;
              if(i==sizeWindow){
                while(i>=0){
                  window[i]=NULL;
                  i--;
                }
                printf("got rid of all packets!"); break;
              }
          }
          for (size_t i = deleteCount; i < sizeWindow; i++) {//move the stack
              window[i-deleteCount]=window[i];
              window[i]=NULL;
              // printf("Set window[%d] to NULL\n", i);
          }
          sizeWindow = sizeWindow-deleteCount;
          ws = ws+1/ws;
          // printf("We deleted %d elements, changing sizeWindow to %d, change ws to %f\n",deleteCount,sizeWindow,ws);
          if(window[0]!=NULL){
            NextACK=window[0]->sequence;
          }
          else{
            NextACK=RetAck+deleteCount;printf("NextACK: %d, NextSeqNum: %d",NextACK, NextSeqNum);
            if(done!=1){printf("done!=1 when empty?");}
          }
        }
        else{//got old packets, think about what to respond
        }
        gettimeofday(&time_last,NULL);
      }
      gettimeofday(&time_recv, NULL);
      int difftime = (time_recv.tv_sec - time_sent.tv_sec) * 1000000 + (time_recv.tv_usec - time_recv.tv_usec);
      // if(difftime>0)
      //   printf ("\n\nrecvtime is %d\n\n",difftime);
      // printf ("totaltime is %d\n",(time_recv.tv_sec - begin.tv_sec) * 1000000 + (time_recv.tv_usec - begin.tv_usec));
    }



      /* Student's Baby Code End*/
    fclose(fp);
    // fclose(fw);
    printf("Closing the socket\n");
    close(s);
    return;

}

/*
 *
 */
int main(int argc, char** argv) {

    unsigned short int udpPort;
    unsigned long long int numBytes;


    if (argc != 5) {
        fprintf(stderr, "usage: %s receiver_hostname receiver_port filename_to_xfer bytes_to_xfer\n\n", argv[0]);
        exit(1);
    }
    udpPort = (unsigned short int) atoi(argv[2]);
    numBytes = atoll(argv[4]);

    struct timeval start, end;
    int timediff;
    gettimeofday(&start,NULL);
    reliablyTransfer(argv[1], udpPort, argv[3], numBytes);
    gettimeofday(&end, NULL);
    timediff = (end.tv_sec - start.tv_sec) * 1000000 + (end.tv_usec - start.tv_usec);
    printf("Used %d us to send %lld bytes\n",timediff, numBytes );
    return (EXIT_SUCCESS);
}
