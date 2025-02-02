.section .data
fd:
    .int 0              
pena:
    .int 0
tmp:
    .int 0
scelta:
    .ascii "\nSelezione uno dei due metodi\n1-EDF\n2-HPF\n3-ESCI\n"
scelta_len:
    .long .-scelta
HPFc:
    .ascii "\nPianificazione HPF:\n"
HPF_len:
    .long .-HPFc
EDFc:
    .ascii "\nPianificazione EDF:\n"
EDF_len:
    .long .-EDFc
conclusione:
    .ascii "Conclusione: "
conclusione_len:
    .long .-conclusione

penale:
    .ascii "Penalty: "

p_len:
    .long .-penale

duepunti:
    .ascii ":"

duepunti_len:
    .long .-duepunti

offset:
    .int 0

cifre:
    .int 0

elementi:
    .int 0

newline: 
    .byte 13       

controllo: 
    .byte 10  

numstr: .ascii "000000000"     # string output

numtmp: .ascii "00000000000"     # temporary string   

errore1:
    .ascii "FILE NON TROVATO\n"

e1_len:
    .long .-errore1

errore2:
    .ascii "\nNUMERO INSERITO ERRATO\n"

e2_len:
    .long .-errore2

.section .bss

stringa:
    .string ""

buffer: 
    .string ""

nomefile: 
    .string ""       

.section .text
    .global _start

_converti:

  movb (%ecx,%esi,1), %bl

  cmp $10, %bl            
  je _compara

  subb $48, %bl            
  movl $10, %edx
  mulb %dl                
  addl %ebx, %eax

  inc %ecx
  jmp _converti

_compara:
    
    cmp $1, %eax
    je _uno
    jl _error2
    cmp $2, %eax
    je _due
    cmp $3, %eax
    je exit
    jg _error2

_error2:
    movl $4, %eax	        
	movl $1, %ebx	        
	leal errore2, %ecx        
	movl e2_len, %edx        
	int $0x80 

    jmp _scegli  

_trasforma:

    cmp $44, %bl
   je _carica
  
  movl $0, %eax
  movl %esi, %eax
  subb $48, %bl            
  movl $10, %edx
  mulb %dl                
  addl %ebx, %eax
  movl %eax, %esi

  jmp _read


_read:
    mov $3, %eax        
    mov fd, %ebx        
    mov $buffer, %ecx   
    mov $1, %edx        
    int $0x80           

    cmp $0, %eax        
    jle _close_file     
    
    
    movb buffer, %bl   
    cmpb controllo, %bl 
    je occhio
    cmpb newline, %bl 
    jne _trasforma    

occhio:
    cmp $0,%esi
    je _read
    jmp _carica

_carica:
    push %esi
    movl $0, %esi
    addl $4,elementi
    addl $1, %edi
    jmp _read

_scegli:
    movl $4, %eax	        
	movl $1, %ebx	        
	leal scelta, %ecx        
	movl scelta_len, %edx        
	int $0x80             

    movl $3, %eax         
	movl $0, %ebx         
	leal stringa, %ecx        
	movl $50, %edx        
	int $0x80             

    leal stringa, %esi
    movl $0, %eax
    movl $0, %ecx            
    movl $0, %ebx            
    jmp _converti


_close_file: 
    cmp $0,%esi
    jg last
    movl $6, %eax
    movl %ebx, %ecx
    int $0x80

    jmp _scegli

last:
    push %esi
    movl $0, %esi
    addl $4,elementi
    jmp _close_file

_error1:
    movl $4, %eax	        
	movl $1, %ebx	        
	leal errore1, %ecx        
	movl e1_len, %edx        
	int $0x80 

    movl $1, %eax         
	xorl %ebx, %ebx       
	int $0x80             

exit:
    movl $1, %eax         
	xorl %ebx, %ebx       
	int $0x80 

_uno:
    call primo
    jmp resetta      

_due:
    call secondo
    jmp resetta

resetta:
    popl %eax
    cmp $0,%eax
    je ricarica
    jmp resetta

ricarica: 
    push $0
    movl $0,elementi
    movl $0,offset
    movl $0,pena
    movl $5, %eax
    movl nomefile, %ebx
    movl $0, %ecx
    int $0x80

    cmp $0, %eax
    jl _error1

    movl %eax, fd
    movl $0, %esi

    jmp _read
    

.type secondo, @function
cambia:
    addl $1, %esi
    cmp $6, %esi
    je preparazione
    addl $4, %esp
    jmp control 

preparazione:
    subl $4,elementi
    subl elementi,%esp

    movl $4, %eax	        
	movl $1, %ebx	        
	leal HPFc, %ecx        
	movl HPF_len, %edx        
	int $0x80             

    movl $0,%eax
    movl $0,%ebx
    movl $0,%ecx
    movl $0,%edx
    movl $0,%esi
    movl $0,%edi


    jmp stampa

stampa:
    # inserire la stampa dell'ID
    movl (%esp),%eax
    movl $10, %ebx             
	movl $0, %ecx              

	leal numtmp, %esi          

continua_a_dividere3:

	movl $0, %edx              
	divl %ebx                  

	addb $48, %dl              
	movb %dl, (%ecx,%esi,1)    

	inc %ecx                   

	cmp $0, %eax               

	jne continua_a_dividere3


	movl $0, %ebx              

	leal numstr, %edx          

ribalta3:

	movb -1(%ecx,%esi,1), %al  
	movb %al, (%ebx,%edx,1)    

	inc %ebx                   

	loop ribalta3


schermo3:

	movb $10, (%ebx,%edx,1)    

	inc %ebx
	movl %ebx, cifre            
	movl $4, %eax              
	movl $1, %ebx              
	leal numstr, %ecx 
    subl $1,cifre
    movl cifre, %edx         
	int $0x80                  

    # inserire la stampa dei :
    movl $4, %eax	        
	movl $1, %ebx	        
	leal duepunti, %ecx        
	movl duepunti_len, %edx        
	int $0x80

    # inserire la stampa dell'inizio(edi)
    movl %edi,%eax
    movl $10, %ebx             
	movl $0, %ecx              

	leal numtmp, %esi          


continua_a_dividere4:

	movl $0, %edx              
	divl %ebx                  

	addb $48, %dl              
	movb %dl, (%ecx,%esi,1)    

	inc %ecx                   

	cmp $0, %eax               

	jne continua_a_dividere4


	movl $0, %ebx              

	leal numstr, %edx          

ribalta4:

	movb -1(%ecx,%esi,1), %al  
	movb %al, (%ebx,%edx,1)    

	inc %ebx                   

	loop ribalta4


schermo4:

	movb $10, (%ebx,%edx,1)    

	inc %ebx
	movl %ebx, %edx            
	movl $4, %eax              
	movl $1, %ebx              
	leal numstr, %ecx          
	int $0x80                  

    addl $4, %esp
    addl (%esp), %edi
    addl $4, %esp
    cmp %edi, (%esp)
    jl penalty
    addl $8, %esp
    movl $127, %eax
    cmp %eax,(%esp)
    jg basta
    jmp stampa
    
    

penalty:
    movl %edi,tmp
    movl (%esp),%eax
    subl %eax,tmp
    movl tmp,%eax
    addl $4, %esp
    movl (%esp),%ecx
    mul %ecx
    addl %eax,pena
    addl $4, %esp
    movl $127, %ecx
    cmp %ecx,(%esp)
    jg basta
    jmp stampa

basta:
    movl $4, %eax	        
	movl $1, %ebx	        
	leal conclusione, %ecx        
	movl conclusione_len, %edx        
	int $0x80   

    movl %edi,%eax
    movl $10, %ebx             
	movl $0, %ecx              

	leal numtmp, %esi          


continua_a_dividere_f2:

	movl $0, %edx              
	divl %ebx                  

	addb $48, %dl              
	movb %dl, (%ecx,%esi,1)    

	inc %ecx                   

	cmp $0, %eax               

	jne continua_a_dividere_f2


	movl $0, %ebx              

	leal numstr, %edx          

ribalta_f2:

	movb -1(%ecx,%esi,1), %al  
	movb %al, (%ebx,%edx,1)    

	inc %ebx                   

	loop ribalta_f2


schermo_f2:

	movb $10, (%ebx,%edx,1)    

	inc %ebx
	movl %ebx, %edx            
	movl $4, %eax              
	movl $1, %ebx              
	leal numstr, %ecx          
	int $0x80
          
    movl $4, %eax	        
	movl $1, %ebx	        
	leal penale, %ecx        
	movl p_len, %edx        
	int $0x80
    
    movl pena,%eax
    movl $10, %ebx             
	movl $0, %ecx              

	leal numtmp, %esi 

    continua_a_dividere_f2p:

	movl $0, %edx              
	divl %ebx                  

	addb $48, %dl              
	movb %dl, (%ecx,%esi,1)    

	inc %ecx                   

	cmp $0, %eax               

	jne continua_a_dividere_f2p


	movl $0, %ebx              

	leal numstr, %edx          

ribalta_f2p:

	movb -1(%ecx,%esi,1), %al  
	movb %al, (%ebx,%edx,1)    

	inc %ebx                   

	loop ribalta_f2p


schermo_f2p:

	movb $10, (%ebx,%edx,1)    

	inc %ebx
	movl %ebx, %edx            
	movl $4, %eax              
	movl $1, %ebx              
	leal numstr, %ecx          
	int $0x80


    ret

# inizio della funzione
secondo:
    addl $4, elementi
    movl $0, %ebx
    movl $1, %esi
    addl $4, %esp
    movl $0, %edi

# controllo se la casella selezionata dello stack e' uguale al numero in edi
control:
    cmp (%esp), %esi
    je massimo
    addl $16,%esp
    movl $0, %edx
    cmp %edx, (%esp)
    je ricomincia
    jmp control

# vedo se e' il minimo 
massimo:
    addl $1, %ebx
    addl $4, %esp
    cmp %edi,(%esp)
    jg inse
    addl $12, %esp
    movl $0, %edx
    cmp %edx, (%esp)
    je ricomincia
    jmp control

# inserisco il nuovo valore massimo
inse:
    movl $0, %edi
    addl (%esp), %edi
    addl $12, %esp
    movl $0, %edx
    cmp %edx, (%esp)
    je ricomincia
    jmp control
# sono arrivato alla fine e quindi devo ritornare su
ricomincia:
    subl elementi, %esp
    cmp $0, %ebx
    je cambia
    movl $0, %ebx
    addl $8, %esp
    jmp scorri

# cerco il valore maggiore da caricare nello stack
scorri:
    cmp %edi,(%esp)
    je guarda
    addl $16,%esp
    jmp scorri

guarda:
    subl $4,%esp
    cmp %esi,(%esp)
    je stack
    addl $20,%esp
    jmp scorri
# ricarico nello stack i valori  
stack:
    popl %eax
    popl %ebx
    popl %ecx
    popl %edx
    jmp azzera

azzera:
    subl $16,%esp
    movl $128,(%esp)
    addl $4,%esp
    movl $128,(%esp)
    addl $4,%esp
    movl $128,(%esp)
    addl $4,%esp
    movl $128,(%esp)
    addl $4,%esp
    movl $0,%edi
    cmp %edi,(%esp)
    je ripristina
    jmp ciclo


ciclo:
    addl $16, %esp
    movl $0, %edi
    cmp %edi,(%esp)
    je ripristina
    jmp ciclo

ripristina:
    subl elementi,%esp
    subl offset,%esp
    push %eax
    push %ebx
    push %ecx
    push %edx
    addl $16,offset
    movl $0,%eax
    movl $0,%ebx
    movl $0,%edx
    movl $0,%ecx
    addl offset,%esp
    addl $4, %esp
    movl $0, %edi
    jmp control



.type primo, @function
change:
    subl $1, %esi
    cmp $0, %esi
    je prepare
    addl $8, %esp
    jmp check 

prepare:
    subl $4,elementi
    subl elementi,%esp

    movl $4, %eax	        
	movl $1, %ebx	        
	leal EDFc, %ecx        
	movl EDF_len, %edx        
	int $0x80             

    movl $0,%eax
    movl $0,%ebx
    movl $0,%ecx
    movl $0,%edx
    movl $0,%esi
    movl $0,%edi


    jmp print

print:
    # inserire la stampa dell'ID
    movl (%esp),%eax
    movl $10, %ebx             
	movl $0, %ecx              

	leal numtmp, %esi          


continua_a_dividere1:

	movl $0, %edx              
	divl %ebx                  

	addb $48, %dl              
	movb %dl, (%ecx,%esi,1)    

	inc %ecx                   

	cmp $0, %eax               

	jne continua_a_dividere1


	movl $0, %ebx              

	leal numstr, %edx          

ribalta1:

	movb -1(%ecx,%esi,1), %al  
	movb %al, (%ebx,%edx,1)    

	inc %ebx                   

	loop ribalta1


schermo1:

	movb $10, (%ebx,%edx,1)    

	inc %ebx
	movl %ebx, cifre            
	movl $4, %eax              
	movl $1, %ebx              
	leal numstr, %ecx
    subl $1,cifre
    movl cifre, %edx         
	int $0x80                  

    # inserire la stampa dei :
    movl $4, %eax	        
	movl $1, %ebx	        
	leal duepunti, %ecx        
	movl duepunti_len, %edx        
	int $0x80

    # inserire la stampa dell'inizio(edi)
    movl %edi,%eax
    movl $10, %ebx             
	movl $0, %ecx              

	leal numtmp, %esi          


continua_a_dividere2:

	movl $0, %edx              
	divl %ebx                  

	addb $48, %dl              
	movb %dl, (%ecx,%esi,1)    

	inc %ecx                   

	cmp $0, %eax               

	jne continua_a_dividere2


	movl $0, %ebx              

	leal numstr, %edx          

ribalta2:

	movb -1(%ecx,%esi,1), %al  
	movb %al, (%ebx,%edx,1)    

	inc %ebx                   

	loop ribalta2


schermo2:

	movb $10, (%ebx,%edx,1)    

	inc %ebx
	movl %ebx, %edx            
	movl $4, %eax              
	movl $1, %ebx              
	leal numstr, %ecx          
	int $0x80                  


    addl $4, %esp
    addl (%esp), %edi
    addl $4, %esp
    cmp %edi, (%esp)
    jl pen
    addl $8, %esp
    movl $127, %eax
    cmp %eax,(%esp)
    jg stop
    jmp print
    

pen:
    movl %edi,tmp
    movl (%esp),%eax
    subl %eax,tmp
    movl tmp,%eax
    addl $4, %esp
    movl (%esp),%ecx
    mul %ecx
    addl %eax,pena
    addl $4, %esp
    movl $127, %ecx
    cmp %ecx,(%esp)
    jg stop
    jmp print



stop:
    movl $4, %eax	        
	movl $1, %ebx	        
	leal conclusione, %ecx        
	movl conclusione_len, %edx        
	int $0x80    

    movl %edi,%eax
    movl $10, %ebx             
	movl $0, %ecx              

	leal numtmp, %esi          


continua_a_dividere_f1:

	movl $0, %edx              
	divl %ebx                  

	addb $48, %dl              
	movb %dl, (%ecx,%esi,1)    

	inc %ecx                   

	cmp $0, %eax               

	jne continua_a_dividere_f1


	movl $0, %ebx              

	leal numstr, %edx          

ribalta_f1:

	movb -1(%ecx,%esi,1), %al  
	movb %al, (%ebx,%edx,1)    

	inc %ebx                   

	loop ribalta_f1


schermo_f1:

	movb $10, (%ebx,%edx,1)    

	inc %ebx
	movl %ebx, %edx            
	movl $4, %eax              
	movl $1, %ebx              
	leal numstr, %ecx          
	int $0x80

    movl $4, %eax	        
	movl $1, %ebx	        
	leal penale, %ecx        
	movl p_len, %edx        
	int $0x80 

    movl pena,%eax
    movl $10, %ebx             
	movl $0, %ecx              

	leal numtmp, %esi 

    continua_a_dividere_f1p:

	movl $0, %edx              
	divl %ebx                  

	addb $48, %dl              
	movb %dl, (%ecx,%esi,1)    

	inc %ecx                   

	cmp $0, %eax               

	jne continua_a_dividere_f1p


	movl $0, %ebx              

	leal numstr, %edx          

ribalta_f1p:

	movb -1(%ecx,%esi,1), %al  
	movb %al, (%ebx,%edx,1)    

	inc %ebx                   

	loop ribalta_f1p


schermo_f1p:

	movb $10, (%ebx,%edx,1)    

	inc %ebx
	movl %ebx, %edx            
	movl $4, %eax              
	movl $1, %ebx              
	leal numstr, %ecx          
	int $0x80

    ret


# inizio della funzione
primo:
    addl $4,elementi
    movl $0, %ebx
    movl $100, %esi
    addl $8, %esp
    movl $6, %edi

# controllo se la casella selezionata dello stack e' uguale al numero in edi
check:
    cmp (%esp), %esi
    je minimo
    addl $12,%esp
    movl $0, %edx
    cmp %edx, (%esp)
    je restart
    addl $4, %esp
    jmp check

# vedo se e' il minimo 
minimo:
    addl $1, %ebx
    subl $4, %esp
    cmp %edi,(%esp)
    jl insert
    addl $16, %esp
    movl $0, %edx
    cmp %edx, (%esp)
    je restart
    addl $4, %esp
    jmp check

# inserisco il nuovo valore massimo
insert:
    movl $0, %edi
    addl (%esp), %edi
    addl $16, %esp
    movl $0, %edx
    cmp %edx, (%esp)
    je restart
    addl $4, %esp
    jmp check
# sono arrivato alla fine e quindi devo ritornare su
restart:
    subl elementi, %esp
    cmp $0, %ebx
    je change
    movl $0, %ebx
    addl $8, %esp
    jmp down

# cerco il valore maggiore da caricare nello stack
down:
    cmp %esi,(%esp)
    je vedi
    addl $16,%esp
    jmp down

vedi:
    subl $4,%esp
    cmp %edi,(%esp)
    je stack1
    addl $20,%esp
    jmp down

# ricarico nello stack i valori  
stack1:
    popl %eax
    popl %ebx
    popl %ecx
    popl %edx
    jmp zero

zero:
    subl $16,%esp
    movl $128,(%esp)
    addl $4,%esp
    movl $128,(%esp)
    addl $4,%esp
    movl $128,(%esp)
    addl $4,%esp
    movl $128,(%esp)
    addl $4,%esp
    movl $0,%edi
    cmp %edi,(%esp)
    je reset
    jmp cycle


cycle:
    addl $16, %esp
    movl $0, %edi
    cmp %edi,(%esp)
    je reset
    jmp cycle

reset:
    subl elementi,%esp
    subl offset,%esp
    push %eax
    push %ebx
    push %ecx
    push %edx
    addl $16,offset
    movl $0,%eax
    movl $0,%ebx
    movl $0,%edx
    movl $0,%ecx
    addl offset,%esp
    addl $8, %esp
    movl $6, %edi
    jmp check

_start:
    popl %esi			
    popl %esi
    popl %esi	
    movl %esi,nomefile		
	testl %esi, %esi
    

    movl $5, %eax
    movl %esi, %ebx
    movl $0, %ecx
    int $0x80

    cmp $0, %eax
    jl _error1

    movl %eax, fd
    movl $0, %esi

    jmp _read
    