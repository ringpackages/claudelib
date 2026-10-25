load "claudelib.ring"

func main

	oClient = new ClaudeClient(read("claude_api_key.txt"))

	# ====================================================================
	#  Example 1: Send an Image File (Base64)
	# ====================================================================

	see "=== Example 1: Upload Image File ===" + nl + nl

	oChat = oClient.createChat("image-chat")

	cBase64 = oClient.fileToBase64("resources/photo.jpg")
	if cBase64 != ""
		oChat.addUserImageBase64(
			"What do you see in this image? Describe it in detail.",
			cBase64,
			CLAUDELIB_MEDIA_JPEG
		)
		oResponse = oClient.sendChat(oChat)
		see "Image description: " + oResponse.getText() + nl + nl
	else
		see "Could not read image file." + nl
		see "Error: " + oClient.getLastError() + nl + nl
	ok

	# ====================================================================
	#  Example 2: Send an Image from URL
	# ====================================================================

	see "=== Example 2: Image from URL ===" + nl + nl

	oChat2 = oClient.createChat("url-image-chat")
	oChat2.addUserImageURL(
		"What animal is shown in this image?",
		"https://upload.wikimedia.org/wikipedia/commons/a/a7/Camponotus_flavomarginatus_ant.jpg"
	)
	oResponse = oClient.sendChat(oChat2)
	see "URL image: " + oResponse.getText() + nl + nl

	# ====================================================================
	#  Example 3: Send a PDF Document
	# ====================================================================

	see "=== Example 3: Upload PDF ===" + nl + nl

	oChat3 = oClient.createChat("pdf-chat")

	cPDFBase64 = oClient.fileToBase64("resources/document.pdf")
	if cPDFBase64 != ""
		oChat3.addUserDocument(
			"Please summarize this PDF document.",
			cPDFBase64,
			CLAUDELIB_MEDIA_PDF
		)
		oResponse = oClient.sendChat(oChat3)
		see "PDF Summary: " + oResponse.getText() + nl + nl
	else
		see "Could not read PDF file (expected if file does not exist)." + nl + nl
	ok

	# ====================================================================
	#  Example 4: Send a Plain Text Document
	# ====================================================================

	see "=== Example 4: Plain Text Document ===" + nl + nl

	oChat4 = oClient.createChat("text-doc-chat")

	cDocContent = "Ring Programming Language" + nl +
		"=========================" + nl +
		"Ring is a practical general-purpose multi-paradigm language." + nl +
		"It supports procedural, object-oriented, functional," + nl +
		"and natural programming paradigms." + nl + nl +
		"Key Features:" + nl +
		"- Dynamic typing" + nl +
		"- Garbage collection" + nl +
		"- Classes and objects" + nl +
		"- Natural language programming" + nl +
		"- Comprehensive standard library"

	oChat4.addUserTextDocument(
		"Based on this document, what are the key features of Ring?",
		cDocContent,
		"Ring Language Overview"
	)

	oResponse = oClient.sendChat(oChat4)
	see "Document analysis: " + oResponse.getText() + nl + nl

	# ====================================================================
	#  Example 5: Auto-detect and Upload Any File
	# ====================================================================

	see "=== Example 5: Auto-detect File Upload ===" + nl + nl

	oChat5 = oClient.createChat("auto-upload")

	# sendFileToChat auto-detects the file type from extension
	oResp = oClient.sendFileToChat("auto-upload", 
		"Describe this image.", "resources/screenshot.png")
	if oResp != NULL
		see "Auto-upload result: " + oResp.getText() + nl + nl
	else
		see "Auto-upload: " + oClient.getLastError() + nl + nl
	ok

	# ====================================================================
	#  Example 6: Multi-modal Message (Text + Image + Document)
	# ====================================================================

	see "=== Example 6: Multi-modal Message ===" + nl + nl

	oChat6 = oClient.createChat("multimodal")
	oChat6.setSystem("You are a helpful assistant that can analyze both text and images.")

	# Build a complex message with multiple content types
	oMsg = new ClaudeMessage(CLAUDELIB_ROLE_USER)
	oMsg.addText("I have two items to show you:")
	oMsg.addImageURL("https://upload.wikimedia.org/wikipedia/commons/a/a7/Camponotus_flavomarginatus_ant.jpg")
	oMsg.addDocumentPlainText(
		"Ants are social insects that live in colonies. " +
		"They are known for their organized behavior and teamwork.",
		"Ant Facts"
	)
	oMsg.addText("Does the image match the document content? Explain.")

	oChat6.addMessage(oMsg)
	oResponse = oClient.sendChat(oChat6)
	see "Multi-modal: " + oResponse.getText() + nl + nl

	# ====================================================================
	#  Example 7: Follow-up Questions About Uploaded Content
	# ====================================================================

	see "=== Example 7: Follow-up on Uploads ===" + nl + nl

	oChat7 = oClient.createChat("follow-up-upload")

	cCodeSample = 'load "stdlib.ring"' + nl +
		"func main" + nl +
		"    aList = 1:10" + nl +
		'    aResult = filter(aList, func x { return x % 2 = 0 })' + nl +
		"    see aResult"

	oChat7.addUserTextDocument(
		"Read this code and explain what it does.",
		cCodeSample,
		"Ring Code Sample"
	)

	oResponse = oClient.sendChat(oChat7)
	see "Code explanation: " + oResponse.getText() + nl + nl

	# Follow-up about the same document (history preserved via ref)
	oChat7.addUserText("How could I modify this to find odd numbers instead?")
	oResponse = oClient.sendChat(oChat7)
	see "Follow-up: " + oResponse.getText() + nl + nl

	see "=== All File Upload Examples Complete ===" + nl
