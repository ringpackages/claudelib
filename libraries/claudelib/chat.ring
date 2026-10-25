class ClaudeChat

	cChatID       = ""
	cSystemPrompt = ""
	aMessages     = []
	cLastResponse = ""
	cLastText     = ""

	func init cID
		cChatID = cID

	func getID
		return cChatID

	func setSystem cPrompt
		cSystemPrompt = cPrompt
		return self

	func getSystem
		return cSystemPrompt

	func addMessage oMsg
		add(aMessages, oMsg)
		return self

	func addUserText cText
		oMsg = new ClaudeMessage(RINGCLAUDE_ROLE_USER)
		oMsg.addText(cText)
		add(aMessages, oMsg)
		return self

	func addAssistantText cText
		oMsg = new ClaudeMessage(RINGCLAUDE_ROLE_ASSISTANT)
		oMsg.addText(cText)
		add(aMessages, oMsg)
		return self

	func addUserImageBase64 cText, cBase64Data, cMediaType
		oMsg = new ClaudeMessage(RINGCLAUDE_ROLE_USER)
		if cText != NULL and cText != ""
			oMsg.addText(cText)
		ok
		oMsg.addImageBase64(cBase64Data, cMediaType)
		add(aMessages, oMsg)
		return self

	func addUserImageURL cText, cImageURL
		oMsg = new ClaudeMessage(RINGCLAUDE_ROLE_USER)
		if cText != NULL and cText != ""
			oMsg.addText(cText)
		ok
		oMsg.addImageURL(cImageURL)
		add(aMessages, oMsg)
		return self

	func addUserDocument cText, cBase64Data, cMediaType
		oMsg = new ClaudeMessage(RINGCLAUDE_ROLE_USER)
		if cText != NULL and cText != ""
			oMsg.addText(cText)
		ok
		oMsg.addDocumentBase64(cBase64Data, cMediaType)
		add(aMessages, oMsg)
		return self

	func addUserTextDocument cText, cDocText, cTitle
		oMsg = new ClaudeMessage(RINGCLAUDE_ROLE_USER)
		if cText != NULL and cText != ""
			oMsg.addText(cText)
		ok
		oMsg.addDocumentPlainText(cDocText, cTitle)
		add(aMessages, oMsg)
		return self

	func getMessages
		return aMessages

	func clearMessages
		aMessages = []
		return self

	func getMessageCount
		return len(aMessages)

	func getLastResponse
		return cLastResponse

	func getLastText
		return cLastText

	func setLastResponse cResp
		cLastResponse = cResp

	func setLastText cTextVal
		cLastText = cTextVal

	# Build JSON string for the messages array
	func messagesToJSON
		cJSON = "["
		nCount = len(aMessages)
		for nIdx = 1 to nCount
			cJSON += aMessages[nIdx].toJSON()
			if nIdx < nCount
				cJSON += ","
			ok
		next
		cJSON += "]"
		return cJSON
