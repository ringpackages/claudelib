load "claudelib.ring"

func main

	# ====================================================================
	#  Example 1: Quick Question (Simplest Usage)
	# ====================================================================

	see "=== Example 1: Quick Question ===" + nl + nl

	oClient = new ClaudeClient(read("claude_api_key.txt"))

	cAnswer = oClient.ask("What is the Ring programming language?")
	see "Answer: " + cAnswer + nl + nl

	# ====================================================================
	#  Example 2: Question with System Prompt
	# ====================================================================

	see "=== Example 2: System Prompt ===" + nl + nl

	cAnswer = oClient.askWithSystem(
		"Explain closures in simple terms.",
		"You are a programming tutor. Keep answers under 100 words."
	)
	see "Answer: " + cAnswer + nl + nl

	# ====================================================================
	#  Example 3: Selecting a Specific Model
	# ====================================================================

	see "=== Example 3: Model Selection ===" + nl + nl

	# Use Haiku for faster, cheaper responses
	oClient.setModel(CLAUDELIB_MODEL_HAIKU_45)
	cAnswer = oClient.ask("What is 42 * 7?")
	see "Haiku says: " + cAnswer + nl + nl

	# Switch to Opus for complex reasoning
	oClient.setModel(CLAUDELIB_MODEL_OPUS_46)
	cAnswer = oClient.ask("Explain the P vs NP problem briefly.")
	see "Opus says: " + cAnswer + nl + nl

	# Switch back to Sonnet (balanced)
	oClient.setModel(CLAUDELIB_MODEL_SONNET_45)

	# ====================================================================
	#  Example 4: Multi-turn Conversation
	# ====================================================================

	see "=== Example 4: Multi-turn Conversation ===" + nl + nl

	# Create a named chat session
	# createChat() stores by ref(), so oChat and the stored copy
	# are the same object - modifications are shared.
	oChat = oClient.createChat("math-tutor")
	oChat.setSystem("You are a math tutor. Be concise.")

	# First question
	oChat.addUserText("What is the Pythagorean theorem?")
	oResponse = oClient.sendChat(oChat)
	see "Turn 1: " + oResponse.getText() + nl + nl

	# Follow-up (context is maintained)
	oChat.addUserText("Can you give me a real-world example?")
	oResponse = oClient.sendChat(oChat)
	see "Turn 2: " + oResponse.getText() + nl + nl

	# Check conversation history
	see "Messages in chat: " + oChat.getMessageCount() + nl + nl

	# ====================================================================
	#  Example 5: Response Metadata
	# ====================================================================

	see "=== Example 5: Response Metadata ===" + nl + nl

	oChat2 = oClient.createChat("meta-test")
	oChat2.addUserText("Hello Claude!")
	oResponse = oClient.sendChat(oChat2)

	see "Response ID    : " + oResponse.getID() + nl
	see "Model Used     : " + oResponse.getModel() + nl
	see "Stop Reason    : " + oResponse.getStopReason() + nl
	see "Input Tokens   : " + oResponse.getInputTokens() + nl
	see "Output Tokens  : " + oResponse.getOutputTokens() + nl
	see "Total Tokens   : " + oResponse.getTotalTokens() + nl
	see "Text           : " + oResponse.getText() + nl + nl

	# ====================================================================
	#  Example 6: Error Handling
	# ====================================================================

	see "=== Example 6: Error Handling ===" + nl + nl

	oBadClient = new ClaudeClient("invalid-key")
	cAnswer = oBadClient.ask("Hello?")
	if cAnswer = ""
		see "Error occurred: " + oBadClient.getLastError() + nl + nl
	ok

	see "=== All Basic Examples Complete ===" + nl
