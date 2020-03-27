#!/usr/bin/python3
import os
import sys

from pathlib import Path

try:
    authorized_keys = Path.home() / ".ssh/authorized_keys"

    # Find the name of device
    auth_info = os.environ["SSH_AUTH_INFO_0"].strip()

    # auth_info will be like: publickey ecdsa-sha2-nistp256 AAAAE2
    _, key = auth_info.split(' ', 1)  # key = ecdsa-sha2-nistp256 AAAAE2

    for line in authorized_keys.read_text().splitlines():
        if key in line:
            idx = line.find("/rtunnel-shell ")
            device_name = line[idx + 15:].strip()
            idx = device_name.find('"')
            device_name = device_name[:idx]
            break
    else:
        sys.exit("Unable to find device name???")

    devices = Path("/devices")
    device = devices / device_name

    action = os.environ["PAM_TYPE"]
    if action == "close_session" and device.exists():
        device.unlink()
except Exception as e:
    with open("/tmp/pam.err", "w") as f:
        f.write("Unexpected: %s\n" % e)
