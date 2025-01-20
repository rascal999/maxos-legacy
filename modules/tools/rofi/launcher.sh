#!/usr/bin/env bash

ROFI_CMD="rofi"

# Path to your SQLite database file
DB_FILE="$HOME/.local/share/rofi/rofi.db"

# SQLite query to select entries and commands from your database
QUERY="SELECT entry_name command FROM rofi;"

# Execute the SQLite query and store the results in a variable
ENTRIES=$(sqlite3 "$DB_FILE" "$QUERY")

# Firefox bookmarks
ENTRIES_BOOKMARKS=$(cat "$HOME/.mozilla/firefox/policies/policies.json" | jq -r '.policies.ManagedBookmarks.[] | .name + if .children then (.children[] | .policies.ManagedBookmarks.name + " # " + .name + " " + (.url // "NA")) end' | grep http | sed 's/^/📚 Bookmarks # Bks # /g' | sed 's/ http/ | xdg-open http/g')

# Want history last
ENTRIES_SORTED=$(echo "$ENTRIES" | sort)
ENTRIES_BOOKMARKS_SORTED=$(echo "$ENTRIES_BOOKMARKS" | sort)
ENTRIES="${ENTRIES_SORTED}
${ENTRIES_BOOKMARKS_SORTED}"

# Use $ROFI_CMD to display the entries and select one
SELECTED_ENTRY=$(echo "$ENTRIES" | cut -d '|' -f 1 | $ROFI_CMD -i -dmenu -p "maxos >")

# Find the corresponding command for the selected entry
SELECTED_COMMAND=$(echo "$ENTRIES" | grep "^$SELECTED_ENTRY|" | cut -d '|' -f 2)

perform_search() {
    local url="$1"
    shift  # Remove the URL from arguments leaving only the search query
    local search_query="$@"

    # Construct the search URL
    search_url="${url}${search_query// /+}"

    if [[ $search_query != "" ]]; then
        # Open the search URL in the default web browser
        xdg-open "$search_url"
        sleep 1
        i3-msg "[title=\"$search_query.*Firefox\"] focus"
    fi
}

case "$SELECTED_COMMAND" in
    ai-ollama-simple-query)
        SEARCH_QUERY=$($ROFI_CMD -dmenu -p "Simple query")
        /home/user/git/github/ai-helper/query_ollama.py --template basic --query "$SEARCH_QUERY"
    ;;
    ai-ollama-pentest-title)
        SEARCH_QUERY=$($ROFI_CMD -dmenu -p "Pentest title")
        /home/user/git/github/ai-helper/query_ollama.py --template pentest_title --query "$SEARCH_QUERY"
    ;;
    ai-ollama-pentest-issue)
        SEARCH_QUERY=$($ROFI_CMD -dmenu -p "Pentest issue")
        /home/user/git/github/ai-helper/query_ollama.py --template pentest --query "$SEARCH_QUERY"
    ;;
    ai-ollama-explain-tech)
        SEARCH_QUERY=$($ROFI_CMD -dmenu -p "Explain tech")
        /home/user/git/github/ai-helper/query_ollama.py --template explain_tech --query "$SEARCH_QUERY"
    ;;
    ai-ollama-summarise)
        SEARCH_QUERY=$($ROFI_CMD -dmenu -p "Summarise")
        /home/user/git/github/ai-helper/query_ollama.py --template summarize --query "$SEARCH_QUERY"
    ;;
    ai-ollama-translate)
        SEARCH_QUERY=$($ROFI_CMD -dmenu -p "Translate")
        /home/user/git/github/ai-helper/query_ollama.py --template translate --query "$SEARCH_QUERY"
    ;;
    amazon)
        SEARCH_QUERY=$($ROFI_CMD -dmenu -p "Amazon search")
        perform_search "https://www.amazon.co.uk/s?k=" "$SEARCH_QUERY"
    ;;
    github-topic)
        SEARCH_QUERY=$($ROFI_CMD -dmenu -p "GitHub topic")
        perform_search "https://github.com/topics/" "$SEARCH_QUERY"
    ;;
    google)
        SEARCH_QUERY=$($ROFI_CMD -dmenu -p "Google search query")
        perform_search "https://www.google.com/search?q=" "$SEARCH_QUERY"
    ;;
    google-image)
        SEARCH_QUERY=$($ROFI_CMD -dmenu -p "Google image search query")
        perform_search "https://www.google.com/search?tbm=isch&q=" "$SEARCH_QUERY"
    ;;
    gdrive)
        SEARCH_QUERY=$($ROFI_CMD -dmenu -p "Google Drive search")
        perform_search "https://drive.google.com/drive/u/0/search?q=" "$SEARCH_QUERY"
    ;;
    jql)
        SEARCH_QUERY=$($ROFI_CMD -dmenu -p "JQL")
        perform_search "https://mangopay.atlassian.net/issues/?jql=" "$SEARCH_QUERY"
    ;;
    jira-ticket)
        SEARCH_QUERY=$($ROFI_CMD -dmenu -p "Jira ticket ID")
        perform_search "https://mangopay.atlassian.net/browse/" "$SEARCH_QUERY"
    ;;
    nix-pkg)
        SEARCH_QUERY=$($ROFI_CMD -dmenu -p "NixOS pkg")
        perform_search "https://search.nixos.org/packages?channel=24.11&from=0&size=50&sort=relevance&type=packages&query=" "$SEARCH_QUERY"
    ;;
    youtube)
        SEARCH_QUERY=$($ROFI_CMD -dmenu -p "YouTube search")
        perform_search "https://www.youtube.com/results?search_query=" "$SEARCH_QUERY"
    ;;
    wikipedia)
        SEARCH_QUERY=$($ROFI_CMD -dmenu -p "Wiki search")
        perform_search "https://en.wikipedia.org/w/index.php?search=" "$SEARCH_QUERY"
    ;;
    yahoo-finance)
        SEARCH_QUERY=$($ROFI_CMD -dmenu -p "Quote")
        perform_search "https://uk.finance.yahoo.com/quote/" "$SEARCH_QUERY"
    ;;
    notion)
        xdg-open "https://notion.so/"
    ;;
    *)
        eval "$SELECTED_COMMAND"

        # Focus Firefox if xdg-open command
        if [[ $SELECTED_COMMAND =~ .*xdg-open.* ]]; then
            i3-msg "[title=\".*Firefox\"] focus"
        fi
    ;;
esac
