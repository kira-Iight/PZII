%% domain.pl — описание признаков предметной области и их допустимых значений
:- module(domain, [
    feature/3,
    all_features/1,
    describe/2,
    valid_value/2,
    parse_value/3,
    is_mandatory/1,
    hint_for/2,
    optional_features/1
]).

%% feature(Ключ, РусскаяПодпись, Спецификация)
%% Спецификация: список допустимых атомов ИЛИ int(Мин, Макс)
feature(day,             'День недели', [monday,tuesday,wednesday,thursday,friday,saturday,sunday]).
feature(time_start,      'Время начала парковки (час 0-23)', int(0,23)).
feature(duration,        'Продолжительность парковки (часы 1-24)', int(1,24)).
feature(zone,            'Зона парковки (a/b/c/d)', [a,b,c,d]).
feature(holiday,         'Праздничный день?', [yes,no]).
feature(category,        'Категория ТС', [m1,m2_m3,n1,n2_n3,motorcycle]).
feature(electric,        'Электромобиль?', [yes,no]).
feature(resident,        'Резидентное разрешение?', [yes,no]).
feature(resident_zone,   'Зона резидентного разрешения (a/b/c/d/none)', [a,b,c,d,none]).
feature(disabled,        'Знак "Инвалид"?', [yes,no]).
feature(subscription,    'Действующий абонемент?', [yes,no]).
feature(payment_method,  'Способ оплаты', [cash,card,app,none]).
feature(debt,            'Задолженность по парковке?', [yes,no]).
feature(parking_ban,     'Запрет парковки в этой зоне?', [yes,no]).
feature(special_zone,    'Спецзона (инвалиды/электромобили)?', [yes,no]).

all_features(L) :- findall(K, feature(K,_,_), L).
describe(K, D)  :- feature(K, D, _).

%% Обязательные признаки
is_mandatory(day).
is_mandatory(time_start).
is_mandatory(duration).
is_mandatory(zone).
is_mandatory(holiday).
is_mandatory(category).

optional_features([resident, resident_zone, electric, disabled,
                   subscription, payment_method, debt,
                   parking_ban, special_zone]).

%% valid_value(Ключ, Значение)
valid_value(K, V) :- feature(K, _, Spec), ok(Spec, V).
ok(L, V)      :- is_list(L), member(V, L).
ok(int(L,H), V) :- integer(V), V >= L, V =< H.

%% parse_value(Ключ, ВводАтом, Результат)
parse_value(K, Raw, V) :- feature(K, _, Spec), parse_one(Spec, Raw, V).

parse_one(L, Raw, V) :-
    is_list(L),
    atom_string(RS, Raw), downcase_atom(RS, RL),
    member(V, L), atom_string(VS, V), downcase_atom(VS, VL),
    VL == RL.

parse_one(int(L,H), Raw, V) :-
    catch(atom_number(Raw, V), _, fail),
    integer(V), V >= L, V =< H.

%% Подсказка для вопроса
hint_for(K, H) :- feature(K, _, Spec), hint_one(Spec, H).
hint_one(L, H) :- is_list(L), atomic_list_concat(L, ' / ', H).
hint_one(int(A,B), H) :- format(atom(H), 'целое от ~w до ~w', [A,B]).