:- set_prolog_flag(encoding, utf8).
:- current_prolog_flag(encoding, Enc),
   ( Enc == utf8 -> true
   ; format(user_error, "WARNING: encoding is ~w, not utf8~n", [Enc]) ).
:- consult('src/expert_system.pl').
:- start.
:- halt.
