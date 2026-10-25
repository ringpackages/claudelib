load "claudelib.ring"

func main

	see nl
	see "========================================" + nl
	see "     ClaudeLib  Interactive Chat        " + nl
	see "     Powered by Anthropic Claude        " + nl
	see "========================================" + nl
	see nl

	cAPIKey = read("claude_api_key.txt")

	if cAPIKey = "" or len(cAPIKey) < 10
		see "Invalid API key. Exiting." + nl
		return
	ok

	# Initialize client
	oClient = new ClaudeClient(cAPIKey)

	# Create default chat
	cCurrentChat = "default"
	oClient.createChat(cCurrentChat)

	see nl + "Chat session '" + cCurrentChat + "' created." + nl
	see "Type /help for available commands, or just type your message." + nl + nl

	# Main loop
	while true
		see "[" + cCurrentChat + "] You: "
		give cInput
		cInput = trim(cInput)

		if cInput = ""
			loop
		ok

		# Process commands
		if left(cInput, 1) = "/"
			cCmd = lower(cInput)

			# /quit
			if cCmd = "/quit" or cCmd = "/exit"
				see nl + "Goodbye!" + nl
				exit

			# /help
			but cCmd = "/help"
				showHelp()

			# /new <name>
			but left(cCmd, 5) = "/new "
				cName = trim(substr(cInput, 6))
				if cName != ""
					oClient.createChat(cName)
					cCurrentChat = cName
					see "Created and switched to chat: " + cName + nl
				else
					see "Usage: /new <chat_name>" + nl
				ok

			# /switch <name>
			but left(cCmd, 8) = "/switch "
				cName = trim(substr(cInput, 9))
				if oClient.getChat(cName) != NULL
					cCurrentChat = cName
					see "Switched to chat: " + cName + nl
				else
					see "Chat not found: " + cName + nl
				ok

			# /list
			but cCmd = "/list"
				aChats = oClient.getChatList()
				nCount = len(aChats)
				see "Active chats (" + nCount + "):" + nl
				for nIdx = 1 to nCount
					cID = aChats[nIdx]
					cMarker = "  "
					if cID = cCurrentChat
						cMarker = "> "
					ok
					oChat = oClient.getChat(cID)
					see cMarker + cID + " (" + 
						oChat.getMessageCount() + " messages)" + nl
				next

			# /system <text>
			but left(cCmd, 8) = "/system "
				cPrompt = trim(substr(cInput, 9))
				oChat = oClient.getChat(cCurrentChat)
				oChat.setSystem(cPrompt)
				see "System prompt set for '" + cCurrentChat + "'" + nl

			# /model <name>
			but left(cCmd, 7) = "/model "
				cModelName = trim(lower(substr(cInput, 8)))
				if cModelName = "opus" or cModelName = "opus46"
					oClient.setModel(CLAUDELIB_MODEL_OPUS_46)
					see "Model set to: Claude Opus 4.6" + nl
				but cModelName = "opus45"
					oClient.setModel(CLAUDELIB_MODEL_OPUS_45)
					see "Model set to: Claude Opus 4.5" + nl
				but cModelName = "sonnet" or cModelName = "sonnet45"
					oClient.setModel(CLAUDELIB_MODEL_SONNET_45)
					see "Model set to: Claude Sonnet 4.5" + nl
				but cModelName = "sonnet4"
					oClient.setModel(CLAUDELIB_MODEL_SONNET_4)
					see "Model set to: Claude Sonnet 4" + nl
				but cModelName = "haiku" or cModelName = "haiku45"
					oClient.setModel(CLAUDELIB_MODEL_HAIKU_45)
					see "Model set to: Claude Haiku 4.5" + nl
				else
					see "Unknown model. Use: opus, sonnet, haiku" + nl
				ok

			# /tokens <n>
			but left(cCmd, 8) = "/tokens "
				nTokens = 0 + trim(substr(cInput, 9))
				if nTokens > 0
					oClient.setMaxTokens(nTokens)
					see "Max tokens set to: " + nTokens + nl
				else
					see "Usage: /tokens <number>" + nl
				ok

			# /temp <n>
			but left(cCmd, 6) = "/temp "
				cVal = trim(substr(cInput, 7))
				if cVal = "default"
					oClient.setTemperature(-1)
					see "Temperature reset to default." + nl
				else
					nTemp = 0 + cVal
					oClient.setTemperature(nTemp)
					see "Temperature set to: " + nTemp + nl
				ok

			# /info
			but cCmd = "/info"
				see "Current Settings:" + nl
				see "  Chat      : " + cCurrentChat + nl
				see "  Model     : " + oClient.getModel() + nl
				see "  Max Tokens: " + oClient.getMaxTokens() + nl
				nT = oClient.getTemperature()
				if nT >= 0
					see "  Temperature: " + nT + nl
				else
					see "  Temperature: (default)" + nl
				ok
				oChat = oClient.getChat(cCurrentChat)
				cSys = oChat.getSystem()
				if cSys != ""
					see "  System    : " + cSys + nl
				else
					see "  System    : (none)" + nl
				ok

			# /clear
			but cCmd = "/clear"
				oChat = oClient.getChat(cCurrentChat)
				oChat.clearMessages()
				see "Chat history cleared for '" + cCurrentChat + "'" + nl

			# /history
			but cCmd = "/history"
				oChat = oClient.getChat(cCurrentChat)
				see "Messages in '" + cCurrentChat + "': " + 
					oChat.getMessageCount() + nl

			# Unknown command
			else
				see "Unknown command. Type /help for available commands." + nl
			ok

		else
			# Regular message - send to Claude
			oResponse = oClient.sendToChat(cCurrentChat, cInput)
			if oResponse = NULL
				see "Error: " + oClient.getLastError() + nl
			but oResponse.isError()
				see "API Error: " + oResponse.getErrorMessage() + nl
			else
				see nl + "Claude: " + oResponse.getText() + nl
				see "  [" + oResponse.getInputTokens() + " in / " + 
					oResponse.getOutputTokens() + " out tokens]" + nl
			ok
		ok
		see nl
	end

func showHelp
	see nl
	see "Available Commands:" + nl
	see "  /new <name>     Create a new chat session" + nl
	see "  /switch <name>  Switch to an existing chat" + nl
	see "  /list           List all chat sessions" + nl
	see "  /system <text>  Set system prompt for current chat" + nl
	see "  /model <name>   Change model (opus/sonnet/haiku)" + nl
	see "  /tokens <n>     Set max tokens" + nl
	see "  /temp <n>       Set temperature (or 'default')" + nl
	see "  /info           Show current settings" + nl
	see "  /clear          Clear current chat history" + nl
	see "  /history        Show message count" + nl
	see "  /help           Show this help" + nl
	see "  /quit           Exit the chatbot" + nl
	see nl
	see "Just type your message to chat with Claude!" + nl
