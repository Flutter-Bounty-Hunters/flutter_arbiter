---
title: How to file a Pull Request
description: How to file pull requests that your team wants to review.
synopsis: Code needs to be reviewed before its merged. Learn how to make that process easier on your team.
layout: layouts/article.jinja
groupOrder: 5
---
Changes to code should take place through Pull Requests (PR). When they do, all changes should be reviewed,
both for technical correctness, as well as an appropriate approach.

A PR review can be easy, or it can be difficult, that's up to how you draft it. This article
begins with a PR that no one would want to review and evolves it into a PR that anyone could review.

## You're the first reviewer
Don't ask someone else to review your code if you haven't reviewed it first, yourself.

First, your own review will catch numerous obvious mistakes. You'll find commented code that you
should have deleted. You'll find TODOs that still need to be handled. You'll find messes of
unintelligible code that you need to refactor and comment. You'll realize that you forgot to add
Dart Docs to your new classes and methods. Don't make another developer spend time catching these
obvious oversights.

Second, if reviewing your own PR takes a while, and feels tedious, then that's a great sign that
you're asking a reviewer to do too much. You know how your code works, a reviewer doesn't, if you
can't handle what's in your PR, how do you expect someone else to handle it?

## Fewest changes that solve the problem
Imagine opening a PR for review and finding that you'll need to review dozens of changed files, with
hundreds or thousands of changed lines of code. Would you be excited to review it?

![](/images/articles/operations/how-to-file-a-pull-request/large-pr.png)

Code reviewers are human, too. They can't fit hundreds of lines of code, dozens of classes, and
numerous files in their heads at one time. When you ask a developer to review a huge change, you're
either asking that developer to invest a huge amount of time, or you're asking that developer to
skimp on the review, or both.

Submit the minimum changes necessary to solve the given problem. If that's still a lot of changes,
then attempt to break the problem down into smaller problems and solve those one PR at a time.

![](/images/articles/operations/how-to-file-a-pull-request/small-pr.png)

## Begin with a descriptive title
A reviewer's first exposure to a PR is the title. The title should clearly describe the goal of
the PR. If you're unable to concisely describe your PR in the title, that's a good indication
that something is wrong with the scope of the PR.

![](/images/articles/operations/how-to-file-a-pull-request/bad-title.png)

A good title captures the motivation and the subject of the proposed code change.

![](/images/articles/operations/how-to-file-a-pull-request/good-title.png)

## Describe the motivation and approach
The description of a PR is the most critical part. Unfortunately, many developers leave the PR 
description blank. **This should never happen.**

![](/images/articles/operations/how-to-file-a-pull-request/empty-description.png)

A PR description should clearly describe the motivation and the approach of code under review. If
there were multiple possible approaches, describe why you chose the one that you did. Describe any
tradeoffs that your approach requires. Describe any temporary hacks that you may have placed in the
code. Prepare the reviewer for what he is about to review.

![](/images/articles/operations/how-to-file-a-pull-request/good-description.png)

## Clarify with images and videos
A text description is useful, but sometimes it takes a paragraph of text to convey a simple idea.

When words aren't the best way to communicate, use supplemental images and videos to prepare your
reviewer to understand your code changes.

![](/images/articles/operations/how-to-file-a-pull-request/description-with-video.png)