#!/bin/sh

# Define the directories to check
POSTS_DIR="_posts"
HUGO_CONTENT_DIR="hugo/content/posts"
HUGO_STATIC_DIR="hugo/static"

# Function to check if a directory exists
check_directory() {
    if [ ! -d "$1" ]; then
        echo "Error: Directory '$1' does not exist."
        exit 1
    fi
}

# Function to check if a command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Error: Command '$1' is not installed."
        exit 1
    fi
}

# Check for required commands
check_command "jupyter-nbconvert"
check_command "hugo"

# Check for the _posts directory
check_directory "$POSTS_DIR"

# Check for the hugo/content/posts directory
mkdir -p "$HUGO_CONTENT_DIR"
check_directory "$HUGO_CONTENT_DIR"
rm ${HUGO_CONTENT_DIR}/*md

# Check for the hugo/static directory
mkdir -p "$HUGO_STATIC_DIR"
check_directory "$HUGO_STATIC_DIR"

# If all checks pass, proceed with deployment
echo "All required directories and dependencies exist. Proceeding with deployment..."

# Function to convert Jupyter notebooks to Markdown
convert_notebooks() {
    for notebook in "$POSTS_DIR"/*.ipynb; do
        if [ -f "$notebook" ]; then
            echo "Converting $notebook to Markdown..."
            jupyter-nbconvert --to markdown "$notebook"
        fi
    done
}



# Function to copy Markdown files and resources
copy_files() {
    echo "Copying Markdown files and resources to $HUGO_CONTENT_DIR and $HUGO_STATIC_DIR..."
    
    # Copy Markdown files
    cp "$POSTS_DIR"/*.md "$HUGO_CONTENT_DIR/"

    # delete copied md files
    rm "$POSTS_DIR"/*.md
    
    # Copy all folders ending in _files, preserving the folder namesde
    for folder in "$POSTS_DIR"/*_files; do
        if [ -d "$folder" ]; then
            echo "Copying resources from $folder to $HUGO_STATIC_DIR..."
            cp -r "$folder" "$HUGO_STATIC_DIR/"
        fi
    done
}
# Function to prefix local image paths in Markdown files
prefix_image_paths() {
    echo "Prefixing local image paths with '/'..."
    
    # Loop through all Markdown files in the specified directory
    for md in "$HUGO_CONTENT_DIR"/*.md; do
        if [[ -f "$md" ]]; then
            echo "Processing file: $md"
            python scripts/markdown_images.py "$md"
        else
            echo "No Markdown files found in $HUGO_CONTENT_DIR."
            break
        fi
    done
}
# Function to build the Hugo site
build_hugo() {
    echo "Building the Hugo site..."
    cd ./hugo && hugo -D 
}

# Execute the functions
convert_notebooks
copy_files
prefix_image_paths
build_hugo

echo "Deployment completed successfully."
