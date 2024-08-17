#!/bin/env bash

# Set variables
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
INSTALL_DIR="$HOME/.local/bin"
MISC_DIR="$SCRIPT_DIR/misc"
MANPAGE_DIR="$MISC_DIR/manpages"

# Function to install selected scripts
install_scripts() {
    mkdir -p "$INSTALL_DIR"

    # Get the list of scripts to install, excluding already installed ones
    script_files=$(ls "$SCRIPT_DIR"/*.sh)

    # Prepare list for dialog, excluding already installed scripts
    script_list=()
    for script in $script_files; do
        script_name=$(basename "$script")
        install_name="${script_name%.sh}"
        if [[ ! -f "$INSTALL_DIR/$install_name" ]]; then
            manpage_available=""
            if [[ -f "$MANPAGE_DIR/$install_name.1" ]]; then
                manpage_available=" (manpage)"
            fi
            script_list+=("$script_name" "$install_name$manpage_available" "off")
        fi
    done

    if [ ${#script_list[@]} -eq 0 ]; then
        dialog --msgbox "No new scripts to install." 8 40
        return
    fi

    # Show multiselect dialog
    selected_scripts=$(dialog --title "Select Scripts to Install" \
        --checklist "Choose scripts to install:" 15 50 6 \
        "${script_list[@]}" \
        2>&1 >/dev/tty)

    # Process selected scripts
    for script_name in $selected_scripts; do
        script_name=$(echo "$script_name" | sed 's/"//g')
        install_name="${script_name%.sh}"
        script_path="$SCRIPT_DIR/$script_name"

        # Submenu to handle manpage installation if available
        if [[ -f "$MANPAGE_DIR/$install_name.1" ]]; then
            dialog --title "Install Manpage" --yesno "Manpage for $install_name found. Install?" 8 40
            if [ $? -eq 0 ]; then
                mkdir -p "$HOME/.local/share/man/man1"
                cp "$MANPAGE_DIR/$install_name.1" "$HOME/.local/share/man/man1/"
            fi
        fi

        # Install the script
        if [[ -f "$script_path" ]]; then
            cp "$script_path" "$INSTALL_DIR/$install_name"
            chmod +x "$INSTALL_DIR/$install_name"
            touch "$INSTALL_DIR/$install_name"  # Update the timestamp to mark the installation date
        fi
    done
    dialog --msgbox "Selected scripts installed." 8 40
}

# Function to list installed scripts
list_installed_scripts() {
    installed_scripts=$(ls -1 "$INSTALL_DIR")

    if [ -z "$installed_scripts" ]; then
        dialog --msgbox "No scripts are installed." 8 40
        return
    fi

    formatted_list="SCRIPT NAME\n-----------\n"
    while IFS= read -r script; do
        formatted_list+="$script\n"
    done <<< "$installed_scripts"

    dialog --title "Installed Scripts" --msgbox "$formatted_list" 20 40
}

# Function to remove selected scripts
remove_scripts() {
    installed_scripts=$(ls -1 "$INSTALL_DIR")

    if [ -z "$installed_scripts" ]; then
        dialog --msgbox "No scripts are installed." 8 40
        return
    fi

    script_list=()
    for script in $installed_scripts; do
        script_list+=("$script" "$script" "off")
    done

    selected_scripts=$(dialog --title "Select Scripts to Remove" \
        --checklist "Choose scripts to remove:" 15 50 6 \
        "${script_list[@]}" \
        2>&1 >/dev/tty)

    for script_name in $selected_scripts; do
        script_name=$(echo "$script_name" | sed 's/"//g')
        rm -f "$INSTALL_DIR/$script_name"
        rm -f "$HOME/.local/share/man/man1/$script_name.1"  # Remove the associated manpage if it exists
    done
    dialog --msgbox "Selected scripts removed." 8 40
}

# Function to update scripts from the repository
update_scripts() {
    git pull origin main
    dialog --msgbox "Scripts updated from the repository." 8 40
}

# Function to handle zsh completions
handle_zsh_completions() {
    mkdir -p "$HOME/.zsh/completions"
    cp "$MISC_DIR/completions/"* "$HOME/.zsh/completions/"
    dialog --msgbox "Zsh completions installed." 8 40
}

# Main menu
while true; do
    action=$(dialog --title "Script Manager" --menu "Choose an action:" 15 50 7 \
        1 "Install Scripts" \
        2 "List Installed Scripts" \
        3 "Remove Scripts" \
        4 "Update Scripts from Repo" \
        5 "Install Zsh Completions" \
        6 "Exit" \
        2>&1 >/dev/tty)

    case $action in
        1)
            install_scripts
            ;;
        2)
            list_installed_scripts
            ;;
        3)
            remove_scripts
            ;;
        4)
            update_scripts
            ;;
        5)
            handle_zsh_completions
            ;;
        6)
            break
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
done

