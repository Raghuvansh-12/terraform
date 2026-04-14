def handler(event, context):
    path = event.get("rawPath", "/")

    if path == "/health":
        return {
            "statusCode": 200,
            "body": "OK"
        }

    return {
        "statusCode": 200,
        "body": "App v2 running"
    }