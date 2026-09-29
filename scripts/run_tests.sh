#!/usr/bin/env bash
# Запуск автоматических тестов
set -e
cd "$(dirname "$0")/.."
swipl -q -g "consult('tests/test_basic.pl'), run_tests, halt" -t halt
echo "Все тесты завершены."