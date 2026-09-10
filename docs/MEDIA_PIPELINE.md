# LUSTER 360 — MEDIA PROCESSING PIPELINE SPECIFICATION

## 1. Overview

The LUSTER 360 media pipeline transforms high-speed raw video captured on the 360 booth arm into broadcast-grade commercial video deliverables in under 15 seconds. The pipeline runs locally on device hardware using hardware-accelerated FFmpeg filters, ensuring zero cloud dependency for the physical guest experience.

```
RAW CAPTURE (120 FPS MP4)
      │
      ▼
[ 1. SPEED RAMPING ] ──► Split segments, apply setpts & atempo, concat
      │
      ▼
[ 2. DIRECTION/BOOMERANG ] ──► Optional reverse or forward+reverse loop
      │
      ▼
[ 3. COLOR GRADING ] ──► Color balance, saturation, cinematic curves
      │
      ▼
[ 4. LAYER COMPOSITING ] ──► Multi-layer PNG overlay stack (logos, frames)
      │
      ▼
[ 5. AUDIO MIXING ] ──► Ambient sound + background music ducking
      │
      ▼
[ 6. H.264 / AAC ENCODE ] ──► FastStart MP4 (1080x1920 @ 30 FPS)
      │
      ▼
[ 7. THUMBNAIL POSTER ] ──► Crisp keyframe extraction at t=2.5s
```

---

## 2. Speed Ramping Mathematics & Filter Complex

### 2.1 Video Presentation Timestamp (`setpts`)
For any speed segment $[t_{\text{start}}, t_{\text{end}}]$ with target speed multiplier $S \in [0.2, 4.0]$:
$$\text{PTS Multiplier} = \frac{1}{S}$$

- **Fast Motion ($S = 2.0$)**: $\text{setpts} = 0.5 \times \text{PTS}$ (compresses frame timestamps).
- **Slow Motion ($S = 0.5$)**: $\text{setpts} = 2.0 \times \text{PTS}$ (expands frame timestamps).
- **Audio Compensation (`atempo`)**: The `atempo` filter adjusts audio playback rate without modifying pitch:
  $$\text{atempo} = S$$

### 2.2 Segment Filtergraph Assembly
For $N$ segments, the filter complex generates dedicated trim nodes:
```text
[0:v]trim=start=0:end=3,setpts=PTS-STARTPTS,setpts=0.5*PTS[v0];
[0:a]atrim=start=0:end=3,asetpts=PTS-STARTPTS,atempo=2.0[a0];
[0:v]trim=start=3:end=7,setpts=PTS-STARTPTS,setpts=2.0*PTS[v1];
[0:a]atrim=start=3:end=7,asetpts=PTS-STARTPTS,atempo=0.5[a1];
[0:v]trim=start=7:end=10,setpts=PTS-STARTPTS,setpts=0.5*PTS[v2];
[0:a]atrim=start=7:end=10,asetpts=PTS-STARTPTS,atempo=2.0[a2];
[v0][a0][v1][a1][v2][a2]concat=n=3:v=1:a=1[v_ramped][a_ramped];
```

---

## 3. Direction & Boomerang Processing

### 3.1 Standard Reverse
Reverses both video and audio streams:
```text
[v_ramped]reverse[v_rev];
[a_ramped]areverse[a_rev];
```

### 3.2 Boomerang Looping
Appends the reversed stream immediately after the forward stream, creating a smooth forward-backward bounce:
```text
[v_ramped]reverse[v_rev];
[a_ramped]areverse[a_rev];
[v_ramped][a_ramped][v_rev][a_rev]concat=n=2:v=1:a=1[v_boom][a_boom];
```

---

## 4. Color Grading Filter Graphs

LUSTER 360 provides 6 hardware-optimized color presets using FFmpeg's `colorbalance`, `eq`, and `hue` native filters:

| Filter Name | FFmpeg Filter Graph | Visual Style |
|---|---|---|
| **Normal** | *(None)* | Unaltered natural colors |
| **Warm** | `colorbalance=rs=0.08:gs=0.02:bs=-0.08` | Golden hour warmth, flattering skin tones |
| **Cool** | `colorbalance=rs=-0.08:gs=0.0:bs=0.12` | Modern crisp blue tone, corporate clean |
| **Contrast** | `eq=contrast=1.15:brightness=0.02:saturation=1.2` | Punchy dynamic colors, high pop |
| **Black & White** | `hue=s=0,eq=contrast=1.1` | Timeless monochrome, editorial wedding |
| **Cinematic** | `eq=contrast=1.1:saturation=1.15,colorbalance=rs=0.04:bs=-0.04` | Teal/orange filmic contrast |

---

## 5. Layer-Based Overlay Compositing

Overlays support static PNG frames, watermarks, corporate branding banners, and corner logos. Coordinates are defined normalized $[0.0, 1.0]$ with center-anchor positioning:

$$\text{pos}_x = \text{main\_w} \times x_{\text{norm}} - \frac{\text{overlay\_w}}{2}$$
$$\text{pos}_y = \text{main\_h} \times y_{\text{norm}} - \frac{\text{overlay\_h}}{2}$$

```text
[v_graded][1:v]overlay=x=main_w*0.5-overlay_w/2:y=main_h*0.9-overlay_h/2:format=auto[v_overlay_0];
```
- The `:format=auto` flag preserves full 8-bit alpha transparency with premultiplied alpha channel blending.

---

## 6. Background Audio Mixing & Ducking

When an event soundtrack is configured:
1. The background music input is padded or truncated to match video duration.
2. Volume is scaled according to operator configuration (`volume=0.85`).
3. Audio streams are blended using `amix`:
```text
[2:a]volume=0.85[a_bg];
[a_ramped][a_bg]amix=inputs=2:duration=first:dropout_transition=2[a_final];
```
- `duration=first`: Video duration dictates master length; music cuts cleanly when video ends.
- `dropout_transition=2`: Prevents audible clicks or sudden volume spikes when audio streams mix.

---

## 7. Master Video Encoding Parameters

```bash
ffmpeg -y \
  -i input.mp4 \
  -filter_complex "[...]" \
  -map "[v_final]" \
  -map "[a_final]" \
  -c:v libx264 \
  -preset veryfast \
  -profile:v high \
  -pix_fmt yuv420p \
  -c:a aac \
  -b:a 192k \
  -movflags +faststart \
  output.mp4
```

### Encoding Parameter Rationale:
- `-c:v libx264`: Universal industry-standard H.264 codec playable across every mobile browser, iOS Safari, Android Chrome, and desktop operating system.
- `-preset veryfast`: Delivers the optimal sweet spot between mobile CPU/GPU thermal limits and encoding throughput (rendering 15s clips in ~8-12 seconds on modern smartphones).
- `-profile:v high`: Enables CABAC entropy coding and 8x8 DCT transform for maximum visual quality per bit.
- `-pix_fmt yuv420p`: Enforces 4:2:0 chroma subsampling required by Apple QuickTime and Android media decoders (avoiding the black screen / audio-only bug).
- `-movflags +faststart`: Moves the `moov` index atom from the end of the file to the front. This enables instantaneous progressive video playback in mobile browsers before the full file finishes downloading.

---

## 8. Poster Thumbnail Extraction

To generate crisp thumbnails for gallery grids and social sharing:
```bash
ffmpeg -y \
  -ss 00:00:02.500 \
  -i output.mp4 \
  -vframes 1 \
  -q:v 2 \
  thumbnail.jpg
```
- `-ss 00:00:02.500`: Seeks to 2.5 seconds into the video, bypassing the initial spin acceleration and capturing guests in full pose.
- `-q:v 2`: High-quality JPEG quantization factor (1-31 scale, 2 = near-lossless).
