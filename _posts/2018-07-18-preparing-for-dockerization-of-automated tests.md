---
layout: post
title: "Preparing for dockerization of automated tests"
description: "What needs to be done before trying to move automated tests to the containers?"
tags: [docker, architecture]
comments: true
---

Nowadays microservice architecture is a wide-spread approach to design digital solutions. And often the containerization is used to achieve all the benefits microservices bring up. Due to this tendency, the automated tests need to be ready for use within containers. What does it really means for a particular set of tests?

There are several containers platforms like [Docker](https://www.docker.com), [rkt](https://github.com/rkt/rkt), [Linux Containers](https://linuxcontainers.org), etc. However, all of them declare the same requirements to the source code and auxiliary tools.

# Configurability
The configurability stands for an ability to configure any options required for the successful tests execution. It can be some internal tests configurations (like timeouts, additional checks, etc.) as well as external ones (like SUT URLs, credentials, reporting system, etc.). 

The great example here is the paths for the configuration/resource files. For instance, there are resource files within the project structure, which are used in the tests. The correct paths stand for:
- a path is always relative (like `data/users.xm` or `./data/users.xm`)
- all paths are relative comparatively the same point (for instance, the working directory is a good choice)
- there are no backslashes (`\`) in a path (use `/` to split directories or files as it's supported on any platform)

Another important part is that you want to be able to edit some configuration before running the tests. The only way is to have the configuration options. That’s why you need to review your tests execution process and make everything configurable (instead of editable). For instance, there is a configuration file with different options. Before the test execution, some options have to be updated according to the environment to be used. In this case, you need to care about two things. First, it’s ability to specify a path to the configuration file. Second, provide a separate file per environment. This allows you to specify desired options by passing a path to the file as an argument to the tests execution command.

Everything that needs to be changed for a test execution, has to be configurable.

# Modularity
Let's look for the modularity from two different sides - a process of tests execution and tools to be used.

To be able to give a better explanation, I would like to describe some tests. There are WEB tests written in Java. [Selenium](http://seleniumhq.org/) is used for automation of browsers interaction. [Allure](http://allure.qatools.ru) is used as a reporting system. The email report is sent after the execution to the stakeholders. And [maven](http://maven.apache.org) controls the execution of the tests.

The process of execution of these tests will be the following:
1. prepare the Selenium infrastructure
2. run tests
3. generate Allure report
4. send email report

The main idea is that we need to be able to run each step separately as well as all of them together. Why is it so important? For instance, let's take a look for the Selenium infrastructure. I know that your tests are using a remote driver for interacting with a browser (if no, maybe [this post]({% post_url 2018-05-23-test-webdriver-browser-in-selenium-world %}) motivates you). If the tests are executed locally, they connect to a started WebDriver. If the tests are executed on Jenkins, they will connect to a [Selenium Grid](https://www.seleniumhq.org/docs/07_selenium_grid.jsp). And there can be more if-conditions. This means the process of the tests execution is different. And the properly modularized steps of execution allow you easily support several configurations. By the way, the containerization may introduce at least one more.

Step #3 is a good candidate why we need to be able to exchange the tools easily. After step #2, there is a directory with raw Allure files which are going to use for HTML report generation. Depending on the environment, different tools can be used for the report generation:
- local environment - either Allure CLI application or maven plugin can be used
- CI server - an appropriate plugin can be used
- Containers - a separate container can be used

As the result, you have to use several tools depending on the environment to achieve the same goal.

I hope the above samples show you why modularity is so important.    

# Conclusion
As practical experience shows correctly applied configurability and modularity bring a lot of benefits even if you don’t use containers for automated tests. And if at some point, you decide to move the automated tests to the containers, the process seems to be as smooth as possible.
