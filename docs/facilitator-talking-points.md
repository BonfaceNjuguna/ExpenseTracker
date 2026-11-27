# Bonface's facilitator talking points

## Your role and the working division of responsibilities

Based on the email conversation, Benson proposed the lesson sequence, created
the workshop site and said he would update the Scheme/app-distribution lessons.
You have coordinated participants, prepared the app, and will introduce it and
support the practical activities. The working plan is for Benson to lead the
main Scheme, LambdaNative, F-Droid and build concepts, with you facilitating and
connecting those concepts to the app. His emails do not formally assign every
teaching slot: agree quick handoffs with him before the call rather than
announcing an unconfirmed division as settled.

You do not need to deliver a complete Scheme course. Your preparation priorities:

1. Make the improved app easy to understand and try.
2. Keep participants informed about the agenda, timing and how to get help.
3. Invite useful feedback, especially from beginners and phone-only participants.
4. Find volunteers with design/Inkscape skills and organize a small icon task.
5. Capture issues, decisions, questions and next steps.
6. Hand technical concept questions to Benson, then connect the explanation back
   to a concrete app behavior.

## Before the meeting: five-minute check-in with Benson

Say or message:

> “I have the improved app ready for the demonstration. I'll welcome people,
> introduce the app, collect feedback and coordinate the practical/icon work.
> Shall I hand over to you for the Scheme, LambdaNative and F-Droid concepts?
> Let us agree when you would like the app demo and how we will manage breakouts.”

Confirm who hosts, admits participants and can create breakout rooms. Confirm
survey links and the correct APK before sharing. The new meeting link is the
primary venue; keep the previously emailed Google Meet as a backup. Do not send
everyone to a backup without a clear announcement and agreed switch time.
Do not assume the same meeting room applies to later days until confirmed.

## Commands to have ready on your Linux machine

These use the prepared workstation and its local helper scripts. Run them before
participants join:

```sh
cd /home/boni/Documents/Development/expense-tracker/LambdaNativeQuickStart
git branch --show-current
./tests/run.sh
./tools/build-linux.sh
./.local-build/linux/ExpenseTracker/ExpenseTracker
```

Expected branch: `improved-expense-income-tracker`. If already built, only the
last command is needed after changing into the repository. The app is a native
Linux window, not an Android emulator. Close the old preview before rebuilding.

If you need a separate fictional dataset, close the default preview and use:

```sh
demo_dir=$(mktemp -d "$PWD/.local-build/workshop-demo.XXXXXX")
cp .local-build/linux/ExpenseTracker/ExpenseTracker "$demo_dir/ExpenseTracker"
"$demo_dir/ExpenseTracker"
```

Keep that terminal so you can reopen the same demo using
`"$demo_dir/ExpenseTracker"`. It stores data beside this copied executable in the
prepared Linux build. Do not delete existing databases to clear the screen.
For failures, use the [command guide](commands-and-troubleshooting.md).

## Opening: approximately two minutes

> “Jambo everyone, and welcome. Thank you for making time to join us. I'm
> Bonface, and I'll help facilitate the workshop and take you through our
> personal finance app. Benson will guide the main concepts and lessons; we'll
> connect them to practical tasks together.”

> “We have people with different experience levels. You do not need to know
> Scheme already. You can contribute by testing, asking questions, suggesting
> better wording, creating icons or writing code.”

> “Please use chat for questions and tell us if you get stuck. If you are using
> only a phone or have limited connectivity, let us know so we can help you
> choose an activity. Use fictional transactions when testing.”

Housekeeping: meeting controls, breaks, volunteer helpers, where notes/issues go,
and whether recording is happening. Do not promise a recording unless agreed.
Participation is voluntary and unpaid, and internet/data support is not provided;
this was already stated in the participant email. If asked, repeat it clearly
without suggesting a reimbursement might follow.

## Introduce the improved app: approximately two minutes

> “This is the improved version of our app, and it will be our starting point.
> It records income and expenses locally, shows the balance, and allows you to
> edit or delete a saved transaction. Overview shows the newest ten entries;
> Activity has the full history.”

> “The same app source is used for Linux and Android builds. There is no bank
> connection, login or cloud synchronization in this version. Today we want to
> learn from using it, identify useful improvements, and explore how design
> contributions such as icons can make it clearer.”

Ask: “When tracking money, what do you most need to see or do quickly?” Take
two or three answers before presenting features. Do not begin with hundreds of
lines of source code.

## Demo narration card: 10–15 minutes, plus questions

Use the [full walkthrough](app-walkthrough.md#guided-demo-with-expected-results)
when you want the detailed checks. Values below assume an empty demo database.

| Action | Say / ask | Expected balance |
|---|---|---|
| Show Overview | “Recorded income minus recorded expenses; not a bank connection.” | KES 0.00 |
| Income 1000.00, Salary | “Which type and category should this use?” | KES 1,000.00 |
| Expense 125.50, Transport | “Predict what will happen to the balance.” | KES 874.50 |
| Expense 25.25, Other → Workshop supplies | “What if none of the default categories fits?” | KES 849.25 |
| Activity filters | “Overview is a summary. Where would you look for all records?” | Unchanged |
| Edit Transport to 100.50 | “We are correcting the existing record, not creating another.” | KES 874.25 |
| Delete supplies; first cancel, then confirm | “We should be sure before removing a saved entry.” | KES 899.50 |
| Try zero amount | “What should the app do with an invalid amount?” | Unchanged |

Pause after each meaningful action. Ask “What happened?” before explaining the
implementation. If the app already has records, state the starting balance and
demonstrate relative changes instead of promising the exact totals above.

## Handoff to Benson

> “We have seen the user-facing behavior. Benson, could you take us through how
> Scheme and LambdaNative fit together? We can return to this example when we
> discuss callbacks, form values and saving data.”

For F-Droid:

> “This app gives us one starting point. Benson will introduce F-Droid and how
> open-source Android applications are distributed. Then we can compare what
> other personal finance apps do well and what users would value here.”

For a difficult implementation question:

> “Let us separate the user need from the technical question. I'll capture the
> need as an issue; Benson, could you help explain the underlying concept?”

You can say “I'll verify that” rather than improvise a technical guarantee.

## Guide app testing and collect actionable feedback

Give one task at a time: add an expense, find it, correct it, then remove only a
fictional test entry. Ask for:

- The task and device/platform.
- What the participant expected.
- What actually happened, including exact labels or steps.
- Whether it is a bug, usability concern or new feature idea.

If someone cannot access GitHub, capture their observation in the shared notes
and ask a helper to turn it into an issue later. Do not invent a download link
when the build has failed: use the Linux screen-share demo while it is repaired.

## Introduce the icon activity

> “You do not need to be a programmer to improve the app. Who has used Inkscape
> or created icons or SVG graphics? We would like a small, consistent set of
> icons that makes actions easier to recognize while keeping the text labels.”

Start with two or three priorities: Income, Expense and Activity, or Edit/Delete
if the group identifies those as more useful. Refer to the
[icon brief](icon-design-brief.md) for deliverables.

> “We can create our own designs or find assets whose license permits reuse.
> Keep the editable SVG source and record the source and license for anything
> reused. We will review the icons first; integration into LambdaNative is a
> separate step, not something SVG export alone completes.”

Ask a design volunteer to lead the visual work and pair them with someone who
can explain the app's screens. Give beginners a useful review task: “Can you
tell what this icon means at a small size without knowing its filename?”

## Facilitate breakouts

Before opening rooms, state the task, helper, return time and expected output.
Keep a written task in chat. Ask groups to return with:

1. The user problem they chose.
2. Their icon/prototype, issue, test or code change.
3. How they checked it.
4. One limitation or next step.

If room features or connectivity fail, use the main room and assign parallel
tasks in chat. Use the backup Google Meet only after agreeing with Benson and
announcing the switch; avoid splitting the group across two calls unknowingly.

## Close each session

> “Today we tried the app and identified these priorities: [name two or three].
> Thank you to the people who tested, designed, helped others or asked questions.
> Please complete the survey at [confirmed survey link]. Our next session is
> [date/time in EAT]; we will confirm the meeting link by email.”

Record owners and next steps rather than promising every feature will be
finished immediately. Keep a list of questions for Benson and topics for a
possible November follow-up.
