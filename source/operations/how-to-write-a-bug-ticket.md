---
title: How to write a bug ticket
description: File bugs that your developers can fix.
synopsis: Fixing bugs requires certain information. Learn how to file bug tickets that developers
  can fix.
layout: layouts/article.jinja
groupOrder: 4
---
There's some advice that applies to [writing all issue tickets](/operations/how-to-write-an-issue-ticket). 
Bug reports require more specific, actionable information. In the absence of that information, the 
developer might take hours or days to solve a problem that should only take minutes, or the developer 
might not be able to solve the problem at all.

Every bug report should include at least the following details:
 * The steps to take to recreate the problem, known as "reproduction steps".
 * A description of the unwanted behavior that currently occurs, known as the "actual result".
 * A description of the desired behavior, known as the "expected result".

Many teams file bug reports with nothing more than an ambiguous title.

![](/images/articles/operations/how-to-write-a-bug-ticket/bad-title.png)

A title is virtually useless. What's the specific problem? How can the developer see the problem
happen? What's supposed to happen instead? None of these things are communicated by the issue
title.

Even if a description is added after the title, an anemic description is still useless.

![](/images/articles/operations/how-to-write-a-bug-ticket/bad-description.png)

A bug issue ticket must include at least the reproduction steps, the actual result, and the expected
result.

![](/images/articles/operations/how-to-write-a-bug-ticket/good-description.png)

The reproduction steps, the actual result, and the expected result are a good basis for a bug
report. But you're not constrained by the minimum amount of information. You should consider adding
any other supplemental information that might help the developer find and solve the issue. That's
the whole point of the bug report.

![](/images/articles/operations/how-to-write-a-bug-ticket/best-description.png)

Write your bug reports to accelerate the fix as much as possible. It takes minutes to write a good
bug report, and a good bug report can save hours or days of development time.