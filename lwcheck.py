import sys
import logging
import logging.handlers
import os
import subprocess


def main():
   hostname = os.uname()[1]
   osversion = os.uname()[2]
   mail = logging.getLogger("mylogger")
   mail.setLevel(logging.DEBUG)
   config = logging.handlers.SMTPHandler(mailhost='10.0.0.1', fromaddr='cluster@contoso.com', toaddrs=['everybody@contoso.com'], subject='Isilon Process log')
   config.setLevel(logging.INFO)
   mail.addHandler(config)
   try:
      countpr = subprocess.Popen ("/usr/likewise/bin/lwsm list|/usr/bin/wc -l", shell=True, stdout=subprocess.PIPE)
      allpr = countpr.stdout.read()
      counrrun = subprocess.Popen ("/usr/likewise/bin/lwsm list|/usr/bin/egrep \"running|refresh\"|/usr/bin/wc -l", shell=True, stdout=subprocess.PIPE)
      runpr = counrrun.stdout.read()
      if (runpr != allpr):
         mail.info("Not all LikeWise processes are running on " +hostname)
      else:
         return False
   except:
      mail.info("Process check failed on " +hostname)
   else:
      sys.exit(2)

main()
