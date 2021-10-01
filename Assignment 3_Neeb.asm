;--------------------------------------
; Triangle Program
;--------------------------------------
                 
;Short answer questions:
;   1.  With the current program and resources, yes; there is a limit. 
;       The limit exists because it's only a 16-bit processor and I am using the ax to perform multiplication.
;       The ax register can hold 16 bits. If the user calculated more than the first 25 terms, he would eventually
;       run out of memory purely due to physical limitations. 
;
;   2.  It would create an overflow error. Technically, I could budget resources to reach beyond the 16-bit limit
;       by performing separate multiplication and just combining print outputs.          

        
        .MODEL  small
        .STACK  100h

        .DATA
  msg         DB      "The big ol' triangle program!$"
  hextable    DB      '0123456789ABCDEF'  ;An array of all Hex values
  comma       DB      ", $"
  pLine       DW      0100h
  
        .CODE
  start:
        mov     ax,@DATA
        mov     ds,ax

        call    display_msg     ;Call procedure to display message
        
        call        shift_row
        call        shift_row
         
        mov     cx,0 
        
        loop:
            ;logic here
              
            inc     cx                  ;increment our counter
            
            ;TRIANGLE FORMULA IS n(n+1)/2
             
            mov     bx,cx               ;copy counter value into bx for multiplication [n]
            mov     ax,cx               ;copy counter value into ax and add 1 [n + 1]
            inc     ax
            
            mul     bx                  ;multiply bx and ax together [n(n+1)]
            
            mov     bx,02               ;copy value 02 into the bx
            
            div     bx                  ;divide the ax by bx [ax/2]        
             
            call    display_hex         ;Call procedure to display hex
                                                  
            cmp     cx,25
            
            jz      code2               ;If we need to print a comma and loop    
            
            code1:
                    call    print_comma  
                    jmp     loop  
            code2:
                    ENDP 
  exit:
        mov     ax,4C00h
        int     21h
        
 ;--------------------------------------
 ; shift_row - shifts output row accordingly
 ;--------------------------------------
  shift_row     PROC    near
   
        mov     ah,02h
        mov     bh,00h      ; page 0
        mov     dx,pLine    ; Increment rows with pLine
        ADD     pLine,100h  ;Add 100h to pLine every loop
        int     10h
        ret                                          
  shift_row     ENDP  
 
 ;--------------------------------------
 ; print_comma - used to print a comma and space between terms
 ;--------------------------------------  
  print_comma   PROC    near
        lea     dx,comma
                mov     ah,09h
                int     21h
                ret             ;Return control to calling program                            
  print_comma   ENDP 
                    
 ;--------------------------------------
 ; display_msg - used to display a text message
 ;--------------------------------------

  display_msg   PROC    near
                lea     dx,msg
                mov     ah,09h
                int     21h
                ret             ;Return control to calling program
  display_msg   ENDP            
       
  ;--------------------------------------
  ; display_hex - converts a decimal number to hex
  ;               one hex digit at a time and then
  ;               displays the converted digit
  ;--------------------------------------

  display_hex   PROC    near

             ;---
             ;--- We will use ax, bx, cx and dx in this routine
             ;--- which would corrupt whatever data was in them
             ;--- from the main program.  Therefore, we should
             ;--- preserve a copy on the stack by pushing them...

             push       ax
             push       bx
             push       cx
             push       dx

             mov        bx,ax   ;Copy decimal number to bx which
                                ;is what we will dissect to get
                                ;4 binary digits to look up in
                                ;table

             mov        cl,04   ;We will be rotating 4 digits at a time

             mov        ch,04   ;Loop counter -- There are 4 hex digits max
                                ;in a word (which is size of ax)

  proc_digit:
             rol        bx,cl   ;Rotate bits left to get digit to convert in
                                ;last 4 bits of bl

             mov        al,bl   	     ;Copy the BL into the AL
             and        al,00001111b  ;Clear bits 4-7 of AL
                                      ;-- bits 0-3 contain the digit and
                                      ;  we can now point at table

             push       bx            ;Save the BX's contents since we need
                                      ;to convert other digits

             lea        bx,hextable   ;Load the hextable's address into BX

             xlat                     ;This instruction is used to look up
                                      ;information in a table.  The BX must
                                      ;point to the table's start (offset)
                                      ;and AL must point to an entry (element)
                                      ;in the table.  Once xlat is done AL
                                      ;will contain the value from the table.

             pop        bx            ;Restore bx for next digit

             mov        dl,al         ;Call an interrupt to print out the 
                                      ;digit we got from the table
             mov        ah,02h
             int        21h

             dec        ch            ;Decrement the ch counter by 1
             jnz        proc_digit

             ;---
             ;--- Reload original register values prior to this proc call
             ;---

             pop        dx
             pop        cx
             pop        bx
             pop        ax
               
             ret                        ;Return control to calling program
;display_hex  ENDP

             END        start                             