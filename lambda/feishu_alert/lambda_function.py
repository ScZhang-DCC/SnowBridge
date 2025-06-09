import requests
import json


def get_token():
    url = 'https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal'
    payload = json.dumps({
        'app_id': 'cli_a668dfcb7abb100c',
        'app_secret': 'uO70FwOQUMDus6ISgu4fkbeYjWdjtzPS'
    })
    headers = {'Content-Type': 'application/json'}
    response = requests.request("POST", url, headers=headers, data=payload)
    json_data = json.loads(response.text)
    token = json_data['tenant_access_token']
    return token


def send_message(token, msg):
    authorization = 'Bearer ' + token
    url = 'https://open.feishu.cn/open-apis/im/v1/messages'
    params = {'receive_id_type': 'chat_id'}
    msgContent = {
        "text": msg,
    }
    payload = json.dumps({
        'receive_id': 'oc_820e41f5b63bf1618975791933f98ae9',
        'msg_type': 'text',
        'content': json.dumps(msgContent)
    })
    headers = {
        'Authorization': authorization,
        'Content-Type': 'application/json'
    }
    response = requests.request('POST', url, params=params, headers=headers, data=payload)
    json_data = json.loads(response.text)
    message_id = json_data['data']['message_id']
    return message_id

def emergency_phone(token,message_id, user):
    authorization = 'Bearer '+token
    url = 'https://open.feishu.cn/open-apis/im/v1/messages/'+message_id+'/urgent_phone?user_id_type=open_id'
    payload = json.dumps({
	    "user_id_list": [
	        user
	    ]
	})
    headers = {
	    'Authorization': authorization,
	    'Content-Type': 'application/json'
	}
    response = requests.request("PATCH", url, headers=headers, data=payload)

def lambda_handler(event, context):
    try:
        user_id = "ou_d003cac6418c943d3bea0d9eac7e3988"
        token = get_token()
        message = event.get("message", "New Incident Fired.")
        message_id = send_message(token, message)
        emergency_phone(token, message_id, user_id)	
        return {
            'statusCode': 200,
            'body': json.dumps({
                "message_id": message_id,
                "status": "Message sent successfully"
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
