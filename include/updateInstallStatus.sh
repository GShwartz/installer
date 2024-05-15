#!/bin/bash

show_help() {
    echo "Usage: $0 [html_file] [action] [content]"
    echo "Actions:"
    echo "  -uh, update_heading     - Updates the content of the <h1> element in the specified HTML file."
    echo "  -ap, add_paragraph      - Adds new paragraphs to the end of the <div id='statusList'>. Each new line in 'content' will be a new paragraph."
    echo "  -rp, replace_paragraphs - Replaces all existing paragraphs in <div id='statusList'> with new ones. Each new line in 'content' will be a new paragraph."
    echo "  -cp, clear_paragraphs   - Clears all paragraphs from <div id='statusList'>."
    echo "  -ui, update_image       - Updates the source of the logo image in the specified HTML file."
    echo "  -ut, update_title       - Updates the content of the <title> element in the specified HTML file."
    echo "  -uf, update_favicon     - Updates the href of the <link rel='icon'> tag in the specified HTML file."
    echo ""
    echo "Arguments:"
    echo "  html_file          - Path to the HTML file to be modified."
    echo "  action             - Action to perform (update_heading, add_paragraph, replace_paragraphs, clear_paragraphs, update_image, update_title, update_favicon)."
    echo "  content            - Content to update in the HTML file, dependent on the action. Not needed for clear_paragraphs."
    echo ""
    echo "Examples:"
    echo "  $0 /path/to/file.html -uh \"New Page Title\""
    echo "  $0 /path/to/file.html -ap \"This is the first paragraph.\nThis is the second paragraph.\""
    echo "  $0 /path/to/file.html -rp \"First new paragraph.\nSecond new paragraph.\""
    echo "  $0 /path/to/file.html -cp"
    echo "  $0 /path/to/file.html -ui \"new_logo.png\""
    echo "  $0 /path/to/file.html -ut \"New Title\""
    echo "  $0 /path/to/file.html -uf \"new_favicon.ico\""
    echo ""
    echo "Options:"
    echo "  -h, --help         - Display this help message and exit."
}

# Check for necessary arguments
if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ "$#" -lt 3 ] && [ "$2" != "-cp" ] && [ "$2" != "-ui" ] && [ "$2" != "-uf" ]; then
    show_help
    exit 1
fi

HTML_FILE="$1"
ACTION="$2"
CONTENT="${3-}"

# Function to update the title
update_title() {
    sed -i "s|<title>.*</title>|<title>$CONTENT</title>|" "$HTML_FILE"
}

# Function to update the heading
update_heading() {
    sed -i "s|<h1>.*</h1>|<h1>$CONTENT</h1>|" "$HTML_FILE"
}

# Function to add a new paragraph for each line of the input
add_paragraph() {
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            sed -i "/<div id=\"statusList\">/a \        <p class=\"status\">$line</p>" "$HTML_FILE"
        fi
    done <<< "$(echo -e "$CONTENT")"
}

# Function to replace all paragraphs with new ones
replace_paragraphs() {
    sed -i "/<div id=\"statusList\">/,/<\/div>/ { /<p class=\"status\">.*<\/p>/d; }" "$HTML_FILE"
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            sed -i "/<div id=\"statusList\">/a \        <p class=\"status\">$line</p>" "$HTML_FILE"
        fi
    done <<< "$(echo -e "$CONTENT")"
}

# Function to clear all paragraphs
clear_paragraphs() {
    sed -i "/<div id=\"statusList\">/,/<\/div>/ { /<p class=\"status\">.*<\/p>/d; }" "$HTML_FILE"
}

# Function to update the logo image source
update_logo_img() {
    sed -i "/<div class=\"logo-space\">/,/<\/div>/ s|<img src=\"[^\"]*\"|<img src=\"$CONTENT\"|" "$HTML_FILE"
}

# Function to update the favicon
update_favicon() {
    sed -i "s|<link rel=\"icon\" href=\"[^\"]*\" type=\"image/x-icon\">|<link rel=\"icon\" href=\"$CONTENT\" type=\"image/x-icon\">|" "$HTML_FILE"
}

# Decide which action to perform based on the second argument
case "$ACTION" in
    -uh | update_heading)
        update_heading "$HTML_FILE" "$CONTENT"
        ;;
    -ap | add_paragraph)
        add_paragraph "$HTML_FILE" "$CONTENT"
        ;;
    -rp | replace_paragraphs)
        replace_paragraphs "$HTML_FILE" "$CONTENT"
        ;;
    -cp | clear_paragraphs)
        clear_paragraphs "$HTML_FILE"
        ;;
    -ui | update_image)
        update_logo_img "$HTML_FILE" "$CONTENT"
        ;;
    -ut | update_title)
        update_title "$HTML_FILE" "$CONTENT"
        ;;
    -uf | update_favicon)
        update_favicon "$HTML_FILE" "$CONTENT"
        ;;
    *)
        echo "Invalid action: $ACTION"
        echo "Valid actions: -uh (update_heading), -ap (add_paragraph), -rp (replace_paragraphs), -cp (clear_paragraphs), -ui (update_image), -ut (update_title), -uf (update_favicon)"
        exit 1
        ;;
esac
