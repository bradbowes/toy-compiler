ifeq ($(OS),Windows_NT)
	TARGET = compile.exe
else
	TARGET = compile
endif

$(TARGET):	utils.pas symbols.pas scanners.pas nodes.pas literal_nodes.pas \
        var_nodes.pas assign_nodes.pas op_nodes.pas if_nodes.pas \
        loop_nodes.pas call_nodes.pas field_nodes.pas decl_nodes.pas \
        sequence_nodes.pas compile.pas bindings.pas parsers.pas
	fpc -Px86_64 -Sh -O3 compile
	strip $(TARGET)

clean:
	rm -rf $(TARGET)
	rm -rf *.o
	rm -rf *.ppu


