# Amber

A tiny Mac menu bar app that saves a post from X as one self-contained `.html` file: text, real links, photos, video, quoted post, community note. Works offline, survives the post or account being deleted.

Press **Control + Option + Command + S** with a post open in your browser. Amber saves it to `iCloud Drive/Saved Tweets/` and shows a notification.

Not affiliated with X Corp.

## Install

1. Download **[Amber.zip](https://github.com/tessera1985/amber/releases/latest/download/Amber.zip)**.
   - Use this link. Don't use the green **Code → Download ZIP** button or **Source code (zip)** on the Release page: those are the source code and have no app inside.
2. Open your **Downloads** folder. Double-click `Amber.zip` to unzip it (Safari may have unzipped it already). You get an app called **Amber** with an amber stone icon. Drag it into **Applications**.
3. Open Amber. macOS blocks it the first time because it isn't signed with a paid Apple Developer account:
   - Click **Done** on the warning.
   - Open **System Settings → Privacy & Security**, scroll down, click **Open Anyway** next to "Amber was blocked", then confirm.
4. Allow notifications when asked.
5. The first time Amber reads a browser tab, macOS asks to let Amber control that browser. Click **Allow**.

## Using it

Hotkey, or the amber stone in the menu bar → **Save Tweet**. Amber looks for the post in this order:

1. The browser tab in front, if it's showing one post (Chrome, Safari, Brave, Edge, Arc, Search).
2. The clipboard (on the timeline: Share → **Copy link**, then the hotkey).

Menu: Save Tweet · Open Saved Tweets Folder · Choose Save Folder… · Change Hotkey… · Launch at Login · Show Last Run Log · Quit.

## What gets saved

`@marcgmbh - made a website to turn images into playlists.html`

- Named after the account and the post's first line (about 60 characters). Different posts with the same name get " 2", " 3".
- Photos, avatar and video are packed inside as base64. Videos over 150 MB stay as a separate `.mp4` next to the page.
- Saving the same post twice does nothing (each file starts with `<!-- tweet-id: N -->`).
- The raw API data is embedded in the page (`<script id="raw-tweet">`).

Data comes from [FxTwitter](https://github.com/FixTweet/FxTwitter)'s public API, with X's embed service as a fallback (cuts off long posts; the page says so). Neither is official, so either can break.

## For developers

You don't need this to use Amber.

- Swift + AppKit, macOS 15 or newer.
- Hotkey and recorder: [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) by Sindre Sorhus.
- The saving is done by `Resources/save-tweet`, a zsh script using `curl` and `jq` (both built into macOS 15+). Amber runs it and shows its last line. It also works on its own: `zsh Resources/save-tweet "https://x.com/user/status/123"`.
- GitHub Actions builds the app (`.github/workflows/build.yml`). Each build of `main` publishes the Release for the version in `project.yml`.
- To build on your own Mac: `brew install xcodegen && xcodegen generate && open Amber.xcodeproj`.

## Why macOS warns you the first time

Apple wants every Mac app stamped with a registered developer ID and checked by Apple. That costs $99 a year, and Amber doesn't have it. So:

- The first time you open Amber, macOS says it can't verify it. You click **Open Anyway** once (see Install).
- After you update Amber, macOS may not recognize it as the same app and ask again for permission to read your browser tab. Click **Allow** again.

That's all. If Amber ever gets Apple's stamp, both go away.
