# Signal Multiple Desktop Instances (Mac)

![Signal Desktop launcher icon color options](docs/images/icons.png)

Two different tools to help you run multiple Signal instances on your Mac.

1. [Mode 1: Run multiple Signal desktops, each linked to a **different phone**](#mode-1)
2. [Mode 2: Run multiple Signal desktops **without extra phones**](#mode-2)

<a id="mode-1"></a>

# Mode 1: Run multiple Signal desktops, each linked to a different phone

Use this if each Signal account you want on desktop already exists on a phone you control. Each desktop instance links to one phone's account.

1. [Download the Signal launcher helper script here](https://github.com/blanchardjeremy/signal-multiple-desktop-mac/raw/refs/heads/main/signal_multiple_desktop_instances_generator.applescript)  
2. Open the file you downloaded: **signal\_multiple\_desktop\_instances\_generator.applescript**  
3. Click the “Play” icon in the top right corner of the screen.

    <img width="484" height="232" alt="image" src="https://github.com/user-attachments/assets/d1cd97a1-39d8-487d-b639-944085c50ef2" />

   1. Follow the prompts  
   2. Name it. (Example: **Work)**  
   3. Save it to the default location (your **Applications** folder)  
   4. Select an **icon color**. (See screenshot above.)
   5. When prompted, click the **Create Signal-Primary** button
4. Get the correct Signal apps in your dock
   1. First, remove any old Signal you had in your dock bar at the bottom of the screen. **Important: only remove it from the Dock. Do not uninstall the original Signal app.** Right-click the Signal icon in the Dock and choose **Options → Remove from Dock** (or just drag it off the Dock). The Signal app should still exist in your **Applications** folder afterward.
   2. Go to your **Applications** folder  
   3. Drag the new launcher app (**Signal-Work**) to your dock bar  
   4. Drag the primary launcher app (**Signal-Primary**) to your dock bar.  
5. **Open** the new Signal launcher.
6. **Link:** Follow the [usual instructions for linking your new Signal desktop instance to your phone](https://support.signal.org/hc/en-us/articles/360007320551-Linked-Devices).

<a id="mode-2"></a>

# Mode 2: Run multiple Signal desktops without extra phones

Use this if you want additional Signal accounts that live only on your computer, with no physical phone attached. You'll register each new account using a VoIP number (example: Google Voice).

## Quick start

1. **Get a number** you can receive SMS on (see [Phone numbers](#phone-numbers) below).
2. **Install, clone, and run the wizard** ([Homebrew](https://brew.sh/) required for `brew`):

   ```bash
   # Install (zbar is for QR scanning)
   brew install signal-cli zbar
   git clone https://github.com/blanchardjeremy/signal-multiple-desktop-mac
   cd signal-voip-registration-helper
   
   # Interactive setup wizard
   ./signal_voip_helper.py
   ```

The wizard walks you through captcha, SMS verification, optional launcher icon, copying the app to `~/Applications`, daily `signal-cli receive`, turning on registration lock, and linking Desktop (QR code).

**Captcha (registration):** open [signalcaptchas.org/registration/generate.html](https://signalcaptchas.org/registration/generate.html), solve it, right‑click **Open Signal** → **Copy link address**, paste when asked.

## Phone numbers

You need **some** number for Signal; it doesn’t have to be a cell plan. [VOIP](https://en.wikipedia.org/wiki/Voice_over_IP) is fine.

| Option | Notes |
|--------|--------|
| [Google Voice](https://workspace.google.com/products/voice/) | Free. The number can lapse if unused (Google Voice’s rules, not Signal’s). |
| [MySudo](https://anonyome.com/individuals/mysudo/) | Paid tiers. |
| [SMSPool](https://smspool.net/) (and similar) | Cheap temporary numbers. If you don't check it weekly, you could lose the number. If you use this route, set a [Signal PIN](https://support.signal.org/hc/en-us/articles/360007059792-Signal-PIN) as prompted by the wizard.

## Command-line manual uses (skip the wizard)

```bash
./signal_voip_helper.py register +15551112222 --captcha '<token>'
./signal_voip_helper.py addDevice +15551112222
```

| Command | Purpose |
|---------|---------|
| `regenerateLauncher` | Rebuild the `Signal-….app` for an existing profile. Run with no args to pick a profile, or pass `+number`. Use `--copy-to-user-applications` or `-o` if you want it in `~/Applications` or another folder. |
| `installReceiveJob` / `uninstallReceiveJob` | Install or remove a macOS LaunchAgent that runs `signal-cli receive` on a schedule (about twice a day and at login). Logs live under `~/Library/Logs/signal-voip-registration-helper/`. |

Run `./signal_voip_helper.py --help` for flags (`--launcher-icon`, `-o`, etc.).

## Troubleshooting

* **`signal-cli` not found** — Run `brew install signal-cli` and make sure Homebrew’s bin directory is on your `PATH`.
* **No SMS code** — Use international format (`+` and country code). For Google Voice, check spam and filters.
* **Linking fails** — Generate a new QR in Signal Desktop if it may have expired. The pasted link must start with `sgnl://linkdevice?`. Quit Signal Desktop first when the wizard asks (linking won’t work if it is already running).

## Security

Treat phone numbers and codes like secrets. This project doesn’t phone home; Signal traffic is between your machine and Signal’s servers. Data lives under `~/.local/share/signal-cli/data/` and your Desktop profile dirs.

## Features (what’s included)

* Register with **signal-cli**, captcha, and SMS verification. The wizard can turn on **registration lock** with `setPin`.
* **Link Signal Desktop** as a second device (signal-cli stays primary). Helpers for scanning or pasting the link QR.
* **Colored launcher apps** (`Signal-….app`) and optional copy into **`~/Applications`**.
* **Regenerate launcher** if you removed the app or want a different icon or name.
* **Optional daily `receive` job** on macOS (LaunchAgent) so messages are fetched without running `signal-cli` by hand.

## License

[LICENSE.txt](./LICENSE.txt)

## Contributing

Issues and PRs welcome.
