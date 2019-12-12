@
@ Created by Michael McGregor on 10/25/19.
@ Implemented by Katherine Wilsdon
@

.text


.align 2
.global my_strcat
.global my_strncat
.global my_strchr
.global my_strrchr
.global my_strcmp
.global my_strncmp
.global my_strcpy
.global my_strncpy
.global my_strdup
.global my_strndup
.global my_strlen
.global my_strstr

.func my_strcat
my_strcat:

    	@ char *strcat(char *dest, char *src){
    	@     int i = my_strlen(char *dest);
   	@     strcpy(dest + i, src);
    	@     return dest;
	@ }
	
	push    {fp, lr}
    	add     fp, sp, #4
	sub     sp, sp, #16
                                		@ dest(base address): [fp, #-8]
						@ src(base address): [fp, #-12]
                        			@ i (dest length): [fp, #-16]        
						@ dest + len(dest): [fp, #-20]
	@ initialize variables
	str 	r0, [fp, #-8]
	str 	r1, [fp, #-12]
	
	@ determine the length of dest
	ldr 	r0, [fp, #-8]
	bl	my_strlen			@ i = len(dest)
	str	r0, [fp, #-16]

	@ strcpy (dest + len(dest), src) 
	ldr	r1, [fp, #-8]
	ldr 	r2, [fp, #-16]
	add 	r0, r1, r2			@ dest + i
	ldr 	r1, [fp, #-12]
	bl 	my_strcpy
	str	r0, [fp, #-20]

	@ add dest + i
	ldr	r1, [fp, #-8]
	ldr 	r2, [fp, #-16]
	add	r1, r1, r2			@ dest + i
	
	@ load the byte returned by my_strcpy
	ldr	r0, [fp, #-20]
	ldrb	r0, [r0]

	@ store the byte in dest + i
	strb	r0, [r1]

	ldr	r0, [fp, #-8]
	sub     sp, fp, #4
    	pop     {fp, pc}

.endfunc

.func my_strncat
my_strncat:
    
    	push    {fp, lr}
	add     fp, sp, #4
	sub     sp, sp, #20
						@ dest(base address): [fp, #-8]
						@ src(base address): [fp, #-12] 
						@ n(number of bytes of source copied) : [fp, #-16]
						@ len(dest): [fp, #-20]
						@ dest + len(dest) [fp, #-24]
	@ initialize variables
	str 	r0, [fp, #-8]
	str 	r1, [fp, #-12]
	str	r2, [fp, #-16]
	mov 	r0, #0
	str	r0, [fp, #-20]
	
	@ len(src)
	ldr	r0, [fp, #-12]
	bl	my_strlen
	str	r0, [fp, #-24]
	
	@ if (n < len(src))
	ldr	r0, [fp, #-16]	
	ldr 	r1, [fp, #-24]		
	cmp	r0, r1				@ n < len(src) 
	bge	strncat_greater_than_equal_n_bytes	@ n >= len(src)
	
strncat_less_than_n_bytes:
	@ determine the length of dest
	ldr 	r0, [fp, #-8]
	bl	my_strlen			@ len(dest)
	str	r0, [fp, #-20]

	@ strcpy (dest + len(dest), src) 
	ldr	r1, [fp, #-8]
	ldr 	r2, [fp, #-20]
	add 	r0, r1, r2			@ dest + len(dest)
	ldr 	r1, [fp, #-12]
	ldr	r2, [fp, #-16]
	bl 	my_strncpy
	str	r0, [fp, #-24]

	@ add dest + len(dest)
	ldr	r1, [fp, #-8]
	ldr 	r2, [fp, #-20]
	add	r1, r1, r2			@ dest + len(dest)
	
	@ load the byte returned by my_strcpy
	ldr	r0, [fp, #-24]
	ldrb	r0, [r0]

	@ store the byte in dest + len(dest)
	strb	r0, [r1]

    	b       strncat_end

strncat_greater_than_equal_n_bytes:
	
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-12]
	bl	my_strcat
	str 	r0, [fp, #-8]
	
	
strncat_end:

	ldr	r0, [fp, #-8]
	sub     sp, fp, #4
	pop     {fp, pc}

.endfunc

.func my_strchr
my_strchr:
    	push    {fp, lr}
    	add     fp, sp, #4
	sub     sp, sp, #12
						@ s (string): [fp, #-8]
						@ c (int char): [fp, #-12]
						@ i (iterated length): [fp, #-16]

	@ while (s++) {
	@   if (s[i] == c)
	@     return s[i];
	@   if (s[i] == '\0')
	@     return NULL;
	@ } 

	@ intitalize variables
	str 	r0, [fp, #-8]
	str	r1, [fp, #-12]
	mov	r0, #0
	str	r0, [fp, #-16]


while_strchr_begin:
	
	@ add s and i
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-16]
	add	r0, r0, r1
	ldrb	r0, [r0]

	@ if (s[i] == c)
	ldr	r1, [fp, #-12]
	cmp	r0, r1
	beq	strchr_found_char_end

	@ add s and i
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-16]
	add	r0, r0, r1
	ldrb	r0, [r0]

	@ if (s[i] == '\0')
	mov	r1, #0
	cmp	r0, r1
	beq	strchr_not_found_char_end

	@ iterate i
	ldr 	r0, [fp, #-16]
	add	r0, r0, #1		@ i++
	str	r0, [fp, #-16]
	
	b 	while_strchr_begin	

strchr_found_char_end:
	
	@ return s[i]
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-16]
	add	r0, r0, r1
	sub     sp, fp, #4
	pop     {fp, pc}

strchr_not_found_char_end:
	
	@ return null
	mov	r0, #0
	sub     sp, fp, #4
	pop     {fp, pc}

.endfunc

.func my_strrchr
my_strrchr:
 	push    {fp, lr}
    	add     fp, sp, #4
	sub     sp, sp, #12
						@ s (string): [fp, #-8]
						@ c (int char): [fp, #-12]
						@ i (iterated length): [fp, #-16]

	@ while (s--) {
	@   if (s[i] == c)
	@     return s[i];
	@   if ( i == -1)
	@     return NULL;
	@ } 

	@ intitalize variables
	str 	r0, [fp, #-8]
	str	r1, [fp, #-12]
	mov	r0, #0
	str	r0, [fp, #-16]
	
	@ i = len(s)
	ldr	r0, [fp, #-8]
	bl 	my_strlen
	str	r0, [fp, #-16]

while_strrchr_begin:
	
	@ s[i]
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-16]
	add	r0, r0, r1
	ldrb	r0, [r0]

	@ if (s[i] == c)
	ldr	r1, [fp, #-12]
	cmp	r0, r1
	beq	strrchr_found_char_end

	@ if (i == -1)
	ldr	r0, [fp, #-16]
	mov	r1, #-1
	cmp	r0, r1
	beq	strrchr_not_found_char_end

	@ decrement i
	ldr 	r0, [fp, #-16]
	sub	r0, r0, #1			@ i--
	str	r0, [fp, #-16]
	
	b 	while_strrchr_begin	

strrchr_found_char_end:
	
	@ return s[i]
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-16]
	add	r0, r0, r1
	sub     sp, fp, #4
	pop     {fp, pc}

strrchr_not_found_char_end:
	
	@ return null
	mov	r0, #0
	sub     sp, fp, #4
	pop     {fp, pc}

.endfunc

.func my_strcmp
my_strcmp:
 	push    {fp, lr}
    	add     fp, sp, #4
	sub     sp, sp, #16
        					@ s1: [fp, #-8]
						@ s2: [fp, #-12]
						@ i (incremented length): [fp, #-16]
						@ return value:	[fp, #-20]
							@ return <0:the first character that does not 
							@     match has a lower value in s1 than in s2
							@ return 0: the contents of both strings are equal
							@ return >0: the first character that does not
							@     match has a greater value in s1 than in s2

	@ initialize variables
	str	r0, [fp, #-8]
	str	r1, [fp, #-12]
	mov	r0, #0
	str	r0, [fp, #-16]
						@ while (s1[i] == s2[i]){
						@     if (s1[i] == \0)
						@          return s1[i] - s2[i];
						@     i++;
						@ }
						@ return s1[i] - s2[i];


while_strcmp_begin:	
	
	@ s1 + i
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-16]
	add	r0, r0, r1
	ldrb	r0, [r0]	

	@ s2 + i
	ldr	r1, [fp, #-12]
	ldr	r2, [fp, #-16]
	add	r1, r1, r2
	ldrb	r1, [r1]	

	@ s1[i] == s2[i]
	cmp	r0, r1
	bne	while_strcmp_end

if_strcmp:
	
	@ s1 + i
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-16]
	add	r0, r0, r1
	ldrb	r0, [r0]	
	
	@ s1[i] != \0
	mov	r1, #0
	cmp	r0, r1				@ s1[i] != \0
	beq	while_strcmp_end		@ s1[i] == \0

	@ increment i
	ldr	r0, [fp, #-16]
	add	r0, r0, #1			@i++
	str	r0, [fp, #-16]

	b	while_strcmp_begin

while_strcmp_end:
	
	@ s1 + i
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-16]
	add	r0, r0, r1
	ldrb	r0, [r0]	

	@ s2 + i
	ldr	r1, [fp, #-12]
	ldr	r2, [fp, #-16]
	add	r1, r1, r2
	ldrb	r1, [r1]	

	@ s1[i] - s2[i]
	sub	r0, r0, r1
	str	r0, [fp, #-20]
	
	@ return s1[i] - s2[i]
	ldr	r0, [fp, #-20]
	sub     sp, fp, #4
	pop     {fp, pc}

.endfunc

.func my_strncmp
my_strncmp:
   	
	push    {fp, lr}
    	add     fp, sp, #4
	sub     sp, sp, #24
        					@ s1: [fp, #-8]
						@ s2: [fp, #-12]
						@ n(number of bytes of s2 copied) : [fp, #-16]
						@ len(s2): [fp, #-20]
						@ i (incremented length): [fp, #-24]
						@ return value:	[fp, #-28]
							@ return <0:the first character that does not 
							@     match has a lower value in s1 than in s2
							@ return 0: the contents of both strings are equal
							@ return >0: the first character that does not
							@     match has a greater value in s1 than in s2


	@ initialize variables
	str 	r0, [fp, #-8]
	str 	r1, [fp, #-12]
	str	r2, [fp, #-16]
	mov 	r0, #0
	str	r0, [fp, #-20]
	str	r0, [fp, #-24]
	
	@ len(s2)
	ldr	r0, [fp, #-12]
	bl	my_strlen
	str	r0, [fp, #-20]
	
	@ if (n < len(s2))
	ldr	r0, [fp, #-16]	
	ldr 	r1, [fp, #-20]		
	cmp	r0, r1				@ n < len(src) 
	bge	strncat_greater_than_equal_n_bytes	@ n >= len(src)
	
strncmp_less_than_n_bytes: 
	
	@ while (i < n)
	ldr	r0, [fp, #-24]
	ldr	r1, [fp, #-16]
	cmp	r0, r1
	bge	strncmp_less_than_n_bytes_equal_end
	
	@ s1 + i
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-24]
	add	r0, r0, r1
	ldrb	r0, [r0]	

	@ s2 + i
	ldr	r1, [fp, #-12]
	ldr	r2, [fp, #-24]
	add	r1, r1, r2
	ldrb	r1, [r1]	

	@ s1[i] == s2[i]
	cmp	r0, r1
	bne	strncmp_less_than_n_bytes_not_equal_end

	@ increment i
	ldr	r0, [fp, #-24]
	add	r0, r0, #1			@i++
	str	r0, [fp, #-24]

	b	strncmp_less_than_n_bytes

strncmp_less_than_n_bytes_not_equal_end:
	
	@ s1 + i
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-24]
	add	r0, r0, r1
	ldrb	r0, [r0]	

	@ s2 + i
	ldr	r1, [fp, #-12]
	ldr	r2, [fp, #-24]
	add	r1, r1, r2
	ldrb	r1, [r1]	

	@ s1[i] - s2[i]
	sub	r0, r0, r1
	str	r0, [fp, #-28]

	b	strncmp_end

strncmp_less_than_n_bytes_equal_end:
	
	@ i - 1
	ldr	r0, [fp, #-24]
	sub	r0, r0, #1
	str	r0, [fp, #-24]	

	@ s1 + i
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-24]
	add	r0, r0, r1
	ldrb	r0, [r0]	

	@ s2 + i
	ldr	r1, [fp, #-12]
	ldr	r2, [fp, #-24]
	add	r1, r1, r2
	ldrb	r1, [r1]	

	@ s1[i] - s2[i]
	sub	r0, r0, r1
	str	r0, [fp, #-28]

	b	strncmp_end


strncmp_greater_than_equal_n_bytes:
	
	@ strcmp (s1, s2)	
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-12]
	bl	my_strcmp
	str 	r0, [fp, #-28]

strncmp_end:
	
	@ return s1[i] - s2[i]
	ldr	r0, [fp, #-28]
	sub     sp, fp, #4
	pop     {fp, pc}



.endfunc

.func my_strcpy
my_strcpy:
 	push    {fp, lr}
    	add     fp, sp, #4
	sub     sp, sp, #12
        					@ dest(base address): [fp, #-8]
						@ src(base address): [fp, #-12] 
						@ i(incremented length): [fp, #-16]
	       
	@ initialize variables
	str 	r0, [fp, #-8]
	str 	r1, [fp, #-12]
	mov 	r0, #0
	str	r0, [fp, #-16]
	
while_strcpy_begin:
						@ char *my_strcpy(char *dest, char *src){
						@     int i = 0;
						@     while(src[i] != 0) {
						@         dest[i] = src[i];
						@         i++;
						@     } 
						@     dest[i] = \0;
						@     return dest;
						@ }
	@ src[i]
	ldr     r1, [fp, #-12]		
    	ldr     r2, [fp, #-16]		
    	add     r1, r1, r2			@ src + i          

	@ while (src[i] != 0)
    	ldrb    r1, [r1]            
    	cmp     r1, #0              		@ src[i] != 0
    	beq while_strcpy_end			@ src[i] == \0

	@ dest[i]
	ldr	r0, [fp, #-8]
	ldr	r2, [fp, #-16]
	add	r0, r0, r2			@ dest + i		
	
	@ src[i]
	ldr     r1, [fp, #-12]		
    	ldr     r2, [fp, #-16]		
    	add     r1, r1, r2    			@ src + i      

	@ dest[i] = src[i]
	ldrb	r1, [r1]	
	strb	r1, [r0]			@ dest[i] = scr[i]	
	
	@ iterate i
    	ldr     r1, [fp, #-16]
    	add     r1, r1, #1          		@ i++
    	str     r1, [fp, #-16]

    	b       while_strcpy_begin

while_strcpy_end:
	@ dest[i]
	ldr 	r1, [fp, #-8]
	ldr	r2, [fp, #-16]
	add	r0, r1, r2			@ dest + i		

	@ dest[i] = \0
	mov	r1, #0
	strb	r1, [r0]			@ dest[i] = \0
	
	@ return dest
	ldr	r0, [fp, #-8]
	sub     sp, fp, #4
    	pop     {fp, pc}
  
.endfunc

.func my_strncpy
my_strncpy:
	push    {fp, lr}
	add     fp, sp, #4
	sub     sp, sp, #20
						@ dest(base address): [fp, #-8]
						@ src(base address): [fp, #-12] 
						@ n(number of bytes of source copied) : [fp, #-16]
						@ i(incremented length): [fp, #-20]
	       					@ len(src): [fp, #-24]
	@ initialize variables
	str 	r0, [fp, #-8]
	str 	r1, [fp, #-12]
	str	r2, [fp, #-16]
	mov 	r0, #0
	str	r0, [fp, #-20]
	
	@ if (len(src) < n)
	ldr	r0, [fp, #-12]
	bl	my_strlen
	str	r0, [fp, #-24]
	
	@ if (n < len(src))
	ldr	r0, [fp, #-16]	
	ldr 	r1, [fp, #-24]		
	cmp	r0, r1				@ n < len(src) 
	beq	strncpy_greater_than_equal_n_bytes		@ n >= len(src)	

strncpy_less_than_n_bytes:
	
	@ while (i < n)
    	ldr	r0, [fp, #-20]
	ldr	r1, [fp, #-16]            
    	cmp     r0, r1  	            	@ i < n
    	bge 	strncpy_end			@ i >= n

	@ dest[i]
	ldr	r0, [fp, #-8]
	ldr	r2, [fp, #-20]
	add	r0, r0, r2			@ dest + i		
	
	@ src[i]
	ldr     r1, [fp, #-12]		
    	ldr     r2, [fp, #-20]		
    	add     r1, r1, r2    			@ src + i      

	@ dest[i] = src[i]
	ldrb	r1, [r1]	
	strb	r1, [r0]			@ dest[i] = scr[i]	
	
	@ iterate i
    	ldr     r1, [fp, #-20]
    	add     r1, r1, #1          		@ i++
    	str     r1, [fp, #-20]

    	b       strncpy_less_than_n_bytes

strncpy_greater_than_equal_n_bytes:
	
	@ my_strcpy(dest, src)
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-12]
	bl	my_strcpy
	str 	r0, [fp, #-8]

	@ if (n > len(src))
	ldr	r0, [fp, #-16]	
	ldr 	r1, [fp, #-24]		
	cmp	r0, r1				@ n > len(src) 
	ble	strncpy_end			@ n <= len(src)

	@ i = len(src)
	ldr	r0, [fp, #-20]
	ldr	r1, [fp, #-24]
	mov	r0, r1
	str	r0, [fp, #-20]	

strncpy_greater_than_n_bytes:	
	@ dest[i]
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-24]
	add	r0, r0, r1
	ldrb	r0, [r0]
	
	@ dest[n]
	ldr	r1, [fp, #-8]
	ldr	r2, [fp, #-16]
	add	r1, r1, r2
	ldrb	r1, [r1]

	@ while (dest[i] < dest[n])
	cmp	r0, r1
	bge	strncpy_end

	@ dest[i]
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-24]
	add	r0, r0, r1
	ldrb	r0, [r0]
	
	@ dest[i] == \0
	mov	r0, #0
	strb	r0, [r0]

	@ iterate i
	ldr 	r0, [fp, #-24]
	add	r0, r0, #1
	str	r0, [fp, #-24]

	b	strncpy_greater_than_n_bytes

strncpy_end:
	
	@ return dest
	ldr	r0, [fp, #-8]
	sub     sp, fp, #4
	pop     {fp, pc}

.endfunc

.func my_strdup
my_strdup:
    	
	push    {fp, lr}
	add     fp, sp, #4
	sub     sp, sp, #12
						@ dest(new string): [fp, #-8]
						@ s : [fp, #-12]	
						@ len(s) : [fp, #-16]
	@initialize variables
	str 	r0, [fp, #-12]

	@ len(s) + 1
	ldr	r0, [fp, #-12]
	bl	my_strlen
	add	r0, r0, #1
	str	r0, [fp, #-16]

	@ create a new string
	ldr	r0, [fp, #-16]
	bl	malloc
	str	r0, [fp, #-8]

	@ strcpy(dest, s)
	ldr 	r0, [fp, #-8]
	ldr	r1, [fp, #-12]
	bl 	my_strcpy
	str	r0, [fp, #-8]
 
	@ return dest
	ldr	r0, [fp, #-8]
	sub     sp, fp, #4
	pop     {fp, pc}


.endfunc

.func my_strndup
my_strndup:
   	push    {fp, lr}
	add     fp, sp, #4
	sub     sp, sp, #16
						@ dest(new string): [fp, #-8]
						@ s : [fp, #-12]	
						@ n(number of bytes of source copied) : [fp, #-16]
						@ len(s) : [fp, #-20]
	@initialize variables
	str 	r0, [fp, #-12]
	str	r1, [fp, #-16]

	@ len(s)
	ldr	r0, [fp, #-12]
	bl	my_strlen
	str	r0, [fp, #-20]

	
	@ if (n < len(s))
	ldr	r0, [fp, #-16]	
	ldr 	r1, [fp, #-20]		
	cmp	r0, r1				@ n < len(src) 
	bge	strndup_greater_than_equal_n_bytes	@ n >= len(src)
	
strndup_less_than_n_bytes:
	
	@ len(s) + 1
	ldr	r0, [fp, #-20]
	add	r0, r0, #1
	str	r0, [fp, #-20]

	@ create a new string
	ldr	r0, [fp, #-16]
	bl	malloc
	str	r0, [fp, #-8]
	
	@ strncpy(dest, s, n)
	ldr 	r0, [fp, #-8]
	ldr	r1, [fp, #-12]
	ldr	r2, [fp, #-16]
	bl 	my_strncpy
	str	r0, [fp, #-8]
 
	b 	strndup_end

strndup_greater_than_equal_n_bytes:
	
	@ strdup(s)
	ldr	r0, [fp, #-12]
	bl	my_strdup
	str 	r0, [fp, #-8]
	
	
strndup_end:
	
	@ return dest
	ldr	r0, [fp, #-8]
	sub     sp, fp, #4
	pop     {fp, pc}

.endfunc

.func my_strlen
my_strlen:

    	@ int my_strlen(string s){
    	@   int i = 0;
    	@   while (s[i] != 0)
    	@     i++;
    	@   return i;
	@ }

    	push    {fp, lr}
    	add     fp, sp, #4
    	sub     sp, sp, #8
                                		@ s(base address): [fp, #-8]
                                		@ i(incremented length): [fp, #-12]
    	@initialize variables
	str     r0, [fp, #-8]
    	mov     r1, #0
    	str     r1, [fp,#-12]      

	@ while s[i] != 0
while_strlen_begin:
	
	@ s[i]
    	ldr     r0, [fp, #-8]       
    	ldr     r1, [fp, #-12]      
    	add     r0, r0, r1          

	@ if (s[i] != '\0')
    	ldrb    r0, [r0]            
    	cmp     r0, #0              		@ s[i] != 0
    	beq while_strlen_end        		@ s[i] == \0

    	@ iterate i
    	ldr     r0, [fp, #-12]
    	add     r0, r0, #1          		@ i++
    	str     r0, [fp, #-12]
    	b       while_strlen_begin

while_strlen_end:
	
	@ return i
    	ldr     r0, [fp, #-12] 
    	sub     sp, fp, #4
    	pop     {fp, pc}

.endfunc

.func my_strstr
my_strstr:
 	push    {fp, lr}
    	add     fp, sp, #4
    	sub     sp, sp, #28
        					@ haystack: [fp, #-8]
						@ needle: [fp, #-12]
						@ i (incremented length for haystack): [fp, #-16]
						@ j (incremented length for needle and pattern): [fp, #-20]
					
	@ for(int i = 0; i <= len(haystack); ++i)
	@   if (haystack[i] != needle[j])
	@     continue;
	@   while(1) {
	@     if (needle[j] == '\0')
	@       return haystack[i];
	@     if (haystack[i+j] != needle[j]) {
	@       j = 0;
	@       break;
	@     j++;
	@   }
	@ }
	@ return null;
	

	@ intitalize variables
	str	r0, [fp, #-8]
	str	r1, [fp, #-12]
	mov	r0, #0
	str	r0, [fp, #-16]
	str	r0, [fp, #-20]

for_strstr_begin:
	@ haystack[i]
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-16]
	add	r0, r0, r1
	ldrb	r0, [r0]

	@ if (haystack[i] != '\0')	
	mov	r1, #0
	cmp	r0, r1				@ haystack[i] != '\0'
	beq	strstr_not_found_end		@ haystack[i] == '\0'
	
	@ haystack[i]
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-16]
	add	r0, r0, r1
	ldrb	r0, [r0]

	@ needle[j]
	ldr	r1, [fp, #-12]
	ldr	r2, [fp, #-20]
	add	r1, r1, r2
	ldrb	r1, [r1]	
	
	@ if (hystack[i] == needle[j])
	cmp	r0, r1				@ haystack[i] == needle[j]
	bne	strstr_iter_i			@ haystack[i] != needle[j]

while_strstr_begin:
	@ needle[j]
	ldr	r1, [fp, #-12]
	ldr	r2, [fp, #-20]
	add	r1, r1, r2
	ldrb	r1, [r1]	
	

	@ if (needle[j] != '\0')
	mov	r2, #0
	cmp	r1, r2				@ needle[j] != '\0'
	beq	strstr_found_end		@ needle[j] == '\0'
	
	@ haystack[i+j]
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-16]
	ldr	r2, [fp, #-20]
	add	r0, r0, r1
	add	r0, r0, r2
	ldrb	r0, [r0]

	@ needle[j]
	ldr	r1, [fp, #-12]
	ldr	r2, [fp, #-20]
	add	r1, r1, r2
	ldrb	r1, [r1]

	@ if (haystack[i+j] != needle[j])
	cmp 	r0, r1				@ haystack[i+j] != needle[j]
	beq	strstr_iter_j			@ haystack[i+j] == needle[j]
	
	b	strstr_iter_i

strstr_iter_i:

	@ j = 0
	mov	r0, #0
	str	r0, [fp, #-20]
	
	@ iterate i
	ldr 	r0, [fp, #-16]
	add	r0, r0, #1
	str	r0, [fp, #-16]

	b	for_strstr_begin

strstr_iter_j:
	
	@ iterate j
	ldr 	r0, [fp, #-20]
	add	r0, r0, #1
	str	r0, [fp, #-20]

	b	while_strstr_begin

strstr_found_end:
	
	@ return haystack[i]
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-16]
	add	r0, r0, r1
	sub     sp, fp, #4
    	pop     {fp, pc}

strstr_not_found_end:
	
	@ return NULL
	mov	r0, #0     
    	sub     sp, fp, #4
    	pop     {fp, pc}

.endfunc
