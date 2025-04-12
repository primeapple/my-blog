---
title: "Event Sourcing - The current is the result of the past"
description: "Thoughts on the practice of Event Sourcing in software development, how it works and what I might be using it for. Also contains some bits about CQRS."
publishDate: "2025-04-12"
tags: ["programming"]
---

In my very first job as a software developer I came across a very strange architecture.
We were building a SaaS application for data analysts, built on top of the "Data Cloud" platform "Snowflake".

I had no idea about the domain but the biggest surprise was the way our backend was modeled.
We used Java and the whole application was built not on Spring Boot but on an unconventional, home-brewed system, that was described to me as based on "CQRS".
Back then I had now idea what this was about.
I saw functions that were annotated as `@Query` for reads or `@Command` for all the other stuff and that was about it.

What really hit me was the usage of an `events` table in our database.
In there we noted every `Query` and `Command` call, together with  parameters and some surrounding context.
They told me they did created because of "debugging" in case something weird may have happened.
I didn't think much of it and moved to the frontend soon after, which caused me to forget all of this.

At least until today.
I was listening a podcast for a video that I have long procrastinated on.
The title is [Event-Sourcing – das einzige Video, das Du brauchst](https://www.youtube.com/watch?v=ss9wnixCGRY) (Event Sourcing - the only video you will need) by Golo Roden of "the native web GmbH".
Sadly it is originally voiced in German but has an automatic translation to English available.
The term `Event Sourcing` sounded very theoretically (which is why I ignored it so long) but OMG am I happy to have listened to it.
I'll give you a short overview on how I understood it.

## Event Sourcing
I understood Event Sourcing as the process of storing every single event that changes the state of the application.
Contrary to the CRUD pattern, where changes are immediately executed, we only create the information which data was changed.
Even further we don't store the technical terms (`Deleted spouse "Jessica"`, `Updated state_of_relationship to "single"`) we store the terms of the domain (`Ended relationship with Jessica`).
The current state of the application now can be computed by executing all the stored events in order.
Some (but certainly not all) advantages are:

1. Allowing fine grained analysis of data flow, useful for computing additional insights in the business.
2. Changing the history and analyzing how the present would have looked if Jessica didn't get to meet Jim at the Christmas party
3. Creating multiple current views of the current state for different use cases (e.g. create a separate table for each data fetching endpoint)

There certainly also are problems compared to the usual CRUD pattern.
The biggest of them all seems to be unfamiliarity with the method.<br>
[Grug Brained Developer](https://grugbrain.dev/) wants to update row when user clicks "Update".<br>
[Grug Brained Developer](https://grugbrain.dev/) wants to add row when user clicks "+" sign.<br>
[Grug Brained Developer](https://grugbrain.dev/) wants to delete row when user clicks the trash bin.<br>
(I really hope you understand the reference, if not don't judge me to harshly, I'm young and like the memes.)

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
My old company that I mentioned in the beginning tried it's best, but in retrospect even they only used a little glimpse of what would be possible by relying only on Event Sourcing for the application state.

I took some time today to think about a good problem to use this technique on (just as we programmers do, finding the right problem for our wanted solution).
I came to the conclusion that it is perfect for online/offline use cases.
Even better for workflows where asynchrony is involved.

The perfect example that came into my mind is Git.<br>
It keeps track of a series of changes (`commits`).<br>
It allows for work even when the central data source (often called `origin`) is not available, still allowing for later integration.<br>
It is based on the ability to "time travel" back to previous states.

Great, now I want to build my future business on top of git.<br>
On the bright side users can see the history of any of their actions.
On the dark side, I'll probably have to develop it all alone.
