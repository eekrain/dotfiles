---
argument-hint: [Any extra constraints or specific things to tell the research agent]
description: Instruct the coding agent to package its current session context into a prompt for a research LLM
---

# Task: Package This Session for a Research Agent

The user wants to escalate the current debugging problem to a more capable Research Agent. Since the Research Agent does not have access to this conversation history or the codebase, you must synthesize everything we have done into a single, self-contained prompt.

Review our entire conversation history up to this point and output a ready-to-copy prompt.

## Your Output Format

Your entire response must be a single markdown code block containing the prompt for the Research Agent. Structure that generated prompt with the following sections:

1. **The Objective & Core Issue**: Clear explanation of what we are trying to achieve and the exact error, bug, or limitation we have run into.
2. **Relevant Code Snippets**: Do not just explain or reference file names. Extract and copy the actual, literal blocks of code from our context that are relevant to this issue so the Research Agent can read them directly.
3. **What We Have Tried**: A summary of the approaches, code changes, or fixes we have already attempted in this session, and why they failed.
4. **The Likely Culprit(s)**: Your best technical hypothesis on where the root cause or bottleneck lies.
5. **Research Questions**: A targeted list of high-level conceptual or technical questions the Research Agent needs to answer to unblock us.

## User's Additional Notes
> $ARGUMENTS

Do not include any introductory text or conversational filler. Start your response directly with the markdown code block containing the generated prompt.