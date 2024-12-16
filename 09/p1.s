section .text
   default rel
   extern printf
   extern puts
   extern fopen
   extern getline
   global main
   global convert_disk_map
   global get_filesystem_size
   global calculate_checksum

main:
   push rbp
   mov rbp, rsp
   sub rsp, 0x50 ; rsp must always be aligned to 16 bytes or segfault occurs
   mov [rbp-0x8], rdi
   mov [rbp-0x10], rsi
   mov QWORD [rbp-0x18], 0 ; eventual return value for main
   mov rax, [rbp-0x10]
   mov rax, [rax+0x8]
   mov [rbp-0x20], rax ; file name
   mov QWORD [rbp-0x30], 0x5000 ; size of disk map
   mov QWORD [rbp-0x38], __disk_map ; pointer to the disk map
   mov QWORD [rbp-0x40], 0 ; checksum

   cmp QWORD [rbp-0x8], 2
   jl __main_not_enough_args

   mov rsi, __read_mode
   mov rdi, [rbp-0x20]
   call fopen ; fopen(filepath, "r")
   mov [rbp-0x28], rax ; result of open aka FILE *
   cmp QWORD [rbp-0x28], 0
   je __main_could_not_open_file

   mov rdx, [rbp-0x28] ; file pointer
   lea rsi, [rbp-0x30] ; length of disk map
   lea rdi, [rbp-0x38] ; pointer to the pointer to the buffer
   call getline
   mov [rbp-0x30], rax
   cmp rax, -1
   je __main_could_not_read_line

   mov rdi, [rbp-0x30]
   call convert_disk_map

   mov rdi, [rbp-0x30]
   call calculate_checksum
   mov [rbp-0x40], rax

   mov rsi, [rbp-0x40]
   mov rdi, __main_print_checksum_msg
   call printf

__main_end:
   mov rax, [rbp-0x18]
   mov rsi, [rbp-0x10]
   mov rdi, [rbp-0x8]
   mov rsp, rbp
   pop rbp
   ret

__main_not_enough_args:
   mov rdi, __main_not_enough_args_msg
   call printf
   mov QWORD [rbp-0x18], 1
   jmp __main_end

__main_could_not_open_file:
   mov rsi, [rbp-0x20]
   mov rdi, __main_could_not_open_file_msg
   call printf
   mov QWORD [rbp-0x18], 1
   jmp __main_end

__main_could_not_read_line:
   mov rdi, __main_could_not_read_line_msg
   call printf
   mov QWORD [rbp-0x18], 1
   jmp __main_end

convert_disk_map:
   push rbp
   mov rbp, rsp
   sub rsp, 0x10
   mov [rbp-0x8], rbx
   ; rdi contains length of disk_map
   ; rax is the index of disk_map
   mov rbx, __disk_map
   mov QWORD rax, 0
__convert_disk_map_loop_start:
   cmp rax, rdi
   jge __convert_disk_map_after_loop
   sub BYTE [rbx+rax], 0x30
   inc rax
   jmp __convert_disk_map_loop_start
__convert_disk_map_after_loop:
   mov rbx, [rbp-0x8]
   mov QWORD rax, 0 ; return void
   mov rsp, rbp
   pop rbp
   ret

get_filesystem_size:
   push rbp
   mov rbp, rsp
   sub rsp, 0x20
   mov [rbp-0x8], rbx
   mov QWORD [rbp-0x10], 0 ; return value
   mov [rbp-0x18], rdi ; length
   mov QWORD [rbp-0x20], 0 ; index
   mov rbx, __disk_map
__get_filesystem_size_loop_start:
   mov rdx, [rbp-0x18]
   mov rcx, [rbp-0x20]
   cmp rcx, rdx
   jge __get_filesystem_size_after_loop
   mov rax, 0
   mov al, [rbx+rcx]
   add [rbp-0x10], rax
   inc QWORD [rbp-0x20]
   jmp __get_filesystem_size_loop_start
__get_filesystem_size_after_loop:
   mov rax, [rbp-0x10]
   mov rbx, [rbp-0x8]
   mov rsp, rbp
   pop rbp
   ret

calculate_checksum:
   push rbp
   mov rbp, rsp
   sub rsp, 0x50
   mov [rbp-0x8], rdi ; length of disk_map
   mov [rbp-0x10], rbx ; just in case
   mov QWORD [rbp-0x18], 0 ; fwd_dmidx
   mov [rbp-0x20], rdi ; bwd_dmidx
   sub QWORD [rbp-0x20], 1
   mov rax, __disk_map
   mov rbx, 0
   mov bl, [rax]
   mov [rbp-0x28], rbx ; fwd_rmbyt
   mov rbx, [rbp-0x20]
   mov rcx, 0
   mov cl, [rax+rbx]
   mov [rbp-0x30], rcx ; bwd_rmbyt
   mov QWORD [rbp-0x38], 0 ; fwd_fsidx
   mov rdi, [rbp-0x8]
   call get_filesystem_size
   mov [rbp-0x40], rax ; bwd_fsidx
   sub QWORD [rbp-0x40], 1
   mov QWORD [rbp-0x48], 0 ; checksum

__calculate_checksum_loop_start:
   mov rax, [rbp-0x38]
   mov rbx, [rbp-0x40]
   cmp rax, rbx
   jg __calculate_checksum_after_loop
   cmp QWORD [rbp-0x28], 0
   jle __calculate_checksum_loop_fwd_rmbyt_branch
   cmp QWORD [rbp-0x30], 0
   jle __calculate_checksum_loop_bwd_rmbyt_branch

   mov rax, [rbp-0x18]
   and rax, 1
   cmp rax, 0 ; check if even
   jne __calculate_checksum_loop_empty_block_branch

   mov rax, [rbp-0x18]
   sar rax, 1 ; file id
   mov rbx, [rbp-0x38]
   mul rbx
   add [rbp-0x48], rax
   dec QWORD [rbp-0x28]
   inc QWORD [rbp-0x38]

   jmp __calculate_checksum_loop_start
__calculate_checksum_loop_empty_block_branch:

   mov rax, [rbp-0x20]
   sar rax, 1 ; file id
   mov rbx, [rbp-0x38]
   mul rbx
   add [rbp-0x48], rax
   dec QWORD [rbp-0x28]
   dec QWORD [rbp-0x30]
   inc QWORD [rbp-0x38]
   dec QWORD [rbp-0x40]

   jmp __calculate_checksum_loop_start
__calculate_checksum_loop_fwd_rmbyt_branch:
   inc QWORD [rbp-0x18]
   mov rax, __disk_map
   mov rbx, [rbp-0x18]
   mov rcx, 0
   mov cl, [rax+rbx]
   mov [rbp-0x28], rcx
   jmp __calculate_checksum_loop_start
__calculate_checksum_loop_bwd_rmbyt_branch:
   mov rbx, [rbp-0x20]
   dec rbx
   mov rax, __disk_map
   mov rcx, 0
   mov cl, [rax+rbx]
   sub [rbp-0x40], rcx
   dec rbx
   mov rcx, 0
   mov cl, [rax+rbx]
   mov [rbp-0x30], rcx
   mov [rbp-0x20], rbx
   jmp __calculate_checksum_loop_start
__calculate_checksum_after_loop:
   mov rax, [rbp-0x48]
   mov rbx, [rbp-0x10]
   mov rsp, rbp
   pop rbp
   ret

section .data
   __main_not_enough_args_msg: db "No file included!", 0xa, 0
   __read_mode: db "r", 0
   __main_could_not_open_file_msg: db "Could not open %s", 0xa, 0
   __main_could_not_read_line_msg: db "Could not getline", 0xa, 0
   __main_length_of_disk_map_msg: db "Length of disk map %llu", 0xa, 0
   __main_print_checksum_msg: db "Checksum: %llu", 0xa, 0
   __main_string_debug_msg: db "%s", 0xa, 0
   __main_one_llu_debug_msg: db "%llu", 0xa, 0
   __main_two_llu_debug_msg: db "%llu %llu", 0xa, 0

section .bss
   __disk_map: resb 0x5000 ; more than 20000