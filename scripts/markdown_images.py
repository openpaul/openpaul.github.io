import re
import sys

def process_markdown(input_file):
    # Initialize a list to hold modified lines
    modified_lines = []

    # Regular expression to find image links in Markdown
    image_pattern = r'(!\[[._\w]+\])\((?!\/)([-\w\/].+)\)'

    # Read the content of the input Markdown file line by line
    with open(input_file, 'r', encoding='utf-8') as file:
        for line in file:
            # Function to modify the image URL
            def modify_image_url(match):
                url = match.group(2)
                alttext = match.group(1)

                # Check if the URL does not start with a "/"
                if not url.startswith('/'):
                    url = '/' + url  # Add "/" prefix
                return f'{alttext}({url})'  # Return the modified image link

            # Replace all image URLs in the current line
            modified_line = re.sub(image_pattern, modify_image_url, line)
            
            modified_lines.append(modified_line)

    # Write the modified content back to the input file
    with open(input_file, 'w', encoding='utf-8') as file:
        file.writelines(modified_lines)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python process_markdown.py <input_file>")
        sys.exit(1)

    input_file_path = sys.argv[1]

    process_markdown(input_file_path)
