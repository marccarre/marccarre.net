---
layout: post
title: "Working remotely & asynchronously"
name: working-remotely-and-asynchronously
date: 2018-04-19 17:06
categories:
- management
---

## EDIT: Update as of February 2024

In April 2018, I was spending some of my time creating my own company, Sway.
At the time, a few friends and friends of friends were contributing to this
software project on their mornings, evenings and weekends. We were all working
_remotely_ and _asynchronously_ by the nature of working on a side project, on
our free time. As we progressed on this project, we started to experience
_inefficiencies_ in our collaboration, and as co-founder, I took it upon me to
try to formalise these problems, and suggest some solutions, in the form of a
guideline we could collectively follow -- the same guidelines you can read
below.

Fast-forward a few years: tech companies going full-remote is no longer rare,
[GitLab](https://handbook.gitlab.com/handbook/company/culture/all-remote/guide/)
being a known example of this trend. COVID 19 happened and changed the way many
companies worked, and these went full or partial remote for at least a few
years, and many continued to operate this way nowadays. Even non-remote global
companies work in a similar fashion, just by the nature of being distributed
across different cities, countries and/or continents.

In short, **many** now work _remotely_ and _asynchronously_, and therefore
experience the same _inefficiencies_ I was experiencing many years ago. And many
still have not found a good way to make this work for their teams, and even less
entire divisions or entire organisations.

Surprisingly (at least to me), some of what I wrote at the time stood the test
of time, applies elsewhere, and seems still relevant nowadays.

As a result, I often end up sharing this article or a copy-pasted variant of it.
May this article continue to help you and the people you work with, and if it
does, please mention it as a source to your own documents. 🙇🏻

----

## Guidelines

### 1. Provide context & Be precise

- a. **When asking for help**:

    - What are you trying to achieve?
    - What are the blockers?
        - What did you try?
        - What commands or scripts did you run? (c.f. `bash`/`zsh` history)
        - Which environment/machine/tool/version/etc. did you use?
    - What did you expect the outcome to be?
    - What happened? (full error, logs, etc.)
    - What is the ask? (e.g. help investigate, find alternative, etc. -- be
      specific! clarify what you've already tried or already know!)

<br />

- b. **When sharing an opinion**:

    Tone & emotions: this information is typically lost when chatting over
    Slack, it is therefore even easier for your message to be incorrectly
    perceived/interpreted than in face-to-face communication.

    To compensate for this:

    - explain your thinking, be extra explicit,
    - use emojis where & when relevant.

    ➡ As an "emitter", **you** are responsible for how the "receiver" gets your
    message.

<br />

- c. **Share information in the appropriate Slack channel**:

    This generally helps with context. If a communication has been clearly posted
    in the wrong slack channel, "copy and share" to the appropriate channel.

<br />

### 2. Over communicate

- a. **Push, don't pull**:

    If you don't provide information/updates/etc. spontaneously, then your
    colleagues have to _pull_ it, wait for you to see their request, for you to
    reply, and then, eventually receive the information.

    ➡ Communicate pro-actively to save everyone's time.

<br />

- b. **Work visibly**:

    Share your findings, progress, issues, documents, etc. so that people can
    keep track of what's happening, collaborate, help with problem solving,
    reproduce work/issues easily, enrich & contribute to your thinking, etc.

    ➡ Don't hesitate to use tools to automate some of this (e.g. Slack
    integrations for GitHub/GitLab) or help with this (e.g. Trello/Jira kanban
    board).

<br />

- c. **Learn as a Team**:

    A lot about startups and a lot about software engineering is "learning"
    about a business, about a problem, and about the solution to that problem.

    When you learn something, share it, document it, etc. so that we
    collectively learn, and don't have to spend time & energy learning the same
    thing again, reinventing the wheel, etc.

    When we make a decision, document the reasons, say "why", so that we can
    refer back to this later, and remember (or understand, for new joiners) the
    context we were in at the time.

    EDIT (2024-02): a good tool for this is ADRs (Architectural Decision
    Records) [[1]](https://adr.github.io)
    [[2]](https://www.thoughtworks.com/en-us/radar/techniques/lightweight-architecture-decision-records).

<br />

- d. **Document your code**:

  Other team members should be able to:
  - i. run your code.

    ➡ As you work, keep a notepad open with your notes, which you can then turn
    into docs without much effort.

    ➡ Once done with development, check your `bash`/`zsh` history, which you can
    then also turn into docs. (This approach probably requires more effort than
    the previous one, though.)

  - ii. easily modify your code:

    - avoid commented out code ➡ use branches,
    - properly name variables, functions, classes, etc.,
    - properly structure your code,
    - don't hardcode configuration ➡ allow it to be injected.

<br />

- e. **Share the commands you run & actions you perform when working towards a
  deliverable**:

    Until the process to generate a deliverable is fully automated, please share
    all the commands you run to produce each step of the deliverable, as well as
    details on the more manual operations. This can help your colleagues:

    - know the assumptions made for that step,
    - re-run a step which went wrong,
    - re-run a step which should be tweaked,
    - meet a deadline!
    - etc.

    and generally helps:

    - to learn from you,
    - to be more autonomous (e.g. while you're away or asleep),
    - to automate! (which, unless it has a ROI <0, should be the ultimate goal).

    Remember:

    ➡ "_Software should be a science, not an art_". However, it cannot be a
    science if it cannot be reproduced. Share what you did and how you did it.

    ➡ "_Civilisation advances by extending the number of important operations
    which we can perform without thinking about them_." -- Alfred North
    Whitehead.

<br />

- f. **Don't just talk in private**, share relevant information with everyone,
  so we're all on the same page.

<br />

### 3. Communicate timely & Manage expectations

- a. **Say what you do. Do what you say.**

<br />

- b. **Ideally, check Slack at least once a day**, especially look for
  notifications, threads, and direct messages.

<br />

- c. **If you are going to be unavailable or offline** for more than a day,
  clearly say so in Slack (e.g. notifying everyone, updating your status, etc.).

<br />

- d. **If you have seen a message, acknowledge it** (e.g. reply, add an Slack
  reaction, etc.)


  EDIT (2024-02): When communicating asynchronously, it is easy to miss
  messages. A simple "ack" Slack reaction confirms that you have received and
  seen this message, which helps the sender and everyone else know you know, and
  therefore know who may not be on the same page.

<br />

- e. **If a response is needed**, but you cannot provide it just yet, say so,
  and say when you expect to come back with an answer.

<br />

- f. **Respect your colleagues' time**:

  - Notify them, ideally at least 24 hours in advance, if you cannot attend a
    meeting.
  - Be on time: nobody likes to wait 15 minutes for you to join the meeting.

- g. **Update the agenda** and/or notes used for the meeting **before** the
  meeting starts (e.g. "Team - Meetings" GDoc).
  Please share:
  - What was done.
  - What we learned as a team.
  - If issues arose, what were these, and what is the plan to address them.
  - What are the new priorities.
  - What we plan to work on next.

  <br />
  ➡ It should be extra clear for everyone: what the priorities for the next week
  are, and what are the deadlines, if any.

<br />

### 4. Provide feedback & Continuously improve

- a. **Resentment builds over time** due to underlying issues not being
  addressed. Digital communication gone rogue can breed misunderstandings and
  hurt feelings.

  ➡ Provide timely feedback, privately or publicly, in a constructive way.

  ➡ Feedback is a gift: as you receive feedback, try to keep an open &
  constructive mind.

<br />

- b. **Organise retrospectives** to fix the way we work & communicate.

<br />

- c. **Periodically reflect** to avoid repeating the same mistakes.

  ➡ For each problem, try to find _preventive_ and _corrective_ measures.
