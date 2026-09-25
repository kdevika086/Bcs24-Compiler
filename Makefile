CC = gcc
TARGET = bcs24

$(TARGET): parser.tab.c lex.yy.c
	$(CC) parser.tab.c lex.yy.c -o $(TARGET)

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

clean:
	rm -f $(TARGET) parser.tab.c parser.tab.h lex.yy.c