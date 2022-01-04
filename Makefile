validation:
	lex proiect.l
	yacc -d proiect.y
	gcc lex.yy.c y.tab.c -o output
	./output <test.txt
rmFiles:
	rm lex.yy.c 
	rm y.tab.c 
	rm y.tab.h 
	rm output