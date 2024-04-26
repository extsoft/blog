---
layout: post
title: "Extending monitoring capabilities of SNMP-enabled device"
description: "We will take a look at the standard abilities that can be used for monitoring the SNMP-enabled devices on your network. Then, will discover the ways of adding custom metrics together with some practical example."
tags: [snmp, monitoring]
comments: true
modified: 2018-04-11
---

SNMP protocol is the internet standard often used a monitoring instrument. This happens because it’s a widespread tool within IP/TCP networks. And there are plenty different devices supporting it like switches, routers, surveillance camera and other devices, including IoT staffs.

[How it works](#how-it-works)|[Adding custom metric](#adding-custom-metric)|[Experiments](#experiments)|[Conclusion](#conclusion)

How it works
============
A device has a working daemon which allows communication capabilities defined by SNMP protocol. Then, it's possible to send the queries to the daemon using UDP protocol. If the daemon is capable to answer, it sends back the requested information. Please take into account that SNMP works over TCP and other protocols, it is most commonly used over UDP that is connectionless – both for performance reasons, and to minimize the additional load on a potentially troubled network that protocols like TCP impose.

All the information inside the daemon is structured in the Management Information Base (MIB). Each element of this database is an object which represents a piece of information or group of other objects. The path of an object in the MIB is called [object identifier (OID)](http://oid-info.com/#oid).

OID has a textual representation (like `iso.identified-organization.dod.internet.private.enterprise.2021.memory`) and numerical (like `1.3.6.1.4.1.2021.4`). And there are several commands which allow getting information from an SNMP daemon. `snmpwalk` allows retrieving a subtree of management values while `snmpget` queries for specific value of OID. `snmptranslate` translates MIB OID names between numeric and textual forms. Please take a look at the following video to see tools in action.

<iframe width="560" height="315" src="https://www.youtube.com/embed/fD4CZY7gI_Q" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

Adding custom metric
====================
Sometimes there is a necessity to retrieve some specific value of a device. And SNMP has extending capabilities. 
For instance, you would like to know how many Python's processes are run. Then, you need to add `extend python /bin/bash -c "ps | grep -c 'python'"` to `/etc/snmp/snmpd.conf` file and restart the SNMP daemon. After this, you need to walk through the `NET-SNMP-EXTEND-MIB::nsExtendObjects` OID and find out the desired textual OID. Using `snmptranslate` the numerical OID can be loaded for given textual OID. It's simple, isn't it?

In general, you can configure any command you like. The video below demonstrates one more sample when a specific bash script is used.
<iframe width="560" height="315" src="https://www.youtube.com/embed/eDVD_Uyc10Q" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>


Please be careful while configuring the different extension. It’s too important to measure how long a command you would like to use is working. Monitoring frequency has to be greater than an execution time of the command.

For instance, there is a log file like:
```
2018-03-30 22:16:24,139 INFO Handling the "/" request...
2018-03-30 22:16:24,139 INFO My Hostname is ”test"
2018-03-30 22:16:24,140 INFO current index is 0
2018-03-30 22:16:24,140 INFO I have been seen 1 times
2018-03-30 22:16:24,140 INFO HTML: <p>1</p>
2018-03-30 22:16:24,164 INFO Handling the "/" request...
2018-03-30 22:16:24,165 INFO My Hostname is " test "
2018-03-30 22:16:24,165 INFO current index is 1
2018-03-30 22:16:24,140 INFO I have been seen 2 times
.....
```  
The goal is to get `2` following by `seen ` from `2018-03-30 22:16:24,140 INFO I have been seen 2 times`. There are at least couple solutions:
1. `grep 'times' logfile | tail -1 | egrep -o '[0-9]+' | tail -1`
2. `egrep -o '[0-9]+ t' logfile | tail -1 | egrep -o '[0-9]+'`
3. `awk '/[0-9]+ t/ {a=$8} END {print a}' logfile`

The tests show that **first solution is 4 times faster than other ones**. The table below provides benchmark data for this conclusion.

| File | #1, seconds | #2, seconds | #3, seconds |
|:----:|:-----:|:-----:|:-----:|
| 2.6M | 0.054 | 0.191 | 0.184 |
|---
| 5.3M | 0.089 | 0.339 | 0.353 |
|---
| 7.9M | 0.118 | 0.503 | 0.524 |
{: rules="groups"}

Experiments
===========
If you wish to have some experiments, just create the 4 files (see below) and run `vagrant up --provision`. Once VM will be ready, you can try to open [http://192.168.33.11:5000](http://192.168.33.11:5000). As the result, you have to see some number on the page. Then, just run one of SNMP tools like `snmpwalk -v2c -c pwd 192.168.33.11 NET-SNMP-EXTEND-MIB::nsExtendObjects` or do something other is interesting to you. Use `vagrant destroy -f` to remove the created environment.

Vagrantfile
-----------
```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.network "private_network", ip: "192.168.33.11"

  config.vm.provision "deploy", type: "shell", inline: <<-SHELL
    apt-get -y update
    apt-get -y install python-pip snmp snmp-mibs-downloader snmpd

    mkdir -p /etc/app

    # custom script
    cp /vagrant/analytic.sh /etc/app
    chmod +x /etc/app/analytic.sh
    cp /vagrant/snmpd.conf /etc/snmp/snmpd.conf
    service snmpd restart

    # application setup
    pip install flask
    cd /etc/app
    cp /vagrant/app.py .
    # application run
    python app.py & sleep 2
    for i in {1..20000}; do curl -s 192.168.33.11:5000; sleep 1; done &
  SHELL
end
```

app.py
------
```python
import socket
import logging

from flask import Flask

logger = logging.getLogger('myapp')
hdlr = logging.FileHandler('app.log')
formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
hdlr.setFormatter(formatter)
logger.addHandler(hdlr)
logger.setLevel(logging.INFO)

app = Flask(__name__)


class Hits:
    def __init__(self):
        self._count = 0

    def one_more(self):
        self._count += 1

    def current(self):
        return self._count


hits = Hits()


@app.route('/')
def hello():
    logger.info('Handling the "/" request...')
    logger.info('My Hostname is "%s"', socket.gethostname())
    logger.info('current index is %s', hits.current())
    hits.one_more()
    logger.info('I have been seen %s times', hits.current())
    html = '<p>{}</p>'.format(hits.current())
    logger.info('HTML: %s', html)
    return html


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
```

analytic.sh
-----------
```bash
#!/bin/bash -e

req="$1"

if [ "$req" == "last" ]; then ask="times"; fi
if [ "$req" == "prev" ]; then ask="index is"; fi
if [ -z "$ask" ]; then
    echo "Wrong request: $req"
    exit 101
fi
echo $(grep "${ask}" /etc/app/app.log | tail -1 | egrep -o '[0-9]+' | tail -1)
exit 0
```

snmpd.conf
----------
```
rocommunity  pwd
syslocation  "Dmytro Serdiuk"
syscontact  dmytro@email.com

extend prev /etc/app/analytic.sh prev
extend last /etc/app/analytic.sh last
```

Useful OIDs
=========== 

| Description | OID |
|:-----|:----|
| Network interfaces | `1.3.6.1.2.1.2.2.1` |
| Memory             | `1.3.6.1.4.1.2021.4` |
| Load               | `1.3.6.1.4.1.2021.10` |
| CPU                | `1.3.6.1.4.1.2021.11` |
{: rules="groups"}

To find out more, please visit [http://oid-info.com](http://oid-info.com). 

Conclusion
==========
SNMP is a powerful tool for getting metrics from the devices. You can use either integrate SNMP with an existing monitoring tool or write your own monitoring using `python` + `easysnmp`. It fits with the goals of long-term monitoring as well as with short-term monitoring for performance testing etc. Also, there are a lot of cases when SNMP is only the one way to test or monitor network devices.

As you may notice, in the examples above SNMP  version `2c` is used. If you take care of security aspects, please use version `3`. The material below can give you more insights about also. 

**Further reading**

General info
- [https://en.wikipedia.org/wiki/Simple_Network_Management_Protocol](https://en.wikipedia.org/wiki/Simple_Network_Management_Protocol)
- [http://net-snmp.sourceforge.net/](http://net-snmp.sourceforge.net/) 
- [http://www.net-snmp.org/docs/FAQ.html](http://www.net-snmp.org/docs/FAQ.html)
- [https://technet.microsoft.com/en-us/library/cc776379(v=ws.10).aspx](https://technet.microsoft.com/en-us/library/cc776379(v=ws.10).aspx)
- [https://technet.microsoft.com/en-us/library/cc783142(v=ws.10).aspx](https://technet.microsoft.com/en-us/library/cc783142(v=ws.10).aspx)
- [http://oid-info.com](http://oid-info.com)

Architecture
- [http://www.ietf.org/rfc/rfc2571.txt](http://www.ietf.org/rfc/rfc2571.txt)
- [http://www.ietf.org/rfc/rfc1901.txt](http://www.ietf.org/rfc/rfc1901.txt)
- [http://www.ietf.org/rfc/rfc1157.txt](http://www.ietf.org/rfc/rfc1157.txt)


Extending
- [http://net-snmp.sourceforge.net/wiki/index.php/Tut:Extending_snmpd_using_shell_scripts](http://net-snmp.sourceforge.net/wiki/index.php/Tut:Extending_snmpd_using_shell_scripts)
- [http://net-snmp.sourceforge.net/docs/man/snmpd.conf.html](http://net-snmp.sourceforge.net/docs/man/snmpd.conf.html)
