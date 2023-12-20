#!/bin/bash
mkdir -p htmls
echo "Name, Health, Last Release, Adoption, Deprecation, Repository Configuration, Security, Update Center Plugin Publication, Healthscore URL " > done.csv

while IFS= read -r plugin; do

    healthscore_url="https://plugins.jenkins.io/${plugin}/healthscore/"

    if [ -f htmls/${plugin}.html ]; then
        #echo "Already downloaded ${plugin}"
        true
    else
        echo "Downloading ${plugin}"
        curl -s "${healthscore_url}" > htmls/${plugin}.html
        sleep 1
    fi

    # Uncomment this the first time to download the HTMLs locally. 
    # Then you can comment this part out and continue to use the locally downloaded HTMLs
    # It is good to uncomment from time to time to refresh the local cache
    # curl -s "https://plugins.jenkins.io/${plugin}/healthscore/" > htmls/${plugin}.html
    # sleep 1
    
    health=$(cat "htmls/${plugin}.html" | xmllint --html --xpath 'string(//span[@id="pluginHealth--score-value"])' - 2>/dev/null)
    # Skip processing if $health is empty
    if [[ -z "$health" ]]; then
        echo "$plugin" >> done.csv
        continue
    fi
    
    last_release=$(cat "htmls/${plugin}.html" | xmllint --html --xpath 'string(//time/@datetime)' - 2>/dev/null)
    details=$(cat "htmls/${plugin}.html" | xmllint --html --xpath '//*[@class="pluginHealth--score-section--header"]' - 2>/dev/null)
    echo "${details}" | sed 's/<div class="pluginHealth--score-section--header"><div class="pluginHealth--score-section--header-title">'// | sed 's/<\/div><div>/,/' | sed 's/<\/div><\/div>//' > temp_details
    
    printf "%s" "${plugin}, ${health}, ${last_release}" >> done.csv
    echo "HEALTH=${health}, PLUGIN=${plugin}"

    cat temp_details | sed 's/Adoption//' | sed 's/Deprecation//' | sed 's/Repository Configuration//' | sed 's/Security//' | sed 's/Update Center Plugin Publication//' | tr '\n' ' ' >> done.csv


    echo ", ${healthscore_url}" >> done.csv

    #echo "" >> done.csv

done < <(cat "plugins.txt")

rm -f temp_details
