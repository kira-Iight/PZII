# Экспертная система обслуживания платной парковки

Учебная экспертная система на SWI-Prolog. По ответам пользователя
определяет статус парковки (бесплатно / платно / запрещено), стоимость,
рекомендуемое действие и объясняет вывод.

## Запуск

Запуск на Windows:
  chcp.com 65001
  swipl -q -Dencoding=utf8 -s run.pl

Запуск на Linux/macOS:
  swipl -q -s src/expert_system.pl -g start -t halt

```bash
swipl -q -s src/expert_system.pl -g start -t halt
```

## Тесты

```bash
scripts/run_tests.sh
```

## Структура

- `src/domain.pl` — признаки и их допустимые значения
- `src/thresholds.pl` — тарифы и пороги
- `src/consistency.pl` — проверка противоречий
- `src/knowledge_base.pl` — 52 правила слоя 1 и 8 правил слоя 2
- `src/inference.pl` — механизм вывода
- `src/expert_system.pl` — диалог и отчёт