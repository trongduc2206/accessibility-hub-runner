echo "Fetching rule IDs for service: $SERVICE_ID"
RULE_IDS=$(curl -s "https://accessibility-hub-be.onrender.com/rules/$SERVICE_ID")

if [ -z "$RULE_IDS" ]; then
    echo "No rule IDs retrieved. Exiting..."
    exit 1
fi

echo "Rule IDs: $RULE_IDS"
echo "RULE_IDS=$RULE_IDS" >> $GITHUB_ENV

IFS=',' read -ra TOOLS_ARRAY <<< "$TOOLS"

for TOOL in "${TOOLS_ARRAY[@]}"; do
    if [ "$TOOL" == "axe" ]; then
        echo "Running Axe CLI on $URL with axe-source $GITHUB_ACTION_PATH/axe.js with rules: $RULE_IDS"
        axe "$URL" --chrome-options="headless,disable-gpu,no-sandbox,incognito" --rules "$RULE_IDS" --axe-source "$GITHUB_ACTION_PATH/axe.js" --verbose --exit
        if [ $? -ne 0 ]; then
            echo "Axe CLI reported issues."
            FAILED=1
        fi
    elif [ "$TOOL" == "pa11y" ]; then
        IGNORED_RULES=$(curl -s "https://accessibility-hub-be.onrender.com/ignore-pa11y-rules/$SERVICE_ID")
        echo "Running Pa11y CLI on $URL with ignored rules: $IGNORED_RULES"
        pa11y "$URL" --config "$GITHUB_ACTION_PATH/pa11y-config.json" --ignore "$IGNORED_RULES"
        if [ $? -eq 2 ]; then
            echo "Pa11y CLI reported issues."
            FAILED=1
        fi
    else
        echo "Tool $TOOL is not supported. Skipping..."
    fi
done

if [ $FAILED -ne 0 ]; then
    echo "One or more tools reported issues. Failing the workflow."
    exit 1
fi

echo "All tools executed successfully with no issues."