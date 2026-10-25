load "claudelib.ring"

func main

	oClient = new ClaudeClient(read("claude_api_key.txt"))

	# ====================================================================
	#  Example 1: Managing Multiple Chat Sessions
	# ====================================================================

	see "=== Example 1: Multiple Chat Sessions ===" + nl + nl

	# Create different chats for different purposes

	oChatCode = oClient.createChat("coding-help")
	oChatCode.setSystem("You are an expert Ring programming language developer.")

	oChatWrite = oClient.createChat("writing-help")
	oChatWrite.setSystem("You are a creative writing assistant.")

	oChatMath = oClient.createChat("math-help")
	oChatMath.setSystem("You are a math professor. Show your work step by step.")

	# List all active chats (index-based loop, index starts from 1)
	see "Active chats: " + nl
	aChats = oClient.getChatList()
	nCount = len(aChats)
	for nIdx = 1 to nCount
		see "  - " + aChats[nIdx] + nl
	next
	see "Total: " + oClient.getChatCount() + " chats" + nl + nl

	# Send messages to different chats using their IDs
	oResp1 = oClient.sendToChat("coding-help", 
		"How do I create a class in Ring?")
	see "Coding chat: " + oResp1.getText() + nl + nl

	oResp2 = oClient.sendToChat("writing-help", 
		"Give me an opening line for a mystery novel.")
	see "Writing chat: " + oResp2.getText() + nl + nl

	oResp3 = oClient.sendToChat("math-help", 
		"Solve: 2x + 5 = 17")
	see "Math chat: " + oResp3.getText() + nl + nl

	# Continue a specific conversation (history is preserved)
	oResp4 = oClient.sendToChat("coding-help", 
		"How do I add methods to that class?")
	see "Coding follow-up: " + oResp4.getText() + nl + nl

	# Delete a chat when done
	oClient.deleteChat("writing-help")
	see "After deleting writing-help, chats: " + 
		oClient.getChatCount() + nl + nl

	# ====================================================================
	#  Example 2: Temperature Control
	# ====================================================================

	see "=== Example 2: Temperature Control ===" + nl + nl

	# Note: Claude 4.7 and later models accept only the default sampling,
	# so the library skips temperature/top_p/top_k for these models
	if ! oClient.supportsSampling()
		see "(" + oClient.getModel() + " ignores temperature)" + nl + nl
	ok

	# Low temperature = more deterministic/focused
	oClient.setTemperature(0.1)
	oChat = oClient.createChat("temp-low")
	oChat.addUserText("List 3 prime numbers.")
	oResponse = oClient.sendChat(oChat)
	see "Low temp (0.1): " + oResponse.getText() + nl + nl

	# High temperature = more creative/varied
	oClient.setTemperature(0.9)
	oChatHigh = oClient.createChat("temp-high")
	oChatHigh.addUserText("Write a haiku about programming.")
	oResponse = oClient.sendChat(oChatHigh)
	see "High temp (0.9): " + oResponse.getText() + nl + nl

	# Reset temperature to default
	oClient.setTemperature(-1)

	# ====================================================================
	#  Example 3: Max Tokens Control
	# ====================================================================

	see "=== Example 3: Max Tokens Control ===" + nl + nl

	oClient.setMaxTokens(50)
	oShortChat = oClient.createChat("short-response")
	oShortChat.addUserText("Explain quantum computing.")
	oResponse = oClient.sendChat(oShortChat)
	see "Short response: " + oResponse.getText() + nl
	see "Stop reason: " + oResponse.getStopReason() + nl + nl

	# Restore default
	oClient.setMaxTokens(4096)

	# ====================================================================
	#  Example 4: Stop Sequences
	# ====================================================================

	see "=== Example 4: Stop Sequences ===" + nl + nl

	oClient.addStopSequence("END")
	oClient.addStopSequence("STOP")

	oStopChat = oClient.createChat("stop-test")
	oStopChat.setSystem("When you finish your answer, write END on a new line.")
	oStopChat.addUserText("Name 3 colors.")
	oResponse = oClient.sendChat(oStopChat)
	see "With stop sequence: " + oResponse.getText() + nl
	see "Stop reason: " + oResponse.getStopReason() + nl + nl

	oClient.clearStopSequences()

	# ====================================================================
	#  Example 5: Extended Thinking
	# ====================================================================

	see "=== Example 5: Extended Thinking ===" + nl + nl

	# Older models (like Sonnet 4.5) use the thinking budget (tokens)
	# Newer models (4.6 and later) use adaptive thinking and ignore it
	oClient.setBudgetTokens(2000)
	oClient.setModel(CLAUDELIB_MODEL_SONNET_55)

	oThinkChat = oClient.createChat("thinking-test")
	oThinkChat.addUserText("What is 127 * 389? Think step by step.")
	oResponse = oClient.sendChat(oThinkChat)

	if oResponse.getThinking() != ""
		see "Thinking: " + oResponse.getThinking() + nl + nl
	ok
	see "Answer: " + oResponse.getText() + nl + nl

	oClient.setBudgetTokens(0)
	oClient.setModel(CLAUDELIB_MODEL_DEFAULT)

	# ====================================================================
	#  Example 6: Verbose / Debug Mode
	# ====================================================================

	see "=== Example 6: Debug Mode ===" + nl + nl

	oClient.setVerbose(true)

	oDebugChat = oClient.createChat("debug-test")
	oDebugChat.addUserText("Say hello.")
	oResponse = oClient.sendChat(oDebugChat)

	see nl + "Debug response: " + oResponse.getText() + nl + nl

	oClient.setVerbose(false)

	# ====================================================================
	#  Example 7: Building Messages Manually
	# ====================================================================

	see "=== Example 7: Manual Message Building ===" + nl + nl

	oManualChat = oClient.createChat("manual-build")
	oManualChat.setSystem("You are a translator. Translate to French.")

	# Build a message with multiple content blocks
	oMsg = new ClaudeMessage(CLAUDELIB_ROLE_USER)
	oMsg.addText("Translate the following:")
	oMsg.addText("Hello, how are you today?")
	oManualChat.addMessage(oMsg)

	oResponse = oClient.sendChat(oManualChat)
	see "Translation: " + oResponse.getText() + nl + nl

	# Inject synthetic assistant messages for context
	oManualChat.addAssistantText("Bonjour, comment allez-vous aujourd'hui?")
	oManualChat.addUserText("Now translate: Goodbye, see you tomorrow.")
	oResponse = oClient.sendChat(oManualChat)
	see "Follow-up: " + oResponse.getText() + nl + nl

	# ====================================================================
	#  Example 8: Using Top P and Top K
	# ====================================================================

	see "=== Example 8: Top P and Top K ===" + nl + nl

	# Like temperature, these are skipped for Claude 4.7 and later models
	if ! oClient.supportsSampling()
		see "(" + oClient.getModel() + " ignores top_p/top_k)" + nl + nl
	ok

	oClient.setTopP(0.9)
	oClient.setTopK(40)

	oSampChat = oClient.createChat("sampling-test")
	oSampChat.addUserText("Tell me a fun fact about space.")
	oResponse = oClient.sendChat(oSampChat)
	see "Fun fact: " + oResponse.getText() + nl + nl

	# Reset
	oClient.setTopP(-1)
	oClient.setTopK(-1)

	see "=== All Advanced Examples Complete ===" + nl
