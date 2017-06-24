.data
		inicio:  .word 0x10010000		# Inicio del bitmap
		esquina: .word 0x10010214		# Esquina superior izquierda
		te: 	 .word 0xffff0004		# Contiene el ultimo caracter en ser tecleado
		tc: 	 .word 0xffff0000		# Se prende en 1 cuando se va a mandar el caracter tecleado
		         .space 1048576			# 512 x 512 x 4 (bytes)


.macro	tablero($inicio,$desp,$linea)
			move $t1,$inicio			# El color sigue guardado en $t0
			li $t2, 0				# Contador 1
			li $t3, 2				# Contador 2 (hacia atras)
		
	loop:	li $t2, 0					# Vuelves a poner en 0 el contador 1
			subi $t3, $t3, 1			# Le restas 1 al contador 2
			
	loop2:  sw $t0,0($t1)					# Pintas la direccion en $t1
			add $t1, $t1, $desp			# Le sumas el desplazamiento a $t1
			addi $t2, $t2, 1			# Le sumas 1 al contador 1
			blt $t2, 22, loop2
			
			lw $t1, esquina
			add $t1, $t1, $linea			# Bajas la direccion a pintar una linea?
			bnez $t3, loop
.end_macro			 
			 			 
			 
.text
			# Tablero
			li $t0, 0xc7cfdb					# Guardamos en $t0 el color GRIS
			lw $s0, esquina						# Guardamos en $s0 la direccion de la esquina del tablero
			li $s1, 4						# Desplazamiento para mover a la derecha
			li $s2, 2816						# Nro. de linea
			tablero($s0,$s1,$s2)					# Pintamos los bordes horizontales
	
			li $s1, 128						# Desplazamiento para mover hacia abajo
			li $s2, 84						# Nro. de linea
			tablero($s0,$s1,$s2)					# Pintamos los bordes verticales
	
	
	
			# Snake
			li $t2,0						# $t2 sera un contador
			move $t1, $s0						# Guardamos la posicion de la esquina en $t1
			li $t0, 0x53f442					# Guardamos en $t0 el color VERDE
			sw $t0,1448($s0)					# Pintamos el cuadro central del tablero
	
			
mover:
			sw $t0,0($t1)						# Pintar
			li $v0,30
			syscall							# Syscall 30: Tiempo
			
			move $s1,$a0						# Guardamos el tiempo en $s1
			addi $s1,$s1,1000					# Le sumamos un segundo a $s1
			
tiempo:
			la $t5,0xffff0000		
			lw $t5,0($t5)
			bnez $t5,teclado
			
			li $v0,30
			syscall							# Syscall 30: Tiempo
			
			blt $a0,$s1,tiempo
			addi $t1,$t1,4
			blt $t2,32,mover
			b fin
			
teclado:
			la $s2,0xffff0004
			lw $s2,0($s2)

			beq $s2,97,seguir
			bne $s2,100,mover 
			li $s5,0
			sw $t5,0($t1)						# Pintar
			addi $t1,$t1,-4
			b mover
			
seguir:
			li $s5,0
			sw $t5,0($t1)						# Pintar
			addi $t1,$t1,128
			b mover

fin:   li $v0, 10
	   syscall

			
			
