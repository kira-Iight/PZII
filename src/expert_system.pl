%% expert_system.pl — диалог с пользователем и печать отчёта
:- module(expert_system, [start/0]).

:- set_prolog_flag(encoding, utf8).

:- use_module(library(readutil)).
:- use_module(library(lists)).
:- use_module(domain).
:- use_module(inference).
:- use_module(consistency).
:- use_module(knowledge_base).

start :-
    format('~n=== Экспертная система обслуживания платной парковки ===~n'),
    format('Результат носит справочный характер и не заменяет правила оператора парковки.~n~n'),
    run_session.

run_session :-
    ( collect_all_answers(Store) ->
        ( find_contradictions(Store, Conflicts),
          Conflicts \= [] ->
              print_contradictions(Conflicts)
        ; Store = [] ->
              format('~nВвод не был выполнен.~n')
        ; process_store(Store) )
    ; format('~nВвод завершён пользователем (Ctrl-D).~n')
    ),
    ask_again.

process_store(Store) :-
    infer(Store, Findings, VerdictInfo),
    print_report(Store, Findings, VerdictInfo).

%% ---------- Сбор ответов ----------
collect_all_answers(Store) :-
    all_features(Keys),
    collect(Keys, [], Store),
    Store \= [].

collect([], Acc, Acc).
collect([K|Ks], Acc, Store) :-
    ( ask_feature(K, V) ->
        collect(Ks, [K-V|Acc], Store)
    ; Store = []
    ).

ask_feature(K, V) :-
    describe(K, Desc),
    hint_for(K, Hint),
    ( is_mandatory(K) -> Tag = 'обязательный' ; Tag = 'необязательный' ),
    format('~w [~w]. Подсказка: ~w~n> ', [Desc, Tag, Hint]),
    flush_output,
    ( read_line_to_string(user_input, Line) ->
        ( Line == end_of_file ->
            fail
        ; Line == "" ->
            format('  Это обязательный признак, повторите ввод.~n'),
            ask_feature(K, V)
        ; atom_string(Raw, Line),
          downcase_atom(Raw, RLow),
          ( RLow == unknown, \+ is_mandatory(K) ->
              V = unknown
          ; parse_value(K, Raw, V) -> true
          ; format('  Недопустимое значение: ~w. Повторите.~n', [Raw]),
            ask_feature(K, V)
          )
        )
    ; fail
    ).

%% ---------- Печать отчёта ----------
print_report(Store, Findings, verdict(_, _, Conclusion, Action, VText)) :-
    format('~n~n===== РЕЗУЛЬТАТ ОБСЛУЖИВАНИЯ ПАРКОВКИ =====~n'),
    format('Заключение: ~w~n', [Conclusion]),
    format('Рекомендуемое действие: ~w~n', [Action]),
    format('Правило заключения: ~w~n~n', [VText]),
    ( Findings == [] ->
        format('Несоответствий не выявлено.~n')
    ;
        format('Выявленные несоответствия:~n'),
        forall(member(finding(Id, Group, Crit, Text), Findings),
               print_finding(Id, Group, Crit, Text, Store))
    ),
    print_explanation(Findings, VText),
    format('~nОговорка: результат носит справочный характер и не заменяет~n'),
    format('официальные правила оператора платной парковки.~n').

print_finding(Id, Group, Crit, Text, _Store) :-
    format('  ~w [~w, ~w]: ~w~n', [Id, Group, Crit, Text]).

print_explanation(Findings, VText) :-
    findall(Id, member(finding(Id,_,_,_), Findings), Ids),
    ( Ids == [] -> IdsStr = 'нет'
    ; atomic_list_concat(Ids, ', ', IdsStr) ),
    format('~nОбъяснение вывода:~n'),
    format('  Правила слоя 1: ~w~n', [IdsStr]),
    format('  Правило слоя 2: ~w~n', [VText]).

print_contradictions(Conflicts) :-
    format('~n~n===== ОБНАРУЖЕНЫ ПРОТИВОРЕЧИЯ =====~n'),
    forall(member(C, Conflicts), format('  - ~w~n', [C])),
    format('Правила не применяются, заключение не формируется.~n').

ask_again :-
    format('~nНачать новый осмотр? (да/нет) > '),
    flush_output,
    ( read_line_to_string(user_input, Line) ->
        ( Line == end_of_file -> format('~nРабота завершена.~n')
        ; atom_string(A, Line), downcase_atom(A, L),
          ( L == да ; L == yes ; L == y -> run_session
          ; format('Работа завершена.~n') )
        )
    ; format('~nРабота завершена.~n')
    ).

%% Для запуска без диалога (программный вызов)
:- initialization(main, main).

main :-
    current_prolog_flag(argv, Argv),
    ( Argv == [] -> true
    ; Argv == ['--no-start'] -> true
    ; start
    ).
