---
title: How to write an issue ticket
description: File issues that your developers can implement.
synopsis: When you file an issue for a developer to work on, you can make it easy on that developer, or
  you can make it very frustrating.
layout: layouts/article.jinja
groupOrder: 20
---
Issue tickets are a communication tool that's intended to describe an actionable goal, which can
be accomplished by an assigned developer. As with any communication tool, the person who authors
an issue ticket should eliminate as much ambiguity and confusion as possible.

We'll assemble an issue ticket in this article, moving from horribly anemic all the way to fully
actionable.

Unfortunately, many teams write useless tickets. For example, a team might define a ticket
by simply writing a short title.

![](/images/articles/operations/how-to-write-an-issue-ticket/bad-title.png)

A title is woefully inadequate to define an issue ticket. That said, let's at least improve the title.
Instead of defining an issue ticket title with a few cryptic words, make sure to include at least a
little bit of context for team members who are quickly scanning through open issues.

![](/images/articles/operations/how-to-write-an-issue-ticket/good-title.png)

The description of an issue ticket should capture the motivation for the work. This motivation helps
the assigned developer identify problems with the desired behavior. It also provides an historical
record as to why the ticket was filed in the first place.

![](/images/articles/operations/how-to-write-an-issue-ticket/good-description.png)

A description of motivation and the desired result is a great start. Sometimes that's enough for
a developer to produce expected results. However, sometimes the implemented result still needs
further clarification to eliminate ambiguities. It's cheaper to figure out those ambiguities now,
when filing the issue, than after the developer has implemented the wrong behavior.

![](/images/articles/operations/how-to-write-an-issue-ticket/best-description.png)

How long did it take to write the useless title? How long did it take to write the fully actionable
ticket? The difference is probably a matter of minutes. Yet, by fully defining an issue ticket the
developer who works on the issue won't need to go back-and-forth with the product team to figure
out the desired behavior. Additionally, the developer won't build the wrong thing before building
the right thing. By spending a few extra minutes on the issue ticket, you might save hours of
product and developer time.

In the case where filing the full ticket results in additional research or team discussion, this is
a feature, not a bug. If your team doesn't take the time to resolve issues up front, then your team
is saddling a single developer with those problems later. That's not fair to the developer, and that
developer isn't in a position to make product decisions or UX decisions.