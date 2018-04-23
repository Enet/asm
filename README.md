# AT&T assembly language for Linux
## How to compile
If a source code contains main function:
```sh
gcc -m32 file.s -o file.elf
./file.elf
```

If you see _start instead main:
```sh
as --32 file.s -o file.o
ld -m elf_i386 file.o -o file.elf
./file.elf
```

## How to run
```sh
./hello.elf
./sum.elf # Type 100 and 200
./calc.elf # Type 4, 5 and ^
./table.elf # Type 20
./factorial_loop.elf # Type 5
./factorial_recursion.elf # Type 5
./args.elf 1 2 3
./max_min.elf # Type 4 and 3, 4, 5, 6
./caesar.elf # Type 3 and "Hello world"
./strlen.elf
./file_write.elf
./file_read.elf
./file_copy.elf file.txt new_file.txt
./atoi.elf -123
./json_prettify.elf file.json
```
