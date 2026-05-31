#!/bin/bash
# запуск: ./linux.sh <year> <folder_name_1> [<folder_name_2> ... <folder_name_n>]

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'


LS_REMOTE_TIMEOUT=60
DELETE_TIMEOUT=60
LFS_PUSH_TIMEOUT=60
GIT_PUSH_TIMEOUT=60
RETRY_ATTEMPTS=3
RETRY_DELAY=15

if [ "$#" -lt 2 ]; then
  echo -e "${YELLOW}Usage:${NC} $0 <year> <folder_name_1> [<folder_name_2> ...]"
  exit 1
fi

YEAR="$1"
NEW_REPO_URL="git@github-work:Dmitriy-d900/test-nova-white.git"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
SOURCE_DIR="$SCRIPT_DIR/../websites"
DEST_DIR="$SCRIPT_DIR/$YEAR"

export GIT_SSH_COMMAND="ssh -o ConnectTimeout=30 -o ServerAliveInterval=15 -o ServerAliveCountMax=8"
export GIT_TERMINAL_PROMPT=0
export GIT_LFS_PROGRESS="/dev/stderr"

# -----------------------------
# Retry helper
# -----------------------------
retry_cmd() {
  local attempts="$RETRY_ATTEMPTS"
  local delay="$RETRY_DELAY"
  local n=1

  while true; do
    "$@"
    local code=$?

    if [ "$code" -eq 0 ]; then
      return 0
    fi

    if [ "$n" -ge "$attempts" ]; then
      echo -e "${RED}❌ Команда упала после ${attempts} попыток: $*${NC}"
      return "$code"
    fi

    echo -e "${YELLOW}⚠️ Попытка ${n}/${attempts} не удалась. Повтор через ${delay} сек...${NC}"
    sleep "$delay"
    n=$((n + 1))
  done
}

echo -e "${CYAN}=== Старт скрипта ===${NC}"

cd "$SOURCE_DIR" || {
  echo -e "${RED}Ошибка: не удалось перейти в $SOURCE_DIR${NC}"
  exit 1
}

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

  rm -rf "$DEST_DIR/$TEAM_FOLDER"

  cp -r "$YEAR/$TEAM_FOLDER" "$DEST_DIR/" || {
    echo -e "${RED}Ошибка копирования $TEAM_FOLDER${NC}"
    FAILED_BRANCHES+=("$YEAR/$TEAM_FOLDER")
    continue
  }

  cd "$DEST_DIR/$TEAM_FOLDER" || {
    echo -e "${RED}Не удалось перейти в $DEST_DIR/$TEAM_FOLDER${NC}"
    FAILED_BRANCHES+=("$YEAR/$TEAM_FOLDER")
    cd "$SOURCE_DIR" || exit 1
    continue
  }

  echo -e "${YELLOW}1. Обновляем пути в файлах...${NC}"
  find . -type f -exec sed -i -E 's|/websites/[0-9]+/[^/]+/|./|g' {} +

  echo -e "${YELLOW}1b. Вставляем GA4 блок после <head> только в .php...${NC}"

  PHP_INSERT_BLOCK=$(cat <<'EOF'
  <?php
$dotenvPath = __DIR__ . '/../../../../';
$autoloadPath = __DIR__ . '/../vendor/autoload.php';

if (file_exists($autoloadPath)) {
  require_once $autoloadPath;

  if (class_exists(Dotenv\Dotenv::class) && file_exists($dotenvPath . '/.env')) {
    $dotenv = Dotenv\Dotenv::createImmutable($dotenvPath);
    $dotenv->safeLoad();
  }
}
?>
  <script>
  window.ga4Id = <?= isset($_ENV['GA4_MEASUREMENT_ID'])
    ? "'" . htmlspecialchars($_ENV['GA4_MEASUREMENT_ID']) . "'"
    : 'null'
  ?>;
</script>
EOF
)

  export PHP_INSERT_BLOCK

  find . -type f -name "*.php" -print0 | while IFS= read -r -d '' f; do
    if ! grep -qi "<head" "$f"; then
      continue
    fi

    perl -0777 -i -pe '
      s{
        \s*<\?php\b.*?\?>\s*
        <script>\s*
        \s*window\.ga4Id\s*=.*?;\s*
        </script>\s*
      }{}gxis
    ' "$f"

    perl -0777 -i -pe '
      my $ins = $ENV{PHP_INSERT_BLOCK};
      s{(<head\b[^>]*>)}{$1\n$ins}i;
    ' "$f"
  done

  echo -e "${YELLOW}1.1. Чистим PHP-файлы от markdown-блоков...${NC}"

  find . -type f -name "*.php" -print0 | while IFS= read -r -d '' file; do
    awk '
      {
        lines[NR] = $0
        if ($0 !~ /^[[:space:]]*$/) {
          last_non_empty = NR
        }
      }

      END {
        for (i = 1; i <= NR; i++) {
          if (lines[i] !~ /^[[:space:]]*$/) {
            if (lines[i] ~ /^[[:space:]]*```[Pp][Hh][Pp][[:space:]]*$/) {
              delete lines[i]
            }
            break
          }
        }

        if (lines[last_non_empty] ~ /^[[:space:]]*```[[:space:]]*$/) {
          delete lines[last_non_empty]
        }

        for (i = 1; i <= NR; i++) {
          if (i in lines) {
            print lines[i]
          }
        }
      }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  done

  echo -e "${YELLOW}2. Инициализация Git...${NC}"

  rm -rf .git

  git init > /dev/null || {
    echo -e "${RED}❌ git init failed${NC}"
    FAILED_BRANCHES+=("$YEAR/$TEAM_FOLDER")
    cd "$SOURCE_DIR" || exit 1
    continue
  }

  git config lfs.activitytimeout 300
  git config lfs.dialtimeout 120
  git config lfs.tlstimeout 120
  git config lfs.concurrenttransfers 2
  git config lfs.locksverify false

  git remote remove origin 2>/dev/null
  git remote add origin "$NEW_REPO_URL"

  git lfs install --local > /dev/null 2>&1

  cat > .gitattributes <<'EOF'
*.jpg filter=lfs diff=lfs merge=lfs -text
*.jpeg filter=lfs diff=lfs merge=lfs -text
*.png filter=lfs diff=lfs merge=lfs -text
*.webp filter=lfs diff=lfs merge=lfs -text
*.svg filter=lfs diff=lfs merge=lfs -text
*.gif filter=lfs diff=lfs merge=lfs -text
*.ico filter=lfs diff=lfs merge=lfs -text
EOF

  BRANCH_NAME="$YEAR/$TEAM_FOLDER"

  echo -e "${YELLOW}3. Создаём orphan branch $BRANCH_NAME...${NC}"

  git checkout --orphan "$BRANCH_NAME" > /dev/null || {
    echo -e "${RED}❌ Не удалось создать orphan branch $BRANCH_NAME${NC}"
    FAILED_BRANCHES+=("$BRANCH_NAME")
    cd "$SOURCE_DIR" || exit 1
    continue
  }

  git add .

  if ! git commit -m "Added files from $TEAM_FOLDER"; then
    echo -e "${RED}❌ Не удалось сделать commit для $TEAM_FOLDER${NC}"
    FAILED_BRANCHES+=("$BRANCH_NAME")
    cd "$SOURCE_DIR" || exit 1
    continue
  fi

  echo -e "${YELLOW}3.1. Проверяем LFS-файлы...${NC}"
  git lfs ls-files

  echo -e "${YELLOW}4. Отправляем LFS-файлы с retry...${NC}"

  if ! retry_cmd timeout "$LFS_PUSH_TIMEOUT" git lfs push --all origin "$BRANCH_NAME"; then
    echo -e "${RED}❌ Ошибка при git lfs push: $BRANCH_NAME${NC}"
    FAILED_BRANCHES+=("$BRANCH_NAME")
    cd "$SOURCE_DIR" || exit 1
    continue
  fi

  echo -e "${YELLOW}5. Отправляем Git-ветку через force push с retry...${NC}"

  if retry_cmd timeout "$GIT_PUSH_TIMEOUT" git push --force --progress -u origin "$BRANCH_NAME"; then
    echo -e "${GREEN}✅ Ветка $BRANCH_NAME создана/обновлена и файлы успешно загружены!${NC}"
    PUSHED_BRANCHES+=("$BRANCH_NAME")
    rm -rf "$DEST_DIR/$TEAM_FOLDER"
  else
    echo -e "${RED}❌ Ошибка при git push или операция зависла: $BRANCH_NAME${NC}"
    FAILED_BRANCHES+=("$BRANCH_NAME")
  fi

  cd "$SOURCE_DIR" || {
    echo -e "${RED}Не удалось вернуться в $SOURCE_DIR${NC}"
    exit 1
  }
done

echo -e "\n${CYAN}=== Скрипт завершён ===${NC}"

echo -e "${GREEN}-----------------------------${NC}"
echo -e "${GREEN}Всего успешно залито веток: ${#PUSHED_BRANCHES[@]}${NC}"
for b in "${PUSHED_BRANCHES[@]}"; do
  echo -e "${GREEN}  - ${b}${NC}"
done
echo -e "${GREEN}-----------------------------${NC}"

echo -e "${RED}-----------------------------${NC}"
echo -e "${RED}Не удалось залить веток: ${#FAILED_BRANCHES[@]}${NC}"
for b in "${FAILED_BRANCHES[@]}"; do
  echo -e "${RED}  - ${b}${NC}"
done
echo -e "${RED}-----------------------------${NC}"

echo -e "${CYAN}-----------------------------${NC}"
echo -e "${CYAN}Пропущено папок: ${#SKIPPED_FOLDERS[@]}${NC}"
for b in "${SKIPPED_FOLDERS[@]}"; do
  echo -e "${CYAN}  - ${b}${NC}"
done
echo -e "${CYAN}-----------------------------${NC}"