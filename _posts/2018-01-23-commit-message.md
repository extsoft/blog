---
layout: post
title: "A message of the commit"
description: "My personal rule to check correctness of a commit message."
tags: [git, commit message, tips & tricks]
comments: true
---
Probably you know if I run `git log` within a git repository, I could read a story of life. And I like this kind of stories because they show you everything about the code I may work with. From the other side, if I run `git commit`, I will add a new chapter to the story. And someone else will read it. That's why I need to make sure the commit message, I wrote, will be a useful chapter.

There are a lot of materials about how to write good messages of commits like [this](https://chris.beams.io/posts/git-commit/) and [this](https://wiki.openstack.org/wiki/GitCommitMessages) and [this](https://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message) and many others. Although they all are useful, my brain is limited and it can't remember all of the recommendations. That's why I created my own rule. As you remember, commit message has two parts: a subject and a body which is optional. My personal rule says:
> Subject describes a task I have to solve while body explains why this particular implementation is used.

This simple rule leads to the following conclusion: I can rely on the commit messages of a repository to understand why some particular line of code lives in a particular file. And no other information is required (like issue tracker, wikis, etc.).

In addition, a set of commits between a new tag and the previous one is a release scope. And I can use the commit messages as a release notes. As you know, release notes are read by non-tech people also. That's why the commit message has... I hope you understand the idea of the rule above.
