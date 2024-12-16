section .text
   default rel
   extern printf
   extern puts
   extern fopen
   extern getline
   global main
   global convert_disk_map
   global get_filesystem_size
   global setup_file_data
   global compact
   global digest
   global find_blank_space
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
   call setup_file_data

   mov rdi, [rbp-0x30]
   call compact

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

setup_file_data:
   push rbp
   mov rbp, rsp
   sub rsp, 0x30
   mov [rbp-0x8], rdi ; length
   mov QWORD [rbp-0x10], 0 ; fsidx
   mov QWORD [rbp-0x18], 0 ; i
   mov [rbp-0x20], rbx

__setup_file_data_loop_start:
   mov rbx, [rbp-0x18]
   mov rax, [rbp-0x8]
   cmp rbx, rax
   jge __setup_file_data_after_loop

   mov rbx, [rbp-0x18]
   and rbx, 1
   cmp rbx, 0
   jne __setup_file_data_loop_odd
   mov rbx, [rbp-0x18]
   sar rbx, 1
   mov rax, [rbp-0x10]
   mov rcx, __file_offsets
   mov [rcx+rbx*8], rax
   jmp __setup_file_data_loop_end
__setup_file_data_loop_odd:
   mov rbx, [rbp-0x18]
   mov rcx, __disk_map
   mov rax, 0
   mov al, [rcx+rbx] ; DISK_MAP[i]
   mov rcx, __blank_spaces
   mov [rcx+rbx], al
__setup_file_data_loop_end:
   mov rbx, [rbp-0x18]
   mov rcx, __fsidx_up_to
   mov rax, [rbp-0x10]
   mov [rcx+rbx*8], rax ; FSIDX_UP_TO[i] = fsidx
   mov rcx, __disk_map
   mov rax, 0
   mov al, [rcx+rbx] ; DISK_MAP[i]
   add [rbp-0x10], rax ; fsidx += DISK_MAP[i]
   inc QWORD [rbp-0x18]
   jmp __setup_file_data_loop_start
__setup_file_data_after_loop:
   mov rbx, [rbp-0x20]
   mov rax, 0
   mov rsp, rbp
   pop rbp
   ret

digest:
   push rbp
   mov rbp, rsp
   sub rsp, 0x30
   mov [rbp-0x8], rdx ; length
   mov [rbp-0x10], rsi ; offset/index
   mov [rbp-0x18], rdi ; file_id
   mov [rbp-0x20], rsi
   add [rbp-0x20], rdx ; offset + length = end
   mov QWORD [rbp-0x28], 0 ; sum

__digest_loop_start:
   mov rdi, [rbp-0x20] ; end
   mov rsi, [rbp-0x10] ; index
   cmp rsi, rdi
   jge __digest_after_loop

   mov rax, [rbp-0x10]
   add [rbp-0x28], rax ; add to sum

   inc QWORD [rbp-0x10]
   jmp __digest_loop_start
__digest_after_loop:
   mov rax, [rbp-0x28]
   mul QWORD [rbp-0x18] ; sum *= file_id
   mov rsp, rbp
   pop rbp
   ret

find_blank_space:
   push rbp
   mov rbp, rsp
   sub rsp, 0x30
   mov [rbp-0x8], rsi ; length
   mov [rbp-0x10], rdi ; limit
   mov QWORD [rbp-0x18], 1 ; index
   mov QWORD [rbp-0x20], 0 ; return value

__find_blank_space_loop_start:
   mov rdi, [rbp-0x10]
   mov rax, [rbp-0x18]
   cmp rax, rdi
   jge __find_blank_space_after_loop
   mov rcx, __blank_spaces
   mov rdx, [rbp-0x18]
   mov rax, 0
   mov al, [rcx+rdx]
   mov rsi, [rbp-0x8]
   cmp rax, rsi
   jge __find_blank_space_set_ret_val
   add QWORD [rbp-0x18], 2
   jmp __find_blank_space_loop_start
__find_blank_space_set_ret_val:
   mov rax, [rbp-0x18]
   mov [rbp-0x20], rax
__find_blank_space_after_loop:
   mov rax, [rbp-0x20]
   mov rsp, rbp
   pop rbp
   ret

compact:
   push rbp
   mov rbp, rsp
   sub rsp, 0x40
   mov [rbp-0x8], rdi ; length
   mov [rbp-0x10], rdi ; bwd_dmidx
   dec QWORD [rbp-0x10]

__compact_loop_start:
   mov rax, [rbp-0x10]
   mov rdi, [rbp-0x8]
   cmp rax, 0
   jl __compact_after_loop
   cmp rax, rdi
   jge __compact_after_loop
   mov rdi, [rbp-0x10]
   mov rcx, __disk_map
   mov rax, 0
   mov al, [rcx+rdi]
   mov rsi, rax
   call find_blank_space
   mov [rbp-0x18], rax ; size_t bsidx = find_blank_space(bwd_dmidx, DISK_MAP[bwd_dmidx])
   cmp QWORD [rbp-0x18], 0
   je __compact_loop_end
   mov rcx, __disk_map
   mov rdx, [rbp-0x18]
   mov rax, 0
   mov al, [rcx+rdx]
   mov [rbp-0x20], rax ; DISK_MAP[bsidx]
   mov rcx, __blank_spaces
   mov rdx, [rbp-0x18]
   mov rax, 0
   mov al, [rcx+rdx]
   mov [rbp-0x28], rax ; BLANK_SPACES[bsidx]
   mov rax, [rbp-0x20]
   sub rax, [rbp-0x28]
   mov [rbp-0x30], rax ; bsoffset = DISK_MAP[bsidx] - BLANK_SPACES[bsidx]
   mov rcx, __fsidx_up_to
   mov rdx, [rbp-0x18]
   mov rax, [rcx+rdx*8]
   mov [rbp-0x38], rax ; size_t fsidx = FSIDX_UP_TO[bsidx]
   mov rdx, [rbp-0x10] ; bwd_dmidx
   sar rdx, 1
   mov rcx, __file_offsets
   lea rcx, [rcx+rdx*8] ; &FILE_OFFSETS[bwd_dmidx / 2]
   mov rax, [rbp-0x38]
   add rax, [rbp-0x30] ; fsidx + bsoffset
   mov [rcx], rax ; FILE_OFFSETS[bwd_dmidx / 2] = fsidx + bsoffset
   mov rcx, __disk_map
   mov rdx, [rbp-0x10]
   mov rax, 0
   mov al, [rcx+rdx]
   mov [rbp-0x40], rax ; DISK_MAP[bwd_dmidx]
   mov rcx, __blank_spaces
   mov rdx, [rbp-0x18]
   mov al, [rbp-0x40]
   sub [rcx+rdx], al ; BLANK_SPACES[bsidx] -= DISK_MAP[bwd_dmidx]
__compact_loop_end:
   sub QWORD [rbp-0x10], 2
   jmp __compact_loop_start
__compact_after_loop:
   mov rsp, rbp
   pop rbp
   ret

calculate_checksum:
   push rbp
   mov rbp, rsp
   sub rsp, 0x30
   mov [rbp-0x8], rdi ; length / 2
   sar QWORD [rbp-0x8], 1
   mov QWORD [rbp-0x10], 0 ; checksum
   mov QWORD [rbp-0x18], 0 ; i

__calculate_checksum_loop_start:
   mov rcx, [rbp-0x8]
   mov rax, [rbp-0x18]
   cmp rax, rcx
   jg __calculate_checksum_after_loop
   mov rcx, __file_offsets
   mov rdx, [rbp-0x18]
   mov rax, [rcx+rdx*8]
   mov [rbp-0x20], rax ; FILE_OFFSETS[i]
   mov rcx, __disk_map
   mov rdx, [rbp-0x18]
   sal rdx, 1
   mov rax, 0
   mov al, [rcx+rdx] ; DISK_MAP[i*2]
   mov rdx, rax
   mov rsi, [rbp-0x20]
   mov rdi, [rbp-0x18]
   call digest
   add [rbp-0x10], rax ; cs += digest(i, FILE_OFFSETS[i], DISK_MAP[i*2])
   inc QWORD [rbp-0x18]
   jmp __calculate_checksum_loop_start
__calculate_checksum_after_loop:
   mov rax, [rbp-0x10]
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
   __fsidx_up_to: resb 0x28000 ; 0x5000 * 8
   __blank_spaces: resb 0x5000
   __file_offsets: resb 0x28000 ; 0x5000 * 8