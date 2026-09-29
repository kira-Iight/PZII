%% test_basic.pl — базовые автоматические проверки
:- module(test_basic, []).
:- use_module(library(plunit)).
:- use_module('../src/domain').
:- use_module('../src/inference').
:- use_module('../src/consistency').
:- use_module('../src/knowledge_base').

:- begin_tests(domain).

test(feature_count) :-
    all_features(L), length(L, N), N >= 15.

test(parse_sunday, [true(V == sunday)]) :-
    parse_value(day, "sunday", V).

test(parse_zone_a, [true(V == a)]) :-
    parse_value(zone, "A", V).

test(parse_int, [true(V == 10)]) :-
    parse_value(time_start, "10", V).

test(reject_bad_value, [fail]) :-
    parse_value(zone, "z", _).

:- end_tests(domain).

:- begin_tests(rules).

test(rule_count_ok) :-
    rule_count(N), N >= 50.

test(verdict_rule_count_ok) :-
    verdict_rule_count(N), N >= 5.

:- end_tests(rules).

:- begin_tests(inference).

test(free_sunday) :-
    Store = [day-sunday, time_start-12, duration-2, zone-a, holiday-no,
             category-m1, resident-no, resident_zone-none, electric-no,
             disabled-no, subscription-no, payment_method-app,
             debt-no, parking_ban-no, special_zone-no],
    infer(Store, _Fs, verdict(_, _, Conclusion, _, _)),
    Conclusion == 'бесплатно'.

test(paid_zone_a) :-
    Store = [day-monday, time_start-10, duration-2, zone-a, holiday-no,
             category-m1, resident-no, resident_zone-none, electric-no,
             disabled-no, subscription-no, payment_method-app,
             debt-no, parking_ban-no, special_zone-no],
    infer(Store, Findings, _Verdict),
    member(finding(p23, tariff, _, _), Findings).

test(ban_critical) :-
    Store = [day-monday, time_start-10, duration-2, zone-a, holiday-no,
             category-m1, resident-no, resident_zone-none, electric-no,
             disabled-no, subscription-no, payment_method-app,
             debt-no, parking_ban-yes, special_zone-no],
    infer(Store, _Fs, verdict(_, _, Conclusion, _, _)),
    Conclusion == 'парковка запрещена'.

:- end_tests(inference).

:- begin_tests(consistency).

test(no_conflict_clean) :-
    Store = [resident-no, resident_zone-none, subscription-no,
             electric-no, disabled-no, special_zone-no,
             payment_method-app, debt-no, parking_ban-no],
    find_contradictions(Store, C), C == [].

test(conflict_resident_zone) :-
    Store = [resident-yes, resident_zone-none],
    find_contradictions(Store, C), C \= [].

:- end_tests(consistency).