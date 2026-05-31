#!/bin/bash

# Запуск скрипта: ./script.sh <year> <folder_name_1> [<folder_name_2> ... <folder_name_n>] [-f] [-p]
# Пример: ./script.sh 2025 team1 team2 -f
# Пример: ./script.sh 2025 team1 team2 -p for Prelend

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <year> <folder_name_1> [<folder_name_2> ... <folder_name_n>] [-f] [-p]"
    exit 1
fi

YEAR="$1"
shift

USE_FUNNELS=false
USE_PRELEND=false
FOLDERS=()

for arg in "$@"; do
    if [ "$arg" == "-f" ]; then
        USE_FUNNELS=true
    elif [ "$arg" == "-p" ]; then
        USE_PRELEND=true
    else
        FOLDERS+=("$arg")
    fi
done

NEW_REPO_URL=git@github-work:Dmitriy-d900/test-nova-black.git
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
SOURCE_DIR="$SCRIPT_DIR/../landers"
SOURCE_DIR_F="$SCRIPT_DIR/../funnels"
DEST_DIR="$SCRIPT_DIR/$YEAR"

if [ "$USE_FUNNELS" = true ]; then
    SOURCE_DIR="$SOURCE_DIR_F"
    echo "⚙️ Используется директория FUNNELS: $SOURCE_DIR"
else
    echo "⚙️ Используется директория LANDERS: $SOURCE_DIR"
fi

cd "$SOURCE_DIR" || { echo "Failed to change directory to $SOURCE_DIR."; exit 1; }

if [ ! -d "$YEAR" ]; then
    echo "Folder $YEAR not found."
    exit 1
fi

mkdir -p "$DEST_DIR"

for TEAM_FOLDER in "${FOLDERS[@]}"; do
    if [ ! -d "$YEAR/$TEAM_FOLDER" ]; then
        echo "Folder $YEAR/$TEAM_FOLDER not found."
        continue
    fi

    cp -r "$YEAR/$TEAM_FOLDER" "$DEST_DIR/" || { echo "Failed to copy $YEAR/$TEAM_FOLDER to $DEST_DIR."; continue; }

    cd "$DEST_DIR/$TEAM_FOLDER" || { echo "Failed to change directory to $DEST_DIR/$TEAM_FOLDER."; exit 1; }

    echo "Processing directory: $TEAM_FOLDER"

    if [ -d "." ]; then
        if [ -d "assets" ]; then
            mv "assets" "assets_main"
            echo "Renamed assets to assets_main in $TEAM_FOLDER"
        fi

        # ==========================
        # ✅ PATH REWRITE BLOCK
        # ==========================
        if [ "$USE_FUNNELS" = true ]; then
            echo "🔧 Funnels mode: меняю /funnels/... на относительные"

            # 1) /funnels/<число>/<папка>/ -> ./
            # Работает при любых символах в имени папки ([], ., и т.д.)
            find . -type f \( -name "*.php" -o -name "*.html" -o -name "*.js" -o -name "*.css" \) \
                -exec perl -pi -e 's#\/funnels\/\d+\/[^\/]+\/#./#g' {} +

            # 2) На случай если где-то без финального слеша после папки:
            # /funnels/<число>/<папка> -> ./
            find . -type f \( -name "*.php" -o -name "*.html" -o -name "*.js" -o -name "*.css" \) \
                -exec perl -pi -e 's#\/funnels\/\d+\/[^\/]+#./#g' {} +

            # 3) ./assets/ -> ./assets_main/
            find . -type f \( -name "*.php" -o -name "*.html" -o -name "*.js" -o -name "*.css" \) \
                -exec perl -pi -e 's#\./assets/#./assets_main/#g' {} +

        else
            echo "🔧 Landers mode: старые замены /landers/..."

            find . -type f \( -name "*.php" -o -name "*.html" -o -name "*.js" -o -name "*.css" \) \
                -exec sed -i 's|/landers/[0-9]\+/[^/]+/|./|g' {} +
            find . -type f \( -name "*.php" -o -name "*.html" -o -name "*.js" -o -name "*.css" \) \
                -exec sed -i 's|./assets/|./assets_main/|g' {} +
            find . -type f \( -name "*.php" -o -name "*.html" -o -name "*.js" -o -name "*.css" \) \
                -exec sed -i 's|/landers/[0-9]\+/[^/]\+/|./|g' {} +
        fi

        echo "Checking for remaining landers/funnels paths:"
        if [ "$USE_FUNNELS" = true ]; then
            grep -Eo '/funnels/[0-9]+/[^/]+/assets' . -r --include=\*.{php,html,js,css}
        else
            grep -Eo '/landers/[0-9]+/[^/]+/assets' . -r --include=\*.{php,html,js,css}
        fi

        if [ -d "assets_main/css" ]; then
            find assets_main/css/ -type f -name "*.css" -exec sed -i 's|./assets_main/fonts|../fonts|g' {} +
            echo "Updated font paths in CSS files in $TEAM_FOLDER/assets_main/css/"
        fi

        find . -type f \( -name "*.php" -o -name "*.html" -o -name "*.js" -o -name "*.css" \) \
            -exec sed -i '/<?php require "\/var\/www\/html\/sdk\/redirect-campaigns.php" ?>/d' {} +

        find . -type f \( -name "*.php" -o -name "*.html" \) \
            -exec sed -i "s|<?php require \"/var/www/html/sdk/index.php\" ?>|<?php require rtrim(\$_ENV['WORKDIR_PATH'], '/') . '/' . rtrim(\$_ENV['DOMAIN'], '/') . '/' . rtrim(\$_ENV['REPOSITORY_TARGET'], '/') . '/sdk/index.php'; ?>|g" {} +

        echo "Removed line '<?php require \"/var/www/html/sdk/redirect-campaigns.php\" ?>' from files in $TEAM_FOLDER"

        find . -type f -name "index.php" \
            -exec sed -i 's|<?php require "/var/www/html/sdk/index.php"?>|<?php require rtrim($_ENV["WORKDIR_PATH"], "/") . "/" . rtrim($_ENV["DOMAIN"], "/") . "/" . rtrim($_ENV["REPOSITORY_TARGET"], "/") . "/sdk/index.php"; ?>|g' {} +

        echo "Replaced require '/var/www/html/sdk/index.php' in index.php files in $TEAM_FOLDER"

        find . -type f -name "index.php" \
            -exec sed -i 's|<?php require "/var/www/html/sdk/sdk-nophp.php" ?>|<?php require rtrim($_ENV["WORKDIR_PATH"], "/") . "/" . rtrim($_ENV["DOMAIN"], "/") . "/" . rtrim($_ENV["REPOSITORY_TARGET"], "/") . "/sdk/sdk-nophp.php"; ?>|g' {} +

        echo "Replaced require '/var/www/html/sdk/sdk-nophp.php' in index.php files in $TEAM_FOLDER"

        # ====== PRELEND (-p) как было ======
        if [ "$USE_PRELEND" = true ]; then
            echo "🧩 USE_PRELEND включён: добавляю voluum-строки перед закрывающим head/header"

            PRELEND_LINE1="<?php \$voluumSettings = ['domain' => 'priallysearly.com']; ?>"
            PRELEND_LINE2="<?php require rtrim(\$_ENV['WORKDIR_PATH'], '/') . '/' . rtrim(\$_ENV['DOMAIN'], '/') . '/' . rtrim(\$_ENV['REPOSITORY_TARGET'], '/') . '/sdk/1step-voluum.php'; ?>"

            find . -type f \( -name "*.php" -o -name "*.html" \) -print0 | while IFS= read -r -d '' file; do
                if grep -q "</head>" "$file"; then
                    sed -i "/<\/head>/i\\
$PRELEND_LINE1\\
$PRELEND_LINE2" "$file"
                    echo "  ✅ Вставлено в $file перед </head>"
                elif grep -q "</header>" "$file"; then
                    sed -i "/<\/header>/i\\
$PRELEND_LINE1\\
$PRELEND_LINE2" "$file"
                    echo "  ✅ Вставлено в $file перед </header>"
                fi
            done
        fi

        if [ "$USE_FUNNELS" = true ]; then
            echo "🧩 USE_FUNNELS включён: добавляю delegate-ch + dtpcnt блок перед закрывающим head/header"

            read -r -d '' FUNNEL_SNIPPET <<'EOF'
<meta http-equiv="delegate-ch" content="sec-ch-ua https://<?=$voluumSettings['domain'] ?? 'priallysearly.com'?>; sec-ch-ua-mobile https://<?=$voluumSettings['domain'] ?? 'priallysearly.com'?>; sec-ch-ua-arch https://<?=$voluumSettings['domain'] ?? 'priallysearly.com'?>; sec-ch-ua-model https://<?=$voluumSettings['domain'] ?? 'priallysearly.com'?>; sec-ch-ua-platform https://<?=$voluumSettings['domain'] ?? 'priallysearly.com'?>; sec-ch-ua-platform-version https://<?=$voluumSettings['domain'] ?? 'priallysearly.com'?>; sec-ch-ua-bitness https://<?=$voluumSettings['domain'] ?? 'priallysearly.com'?>; sec-ch-ua-full-version-list https://<?=$voluumSettings['domain'] ?? 'priallysearly.com'?>; sec-ch-ua-full-version https://<?=$voluumSettings['domain'] ?? 'priallysearly.com'?>"><style>.dtpcnt{opacity: 0;}</style>
<script>
 (function(c,d,f,h,t,b,n,u,k,l,m,e,p,v,q){function r(a){var c=d.cookie.match(new RegExp("(^| )"+a+"=([^;]+)"));return c?c.pop():f.getItem(a+"-expires")&&+f.getItem(a+"-expires")>(new Date).getTime()?f.getItem(a):null}q="https:"===c.location.protocol?"secure; ":"";c[b]||(c[b]=function(a){c[b].state.callbackQueue.push(a)},c[b].state={callbackQueue:[]},c[b].registerConversion=function(a){c[b].state.callbackQueue.push(a)},function(){(m=/[?&]cpid(=([^&#]*)|&|#|$)/.exec(c.location.href))&&m[2]&&(e=m[2],
 p=r("vl-"+e));var a=r("vl-cid"),b;"savedCid"!==u||!a||e&&"undefined"!==typeof e||(b=a);k=d.createElement("script");l=d.scripts[0];k.src=n+(-1===n.indexOf("?")?"?":"&")+"oref="+h(d.referrer)+"&ourl="+h(location[t])+"&opt="+h(d.title)+"&vtm="+(new Date).getTime()+(b?"&cid="+b:"")+(p?"&uw=no":"");l.parentNode.insertBefore(k,l);if(e){a="vl-"+e;b=q;var g=new Date;g.setTime(g.getTime()+864E5);d.cookie=a+"=1; "+b+"samesite=Strict; expires="+g.toGMTString()+"; path=/";f.setItem(a,"1");f.setItem(a+"-expires",
 g.getTime())}}())})(window,document,localStorage,encodeURIComponent,"href","dtpCallback","https://<?=$voluumSettings['domain'] ?? 'priallysearly.com'?>/d/.js","savedCid");
</script>
<noscript><link href="https://<?=$voluumSettings['domain'] ?? 'priallysearly.com'?>/d/.js?noscript=true&ourl=" rel="stylesheet"/></noscript>
EOF

            export FUNNEL_SNIPPET

            find . -type f \( -name "*.php" -o -name "*.html" \) -print0 | while IFS= read -r -d '' file; do
                if grep -q "</head>" "$file"; then
                    perl -0777 -i -pe 's@</head>@$ENV{FUNNEL_SNIPPET}."\n</head>"@ie' "$file"
                    echo "  ✅ Вставлено в $file перед </head>"
                elif grep -q "</header>" "$file"; then
                    perl -0777 -i -pe 's@</header>@$ENV{FUNNEL_SNIPPET}."\n</header>"@ie' "$file"
                    echo "  ✅ Вставлено в $file перед </header>"
                fi
            done
        fi

        if [ ! -d .git ]; then
            git init
        fi

        if ! git remote | grep -q origin; then
            git remote add origin "$NEW_REPO_URL"
        fi

        git lfs install
        git lfs track "*.jpg"
        git lfs track "*.png"
        git lfs track "*.webp"
        git lfs track "*.svg"

        echo "*.jpg filter=lfs diff=lfs merge=lfs -text" >> .gitattributes
        echo "*.png filter=lfs diff=lfs merge=lfs -text" >> .gitattributes
        echo "*.webp filter=lfs diff=lfs merge=lfs -text" >> .gitattributes
        echo "*.svg filter=lfs diff=lfs merge=lfs -text" >> .gitattributes

        git add .gitattributes

        SAFE_BRANCH_NAME=$(echo "$YEAR/$TEAM_FOLDER" | sed 's/\[/_/g; s/\]/_/g')

        if git ls-remote --exit-code --heads origin "$SAFE_BRANCH_NAME"; then
            git push origin --delete "$SAFE_BRANCH_NAME"
        fi

        if git show-ref --verify --quiet "refs/heads/$SAFE_BRANCH_NAME"; then
            git checkout "$SAFE_BRANCH_NAME"
        else
            git checkout --orphan "$SAFE_BRANCH_NAME"
        fi

        git add .
        git commit -m "Added files from $TEAM_FOLDER"
        git push -u origin "$SAFE_BRANCH_NAME"

        echo "Push successful, directory $TEAM_FOLDER processed."

        cd "$DEST_DIR" || { echo "Failed to change directory to $DEST_DIR."; exit 1; }
        rm -rf "$TEAM_FOLDER"
        echo "Removed directory $TEAM_FOLDER from $DEST_DIR."

        cd "$SOURCE_DIR" || { echo "Failed to return to the original directory."; exit 1; }
    else
        echo "Directory $TEAM_FOLDER not found in $YEAR."
    fi
done

echo "All directories processed."
