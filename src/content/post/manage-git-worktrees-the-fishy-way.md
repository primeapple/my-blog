---
title: "Managing git worktrees the fishy way"
description: "My opinionated git worktree flow and the fish plugin I developed for it"
publishDate: "2026-02-09"
tags: ["programming"]
---

OK. I get it. Nobody wants to read anything about AI anymore.
That's what they say, at least.
AI articles regularly top the board on Hackernews, /r/programming, the company internal Slack channel and the meetup with your former colleagues at the pizza place.<br>
Well, good news for you, this is not going go be another one.
At least not primarily 😜.

## One worktree per branch

The idea for including `git worktree` more into my personal workflow has been flying around for years now.
I was deeply impressed by one of my co-workers being able to easily switch between reviewing (my unnecessary refactoring), proving QA wrong and developing their next untyped prototype.
All that without the need for long recompiles and the pain that is `git stash`.<br>
After asking he told me that he uses `git worktree` extensively and I should as well.

> Just create a worktree for each thing you work on and you are fine!

This creates a 1-1 relationship between branches and worktrees.
And it is the perfect way to run out of disc space in no time.<br>
I did not like this workflow.
It felt overly "heavy", maybe a little "bloaty".
I don't need a worktree for adjusting a single translation.
I don't want to recreate a `main` worktree every single time when I need to check the current trunk of the repository.
I don't want to think of a place where I create the worktree on the filesystem.<br>
So I sucked it up and got better at stashing.
That solved the issue surprisingly well.

All this was way before coding agents and the idea of "concurrent" or even "parallel" work.
Who would've guessed that today we have 3 terminals open with some "next token guesser" implementing the next security hole?<br>
As it turns out stashing your changes doesn't really work if there are three of you working in the same directory.

Since I'm to poor to even think about proper hosted coding environments for agents (like [Deno Sandbox](https://deno.com/deploy/sandbox) or [Sprites.dev](https://sprites.dev/)), why not make it work locally?
I'm trying to solve the security risks via OpenCodes [Permission](https://opencode.ai/docs/permissions/) system (that's another blog post).<br>
The main interest, however, was the code duplication.
Suddenly there was a reason to dive into worktrees again.

## Having a fixed set of worktrees
I googled around and found [this blogpost](https://matklad.github.io/2024/07/25/git-worktrees.html) by Matklad (the original author of [rust-analyzer](https://github.com/rust-lang/rust-analyzer) and now member of the team developing [TigerBeetle](https://tigerbeetle.com/)).
He describes a workflow where we work on a set of fixed worktrees, one for each purpose.
There is `main` for the main branch, `work` for the actual coding, `review` for reviews.
Also he has `fuzz`, which is where he executes long running tests or checks.
Each worktree has a `parking/` branch that should only ever be checked out in this version of the repository.
That completely resonated with me.
I'm a huge fan of a limited set of options that I know by head and that sounded simple enough for me.

I quickly hacked together some git scripts to let me manage this worktree structure and went of the roads.
Since I don't work with a software that needs long test executions, I would reuse the `fuzz` worktree to let the AI do it's magic there.<br>
This approach worked for a couple months but the scripts kept getting bigger and bigger.<br>
- How to switch between worktrees?<br>
-> I added `git-switch-work|fuzz|main|...` commands<br>
- How to reset the `parking` branches for each worktree?<br>
-> Here, have your `git park` command<br>
- How do I initialize these worktrees?<br>
-> AHH fine, `git-worktree-init` it is

Now add in different default branches (`main`/`master`/`dev`/...) and the option to have more than one agent at a time running and you got the disaster.

## Introducing worktree.fish
