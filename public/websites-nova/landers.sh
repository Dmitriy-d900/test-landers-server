#!/bin/bash

# Запуск скрипта: ./script.sh <year> <folder_name_1> [<folder_name_2> ... <folder_name_n>]
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <year> <folder_name_1> [<folder_name_2> ... <folder_name_n>]"
    exit 1
fi

YEAR="$1"
NEW_REPO_URL=git@github.com:900direct/black.git
SCRIPT_DIR="$(dirname "$(realpath "$0")")"     # Получение директории скрипта
SOURCE_DIR="$SCRIPT_DIR/../landers"            # Директория с исходными папками
DEST_DIR="$SCRIPT_DIR/$YEAR"                   # Директория назначения

cd "$SOURCE_DIR" || { echo "Failed to change directory to $SOURCE_DIR."; exit 1; }

if [ ! -d "$YEAR" ]; then
    echo "Folder $YEAR not found."
    exit 1
fi

mkdir -p "$DEST_DIR"

for TEAM_FOLDER in "${@:2}"; do
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

    
        find . -type f \( -name "*.php" -o -name "*.html" -o -name "*.js" -o -name "*.css" \) -exec sed -i 's|/landers/[0-9]\+/[^/]+/|./|g' {} +
        find . -type f \( -name "*.php" -o -name "*.html" -o -name "*.js" -o -name "*.css" \) -exec sed -i 's|./assets/|./assets_main/|g' {} +
        find . -type f \( -name "*.php" -o -name "*.html" -o -name "*.js" -o -name "*.css" \) -exec sed -i 's|/landers/[0-9]\+/[^/]\+/|./|g' {} + 

        
        #check
        echo "Checking for remaining landers paths:"
        grep -Eo '/landers/[0-9]+/[^/]+/assets' . -r --include=\*.{php,html,js,css}

        if [ -d "assets_main/css" ]; then
            find assets_main/css/ -type f -name "*.css" -exec sed -i 's|./assets_main/fonts|../fonts|g' {} +
            echo "Updated font paths in CSS files in $TEAM_FOLDER/assets_main/css/"
        fi

        find . -type f \( -name "*.php" -o -name "*.html" -o -name "*.js" -o -name "*.css" \) -exec sed -i '/<?php require "\/var\/www\/html\/sdk\/redirect-campaigns.php" ?>/d' {} +
        find . -type f \( -name "*.php" -o -name "*.html" \) -exec sed -i "s|<?php require \"/var/www/html/sdk/index.php\" ?>|<?php require rtrim(\$_ENV['WORKDIR_PATH'], '/') . '/' . rtrim(\$_ENV['DOMAIN'], '/') . '/' . rtrim(\$_ENV['REPOSITORY_TARGET'], '/') . '/sdk/index.php'; ?>|g" {} +
        echo "Removed line '<?php require \"/var/www/html/sdk/redirect-campaigns.php\" ?>' from files in $TEAM_FOLDER"

        #git int
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

