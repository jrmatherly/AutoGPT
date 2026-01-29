# Voice and Text-to-Speech Providers

AutoGPT supports multiple voice and text-to-speech (TTS) providers for generating natural-sounding audio and video content with AI-powered voices.

## Provider Overview

| Provider         | Type           | Key Features                              | Best For                           |
| ---------------- | -------------- | ----------------------------------------- | ---------------------------------- |
| **Unreal Speech**| TTS API        | Direct MP3 generation, customizable       | Audio-only TTS, cost-effective     |
| **D-ID**         | Video + Voice  | Avatar videos with voice synthesis        | Talking avatar videos, marketing   |

---

## Unreal Speech

Direct text-to-speech API for high-quality voice generation with customizable parameters.

### Overview

Unreal Speech provides a straightforward API for converting text to speech with control over voice selection, audio quality, speed, and pitch. The API returns direct MP3 URLs for immediate use.

### Available Voices

The following voices are available through Unreal Speech:

- **Scarlett** (default) - Female voice
- Additional voices available - see [Unreal Speech Voice Gallery](https://unrealspeech.com/voices)

### Configuration Options

| Parameter   | Description                           | Default   | Range/Options             |
| ----------- | ------------------------------------- | --------- | ------------------------- |
| `voice_id`  | Voice identifier                      | Scarlett  | See voice list            |
| `bitrate`   | Audio quality                         | 192k      | 64k, 128k, 192k, 320k     |
| `speed`     | Speech speed adjustment               | 0         | -1.0 to 1.0               |
| `pitch`     | Voice pitch adjustment                | 1         | 0.5 to 2.0                |
| `timestamp` | Timestamp generation type             | sentence  | word, sentence            |

### Setup

1. Get API key from [Unreal Speech](https://unrealspeech.com)
2. In AutoGPT, select the **Unreal Text To Speech** block
3. Add your Unreal Speech credentials when prompted
4. Configure voice and audio parameters

### Usage Example

**Block Configuration:**
```
Block: Unreal Text To Speech
Inputs:
  - text: "Welcome to AutoGPT. This is a demonstration of text to speech."
  - voice_id: "Scarlett"
  - credentials: [Your Unreal Speech API key]

Output:
  - mp3_url: "https://api.v7.unrealspeech.com/speech/[generated-id].mp3"
```

### Use Cases

- **Audio Content Creation**: Generate voiceovers for videos, podcasts, or presentations
- **Accessibility**: Convert text content to audio for visually impaired users
- **Notifications**: Create audio alerts and notifications
- **E-Learning**: Generate narration for educational content
- **Multilingual Content**: Support multiple languages with appropriate voice selection

### API Details

- **Endpoint**: `https://api.v7.unrealspeech.com/speech`
- **Method**: POST
- **Response**: JSON with `OutputUri` containing the MP3 URL
- **Authentication**: Bearer token in Authorization header

### Pricing & Limits

- Check current pricing at [Unreal Speech Pricing](https://unrealspeech.com/pricing)
- API key required for all requests
- Rate limits apply based on subscription tier

---

## D-ID

Video generation service that creates talking avatar videos by combining images with voice synthesis from multiple voice providers.

### Overview

D-ID specializes in creating realistic talking avatar videos from still images. While primarily a video generation service, it integrates with multiple voice providers to synthesize speech for the avatars.

### Supported Voice Providers

D-ID integrates with three major voice providers:

1. **Microsoft Azure** - Wide language support, neural voices
2. **ElevenLabs** - High-quality AI voices, natural intonation
3. **Amazon Polly** - AWS-integrated, cost-effective

### Microsoft Azure Voices

Microsoft Azure provides neural text-to-speech voices with natural intonation and emotion.

**Setup:**

1. Browse [Azure Voice Gallery](https://speech.microsoft.com/portal/voicegallery)
2. Select a voice from the gallery
3. Click on the "Sample code" tab on the right side
4. Copy the voice name from the code sample

**Example:**
```
// From Azure sample code:
config.SpeechSynthesisVoiceName = "en-GB-AbbiNeural"

// Use in D-ID block:
voice_id: "en-GB-AbbiNeural"
```

**Popular Azure Voices:**
- `en-US-JennyNeural` - US English, Female (default in AutoGPT)
- `en-GB-AbbiNeural` - British English, Female
- `en-US-GuyNeural` - US English, Male
- `en-AU-NatashaNeural` - Australian English, Female
- `es-ES-ElviraNeural` - Spanish (Spain), Female
- `fr-FR-DeniseNeural` - French (France), Female

### ElevenLabs Voices

ElevenLabs provides state-of-the-art AI voices with exceptional naturalness and emotion.

**Setup:**

1. Get voice list from [ElevenLabs API](https://api.elevenlabs.io/v1/voices)
2. Find the voice you want to use in the JSON response
3. Copy the `voice_id` field
4. Use it directly in the D-ID block

**Example API Response:**
```json
{
  "voices": [
    {
      "voice_id": "21m00Tcm4TlvDq8ikWAM",
      "name": "Rachel"
    },
    {
      "voice_id": "AZnzlk1XvdvUeBnXmlld",
      "name": "Domi"
    }
  ]
}
```

**Usage:**
```
voice_id: "21m00Tcm4TlvDq8ikWAM"  // Rachel voice
provider: "elevenlabs"
```

**Note:** ElevenLabs requires a separate API key, configured through D-ID's integration.

### Amazon Polly Voices

Amazon Polly provides cloud-based text-to-speech with a wide selection of voices and languages.

**Setup:**

1. Browse [AWS Polly Voice List](https://docs.aws.amazon.com/polly/latest/dg/available-voices.html)
2. Find the voice name/ID in the documentation
3. Use the voice ID directly in the D-ID block

**Popular Polly Voices:**
- `Joanna` - US English, Female
- `Matthew` - US English, Male
- `Salli` - US English, Female
- `Joey` - US English, Male
- `Amy` - British English, Female
- `Emma` - British English, Female
- `Brian` - British English, Male

**Usage:**
```
voice_id: "Joanna"
provider: "amazon"
```

### D-ID Block Configuration

**Block:** Create Talking Avatar Video

**Required Inputs:**
- `script_input` - The text to be spoken by the avatar
- `provider` - Voice provider: `microsoft`, `elevenlabs`, or `amazon`
- `voice_id` - Voice identifier from the selected provider
- `presenter_id` - Avatar image identifier (default: `amy-Aq6OmGZnMt`)
- `driver_id` - Animation driver (default: `Vcq0R4a8F0`)

**Optional Inputs:**
- `result_format` - Output format: `mp4` (default), `gif`, or `wav`
- `crop_type` - Video aspect ratio: `wide` (default), `square`, or `vertical`
- `subtitles` - Enable/disable subtitles (default: `false`)
- `ssml` - Enable SSML support for advanced speech control (default: `false`)

**Output:**
- `video_url` - URL to the generated talking avatar video

### Usage Example

**Configuration:**
```
Block: Create Talking Avatar Video
Inputs:
  - script_input: "Welcome to our product demo. Let me show you the key features."
  - provider: "microsoft"
  - voice_id: "en-US-JennyNeural"
  - presenter_id: "amy-Aq6OmGZnMt"
  - driver_id: "Vcq0R4a8F0"
  - result_format: "mp4"
  - crop_type: "wide"
  - subtitles: false

Output:
  - video_url: "https://d-id.com/api/clips/[clip-id]/video"
```

### D-ID Use Cases

- **Marketing Videos**: Create personalized video messages with branded avatars
- **E-Learning**: Generate educational content with virtual instructors
- **Product Demos**: Showcase products with AI-generated presenters
- **Social Media**: Create engaging video content for platforms like Instagram, TikTok
- **Customer Support**: Generate FAQ videos with consistent avatar representation
- **News & Updates**: Create announcement videos with professional presentation

### Advanced Features

**SSML Support:**
D-ID supports SSML (Speech Synthesis Markup Language) for fine-grained control over speech:

```xml
<speak>
  <prosody rate="slow">This part is slower.</prosody>
  <break time="500ms"/>
  <prosody pitch="+10%">This part has higher pitch.</prosody>
</speak>
```

Set `ssml: true` when using SSML in `script_input`.

**Custom Avatars:**
- Upload custom images to D-ID
- Use custom `presenter_id` values for brand-specific avatars
- Control animation style with different `driver_id` values

### API Details

- **Base URL**: `https://api.d-id.com`
- **Authentication**: Basic auth with API key
- **Polling**: Video generation is asynchronous (typically 30-60 seconds)
- **Formats**: MP4, GIF, WAV audio-only
- **Rate Limits**: Based on D-ID subscription tier

---

## Provider Comparison

### When to Use Each Provider

**Use Unreal Speech when:**
- ✅ You only need audio output (no video)
- ✅ Cost-effectiveness is a priority
- ✅ Simple TTS with standard voices is sufficient
- ✅ You need fast, direct MP3 generation
- ✅ You want full control over audio parameters

**Use D-ID when:**
- ✅ You need talking avatar videos
- ✅ Visual presentation is important
- ✅ You want to use premium voices (ElevenLabs)
- ✅ You need SSML support for advanced speech control
- ✅ You're creating marketing or social media content

### Voice Quality Comparison

| Provider            | Quality Level | Naturalness | Emotion  | Languages      |
| ------------------- | ------------- | ----------- | -------- | -------------- |
| Unreal Speech       | High          | Good        | Standard | 10+            |
| Azure (via D-ID)    | Very High     | Excellent   | Good     | 100+           |
| ElevenLabs (D-ID)   | Premium       | Exceptional | Excellent| 20+            |
| Amazon Polly (D-ID) | High          | Good        | Standard | 60+            |

### Cost Considerations

**Unreal Speech:**
- Direct API pricing
- Pay-per-character or subscription
- No video generation overhead
- Most cost-effective for audio-only

**D-ID:**
- Video generation pricing
- Includes voice synthesis costs
- Higher cost due to video processing
- Premium pricing for premium features

---

## Best Practices

### Voice Selection

1. **Match voice to content**:
   - Professional content: Neutral, clear voices
   - Marketing: Engaging, enthusiastic voices
   - Education: Clear, patient-sounding voices

2. **Consider audience**:
   - Geographic location (accent/dialect)
   - Age demographic (voice age/tone)
   - Industry context (formal vs. casual)

3. **Test multiple voices**:
   - Create samples with different voices
   - Get feedback from target audience
   - A/B test for optimal engagement

### Audio Quality

**For Unreal Speech:**
- Use 192k or 320k bitrate for production content
- Use 128k for testing or high-volume applications
- Adjust speed carefully (±20% maximum for natural sound)
- Keep pitch close to default (0.8-1.2 range)

**For D-ID:**
- Use MP4 format for social media (best compatibility)
- Use square crop for Instagram, vertical for TikTok/Stories
- Enable subtitles for accessibility and silent viewing
- Test SSML markup before production use

### Performance Optimization

1. **Batch processing**: Generate multiple audio/video files in parallel workflows
2. **Caching**: Store frequently used voice content to avoid regeneration
3. **Error handling**: Implement retry logic for API failures
4. **Monitoring**: Track API usage and costs

### Accessibility

- Always provide text alternatives for audio content
- Enable subtitles in D-ID videos for hearing-impaired users
- Use clear, well-articulated voices for maximum comprehension
- Consider providing transcripts alongside audio content

---

## Troubleshooting

### Common Issues

**Unreal Speech:**

| Issue | Solution |
| ----- | -------- |
| Invalid API key | Verify key is active at unrealspeech.com |
| Voice not found | Check voice_id spelling and availability |
| Audio quality poor | Increase bitrate to 192k or 320k |
| Speech too fast/slow | Adjust speed parameter in smaller increments |

**D-ID:**

| Issue | Solution |
| ----- | -------- |
| Video generation timeout | Increase polling attempts/interval |
| Voice ID not working | Verify provider matches voice ID format |
| SSML parsing error | Validate SSML syntax before submission |
| Avatar not speaking | Check script_input is not empty |

### Getting Help

- **Unreal Speech**: [Support](https://unrealspeech.com/support)
- **D-ID**: [Documentation](https://docs.d-id.com/) | [Support](https://www.d-id.com/contact/)
- **Azure Voices**: [Microsoft Documentation](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/)
- **ElevenLabs**: [API Documentation](https://docs.elevenlabs.io/)
- **Amazon Polly**: [AWS Documentation](https://docs.aws.amazon.com/polly/)

---

## Additional Resources

### Official Documentation

- [Unreal Speech API Docs](https://unrealspeech.com/docs)
- [D-ID API Reference](https://docs.d-id.com/)
- [Microsoft Azure Speech](https://speech.microsoft.com/portal)
- [ElevenLabs API](https://api.elevenlabs.io/docs)
- [Amazon Polly Developer Guide](https://docs.aws.amazon.com/polly/latest/dg/)

### AutoGPT Documentation

- [Block SDK Guide](../../BLOCK_SDK.md)
- [LLM Providers Guide](llm-providers.md)
- [AutoGPT Blocks Overview](../README.md)
- [API Reference](../../API_REFERENCE.md)

### Voice Resources

- [Microsoft Voice Gallery](https://speech.microsoft.com/portal/voicegallery)
- [ElevenLabs Voice Library](https://elevenlabs.io/voice-library)
- [AWS Polly Voice List](https://docs.aws.amazon.com/polly/latest/dg/available-voices.html)
- [Unreal Speech Voice Samples](https://unrealspeech.com/voices)

---

## Update History

- **2026-01-29**: Added Unreal Speech TTS provider, restructured guide, enhanced D-ID documentation
- **Previous**: Initial D-ID voice provider documentation