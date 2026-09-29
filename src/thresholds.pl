%% thresholds.pl — пороговые значения и тарифы
%% Источник: Правила пользования платными парковками в Москве
%% (постановление Правительства Москвы), тарифы зон A–D на 2026 год.
:- module(thresholds, [
    rate/2,
    paid_hour_range/2,
    daily_cap/2,
    resident_year/2,
    subscription_discount/2,
    app_discount/1
]).

%% Тарифы зон (руб/час)
rate(a, 600).
rate(b, 450).
rate(c, 380).
rate(d, 200).

%% Диапазон платных часов (включительно слева, исключительно справа)
paid_hour_range(8, 21).

%% Максимальная суточная стоимость парковки по зоне (руб)
daily_cap(a, 4000).
daily_cap(b, 3000).
daily_cap(c, 2500).
daily_cap(d, 1500).

%% Стоимость резидентного разрешения на год (руб)
resident_year(a, 3000).
resident_year(b, 2000).
resident_year(c, 1500).
resident_year(d, 1000).

%% Скидки по абонементу (%)
subscription_discount(week, 10).
subscription_discount(month, 20).
subscription_discount(year, 50).

%% Скидка за оплату через приложение (%)
app_discount(5).