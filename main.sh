#!/bin/bash

# Configuration for source to add mirror
SOURCE_GITLAB_URL="https://git.g2holding.org"  # Replace with your GitLab instance URL
SOURCE_ACCESS_TOKEN=""  # Replace with your personal access token
SOURCE_GITLAB_GROUP="g2"


# Target 
TARGET_GITLAB_URL="https://gitlab.com"  # Replace with your GitLab instance URL
TARGET_ACCESS_TOKEN=""  # Replace with your personal access token
TARGET_GITLAB_GROUP="g29485726"


OUTPUT_FILE="repository_urls.json"  # File to store repository URLs

# Initialize output file
touch $OUTPUT_FILE

# Function to get a list of repositories
get_repositories_from_source() {
    page=1
    per_page=100
    merged_array="[]"

    while : ; do
        # Fetch the list of repositories
        response=$(curl --silent --header "PRIVATE-TOKEN: $SOURCE_ACCESS_TOKEN" "$SOURCE_GITLAB_URL/api/v4/projects?per_page=$per_page&page=$page")

        # Check if the response is empty
        if [[ -z "$response" || "$response" == "[]" ]]; then
            break
        fi

        # Extract and append repository names to the output file
        # echo "$response" | jq -r '.[].id' >> $OUTPUT_FILE
        merged_array=$(echo $response $merged_array | jq -s '.[0] + .[1]')

        # Increment page number
        page=$((page + 1))
    done

    echo "$merged_array" > $OUTPUT_FILE

    echo "Repository list has been saved to $OUTPUT_FILE"
}

create_mirror() {
    # loop json file to oprate per project file
    jq -c '.[]' $OUTPUT_FILE | while read i; do
        project_is_exist=0
        id=$(echo $i | jq -r '.id')
        path_with_namespace=$(echo $i | jq -r '.path_with_namespace')

        # check group exist
        # Split string into an array by forward slash
        IFS='/' read -ra groups <<< "$path_with_namespace"
        project_name="${groups[-1]}"

        # remove project name from namespace array
        groups=("${groups[@]:0:${#groups[@]}-1}")

        echo "${array[2]}"

        break

        # check project exsit in target or not?
        echo "$TARGET_GITLAB_URL/api/v4/projects?search_namespaces=true&search=${path_with_namespace/$SOURCE_GITLAB_GROUP/$TARGET_GITLAB_GROUP}"
        break
        target=$(curl --silent --header "PRIVATE-TOKEN: $TARGET_ACCESS_TOKEN" "$TARGET_GITLAB_URL/api/v4/projects?search_namespaces=true&search=${path_with_namespace/$SOURCE_GITLAB_GROUP/$TARGET_GITLAB_GROUP}")
        if [[ $(echo "$target" | jq '. | length') -gt 1 ]]; then
            echo "project exist"
        else
            echo "failure"
        fi

        echo $id ;
        break

    done
}



create_target_repository() {
    echo $(curl --silent --header "PRIVATE-TOKEN: $TARGET_ACCESS_TOKEN" "$TARGET_GITLAB_URL/api/v4/projects/13777243/remote_mirrors")
}

# Install jq if it's not installed
if ! command -v jq &> /dev/null; then
    echo "jq could not be found. Installing jq..."
    sudo apt-get update
    sudo apt-get install -y jq
fi

# Get the repositories
# get_repositories_from_source

create_mirror

