ifeq ($(OS),Windows_NT)
	TARGET = compile.exe
else
	TARGET = compile
endif

$(TARGET):	utils.pas Symbols.pas Scanners.pas nodes.pas LiteralNodes.pas \
        VarNodes.pas AssignNodes.pas OpNodes.pas IfNodes.pas \
        LoopNodes.pas CallNodes.pas FieldNodes.pas DeclNodes.pas \
        DescNodes.pas BlockNodes.pas ObjectNodes.pas compile.pas \
        bindings.pas Parsers.pas
	fpc -Sh -Px86_64 -O3 compile
	strip $(TARGET)

clean:
	rm -f $(TARGET)
	rm -f *.o
	rm -f *.s
	rm -f ppas.sh
	rm -f *.ppu


