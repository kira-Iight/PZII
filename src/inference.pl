%% inference.pl — механизм логического вывода
:- module(inference, [
    infer/3,
    apply_layer1/2,
    build_state/2,
    apply_layer2/2,
    answer/3,
    check_cond/2
]).

:- use_module(knowledge_base).
:- use_module(consistency).
:- use_module(thresholds).
:- use_module(domain).
:- use_module(library(lists)).

%% answer(Store, Key, Value)
answer(Store, K, V) :- memberchk(K-V, Store).

%% ---------- Проверка условий правил ----------
check_cond(eq(F, V), S)   :- memberchk(F-V, S).
check_cond(neq(F, V), S)  :- memberchk(F-V0, S), V0 \= V.
check_cond(gt(F, N), S)   :- memberchk(F-V, S), number(V), V > N.
check_cond(ge(F, N), S)   :- memberchk(F-V, S), number(V), V >= N.
check_cond(lt(F, N), S)   :- memberchk(F-V, S), number(V), V < N.
check_cond(le(F, N), S)   :- memberchk(F-V, S), number(V), V =< N.
check_cond(paid_hours, S) :-
    memberchk(time_start-T, S), T >= 8, T < 21.
check_cond(same_zone, S) :-
    memberchk(resident_zone-Z, S), Z \= none,
    memberchk(zone-Z, S).
check_cond(neq_zone, S) :-
    memberchk(resident_zone-Z, S), Z \= none,
    memberchk(zone-Z0, S), Z \= Z0.

all_conds([], _).
all_conds([C|Cs], S) :- check_cond(C, S), all_conds(Cs, S).

%% ---------- Слой 1: сбор находок ----------
apply_layer1(Store, Findings) :-
    findall(finding(Id, Group, Crit, Text),
            ( rule(Id, Group, Crit, Conds, Text),
              all_conds(Conds, Store) ),
            Findings).

%% ---------- Формирование состояния осмотра ----------
build_state(Findings, State) :-
    ( member(finding(_,_,critical,_), Findings) -> Crit = true ; Crit = false ),
    ( member(finding(_,_,major,_),    Findings) -> Maj  = true ; Maj  = false ),
    ( member(finding(_,_,minor,_),    Findings) -> Min  = true ; Min  = false ),
    ( member(finding(_,free,_,_),     Findings) -> Free = true ; Free = false ),
    ( member(finding(_,tariff,_,_),   Findings) -> Tar  = true ; Tar  = false ),
    State = [critical-Crit, major-Maj, minor-Min, free-Free, tariff-Tar].
%% ---------- Слой 2: заключение ----------
apply_layer2(State, VerdictInfo) :-
    memberchk(critical-true, State), !,
    verdict_rule(Id, has_critical, Text),
    VerdictInfo = verdict(Id, banned, 'парковка запрещена',
                          'обратиться в поддержку', Text).
apply_layer2(State, VerdictInfo) :-
    memberchk(free-true, State), !,
    verdict_rule(Id, has_minor_only, Text),
    VerdictInfo = verdict(Id, free, 'бесплатно',
                          'оплата не требуется', Text).
apply_layer2(State, VerdictInfo) :-
    memberchk(tariff-true, State), !,
    verdict_rule(Id, has_tariff, Text),
    VerdictInfo = verdict(Id, paid, 'платно',
                          'оплатить парковку', Text).
apply_layer2(State, VerdictInfo) :-
    memberchk(major-true, State), !,
    verdict_rule(Id, has_major, Text),
    VerdictInfo = verdict(Id, paid, 'платно',
                          'оплатить парковку', Text).
apply_layer2(_, VerdictInfo) :-
    verdict_rule(Id, no_findings, Text),
    VerdictInfo = verdict(Id, free, 'бесплатно',
                          'оплата не требуется', Text).

%% ---------- Главная функция вывода ----------
%% infer(+Store, -Findings, -VerdictInfo)
infer(Store, Findings, VerdictInfo) :-
    apply_layer1(Store, Findings),
    build_state(Findings, State),
    apply_layer2(State, VerdictInfo).