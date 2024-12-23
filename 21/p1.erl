-module(p1).
-export([main/1]).

main(Fp) ->
    Codes = readlines(Fp),
    SeqAndNums = [{line_to_sequence(Line), line_to_numeric(Line)} || Line <- Codes],
    io:fwrite("~w\n", [sum_complexity(SeqAndNums, 0)]).

% show_complexity([]) -> ok;

% show_complexity([{Sequence, Numeric}|Rest]) ->
%     io:fwrite("~w\n", [sum_human_inputs(Sequence) * Numeric]),
%     show_complexity(Rest).

sum_complexity([], Sum) -> Sum;

sum_complexity([{Sequence, Numeric}|Rest], Sum) ->
    sum_complexity(Rest, Sum + (sum_human_inputs(Sequence) * Numeric)).

% https://stackoverflow.com/questions/2475270/how-to-read-the-contents-of-a-file-in-erlang
readlines(Fp) ->
    {ok, Device} = file:open(Fp, [read]),
    try get_all_lines(Device, [])
        after file:close(Device)
    end.

get_all_lines(Device, Lines) ->
    case io:get_line(Device, "") of
        eof -> Lines;
        Line -> get_all_lines(Device, Lines ++ [string:trim(Line)])
    end.

line_to_sequence(Line) -> line_to_sequence(Line, []).

line_to_sequence(Line, Sequence) ->
    case Line of
        [] -> Sequence;
        [C|Rest] ->
            line_to_sequence(Rest, Sequence ++ [codepoint_to_button(C)])
    end.

line_to_numeric(Line) -> list_to_integer(string:slice(Line, 0, 3)).

codepoint_to_button(C) ->
    if
        ((C >= 48) and (C =< 57)) -> (C - 48);
        true -> activate
    end.

sum_human_inputs(Sequence) -> sum_human_inputs(Sequence, activate, 0).

sum_human_inputs(Sequence, Previous, Sum) ->
    case Sequence of
        [] -> Sum;
        [Next|Rest] -> sum_human_inputs(
            Rest,
            Next,
            Sum + get_sequence_length(0, 3, Previous, Next)
        )
    end.

vec_sum({Ax, Ay}, {Bx, By}) ->
    {Ax + Bx, Ay + By}.

dpad_button_coords(Direction) ->
    case Direction of
        up -> {1, 0};
        down -> {1, 1};
        left -> {0, 1};
        right -> {2, 1};
        activate -> {2, 0}
    end.

get_dir_change(Direction) ->
    case Direction of
        up -> {0, -1};
        down -> {0, 1};
        left -> {-1, 0};
        right -> {1, 0};
        _ -> {0, 0}
    end.

numpad_button_coords(Number) ->
    case Number of
        0 -> {1, 3};
        1 -> {0, 2};
        2 -> {1, 2};
        3 -> {2, 2};
        4 -> {0, 1};
        5 -> {1, 1};
        6 -> {2, 1};
        7 -> {0, 0};
        8 -> {1, 0};
        9 -> {2, 0};
        activate -> {2, 3}
    end.

% button_to_string(Button) ->
%     if
%         is_atom(Button) -> atom_to_list(Button);
%         true -> integer_to_list(Button)
%     end.

valid_dpad_pos({X, Y}) ->
    (((X >= 0) and (X =< 2)) and ((Y >= 0) and (Y =< 1)) and ({X, Y} =/= {0, 0})).

valid_numpad_pos({X, Y}) ->
    (((X >= 0) and (X =< 2)) and ((Y >= 0) and (Y =< 3)) and ({X, Y} =/= {0, 3})).

get_possible_sequences_between({HorizontalDifference, VerticalDifference}) ->
    HorizontalSeq = if
        HorizontalDifference > 0 -> lists:duplicate(abs(HorizontalDifference), right);
        HorizontalDifference < 0 -> lists:duplicate(abs(HorizontalDifference), left);
        true -> []
    end,
    VerticalSeq = if
        VerticalDifference > 0 -> lists:duplicate(abs(VerticalDifference), down);
        VerticalDifference < 0 -> lists:duplicate(abs(VerticalDifference), up);
        true -> []
    end,
    % Try not to alternate between horizontal and vertical movements
    % as the robots needs to align itself which wastes time
    {HorizontalSeq ++ VerticalSeq ++ [activate], VerticalSeq ++ HorizontalSeq ++ [activate]}.

% Src, Diff
vector_diff({Ax, Ay}, {Bx, By}) ->
    {Bx - Ax, By - Ay}.

get_sequence_length(Layer, Depth, Src, Dest) ->
    {SrcPos, DestPos} = if
        Layer == 0 -> {numpad_button_coords(Src), numpad_button_coords(Dest)};
        true -> {dpad_button_coords(Src), dpad_button_coords(Dest)}
    end,
    Vector = vector_diff(SrcPos, DestPos),
    if
        Layer >= (Depth - 1) -> get_sequence_length_top_level(Vector);
        true -> get_sequence_length_lower_level(Layer, Depth, SrcPos, Vector)
    end.

get_sequence_length_top_level({Dx, Dy}) ->
    % io:fwrite("Highest {~w, ~w}\n", [Dx, Dy]),
    abs(Dx) + abs(Dy) + 1.

get_sequence_length_lower_level(Layer, Depth, SrcPos, Vector) ->
    {Hv, Vh} = get_possible_sequences_between(Vector),
    if
        length(Hv) == 0 -> 1;
        true ->
            HvSteps = try
                get_steps_at_higher_level(Hv, Layer + 1, Depth, SrcPos, activate, 0)
            catch
                bad_sequence -> bad_sequence
            end,
            VhSteps = try
                get_steps_at_higher_level(Vh, Layer + 1, Depth, SrcPos, activate, 0)
            catch
                bad_sequence -> bad_sequence
            end,
            Best = if
                ((HvSteps == bad_sequence) and (VhSteps == bad_sequence)) -> bad_sequence;
                HvSteps == bad_sequence -> VhSteps;
                VhSteps == bad_sequence -> HvSteps;
                true -> min(HvSteps, VhSteps)
            end,
            Best
    end.

get_steps_at_higher_level(Sequence, Layer, Depth, CurrentPos, PreviousStep, Steps) ->
    ValidPos = if
        Layer == 1 -> valid_numpad_pos(CurrentPos);
        true -> valid_dpad_pos(CurrentPos)
    end,
    if
        ValidPos ->
            case Sequence of
                [] -> Steps;
                [NextStep|Remaining] ->
                    get_steps_at_higher_level(
                        Remaining,
                        Layer,
                        Depth,
                        vec_sum(CurrentPos, get_dir_change(NextStep)),
                        NextStep,
                        Steps + get_sequence_length(Layer, Depth, PreviousStep, NextStep)
                    )
            end;
        true -> throw(bad_sequence)
    end.
    