echo "Fetching rule IDs for service: $SERVICE_ID"
RULE_IDS=$(curl -s "https://accessibility-hub-be.onrender.com/rules/$SERVICE_ID")

if [ -z "$RULE_IDS" ]; then
    echo "No rule IDs retrieved. Exiting..."
    exit 1
fi

echo "Rule IDs: $RULE_IDS"
echo "RULE_IDS=$RULE_IDS" >> $GITHUB_ENV

echo "Running Axe CLI on $URL with axe-source $GITHUB_ACTION_PATH/axe.js with rules: $RULE_IDS"
# AXE_OUTPUT=$(axe "$URL" --chrome-options="no-sandbox,incognito" --rules "$RULE_IDS" --exit)
# AXE_OUTPUT_CLEAN=$(echo "$AXE_OUTPUT" | tr '\n' ' ' | tr -d '\r')

# echo "$AXE_OUTPUT"
# echo "result=$AXE_OUTPUT_CLEAN" >> $GITHUB_OUTPUT
axe "$URL" --chrome-options="headless,disable-gpu,no-sandbox,incognito" --rules "$RULE_IDS" --axe-source "$GITHUB_ACTION_PATH/axe.js" --verbose --exit