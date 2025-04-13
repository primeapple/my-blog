---
title: "Event Sourcing - The current is the result of the past"
description: "Thoughts on the practice of Event Sourcing in software development, how it works and what I might be using it for. Also contains some bits about CQRS."
publishDate: "2025-04-12"
updatedDate: "2025-04-13"
tags: ["programming"]
---

In my very first job as a software developer I came across a very strange architecture.
We were building a SaaS application for data analysts, built on top of the "Data Cloud" platform "Snowflake".

I had no idea about the domain but the biggest surprise was the way our backend was modeled.
We used Java and the whole application was built not on Spring Boot but on an home-brewed system, that was described to me as based on "CQRS".
Back then I had now idea what this was about.
I saw functions that were annotated as `@Query` for reads or `@Command` for all the other stuff and that was about it.

With all of that I could deal, but what really hit me was the usage of an `events` table in our database.
In there we noted every `Query` and `Command` call, together with  parameters and some surrounding context.
They told me they did so because of "debugging", so in case something weird has happened we could see what operations led to this point.
I didn't think much of it and moved to the frontend soon after, which caused me to forget all of this.

At least until today.
I was listening a podcast for a video that I have long procrastinated on.
The title is [Event-Sourcing – das einzige Video, das Du brauchst](https://www.youtube.com/watch?v=ss9wnixCGRY) (Event Sourcing - the only video you will need) by Golo Roden of "the native web GmbH".
It is originally voiced in German but has an automatic translation to English available.
The term `Event Sourcing` sounded very theoretically (which is why I ignored it so long) but OMG am I happy to have listened to it.
I'll give you a short overview on how I understood it.

## Event Sourcing
I understood Event Sourcing as the process of storing every single event that changes the state of the application.
Contrary to the CRUD pattern, where changes are immediately executed, we only create the information which data was changed.
Even further we don't store the technical terms (`Deleted spouse "Jessica"`, `Updated state_of_relationship to "single"`) we store the terms of the domain (`Ended relationship with Jessica`).
The current state of the application now can be computed by executing all the stored events in order.

Golo uses the analogy of a bank account.
There the current balance is calculated by the chain of transactions that happened since the start of your account at this bank.
If there was an error, a bank will not "update" your account, but rather add a new transaction to the chain, fixing the problem and bringing the balance back in check.<br>
That allows for scenarios where it is possible to hurt data consistency in the current moment to allow for special use cases.
Think of a vending machine that is currently offline because of a networking problem.
Wouldn't it be amazing if you can still withdraw money?<br>
Event Sourcing makes it possible (the bank can get the money back with interest later).

Some other advantages that were brought up are:

1. Allowing fine grained analysis of data flow, useful for computing additional insights in the business.
2. Changing the history and analyzing how the present would have looked if Jessica didn't get to meet Jim at the Christmas party.
3. Creating multiple current views of the current state for different use cases (e.g. create a separate table for each data fetching endpoint).

There certainly also are problems compared to the usual CRUD pattern.
The biggest of them all seems to be unfamiliarity with the method.<br>
[Grug Brained Developer](https://grugbrain.dev/) wants to update row when user clicks "Update".<br>
[Grug Brained Developer](https://grugbrain.dev/) wants to add row when user clicks "+" sign.<br>
[Grug Brained Developer](https://grugbrain.dev/) wants to delete row when user clicks the trash bin.<br>
(I really hope you understand the reference, if not don't judge me to harshly, I'm young and here only for the memes.)

All in all something clicked in me.
Event Sourcing might not be the holy grail.
But CRUD isn't it either.
And I certainly had cases where adding some kind of "history" to my application state after it was already in use caused me tremendous problems.
Event Sourcing might have really helped me with that.

And since I got really hyped by the video I clicked the [next one](https://www.youtube.com/watch?v=hP-2ojGfd-Q). It was about:

## CQRS
So this term stands for "Command Query Responsibility Segregation".
This "seems" clear, we divide our API into Write (Command) and Read (Query).
What wasn't clear to me was the reason for this:
We are now able segregate the data models for Writes and Reads.

For example the model for any Command could be the mentioned "Event Sourcing".
Now every write just adds yet another event to the chain.<br>
The model for Query depends on the use case.
For searching we may be able to use an Elasticsearch cluster, containing only the needed data.
Permissions could be very easily modeled through different tables per endpoint, one for each role-set.
Exports could have their own tables or even their pregenerated files.<br>
Heck you could even store data in memory to make the access even faster.

## Outlook
I fell very much in love at least with the concept of event sourcing.
My main concern is finding people that understand this concept and are able to develop without drifting into CRUD when the pressure becomes high.
My old company that I mentioned in the beginning did it's best, but in retrospect even they only used a little glimpse of what would be possible by relying only on Event Sourcing for the application state.

Why is this practice so seldom found in the current software development landscape?
It may be because it forces you to really think about your domain and get an overview over the most important operations that may happen.
That seems not to fit into the very "agile" wave of development we are currently riding on.

I took some time today to think about a good problem to use this technique on (just as we programmers do, finding the right problem for our wanted solution).
The conclusion I came to is that Event Sourcing & CQRS seems perfect for online/offline use cases.
Even better for workflows where asynchrony is involved.

The perfect example that came into my mind is Git.<br>
It keeps track of a series of changes (`commits`).<br>
It allows for work even when the central data source (often called `origin`) is not available, still allowing for later integration.<br>
It is based on the ability to "time travel" back to previous states.

Great, now I want to build my future business on top of git.<br>
On the bright side users can see the history of any of their actions.<br>
On the dark side, finding fellow developers to join me on this way seems to be rather hard, so I might have to do it on my own.

<hr>

PS: Damn you Jessica, we had everything we ever wanted 🥹. F*** you Jim! 😠

PPS: Just kidding my wife and me are fine. Mostly because she is not like Jessica (and I'm not like Jim 😉).
