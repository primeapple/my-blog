---
title: "Detection availability of concert tickets"
description: "Using self-hosted changedetection.io service to monitor band shop for concert tickets availability. Powered by conditional XPaths."
publishDate: "2025-07-12"
updatedDate: "2025-07-1"
tags: ["programming"]
---

Recently a friend asked me for a favor related to computers.
He wanted to visit a concert but the event at the desired location was booked out already.
His question was if there is the possibility of monitoring the website, to see if the location in question gets available again.

I was very glad for this request.
Since studying computer science and becoming the "IT guy" in my friends group this is the very first problem to actually fit into my domain.
No printer installation, Windows fixes or broken hard drive repair.
I finally was asked to do something that I'm interested in myself.

It took me a few days and I had a plan.
This was the perfect excuse to finally play with [changedetection.io](https://changedetection.io/).
And since it was a shared friend convincing my wife to take some time for that was easy.

Deploying the service to my home lab was a deal of 15 minutes thanks to the magic of docker.
I did not yet add the Playwright web driver to the compose file to decrease further maintenance.
Having a look at the web interface made it clear that you don't have to be some sort of web wizard to use it.
Heck, with its automatic price extraction and restock detection feature most non technical people would probably be able to use it.
Maybe not self-hosted but certainly through a running instance.

OK, let's go back to my mission.
Originally I was expecting the page to be some sort of Single Page Application (SPA).
That would mean there is some HTTP (or similar technology) endpoint for the bookable locations.
I did not find that.
Instead the network tab showed a big, prerendered HTML page being served, together with a bunch of JavaScript Bundles, coming from the Shopify CDN.
Luckily the needed information where stored in the HTML file, so a simple HTTP call (as being done by changedetection.io) was enough, I wouldn't need to execute any scripts.

The relevant snippet looks a bit like this:
```html
<input
      type="radio"
      id="template--25107551879555__main-2-0"
      name="Stadt"
      value="Stuttgart"
      class="disabled"
>
```
That's where my trouble began.
Turns out changedetection.io monitors for text changes only and [can't extract attribute changes](https://github.com/dgtlmoon/changedetection.io/issues/2254) yet.
This is bad since in my case the snippet above is the only clear indicator for a booked event (available events are lacking the `disabled` class).
There are other hints that **might** also carry this information (such as the availability of band t-shirts with the city name on it).
But I would rather avoid such ambiguities.

So my Google-Fu brought me to the realization that it is somehow possible to add conditionals to XPath statements, at least in changedetection.io.
These can then produce text which we can observe for changes.
I added this code to the `CSS/JSONPath/JQ/XPath Filters` field in the `Filters & Triggers` page of a watch:
```
xpath:if (count(//input[@type='radio' and @value='Stuttgart' and @class="disabled"]) >0 ) then "Stuttgart is Enabled :)" else "Stuttgart is Disabled :("
```

After that I only needed to adjust some settings to send notifications to my [ntfy](https://ntfy.sh) topic.
Also I changed the check intervals to scrape the page every 1 hour as well as set up some jittering to make detecting my crawler less obvious.

Et voilà, have a lot of fun at the concert my friend.
(If the tickets ever get restocked at least :)).

For many more web observations to come!
