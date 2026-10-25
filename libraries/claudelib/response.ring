class ClaudeResponse

	cRawJSON      = ""
	cID           = ""
	cModel        = ""
	cStopReason   = ""
	cText         = ""
	nInputTokens  = 0
	nOutputTokens = 0
	lError        = false
	cErrorType    = ""
	cErrorMessage = ""
	cThinking     = ""

	func init cJSON
		cRawJSON = cJSON
		parseResponse()

	func getRaw
		return cRawJSON

	func getID
		return cID

	func getModel
		return cModel

	func getStopReason
		return cStopReason

	func getText
		return cText

	func getInputTokens
		return nInputTokens

	func getOutputTokens
		return nOutputTokens

	func getTotalTokens
		return nInputTokens + nOutputTokens

	func isError
		return lError

	func getErrorType
		return cErrorType

	func getErrorMessage
		return cErrorMessage

	func getThinking
		return cThinking

	private

	func parseResponse
		if cRawJSON = NULL or cRawJSON = ""
			lError = true
			cErrorType = "empty_response"
			cErrorMessage = "Empty response from API"
			return
		ok

		# Check if error response
		if substr(cRawJSON, '"type":"error"') > 0 or 
		   substr(cRawJSON, '"type": "error"') > 0
			lError = true
			nErrorPos = substr(cRawJSON, '"error"')
			if nErrorPos > 0
				cErrorType = extractVal(cRawJSON, "type", nErrorPos + 7)
				cErrorMessage = extractVal(cRawJSON, "message", nErrorPos)
			ok
			return
		ok

		# Extract top-level fields
		cID = extractVal(cRawJSON, "id", 1)
		cModel = extractVal(cRawJSON, "model", 1)
		cStopReason = extractVal(cRawJSON, "stop_reason", 1)

		# Extract text from content blocks
		cText = extractContentByType(cRawJSON, "text", "text")

		# Extract thinking from content blocks
		cThinking = extractContentByType(cRawJSON, "thinking", "thinking")

		# Extract usage tokens
		nUsagePos = substr(cRawJSON, '"usage"')
		if nUsagePos > 0
			cInp = extractVal(cRawJSON, "input_tokens", nUsagePos)
			cOut = extractVal(cRawJSON, "output_tokens", nUsagePos)
			if cInp != ""
				nInputTokens = 0 + cInp
			ok
			if cOut != ""
				nOutputTokens = 0 + cOut
			ok
		ok

	# Extract a string or numeric value for a given key from JSON
	# starting search at position nStart
	func extractVal cJSON, cKey, nStart
		if nStart < 1
			nStart = 1
		ok
		cSearch = '"' + cKey + '"'
		nPos = findFrom(cJSON, cSearch, nStart)
		if nPos = 0
			return ""
		ok

		# Find colon after key
		nAfterKey = nPos + len(cSearch)
		nColonPos = findFrom(cJSON, ":", nAfterKey)
		if nColonPos = 0
			return ""
		ok

		# Skip whitespace after colon
		nIdx = nColonPos + 1
		nJLen = len(cJSON)
		while nIdx <= nJLen
			cCh = cJSON[nIdx]
			if cCh != " " and cCh != char(9) and 
			   cCh != char(10) and cCh != char(13)
				exit
			ok
			nIdx++
		end

		if nIdx > nJLen
			return ""
		ok

		# String value
		if cJSON[nIdx] = '"'
			nValStart = nIdx + 1
			nValEnd = nValStart
			while nValEnd <= nJLen
				if cJSON[nValEnd] = "\" and nValEnd + 1 <= nJLen
					nValEnd += 2
					loop
				ok
				if cJSON[nValEnd] = '"'
					exit
				ok
				nValEnd++
			end
			return jsonUnesc(substr(cJSON, nValStart, nValEnd - nValStart))
		ok

		# Null value
		if nIdx + 3 <= nJLen
			if substr(cJSON, nIdx, 4) = "null"
				return ""
			ok
		ok

		# Numeric/boolean value
		nValStart = nIdx
		nValEnd = nIdx
		while nValEnd <= nJLen
			cCh = cJSON[nValEnd]
			if cCh = "," or cCh = "}" or cCh = "]" or
			   cCh = " " or cCh = char(10) or cCh = char(13)
				exit
			ok
			nValEnd++
		end
		return substr(cJSON, nValStart, nValEnd - nValStart)

	# Find all content blocks of a given type and extract a field
	func extractContentByType cJSON, cTypeName, cFieldName
		cResult = ""
		nPos = 1
		cTypeSearch = '"type":"' + cTypeName + '"'
		cTypeSearch2 = '"type": "' + cTypeName + '"'
		while true
			nTypePos = findFrom(cJSON, cTypeSearch, nPos)
			if nTypePos = 0
				nTypePos = findFrom(cJSON, cTypeSearch2, nPos)
			ok
			if nTypePos = 0
				exit
			ok
			cVal = extractVal(cJSON, cFieldName, nTypePos + 10)
			if cVal != ""
				if cResult != ""
					cResult += nl
				ok
				cResult += cVal
			ok
			nPos = nTypePos + 15
		end
		return cResult

	# Find substring in string starting from position nFrom
	func findFrom cStr, cFind, nFrom
		if nFrom <= 1
			return substr(cStr, cFind)
		ok
		nLen = len(cStr)
		if nFrom > nLen
			return 0
		ok
		# Get the tail of the string from nFrom onward
		cTail = substr(cStr, nFrom)
		nResult = substr(cTail, cFind)
		if nResult > 0
			return nResult + nFrom - 1
		ok
		return 0

	# Unescape a JSON string value
	func jsonUnesc cStr
		if cStr = NULL
			return ""
		ok
		cResult = ""
		nIdx = 1
		nLen = len(cStr)
		while nIdx <= nLen
			cCh = cStr[nIdx]
			if cCh = "\" and nIdx < nLen
				nIdx++
				cNext = cStr[nIdx]
				if cNext = '"'
					cResult += '"'
				but cNext = "\"
					cResult += "\"
				but cNext = "/"
					cResult += "/"
				but cNext = "n"
					cResult += nl
				but cNext = "t"
					cResult += char(9)
				but cNext = "r"
					cResult += char(13)
				but cNext = "b"
					cResult += char(8)
				but cNext = "f"
					cResult += char(12)
				but cNext = "u"
					# \uXXXX
					if nIdx + 4 <= nLen
						cHex = substr(cStr, nIdx + 1, 4)
						nCode = 0
						for nHIdx = 1 to 4
							cH = upper(cHex[nHIdx])
							if cH >= "0" and cH <= "9"
								nCode = nCode * 16 + (ascii(cH) - ascii("0"))
							but cH >= "A" and cH <= "F"
								nCode = nCode * 16 + 10 + (ascii(cH) - ascii("A"))
							ok
						next
						if nCode < 128
							cResult += char(nCode)
						else
							cResult += "?"
						ok
						nIdx += 4
					ok
				else
					cResult += cNext
				ok
			else
				cResult += cCh
			ok
			nIdx++
		end
		return cResult