:- ensure_loaded('golog2_32.pl').

test:-
    new_frame(name),
    new_slot(name,lol,2),
    show_frame(name).