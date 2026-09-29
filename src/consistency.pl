%% consistency.pl — проверка входных данных на взаимно исключающие ответы
:- module(consistency, [find_contradictions/2]).

%% find_contradictions(+Store, -Conflicts)
find_contradictions(Store, Conflicts) :-
    findall(Msg, contradiction(Store, Msg), L),
    sort(L, Conflicts).

contradiction(S, 'Резидентное разрешение указано, но зона не выбрана') :-
    memberchk(resident-yes, S),
    memberchk(resident_zone-none, S).

contradiction(S, 'Спецзона отмечена, но нет оснований (инвалид/электромобиль)') :-
    memberchk(special_zone-yes, S),
    memberchk(disabled-no, S),
    memberchk(electric-no, S),
    ( \+ memberchk(category-motorcycle, S) ).

contradiction(S, 'Абонемент и резидентное разрешение указаны одновременно') :-
    memberchk(subscription-yes, S),
    memberchk(resident-yes, S).

contradiction(S, 'Есть задолженность, но способ оплаты не указан') :-
    memberchk(debt-yes, S),
    memberchk(payment_method-none, S).

contradiction(S, 'Запрет парковки и спецзона указаны одновременно') :-
    memberchk(parking_ban-yes, S),
    memberchk(special_zone-yes, S).     