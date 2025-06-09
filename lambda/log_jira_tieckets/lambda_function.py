import json
import requests
import os
from base64 import b64encode

def handler(event, context):
    JIRA_URL = os.environ['JIRA_URL']
    JIRA_USER = os.environ['JIRA_USER']
    JIRA_TOKEN = os.environ['JIRA_TOKEN']
    JIRA_PROJECT = os.environ['JIRA_PROJECT']
    
    auth = b64encode(f\"{JIRA_USER}:{JIRA_TOKEN}\".encode()).decode()
    headers = {
        \"Authorization\": f\"Basic {auth}\",
        \"Content-Type\": \"application/json\"
    }
    
    issue_data = {
        \"fields\": {
            \"project\": {\"key\": JIRA_PROJECT},
            \"summary\": \"Automated alert: something needs attention.\",
            \"description\": json.dumps(event),
            \"issuetype\": {\"name\": \"Task\"}
        }
    }

    response = requests.post(f\"{JIRA_URL}/rest/api/2/issue\", headers=headers, json=issue_data)
    return {\"statusCode\": response.status_code, \"body\": response.text}
