#!/usr/bin/env python
import psutil
import time
import string

import subprocess
import signal
import os

a= 9999999999999

perf = subprocess.Popen(["perf","stat","-p",str(os.getpid())],stderr=subprocess.PIPE)

a=a/2

if os.fork():
        time.sleep(0.1)
        perf.send_signal(signal.SIGINT)
        exit (0)

print ("got perf stats>>{}<<".format(perf.stderr.read().decode("utf-8")))

