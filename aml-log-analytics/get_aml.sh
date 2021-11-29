curl -sS https://webinstall.dev/jq | bash > /dev/null 2>&1
command=$(az ml workspace show --only-show-errors --output json --resource-group $1 --name $2 | $HOME/.local/bin/jq  '{"application_insights": .application_insights, "key_vault": .key_vault, "location": .location}')
echo $command
