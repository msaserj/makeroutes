#!/bin/bash

# Имя файла с исходными доменами
domains_file="domains"

# Имя файла для записи маршрутов
routes_file="routes.bat"

# Проверка существования файла с доменами
if [ ! -f "$domains_file" ]; then
    echo "Файл с доменами '$domains_file' не найден."
    exit 1
fi

# Очистка файла с маршрутами (если существует)
> "$routes_file"

# Цикл по каждой строке в файле с доменами
while IFS= read -r domain || [[ -n "$domain" ]]; do

	# Пропуск пустых строк
    if [[ -z "$domain" ]]; then
        continue
    fi

    # Получение только IP-адресов без всяких cdn
    ip_addresses=$(dig +short "$domain" | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}')
    echo "$domain" $ip_addresses

    # Бывает communications error, поэтому переделываем
    if [[ $ip_addresses == *"communications error"* ]]; then
        echo "############"
        echo "communications error! for domain $domain"
        echo "############"
        sleep 2
        echo "REPEAT :-)"
        sleep 2
        ip_addresses=$(dig +short "$domain" | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}')
        echo "$domain" $ip_addresses
    fi

    # Цикл по каждому IP-адресу
    while IFS= read -r ip_address || [[ -n "$ip_address" ]]; do
        # Запись статического маршрута в файл
        echo "route ADD $ip_address MASK 255.255.255.255 0.0.0.0" >> "$routes_file"
    done <<< "$ip_addresses"
done < "$domains_file"