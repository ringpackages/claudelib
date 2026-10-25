# API Configuration
RINGCLAUDE_API_URL         = "https://api.anthropic.com/v1/messages"
RINGCLAUDE_API_VERSION     = "2023-06-01"

# Model Constants
RINGCLAUDE_MODEL_OPUS_46          = "claude-opus-4-6"
RINGCLAUDE_MODEL_OPUS_45          = "claude-opus-4-5-20250514"
RINGCLAUDE_MODEL_SONNET_45        = "claude-sonnet-4-5-20250929"
RINGCLAUDE_MODEL_SONNET_4         = "claude-sonnet-4-20250514"
RINGCLAUDE_MODEL_HAIKU_45         = "claude-haiku-4-5-20251001"
RINGCLAUDE_MODEL_DEFAULT          = RINGCLAUDE_MODEL_SONNET_45

# Content Types
RINGCLAUDE_CONTENT_TEXT      = "text"
RINGCLAUDE_CONTENT_IMAGE     = "image"
RINGCLAUDE_CONTENT_DOCUMENT  = "document"

# Image Media Types
RINGCLAUDE_MEDIA_JPEG  = "image/jpeg"
RINGCLAUDE_MEDIA_PNG   = "image/png"
RINGCLAUDE_MEDIA_GIF   = "image/gif"
RINGCLAUDE_MEDIA_WEBP  = "image/webp"

# Document Media Types
RINGCLAUDE_MEDIA_PDF   = "application/pdf"
RINGCLAUDE_MEDIA_TXT   = "text/plain"

# Roles
RINGCLAUDE_ROLE_USER      = "user"
RINGCLAUDE_ROLE_ASSISTANT = "assistant"

# Stop Reasons
RINGCLAUDE_STOP_END_TURN    = "end_turn"
RINGCLAUDE_STOP_MAX_TOKENS  = "max_tokens"
RINGCLAUDE_STOP_SEQUENCE    = "stop_sequence"
