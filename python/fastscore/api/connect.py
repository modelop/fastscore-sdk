import sys

import requests
from time import sleep
import getpass

import _service as service

def connect(proxy_prefix, sec_creds=None):
    """
    Connect to the FastScore fleet. Returns True if successful.

    Required fields:
    - proxy_prefix: The URL and port of the FastScore Proxy as a string,
                    e.g., 'https://localhost:8000'
    Optional fields:
    - sec_creds: Security credentials to use: a string of the form 'username:password'
    """
    test_url = proxy_prefix + "/api/1/service/connect/1/health"
    credentials_provided = sec_creds != None
    if credentials_provided:
        service.reset_auth()

    last_status = ping_url(test_url)

    if last_status == 401 or credentials_provided:
        username = None
        password = None
        if credentials_provided:
            creds = sec_creds
            (username,password) = creds.split(":") if ":" in creds else (creds,None)
        ask_username = username == None
        ask_password = password == None
        while True:
            if ask_username:
                username = raw_input("Username: ")
            if ask_password:
                password = getpass.getpass()
            login_url = proxy_prefix + "/1/login"
            data = "username=%s&password=%s" % (username,password)
            headers = {"Content-Type": "application/x-www-form-urlencoded"}
            r = requests.post(login_url, headers=headers, data=data, verify=False)
            last_status = r.status_code
            if last_status == 200:
                secret = r.cookies["connect.sid"]
                service.set_auth(secret)
                break
            if not ask_username and not ask_password:
                break

    if last_status == 200:
        service.options["proxy-prefix"] = proxy_prefix
        service.update_config()
        print "Proxy prefix set, connected to FastScore fleet."
        return True
    elif last_status == 401:
        raise Exception("Access denied (bad credentials?)")
    else:
        raise Exception("Not connected (Is FastScore suite running?)")

def ping_url(test_url):
    if service.options["wait"]:
        sys.stdout.write("Connecting...")
        sys.stdout.flush()
        while True:
            try:
                r = requests.get(test_url, verify=False, cookies=service.cookies())
                if r.status_code == 200 or r.status_code == 401:
                    break
                progress_char = ":"
            except requests.ConnectionError:
                progress_char = "."
            sys.stdout.write(progress_char)
            sys.stdout.flush()
            sleep(0.5)
        print " done"
    else:
        r = requests.get(test_url, verify=False)
    return r.status_code
