# ----- Inclusões --------------------------------

# Arquivo de definições
!include miniSO.def

# ---- all ---------------------------------------
all:		miniSO.img VERSION
		@echo ***********
		@echo * ATENCAO *
		@echo ***********
		@echo - Use os dados abaixo para atualizar a variavel DATA no arquivo miniSO.def:
                @grep "C=DATA *S=_DATA *G=DGROUP *M=INIT.C" miniSO.map
		@echo - Conteudo atual do arquivo:
                @grep DATA miniSO.def
		@echo - Carregue o arquivo miniSO.bxrc no Bochs

# ---- VERSION -----------------------------------
VERSION:	miniSO.def
		@echo $(VERSION) > VERSION

# ---- miniSO.img --------------------------------
miniSO.img:	boot.bin miniSO.bin
		@mkfpimg boot.bin miniSO.bin miniSO.img

# ---- boot.bin ----------------------------------
boot.asm:	boot.bl
		@bootlib -o boot.asm boot.bl

boot.obj:	boot.asm
                @tasm /zn boot

boot.exe:	boot.obj
		@tlink boot

boot.bin:	boot.exe
		@exe2bin boot boot.bin

# ---- command.obj ------------------------------
command.asm:	command.c lib.h miniSO.h command.h
		@bcc -1- -S -ms! -TDc -v- -DminiSO_VERSION="$(VERSION)" command.c

command.obj:	command.asm
		@tasm /zn command,,,

# ---- lib.obj ----------------------------------
lib.asm:	lib.c lib.h miniSO.h scall.h miniSO.def
		@bcc -1- -S -ms! -TDc -v- -DminiSO_CODESEGMENT=0x$(CODE) -DminiSO_DATASEGMENT=0x$(CODE)+0x$(DATA) lib.c

lib.obj:	lib.asm
		@tasm /zn lib,,,

# ---- scall.obj --------------------------------
scall.asm:      scall.c scall.h miniSO.def
                @bcc -1- -S -ms! -TDc -v- -DminiSO_CODESEGMENT=0x$(CODE) -DminiSO_DATASEGMENT=0x$(CODE)+0x$(DATA) scall.c

scall.obj:      scall.asm
                @tasm /zn scall,,,

# ---- miniSO.bin -------------------------------
init.asm:	init.c miniSO.h lib.h miniSO.def
		@bcc -1- -S -ms! -TDc -v- -DminiSO_CODESEGMENT=0x$(CODE) -DminiSO_DATASEGMENT=0x$(CODE)+0x$(DATA) init.c

init.obj:	init.asm
		@tasm /zn init,,,

miniSO.obj:	miniSO.asm miniSO.def
		@tasm /zn /dminiSO_DATASEGMENT=$(CODE)h+$(DATA)h miniSO,,,

miniSO.exe:     init.obj command.obj lib.obj scall.obj miniSO.obj
                @tlink /s init command lib miniSO scall,miniSO,,,

miniSO.bin:	miniSO.exe
		@exe2bin miniSO miniSO.bin

# ---- clean ------------------------------------
clean:
		@if exist bootlib.str del bootlib.str
		@if exist boot.asm del boot.asm
		@if exist lib.asm del lib.asm
		@if exist init.asm del init.asm
		@if exist scall.asm del scall.asm
		@if exist command.asm del command.asm
		@if exist *.obj del *.obj
		@if exist *.bin del *.bin
		@if exist *.exe del *.exe
		@if exist *.map del *.map
		@if exist *.xrf del *.xrf
		@if exist *.lst del *.lst
		@if exist miniso.img del miniso.img
		@if exist bochsout.txt del bochsout.txt
		@if exist VERSION del VERSION

# ---- install ------------------------------------
install:	all
		@bootcopy boot.bin
		@if exist a:\miniSO.bin del a:\miniSO.bin
		@copy miniSO.bin a:\ > nul

# ---- run ----------------------------------------
run:		all
		@-bochs -q -f miniSO.bxrc -rc miniSO-debug_cmd.txt & > nul
