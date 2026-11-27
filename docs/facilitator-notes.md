# Facilitator preparation and session notes

These are Bonface's working notes for the remote workshop. They are a proposed
delivery plan, not a claim that Benson has approved every time allocation or
assigned role below. Confirm handoffs together before the session.

**Updated approach:** begin with the improved app, collect feedback, and invite
designers to find/create suitable icons in Inkscape. Bonface facilitates and
leads the app demo/practical coordination; Benson is the intended lead for the
concept lessons, based on the materials and lesson plan in his emails. Confirm
individual teaching slots rather than treating that inference as a formal assignment.
Keep [facilitator talking points](facilitator-talking-points.md) open for the live call.

## 1. Purpose and outcomes

By the end, participants should be able to explain the relationship between
Scheme, Gambit, LambdaNative and F-Droid; try a working app; report useful
feedback; read/change a small Scheme expression; and understand how a hosted
build becomes an installable artifact. More experienced participants can help
with a small code/design improvement and support beginners.

Avoid setting the expectation that everyone will compile Android from scratch
or finish a new production app in 11 hours. Useful contributions include tests,
bug reports, documentation, design and usability observations.

## 2. Confirm with Benson before starting

- Who opens the meeting and explains the agenda?
- Who leads each Scheme/LambdaNative/F-Droid lesson?
- Bonface's app introduction, demonstration and practical support slots.
- Who hosts the call, manages breakout rooms and admits participants?
- Which experienced volunteers can support beginners, and how do they ask for help?
- Final lesson URLs, meeting link and source/APK distribution method.
- Pre/post workshop surveys, when to complete them, and where results go.
- Whether recording is planned and how participants will be informed.
- Breaks within the scheduled windows and how contact time is counted.
- Which successful improved-branch artifact to share; the app code is now published.
- The primary meeting room, the previously emailed Google Meet backup, and who announces a switch.

Participation is voluntary and unpaid; internet/data support is not provided,
as stated in the participant email. Do not imply there is an allowance. Keep registration spreadsheets/contact details
outside a public repository and off the shared screen.

## 3. Material to have open

1. [App walkthrough](app-walkthrough.md) and its sample values.
2. [Scheme cheat sheet](scheme-cheat-sheet.md).
3. [LambdaNative cheat sheet](lambdanative-cheat-sheet.md).
4. [Command guide](commands-and-troubleshooting.md).
5. App source, MODULES, FONTS, workflow and tests in separate editor tabs.
6. The improved Linux app, its successful APK if available, and an app screenshot fallback.
7. [Icon design brief](icon-design-brief.md) and a place to collect SVG/license notes.
8. Shared feedback document or GitHub issues page and agreed survey links.

Benson's provided links:

- [Workshop website](https://bkmgit.github.io/2026-10-29-LambdaNative-Learning-Lions-Online/)
- [LambdaNative and F-Droid](https://bkmgit.github.io/LambdaNative-and-FDroid/)
- [Scheme novice lesson](https://bkmgit.github.io/scheme-novice/)
- [Create and distribute an app on F-Droid](https://bkmgit.github.io/create-and-distribute-an-app-on-fdroid/)

Open these in a browser before presenting: automatic retrieval was unavailable
during preparation, and Benson said the lessons would be updated. These notes
supplement the lessons rather than replacing their current content.

## 4. Remote setup checklist

### Before participants arrive

- [ ] Test microphone, camera if used, headphones and screen sharing.
- [ ] Confirm the meeting link, timezone and first session start time.
- [ ] Choose a readable editor/terminal font and disable distracting notifications.
- [ ] Run `gsi docs/examples/scheme-practice.scm` and `./tests/run.sh`.
- [ ] Open the Linux app and rehearse a demo using fictional data.
- [ ] Prepare APK, screenshots and source so a slow build does not block teaching.
- [ ] If using the Pixel, test cable, ADB authorization and screen visibility.
- [ ] Verify the shared materials are accessible to participants outside the organization.
- [ ] Identify helper volunteers and agree a simple escalation route.
- [ ] Keep a copy of key instructions in chat for people with intermittent audio.

### At the start

Explain how to ask questions, use chat, request help and rejoin after a dropped
connection. State that phone-only participants can test and review apps even if
they cannot follow every desktop build exercise. Pair by complementary skills,
not simply “advanced people together, beginners alone.”

## Day 1: Thursday, 29 October, 3pm–6pm EAT

Suggested allocation, totaling 180 minutes including a break:

| Minutes | Activity | Presenter prompt / output |
|---|---|---|
| 0–10 | Welcome and expectations | What do you want a personal finance app to help you do? |
| 10–30 | Bonface introduces the improved app | Demonstrate create/edit/delete with fictional data |
| 30–50 | Benson: LambdaNative and Scheme overview | Bonface hands over and collects questions |
| 50–65 | Benson: introduce F-Droid | Explain open-source apps and distribution |
| 65–75 | Break | Share restart time in chat |
| 75–110 | Test the app | Learners try a task; helpers collect reproducible observations |
| 110–135 | Compare personal finance apps | Identify features that solve real needs |
| 135–160 | Prioritize feedback and identify design volunteers | Issues plus an initial icon brief/owners |
| 160–180 | Review and next-day setup | Summarize observations and confirm materials/access |

Use the improved app as the shared starting point. Do not spend the session
rebuilding the original interface. Invite observations before explaining your
design choices. Use [talking points](facilitator-talking-points.md) for your
opening, demo narration and handoff to Benson. Ask who has Inkscape/SVG skills
and what actions would benefit from clearer icons.

### Comparison worksheet

For each app/task, ask:

| Question | What to capture |
|---|---|
| How do I add income/expense? | Number of steps, labels, defaults |
| Can I correct a mistake? | Edit/delete behavior, confirmation and recovery |
| How do I understand the balance? | Currency, signs, totals and date range |
| What categories are useful? | Defaults, custom categories, discoverability |
| What happens without an account/internet? | Observe actual behavior rather than guessing |
| How would I keep or move my records? | Export/backup, if present |
| Is it usable on my device? | Text size, touch targets, keyboard, scrolling |

Do not ask participants to disclose real financial details. “Free/open source”
does not eliminate the need to evaluate permissions, usability and suitability.

## Day 2: Friday, 30 October, 2pm–6pm EAT

Suggested allocation, totaling 240 minutes including a break:

| Minutes | Activity | Expected output |
|---|---|---|
| 0–15 | Recap and resolve access problems | Everyone knows their participation route |
| 15–45 | Git/GitHub introduction, teaching lead agreed with Benson | Bonface helps with access and questions |
| 45–105 | Benson: Scheme introduction | Bonface monitors chat and helps learners |
| 105–115 | Break | Explicit return time |
| 115–150 | Guided Scheme practice | Run/predict small examples; connect to app categories |
| 150–205 | Benson: app build and GitHub Actions | Bonface relates the steps to the improved branch |
| 205–230 | Small paired task or icon planning | A scoped issue, prototype or SVG proposal |
| 230–240 | Questions and recap | Capture blockers for Day 3 |

Keep raw C toolchain details for troubleshooting, not the first explanation of
Scheme. A learner should first experience an expression producing a result.
If a live build is slow, show an existing run and explain its stages while it
continues. Check the improved branch and run result before sharing a download.

## Day 3: Saturday, 31 October, 9am–1pm EAT

Suggested allocation, totaling 240 minutes including a break:

| Minutes | Activity | Expected output |
|---|---|---|
| 0–15 | Recap | Revisit a few questions from Day 2 |
| 15–60 | Benson: more Scheme using app examples | Bonface links examples to the app demo |
| 60–80 | Bonface coordinates icon/app improvement tasks | Scope, helper, owner and review check |
| 80–90 | Break | Helpers confirm group assignments |
| 90–160 | Breakout work, including Inkscape/SVG design | Reviewed icon source, issue, test or code contribution |
| 160–195 | Group demonstrations | Explain need, change and verification |
| 195–220 | Feedback and workshop surveys | Completed survey and prioritized next steps |
| 220–240 | Next sessions and closing | Agreed follow-up topics and contribution routes |

## 5. Breakout task menu

| Group | Possible task | Definition of done |
|---|---|---|
| Beginners/usability | Test add/edit/delete flow and improve wording | Clear observation and one concrete suggestion/issue |
| Beginner coding pair | Add a suitable predefined category | Correct list, form/picker behavior and saved value |
| Design | Find/adapt/create a small icon set in Inkscape | Editable SVG, source/license note and small-size preview |
| Testing | Cover a missed edge case | Test fails for the wrong behavior and passes for the fix |
| Intermediate coding | Improve a small navigation/feedback interaction | Working change with defined manual check |
| Documentation | Clarify one setup or user instruction | Another participant can follow it successfully |

Give each group a helper, a task, a place to record notes and a time to report
back. Do not have every group edit the same shared working directory. Use
separate clones/branches or submit proposals for a facilitator to integrate later.

## 6. Questions to ask rather than answering everything yourself

- What do you expect to happen before we click Save?
- Where is this value stored: in a widget, a variable, or the SQLite file?
- What is different between the text `"12.50"` and stored integer `1250`?
- What would make this bug report reproducible?
- Which function would you inspect first if the balance is wrong?
- Why might an edited row disappear from an active filter?
- How would you know a build artifact came from the source you just changed?
- What is the smallest useful improvement we can finish and check today?

For a beginner's question, first identify the layer: language, app behavior,
framework, native build, Android installation, or collaboration tool. This stops
every problem becoming a random change to `main.scm`.

## 7. Fallback plans

| Problem | Keep the session moving |
|---|---|
| Weak internet | Share short instructions and small screenshots; allow asynchronous feedback |
| Phone-only participation | App testing, feature comparison, issue drafting and design feedback |
| Build takes too long | Use prebuilt app/artifact and explain the logs/stages |
| ADB stops seeing the phone | Use Linux preview and saved phone screenshot; troubleshoot later |
| Updated UI crashes | Capture logs; demonstrate the last known working build |
| Too many beginners need help | Short guided checkpoints, paired helpers and smaller tasks |
| No GitHub account/access | Record feedback in a shared document for later issue entry |
| Design group has SVG ready | Review and retain source; don't promise automatic runtime SVG loading |

## 8. Notes template to fill in during the session

```text
Date/session:
Attendance count (avoid public personal details):
Material/source version demonstrated:
App package/build demonstrated:
What worked:
Blockers and affected tasks:
Participant feedback:
Issues/tasks agreed:
Owner and next step:
Survey link shared/completion follow-up:
Questions for Benson:
```

After the meeting, separate observations from proposals and confirmed bugs.
Collect only the evidence needed to reproduce a problem. Agree what can be
finished before any reporting deadline and what belongs in November follow-up
sessions. Do not claim every proposed improvement has been implemented.
