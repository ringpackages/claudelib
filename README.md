# ClaudeLib

ClaudeLib package for the Ring programming language

A Ring language library for the Anthropic Claude Messages API

## Install

	ringpm install claudelib from ringpackages

## Screen Shots

![Screen Shot 1](https://raw.githubusercontent.com/ringpackages/claudelib/main/images/claudelib_shot1.png)

![Screen Shot 2](https://raw.githubusercontent.com/ringpackages/claudelib/main/images/claudelib_shot2.png)

![Screen Shot 3](https://raw.githubusercontent.com/ringpackages/claudelib/main/images/claudelib_shot3.png)

## Quick Start

```ring
load "claudelib.ring"

oClient = new ClaudeClient(read("claude_api_key.txt"))

# One question, one answer
? oClient.ask("What is the Ring programming language?") 

```

## Samples

More examples are in the samples/UsingClaudeLib folder:

| Sample | Description |
|---|---|
| sample1_basic.ring | Questions, system prompt, model selection, conversation, response details, error handling |
| sample2_advanced.ring | Multiple chats, temperature, max tokens, stop sequences, thinking, debug mode, building messages, top_p/top_k |
| sample3_files.ring | Images (file and URL), PDF and text documents, auto-detected files, multi-modal messages |
| sample4_chatbot.ring | Interactive console chatbot with commands |

## Classes

### ClaudeClient

The main class. It stores the settings, manages the chats and sends the requests.

```ring
oClient = new ClaudeClient(cAPIKey)
```

Most setter methods return the object, so calls can be chained.

**Settings**

| Method | Description |
|---|---|
| `setAPIKey(cKey)` / `getAPIKey()` | Set or get the API key |
| `setModel(cModel)` / `getModel()` | Set or get the model (use the model constants) |
| `setMaxTokens(nTokens)` / `getMaxTokens()` | Set or get the max tokens in the answer (default: 4096) |
| `setTemperature(nTemp)` / `getTemperature()` | Set or get the temperature (-1 = default) |
| `setTopP(nValue)` | Set top_p (-1 = default) |
| `setTopK(nValue)` | Set top_k (-1 = default) |
| `addStopSequence(cSeq)` | Add a stop sequence |
| `clearStopSequences()` | Remove all stop sequences |
| `setBudgetTokens(nTokens)` | Enable thinking when nTokens > 0, disable it with 0 |
| `setVerbose(lValue)` | Print the request and response JSON (debug mode) |
| `setAPIURL(cURL)` | Change the API URL |
| `setAPIVersion(cVersion)` | Change the API version |
| `getLastError()` | Get the last error message |

**Model Capabilities**

| Method | Description |
|---|---|
| `supportsSampling()` | False for Claude 4.7 and later models (they accept only the default sampling) |
| `supportsAdaptiveThinking()` | True for Claude 4.6 and later models |
| `isNewModel()` | True for Claude 4.7 and later models |

The library uses these methods to build a valid request for each model:

* temperature, top_p and top_k are sent only if `supportsSampling()` is true and thinking is disabled (thinking requires the default sampling).
* When thinking is enabled, models with adaptive thinking get `{"type":"adaptive","display":"summarized"}` and the budget value is ignored. Older models (like Sonnet 4.5 and Haiku 4.5) get `{"type":"enabled","budget_tokens":n}`.

**Chats**

| Method | Description |
|---|---|
| `createChat(cChatID)` | Create a new chat and return it (ClaudeChat object) |
| `getChat(cChatID)` | Return the chat, or NULL if not found |
| `deleteChat(cChatID)` | Delete the chat (returns true/false) |
| `getChatList()` | Return a list of the chat IDs |
| `getChatCount()` | Return the number of chats |

**Sending**

| Method | Description |
|---|---|
| `ask(cQuestion)` | Send one question and return the answer text ("" on error) |
| `askWithSystem(cQuestion, cSystemPrompt)` | Like `ask()` but with a system prompt |
| `sendChat(oChat)` | Send the chat messages and return a ClaudeResponse object |
| `sendToChat(cChatID, cMessage)` | Add a user message to the chat, then send it |
| `sendImageToChat(cChatID, cText, cBase64Data, cMediaType)` | Send text with a base64 image |
| `sendImageURLToChat(cChatID, cText, cImageURL)` | Send text with an image URL |
| `sendDocumentToChat(cChatID, cText, cBase64Data, cMediaType)` | Send text with a base64 document |
| `sendFileToChat(cChatID, cText, cFilePath)` | Send text with a file (image or document, detected from the extension) |

The send methods return NULL if the request can't be sent (for example, the API key or the chat is missing). Use `getLastError()` to know why.

After a successful answer, the answer text is added to the chat history automatically.

**Files**

| Method | Description |
|---|---|
| `fileToBase64(cFilePath)` | Read a file and return its base64 content ("" on error) |
| `detectMediaType(cFilePath)` | Return the media type from the file extension (jpg, jpeg, png, gif, webp, pdf, txt) or "" |

### ClaudeChat

A conversation: a system prompt and a list of messages. Usually created using `ClaudeClient.createChat()`.

```ring
oChat = new ClaudeChat(cChatID)
```

| Method | Description |
|---|---|
| `getID()` | Return the chat ID |
| `setSystem(cPrompt)` / `getSystem()` | Set or get the system prompt |
| `addMessage(oMsg)` | Add a ClaudeMessage object |
| `addUserText(cText)` | Add a user text message |
| `addAssistantText(cText)` | Add an assistant text message |
| `addUserImageBase64(cText, cBase64Data, cMediaType)` | Add a user message with text and a base64 image |
| `addUserImageURL(cText, cImageURL)` | Add a user message with text and an image URL |
| `addUserDocument(cText, cBase64Data, cMediaType)` | Add a user message with text and a base64 document |
| `addUserTextDocument(cText, cDocText, cTitle)` | Add a user message with text and a plain text document |
| `getMessages()` | Return the list of ClaudeMessage objects |
| `clearMessages()` | Remove all messages |
| `getMessageCount()` | Return the number of messages |
| `getLastResponse()` | Return the last raw JSON response |
| `getLastText()` | Return the last answer text |
| `messagesToJSON()` | Return the messages as a JSON array (used by the client) |

### ClaudeMessage

One message with a role and one or more content blocks (text, images and documents).

```ring
oMsg = new ClaudeMessage(CLAUDELIB_ROLE_USER)
oMsg.addText("Translate the following:")
oMsg.addText("Hello, how are you today?")
oChat.addMessage(oMsg)
```

| Method | Description |
|---|---|
| `setRole(cRole)` / `getRole()` | Set or get the role (use the role constants) |
| `addText(cText)` | Add a text block |
| `addImageBase64(cBase64Data, cMediaType)` | Add a base64 image block |
| `addImageURL(cImageURL)` | Add an image block from a URL |
| `addDocumentBase64(cBase64Data, cMediaType)` | Add a base64 document block (like PDF) |
| `addDocumentPlainText(cText, cTitle)` | Add a plain text document block |
| `getContent()` | Return the list of content blocks |
| `toJSON()` | Return the message as JSON (used by the chat) |

### ClaudeResponse

The result of a request, returned by the send methods.

| Method | Description |
|---|---|
| `getText()` | Return the answer text |
| `getThinking()` | Return the thinking text (when thinking is enabled) |
| `getStopReason()` | Return the stop reason (see the stop reason constants) |
| `getModel()` | Return the model used |
| `getID()` | Return the message ID |
| `getInputTokens()` | Return the number of input tokens |
| `getOutputTokens()` | Return the number of output tokens |
| `getTotalTokens()` | Return the input + output tokens |
| `isError()` | Return true if the API returned an error |
| `getErrorType()` | Return the error type |
| `getErrorMessage()` | Return the error message |
| `getRaw()` | Return the raw JSON response |

## Constants

### Models

| Constant | Model ID | Notes |
|---|---|---|
| `CLAUDELIB_MODEL_FABLE_51` | `claude-fable-5-1` | Most capable model |
| `CLAUDELIB_MODEL_FABLE_5` | `claude-fable-5` | |
| `CLAUDELIB_MODEL_OPUS_55` | `claude-opus-5-5` | Current Opus |
| `CLAUDELIB_MODEL_OPUS_5` | `claude-opus-5` | |
| `CLAUDELIB_MODEL_OPUS_48` | `claude-opus-4-8` | |
| `CLAUDELIB_MODEL_OPUS_47` | `claude-opus-4-7` | |
| `CLAUDELIB_MODEL_OPUS_46` | `claude-opus-4-6` | |
| `CLAUDELIB_MODEL_OPUS_45` | `claude-opus-4-5-20251101` | |
| `CLAUDELIB_MODEL_SONNET_55` | `claude-sonnet-5-5` | Current Sonnet |
| `CLAUDELIB_MODEL_SONNET_5` | `claude-sonnet-5` | |
| `CLAUDELIB_MODEL_SONNET_46` | `claude-sonnet-4-6` | |
| `CLAUDELIB_MODEL_SONNET_45` | `claude-sonnet-4-5-20250929` | |
| `CLAUDELIB_MODEL_SONNET_4` | `claude-sonnet-4-20250514` | Deprecated by Anthropic |
| `CLAUDELIB_MODEL_HAIKU_55` | `claude-haiku-5-5` | Current Haiku |
| `CLAUDELIB_MODEL_HAIKU_45` | `claude-haiku-4-5-20251001` | |
| `CLAUDELIB_MODEL_DEFAULT` | Same as `CLAUDELIB_MODEL_SONNET_45` | Used by new clients |

### Content Types

| Constant | Value |
|---|---|
| `CLAUDELIB_CONTENT_TEXT` | `"text"` |
| `CLAUDELIB_CONTENT_IMAGE` | `"image"` |
| `CLAUDELIB_CONTENT_DOCUMENT` | `"document"` |

### Media Types

| Constant | Value |
|---|---|
| `CLAUDELIB_MEDIA_JPEG` | `"image/jpeg"` |
| `CLAUDELIB_MEDIA_PNG` | `"image/png"` |
| `CLAUDELIB_MEDIA_GIF` | `"image/gif"` |
| `CLAUDELIB_MEDIA_WEBP` | `"image/webp"` |
| `CLAUDELIB_MEDIA_PDF` | `"application/pdf"` |
| `CLAUDELIB_MEDIA_TXT` | `"text/plain"` |

### Roles

| Constant | Value |
|---|---|
| `CLAUDELIB_ROLE_USER` | `"user"` |
| `CLAUDELIB_ROLE_ASSISTANT` | `"assistant"` |

### Stop Reasons

Compare these with `ClaudeResponse.getStopReason()`.

| Constant | Value | Meaning |
|---|---|---|
| `CLAUDELIB_STOP_END_TURN` | `"end_turn"` | Claude finished its answer |
| `CLAUDELIB_STOP_MAX_TOKENS` | `"max_tokens"` | The answer reached the max tokens limit |
| `CLAUDELIB_STOP_SEQUENCE` | `"stop_sequence"` | The answer reached one of the stop sequences |

## License

This package is free open source (MIT License)