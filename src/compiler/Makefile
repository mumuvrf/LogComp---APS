all: maieutic

maieutic: lexer.l parser.y ast.h
	bison -d parser.y
	flex lexer.l
	g++ -std=c++17 parser.tab.c lex.yy.c -o maieutic -lm

clean:
	rm maieutic parser.tab.c parser.tab.h lex.yy.c