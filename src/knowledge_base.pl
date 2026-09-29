%% knowledge_base.pl — 52 правила слоя 1 (P01–P52) и 8 правил слоя 2 (V01–V08)
:- module(knowledge_base, [
    rule/5,
    verdict_rule/3,
    rule_count/1,
    verdict_rule_count/1
]).

%% rule(Id, Group, Criticality, Conditions, Text)
%% Group: free | privilege | tariff | restriction | recommendation
%% Criticality: critical | major | minor

%% ---------- P01–P12: бесплатные случаи ----------
rule(p01, free, minor, [eq(day, sunday)],
     'В воскресенье парковка бесплатна.').
rule(p02, free, minor, [eq(holiday, yes)],
     'В праздничный день парковка бесплатна.').
rule(p03, free, minor, [lt(time_start, 8)],
     'До 8:00 парковка бесплатна.').
rule(p04, free, minor, [ge(time_start, 21)],
     'После 21:00 парковка бесплатна.').
rule(p05, free, minor, [eq(disabled, yes)],
     'Инвалидам парковка предоставляется бесплатно.').
rule(p06, free, minor, [eq(electric, yes)],
     'Электромобилям парковка предоставляется бесплатно.').
rule(p07, free, minor, [eq(category, motorcycle)],
     'Мотоциклам парковка предоставляется бесплатно.').
rule(p08, free, minor, [eq(resident, yes), same_zone],
     'Резидент в своей зоне паркуется бесплатно.').
rule(p09, free, minor, [eq(subscription, yes)],
     'Действующий абонемент даёт право бесплатной парковки.').
rule(p10, free, minor, [eq(special_zone, yes), eq(disabled, yes)],
     'Спецзона для инвалидов — бесплатно.').
rule(p11, free, minor, [eq(special_zone, yes), eq(electric, yes)],
     'Спецзона для электромобилей — бесплатно.').
rule(p12, free, minor, [eq(day, saturday), lt(time_start, 10)],
     'Утренние часы субботы (до 10:00) — бесплатно.').

%% ---------- P13–P22: льготы и скидки ----------
rule(p13, privilege, minor, [eq(resident, yes), neq_zone],
     'Резидент другой зоны: скидка 50%.').
rule(p14, privilege, minor, [eq(disabled, yes), eq(zone, c)],
     'Инвалид в зоне C: бесплатно.').
rule(p15, privilege, minor, [eq(electric, yes), eq(zone, d)],
     'Электромобиль в зоне D: бесплатно.').
rule(p16, privilege, minor, [eq(subscription, yes), eq(zone, d)],
     'Абонемент в зоне D: скидка 30%.').
rule(p17, privilege, minor, [eq(resident, yes)],
     'Резиденту доступен годовой тариф.').
rule(p18, privilege, minor, [eq(subscription, yes), gt(duration, 8)],
     'Абонемент + длительная стоянка: суточный тариф.').
rule(p19, privilege, minor, [eq(category, m2_m3)],
     'Транспорт категории M2/M3: коммерческий тариф.').
rule(p20, privilege, minor, [eq(category, n2_n3)],
     'Транспорт категории N2/N3: коммерческий тариф.').
rule(p21, privilege, minor, [eq(category, n1)],
     'Транспорт категории N1: коммерческий тариф.').
rule(p22, privilege, minor, [eq(payment_method, app)],
     'Оплата через приложение: скидка 5%.').

%% ---------- P23–P37: тарификация ----------
rule(p23, tariff, major, [eq(zone, a), paid_hours],
     'Зона A: 600 руб/час.').
rule(p24, tariff, major, [eq(zone, b), paid_hours],
     'Зона B: 450 руб/час.').
rule(p25, tariff, major, [eq(zone, c), paid_hours],
     'Зона C: 380 руб/час.').
rule(p26, tariff, major, [eq(zone, d), paid_hours],
     'Зона D: 200 руб/час.').
rule(p27, tariff, major, [eq(zone, a), eq(day, saturday), paid_hours],
     'Зона A, суббота: 600 руб/час.').
rule(p28, tariff, major, [eq(zone, b), eq(day, saturday), paid_hours],
     'Зона B, суббота: 450 руб/час.').
rule(p29, tariff, major, [eq(zone, c), eq(day, saturday), paid_hours],
     'Зона C, суббота: 380 руб/час.').
rule(p30, tariff, major, [eq(zone, d), eq(day, saturday), paid_hours],
     'Зона D, суббота: 200 руб/час.').
rule(p31, tariff, major, [eq(zone, a), gt(duration, 4)],
     'Зона A: длительная стоянка — применяется суточный тариф.').
rule(p32, tariff, major, [eq(zone, b), gt(duration, 4)],
     'Зона B: длительная стоянка — применяется суточный тариф.').
rule(p33, tariff, major, [eq(zone, c), gt(duration, 4)],
     'Зона C: длительная стоянка — применяется суточный тариф.').
rule(p34, tariff, major, [eq(zone, d), gt(duration, 4)],
     'Зона D: длительная стоянка — применяется суточный тариф.').
rule(p35, tariff, major, [ge(duration, 8)],
     'Стоянка 8 часов и более: применяется суточный тариф.').
rule(p36, tariff, major, [eq(zone, a), eq(resident, yes)],
     'Резидент зоны A: годовой тариф 3000 руб.').
rule(p37, tariff, major, [eq(zone, d), eq(payment_method, app)],
     'Зона D с оплатой в приложении: скидка 5%.').

%% ---------- P38–P45: ограничения и запреты ----------
rule(p38, restriction, critical, [eq(parking_ban, yes)],
     'В зоне действует запрет парковки.').
rule(p39, restriction, critical,
     [eq(special_zone, yes), eq(disabled, no), eq(electric, no)],
     'Спецзона без оснований: парковка запрещена.').
rule(p40, restriction, critical,
     [eq(special_zone, yes), eq(category, n2_n3)],
     'Спецзона закрыта для грузового транспорта N2/N3.').
rule(p41, restriction, major, [eq(debt, yes)],
     'Есть задолженность по парковке: возможно блокирование.').
rule(p42, restriction, major, [eq(parking_ban, yes), eq(debt, yes)],
     'Запрет парковки и задолженность: риск эвакуации.').
rule(p43, restriction, major,
     [eq(special_zone, yes), eq(category, motorcycle)],
     'Мотоцикл в спецзоне для инвалидов: ограничение.').
rule(p44, restriction, major,
     [eq(special_zone, yes), eq(electric, no)],
     'Спецзона для электромобилей: ваше ТС не подходит.').
rule(p45, restriction, minor,
     [eq(parking_ban, yes), lt(time_start, 8)],
     'Запрет парковки действует и в нерабочие часы.').

%% ---------- P46–P52: рекомендации ----------
rule(p46, recommendation, minor, [eq(debt, yes)],
     'Рекомендуется погасить задолженность до парковки.').
rule(p47, recommendation, minor, [eq(payment_method, none)],
     'Выберите способ оплаты: cash / card / app.').
rule(p48, recommendation, minor,
     [eq(resident, yes), eq(resident_zone, none)],
     'Уточните зону резидентного разрешения.').
rule(p49, recommendation, minor,
     [eq(subscription, yes), eq(resident, yes)],
     'Определитесь: абонемент или резидентное разрешение.').
rule(p50, recommendation, minor,
     [eq(parking_ban, yes), ge(time_start, 21)],
     'Запрет парковки: переместите ТС на другую зону.').
rule(p51, recommendation, minor, [gt(duration, 24)],
     'Парковка более суток: проверьте тариф выходного дня.').
rule(p52, recommendation, minor,
     [eq(category, motorcycle), eq(special_zone, yes)],
     'Используйте мотоциклетную спецзону.').

rule_count(52).

%% ---------- Слой 2: V01–V08 ----------
%% verdict_rule(Id, Ключ, Текст)
verdict_rule(v01, has_critical,
    'Критическое ограничение: парковка запрещена.').
verdict_rule(v02, has_major,
    'Действует тариф: парковка платная.').
verdict_rule(v03, has_minor_only,
    'Льготные условия: парковка бесплатная.').
verdict_rule(v04, no_findings,
    'Нарушений не выявлено: парковка бесплатная.').
verdict_rule(v05, paid_status,
    'Парковка платная: оплатите согласно тарифу.').
verdict_rule(v06, free_status,
    'Парковка бесплатная.').
verdict_rule(v07, incomplete,
    'Данных недостаточно: заключение не формируется.').
verdict_rule(v08, contradictory,
    'Противоречие входных данных: заключение не формируется.').

verdict_rule(v09, has_tariff, 'Действует тариф: парковка платная.').
verdict_rule_count(9).