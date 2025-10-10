#!/bin/bash
# запуск: ./linux.sh <year> <folder_name_1> [<folder_name_2> ... <folder_name_n>]

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' 

if [ "$#" -lt 2 ]; then
    echo -e "${YELLOW}Usage:${NC} $0 <year> <folder_name_1> [<folder_name_2> ...]"
    exit 1
fi

YEAR="$1"
NEW_REPO_URL=git@github-work:Dmitriy-d900/test-nova-black.git
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
SOURCE_DIR="$SCRIPT_DIR/../websites"
DEST_DIR="$SCRIPT_DIR/$YEAR"

echo -e "${CYAN}=== Старт скрипта ===${NC}"

cd "$SOURCE_DIR" || { echo -e "${RED}Ошибка: не удалось перейти в $SOURCE_DIR${NC}"; exit 1; }

if [ ! -d "$YEAR" ]; then
    echo -e "${RED}Папка $YEAR не найдена!${NC}"
    exit 1
fi

mkdir -p "$DEST_DIR"

PUSHED_BRANCHES=()
FAILED_BRANCHES=()
SKIPPED_FOLDERS=()

for TEAM_FOLDER in "${@:2}"; do
    echo -e "\n${CYAN}--- Обработка папки: ${TEAM_FOLDER} ---${NC}"

    if [ ! -d "$YEAR/$TEAM_FOLDER" ]; then
        echo -e "${RED}Папка $YEAR/$TEAM_FOLDER не найдена, пропуск...${NC}"
        SKIPPED_FOLDERS+=("$TEAM_FOLDER")
        continue
    fi

    cp -r "$YEAR/$TEAM_FOLDER" "$DEST_DIR/" || { echo -e "${RED}Ошибка копирования $TEAM_FOLDER${NC}"; continue; }

    cd "$DEST_DIR/$TEAM_FOLDER" || { echo -e "${RED}Не удалось перейти в $DEST_DIR/$TEAM_FOLDER${NC}"; exit 1; }

    echo -e "${YELLOW}1. Обновляем пути в файлах...${NC}"
    find . -type f -exec sed -i -E 's|/websites/[0-9]+/[^/]+/|./|g' {} +

    echo -e "${YELLOW}2. Инициализация Git...${NC}"
    git init > /dev/null
    git remote add origin "$NEW_REPO_URL"

    git lfs install > /dev/null
    git lfs track "*.jpg" "*.png" "*.webp" "*.svg" > /dev/null
    echo "*.jpg filter=lfs diff=lfs merge=lfs -text" >> .gitattributes
    echo "*.png filter=lfs diff=lfs merge=lfs -text" >> .gitattributes
    echo "*.webp filter=lfs diff=lfs merge=lfs -text" >> .gitattributes
    echo "*.svg filter=lfs diff=lfs merge=lfs -text" >> .gitattributes

    git add .gitattributes

    BRANCH_NAME="$YEAR/$TEAM_FOLDER"

    if git ls-remote --exit-code --heads origin "$BRANCH_NAME" > /dev/null 2>&1; then
        echo -e "${YELLOW}Удаляем существующую ветку $BRANCH_NAME на удалённом репо...${NC}"
        git push origin --delete "$BRANCH_NAME" > /dev/null
    fi

    echo -e "${YELLOW}3. Создаём новую ветку $BRANCH_NAME...${NC}"
    git checkout --orphan "$BRANCH_NAME" > /dev/null
    git add .
    git commit -m "Added files from $TEAM_FOLDER" > /dev/null

    echo -e "${YELLOW}4. Отправка файлов в удалённый репозиторий...${NC}"
    if git push -u origin "$BRANCH_NAME" > /dev/null 2>&1; then
        if git ls-remote --exit-code --heads origin "$BRANCH_NAME" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Ветка $BRANCH_NAME создана и файлы успешно загружены!${NC}"
            PUSHED_BRANCHES+=("$BRANCH_NAME")
            rm -rf "$DEST_DIR/$TEAM_FOLDER"
        else
            echo -e "${RED}❌ Push прошёл, но ветка $BRANCH_NAME не найдена на удалённом репо!${NC}"
            FAILED_BRANCHES+=("$BRANCH_NAME")
        fi
    else
        echo -e "${RED}❌ Ошибка при push, папка $TEAM_FOLDER не будет удалена.${NC}"
        FAILED_BRANCHES+=("$BRANCH_NAME")
    fi

    cd "$SOURCE_DIR" || { echo -e "${RED}Не удалось вернуться в $SOURCE_DIR${NC}"; exit 1; }
done

echo -e "\n${CYAN}=== Скрипт завершён ===${NC}"


if [ "${#PUSHED_BRANCHES[@]}" -gt 0 ]; then
    echo -e "${GREEN}-----------------------------${NC}"
    echo -e "${GREEN}Всего успешно залито веток: ${#PUSHED_BRANCHES[@]}${NC}"
    echo -e "${GREEN}Список веток:${NC}"
    for b in "${PUSHED_BRANCHES[@]}"; do
        echo -e "${GREEN}  - ${b}${NC}"
    done
    echo -e "${GREEN}-----------------------------${NC}"
else
    echo -e "${YELLOW}Нет успешно загруженных веток.${NC}"
fi


if [ "${#FAILED_BRANCHES[@]}" -gt 0 ]; then
    echo -e "${RED}-----------------------------${NC}"
    echo -e "${RED}Не удалось залить веток: ${#FAILED_BRANCHES[@]}${NC}"
    echo -e "${RED}Список веток:${NC}"
    for b in "${FAILED_BRANCHES[@]}"; do
        echo -e "${RED}  - ${b}${NC}"
    done
    echo -e "${RED}-----------------------------${NC}"
else
    echo -e "${YELLOW}Незалито веток: 0${NC}"
fi


if [ "${#SKIPPED_FOLDERS[@]}" -gt 0 ]; then
    echo -e "${CYAN}-----------------------------${NC}"
    echo -e "${CYAN}Пропущено папок: ${#SKIPPED_FOLDERS[@]}${NC}"
    echo -e "${CYAN}Список папок:${NC}"
    for b in "${SKIPPED_FOLDERS[@]}"; do
        echo -e "${CYAN}  - ${b}${NC}"
    done
    echo -e "${CYAN}-----------------------------${NC}"
else
    echo -e "${YELLOW}Пропущено папок: 0${NC}"
fi