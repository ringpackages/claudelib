class ClaudeMessage

	cRole    = ""
	aContent = []

	func init cMsgRole
		cRole = cMsgRole

	func setRole cMsgRole
		cRole = cMsgRole
		return self

	func getRole
		return cRole

	func addText cText
		aContent + [
			:type = RINGCLAUDE_CONTENT_TEXT,
			:text = cText
		]
		return self

	func addImageBase64 cBase64Data, cMediaType
		aContent + [
			:type       = RINGCLAUDE_CONTENT_IMAGE,
			:sourcetype = "base64",
			:mediatype  = cMediaType,
			:data       = cBase64Data
		]
		return self

	func addImageURL cImageURL
		aContent + [
			:type       = RINGCLAUDE_CONTENT_IMAGE,
			:sourcetype = "url",
			:imageurl   = cImageURL
		]
		return self

	func addDocumentBase64 cBase64Data, cMediaType
		aContent + [
			:type       = RINGCLAUDE_CONTENT_DOCUMENT,
			:sourcetype = "base64",
			:mediatype  = cMediaType,
			:data       = cBase64Data
		]
		return self

	func addDocumentPlainText cText, cTitle
		aContent + [
			:type       = RINGCLAUDE_CONTENT_DOCUMENT,
			:sourcetype = "text",
			:mediatype  = RINGCLAUDE_MEDIA_TXT,
			:data       = cText,
			:title      = cTitle
		]
		return self

	func getContent
		return aContent

	# Build JSON string for this message
	func toJSON
		cJSON = '{"role":"' + jsonEsc(cRole) + '","content":['
		nCount = len(aContent)
		for nIdx = 1 to nCount
			aItem = aContent[nIdx]
			switch aItem[:type]
			on RINGCLAUDE_CONTENT_TEXT
				cJSON += '{"type":"text","text":"' + 
					jsonEsc(aItem[:text]) + '"}'
			on RINGCLAUDE_CONTENT_IMAGE
				if aItem[:sourcetype] = "base64"
					cJSON += '{"type":"image","source":{' +
						'"type":"base64",' +
						'"media_type":"' + jsonEsc(aItem[:mediatype]) + '",' +
						'"data":"' + aItem[:data] + '"' +
						'}}'
				else
					cJSON += '{"type":"image","source":{' +
						'"type":"url",' +
						'"url":"' + jsonEsc(aItem[:imageurl]) + '"' +
						'}}'
				ok
			on RINGCLAUDE_CONTENT_DOCUMENT
				if aItem[:sourcetype] = "base64"
					cJSON += '{"type":"document","source":{' +
						'"type":"base64",' +
						'"media_type":"' + jsonEsc(aItem[:mediatype]) + '",' +
						'"data":"' + aItem[:data] + '"' +
						'}}'
				but aItem[:sourcetype] = "text"
					cJSON += '{"type":"document","source":{' +
						'"type":"text",' +
						'"media_type":"text/plain",' +
						'"data":"' + jsonEsc(aItem[:data]) + '"' +
						'}'
					if aItem[:title] != NULL and aItem[:title] != ""
						cJSON += ',"title":"' + jsonEsc(aItem[:title]) + '"'
					ok
					cJSON += '}'
				ok
			off
			if nIdx < nCount
				cJSON += ","
			ok
		next
		cJSON += "]}"
		return cJSON

	private

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