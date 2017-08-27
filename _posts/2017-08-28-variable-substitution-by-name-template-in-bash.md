---
layout: post
title: "Variable substitution by name template in bash"
description: The article explains how to access bash variable by a name pattern.
tags: [bash, commandline]
comments: true
---

For instance, there are 3 environments potentially can be used for the automated tests. And, tests are run with a
script like `./run-my-tests.bash qa1`. The word `qa1` is an identifier of an environment (there are also two other).
Based on the environment identifier, the script has to read 2 variables to get the required configuration.
How to do that?

Let's define the environments within the script:
```bash
qa1_url="http://qa1.example.com"
qa1_port="8080"

qa2_url="http://qa2.example4.com"
qa2_port="8081"

qa3_url="http://qa3.example2.com"
qa3_port="80"
```

Next step is to evaluate environment settings based on given script's argument.
```bash
if [ "$1" == "qa1" ]; then
    echo "run tests on the $qa1_url:$qa1_port"
fi
if [ "$1" == "qa2" ]; then
    echo "run tests on the $qa2_url:$qa2_port"
fi
if [ "$1" == "qa3" ]; then
    echo "run tests on the $qa3_url:$qa3_port"
fi
```
If the script will be run with `./run-my-tests.bash qa2`, then `qa2` settings have to be used.
Great! It works! But, we have separate `if` for each environment. How can we avoid that?

Variable substitution by name template
--------------------------------------
There is a magic construction which allows evaluation of bash variable by a name template:
```bash
eval "echo -n \$${ENVIRONMENT}_url"
```

1. `eval ..."` allows executing a command in the shell
2. `"..."` encloses desired variable (`${ENVIRONMENT}`)
3. `echo -n ...` outputs the arguments without the trailing newline
4. `\$...` is used to tell to `eval` to get the variable (`ENVIRONMENT=qa1` => `$qa1_url`)
5. `${ENVIRONMENT}_url` generates variable with a suffix (`_url`) in the name

So, if `ENVIRONMENT=qa2`, then in the process of execution the construction will be
1. updated to `eval "echo -n $qa2_url"`
2. evaluated to `http://qa2.example4.com`

Conclusion
----------
Using variable substitution by name template reduces code duplication. The final version of the script you could find
below.

**run-my-tests.bash**.
```bash
#!/usr/bin/env bash

# read the user input
ENVIRONMENT=${1?"Please specify on of the environments: 'qa1' or 'qa2' or 'qa3'"}

# define a list of configurations per environment
qa1_url="http://qa1.example.com"
qa1_port="8080"

qa2_url="http://qa2.example4.com"
qa2_port="8081"

qa3_url="http://qa3.example2.com"
qa3_port="80"

URL=$(eval "echo -n \$${ENVIRONMENT}_url")
PORT=$(eval "echo -n \$${ENVIRONMENT}_port")

echo "run tests on the $URL:$PORT"
```

Sample outputs:
```bash
$ ./run-my-tests.bash
./run-my-tests.bash: line 4: 1: Please specify one of the environments: 'qa1' or 'qa2' or 'qa3'
$ ./run-my-tests.bash qa1
run tests on the http://qa1.example.com:8080
$ ./run-my-tests.bash qa2
run tests on the http://qa2.example4.com:8081
$ ./run-my-tests.bash qa3
run tests on the http://qa3.example2.com:80
```