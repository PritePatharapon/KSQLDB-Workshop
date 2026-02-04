#!/bin/bash

# ==============================================================================
# SCRIPT TO DELETE KAFKA TOPICS BY SUFFIX VIA REST API V3
# Ref: https://docs.confluent.io/platform/current/kafka-rest/api.html#topic-v3
# ==============================================================================

# 1. SETUP CONFIGURATION (USER MUST UPDATE THESE)
# Example URL: http://localhost:8082 Or http://localhost:8090
KAFKA_REST_ENDPOINT="http://138.2.78.77:8082"

# REQUIRED: Your Kafka Cluster ID (e.g., lkc-xxxx or cluster-id-xxxx)
# You can find this via: curl http://<host>:<port>/v3/clusters
KAFKA_CLUSTER_ID="MkU3OEVBNTcwNTJENDM2Qk"

# 2. CHECK PARAMS
if [ -z "$1" ]; then
    echo "Usage: $0 <suffix>"
    echo "Example: $0 test88"
    exit 1
fi

if [ "$KAFKA_CLUSTER_ID" == "YOUR_CLUSTER_ID_HERE" ]; then
    echo "Error: Please edit the script update 'KAFKA_CLUSTER_ID' variable first."
    exit 1
fi

SUFFIX=$1

echo "----------------------------------------------------------------"
echo "Target Endpoint:   $KAFKA_REST_ENDPOINT"
echo "Target Cluster ID: $KAFKA_CLUSTER_ID"
echo "Target Suffix:     $SUFFIX"
echo "----------------------------------------------------------------"

# 3. FETCH TOPICS (V3 API)
# API Path: /kafka/v3/clusters/{cluster_id}/topics (Try /v3/ if /kafka/v3/ fails)
API_PATH="/kafka/v3/clusters/$KAFKA_CLUSTER_ID/topics"

echo "Fetching topic list from $API_PATH ..."
RESPONSE=$(curl -s "$KAFKA_REST_ENDPOINT$API_PATH")

# Check if curl failed (empty or curl error)
if [ -z "$RESPONSE" ]; then
    echo "Error: Failed to fetch topics. Check your URL, Port, or Network Connection."
    exit 1
fi

# 4. PARSE AND FILTER (Using grep/sed to avoid jq dependency)
# V3 Response format: {"kind":"KafkaTopicList","metadata":{...},"data":[{"kind":"KafkaTopic","metadata":{...},"cluster_id":"...","topic_name":"TOPIC1",...}, ...]}
# We need to extract "topic_name":"XXXX"
TARGET_TOPICS=$(echo "$RESPONSE" | grep -o '"topic_name":"[^"]*"' | awk -F'"' '{print $4}' | grep "$SUFFIX" | sort)

if [ -z "$TARGET_TOPICS" ]; then
    echo "No topics found containing suffix '$SUFFIX' (or failed to parse response)."
    echo "Raw Response (First 100 chars): ${RESPONSE:0:100}..."
    exit 0
fi

# 5. CONFIRMATION
echo "Found the following topics to DELETE:"
echo "$TARGET_TOPICS"
echo "----------------------------------------------------------------"
read -p "Are you sure you want to PERMANENTLY DELETE these topics? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

# 6. EXECUTE DELETE LOOP
echo "Starting deletion..."
for topic in $TARGET_TOPICS; do
    echo -n "Deleting '$topic' ... "
    
    # Path: /kafka/v3/clusters/{cluster_id}/topics/{topic_name}
    DELETE_URL="$KAFKA_REST_ENDPOINT$API_PATH/$topic"
    
    # Send DELETE request
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$DELETE_URL")
    
    if [ "$HTTP_CODE" == "204" ]; then
        echo "SUCCESS"
    elif [ "$HTTP_CODE" == "404" ]; then
        echo "NOT FOUND (Already deleted?)"
    else
        echo "FAILED (HTTP $HTTP_CODE)"
    fi
done

echo "Done."
