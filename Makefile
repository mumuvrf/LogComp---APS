all: maieutica

maieutica: parser.tab.c lex.yy.c
	gcc -o maieutica parser.tab.c lex.yy.c -lfl

parser.tab.c parser.tab.h: parser.y
	bison -d -v parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

clean:
	rm -f maieutica parser.tab.c parser.tab.h parser.output lex.yy.c

.PHONY: all clean
