class ClaudeClient

	cAPIKey           = ""
	cModel            = RINGCLAUDE_MODEL_DEFAULT
	nMaxTokens        = 4096
	nTemperature      = -1
	nTopP             = -1
	nTopK             = -1
	aStopSequences    = []
	aChats            = []
	cLastError        = ""
	lVerbose          = false
	cAPIURL           = RINGCLAUDE_API_URL
	cAPIVersion       = RINGCLAUDE_API_VERSION
	nBudgetTokens     = 0

	func init cKey
		if cKey != NULL and cKey != ""
			cAPIKey = cKey
		ok

	func setAPIKey cKey
		cAPIKey = cKey
		return self

	func getAPIKey
		return cAPIKey

	func setModel cModelName
		cModel = cModelName
		return self

	func getModel
		return cModel

	func setMaxTokens nTokens
		nMaxTokens = nTokens
		return self

	func getMaxTokens
		return nMaxTokens

	func setTemperature nTemp
		nTemperature = nTemp
		return self

	func getTemperature
		return nTemperature

	func setTopP nVal
		nTopP = nVal
		return self

	func setTopK nVal
		nTopK = nVal
		return self

	func addStopSequence cSeq
		aStopSequences + cSeq
		return self

	func clearStopSequences
		aStopSequences = []
		return self

	func setVerbose lVal
		lVerbose = lVal
		return self

	func setAPIURL cNewURL
		cAPIURL = cNewURL
		return self

	func setAPIVersion cVer
		cAPIVersion = cVer
		return self

	func setBudgetTokens nTokens
		nBudgetTokens = nTokens
		return self

	func getLastError
		return cLastError

	func createChat cChatID
		oChat = new ClaudeChat(cChatID)
		add(aChats, ref(oChat))
		return oChat

	func getChat cChatID
		nCount = len(aChats)
		for nIdx = 1 to nCount
			if aChats[nIdx].getID() = cChatID
				return aChats[nIdx]
			ok
		next
		return NULL

	func deleteChat cChatID
		nCount = len(aChats)
		for nIdx = 1 to nCount
			if aChats[nIdx].getID() = cChatID
				del(aChats, nIdx)
				return true
			ok
		next
		return false

	func getChatList
		aList = []
		nCount = len(aChats)
		for nIdx = 1 to nCount
			aList + aChats[nIdx].getID()
		next
		return aList

	func getChatCount
		return len(aChats)

	func ask cQuestion
		return askWithSystem(cQuestion, "")

	func askWithSystem cQuestion, cSystemPrompt
		oChat = new ClaudeChat("_temp_" + random(999999))
		if cSystemPrompt != NULL and cSystemPrompt != ""
			oChat.setSystem(cSystemPrompt)
		ok
		oChat.addUserText(cQuestion)
		oResponse = sendChat(oChat)
		if oResponse != NULL and ! oResponse.isError()
			return oResponse.getText()
		ok
		if oResponse != NULL
			cLastError = oResponse.getErrorMessage()
		ok
		return ""

	func sendChat oChat
		if cAPIKey = "" or cAPIKey = NULL
			cLastError = "API key not set. Use setAPIKey() first."
			return NULL
		ok

		cRequestJSON = buildRequestJSON(oChat)

		if lVerbose
			see "=== RingClaude Request ===" + nl
			see cRequestJSON + nl
			see "=========================" + nl
		ok

		cHTTPResponse = sendHTTPPost(cRequestJSON)

		if lVerbose
			see "=== RingClaude Response ===" + nl
			see cHTTPResponse + nl
			see "===========================" + nl
		ok

		oResponse = new ClaudeResponse(cHTTPResponse)

		oChat.setLastResponse(cHTTPResponse)

		if ! oResponse.isError() and oResponse.getText() != ""
			oChat.setLastText(oResponse.getText())
			oChat.addAssistantText(oResponse.getText())
		ok

		return oResponse

	func sendToChat cChatID, cMessage
		oChat = getChat(cChatID)
		if oChat = NULL
			cLastError = "Chat not found: " + cChatID
			return NULL
		ok
		oChat.addUserText(cMessage)
		return sendChat(oChat)

	func sendImageToChat cChatID, cText, cBase64Data, cMediaType
		oChat = getChat(cChatID)
		if oChat = NULL
			cLastError = "Chat not found: " + cChatID
			return NULL
		ok
		oChat.addUserImageBase64(cText, cBase64Data, cMediaType)
		return sendChat(oChat)

	func sendImageURLToChat cChatID, cText, cImageURL
		oChat = getChat(cChatID)
		if oChat = NULL
			cLastError = "Chat not found: " + cChatID
			return NULL
		ok
		oChat.addUserImageURL(cText, cImageURL)
		return sendChat(oChat)

	func sendDocumentToChat cChatID, cText, cBase64Data, cMediaType
		oChat = getChat(cChatID)
		if oChat = NULL
			cLastError = "Chat not found: " + cChatID
			return NULL
		ok
		oChat.addUserDocument(cText, cBase64Data, cMediaType)
		return sendChat(oChat)

	func fileToBase64 cFilePath
		try
			cFileData = read(cFilePath)
			if cFileData = NULL or len(cFileData) = 0
				cLastError = "Cannot read file: " + cFilePath
				return ""
			ok
			return encodeBase64(cFileData)
		catch
			cLastError = "Error reading file: " + cFilePath
			return ""
		done

	func detectMediaType cFilePath
		cLowerPath = lower(cFilePath)
		if right(cLowerPath, 4) = ".jpg" or right(cLowerPath, 5) = ".jpeg"
			return RINGCLAUDE_MEDIA_JPEG
		but right(cLowerPath, 4) = ".png"
			return RINGCLAUDE_MEDIA_PNG
		but right(cLowerPath, 4) = ".gif"
			return RINGCLAUDE_MEDIA_GIF
		but right(cLowerPath, 5) = ".webp"
			return RINGCLAUDE_MEDIA_WEBP
		but right(cLowerPath, 4) = ".pdf"
			return RINGCLAUDE_MEDIA_PDF
		but right(cLowerPath, 4) = ".txt"
			return RINGCLAUDE_MEDIA_TXT
		ok
		return ""

	func sendFileToChat cChatID, cText, cFilePath
		cMediaType = detectMediaType(cFilePath)
		if cMediaType = ""
			cLastError = "Unsupported file type: " + cFilePath
			return NULL
		ok
		cBase64 = fileToBase64(cFilePath)
		if cBase64 = ""
			return NULL
		ok
		if cMediaType = RINGCLAUDE_MEDIA_JPEG or
		   cMediaType = RINGCLAUDE_MEDIA_PNG or
		   cMediaType = RINGCLAUDE_MEDIA_GIF or
		   cMediaType = RINGCLAUDE_MEDIA_WEBP
			return sendImageToChat(cChatID, cText, cBase64, cMediaType)
		else
			return sendDocumentToChat(cChatID, cText, cBase64, cMediaType)
		ok

	private

	func buildRequestJSON oChat
		cJSON = "{"

		# Model (string)
		cJSON += '"model":"' + jsonEsc(cModel) + '"'

		# Max Tokens (integer)
		cJSON += ',"max_tokens":' + "" + nMaxTokens

		# Messages (built by ClaudeChat.messagesToJSON)
		cJSON += ',"messages":' + oChat.messagesToJSON()

		# System prompt (string)
		cSys = oChat.getSystem()
		if cSys != NULL and cSys != ""
			cJSON += ',"system":"' + jsonEsc(cSys) + '"'
		ok

		# Temperature (number)
		if nTemperature >= 0
			cJSON += ',"temperature":' + "" + nTemperature
		ok

		# Top P (number)
		if nTopP >= 0
			cJSON += ',"top_p":' + "" + nTopP
		ok

		# Top K (number)
		if nTopK >= 0
			cJSON += ',"top_k":' + "" + nTopK
		ok

		# Stop Sequences (array of strings)
		if len(aStopSequences) > 0
			cJSON += ',"stop_sequences":['
			nCount = len(aStopSequences)
			for nIdx = 1 to nCount
				cJSON += '"' + jsonEsc(aStopSequences[nIdx]) + '"'
				if nIdx < nCount
					cJSON += ","
				ok
			next
			cJSON += ']'
		ok

		# Extended Thinking (integer)
		if nBudgetTokens > 0
			cJSON += ',"thinking":{"type":"enabled","budget_tokens":' + 
				"" + nBudgetTokens + '}'
		ok

		cJSON += "}"
		return cJSON

	func jsonEsc cStr
		if cStr = NULL
			return ""
		ok
		cResult = ""
		nLen = len(cStr)
		for nIdx = 1 to nLen
			cChar = cStr[nIdx]
			nCode = ascii(cChar)
			if cChar = '"'
				cResult += '\"'
			but cChar = "\"
				cResult += "\\"
			but nCode = 10
				cResult += "\n"
			but nCode = 13
				cResult += "\r"
			but nCode = 9
				cResult += "\t"
			but nCode < 32
				cHexChars = "0123456789abcdef"
				cResult += "\u00"
				cResult += cHexChars[(nCode >> 4) + 1]
				cResult += cHexChars[(nCode & 15) + 1]
			else
				cResult += cChar
			ok
		next
		return cResult

	func sendHTTPPost cBody
		curl = curl_easy_init()

		curl_easy_setopt(curl, CURLOPT_URL, cAPIURL)

		mylist = curl_slist_append(NULL, "content-type: application/json")
		curl_slist_append(mylist, "x-api-key: " + cAPIKey)
		curl_slist_append(mylist, "anthropic-version: " + cAPIVersion)

		curl_easy_setopt(curl, CURLOPT_HTTPHEADER, mylist)
		curl_easy_setopt(curl, CURLOPT_POSTFIELDS, cBody)
		curl_easy_setopt(curl, CURLOPT_POST, 1)

		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0)
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0)

		if lVerbose
			curl_easy_setopt(curl, CURLOPT_VERBOSE, 1)
		ok

		cOutput = curl_easy_perform_silent(curl)

		curl_slist_free_all(mylist)
		curl_easy_cleanup(curl)

		return cOutput

	func encodeBase64 cData
		cChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
		cResult = ""
		nLen = len(cData)
		nIdx = 1
		while nIdx <= nLen
			n1 = ascii(cData[nIdx])
			if nIdx + 1 <= nLen
				n2 = ascii(cData[nIdx + 1])
			else
				n2 = 0
			ok
			if nIdx + 2 <= nLen
				n3 = ascii(cData[nIdx + 2])
			else
				n3 = 0
			ok
			nI1 = (n1 >> 2) + 1
			nI2 = (((n1 & 3) << 4) | (n2 >> 4)) + 1
			nI3 = (((n2 & 15) << 2) | (n3 >> 6)) + 1
			nI4 = (n3 & 63) + 1

			cResult += cChars[nI1]
			cResult += cChars[nI2]
			if nIdx + 1 <= nLen
				cResult += cChars[nI3]
			else
				cResult += "="
			ok
			if nIdx + 2 <= nLen
				cResult += cChars[nI4]
			else
				cResult += "="
			ok
			nIdx += 3
		end
		return cResult
