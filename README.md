# Amber

A tiny Mac menu bar app that saves a post from X as one self-contained `.html` file: text, real links, photos, video, quoted post, community note. Works offline, survives the post or account being deleted.

Press **Control + Option + Command + S** with a post open in your browser. Amber saves it to `iCloud Drive/Saved Tweets/` and shows a notification.

Not affiliated with X Corp.

## Install

1. Download `Amber.zip` from the latest [Release](../../releases) (or from a build under [Actions](../../actions)).
2. Double-click the zip, drag **Amber** into **Applications**.
3. Open Amber. macOS blocks it the first time because it isn't signed with a paid Apple Developer account:
   - Click **Done** on the warning.
   - Open **System Settings → Privacy & Security**, scroll down, click **Open Anyway** next to "Amber was blocked", then confirm.
4. Allow notifications when asked.
5. The first time Amber reads a browser tab, macOS asks to let Amber control that browser. Click **Allow**.

## Using it

Hotkey, or the amber stone in the menu bar → **Save Tweet**. Amber looks for the post in this order:

1. The browser tab in front, if it's showing one post (Chrome, Safari, Brave, Edge, Arc).
2. The clipboard (on the timeline: Share → **Copy link**, then the hotkey).

Menu: Save Tweet · Open Saved Tweets Folder · Choose Save Folder… · Change Hotkey… · Launch at Login · Show Last Run Log · Quit.

## What gets saved

`@marcgmbh - made a website to turn images into playlists.html`

- Named after the account and the post's first line (about 60 characters). Different posts with the same name get " 2", " 3".
- Photos, avatar and video are packed inside as base64. Videos over 150 MB stay as a separate `.mp4` next to the page.
- Saving the same post twice does nothing (each file starts with `<!-- tweet-id: N -->`).
- The raw API data is embedded in the page (`<script id="raw-tweet">`).

Data comes from [FxTwitter](https://github.com/FixTweet/FxTwitter)'s public API, with X's embed service as a fallback (cuts off long posts; the page says so). Neither is official, so either can break.

## How it's built

- Swift + AppKit, macOS 14+.
- Hotkey and recorder: [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) by Sindre Sorhus.
- The saving itself is `Resources/save-tweet`, a zsh script using `curl` and `jq` (both built into macOS 15+). Amber runs it and shows its last line.
- GitHub Actions builds the app on a macOS runner (`.github/workflows/build.yml`). Push a `v*` tag to publish a Release.

To build locally: `brew install xcodegen && xcodegen generate && open Amber.xcodeproj`.

The script works on its own too: `zsh Resources/save-tweet "https://x.com/user/status/123"`.

## Why macOS warns you the first time

Apple wants every Mac app stamped with a registered developer ID and checked by Apple. That costs $99 a year, and Amber doesn't have it. So:

- The first time you open Amber, macOS says it can't verify it. You click **Open Anyway** once (see Install).
- After you update Amber, macOS may not recognize it as the same app and ask again for permission to read your browser tab. Click **Allow** again.

That's all. If Amber ever gets Apple's stamp, both go away.
