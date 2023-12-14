#!/bin/bash

mkdir -p htmls
echo "Name, Health, Last Release, Adoption, Deprecation, Repository Configuration, Security, Update Center Plugin Publication " > done.csv

while IFS= read -r plugin; do

    if [ -f htmls/${plugin}.html ]; then
        echo "Already downloaded ${plugin}"
    else
        echo "Downloading ${plugin}"
        curl -s "https://plugins.jenkins.io/${plugin}/healthscore/" > htmls/${plugin}.html
        sleep 2
    fi

    # Uncomment this the first time to get the HTMLs locally. Then you can comment it out and continue to use the locally downloaded HTMLs
    # curl -s "https://plugins.jenkins.io/${plugin}/healthscore/" > htmls/${plugin}.html
    # sleep 2
    
    health=$(cat "htmls/${plugin}.html" | xmllint --html --xpath 'string(//span[@id="pluginHealth--score-value"])' - 2>/dev/null)
    last_release=$(cat "htmls/${plugin}.html" | xmllint --html --xpath 'string(//time/@datetime)' - 2>/dev/null)
    details=$(cat "htmls/${plugin}.html" | xmllint --html --xpath '//*[@class="pluginHealth--score-section--header"]' - 2>/dev/null)
    echo "${details}" | sed 's/<div class="pluginHealth--score-section--header"><div class="pluginHealth--score-section--header-title">'// | sed 's/<\/div><div>/,/' | sed 's/<\/div><\/div>//' > temp_details
    
    printf "%s" "${plugin}, ${health}, ${last_release}" >> done.csv
    echo "${health}, ${plugin}"

    cat temp_details | sed 's/Adoption//' | sed 's/Deprecation//' | sed 's/Repository Configuration//' | sed 's/Security//' | sed 's/Update Center Plugin Publication//' | tr '\n' ' ' >> done.csv

    echo "" >> done.csv

done < <(cat "plugins.txt")

##curl -s "https://plugins.jenkins.io/ansible-tower/healthscore/" | xmllint --html --xpath 'string(//span[@id="pluginHealth--score-value"])' - 2>/dev/null
