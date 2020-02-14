---
layout: post
title: "Image-driven CI/CD pipeline"
description: "Building a CI/CD pipeline that uses Docker and an interpreted programming language is not so simple task as it looks at the beginning. Here's one of the useful approaches..."
tags: [docker, python, cicd]
comments: true
---
In the era of wide adoption of CI/CD and microservices, a software engineer often needs to create
a piece of code and to configure a proper CI/CD pipeline that aims to a produce high-quality Docker
image. Docker provides such a great feature as [multi-stage builds][1] which simplifies pipeline
configuration for compiled programming languages like Java, Golang, etc. But it is still a
challenge to make a robust and fast pipeline for the interpreted programming languages like Python,
Ruby, etc. Let’s see what a Docker pipeline is for an interpreted programing language. You will
see a solution which is successfully used during the last several years.

# Setting a scene
Suppose, you're working on a Python project (put here your interpreted language; all examples are
Python-based, but you can easily adapt them to your stack) . It has several quality gates
that ensure delivering a high-quality solution. As
[Python is an interpreted and dynamically typed language][2], there is a big chance to write a
non-working code and you will know about something goes wrong only when you try to run code. That’s
why, in order to reduce as many errors as possible, you may configure the following stuff:
- style verifications for checking code formatting and imports order ([Black][3], [isort][4], etc.)
- static analysis for bugs hunting ([wemake-python-styleguide][5] which combines [Flake8][6],
[pydocstyle][7] and other tools; [mypy][8] for types misuse evaluation; etc.)
- unit testing for proofing that units of code are working as expected ([pytest][9], [unittest][10],
etc.)

This is not a complete list of what can be included in the quality gates for a Python codebase, but,
in most cases, this is a good starting point.

All these quality gates have to be configured and executed locally during the development. And, of
course, we need a continuous integration (CI) server for verifying of a change request - a guard
who never sleeps.

# Regular pipeline for Python app
In this case, the goal of the CI/CD pipeline is to deliver a code that passes the quality gates.
And a process of achieving this is just checking the gateways against the codebase.

So, it's pretty straightforward:
{% capture images %} /images/001/1.png {% endcapture %}
{% include gallery images=images caption="" cols=1 %}

From the technical side, it looks like the execution of the following commands (or similar depending
on what tools are used):
```bash
# 1. style verification
python -m black --check thenumbers tests
python -m isort --check-only --recursive thenumbers tests
# 2. static analysis
python -m flake8 thenumbers
python -m mypy thenumbers
# 3. unit testing
python -m pytest tests
```
Once all checks are passed, the code is good enough to be delivered for review (if the quality
gates pass locally) or considered for merging (if they pass on a CI server). And, since the CI/CD
pipeline delivers code, it’s enough.

# Regular pipeline for Python app + Docker
If a Docker is used, the pipeline aims to ship a Docker image instead of the code - it’s a major
difference comparing to the previous one. “Okay, no problems!” you can say and add steps for
building and pushing Docker image to the previous pipeline. Or maybe even three steps: first builds
an image, second does [a smoke testing][11] to check the image operability, and third pushes the
image.
{% capture images %} /images/001/2.png {% endcapture %}
{% include gallery images=images caption="" cols=1 %}

This pipeline will work! However, there are several reasons why this approach is not the best one:
1. You will know if an image can be built or not only on the 4th stage. It is too late as the
objective of the pipeline is delivering the image. And even having the best code ever written is
nothing if the image build is failed.
2. Since Docker is involved only from the 4th step,
    1. you need to support 2 environment configurations: first for assessing the code and second for
working with Docker.
    2. the first three steps aren’t executed in an isolation. This may lead to unstable work of
quality gates as the runtime of used environments (local dev, CI server, etc.) can be different.

Sometimes, such disadvantages are solved by moving the whole pipeline within a Dockerfile. So, 4
first steps are executed during the image creation. And if they are passed, the image is built. But
in this case, the final image has a lot of production-useless stuff (such as linters, tests,
execution reports, etc.) that may significantly affect image size and even production operability.

That’s why a Docker pipeline requires another solution than just adding new steps to the existing
non-Docker pipeline.

# Image-driven CI/CD pipeline for Python code
The main ideas for this pipeline are
1. Start from Docker to find critical things first
2. Use Docker as match as possible to get more isolation

And they reflect the pipeline in the following way:
￼{% capture images %} /images/001/3.png {% endcapture %}
{% include gallery images=images caption="" cols=1 %}

From the technical side, the output of step #1 is a Docker image. This image runs as a container
for the execution of steps #2-4. If they are passed, step #5 spins one more container for
checking images operability. Finally, the image is pushed to a Docker register.

Key benefits are:
1. The whole pipeline requires only Docker installation for the execution.
2. The pipeline is [idempotent][16] which reduces development and maintenance costs.
3. The pipeline produces a high-quality production-ready Docker image.

# Show me the code!
There is a Python project called ["Number API"][12]. It provides two endpoints that can generate
even and random numbers. Let's see how **image-driven CI/CD pipeline** is implemented there.

The actions needed for the pipeline are described as a shell script called `workflows`. This script
defines atomic functions to perform a single action and composite functions to run some composition
of actions. In order to run the whole pipeline, you need to run
```
# steps 1-5
./workflows quality_pipeline
# step 6
./workflows publish_image
```

`./workflows quality_pipeline` creates a Docker image (step #1) by running command like
```bash
docker build --no-cache
    --tag numbers-api:latest \
    --label commit=fbc4a2fb94d13bf5196fe9568ca2ae93bb9f2abf \
    --label branch=HEAD \
    --label version=unknown \
    .
```
The created image is a production-ready artifact that follows Docker and security best practices.
After, it's used for spinning a container for code verification (steps #2-#4) by running
```bash
docker run --rm \
    # mount all needed files
    -v $(pwd)/tests:/home/thenumbers/tests \
    -v $(pwd)/.flake8:/home/thenumbers/.flake8 \
    -v $(pwd)/.isort.cfg:/home/thenumbers/.isort.cfg \
    -v $(pwd)/requirements-test.txt:/home/thenumbers/requirements-test.txt \
    -v $(pwd)/workflows:/home/thenumbers/workflows \
    # configure working directory
    --workdir /home/thenumbers \
    # set the entry program
    --entrypoint ./workflows \
    # switch to root user as default user can't call "apk" command
    --user root \
    numbers-api:latest \
    # install required system dependencies
    "apk add --virtual .build-deps gcc musl-dev sudo" \
    # switch to default user
    "sudo --user thenumbers sh" \
    # install required Python dependencies
    "python -m pip install --user --no-cache-dir --no-warn-script-location -r requirements-test.txt" \
    # run verifications ("assess_code" is a function from "workflows" script)
    assess_code
```
The container will stop once all verifications are completed. If the exit code is 0 (means code
has expected quality), the next container will be started to check image operability (step #5) by
checking container health status.

In [the `Dockerfile`][13], the [`HEALTHCHECK` instruction][14] describes that the container is
healthy if the `/random` endpoint works; otherwise, there are problems. The verifications itself
are implemented in `assess_image_health` function (see [`workflows` script][15]). Approximate
execution logic looks like
```bash
attempt=0
# run container
docker run -itd --rm --name test numbers-api:latest
# run cycle until status becomes healthy
while [ ! $(docker inspect --format='{{json .State.Health.Status}}' test) = "\"healthy\"" ]; do
    attempt=$((attempt+1))
    verbose_execution sleep 2s
    # exit with an error if execution time is more than 20 seconds
    if [ ${attempt} -gt 10 ]; then
        echo "The container is not healthy. Something goes wrong..."
        docker logs test
        docker stop test
        exit 1
    fi
done
docker stop test
```
Finally, if step #5 is completed, the image will be tagged correspondingly to Github Docker
register requirements and pushed - step #6.
```bash
# for a new Git tag
docker tag numbers-api:latest docker.pkg.github.com/extsoft/numbers-api/app:latest
docker push docker.pkg.github.com/extsoft/numbers-api/app:latest
docker tag numbers-api:latest docker.pkg.github.com/extsoft/numbers-api/app:1.0.3
docker push docker.pkg.github.com/extsoft/numbers-api/app:1.0.3
```
And, the pushing works only for the `master` branch or a new Git tag.

# Conclusion
**Image-driven CI/CD pipeline** is a great option for any of interpreted programming languages.
It utilizes all power of Docker, delivers high-quality Docker images, and works identically on the
development and CI environment. All these benefits speed up the development process and reduce
maintenance efforts. Feel free to adapt a given solution ([https://github.com/extsoft/numbers-api][12]
is available under MIT license) for your needs or even use it as a template for the next project.

[1]: https://docs.docker.com/develop/develop-images/multistage-build/
[2]: https://en.wikipedia.org/wiki/Python_(programming_language)
[3]: https://black.readthedocs.io
[4]: https://isort.readthedocs.io
[5]: https://wemake-python-stylegui.de/
[6]: http://flake8.pycqa.org
[7]: http://pycodestyle.pycqa.org
[8]: https://mypy.readthedocs.io
[9]: https://docs.pytest.org
[10]: https://docs.python.org/3/library/unittest.html
[11]: https://en.wikipedia.org/wiki/Smoke_testing_(software)
[12]: https://github.com/extsoft/numbers-api
[13]: https://docs.docker.com/engine/reference/builder/#healthcheck
[14]: https://github.com/extsoft/numbers-api/blob/master/Dockerfile
[15]: https://github.com/extsoft/numbers-api/blob/master/workflows
[16]: https://en.wikipedia.org/wiki/Idempotence
