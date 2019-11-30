# Lexical-Interpreter
Lexical parser &amp; analyzer

bison -dy mPL.y

flex mPL.l

bison -dy mPL.y

gcc lex.yy.c y.tab.c -o {execution_file_name}.exe
./{execution_file_name} {testing_text_name}.txt



ex)

bison -dy mPL.y

flex mPL.y

bison -dy mPL.y

gcc lex.yy.c y.tab.c -o result.exe
./result.exe test.txt