import requests

token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3R1c2VyIn0.woCj2NtAg6QalPTYHbKND72NLtRvfnvtVtasFE725Qg"

r = requests.get("http://127.0.0.1:8000/verifylogin", headers={
    "Authorization": f"Bearer {token}"
})
print(r.text)
