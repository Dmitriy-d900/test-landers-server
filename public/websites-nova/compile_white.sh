#!/bin/bash
# запуск: ./compile_white.sh <year> <folder_name_1> [<folder_name_2> ...]

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

minify_assets() {
    local project_dir="$1"

    # echo -e "${YELLOW}⚙️  Минификация HTML...${NC}"
    # find "$project_dir" -type f -name "*.html" | while read -r file; do
    #     echo "    → Минифицируем: $file"
    #     html-minifier-terser \
    #         --collapse-whitespace \
    #         --remove-comments \
    #         --minify-js \
    #         --minify-css \
    #         "$file" -o "$file"
    # done

    echo -e "${YELLOW}⚙️  Минификация JS...${NC}"
    if [ -d "$project_dir/assets/js" ]; then
        find "$project_dir/assets/js" -type f -name "*.js" | while read -r js_file; do
            echo "    → Минифицируем: $js_file"
            terser "$js_file" -o "$js_file" --compress --mangle
        done
    fi

    echo -e "${YELLOW}⚙️  PurgeCSS + минификация CSS...${NC}"
    CSS_DIR="$project_dir/assets/css"
    if [ -d "$CSS_DIR" ]; then
        mapfile -d '' content_files < <(find "$project_dir" \( -name "*.html" -o -name "*.js" \) -print0)
        for css_file in "$CSS_DIR"/*.css; do
            [ -f "$css_file" ] || continue
            purgecss --css "$css_file" --content "${content_files[@]}" \
              --safelist standard[js-,btn-,active,open,show,collapse,modal,offcanvas,dropdown,toast,tooltip,is-] \
              --output "$CSS_DIR"
            csso "$CSS_DIR/$(basename "$css_file")" --output "$css_file"
        done
    fi
}

for TEAM_FOLDER in "${@:2}"; do
    echo -e "\n${CYAN}--- Обработка папки: ${TEAM_FOLDER} ---${NC}"

    if [ ! -d "$YEAR/$TEAM_FOLDER" ]; then
        echo -e "${RED}Папка $YEAR/$TEAM_FOLDER не найдена, пропуск...${NC}"
        continue
    fi

    cp -r "$YEAR/$TEAM_FOLDER" "$DEST_DIR/" || { echo -e "${RED}Ошибка копирования $TEAM_FOLDER${NC}"; continue; }

    minify_assets "$DEST_DIR/$TEAM_FOLDER"

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
        fi
    else
        echo -e "${RED}❌ Ошибка при push, папка $TEAM_FOLDER не будет удалена.${NC}"
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
