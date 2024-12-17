module my_mod
contains
    function get_line_len(line) result(length)
        character(len=256), intent (in) :: line
        integer :: length, x

        length = 0
        do x = 1, 256
            if (line(x:x) == ' ') exit ! for some reason the implicit character is a space???
        end do
        length = x - 1
    end function get_line_len

    function cascade(topo_map, map_len) result(sum)
        integer, intent (in) :: topo_map(:,:)
        integer, intent (in) :: map_len
        integer :: x, y, i, height, score, q_start, q_end, sum
        complex, allocatable :: my_queue(:)
        integer, allocatable :: score_map(:,:)

        allocate(score_map(map_len, map_len))
        allocate(my_queue(map_len*map_len))
        q_start = 1
        q_end = 1

        do y = 1, map_len
            do x = 1, map_len
                if (topo_map(x, y) == 0) then
                    score_map(x, y) = 1
                    my_queue(q_end) = complex(x, y)
                    q_end = q_end + 1
                else
                    score_map(x, y) = 0
                end if
            end do
        end do

        sum = 0
        do while ((q_end - q_start) > 0)
            x = my_queue(q_start)%re
            y = my_queue(q_start)%im
            height = topo_map(x, y)
            score = score_map(x, y)
            !print *, x, y, height, my_queue!(q_start:q_end-1)
            ! my_queue = [my_queue(2:)]
            q_start = q_start + 1
            if (height == 9) then
                sum = sum + score
                cycle
            end if
            height = height + 1

            ! top
            if ((y >= 2) .and. (topo_map(x, y-1) == height)) then
                score_map(x, y-1) = score_map(x, y-1) + score
                if (.not.(any(my_queue(q_start:q_end-1) == complex(x, y-1)))) then
                    my_queue(q_end) = complex(x, y-1)
                    q_end = q_end + 1
                end if
            end if
            ! left
            if ((x >= 2) .and. (topo_map(x-1, y) == height)) then
                score_map(x-1, y) = score_map(x-1, y) + score
                if (.not.(any(my_queue(q_start:q_end-1) == complex(x-1, y)))) then
                    my_queue(q_end) = complex(x-1, y)
                    q_end = q_end + 1
                end if
            end if
            ! bottom
            if ((y <= (map_len-1)) .and. (topo_map(x, y+1) == height)) then
                score_map(x, y+1) = score_map(x, y+1) + score
                if (.not.(any(my_queue(q_start:q_end-1) == complex(x, y+1)))) then
                    my_queue(q_end) = complex(x, y+1)
                    q_end = q_end + 1
                end if
            end if
            ! right
            if ((x <= (map_len-1)) .and. (topo_map(x+1, y) == height)) then
                score_map(x+1, y) = score_map(x+1, y) + score
                if (.not.(any(my_queue(q_start:q_end-1) == complex(x+1, y)))) then
                    my_queue(q_end) = complex(x+1, y)
                    q_end = q_end + 1
                end if
            end if
        end do
        !print *, score
    end function cascade
end module

program p1
    use my_mod
    integer :: argc, status, map_len, x, y, sum
    character :: c
    character(len=256) :: fp, line
    integer, allocatable :: topo_map(:,:)

    argc = command_argument_count()
    if (argc < 1) then
        print *, "No file included!"
        stop 1
    end if
    call get_command_argument(1, fp)
    !print *, fp

    map_len = 0
    y = 1
    open(1, file=fp, action="read", iostat=status)
    do
        read(1, *, iostat=status) line
        if (map_len == 0) then ! allocate array
            map_len = get_line_len(line)
            ! print *, map_len
            allocate(topo_map(map_len, map_len))
        end if
        if (status /= 0) then
            exit
        end if
        do x = 1, map_len
            c = line(x:x)
            topo_map(x, y) = (ichar(c) - 48) ! subtract ascii code for '0'
        end do
        y = y + 1
    end do
    ! print *, map_len
    ! print *, topo_map
    close(1)

    sum = cascade(topo_map, map_len)
    print *, sum
end program p1