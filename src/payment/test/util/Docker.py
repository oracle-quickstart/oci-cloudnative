import re
from subprocess import Popen, PIPE
from random import random
import time

# From http://blog.bordage.pro/avoid-docker-py/
class Docker:
    def kill_and_remove(self, ctr_name):
        command = ['docker', 'rm', '-f', ctr_name]
        try:
            self.execute(command)
            return True
        except RuntimeError as e:
            print(e)
            return False

    def random_container_name(self, prefix):
        retstr = prefix + '-'
        for i in range(5):
            retstr += chr(int(round(random() * (122-97) + 97)))
        return retstr

    def get_container_ip(self, ctr_name):
        self.waitForContainerToStart(ctr_name)
        command = ['docker', 'inspect',
                   '--format', '\'{{.NetworkSettings.IPAddress}}\'',
                   ctr_name]
        return re.sub(r'[^0-9.]*', '', self.execute(command))

    def execute(self, command, dump_streams=False):
        print("Running: " + ' '.join(command))
        p = Popen(command, stdout=PIPE, stderr=PIPE)
        out, err = p.communicate()
        if dump_streams == True:
            print(out.decode('utf-8'))
            print(err.decode('utf-8'))
        return str(out.decode('utf-8'))

    def start_container(self, container_name="", image="", cmd="", host=""):
        command = ['docker', 'run', '-d', '-h', host, '--name', container_name, image]
        self.execute(command)

    def waitForContainerToStart(self, ctr_name):
        command = ['docker', 'inspect',
                   '--format', '\'{{.State.Status}}\'',
                   ctr_name]
        status = re.sub(r'[^a-z]*', '', self.execute(command))
        while status != "running":
            time.sleep(1)
            print("Status: " + status + ". Waiting for container to start.")
            status = re.sub(r'[^a-z]*', '', self.execute(command))
