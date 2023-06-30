#!/bin/bash

# Имя файла с исходными доменами
# создайте если его нет, в нём укажите доменные имена на каждой строчке
domains_file="domains"
# временные файлы
tmp_bat="temp.bat"
tmp_cli="temp.cli"

# Имя файла для записи маршрутов через web-интерфейс роутера и cli командной строки скриптом expect.sh
routes_bat="temp.bat"
routes_cli="temp.cli"

# Проверка существования файла с доменами
if [ ! -f "$domains_file" ]; then
    echo "Файл с доменами '$domains_file' не найден."
    exit 1
fi

# Очистка файлов с маршрутами (если существует)
> "$routes_bat"
> "$routes_cli"

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
        sleep 1
        echo "REPEAT :-)"
        sleep 1
        ip_addresses=$(dig +short "$domain" | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}')
        echo "$domain" $ip_addresses
    fi

    # Цикл по каждому IP-адресу
    while IFS= read -r ip_address || [[ -n "$ip_address" ]]; do
        # Запись статического маршрута в файл
        # ip route 199.199.199.2 255.255.255.255 0.0.0.0 Wireguard0 auto
        echo "route ADD $ip_address MASK 255.255.255.255 0.0.0.0" >> "$tmp_bat"
        echo "ip route $ip_address 255.255.255.255 0.0.0.0 Wireguard0 auto !script_address" >> "$tmp_cli"
    done <<< "$ip_addresses"
done < "$domains_file"

echo "############"
echo "DEL DUPLICATES"
echo "############"
sleep 1

sort "$tmp_bat" | uniq > "routes.bat"
sort "$tmp_cli" | uniq > "routes.cli"

rm temp.cli
rm temp.bat

echo "#### OK! ####"
sleep 2